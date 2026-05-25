---
id: sfs-command-implement
summary: Execute the smallest verified work slice; code is one artifact, not the only one.
load_when: ["implement", "구현", "build", "execute", "작업"]
---

# Implement

- Do not stop at artifact creation: execute the requested slice and record evidence.
- Preflight is strict: `sfs implement` requires a Gate 3 Plan review PASS
  (`sfs review --gate 3`) before implementation starts. If review evidence is
  missing, return to plan review; bypass only with an explicit user waiver or
  recorded self-CPO fallback evidence for no other agent subscription, external
  agent token exhaustion, or cross-review bridge unavailability.
- Gate 3 Plan review PASS is not user approval. If `plan.md` marks
  `user_approval_required: true` or `user_approval_status: "pending"`,
  `sfs implement` must stop until the user approves or waives implementation
  and that evidence is captured with `sfs capture --kind user-approval --gate 3
  "..."` or `sfs capture --kind waiver --gate 3 "..."`.
- Gate 3 review must have passed by outcome, not by effort. Do not enter
  implementation because there were many review rounds, many lenses, or no new
  categories. Self-review must pass first; cross review follows unless the
  review evidence records a valid self-CPO fallback reason; any partial/fail
  returns to plan rework and self-review.
- The default implementation owner is the worker/generator model resolved from
  `.sfs-local/model-profiles.yaml`, not the C-Level planner/evaluator model.
  C-Level may define the contract, split files_scope, and handle escalation, but
  should not present itself as the normal direct coding option.
- For Codex runtime, the normal implementation worker is `gpt-5.4`; use
  `gpt-5.3-codex` for bounded repo-aware coding helper work and
  `gpt-5.3-codex-spark` only for locked judgment-free mechanical implementation.
  Claude worker/helper lanes use Sonnet 4.6; Haiku must not write code. Gemini
  routes strategy/research/review to `gemini-3.1-pro-preview`, coding/bounded
  implementation to `gemini-3-flash-preview`, and relay/probe/economy helpers to
  `gemini-3.1-flash-lite`. Escalate to strategic_high before coding if the slice
  touches architecture, public contracts, security, privacy, data-loss,
  release gates, or repeated review failure.
- Valid artifacts: code, taxonomy, design handoff, QA evidence, infra/runbook,
  admin evidence, decisions, docs, workflow, research, or user-facing material.
- If the codebase, dependency change, or domain model is unfamiliar, split off a
  read-only research slice with `.sfs-local/personas/researcher.md`; prefer
  Gemini when configured and record only compact findings in the workbench.
- Do not create new lifecycle commands for borrowed practices; route source-
  docs, debugging, migration/deprecation, and release/deploy through policies.
  Load `policies/source-driven-development.md` and debugging/deprecation/shipping
  packs when those practices are triggered.
- If intent is not shared, ask 1-3 precise questions before changing files.
- Use project/domain terms consistently; add or reuse a small glossary when terms drift.
- Move only as fast as feedback: test, smoke, preview, or review the smallest useful slice.
- Keep changes surgical: touch only files and lines tied to the request, do not
  refactor adjacent code, and remove only unused pieces created by this slice.
- For user-facing UX validation, add S0 repair contract: field location,
  coaching copy, one-step recovery, and server-side fallback. Warning/blocking alone is not a repair.
- Prefer simple code over speculative flexibility. If the implementation grew
  larger than the problem justifies, simplify before review.
- Inspect the exact files and nearby call sites before editing. Treat dirty
  worktree changes as user work unless you made them, and adapt rather than
  reverting unrelated edits.
- When a command fails, read the full error/log output and verify the cause
  before applying a fix.
- Stop-the-line on failures: preserve exact evidence, reproduce or document why
  reproduction is not yet possible, localize the smallest failing layer, fix the
  root cause, add a guard, and resume only after verification passes.
- Framework-specific code must be source-driven: detect stack/version from the
  repo, check the smallest relevant official documentation or standard, cite the
  source in evidence for non-trivial decisions, and mark unverified patterns
  instead of hiding them.
- Bug fixes should use the prove-it pattern: create a failing regression test or
  minimal repro first when practical, then make it pass. If no automated guard
  is practical, record the exact manual repro and smoke check.
- If code or executable artifacts changed, run the smallest relevant test,
  build, typecheck, smoke, or scripted review before marking complete. Record
  the command and result in the implementation evidence.
- If the plan selected enterprise packs, keep council evidence live while
  coding: update AC/files/evidence rows, record project-applied QA/QC for SFS/
  harness policy changes, and collect performance evidence for triggered hot paths.
