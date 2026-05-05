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

if (-not $SolonRepo) { $SolonRepo = "MJ-0701/solon-product" }
if (-not $A1First)   { $A1First   = "1" }
$PromoteFirst = $env:SFS_DISCOVERY_PROMOTE_FIRST
if (-not $PromoteFirst) { $PromoteFirst = "1" }
$ForcePromote = $env:SFS_DISCOVERY_FORCE_PROMOTE
if (-not $ForcePromote) { $ForcePromote = "0" }

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

function To-OrderedMap($obj) {
  $map = [ordered]@{}
  if ($obj) {
    foreach ($p in $obj.PSObject.Properties) {
      $map[$p.Name] = $p.Value
    }
  }
  return $map
}

function Get-PriorityMarkerPath {
  return "$HomeDir\.sfs\discovery-priority.json"
}

function Test-PriorityMarker([string]$key) {
  $marker = Get-PriorityMarkerPath
  if (-not (Test-Path $marker)) { return $false }
  try {
    $obj = Get-Content $marker -Raw | ConvertFrom-Json
    return ($obj.PSObject.Properties['promoted'] -and
            $obj.promoted.PSObject.Properties[$key] -and
            $obj.promoted.$key -eq $true)
  } catch {
    return $false
  }
}

function Set-PriorityMarker([string]$key) {
  $marker = Get-PriorityMarkerPath
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $marker) | Out-Null
  $obj = $null
  if (Test-Path $marker) {
    try { $obj = Get-Content $marker -Raw | ConvertFrom-Json } catch { $obj = $null }
  }
  if (-not $obj) { $obj = [pscustomobject]@{} }
  if (-not $obj.PSObject.Properties['promoted']) {
    $obj | Add-Member -NotePropertyName 'promoted' -NotePropertyValue ([pscustomobject]@{})
  }
  if (-not $obj.PSObject.Properties['lastPromotedAt']) {
    $obj | Add-Member -NotePropertyName 'lastPromotedAt' -NotePropertyValue ([pscustomobject]@{})
  }
  $obj.promoted | Add-Member -Force -NotePropertyName $key -NotePropertyValue $true
  $obj.lastPromotedAt | Add-Member -Force -NotePropertyName $key -NotePropertyValue ((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
  $obj | Add-Member -Force -NotePropertyName 'policy' -NotePropertyValue 'promote solon to first on install/update; if user later changes order, respect unless SFS_DISCOVERY_FORCE_PROMOTE=1'
  $obj | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 $marker
}

function Should-PromotePriority([string]$key, [string]$currentFirst, [string]$desiredFirst, [string]$label) {
  if ($PromoteFirst -ne "1") {
    Write-Info "$label`: priority promotion disabled by SFS_DISCOVERY_PROMOTE_FIRST=0"
    return $false
  }
  if ($ForcePromote -eq "1") { return $true }
  if (-not $currentFirst -or $currentFirst -eq $desiredFirst) { return $true }
  if (Test-PriorityMarker $key) {
    Write-Warn "$label`: user-managed priority detected (first=$currentFirst) — respecting existing order"
    Write-Warn "  To force Solon first again: `$env:SFS_DISCOVERY_FORCE_PROMOTE=1; sfs upgrade"
    return $false
  }
  return $true
}

function Promote-ClaudePriority {
  $settings = "$HomeDir\.claude\settings.json"
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $settings) | Out-Null
  $obj = $null
  if (Test-Path $settings) {
    try { $obj = Get-Content $settings -Raw | ConvertFrom-Json } catch { $obj = $null }
  }
  if (-not $obj) { $obj = [pscustomobject]@{} }
  $currentFirst = ""
  if ($obj.PSObject.Properties['enabledPlugins'] -and $obj.enabledPlugins.PSObject.Properties.Count -gt 0) {
    $currentFirst = $obj.enabledPlugins.PSObject.Properties[0].Name
  }
  if (-not (Should-PromotePriority "claude" $currentFirst "solon@solon" "Claude Code")) {
    return
  }

  $enabled = [ordered]@{ "solon@solon" = $true }
  if ($obj.PSObject.Properties['enabledPlugins']) {
    foreach ($p in $obj.enabledPlugins.PSObject.Properties) {
      if ($p.Name -ne "solon@solon") { $enabled[$p.Name] = $p.Value }
    }
  }

  $existingSolonMarket = $null
  if ($obj.PSObject.Properties['extraKnownMarketplaces'] -and $obj.extraKnownMarketplaces.PSObject.Properties['solon']) {
    $existingSolonMarket = $obj.extraKnownMarketplaces.solon
  }
  if (-not $existingSolonMarket) {
    $existingSolonMarket = [ordered]@{ source = [ordered]@{ source = "github"; repo = $SolonRepo } }
  }
  $markets = [ordered]@{ "solon" = $existingSolonMarket }
  if ($obj.PSObject.Properties['extraKnownMarketplaces']) {
    foreach ($p in $obj.extraKnownMarketplaces.PSObject.Properties) {
      if ($p.Name -ne "solon") { $markets[$p.Name] = $p.Value }
    }
  }

  $root = [ordered]@{
    enabledPlugins = $enabled
    extraKnownMarketplaces = $markets
  }
  foreach ($p in $obj.PSObject.Properties) {
    if ($p.Name -ne "enabledPlugins" -and $p.Name -ne "extraKnownMarketplaces") {
      $root[$p.Name] = $p.Value
    }
  }
  $root | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 $settings
  Write-Ok "Claude Code: solon promoted to first enabled plugin in ~/.claude/settings.json"

  $installed = "$HomeDir\.claude\plugins\installed_plugins.json"
  if (Test-Path $installed) {
    try {
      $inst = Get-Content $installed -Raw | ConvertFrom-Json
      if ($inst.PSObject.Properties['plugins'] -and $inst.plugins.PSObject.Properties['solon@solon']) {
        $plugins = [ordered]@{ "solon@solon" = $inst.plugins.'solon@solon' }
        foreach ($p in $inst.plugins.PSObject.Properties) {
          if ($p.Name -ne "solon@solon") { $plugins[$p.Name] = $p.Value }
        }
        $instRoot = [ordered]@{}
        foreach ($p in $inst.PSObject.Properties) {
          if ($p.Name -eq "plugins") { $instRoot["plugins"] = $plugins }
          else { $instRoot[$p.Name] = $p.Value }
        }
        $instRoot | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 $installed
        Write-Ok "Claude Code: solon promoted to first plugin registry entry"
      }
    } catch {
      Write-Warn "Claude Code: could not reorder installed_plugins.json"
    }
  }

  $known = "$HomeDir\.claude\plugins\known_marketplaces.json"
  if (Test-Path $known) {
    try {
      $km = Get-Content $known -Raw | ConvertFrom-Json
      $solonMarket = $null
      if ($km.PSObject.Properties['solon']) { $solonMarket = $km.solon }
      if (-not $solonMarket) {
        $solonMarket = [ordered]@{ source = [ordered]@{ source = "github"; repo = $SolonRepo } }
      }
      $kmRoot = [ordered]@{ "solon" = $solonMarket }
      foreach ($p in $km.PSObject.Properties) {
        if ($p.Name -ne "solon") { $kmRoot[$p.Name] = $p.Value }
      }
      $kmRoot | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 $known
      Write-Ok "Claude Code: solon promoted to first marketplace registry entry"
    } catch {
      Write-Warn "Claude Code: could not reorder known_marketplaces.json"
    }
  }
  Set-PriorityMarker "claude"
}

