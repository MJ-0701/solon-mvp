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
content_policy: "compact operating guidance; apply only matching ids and keep design depth proportional to visible workflow risk"
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

## DES-FILL - Operating Guidance

### DES-FILL-TASK - Primary Workflow

- Identify the primary task before designing surfaces. The first screen should
  let the target user start or resume that task without reading product docs.
- For operational tools, optimize for scan, compare, decide, and repeat. Avoid
  marketing-page composition when the user needs a work surface.
- Keep the user's next action visible in empty, loading, error, partial, and
  success states.

### DES-FILL-LAYOUT - Information Architecture

- Layout should reflect frequency and consequence: frequent actions close at
  hand, destructive or rare actions guarded and less prominent.
- Dense lists need stable table/grid behavior: sorting, filtering, pagination or
  virtualization, selection, bulk action policy, and column visibility.
- Navigation should preserve context. Returning from detail to list should not
  erase filters, scroll, selected item, or current task state.

### DES-FILL-CONTROLS - Interaction And Forms

- Use familiar controls: buttons for commands, toggles for binary state, menus
  for option sets, tabs for peer views, inputs/sliders/steppers for values, and
  icons with tooltips for compact tool actions.
- Forms need validation timing, field-level error placement, summary where
  useful, recovery path, unsaved-change behavior, and disabled-state rationale.
- Destructive actions need permission, confirmation, consequence preview, and
  audit trail when state matters.

### DES-FILL-SYSTEM - Design.md And Anti-AI-Slop Governance

- `design.md` is the design-system contract an AI can read. Put machine-readable
  tokens at the top and short rationale below. A useful seed can be small:
  5-6 colors, a 6-step type scale, 8 spacing steps, radius/shadow rules,
  component variants, icon style, and forbidden values.
- When asking AI to build UI, include "read `design.md` first and do not invent
  values outside it" in the implementation request. Review the result for token
  drift: arbitrary hex values, arbitrary font sizes, arbitrary spacing/radius,
  mixed icon weights, or different card treatments across screens.
- For Korean products, a practical starter set can be Wanted Montage-style
  components, a single icon family such as Coolicons, and a Korean-capable font
  such as Pretendard. These are starter references, not vendor lock-in. If the
  product already has a design system, the existing system wins.
- Korean typography is not solved by picking a font. Start body copy around
  line-height 1.5-1.6, keep letter-spacing at 0 by default, and screenshot-check
  long Korean labels, mobile widths, button text, and table cell wrapping.
- Extracting a `design.md` seed from a reference page can work. Do not copy
  protected brand assets or distinctive trade dress; extract principles such as
  color relationships, spacing rhythm, hierarchy, and component structure, then
  translate them into the product's own language.
- The designer role moves upward: from drawing every pixel to designing the
  system and judging AI output quality. Design review should judge system
  adherence, user-task fit, token drift, and AI-slop signals with evidence.

### DES-FILL-REPAIR - Friendly Validation And Recovery

- For user-facing validation, define a repair-first UX contract before
  implementation. The primary goal is helping the user fix the input, not merely
  detecting that it is invalid.
- Show the exact field and item that need attention. For unresolved placeholders
  such as `[Product]` or `[Scene]`, present the tokens near the input and offer a
  direct edit path such as focus, clear, replace, or "let AI fill this" where
  product risk allows.
- Copy should sound like coaching: "This part still needs a real value" rather
  than "Invalid input." Helper text should teach better results, for example
  asking for scene, mood, or background and warning gently that render-order
  words like "8k" or "cinematic" can make output feel more artificial.
- Server-side 4xx validation is a final safety net for cost, abuse, or data
  integrity. It must return structured information that the UI can render as the
  same field-level repair path, not a dead-end error.

### DES-FILL-RESPONSIVE - Fit And Accessibility

- Text must fit its parent across mobile and desktop. Prefer wrapping, stable
  constraints, and content-aware sizing over viewport-scaled typography.
- Accessibility includes keyboard path, focus order, visible focus, label
  association, contrast, reduced-motion tolerance, and screen-reader names for
  icon-only controls.
- Responsive QA should check smallest supported viewport, common desktop width,
  long localized strings, empty/overflow data, and modal/toolbar collisions.

### DES-FILL-COPY - Domain Language And UX Writing

- UI copy should use canonical taxonomy terms while staying friendlier than
  internal object names when needed.
- Do not explain implementation mechanics in the app unless the user must act
  on them.
- Error copy should state what happened, whether data was saved, what the user
  can do next, and whether support/operator action is needed.

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
