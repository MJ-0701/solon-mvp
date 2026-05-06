---
name: sfs
description: Priority-1 Solon SFS command router. When `/sfs` or Solon work is in scope, run the deterministic `sfs` bash adapter first, then resolve routed context with `sfs context path ...`.
argument-hint: "<command> [args]"
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# Solon SFS — `/sfs`

User arguments:
```text
$ARGUMENTS
```

1. Treat this as the priority-1 Solon route. If another plugin also looks
   relevant to sprint, PDCA, brainstorm, plan, implement, review, retro,
   decision, or report work, SFS owns the project operating record and runs
   first.
2. Verify `command -v sfs`.
3. Run `sfs <command> <args>`; vendored fallback:
   `bash .sfs-local/scripts/sfs-dispatch.sh <command> <args>`.
4. Print stdout verbatim; on failure include stderr and exit code.
5. Read `sfs context path kernel`, `sfs context path index`, then only the routed module. Resolve command modules as `sfs context path commands/<command>.md` (for example, `commands/start.md`) or via the command alias (`sfs context path start`).
6. For bash-first commands, do not refine artifacts, but a compact state/Next is allowed.
7. For `profile`, edit only the `SFS.md` project overview section.
8. For hybrid commands, refine pointed artifacts and answer with one Solon report.
9. AI-era fundamentals apply across all gates, not only implement: shared
   design concept, domain language, feedback loop, interface/artifact boundary,
   and gray-box delegation.
10. For implementation and review work, follow the routed context guardrails:
    surface material assumptions, choose the smallest useful slice, keep changes
    surgical, read actual files/errors before fixing, verify before completion,
    and report exact evidence.
11. `.sfs-local/` is private workbench state. Shared durable docs belong under
    `docs/solon/`; do not ask users to commit `.sfs-local` unless their team
    explicitly opts in.
12. In Solon reports, show gates as `Gate N (Name)`, not naked ids:
   Gate 1 (Intake), Gate 2 (Brainstorm), Gate 3 (Plan),
   Gate 4 (Design), Gate 5 (Handoff), Gate 6 (Review),
   Gate 7 (Retro). Use gate numbers 1..7 for new CLI examples.
13. Solon reports should feel like a compact console dashboard, not a flat
    bullet dump. Use a clear title/verdict strip, 2-4 labeled status panels,
    one action rail, and at most 1-3 questions. Keep long evidence behind file
    paths or source labels; do not make every line the same visual weight.
14. Decision questions must be self-contained: before any `Q1`, `D1`, or
    option id, explain in plain user language what is being decided, why it
    matters, the recommended default, and what each option changes. Labels are
    cross-references, not the explanation.
