---
name: sfs
description: Solon SFS command router. Run the deterministic platform adapter first (`sfs` on macOS/Linux/Git Bash/WSL, `sfs.cmd` on Windows PowerShell/cmd), then read routed context with `sfs context cat ...` or native Windows `sfs.cmd context cat ...`.
argument-hint: "<command> [args]"
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# Solon SFS — `/sfs`

User arguments:
```text
$ARGUMENTS
```

1. Verify the platform adapter exists: `command -v sfs` on macOS/Linux/Git
   Bash/WSL, or `where sfs.cmd` on Windows PowerShell/cmd.
2. Run the platform adapter first: `sfs <command> <args>` on macOS/Linux/Git
   Bash/WSL, `sfs.cmd <command> <args>` on Windows PowerShell/cmd. Vendored fallback:
   `bash .sfs-local/scripts/sfs-dispatch.sh <command> <args>`.
3. If Windows execution fails before SFS starts with Git Bash
   `couldn't create signal pipe, Win32 error 5`, rerun the same command via
   `sfs.cmd ...` outside the sandbox. If that run is empty or fails, report the
   exact stdout/stderr and ask for `sfs.cmd --help`.
   For read-only fallback on Windows, `sfs.cmd status`, `sfs.cmd version`, and `sfs.cmd context path/cat`
   are native read-only and must not start Git Bash. If a Codex/Claude/Gemini
   runner cannot launch Git Bash, use those native read-only commands for
   context/status and tell the user to run mutating commands in PowerShell/cmd.
4. Empty adapter output is not success for visible SFS commands. `start`,
   `brainstorm`, `plan`, `implement`, `review`, `retro`, `adopt`, `profile`,
   `upgrade`, and `agent install` must print output or change their expected
   artifact. For `start`, verify `.sfs-local/current-sprint` and the sprint
   directory exist before reporting success.
5. Print stdout verbatim; on failure include stderr and exit code.
6. Read `sfs context cat kernel`, `sfs context cat index`, then only the routed module. On Windows PowerShell/cmd use native `sfs.cmd context cat ...` so Git Bash is not started. Resolve command modules as `sfs context cat commands/<command>.md` (for example, `commands/start.md`) or via the command alias (`sfs context cat start`).
7. For bash-first commands, do not refine artifacts, but a compact state/Next is allowed.
   Compact output is quality-preserving only: remove filler in summaries/Next,
   but never compress adapter stdout/stderr, evidence, risk warnings,
   decisions, source links/paths, or raw-source traceability. If compactness
   would weaken quality, use full clarity.
8. For `profile`, edit only the `SFS.md` project overview section.
9. For hybrid commands, refine pointed artifacts and answer with one Solon report.
10. AI-era fundamentals and Harness Engineering apply across all gates:
   shared design, domain language, feedback, interface/artifact boundary,
   gray-box delegation, narrow tool surface, project-as-prompt, and automated
   checks. DDD/TDD is a product-level engineering floor: behavior, domain
   language, boundary, and first evidence are named before worker handoff;
   DDD-lite code boundaries apply when code is touched.
   All product-bearing entrypoints are included: UI bootstraps, routers, root
   components, hooks/stores/effects, controllers, jobs, repositories, DTO mappers,
   CLI flags, scripts, migrations, docs wording, observability glue, and external
   adapters are not default homes for product policy without a named boundary,
   evidence, or explicit waiver. Natural-language SFS activation is real SFS: reconcile current user wording, latest handoff/docs, active sprint plan, and wiki/DDD maps; Approved sprint state never overrides a newer handoff or user intent, so evidence-backed conflicts are mis-scoped work, not user questions. Broad-entrypoint growth that adds product behavior during DDD/TDD work is a Gate 6 finding unless boundary extraction or approved deferral is recorded.
   Domain knowledge assets are first-class: compile expert know-how into source-linked glossaries/playbooks/skills/fixtures/wiki maps with owner/confidence/gaps and human-reviewed publication boundaries.
