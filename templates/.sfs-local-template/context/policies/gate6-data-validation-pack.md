---
id: sfs-policy-gate6-data-validation-pack
summary: Gate 6 TDD closure for mock, fixture, seed, API, UI state, and persisted data validation.
load_when:
  - Gate 6
  - data validation
  - mock
  - fixture
  - seed
  - migration
  - backfill
  - API payload
  - UI state
  - persistence
status: filled-v1
content_policy: "load when implementation changes data shape, state, persistence, API payloads, auth/session, or fixtures"
---

# Gate 6 Data Validation Pack

Gate 6 must prove data behavior, not only that code was edited. Mock data is a
TDD tool, not acceptance evidence by itself.

## Activation

Use this pack when the sprint changes:

- DB schema, migration, backfill, seed, cache, job, or persistence behavior;
- API request/response, event payload, DTO mapper, validation, auth/session;
- UI state, form data, local storage, analytics, or observable log shape;
- permissions, ownership, tenant/user boundaries, lifecycle/delete rules;
- fixtures, mock providers, fallback data, demo data, or test dataset rules.

## Representative Data Set

Choose only the relevant rows:

- happy path with normal production-like synthetic data;
- boundary values: empty, min/max, long text, unicode, null/legacy value;
- negative values: malformed, unauthorized, cross-owner, duplicate, stale;
- migration/backfill: before/after count, sampled rows, idempotent rerun;
- concurrency/retry: duplicate call, partial failure, resume/restart;
- UI state: first visit, returning session, cached/stale state, offline/error.

## TDD Closure

Prefer a failing or characterization check before the fix. At Gate 6, record:

| field | required evidence |
|---|---|
| fixture name | named fixture/mock/seed or real integration source |
| invariant | what must always hold |
| validation command | test/smoke/query/browser/API command |
| result | pass/fail plus relevant count/sample |
| waiver | why automation or real integration was not practical |

Mock-only PASS is partial unless the fixture is named, synthetic, covers the
relevant boundary/negative case, and asserts the invariant. Production snapshots
or PII require explicit approval and redaction.
