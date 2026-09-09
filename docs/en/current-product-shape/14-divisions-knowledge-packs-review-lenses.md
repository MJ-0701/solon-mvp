---
doc_id: sfs-current-product-shape-en-14
title: "Organization Divisions / Knowledge Packs / Review Lenses"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-08-27
parent: docs/en/current-product-shape.md
summary: "Organization Divisions / Knowledge Packs / Review Lenses"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Organization Divisions / Knowledge Packs / Review Lenses

Solon has exactly five organization divisions: `dev`, `strategy-pm`, `qa`,
`design`, and `infra`. It documents those divisions, knowledge packs, and review
lenses as separate surfaces. `.sfs-local/divisions.yaml` retains six activation
slots for compatibility with existing projects, but the `taxonomy` slot is the
foundational cross-cutting product function/lens, not an organization division.
All six are required conceptual council participation roles from brainstorm
through Gate 6. `activation_state` controls read depth and escalation; it does
not decide whether a council role participates.

Current filled guidance is provided through the product-level DDD/TDD, backend,
strategy/PM, QA, design/frontend, infra/DevOps, management-admin, and taxonomy
knowledge packs/review lenses, plus enterprise agent-team packs for non-trivial
product-bearing work. DDD/TDD is a cross-cutting product behavior floor; backend
is one specialization. Enterprise plan council, evidence, and performance packs
make plan a real design phase and make Gate 6 claims measurable.
Mainline focus, Gate 6 data validation, agentic security/logging, and
wiki-mission checklist packs prevent auxiliary setup, mock-only evidence,
OWASP/Datadog gaps, or long-context drift from passing review as if the main
objective were complete.
Post-development external review packs attach Claude Cowork, Gemini, and
GitHub Codex as evidence lanes after implementation, while lean procedure packs
shrink, automate, or remove ceremony when process bottlenecks do not protect
quality.

The user should not need to memorize this list. Solon reads only the lens that
fits the work. A small docs edit stays light. A release, architecture change, or
risky workflow gets stronger questions and evidence checks. The criteria become
richer while the user-facing surface stays simple.

### Review verdict contract

Gate 3/6 verdicts follow enumerated PASS criteria and severity. Only a
`Critical` or `Required` violation of an applicable criterion blocks a verdict;
wording or formatting observations without a criterion are advisories. Consumer
Gate 6 first uses the seven-stage `quality-gate.sh --mode pr|full` evidence, and
a skipped credential scan or unit-test tool fails the gate.
For enterprise-triggered work, each relevant council role records risk flags plus a
finding, evidence path, waiver, or concrete not-applicable reason. Performance
and algorithm PASS requires measurement, bounded proof, or explicit N/A waiver.
Backend is a dev specialization, and management-admin covers finance,
bookkeeping, tax, and accounting. The taxonomy slot remains in the legacy
activation file for compatibility, but product guidance treats taxonomy as the
foundational cross-cutting product function/language-and-classification lens
rather than an org department.

This is also why the six-role council matters in the AI era: it is the default
domain-asset capture loop. Strategy-PM, taxonomy, design, dev, QA, and infra
each notice a different kind of practitioner judgment. When a row exposes a
repeatable rule, edge case, taste call, or operating constraint, the council
records `asset_candidate`: reuse an existing glossary/playbook/review lens/test,
create a new one, or explain why no durable asset should be promoted. The
Council Participation Ledger therefore turns expert know-how into AI-usable product memory
instead of leaving it inside one person's head.

Useful disciplines from the agent-skills benchmark are absorbed
the same way. Official-docs implementation flows through `implement` and the
`source-docs` lens, stop-the-line debugging flows through implementation
verification, deprecation/migration flows through `adopt` and `tidy`, and
shipping checks flow through `release`. SFS strengthens the existing flow
instead of adding more lifecycle commands.
