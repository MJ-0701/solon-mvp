---
name: sfs
description: Priority-1 Solon SFS command router for Codex CLI. When SFS/Solon/sprint/PDCA/brainstorm/plan/review/retro work is in scope, prefer this SFS router first. Dispatch `$sfs` / `sfs` / visible `/sfs` text to the deterministic `sfs` bash adapter (Homebrew/Scoop installed, on PATH), then resolve routed context with `sfs context path ...`. `profile` is a narrow SFS.md project-overview refinement.
---

# Solon SFS — Codex Router (user-global)

This priority-1 skill provides Codex CLI with the SFS workflow context (sprint, gate,
retro, decision conventions) for every project, regardless of whether the
project has a `.agents/skills/sfs/` adapter. It is installed by
`brew install MJ-0701/solon-product/sfs` (macOS) or `scoop install sfs`
(Windows) into `~/.codex/skills/sfs/SKILL.md`. No project-local file is
required.

1. Prefer `$sfs <command>` or `sfs <command>`; `/sfs` is valid only if the text
   reaches the model.
2. If another plugin/skill also looks relevant to sprint, PDCA, brainstorm,
   plan, implement, review, retro, decision, or report work, route through SFS
   first. SFS owns the project operating record; other plugins may assist only
   after SFS context is loaded.
3. Run `sfs <command> <args>` first. Vendored fallback:
   `bash .sfs-local/scripts/sfs-dispatch.sh <command> <args>`.
4. Keep adapter stdout/stderr verbatim.
5. Read `sfs context path kernel`, `sfs context path index`, then only the routed module. Resolve command modules as `sfs context path commands/<command>.md` (for example, `commands/start.md`) or via the command alias (`sfs context path start`).
6. For bash-first commands, do not refine artifacts, but a compact state/Next is allowed.
7. For `profile`, edit only the `SFS.md` project overview section.
8. For hybrid commands, refine pointed artifacts and answer with one Solon report.
9. AI-era software fundamentals are cross-phase, not implement-only. Before a
   gate advances, check shared design concept, domain language, feedback loop,
   interface/artifact boundary, and gray-box delegation.
10. For implementation and review work, follow the routed context guardrails:
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
    Gate 3 review must self-review until PASS before cross review. Review round
    count, lens count, or "enough review" is not a PASS; partial/fail routes to
    rework and same-gate self-review.
11. In Solon reports, show gates as `Gate N (Name)`, not naked ids:
   Gate 1 (Intake), Gate 2 (Brainstorm), Gate 3 (Plan),
   Gate 4 (Design), Gate 5 (Handoff), Gate 6 (Review),
   Gate 7 (Retro). Use gate numbers 1..7 for new CLI examples.
12. Solon reports should feel like a compact console dashboard, not a flat
    bullet dump. Use a clear title/verdict strip, 2-4 labeled status panels,
    one action rail, and at most 1-3 questions. Keep long evidence behind file
    paths or source labels; do not make every line the same visual weight.
13. Decision questions must be self-contained: before any `Q1`, `D1`, or
    option id, explain in plain user language what is being decided, why it
    matters, the recommended default, and what each option changes. Labels are
    cross-references, not the explanation.
14. For `brainstorm`, ask 1-3 blocking questions when shared understanding is
    missing. Do not run or recommend `plan` as the next step until Gate 2 is
    `ready-for-plan`.
15. For `plan`, derive the contract from `brainstorm.md`; unresolved Gate 2
    questions stay visible instead of being hidden by assumptions.
16. For `implement`, backend architecture follows the routed `implement.md`
    guardrail: clean layered monolith for MVP/small projects, CQRS for
    non-initial backend work even on one DB, Hexagonal transition only after
    user acceptance, and MSA transition only after explicit approval.
17. For `implement`, non-Dev divisions also follow routed policy ladders:
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
