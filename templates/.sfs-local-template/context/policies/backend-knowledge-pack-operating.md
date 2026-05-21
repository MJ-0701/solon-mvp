---
id: sfs-policy-backend-knowledge-pack-operating
summary: Backend filled operating guidance, review questions, evidence, and deepening contract.
load_when:
  - backend
  - BE-FILL
  - evidence
  - review questions
  - operating guidance
status: split-v1
parent_doc: backend-knowledge-pack.md
split_from_section: "Backend Filled Guidance"
content_policy: "read after backend-knowledge-pack.md and matching proposition ids activate detailed backend operating guidance"
---

# Backend Operating Guidance

Use these checks only when the matching proposition ids are active.

## BE-FILL-ARCH - Architecture Shape

- Start with the runtime the team can actually operate. A clean layered
  monolith is the default until independent deployability, scaling, ownership,
  or compliance pressure proves a stronger boundary is needed.
- Treat CQRS as an application boundary choice, not a database-count choice.
  It is useful when commands, reads, audit, or integration flows have different
  models and failure modes.
- Treat Hexagonal architecture as a boundary-revealing move. It should clarify
  ports, adapters, tests, and domain language; if it only adds folders, it is
  not carrying its weight.
- Treat MSA as an organizational/runtime commitment. Require evidence for
  independent release cadence, team ownership, observability, data ownership,
  failure isolation, and deployment operations.

## BE-FILL-TX - Transaction And State Safety

- Name the transaction owner for each use case. Controller and repository
  methods should not accidentally define business transaction scope.
- Keep external API calls, slow I/O, and uncertain retries outside DB
  transactions unless there is a written reason and a compensation strategy.
- For `REQUIRES_NEW`, write down whether the caller needs a return value, a
  committed side effect, or merely an isolated log/audit action.
- If code re-reads state after a child transaction, review first-level cache,
  flush, clear, refresh, and test boundaries with a real persistence context.
- Quota, balance, settlement, limit, and inventory paths need atomic
  check-effect-record semantics plus boundary tests.

## BE-FILL-BATCH - Batch, Worker, And Replay

- A batch job needs restartability, idempotency, chunk sizing, partial-progress
  policy, and failure classification before it is release-ready.
- Writer side effects should be safe under retry and restart. If the effect is
  external, record the idempotency key and reconciliation path.
- Boundary datasets should cover zero items, one item, exact chunk boundary,
  just before/at/after business limits, duplicates, stale rows, and failed
  downstream calls.
- Job metadata, execution ids, input snapshots, output counts, skip counts,
  and error samples are part of the evidence, not debug noise.

## BE-FILL-INTEGRATION - API, Events, And Partners

- Define Source of Truth for each shared object. Replicas may cache or project,
  but hidden write-master behavior must be explicit or rejected.
- For every partner/API/event boundary, record timeout, retry, idempotency,
  error taxonomy, correlation id, versioning, replay, and support ownership.
- Prefer durable handoff for external propagation: outbox, queue, or archived
  payload plus replay path. JVM-local events alone are not integration.
- Contract drift needs an owner and compatibility policy before production
  exposure.

## BE-FILL-OPS - Runtime And Observability

- Release readiness includes config source, secret handling, health checks,
  logs/metrics/traces, rollback, and runbook coverage for the changed path.
- Connection pools, worker concurrency, scheduled jobs, and blue/green overlap
  must fit the same capacity model.
- Sensitive logs must be masked at source and verified in failure paths.
- For AWS/cloud work, review IAM, network exposure, secret storage, cost,
  backups, and alert ownership only when the runtime surface is actually in
  scope.

## Backend Review Questions

- What can be safely retried, and what must be compensated or reconciled?
- Which transaction owns the business invariant?
- Which state is authoritative when systems disagree?
- What evidence proves the failure mode, not only the happy path?
- Which operations can wake someone up, and who owns the runbook?

## Backend Evidence

- AC id to test/smoke/manual verification mapping.
- Transaction/integration sequence for high-risk flows.
- State transition matrix or append-only history sample.
- DB migration/backfill dry-run and rollback note when data changes.
- Logs/metrics/alerts/runbook links for production or release tooling.

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
