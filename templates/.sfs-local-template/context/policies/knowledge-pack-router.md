---
id: sfs-policy-knowledge-pack-router
summary: Lightweight activation router for knowledge packs and review lenses.
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
  - DDD
  - TDD
  - domain model
  - product behavior
  - acceptance criteria
  - integration
  - API
  - AWS
  - Obsidian
  - llm wiki
  - wiki
  - docs migration
status: filled-v1
content_policy: "read only this router first; read full packs only when matching signals make them useful"
---

# Knowledge Pack / Review Lens Router

Use this router before opening knowledge packs. Default policy is minimum
required checks by project size and risk. This router is not the same surface as
`.sfs-local/divisions.yaml`: that file is a six-slot compatibility activation
state, while this router covers the current guidance packs and review lenses.
This scope is limited to knowledge-pack documents; other documentation is unchanged unless explicitly requested.
The six core divisions are an always-on Division sub-agent council across
brainstorm, plan, implement, and review. activation_state controls read-depth
and escalation, not whether strategy-pm/dev/QA/design/infra/taxonomy participate.

If Korean is requested, read `knowledge-pack-router.ko.md` first.

## Lens activation

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
- DDD/TDD signals: `DDD`, `TDD`, `domain model`, `product behavior`,
  `acceptance criteria`, `aggregate`, `value object`, `test-first`, `failing
  test`, `red-green`.
- Obsidian/wiki signals: `Obsidian`, `llm-wiki`, `knowledge base`, `docs
  migration`, `existing project`, `new project`, `sprint continuity`.

## Read order

1. Read only this file to decide coverage.
2. Read the matching parent pack for AC/lens.
3. For split packs, read only the child file named by the parent and matching
   the active ids.
4. Read deeper pack only if the task explicitly asks for detail
   (`deep`, `expand`, `full`, `evidence matrix`, or direct section reference).

## On-demand full-pack mapping

- `policies/backend-knowledge-pack.md`
- `policies/backend-knowledge-pack-runtime.md`
- `policies/backend-knowledge-pack-transactions.md`
- `policies/backend-knowledge-pack-integration.md`
- `policies/backend-knowledge-pack-operating.md`
- `policies/backend-knowledge-pack.ko.md` (Korean)
- `policies/backend-knowledge-pack-runtime.ko.md` (Korean)
- `policies/backend-knowledge-pack-transactions.ko.md` (Korean)
- `policies/backend-knowledge-pack-integration.ko.md` (Korean)
- `policies/backend-knowledge-pack-operating.ko.md` (Korean)
- `policies/strategy-pm-knowledge-pack.md`
- `policies/strategy-pm-knowledge-pack.ko.md` (Korean)
- `policies/qa-knowledge-pack.md`
- `policies/qa-knowledge-pack.ko.md` (Korean)
- `policies/design-knowledge-pack.md`
- `policies/design-knowledge-pack-operating.md`
- `policies/design-knowledge-pack.ko.md` (Korean)
- `policies/design-knowledge-pack-operating.ko.md` (Korean)
- `policies/infra-knowledge-pack.md`
- `policies/infra-knowledge-pack.ko.md` (Korean)
- `policies/management-admin-knowledge-pack.md`
- `policies/management-admin-knowledge-pack.ko.md` (Korean)
- `policies/taxonomy-knowledge-pack.md`
- `policies/taxonomy-knowledge-pack.ko.md` (Korean)
- `policies/ddd-tdd-knowledge-pack.md`
- `policies/ddd-tdd-knowledge-pack.ko.md` (Korean)
- `policies/obsidian-llm-wiki.md`
- `policies/obsidian-llm-wiki.ko.md` (Korean)

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
