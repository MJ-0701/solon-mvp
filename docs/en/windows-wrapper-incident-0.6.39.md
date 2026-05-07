# Windows SFS Wrapper Incident Report (0.6.35 -> 0.6.39)

**Language**: [한국어](../ko/windows-wrapper-incident-0.6.39.md) / English

This report summarizes the Windows `sfs.cmd` / `sfs.ps1` wrapper failures found
while running `$sfs start 이미지 프롬프트 고도화` and `sfs.cmd upgrade` on a Windows PC.
The final baseline is 0.6.39.

## One-Line Conclusion

Windows must use the known-good path by default:
`sfs.cmd -> sfs.ps1 -> Bash runtime`. The raw Git Bash `%*` bridge had already
failed for sandbox startup, argument forwarding, and UTF-8 output, so it must not
be the default path for mutating commands. Scoop self-upgrade must also be owned
by `sfs.ps1`, not by the replaceable `sfs.cmd` batch wrapper, and `sfs.cmd` must
exit on the same parsed line after calling `sfs.ps1`.

## Final Issue Summary

| # | Issue | Observed Symptom | Final Action |
|---|---|---|---|
| P1 | Windows agent sandbox blocks Git Bash creation | `couldn't create signal pipe, Win32 error 5` | Handle read-only recovery through native PowerShell `sfs.cmd status/version/context` |
| P2 | PowerShell `-File` invocation can lose script-param arguments | `sfs.cmd status`, `sfs.cmd context cat kernel`, `sfs.cmd start ...` print usage only | `sfs.ps1` avoids `ValueFromRemainingArguments` and normalizes `$args` / `$MyInvocation.UnboundArguments`, nested arrays, literal `-SfsArgs`, and `--%` |
| P3 | Mutating commands leaked through raw Git Bash `%*` | Empty output after `start`; Korean goal can become mojibake | Fix default bridge to `sfs.cmd -> sfs.ps1 -> Bash runtime` |
| P4 | Partial success can be mistaken for success | Exit code 0, no next-step output, only sprint pointer created | Empty output is not success. Check `current-sprint`, sprint dir, and `sfs.cmd status` |
| P5 | Replaceable batch kept reading after delegated self-upgrade | `TIVE_READONLY_DONE`, `LF_UPGRADE_DONE`, `e`, `*` executed like commands | Remove Scoop update from `sfs.cmd`; `sfs.ps1` owns self-upgrade/reload; batch calls PowerShell and exits on the same parsed line |
| P6 | Installed docs layout differs from source layout | Homebrew installed tests could not find `CHANGELOG.md` / `RELEASE-NOTES.md` | Tests resolve both `libexec` and the Cellar version root |

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

## Fixes Applied

- `sfs.cmd` tries native read-only dispatch first, then routes remaining commands
  through the packaged `sfs.ps1` bridge.
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
- 0.6.39 changes the non-native `sfs.cmd` PowerShell dispatch to
  `call :powershell_dispatch %* & call exit /b %%ERRORLEVEL%%`, and the actual
  `powershell.exe -File sfs.ps1 ...` dispatch also exits on the same parsed line.
  That prevents `cmd.exe` from reading arbitrary lines from a replaced batch file
  after self-upgrade.

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

## Verification Evidence

- `tests/test-windows-agent-adapter-fallback.sh` locks
  `sfs.cmd -> sfs.ps1 -> Bash runtime`, rejects raw Git Bash `%*` forwarding,
  and confirms that `sfs.cmd` does not call `scoop update` directly.
- Windows Scoop smoke installs a local previous package first, publishes the
  current package to the same local bucket, then runs `sfs.cmd upgrade` for the
  self-upgrade path itself. The smoke fails if output contains
  `TIVE_READONLY_DONE`, `LF_UPGRADE_DONE`, `e`, or `*` tail fragments.
- The same Windows smoke runs
  `sfs.cmd start --id ci-korean-sprint-test --force "스프린트 생성 테스트"` and
  verifies both `.sfs-local/current-sprint` and the Korean `events.jsonl` goal.
- `tests/test-windows-wrapper-incident-report.sh` verifies the P1-P6 issue
  summary, the 0.6.39 report links, and the Homebrew installed-layout fallback.
- `tests/test-docs-model-routing.sh` validates both source docs and Homebrew
  installed docs layout.
- 0.6.39 is the final follow-up baseline that includes the Windows
  `sfs.cmd upgrade` self-replacement fix, the installed incident-report test
  layout fix, and the batch same-line exit hardening.
