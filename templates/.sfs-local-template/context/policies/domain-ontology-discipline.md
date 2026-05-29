---
id: sfs-policy-domain-ontology-discipline
summary: Keep domain entities, relationships, and tacit work-process knowledge compiled and reconciled when they change.
load_when:
  - ontology
  - domain ontology
  - entity
  - entity relationship
  - relationship
  - domain knowledge asset
  - ubiquitous language
  - 온톨로지
  - 도메인 지식
status: filled-v1
content_policy: "load when domain entities/relationships or domain-knowledge assets change, or when the ontology / entity-change review lens is active"
---

# Domain Ontology Discipline

The ontology of a product is its entities, the relationships between them, the
invariants that hold across those relationships, and the tacit work-process
knowledge that explains why they exist. Solon already stores these as assets
(`domain-knowledge-assets.md` glossary/playbook/fixture/wiki TopicHub, the
DDD/TDD knowledge pack aggregates/events/invariants, and the `llm-wiki/ddd/`
context map). This pack keeps that surface from drifting silently when the
domain language or its relationships change.

This pack is not a new lifecycle command. It is the discipline behind the
`ontology` review lens and loads through `review-lens-routing.md`.

## When this applies

Apply when work creates, renames, removes, or re-relates a domain entity, or
when it edits `domain-knowledge-assets`, `llm-wiki/ddd/`, glossary, or
ubiquitous-language assets. Small wording fixes that do not change meaning do
not need the full checklist.

## Entity-Change Checklist

- New or renamed entity follows the project ubiquitous language and the
  glossary. New term is added to the glossary, not invented ad hoc.
- Each entity's relationships (owns, references, is-part-of, depends-on) are
  stated explicitly, not left implicit across scattered playbooks or fixtures.
- A renamed or removed entity/relationship records backward-compatibility:
  migration, alias, deprecation note, or an explicit user-approved break.
- A changed relationship that carries an invariant has a test or bounded proof
  for that invariant, or an explicit N/A waiver.
- Tacit work-process knowledge behind the change (why the relationship exists,
  who owns it, known gaps) is captured as an asset with owner and confidence,
  not lost in chat.

## Reconciliation Gate

When domain language or a relationship changes, the change is incomplete until
the dependent surfaces are reconciled in the same unit of work:

- `domain-knowledge-assets` entries that name the entity.
- `llm-wiki/ddd/` context map links.
- Tests or fixtures that encode the old name or relationship.

Treat an entity/relationship change that updates only one of these surfaces as
a review finding, not a complete change. If reconciliation is deferred, record
it as an explicit follow-up with owner, not as silent drift.
