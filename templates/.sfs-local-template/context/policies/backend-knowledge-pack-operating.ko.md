---
id: sfs-policy-backend-knowledge-pack-operating-ko
summary: Backend filled operating guidance, review questions, evidence, deepening contract(한글 버전).
language: ko
load_when:
  - backend
  - BE-FILL
  - evidence
  - review questions
  - operating guidance
status: split-v1
parent_doc: backend-knowledge-pack.ko.md
split_from_section: "Backend Filled Guidance"
content_policy: "backend-knowledge-pack.ko.md 와 matching proposition ids 가 세부 운영 지침을 활성화할 때 읽는다"
---

# Backend Operating Guidance

아래 check 는 matching proposition id 가 활성화된 경우에만 적용한다.

## BE-FILL-ARCH - Architecture Shape

- 팀이 실제로 운영할 수 있는 runtime 에서 시작한다. 독립 배포, scaling,
  ownership, compliance 압력이 증명되기 전까지 clean layered monolith 가 기본값이다.
- CQRS 는 database 수가 아니라 application boundary 선택이다. command,
  read, audit, integration flow 의 model 과 failure mode 가 다를 때 유용하다.
- Hexagonal architecture 는 boundary 를 선명하게 만드는 경우에만 값이 있다.
  port, adapter, test, domain language 가 명확해지지 않으면 단순 폴더 증가다.
- MSA 는 조직/운영 commitment 다. 독립 release cadence, team ownership,
  observability, data ownership, failure isolation, deployment operation 증거가 필요하다.

## BE-FILL-TX - Transaction And State Safety

- 각 use case 의 transaction owner 를 명명한다. controller/repository method 가
  business transaction scope 를 우연히 정의하게 두지 않는다.
- 외부 API call, 느린 I/O, retry 가 불확실한 작업은 DB transaction 밖에 둔다.
  예외는 이유와 compensation strategy 가 기록되어야 한다.
- `REQUIRES_NEW` 는 caller 가 return value, committed side effect, isolated
  log/audit action 중 무엇을 소비하는지 명시한다.
- child transaction 후 state 를 다시 읽는다면 first-level cache, flush, clear,
  refresh, real persistence-context test boundary 를 검토한다.
- quota, balance, settlement, limit, inventory path 는 atomic
  check-effect-record semantics 와 boundary test 가 필요하다.

## BE-FILL-BATCH - Batch, Worker, And Replay

- batch job 은 release-ready 전 restartability, idempotency, chunk sizing,
  partial-progress policy, failure classification 을 가져야 한다.
- writer side effect 는 retry/restart 에 안전해야 한다. 외부 effect 라면
  idempotency key 와 reconciliation path 를 기록한다.
- boundary dataset 은 zero, one, exact chunk boundary, limit 직전/정확히/직후,
  duplicate, stale row, downstream failure 를 포함한다.
- job metadata, execution id, input snapshot, output count, skip count,
  error sample 은 evidence 이며 단순 debug noise 가 아니다.

## BE-FILL-INTEGRATION - API, Events, And Partners

- 공유 object 별 Source of Truth 를 정의한다. replica 는 cache/project 할 수 있지만,
  hidden write-master 동작은 명시하거나 거부해야 한다.
- partner/API/event boundary 마다 timeout, retry, idempotency, error taxonomy,
  correlation id, versioning, replay, support ownership 을 기록한다.
- 외부 propagation 은 outbox, queue, archived payload + replay path 같은 durable
  handoff 를 선호한다. JVM-local event 만으로는 integration 이 아니다.
- production exposure 전 contract drift 의 owner 와 compatibility policy 가 필요하다.

## BE-FILL-OPS - Runtime And Observability

- release readiness 는 config source, secret handling, health check,
  logs/metrics/traces, rollback, runbook coverage 를 포함한다.
- connection pool, worker concurrency, scheduled job, blue/green overlap 은
  같은 capacity model 안에서 맞아야 한다.
- sensitive log 는 source 에서 masking 하고 failure path 에서 검증한다.
- AWS/cloud 작업은 runtime surface 가 실제 scope 일 때 IAM, network exposure,
  secret storage, cost, backup, alert ownership 을 검토한다.

## Backend Review Questions

- 무엇은 안전하게 retry 할 수 있고, 무엇은 compensate/reconcile 해야 하는가?
- business invariant 를 소유하는 transaction 은 무엇인가?
- system 간 state 가 충돌할 때 authoritative source 는 무엇인가?
- happy path 가 아니라 failure mode 를 증명하는 evidence 는 무엇인가?
- 어떤 operation 이 사람을 깨울 수 있으며 runbook owner 는 누구인가?

## Backend Evidence

- AC id 와 test/smoke/manual verification mapping.
- high-risk flow 의 transaction/integration sequence.
- state transition matrix 또는 append-only history sample.
- data 변경 시 DB migration/backfill dry-run 과 rollback note.
- production 또는 release tooling 에 대한 logs/metrics/alerts/runbook link.

## Related Official Division Packs

Use these files for the other official SFS divisions. They are also compact
guidance packs and should be loaded through the router.

- `strategy-pm-knowledge-pack.md`
- `taxonomy-knowledge-pack.md`
- `design-knowledge-pack.md`
- `qa-knowledge-pack.md`
- `infra-knowledge-pack.md`

## Future Deepening Contract

When a later deepening sprint starts, high-risk propositions may receive:
- rationale
- when-to-activate triggers
- pass/partial/fail review questions
- examples and counterexamples
- suggested evidence
- source references
- owner division
- severity
- release visibility
