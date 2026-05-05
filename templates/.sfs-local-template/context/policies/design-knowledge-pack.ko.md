---
id: sfs-policy-design-knowledge-pack-ko
summary: 디자인/프론트 지식 항목 인벤토리(한글 버전).
language: ko
load_when:
  - design
  - frontend
  - UX
  - UI
  - accessibility
  - responsive
  - design system
  - operator screen
status: filled-v1
content_policy: "compact operating guidance; apply only matching ids and keep design depth proportional to visible workflow risk"
---

# Design/Frontend Knowledge Pack Inventory

이 파일은 design/frontend 작업을 위한 compact filled guidance pack 이다. sprint,
review, release 에서 workflow, layout, state, accessibility, copy check 중 무엇이
활성화되는지 판단하고 matching id 만 적용한다.

## Activation Rules

- Activate design depth when users, operators, admins, or reviewers interact
  with a visible workflow.
- Do not make a marketing landing page when the work is an operational tool.
- Data-dense product surfaces need scanning, hierarchy, states, and task flow,
  not decorative composition.
- Accessibility and responsive fit are active whenever UI is user-facing.

## DES-SCALE - Review Depth By Project Size

- DES-SCALE-001: A prototype needs a clear primary task and obvious controls.
- DES-SCALE-002: MVP UI needs core flow, empty/loading/error/success states, and responsive fit.
- DES-SCALE-003: Production UI needs accessibility, consistency, copy quality, and failure recovery.
- DES-SCALE-004: Admin/operator UI needs audit trail, filters, timeline, permissions, and destructive-action safeguards.
- DES-SCALE-005: Multi-screen products need information architecture, navigation, and state continuity.
- DES-SCALE-006: Design-system work needs tokens, components, variants, usage rules, and migration plan.
- DES-SCALE-007: Brand/marketing work needs first-viewport signal, real assets, and conversion/action clarity.

## DES-PROP - Proposition Inventory

- DES-PROP-001: The primary user task must be visible without reading documentation.
- DES-PROP-002: UI hierarchy must support scanning, comparison, and repeated action for operational tools.
- DES-PROP-003: Empty, loading, error, disabled, partial, and success states are part of the design.
- DES-PROP-004: Controls should use familiar affordances such as icons, toggles, menus, tabs, sliders, and inputs.
- DES-PROP-005: Text must fit its container across mobile and desktop viewports.
- DES-PROP-006: Responsive layout needs stable constraints, not viewport-scaled typography.
- DES-PROP-007: Accessibility review includes keyboard, focus, contrast, labels, and motion tolerance.
- DES-PROP-008: Visual assets should reveal the actual product, state, place, or workflow when inspection matters.
- DES-PROP-009: Admin and CS screens should expose history, current state, source, reason, and next action.
- DES-PROP-010: Destructive or irreversible actions need confirmation, permission, and audit visibility.
- DES-PROP-011: Microcopy must use canonical domain terms from taxonomy.
- DES-PROP-012: Navigation must preserve user context when moving between related views.
- DES-PROP-013: Design-system additions need naming, variants, tokens, and reuse rationale.
- DES-PROP-014: Dense tables need sorting, filtering, pagination, selection, and column visibility strategy.
- DES-PROP-015: Forms need validation timing, error placement, recovery path, and saved-state behavior.
- DES-PROP-016: Charts and dashboards need clear units, time range, thresholds, and drill-down path.
- DES-PROP-017: Mobile constraints must be checked for touch targets, wrapping, overflow, and hierarchy.
- DES-PROP-018: User-facing language must avoid explaining implementation details inside the app.

## DES-FILL - Operating Guidance

### DES-FILL-TASK - Primary Workflow

- surface 를 만들기 전에 primary task 를 식별한다. 첫 relevant screen 에서 target
  user 가 product doc 을 읽지 않고 task 를 시작하거나 이어갈 수 있어야 한다.
- operational tool 은 scan, compare, decide, repeat 를 우선한다. 사용자가 work
  surface 를 필요로 할 때 marketing-page composition 을 만들지 않는다.
- empty, loading, error, partial, success state 에서도 user's next action 이 보여야 한다.

### DES-FILL-LAYOUT - Information Architecture

- layout 은 frequency 와 consequence 를 반영한다. 자주 쓰는 action 은 가까이,
  destructive/rare action 은 guard 하고 덜 prominent 하게 둔다.
- dense list 는 stable table/grid behavior 가 필요하다: sorting, filtering,
  pagination 또는 virtualization, selection, bulk action policy, column visibility.
- navigation 은 context 를 보존한다. detail 에서 list 로 돌아왔을 때 filter, scroll,
  selected item, current task state 가 사라지면 안 된다.

### DES-FILL-CONTROLS - Interaction And Forms

- 익숙한 control 을 쓴다: command 는 button, binary state 는 toggle, option set 은
  menu, peer view 는 tabs, value 는 input/slider/stepper, compact tool action 은 tooltip 있는 icon.
- form 은 validation timing, field-level error placement, 필요 시 summary,
  recovery path, unsaved-change behavior, disabled-state rationale 을 가져야 한다.
- destructive action 은 permission, confirmation, consequence preview, state 가 중요할 때 audit trail 이 필요하다.

### DES-FILL-RESPONSIVE - Fit And Accessibility

- text 는 mobile/desktop 에서 parent 안에 들어가야 한다. viewport-scaled typography 보다
  wrapping, stable constraints, content-aware sizing 을 선호한다.
- accessibility 는 keyboard path, focus order, visible focus, label association,
  contrast, reduced-motion tolerance, icon-only control 의 screen-reader name 을 포함한다.
- responsive QA 는 smallest supported viewport, common desktop width,
  long localized strings, empty/overflow data, modal/toolbar collision 을 확인한다.

### DES-FILL-COPY - Domain Language And UX Writing

- UI copy 는 canonical taxonomy term 을 쓰되, 필요한 경우 internal object name 보다 친절하게 표현한다.
- 사용자가 행동해야 하는 정보가 아니라면 app 안에서 implementation mechanics 를 설명하지 않는다.
- error copy 는 무슨 일이 있었는지, data 가 저장됐는지, 다음에 무엇을 할 수 있는지,
  support/operator action 이 필요한지를 말해야 한다.

## DES-REVIEW - Review Questions

- target user 가 첫 relevant screen 에서 primary task 를 완료할 수 있는가?
- happy path 말고 중요한 state 들이 설계되어 있는가?
- layout 이 반복 작업을 방해하지 않는가?
- 긴 label, mobile width, empty/error state 에서도 fit 이 유지되는가?
- copy 가 canonical domain language 를 보존하는가?

## DES-EVIDENCE - Suggested Evidence

- desktop/mobile screenshot 또는 browser capture.
- state matrix: empty/loading/error/partial/success/disabled.
- interactive surface 의 keyboard/focus/contrast note.
- taxonomy pack 기준 copy/terminology spot-check.
- entry, decision, recovery, completion 을 담은 workflow note.

## DES-GAP - Deepening Slots

- DES-GAP-001: Operational-tool layout patterns.
- DES-GAP-002: Admin/CS timeline and reconciliation UX.
- DES-GAP-003: Form validation and recovery patterns.
- DES-GAP-004: Dashboard/chart review rubric.
- DES-GAP-005: Accessibility test checklist.
- DES-GAP-006: Design-system component governance.
- DES-GAP-007: Responsive QA viewport matrix.
- DES-GAP-008: UX writing and domain-language alignment guide.
