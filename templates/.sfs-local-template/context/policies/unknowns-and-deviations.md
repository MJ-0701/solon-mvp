---
id: sfs-policy-unknowns-and-deviations
summary: Close the map-vs-territory gap — prototype fork, blind-spot list, interview gate, and references field before plan freeze; conservative deviation ledger during implementation; changed-code comprehension quiz after.
load_when:
  - unknowns
  - blind spot
  - deviation
  - 계획 이탈
  - quiz
  - explainer
  - 이해도
  - interview
  - 인터뷰
  - references
  - 레퍼런스 코드
  - prototype
  - 시안
  - recon
  - 정찰
---

# Unknowns & Deviations Loop

A prompt/plan/context bundle is a **map**; the codebase, data, and domain are
the **territory**. The gap between them is the operator's unknowns, and work
quality is bottlenecked by how fast those unknowns are found — not by model
capability. This policy gives the gap three touchpoints: before the contract
freezes (quadrant + blind-spot pass + interview close-out), while the work
runs (deviation log), and after it lands (comprehension gate). Two companion
techniques sharpen the map before it freezes: a prototype fork when direction
cannot even be verbalized, and a references field when the territory already
contains the desired behavior. External validation (by-reference): a
Claude blog field guide on finding your unknowns (2026-07-06); vendor and
model specifics held out. All touchpoints are advisory — no new
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

## PROTOTYPE_FORK (when direction cannot be verbalized)

When the operator cannot say what they want — the map is blank, not merely
gappy — do not force an interview. Fork **2–4 cheap variants** (skeletons,
design sketches, throwaway spikes) that make the choice concrete, present
them side by side with a short comparison table (what each optimizes, what it
gives up), and let the operator pick. Record the **selection and the
rejection reasons** for the losing variants in the brainstorm workbench
(options / append-log sections): a rejected variant with a recorded reason is
a map asset; an unrecorded one is the same conversation waiting to repeat.
The fork is an optional pre-spec step on the existing Gate 2 rail — no new
lifecycle command, signal-only; once a variant is chosen, the spec freezes
through the normal interview + plan path below.

## RECON_RUN_BEFORE_COMMIT (collect telemetry before the real attempt)

For a high-uncertainty slice, a cheap **read-only recon pass** before the main
attempt beats a brave first try: explore the territory (`sfs dig` surfaces,
targeted reads, a dry-run) to collect facts, then fold them into the plan the
real attempt executes. Recon output lands in existing plan sections
(assumptions, risks, `references`) — no new artifact, no new command. This is
the single-variant sibling of PROTOTYPE_FORK above: fork when *direction* is
unknown, recon when direction is known but the *territory* is (external
validation, by-reference: a frontier eval-design case, Claude blog
2026-07-17 — a strong agent flew a reconnaissance orbit to gather telemetry
before committing to the landing plan; vendor, bench, and score specifics
held out).

## BLIND_SPOT_PASS (ask the agent what you did not say)

Before the Gate 3 contract freezes, spend one prompt asking the agent to name
what it would need to know that the operator has not said: missing context,
contradicting evidence in the territory, and the questions it would ask an
expert. Brainstorm/prototype spikes, interview-style Q&A, source-code
reference reads, and an implementation-plan read-back are all forms of this
pass. It matters most for non-technical operators, whose unknown-unknowns
quadrant is the largest; the pass converts them into known-unknowns while
they are still cheap. Findings fold into plan AC/risks, same as a matching
lesson (`lessons-accumulation.md` consult obligation). Its adversarial sibling — attack the answer you did find, not the question you did not ask — is ANTAGONISTIC_RESEARCH_PASS (`source-pointer-citation.md`), which runs after research and before implementation.

EVAL_SURFACE_BLIND_SPOT: the pass's checklist includes the **eval/test
surface itself** — what can the acceptance criteria and existing tests *not*
see (a cost axis, a cache hit, a latency cliff)? When the agent discovers
mid-work an axis the AC is blind to, it surfaces that as a finding rather
than silently optimizing an unmeasured dimension — the verifier blind spot's
self-report path (external validation, by-reference: a frontier
platform-engineering case, Claude blog 2026-07-15; vendor and figures held
out).

The pass output is a concrete `blind_spots` list in the kickoff artifact
(brainstorm workbench): decisions the operator never mentioned but the work
will force. Each item carries a state — `answered` (operator decided),
`delegated` (explicitly left to the worker's conservative judgment), or
`open` — and an `open` item at contract freeze is a plan-readiness finding,
the same standing as an unanswered interview question below.

## SPEC_INTERVIEW_GATE (empty the question list into the spec)

Once direction is confirmed and before the Gate 3 contract freezes, the agent
runs one interview pass to remove ambiguity — and the questions are **ordered
by impact**: design-overturning questions first (a wrong answer there forces
re-architecture), detail questions last. Each answer is **merged into the
spec** (plan requirements / AC / assumptions), never left as chat history —
an answer that only lives in the conversation is not spec. An open question
with neither a merged answer nor an explicit skip record (`skip: <reason>` —
deferring is allowed, silence is not) keeps the plan `status: draft`, and the
plan review-readiness checklist carries this check. Signal-only as ever: the
check moves artifact readiness state and review findings, never exit codes.

## REFERENCES_FIELD (point at territory already mapped)

Existing code that already does the desired behavior — any language, any
repo — is a more precise spec than prose describing it. The plan's execution
contract may carry a `references` field: one pointer per line (path / repo /
commit) plus a one-line note of *what to imitate from it*. When set, the
worker **reads the references before implementing** and records the read in
the implementation log (which reference, what was taken or discarded); a
reference named in the plan with no read trace in the log is a review
finding. References are pointers, not payloads: cite locations, do not paste
bodies (`source-pointer-citation.md`).

REFERENCE_FIDELITY_LADDER — references differ in how much they carry. Prefer,
in order: an **artifact that behaves** (rendered HTML mockup, test suite, a
function elsewhere that already does it) > a **frozen depiction** (screenshot,
fixture, sample output) > a **description in prose**. Each rung down loses
detail the worker must re-invent. A rubric is the executable rung for quality
rather than behavior: written before the work, it is what a verifier checks
against (`sub-agent-capsule-contract.md`; `source-pointer-citation.md`
PROOF_CARRYING_FINDING). Ranks references already allowed — no new field.

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

A completion claim states the ledger explicitly: the `## Deviations` section
carries entries or the literal `none observed` — a slice claimed done with an
observed-but-unlogged deviation is not complete, it is unverified. Gate 6
review includes reading the deviation log (`commands/review.md`). The log is
not overhead; it is the **next sprint's map** — today's deviation entries are
tomorrow's plan-preflight input, folding the territory back into the map.

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

Quiz scope is strict: **3–5 questions drawn only from this slice's changed
code and decisions** — no general-knowledge trivia — so passing evidences
understanding of *this* change, not background skill. The result is recorded
in the sprint workbench (report / retro), and each missed question links to
the explainer or report section that answers it: a wrong answer routes to a
targeted re-read, never to a block.

## Boundaries

- Advisory end to end: no verdict, exit code, or gate order changes. The
  interview / blind-spot / references checks move artifact readiness states
  (draft vs ready) and review findings only; the prototype fork is optional.
- No new required capsule field — deviations ride the existing
  `output_paths` evidence contract.
- The quadrant/blind-spot/interview/references/quiz artifacts live in
  existing sprint workbench files; do not create root-level files for them.
