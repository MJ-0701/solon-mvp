---
name: sfs
description: Solon SFS command router for Codex. Dispatch `$sfs` / `sfs` / visible `/sfs` text to the deterministic SFS adapter (`sfs.cmd` on Windows PowerShell/cmd, `sfs` elsewhere), then read routed context with `sfs context cat ...` or native Windows `sfs.cmd context cat ...`. `profile` is a narrow SFS.md project-overview refinement.
---

# Solon SFS — Codex Router

1. Prefer `$sfs <command>` or `sfs <command>`; `/sfs` is valid only if the text
   reaches the model. When executing on Windows PowerShell/cmd, use
   `sfs.cmd <command>`; use `sfs <command>` on macOS/Linux/Git Bash/WSL.
2. Run the platform adapter first: `sfs.cmd <command> <args>` on Windows
   PowerShell/cmd, otherwise `sfs <command> <args>`. Vendored fallback:
   `bash .sfs-local/scripts/sfs-dispatch.sh <command> <args>`.
3. If Windows execution sandboxing fails before SFS starts with Git Bash
   `couldn't create signal pipe, Win32 error 5`, rerun the same `sfs.cmd ...`
   command outside the sandbox. If the outside run is still empty or fails,
   report that exact stdout/stderr and ask for a PowerShell `sfs.cmd --help`
   sanity check instead of claiming success.
   For read-only fallback, use native `sfs.cmd status`, `sfs.cmd version`, and
   `sfs.cmd context cat ...`; these must not start Git Bash. If the runner
   cannot launch Git Bash, tell the user to run mutating commands in
   PowerShell/cmd.
4. Empty adapter output is not success for visible SFS commands. `start`,
   `brainstorm`, `plan`, `implement`, `review`, `retro`, `adopt`, `profile`,
   `upgrade`, and `agent install` must print output or change their expected
   artifact. For `start`, verify `.sfs-local/current-sprint` and the sprint
   directory exist before reporting success.
5. Keep adapter stdout/stderr verbatim.
6. Read `sfs context cat kernel`, `sfs context cat index`, then only the routed module. On Windows PowerShell/cmd use native `sfs.cmd context cat ...` so Git Bash is not started. Resolve command modules as `sfs context cat commands/<command>.md` (for example, `commands/start.md`) or via the command alias (`sfs context cat start`).
7. For bash-first commands, do not refine artifacts, but a compact state/Next is allowed.
8. For `profile`, edit only the `SFS.md` project overview section.
9. For hybrid commands, refine pointed artifacts and answer with one Solon report.
10. AI-era software fundamentals are cross-phase, not implement-only. Before a
   gate advances, check shared design concept, domain language, feedback loop,
   interface/artifact boundary, and gray-box delegation.
