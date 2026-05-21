---
id: sfs-policy-backend-knowledge-pack-integration-ko
summary: Partner integration, HTTP resilience, async, cache, lock, API, data, MQ, SecOps 점검 항목(한글 버전).
language: ko
load_when:
  - backend
  - integration
  - HTTP
  - async
  - cache
  - lock
  - API
  - database
  - MQ
  - SecOps
  - AWS
status: split-v1
parent_doc: backend-knowledge-pack.ko.md
split_from_section: "Backend Proposition Inventory"
content_policy: "backend-knowledge-pack.ko.md 가 integration, resilience, API, data, MQ, SecOps ids 를 활성화할 때 읽는다"
---

# Backend Integration Pack

## BE-INTEGRATION - Partner / External System Boundary

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

## BE-HTTP - HTTP Client / Resilience

- BE-HTTP-001: Every external call needs connect/read/response timeout.
- BE-HTTP-002: Connection pool max, per-route max, idle time, and max lifetime must be set intentionally.
- BE-HTTP-003: Retry must include exception scope, backoff, jitter, max attempts, and total budget.
- BE-HTTP-004: Non-idempotent calls must not be retried casually.
- BE-HTTP-005: Circuit breaker, bulkhead, rate limiter, time limiter, and fallback are separate review slots.
- BE-HTTP-006: JVM DNS TTL and Netty DNS behavior are deployment review topics.
- BE-HTTP-007: Metrics must avoid URI cardinality explosion.

## BE-THREAD - Async / Scheduler / Context Propagation

- BE-THREAD-001: ThreadPoolTaskExecutor must set core, max, queue, keepalive, shutdown, rejection, prefix, and task decorator intentionally.
- BE-THREAD-002: Unbounded queues hide saturation and make `maxPoolSize` meaningless.
- BE-THREAD-003: Scheduler pool size must be explicit when multiple scheduled tasks exist.
- BE-THREAD-004: Executor sizing must align with external API limits and DB/Redis/MQ pools.
- BE-THREAD-005: MDC and SecurityContext propagation must be explicit across async boundaries.
- BE-THREAD-006: Rejected count and queue size require metrics/alarms.

## BE-RESILIENCE - Retry / Circuit Breaker / Bulkhead

- BE-RES-001: Retry scope, exception whitelist/blacklist, backoff, jitter, and stop budget are reviewed together.
- BE-RES-002: Non-idempotent methods must not be placed on naive infinite retry without compensation design.
- BE-RES-003: Circuit breaker policies must be endpoint- or boundary-specific to avoid shared blast radius.
- BE-RES-004: Semaphore/bulkhead partitioning is required when async or batch work can flood shared thread pools.
- BE-RES-005: Rate limiter policy must protect both upstream and downstream from burst amplification.
- BE-RES-006: Fallback paths must be idempotent or safe to de-duplicate under repeated invocation.
- BE-RES-007: Timeout and retry budgets should align with batch chunk/loop and lock hold-time realities.

## BE-CACHE - Redis / Local Cache

- BE-CACHE-001: Redis serializer choice is a compatibility and security topic.
- BE-CACHE-002: Cache TTL, key prefix, and stampede prevention must be explicit.
- BE-CACHE-003: Redis timeout, pool, native connection sharing, read preference, and cluster refresh are review topics.
- BE-CACHE-004: L1 local cache requires staleness budget and invalidation path.

## BE-LOCK - Distributed Locking / Concurrent State Protection

- BE-LOCK-001: Distributed lock need is explicit when duplicate processing can violate idempotency or balance invariants.
- BE-LOCK-002: Lock key design includes aggregate/entity scope and timeout policy, not only operation name.
- BE-LOCK-003: Try-lock with bounded wait is preferred where user-facing latency or batch backlog SLA matters.
- BE-LOCK-004: Lock failure must map to explicit retry/requeue/reject policy.
- BE-LOCK-005: Lock duration and renewal policy include heartbeat, stale lock recovery, and alerting.
- BE-LOCK-006: Deadlock and inversion ordering are documented for nested lock paths.

## BE-API - Contract / Error / Validation / Serialization

- BE-API-001: Error response format and partner-facing error codes require agreement.
- BE-API-002: Retryable vs terminal errors must be distinguishable.
- BE-API-003: Bean validation covers DTO shape; domain invariants belong in domain construction/change.
- BE-API-004: API and event versioning must preserve backward compatibility rules.
- BE-API-005: OpenAPI/AsyncAPI or contract test sources of truth are review topics.
- BE-API-006: Jackson time, timezone, unknown fields, nulls, enums, BigDecimal, and sensitive fields are review topics.
- BE-API-007: UTC storage and presentation-layer timezone conversion must be explicit.
- BE-API-008: JPA auditing is not a substitute for state history.

## BE-DATA - Database / Paging / NoSQL

- BE-DATA-001: Application DB accounts should not carry DDL or master privileges.
- BE-DATA-002: Aurora writer/reader endpoint and failover behavior must be reviewed.
- BE-DATA-003: DB wait timeout, Hikari lifetime, and failover behavior must align.
- BE-DATA-004: Slow query, audit, error logs, and Performance Insights are operational review topics.
- BE-DATA-005: Large offset paging is a smell; keyset/cursor or Slice should be considered.
- BE-DATA-006: Mongo timeouts, pool bounds, read/write concerns, and read preference must be explicit.

## BE-MQ - SQS / Kafka

- BE-MQ-001: SQS retention, long polling, visibility timeout, FIFO grouping, and DLQ are review topics.
- BE-MQ-002: Kafka manual commit, consumer lag, poll/session timeouts, idempotent producer, and schema registry are review topics.
- BE-MQ-003: MQ monitoring must include age/lag, visible backlog, DLQ ingress, and processing errors.

## BE-SECOPS - Security / DevOps / AWS / Observability

- BE-SECOPS-001: CI/CD must compile, test, package, and deploy immutable artifacts.
- BE-SECOPS-002: Rollback, blue/green/canary/rolling strategy, and graceful shutdown are release review topics.
- BE-SECOPS-003: Secrets belong in a secret manager or secure parameter store, not plaintext config.
- BE-SECOPS-004: Dependency scanning, container non-root, public subnet, SG minimum privilege, WAF, TLS, and IAM are review topics.
- BE-SECOPS-005: EC2, ALB, AutoScaling, RDS, Redis, S3/CloudFront, DynamoDB, SNS, OpenSearch, and Secrets Manager each need service-specific review slots.
- BE-SECOPS-006: Tagging must cover service/component/environment/owner/cost/managed-by where cost and ownership matter.
- BE-SECOPS-007: Monitoring must cover system, JVM, HTTP, ALB, RDS, Redis, MQ, logs, business metrics, severity, and runbook link.
