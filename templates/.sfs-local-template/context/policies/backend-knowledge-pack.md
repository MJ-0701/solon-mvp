---
id: sfs-policy-backend-knowledge-pack
summary: Backend/JVM/Spring/transaction/batch/DevOps topic router.
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
status: split-v1
content_policy: "parent router; read split backend packs only when matching signals make them useful"
split_children:
  - backend-knowledge-pack-runtime.md
  - backend-knowledge-pack-transactions.md
  - backend-knowledge-pack-integration.md
  - backend-knowledge-pack-operating.md
---

# Backend Knowledge Pack Inventory

This file is the parent router for backend-heavy work. When backend,
transaction, batch, integration, or DevOps risk appears, use the ids below to
choose the smallest useful split pack. Do not load or apply every section by
default.

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

### GAP - Deepening Slots

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

## Split Backend Packs

Read only the matching child pack after this parent activates backend scope:

- `policies/backend-knowledge-pack-runtime.md` - BE-ARCH, BE-CICD, BE-JVM, BE-JPA, BE-HIKARI.
- `policies/backend-knowledge-pack-transactions.md` - BE-TX, BE-BATCH-TX, BE-EVENT, BE-IDEMP.
- `policies/backend-knowledge-pack-integration.md` - BE-INTEGRATION, BE-HTTP, BE-THREAD, BE-RESILIENCE, BE-CACHE, BE-LOCK, BE-API, BE-DATA, BE-MQ, BE-SECOPS.
- `policies/backend-knowledge-pack-operating.md` - BE-FILL guidance, review questions, evidence, related packs, and future deepening contract.

## Related Official Division Packs

Use these files for the other official SFS divisions. They are also compact
guidance packs and should be loaded through the router.

- `strategy-pm-knowledge-pack.md`
- `taxonomy-knowledge-pack.md`
- `design-knowledge-pack.md`
- `qa-knowledge-pack.md`
- `infra-knowledge-pack.md`
