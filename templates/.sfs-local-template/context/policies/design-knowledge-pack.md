---
id: sfs-policy-design-knowledge-pack
summary: Design/frontend topic and proposition inventory for SFS lens activation.
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

This file is a compact filled guidance pack for design/frontend work. Use it
to decide which workflow, layout, state, accessibility, and copy checks are
active for a sprint, review, or release. Apply only the matching ids.

## Activation Rules

- Activate design depth when users, operators, admins, or reviewers interact
  with a visible workflow.
- Do not make a marketing landing page when the work is an operational tool.
- Data-dense product surfaces need scanning, hierarchy, states, and task flow,
  not decorative composition.
- Accessibility and responsive fit are active whenever UI is user-facing.
- Visible UI implementation activates pre-user browser verification:
  Playwright or equivalent browser automation must run before asking the user
  to inspect the UI.
- Visible UI product behavior also activates product-level DDD/TDD: session/
  auth/workflow, permission, and product-state rules need a named
  domain/use-case/state boundary, not only a component, hook, store, router, or
  bootstrap edit.
- AI-generated UI activates design-system governance. If `design.md` or
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
- DES-SCALE-009: Frontend implementation needs automated browser evidence before user inspection, scaled to risk.

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
- DES-PROP-024: Visible UI changes need pre-user browser QA with desktop and mobile/small viewport evidence, primary interaction coverage, and console/runtime error checks.
- DES-PROP-025: Visible UI product logic should live in named
  domain/use-case/state logic; bootstraps, routers, root components, pages,
  hooks, stores, effects, HTTP clients, cookies, and localStorage are
  composition/presentation/adapter surfaces unless a waiver is recorded.

## Split Operating Guidance

Read `policies/design-knowledge-pack-operating.md` when a review needs the
DES-FILL operating sections:

- DES-FILL-TASK, DES-FILL-LAYOUT, DES-FILL-CONTROLS
- DES-FILL-SYSTEM for `design.md`, token drift, Korean typography, and
  AI-slop signals
- DES-FILL-REPAIR for repair-first UX validation
- DES-FILL-RESPONSIVE, DES-FILL-BROWSER-QA, and DES-FILL-COPY

## DES-REVIEW - Review Questions

- Can the target user complete the primary task from the first relevant screen?
- Are all important states designed, not only the happy path?
- Does layout support repeated work without making the user hunt?
- Do long labels, mobile widths, and empty/error states still fit?
- Does copy preserve canonical domain language?
- When validation fails, can the user see what to fix, where to fix it, and how
  to recover without reading documentation?
- Did the implementer read and apply `design.md` or an equivalent design
  contract?
- Did any colors, font sizes, spacing, radius, shadow, or icon styles appear
  outside the token contract?
- Does the screen show generic AI-slop signals, or does the product's own
  design language come through?
- Does Korean typography and long-label fit hold across mobile and desktop?
- Did the implementer run Playwright or equivalent browser automation before
  user inspection, with desktop/mobile evidence and console/runtime checks?
- Did frontend behavior preserve DDD/TDD boundaries, with product rules named in
  UI domain/use-case/state logic and verified by unit/component/browser evidence?

## DES-EVIDENCE - Suggested Evidence

- Screenshot or browser capture for desktop and mobile.
- State matrix: empty/loading/error/partial/success/disabled.
- Keyboard/focus/contrast notes for interactive surfaces.
- Copy/terminology spot-check against taxonomy pack.
- Workflow note covering entry, decision, recovery, and completion.
- Repair matrix for validation states: detected issue, field location, user
  action, server fallback, and success-after-fix path.
- Design-system evidence: `design.md` excerpt, token usage note, token drift
  grep/inspection result, desktop/mobile screenshot, and icon/font consistency
  note.
- Browser QA evidence: Playwright/Cypress/Storybook/browser command and result,
  desktop/mobile screenshots or traces, primary interaction note, and console
  error summary.
- Visible UI DDD/TDD evidence: state/use-case transition test, component test,
  browser smoke, or explicit waiver mapping each affected AC to evidence.

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
- DES-GAP-013: Playwright/browser QA smoke matrix for frontend handoff.
