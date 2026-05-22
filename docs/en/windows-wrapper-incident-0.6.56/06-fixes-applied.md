---
doc_id: sfs-windows-wrapper-incident-0-6-56-en-6
title: "Fixes Applied"
visibility: oss-public
doc_type: incident-report
language: en
updated: 2026-05-22
parent: docs/en/windows-wrapper-incident-0.6.56.md
summary: "Fixes Applied"
load_when: "Read when docs/en/windows-wrapper-incident-0.6.56.md routes to this section."
---
## Fixes Applied

- `sfs.cmd` is now a call-label-dispatch-free thin PowerShell trampoline. It stores received
  arguments in the numbered env bridge, invokes packaged `sfs.ps1`, and exits on
  the same parsed line.
- `sfs.ps1` handles native read-only dispatch first, then routes remaining
  commands through the same bridge into the Bash runtime.
- `sfs.cmd` no longer uses the raw Git Bash `%*` bridge for mutating commands.
- `sfs.ps1` no longer depends on a script-param source. It normalizes numbered
  env bridge args, PowerShell automatic `$args`, `CMDCMDLINE`,
  `$MyInvocation.UnboundArguments`, nested arrays, accidental literal
  `-SfsArgs`, and `--%` forms into one command list.
- `sfs.ps1` sets UTF-8 console/native-command encoding and Git Bash UTF-8 locale
  where possible.
- The Windows guard test locks the bridge contract and, on real Windows hosts,
  executes `powershell.exe -File sfs.ps1 context cat kernel` and `status`.
- 0.6.36 also fixed docs tests so they understand both source layout and the
  Homebrew installed layout.
- 0.6.37 moves Scoop self-upgrade ownership out of `sfs.cmd`. The batch wrapper
  now handles native read-only dispatch, then hands off to `sfs.ps1`; the
  PowerShell entrypoint owns `scoop update`, `scoop update sfs`, and reloading
  the updated runtime.
- 0.6.38 also fixes the new `test-windows-wrapper-incident-report.sh` so it
  understands the Homebrew installed layout and does not repeat the same layout
  assumption during installed-package verification.
- 0.6.40 changes the non-native `sfs.cmd` PowerShell dispatch to
  `call :powershell_dispatch %* & exit /b !ERRORLEVEL!`, and the actual
  `powershell.exe -File sfs.ps1 ...` dispatch also exits with
  `exit /b !ERRORLEVEL!` on the same parsed line.
  That prevents `cmd.exe` from reading arbitrary lines from a replaced batch file
  after self-upgrade.
- 0.6.41 keeps Windows runtime `.ps1` / `.cmd` files ASCII-only to avoid
  BOM-less UTF-8 parser corruption in Windows PowerShell 5.1. It also removes
  `SFS_ORIGINAL_ARGS` and forwards the call-label `%*` directly to `sfs.ps1`.
- 0.6.42 uses the 0.6.41 GitHub Windows Scoop usage-only failure as the final
  signal to remove batch-label dispatch from `sfs.cmd`. `sfs.cmd` now only
  trampolines into PowerShell; `sfs.ps1` owns `version`, `status`, `guide`,
  `context`, Scoop self-upgrade, and Bash fallback.
- 0.6.43 uses the 0.6.42 GitHub Windows Scoop usage-only failure as the signal
  to replace `-File` with `-Command "& $env:SFS_NATIVE_SCRIPT @args"`. That path
  failed again in the real 0.6.43 Windows smoke, so 0.6.45 supersedes it.
- 0.6.44 no longer depends on PowerShell CLI argument binding. `sfs.cmd` stores
  `%1..%n` into `SFS_NATIVE_ARGC` / `SFS_NATIVE_ARG_N`, then invokes
  `powershell.exe -File "%SFS_NATIVE_SCRIPT%"` without argv. `sfs.ps1` reads the
  env bridge first, then falls back to positional param args, `$args`, and
  `$MyInvocation.UnboundArguments`.
- 0.6.45 also adds the `CMDCMDLINE` fallback based on the additional 0.6.44
  Windows smoke failure. If the env bridge, positional param args, and `$args`
  are all empty, `sfs.ps1` parses the original Windows command line and recovers
  the command tail after `sfs` / `sfs.cmd`.
