---
id: sfs-policy-loop-taxonomy
summary: Single decision lens for choosing a loop type — score trigger axis (prompt/goal/interval/event) x stop axis (judgment/criteria+turn-cap/cancel/goal-met), then pick the minimum-complexity primitive; four loop types mapped by-reference to existing solon primitives.
load_when: ["which loop", "loop type", "loop taxonomy", "choose loop", "recurring or autonomous", "goal loop", "scheduled loop", "proactive loop", "turn-based", "stop condition", "루프 선택", "어떤 루프"]
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