11. For implementation and review work, follow the routed context guardrails:
   surface material assumptions, choose the smallest useful slice, keep changes
   surgical, read actual files/errors before fixing, verify before completion,
   and report exact evidence.
   Benchmarked engineering practices strengthen existing commands instead of
   creating new lifecycle commands: source-driven official docs, stop-the-line
   debugging, deprecation/migration, shipping/release checks, and review lenses
   `source-docs`, `simplify`, `security`, `performance`, `api-contract`.
   Gate 3 (Plan) ready-for-implement routes to `sfs review --gate 3` first;
   do not offer `sfs implement` or worker/model handoff until plan review
   passes. Keep C-Level and worker/generator responsibilities separate: C-Level
   owns intent, architecture, AC, and review handoff; worker/generator owns
   fixed implementation slices.
   Codex worker default is `gpt-5.3-codex`; `gpt-5.3-codex-spark` is helper-only
   for bounded mechanical subtasks after scope/files_scope/AC are locked.
   Model routing applies by default, no user setup required. Helper-grade simple
   I/O is advisor-exempt. Focused question generation uses facilitator-standard
   models (Claude Sonnet, Codex `gpt-5.4`; Codex helper intake uses
   `gpt-5.4-mini`). Lower-model outputs that frame questions/options, interpret
   user answers, or affect product identity, architecture, gate, AC, or
   files_scope require top-model advisor review before gate advancement
   (Claude Opus 4.7, Codex `gpt-5.5` xhigh, Gemini `gemini-3.1-pro-preview`).
   Complex shared behavior escalates to high reasoning before coding.
   Multi-agent implement is optional, never the default: use single-agent mode unless the user selects parallel agents, each lane has disjoint files_scope and a clear native-language commit message, and post-implement cross review is recorded before Gate 6. Commit messages default to the user's native/workspace language; English is only the default when that is the user or repo language.
   Gate 3 review must self-review until PASS before cross review. Review round
   count, lens count, or "enough review" is not a PASS; partial/fail routes to
   rework and same-gate self-review.
   If a partial/fail finding is deterministic and low-risk, such as grep
   scope, stale evidence, missing AC/file mapping, evidence path typo, or
   bounded wording/document consistency, patch it and run the same-gate review again
   in the same cycle. Ask the user only when product judgment is needed:
   scope, architecture, public contract, security/privacy/data-loss,
   cost/latency/model policy, destructive behavior, or changed AC meaning.
   Advisor calls do not count as self-CPO. Before external cross review, record
   a self-CPO mini-check: requirements to AC to implementation slices to
   ADR/decision ids, every AC mapped to file/artifact/evidence, and SEED/
   placeholder/mock/fallback material treated as non-acceptance until replaced.
   For Solon commit grouping, guide users to `$sfs commit plan` or
   `sfs commit plan`, then `$sfs commit apply --group <name>` or
   `sfs commit apply --group <name>`. `sfs commit apply` commits and pushes
   the current branch by default in user projects; use `--no-push` only for
   local sandbox/release testing or offline work. Do not route SFS work to a
   host-local `/commit` skill; `/commit` is not the portable SFS workflow
   command.
12. In Solon reports, show gates as `Gate N (Name)`, not naked ids:
   Gate 1 (Intake), Gate 2 (Brainstorm), Gate 3 (Plan),
   Gate 4 (Design), Gate 5 (Handoff), Gate 6 (Review),
   Gate 7 (Retro). Use gate numbers 1..7 for new CLI examples.
13. Decision questions must be self-contained: before any `Q1`, `D1`, or
   option id, explain in plain user language what is being decided, why it
   matters, the recommended default, and what each option changes. Labels are
   cross-references, not the explanation.
14. Do not show a question/recommendation-only choice table. When multiple
    options exist, show every viable option with its plain-language meaning and
    consequence, then mark the recommendation as the default. If that is too
    much for one view, ask one decision at a time instead of hiding
    alternatives.
15. Never ask the user to confirm a compact option bundle such as `A/A/A/C/C`,
    and never answer "show the recommendation again" with only option labels or
    only the recommended row. Re-present the decision in plain language and use
    a natural confirmation phrase such as `권장안 그대로 확정`, not a label bundle.
16. Taxonomy is a product function, not an org division or copy polish. Match
    the user's native/workspace language and project terms; do not
    machine-translate SFS command/domain terms into mixed phrases or expose app
    placeholder labels such as `Other` or `Type something` as product choices.
17. If a required command argument is missing, ask one plain-language question
    in the user's language instead of opening a multi-choice prompt. For Korean
    `sfs start` with no goal, ask: `이번 sprint 목표를 한 줄로 말해 주세요. 예:
    "docker compose 구조 리디자인"`.
18. For `brainstorm`, ask 1-3 blocking questions when shared understanding is
   missing. Do not run or recommend `plan` as the next step until Gate 2 is
   `ready-for-plan`.
19. For `plan`, derive the contract from `brainstorm.md`; unresolved Gate 2
    questions stay visible instead of being hidden by assumptions.
20. For `implement`, backend architecture follows the routed `implement.md`
    guardrail: clean layered monolith for MVP/small projects, CQRS for
    non-initial backend work even on one DB, Hexagonal transition only after
    user acceptance, and MSA transition only after explicit approval.
21. For `implement`, non-Dev divisions also follow routed policy ladders:
    strategy-pm, taxonomy, design/frontend, QA, and infra start lightweight,
    strengthen on trigger evidence, and require user acceptance/approval before
    large roadmap, rename, redesign, release-readiness, or infra transitions.
