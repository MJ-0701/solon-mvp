# Windows SFS Wrapper Incident Report (0.6.35 -> 0.6.56)

**Language**: [한국어](../ko/windows-wrapper-incident-0.6.56.md) / English

This report summarizes the Windows `sfs.cmd` / `sfs.ps1` wrapper failures found
while running `$sfs start 이미지 프롬프트 고도화` and `sfs.cmd upgrade` on a Windows PC.
The final baseline is 0.6.56.

## One-Line Conclusion

Windows PowerShell/cmd must use the known-good path by default:
`sfs.cmd -> sfs.ps1 -> native read-only/Bash runtime`. Git Bash/WSL keep using
`sfs`. The raw Git Bash `%*`
bridge and batch-label forwarding path had already failed for sandbox startup,
argument forwarding, UTF-8 output, and Scoop shims, so they must not be the
default path. Scoop self-upgrade and native read-only commands belong in
`sfs.ps1`, not in the replaceable `sfs.cmd` batch wrapper. 0.6.49 also stops
trusting generated Scoop shims as-is: the post-install hook
overwrites the shims-directory `sfs.cmd`, `sfs.ps1`, and extensionless `sfs`
with deterministic wrappers that Solon owns. 0.6.50 also makes the hardened
`sfs.cmd` shim pass both the env bridge and the `%*` positional fallback.
0.6.52 preserves that `%*` tail in `SFS_NATIVE_RAW_ARGS` before `shift`, then
lets `sfs.ps1` read it as a raw-arg fallback. 0.6.53 also saves the batch
process's original command line as `SFS_NATIVE_CMDLINE` through delayed
expansion, so `sfs.ps1` can recover the original `sfs.cmd version` tail even
after child PowerShell changes its own `CMDCMDLINE`.
0.6.54 adds the final parent `cmd.exe` command-line probe for the runner path
where even that saved variable is empty. That fallback extracts the tail after
the `sfs.cmd` command name before whitespace splitting, because a parent
command line can contain spaces earlier in the wrapper path.
The 0.6.55 candidate responded to the GitHub runner evidence that even with the
parent fallback present, the first post-install `sfs.cmd version` could still
print usage-only output, by trying to append `SFS_NATIVE_RAW_ARGS` after `--%`.
The 0.6.55 trace run `25554923214` proved the batch side did not lose
`version`; instead, multiple `sfs.ps1` helpers collapsed live env-bridge args
to empty/help at function boundaries because they used the PowerShell-sensitive
parameter name `$Args`. 0.6.56 renames the usable guard to `$Items`, native
dispatch/self-upgrade helpers to `$InvocationArgs`, and removes the
`--% %SFS_NATIVE_RAW_ARGS%` experiment, which produced the wrong
`--SFS_NATIVE_RAW_ARGS` token on the runner. It also keeps the opt-in
`SFS_WINDOWS_ARG_TRACE=1` diagnostic mode, so the next Windows smoke failure
shows batch `%*`, child PowerShell `$args`, env/raw/saved/parent sources, and
the final selected source in the log.
Windows
PowerShell/cmd runtime scripts must also stay ASCII-safe so BOM-less UTF-8 is
not mis-parsed by Windows PowerShell 5.1.

## Final Issue Summary

