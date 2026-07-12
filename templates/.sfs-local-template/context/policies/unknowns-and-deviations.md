---
id: sfs-policy-unknowns-and-deviations
summary: Close the map-vs-territory gap — decompose unknowns before plan freeze, log conservative deviations during implementation, and check operator comprehension after.
load_when:
  - unknowns
  - blind spot
  - deviation
  - 계획 이탈
  - quiz
  - explainer
  - 이해도
---

# Unknowns & Deviations Loop

A prompt/plan/context bundle is a **map**; the codebase, data, and domain are
the **territory**. The gap between them is the operator's unknowns, and work
quality is bottlenecked by how fast those unknowns are found — not by model
capability. This policy gives the gap three touchpoints: before the contract
freezes (quadrant + blind-spot pass), while the work runs (deviation log), and
after it lands (comprehension gate). External validation (by-reference): a
Claude blog field guide on finding your unknowns (2026-07-06); vendor and
model specifics held out. All three touchpoints are advisory — no new
lifecycle command, no hard block (ALT-INV-3 signal-only).

## UNKNOWNS_QUADRANT (plan preflight)

On plan entry, decompose the slice across known/unknown × known/unknown:

- **known-knowns** — state them as requirements and binary AC.
- **known-unknowns** — name them in the plan as open questions or risk rows;
  each either gets a resolution step or an explicit assumption.
- **unknown-knowns** — assumptions the operator holds but never wrote down;
  the restate-and-clarify pass (`work-delegation-and-startup.md`) exists to
  flush these out before the worker inherits them silently.
- **unknown-unknowns** — invisible to the operator by definition; only the
  BLIND_SPOT_PASS below can surface them.

The quadrant is a preflight lens, not a new artifact: its outputs land in the
existing plan sections (AC, assumptions, non-goals, risks).

## BLIND_SPOT_PASS (ask the agent what you did not say)

Before the Gate 3 contract freezes, spend one prompt asking the agent to name
what it would need to know that the operator has not said: missing context,
contradicting evidence in the territory, and the questions it would ask an
expert. Brainstorm/prototype spikes, interview-style Q&A, source-code
reference reads, and an implementation-plan read-back are all forms of this
pass. It matters most for non-technical operators, whose unknown-unknowns
quadrant is the largest; the pass converts them into known-unknowns while
they are still cheap. Findings fold into plan AC/risks, same as a matching
lesson (`lessons-accumulation.md` consult obligation).

## DEVIATIONS_LOG (conservative choice + record + continue)

When implementation meets territory that contradicts the plan (a missing API,
a wrong assumption, an unexpected schema), the worker does not improvise
silently and does not hard-stop for non-blocking gaps. The rule is:

1. make the **conservative** choice — smallest change that preserves the
   contract's intent and reverses cheaply;
2. **record** the deviation in the sprint workbench (`implement.md` /
   `log.md`) under a `## Deviations` heading: what the plan said, what the
   territory showed, the choice made, and why it is the conservative one;
3. **continue** the slice.

A capsule worker follows the same convention: deviations are part of the
evidence written to the capsule's `output_paths`
(`sub-agent-capsule-contract.md`), so the lead reviews them with the result
instead of discovering them by diff archaeology. Deviation entries are a
SIGNAL input to the self-improving loop: a recurring deviation class becomes
one `L-NNN` lesson (`lessons-accumulation.md`), and an unresolved deviation
with neither a lesson nor a waiver is a Gate 6 review finding.

## COMPREHENSION_GATE (post-implementation explainer + quiz)

After a slice lands, the worker can produce two small artifacts: an
**explainer** — a pitch/what-changed document written for the operator, a
natural fit for the HTML-encouraged user-facing docs strategy — and a short
**quiz** over the decisions and tradeoffs the change embodies. The operator
passing the quiz is comprehension evidence: it verifies the *operator's*
model of the work, the counterpart of Gate 6 review verifying the work
itself. For a non-technical operator this is the merge-adjacent understanding
check: adopt the result only when you can answer what it does and what it
traded away. Signal-only — failing the quiz routes to re-reading the
explainer or asking follow-ups, never to a hard block; whether to require it
per-WU is the operator's standing choice.

## Boundaries

- Advisory end to end: no verdict, exit code, or gate order changes.
- No new required capsule field — deviations ride the existing
  `output_paths` evidence contract.
- The quadrant/blind-spot/quiz artifacts live in existing sprint workbench
  files; do not create root-level files for them.
