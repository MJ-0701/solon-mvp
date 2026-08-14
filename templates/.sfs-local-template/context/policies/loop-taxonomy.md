---
id: sfs-policy-loop-taxonomy
summary: Single decision lens for choosing a loop type — score trigger axis (prompt/goal/interval/event) x stop axis (judgment/criteria+turn-cap/cancel/goal-met), then pick the minimum-complexity primitive; four loop types mapped by-reference to existing solon primitives.
load_when: ["which loop", "loop type", "loop taxonomy", "choose loop", "recurring or autonomous", "goal loop", "scheduled loop", "proactive loop", "turn-based", "stop condition", "where should this check live", "run it every time", "chain the check", "verification loop", "루프 선택", "어떤 루프"]
---

# Loop Taxonomy

A loop is a work cycle that repeats until a stop condition is met. Solon already
owns every loop primitive this policy names — the default session, the gated
autonomous loop, the scheduled-run contract, the unattended runners, the
self-improvement cycle. What was scattered is the **choice**: which primitive
fits the task at hand. This policy is that single decision lens. It is
**by-reference only**: each loop type routes to the policy/command that owns its
mechanics, and no mechanic is re-stated here as a second SSoT.

External validation (by-reference): a Claude Code team post on getting started
with loops, 2026-06-30 — the four-type classification and the "start with the
simplest loop" principle are adopted; the vendor command surface and preview
feature names are held out entirely.

## DECISION_FRAME

Score the task on two axes, then pick the **minimum-complexity primitive** that
satisfies both. Complexity rises left to right on each axis; never pick a more
autonomous loop than the stop condition you can actually verify.

- **Trigger axis** — what starts each cycle:
  `prompt` (a human turn) → `goal` (an accepted contract drives iterations) →
  `interval` (a schedule fires) → `event` (a signal/queue item fires).
- **Stop axis** — what ends the loop:
  `human judgment` (operator reads and decides) →
  `criteria + turn-cap` (deterministic acceptance criteria bounded by an
  iteration/turn cap) → `cancel` (runs until paused/retired via operational
  controls) → `goal-met` (a proposal/queue drains or a north-star check passes).

Simplest loop first: if `prompt x human judgment` covers the task, use the
default session and stop there. Escalate one notch only when the current notch
demonstrably cannot hold the task — the same minimum-useful-slice rule the
kernel applies to work applies to loop selection. Stop criteria should be
deterministic, measurable signals wherever possible; a loop whose stop
condition cannot be checked without fresh human judgment does not belong on the
interval/event notches.

## LOOP_TYPES

Four types, each mapped to the solon primitive that owns it:

1. **TURN_BASED** — trigger `prompt`, stop `human judgment`. Primitive: the
   default interactive session under the kernel rails. No extra machinery; this
   is the floor every other type must justify leaving.
2. **GOAL_BASED** — trigger `goal`, stop `criteria + turn-cap`. Primitive: the
   gated autonomous loop (`commands/loop.md`) — Ralph-grade continuation until
   every story acceptance_criteria is PASS/waived/approved-deferred, bounded by
   the within-loop discard-escalation ladder (refine@3 / pivot@5 / halt@8) and
   one atomic change per iteration (`policies/harness-autonomy.md`).
3. **TIME_BASED** — trigger `interval`, stop `cancel` (pause/resume/archive/
   on-demand — the four operational controls). Primitive: SCHEDULED_RUN_CONTRACT
   (`policies/work-delegation-and-startup.md`): every fire a fresh session,
   inter-run state by file only, credentials by indirection. The bookend daily
   loop (`commands/daily.md`) is the supervised instance of this type.
4. **PROACTIVE** — trigger `event`, stop `goal-met` (queue drained, proposal
   accepted or declined). Primitive: unattended runners under the same
   SCHEDULED_RUN_CONTRACT, plus NORTH_STAR proactive-proposal authority
   (`policies/work-delegation-and-startup.md`) — trust-gated, suggest-only,
   never bypassing the inviolable gates. The self-improvement cycle
   (`policies/self-improvement-loop.md`) is solon's standing proactive loop.

A task that seems to need a hybrid usually decomposes: a proactive detector
(type 4) that opens a goal-based WU (type 2) is two simple loops, not one
complex one.

## CHECK_PLACEMENT_LADDER

DECISION_FRAME sizes the work loop; a verification check needs a second
decision — **where it lives**. Four placements, least to most coupled:

1. **Standalone** — the operator invokes the check by hand. Right for
   cross-cutting sweeps, and for a check still earning trust
   (`policies/skill-catalog-discipline.md` SHADOW_MODE_TRUST_LADDER).
2. **Embedded** — the check is a step inside the producing rail, so producing
   without checking is not a reachable path.
3. **Chained** — the producing rail calls the check when it finishes. A rail
   that cannot be edited is chained through a thin wrapper that calls the
   original and then the check.
4. **Every-change** — the check runs on every change to the surface (a gate, a
   hook, a required pre-merge step): the enforcement tier, and
   `policies/critical-rule-hook-promotion.md` owns when a rule earns it.

Promotion signal: **repeated invocation**. Running a standalone check by hand
after every change means the check has already graduated and needs a permanent
home — the verification-side twin of the repeated-correction trigger
(`policies/skill-promotion-loop.md` DETECTION, floor 2). Same floor, same
suggest-only handling: the ladder proposes the next placement; a human accepts
it.

## HABIT_TO_CONTRACT_CHAINING

