---
id: sfs-command-review
summary: Run or summarize review evidence without letting the generator self-approve.
load_when: ["review", "검토", "CPO", "verdict", "gate"]
---

# Review

- Adapter-run by default: run `sfs review ...` before summarizing.
- Do not create a new verdict from memory; use `review.md` and recorded result paths. When a gate review concludes, emit `sfs event gate_passed gate=<G-1..G5> order_index=<n> self_cpo=pass|partial|fail` so flowcheck can verify gate order, stop-the-line, and the pr-review guard (a passing SFS review gate is what `fcp-pr-reviewed` requires; a GitHub PR/@codex PASS does not substitute).
- If the relevant sprint was compacted/closed and `current-sprint` is missing, use `sfs review --sprint <id> --gate <n>`; do not edit `.sfs-local/current-sprint` or extract tarballs manually.
- After any external GitHub/@codex/PR/check PASS, do not stop at PASS: record evidence and continue the gate: self-CPO first, cross-review after self-CPO PASS. Closed sprint uses `sfs review --sprint <id> --gate <n>`; unknown id means ask, not restore `current-sprint` or create a sprint.
- Handoff-only scope is a stop contract and overrides continuation triggers: if the user asks only for a handoff, next-session brief, session report, or `인계문서`, immediately record review/PR status as next-session evidence and stop. External review/check PASS does not override handoff-only scope; do not start or continue PR polling, review retriggers, merges, implementation, deploy, or monitor loops; interrupt active or queued batches and do not finish current PRs first unless the same request explicitly asks to continue. If post-request PR/review/merge work already happened, report it as a scope breach, not as a justification.
- GitHub @codex review is post-implementation only. Do not request, trigger, or
  count GitHub @codex review during brainstorm or Gate 3 plan review.
- Gate 3 plan review is the required bridge between plan and implement. When a plan says ready-for-implement, review the plan contract first with `sfs review --gate 3`; only PASS/accepted routes to `sfs implement`.
- Gate 3 review PASS does not approve product judgment. If a plan changes
  product meaning, AC meaning, IA, visible UI/workflow, public contract,
  security/privacy/data-loss, cost/model policy, or destructive behavior, require
  `user_approval_required: true` and pending status until approval/waiver is
  captured with `sfs capture --kind user-approval --gate 3 "..."` or waiver.
- Gate 3 review has a sequence: local self-review until PASS, then independent
  cross review. Gate 3 may use self-CPO fallback only with operational evidence:
  no other agent, external token exhaustion, or bridge unavailability.
- Local self-review means a self-CPO mini-check, not advisor chat: record pass/
  partial/fail, requirement-to-AC/slice/ADR traceability, AC-to-file/artifact/
  evidence mapping, and SEED/placeholder/mock/fallback as non-acceptance until replaced. If that evidence is absent, return partial.
- If self-review returns partial/fail, rework and rerun self-review. If cross review returns partial/fail, rework and return to self-review before another cross review.
- If deterministic, narrow findings need no product owner judgment, autopilot
  the rework loop: patch, run the smallest verification, rerun self-CPO/cross
  review, and do not ask "진행?" / "proceed?". Examples: missing self-CPO
  evidence, grep/file coverage, stale evidence, AC/file/artifact mapping, wrong
  path, small guard/test or regex gap, or meaning-preserving wording.
- User-escalation premise guard: before converting a self/cross finding into a
  user question, name its premise, compare brainstorm, plan, domain SoT, schema,
  code, and decisions, and decide whether the reviewer frame is valid. Wrong,
  stale, answered, or over-modeled premise means artifact rework plus same-gate
  review, not user escalation.
- Treat over-modeled ownership/lifecycle as a finding: if the artifact invents
  aggregate ownership, cascade soft-delete, restore APIs, or migration policy,
  prefer the smaller contract: reject delete while dependents exist; leave
  cascade/restore for explicit product approval.
