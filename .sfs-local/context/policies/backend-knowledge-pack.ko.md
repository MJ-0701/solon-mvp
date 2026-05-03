---
id: sfs-policy-backend-knowledge-pack-ko
summary: Backend/JVM/Spring/Transaction/Batch/DevOps 지식 항목 인벤토리(한글 버전).
language: ko
load_when:
  - backend
  - JVM
  - Spring Boot
  - JPA
  - Hibernate
  - HikariCP
  - transaction
  - batch
  - DevOps
  - AWS
status: seed-inventory
content_policy: "topic/proposition only; do not expand into full guidance until a dedicated fill sprint"
---

# Backend Knowledge Pack Inventory

This file is a topic/proposition inventory, not the filled knowledge base.
When backend, transaction, batch, integration, or DevOps risk appears, use the
ids below to decide which knowledge slots must be filled or reviewed. Do not
expand the deep content unless the user explicitly asks for that fill work.

Source seeds:
- `architecture-review-checklist.md` - JVM backend, Spring Boot, JPA, HikariCP,
  integration reliability, DevOps/AWS review topics.
- `Spring_Batch_트랜잭션.pdf` - Spring Batch chunk transaction, JPA persistence
  context, `REQUIRES_NEW`, external API interaction accident pattern.

## Activation Rules

- Use only matching topics. Small CRUD work should not load every proposition.
- Treat these as expert-review prompts, not universal blockers.
- During Gate 3 (Plan), record applicable ids in AC or risk notes.
- During Gate 4/6 (Design/Review), evaluate only ids that match the work.
- During Gate 7 (Retro), promote missing or repeated ids into filled rules.
- This pack is a division-activation router. It decides which concepts become
  relevant at the current project size and risk level.
- Do not activate Kubernetes/MSA/enterprise cloud governance for an initial MVP
  unless concrete scale, deployment, ownership, or compliance evidence exists.

## Scale / Division Activation Inventory

### SCALE - Review Depth By Project Size

- SCALE-001: Local prototype or first MVP uses the smallest useful backend guardrails only.
- SCALE-002: First production exposure activates deploy, rollback, logging, basic monitoring, secrets, and DB safety topics.
- SCALE-003: Money, settlement, refund, contract, claim, PII, or regulated data activates transaction, history, idempotency, audit, and reconciliation topics.
- SCALE-004: Partner integration activates contract, timeout, retry, error, correlation, runbook, and joint observability topics.
- SCALE-005: Event/MQ/webhook usage activates Outbox, idempotent consumer, DLQ, ordering, replay, and poison-message topics.
- SCALE-006: Batch/worker/scheduler usage activates chunk transaction, job idempotency, retry/skip, resource sizing, and restartability topics.
- SCALE-007: High traffic or latency-sensitive paths activate capacity, connection pool, cache, async, backpressure, and load-test topics.
- SCALE-008: Multi-team or long-lived product work activates ADR, ownership, compatibility, migration, and deprecation topics.
- SCALE-009: K8s, Terraform, MSA, service mesh, and platform governance require explicit evidence; they are not default MVP topics.

### DIV-ACT - Division Activation Hints

- DIV-ACT-DEV-001: Dev is active whenever code, data model, API, batch, or integration behavior changes.
- DIV-ACT-INFRA-001: Infra activates when cloud resources, deployment topology, secrets, networking, scaling, or observability changes.
- DIV-ACT-QA-001: QA activates when money/PII/partner state, regression risk, migration, batch, or release confidence is material.
- DIV-ACT-TAX-001: Taxonomy activates when aggregate, state, event, error, API field, role, or status wording can drift.
- DIV-ACT-SEC-001: Security activates when credentials, PII, financial data, public endpoints, IAM, audit, or partner auth is involved.
- DIV-ACT-DESIGN-001: Design activates when admin/CS/operator screens must expose state history, reconciliation, replay, or incident workflows.
- DIV-ACT-PM-001: Strategy/PM activates when SLA/SLO, partner responsibility, business process, pricing/cost, or roadmap commitment is affected.

### ANTI-OVER - Over-Engineering Guardrails