- Keep a mainline ledger live while coding. If a tool/auth/model setup issue
  appears, classify it first; do only minimum viable unblocker work, then return
  to the user's main objective. Do not let helper setup become the sprint unless
  the plan says it is the deliverable.
- For data-affecting work, create or reuse representative synthetic fixtures:
  happy path, boundary, negative/unauthorized/cross-owner, legacy/null, and
  idempotent rerun where relevant. Mock/seed/fallback evidence must name the
  fixture, assert invariants, and record the validation command/result.
- For security/logging work, map touched surfaces to OWASP-style families,
  verify authz/masking/secret handling where relevant, remove or justify stray
  production `console.log`/`debugger`/temporary traces, and route errors to
  Datadog or the configured observability path with redaction.
- For high-context work, update the wiki/workbench mission checklist at audit,
  edit, test, review, and release boundaries. Do not rely on chat memory to
  remember user-reported defects.
- If implementation completes and extra reviewers are available, use
  `postdev-external-review-pack.md` to attach Claude Cowork/Gemini/Codex
  evidence after SFS self/cross review without replacing the gate.
- If implementation flow itself is the problem, use `lean-procedure-refactor-pack.md`:
  remove ceremony only when equivalent or stronger evidence remains.
- Execute approved runnable steps yourself: when shell/tool/auth context and
  approval are available, run the operation and record evidence. Give commands
  only when the user explicitly asked for them or a true blocker remains.
- Treat approval gates and true blockers differently: if the user grants
  autonomous execution for the current scope, record session authorization and
  proceed. Stop again only for new destructive/data-loss/public-contract scope,
  missing auth, unavailable tooling/runtime, sandbox denial, or true failure.
- For secrets or production-write flows, enforce approval first; once
  authorized and tooled, execute one-shot inline env with masked output. Do not ask the user to export variables,
  switch terminals, or rerun commands because shell state would not persist.
- If visible frontend/UI changed, run browser automation before asking the user
  to inspect it. Prefer Playwright/Cypress/Storybook; cover desktop plus mobile,
  primary interaction, text fit/overflow, responsive layout, and console/runtime
  errors; attach evidence or exact blocker plus alternate evidence/explicit user waiver.
- Before starting a new implementation slice in a long host conversation, apply
  Session Continuation Guard: at 30%+ before new WU/sprint or 50%+ before gate/worker handoff, create
  compact fresh-session handoff instead of spending another slice in-chat.
- After tests/smokes pass, run a self-agent top-model CPO review before pushing
  product code or marking done. Claude routes self-CPO to Opus 4.7, Codex to
  `gpt-5.5` with xhigh reasoning, and Gemini routes it to `gemini-3.1-pro-preview`.
  If the verdict is partial/fail, let the CPO redirect the slice, rework it,
  rerun verification, and repeat self-CPO until PASS or an explicit user waiver.
- Use current sprint artifacts for plan/checklist/context notes. Create
  root-level `checklist.md` or `context-notes.md` only when the user asks for
  those exact files.
- If `llm-wiki/` exists and the slice changes core design, domain language,
  docs, tests, CI, release, runtime, or pack semantics, update wiki or gap.
- Token discipline: inspect the smallest relevant files, prefer symbol/semantic
  search or precise `rg` before broad reads, and do not carry old workbench
  history into the turn unless current report/plan evidence is insufficient.
- Prefer deep modules and gray-box delegation: design the public interface, then let AI fill internals.
- Record artifact type, domain terms, feedback checks, design/interface notes, review handoff, and a `division_subagent_ledger`: strategy-pm/dev/QA/design/infra/taxonomy finding/evidence/waiver.
- When delegating worker slices, keep files_scope explicit and disjoint. Workers
  may implement fixed internals, but architecture, public API, domain terms, and
  acceptance criteria stay with CEO/CTO/user decisions.
- Worker handoff must follow Runtime Token Firewall: compact capsule only with
  goal, AC, files_scope, commands, and expected evidence; no full lead-chat history, plugin wrapper, rescue subagent. Poll worker artifacts/status manifests, not the main chat.
- Agent mode is an implementation-time choice. Default to single-agent. Use
  `--agent-mode parallel --agents codex,claude[,gemini]` only when plan lanes are
  independent and every lane has disjoint files_scope, AC/ADR subset, non-goals,
  evidence, output path, merge policy, and one-sentence proposed commit message.
