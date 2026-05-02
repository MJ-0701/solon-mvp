---
name: sfs
description: Solon SFS command router. Run the deterministic `sfs` bash adapter first, then resolve routed context with `sfs context path ...`.
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
4. Read `sfs context path kernel`, `sfs context path index`, then only the routed module via `sfs context path ...`.
5. For bash-first commands, do not refine artifacts, but a compact state/Next is allowed.
6. For `profile`, edit only the `SFS.md` project overview section.
7. For hybrid commands, refine pointed artifacts and answer with one Solon report.
8. AI-era fundamentals apply across all gates, not only implement: shared
   design concept, domain language, feedback loop, interface/artifact boundary,
   and gray-box delegation.
9. In Solon reports, show gates as `Gate N (Name)`, not naked ids:
   Gate 1 (Intake), Gate 2 (Brainstorm), Gate 3 (Plan),
   Gate 4 (Design), Gate 5 (Handoff), Gate 6 (Review),
   Gate 7 (Retro). Use gate numbers 1..7 for new CLI examples.
