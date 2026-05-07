$ErrorActionPreference = "Stop"
$CurrentScriptPath = $MyInvocation.MyCommand.Path

function Expand-SfsArgItem([object] $Item) {
  if ($null -eq $Item) { return @() }
  if ($Item -is [System.Array]) {
    $expanded = @()
    foreach ($child in $Item) {
      $expanded += @(Expand-SfsArgItem $child)
    }
    return $expanded
  }
  return @([string] $Item)
}

function Resolve-SfsArgs([object[]] $AutomaticArgs, [object[]] $UnboundArgs) {
  $resolved = @()
  $source = if ($AutomaticArgs -and $AutomaticArgs.Count -gt 0) { $AutomaticArgs } else { $UnboundArgs }
  foreach ($item in @($source)) {
    $resolved += @(Expand-SfsArgItem $item)
  }
  if ($resolved.Count -gt 0 -and $resolved[0] -eq "-SfsArgs") {
    if ($resolved.Count -eq 1) { return [string[]] @() }
    return [string[]] @($resolved[1..($resolved.Count - 1)])
  }
  if ($resolved.Count -ge 2 -and $resolved[0] -eq "--%") {
    return [string[]] @($resolved[1..($resolved.Count - 1)])
  }
  return [string[]] $resolved
}

function Enable-SfsUtf8Bridge {
  try {
    $utf8 = New-Object System.Text.UTF8Encoding -ArgumentList $false
    [Console]::InputEncoding = $utf8
    [Console]::OutputEncoding = $utf8
    $script:OutputEncoding = $utf8
  } catch {
    # Some constrained Windows hosts reject console encoding changes.
  }
  if (-not $env:LANG) { $env:LANG = "C.UTF-8" }
  if (-not $env:LC_CTYPE) { $env:LC_CTYPE = "C.UTF-8" }
}

$SfsArgs = Resolve-SfsArgs $args $MyInvocation.UnboundArguments
Enable-SfsUtf8Bridge

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
  $oldScoopProjectUpgrade = $env:SFS_SCOOP_PROJECT_UPGRADE
  $env:SFS_SCOOP_PROJECT_UPGRADE = "0"
  & scoop update sfs
  $scoopUpdateExitCode = $LASTEXITCODE
  if ($null -eq $oldScoopProjectUpgrade) {
    Remove-Item "Env:SFS_SCOOP_PROJECT_UPGRADE" -ErrorAction SilentlyContinue
  } else {
    $env:SFS_SCOOP_PROJECT_UPGRADE = $oldScoopProjectUpgrade
  }
  if ($scoopUpdateExitCode -ne 0) {
    Write-Error "scoop update sfs failed; rerun with SFS_UPDATE_SELF=0 to use the current runtime only."
    exit 1
  }

  Write-Host "reloading installed sfs runtime..."
  $env:SFS_SKIP_SELF_UPGRADE = "1"
  & $CurrentScriptPath @Args
  exit $LASTEXITCODE
}

Invoke-ScoopSelfUpgrade $SfsArgs | Out-Null

$script:SfsNativeHandled = $false
$script:SfsNativeExitCode = 0

function Set-SfsNativeExit([int] $Code) {
  $script:SfsNativeHandled = $true
  $script:SfsNativeExitCode = $Code
}

function Write-SfsNativeError([string] $Message) {
  [Console]::Error.WriteLine($Message)
}

function Get-SfsNativeInvocation([string[]] $Args) {
  $cmdIndex = 0
  if ($Args -and $Args.Count -gt 0 -and ($Args[0] -in @("/sfs", "sfs", '$sfs'))) {
    $cmdIndex = 1
  }
  if (-not $Args -or $Args.Count -le $cmdIndex) {
    return [pscustomobject]@{ Command = "help"; Rest = @() }
  }
  $rest = @()
  if ($Args.Count -gt ($cmdIndex + 1)) {
    $rest = @($Args[($cmdIndex + 1)..($Args.Count - 1)])
  }
  return [pscustomobject]@{ Command = $Args[$cmdIndex]; Rest = $rest }
}

