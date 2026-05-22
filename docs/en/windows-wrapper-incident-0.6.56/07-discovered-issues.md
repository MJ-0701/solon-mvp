---
doc_id: sfs-windows-wrapper-incident-0-6-56-en-7
title: "Discovered Issues"
visibility: oss-public
doc_type: incident-report
language: en
updated: 2026-05-22
parent: docs/en/windows-wrapper-incident-0.6.56.md
summary: "Discovered Issues"
load_when: "Read when docs/en/windows-wrapper-incident-0.6.56.md routes to this section."
---
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

