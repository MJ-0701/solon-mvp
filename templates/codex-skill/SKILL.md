---
name: sfs
description: Priority-1 Solon SFS command router for Codex CLI. When SFS/Solon/sprint/PDCA/brainstorm/plan/review/retro work is in scope, prefer this SFS router first. Dispatch `$sfs` / `sfs` / visible `/sfs` text to the deterministic SFS adapter (`sfs` on macOS/Linux/Git Bash/WSL, `sfs.cmd` on Windows PowerShell/cmd), then read routed context with `sfs context cat ...` or native Windows `sfs.cmd context cat ...`. `profile` is a narrow SFS.md project-overview refinement.
---

# Solon SFS — Codex Router (user-global)

This priority-1 skill gives Codex CLI the SFS workflow context for every
project, even without a `.agents/skills/sfs/` adapter. It is installed by
Homebrew/Scoop into `~/.codex/skills/sfs/SKILL.md`.

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
   Compact output is quality-preserving only: remove filler in summaries/Next,
   but never compress adapter stdout/stderr, evidence, risk warnings,
   decisions, source links/paths, or raw-source traceability. If compactness
   would weaken quality, use full clarity.
9. For `profile`, edit only the `SFS.md` project overview section.
10. For hybrid commands, refine pointed artifacts and answer with one Solon report.
11. AI-era software fundamentals are cross-phase, not implement-only. Before a
   gate advances, check shared design concept, domain language, feedback loop,
   interface/artifact boundary, and gray-box delegation.
   DDD/TDD is a product-level engineering floor: name product behavior, domain
   language, and first evidence before worker handoff; use DDD-lite boundaries
   when code is touched; keep invariants out of adapters; prefer failing,
   characterization, smoke, or review evidence before implementation.
   Obsidian LLM wiki is a recommended companion for SFS continuity, not a hard
   dependency; load `policies/obsidian-llm-wiki.md` when setup/adoption/docs
   migration or multi-sprint retrieval is in scope. If `.obsidian/` or
   `llm-wiki/` exists, treat the wiki as active project context: check
   `llm-wiki/README.md` and `llm-wiki/ddd/README.md` before broad scans, then
   update the relevant map or record a gap/waiver when the slice changes domain
   language, release flow, tests, or core components.
   Host-local tool/skill bundles and user-home folders are external
   environment, not project SSoT, wiki roots, install targets, or migration
   sources; do not install, clone, scaffold, or promote them while building an
   Obsidian wiki unless explicitly asked, and record references as external evidence.
