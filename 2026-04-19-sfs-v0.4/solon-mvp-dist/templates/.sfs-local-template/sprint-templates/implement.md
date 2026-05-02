---
phase: implement
status: draft
sprint_id: ""          # filled by /sfs start
goal: ""               # filled by /sfs start <goal>
created_at: ""         # filled by /sfs start
last_touched_at: ""
---

# Implement — <sprint title>

> Implementation execution artifact. This file records the work slice, changed
> artifacts, and verification evidence. Code changes are one possible output,
> not the only one: strategy, taxonomy, design handoff, QA evidence, infra
> runbooks, and docs can also be implementation artifacts.
> AI implementation must preserve system design and user intent, not only
> satisfy the nearest edit request.
> 생명주기: 구현 중에는 evidence 를 충분히 남기되, close 후 최종 변경/검증 요약은
> `report.md` 로 압축된다. 본 파일은 완료 뒤 compact stub 대상이다.

---

## §0. Execution Guardrails — Harness / Design / Domain / Feedback

AI execution fails when it optimizes for the nearest change while ignoring the
system design. Treat bad artifacts as expensive: unclear domain language, weak
feedback, and irregular structure make future AI edits worse.

The first four guardrails are mandatory for every implementation slice, not
just for the final report. `/sfs implement` is complete only when the work
slice is small, scoped, verified, and ready to summarize.

- **Think before execution**: name assumptions, trade-offs, and success criteria
  before editing when the request is ambiguous.
- **Simplicity first**: implement the smallest artifact surface that proves the
  AC. Do not add flexibility or ceremony for imagined futures.
- **Surgical changes**: every changed line must connect to the requested slice.
  Leave unrelated cleanup as a finding or follow-up.
- **Goal-driven execution**: finish with verification evidence, not confidence.
- **Shared design concept first**: before editing, name the intended design,
  artifact boundary, and why this slice belongs there.
- **Domain language**: use the project's domain terms consistently in code,
  docs, design labels, tests, filenames, and this artifact. If terms are
  missing, record them before implementing.
- **Feedback loop first**: prefer a small failing/covering test before code
  changes. For non-code work, define the smallest review/smoke/checklist that
  proves the artifact is usable before widening scope.
- **Regularity over cleverness**: follow existing codebase patterns. If a
  project pattern is unclear or harmful, stop and record the refactor decision
  instead of adding another one-off.

### §0.1 Solon Division Guardrails

`/sfs implement` applies guardrails by division before artifact changes. Use the
same shape everywhere: always-on craft rules, trigger-based checks, and
scale-gated `light` / `full` / `skip` reviews for expensive work. Solon/Codex
provides the first-pass checklist; the user should not need to know every
non-backend discipline checklist.

- **strategy-pm**: always-on AC clarity, tradeoffs, and smallest shippable
  slice; trigger on pricing, compliance, launch, support, or stakeholder risk;
  scale-gate market or roadmap review.
- **taxonomy**: always-on names, states, schema, and glossary consistency;
  trigger on new concepts, enums, states, events, APIs, or persisted fields;
  scale-gate broad information architecture changes.
- **design/frontend**: always-on usability, accessibility, responsive fit, and
  existing design-system use; trigger on UI, forms, navigation, visual states,
  or interaction changes; scale-gate full design review.
- **dev/backend**: always-on codebase regularity when code is touched plus
  backend Transaction discipline when DB, Spring/JPA, Spring Batch, external
  API, MQ/event, idempotency, state, or consistency paths are touched. Use the
  backend architecture evolution ladder: clean layered monolith for MVP/small
  projects; CQRS for non-initial backend work even with one DB; Hexagonal
  transition when domain seams grow; MSA only when independent service
  boundaries are justified and approved.
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

Backend architecture evolution guardrail is also part of implementation
planning:

- **Clean layered monolith** is the default for initial MVP and small projects.
  Keep the layers clear, but do not create ports/services/process boundaries for
  futures that are not yet real.
- **CQRS** is the default for backend work beyond the initial MVP, even when the
  system still uses one database. Separate command/write use cases from
  query/read paths at the application boundary without forcing separate stores.
- **Hexagonal candidate** appears when domain areas, integrations, release
  cadence, or test seams start pulling apart. Record the trigger evidence and
  ask for user acceptance before refactoring to ports/adapters.
- **MSA candidate** appears only when independent deployability, scaling,
  ownership, resilience, or blast-radius isolation is required. Ask for explicit
  approval, then refactor incrementally from monolith/hexagonal seams.

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
- **Domain terms touched**:
- **Solon divisions touched**:
- **Artifact types touched**: code / docs / taxonomy / design / QA / infra / decision / other
- **Trigger-based guardrails active**:
- **Backend architecture mode**: n/a / clean-layered-monolith / cqrs-single-db / hexagonal-candidate / hexagonal-approved / msa-candidate / msa-approved
- **Architecture transition approval**: n/a / pending-user / accepted / approved / rejected / deferred
- **Security / Infra / DevOps guard level**: n/a / light / full / skip
- **MVP filter decisions**:

## §2. Execution Notes

- **Approach**:
- **Files/artifacts expected to change**:
- **Feedback-first plan**:
- **Guardrails applied**:
- **Guardrails skipped with reason**:
- **Backend architecture evolution notes**:
- **Deferred items**:
- **Risk-accepted items**:
- **Backend Transaction notes**:
- **Risks / rollback notes**:

## §3. Artifact Changes Made

- **Code**:
- **Docs / decisions**:
- **Taxonomy / naming**:
- **Design / UX handoff**:
- **QA / verification evidence**:
- **Infra / deploy / runbook**:

## §4. Verification

- **Commands run**:
- **Raw command output**:
  ```text
  paste exact build/smoke/grep output here when a reviewer must verify it
  ```
- **Result**:
- **Manual smoke / inspection**:
- **Guardrail verification evidence**:
- **Architecture transition evidence when relevant**:
- **Transaction / integration evidence when relevant**:
- **Non-code artifact review evidence when relevant**:

## §5. Review Handoff

- **Ready for review?** no
- **Recommended next gate**: Gate 6 (Review)
- **Next command**: `/sfs review --gate 6`
- **Guardrail ledger complete?** no
