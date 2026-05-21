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
   Compact output is quality-preserving only: remove filler in summaries/Next,
   but never compress adapter stdout/stderr, evidence, risk warnings,
   decisions, source links/paths, or raw-source traceability. If compactness
   would weaken quality, use full clarity.
9. For `profile`, edit only the `SFS.md` project overview section.
10. For hybrid commands, refine pointed artifacts and answer with one Solon report.
11. AI-era fundamentals apply across all gates, not only implement: shared
   design concept, domain language, feedback loop, interface/artifact boundary,
   and gray-box delegation. DDD/TDD is a product-level engineering floor:
   product behavior, domain language, behavior boundary, and first evidence are
   named before worker handoff; DDD-lite code boundaries apply when code is
   touched.
12. For implementation and review work, follow the routed context guardrails:
    surface material assumptions, choose the smallest useful slice, keep changes
    surgical, read actual files/errors before fixing, verify before completion,
    and report exact evidence.
    Benchmarked engineering practices strengthen existing commands instead of
    creating new lifecycle commands: source-driven official docs, stop-the-line
    debugging, deprecation/migration, shipping/release checks, and review lenses
    `source-docs`, `simplify`, `security`, `performance`, `api-contract`,
    `ddd-tdd`.
    Gate 3 (Plan) ready-for-implement routes to `sfs review --gate 3` first;
    do not offer `sfs implement` or worker/model handoff until plan review
    passes. Gate 3 PASS is still not user product approval: if the plan changes
    product meaning, AC meaning, IA, visible UI/workflow, public contract,
    security/privacy/data-loss posture, cost/model policy, or destructive
    behavior, mark user approval pending and record approval with
    `sfs capture --kind user-approval --gate 3` before implementation.
    Keep C-Level and worker/generator responsibilities separate:
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
    For Solon commit grouping, guide users to `sfs commit plan` and
    `sfs commit apply --group <name>` (or `/sfs commit ...` only when this SFS
    slash router is active). `sfs commit apply` commits and pushes the current
    branch by default in user projects; use `--no-push` only for local
    sandbox/release testing or offline work. Do not route SFS work to a
    host-local `/commit` skill; `/commit` is not the portable SFS workflow
    command.
13. `.sfs-local/` is private active workbench state, not durable history.
    `events.jsonl` stays visible only for the current sprint ledger; stale or
    orphan events are removed/archived by `sfs upgrade` / `sfs tidy --all --apply`.
    Repeated cleanup evidence is date-bundled under
    `.sfs-local/archives/adopt/surface-cleanup/<yyyyMMdd>/surface-cleanup.tar.gz`.
    Shared handoff/history docs prefer
    `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/` and fall back to
    `docs/solon/<english-workspace>/<yyyyMMdd>/` only for domainless
    exploration; project-wide Solon reference docs use named files under
    `docs/solon/`. Do not ask users to commit `.sfs-local` unless their team
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
17. Do not show a question/recommendation-only choice table. When multiple
    options exist, show every viable option with its plain-language meaning and
    consequence, then mark the recommendation as the default. If that is too
    much for one view, ask one decision at a time instead of hiding
    alternatives.
- Never ask the user to confirm a compact option bundle such as `A/A/A/C/C`,
  and never answer "show the recommendation again" with only option labels or
  only the recommended row. Re-present the decision in plain language and use a
  natural confirmation phrase such as `권장안 그대로 확정`, not a label bundle.
18. Taxonomy is a product function, not an org division or copy polish. Match
    the user's native/workspace language and project terms; do not
    machine-translate SFS command/domain terms into mixed phrases or expose app
    placeholder labels such as `Other` or `Type something` as product choices.
19. If a required command argument is missing, ask one plain-language question
    in the user's language instead of opening a multi-choice prompt. For Korean
    `sfs start` with no goal, ask: `이번 sprint 목표를 한 줄로 말해 주세요. 예:
    "docker compose 구조 리디자인"`.
