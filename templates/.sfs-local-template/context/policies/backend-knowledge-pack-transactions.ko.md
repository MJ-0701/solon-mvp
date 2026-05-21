---
id: sfs-policy-backend-knowledge-pack-transactions-ko
summary: Transaction, Spring Batch, event, outbox, idempotency 점검 항목(한글 버전).
language: ko
load_when:
  - backend
  - transaction
  - Spring Batch
  - batch
  - event
  - outbox
  - idempotency
status: split-v1
parent_doc: backend-knowledge-pack.ko.md
split_from_section: "Backend Proposition Inventory"
content_policy: "backend-knowledge-pack.ko.md 가 BE-TX, BE-BATCH-TX, BE-EVENT, BE-IDEMP 를 활성화할 때 읽는다"
---

# Backend Transactions Pack

## BE-TX - Transaction Boundary

- BE-TX-001: Transaction boundaries belong at the service/application layer, not controller/repository by default.
- BE-TX-002: Read-only transactions should be marked explicitly when useful.
- BE-TX-003: External API calls inside DB transactions are a review smell.
- BE-TX-004: Message/event publication inside a transaction must go through Outbox or equivalent durable handoff.
- BE-TX-005: Non-default propagation/isolation/rollback rules need written rationale.
- BE-TX-006: Self-invocation can bypass Spring AOP transaction semantics.
- BE-TX-007: Long transactions must be split or justified.
- BE-TX-008: `REQUIRES_NEW` uses a separate physical transaction/EntityManager and may require a second connection.
- BE-TX-009: `REQUIRES_NEW` must define whether the caller consumes a return value, a persisted side effect, or a fire-and-forget effect.
- BE-TX-010: Swallowed child exceptions can still lead to `UnexpectedRollbackException` under shared rollback-only state.
- BE-TX-011: `NESTED` is limited with JPA transaction managers and must not be assumed.
- BE-TX-012: `@Async` does not inherit caller transaction context; use after-commit/outbox design when state visibility matters.

## BE-BATCH-TX - Spring Batch Transaction Semantics

- BE-BATCH-TX-001: Chunk-oriented steps open a transaction and EntityManager for the chunk.
- BE-BATCH-TX-002: `ItemWriter.write()` runs inside the chunk transaction opened by Spring Batch.
- BE-BATCH-TX-003: `chunk(1)` still has a transaction and persistence context for the one item.
- BE-BATCH-TX-004: A `REQUIRED` service called by the writer joins the chunk transaction and EntityManager.
- BE-BATCH-TX-005: A `REQUIRES_NEW` service commits in a separate transaction/EntityManager while the outer chunk EntityManager remains alive.
- BE-BATCH-TX-006: A database row changed by `REQUIRES_NEW` may remain stale in the outer EntityManager first-level cache.
- BE-BATCH-TX-007: "Void update then caller re-read in the same outer EntityManager" is an accident-prone pattern.
- BE-BATCH-TX-008: If the caller needs the result of `REQUIRES_NEW`, prefer an explicit return result over DB re-read.
- BE-BATCH-TX-009: If a re-read is unavoidable, the EntityManager boundary must be intentionally separated or refreshed.
- BE-BATCH-TX-010: Putting an external API inside the chunk transaction can hide cache staleness while introducing worse lock/rollback/external-effect risks.
- BE-BATCH-TX-011: Quota/limit/balance logic must define atomic "check -> execute -> record/decrement" semantics.
- BE-BATCH-TX-012: Mock tests do not simulate persistence-context lifetime, first-level cache, transaction propagation, flush, or commit timing.
- BE-BATCH-TX-013: Batch transaction bugs require DataJpa/SpringBoot/SpringBatch integration tests with a real database boundary.
- BE-BATCH-TX-014: `@SpringBatchTest` should cover job/step behavior when reader/processor/writer/listener interaction matters.
- BE-BATCH-TX-015: Limit/quota batch paths need boundary tests before/at/after the limit.

## BE-EVENT - Events / Outbox / Messaging

- BE-EVENT-001: Internal Spring events are JVM-local and must not be confused with durable integration events.
- BE-EVENT-002: `@TransactionalEventListener(AFTER_COMMIT)` alone is not enough for external propagation.
- BE-EVENT-003: Transactional Outbox couples business state change and outbox insert in one transaction.
- BE-EVENT-004: Outbox relay/CDC publishing and backlog monitoring are separate review topics.
- BE-EVENT-005: Events are immutable and need event id, version, time, producer, correlation, causation, aggregate, and sequence metadata.
- BE-EVENT-006: At-least-once delivery is assumed; effects become effectively-once through idempotent consumers.
- BE-EVENT-007: Consumer ACK occurs after durable business processing.
- BE-EVENT-008: DLQ, poison-message isolation, and reprocessing tools are required topics when MQ is in scope.

## BE-IDEMP - Idempotency / Ordering / State History

- BE-IDEMP-001: Idempotency key strategy differs for partner events, user requests, and batch records.
- BE-IDEMP-002: Duplicate detection must be stored durably or with a justified TTL margin.
- BE-IDEMP-003: Idempotency check and business effect must be transactionally safe.
- BE-IDEMP-004: Database uniqueness remains the final defense line.
- BE-IDEMP-005: Ordering is scoped by aggregate; one global FIFO key is a throughput smell.
- BE-IDEMP-006: Late/old events require policy: ignore, compensate, or alarm.
- BE-IDEMP-007: State transition matrices must define allowed from/to movement.
- BE-IDEMP-008: State history should be append-only and carry causal ids.
- BE-IDEMP-009: Partner event id to internal aggregate id mapping is an explicit artifact.