- 0.6.46 uses the additional 0.6.45 Windows smoke failure to change the Scoop
  manifest primary `bin` target from `bin\sfs.cmd` to `bin\sfs.ps1`. The
  generated Scoop PowerShell shim now calls `sfs.ps1` directly. That path was
  applied in the 0.6.46 Windows smoke, but script-param binding failed again and
  is superseded by 0.6.47.
- 0.6.47 removes the packaged `sfs.ps1` param block. `sfs.ps1` normalizes the
  numbered env bridge, PowerShell automatic `$args`, `CMDCMDLINE`, and
  `$MyInvocation.UnboundArguments` into the same argument list.
- 0.6.48 pins Windows PowerShell/cmd smoke and user guidance to `sfs.cmd`.
  The bare `sfs` generated shim is treated as a Git Bash/WSL contract, not the
  Windows PowerShell/cmd contract.
- 0.6.49 makes the Scoop post-install hook overwrite shims-directory `sfs.cmd`,
  `sfs.ps1`, and extensionless `sfs` with deterministic wrappers. The `sfs.cmd`
  shim stores `%1..%n` in the numbered env bridge and invokes packaged
  `sfs.ps1` on the same parsed line. The `sfs.ps1` shim forwards PowerShell
  `$args`, and the extensionless `sfs` shim executes packaged `bin/sfs` from
  Git Bash.
- 0.6.50 keeps the numbered env bridge in the hardened `sfs.cmd` shim and also
  invokes `powershell.exe -File "%SFS_NATIVE_SCRIPT%" %*` so the positional
  fallback reaches `sfs.ps1`. The Windows smoke also checks the installed shim
  text for both `SFS_NATIVE_ARGC` and `%*` immediately after install.
- 0.6.51 braces the known-broken package tag refspec as
  `refs/tags/v${brokenVersion}:refs/tags/v${brokenVersion}` so PowerShell does
  not rewrite it before Git sees it.
- 0.6.52 stores the original `%*` tail in `SFS_NATIVE_RAW_ARGS` before `shift`
  in both packaged and post-install hardened `sfs.cmd`. `sfs.ps1` reads that raw
  arg tail after the numbered env bridge and before the `CMDCMDLINE` fallback;
  empty resolved arg arrays are treated as unusable so later fallbacks can run.
- 0.6.53 stores the batch process's original command line in
  `SFS_NATIVE_CMDLINE` with delayed expansion before starting PowerShell.
  `sfs.ps1` reads that saved command line after the raw arg tail and before
  child PowerShell's own `CMDCMDLINE` fallback, then trims `cmd.exe`
  shell-control tails such as `&& sfs.cmd --help`.
- 0.6.54 adds a parent-process command-line fallback after the 0.6.53 GitHub
  runner still produced usage-only output. When env/raw/saved command-line
  sources are empty, `sfs.ps1` reads its parent `cmd.exe` `Win32_Process`
  command line, extracts the original `sfs.cmd ...` tail before whitespace
  splitting so paths with spaces do not become fake args, and only then falls
  back to child PowerShell's own `CMDCMDLINE`.
- The 0.6.55 candidate tried to carry the saved raw tail directly into the
  PowerShell invocation after the 0.6.54 GitHub runner still produced
  usage-only output. Trace run `25554923214` showed this produced the wrong
  `--SFS_NATIVE_RAW_ARGS` token while the numbered env bridge still contained
  `version`, so 0.6.56 supersedes it with the P23 root-cause fix.
- 0.6.56 renames `Test-SfsUsableArgs([string[]] $Args)` to
  `Test-SfsUsableArgs([string[]] $Items)` and native dispatch/self-upgrade
  `$Args` parameters to `$InvocationArgs`, allowing the live env bridge to be
  accepted as the command all the way to native handling. Windows smoke requires `SFS_ARGTRACE_PS_SELECTED_SOURCE=env`
  and `SFS_ARGTRACE_PS_FINAL_ARGS=.*version`.

