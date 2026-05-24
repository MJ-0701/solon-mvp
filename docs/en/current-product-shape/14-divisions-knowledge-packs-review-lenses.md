---
doc_id: sfs-current-product-shape-en-14
title: "Divisions / Knowledge Packs / Review Lenses"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-25
parent: docs/en/current-product-shape.md
summary: "Divisions / Knowledge Packs / Review Lenses"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Divisions / Knowledge Packs / Review Lenses

Current Solon documents divisions, knowledge packs, and review lenses as
separate surfaces. `.sfs-local/divisions.yaml` is the six core activation slots
for compatibility with existing projects: `dev`, `strategy-pm`, `qa`, `design`,
`infra`, and `taxonomy`. It is runtime activation state, not the full
knowledge-pack/review-lens registry.
However, the six core divisions participate as an always-on conceptual
sub-agent council from brainstorm through Gate 6. `activation_state` controls
read depth and escalation; it does not decide whether a division participates.

Current filled guidance is provided through the product-level DDD/TDD, backend,
strategy/PM, QA, design/frontend, infra/DevOps, management-admin, and taxonomy
knowledge packs/review lenses. DDD/TDD is a cross-cutting product behavior
floor; backend is one specialization. Each pack gives Solon a compact sense of
what to watch, what to ask, and what evidence should count for that kind of
work.

The user should not need to memorize this list. Solon reads only the lens that
fits the work. A small docs edit stays light. A release, architecture change, or
risky workflow gets stronger questions and evidence checks. The criteria become
richer while the user-facing surface stays simple.
Backend is a dev specialization, and management-admin covers finance,
bookkeeping, tax, and accounting. The taxonomy slot remains in the legacy
activation file for compatibility, but product guidance treats taxonomy as a
cross-cutting language/classification lens rather than an org department.

Useful disciplines from the agent-skills benchmark are absorbed
the same way. Official-docs implementation flows through `implement` and the
`source-docs` lens, stop-the-line debugging flows through implementation
verification, deprecation/migration flows through `adopt` and `tidy`, and
shipping checks flow through `release`. SFS strengthens the existing flow
instead of adding more lifecycle commands.
