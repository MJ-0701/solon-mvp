param()

$ErrorActionPreference = "Stop"

function Restore-SfsEnvValue([string] $Name, $Value) {
  if ($null -eq $Value) {
    Remove-Item "Env:$Name" -ErrorAction SilentlyContinue
  } else {
    Set-Item "Env:$Name" $Value
  }
}

function Find-SfsProjectRoot([string] $StartDir) {
  $item = Get-Item -LiteralPath $StartDir -ErrorAction SilentlyContinue
  while ($item) {
    $versionFile = Join-Path $item.FullName ".sfs-local\VERSION"
    $projectFile = Join-Path $item.FullName "SFS.md"
    if ((Test-Path $versionFile) -and (Test-Path $projectFile)) {
      return $item.FullName
    }
    $item = $item.Parent
  }
  return $null
}

# 0.5.96-product slash-command zero-file discovery hook.
# Always runs on `scoop install sfs` and `scoop update sfs` (idempotent).
# Project upgrade path below sets SFS_SKIP_CLI_DISCOVERY=1 to avoid running
# the same hook twice when sfs upgrade also calls it.
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$discoveryPs1 = Join-Path (Split-Path -Parent $scriptDir) "scripts\install-cli-discovery.ps1"
if (Test-Path $discoveryPs1) {
  $oldDiscoverySource = $env:SFS_DISCOVERY_SOURCE_DIR
  try {
    $env:SFS_DISCOVERY_SOURCE_DIR = (Split-Path -Parent $scriptDir)
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $discoveryPs1
  } catch {
    Write-Warning "cli-discovery (scoop) hook failed: $($_.Exception.Message) — continuing"
  } finally {
    Restore-SfsEnvValue "SFS_DISCOVERY_SOURCE_DIR" $oldDiscoverySource
  }
} else {
  Write-Host "cli-discovery hook not found at $discoveryPs1 — slash-command discovery skipped"
}

if ($env:SFS_SCOOP_PROJECT_UPGRADE -eq "0") {
  Write-Host "Solon SFS runtime updated. Project upgrade hook skipped by SFS_SCOOP_PROJECT_UPGRADE=0."
  exit 0
}

$startDir = (Get-Location).ProviderPath
$projectRoot = Find-SfsProjectRoot $startDir

if (-not $projectRoot) {
  Write-Host "Solon SFS runtime updated. Project files were not changed; run sfs.cmd upgrade in an initialized project when needed."
  exit 0
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sfsCmd = Join-Path $scriptDir "sfs.cmd"
if (-not (Test-Path $sfsCmd)) {
  throw "missing packaged SFS command wrapper: $sfsCmd"
}

Write-Host "Solon project detected: $projectRoot"
Write-Host "running project upgrade after Scoop runtime update..."

$oldSkipSelfUpgrade = $env:SFS_SKIP_SELF_UPGRADE
$oldUpdateSelf = $env:SFS_UPDATE_SELF
$oldUpgradeLayout = $env:SFS_UPGRADE_LAYOUT
$oldSkipDiscovery = $env:SFS_SKIP_CLI_DISCOVERY

Push-Location $projectRoot
try {
  $env:SFS_SKIP_SELF_UPGRADE = "1"
  $env:SFS_UPDATE_SELF = "0"
  if (-not $env:SFS_UPGRADE_LAYOUT) {
    $env:SFS_UPGRADE_LAYOUT = "thin"
  }
  # cli-discovery already ran above — skip in sfs upgrade to avoid double-run
  $env:SFS_SKIP_CLI_DISCOVERY = "1"

  & $sfsCmd upgrade --no-self-upgrade
  $exitCode = $LASTEXITCODE
  if ($exitCode -ne 0) {
    throw "Solon project upgrade failed with exit code $exitCode"
  }
} finally {
  Restore-SfsEnvValue "SFS_SKIP_SELF_UPGRADE" $oldSkipSelfUpgrade
  Restore-SfsEnvValue "SFS_UPDATE_SELF" $oldUpdateSelf
  Restore-SfsEnvValue "SFS_UPGRADE_LAYOUT" $oldUpgradeLayout
  Restore-SfsEnvValue "SFS_SKIP_CLI_DISCOVERY" $oldSkipDiscovery
  Pop-Location
}
