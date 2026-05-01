param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $SfsArgs
)

$ErrorActionPreference = "Stop"
$CurrentScriptPath = $MyInvocation.MyCommand.Path

function Find-SfsBash {
  if ($env:SFS_BASH) {
    $cmd = Get-Command $env:SFS_BASH -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    if (Test-Path $env:SFS_BASH) { return $env:SFS_BASH }
  }

  foreach ($candidate in @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files\Git\usr\bin\bash.exe",
    "C:\Program Files (x86)\Git\bin\bash.exe",
    "C:\Program Files (x86)\Git\usr\bin\bash.exe"
  )) {
    if (Test-Path $candidate) { return $candidate }
  }

  foreach ($candidate in @("bash.exe", "bash")) {
    $cmd = Get-Command $candidate -ErrorAction SilentlyContinue
    if ($cmd -and ($cmd.Source -notmatch "\\Windows\\System32\\bash\.exe$")) {
      return $cmd.Source
    }
  }

  return $null
}

function Convert-ToBashPath([string] $Path) {
  return ($Path -replace "\\", "/")
}

function Test-SfsUpgradeCommand([string[]] $Args) {
  if (-not $Args -or $Args.Count -eq 0) { return $false }
  $cmdIndex = 0
  if ($Args[0] -in @("/sfs", "sfs", '$sfs')) { $cmdIndex = 1 }
  if ($Args.Count -le $cmdIndex) { return $false }
  return ($Args[$cmdIndex] -in @("upgrade", "update"))
}

function Test-NoSelfUpgrade([string[]] $Args) {
  return (($Args -contains "--no-self-upgrade") -or $env:SFS_SKIP_SELF_UPGRADE -or ($env:SFS_UPDATE_SELF -eq "0"))
}

function Test-ScoopRuntime([string] $ScriptPath) {
  return ($ScriptPath -match "\\scoop\\apps\\sfs\\")
}

function Invoke-ScoopSelfUpgrade([string[]] $Args) {
  if (-not (Test-SfsUpgradeCommand $Args)) { return $false }
  if (Test-NoSelfUpgrade $Args) { return $false }
  if (-not (Test-ScoopRuntime $CurrentScriptPath)) { return $false }

  $scoop = Get-Command scoop -ErrorAction SilentlyContinue
  if (-not $scoop) {
    Write-Error "scoop command not found; rerun with SFS_UPDATE_SELF=0 to use the current runtime only."
    exit 1
  }

  Write-Host "global runtime self-upgrade:"
  Write-Host "  scoop update"
  & scoop update
  if ($LASTEXITCODE -ne 0) {
    Write-Error "scoop update failed; rerun with SFS_UPDATE_SELF=0 to use the current runtime only."
    exit 1
  }

  Write-Host "  scoop update sfs"
  & scoop update sfs
  if ($LASTEXITCODE -ne 0) {
    Write-Error "scoop update sfs failed; rerun with SFS_UPDATE_SELF=0 to use the current runtime only."
    exit 1
  }

  Write-Host "reloading installed sfs runtime..."
  $env:SFS_SKIP_SELF_UPGRADE = "1"
  & $CurrentScriptPath @Args
  exit $LASTEXITCODE
}

Invoke-ScoopSelfUpgrade $SfsArgs | Out-Null

$bash = Find-SfsBash
if (-not $bash) {
  Write-Error "Solon SFS on Windows PowerShell requires Git Bash. Install Git for Windows, or set SFS_BASH to a compatible bash.exe."
  exit 9
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sfsSh = Join-Path $scriptDir "sfs"
if (-not (Test-Path $sfsSh)) {
  Write-Error "missing packaged SFS entrypoint: $sfsSh"
  exit 4
}

& $bash (Convert-ToBashPath $sfsSh) @SfsArgs
exit $LASTEXITCODE
