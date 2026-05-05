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
10. In Solon reports, show gates as `Gate N (Name)`, not naked ids:
   Gate 1 (Intake), Gate 2 (Brainstorm), Gate 3 (Plan),
   Gate 4 (Design), Gate 5 (Handoff), Gate 6 (Review),
   Gate 7 (Retro). Use gate numbers 1..7 for new CLI examples.
11. For `brainstorm`, ask 1-3 blocking questions when shared understanding is
    missing. Do not run or recommend `plan` as the next step until Gate 2 is
    `ready-for-plan`.
12. For `plan`, derive the contract from `brainstorm.md`; unresolved Gate 2
    questions stay visible instead of being hidden by assumptions.
13. For `implement`, backend architecture follows the routed `implement.md`
    guardrail: clean layered monolith for MVP/small projects, CQRS for
    non-initial backend work even on one DB, Hexagonal transition only after
    user acceptance, and MSA transition only after explicit approval.
14. For `implement`, non-Dev divisions also follow routed policy ladders:
    strategy-pm, taxonomy, design/frontend, QA, and infra start lightweight,
    strengthen on trigger evidence, and require user acceptance/approval before
    large roadmap, rename, redesign, release-readiness, or infra transitions.

## Project state and continuity

- Work artifacts (`.sfs-local/sprints/`, `decisions/`, `events.jsonl`,
  `SFS.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`) are project-local and
  git-tracked. Switch CLIs (Claude / Gemini / Codex) on the same project —
  state is preserved.
- This user-global skill provides only **discovery and routing**. The work
  artifacts live in the project tree.