| # | Issue | Observed Symptom | Final Action |
|---|---|---|---|
| P1 | Windows agent sandbox blocks Git Bash creation | `couldn't create signal pipe, Win32 error 5` | Handle read-only recovery through native PowerShell `sfs.cmd status/version/context` |
| P2 | PowerShell `-File` invocation can lose script-param arguments | `sfs.cmd status`, `sfs.cmd context cat kernel`, `sfs.cmd start ...` print usage only | `sfs.ps1` avoids depending on one argument source and normalizes env bridge args, positional args, `$args`, `$MyInvocation.UnboundArguments`, literal `-SfsArgs`, and `--%` |
| P3 | Mutating commands leaked through raw Git Bash `%*` | Empty output after `start`; Korean goal can become mojibake | Fix default bridge to `sfs.cmd -> sfs.ps1 -> Bash runtime` |
| P4 | Partial success can be mistaken for success | Exit code 0, no next-step output, only sprint pointer created | Empty output is not success. Check `current-sprint`, sprint dir, and `sfs.cmd status` |
| P5 | Replaceable batch kept reading after delegated self-upgrade | `TIVE_READONLY_DONE`, `LF_UPGRADE_DONE`, `e`, `*` executed like commands | Remove Scoop update from `sfs.cmd`; `sfs.ps1` owns self-upgrade/reload; batch calls PowerShell and exits on the same parsed line |
| P6 | Installed docs layout differs from source layout | Homebrew installed tests could not find `CHANGELOG.md` / `RELEASE-NOTES.md` | Tests resolve both `libexec` and the Cellar version root |
| P7 | Windows PowerShell 5.1 parsed a BOM-less UTF-8 PowerShell script through a legacy code page | `install-cli-discovery.ps1` parser error: `Try statement is missing its Catch or Finally block` | Keep Windows `.ps1` / `.cmd` runtime files ASCII-only and enforce that in release guards |
| P8 | Batch forwarded cached `SFS_ORIGINAL_ARGS` instead of the call-label `%*` | `sfs version` fell through to usage because the Scoop shim path reached `sfs.ps1` with empty args | Forward call-label `%*` directly to `sfs.ps1` |
| P9 | Batch-label forwarding itself remained unstable under Scoop shims | The 0.6.41 GitHub Windows Scoop smoke passed post-install but `sfs version` still fell through to usage | Reduce `sfs.cmd` to a label-free thin PowerShell trampoline; move native/read-only/upgrade ownership to `sfs.ps1` |
| P10 | `powershell.exe -File sfs.ps1 %*` also lost args under Scoop shims | The 0.6.42 GitHub Windows Scoop smoke had a label-free `sfs.cmd`, but `sfs version` still fell through to usage | 0.6.43 tried `-Command "& $env:SFS_NATIVE_SCRIPT @args"`, but the real Windows smoke failed again and superseded this with P11 |
| P11 | PowerShell `-Command @args` also failed to pass args under Scoop shims | The 0.6.43 GitHub Windows Scoop smoke run `25532139459` again made `sfs version` fall through to usage-only output | `sfs.cmd` stores `%1..%n` as `SFS_NATIVE_ARGC` / `SFS_NATIVE_ARG_N`, and `sfs.ps1` reads that env bridge as its first argument source |
| P12 | The `%1..%n` numbered env bridge can also start empty under Scoop shims | The 0.6.44 GitHub Windows Scoop smoke run `25532838102` again made `sfs version` fall through to usage-only output | If env/param/`$args` are all empty, `sfs.ps1` recovers the command tail after `sfs` / `sfs.cmd` from Windows `CMDCMDLINE` |
| P13 | A generated Scoop shim can still lose the original argument tail when packaged `bin\sfs.cmd` is the target | The 0.6.45 GitHub Windows Scoop smoke run `25533332634` still made the first `sfs version` call fall through to usage-only output after the `CMDCMDLINE` fallback | Make `bin\sfs.ps1` the Scoop manifest primary shim target. Keep packaged `sfs.cmd` only as a direct-run compatibility trampoline |
| P14 | A `ValueFromRemainingArguments` script param can also miss args from generated Scoop PowerShell shims | The 0.6.46 GitHub Windows Scoop smoke run `25534566676` showed `Get-Command sfs` now pointing to `sfs.ps1`, but `sfs version` still fell through to usage-only output | Remove the packaged `sfs.ps1` param block and use PowerShell automatic `$args` as the primary shim argument source |
| P15 | The bare `sfs` generated shim must not be the Windows PowerShell/cmd contract | The 0.6.47 GitHub Windows Scoop smoke run `25535059980` showed `Get-Command sfs` pointing to `sfs.ps1`, but `sfs version` still fell through to usage-only output | Pin Windows PowerShell/cmd smoke and user guidance to `sfs.cmd`. Only Git Bash/WSL smoke validates bare `sfs` |
| P16 | A generated `sfs.cmd` shim can also fail to pass args to the `bin\sfs.ps1` target | The 0.6.48 GitHub Windows Scoop smoke run `25539387684` showed `sfs.cmd version` still printing generic usage | The post-install hook overwrites shims-directory `sfs.cmd`, `sfs.ps1`, and extensionless `sfs` with deterministic wrappers owned by Solon |
| P17 | An env-only hardened `sfs.cmd` shim can still fail to revive args on the GitHub runner | The 0.6.49 GitHub Windows Scoop smoke run `25541086874` showed post-install hardening ran, but `sfs.cmd version` still printed generic usage | The hardened `sfs.cmd` shim passes both the numbered env bridge and `%*` positional fallback to `sfs.ps1` |
| P18 | PowerShell can parse `$brokenVersion:` in a Git refspec as scoped-variable syntax | The 0.6.50 GitHub Windows Scoop smoke run `25542777986` tried to fetch `refs/tags/v/tags/v0.6.49` before install | Brace the variable as `${brokenVersion}` in tag fetch/archive refs |
| P19 | The `%*` positional fallback can be empty after `shift` consumes the batch args | The 0.6.51 GitHub Windows Scoop smoke run `25543802195` showed the hardened `sfs.cmd version` still printing usage-only output immediately after install | Save original `%*` as `SFS_NATIVE_RAW_ARGS` before `shift`, let `sfs.ps1` read that raw arg fallback after the env bridge, and treat empty resolved arg arrays as unusable |
| P20 | Child PowerShell can expose `CMDCMDLINE` for `powershell.exe -File ...`, not the original wrapper invocation | The 0.6.52 GitHub Windows Scoop smoke run `25545120029` still made `sfs.cmd version` fall through to usage even though the shim contained `SFS_NATIVE_RAW_ARGS` | Save `!CMDCMDLINE!` as `SFS_NATIVE_CMDLINE` inside the delayed-expansion dispatch block, then let `sfs.ps1` parse that saved command line after the raw-arg fallback and trim `cmd.exe` shell-control tails |
| P21 | Delayed expansion did not recover the wrapper command line on the GitHub runner | The 0.6.53 GitHub Windows Scoop smoke run `25546859759` still made the first `sfs.cmd version` print usage-only output | If env/raw/saved command line sources are empty, `sfs.ps1` queries the parent `cmd.exe` process command line through `Win32_Process`, extracts the tail after the `sfs.cmd` command name before whitespace splitting, and parses that before child `CMDCMDLINE` |
| P22 | Child PowerShell can still start without real argv even after multiple fallback sources exist | The 0.6.54 GitHub Windows Scoop smoke run `25548381094` showed post-install hardening, but the first `sfs.cmd version` still printed usage-only output | The 0.6.55 candidate added a `--% %SFS_NATIVE_RAW_ARGS%` experiment, superseded by the P23 trace |
| P23 | The PowerShell-sensitive `$Args` parameter name collapsed live env-bridge args to empty/help at function boundaries | The 0.6.55 trace run `25554923214` showed `CMD_FIRST=version` and `PS_ENV_ARGS=version`; first it fell through to `PS_SELECTED_SOURCE=empty`, then after the guard fix it reached `PS_SELECTED_SOURCE=env` and `PS_FINAL_ARGS=version` but native dispatch still printed usage | Rename the guard to `$Items`, native dispatch/self-upgrade helpers to `$InvocationArgs`, and remove `--% %SFS_NATIVE_RAW_ARGS%` dispatch. Windows smoke requires `SFS_ARGTRACE_PS_SELECTED_SOURCE=env` and `SFS_ARGTRACE_PS_FINAL_ARGS=.*version` |
| P24 | The Windows CI self-upgrade smoke can stall at the interactive upgrade prompt rather than a runtime loop, and live trace can be hidden by assignment | The 0.6.56 trace run `25557503623` stopped advancing in `Smoke thin project in PowerShell`; the `Tee-Object` pipeline was assigned to `$upgradeLines`, so `SFS_ARGTRACE_*` lines were not emitted live, and code trace showed `upgrade.sh` could reopen `/dev/tty` under CI Git Bash and wait at `continue upgrade?` | Do not reconnect `/dev/tty` in CI, run the smoke as `sfs.cmd upgrade --yes`, stream `Tee-Object` without assignment, resolve self-upgrade reloads through Scoop `current\bin\sfs.ps1`, and trace `PS_RELOAD_SCRIPT` |