Placement 3 above is one specific conversion: an operator habit ("I always run
Y after X") becomes a contract ("X calls Y when it finishes"). The habit
depends on the operator remembering; the contract does not. Convert when the
pairing is unconditional, and keep the trade explicit:

- Chaining spends tokens on every run of X, whether or not Y was needed.
- Chaining costs flexibility: if Y is genuinely useful on its own, or X is
  sometimes run precisely to skip Y, do not chain — leave it at placement 1.
- Do not chain a check the operator has not yet come to trust; that is a
  placement-4 move made early, and it turns X's output into Y's false alarms.

The capture side is not a new mechanism: taking the manual follow-up you repeat
most and encoding it as a check is the verification-side instance of
`policies/lessons-accumulation.md` CURATION_PASS and
`policies/harness-autonomy.md` FIX_THE_LOOP_NOT_THE_CODE. One addition to the
capture scope: **project-specific deterministic rules count** — the domain rule
a generic linter cannot know (rejecting a migration that drops a column with no
backfill, say) is as capturable as a qualitative check, and cheaper to trust.

External validation (by-reference): a Claude blog post on building verification
loops with skills (2026-07-22) — the placement classification and the "if you
run it after every change, it has graduated" signal; the vendor's command and
feature names are held out entirely.

## PROACTIVE_INTERVENTION_LADDER

DECISION_FRAME picks the loop and CHECK_PLACEMENT_LADDER places the check; this
places the **response**. A proactive surface (type 4) with something to say has
had two settings — file a candidate or stay silent — which is why one subject
gets re-filed under a new title every pass. Four rungs:

1. **No action.** A first-class choice, not a failure to decide: a finding below
   the rubric bar is dropped, and a noisy agent is worse than an idle one.
2. **Inline note.** It rides an artifact already being written (report,
   flowcheck output, curation report) and opens nothing new.
3. **New candidate.** A fresh suggest-only entry — promotion candidate, `L-NNN`,
   doctor line. This rung was carrying all the traffic.
4. **Merge into an open unit.** Read the open queue before minting a candidate:
   when an unclosed unit already covers the subject — a pending item, a live
   capsule, an open sprint AC — append there rather than file a rival entry.
   Merging appends to a proposal, never to an accepted one.

**Rubric — three axes, no new scorer.** Clearing rung 1 is scored on
**usefulness** (does acting change what happens next), **confidence** (checkable
evidence — `policies/source-pointer-citation.md` PROOF_CARRYING_FINDING), and
**is a human better suited** — the decision-side pair of
`policies/work-delegation-and-startup.md` HUMAN_ATTENTION_IS_SCARCE, sending that
call to the operator as rung 2 instead of rung 3 work. No new scorer:
`policies/skill-promotion-loop.md` HELD_OUT_SCORING measures it.

## ATTENTION_DECAY_ON_BARREN_SURFACES

A standing check costs the same on a surface that has produced nothing for months
as on the one where the work is. After N consecutive barren passes a surface is
demoted in **check frequency**, returning to full cadence at once when the
surface changes or the operator names it. Never removal.

**Inviolable gates are exempt.** Decay applies only to observation surfaces,
where a miss costs a delayed finding. An enforcement surface, where one miss is
the whole failure, is never decayed — a decayed gate is a trimmed gate wearing a
schedule. Classify with `policies/steering-surface-taxonomy.md`
RULE_VS_GUARDRAIL; if the answer is inviolable, stop. Grain twin:
SCHEDULED_RUN_CONTRACT item 5 (`policies/work-delegation-and-startup.md`) asks
whether a scheduled *job* still earns its fires; this is surface-grain and its
outcome is a frequency. Cost rationale: `policies/token-harness.md`. External
validation for both sections (by-reference): a Claude blog post on proactive
assistance across a shared surface (2026-08-13) — a four-way outcome including
doing nothing and joining open work, plus attention lowered where there is
nothing to contribute; vendor product, chat platform, invocation UI, plan names
and figures held out.

## VERIFICATION_AND_SYSTEM_ENCODING (by-reference)

Three secondary lessons from the same source land on existing anchors, one line
each — no new mechanics:

- **Self-verify with quantitative checks.** A loop's per-iteration verification
  should be a deterministic check the loop can run itself; this externally
  validates the MEASURE stage (`policies/self-improvement-loop.md`) and
  HELD_OUT_SCORING's eval-first, deterministic-stage-before-judge ordering
  (`policies/skill-promotion-loop.md`).
- **Encode individual failures into the system.** Fixing one failed iteration
  improves one run; recording it as a durable avoidance rule improves every
  subsequent iteration — the lessons ledger and CURATION_PASS already own this
  (`policies/lessons-accumulation.md`).
- **Deterministic work goes to scripts; route model tiers by judgment.** Inside
  any loop, offload mechanical steps to scripts/hooks and reserve the strongest
  model for judgment calls — owned by `policies/token-harness.md` (tool/script
  offload, cache-aware layout) with model-tier workarounds tagged and sunset per
  `policies/model-workaround-sunset.md` (MODEL_TAG_REQUIRED).

## CROSS_REFERENCES

- Loop execution rails (single-runner, queue, mutex, monitor checkpoints,
  session transfer): `commands/loop.md`.
- Autonomy spectrum + discard escalation + verifier != implementer:
  `policies/harness-autonomy.md`.
- Duration/trigger routing axis + SCHEDULED_RUN_CONTRACT + NORTH_STAR:
  `policies/work-delegation-and-startup.md` (LONG_RUNNING_AND_SCHEDULED).
- Standing self-improvement cycle: `policies/self-improvement-loop.md`.
- Scheduled/unattended credential handling: `policies/credential-hygiene.md`.
