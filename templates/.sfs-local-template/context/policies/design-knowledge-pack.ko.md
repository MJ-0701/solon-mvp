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
content_policy: "parent router; read split child only when matching design evidence is needed"
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
- visible UI 구현은 사용자 확인 전에 browser 검증을 활성화한다. Playwright
  또는 동등한 browser automation evidence 없이 UI 를 ready 로 넘기지 않는다.
- visible UI product behavior 도 product-level DDD/TDD 를 활성화한다.
  session/auth/workflow, permission, product-state rule 은 component, hook,
  store, router, bootstrap 수정만으로 충분하지 않고 named
  domain/use-case/state boundary 를 가져야 한다.
- AI generated UI activates design-system governance. If `design.md` or
  `docs/solon/design.md` exists, read it before editing; if neither exists and
  the work creates visible UI, record the gap or create a compact seed contract
  before broad screen generation.

## DES-SCALE - Review Depth By Project Size

- DES-SCALE-001: A prototype needs a clear primary task and obvious controls.
- DES-SCALE-002: MVP UI needs core flow, empty/loading/error/success states, and responsive fit.
- DES-SCALE-003: Production UI needs accessibility, consistency, copy quality, and failure recovery.
- DES-SCALE-004: Admin/operator UI needs audit trail, filters, timeline, permissions, and destructive-action safeguards.
- DES-SCALE-005: Multi-screen products need information architecture, navigation, and state continuity.
- DES-SCALE-006: Design-system work needs tokens, components, variants, usage rules, and migration plan.
- DES-SCALE-007: Brand/marketing work needs first-viewport signal, real assets, and conversion/action clarity.
- DES-SCALE-008: AI-generated UI needs `design.md`, token drift checks, and screenshot evidence, not only "looks good" judgment.
- DES-SCALE-009: Frontend 구현은 위험도에 맞는 자동 browser evidence 를 사용자 확인 전에 남겨야 한다.

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
- DES-PROP-019: Validation should coach repair before warning, blocking, or blaming the user.
- DES-PROP-020: AI UI must not invent colors, type sizes, spacing, radius, shadows, or icon styles outside `design.md` without review.
- DES-PROP-021: Korean typography needs one primary Korean-capable font, stable line-height, and `letter-spacing: 0` unless the existing design system explicitly overrides it.
- DES-PROP-022: Iconography should come from one coherent icon family or the existing product icon system; do not mix random free icons.
- DES-PROP-023: AI-slop signals include generic SaaS gradients, arbitrary card/radius choices, inconsistent palettes, mixed icon weights, and token values that differ screen by screen.
- DES-PROP-024: Visible UI 변경은 desktop/mobile viewport evidence, primary interaction coverage, console/runtime error check 를 포함한 pre-user browser QA 가 필요하다.
- DES-PROP-025: Visible UI product logic 은 named domain/use-case/state logic
  에 있어야 한다. bootstrap, router, root component, page, hook, store,
  effect, HTTP client, cookie, localStorage 는 waiver 가 없으면
  composition/presentation/adapter 표면이다.

## Split Operating Guidance

DES-FILL 세부 운영 지침은 `policies/design-knowledge-pack-operating.ko.md` 로
분리되었다. DES-FILL-SYSTEM, DES-FILL-REPAIR, DES-FILL-BROWSER-QA,
Design-system, `design.md`, token drift, AI-slop signal, repair-first UX,
responsive/accessibility, browser QA, copy guidance 가 필요할 때만 child pack 을 읽는다.

## DES-REVIEW - Review Questions

- target user 가 첫 relevant screen 에서 primary task 를 완료할 수 있는가?
- happy path 말고 중요한 state 들이 설계되어 있는가?
- layout 이 반복 작업을 방해하지 않는가?
- 긴 label, mobile width, empty/error state 에서도 fit 이 유지되는가?
- copy 가 canonical domain language 를 보존하는가?
- validation 이 실패했을 때 사용자가 무엇을, 어디서, 어떻게 고치면 되는지
  문서를 읽지 않고 알 수 있는가?