## User-Visible Symptoms

- Inside the agent sandbox, `sfs.cmd start "이미지 프롬프트 고도화"` failed before
  Git Bash could start with `fatal error - couldn't create signal pipe, Win32 error 5`.
- Outside the sandbox, the retry exited 0 but printed no output.
- `.sfs-local/current-sprint` pointed at `2026-W19-sprint-1`, and the sprint
  directory existed, but the user did not receive reliable next-step output.
- `sfs.cmd status`, `sfs.cmd context cat kernel`, and `sfs.cmd context path kernel`
  printed generic usage/help instead of real state or context.
- `.sfs-local/events.jsonl` recorded the Korean `sprint_start` goal as mojibake.

## What Was A Bug

An empty sprint directory after `sfs start` is not, by itself, a bug. `start`
creates the sprint workspace and pointer; `brainstorm`, `plan`, `review`, and
`retro` create their step files lazily.

The real bugs were:

- read-only commands lost arguments and degraded to usage-only output
- `start` could leave empty output and corrupted Korean event text
- agent routing could mistake partial state plus exit code 0 for success

## Root Causes

1. `bin/sfs.ps1` used a `ValueFromRemainingArguments` script param that did not
   bind reliably for real Windows PowerShell 5.1 `powershell.exe -File ...`
   invocation shapes, so command words could disappear.