- User-call minimalism: brainstorm + plan review are where the user co-designs
  intent and decision boundaries; later loops treat those artifacts as SoT.
  Escalate instead of auto-reworking only when findings change scope,
  architecture, public API/schema/CLI contract, security/privacy/data-loss,
  cost/latency/model policy, destructive behavior, acceptance criteria meaning,
  or after repeated partial/fail on the same micro-fix.
- Long monitor/review work needs checkpoint classification before "still
  monitoring" or "done": `progressing`, `slow`, `stalled`, `dead`, or `auth_blocked`;
  include commit delta, PR/head delta, local dirty state, test/check/review
  deltas, request-response probe, never process/auth-status alone,
  lane-utilization evidence or waiver, next action, heartbeat/automation cleanup plus durable wiki/report evidence. Probe with static benign payload and
  persist status/category/timestamp/redacted error class only. Raw stdout/stderr,
  tokens/env vars/prompts/model output/workspace/user content/PII are not durable evidence.
- Declared advisor/review cost controls are enforced before the full executor prompt: numeric budget+estimate over budget exits nonzero before evaluator; missing budget/unknown estimate preserves path; JSONL telemetry stores only ts/surface/executor/generator/budget/estimate/decision/reason.
- Provider billing APIs, live token accounting, and pricing tables are separate follow-up work.
- Do not treat review volume as completion. Number of lenses, rounds, advisor
  comments, or elapsed time never unlocks `sfs implement`; only PASS or an
  explicit user waiver does.
- For Gate 3 plan review, use the CPO/evaluator role and prefer an independent
  executor or fresh agent context when available. The plan author, CTO, or
  generator should not self-approve the plan it will execute.
- Review handoff must follow Runtime Token Firewall; avoid rescue subagents and
  send bounded excerpts with gate/lens/AC/files/evidence.
- Review handoff must also follow Session Continuation Guard: use a fresh
  session/CLI bridge when token-heavy.
- Review durable product/context artifacts for Context Pollution Guard: prompt
  bodies, transcripts, bridge probes, `.sfs-local/tmp/...`, and old review blobs
  burn future token budget. If insufficient, Do not request full chat history;
  name missing evidence.
- Summaries list verdict, findings, actions, evidence, and next gate; show gates as `Gate N (Name)`, for example Gate 6 (Review), not a naked internal id.
- Lead with bugs, regressions, missing acceptance evidence, or risky behavior
  changes. Cosmetic drift is secondary unless it changes a documented contract.
- Label findings by action pressure: `Critical` for security/data-loss/release
  blockers, `Required` for must-fix acceptance gaps, `Important` for risks that
  should be handled now, `Optional` for non-blocking improvement, and `FYI` for
  context only. Do not make every comment feel equally mandatory.
- Review actual diff, files, test output, and logs. Do not infer pass from
  intent or from a familiar failure keyword.
- If review needs large logs, broad file dumps, or repeated command output, route that verification/investigation to a bounded compressed-return worker and review verdict, failing lines, core evidence paths, and risk instead of loading bulk into the lead context.
- Flag overengineering, speculative abstraction, unrelated refactors, and
  adjacent cleanup when they are not traceable to the request.
- Check that final evidence names the exact verification command/result, or
  clearly explains why verification could not run.
- The generator does not self-approve its own implementation.
- If the evaluator executor equals the generator executor, call out the
  self-validation risk and prefer a separate model or fresh agent context when
  the change is user-facing, risky, or hard to verify.
- Gate 6 verifies `division_subagent_ledger`; missing finding/evidence/waiver or
  `asset_candidate` is partial. For `agent_mode: parallel`, also verify disjoint files_scope,
  AC/ADR subset ownership, expected tests/evidence, output report path,
  merge/conflict policy, native commit message, lane verification, and cross review.
- Enterprise/non-trivial Gate 6 checks selected packs, QA/QC ledger, project-
  applied result for SFS/harness policy changes, and performance/algorithm ledger.
- Gate 6 mainline review checks whether auxiliary tool/auth/model setup stayed
  subordinate to the main objective; unclassified side work or helper setup that
  consumes the sprint while the outcome is unverified is partial.