function Promote-GeminiPriority {
  $enable = "$HomeDir\.gemini\extensions\extension-enablement.json"
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $enable) | Out-Null
  $obj = $null
  if (Test-Path $enable) {
    try { $obj = Get-Content $enable -Raw | ConvertFrom-Json } catch { $obj = $null }
  }
  if (-not $obj) { $obj = [pscustomobject]@{} }
  $currentFirst = ""
  if ($obj.PSObject.Properties.Count -gt 0) { $currentFirst = $obj.PSObject.Properties[0].Name }
  if (-not (Should-PromotePriority "gemini" $currentFirst "solon" "Gemini CLI")) {
    return
  }
  $solonEntry = $null
  if ($obj.PSObject.Properties['solon']) { $solonEntry = $obj.solon }
  if (-not $solonEntry) { $solonEntry = [ordered]@{ overrides = @("$HomeDir\*") } }
  $root = [ordered]@{ "solon" = $solonEntry }
  foreach ($p in $obj.PSObject.Properties) {
    if ($p.Name -ne "solon") { $root[$p.Name] = $p.Value }
  }
  $root | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 $enable
  Write-Ok "Gemini CLI: solon promoted to first extension enablement entry"
  Set-PriorityMarker "gemini"
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
      Promote-ClaudePriority
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

  # Settings/registry merge + ordering. Install/update exposes SFS first, but
  # later user-managed priority changes are respected unless forced.
  Promote-ClaudePriority
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
  $extensionDir = "$HomeDir\.gemini\extensions\solon"
  if ((Test-Path "$extensionDir\gemini-extension.json") -or (Test-Path "$extensionDir\commands\sfs.toml")) {
    Write-Ok "Gemini CLI: solon extension filesystem present at ~/.gemini/extensions/solon"
    Promote-GeminiPriority
    return
  }

  $list = (& gemini extensions list 2>$null | Out-String)
  if ($list -match "solon|MJ-0701/solon-product") {
    Write-Ok "Gemini CLI: solon extension already installed — skip"
    Promote-GeminiPriority
    return
  }

  $out = (& gemini extensions install --consent --auto-update "https://github.com/$SolonRepo.git" 2>&1 | Out-String)
  if ($out -match "(?i)installed|already") {
    Write-Ok "Gemini CLI: extension installed via 'gemini extensions install --consent'"
    Promote-GeminiPriority
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
  Write-Ok "Codex CLI: priority-1 user-global skill installed at ~/.codex/skills/sfs/SKILL.md (C-1)"
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
