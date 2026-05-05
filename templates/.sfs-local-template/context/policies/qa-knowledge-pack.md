---
id: sfs-policy-qa-knowledge-pack
summary: QA topic and proposition inventory for SFS division activation.
load_when:
  - qa
  - test
  - verification
  - regression
  - release confidence
  - defect
  - acceptance criteria
status: seed-inventory
content_policy: "topic/proposition only; do not expand into full guidance until a dedicated fill sprint"
---

# QA Knowledge Pack Inventory

This file is a topic/proposition inventory, not the filled knowledge base.
Use it to decide which QA concepts are active for a sprint, review, or release.
Record ids only unless the user asks for fill work.

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

## QA-GAP - Fill Slots For Later

- QA-GAP-001: QA evidence matrix by artifact type.
- QA-GAP-002: Regression selection heuristics for AI-generated changes.
- QA-GAP-003: Contract-test strategy and Pact-style examples.
- QA-GAP-004: Batch/migration test recipes.
- QA-GAP-005: Flake triage and CI reliability policy.
- QA-GAP-006: Release confidence report template.
- QA-GAP-007: Exploratory testing charter templates.
- QA-GAP-008: Security QA checklist for auth, PII, and secret exposure.
