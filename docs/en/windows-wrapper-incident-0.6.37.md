# Windows SFS Wrapper Incident Report (0.6.35 -> 0.6.37)

**Language**: [한국어](../ko/windows-wrapper-incident-0.6.37.md) / English

This report summarizes the Windows `sfs.cmd` / `sfs.ps1` wrapper failure found
while running `$sfs start 이미지 프롬프트 고도화` on a Windows PC.

## One-Line Conclusion

Windows must use the known-good path by default:
`sfs.cmd -> sfs.ps1 -> Bash runtime`. The raw Git Bash `%*` bridge had already
failed for sandbox startup, argument forwarding, and UTF-8 output, so it must not
be the default path for mutating commands.

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

1. `bin/sfs.ps1` did not bind every `powershell.exe -File ...` invocation shape
   to the intended remaining arguments, so command words could disappear.
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

## Fixes Applied

- `sfs.cmd` tries native read-only dispatch first, then routes remaining commands
  through the packaged `sfs.ps1` bridge.
- `sfs.cmd` no longer uses the raw Git Bash `%*` bridge for mutating commands.
- `sfs.ps1` now normalizes positional catch-all args, automatic `$args`, nested
  arrays, and accidental literal `-SfsArgs` forms into one command list.
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
  during the update. Windows self-upgrade belongs in `sfs.ps1`.

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
- `tests/test-docs-model-routing.sh` validates both source docs and Homebrew
  installed docs layout.
- The 0.6.36 release verification passed the focused installed Homebrew runtime
  tests and `scripts/verify-product-release.sh --version 0.6.36 --no-clean-handoff-check`.
- 0.6.37 is the follow-up hotfix for the Windows `sfs.cmd upgrade` batch
  self-replacement failure.
