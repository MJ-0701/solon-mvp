---
id: sfs-policy-taxonomy-knowledge-pack-ko
summary: 용어체계(Taxonomy) 지식 항목 인벤토리(한글 버전).
language: ko
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

이 파일은 taxonomy/domain-language 작업을 위한 compact filled guidance pack 이다.
sprint, review, release 에서 naming, state, event, role, glossary, compatibility
check 중 무엇이 활성화되는지 판단하고 matching id 만 적용한다.

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

- glossary entry 는 canonical term, definition, examples, non-examples,
  forbidden aliases, owner, source, affected artifacts 를 포함한다.
- canonical term 은 해당 concept 이 등장하는 plan, AC, code identifier, test,
  docs, UI label, log, metric, release note 에서 일관되어야 한다.
- user-facing copy 는 internal name 보다 친절할 수 있지만, 두 번째 concept boundary 를 만들면 안 된다.

### TAX-FILL-STATE - States, Events, And Commands

- state name 은 durable domain condition 을 설명해야 한다. UI mood 나 임시 implementation step 이 아니다.
- event 는 이미 일어난 fact 를, command 는 요청된 action 을 이름 붙인다.
  둘을 섞으면 retry, audit, replay 의미가 흐려진다.
- business state 가 중요하면 state transition 은 allowed from/to matrix,
  terminal state, invalid transition, actor/source, audit rule 을 가진다.

### TAX-FILL-CONTRACT - API, DB, UI, Log Alignment

- public API field, DB column, UI label, log, metric, docs 는 naming style 이 달라도
  같은 concept boundary 를 써야 한다.
- enum expansion 은 unknown-value handling, backward compatibility,
  display fallback, partner/client expectation 을 정한다.
- error code 는 domain meaning 을 바꾸지 않고 user/operator message 로 mapping 되어야 한다.

### TAX-FILL-RENAME - Rename And Migration

- rename 은 affected artifacts, alias, migration path, compatibility window,
  search evidence, user-facing impact 가 알려졌을 때 안전하다.
- internal-only rename 도 AI agent 나 automation 이 term 을 소비하면 test/docs/log check 가 필요하다.
- external rename 은 deprecation timeline, old/new mapping, support note,
  rollback 또는 compatibility alias 가 필요하다.

### TAX-FILL-BILINGUAL - Korean/English Policy

- artifact type 별 canonical internal language 를 하나 정한다. mixed label 은 target
  user 의 ambiguity 를 줄일 때만 허용한다.
- Korean/English variant 는 literal word order 가 아니라 concept boundary 를 보존해야 한다.
- Korean user phrase 와 internal English term 이 다르면 mapping 을 기록하고 prompt,
  docs, UX copy 에서 재사용한다.

## TAX-REVIEW - Review Questions

- canonical term 은 무엇이고 forbidden alias 는 무엇인가?
- state/event/command 가 서로 다른 concept type 으로 분명히 구분되는가?
- API, DB, UI, log, docs 를 예측 가능한 term 으로 검색할 수 있는가?
- enum/state evolution 이 backward compatible 한가?
- bilingual term 이 직역이 아니라 의미 기준으로 mapping 되는가?

## TAX-EVIDENCE - Suggested Evidence

- glossary entry 또는 terminology table.
- state transition matrix 또는 event/command naming list.
- old/new term migration 에 대한 `rg` evidence.
- API/DB/UI/log/docs alignment spot-check.
- 필요 시 partner 또는 Korean/English vocabulary mapping.

## TAX-GAP - Deepening Slots

- TAX-GAP-001: Glossary entry template.
- TAX-GAP-002: State/event naming conventions.
- TAX-GAP-003: API/DB/UI/log naming alignment checklist.
- TAX-GAP-004: Rename/migration/deprecation playbook.
- TAX-GAP-005: Partner vocabulary mapping template.
- TAX-GAP-006: Enum compatibility and unknown-value policy.
- TAX-GAP-007: AI prompt terminology guardrails.
- TAX-GAP-008: Bilingual Korean/English naming convention guide.