- ANTI-OVER-001: Do not require every architecture artifact for a throwaway spike.
- ANTI-OVER-002: Do not introduce K8s because deployment is mentioned; first ask what runtime scale and ownership demand it.
- ANTI-OVER-003: Do not introduce MSA before monolith/hexagonal seams and independent lifecycle evidence exist.
- ANTI-OVER-004: Do not require Kafka when SQS, DB polling, webhook queueing, or a simpler durable queue satisfies the failure model.
- ANTI-OVER-005: Do not require CQRS/Event Sourcing for ordinary CRUD unless read/write model, audit, integration, or scale pressure demands it.
- ANTI-OVER-006: Do not force Redis/cache before a measured hot path or clear consistency budget exists.
- ANTI-OVER-007: Do not make infra/security review optional when secrets, PII, money, public surface, or production exposure exists.

### GAP - Missing Knowledge Slots To Fill Later

- GAP-001: Database migration, zero-downtime rollout, backfill, and rollback strategy.
- GAP-002: Data retention, deletion, legal basis, audit retention, and privacy lifecycle.
- GAP-003: Feature flag, kill switch, dark launch, and progressive rollout patterns.
- GAP-004: Cost budget, unit economics, and cloud spend guardrails by project size.
- GAP-005: Incident severity, ownership, escalation, communication, and postmortem quality.
- GAP-006: Backup/restore drills and disaster recovery evidence.
- GAP-007: Local/dev/stage/prod parity and fixture/test data governance.
- GAP-008: Schema evolution for OpenAPI, AsyncAPI, DB, event payloads, and enum expansion.
- GAP-009: Multi-tenant boundaries, tenant isolation, and data access control.
- GAP-010: Dependency ownership, supply-chain risk, vulnerability response, and upgrade cadence.
- GAP-011: Network topology, DNS, NAT, VPC/subnet routing, and private/public boundary review.
- GAP-012: Runtime configuration, environment variables, secret rotation, and config drift detection.
- GAP-013: Replay/reprocessing semantics for events, batches, and external payload archives.
- GAP-014: Admin/operator tooling for reconciliation, state correction, DLQ replay, and audit trail.
- GAP-015: Performance test design, load shape, traffic model, and bottleneck hypothesis.

## Backend Proposition Inventory

### BE-ARCH - Backend Architecture Shape

- BE-ARCH-001: MVP/small backend starts as a clean layered monolith.
- BE-ARCH-002: Non-initial backend work may need CQRS at the application boundary even on one database.
- BE-ARCH-003: Hexagonal architecture is proposed when domain seams, integration seams, or release cadence make boundaries visible.
- BE-ARCH-004: MSA requires explicit deploy/scale/ownership/resilience/blast-radius evidence and user approval.
- BE-ARCH-005: Architecture artifacts must include context, component, sequence, state, data-flow, ERD, API/event contract, runbook, capacity, SLO, and security agreement when partner integration is material.

### BE-CICD - 배포 / 운영 런타임

- BE-CICD-001: CI/CD는 빌드-테스트-검증-패키징-공개까지 하나의 신뢰 경로로 연결되어야 한다.
- BE-CICD-002: 배포 전략은 blue/green, canary, rolling 중 프로젝트 리스크와 가용성 요구에 맞춰 선택된다.
- BE-CICD-003: Blue/green 또는 canary는 상태 확인, 롤백 임계치, 그리고 부분 실패 정리 절차가 함께 정립되어야 한다.
- BE-CICD-004: 배포 아티팩트는 환경별 재생성이 아니라 동일 산출물을 배포한다.
- BE-CICD-005: Secrets와 시크릿 스토어(Secrets Manager/SSM/CI secret store) 사용이 기본값이다.
- BE-CICD-006: server shutdown/컨테이너 종료 동작과 로드밸런서 드레인·커넥션 회수 정책은 함께 정합성 검토한다.
- BE-CICD-007: 이벤트 수신/웹훅은 배포 시점에도 최소 유실 조건으로 동작해야 한다.
- BE-CICD-008: 배포 도중 로그/헬스·메트릭의 상시 가시성은 회귀 탐지의 기본 조건이다.
- BE-CICD-009: 배포 파이프라인이 커버하지 않는 수동 작업은 체크리스트와 점검책임자가 명시되어야 한다.

