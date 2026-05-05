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
status: filled-v1
content_policy: "compact operating guidance; apply only matching ids and keep QA depth proportional to blast radius"
---

# QA Knowledge Pack Inventory

This file is a compact filled guidance pack for QA work. Use it to decide the
right confidence evidence for a sprint, review, or release. Apply only the
matching ids and keep the verification surface proportional to blast radius.

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

- Map each acceptance criterion to one evidence method: automated test, smoke
  command, manual walkthrough, screenshot, fixture diff, log assertion, or
  release verifier.
- If an AC cannot be verified, rewrite the AC or record it as a product
  judgment, not a test result.
- Evidence belongs to the commit or artifact under review. Stale green checks
  are not release confidence.

### QA-FILL-RISK - Regression Selection

- Start from changed behavior, then inspect adjacent contracts: public command,
  file path, persisted data, API/event shape, user docs, install/update path,
  and operator workflow.
- Small docs changes need link/path/wording consistency checks. Small release
  tooling changes need clean install/upgrade smoke, not just syntax.
- High-risk domains such as money, PII, auth, partner state, migration, batch,
  or public release artifacts require negative and recovery checks.

### QA-FILL-CONTRACT - External And Cross-Boundary Checks

- API/event/CLI contracts need compatibility checks for required fields, unknown
  fields, versioning, errors, retry, and idempotency.
- Contract tests are mandatory when another team, partner, runtime, package
  manager, or automation consumes the surface.
- If formal contract tooling is unavailable, record sample payloads, command
  examples, expected outputs, and failure examples.

### QA-FILL-STATE - Data, Batch, And Migration

- Migration and backfill evidence should include before/after counts, sampled
  record checks, idempotent rerun, reject list, rollback, and audit trail.
- Batch QA needs restart, retry, skip, duplicate, partial progress, and limit
  boundary scenarios.
- Transactional semantics require real integration evidence when cache,
  propagation, locking, flush, or commit timing matters.

### QA-FILL-RELEASE - Confidence Report

- A release confidence note should list what was tested, what was not tested,
  why the untested risk is acceptable, rollback/fallback, and the artifact
  identity.
- Manual verification is acceptable when it is reproducible enough for a second
  evaluator.
- Flaky or environment-dependent checks must be labeled and either fixed,
  quarantined, or excluded with a reason.

## QA-REVIEW - Review Questions

- Does every AC have current evidence?
- Which adjacent behavior could regress even if the direct path works?
- Did we test at least one negative path for each high-risk surface?
- Can this verification be repeated by another agent or human?
- What risk remains, and who accepted it?

## QA-EVIDENCE - Suggested Evidence

- AC-to-evidence matrix.
- Test/smoke command output with commit/artifact identity.
- Fixture samples for boundary and negative cases.
- Manual walkthrough notes with exact path and expected observation.
- Release confidence note with residual risk and rollback.

## QA-GAP - Deepening Slots

- QA-GAP-001: QA evidence matrix by artifact type.
- QA-GAP-002: Regression selection heuristics for AI-generated changes.
- QA-GAP-003: Contract-test strategy and Pact-style examples.
- QA-GAP-004: Batch/migration test recipes.
- QA-GAP-005: Flake triage and CI reliability policy.
- QA-GAP-006: Release confidence report template.
- QA-GAP-007: Exploratory testing charter templates.
- QA-GAP-008: Security QA checklist for auth, PII, and secret exposure.
