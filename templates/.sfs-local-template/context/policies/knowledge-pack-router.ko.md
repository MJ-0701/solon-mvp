---
id: sfs-policy-knowledge-pack-router-ko
summary: 분과별 지식팩 라우터(한글 버전), 활성화 조건과 범위를 가볍게 제어.
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
  - integration
  - API
  - AWS
status: filled-v1
content_policy: "read only this router first; read full division packs only when matching signals make them useful"
---

# Division Knowledge Pack Router

division pack 을 열기 전에 이 router 를 먼저 읽는다. 기본 정책은 project size 와
risk 에 맞는 최소 check 만 활성화하는 것이다.
이 범위는 knowledge-pack 문서에 한정되며, 별도 요청이 없는 한 나머지 문서는 변경하지 않습니다.

## Division activation

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

## Read order

1. Read only this file to decide coverage.
2. Read exactly one matching division pack for AC/lens.
3. Read deeper division pack only if the task explicitly asks for detail
   (`deep`, `expand`, `full`, `evidence matrix`, or direct section reference).

## On-demand full-pack mapping

- `policies/backend-knowledge-pack.md`
- `policies/backend-knowledge-pack.ko.md`
- `policies/strategy-pm-knowledge-pack.md`
- `policies/strategy-pm-knowledge-pack.ko.md`
- `policies/qa-knowledge-pack.md`
- `policies/qa-knowledge-pack.ko.md`
- `policies/design-knowledge-pack.md`
- `policies/design-knowledge-pack.ko.md`
- `policies/infra-knowledge-pack.md`
- `policies/infra-knowledge-pack.ko.md`
- `policies/management-admin-knowledge-pack.md`
- `policies/management-admin-knowledge-pack.ko.md`
- `policies/taxonomy-knowledge-pack.md`
- `policies/taxonomy-knowledge-pack.ko.md`

## Depth Rules

- 첫 pass 는 router signal 과 matching pack 1개만 사용한다.
- multi-division work 는 AC 또는 risk evidence 가 여러 division 을 실제로 건드릴 때만 여러 pack 을 읽는다.
- 모든 pack 을 blocker 로 승격하지 않는다. 각 pack 은 matching scope, evidence,
  review question 을 고르는 decision aid 다.
- pack 이 MSA, 대형 redesign, release-readiness escalation, finance/admin process,
  tax/accounting advisor checkpoint, governance process 같은 큰 전환을 제안하면
  조용히 scope 를 넓히지 말고 user/product decision 으로 surface 한다.