2. `bin/sfs.cmd` still had a mutating-command path that forwarded raw `%*`
   directly into Git Bash. That path is brittle for Windows quoting and Unicode.
3. Windows agent sandboxes can block Git Bash process creation. Read-only
   recovery commands must therefore work through native PowerShell before Bash
   is involved.
4. Follow-up validation found a separate Homebrew installed-layout issue:
   `CHANGELOG.md` lives at the Cellar version root, not inside `libexec/`.
5. A 0.6.36 Scoop install exposed another Windows self-update issue:
   `sfs.cmd upgrade` ran `scoop update sfs` from the same batch file that Scoop
   replaced under `current\bin\sfs.cmd`. After replacement, `cmd.exe` could
   resume at the wrong command offset, executing tail fragments such as
   `TIVE_READONLY_DONE` and `LF_UPGRADE_DONE` as commands.
6. 0.6.38 still left a residual risk for machines upgrading from 0.6.36 because
   the running process was still the old `sfs.cmd`. After a successful 0.6.38
   install, shorter tail fragments such as `e` and `*` could appear once. That
   proved that moving ownership to `sfs.ps1` was not sufficient; the batch file
   also must not read the next physical line after PowerShell returns.
7. 0.6.40's `install-cli-discovery.ps1` did include a logical `catch`, but the
   file was BOM-less UTF-8 and still contained non-ASCII dash/arrow text. Under
   Windows PowerShell 5.1 / Scoop post-install, legacy code-page decoding could
   corrupt those bytes and make the parser misread strings or blocks.