11. For implementation and review work, follow the routed context guardrails:
   surface material assumptions, choose the smallest useful slice, keep changes
   surgical, read actual files/errors before fixing, verify before completion,
   and report exact evidence.
   User-facing docs HTML-first: agent docs/logs/SSoT stay Markdown; real-user
   guides, reports, handbooks, onboarding, and landing docs default to HTML.
   Benchmarked engineering practices strengthen existing commands instead of
   creating new lifecycle commands: source-driven official docs, stop-the-line
   debugging, deprecation/migration, shipping/release checks, and review lenses
   `source-docs`, `simplify`, `security`, `performance`, `api-contract`,
   `ddd-tdd`, `process-lean`.
   postdev external review is evidence only: Claude Cowork, Gemini,
   GitHub `@codex`, and future reviewer bridges attach after self/cross review;
   unavailable optional lanes are recorded instead of blocking. lean procedure review
   shrinks or removes ceremony only when equivalent or stronger evidence
   preserves the safety invariant.
   Release trigger contract: if the user says `배포해줘`, treat it as
   `배포 프로세스 쭉 진행해줘`, not a publish-only command. Load the release
   context and run readiness checks, relevant tests, review/검수, release cut,
   stable tag, Homebrew, Scoop, installed runtime verification, and evidence
   reporting end to end.
   Gate 3 (Plan) ready-for-implement routes to `sfs review --gate 3` first;
   do not offer `sfs implement` or worker/model handoff until plan review
   passes. Keep C-Level and worker/generator responsibilities separate: C-Level
   owns intent, architecture, AC, and review handoff; worker/generator owns
   fixed implementation slices.
   Codex routing is role-specific: normal worker slices use `gpt-5.4`,
   helper I/O and non-coding helpers use `gpt-5.4-mini`, bounded repo-aware
   coding helpers use `gpt-5.3-codex`, and only locked judgment-free
   mechanical implementation helpers use `gpt-5.3-codex-spark`. Claude
   coding-capable worker/helper lanes use Sonnet 4.6; Haiku is non-coding
   helper-only. Gemini routes strategic/research/review to `gemini-3.1-pro-preview`, agentic coding/bounded implementation helpers to `gemini-3-flash-preview`, and relay/probe/economy helpers to `gemini-3.1-flash-lite`. Model routing
   applies by default, no user setup required. Helper-grade simple
   I/O is advisor-exempt. Focused question generation uses facilitator-standard
   models (Claude Sonnet 4.6, Codex `gpt-5.4`; Codex helper intake uses
   `gpt-5.4-mini`). Lower-model outputs that frame questions/options, interpret
   user answers, or affect product identity, architecture, gate, AC, or
   files_scope require top-model advisor review before gate advancement
   (Claude Opus 4.7, Codex `gpt-5.5` xhigh, Gemini `gemini-3.1-pro-preview`).
   Complex shared behavior escalates to high reasoning before coding.
   Division sub-agent council is always-on from brainstorm through Gate 6: strategy-pm, dev, QA, design, infra, and taxonomy each records finding/evidence/waiver; actual parallel worker lanes remain opt-in. Multi-agent implement is optional, never the default: use single-agent mode unless the user selects parallel agents, each lane has disjoint files_scope, AC/ADR subset ownership, expected tests/evidence, output report path, merge/conflict policy, and a clear native-language commit message, and post-implement cross review is recorded before Gate 6. Commit messages default to the user's native/workspace language; English is only the default when that is the user or repo language.
   Gate 3 review must self-review until PASS before cross review. Review round
   count, lens count, or "enough review" is not a PASS; partial/fail routes to
   rework and same-gate self-review.
   If a partial/fail finding is deterministic and low-risk inside the brainstorm/plan contract, autopilot patch+verify+self-CPO/cross review.
   Never ask "진행?" / "proceed?" for missing self-CPO evidence, small guard/test/regex gaps, evidence paths, stale evidence, or meaning-preserving consistency.
   User-call minimalism: brainstorm + plan review define intent and decision boundaries.
   Ask only for new product judgment: scope, architecture, public contract,
   security/privacy/data-loss, cost/latency/model policy, destructive behavior, or changed AC meaning.
   User-escalation premise guard: before relaying any self/cross-review
   finding as a user question, normalize the premise and check it against
   brainstorm, plan, domain SoT, schema, code, and recorded decisions. If the
   premise is wrong, stale, already answered, or over-modeled, patch the
   artifact and re-review instead of forwarding the reviewer frame to the user.
   Do not invent ownership columns, cascade soft-delete, restore APIs, or
   migration policy unless the product contract requires them; prefer
   reject-delete-with-dependents when child records exist.
   Executable Action Ownership: when shell/tool/auth context and approval are
   available, run executable steps yourself and record evidence. Give
   copy-paste commands only when the user explicitly asks for them or when
   truly blocked by missing auth, unavailable tooling/runtime, sandbox or
   permission denial, uncaptured destructive/data-loss/public-contract approval,
   or materially broader scope than authorized. If the user grants
   session-scoped authorization such as
   `알아서 해`, `이번 세션은 진행`, or autonomous deploy, treat approval-gated
   steps in that scope as authorized for the current session and continue
   executing until scope changes or a true blocker appears. Shell state is
   agent-owned: use one-shot inline env and mask secrets instead of asking the
   user to export variables across terminals.
   Monitor checkpoint classification is mandatory for long-running monitor
   work: classify each checkpoint as `progressing`, `slow`, `stalled`, `dead`,
   or `auth_blocked`; record commit delta, PR/head delta, local dirty state,
   test/check delta, review status delta, worker liveness probe result,
   lane-utilization evidence or waiver, and next action `wait`, `probe`,
   `revive`, or `close`. Worker liveness requires a request-response probe,
   never process/auth-status alone. Use a static benign payload only, never
   workspace/user content, and persist only status/category/timestamp/redacted
   error class; do not persist raw stdout/stderr, bearer/auth tokens, env vars,
   prompt bodies, model responses, workspace/user content, or PII. Close only
   after heartbeat/automation cleanup and durable wiki/report evidence.
   Handoff-only scope is a stop contract: if the user asks only for a handoff, next-session brief, session report, or `인계문서`, immediately write/update that artifact, record current state/blockers/first next command, clean heartbeat/automation evidence when relevant, then stop; do not start or continue PR polling, review retriggers, merges, implementation, deploy, or monitor loops; interrupt active or queued batches and do not finish current PRs first unless the same user request explicitly asks to continue. If post-request PR/review/merge work already happened, report it as a scope breach, not as a justification.
   Advisor calls do not count as self-CPO. Before external cross review, record
   a self-CPO mini-check: requirements to AC to implementation slices to
   ADR/decision ids, every AC mapped to file/artifact/evidence, and SEED/
   placeholder/mock/fallback material treated as non-acceptance until replaced.
   A GitHub `@codex` PR/code review, PR approval, or GitHub check PASS is
   external evidence only and post-implementation only; Claude Cowork, Gemini,
   and future external reviews follow the same boundary. Do not request,
   trigger, or count them during brainstorm or Gate 3 plan review. They do not satisfy self-CPO,
   SFS cross review, `sfs review`, Gate 3, or Gate 6 PASS by themselves.
   External review/check PASS is a continuation trigger, not a stopping point.
   Codex, Claude, Gemini, and future LLM agents must continue with the next
   unmet SFS review command. For Gate 6 implementation review, run
   `sfs review --gate 6 --stage self`, then `sfs review --gate 6 --stage cross`,
   then attach available Claude Cowork/Gemini/GitHub `@codex` evidence.
   Session Continuation Guard: `sfs upgrade` updates runtime/project context
   but cannot shrink an already-open LLM conversation. If the host token meter
   is 30%+ before a new WU/sprint action, 50%+ before a new gate/loop/review
   handoff, or the same chat has spanned multiple WUs/sprints or repeated loop
   wakeups, stop and hand off to a fresh session using compact artifacts. Fresh-session transfer is lossless autopilot: write durable handoff/transfer capsule, invoke host-owned transfer/new-session/archive/clear+resume when available, and resume immediately; otherwise stop with exact prompt. Never ask user to type `/clear` or choose same-session vs fresh-session, and never call bare clear.
   After a work slice is implemented and verified, run self-agent top-model
   CPO: Claude Opus 4.7, Codex `gpt-5.5` xhigh, Gemini `gemini-3.1-pro-preview`, or
   the configured custom top model. Partial/fail redirects the work and repeats
   until PASS or explicit user waiver.
   For Solon commit grouping, guide users to `sfs commit plan` and
   `sfs commit apply --group <name>` (or `/sfs commit ...` only when this SFS
   slash router is active). `sfs commit apply` commits and pushes the current
   branch by default in user projects; use `--no-push` only for local
   sandbox/release testing or offline work. Do not route SFS work to a
   host-local `/commit` skill; `/commit` is not the portable SFS workflow
   command.
