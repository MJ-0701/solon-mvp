# Windows SFS Wrapper Incident Report (0.6.35 -> 0.6.43)

**Language**: [한국어](../ko/windows-wrapper-incident-0.6.43.md) / English

This report summarizes the Windows `sfs.cmd` / `sfs.ps1` wrapper failures found
while running `$sfs start 이미지 프롬프트 고도화` and `sfs.cmd upgrade` on a Windows PC.
The final baseline is 0.6.43.

## One-Line Conclusion

Windows must use the known-good path by default:
`sfs.cmd -> sfs.ps1 -> native read-only/Bash runtime`. The raw Git Bash `%*`
bridge and batch-label forwarding path had already failed for sandbox startup,
argument forwarding, UTF-8 output, and Scoop shims, so they must not be the
default path. Scoop self-upgrade and native read-only commands belong in
`sfs.ps1`, not in the replaceable `sfs.cmd` batch wrapper. Windows
PowerShell/cmd runtime scripts must also stay ASCII-safe so BOM-less UTF-8 is
not mis-parsed by Windows PowerShell 5.1.

## Final Issue Summary

| # | Issue | Observed Symptom | Final Action |
|---|---|---|---|
| P1 | Windows agent sandbox blocks Git Bash creation | `couldn't create signal pipe, Win32 error 5` | Handle read-only recovery through native PowerShell `sfs.cmd status/version/context` |
| P2 | PowerShell `-File` invocation can lose script-param arguments | `sfs.cmd status`, `sfs.cmd context cat kernel`, `sfs.cmd start ...` print usage only | `sfs.ps1` avoids `ValueFromRemainingArguments` and normalizes `$args` / `$MyInvocation.UnboundArguments`, nested arrays, literal `-SfsArgs`, and `--%` |
| P3 | Mutating commands leaked through raw Git Bash `%*` | Empty output after `start`; Korean goal can become mojibake | Fix default bridge to `sfs.cmd -> sfs.ps1 -> Bash runtime` |
| P4 | Partial success can be mistaken for success | Exit code 0, no next-step output, only sprint pointer created | Empty output is not success. Check `current-sprint`, sprint dir, and `sfs.cmd status` |
| P5 | Replaceable batch kept reading after delegated self-upgrade | `TIVE_READONLY_DONE`, `LF_UPGRADE_DONE`, `e`, `*` executed like commands | Remove Scoop update from `sfs.cmd`; `sfs.ps1` owns self-upgrade/reload; batch calls PowerShell and exits on the same parsed line |
| P6 | Installed docs layout differs from source layout | Homebrew installed tests could not find `CHANGELOG.md` / `RELEASE-NOTES.md` | Tests resolve both `libexec` and the Cellar version root |
| P7 | Windows PowerShell 5.1 parsed a BOM-less UTF-8 PowerShell script through a legacy code page | `install-cli-discovery.ps1` parser error: `Try statement is missing its Catch or Finally block` | Keep Windows `.ps1` / `.cmd` runtime files ASCII-only and enforce that in release guards |
| P8 | Batch forwarded cached `SFS_ORIGINAL_ARGS` instead of the call-label `%*` | `sfs version` fell through to usage because the Scoop shim path reached `sfs.ps1` with empty args | Forward call-label `%*` directly to `sfs.ps1` |
| P9 | Batch-label forwarding itself remained unstable under Scoop shims | The 0.6.41 GitHub Windows Scoop smoke passed post-install but `sfs version` still fell through to usage | Reduce `sfs.cmd` to a label-free thin PowerShell trampoline; move native/read-only/upgrade ownership to `sfs.ps1` |
| P10 | `powershell.exe -File sfs.ps1 %*` also lost args under Scoop shims | The 0.6.42 GitHub Windows Scoop smoke had a label-free `sfs.cmd`, but `sfs version` still fell through to usage | `sfs.cmd` now uses `-Command "& $env:SFS_NATIVE_SCRIPT @args"` and `sfs.ps1` reads a positional array param before `$args` / unbound args |

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
    `powershell.exe -File sfs.ps1 %*`, so the Windows shim path needs PowerShell
    `-Command` plus `@args` forwarding instead of `-File`.

## Fixes Applied

- `sfs.cmd` is now a label-free thin PowerShell trampoline. It forwards received
  arguments directly to packaged `sfs.ps1` and exits on the same parsed line.
- `sfs.ps1` handles native read-only dispatch first, then routes remaining
  commands through the same bridge into the Bash runtime.
- `sfs.cmd` no longer uses the raw Git Bash `%*` bridge for mutating commands.
- `sfs.ps1` no longer depends on a `ValueFromRemainingArguments` script param.
  It normalizes automatic `$args`, `$MyInvocation.UnboundArguments`, nested
  arrays, accidental literal `-SfsArgs`, and `--%` forms into one command list.
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
  to replace `-File` with `-Command "& $env:SFS_NATIVE_SCRIPT @args"`. `sfs.ps1`
  normalizes positional array param args, `$args`, and
  `$MyInvocation.UnboundArguments` in that order.

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
- `sfs.cmd` should not cache arguments into an environment variable for later
  forwarding. As of 0.6.43, it also avoids call-label forwarding entirely and
  passes directly from a label-free batch trampoline into `sfs.ps1`.

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
If an already-installed 0.6.41-or-older wrapper makes `sfs.cmd update` itself
fall through to usage, run `scoop update sfs` directly in PowerShell once, then
run `sfs.cmd upgrade --no-self-upgrade` from the project folder.

## Verification Evidence

- `tests/test-windows-agent-adapter-fallback.sh` locks the label-free
  `sfs.cmd -> sfs.ps1 -> Bash runtime` bridge, rejects raw Git Bash `%*`
  forwarding, and confirms that `sfs.cmd` has no `call :...` labels and does not
  call `scoop update` directly.
- Windows Scoop smoke installs a local previous package first, publishes the
  current package to the same local bucket, then runs `sfs.cmd upgrade` for the
  self-upgrade path itself. The smoke fails if output contains
  `TIVE_READONLY_DONE`, `LF_UPGRADE_DONE`, `e`, or `*` tail fragments.
- The same Windows smoke runs
  `sfs.cmd start --id ci-korean-sprint-test --force "스프린트 생성 테스트"` and
  verifies both `.sfs-local/current-sprint` and the Korean `events.jsonl` goal.
- `tests/test-windows-wrapper-incident-report.sh` verifies the P1-P10 issue
  summary, the 0.6.43 report links, and the Homebrew installed-layout fallback.
- `tests/test-docs-model-routing.sh` validates both source docs and Homebrew
  installed docs layout.
- 0.6.43 is the final follow-up baseline that includes the Windows
  `sfs.cmd upgrade` self-replacement fix, the installed incident-report test
  layout fix, the batch same-line exit hardening, ASCII-only Windows scripts,
  direct `%*` forwarding, batch-label removal, and the PowerShell
  `-Command @args` bridge.