function Get-SfsDistDir {
  $scriptDir = Split-Path -Parent $CurrentScriptPath
  return (Resolve-Path -LiteralPath (Join-Path $scriptDir "..")).Path
}

function Get-SfsLocalDir {
  $local = if ($env:SFS_LOCAL_DIR) { $env:SFS_LOCAL_DIR } else { ".sfs-local" }
  if ([IO.Path]::IsPathRooted($local)) { return $local }
  return (Join-Path (Get-Location) $local)
}

function Get-SfsFirstLine([string] $Path) {
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return "" }
  $line = Get-Content -LiteralPath $Path -TotalCount 1 -ErrorAction SilentlyContinue
  if ($null -eq $line) { return "" }
  return ($line.ToString().Trim())
}

function Get-SfsGateLabel([string] $Gate) {
  switch ($Gate) {
    "G-1" { return "Gate 1 (Intake)" }
    "G0"  { return "Gate 2 (Brainstorm)" }
    "G1"  { return "Gate 3 (Plan)" }
    "G2"  { return "Gate 4 (Design)" }
    "G3"  { return "Gate 5 (Handoff)" }
    "G4"  { return "Gate 6 (Review)" }
    "G5"  { return "Gate 7 (Retro)" }
    default { if ($Gate) { return $Gate } else { return "-" } }
  }
}

function Show-SfsNativeUsage {
  @"
Usage:
  sfs.cmd init [--yes] [--layout thin|vendored]
  sfs.cmd upgrade [--skip-existing] [--no-self-upgrade] [--interactive] [--layout thin|vendored]
  sfs.cmd update [--skip-existing]
  sfs.cmd uninstall [--keep-artifacts|--remove-all] [--remove-docs|--keep-docs]
  sfs.cmd agent install <claude|gemini|codex|all> [--skip-existing]
  sfs.cmd context path <kernel|index|commands/name.md|policies/name.md>
  sfs.cmd context cat  <kernel|index|commands/name.md|policies/name.md>
  sfs.cmd <command> [args]

Commands:
  agent install, upgrade, update, uninstall
  version [--check]
  status, start, guide, auth, profile, division, adopt, brainstorm, plan, implement, review, decision, report, tidy, retro, commit, loop

Windows note:
  sfs.cmd status, version, guide, and context path/cat are native read-only commands.
  Mutating commands still require Git for Windows/Git Bash.
"@
}

function Invoke-SfsNativeVersion([string[]] $Args) {
  $check = $false
  foreach ($arg in $Args) {
    switch ($arg) {
      "--check" { $check = $true }
      "-h" { Show-SfsNativeVersionUsage; Set-SfsNativeExit 0; return }
      "--help" { Show-SfsNativeVersionUsage; Set-SfsNativeExit 0; return }
      default {
        Write-SfsNativeError "unexpected arg for version: $arg"
        Set-SfsNativeExit 99
        return
      }
    }
  }

  $versionPath = Join-Path (Get-SfsDistDir) "VERSION"
  $version = Get-SfsFirstLine $versionPath
  if (-not $version) { $version = "unknown" }
  Write-Output "sfs $version"

  if ($check) {
    try {
      $release = Invoke-RestMethod -UseBasicParsing -Uri "https://api.github.com/repos/MJ-0701/solon-product/releases/latest" -TimeoutSec 10
      $latest = ($release.tag_name -replace "^v", "")
      Write-Output "latest $latest"
      if ($version -eq $latest) {
        Write-Output "status up-to-date"
      } else {
        Write-Output "status upgrade-available"
      }
    } catch {
      Write-Output "latest unknown"
      Write-Output "status check-failed"
    }
  }
  Set-SfsNativeExit 0
}

