---
id: sfs-command-review
summary: Run or summarize review evidence without letting the generator self-approve.
load_when: ["review", "검토", "CPO", "verdict", "gate"]
---

# Review

- Adapter-run by default: run `sfs review ...` before summarizing.
- Do not create a new verdict from memory; use `review.md` and recorded result paths.
- If the relevant sprint was compacted/closed and `current-sprint` is missing,
  use `sfs review --sprint <id> --gate <n>`; do not edit `.sfs-local/current-sprint`
  or extract tarballs manually.
- After any external GitHub/@codex/PR/check PASS, do not stop at PASS. Record
  the evidence, then continue the review gate: self-CPO first, cross-review
  after self-CPO PASS. If the sprint is closed but the id is known, the next
  command is `sfs review --sprint <id> --gate <n>`; if the id is unknown, ask
  for that id instead of creating a new sprint or manually restoring
  `.sfs-local/current-sprint`.
- Handoff-only scope is a stop contract and overrides continuation triggers: if the user asks only for a handoff, next-session brief, session report, or `인계문서`, immediately record review/PR status as next-session evidence and stop. External review/check PASS does not override handoff-only scope; do not start or continue PR polling, review retriggers, merges, implementation, deploy, or monitor loops; interrupt active or queued batches and do not finish current PRs first unless the same request explicitly asks to continue. If post-request PR/review/merge work already happened, report it as a scope breach, not as a justification.
- GitHub @codex review is post-implementation only. Do not request, trigger, or
  count GitHub @codex review during brainstorm or Gate 3 plan review.
- Gate 3 plan review is the required bridge between plan and implement. When a
  plan says ready-for-implement, review the plan contract first with
  `sfs review --gate 3`; only a PASS/accepted result should route to
  `sfs implement`.
- Gate 3 review PASS does not approve product judgment. If a plan changes
  product meaning, AC meaning, IA, visible UI/workflow, public contract,
  security/privacy/data-loss, cost/model policy, or destructive behavior, require
  `user_approval_required: true` and pending status until approval/waiver is
  captured with `sfs capture --kind user-approval --gate 3 "..."` or waiver.
- Gate 3 review has a sequence: local self-review until PASS, then independent
  cross review. Gate 3 may use self-CPO fallback only with operational evidence:
  no other agent subscription, external token exhaustion, or bridge unavailability.
- Local self-review means a self-CPO mini-check, not an advisor call: record
  pass/partial/fail, requirements-to-AC-to-slice-to-ADR traceability,
  AC-to-file/artifact/evidence mapping, and SEED/placeholder/mock/fallback as
  fail/partial/non-acceptance until real deliverables replace it. If that evidence is absent, return partial.
- If self-review returns partial/fail, rework the plan and run self-review
  again. If cross review returns partial/fail, rework the plan and return to
  self-review before another cross review.
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
- For long-running monitor/review work, require monitor checkpoint
  classification evidence before accepting "still monitoring" or "done":
  state `progressing`, `slow`, `stalled`, `dead`, or `auth_blocked`; include
  commit delta, PR/head delta, local dirty state, test/check delta, review
  status delta, worker liveness probe result, lane-utilization evidence or
  waiver, and next action `wait`, `probe`, `revive`, or `close`. Worker
  liveness needs a request-response probe, never process/auth-status alone;
  probes use a static benign payload, never workspace/user content, and persist
  only status/category/timestamp/redacted error class. Raw stdout/stderr,
  bearer/auth tokens, env vars, prompt bodies, model responses, workspace/user
  content, and PII are not durable monitor evidence. Gate close also checks
  heartbeat/automation cleanup plus durable wiki/report evidence.
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
- Summaries should list verdict, findings, required actions, evidence, and next gate.
  Show gates as `Gate N (Name)`, for example Gate 6 (Review), not a naked
  internal id.
- Lead with bugs, regressions, missing acceptance evidence, or risky behavior
  changes. Cosmetic drift is secondary unless it changes a documented contract.
- Label findings by action pressure: `Critical` for security/data-loss/release
  blockers, `Required` for must-fix acceptance gaps, `Important` for risks that
  should be handled now, `Optional` for non-blocking improvement, and `FYI` for
  context only. Do not make every comment feel equally mandatory.
- Review actual diff, files, test output, and logs. Do not infer pass from
  intent or from a familiar failure keyword.
- Flag overengineering, speculative abstraction, unrelated refactors, and
  adjacent cleanup when they are not traceable to the request.
- Check that final evidence names the exact verification command/result, or
  clearly explains why verification could not run.
- The generator does not self-approve its own implementation.
- If the evaluator executor equals the generator executor, call out the
  self-validation risk and prefer a separate model or fresh agent context when
  the change is user-facing, risky, or hard to verify.
- If implement.md records `agent_mode: parallel`, Gate 6 verifies lane contract:
  disjoint files_scope per lane, AC/ADR subset ownership, expected tests/
  evidence, output report path, merge/conflict policy, native/workspace-language
  commit message per lane, lane-level verification, and different-agent cross review.
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
- External review/check PASS is a continuation trigger, not a stopping point.
  Codex, Claude, Gemini, and future LLM agents must name the next unmet SFS
  command instead of ending the turn at "PASS": run/record self-CPO first with
  `sfs review --gate <n>` or `sfs review --sprint <id> --gate <n>`, then run
  the configured cross-review sequence after self-CPO PASS.
