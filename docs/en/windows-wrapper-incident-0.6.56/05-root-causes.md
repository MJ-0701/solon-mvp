---
doc_id: sfs-windows-wrapper-incident-0-6-56-en-5
title: "Root Causes"
visibility: oss-public
doc_type: incident-report
language: en
updated: 2026-05-22
parent: docs/en/windows-wrapper-incident-0.6.56.md
summary: "Root Causes"
load_when: "Read when docs/en/windows-wrapper-incident-0.6.56.md routes to this section."
---
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