function Show-SfsNativeVersionUsage {
  @"
Usage:
  sfs.cmd version [--check]
  sfs.cmd --version

Prints the installed SFS runtime version. With --check, also checks the latest
GitHub release when network access is available.
"@
}

function Invoke-SfsNativeStatus([string[]] $Args) {
  foreach ($arg in $Args) {
    if ($arg -eq "--") { continue }
    if ($arg -eq "-h" -or $arg -eq "--help") {
      Write-Output "Usage: sfs.cmd status [--color auto|always|never]"
      Set-SfsNativeExit 0
      return
    }
    if ($arg -eq "--color") { continue }
    if ($arg -like "--color=*") { continue }
    if ($arg -in @("auto", "always", "never")) { continue }
    Write-SfsNativeError "unknown arg for status: $arg"
    Set-SfsNativeExit 99
    return
  }

  $localDir = Get-SfsLocalDir
  if (-not (Test-Path -LiteralPath $localDir -PathType Container)) {
    Write-SfsNativeError "no .sfs-local found - this project is not initialized yet. Run: sfs.cmd init --layout thin --yes"
    Set-SfsNativeExit 1
    return
  }

  $eventsPath = Join-Path $localDir "events.jsonl"
  $eventLines = @()
  if (Test-Path -LiteralPath $eventsPath -PathType Leaf) {
    $lineNo = 0
    foreach ($line in Get-Content -LiteralPath $eventsPath) {
      $lineNo += 1
      if (-not $line) { continue }
      if ($line -notmatch '^\s*\{.*\}\s*$') {
        Write-SfsNativeError "events.jsonl parse error at line $lineNo"
        Set-SfsNativeExit 2
        return
      }
      $eventLines += $line
    }
  }

  & git rev-parse --git-dir *> $null
  if ($LASTEXITCODE -ne 0) {
    Write-SfsNativeError "not a git repo (sfs requires git for ahead count)"
    Set-SfsNativeExit 3
    return
  }

  $sprint = Get-SfsFirstLine (Join-Path $localDir "current-sprint")
  $wu = Get-SfsFirstLine (Join-Path $localDir "current-wu")
  if (-not $wu -and $eventLines.Count -gt 0) {
    for ($i = $eventLines.Count - 1; $i -ge 0; $i--) {
      $line = $eventLines[$i]
      if ($line -match '"type"\s*:\s*"wu_open"' -and $line -match '"wu_id"\s*:\s*"([^"]+)"') {
        $wu = $Matches[1]
        break
      }
    }
  }

  $gate = ""
  $verdict = ""
  if ($eventLines.Count -gt 0) {
    for ($i = $eventLines.Count - 1; $i -ge 0; $i--) {
      $line = $eventLines[$i]
      if ($line -match '"type"\s*:\s*"gate"') {
        if ($line -match '"gate_id"\s*:\s*"([^"]+)"') { $gate = $Matches[1] }
        if ($line -match '"verdict"\s*:\s*"([^"]+)"') { $verdict = $Matches[1] }
        break
      }
    }
  }

  $lastEvent = ""
  if ($eventLines.Count -gt 0) {
    $line = $eventLines[$eventLines.Count - 1]
    if ($line -match '"ts"\s*:\s*"([^"]+)"') { $lastEvent = $Matches[1] }
  }

  $ahead = "0"
  $upstream = (& git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null | Select-Object -First 1)
  if ($LASTEXITCODE -eq 0 -and $upstream) {
    $count = (& git rev-list --count "$upstream..HEAD" 2>$null | Select-Object -First 1)
    if ($LASTEXITCODE -eq 0 -and $count -match '^[0-9]+$') { $ahead = $count }
  }

  if (-not $sprint) { $sprint = "-" }
  if (-not $wu) { $wu = "-" }
  if (-not $verdict) { $verdict = "-" }
  if (-not $lastEvent) { $lastEvent = "-" }
  $gateLabel = Get-SfsGateLabel $gate
  Write-Output "sprint $sprint - WU $wu - gate $($gateLabel):$verdict - ahead $ahead - last_event $lastEvent"
  Set-SfsNativeExit 0
}

