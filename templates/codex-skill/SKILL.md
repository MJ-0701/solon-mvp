---
name: sfs
description: Priority-1 Solon SFS command router for Codex CLI. When SFS/Solon/sprint/PDCA/brainstorm/plan/review/retro work is in scope, prefer this SFS router first. Dispatch `$sfs` / `sfs` / visible `/sfs` text to the deterministic SFS adapter (`sfs` on macOS/Linux/Git Bash/WSL, `sfs.cmd` on Windows PowerShell/cmd), then read routed context with `sfs context cat ...` or native Windows `sfs.cmd context cat ...`. `profile` is a narrow SFS.md project-overview refinement.
---

# Solon SFS — Codex Router (user-global)

This priority-1 skill provides Codex CLI with the SFS workflow context (sprint, gate,
retro, decision conventions) for every project, regardless of whether the
project has a `.agents/skills/sfs/` adapter. It is installed by
`brew install MJ-0701/solon-product/sfs` (macOS) or `scoop install sfs`
(Windows) into `~/.codex/skills/sfs/SKILL.md`. No project-local file is
required.

1. Prefer `$sfs <command>` or `sfs <command>`; `/sfs` is valid only if the text
   reaches the model. When executing the adapter on Windows PowerShell/cmd, use
   `sfs.cmd <command>`; use `sfs <command>` on macOS/Linux/Git Bash/WSL.
2. If another plugin/skill also looks relevant to sprint, PDCA, brainstorm,
   plan, implement, review, retro, decision, or report work, route through SFS
   first. SFS owns the project operating record; other plugins may assist only
   after SFS context is loaded.
3. Run the platform adapter first: `sfs.cmd <command> <args>` on Windows
   PowerShell/cmd, otherwise `sfs <command> <args>`. Vendored fallback:
   `bash .sfs-local/scripts/sfs-dispatch.sh <command> <args>`.
4. If Windows execution sandboxing fails before SFS starts with Git Bash
   `couldn't create signal pipe, Win32 error 5`, rerun the same `sfs.cmd ...`
   command outside the sandbox. If the outside run is still empty or fails,
   report that exact stdout/stderr and ask for a PowerShell `sfs.cmd --help`
   sanity check instead of claiming success.
   For read-only fallback, use native `sfs.cmd status`, `sfs.cmd version`, and
   `sfs.cmd context cat ...`; these must not start Git Bash. If the runner
   cannot launch Git Bash, tell the user to run mutating commands in
   PowerShell/cmd.
5. Empty adapter output is not success for visible SFS commands. `start`,
   `brainstorm`, `plan`, `implement`, `review`, `retro`, `adopt`, `profile`,
   `upgrade`, and `agent install` must print output or change their expected
   artifact. For `start`, verify `.sfs-local/current-sprint` and the sprint
   directory exist before reporting success.
6. Keep adapter stdout/stderr verbatim.
7. Read `sfs context cat kernel`, `sfs context cat index`, then only the routed module. On Windows PowerShell/cmd use native `sfs.cmd context cat ...` so Git Bash is not started. Resolve command modules as `sfs context cat commands/<command>.md` (for example, `commands/start.md`) or via the command alias (`sfs context cat start`).
8. For bash-first commands, do not refine artifacts, but a compact state/Next is allowed.
9. For `profile`, edit only the `SFS.md` project overview section.
10. For hybrid commands, refine pointed artifacts and answer with one Solon report.
11. AI-era software fundamentals are cross-phase, not implement-only. Before a
   gate advances, check shared design concept, domain language, feedback loop,
   interface/artifact boundary, and gray-box delegation.
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
13. In Solon reports, show gates as `Gate N (Name)`, not naked ids:
   Gate 1 (Intake), Gate 2 (Brainstorm), Gate 3 (Plan),
   Gate 4 (Design), Gate 5 (Handoff), Gate 6 (Review),
   Gate 7 (Retro). Use gate numbers 1..7 for new CLI examples.
14. Solon reports should feel like a compact console dashboard, not a flat
    bullet dump. Use a clear title/verdict strip, 2-4 labeled status panels,
    one action rail, and at most 1-3 questions. Keep long evidence behind file
    paths or source labels; do not make every line the same visual weight.
15. Decision questions must be self-contained: before any `Q1`, `D1`, or
    option id, explain in plain user language what is being decided, why it
    matters, the recommended default, and what each option changes. Labels are
    cross-references, not the explanation.
16. For `brainstorm`, ask 1-3 blocking questions when shared understanding is
    missing. Do not run or recommend `plan` as the next step until Gate 2 is
    `ready-for-plan`.
17. For `plan`, derive the contract from `brainstorm.md`; unresolved Gate 2
    questions stay visible instead of being hidden by assumptions.
18. For `implement`, backend architecture follows the routed `implement.md`
    guardrail: clean layered monolith for MVP/small projects, CQRS for
    non-initial backend work even on one DB, Hexagonal transition only after
    user acceptance, and MSA transition only after explicit approval.
19. For `implement`, non-Dev divisions also follow routed policy ladders:
    strategy-pm, taxonomy, design/frontend, QA, and infra start lightweight,
    strengthen on trigger evidence, and require user acceptance/approval before
    large roadmap, rename, redesign, release-readiness, or infra transitions.

## Project state and continuity

- `.sfs-local/` is private local workbench state and is gitignored by default.
  Do not ask the user to commit it unless the team explicitly opts into a
  different policy.
- Shared, durable Solon docs belong under `docs/solon/`. Workbench docs are
  created only when a command needs them and are compacted when the slice closes.
- This user-global skill provides only discovery and routing.
