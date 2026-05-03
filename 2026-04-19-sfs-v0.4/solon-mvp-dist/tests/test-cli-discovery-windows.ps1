# test-cli-discovery-windows.ps1 — Windows-side mirror of test-cli-discovery-macos.sh
#
# Tests:
#   T1  Codex skill copied to $HOME\.codex\skills\sfs\SKILL.md
#   T2  Hook exits 0 when claude/gemini/codex NOT on PATH (graceful)
#   T3  Idempotency: re-run yields identical state
#   T4  Source-dir auto-detect when invoked from script dir
#
# Exit: 0 = all pass, 1 = any failure

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $PSCommandPath
$distDir   = Resolve-Path "$scriptDir\.."
$hook      = Join-Path $distDir "scripts\install-cli-discovery.ps1"
$skillSrc  = Join-Path $distDir "templates\codex-skill\SKILL.md"

if (-not (Test-Path $hook))     { Write-Error "hook not found at $hook"; exit 2 }
if (-not (Test-Path $skillSrc)) { Write-Error "SKILL.md not found at $skillSrc"; exit 2 }

$pass = 0; $fail = 0
function Report([string]$label, [string]$outcome, [string]$detail = "") {
  if ($outcome -eq "PASS") {
    Write-Host ("  [PASS] " + $label) -ForegroundColor Green
    $script:pass++
  } else {
    Write-Host ("  [FAIL] " + $label + "  " + $detail) -ForegroundColor Red
    $script:fail++
  }
}

# Sandbox temp HOME
$tmpHome = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("solon-disc-" + [guid]::NewGuid().ToString('N').Substring(0,8))) -Force

try {
  $oldHome = $env:USERPROFILE
  $oldHomeUnix = $env:HOME
  $oldPath = $env:PATH
  $oldSrc = $env:SFS_DISCOVERY_SOURCE_DIR

  $env:USERPROFILE = $tmpHome.FullName
  $env:HOME        = $tmpHome.FullName
  # Trim PATH so claude/gemini/codex are unlikely to be present
  $env:PATH = "$env:SystemRoot\System32;$env:SystemRoot"
  $env:SFS_DISCOVERY_SOURCE_DIR = $distDir.Path

  # Run 1: with SFS_DISCOVERY_SOURCE_DIR set
  $log1 = Join-Path $tmpHome "run1.log"
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $hook *> $log1
  $exit1 = $LASTEXITCODE
  if ($exit1 -eq 0) { Report "T2 graceful exit 0 (no CLIs)" "PASS" }
  else              { Report "T2 graceful exit 0 (no CLIs)" "FAIL" "exit=$exit1" }

  $skillDest = Join-Path $tmpHome ".codex\skills\sfs\SKILL.md"
  if (Test-Path $skillDest) {
    if ((Get-FileHash $skillSrc).Hash -eq (Get-FileHash $skillDest).Hash) {
      Report "T1 codex skill installed (C-1)" "PASS"
    } else {
      Report "T1 codex skill installed (C-1)" "FAIL" "content mismatch"
    }
  } else {
    Report "T1 codex skill installed (C-1)" "FAIL" "file missing"
  }

  # Run 2: without SFS_DISCOVERY_SOURCE_DIR (auto-detect)
  Remove-Item -Recurse -Force (Join-Path $tmpHome ".codex") -ErrorAction SilentlyContinue
  $env:SFS_DISCOVERY_SOURCE_DIR = $null
  $log2 = Join-Path $tmpHome "run2.log"
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $hook *> $log2
  $exit2 = $LASTEXITCODE
  if ($exit2 -eq 0 -and (Test-Path $skillDest)) {
    Report "T4 source-dir auto-detect" "PASS"
  } else {
    $present = if (Test-Path $skillDest) { "present" } else { "missing" }
    Report "T4 source-dir auto-detect" "FAIL" "exit=$exit2 file=$present"
  }

  # Run 3: idempotency
  $env:SFS_DISCOVERY_SOURCE_DIR = $distDir.Path
  $log3 = Join-Path $tmpHome "run3.log"
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $hook *> $log3
  $exit3 = $LASTEXITCODE
  if ($exit3 -eq 0 -and (Get-FileHash $skillSrc).Hash -eq (Get-FileHash $skillDest).Hash) {
    Report "T3 idempotent re-run" "PASS"
  } else {
    Report "T3 idempotent re-run" "FAIL" "exit=$exit3"
  }
}
finally {
  $env:USERPROFILE = $oldHome
  $env:HOME        = $oldHomeUnix
  $env:PATH        = $oldPath
  $env:SFS_DISCOVERY_SOURCE_DIR = $oldSrc
  Remove-Item -Recurse -Force $tmpHome -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host ("  pass: $pass   fail: $fail")
if ($fail -eq 0) { exit 0 } else { exit 1 }
