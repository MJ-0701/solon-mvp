---
id: sfs-policy-knowledge-pack-router-ko
summary: 지식팩/review lens 라우터(한글 버전), 활성화 조건과 범위를 가볍게 제어.
language: ko
load_when:
  - knowledge pack
  - backend
  - strategy-pm
  - qa
  - design
  - infra
  - management-admin
  - taxonomy
  - finance
  - accounting
  - bookkeeping
  - tax
  - 경영관리
  - 재무
  - 경리
  - 세무
  - 회계
  - transaction
  - batch
  - DDD
  - TDD
  - domain model
  - product behavior
  - acceptance criteria
  - integration
  - API
  - AWS
  - Obsidian
  - 옵시디언
  - llm wiki
  - 위키
  - 문서 이관
status: filled-v1
content_policy: "read only this router first; read full packs only when matching signals make them useful"
---

# Knowledge Pack / Review Lens Router

knowledge pack 을 열기 전에 이 router 를 먼저 읽는다. 기본 정책은 project size 와
risk 에 맞는 최소 check 만 활성화하는 것이다. 이 router 는 `.sfs-local/divisions.yaml` 과
같은 표면이 아니다. `divisions.yaml` 은 6개 core activation slot 을 위한 호환성 설정이고,
이 router 는 현재 guidance pack 과 review lens 를 고른다.
이 범위는 knowledge-pack 문서에 한정되며, 별도 요청이 없는 한 나머지 문서는 변경하지 않습니다.
6개 core division 은 brainstorm, plan, implement, review 전 단계의 always-on
Division sub-agent council 이다. `activation_state` 는 read-depth 와 escalation
을 조절할 뿐, strategy-pm/dev/QA/design/infra/taxonomy 참여 여부가 아니다.

## Lens activation

- Backend signals: `backend`, `JVM`, `Spring`, `JPA`, `transaction`, `batch`,
  `integration`, `DevOps`, `AWS`.
- Strategy/PM signals: `strategy`, `PM`, `roadmap`, `SLA`, `rollout`, `partnership`.
- QA signals: `qa`, `test`, `regression`, `release confidence`, `defect`.
- Design/frontend signals: `design`, `UX`, `UI`, `operator`.
- Infra/DevOps signals: `infra`, `deploy`, `release`, `observability`, `secrets`,
  `cost`.
- Management/admin signals: `management-admin`, `finance`, `accounting`,
  `bookkeeping`, `tax`, `invoice`, `cashflow`, `payroll`, `compliance`,
  `경영관리`, `재무`, `경리`, `세무`, `회계`.
- Taxonomy signals: `vocabulary`, `naming`, `state`, `event`, `enum`.
- DDD/TDD signals: `DDD`, `TDD`, `domain model`, `product behavior`,
  `acceptance criteria`, `aggregate`, `value object`, `test-first`, `failing
  test`, `red-green`.
- Obsidian/wiki signals: `Obsidian`, `옵시디언`, `llm-wiki`, `위키`,
  `knowledge base`, `문서 이관`, `existing project`, `new project`,
  `sprint continuity`.

## Read order

1. Read only this file to decide coverage.
2. AC/lens 에 맞는 parent pack 을 읽는다.
3. Split pack 은 parent 가 지정한 child 중 active ids 와 matching 되는 파일만 읽는다.
4. Read deeper pack only if the task explicitly asks for detail
   (`deep`, `expand`, `full`, `evidence matrix`, or direct section reference).

## On-demand full-pack mapping

- `policies/backend-knowledge-pack.md`
- `policies/backend-knowledge-pack.ko.md`
- `policies/backend-knowledge-pack-runtime.md`
- `policies/backend-knowledge-pack-runtime.ko.md`
- `policies/backend-knowledge-pack-transactions.md`
- `policies/backend-knowledge-pack-transactions.ko.md`
- `policies/backend-knowledge-pack-integration.md`
- `policies/backend-knowledge-pack-integration.ko.md`
- `policies/backend-knowledge-pack-operating.md`
- `policies/backend-knowledge-pack-operating.ko.md`
- `policies/strategy-pm-knowledge-pack.md`
- `policies/strategy-pm-knowledge-pack.ko.md`
- `policies/qa-knowledge-pack.md`
- `policies/qa-knowledge-pack.ko.md`
- `policies/design-knowledge-pack.md`
- `policies/design-knowledge-pack.ko.md`
- `policies/design-knowledge-pack-operating.md`
- `policies/design-knowledge-pack-operating.ko.md`
- `policies/infra-knowledge-pack.md`
- `policies/infra-knowledge-pack.ko.md`
- `policies/management-admin-knowledge-pack.md`
- `policies/management-admin-knowledge-pack.ko.md`
- `policies/taxonomy-knowledge-pack.md`
- `policies/taxonomy-knowledge-pack.ko.md`
- `policies/ddd-tdd-knowledge-pack.md`
- `policies/ddd-tdd-knowledge-pack.ko.md`
- `policies/obsidian-llm-wiki.md`
- `policies/obsidian-llm-wiki.ko.md`

## Depth Rules

- 첫 pass 는 router signal 과 matching pack 1개만 사용한다.
- multi-division work 는 AC 또는 risk evidence 가 여러 division 을 실제로 건드릴 때만 여러 pack 을 읽는다.
- 모든 pack 을 blocker 로 승격하지 않는다. 각 pack 은 matching scope, evidence,
  review question 을 고르는 decision aid 다.
- pack 이 MSA, 대형 redesign, release-readiness escalation, finance/admin process,
  tax/accounting advisor checkpoint, governance process 같은 큰 전환을 제안하면
  조용히 scope 를 넓히지 말고 user/product decision 으로 surface 한다.