- `design.md` 또는 equivalent design contract 를 읽고 적용했는가?
- token 밖 색상, 폰트 크기, spacing, radius, shadow, icon style 이 생기지 않았는가?
- 화면이 generic AI-slop 처럼 보이는 신호를 가진가, 아니면 product 고유의 규칙이 보이는가?
- 한국어 typography 와 긴 label 이 mobile/desktop 에서 안정적으로 맞는가?
- 사용자 확인 전에 Playwright 또는 동등한 browser automation 을 실행했고,
  desktop/mobile evidence 와 console/runtime check 가 남아 있는가?
- frontend behavior 가 DDD/TDD boundary 를 보존하는가? product rule 이 UI
  domain/use-case/state logic 에 이름 붙어 있고 unit/component/browser evidence
  로 검증됐는가?

## DES-EVIDENCE - Suggested Evidence

- desktop/mobile screenshot 또는 browser capture.
- state matrix: empty/loading/error/partial/success/disabled.
- interactive surface 의 keyboard/focus/contrast note.
- taxonomy pack 기준 copy/terminology spot-check.
- entry, decision, recovery, completion 을 담은 workflow note.
- validation repair matrix: detected issue, field location, user action,
  server fallback, success-after-fix path.
- design-system evidence: `design.md` excerpt, token usage note, token drift
  grep/inspection result, desktop/mobile screenshot, icon/font consistency note.
- browser QA evidence: Playwright/Cypress/Storybook/browser command 와 result,
  desktop/mobile screenshot 또는 trace, primary interaction note, console error summary.
- frontend DDD/TDD evidence: state/use-case transition test, component test,
  browser smoke, 또는 각 AC 와 연결된 explicit waiver.

## DES-GAP - Deepening Slots

- DES-GAP-001: Operational-tool layout patterns.
- DES-GAP-002: Admin/CS timeline and reconciliation UX.
- DES-GAP-003: Form validation and recovery patterns.
- DES-GAP-004: Dashboard/chart review rubric.
- DES-GAP-005: Accessibility test checklist.
- DES-GAP-006: Design-system component governance.
- DES-GAP-007: Responsive QA viewport matrix.
- DES-GAP-008: UX writing and domain-language alignment guide.
- DES-GAP-009: Repair-first validation patterns.
- DES-GAP-010: `design.md` schema and token drift checker.
- DES-GAP-011: Korean typography and icon-family starter guide.
- DES-GAP-012: AI-slop review rubric.
- DES-GAP-013: frontend handoff 용 Playwright/browser QA smoke matrix.

## DES-AIERA - AI 시대 생성 자산 lens

2026-05/06 실무 강연에서 추린 review-lens 프롬프트. AI 생성 시각 자산의 토의용
체크이지 hard rule 이 아니며, 인용 주장은 강연 시점 주장이다.

- DES-AIERA-001: 레퍼런스로 시각 자산을 생성할 때, 프롬프트가 원작을 베끼지 않고
  느낌만 빌려 새로 창작했는지 묻는다 — 이미지/영상 생성의 표절-아닌-재창작 IP 위생.
  생성 자산도 제품 고유의 디자인 언어와 토큰 일관성을 지켜야 하며(AI-slop 은
  DES-PROP-020/023 참조), "모델이 만들었다"는 IP 출처와 디자인 시스템 적합성 어느
  쪽도 면제하지 않는다.
- DES-AIERA-002: 생성형 제품 광고는 생성 전 asset-consistency 계약이 필요하다:
  product reference library, shot/angle inventory, brief/CTA, aspect ratio,
  duration, prompt preview, approval mode, post-output consistency check.
  이미지 하나를 다시 첨부하는 것만으로는 acceptance evidence 가 아니다.
