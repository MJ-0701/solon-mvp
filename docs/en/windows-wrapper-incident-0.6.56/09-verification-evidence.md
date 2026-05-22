---
doc_id: sfs-windows-wrapper-incident-0-6-56-en-9
title: "Verification Evidence"
visibility: oss-public
doc_type: incident-report
language: en
updated: 2026-05-22
parent: docs/en/windows-wrapper-incident-0.6.56.md
summary: "Verification Evidence"
load_when: "Read when docs/en/windows-wrapper-incident-0.6.56.md routes to this section."
---
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
