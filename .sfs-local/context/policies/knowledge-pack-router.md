---
id: sfs-policy-knowledge-pack-router
summary: Lightweight activation router for all division knowledge packs.
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
