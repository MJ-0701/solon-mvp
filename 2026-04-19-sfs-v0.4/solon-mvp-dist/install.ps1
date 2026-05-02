param(
  [switch] $Yes,
  [switch] $Help,
  [ValidateSet("thin", "vendored")]
  [string] $Layout = "thin",
  [switch] $WithAgentAdapters
)

$ErrorActionPreference = "Stop"
$SolonRepo = "MJ-0701/solon-product"
$SolonBranch = "main"

function Find-SolonBash {
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

$bash = Find-SolonBash
if (-not $bash) {
  Write-Error "Solon Product install on Windows PowerShell requires Git Bash. Install Git for Windows, or set SFS_BASH to a compatible bash.exe."
  exit 9
}

$argsForBash = @()
if ($Yes) { $argsForBash += "--yes" }
if ($Help) { $argsForBash += "--help" }
if ($Layout) {
  $argsForBash += "--layout"
  $argsForBash += $Layout
}
if ($WithAgentAdapters) { $argsForBash += "--with-agent-adapters" }

$scriptPath = $MyInvocation.MyCommand.Path
$sourceDir = $null
if ($scriptPath) {
  $candidateDir = Split-Path -Parent $scriptPath
  if (Test-Path (Join-Path $candidateDir "templates")) {
    $sourceDir = $candidateDir
  }
}

$tmp = $null
try {
  if (-not $sourceDir) {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) {
      Write-Error "git is required for remote install mode."
      exit 9
    }
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("solon-product-install-" + [guid]::NewGuid().ToString("N"))
    & git clone --quiet --depth=1 --branch $SolonBranch "https://github.com/$SolonRepo.git" $tmp
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    $sourceDir = $tmp
  }

  $installSh = Join-Path $sourceDir "install.sh"
  & $bash (Convert-ToBashPath $installSh) @argsForBash
  exit $LASTEXITCODE
}
finally {
  if ($tmp -and (Test-Path $tmp)) {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
  }
}