### BE-JVM - JVM / Spring Boot Runtime

- BE-JVM-001: Spring Boot 3.x implies Java 17+ and Jakarta package migration review.
- BE-JVM-002: Actuator exposure, management port, liveness/readiness, and sensitive value masking are security review topics.
- BE-JVM-003: Profile separation must be explicit across local/dev/stage/prod.
- BE-JVM-004: JVM GC, heap, OOM, timezone, and encoding settings are deployment review topics.
- BE-JVM-005: Embedded Tomcat and graceful shutdown must align with load balancer draining.
- BE-JVM-006: Virtual threads are a workload-specific option, constrained by pinning, ThreadLocal use, and external pools.

### BE-JPA - JPA / Hibernate / Data Access

- BE-JPA-001: OSIV should be explicitly reviewed and usually disabled.
- BE-JPA-002: `ddl-auto` must not mutate production schema implicitly.
- BE-JPA-003: ID generation strategy must be explicit; `AUTO` is a review smell.
- BE-JPA-004: IDENTITY, SEQUENCE, and TABLE strategies carry different batching and connection-demand tradeoffs.
- BE-JPA-005: N+1 mitigation, batch fetch size, entity graph, fetch join, and projection choices must be intentional.
- BE-JPA-006: Query settings such as IN-clause padding and collection-fetch pagination failure are review topics.
- BE-JPA-007: Auto-commit and `provider_disables_autocommit` must match the transaction model.
- BE-JPA-008: SQL logging must avoid `show_sql` and use logger-based controls.
- BE-JPA-009: Optimistic locking is required when partner events and internal state changes can race.
- BE-JPA-010: Envers revision type and audit scope require explicit review.

### BE-HIKARI - HikariCP / Connection Pool

- BE-HIKARI-001: Pool sizing must account for all concurrent DB-accessing threads.
- BE-HIKARI-002: Pool sizing must account for one task needing multiple simultaneous connections.
- BE-HIKARI-003: `REQUIRES_NEW`, sequence/table ID allocation, direct JDBC, reader datasource, and nested service calls can increase connection demand.
- BE-HIKARI-004: Blue/green deployment doubles connection pressure during overlap.
- BE-HIKARI-005: `maxLifetime`, `idleTimeout`, `keepaliveTime`, and DB wait timeout must be coherent.
- BE-HIKARI-006: Leak detection and pool metrics are early warning requirements.
- BE-HIKARI-007: Batch/non-realtime apps should have different pool assumptions from realtime APIs.

### BE-TX - Transaction Boundary

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

### BE-BATCH-TX - Spring Batch Transaction Semantics

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

### BE-EVENT - Events / Outbox / Messaging

- BE-EVENT-001: Internal Spring events are JVM-local and must not be confused with durable integration events.
- BE-EVENT-002: `@TransactionalEventListener(AFTER_COMMIT)` alone is not enough for external propagation.
- BE-EVENT-003: Transactional Outbox couples business state change and outbox insert in one transaction.
- BE-EVENT-004: Outbox relay/CDC publishing and backlog monitoring are separate review topics.
- BE-EVENT-005: Events are immutable and need event id, version, time, producer, correlation, causation, aggregate, and sequence metadata.
- BE-EVENT-006: At-least-once delivery is assumed; effects become effectively-once through idempotent consumers.
- BE-EVENT-007: Consumer ACK occurs after durable business processing.
- BE-EVENT-008: DLQ, poison-message isolation, and reprocessing tools are required topics when MQ is in scope.

### BE-IDEMP - Idempotency / Ordering / State History

