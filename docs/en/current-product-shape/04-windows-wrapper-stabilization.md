---
doc_id: sfs-current-product-shape-en-4
title: "Windows Wrapper Stabilization"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/current-product-shape.md
summary: "Windows Wrapper Stabilization"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Windows Wrapper Stabilization

The Windows PowerShell/cmd user entrypoint is fixed to `sfs.cmd`. Git Bash/WSL
keep using `sfs`, like macOS/Linux. Current Scoop manifests keep the
generated shim target on packaged `bin\sfs.ps1`, but the post-install hook
overwrites the shims-directory `sfs.cmd`, `sfs.ps1`, and extensionless `sfs`
with deterministic wrappers because generated `sfs.cmd` / `sfs.ps1` shims can
drop arguments before the package sees them. The PowerShell/cmd smoke and user
guidance only treat the verified `sfs.cmd` route as the Windows pass condition.
Packaged `sfs.cmd` remains a direct-run compatibility trampoline and passes
arguments to `sfs.ps1` through the `SFS_NATIVE_ARGC` / `SFS_NATIVE_ARG_N`
numbered env bridge. If that is also empty, `sfs.ps1` reads the original
`SFS_NATIVE_RAW_ARGS`, delayed-expansion `SFS_NATIVE_CMDLINE`, the parent
`cmd.exe` command line, and `CMDCMDLINE` as fallbacks.
Saved command-line parsing also trims `cmd.exe` shell-control tails such as `&& sfs.cmd --help`.
`sfs.ps1` owns both read-only commands and mutating commands such as
`start`. Mutating commands go through the `sfs.cmd -> sfs.ps1 -> Bash runtime`
bridge. The hardened Scoop `sfs.cmd` shim also carries the saved raw tail into
the environment before writing the numbered env bridge; `sfs.ps1` reads it as a
fallback when the env bridge is empty. That is different from the old
single-source `-File ... %*` bridge that failed under generated Scoop shims. The
raw Git Bash `%*` path, batch-label forwarding path,
single-source `-File ... %*` bridge, `-Command @args` bridge, empty `%1..%n` path, generated bare
`sfs` PowerShell shim path, generated shim -> packaged `.cmd` path, and generated `sfs.cmd` shim path are no longer defaults because
they already failed for sandbox startup, argument forwarding,
UTF-8 output, and Scoop shims. `sfs.cmd upgrade` also delegates Scoop
self-upgrade to `sfs.ps1` instead of running `scoop update sfs` from the batch
file that Scoop replaces. `sfs.ps1` normalizes numbered env bridge args,
the raw arg tail, the saved cmdline, the parent command line, `CMDCMDLINE`, and `$MyInvocation.UnboundArguments`, and owns `version`,
`status`, `guide`, `context`, Scoop self-upgrade, and Bash fallback. `sfs.cmd`
exits on the same parsed line after calling PowerShell, and Windows runtime `.ps1` / `.cmd`
files stay ASCII-safe for Windows PowerShell 5.1. That covers the `context cat`
/ `start` usage-only regression, the batch tail-fragment regression, and the
PowerShell parser regression.

An empty sprint directory after `sfs start` can be normal. Step files are created
later by `brainstorm`, `plan`, `review`, and `retro`. Empty command output,
usage-only `sfs.cmd status`, or usage-only `sfs.cmd context cat kernel` is a
failure signal. The full root cause and validation flow are in the
[Windows SFS wrapper incident report](./windows-wrapper-incident-0.6.56.md).

