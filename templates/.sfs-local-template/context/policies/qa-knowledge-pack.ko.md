---
id: sfs-policy-qa-knowledge-pack-ko
summary: QA 지식 항목 인벤토리(한글 버전).
language: ko
load_when:
  - qa
  - test
  - verification
  - regression
  - release confidence
  - defect
  - acceptance criteria
status: filled-v1
content_policy: "compact operating guidance; apply only matching ids and keep QA depth proportional to blast radius"
---

# QA Knowledge Pack Inventory

이 파일은 QA 작업을 위한 compact filled guidance pack 이다. sprint, review,
release 에서 필요한 confidence evidence 를 고르고, matching id 만 blast radius 에
비례해서 적용한다.

## Activation Rules

- Activate only the QA depth needed for the blast radius.
- Small local changes may need smoke evidence only.
- Money, PII, partner state, batch processing, migration, auth, and release
  tooling require stronger QA evidence.
- QA review is not limited to tests; it owns confidence, defects, coverage gaps,
  and evidence quality.

## QA-SCALE - Review Depth By Project Size

- QA-SCALE-001: A throwaway spike needs a sanity check and known-risk note.
- QA-SCALE-002: MVP work needs acceptance checks mapped to user-visible behavior.
- QA-SCALE-003: Production work needs regression, rollback, and monitoring evidence.
- QA-SCALE-004: Partner or state-sync work needs contract, idempotency, ordering, and reconciliation checks.
- QA-SCALE-005: Batch/migration work needs restartability, boundary data, and partial-failure checks.
- QA-SCALE-006: Security-sensitive work needs abuse, access, masking, and secret-handling checks.
- QA-SCALE-007: Release tooling needs clean-install, upgrade, downgrade/rollback, and cross-platform smoke checks.

## QA-PROP - Proposition Inventory

- QA-PROP-001: Every acceptance criterion needs a verification method.
- QA-PROP-002: Tests must cover behavior, not only implementation branches.
- QA-PROP-003: The test pyramid must match risk; unit tests alone are not enough for integration semantics.
- QA-PROP-004: Contract tests become active when external API or event consumers are affected.
- QA-PROP-005: Fixtures must represent real boundary cases, not only happy-path samples.
- QA-PROP-006: Regression scope must be chosen from changed behavior and adjacent risk.
- QA-PROP-007: Defect triage must separate severity, priority, reproducibility, and release decision.
- QA-PROP-008: Flaky tests require quarantine or fix policy before release confidence is trusted.
- QA-PROP-009: CI evidence must be tied to the commit or artifact being released.
- QA-PROP-010: Exploratory testing becomes active when UX, workflow, or unclear domain behavior changes.
- QA-PROP-011: Performance checks need expected load shape and pass/fail threshold.
- QA-PROP-012: Migration/backfill checks need before/after counts, idempotency, and rollback evidence.
- QA-PROP-013: Batch checks need restart, skip/retry, duplicate, and boundary-count scenarios.
- QA-PROP-014: Security QA checks need authorization, sensitive output, and logging/masking review.
- QA-PROP-015: Observability checks verify that failures can be detected, not only that code works.
- QA-PROP-016: Release confidence must call out untested risk explicitly.
- QA-PROP-017: Manual verification should be reproducible enough for a second evaluator.
- QA-PROP-018: Test data governance matters when PII, production snapshots, or shared environments appear.
- QA-PROP-019: Event/state sync paths require replay, dedupe, ordering, dead-letter, and recovery tests.
- QA-PROP-020: Batch/transactional tests need real DB-backed integration layers, not only unit-level mocks.

## QA-TX - Batch / Transaction Focus