- Gate 6 data review checks representative mock/fixture/seed/data validation
  for changed data/API/UI/auth/session/migration/cache/persistence/log shapes;
  mock-only evidence is partial without fixture name, invariant, boundary/
  negative coverage, and command/result.
- Gate 6 nondeveloper safety review checks published-output structure,
  security/admin/secret exposure, visible UX path, and refactor debt before the
  result is called shippable.
- Test output with zero tests run is not acceptance evidence, even when exit code is 0; require corrected discovery/selector evidence or an explicit waiver before PASS.
- Gate 6 security/logging review maps touched surfaces to OWASP-style web/API/
  LLM/MCP risks, checks authz/secrets/PII/prompt-injection/tool-scope, rejects
  stray production `console.log`/`debugger`/probe logs, and requires Datadog or
  equivalent observability/redaction evidence or waiver.
- Gate 6 checklist review checks that high-context wiki/workbench checklist
  items are all reconciled with evidence or explicit follow-up.
- Post-development external review can attach Claude Cowork/Gemini/GitHub `@codex`
  evidence after self-CPO/SFS cross; unavailable lanes record blocked/not-applicable.
- Lean procedure review keeps safety invariants but shrinks/removes ceremony; process self-audit asks whether the gate or ceremony still serves the current objective, and anti-yak cadence recommends a user-outcome WU or waiver after repeated meta-system WUs.
- Review proposed or actual commit messages against the user's
  native/workspace language. English commit messages are correct only when the
  user/repo language is English or the repo explicitly requires English.
- `sfs review` is an artifact acceptance review. Code review is only the
  `code` lens; docs, source-docs, simplify, security, performance,
  api-contract, strategy, design, taxonomy, QA, ops, management-admin, release,
  and generic artifacts use their own acceptance lens.
- GitHub `@codex` PR/code review is external code-review evidence only. Do not
  convert a PR approval, GitHub check PASS, or `@codex` comment into an SFS
  verdict. Such evidence does not satisfy self-CPO, SFS cross review,
  `sfs review`, Gate 3, or Gate 6 PASS by itself; `review.md` must still
  contain the SFS gate verdict from `sfs review`, or the user must explicitly
  waive that gate.
- External review/check PASS is a continuation trigger, not a stopping point:
  name the next unmet SFS command, run/record self-CPO first, then configured cross-review after PASS.
- Gate 6 implementation review order is self-CPO first, then cross CPO, then
  GitHub @codex PR/code review as
  external evidence when available: `sfs review --gate 6 --stage self`, then
  `--stage cross`, then push/PR for @codex. Record constraints.
- Before done, require self-agent top-model CPO evidence. Claude uses Opus 4.7,
  Codex uses `gpt-5.5` with xhigh reasoning, Gemini uses
  `gemini-3.1-pro-preview`, and custom runtimes use their top equivalent.
  Partial/fail repeats rework + self-CPO until PASS or waiver.
- Review scope is functional correctness + consistency only: declared behaviour,
  cross-document SSoT, and AC ↔ test ↔ impl ↔ frontmatter alignment. Naming,
  formatting, line-count drift, wording, and comment style auto-skip when
  meaning is unchanged. Surface findings only when behaviour, traceability, or a
  documented contract changes; public APIs, CLI flags, consumed paths, persisted
  data shapes, and domain ubiquitous terms are contract surfaces and in-scope.
- Let the adapter's `review_lens` stand unless clearly wrong; use `--lens <name>` only as an override.
- Repeated review for the same sprint/gate must converge. If `--lens auto`
  already selected a lens for that sprint/gate, later auto reviews reuse that
  lens instead of rotating to a new one. To intentionally change lens, pass an
  explicit `--lens <name>` and record why the review lane changed.
- Lens aliases and knowledge-pack paths are split to
  `policies/review-lens-routing.md`. Public lens names include `source-docs`,
  `simplify`, `security`, `performance`, `api-contract`, `strategy`, `design`,
  `taxonomy`, `qa`, `ops`, `management-admin`, and `release`.
