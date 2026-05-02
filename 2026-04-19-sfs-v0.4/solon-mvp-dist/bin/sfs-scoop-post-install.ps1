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

Push-Location $projectRoot
try {
  $env:SFS_SKIP_SELF_UPGRADE = "1"
  $env:SFS_UPDATE_SELF = "0"
  if (-not $env:SFS_UPGRADE_LAYOUT) {
    $env:SFS_UPGRADE_LAYOUT = "thin"
  }

  & $sfsCmd upgrade --no-self-upgrade
  $exitCode = $LASTEXITCODE
  if ($exitCode -ne 0) {
    throw "Solon project upgrade failed with exit code $exitCode"
  }
} finally {
  Restore-SfsEnvValue "SFS_SKIP_SELF_UPGRADE" $oldSkipSelfUpgrade
  Restore-SfsEnvValue "SFS_UPDATE_SELF" $oldUpdateSelf
  Restore-SfsEnvValue "SFS_UPGRADE_LAYOUT" $oldUpgradeLayout
  Pop-Location
}