- QA-TX-001: Chunk/job-level tests are mandatory where quotas, balances, or side-effects are stateful.
- QA-TX-002: Boundary value tests (just-before/at/after limit) are mandatory for cap and quota logic.
- QA-TX-003: Re-read-after-`REQUIRES_NEW` patterns require explicit transaction/EM visibility checks.
- QA-TX-004: Restartability and recovery tests must cover partial progress, duplicate delivery, and idempotency of effects.
- QA-TX-005: Test data sets must include concurrent writes, lock contention, and rollback/retry interactions.

## QA-FILL - Operating Guidance

### QA-FILL-AC - Evidence Mapping

- 각 AC 를 하나의 evidence method 에 연결한다: automated test, smoke command,
  manual walkthrough, screenshot, fixture diff, log assertion, release verifier.
- 검증할 수 없는 AC 는 AC 를 다시 쓰거나 product judgment 로 기록한다. test result 로 위장하지 않는다.
- evidence 는 review 대상 commit/artifact 에 묶여야 한다. 오래된 green check 는 release confidence 가 아니다.

### QA-FILL-RISK - Regression Selection

- changed behavior 에서 시작하고 adjacent contract 를 본다: public command,
  file path, persisted data, API/event shape, user docs, install/update path,
  operator workflow.
- 작은 docs 변경은 link/path/wording consistency check 가 필요하다. 작은 release
  tooling 변경은 syntax 만이 아니라 clean install/upgrade smoke 가 필요하다.
- money, PII, auth, partner state, migration, batch, public release artifact 는
  negative/recovery check 를 요구한다.

### QA-FILL-CONTRACT - External And Cross-Boundary Checks

- API/event/CLI contract 는 required fields, unknown fields, versioning,
  errors, retry, idempotency compatibility 를 확인한다.
- 다른 team, partner, runtime, package manager, automation 이 소비하는 surface 는
  contract test 가 활성화된다.
- formal contract tooling 이 없으면 sample payload, command example,
  expected output, failure example 을 기록한다.

### QA-FILL-STATE - Data, Batch, And Migration

- migration/backfill evidence 는 before/after count, sampled record check,
  idempotent rerun, reject list, rollback, audit trail 을 포함한다.
- batch QA 는 restart, retry, skip, duplicate, partial progress, limit boundary scenario 를 본다.
- cache, propagation, locking, flush, commit timing 이 중요하면 transactional semantics 는
  real integration evidence 가 필요하다.

### QA-FILL-RELEASE - Confidence Report

- release confidence note 는 tested, not tested, untested risk 수용 이유,
  rollback/fallback, artifact identity 를 적는다.
- manual verification 은 두 번째 evaluator 가 반복할 수 있으면 허용된다.
- flaky/environment-dependent check 는 고치거나 quarantine 하거나 제외 이유를 기록한다.

## QA-REVIEW - Review Questions

- 모든 AC 에 최신 evidence 가 있는가?
- direct path 가 동작해도 adjacent behavior 중 회귀할 수 있는 것은 무엇인가?
- high-risk surface 별 negative path 를 최소 하나 확인했는가?
- 다른 agent/human 이 이 검증을 반복할 수 있는가?
- 남는 risk 는 무엇이고 누가 수용했는가?

## QA-EVIDENCE - Suggested Evidence

- AC-to-evidence matrix.
- commit/artifact identity 가 붙은 test/smoke command output.
- boundary/negative case fixture sample.
- exact path 와 expected observation 이 있는 manual walkthrough note.
- residual risk 와 rollback 을 포함한 release confidence note.

## QA-GAP - Deepening Slots

- QA-GAP-001: QA evidence matrix by artifact type.
- QA-GAP-002: Regression selection heuristics for AI-generated changes.
- QA-GAP-003: Contract-test strategy and Pact-style examples.
- QA-GAP-004: Batch/migration test recipes.
- QA-GAP-005: Flake triage and CI reliability policy.
- QA-GAP-006: Release confidence report template.
- QA-GAP-007: Exploratory testing charter templates.
- QA-GAP-008: Security QA checklist for auth, PII, and secret exposure.
