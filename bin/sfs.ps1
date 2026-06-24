$ErrorActionPreference = "Stop"
$CurrentScriptPath = $MyInvocation.MyCommand.Path
$SfsParamArgs = @()

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

function Convert-SfsArgTraceValue([object] $Value) {
  if ($null -eq $Value) { return "<null>" }
  if ($Value -is [System.Array]) {
    $items = @()
    foreach ($item in $Value) {
      if ($null -eq $item) {
        $items += "<null>"
      } else {
        $items += [string] $item
      }
    }
    return "[" + ($items -join "|") + "]"
  }
  return [string] $Value
}

function Write-SfsArgTrace([string] $Label, [object] $Value) {
  if (-not $env:SFS_WINDOWS_ARG_TRACE) { return }
  [Console]::Error.WriteLine(("SFS_ARGTRACE_{0}={1}" -f $Label, (Convert-SfsArgTraceValue $Value)))
}

function Resolve-SfsArgs([object[]] $ParamArgs, [object[]] $AutomaticArgs, [object[]] $UnboundArgs) {
  $resolved = @()
  $source = @()
  if ($ParamArgs -and $ParamArgs.Count -gt 0) {
    $source = $ParamArgs
  } elseif ($AutomaticArgs -and $AutomaticArgs.Count -gt 0) {
    $source = $AutomaticArgs
  } else {
    $source = $UnboundArgs
  }
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

function Resolve-SfsEnvArgs {
  $countRaw = [Environment]::GetEnvironmentVariable("SFS_NATIVE_ARGC")
  if (-not $countRaw) { return [string[]] @() }
  $count = 0
  if (-not [int]::TryParse($countRaw, [ref] $count)) { return [string[]] @() }
  if ($count -le 0) { return [string[]] @() }

  $items = @()
  for ($i = 1; $i -le $count; $i++) {
    $value = [Environment]::GetEnvironmentVariable("SFS_NATIVE_ARG_$i")
    if ($null -eq $value) { $value = "" }
    $items += @([string] $value)
  }
  return [string[]] $items
}

function Resolve-SfsRawArgs {
  $raw = [Environment]::GetEnvironmentVariable("SFS_NATIVE_RAW_ARGS")
  if (-not $raw) { return [string[]] @() }
  return [string[]] (Split-SfsCommandLine $raw)
}

function Test-SfsUsableArgs([string[]] $Items) {
  if (-not $Items -or $Items.Count -eq 0) { return $false }
  foreach ($arg in $Items) {
    if ($null -ne $arg -and [string] $arg -ne "") { return $true }
  }
  return $false
}

function Split-SfsCommandLine([string] $Text) {
  if (-not $Text) { return [string[]] @() }
  $items = @()
  $current = New-Object System.Text.StringBuilder
  $inQuote = $false

  for ($i = 0; $i -lt $Text.Length; $i++) {
    $ch = $Text[$i]
    if ($ch -eq '"') {
      $inQuote = -not $inQuote
      continue
    }
    if ([char]::IsWhiteSpace($ch) -and -not $inQuote) {
      if ($current.Length -gt 0) {
        $items += @($current.ToString())
        $current.Length = 0
      }
      continue
    }
    [void] $current.Append($ch)
  }

  if ($current.Length -gt 0) {
    $items += @($current.ToString())
  }
  return [string[]] $items
}

function Trim-SfsShellControlTail([string[]] $Items) {
  if (-not $Items) { return [string[]] @() }
  $trimmed = @()
  foreach ($item in @($Items)) {
    if ($item -in @("&", "&&", "||", "|")) { break }
    if ($item -match "^[0-9]*[<>]") { break }
    $trimmed += @($item)
  }
  return [string[]] $trimmed
}

function Test-SfsCommandBoundaryBefore([string] $Line, [int] $Index) {
  if ($Index -le 0) { return $true }
  $before = [string] $Line[$Index - 1]
  return ([char]::IsWhiteSpace($Line[$Index - 1]) -or
    $before -eq '"' -or $before -eq "'" -or $before -eq '\' -or $before -eq '/')
}

function Test-SfsCommandBoundaryAfter([string] $Line, [int] $Index) {
  if ($Index -ge $Line.Length) { return $true }
  $after = [string] $Line[$Index]
  if ([char]::IsWhiteSpace($Line[$Index]) -or
      $after -eq '"' -or $after -eq "'" -or
      $after -in @("&", "|", "<", ">")) { return $true }
  return ($after -eq '\' -and ($Index + 1) -lt $Line.Length -and [string] $Line[$Index + 1] -eq '"')
}

function Resolve-SfsArgsAfterCommandName([string] $Line, [string] $Command) {
  foreach ($match in [regex]::Matches($Line, [regex]::Escape($Command), [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
    $afterIndex = $match.Index + $match.Length
    if (-not (Test-SfsCommandBoundaryBefore -Line $Line -Index $match.Index)) { continue }
    if (-not (Test-SfsCommandBoundaryAfter -Line $Line -Index $afterIndex)) { continue }

    $tail = $Line.Substring($afterIndex).TrimStart()
    while ($tail.Length -gt 0) {
      if ($tail.StartsWith('\"')) {
        $tail = $tail.Substring(2).TrimStart()
        continue
      }
      if ($tail.StartsWith('"') -or $tail.StartsWith("'")) {
        $tail = $tail.Substring(1).TrimStart()
        continue
      }
      break
    }
    return [string[]] (Trim-SfsShellControlTail (Split-SfsCommandLine $tail))
  }
  return [string[]] @()
}

function Resolve-SfsArgsFromCommandLine([string] $Line) {
  $line = $Line
  if (-not $line) { return [string[]] @() }

  $cmdTail = Resolve-SfsArgsAfterCommandName -Line $line -Command "sfs.cmd"
  if (Test-SfsUsableArgs $cmdTail) { return [string[]] $cmdTail }

  $tokens = Split-SfsCommandLine $line
  for ($i = 0; $i -lt $tokens.Count; $i++) {
    $leaf = Split-Path -Leaf ($tokens[$i].Trim('"'))
    if ($leaf -ieq "sfs.cmd" -or $leaf -ieq "sfs") {
      if ($tokens.Count -le ($i + 1)) { return [string[]] @() }
      return [string[]] (Trim-SfsShellControlTail @($tokens[($i + 1)..($tokens.Count - 1)]))
    }
  }

  $cmdTail = Resolve-SfsArgsAfterCommandName -Line $line -Command "sfs"
  if (Test-SfsUsableArgs $cmdTail) { return [string[]] $cmdTail }
  return [string[]] @()
}

function Resolve-SfsSavedCmdLineArgs {
  $line = [Environment]::GetEnvironmentVariable("SFS_NATIVE_CMDLINE")
  return [string[]] (Resolve-SfsArgsFromCommandLine $line)
}

function Resolve-SfsParentCmdLineArgs {
  try {
    $self = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $PID" -ErrorAction Stop
    if (-not $self -or -not $self.ParentProcessId) { return [string[]] @() }
    $parent = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $($self.ParentProcessId)" -ErrorAction Stop
    if (-not $parent -or -not $parent.CommandLine) { return [string[]] @() }
    Write-SfsArgTrace "PS_PARENT_CMDLINE" $parent.CommandLine
    return [string[]] (Resolve-SfsArgsFromCommandLine $parent.CommandLine)
  } catch {
    Write-SfsArgTrace "PS_PARENT_CMDLINE_ERROR" $_.Exception.Message
    return [string[]] @()
  }
}

function Resolve-SfsCmdLineArgs {
  $line = [Environment]::GetEnvironmentVariable("CMDCMDLINE")
  return [string[]] (Resolve-SfsArgsFromCommandLine $line)
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

$SfsEnvArgs = Resolve-SfsEnvArgs
Write-SfsArgTrace "PS_AUTOMATIC_ARGS" $args
Write-SfsArgTrace "PS_UNBOUND_ARGS" $MyInvocation.UnboundArguments
Write-SfsArgTrace "PS_ENV_ARGC" ([Environment]::GetEnvironmentVariable("SFS_NATIVE_ARGC"))
Write-SfsArgTrace "PS_ENV_RAW_ARGS" ([Environment]::GetEnvironmentVariable("SFS_NATIVE_RAW_ARGS"))
Write-SfsArgTrace "PS_ENV_SAVED_CMDLINE" ([Environment]::GetEnvironmentVariable("SFS_NATIVE_CMDLINE"))
Write-SfsArgTrace "PS_ENV_CMDCMDLINE" ([Environment]::GetEnvironmentVariable("CMDCMDLINE"))
Write-SfsArgTrace "PS_ENV_ARGS" $SfsEnvArgs
$SfsSelectedArgSource = "empty"
$SfsArgs = Resolve-SfsArgs -ParamArgs $SfsEnvArgs -AutomaticArgs $SfsParamArgs -UnboundArgs $args
if (Test-SfsUsableArgs $SfsArgs) {
  if (Test-SfsUsableArgs $SfsEnvArgs) {
    $SfsSelectedArgSource = "env"
  } elseif (Test-SfsUsableArgs $SfsParamArgs) {
    $SfsSelectedArgSource = "param"
  } else {
    $SfsSelectedArgSource = "automatic"
  }
}
if (-not (Test-SfsUsableArgs $SfsArgs)) {
  $SfsRawArgs = Resolve-SfsRawArgs
  Write-SfsArgTrace "PS_RAW_ENV_ARGS" $SfsRawArgs
  $SfsArgs = Resolve-SfsArgs -ParamArgs $SfsRawArgs -AutomaticArgs @() -UnboundArgs @()
  if (Test-SfsUsableArgs $SfsArgs) { $SfsSelectedArgSource = "raw-env" }
}
if (-not (Test-SfsUsableArgs $SfsArgs)) {
  $SfsSavedCmdLineArgs = Resolve-SfsSavedCmdLineArgs
  Write-SfsArgTrace "PS_SAVED_CMDLINE_ARGS" $SfsSavedCmdLineArgs
  $SfsArgs = Resolve-SfsArgs -ParamArgs $SfsSavedCmdLineArgs -AutomaticArgs @() -UnboundArgs @()
  if (Test-SfsUsableArgs $SfsArgs) { $SfsSelectedArgSource = "saved-cmdline" }
}
if (-not (Test-SfsUsableArgs $SfsArgs)) {
  $SfsParentCmdLineArgs = Resolve-SfsParentCmdLineArgs
  Write-SfsArgTrace "PS_PARENT_CMDLINE_ARGS" $SfsParentCmdLineArgs
  $SfsArgs = Resolve-SfsArgs -ParamArgs $SfsParentCmdLineArgs -AutomaticArgs @() -UnboundArgs @()
  if (Test-SfsUsableArgs $SfsArgs) { $SfsSelectedArgSource = "parent-cmdline" }
}
if (-not (Test-SfsUsableArgs $SfsArgs)) {
  $SfsCmdLineArgs = Resolve-SfsCmdLineArgs
  Write-SfsArgTrace "PS_CHILD_CMDLINE_ARGS" $SfsCmdLineArgs
  $SfsArgs = Resolve-SfsArgs -ParamArgs $SfsCmdLineArgs -AutomaticArgs @() -UnboundArgs @()
  if (Test-SfsUsableArgs $SfsArgs) { $SfsSelectedArgSource = "child-cmdline" }
}
if (-not (Test-SfsUsableArgs $SfsArgs)) {
  $SfsArgs = Resolve-SfsArgs -ParamArgs @() -AutomaticArgs @() -UnboundArgs $MyInvocation.UnboundArguments
  if (Test-SfsUsableArgs $SfsArgs) { $SfsSelectedArgSource = "unbound" }
}
if (-not (Test-SfsUsableArgs $SfsArgs)) { $SfsSelectedArgSource = "empty" }
Write-SfsArgTrace "PS_SELECTED_SOURCE" $SfsSelectedArgSource
Write-SfsArgTrace "PS_FINAL_ARGS" $SfsArgs
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

function Test-SfsUpgradeCommand([string[]] $InvocationArgs) {
  if (-not $InvocationArgs -or $InvocationArgs.Count -eq 0) { return $false }
  $cmdIndex = 0
  if ($InvocationArgs[0] -in @("/sfs", "sfs", '$sfs')) { $cmdIndex = 1 }
  if ($InvocationArgs.Count -le $cmdIndex) { return $false }
  return ($InvocationArgs[$cmdIndex] -in @("upgrade", "update"))
}

function Test-NoSelfUpgrade([string[]] $InvocationArgs) {
  return (($InvocationArgs -contains "--no-self-upgrade") -or $env:SFS_SKIP_SELF_UPGRADE -or ($env:SFS_UPDATE_SELF -eq "0"))
}

function Test-ScoopRuntime([string] $ScriptPath) {
  return ($ScriptPath -match "\\scoop\\apps\\sfs\\")
}

function Resolve-SfsScoopCurrentScriptPath([string] $ScriptPath) {
  if (-not $ScriptPath) { return $ScriptPath }
  $normalized = ($ScriptPath -replace "/", "\")
  $match = [regex]::Match(
    $normalized,
    "^(?<root>.*\\scoop\\apps\\sfs\\)(?<version>[^\\]+)(?<tail>\\bin\\sfs\.ps1)$",
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
  )
  if (-not $match.Success) { return $ScriptPath }

  $candidate = $match.Groups["root"].Value + "current" + $match.Groups["tail"].Value
  if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
  return $ScriptPath
}

function Normalize-SfsScoopReloadArgs([string[]] $InvocationArgs) {
  $items = @()
  foreach ($item in @($InvocationArgs)) {
    if ($null -eq $item) { continue }
    if ($item -in @("--yes", "-y")) { continue }
    $items += @([string] $item)
  }
  if ($items.Count -eq 0) { return [string[]] @() }

  $cmdIndex = 0
  if ($items[0] -in @("/sfs", "sfs", '$sfs')) { $cmdIndex = 1 }
  if ($items.Count -gt $cmdIndex -and $items[$cmdIndex] -eq "upgrade") {
    $items[$cmdIndex] = "update"
  }
  return [string[]] $items
}

function Set-SfsNativeArgEnv([string[]] $InvocationArgs) {
  $oldCount = 0
  [void] [int]::TryParse([Environment]::GetEnvironmentVariable("SFS_NATIVE_ARGC"), [ref] $oldCount)
  $newCount = if ($InvocationArgs) { $InvocationArgs.Count } else { 0 }
  $limit = [Math]::Max($oldCount, $newCount)
  for ($i = 1; $i -le $limit; $i++) {
    Remove-Item "Env:SFS_NATIVE_ARG_$i" -ErrorAction SilentlyContinue
  }

  $env:SFS_NATIVE_ARGC = [string] $newCount
  for ($i = 0; $i -lt $newCount; $i++) {
    Set-Item "Env:SFS_NATIVE_ARG_$($i + 1)" ([string] $InvocationArgs[$i])
  }

  $rawArgs = if ($newCount -gt 0) { ($InvocationArgs -join " ") } else { "" }
  $env:SFS_NATIVE_RAW_ARGS = $rawArgs
  $env:SFS_NATIVE_CMDLINE = if ($rawArgs) { "sfs.cmd $rawArgs" } else { "sfs.cmd" }
}

function Add-SfsPowerShellModulePath([string] $ModuleRoot) {
  if (-not $ModuleRoot) { return }
  if (-not (Test-Path -LiteralPath $ModuleRoot -PathType Container)) { return }

  $separator = [System.IO.Path]::PathSeparator
  $items = @()
  if ($env:PSModulePath) {
    $items = @($env:PSModulePath -split [regex]::Escape([string] $separator) | Where-Object { $_ })
  }
  foreach ($item in $items) {
    if ($item -ieq $ModuleRoot) { return }
  }
  $env:PSModulePath = (($items + @($ModuleRoot)) -join [string] $separator)
}

function Install-SfsGetFileHashFallback {
  if (Get-Command Get-FileHash -ErrorAction SilentlyContinue) { return }

  function global:Get-FileHash {
    [CmdletBinding(DefaultParameterSetName = "Path")]
    param(
      [Parameter(ParameterSetName = "Path", Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
      [string[]] $Path,

      [Parameter(ParameterSetName = "LiteralPath", Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
      [Alias("PSPath")]
      [string[]] $LiteralPath,

      [Parameter(ParameterSetName = "InputStream", Mandatory = $true)]
      [System.IO.Stream] $InputStream,

      [ValidateSet("SHA1", "SHA256", "SHA384", "SHA512", "MD5")]
      [string] $Algorithm = "SHA256"
    )

    process {
      $algorithmName = $Algorithm.ToUpperInvariant()
      if ($PSCmdlet.ParameterSetName -eq "InputStream") {
        $hashAlgorithm = $null
        try {
          $hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create($algorithmName)
          if (-not $hashAlgorithm) { throw "Unsupported hash algorithm: $Algorithm" }
          $hashBytes = $hashAlgorithm.ComputeHash($InputStream)
          [pscustomobject] @{
            Algorithm = $algorithmName
            Hash = ([System.BitConverter]::ToString($hashBytes) -replace "-", "")
            Path = ""
          }
        } finally {
          if ($hashAlgorithm) { $hashAlgorithm.Dispose() }
        }
        return
      }

      if ($PSCmdlet.ParameterSetName -eq "LiteralPath") {
        $inputPaths = $LiteralPath
      } else {
        $inputPaths = $Path
      }

      foreach ($item in $inputPaths) {
        $resolvedPaths = @()
        if ($PSCmdlet.ParameterSetName -eq "LiteralPath") {
          $resolvedPaths += @($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($item))
        } else {
          foreach ($resolved in @(Resolve-Path -Path $item)) {
            $resolvedPaths += @($resolved.ProviderPath)
          }
        }

        foreach ($resolvedPath in $resolvedPaths) {
          if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
            throw "Cannot find path '$resolvedPath' because it does not exist or is not a file."
          }
          $stream = [System.IO.File]::OpenRead($resolvedPath)
          $hashAlgorithm = $null
          try {
            $hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create($algorithmName)
            if (-not $hashAlgorithm) { throw "Unsupported hash algorithm: $Algorithm" }
            $hashBytes = $hashAlgorithm.ComputeHash($stream)
            [pscustomobject] @{
              Algorithm = $algorithmName
              Hash = ([System.BitConverter]::ToString($hashBytes) -replace "-", "")
              Path = $resolvedPath
            }
          } finally {
            if ($hashAlgorithm) { $hashAlgorithm.Dispose() }
            $stream.Dispose()
          }
        }
      }
    }
  }
}

function Enable-SfsPowerShellUtility {
  Add-SfsPowerShellModulePath (Join-Path $PSHOME "Modules")
  Add-SfsPowerShellModulePath (Join-Path $env:ProgramFiles "WindowsPowerShell\Modules")
  Add-SfsPowerShellModulePath (Join-Path $HOME "Documents\WindowsPowerShell\Modules")
  try {
    Import-Module Microsoft.PowerShell.Utility -ErrorAction SilentlyContinue
  } catch {
  }
  Install-SfsGetFileHashFallback
  if (-not (Get-Command Get-FileHash -ErrorAction SilentlyContinue)) {
    Write-Error "Get-FileHash is unavailable in this PowerShell session; Scoop self-upgrade cannot verify downloads."
    exit 1
  }
}

function Invoke-ScoopSelfUpgrade([string[]] $InvocationArgs) {
  Write-SfsArgTrace "PS_SELF_UPGRADE_INVOCATION_ARGS" $InvocationArgs
  if (-not (Test-SfsUpgradeCommand $InvocationArgs)) { return $false }
  if (Test-NoSelfUpgrade $InvocationArgs) { return $false }
  if (-not (Test-ScoopRuntime $CurrentScriptPath)) { return $false }

  $scoop = Get-Command scoop -ErrorAction SilentlyContinue
  if (-not $scoop) {
    Write-Error "scoop command not found; rerun with SFS_UPDATE_SELF=0 to use the current runtime only."
    exit 1
  }

  Enable-SfsPowerShellUtility
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
  $reloadArgs = [string[]] @(Normalize-SfsScoopReloadArgs $InvocationArgs)
  Set-SfsNativeArgEnv $reloadArgs
  $reloadScriptPath = Resolve-SfsScoopCurrentScriptPath $CurrentScriptPath
  Write-SfsArgTrace "PS_RELOAD_SCRIPT" $reloadScriptPath
  Write-SfsArgTrace "PS_RELOAD_ARGS" $reloadArgs
  & $reloadScriptPath @reloadArgs
  exit $LASTEXITCODE
}

Invoke-ScoopSelfUpgrade -InvocationArgs $SfsArgs | Out-Null

$script:SfsNativeHandled = $false
$script:SfsNativeExitCode = 0

function Set-SfsNativeExit([int] $Code) {
  $script:SfsNativeHandled = $true
  $script:SfsNativeExitCode = $Code
}

function Write-SfsNativeError([string] $Message) {
  [Console]::Error.WriteLine($Message)
}

function Get-SfsNativeInvocation([string[]] $InvocationArgs) {
  $cmdIndex = 0
  if ($InvocationArgs -and $InvocationArgs.Count -gt 0 -and ($InvocationArgs[0] -in @("/sfs", "sfs", '$sfs'))) {
    $cmdIndex = 1
  }
  if (-not $InvocationArgs -or $InvocationArgs.Count -le $cmdIndex) {
    return [pscustomobject]@{ Command = "help"; Rest = @() }
  }
  $rest = @()
  if ($InvocationArgs.Count -gt ($cmdIndex + 1)) {
    $rest = @($InvocationArgs[($cmdIndex + 1)..($InvocationArgs.Count - 1)])
  }
  return [pscustomobject]@{ Command = $InvocationArgs[$cmdIndex]; Rest = $rest }
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
  status, start, guide, auth, profile, division, adopt, brainstorm, plan, implement, review, decision, capture, note, ingest, report, report-bug, flowcheck, healthcheck, tidy, retro, commit, loop
  bootstrap [plain-language app idea]
  measure [--json] [--root <dir>]
  measure --alive -- <command>

Windows note:
  PowerShell/cmd users should prefer sfs.cmd. Git Bash/WSL users can use sfs.
  sfs.cmd status, version, guide, and context path/cat are native read-only.
  Mutating commands still require Git for Windows/Git Bash.
"@
}

function Invoke-SfsNativeVersion([string[]] $InvocationArgs) {
  $check = $false
  foreach ($arg in $InvocationArgs) {
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
    $headline = Get-SfsReleaseHeadline $version
    if ($headline) { Write-Output "installed_release_headline $headline" }
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

function Get-SfsReleaseHeadline {
  param([string]$Version)
  if (-not $Version -or $Version -eq "unknown") { return $null }
  $changelog = Join-Path (Get-SfsDistDir) "CHANGELOG.md"
  if (Test-Path -LiteralPath $changelog) {
    $capture = $false
    $parts = @()
    foreach ($line in Get-Content -LiteralPath $changelog) {
      if ($line -match ("^## \[" + [regex]::Escape($Version) + "\]")) {
        $capture = $true
        continue
      }
      if ($capture -and $line -match "^## ") { break }
      if ($capture -and $line.StartsWith("> ")) {
        $part = $line.Substring(2).Replace("**", "").Trim()
        if ($part) { $parts += $part }
        continue
      }
      if ($capture -and $parts.Count -gt 0) { break }
    }
    if ($parts.Count -gt 0) {
      return (($parts -join " ") -replace "\s+", " ").Trim()
    }
  }

  $notes = Join-Path (Get-SfsDistDir) "RELEASE-NOTES.md"
  if (-not (Test-Path -LiteralPath $notes)) { return $null }
  $capture = $false
  foreach ($line in Get-Content -LiteralPath $notes) {
    if ($line -eq "## $Version") {
      $capture = $true
      continue
    }
    if ($capture -and $line -match "^## ") { break }
    if ($capture -and $line.Trim()) {
      return (($line.Trim()) -replace "\s+", " ")
    }
  }
  return $null
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

function Resolve-SfsGuidePath {
  $localGuide = Join-Path (Get-SfsLocalDir) "GUIDE.md"
  if (Test-Path -LiteralPath $localGuide -PathType Leaf) { return $localGuide }
  return (Join-Path (Get-SfsDistDir) "GUIDE.md")
}

function Show-SfsNativeGuideUsage {
  @"
Usage:
  sfs.cmd guide [--path|--print]

Shows the Solon Product onboarding guide installed with this project.
  --path   print only the guide path
  --print  print the full guide contents
"@
}

function Invoke-SfsNativeGuide([string[]] $InvocationArgs) {
  $mode = ""
  foreach ($arg in $InvocationArgs) {
    switch ($arg) {
      "-h" { Show-SfsNativeGuideUsage; Set-SfsNativeExit 0; return }
      "--help" { Show-SfsNativeGuideUsage; Set-SfsNativeExit 0; return }
      "--path" { $mode = "path" }
      "--print" { $mode = "print" }
      default {
        Write-SfsNativeError "unknown arg for guide: $arg"
        Set-SfsNativeExit 99
        return
      }
    }
  }

  $guidePath = Resolve-SfsGuidePath
  if ($mode -eq "path") {
    Write-Output $guidePath
    Set-SfsNativeExit 0
    return
  }
  if ($mode -eq "print") {
    if (-not (Test-Path -LiteralPath $guidePath -PathType Leaf)) {
      Write-SfsNativeError "guide missing: $guidePath"
      Set-SfsNativeExit 4
      return
    }
    Get-Content -LiteralPath $guidePath -Raw
    Set-SfsNativeExit 0
    return
  }

  @"
Solon guide context

What this is:
  Solon keeps sprint, decision, review, retro, and handoff state inside this repo.

First files:
  SFS.md        project operating guide
  CLAUDE.md     Claude Code entry
  AGENTS.md     Codex entry
  GEMINI.md     Gemini CLI entry

Command entrypoints:
  PowerShell/cmd:        sfs.cmd ...
  Git Bash/WSL/macOS:    sfs ...
  Claude/Gemini agents:  /sfs ...
  Codex agents:          `$sfs ...

First flow:
  sfs.cmd status
  sfs.cmd auth status
  sfs.cmd start "current sprint goal"
  sfs.cmd brainstorm "raw requirements"
  sfs.cmd plan
  sfs.cmd implement "first slice"

Full guide:
  sfs.cmd guide --print
  path: $guidePath
"@
  Set-SfsNativeExit 0
}

function Invoke-SfsNativeStatus([string[]] $InvocationArgs) {
  $outputStyle = "normal"
  if ($env:SFS_OUTPUT_STYLE) { $outputStyle = [string] $env:SFS_OUTPUT_STYLE }
  for ($i = 0; $i -lt $InvocationArgs.Count; $i++) {
    $arg = $InvocationArgs[$i]
    if ($arg -eq "--") { continue }
    if ($arg -eq "-h" -or $arg -eq "--help") {
      Write-Output "Usage: sfs.cmd status [--color auto|always|never] [--compact|--output-style compact]"
      Set-SfsNativeExit 0
      return
    }
    if ($arg -eq "--compact") { $outputStyle = "compact"; continue }
    if ($arg -like "--output-style=*") {
      $outputStyle = $arg.Substring("--output-style=".Length)
      continue
    }
    if ($arg -eq "--output-style") {
      if (($i + 1) -ge $InvocationArgs.Count) {
        Write-SfsNativeError "missing value for --output-style (expected normal|compact)"
        Set-SfsNativeExit 99
        return
      }
      $i += 1
      $outputStyle = $InvocationArgs[$i]
      continue
    }
    if ($arg -eq "--color") { continue }
    if ($arg -like "--color=*") { continue }
    if ($arg -in @("auto", "always", "never")) { continue }
    Write-SfsNativeError "unknown arg for status: $arg"
    Set-SfsNativeExit 99
      return
  }

  if ($outputStyle -notin @("normal", "compact")) {
    Write-SfsNativeError "invalid output style: $outputStyle (expected normal|compact)"
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
  $upstream = ""
  try {
    $upstream = (& git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null | Select-Object -First 1)
  } catch {
    $upstream = ""
  }
  if ($LASTEXITCODE -eq 0 -and $upstream) {
    try {
      $count = (& git rev-list --count "$upstream..HEAD" 2>$null | Select-Object -First 1)
      if ($LASTEXITCODE -eq 0 -and $count -match '^[0-9]+$') { $ahead = $count }
    } catch {
      $ahead = "0"
    }
  }

  if (-not $sprint) { $sprint = "-" }
  if (-not $wu) { $wu = "-" }
  if (-not $verdict) { $verdict = "-" }
  if (-not $lastEvent) { $lastEvent = "-" }
  $gateLabel = Get-SfsGateLabel $gate
  if ($outputStyle -eq "compact") {
    Write-Output "sprint=$sprint wu=$wu gate=$gateLabel verdict=$verdict ahead=$ahead last_event=$lastEvent"
  } else {
    Write-Output "sprint $sprint - WU $wu - gate $($gateLabel):$verdict - ahead $ahead - last_event $lastEvent"
  }
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
    '^(adopt|brainstorm|plan|implement|review|release|upgrade|profile|loop|tidy|ingest)$' { return "commands/$keyNorm.md" }
    '^(capture|note)$' { return "commands/capture.md" }
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

function Invoke-SfsNativeContext([string[]] $InvocationArgs) {
  if (-not $InvocationArgs -or $InvocationArgs.Count -eq 0 -or $InvocationArgs[0] -in @("-h", "--help", "help")) {
    @"
Usage:
  sfs.cmd context path <kernel|index|commands/name.md|policies/name.md>
  sfs.cmd context cat  <kernel|index|commands/name.md|policies/name.md>

Native read-only helper for Windows agents. It does not start Git Bash.
"@
    Set-SfsNativeExit 0
    return
  }
  $mode = $InvocationArgs[0]
  if ($mode -notin @("path", "cat")) {
    Write-SfsNativeError "unknown context subcommand: $mode"
    Set-SfsNativeExit 1
    return
  }
  if ($InvocationArgs.Count -lt 2) {
    Write-SfsNativeError "context $mode requires a key"
    Set-SfsNativeExit 1
    return
  }
  $path = Resolve-SfsContextPath $InvocationArgs[1]
  if (-not $path) {
    Write-SfsNativeError "context file not found: $($InvocationArgs[1])"
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

function Invoke-SfsNativeReadonly([string[]] $InvocationArgs) {
  $invocation = Get-SfsNativeInvocation $InvocationArgs
  $cmd = $invocation.Command.ToLowerInvariant()
  switch ($cmd) {
    "help" { Show-SfsNativeUsage; Set-SfsNativeExit 0; return }
    "-h" { Show-SfsNativeUsage; Set-SfsNativeExit 0; return }
    "--help" { Show-SfsNativeUsage; Set-SfsNativeExit 0; return }
    "-v" { Invoke-SfsNativeVersion @("--check"); return }
    "--version" { Invoke-SfsNativeVersion @(); return }
    "version" { Invoke-SfsNativeVersion -InvocationArgs $invocation.Rest; return }
    "status" { Invoke-SfsNativeStatus -InvocationArgs $invocation.Rest; return }
    "guide" { Invoke-SfsNativeGuide -InvocationArgs $invocation.Rest; return }
    "context" { Invoke-SfsNativeContext -InvocationArgs $invocation.Rest; return }
    default {
      if ($env:SFS_NATIVE_ONLY -eq "1") {
        Write-SfsNativeError "native read-only fallback does not handle command: $($invocation.Command)"
        Set-SfsNativeExit 77
      }
      return
    }
  }
}

Invoke-SfsNativeReadonly -InvocationArgs $SfsArgs
if ($script:SfsNativeHandled) {
  exit $script:SfsNativeExitCode
}

$bash = Find-SfsBash
if (-not $bash) {
  Write-Error "Solon SFS on Windows PowerShell requires Git Bash. Install Git for Windows, or set SFS_BASH to a compatible bash.exe. Multi-agent team activation (sfs team use <solo|pair|trio>, sfs upgrade --team) also runs through Git Bash."
  exit 9
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sfsSh = Join-Path $scriptDir "sfs"
if (-not (Test-Path $sfsSh)) {
  Write-Error "missing packaged SFS entrypoint: $sfsSh"
  exit 4
}

$bashArgs = [string[]] @($SfsArgs)
Write-SfsArgTrace "PS_BASH_ARGS" $bashArgs
& $bash (Convert-ToBashPath $sfsSh) @bashArgs
$bashExitCode = $LASTEXITCODE
Write-SfsArgTrace "PS_AFTER_BASH_BRIDGE_LASTEXITCODE" $bashExitCode
exit $bashExitCode
