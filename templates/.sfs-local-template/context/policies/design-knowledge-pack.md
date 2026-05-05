---
id: sfs-policy-design-knowledge-pack
summary: Design/frontend topic and proposition inventory for SFS division activation.
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

## DES-EVIDENCE - Suggested Evidence

- Screenshot or browser capture for desktop and mobile.
- State matrix: empty/loading/error/partial/success/disabled.
- Keyboard/focus/contrast notes for interactive surfaces.
- Copy/terminology spot-check against taxonomy pack.
- Workflow note covering entry, decision, recovery, and completion.

## DES-GAP - Deepening Slots

- DES-GAP-001: Operational-tool layout patterns.
- DES-GAP-002: Admin/CS timeline and reconciliation UX.
- DES-GAP-003: Form validation and recovery patterns.
- DES-GAP-004: Dashboard/chart review rubric.
- DES-GAP-005: Accessibility test checklist.
- DES-GAP-006: Design-system component governance.
- DES-GAP-007: Responsive QA viewport matrix.
- DES-GAP-008: UX writing and domain-language alignment guide.
