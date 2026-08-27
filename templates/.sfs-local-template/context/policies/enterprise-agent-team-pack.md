---
id: sfs-policy-enterprise-agent-team-pack
summary: Enterprise six-role council operating pack for SFS planning and review.
load_when:
  - enterprise
  - agent team
  - 6 divisions
  - sub-agent
  - plan council
  - large project
status: filled-v1
content_policy: "parent pack; load child packs only for active triggers"
split_children:
  - enterprise-plan-council-pack.md
  - enterprise-evidence-pack.md
  - enterprise-performance-review-pack.md
  - postdev-external-review-pack.md
  - lean-procedure-refactor-pack.md
---

# Enterprise Agent Team Pack

This pack upgrades SFS from decorative role labels to a working agent-team
contract. It applies to any product-bearing work, not only frontend or backend.

## Principles

- There are five organization divisions: strategy-pm, dev, QA, design, and infra.
  Taxonomy is the cross-cutting product function/lens. All six are required council roles
  and conceptual sub-agents from brainstorm through Gate 6.
- The six council roles are also the default domain-asset loop: each role turns
  its expert judgment into reusable terms, playbooks, checks, fixtures, review
  questions, wiki maps, or skill/knowledge-pack material.
- Plan is a design phase, not a post-brainstorm contract stamp. The team must
  expose risks, missing evidence, and files/artifact boundaries before coding.
- Load context just in time. Every council role participates, but deep packs
  load only when AC, risk, or artifact scope touches that role.
- Prefer execution evidence over paper evidence. A checklist without a command,
  artifact, diff, test, trace, screenshot, or explicit waiver is not enough.
- Optimize for modern product teams: small slices, trunk-friendly commits,
  observable rollouts, stable domain language, and fast feedback.
- Optimize the process too: when a gate becomes ceremony, keep the invariant
  but shrink, automate, or remove the visible step.

## Enterprise Sources Absorbed

- DORA metrics: lead time, deployment frequency, change failure rate, failed
  deployment recovery time.
- Google SRE: SLO/error-budget thinking, useful monitoring, incident learning.
- AWS Well-Architected: operational excellence, security, reliability,
  performance efficiency, cost awareness.
- OWASP ASVS: authentication, session, access-control, validation, secrets.
- WCAG/Core Web Vitals: accessibility and user-visible performance.
- Google engineering practice: small CLs, readability, maintainability,
  reviewer responsibility.

## Prune List

Do not import heavyweight or stale rituals as universal blockers:

- SAFe-style ceremony, CAB gates, big-design-up-front, hand-written trace
  matrices without evidence, manual QA as the only safety net.
- Mandatory mutation-test thresholds, PR/FAQ docs, RFCs, ADRs, or architecture
  diagrams for every small change.
- Strict DDD for stateless utilities, glue code, or adapters when a named
  boundary plus evidence is enough.
- Global "read every pack" behavior. It causes context pollution and shallow
  compliance.

## Child Pack Routing

- Load `enterprise-plan-council-pack.md` during Gate 3 plan creation/rework for
  non-trivial product-bearing work.
- Load `enterprise-evidence-pack.md` when acceptance, QA/QC, release, monitor,
  wiki evidence, or applied project behavior is in scope.
- Load `enterprise-performance-review-pack.md` when code, queries, UI runtime,
  batch, network, storage, algorithm, bundle, memory, or concurrency changes.
- Load `postdev-external-review-pack.md` after implementation for optional
  Claude Cowork/Gemini/Codex evidence.
- Load `lean-procedure-refactor-pack.md` when process itself becomes a bottleneck.

## Council Role Asset Duties

- strategy-pm captures market/user/business judgment as prioritization, rollout,
  and decision-boundary assets.
- taxonomy captures language judgment as canonical terms, aliases, states,
  events, and classification assets.
- design captures craft judgment as workflow, interaction, copy, accessibility,
  and visual-review assets.
- dev captures engineering judgment as boundaries, contracts, fixtures, and
  implementation checks.
- QA captures risk judgment as edge cases, regression checks, and acceptance
  evidence assets.
- infra captures operating judgment as deploy, observability, rollback, cost,
  and security runbook assets.

## PASS Shape

An enterprise PASS means:

- each relevant council role has a finding, evidence path, or explicit waiver;
- each relevant council role has an `asset_candidate` or a concrete reason it is not
  creating/reusing one;
- AC maps to files/artifacts and a verification signal;
- hot paths have measured or bounded performance evidence;
- project-applied QA/QC is recorded when the change is harness/product policy;
- user escalation is reserved for real product judgment, not runnable chores.
