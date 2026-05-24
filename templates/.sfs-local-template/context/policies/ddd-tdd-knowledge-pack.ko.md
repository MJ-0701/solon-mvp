---
id: sfs-policy-ddd-tdd-knowledge-pack-ko
summary: 제품 수준 scaffold, plan, implement, review 에 적용하는 DDD/TDD 기본선.
language: ko
load_when:
  - DDD
  - TDD
  - domain model
  - test-first
  - aggregate
  - value object
  - product behavior
  - acceptance criteria
  - layered architecture
status: filled-v1
content_policy: "backend 전용 ceremony 가 아니라 제품 수준에 가볍게 적용하는 기본선"
---

# DDD/TDD Knowledge Pack

이 pack 은 DDD-lite 와 TDD-lite 를 제품 수준 실행 규칙으로 만든다. 프로젝트 구조를
만들거나, product behavior 를 바꾸거나, 도메인 용어와 AC 를 실행 가능한 증거로
검증해야 할 때 활성화한다. backend package layout 은 이 pack 의 적용 사례일 뿐,
scope 자체가 backend 로 제한되지 않는다.

## Activation Rules

- 새 product/app/backend scaffold 는 명시적인 product/domain behavior boundary 를
  기본값으로 둔다.
- product behavior 변경은 backend, frontend, CLI, data, docs, workflow,
  integration 중 무엇이든 구현 전에 TDD-lite 를 활성화한다.
- domain state, event, aggregate, role, money, PII, partner state, persisted
  data 는 더 강한 DDD/TDD check 를 활성화한다.
- brainstorm/plan 은 worker handoff 전에 product behavior, domain language,
  첫 evidence 후보를 이름 붙여야 한다.
- throwaway spike 는 full TDD 를 했다고 꾸미지 말고 waiver, 최소 smoke
  evidence, 후속 guard 를 기록한다.

## DDD Floor

- plan, code, test, UI, log, docs, review evidence 에 canonical domain
  language 를 일관되게 쓴다.
- DDD 는 먼저 product modeling discipline 이다. actor, behavior, state,
  rule, invariant, ownership 을 backend folder 보다 먼저 이름 붙인다.
- 기본 backend/app layout 은 clean layered monolith:
  `domain`, `application`, `interfaces`, `infrastructure`.
- `domain` 은 business concept, invariant, aggregate/entity/value-object,
  state transition, domain event 를 소유한다. framework, HTTP, DB, queue,
  vendor adapter 에 의존하지 않는다.
- `application` 은 use case 와 orchestration 을 소유한다. transaction 과
  port 를 조율하지만 domain invariant 를 generic service 이름 뒤에 숨기지 않는다.
- `interfaces` 는 controller, DTO, CLI/UI adapter, request validation,
  presentation mapping 을 소유한다.
- `infrastructure` 는 persistence, external client, queue, clock, file,
  framework-specific adapter 를 소유한다.
- product behavior 를 담는 모든 layer 가 같은 규율을 따른다. UI
  domain/use-case/state model, backend domain/application service, CLI use
  case, migration/backfill policy, docs/workflow policy owner 는 product rule
  을 담을 때 이름이 있어야 한다. UI bootstrap, router, root component,
  hook/store/effect, controller, job, repository, DTO mapper, CLI flag, script,
  migration, docs wording, observability glue, external adapter 같은 broad
  entrypoint 가 policy 의 조용한 집이 되면 안 된다. 예외는 작은 scope
  waiver 로 이유를 남긴다.
- 자연어 SFS/DDD/TDD 요청도 같은 floor 를 켠다. user wording, 최신 handoff/
  docs, active sprint, wiki/DDD map 을 대조한다. stale approved sprint state 는
  증거로 확인된 session intent 를 덮어쓰지 못한다.
- DDD/TDD 작업 중 broad-entrypoint growth 가 product behavior 를 추가하면
  boundary extraction 또는 approved deferral 증거 없이는 review finding 이다.
- core business rule 은 controller, job, repository, external adapter 에
  묻히면 안 된다.
- product rule 은 UI label, docs wording, CLI flag, migration, seed script,
  workflow glue 안에도 조용히 묻히면 안 된다. domain term 과 verification path
  가 있어야 한다.
- bounded context, aggregate boundary, canonical term 이 sprint 이후에도
  살아남으면 `docs/solon/domain-map.md` 를 갱신하거나 그 문서를 가리킨다.

## TDD Floor

- 구현 전에는 domain behavior 를 이름으로 드러내는 failing acceptance,
  regression, characterization test 를 우선 작성한다.
- test-first 가 현실적으로 어렵다면 이유, 최소 alternate smoke evidence,
  빠진 guard 를 debt 또는 follow-up 으로 기록한다.
- unit test 는 domain invariant 와 value behavior 를 증명한다.
- integration/contract test 는 adapter, transaction, persistence, API, event
  semantics 를 증명한다.
- product-level evidence 는 domain unit test, API/contract test, UI flow
  smoke, CLI golden output, migration dry-run, docs assertion, release verifier,
  manual walkthrough 중 가장 작은 정직한 signal 이 될 수 있다.
- test 이름은 구현 branch 가 아니라 domain behavior language 를 강화해야 한다.
- 완료 evidence 는 각 AC 를 test, smoke, manual walkthrough, explicit waiver
  중 하나에 연결해야 한다.

## Review Questions

- 작업이 product-level DDD/TDD, 즉 domain language, behavior boundary,
  evidence-first planning, implementation boundary 를 보존하는가?
- domain invariant 가 controller/repository/DTO mapper/job/external adapter 가
  아니라 domain/use-case logic 에 있는가?
- backend code 가 아닌 artifact 라면 product rule 은 어디에 이름 붙었고 어떻게
  검증되는가?
- broad entrypoint 가 변경됐다면 product behavior 가 UI bootstrap, router,
  root component, hook/store/effect, controller, job, repository, DTO mapper,
  CLI flag, script, migration, docs wording, observability glue, external
  adapter 가 아니라 named domain/use-case/state boundary 에 있는가?
- handoff/user-intent 와 active-sprint 충돌을 구현 계속 전에 감지했는가?
- canonical term, aggregate/entity/value-object/event 이름이 일관적인가?
- code 작성 전 또는 작성과 함께 failing/characterization test 가 있었는가?
- TDD 를 waive 했다면 이유와 alternate evidence 가 명시됐는가?
- 모든 AC 에 변경 artifact 와 연결된 최신 evidence 가 있는가?

## Findings

- 새 product/code scaffold 에 domain 또는 behavior boundary 가 없고 waiver 도
  없으면 partial.
- product behavior 변경에 test-first, characterization, smoke, explicit
  alternate evidence 가 없으면 partial.
- product rule 이 named domain/use-case/state boundary 와 evidence 없이 broad
  entrypoint 에 묻혀 있으면 partial.
- 자연어 SFS가 장식으로만 쓰였거나, handoff/user-intent conflict 가 증거로
  판정 가능한데도 user 에게 되물어졌으면 partial.
- business invariant 가 adapter 에 묻혀 money, PII, data-loss, partner-state
  risk 를 만들면 fail.
