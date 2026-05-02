---
name: sfs
description: Solon SFS command router. Run the deterministic `sfs` bash adapter first, then read only `.sfs-local/context/kernel.md`, `_INDEX.md`, and the routed context module.
argument-hint: "<command> [args]"
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# Solon SFS — `/sfs`

User arguments:
```text
$ARGUMENTS
```

1. Verify `command -v sfs`.
2. Run `sfs <command> <args>`; vendored fallback:
   `bash .sfs-local/scripts/sfs-dispatch.sh <command> <args>`.
3. Print stdout verbatim; on failure include stderr and exit code.
4. Read `.sfs-local/context/kernel.md`, `_INDEX.md`, then only the routed module.
5. For bash-first commands, do not refine artifacts, but a compact state/Next is allowed.
6. For hybrid commands, refine pointed artifacts and answer with one Solon report.
