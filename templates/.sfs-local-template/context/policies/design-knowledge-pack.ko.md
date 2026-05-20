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
- visible frontend 구현은 사용자 확인 전에 browser 검증을 활성화한다. Playwright
  또는 동등한 browser automation evidence 없이 UI 를 ready 로 넘기지 않는다.
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
- DES-PROP-024: Visible frontend 변경은 desktop/mobile viewport evidence, primary interaction coverage, console/runtime error check 를 포함한 pre-user browser QA 가 필요하다.

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

### DES-FILL-SYSTEM - Design.md And Anti-AI-Slop Governance

- `design.md` 는 AI 가 읽는 디자인 시스템 계약이다. 위쪽에는 machine-readable
  token 을 두고, 아래쪽에는 왜 그런 선택을 했는지 짧은 rationale 을 둔다.
  최소 seed 는 colors 5-6개, type scale 6단계, spacing 8단계, radius/shadow,
  component variants, icon style, 금지값으로 충분하다.
- AI 에게 UI 를 맡길 때는 "먼저 `design.md` 를 읽고 token 밖 값을 만들지 말라"는
  지시를 implement 요청에 포함한다. 결과물 review 에서는 token drift 를 확인한다:
  임의 hex, 임의 font-size, 임의 spacing, 임의 radius, 섞인 icon weight, 화면마다
  다른 card treatment 가 있으면 finding 으로 본다.
- 한국어 제품 starter set 으로는 원티드 몽타주 계열 컴포넌트, Coolicons 같은
  단일 icon family, Pretendard 같은 Korean-capable font 를 참고할 수 있다. 단,
  이것들은 고정 vendor 규칙이 아니라 출발점이다. 기존 제품의 design system 이
  있으면 기존 system 이 우선한다.
- 한국어 typography 는 폰트 하나를 고르는 것으로 끝나지 않는다. 본문 line-height 는
  대체로 1.5-1.6 범위를 먼저 검토하고, letter-spacing 은 기본 0 으로 둔다.
  긴 한국어 label, mobile width, 버튼 안 텍스트, table cell wrapping 을 screenshot 으로
  확인한다.
- reference page 를 분석해 `design.md` seed 를 뽑는 방식은 유효하다. 다만 protected
  brand asset 이나 고유 trade dress 를 그대로 복제하지 말고, 색/간격/계층/컴포넌트
  원리를 추출한 뒤 자기 product language 로 바꾼다.
- 디자이너의 역할은 pixel 을 직접 많이 그리는 사람이 아니라 system 을 설계하고 AI
  output 의 품질을 판정하는 사람으로 올라간다. 디자인본부 review 는 감상평이 아니라
  system adherence, user task fit, token drift, AI-slop signal 을 evidence 로 판단한다.

### DES-FILL-REPAIR - Friendly Validation And Recovery

- user-facing validation 은 구현 전에 repair-first UX contract 를 먼저 잡는다.
  목표는 입력이 틀렸다는 사실을 잡아내는 것이 아니라, 사용자가 바로 고칠 수
  있게 돕는 것이다.
- 어떤 field 의 어떤 item 이 문제인지 가까이에 보여준다. `[Product]`,
  `[Scene]` 같은 미치환 placeholder 가 남았다면 token 을 input 주변에
  chip/list 로 보여주고, focus, clear, replace, "AI 에게 맡기기" 같은
  직접 회복 경로를 제공한다. 단 product risk 가 있으면 무시하고 진행은 숨기거나
  2차 option 으로 낮춘다.
- copy 는 "잘못된 입력" 이 아니라 "아직 실제 값으로 바꿔야 할 부분이 있어요"
  같은 coaching tone 을 쓴다. helper text 는 scene, mood, background 처럼 더
  좋은 결과를 만드는 입력을 알려주고, "8k", "cinematic", "시네마틱" 같은
  render-order 단어가 결과를 더 AI 처럼 보이게 할 수 있음을 부드럽게 안내한다.
- server-side 4xx validation 은 비용, abuse, data integrity 를 위한 마지막
  안전망이다. UI 가 같은 field-level repair path 로 렌더링할 수 있도록
  structured information 을 반환해야 하며 dead-end error 로 끝나면 안 된다.

### DES-FILL-RESPONSIVE - Fit And Accessibility

- text 는 mobile/desktop 에서 parent 안에 들어가야 한다. viewport-scaled typography 보다
  wrapping, stable constraints, content-aware sizing 을 선호한다.
- accessibility 는 keyboard path, focus order, visible focus, label association,
  contrast, reduced-motion tolerance, icon-only control 의 screen-reader name 을 포함한다.
- responsive QA 는 smallest supported viewport, common desktop width,
  long localized strings, empty/overflow data, modal/toolbar collision 을 확인한다.

### DES-FILL-BROWSER-QA - Pre-User Browser Verification

- 변경된 UI 를 사용자에게 확인 요청하기 전에 app 을 실행하고 browser automation 으로
  먼저 본다. repo 의 Playwright, Cypress, Storybook, e2e smoke 가 있으면 그것을
  우선하고, 없으면 사용 가능한 Playwright/browser automation 으로 local dev server
  또는 static file 을 확인한다.
- 최소 desktop viewport 1개와 mobile/small viewport 1개를 확인한다. 위험도가 높은
  flow 는 empty, loading, error, success, disabled, overflow, modal/toolbar
  collision 중 해당 state matrix 를 추가한다.
- page load 만 보지 말고 primary workflow 또는 변경된 control 을 실제로 조작한다.
  screenshot/trace 에서 blank render, overlap, clipping, horizontal overflow,
  unreadable text, broken focus path, console/runtime error 를 확인한다.
- 구현 evidence 에 command/result 와 screenshot, trace, browser-capture path 를 남긴다.
  automation 이 불가능하면 정확한 blocker, 최소 대체 evidence, 사용자 explicit waiver
  여부를 기록한다.

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
- validation 이 실패했을 때 사용자가 무엇을, 어디서, 어떻게 고치면 되는지
  문서를 읽지 않고 알 수 있는가?
- `design.md` 또는 equivalent design contract 를 읽고 적용했는가?
- token 밖 색상, 폰트 크기, spacing, radius, shadow, icon style 이 생기지 않았는가?
- 화면이 generic AI-slop 처럼 보이는 신호를 가진가, 아니면 product 고유의 규칙이 보이는가?
- 한국어 typography 와 긴 label 이 mobile/desktop 에서 안정적으로 맞는가?
- 사용자 확인 전에 Playwright 또는 동등한 browser automation 을 실행했고,
  desktop/mobile evidence 와 console/runtime check 가 남아 있는가?

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