function Resolve-SfsContextRel([string] $Key) {
  $keyNorm = ($Key -replace "\\", "/")
  switch -Regex ($keyNorm) {
    '^kernel$' { return "kernel.md" }
    '^(index|_INDEX\.md)$' { return "_INDEX.md" }
    '^(commands|policies)/.+\.md$' { return $keyNorm }
    '^commands/.+' { return "$keyNorm.md" }
    '^policies/.+' { return "$keyNorm.md" }
    '^(start|intake|sprint)$' { return "commands/start.md" }
    '^(adopt|brainstorm|plan|implement|review|release|upgrade|profile|loop|tidy)$' { return "commands/$keyNorm.md" }
    default { return $null }
  }
}

function Resolve-SfsContextPath([string] $Key) {
  $rel = Resolve-SfsContextRel $Key
  if (-not $rel) { return $null }
  $localPath = Join-Path (Join-Path (Get-SfsLocalDir) "context") $rel
  if (Test-Path -LiteralPath $localPath -PathType Leaf) { return $localPath }
  $runtimePath = Join-Path (Join-Path (Join-Path (Get-SfsDistDir) "templates\.sfs-local-template") "context") $rel
  if (Test-Path -LiteralPath $runtimePath -PathType Leaf) { return $runtimePath }
  return $null
}

function Invoke-SfsNativeContext([string[]] $Args) {
  if (-not $Args -or $Args.Count -eq 0 -or $Args[0] -in @("-h", "--help", "help")) {
    @"
Usage:
  sfs.cmd context path <kernel|index|commands/name.md|policies/name.md>
  sfs.cmd context cat  <kernel|index|commands/name.md|policies/name.md>

Native read-only helper for Windows agents. It does not start Git Bash.
"@
    Set-SfsNativeExit 0
    return
  }
  $mode = $Args[0]
  if ($mode -notin @("path", "cat")) {
    Write-SfsNativeError "unknown context subcommand: $mode"
    Set-SfsNativeExit 1
    return
  }
  if ($Args.Count -lt 2) {
    Write-SfsNativeError "context $mode requires a key"
    Set-SfsNativeExit 1
    return
  }
  $path = Resolve-SfsContextPath $Args[1]
  if (-not $path) {
    Write-SfsNativeError "context file not found: $($Args[1])"
    Set-SfsNativeExit 1
    return
  }
  if ($mode -eq "path") {
    Write-Output $path
  } else {
    Get-Content -LiteralPath $path -Raw
  }
  Set-SfsNativeExit 0
}

function Invoke-SfsNativeReadonly([string[]] $Args) {
  $invocation = Get-SfsNativeInvocation $Args
  $cmd = $invocation.Command.ToLowerInvariant()
  switch ($cmd) {
    "help" { Show-SfsNativeUsage; Set-SfsNativeExit 0; return }
    "-h" { Show-SfsNativeUsage; Set-SfsNativeExit 0; return }
    "--help" { Show-SfsNativeUsage; Set-SfsNativeExit 0; return }
    "-v" { Invoke-SfsNativeVersion @("--check"); return }
    "--version" { Invoke-SfsNativeVersion @(); return }
    "version" { Invoke-SfsNativeVersion $invocation.Rest; return }
    "status" { Invoke-SfsNativeStatus $invocation.Rest; return }
    "context" { Invoke-SfsNativeContext $invocation.Rest; return }
    default {
      if ($env:SFS_NATIVE_ONLY -eq "1") {
        Write-SfsNativeError "native read-only fallback does not handle command: $($invocation.Command)"
        Set-SfsNativeExit 77
      }
      return
    }
  }
}

Invoke-SfsNativeReadonly $SfsArgs
if ($script:SfsNativeHandled) {
  exit $script:SfsNativeExitCode
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
