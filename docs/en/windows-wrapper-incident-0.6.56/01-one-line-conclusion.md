---
doc_id: sfs-windows-wrapper-incident-0-6-56-en-1
title: "One-Line Conclusion"
visibility: oss-public
doc_type: incident-report
language: en
updated: 2026-05-22
parent: docs/en/windows-wrapper-incident-0.6.56.md
summary: "One-Line Conclusion"
load_when: "Read when docs/en/windows-wrapper-incident-0.6.56.md routes to this section."
---
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
The follow-up trace run `25559894888` proved that the `upgrade -> update`
reload and stale-env fixes were working, then stopped after Bash `upgrade.sh`
printed `maybe_prompt_model_profile after`. The 0.6.56 baseline therefore adds
finer post-profile `SFS_UPGRADE_TRACE=1` markers and bounds the `cli-discovery`
hook plus its internal `claude`/`gemini`/`git clone` probes with timeouts, so
no external discovery command can create an unbounded wait during upgrade.
Windows
PowerShell/cmd runtime scripts must also stay ASCII-safe so BOM-less UTF-8 is
not mis-parsed by Windows PowerShell 5.1.