12. For implementation and review work, follow the routed context guardrails:
   surface material assumptions, choose the smallest useful slice, keep changes
   surgical, read actual files/errors before fixing, verify before completion,
   and report exact evidence. User-facing docs HTML-first: agent docs/logs/SSoT
   stay Markdown; real-user guides, reports, handbooks, onboarding, and landing
   docs default to HTML. For visible frontend/UI work, verify with Playwright
   or equivalent browser automation before asking the user to inspect it.
    Benchmarked engineering practices strengthen existing commands instead of
    creating new lifecycle commands: source-driven official docs, stop-the-line
    debugging, deprecation/migration, shipping/release checks, and review lenses
    `source-docs`, `simplify`, `security`, `performance`, `api-contract`,
    `ddd-tdd`.
    Release trigger contract: if the user says `배포해줘`, treat it as `배포 프로세스 쭉 진행해줘`, not a publish-only command.
    Load release context and run readiness checks, relevant tests, review/검수, release cut, stable tag, Homebrew, Scoop, installed runtime verification, and evidence reporting end to end.
    Gate 3 (Plan) ready-for-implement routes to `sfs review --gate 3` first;
    do not offer `sfs implement` or worker/model handoff until plan review
    passes. Keep C-Level and worker/generator responsibilities separate:
    C-Level owns intent, architecture, AC, and review handoff; worker/generator
    owns fixed implementation slices.
    Codex routing is role-specific: normal worker slices use `gpt-5.4`,
    helper I/O and non-coding helpers use `gpt-5.4-mini`, bounded repo-aware
    coding helpers use `gpt-5.3-codex`, and only locked judgment-free
    mechanical implementation helpers use `gpt-5.3-codex-spark`. Claude
    coding-capable worker/helper lanes use Sonnet 4.6; Haiku is non-coding
    helper-only. Gemini uses `gemini-3-pro-auto` for every role. Model routing
    applies by default, no user setup required.
    Helper-grade simple I/O is advisor-exempt. Focused question generation uses
    facilitator-standard models (Claude Sonnet 4.6, Codex `gpt-5.4`; Codex helper
    intake uses `gpt-5.4-mini`). Lower-model outputs that frame
    questions/options, interpret user answers, or affect product identity,
    architecture, gate, AC, or files_scope require top-model advisor review
    before gate advancement (Claude Opus 4.7, Codex `gpt-5.5` xhigh, Gemini `gemini-3-pro-auto`).
    Complex shared behavior escalates to high reasoning before coding.
    Multi-agent implement is optional, never the default: use single-agent mode unless the user selects parallel agents, each lane has disjoint files_scope and a clear native-language commit message, and post-implement cross review is recorded before Gate 6. Commit messages default to the user's native/workspace language; English is only the default when that is the user or repo language.
    Gate 3 review must self-review until PASS before cross review. Review round
    count, lens count, or "enough review" is not a PASS; partial/fail routes to
    rework and same-gate self-review. If no other agent subscription exists,
    external agent tokens are exhausted, or the cross-review bridge is
    unavailable, a recorded self-CPO fallback PASS may satisfy the cross-review
    slot; a bare self-CPO PASS still blocks implementation unless the user
    explicitly waives the gate.
    If a partial/fail finding is deterministic and low-risk, such as grep
    scope, stale evidence, missing AC/file mapping, evidence path typo, or
    bounded wording/document consistency, patch it and run the same-gate review again
    in the same cycle. Ask the user only when product judgment is needed:
    scope, architecture, public contract, security/privacy/data-loss, cost/latency/model policy, destructive behavior, or changed AC meaning.
    Executable Action Ownership: run executable steps yourself when shell/tool/auth context and approval are available; give copy-paste commands only when the user explicitly asks for them or when truly blocked by missing auth/tooling/sandbox/uncaptured approval/broader scope; session-scoped authorization such as `알아서 해` carries approval-gated work in scope until a true blocker; Shell state is agent-owned: use one-shot inline env and mask secrets instead of asking the user to export variables across terminals.
    Advisor calls do not count as self-CPO. Before external cross review, record
    a self-CPO mini-check: requirements to AC to implementation slices to
    ADR/decision ids, every AC mapped to file/artifact/evidence, and SEED/
    placeholder/mock/fallback material treated as non-acceptance until replaced.
    A GitHub `@codex` PR/code review, PR approval, or GitHub check PASS is
    external evidence only and post-implementation only. Do not request,
    trigger, or count it during brainstorm or Gate 3 plan review. It does not
    satisfy self-CPO, SFS cross review, `sfs review`, Gate 3, or Gate 6 PASS by
    itself.
    External review/check PASS is a continuation trigger, not a stopping point.
    Codex, Claude, Gemini, and future LLM agents must continue with the next
    unmet SFS review command. For Gate 6 implementation review, run
    `sfs review --gate 6 --stage self`, then `sfs review --gate 6 --stage cross`,
    then GitHub `@codex` as final external evidence when available unless a
    recorded self-CPO fallback reason covers no other agent subscription,
    external agent token exhaustion, or cross-review bridge unavailability.
    Session Continuation Guard: `sfs upgrade` updates runtime/project context
    but cannot shrink an already-open LLM conversation. If the host token meter
    is 30%+ before a new WU/sprint action, 50%+ before a new gate/loop/review
    handoff, or the same chat has spanned multiple WUs/sprints or repeated loop
    wakeups, stop and hand off to a fresh session using compact artifacts.
    After a work slice is implemented and verified, run self-agent top-model
    CPO: Claude Opus 4.7, Codex `gpt-5.5` xhigh, Gemini `gemini-3-pro-auto`, or
    the configured custom top model. Partial/fail redirects the work and repeats
    until PASS or explicit user waiver.
    For Solon commit grouping, guide users to `$sfs commit plan` or
    `sfs commit plan`, then `$sfs commit apply --group <name>` or
    `sfs commit apply --group <name>`. `sfs commit apply` commits and pushes
    the current branch by default in user projects; use `--no-push` only for
    local sandbox/release testing or offline work. Do not route SFS work to a
    host-local `/commit` skill; `/commit` is not the portable SFS workflow
    command.
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
16. Do not show a question/recommendation-only choice table. When multiple
    options exist, show every viable option with its plain-language meaning and
    consequence, then mark the recommendation as the default. If that is too
    much for one view, ask one decision at a time instead of hiding
    alternatives.
- Never ask the user to confirm a compact option bundle such as `A/A/A/C/C`,
  and never answer "show the recommendation again" with only option labels or
  only the recommended row. Re-present the decision in plain language and use a
  natural confirmation phrase such as `권장안 그대로 확정`, not a label bundle.
17. Taxonomy is a product function, not an org division or copy polish. Match
    the user's native/workspace language and project terms; do not
    machine-translate SFS command/domain terms into mixed phrases or expose app
    placeholder labels such as `Other` or `Type something` as product choices.
18. If a required command argument is missing, ask one plain-language question
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

## Project state and continuity

- `.sfs-local/` is private local workbench state and is gitignored by default.
  Do not ask the user to commit it unless the team explicitly opts into a
  different policy.
- `.sfs-local/` is active workbench state, not durable history. `events.jsonl`
  stays visible only for the current sprint ledger; stale/orphan events should
  be removed or archived by `sfs upgrade` / `sfs tidy --all --apply`. Repeated
  cleanup evidence is date-bundled under
  `.sfs-local/archives/adopt/surface-cleanup/<yyyyMMdd>/surface-cleanup.tar.gz`.
- Shared handoff/history docs prefer `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/`;
  use `docs/solon/<english-workspace>/<yyyyMMdd>/` only as the domainless exploration fallback.
  Project-wide Solon reference docs use named files under `docs/solon/` such as `domain-map.md`. Workbench docs are
  created only when a command needs them and are compacted when the slice closes.
- This user-global skill provides only discovery and routing.
