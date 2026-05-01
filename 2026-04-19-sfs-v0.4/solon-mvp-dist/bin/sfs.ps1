param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $SfsArgs
)

$ErrorActionPreference = "Stop"

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