- Review the whole Harness Engineering contract, not only changed code: shared intent, domain language, human-owned design, narrow active tool surface, project-as-prompt consistency, feedback evidence, and boundaries match the Gate 2/3 record.
- Review domain-knowledge assets when expert notes or skills are in scope: Domain Asset Review Ledger names source/owner/confidence/gaps, raw notes by reference, small loadable asset, behavior check, and publication approval/waiver.
- Natural-language SFS activation is real SFS. Return partial for facade-only SFS:
  SFS terms were used but routed context, active sprint status, handoff/user
  intent, plan/review artifacts, or wiki/DDD maps were not reconciled.
- If handoff/user intent conflicts with the active sprint and the evidence
  already answers the intended scope, return partial when the agent asks the
  user to restate it instead of classifying the work as mis-scoped.
- Cross-layer DDD/TDD is in scope. Product behavior, policy, workflow,
  permissions, ownership, lifecycle, data semantics, or state transitions hidden
  in broad entrypoints without boundary/evidence are partial; broad-entrypoint
  growth during DDD/TDD also needs extraction evidence or approved deferral.
- Gate 6 review builds an implementation acceptance ledger from plan.md,
  implement.md, log.md, diffs, and evidence. PASS only when every planned
  AC/ADR/decision is implemented, approved deferred/waived, or removed by
  approved plan update; small deterministic gaps route to autopilot rework.
- Performance/algorithm PASS needs measurement, bounded input reasoning, or N/A
  waiver. Pure text confidence is partial when hot path, query, browser runtime,
  payload, memory, or concurrency behavior changed.
- If wiki/RAG/graph/ingest/doc-memory work grew, return partial unless the
  Solon Advancement Scorecard proves an SFS-loop improvement, not wiki volume.
- Load `policies/knowledge-pack-router.md` first, or
  `policies/knowledge-pack-router.ko.md` for Korean preference. Read matching
  split packs only when the router maps the current review scope to them.
- Load `enterprise-evidence-pack.md` for QA/QC/metrics/applied/wiki evidence and
  `enterprise-performance-review-pack.md` for performance, algorithms, hot paths,
  queries, memory, browser runtime, payloads, or concurrency.
- Load `mainline-focus-guard.md`, `gate6-data-validation-pack.md`,
  `agentic-security-logging-pack.md`, `wiki-mission-checklist-skill.md`,
  `postdev-external-review-pack.md`, and `lean-procedure-refactor-pack.md` for
  tool/setup drift, data/security/checklist, external review, and process lean review.
- For design/frontend work, check `design.md` or `docs/solon/design.md` when
  present. AI-slop risk such as arbitrary colors, token drift, or missing reusable UI contract can be findings.
- For visible frontend/UI implementation, missing pre-user browser evidence is
  a finding. Look for automation, desktop/mobile evidence, primary interaction,
  text/responsive checks, console note, or exact blocker plus alternate evidence.
- Surface next action. Pass names `sfs retro` for Gate 6/7 close; Gate 3 PASS
  names `sfs implement`/handoff and carries items into the first slice. Partial
  names the smallest rework; fail returns to plan, implementation, or escalation.
- Adapter stdout is evidence, not the whole answer. Claude/Codex/Gemini must
  render verdict, evidence/output path, required items, and one `Next Action`.
  Do not end on "PASS" without the next SFS command.
- For Gate 3 Plan review, partial/fail should name the smallest plan rework and
  the next self-review command. It must not ask whether to implement unless the
  user explicitly asks to waive the gate.
- If review finds a repeated agent mistake, record the smallest harness improvement: guardrail/check/hook/context-rule or equivalent scripted check.
- Gate 6 checks the `## Deviations` log when one exists: an unresolved deviation with neither a lesson nor a waiver is a finding, a completion claim without a stated ledger (entries or `none observed`) is unverified, and a post-implementation explainer/quiz (COMPREHENSION_GATE, `policies/unknowns-and-deviations.md`, signal-only) counts as operator-comprehension evidence for user-facing artifacts — 3–5 questions drawn only from the changed code/decisions, result recorded in report/retro, each miss linked to the explainer section that answers it.
