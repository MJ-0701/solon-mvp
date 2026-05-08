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

function Resolve-SfsScoopRoot([string] $ScriptDir) {
  if ($env:SCOOP -and (Test-Path -LiteralPath $env:SCOOP -PathType Container)) {
    return $env:SCOOP
  }

  $item = Get-Item -LiteralPath $ScriptDir -ErrorAction SilentlyContinue
  while ($item) {
    if ($item.Name -ieq "scoop" -and
        (Test-Path -LiteralPath (Join-Path $item.FullName "apps") -PathType Container)) {
      return $item.FullName
    }
    $item = $item.Parent
  }

  if ($env:USERPROFILE) {
    $fallback = Join-Path $env:USERPROFILE "scoop"
    if (Test-Path -LiteralPath $fallback -PathType Container) {
      return $fallback
    }
  }

  return $null
}

function Install-SfsScoopShims([string] $ScriptDir) {
  $scoopRoot = Resolve-SfsScoopRoot $ScriptDir
  if (-not $scoopRoot) {
    Write-Warning "Scoop root not found; generated shim hardening skipped"
    return
  }

  $shimDir = Join-Path $scoopRoot "shims"
  if (-not (Test-Path -LiteralPath $shimDir -PathType Container)) {
    Write-Warning "Scoop shims directory not found: $shimDir; generated shim hardening skipped"
    return
  }

  $cmdShim = @'
@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "SFS_NATIVE_POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "SFS_NATIVE_SCRIPT=%SCRIPT_DIR%..\apps\sfs\current\bin\sfs.ps1"
if not exist "%SFS_NATIVE_POWERSHELL%" set "SFS_NATIVE_POWERSHELL=powershell.exe"
if not exist "%SFS_NATIVE_SCRIPT%" (
  echo missing packaged SFS PowerShell entrypoint: %SFS_NATIVE_SCRIPT% 1>&2
  exit /b 4
)

set "SFS_NATIVE_ARGC=0"
set "SFS_NATIVE_RAW_ARGS=%*"
:sfs_collect_args
if "%~1"=="" goto sfs_args_done
set /a SFS_NATIVE_ARGC+=1 >NUL
for %%I in (%SFS_NATIVE_ARGC%) do set "SFS_NATIVE_ARG_%%I=%~1"
shift
goto sfs_collect_args

:sfs_args_done
setlocal EnableDelayedExpansion
"%SFS_NATIVE_POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -File "%SFS_NATIVE_SCRIPT%" & exit /b !ERRORLEVEL!
'@

  $psShim = @'
$ErrorActionPreference = "Stop"
$target = Join-Path $PSScriptRoot "..\apps\sfs\current\bin\sfs.ps1"
if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
  Write-Error "missing packaged SFS PowerShell entrypoint: $target"
  exit 4
}
& $target @args
exit $LASTEXITCODE
'@

  $bashShim = @'
#!/usr/bin/env bash
set -e

if [ -n "${USERPROFILE:-}" ]; then
  _sfs_win="${USERPROFILE}\\scoop\\apps\\sfs\\current\\bin\\sfs"
else
  _sfs_win="$HOME/scoop/apps/sfs/current/bin/sfs"
fi

if command -v cygpath >/dev/null 2>&1; then
  _sfs_path="$(cygpath -u "$_sfs_win")"
else
  _sfs_path="${_sfs_win//\\//}"
fi

exec bash "$_sfs_path" "$@"
'@

  Set-Content -LiteralPath (Join-Path $shimDir "sfs.cmd") -Value $cmdShim -Encoding ASCII
  Set-Content -LiteralPath (Join-Path $shimDir "sfs.ps1") -Value $psShim -Encoding ASCII
  Set-Content -LiteralPath (Join-Path $shimDir "sfs") -Value $bashShim -Encoding ASCII
  Write-Host "  [OK]   Scoop shims hardened: sfs.cmd, sfs.ps1, sfs"
}

# slash-command zero-file discovery hook.
# Always runs on `scoop install sfs` and `scoop update sfs` (idempotent).
# Project upgrade path below sets SFS_SKIP_CLI_DISCOVERY=1 to avoid running
# the same hook twice when sfs upgrade also calls it.
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Install-SfsScoopShims $scriptDir

$discoveryPs1 = Join-Path (Split-Path -Parent $scriptDir) "scripts\install-cli-discovery.ps1"
if (Test-Path $discoveryPs1) {
  $oldDiscoverySource = $env:SFS_DISCOVERY_SOURCE_DIR
  try {
    $env:SFS_DISCOVERY_SOURCE_DIR = (Split-Path -Parent $scriptDir)
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $discoveryPs1
  } catch {
    Write-Warning "cli-discovery (scoop) hook failed: $($_.Exception.Message) - continuing"
  } finally {
    Restore-SfsEnvValue "SFS_DISCOVERY_SOURCE_DIR" $oldDiscoverySource
  }
} else {
  Write-Host "cli-discovery hook not found at $discoveryPs1 - slash-command discovery skipped"
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
  # cli-discovery already ran above - skip in sfs upgrade to avoid double-run
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
