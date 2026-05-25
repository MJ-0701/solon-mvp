---
id: sfs-policy-enterprise-performance-review-pack-ko
summary: 성능과 알고리즘 검토를 측정 또는 bounded proof 로 잠그는 review lens.
language: ko
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
parent_doc: enterprise-agent-team-pack.ko.md
content_policy: "runtime cost 에 영향 줄 수 있는 implement/review 에서 로드"
---

# Enterprise Performance Review Pack

Gate 6 lens 이자 위험한 plan 의 설계 체크다. LLM reasoning 은 위험 식별에는
쓸 수 있지만 performance PASS 는 측정, bounded input 분석, 또는 N/A waiver 가
필요하다.

## Trigger

다음이 바뀌면 로드한다.

- algorithm, loop, parser, search, sort, ranking, scoring, batch logic
- DB query, ORM relation, pagination, transaction, lock, index
- network, cache, storage, upload/download, serialization, payload size
- browser boot, route, bundle, render loop, canvas, animation, asset loading
- concurrency, retry, idempotency, rate limit, worker, queue, backpressure

## 필수 질문

- hot path 와 예상 input bound 는 무엇인가?
- complexity class 와 degrade 지점은 어디인가?
- N+1, unbounded memory, repeated DOM/layout, payload amplification 이 있는가?
- 병목은 CPU/IO/DB/network/render/memory/lock wait 중 무엇인가?
- 어떤 measurement 또는 smoke 가 regression 없음을 증명하는가?

## Surface 별 evidence

- Algorithm: boundary size unit/property test, benchmark, 또는 input bound 가
  명시된 complexity proof
- Database: `EXPLAIN`/query log, index check, pagination/limit proof, dry-run
- Web UI: build/bundle output, browser smoke, console check, Core Web Vitals
  또는 local trace
- Backend/API: load-shaped smoke, timing log, response size, streaming/backpressure
  evidence, timeout/error budget check
- Infra/batch: job duration, retry/idempotency, queue depth/backoff, rollback

## PASS/Partial

- PASS: risk 에 맞는 measurement 또는 bounded proof 와 residual risk 기록
- Partial: hot path 가 있는데 text reasoning 만 있음
- Fail: unbounded work, concurrency/data-loss risk, 사용자 체감 regression 을
  mitigation 없이 도입

## Optimization 경계

무작정 최적화하지 않는다. 측정, scale bound, 사용자 체감 위험이 있을 때만
복잡도를 받아들인다. 유지보수성을 해치는 과한 최적화는 기각 사유를 남긴다.
