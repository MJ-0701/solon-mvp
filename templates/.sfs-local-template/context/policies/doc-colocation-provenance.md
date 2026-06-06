---
id: sfs-doc-colocation-provenance
summary: Keep routed-context changes co-located with their docs in one change; lock routes against broken links; ship reference docs on a fixed skeleton; footer 7-step outputs with a provenance line.
load_when: ["doc colocation", "colocation", "provenance", "reference doc", "skeleton", "broken link", "route resolves", "doc drift", "stale doc", "freshness"]
---

# Doc Colocation and Provenance

Stop doc rot the way the Anthropic data-analytics team did: a skill file that
drifts from its docs silently loses accuracy. Two disciplines — change docs in
the *same* change as the context they describe, and stamp generated outputs with
their provenance so a non-expert reader can judge trust. Source: Anthropic "How
Anthropic enables self-service data analytics with Claude" (2026-06-03).

## COLOCATION_RULE

A routed-context change (`commands/*`, `policies/*`, `_INDEX.md`) must update its
co-located surfaces in the same change, not a follow-up:

- New routed file -> add its `_INDEX.md` route line in the same change.
- Renamed/removed routed file -> update or drop the `_INDEX.md` route and any
  cross-links in the same change.
- Behavior change in a command/policy -> update the maintenance doc or reference
  doc that describes it in the same change.

Enforcement is split by what each direction can actually check:

- REVERSE (route -> file) is machine-locked: every literal `_INDEX.md` route
  resolves to an existing file. `*`-glob lines (knowledge-pack families) are
  skipped. Locked by `tests/test-doc-colocation-provenance.sh`. This catches
  rename/delete drift and orphaned routes.
- FORWARD (touched routed file -> docs updated) is review-time, not static: at
  Gate 6 the CPO review confirms a diff that changed a routed file also moved
  its docs, backed by a `contributing.md` checklist item. (No dedicated review
  lens is registered for this; it rides the existing Gate-6 review step.) The
  source puts enforcement at the same place ("a review hook flags the PR"); a
  static unit test cannot read a diff,
  and a forward "every file is routed" check needs a by-design exception list
  (`.ko` mirrors loaded alongside their parent, indirectly-routed lenses) that
  would be brittle. Do not fake the forward check as a static test.

## REFERENCE_DOC_SKELETON

A reference doc (a domain/topic note the router branches into on demand) ships on
a fixed skeleton so readers and the router find the same parts every time:

- `Grain` — one line: the single thing this doc is the source of truth for.
- `Scope` — what it covers and, explicitly, what it does NOT.
- `Usage` — when the router/agent should open it (mirror its `load_when`).
- `Gotchas` — known failure cases. Reuse the Gotchas accumulation loop in
  `lessons-accumulation.md`; do not define a second Gotchas mechanism here.
- `Cross-Ref` — sibling docs and the parent route in `_INDEX.md`.

## PROVENANCE_LINE

7-step outputs and reports carry a one-line provenance footer so a non-technical
operator can gauge trust without re-deriving the work. The footer has five
fields (this policy is their SSoT; other docs cross-link, do not restate):

- `Source-grade` — official / derived / inferred.
- `Confidence` — high / medium / low.
- `Reviewed` — who or what reviewed (self-CPO / cross / advisor / none).
- `Freshness` — date or sprint the content was last validated.
- `Owner` — the role accountable for the claim.

Keep it one line; it is a trust label, not a section. Apply selectively to
outputs a reader cannot self-verify, not to every line.

## CROSS_REFERENCES

- Gotchas accumulation + feedback flywheel: `lessons-accumulation.md`.
- Skill-catalog audit + `load_when` discipline: `skill-catalog-discipline.md`.
- Line budget for this file: `md-line-budget.md` (200-line ceiling).
- 7-step output formats that carry the provenance footer:
  `docs/maintenance/methodology-7-step.md` (cross-link only; fields live here).
