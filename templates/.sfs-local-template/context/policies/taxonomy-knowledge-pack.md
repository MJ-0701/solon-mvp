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
status: filled-v1
content_policy: "compact operating guidance; apply only matching ids and keep taxonomy depth proportional to naming drift risk"
---

# Taxonomy Knowledge Pack Inventory

This file is a compact filled guidance pack for taxonomy/domain-language work.
Use it to decide which naming, state, event, role, glossary, and compatibility
checks are active for a sprint, review, or release. Apply only the matching ids.

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

## TAX-FILL - Operating Guidance

### TAX-FILL-GLOSSARY - Canonical Terms

- A glossary entry should include canonical term, definition, examples,
  non-examples, forbidden aliases, owner, source, and affected artifacts.
- Canonical terms must appear consistently in plan, AC, code identifiers, tests,
  docs, UI labels, logs, metrics, and release notes where the concept appears.
- User-facing copy may be friendlier than internal names, but it must not create
  a second concept boundary.

### TAX-FILL-STATE - States, Events, And Commands

- State names should describe durable domain condition, not UI mood or
  temporary implementation steps.
- Events name facts that already happened. Commands name requested actions.
  Mixing them causes retry, audit, and replay ambiguity.
- State transitions need allowed from/to matrix, terminal states, invalid
  transitions, actor/source, and audit rule when business state matters.

### TAX-FILL-CONTRACT - API, DB, UI, Log Alignment

- Public API fields, DB columns, UI labels, logs, metrics, and docs should use
  the same concept boundary even when naming style differs.
- Enum expansion needs unknown-value handling, backward compatibility, display
  fallback, and partner/client expectations.
- Error codes should map to user/operator messages without changing domain
  meaning.

### TAX-FILL-RENAME - Rename And Migration

- A rename is safe only when affected artifacts, aliases, migration path,
  compatibility window, search evidence, and user-facing impact are known.
- Internal-only rename still needs tests/docs/log checks when AI agents or
  automation consume the term.
- External rename needs deprecation timeline, old/new mapping, support note,
  and rollback or compatibility alias.

### TAX-FILL-BILINGUAL - Korean/English Policy

- Choose one canonical internal language per artifact type. Mixed labels are
  allowed only when they reduce ambiguity for the target user.
- Korean and English variants should preserve concept boundaries, not literal
  word order.
- If a Korean user phrase differs from the internal English term, record the
  mapping and use it in prompts, docs, and UX copy.

## TAX-REVIEW - Review Questions

- Which term is canonical, and which aliases are forbidden?
- Do states/events/commands describe different concept types clearly?
- Can API, DB, UI, logs, and docs be searched with predictable terms?
- Does enum/state evolution remain backward compatible?
- Are bilingual terms mapped by meaning rather than literal translation?

## TAX-EVIDENCE - Suggested Evidence

- Glossary entry or terminology table.
- State transition matrix or event/command naming list.
- `rg` evidence for old/new term migration.
- API/DB/UI/log/docs alignment spot-check.
- Partner or Korean/English vocabulary mapping when applicable.

## TAX-GAP - Deepening Slots

- TAX-GAP-001: Glossary entry template.
- TAX-GAP-002: State/event naming conventions.
- TAX-GAP-003: API/DB/UI/log naming alignment checklist.
- TAX-GAP-004: Rename/migration/deprecation playbook.
- TAX-GAP-005: Partner vocabulary mapping template.
- TAX-GAP-006: Enum compatibility and unknown-value policy.
- TAX-GAP-007: AI prompt terminology guardrails.
- TAX-GAP-008: Bilingual Korean/English naming convention guide.