12. `.sfs-local/` is private workbench state. Shared handoff/history docs
   prefer `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/` and fall back
   to `docs/solon/<english-workspace>/<yyyyMMdd>/` only for domainless
   exploration; project-wide Solon reference docs use named files under
   `docs/solon/`. Do not ask users to commit `.sfs-local` unless their team
   explicitly opts in.
13. In Solon reports, show gates as `Gate N (Name)`, not naked ids:
   Gate 1 (Intake), Gate 2 (Brainstorm), Gate 3 (Plan),
   Gate 4 (Design), Gate 5 (Handoff), Gate 6 (Review),
   Gate 7 (Retro). Use gate numbers 1..7 for new CLI examples.
14. Decision questions must be self-contained: before any `Q1`, `D1`, or
    option id, explain in plain user language what is being decided, why it
    matters, the recommended default, and what each option changes. Labels are
    cross-references, not the explanation.
15. Do not show a question/recommendation-only choice table. When multiple
    options exist, show every viable option with its plain-language meaning and
    consequence, then mark the recommendation as the default. If that is too
    much for one view, ask one decision at a time instead of hiding
    alternatives.
16. Never ask the user to confirm a compact option bundle such as `A/A/A/C/C`,
    and never answer "show the recommendation again" with only option labels or
    only the recommended row. Re-present the decision in plain language and use
    a natural confirmation phrase such as `권장안 그대로 확정`, not a label bundle.
17. Taxonomy is a product function, not an org division or copy polish. Match
    the user's native/workspace language and project terms; do not
    machine-translate SFS command/domain terms into mixed phrases or expose app
    placeholder labels such as `Other` or `Type something` as product choices.
18. If a required command argument is missing, ask one plain-language question
    in the user's language instead of opening a multi-choice prompt. For Korean
    `sfs start` with no goal, ask: `이번 sprint 목표를 한 줄로 말해 주세요. 예:
    "docker compose 구조 리디자인"`.
