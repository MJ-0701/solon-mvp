---
id: sfs-policy-design-knowledge-pack-operating
summary: Split operating guidance for design/frontend workflow, design-system, repair, responsive, browser QA, and copy checks.
load_when:
  - DES-FILL
  - design operating guidance
  - design.md
  - browser QA
  - repair-first UX
status: filled-v1
parent_doc: design-knowledge-pack.md
split_from_section: "DES-FILL - Operating Guidance"
split_reason: "keep design-knowledge-pack.md under 200 lines while preserving full operating guidance"
content_policy: "read only after design-knowledge-pack.md activates matching DES-FILL ids"
---

# Design/Frontend Operating Guidance

## DES-FILL-TASK - Primary Workflow

- Identify the primary task before designing surfaces. The first screen should
  let the target user start or resume that task without reading product docs.
- For operational tools, optimize for scan, compare, decide, and repeat. Avoid
  marketing-page composition when the user needs a work surface.
- Keep the user's next action visible in empty, loading, error, partial, and
  success states.

## DES-FILL-LAYOUT - Information Architecture

- Layout should reflect frequency and consequence: frequent actions close at
  hand, destructive or rare actions guarded and less prominent.
- Dense lists need stable table/grid behavior: sorting, filtering, pagination or
  virtualization, selection, bulk action policy, and column visibility.
- Navigation should preserve context. Returning from detail to list should not
  erase filters, scroll, selected item, or current task state.

## DES-FILL-CONTROLS - Interaction And Forms

- Use familiar controls: buttons for commands, toggles for binary state, menus
  for option sets, tabs for peer views, inputs/sliders/steppers for values, and
  icons with tooltips for compact tool actions.
- Forms need validation timing, field-level error placement, summary where
  useful, recovery path, unsaved-change behavior, and disabled-state rationale.
- Destructive actions need permission, confirmation, consequence preview, and
  audit trail when state matters.

## DES-FILL-SYSTEM - Design.md And Anti-AI-Slop Governance

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

## DES-FILL-REPAIR - Friendly Validation And Recovery

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
- Repair matrix for validation states should name the detected issue, field or
  item location, user action, server fallback, and success-after-fix path.

## DES-FILL-RESPONSIVE - Fit And Accessibility

- Text must fit its parent across mobile and desktop. Prefer wrapping, stable
  constraints, and content-aware sizing over viewport-scaled typography.
- Accessibility includes keyboard path, focus order, visible focus, label
  association, contrast, reduced-motion tolerance, and screen-reader names for
  icon-only controls.
- Responsive QA should check smallest supported viewport, common desktop width,
  long localized strings, empty/overflow data, and modal/toolbar collisions.

## DES-FILL-BROWSER-QA - Pre-User Browser Verification

- Before presenting a changed UI for user inspection, run the app and inspect it
  through browser automation. Prefer Playwright or equivalent browser automation:
  the repo's existing Playwright, Cypress, Storybook, or e2e smoke command;
  otherwise use available browser automation against the local dev server or
  static file.
- Cover at least one desktop viewport and one mobile/small viewport. For
  higher-risk flows, add the smallest relevant state matrix: empty, loading,
  error, success, disabled, overflow, or modal/toolbar collision.
- Exercise the primary workflow or the changed control, not only page load.
  Check screenshots/traces for blank render, overlap, clipping, horizontal
  overflow, unreadable text, broken focus path, and console/runtime errors.
- Record command/result plus screenshot, trace, or browser-capture paths in the
  implementation evidence. If automation cannot run, record the exact blocker,
  the smallest alternate evidence, and whether the user explicitly waived the
  browser check.

## DES-FILL-COPY - Domain Language And UX Writing

- UI copy should use canonical taxonomy terms while staying friendlier than
  internal object names when needed.
- Do not explain implementation mechanics in the app unless the user must act
  on them.
- Error copy should state what happened, whether data was saved, what the user
  can do next, and whether support/operator action is needed.
