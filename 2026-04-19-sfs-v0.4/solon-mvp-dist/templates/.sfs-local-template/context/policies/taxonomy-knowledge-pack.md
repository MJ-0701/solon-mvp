---
id: sfs-policy-taxonomy-knowledge-pack
summary: Taxonomy/domain-language topic and proposition inventory for SFS division activation.
load_when:
  - taxonomy
  - vocabulary
  - naming
  - domain language
  - state
  - event
  - aggregate
  - glossary
status: seed-inventory
content_policy: "topic/proposition only; do not expand into full guidance until a dedicated fill sprint"
---

# Taxonomy Knowledge Pack Inventory

This file is a topic/proposition inventory, not the filled knowledge base.
Use it to decide which taxonomy concepts are active for a sprint, review, or
release. Record ids only unless the user asks for fill work.

## Activation Rules

- Activate taxonomy when names, states, events, roles, entities, API fields,
  UI labels, or docs can drift.
- Taxonomy is lightweight at MVP size but mandatory when multiple agents,
  teams, integrations, or long-lived concepts are involved.
- Renaming is a product and migration decision, not only a wording cleanup.
- Canonical language should travel across plan, code, tests, docs, UI, and logs.

## TAX-SCALE - Review Depth By Project Size

- TAX-SCALE-001: A small feature needs consistent names for the touched concepts.
- TAX-SCALE-002: MVP needs canonical nouns, actors, states, and forbidden aliases.
- TAX-SCALE-003: Production work needs naming stability across API, DB, UI, logs, and docs.
- TAX-SCALE-004: Partner integration needs shared contract vocabulary and enum/state compatibility.
- TAX-SCALE-005: Multi-team work needs glossary ownership and change process.
- TAX-SCALE-006: Schema or enum evolution needs migration and backward-compatibility naming rules.
- TAX-SCALE-007: AI-agent workflows need stable terms so generated artifacts do not diverge silently.

## TAX-PROP - Proposition Inventory

- TAX-PROP-001: Every core domain noun must have one canonical name.
- TAX-PROP-002: Forbidden aliases must be recorded when terms are easily confused.
- TAX-PROP-003: Actors, roles, permissions, and user types must not be conflated.
- TAX-PROP-004: Aggregate, entity, value object, event, command, and view names must reflect domain responsibility.
- TAX-PROP-005: State names require a state machine or transition matrix when transitions matter.
- TAX-PROP-006: Event names should describe facts that happened, not commands to execute.
- TAX-PROP-007: Error codes and user-facing messages must use the same concept boundaries.
- TAX-PROP-008: API fields, DB columns, UI labels, logs, and docs should not invent parallel names.
- TAX-PROP-009: Enum expansion needs unknown-value behavior and compatibility policy.
- TAX-PROP-010: Renames need migration plan, compatibility alias, and deprecation timeline when external consumers exist.
- TAX-PROP-011: Glossary entries need definition, examples, non-examples, owner, and source.
- TAX-PROP-012: Ambiguous Korean/English mixed naming needs explicit convention.
- TAX-PROP-013: Metrics names must preserve the same domain units and lifecycle semantics.
- TAX-PROP-014: Test names should reinforce the canonical behavior language.
- TAX-PROP-015: Decision records should link terminology changes to affected artifacts.
- TAX-PROP-016: AI prompts should name canonical terms and forbid drift-prone synonyms when precision matters.
- TAX-PROP-017: Partner vocabulary mapping needs source term, target term, mapping cardinality, and conflict policy.
- TAX-PROP-018: User-facing copy can be friendlier than internal names but must not change the concept.

## TAX-GAP - Fill Slots For Later

- TAX-GAP-001: Glossary entry template.
- TAX-GAP-002: State/event naming conventions.
- TAX-GAP-003: API/DB/UI/log naming alignment checklist.
- TAX-GAP-004: Rename/migration/deprecation playbook.
- TAX-GAP-005: Partner vocabulary mapping template.
- TAX-GAP-006: Enum compatibility and unknown-value policy.
- TAX-GAP-007: AI prompt terminology guardrails.
- TAX-GAP-008: Bilingual Korean/English naming convention guide.