- Gate 6 implementation review order is self-CPO first, then cross CPO, then
  GitHub @codex PR/code review as final external evidence when
  available. Use `sfs review --gate 6 --stage self`, then
  `sfs review --gate 6 --stage cross`, and only then push/PR for @codex. If the
  user only has self-CPO available, record that constraint and use the self-only
  path.
- Before a completed work slice can be reported as done, require self-agent
  top-model CPO evidence. Claude self-CPO uses Opus 4.7, Codex self-CPO uses
  `gpt-5.5` with xhigh reasoning, Gemini self-CPO uses `gemini-3-pro-auto`, and
  custom runtimes use their configured top-model equivalent. Partial/fail is not
  a stopping point: the CPO redirects the work, the author reworks it, verifies
  again, and repeats self-CPO until PASS or an explicit user waiver.
- Review scope is functional correctness + consistency only: declared behaviour,
  cross-document SSoT, and AC ↔ test ↔ impl ↔ frontmatter alignment. Naming,
  formatting, line-count drift, wording, and comment style auto-skip when
  meaning is unchanged. Surface findings only when behaviour, traceability, or a
  documented contract changes; public APIs, CLI flags, consumed paths, persisted
  data shapes, and domain ubiquitous terms are contract surfaces and in-scope.
- Let the adapter's `review_lens` stand unless it is clearly wrong. Use
  `--lens <name>` only as an override.
- Repeated review for the same sprint/gate must converge. If `--lens auto`
  already selected a lens for that sprint/gate, later auto reviews reuse that
  lens instead of rotating to a new one. To intentionally change lens, pass an
  explicit `--lens <name>` and record why the review lane changed.
- Lens aliases and knowledge-pack paths are split to
  `policies/review-lens-routing.md`. Public lens names include `source-docs`,
  `simplify`, `security`, `performance`, `api-contract`, `strategy`, `design`,
  `taxonomy`, `qa`, `ops`, `management-admin`, and `release`.
- Review the whole contract, not only changed code: shared intent, domain
  language consistency, feedback evidence, interface/artifact boundaries, and
  gray-box delegation should still match the Gate 2/3 record.
- Natural-language SFS activation is real SFS. Return partial for facade-only SFS: SFS terms were used but routed context, active sprint status, handoff/
  user intent, plan/review artifacts, or wiki/DDD maps were not reconciled.
- If handoff/user intent conflicts with the active sprint and the evidence
  already answers the intended scope, return partial when the agent asks the
  user to restate it instead of classifying the work as mis-scoped.
- Cross-layer DDD/TDD is in scope. Return partial when product behavior,
  policy, workflow, permissions, ownership, lifecycle, data semantics, or state
  transitions hide in broad entrypoints without a named boundary and evidence.
  Broad-entrypoint growth that adds product behavior during a DDD/TDD session is partial unless extraction evidence or approved deferral is recorded.
- Gate 6 review must build an implementation acceptance ledger from plan.md,
  implement.md, log.md, diffs, and evidence; PASS only when every planned
  AC/ADR/decision is implemented, user-approved deferred/waived, or removed by
  approved plan update. Small deterministic gaps route to autopilot rework.
- If `llm-wiki/` exists and the sprint uncovers repeated harness/product
  failure, record problem, root cause, fix, local tests, project-applied QA/QC,
  production/applied status if relevant, and follow-up/waiver.
- Load `policies/knowledge-pack-router.md` first, or
  `policies/knowledge-pack-router.ko.md` for Korean preference. Read matching
  split packs only when the router maps the current review scope to them.
- For design/frontend work, check `design.md` or `docs/solon/design.md` when
  present. Token drift (arbitrary colors, type, spacing, radius, shadows, icons,
  per-screen styling) can be findings; missing reusable UI contract is an
  AI-slop risk.
- For visible frontend/UI implementation, missing pre-user browser evidence is
  a finding. Look for automation, desktop/mobile evidence, primary interaction,
  text/responsive checks, console note, or exact blocker plus alternate evidence.
- Surface the evaluator's next action. Pass names `sfs retro` for Gate 6/7
  close; Gate 3 (Plan) PASS names `sfs implement`/handoff and carries review
  items into the first slice. Mention `sfs report` only for report preview or
  past-report rebuild. Partial names the smallest rework; fail returns to plan,
  implementation, or user escalation.
- Adapter stdout is evidence, not the whole user-facing answer. Claude, Codex,
  and Gemini must all render the same compact SFS action rail after review:
  verdict, evidence/output path, required items, and exactly one `Next Action`.
  Do not end on "PASS" without the next SFS command.
- For Gate 3 Plan review, partial/fail should name the smallest plan rework and
  the next self-review command. It must not ask whether to implement unless the
  user explicitly asks to waive the gate.
- If the review finds a repeated agent mistake, record the smallest harness
  improvement: guardrail/check/hook/context-rule. Claude users may map this to
  Hookify; other agents should use their equivalent hook or scripted check.
