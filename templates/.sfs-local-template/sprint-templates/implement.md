---
phase: implement
status: draft
sprint_id: ""          # filled by /sfs start
goal: ""               # filled by /sfs start <goal>
created_at: ""         # filled by /sfs start
last_touched_at: ""
---

# Implement — <sprint title>

> Implementation execution artifact. This file records the work slice, code
> changes, and verification evidence. It is not a substitute for changing code.
> AI implementation must preserve system design, not only satisfy the nearest
> edit request.
> 생명주기: 구현 중에는 evidence 를 충분히 남기되, close 후 최종 변경/검증 요약은
> `report.md` 로 압축된다. 본 파일은 완료 뒤 compact stub 대상이다.

---

## §0. AI Coding Guardrails — Harness / Design / DDD / TDD

AI coding fails when it optimizes for the nearest change while ignoring the
system design. Treat bad code as expensive: unclear domain language, weak tests,
and irregular structure make future AI edits worse.

The first four guardrails are mandatory for code implementation, not just for
the final report. `/sfs implement` is complete only when the code slice is
small, scoped, verified, and ready to summarize.

- **Think before coding**: name assumptions, trade-offs, and success criteria
  before editing when the request is ambiguous.
- **Simplicity first**: implement the smallest code and document surface that
  proves the AC. Do not add flexibility or ceremony for imagined futures.
- **Surgical changes**: every changed line must connect to the requested slice.
  Leave unrelated cleanup as a finding or follow-up.
- **Goal-driven execution**: finish with verification evidence, not confidence.
- **Shared design concept first**: before editing, name the intended design,
  module boundary, and why this slice belongs there.
- **DDD language**: use the project's domain terms consistently in code,
  tests, filenames, and this artifact. If terms are missing, record them before
  implementing.
- **TDD feedback loop**: prefer a small failing/covering test first, then make
  it pass, then refactor. If a true test-first loop is impractical, record the
  reason and run the smallest useful verification before widening scope.
- **Regularity over cleverness**: follow existing codebase patterns. If a
  pattern is unclear or harmful, stop and record the refactor decision instead
  of adding another one-off.

### §0.1 Solon Division Guardrails

`/sfs implement` applies guardrails by division before code changes. Use the
same shape everywhere: always-on craft rules, trigger-based checks, and
scale-gated `light` / `full` / `skip` reviews for expensive work. Solon/Codex
provides the first-pass checklist; the user should not need to know every
non-backend discipline checklist.

- **strategy-pm**: always-on AC clarity and smallest shippable slice; trigger on
  pricing, compliance, launch, support, or stakeholder risk; scale-gate market
  or roadmap review.
- **taxonomy**: always-on names, states, schema, and glossary consistency;
  trigger on new concepts, enums, states, events, APIs, or persisted fields;
  scale-gate broad information architecture changes.
- **design/frontend**: always-on usability, accessibility, responsive fit, and
  existing design-system use; trigger on UI, forms, navigation, visual states,
  or interaction changes; scale-gate full design review.
- **dev/backend**: always-on codebase regularity plus backend Transaction
  discipline when DB, Spring/JPA, Spring Batch, external API, MQ/event,
  idempotency, state, or consistency paths are touched.
- **QA**: always-on smallest useful verification; trigger on regression,
  concurrency, boundary, migration, or user-visible flow risk; scale-gate full
  test-plan expansion.
- **infra**: always-on secrets hygiene, public-surface awareness, logging
  hygiene, and deploy reversibility notes; trigger on deploy, CI/CD, network,
  cloud, container, auth, observability, or runbook changes; scale-gate
  Security / Infra / DevOps review.

Backend Transaction guardrail is not optional skill invocation. When triggered,
check service/application transaction boundaries, external API calls outside
long DB transactions, `REQUIRES_NEW` intent and Hikari pool pressure, JPA
first-level cache behavior, Spring Batch chunk transaction scope, outbox /
idempotency / ordering / state history, and tests that match the risk. If
`REQUIRES_NEW` changes state and the caller needs that state, prefer returning
a result object over re-reading through the same outer EntityManager.

Security / Infra / DevOps guard level is asked once at project/sprint scope
when relevant:

- `light`: secrets, authn/authz, sensitive data, dependency/container basics,
  actuator/public surface, logging hygiene.
- `full`: threat model, AWS/IAM/network/WAF/audit, CI/CD gates, rollback,
  observability, runbooks.
- `skip`: local prototype/MVP; keep basic hygiene and record deferred or
  risk-accepted items.

MVP filter: `required-now` blocks only correctness, money movement, PII leak,
auth bypass, data loss, unrecoverable external side effect, or release blocker
risk. Use `light-now` for cheap risk reduction, `deferred` for valid but
overlarge architecture/security/infra work, and `risk-accepted` when the sprint
or user explicitly accepts the risk.

## §1. Implementation Target

- **Work slice**:
- **Plan source**: `plan.md`
- **Implementation persona**: `.sfs-local/personas/implementation-worker.md`
- **Reasoning tier**: `execution_standard`
- **Model profile source**: `.sfs-local/model-profiles.yaml`
- **Runtime / resolved model / reasoning effort**:
- **Fallback if profile unset**: current runtime model
- **Agent model override used?** no
- **Acceptance criteria in scope**:
- **Out of scope for this slice**:
- **Shared design concept**:
- **DDD terms touched**:
- **Solon divisions touched**:
- **Trigger-based guardrails active**:
- **Security / Infra / DevOps guard level**: n/a / light / full / skip
- **MVP filter decisions**:

## §2. Execution Notes

- **Approach**:
- **Files/modules expected to change**:
- **Test-first plan**:
- **Guardrails applied**:
- **Guardrails skipped with reason**:
- **Deferred items**:
- **Risk-accepted items**:
- **Backend Transaction notes**:
- **Risks / rollback notes**:

## §3. Code Changes Made

-

## §4. Verification

- **Commands run**:
- **Result**:
- **Manual smoke / inspection**:
- **Guardrail verification evidence**:
- **Transaction / integration evidence when relevant**:

## §5. Review Handoff

- **Ready for review?** no
- **Recommended next gate**: `G4`
- **Next command**: `/sfs review --gate G4`
- **Guardrail ledger complete?** no
