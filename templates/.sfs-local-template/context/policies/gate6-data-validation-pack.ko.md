---
id: sfs-policy-gate6-data-validation-pack-ko
summary: mock/fixture/seed/API/UI state/persisted data 를 Gate 6 에서 TDD 방식으로 검증하는 기준.
language: ko
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
content_policy: "데이터 shape/state/persistence/API/auth/session/fixture 가 바뀔 때 로드"
---

# Gate 6 Data Validation Pack

Gate 6 는 코드가 바뀌었다는 사실이 아니라 데이터 동작을 증명해야 한다. 목 데이터는
TDD 도구이지 그 자체로 acceptance evidence 가 아니다.

## 활성 조건

다음이 바뀌면 이 팩을 쓴다.

- DB schema, migration, backfill, seed, cache, job, persistence behavior
- API request/response, event payload, DTO mapper, validation, auth/session
- UI state, form data, local storage, analytics, observable log shape
- permission, ownership, tenant/user boundary, lifecycle/delete rule
- fixture, mock provider, fallback/demo/test dataset rule

## 대표 데이터 세트

필요한 row 만 고른다.

- happy path: production-like synthetic data
- boundary: empty, min/max, long text, unicode, null/legacy value
- negative: malformed, unauthorized, cross-owner, duplicate, stale
- migration/backfill: before/after count, sampled rows, idempotent rerun
- concurrency/retry: duplicate call, partial failure, resume/restart
- UI state: first visit, returning session, cached/stale state, offline/error

## TDD 종료 기준

가능하면 fix 전 failing 또는 characterization check 를 먼저 만든다. Gate 6 에는
다음을 기록한다.

| field | required evidence |
|---|---|
| fixture name | named fixture/mock/seed 또는 real integration source |
| invariant | 항상 지켜야 하는 성질 |
| validation command | test/smoke/query/browser/API command |
| result | pass/fail plus count/sample |
| waiver | 자동화/실통합이 어려웠던 이유 |

mock-only PASS 는 fixture 가 이름 있고, synthetic 이며, 관련 boundary/negative case 를
커버하고 invariant 를 assert 하지 않으면 partial 이다. production snapshot 또는 PII 는
명시 승인과 redaction 이 필요하다.
