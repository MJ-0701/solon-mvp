---
name: sfs
description: Solon SFS command router for Codex CLI. Dispatch `$sfs` / `sfs` / visible `/sfs` text to the deterministic `sfs` bash adapter (Homebrew/Scoop installed, on PATH), then resolve routed context with `sfs context path ...`. `profile` is a narrow SFS.md project-overview refinement. Auto-discovered when this file lives at `~/.codex/skills/sfs/SKILL.md` (Codex CLI scans `~/.codex/skills/<dir>/SKILL.md` for any directory).
---

# Solon SFS — Codex Router (user-global)

This skill provides Codex CLI with the SFS workflow context (sprint, gate,
retro, decision conventions) for every project, regardless of whether the
project has a `.agents/skills/sfs/` adapter. It is installed by
`brew install MJ-0701/solon-product/sfs` (macOS) or `scoop install sfs`
(Windows) into `~/.codex/skills/sfs/SKILL.md`. No project-local file is
required.

1. Prefer `$sfs <command>` or `sfs <command>`; `/sfs` is valid only if the text
   reaches the model.
2. Run `sfs <command> <args>` first. Vendored fallback:
   `bash .sfs-local/scripts/sfs-dispatch.sh <command> <args>`.
3. Keep adapter stdout/stderr verbatim.
4. Read `sfs context path kernel`, `sfs context path index`, then only the routed module via `sfs context path ...`.
5. For bash-first commands, do not refine artifacts, but a compact state/Next is allowed.
6. For `profile`, edit only the `SFS.md` project overview section.
7. For hybrid commands, refine pointed artifacts and answer with one Solon report.
8. AI-era software fundamentals are cross-phase, not implement-only. Before a
   gate advances, check shared design concept, domain language, feedback loop,
   interface/artifact boundary, and gray-box delegation.
9. In Solon reports, show gates as `Gate N (Name)`, not naked ids:
   Gate 1 (Intake), Gate 2 (Brainstorm), Gate 3 (Plan),
   Gate 4 (Design), Gate 5 (Handoff), Gate 6 (Review),
   Gate 7 (Retro). Use gate numbers 1..7 for new CLI examples.
10. For `brainstorm`, ask 1-3 blocking questions when shared understanding is
    missing. Do not run or recommend `plan` as the next step until Gate 2 is
    `ready-for-plan`.
11. For `plan`, derive the contract from `brainstorm.md`; unresolved Gate 2
    questions stay visible instead of being hidden by assumptions.
12. For `implement`, backend architecture follows the routed `implement.md`
    guardrail: clean layered monolith for MVP/small projects, CQRS for
    non-initial backend work even on one DB, Hexagonal transition only after
    user acceptance, and MSA transition only after explicit approval.
13. For `implement`, non-Dev divisions also follow routed policy ladders:
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