- BE-IDEMP-001: Idempotency key strategy differs for partner events, user requests, and batch records.
- BE-IDEMP-002: Duplicate detection must be stored durably or with a justified TTL margin.
- BE-IDEMP-003: Idempotency check and business effect must be transactionally safe.
- BE-IDEMP-004: Database uniqueness remains the final defense line.
- BE-IDEMP-005: Ordering is scoped by aggregate; one global FIFO key is a throughput smell.
- BE-IDEMP-006: Late/old events require policy: ignore, compensate, or alarm.
- BE-IDEMP-007: State transition matrices must define allowed from/to movement.
- BE-IDEMP-008: State history should be append-only and carry causal ids.
- BE-IDEMP-009: Partner event id to internal aggregate id mapping is an explicit artifact.

### BE-INTEGRATION - Partner / External System Boundary

- BE-INTEGRATION-001: Both sides must share the same contract for API, event, error, retry, timeout, and state semantics.
- BE-INTEGRATION-002: Source of Truth must be defined per domain object.
- BE-INTEGRATION-003: Replicas must not become hidden write masters.
- BE-INTEGRATION-004: Push, pull, webhook, polling, and MQ choices require failure-mode rationale.
- BE-INTEGRATION-005: Webhook handlers should be lightweight and durable-queue-first.
- BE-INTEGRATION-006: HMAC/JWT/mTLS/IP allowlist/replay protection/secret rotation are integration security topics.
- BE-INTEGRATION-007: Circuit breaker, bulkhead, fallback, and rate limiting are boundary containment topics.
- BE-INTEGRATION-008: Correlation id must cross company/system boundaries.
- BE-INTEGRATION-009: Reconciliation jobs are required when cross-system state can diverge.
- BE-INTEGRATION-010: Runbooks and shared incident channels are part of the architecture, not afterthoughts.

### BE-HTTP - HTTP Client / Resilience

- BE-HTTP-001: Every external call needs connect/read/response timeout.
- BE-HTTP-002: Connection pool max, per-route max, idle time, and max lifetime must be set intentionally.
- BE-HTTP-003: Retry must include exception scope, backoff, jitter, max attempts, and total budget.
- BE-HTTP-004: Non-idempotent calls must not be retried casually.
- BE-HTTP-005: Circuit breaker, bulkhead, rate limiter, time limiter, and fallback are separate review slots.
- BE-HTTP-006: JVM DNS TTL and Netty DNS behavior are deployment review topics.
- BE-HTTP-007: Metrics must avoid URI cardinality explosion.

### BE-THREAD - Async / Scheduler / Context Propagation

- BE-THREAD-001: ThreadPoolTaskExecutor must set core, max, queue, keepalive, shutdown, rejection, prefix, and task decorator intentionally.
- BE-THREAD-002: Unbounded queues hide saturation and make `maxPoolSize` meaningless.
- BE-THREAD-003: Scheduler pool size must be explicit when multiple scheduled tasks exist.
- BE-THREAD-004: Executor sizing must align with external API limits and DB/Redis/MQ pools.
- BE-THREAD-005: MDC and SecurityContext propagation must be explicit across async boundaries.
- BE-THREAD-006: Rejected count and queue size require metrics/alarms.

### BE-RESILIENCE - Retry / Circuit Breaker / Bulkhead

- BE-RES-001: Retry scope, exception whitelist/blacklist, backoff, jitter, and stop budget are reviewed together.
- BE-RES-002: Non-idempotent methods must not be placed on naive infinite retry without compensation design.
- BE-RES-003: Circuit breaker policies must be endpoint- or boundary-specific to avoid shared blast radius.
- BE-RES-004: Semaphore/bulkhead partitioning is required when async or batch work can flood shared thread pools.
- BE-RES-005: Rate limiter policy must protect both upstream and downstream from burst amplification.
- BE-RES-006: Fallback paths must be idempotent or safe to de-duplicate under repeated invocation.
- BE-RES-007: Timeout and retry budgets should align with batch chunk/loop and lock hold-time realities.

### BE-CACHE - Redis / Local Cache

- BE-CACHE-001: Redis serializer choice is a compatibility and security topic.
- BE-CACHE-002: Cache TTL, key prefix, and stampede prevention must be explicit.
- BE-CACHE-003: Redis timeout, pool, native connection sharing, read preference, and cluster refresh are review topics.
- BE-CACHE-004: L1 local cache requires staleness budget and invalidation path.

