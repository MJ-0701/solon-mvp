---
id: sfs-policy-design-intake-flow
summary: Conditional beginner design intake that records a confirmed or unverified seed before broad UI work.
load_when:
  - design intake
  - design brief
  - Figma
  - visible UI without design.md
  - docs/solon/design.md
six_question_keys: "user-job, first-flow, viewport, constraints, direction, evidence"
intake_states: "CONFIRMED, UNVERIFIED"
content_policy: "conditional beginner intake; propose defaults, request one confirmation when interactive, and retain UNVERIFIED evidence when confirmation is unavailable"
---

# Beginner Design Intake Flow

Use this five-step route only when its intake trigger applies. It reduces
uncertainty without turning a small existing UI edit or a noninteractive run
into a blocker.

## Content Policy

Keep this as an intake route, not a second design-system specification. Reuse
the existing design knowledge pack for tokens, anti-slop review, and browser QA.

## DES-INTAKE-01 - Decide Whether Intake Applies

Run the six-question brief only when there is no confirmed seed and either the
requester says they need design help or are design-inexperienced, or the work
creates a broad new screen, workflow, or redesign. A confirmed `design.md` or
`docs/solon/design.md` goes directly to implementation.

Do not force the full brief for a minor edit to an existing visible UI merely
because a seed file is absent. Preserve the established UI's observed tokens
and components; record a narrow missing-seed gap as `UNVERIFIED` when it needs
to be visible to later review.

## DES-INTAKE-02 - Six-Question Brief

Ask these six questions together: target user and primary job; first workflow
or screen; desktop/mobile priority; existing brand or product constraints;
useful references or preferred direction; and delivery/evidence constraints.
When an answer is missing, propose a clear default and continue; do not block
the brief or request separate approval for each default.

## DES-INTAKE-03 - Reference Or Safe Starter

If a Figma file is available, inspect it first. If not, use a screenshot or
reference page as a fallback. Extract usable principles, not a replica: do not
copy protected assets or distinctive trade dress.

If there is no Figma file, screenshot, or reference, propose a safe starter
direction instead: follow an existing product system when one exists; otherwise
use a calm task-first layout, readable type, one icon family, neutral surfaces
with one restrained accent, regular spacing, modest radius, and no generic
gradient or copied brand treatment. Record `reference: none` in the seed.

## DES-INTAKE-04 - Seed State And One Confirmation

Create `docs/solon/design.md` with the brief, token values, component/icon
rules, prohibited values, and a short reference rationale. Near its top, record
`intake_status: CONFIRMED` or `intake_status: UNVERIFIED`. Ask once for a human
confirmation when interaction is available; that one response accepts the
proposed defaults or supplies edits.

If the person does not confirm, retain the proposed seed as `UNVERIFIED`; when
a seed is not warranted, record an `UNVERIFIED` design-intake gap and its reason
in implementation or review evidence. In noninteractive or CI work, do the same
without waiting: record the proposed seed or gap as `UNVERIFIED`, never `Ready`.
This state is evidence, not a new hard implementation block.

## DES-INTAKE-05 - Implementation, Review, And Ready State

Bind implementation to a confirmed seed when one exists. A scoped change may
continue from an `UNVERIFIED` proposed seed or recorded gap, including CI, but
must use the listed or established values and reject prohibited or newly invented
values. Update the seed before introducing a new approved value.

The route is `Ready` only after confirmation, a clean existing token-drift
check, and existing browser-QA evidence for one desktop and one mobile viewport.
When this intake applied but was skipped or remains unconfirmed, review records
`UNVERIFIED` rather than silently calling the design route `Ready`; it does not
create a new gate or replace existing review and waiver rules.
