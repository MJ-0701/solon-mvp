---
id: sfs-policy-enterprise-performance-review-pack
summary: Performance and algorithm review lens requiring measurement or explicit bounded reasoning.
load_when:
  - performance
  - algorithm
  - optimization
  - hot path
  - query plan
  - Core Web Vitals
  - memory
  - concurrency
status: filled-v1
parent_doc: enterprise-agent-team-pack.md
content_policy: "load during implement/review when changed behavior can affect runtime cost"
---

# Enterprise Performance Review Pack

Use this as a Gate 6 lens and as a design check for risky plans. LLM reasoning
can identify risks, but performance PASS needs a measurement, bounded input
analysis, or explicit N/A waiver.

## Trigger Map

Load this pack when a slice changes:

- algorithm, loop, parser, search, sort, ranking, scoring, or batch logic;
- database query, ORM relation, pagination, transaction, lock, or index usage;
- network, cache, storage, file upload/download, serialization, or payload size;
- browser boot, route, bundle, render loop, canvas, animation, or asset loading;
- concurrency, retry, idempotency, rate limit, worker, queue, or backpressure.

## Required Review Questions

- What is the hot path and expected input bound?
- What is the complexity class, and where can it degrade?
- Is there N+1, unbounded memory growth, repeated DOM/layout work, or payload
  amplification?
- Is the bottleneck CPU, IO, database, network, render, memory, or lock wait?
- Which measurement or smoke proves no unacceptable regression?

## Evidence By Surface

- Algorithm: unit/property test for boundary sizes, benchmark, or complexity
  proof with explicit input bounds.
- Database: `EXPLAIN`/query log, index check, pagination/limit proof, or dry-run
  query evidence.
- Web UI: build/bundle output, browser smoke, console check, Core Web Vitals or
  equivalent local trace when user-visible latency is likely.
- Backend/API: load-shaped smoke, timing log, response size, streaming/backpressure
  evidence, or timeout/error budget check.
- Infra/batch: job duration, retry/idempotency proof, queue depth/backoff, or
  rollback/circuit-breaker evidence.

## PASS/Partial Rule

- PASS: measurement or bounded proof matches the risk, and residual risk is
  recorded.
- Partial: hot path exists but only text reasoning is provided.
- Fail: change introduces obvious unbounded work, data-loss/concurrency risk, or
  user-visible regression with no mitigation.

## Optimization Boundary

Do not optimize blindly. Prefer the simplest code unless measurement, scale
bound, or user-visible risk justifies complexity. Record the rejected heavier
optimization when it would reduce maintainability without evidence.
