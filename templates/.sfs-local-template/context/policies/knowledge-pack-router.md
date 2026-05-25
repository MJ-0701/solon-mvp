---
id: sfs-policy-knowledge-pack-router
summary: Lightweight activation router for knowledge packs and review lenses.
language: en
load_when: [knowledge pack, backend, strategy-pm, qa, design, infra, management-admin, taxonomy, finance, accounting, bookkeeping, tax, transaction, batch, DDD, TDD, domain model, product behavior, acceptance criteria, integration, API, AWS, Obsidian, llm wiki, wiki, docs migration, enterprise, agent team, performance, algorithm, QA/QC, mainline, focus, data validation, mock, fixture, seed, OWASP, Datadog, console.log, checklist, long context]
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
- Enterprise team signals: `enterprise`, `agent team`, `6 divisions`,
  `sub-agent`, `대기업급`, `team agentic coding`, `QA/QC`, `metrics`.
- Performance/algorithm signals: `performance`, `algorithm`, `optimization`,
  `hot path`, `query plan`, `Core Web Vitals`, `memory`, `concurrency`.
- Mainline focus signals: `mainline`, `focus`, `본론`, `삼천포`, tool/auth/
  model setup, helper setup, or user says the agent missed the real request.
- Data validation signals: `mock`, `fixture`, `seed`, `sample data`,
  migration, backfill, API payload, UI state, persistence, auth/session data.
- Security/logging signals: `OWASP`, security, authz, PII, secrets,
  prompt injection, tool permissions, `console.log`, Datadog, observability.
- Checklist signals: long context, multi-step, repeated product bug, monitor,
  release, user says issues may blur, or work crosses projects/agents.

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
- `policies/enterprise-agent-team-pack.md`
- `policies/enterprise-agent-team-pack.ko.md` (Korean)
- `policies/enterprise-plan-council-pack.md`
- `policies/enterprise-plan-council-pack.ko.md` (Korean)
- `policies/enterprise-evidence-pack.md`
- `policies/enterprise-evidence-pack.ko.md` (Korean)
- `policies/enterprise-performance-review-pack.md`
- `policies/enterprise-performance-review-pack.ko.md` (Korean)
- `policies/mainline-focus-guard.md`
- `policies/mainline-focus-guard.ko.md` (Korean)
- `policies/gate6-data-validation-pack.md`
- `policies/gate6-data-validation-pack.ko.md` (Korean)
- `policies/agentic-security-logging-pack.md`
- `policies/agentic-security-logging-pack.ko.md` (Korean)
- `policies/wiki-mission-checklist-skill.md`
- `policies/wiki-mission-checklist-skill.ko.md` (Korean)

## Depth Rules

- First pass: use router signals plus 1 matching pack.
- Multi-division work: read several packs only when AC or risk evidence touches
  several divisions.
- Do not promote every pack into a blocker. Each pack is a decision aid for
  matching scope, evidence, and review questions.
- For non-trivial product-bearing work, plan should load the enterprise plan
  council pack; review should load enterprise evidence/performance packs only
  when the current risk or AC touches them.
- Tool/model/auth setup is not automatically product work. If setup appears
  while another objective is active, load `mainline-focus-guard.md`, classify
  the setup as mainline/unblocker/deferred_followup/blocked/out_of_scope, and
  return to the main objective as soon as the unblocker is satisfied.
- Gate 6 loads `gate6-data-validation-pack.md` when data, fixture, mock, seed,
  API payload, UI state, migration, auth/session, or persistence behavior
  changes.
- Security/logging/deploy work loads `agentic-security-logging-pack.md` and
  maps relevant findings to OWASP-style families plus logging/Datadog evidence.
- Long-context work loads `wiki-mission-checklist-skill.md`; update checklist
  statuses as evidence is produced, not only at the final summary.
- If a pack suggests a large transition such as MSA, heavy redesign,
  release-readiness escalation, finance/admin process, tax/accounting advisor
  checkpoint, or governance process, surface it as a user or product decision
  instead of silently expanding the task.
