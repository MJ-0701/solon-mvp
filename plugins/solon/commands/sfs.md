---
name: sfs
description: Priority-1 Solon SFS command router. When `/sfs` or Solon work is in scope, run the deterministic platform adapter first (`sfs` on macOS/Linux/Git Bash/WSL, `sfs.cmd` on Windows PowerShell/cmd), then read routed context with `sfs context cat ...` or native Windows `sfs.cmd context cat ...`.
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
2. Verify the platform adapter exists: `command -v sfs` on macOS/Linux/Git
   Bash/WSL, or `where sfs.cmd` on Windows PowerShell/cmd.
3. Run the platform adapter first: `sfs <command> <args>` on macOS/Linux/Git
   Bash/WSL, `sfs.cmd <command> <args>` on Windows PowerShell/cmd. Vendored fallback:
   `bash .sfs-local/scripts/sfs-dispatch.sh <command> <args>`.
4. If Windows execution fails before SFS starts with Git Bash
   `couldn't create signal pipe, Win32 error 5`, rerun the same command via
   `sfs.cmd ...` outside the sandbox. If that run is empty or fails, report the
   exact stdout/stderr and ask for `sfs.cmd --help`.
   For read-only fallback on Windows, `sfs.cmd status`, `sfs.cmd version`, and `sfs.cmd context path/cat`
   are native read-only and must not start Git Bash. If a Codex/Claude/Gemini
   runner cannot launch Git Bash, use those native read-only commands for
   context/status and tell the user to run mutating commands in PowerShell/cmd.
5. Empty adapter output is not success for visible SFS commands. `start`,
   `brainstorm`, `plan`, `implement`, `review`, `retro`, `adopt`, `profile`,
   `upgrade`, and `agent install` must print output or change their expected
   artifact. For `start`, verify `.sfs-local/current-sprint` and the sprint
   directory exist before reporting success.
6. Print stdout verbatim; on failure include stderr and exit code.
7. Read `sfs context cat kernel`, `sfs context cat index`, then only the routed module. On Windows PowerShell/cmd use native `sfs.cmd context cat ...` so Git Bash is not started. Resolve command modules as `sfs context cat commands/<command>.md` (for example, `commands/start.md`) or via the command alias (`sfs context cat start`).
8. For bash-first commands, do not refine artifacts, but a compact state/Next is allowed.
9. For `profile`, edit only the `SFS.md` project overview section.
10. For hybrid commands, refine pointed artifacts and answer with one Solon report.
11. AI-era fundamentals apply across all gates, not only implement: shared
   design concept, domain language, feedback loop, interface/artifact boundary,
   and gray-box delegation.
12. For implementation and review work, follow the routed context guardrails:
    surface material assumptions, choose the smallest useful slice, keep changes
    surgical, read actual files/errors before fixing, verify before completion,
    and report exact evidence.
    Gate 3 (Plan) ready-for-implement routes to `sfs review --gate 3` first;
    do not offer `sfs implement` or worker/model handoff until plan review
    passes. Keep C-Level and worker/generator responsibilities separate:
    C-Level owns intent, architecture, AC, and review handoff; worker/generator
    owns fixed implementation slices.
    Codex worker default is `gpt-5.3-codex`; `gpt-5.3-codex-spark` is helper-only
    for bounded mechanical subtasks after scope/files_scope/AC are
    locked. Complex shared behavior escalates to high reasoning before coding.
    Multi-agent implement is optional, never the default: use single-agent mode unless the user selects parallel agents, each lane has disjoint files_scope and a clear native-language commit message, and post-implement cross review is recorded before Gate 6. Commit messages default to the user's native/workspace language; English is only the default when that is the user or repo language.
    Gate 3 review must self-review until PASS before cross review. Review round
    count, lens count, or "enough review" is not a PASS; partial/fail routes to
    rework and same-gate self-review.
13. `.sfs-local/` is private workbench state. Shared durable docs belong under
    `docs/solon/`; do not ask users to commit `.sfs-local` unless their team
    explicitly opts in.
14. In Solon reports, show gates as `Gate N (Name)`, not naked ids:
   Gate 1 (Intake), Gate 2 (Brainstorm), Gate 3 (Plan),
   Gate 4 (Design), Gate 5 (Handoff), Gate 6 (Review),
   Gate 7 (Retro). Use gate numbers 1..7 for new CLI examples.
15. Solon reports should feel like a compact console dashboard, not a flat
    bullet dump. Use a clear title/verdict strip, 2-4 labeled status panels,
    one action rail, and at most 1-3 questions. Keep long evidence behind file
    paths or source labels; do not make every line the same visual weight.
16. Decision questions must be self-contained: before any `Q1`, `D1`, or
    option id, explain in plain user language what is being decided, why it
    matters, the recommended default, and what each option changes. Labels are
    cross-references, not the explanation.
17. Taxonomy is a product function, not an org division or copy polish. Match
    the user's native/workspace language and project terms; do not
    machine-translate SFS command/domain terms into mixed phrases or expose app
    placeholder labels such as `Other` or `Type something` as product choices.
18. If a required command argument is missing, ask one plain-language question
    in the user's language instead of opening a multi-choice prompt. For Korean
    `sfs start` with no goal, ask: `이번 sprint 목표를 한 줄로 말해 주세요. 예:
    "docker compose 구조 리디자인"`.
