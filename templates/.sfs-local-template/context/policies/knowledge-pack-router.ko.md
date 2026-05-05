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
  - taxonomy
  - transaction
  - batch
  - integration
  - API
  - AWS
status: seed-inventory
content_policy: "topic/proposition only; read only this file first. Read a full division pack only on explicit scope request."
---

# Division Knowledge Pack Router

Use this router before opening long division packs.
Default policy is minimum required checks by project size.
이 범위는 knowledge-pack 문서에 한정되며, 별도 요청이 없는 한 나머지 문서는 변경하지 않습니다.

## Division activation

- Backend signals: `backend`, `JVM`, `Spring`, `JPA`, `transaction`, `batch`,
  `integration`, `DevOps`, `AWS`.
- Strategy/PM signals: `strategy`, `PM`, `roadmap`, `SLA`, `rollout`, `partnership`.
- QA signals: `qa`, `test`, `regression`, `release confidence`, `defect`.
- Design/frontend signals: `design`, `UX`, `UI`, `operator`.
- Infra/DevOps signals: `infra`, `deploy`, `release`, `observability`, `secrets`,
  `cost`.
- Taxonomy signals: `vocabulary`, `naming`, `state`, `event`, `enum`.

## Read order

1. Read only this file to decide coverage.
2. Read exactly one matching division pack for AC/lens.
3. Read deeper division pack only if the task explicitly asks for detail
   (`deep`, `expand`, `full`, `evidence matrix`, or direct section reference).

## On-demand full-pack mapping

- `policies/backend-knowledge-pack.md`
- `policies/strategy-pm-knowledge-pack.md`
- `policies/qa-knowledge-pack.md`
- `policies/design-knowledge-pack.md`
- `policies/infra-knowledge-pack.md`
- `policies/taxonomy-knowledge-pack.md`