- Commit messages default to the user's native/workspace language. If the user
  is Korean, write Korean commit messages; use English only when English is the
  user's native/workspace language or the repo explicitly requires English.
- Parallel agents must not edit the same files or silently absorb another
  agent's scope. If scopes overlap, return to single-agent mode or re-plan the
  split before editing.
- Implementation is not complete at artifact creation. After any implementation
  mode, record verification evidence and run `sfs review --gate 6 --stage self`,
  then `sfs review --gate 6 --stage cross`, before any GitHub push/PR review.
  GitHub @codex comes after cross review as final external evidence.
  GitHub @codex applies only after implementation, never during brainstorm or
  Gate 3 plan review. Users with only self-CPO available may record that
  constraint and use the self-only path. For
  multi-agent mode, cross review between agents is required before Gate 6 review
  can pass; each lane should review a different lane's diff/evidence.
- A GitHub `@codex` PR/code review, PR approval, or GitHub check PASS does not
  satisfy self-CPO, SFS cross review, `sfs review`, Gate 3, or Gate 6 PASS by
  itself, and it does not replace `sfs review --gate 6`. Treat GitHub review as
  external code-review evidence to attach, not as the SFS gate result.
- If GitHub/@codex/check PASS arrives before SFS Gate 6, treat it as a
  continuation trigger: run self-CPO, then cross, then attach PR review.
- Load `policies/ddd-tdd-knowledge-pack.md` and use DDD/TDD guardrails whenever product behavior changes, not only backend code. Reconcile latest handoff/user intent and wiki/DDD maps before using current
  sprint artifacts; conflicts are mis-scoped work. Preserve domain language/
  boundaries across UI/API/CLI/docs/data and start with evidence when practical.
- Before editing broad entrypoints, name the product-policy owner and adapter
  boundary. UI bootstraps/router/root components/hooks/stores/effects,
  controllers, jobs, repositories, DTO mappers, CLI flags, scripts, migrations,
  docs wording, observability glue, and external adapters wire/transport/
  describe behavior; they must not silently own auth/session, permission,
  ownership, lifecycle, workflow, or data semantics. Prove behavior with unit/
  characterization, component/API/CLI/browser smoke, migration/backfill dry run,
  review evidence, or explicit waiver plus follow-up guard. Broad-entrypoint line-count or behavior growth during DDD/TDD work needs boundary extraction evidence or approved deferral; otherwise Gate 6 is partial.
- Keep an implementation acceptance ledger while coding: map every AC/ADR/
  decision to implemented/missing/deferred/waived with files/artifacts and
  evidence. Missing self-CPO, stale evidence, small guard/test gaps, and path
  issues are autopilot patch+verify+review work, not user questions.
- Load `policies/knowledge-pack-router.md` first, or `policies/knowledge-pack-router.ko.md`
  for Korean preference. Apply only the matching division router ids.
- Load `policies/enterprise-evidence-pack.md` for harness/product-policy QA/QC
  and `policies/enterprise-performance-review-pack.md` for hot-path, algorithm,
  query, browser runtime, memory, payload, or concurrency changes.
- Load `policies/mainline-focus-guard.md` for tool/setup drift risk,
  `policies/gate6-data-validation-pack.md` for mock/fixture/seed/data changes,
  `policies/agentic-security-logging-pack.md` for OWASP/security/logging/
  Datadog concerns, and `policies/wiki-mission-checklist-skill.md` for long
  context or multi-defect work; add postdev/lean packs for external review or process bottlenecks.
- Load `policies/obsidian-llm-wiki.md` when the slice creates/migrates project
  docs, begins an existing-project adoption, or needs durable retrieval across
  future sprints.
- Read backend, strategy-pm, QA, design/frontend, infra, management-admin, or
  taxonomy packs only after router selection; do not broaden ordinary work.
- For visible design/frontend implementation, read `design.md` or
  `docs/solon/design.md` when present; otherwise record the design-system gap or
  seed. After editing, check token drift: colors, type, spacing, radius, shadows,
  and icons.
- Backend architecture ladder: clean layered monolith for MVP/small projects;
  CQRS for non-initial backend work even with one DB; propose Hexagonal
  transition when domain seams grow; propose MSA only when independent deploy,
  scale, ownership, resilience, or blast-radius needs justify it. Refactor only
  after user acceptance/approval and record the evidence.
- Non-Dev policy ladders start lightweight, strengthen on trigger evidence, and
  require approval before large roadmap, rename/schema, redesign, release-
  readiness, finance/admin, tax/accounting advisor, or infra/ops transitions.