8. `sfs.cmd` cached top-level `%*` into `SFS_ORIGINAL_ARGS` before forwarding to
   PowerShell. Under the actual Scoop shim path, that cached value could be empty
   even though the call-label still had the real arguments.
9. After 0.6.41 removed the parser issue and `SFS_ORIGINAL_ARGS`, the GitHub
   Windows Scoop smoke still failed with usage-only `sfs version`. That proved
   the batch-label forwarding structure itself was not stable enough under the
   Scoop shim path.
10. After 0.6.42 removed batch labels, the GitHub Windows Scoop smoke still
    failed with usage-only `sfs version`. The remaining bridge was
    `powershell.exe -File sfs.ps1 %*`, so 0.6.43 tried PowerShell `-Command`
    plus `@args` forwarding.
11. The 0.6.43 `-Command @args` bridge also failed in GitHub Windows Scoop smoke
    run `25532139459` with usage-only `sfs version`. The Windows/Scoop path
    therefore must not rely on PowerShell CLI argument binding at all. Batch
    creates a numbered env arg bridge, and `sfs.ps1` reads it directly.
12. The 0.6.44 numbered env arg bridge also failed in GitHub Windows Scoop smoke
    run `25532838102` with usage-only `sfs version`. That means the generated
    Scoop shim can start the target `sfs.cmd` with empty `%1..%n`. The last
    Windows-native fallback is recovering the tail after `sfs` / `sfs.cmd` from
    the original `CMDCMDLINE`.
13. The 0.6.45 `CMDCMDLINE` fallback also failed to prevent usage-only
    `sfs version` in GitHub Windows Scoop smoke run `25533332634`. That proves
    the generated Scoop shim -> packaged `bin\sfs.cmd` target shape itself can
    lose the argument tail. The Scoop primary shim target must be the PowerShell
    script, `bin\sfs.ps1`.
14. The 0.6.46 Scoop `bin\sfs.ps1` primary target was applied in GitHub Windows
    Scoop smoke run `25534566676`: `Get-Command sfs` pointed at
    `ExternalScript ...\sfs.ps1`. Even then, the `ValueFromRemainingArguments`
    param did not receive `version`, so `sfs version` still fell through to
    usage-only output. Packaged `sfs.ps1` must read PowerShell automatic `$args`
    without a script param block.
15. After the 0.6.47 param-block removal, GitHub Windows Scoop smoke run
    `25535059980` still made bare `sfs version` fall through to usage-only
    output. That route is not the user contract for Windows PowerShell/cmd.
    The Windows pass condition is therefore pinned to `sfs.cmd version`,
    `sfs.cmd status`, `sfs.cmd context cat ...`, `sfs.cmd start ...`, and
    `sfs.cmd upgrade`; bare `sfs` remains a Git Bash/WSL smoke target only.
16. After the 0.6.48 `sfs.cmd` contract pin, GitHub Windows Scoop smoke run
    `25539387684` showed `Get-Command sfs.cmd` resolving to
    `...\scoop\shims\sfs.cmd`, but `sfs.cmd version` still fell through to
    generic usage. That proves the generated `sfs.cmd` shim can also lose the
    argument tail before packaged `bin\sfs.ps1` sees it. The installed
    shims-directory entrypoints must be overwritten by deterministic wrappers
    during post-install instead of trusting Scoop's generated wrappers as the
    final user path.
17. After the 0.6.49 post-install hardening, GitHub Windows Scoop smoke run
    `25541086874` printed the `Scoop shims hardened` marker, but `sfs.cmd version`
    still fell through to usage. That proves an env-only hardened `sfs.cmd` shim
    can still fail to revive the argument tail on the GitHub runner. The hardened
    shim must pass both the env bridge and the `%*` positional fallback.
18. The 0.6.50 Windows smoke run `25542777986` failed before install because
    PowerShell parsed `$brokenVersion:` in the Git fetch refspec as scoped
    variable syntax. The workflow must use `${brokenVersion}` when a variable is
    immediately followed by `:`.
