# test-cli-discovery-windows.ps1 — Windows-side mirror of test-cli-discovery-macos.sh
#
# Tests:
#   T1  Codex skill copied to $HOME\.codex\skills\sfs\SKILL.md
#   T2  Hook exits 0 when claude/gemini/codex NOT on PATH (graceful)
#   T3  Idempotency: re-run yields identical state
#   T4  Source-dir auto-detect when invoked from script dir
#   T5  Claude plugin settings/registries promote solon to first on install/update
#   T6  Later user-managed priority change is respected unless forced
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

  # Run 4: fake Claude present; hook must promote solon before existing entries.
  $fakeBin = Join-Path $tmpHome "fakebin"
  New-Item -ItemType Directory -Force -Path $fakeBin | Out-Null
  $fakeClaude = Join-Path $fakeBin "claude.cmd"
  @"
@echo off
if "%1"=="--version" (
  echo claude fake 1.0.0
  exit /b 0
)
echo already installed
exit /b 0
"@ | Set-Content -Encoding ASCII $fakeClaude

  $claudeDir = Join-Path $tmpHome ".claude"
  $pluginsDir = Join-Path $claudeDir "plugins"
  New-Item -ItemType Directory -Force -Path $pluginsDir | Out-Null
  @"
{
  "enabledPlugins": {
    "bkit@bkit-marketplace": true,
    "solon@solon": true,
    "other@market": true
  },
  "extraKnownMarketplaces": {
    "bkit-marketplace": { "source": { "source": "github", "repo": "popup-studio-ai/bkit-claude-code" } },
    "solon": { "source": { "source": "github", "repo": "MJ-0701/solon-product" } }
  }
}
"@ | Set-Content -Encoding UTF8 (Join-Path $claudeDir "settings.json")
  @"
{
  "version": 2,
  "plugins": {
    "bkit@bkit-marketplace": [],
    "solon@solon": [],
    "other@market": []
  }
}
"@ | Set-Content -Encoding UTF8 (Join-Path $pluginsDir "installed_plugins.json")
  @"
{
  "bkit-marketplace": { "source": { "source": "github", "repo": "popup-studio-ai/bkit-claude-code" } },
  "solon": { "source": { "source": "github", "repo": "MJ-0701/solon-product" } }
}
"@ | Set-Content -Encoding UTF8 (Join-Path $pluginsDir "known_marketplaces.json")

  $env:PATH = "$fakeBin;$env:SystemRoot\System32;$env:SystemRoot"
  $env:SFS_DISCOVERY_SOURCE_DIR = $distDir.Path
  $log4 = Join-Path $tmpHome "run4.log"
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $hook *> $log4
  $exit4 = $LASTEXITCODE
  $settings = Get-Content (Join-Path $claudeDir "settings.json") -Raw | ConvertFrom-Json
  $installed = Get-Content (Join-Path $pluginsDir "installed_plugins.json") -Raw | ConvertFrom-Json
  $known = Get-Content (Join-Path $pluginsDir "known_marketplaces.json") -Raw | ConvertFrom-Json
  $firstEnabled = $settings.enabledPlugins.PSObject.Properties[0].Name
  $firstMarket = $settings.extraKnownMarketplaces.PSObject.Properties[0].Name
  $firstRegistry = $installed.plugins.PSObject.Properties[0].Name
  $firstKnown = $known.PSObject.Properties[0].Name
  if ($exit4 -eq 0 -and
      $firstEnabled -eq "solon@solon" -and
      $firstMarket -eq "solon" -and
      $firstRegistry -eq "solon@solon" -and
      $firstKnown -eq "solon") {
    Report "T5 solon priority on install/update" "PASS"
  } else {
    Report "T5 solon priority on install/update" "FAIL" "exit=$exit4 enabled=$firstEnabled market=$firstMarket registry=$firstRegistry known=$firstKnown"
  }

  # Run 5: after T5 writes the marker, a later manual reorder should be
  # respected on normal install/update reruns.
  @"
{
  "enabledPlugins": {
    "bkit@bkit-marketplace": true,
    "solon@solon": true
  },
  "extraKnownMarketplaces": {
    "bkit-marketplace": { "source": { "source": "github", "repo": "popup-studio-ai/bkit-claude-code" } },
    "solon": { "source": { "source": "github", "repo": "MJ-0701/solon-product" } }
  }
}
"@ | Set-Content -Encoding UTF8 (Join-Path $claudeDir "settings.json")
  $log5 = Join-Path $tmpHome "run5.log"
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $hook *> $log5
  $exit5 = $LASTEXITCODE
  $settingsAfterUser = Get-Content (Join-Path $claudeDir "settings.json") -Raw | ConvertFrom-Json
  $firstAfterUser = $settingsAfterUser.enabledPlugins.PSObject.Properties[0].Name
  if ($exit5 -eq 0 -and $firstAfterUser -eq "bkit@bkit-marketplace") {
    Report "T6 respect user-managed priority" "PASS"
  } else {
    Report "T6 respect user-managed priority" "FAIL" "exit=$exit5 first=$firstAfterUser"
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
