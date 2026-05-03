# install-cli-discovery.ps1 — 0.5.96-product slash-command zero-file discovery hook (Windows)
#
# Mirror of install-cli-discovery.sh. See that file for design rationale.
# Idempotent + graceful (D7 = b).

[CmdletBinding()]
param(
  [string]$SolonRepo = $env:SOLON_REPO,
  [string]$SourceDir = $env:SFS_DISCOVERY_SOURCE_DIR,
  [string]$A1First   = $env:SFS_DISCOVERY_A1_FIRST
)

if (-not $SolonRepo) { $SolonRepo = "MJ-0701/solon" }
if (-not $A1First)   { $A1First   = "1" }

$HomeDir = $env:USERPROFILE
if (-not $HomeDir) { $HomeDir = $HOME }

function Write-Ok    ($msg) { Write-Host "  [OK]   $msg" -ForegroundColor Green }
function Write-Warn  ($msg) { Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Write-Fail  ($msg) { Write-Host "  [FAIL] $msg" -ForegroundColor Red }
function Write-Info  ($msg) { Write-Host "  $msg" }

function Test-CommandExists($cmd) {
  $null = Get-Command $cmd -ErrorAction SilentlyContinue
  return $?
}

function Discover-SourceDir {
  if ($SourceDir -and (Test-Path "$SourceDir\templates\codex-skill\SKILL.md")) { return }
  $selfDir = Split-Path -Parent $PSCommandPath
  $cand = Resolve-Path "$selfDir\.." -ErrorAction SilentlyContinue
  if ($cand -and (Test-Path "$cand\templates\codex-skill\SKILL.md")) {
    $script:SourceDir = $cand.Path; return
  }
  $candidates = @(
    "$HomeDir\scoop\apps\sfs\current",
    "$HomeDir\scoop\persist\sfs",
    "$env:ProgramData\sfs"
  )
  foreach ($c in $candidates) {
    if (Test-Path "$c\templates\codex-skill\SKILL.md") { $script:SourceDir = $c; return }
  }
}

# ---------------------------------------------------------------------------
# Step 1: Claude Code plugin discovery
# ---------------------------------------------------------------------------
function Install-ClaudeDiscovery {
  if (-not (Test-CommandExists "claude")) {
    Write-Info "Claude Code: not on PATH — skip"
    return
  }
  $cv = (& claude --version 2>$null | Select-Object -First 1)
  Write-Info "Claude Code detected: $cv"

  if ($A1First -eq "1") {
    $a1 = (& claude plugin marketplace add $SolonRepo 2>&1 | Out-String)
    if ($a1 -match "(?i)added|already|registered|installed") {
      Write-Ok "Claude Code: marketplace registered via 'claude plugin marketplace add' (A-1)"
      try { & claude plugin install "solon@solon" 2>$null | Out-Null } catch {}
      Write-Ok "Claude Code: /sfs slash should be discoverable on next session restart"
      return
    }
    Write-Warn "Claude Code: A-1 CLI subcommand path unavailable on this version"
    Write-Warn "  $($a1 -split [Environment]::NewLine | Select-Object -First 1)"
  }

  # A-2 fallback: filesystem-direct + settings.json merge
  $pluginDest = "$HomeDir\.claude\plugins\solon"
  New-Item -ItemType Directory -Force -Path "$pluginDest\.claude-plugin", "$pluginDest\commands" | Out-Null

  if (Test-CommandExists "git") {
    $tmp = Join-Path $env:TEMP "solon-clone-$([guid]::NewGuid().ToString('N').Substring(0,8))"
    try {
      & git clone --depth 1 "https://github.com/$SolonRepo.git" $tmp 2>$null | Out-Null
      if ($LASTEXITCODE -eq 0 -and (Test-Path "$tmp\plugins\solon")) {
        Copy-Item -Recurse -Force "$tmp\plugins\solon\*" $pluginDest
        Write-Ok "Claude Code: plugin filesystem-direct deployed at ~/.claude/plugins/solon (A-2)"
      } else {
        Write-Warn "Claude Code: git clone of $SolonRepo failed or missing plugins/solon — A-2 skipped"
      }
    } finally {
      if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }
    }
  } else {
    Write-Warn "Claude Code: git not on PATH — A-2 cannot deploy plugin filesystem"
    Write-Warn "  Install git: winget install --id Git.Git"
  }

  # settings.json merge (PowerShell-native JSON, no jq dependency)
  $settings = "$HomeDir\.claude\settings.json"
  $obj = $null
  if (Test-Path $settings) {
    try { $obj = Get-Content $settings -Raw | ConvertFrom-Json } catch { $obj = $null }
  }
  if (-not $obj) { $obj = [pscustomobject]@{} }
  if (-not $obj.PSObject.Properties['extraKnownMarketplaces']) {
    $obj | Add-Member -NotePropertyName 'extraKnownMarketplaces' -NotePropertyValue ([pscustomobject]@{})
  }
  if (-not $obj.PSObject.Properties['enabledPlugins']) {
    $obj | Add-Member -NotePropertyName 'enabledPlugins' -NotePropertyValue ([pscustomobject]@{})
  }
  $obj.extraKnownMarketplaces | Add-Member -Force -NotePropertyName 'solon' -NotePropertyValue ([pscustomobject]@{ source = "https://github.com/$SolonRepo" })
  $obj.enabledPlugins         | Add-Member -Force -NotePropertyName 'solon@solon' -NotePropertyValue $true
  $obj | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 $settings
  Write-Ok "Claude Code: ~/.claude/settings.json updated (extraKnownMarketplaces + enabledPlugins)"
}

