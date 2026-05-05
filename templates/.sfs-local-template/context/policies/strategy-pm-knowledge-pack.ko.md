---
id: sfs-policy-strategy-pm-knowledge-pack-ko
summary: Strategy/PM 지식 항목 인벤토리(한글 버전).
language: ko
load_when:
  - strategy-pm
  - product
  - roadmap
  - scope
  - stakeholder
  - SLA
  - business
  - rollout
status: filled-v1
content_policy: "compact operating guidance; apply only matching ids and keep strategy depth proportional to commitment risk"
---

# Strategy/PM Knowledge Pack Inventory

이 파일은 Strategy/PM 작업을 위한 compact filled guidance pack 이다. sprint,
plan, review, release 에서 product, scope, rollout, commitment, stakeholder
check 중 무엇이 활성화되는지 판단하고, matching id 만 적용한다.

## Activation Rules

- Activate only the propositions that match the project size and decision risk.
- Do not turn every small feature into a roadmap or governance exercise.
- Product commitments, partner commitments, pricing, SLA, user promises, and
  launch communication increase Strategy/PM depth.
- When the work is SFS product development, all core divisions plus the
  cross-cutting taxonomy lens are eligible.

## PM-SCALE - Review Depth By Project Size

- PM-SCALE-001: A throwaway experiment needs a hypothesis and stop condition, not a full business case.
- PM-SCALE-002: A first MVP needs target user, problem, non-goals, success signal, and release boundary.
- PM-SCALE-003: First production exposure needs rollback, support, communication, and owner clarity.
- PM-SCALE-004: Partner-facing work needs responsibility matrix, SLA/SLO, escalation path, and change notice rules.
- PM-SCALE-005: Paid, regulated, or trust-sensitive work needs risk acceptance and audit-friendly decision records.
- PM-SCALE-006: Multi-team work needs dependency map, milestone ownership, and decision cadence.
- PM-SCALE-007: Platform/product-line work needs compatibility, migration, deprecation, and adoption strategy.

## PM-PROP - Proposition Inventory

- PM-PROP-001: Shared intent must state the user, problem, business reason, and expected outcome.
- PM-PROP-002: Scope must include non-goals so AI workers do not expand the wrong surface.
- PM-PROP-003: Acceptance criteria must be measurable by an evaluator without reading the generator's mind.
- PM-PROP-004: Prioritization must name tradeoffs, opportunity cost, and what is deliberately deferred.
- PM-PROP-005: Stakeholder promises must be separated from internal implementation preferences.
- PM-PROP-006: Partner responsibilities must be explicit for ownership, timing, error handling, and support.
- PM-PROP-007: SLA/SLO, RTO/RPO, maintenance windows, and support hours are product commitments, not only infra details.
- PM-PROP-008: Rollout must define audience, gates, kill switch, fallback, and communication channel when users are affected.
- PM-PROP-009: Roadmap items must identify dependencies, sequencing, and decision points.
- PM-PROP-010: Cost, pricing, and unit economics become active when runtime or vendor spend changes materially.
- PM-PROP-011: Metrics must distinguish leading indicators, lagging outcomes, guardrails, and vanity numbers.
- PM-PROP-012: Risk register entries must include assumption, likelihood, impact, owner, and review date.
- PM-PROP-013: Product decisions need ADR or decision-log evidence when they affect future compatibility.
- PM-PROP-014: User feedback loops must say who reviews feedback and what action threshold changes the plan.
- PM-PROP-015: Release notes and stakeholder updates must match the actual user-visible change.
- PM-PROP-016: Deprecation needs notice period, replacement path, compatibility guarantee, and sunset evidence.
- PM-PROP-017: Support and CS readiness become active when users can be blocked or confused by the change.
- PM-PROP-018: Experiments need hypothesis, segment, measurement window, and failure interpretation.

## PM-FILL - Operating Guidance

### PM-FILL-INTENT - Shared Intent

- scope 를 확장하기 전에 user, problem, business reason, expected outcome 을
  한 문단으로 쓴다. 넷 중 하나가 비면 plan 은 아직 추측이다.
- user-visible promise 와 internal implementation preference 를 분리한다.
  user promise 는 AC/release note 로, preference 는 design/implementation note 로 간다.
- non-goal 을 명명한다. AI-assisted work 에서는 non-goal 이 adjacent surface 확장을 막는다.

### PM-FILL-SCOPE - Scope And Tradeoff

- scope 결정은 included, excluded, why now, reopen signal 을 함께 가져야 한다.
- install, upgrade, release, public docs, pricing, support, partner behavior 를
  건드리면 파일 변경이 작아도 product commitment 로 본다.
- deferral 은 owner, trigger, 또는 "이 product line 에서는 하지 않음" 이유가 있을 때만 유효하다.

### PM-FILL-AC - Acceptance Contract

- AC 는 구현자와 대화하지 않은 reviewer 도 확인할 수 있어야 한다.
- AC 는 evidence form 을 말해야 한다: command output, screenshot,
  generated file, release artifact, user flow, metric, decision record 등.
- non-code 작업도 AC 가 있다. docs clarity, terminology consistency,
  package inclusion, support handoff, user-facing copy 도 검증 가능해야 한다.

### PM-FILL-ROLLOUT - Launch And Communication

- release note 는 실제 user-visible behavior 와 맞아야 한다. 사용자의 행동이
  바뀌지 않는 internal detail 은 user note 에 넣지 않는다.
- 사용자가 막히거나 혼란스러울 수 있으면 rollout 은 audience, entry point,
  fallback, support owner, stop condition 을 가져야 한다.
- existing user 에게는 migration path, compatibility expectation, 안전하게 무시해도 되는 것을 알려준다.

### PM-FILL-METRICS - Feedback And Decision Cadence

- 유용한 metric 은 actor, action, time window, baseline, decision 을 포함한다.
  decision 이 없는 숫자는 vanity number 다.
- feedback loop 는 owner 와 threshold 가 있어야 한다. "피드백 수집"은 누가
  언제 plan 을 바꿀지 정해져야 loop 가 된다.
- experiment 는 hypothesis, segment, measurement window, success threshold,
  negative result 해석을 기록한다.

## PM-REVIEW - Review Questions

- reviewer 가 implementation note 없이 user value 를 설명할 수 있는가?
- non-goal 이 adjacent-scope expansion 을 막을 만큼 명확한가?
- 각 AC 에 concrete evidence 와 owner 가 있는가?
- release/user-facing message 가 실제 변경과 맞는가?
- deferred item 은 잊힌 것이 아니라 의도적으로 parked 되었는가?

## PM-EVIDENCE - Suggested Evidence

- one-paragraph shared-intent statement.
- AC table with evidence command/path/result.
- scope ledger: included, excluded, deferred, reason.
- 사용자 영향이 있을 때 release note 또는 stakeholder update draft.
- compatibility, pricing, SLA, partner, migration choice 에 대한 decision log.

## PM-GAP - Deepening Slots

- PM-GAP-001: Pricing and packaging decision framework.
- PM-GAP-002: Partner negotiation and responsibility matrix templates.
- PM-GAP-003: Roadmap sequencing and dependency scoring.
- PM-GAP-004: Launch communication and release-note quality rubric.
- PM-GAP-005: User research synthesis and feedback triage.
- PM-GAP-006: Product risk register examples.
- PM-GAP-007: Adoption and migration playbook for existing users.
- PM-GAP-008: Decision log templates for AI-assisted product work.