19. The 0.6.51 Windows smoke run `25543802195` failed immediately after install.
    The hardened `sfs.cmd` shim text contained both `SFS_NATIVE_ARGC` and `%*`,
    but `sfs.cmd version` still printed usage-only output. The batch arg
    collection loop consumed `%1..%n` with `shift` before PowerShell was invoked,
    so the original `%*` tail must be saved before the loop.

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

## Discovered Issues

- If the failed path and successful path are clear, Windows wrappers should be
  fixed to the successful path by default.
- Exit code 0 plus empty output is not enough to accept adapter success. After
  `start`, check `.sfs-local/current-sprint`, the sprint directory, and
  `sfs.cmd status`.
- `context cat` returning usage is a regression signal, not useful help.
- Mojibake in Korean goals points to a UTF-8 bridge problem or raw Bash path leak.
- Package layout can differ from source layout. Homebrew keeps runtime files
  under `libexec/` while some top-level docs live at the Cellar version root.
- Scoop self-upgrade must not be owned by the batch file that Scoop replaces
  during the update. Windows self-upgrade belongs in `sfs.ps1`. The batch wrapper
  must also avoid reading any following physical line after `sfs.ps1` returns.
- Non-ASCII text in BOM-less scripts can break Windows PowerShell 5.1 parsing,
  even if the source looks valid locally. Runtime `.ps1` / `.cmd` files should
  remain ASCII-only.
- PowerShell CLI argv forwarding repeatedly failed under Windows/Scoop shims.
  A single cached `%*` value is still forbidden, and the
  `--% %SFS_NATIVE_RAW_ARGS%` experiment is also forbidden because the runner
  turned it into the wrong token. The default contract is the numbered env arg
  bridge (`SFS_NATIVE_ARGC`, `SFS_NATIVE_ARG_N`), with raw/saved/parent
  fallbacks only when that bridge is empty.
- Under generated Scoop shims, the target batch `%1..%n` can itself be empty.
  In that case, `CMDCMDLINE` is the final Windows-native recovery source.
- The 0.6.45 failure showed that even `CMDCMDLINE` is not enough inside the
  target batch path. Scoop installations must use generated shim -> packaged
  `.ps1`, not generated shim -> packaged `.cmd`, as the primary path.
- The 0.6.46 failure showed that `ValueFromRemainingArguments` is also not
  enough under generated Scoop PowerShell shims. Packaged `sfs.ps1` must read
  automatic `$args` without a param block.
- The 0.6.47 failure showed that bare `sfs` generated shims must not be used as
  the Windows PowerShell/cmd contract. The user-facing Windows entrypoint is
  `sfs.cmd`.
- The 0.6.48 failure showed that generated `sfs.cmd` shims themselves must not
  be treated as the Windows PowerShell/cmd contract. The pass condition is the
  deterministic `sfs.cmd` wrapper written by post-install, not merely a generated
  shim with that name.
- The 0.6.49 failure showed that even a post-install-owned shim is not enough if
  it only forwards through the env bridge. The Windows PowerShell/cmd path needs
  both the env bridge and positional fallback.
- PowerShell variables followed by `:` inside strings need braces. Otherwise
  release smoke can fail before it reaches the runtime behavior being tested.
- `%*` after a batch `shift` loop is not a reliable positional fallback on the
  Windows runner. Preserve the raw argument tail before shifting.

## Windows Validation Commands

These commands should not fall back to generic usage:

```powershell
sfs.cmd version --check
sfs.cmd status
sfs.cmd context cat kernel
sfs.cmd start "이미지 프롬프트 고도화"
sfs.cmd status
```