# ---------------------------------------------------------------------------
# Step 2: Gemini CLI extension
# ---------------------------------------------------------------------------
function Install-GeminiDiscovery {
  if (-not (Test-CommandExists "gemini")) {
    Write-Info "Gemini CLI: not on PATH — skip"
    return
  }
  if (-not (Test-CommandExists "git")) {
    Write-Warn "Gemini CLI: git not on PATH — extension install requires git"
    Write-Warn "  Install git: winget install --id Git.Git"
    Write-Warn "  Then retry:  gemini extensions install --consent https://github.com/$SolonRepo.git"
    return
  }

  Write-Info "Gemini CLI detected"
  $list = (& gemini extensions list 2>$null | Out-String)
  if ($list -match "solon|MJ-0701/solon") {
    Write-Ok "Gemini CLI: solon extension already installed — skip"
    return
  }

  $out = (& gemini extensions install --consent --auto-update "https://github.com/$SolonRepo.git" 2>&1 | Out-String)
  if ($out -match "(?i)installed|already") {
    Write-Ok "Gemini CLI: extension installed via 'gemini extensions install --consent'"
  } else {
    Write-Warn "Gemini CLI: extension install did not confirm success"
    Write-Warn "  Manual recovery: gemini extensions install --consent https://github.com/$SolonRepo.git"
  }
}

# ---------------------------------------------------------------------------
# Step 3: Codex CLI user-global skill (C-1)
# ---------------------------------------------------------------------------
function Install-CodexDiscovery {
  Discover-SourceDir
  if (-not $SourceDir -or -not (Test-Path "$SourceDir\templates\codex-skill\SKILL.md")) {
    Write-Warn "Codex CLI: source bundle not found — skip"
    Write-Warn "  (templates\codex-skill\SKILL.md missing under SourceDir)"
    return
  }
  $destDir = "$HomeDir\.codex\skills\sfs"
  New-Item -ItemType Directory -Force -Path $destDir | Out-Null
  Copy-Item -Force "$SourceDir\templates\codex-skill\SKILL.md" "$destDir\SKILL.md"
  Write-Ok "Codex CLI: user-global skill installed at ~/.codex/skills/sfs/SKILL.md (C-1)"
  if (-not (Test-CommandExists "codex")) {
    Write-Info "  (Codex CLI not on PATH; skill ready for when it is installed)"
  }
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Solon CLI discovery (slash-command zero-file)" -ForegroundColor Cyan
Write-Host ""
Install-ClaudeDiscovery
Write-Host ""
Install-GeminiDiscovery
Write-Host ""
Install-CodexDiscovery
Write-Host ""

@"
Verify with:
  sfs doctor            — check all three CLI discovery paths
  claude  → /sfs        — Claude Code slash command autocomplete
  gemini  → sfs status  — Gemini CLI command
  codex   → `$sfs status — Codex CLI Skill invocation

If any step warned above, the manual recovery line printed alongside is
the one-shot fix. The scoop install of `sfs` itself is unaffected.
"@ | Write-Host

exit 0