### BE-LOCK - Distributed Locking / Concurrent State Protection

- BE-LOCK-001: Distributed lock need is explicit when duplicate processing can violate idempotency or balance invariants.
- BE-LOCK-002: Lock key design includes aggregate/entity scope and timeout policy, not only operation name.
- BE-LOCK-003: Try-lock with bounded wait is preferred where user-facing latency or batch backlog SLA matters.
- BE-LOCK-004: Lock failure must map to explicit retry/requeue/reject policy.
- BE-LOCK-005: Lock duration and renewal policy include heartbeat, stale lock recovery, and alerting.
- BE-LOCK-006: Deadlock and inversion ordering are documented for nested lock paths.

### BE-API - Contract / Error / Validation / Serialization

- BE-API-001: Error response format and partner-facing error codes require agreement.
- BE-API-002: Retryable vs terminal errors must be distinguishable.
- BE-API-003: Bean validation covers DTO shape; domain invariants belong in domain construction/change.
- BE-API-004: API and event versioning must preserve backward compatibility rules.
- BE-API-005: OpenAPI/AsyncAPI or contract test sources of truth are review topics.
- BE-API-006: Jackson time, timezone, unknown fields, nulls, enums, BigDecimal, and sensitive fields are review topics.
- BE-API-007: UTC storage and presentation-layer timezone conversion must be explicit.
- BE-API-008: JPA auditing is not a substitute for state history.

### BE-DATA - Database / Paging / NoSQL

- BE-DATA-001: Application DB accounts should not carry DDL or master privileges.
- BE-DATA-002: Aurora writer/reader endpoint and failover behavior must be reviewed.
- BE-DATA-003: DB wait timeout, Hikari lifetime, and failover behavior must align.
- BE-DATA-004: Slow query, audit, error logs, and Performance Insights are operational review topics.
- BE-DATA-005: Large offset paging is a smell; keyset/cursor or Slice should be considered.
- BE-DATA-006: Mongo timeouts, pool bounds, read/write concerns, and read preference must be explicit.

### BE-MQ - SQS / Kafka

- BE-MQ-001: SQS retention, long polling, visibility timeout, FIFO grouping, and DLQ are review topics.
- BE-MQ-002: Kafka manual commit, consumer lag, poll/session timeouts, idempotent producer, and schema registry are review topics.
- BE-MQ-003: MQ monitoring must include age/lag, visible backlog, DLQ ingress, and processing errors.

### BE-SECOPS - Security / DevOps / AWS / Observability

- BE-SECOPS-001: CI/CD must compile, test, package, and deploy immutable artifacts.
- BE-SECOPS-002: Rollback, blue/green/canary/rolling strategy, and graceful shutdown are release review topics.
- BE-SECOPS-003: Secrets belong in a secret manager or secure parameter store, not plaintext config.
- BE-SECOPS-004: Dependency scanning, container non-root, public subnet, SG minimum privilege, WAF, TLS, and IAM are review topics.
- BE-SECOPS-005: EC2, ALB, AutoScaling, RDS, Redis, S3/CloudFront, DynamoDB, SNS, OpenSearch, and Secrets Manager each need service-specific review slots.
- BE-SECOPS-006: Tagging must cover service/component/environment/owner/cost/managed-by where cost and ownership matter.
- BE-SECOPS-007: Monitoring must cover system, JVM, HTTP, ALB, RDS, Redis, MQ, logs, business metrics, severity, and runbook link.

## Related Official Division Packs

Use these files for the other official SFS divisions. They are also
topic/proposition inventories only.

- `strategy-pm-knowledge-pack.md`
- `taxonomy-knowledge-pack.md`
- `design-knowledge-pack.md`
- `qa-knowledge-pack.md`
- `infra-knowledge-pack.md`

## Fill Contract For Later

When a fill sprint starts, each proposition should receive:
- rationale
- when-to-activate triggers
- pass/partial/fail review questions
- examples and counterexamples
- suggested evidence
- source references
- owner division
- severity
- release visibility
