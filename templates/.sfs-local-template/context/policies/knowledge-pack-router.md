---
id: sfs-policy-knowledge-pack-router
summary: Lightweight activation router for all division knowledge packs.
language: en
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
  - transaction
  - batch
  - integration
  - API
  - AWS
status: filled-v1
content_policy: "read only this router first; read full division packs only when matching signals make them useful"
---

# Division Knowledge Pack Router

Use this router before opening division packs. Default policy is minimum
required checks by project size and risk.
This scope is limited to knowledge-pack documents; other documentation is unchanged unless explicitly requested.

If Korean is requested, read `knowledge-pack-router.ko.md` first.

## Division activation

- Backend signals: `backend`, `JVM`, `Spring`, `JPA`, `transaction`, `batch`,
  `integration`, `DevOps`, `AWS`.
- Strategy/PM signals: `strategy`, `PM`, `roadmap`, `SLA`, `rollout`, `partnership`.
- QA signals: `qa`, `test`, `regression`, `release confidence`, `defect`.
- Design/frontend signals: `design`, `UX`, `UI`, `operator`.
- Infra/DevOps signals: `infra`, `deploy`, `release`, `observability`, `secrets`,
  `cost`.
- Management/admin signals: `management-admin`, `finance`, `accounting`,
  `bookkeeping`, `tax`, `invoice`, `cashflow`, `payroll`, `compliance`.
- Taxonomy signals: `vocabulary`, `naming`, `state`, `event`, `enum`.

## Read order

1. Read only this file to decide coverage.
2. Read exactly one matching division pack for AC/lens.
3. Read deeper division pack only if the task explicitly asks for detail
   (`deep`, `expand`, `full`, `evidence matrix`, or direct section reference).

## On-demand full-pack mapping

- `policies/backend-knowledge-pack.md`
- `policies/backend-knowledge-pack.ko.md` (Korean)
- `policies/strategy-pm-knowledge-pack.md`
- `policies/strategy-pm-knowledge-pack.ko.md` (Korean)
- `policies/qa-knowledge-pack.md`
- `policies/qa-knowledge-pack.ko.md` (Korean)
- `policies/design-knowledge-pack.md`
- `policies/design-knowledge-pack.ko.md` (Korean)
- `policies/infra-knowledge-pack.md`
- `policies/infra-knowledge-pack.ko.md` (Korean)
- `policies/management-admin-knowledge-pack.md`
- `policies/management-admin-knowledge-pack.ko.md` (Korean)
- `policies/taxonomy-knowledge-pack.md`
- `policies/taxonomy-knowledge-pack.ko.md` (Korean)

## Depth Rules

- First pass: use router signals plus 1 matching pack.
- Multi-division work: read several packs only when AC or risk evidence touches
  several divisions.
- Do not promote every pack into a blocker. Each pack is a decision aid for
  matching scope, evidence, and review questions.
- If a pack suggests a large transition such as MSA, heavy redesign,
  release-readiness escalation, finance/admin process, tax/accounting advisor
  checkpoint, or governance process, surface it as a user or product decision
  instead of silently expanding the task.