An empty sprint directory after `start` is acceptable until the next step creates
files. Empty command output, usage-only `status`, or usage-only `context cat` is
not acceptable; run `sfs.cmd update` and re-check.
If an already-installed 0.6.49-or-older wrapper makes `sfs.cmd update` itself
fall through to usage, run `scoop update` and then `scoop update sfs` directly
in PowerShell once, then run `sfs.cmd upgrade --no-self-upgrade` from the
project folder.

## Verification Evidence

- `tests/test-windows-agent-adapter-fallback.sh` locks the Scoop manifest
  primary shim target to `bin\sfs.ps1`, keeps packaged `sfs.cmd` as a
  call-label-dispatch-free compatibility trampoline, rejects raw Git Bash `%*`
  forwarding, and confirms that `sfs.cmd` has no `call :...` labels and does not
  call `scoop update` directly.
- Windows Scoop smoke installs a local previous package first, publishes the
  current package to the same local bucket, then runs `sfs.cmd upgrade` for the
  self-upgrade path itself. The smoke fails if output contains
  `TIVE_READONLY_DONE`, `LF_UPGRADE_DONE`, `e`, or `*` tail fragments.
- The same Windows smoke installs the real `v0.6.49` archive, proves
  `sfs.cmd version` still falls through to usage, then verifies direct
  `scoop update` plus `scoop update sfs` recovers to the current runtime.
- The same Windows smoke runs
  `sfs.cmd start --id ci-korean-sprint-test --force "스프린트 생성 테스트"` and
  verifies both `.sfs-local/current-sprint` and the Korean `events.jsonl` goal.
- The same Windows smoke also forces the saved-cmdline fallback with env/raw
  args empty and verifies `version`, `context cat kernel`, and `start` through
  `cmd.exe /d /c "sfs.cmd ... && sfs.cmd --help >NUL"` command lines.
- The same Windows smoke creates a temporary `sfs.cmd` probe wrapper that clears
  env/raw/saved command-line sources, then verifies `version`, `context cat
  kernel`, and `start` through the parent `cmd.exe` command-line fallback.
- The Windows smoke also checks that the post-install and direct-Scoop-recovery
  hardened `sfs.cmd` shims preserve `SFS_NATIVE_RAW_ARGS` without using
  `--% %SFS_NATIVE_RAW_ARGS%` dispatch.
- The Windows smoke runs `SFS_WINDOWS_ARG_TRACE=1` and requires
  `SFS_ARGTRACE_CMD_ARGC`, `SFS_ARGTRACE_PS_SELECTED_SOURCE=env`, and
  `SFS_ARGTRACE_PS_FINAL_ARGS=.*version` before accepting `sfs.cmd version`.
- `tests/test-windows-wrapper-incident-report.sh` verifies the P1-P24 issue
  summary, the 0.6.56 report links, and the Homebrew installed-layout fallback.
- `tests/test-docs-model-routing.sh` validates both source docs and Homebrew
  installed docs layout.
- 0.6.56 is the final follow-up baseline that includes the Windows
  `sfs.cmd upgrade` self-replacement fix, the installed incident-report test
  layout fix, the batch same-line exit hardening, ASCII-only Windows scripts,
  `SFS_ORIGINAL_ARGS` removal, call-label dispatch removal, single-channel
  `-File ... %*` / `-Command @args` / empty `%1..%n` failure learnings, the numbered env arg
  bridge, the `CMDCMDLINE` fallback, the Scoop primary `bin\sfs.ps1` shim
  target, script-param removal, the automatic `$args` primary path, the Windows
  PowerShell/cmd `sfs.cmd` contract, the generated `sfs.cmd` shim failure
  learning, the post-install deterministic shim overwrite, the delayed-expansion
  saved-cmdline bridge, parent `cmd.exe` command-line fallback,
  the usable-args `$Items` root-cause fix,
  shell-control tail trimming, the hardened shim
  env+positional dual forwarding, the braced PowerShell tag-refspec smoke fix,
  and the shift-before-raw-arg-capture fix.
