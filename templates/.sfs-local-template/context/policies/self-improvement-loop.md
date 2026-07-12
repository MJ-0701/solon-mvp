---
id: sfs-policy-self-improvement-loop
summary: One end-to-end map of solon's self-improving loop (signal -> record -> curate -> propose -> measure -> gate -> apply -> capture-delta) that calls each owning policy by-reference and declares the cross-cutting invariants once.
load_when:
  - self-improvement
  - self-improving
  - evolve loop
  - evolution loop
  - feedback flywheel
  - curation
  - skill promotion
  - lessons loop
  - end-to-end loop
  - loop SSoT
  - improvement cycle
---

# Self-Improvement Loop

Solon's self-improving capability is already mature, but spread across five
policies that each cross-reference their neighbors. What was missing is a single
map showing how those pieces turn one full cycle, and one place that declares
the cross-cutting invariants instead of repeating them in two policies at once.

This file is that map. It is **by-reference only**: every stage names the policy
that owns its mechanics and does not re-describe them, and the invariants below
are declared **here once** — a component policy applies an invariant locally and
points back here, rather than re-stating the rule as a second SSoT.

## The loop — eight stages

```
SIGNAL -> RECORD -> CURATE -> PROPOSE -> MEASURE -> GATE -> APPLY -> CAPTURE -> (back to SIGNAL)
```

1. **SIGNAL** — flow/`tool_call` telemetry hotspots, caught failures,
   plan-deviation log entries (`unknowns-and-deviations.md` DEVIATIONS_LOG),
   and completed-work signatures enter the loop. Owners:
   `flow-conformance-postflight.md`, `skill-promotion-loop.md` (DETECTION).
2. **RECORD** — a caught failure that could recur becomes one durable `L-NNN`
   avoidance rule in the local ledger. Owner: `lessons-accumulation.md`.
3. **CURATE** — a periodic read-only pass (plus a pre-build audit of already
   shipped artifacts before the next slice) clusters patterns and surfaces
   merge / graduation / skill candidates. Owner: `lessons-accumulation.md`
   (CURATION_PASS / PRE_BUILD_AUDIT).
4. **PROPOSE** — success-side repeats (3+) or a single hard task surface as
   skill/command candidates, and `promoted` fields surface graduation
   candidates. Owner: `skill-promotion-loop.md` (DETECTION / COMPLEXITY_TRIGGER).
5. **MEASURE** — a held-out set fixed before the change scores it before/after
   (eval-first; cheap deterministic stage, then a cost-gated judge); after
   adoption, the success-side usage-value signal (repeated real invocations,
   flowcheck telemetry aggregation) is the complementary field measure. Owner:
   `skill-promotion-loop.md` (HELD_OUT_SCORING / DETECTION usage aggregation).
6. **GATE** — the four EVOLUTION_ADOPTION_GATE checks, plus model-swap sunset
   re-review (keep / retire / generalize), decide adoption. Owners:
   `skill-promotion-loop.md` (EVOLUTION_ADOPTION_GATE), `model-workaround-sunset.md`.
7. **APPLY** — only human-gated adoptions land, on the `tidy` rail; a rule that
   meets the promotion criteria graduates to a hook/gate. Owners:
   `commands/tidy.md`, `critical-rule-hook-promotion.md`.
8. **CAPTURE delta** — the harness-evolution delta is recorded; repeated deltas
   promote to tests / policies / skills and re-enter as new SIGNAL. Owner:
   `harness-autonomy.md` (evolution-ledger).

## Stage handoff artifacts (typed handoff)

Each stage emits a concrete artifact the next stage consumes. The handoff is a
**typed handoff** — named fields a downstream stage validates before consuming,
never free prose to re-parse (contract SSoT: `external-orchestrator-entry.md`).

| stage           | artifact (handoff)                          |
|:----------------|:--------------------------------------------|
| RECORD          | `.sfs-local/lessons.md` (`L-NNN` entries)   |
| CURATE          | curation report (suggest-only)              |
| PROPOSE         | promotion candidates (suggest-only)         |
| MEASURE         | `evals/` held-out set + before/after delta  |
| CAPTURE delta   | `.sfs-local/harness/evolution-ledger.md`    |

## Invariants (declared once)

These six rules cut across every stage. They live here; component policies apply
them and point back, so there is no second copy to drift.

- **suggest-only until human gate** — every stage only proposes; applying a
  merge, promotion, or adoption is a human decision (or an agent under explicit
  instruction) at the `tidy` rail. Nothing in the loop auto-writes a ledger,
  skill, or hook.
- **ledger / event log is authoritative** — a run is reconstructible from
  `events.jsonl`; if a handoff or `PROGRESS` disagrees, the log wins. No silent
  sync — a divergence is surfaced (#3), never quietly reconciled.
- **`L-NNN` id preserved** — a merged lesson keeps every source `L-NNN` id, and
  a `promoted` lesson's rule is never merged away (the flywheel never-delete rule
  binds merge application too).
- **measured-but-not-sufficient** — a held-out score is necessary but never
  sufficient: it cannot override a failed gate or the human sign-off, and a tie
  or regression keeps the steady version. External validation (by-reference):
  a frontier-lab adoption gate (Claude blog, 2026-07-10) — "trust no eval":
  a change ships only when practitioner **dogfooding on real work** beats the
  bench; the bench score alone never adopts. Dogfooding-beats-bench is this
  invariant's field twin, feeding EVOLUTION_ADOPTION_GATE and HELD_OUT_SCORING
  (`skill-promotion-loop.md`).
- **no code auto-patch** — applying an adoption edits human-readable MD only.
  DGM-style code self-modification is cited by-reference as prior art, never
  wired into solon's body.
- **scheduled / unattended runs obey SCHEDULED_RUN_CONTRACT** — a scheduled
  CURATE or PRE_BUILD_AUDIT fire is a fresh session, carries state by file only,
  and exposes the four controls (`work-delegation-and-startup.md`).

## Standalone + external seam

The loop runs **standalone**: with no external orchestrator present, it still
turns on `doctor + curation + tidy` alone. An external standing orchestrator
(Hermes-class) is an optional extension point that may feed SIGNAL or host a
cross-system proposal-review surface — its attachment contract and the
default-off schema that holds standalone while it is wired are owned by
`external-orchestrator-entry.md`, with the invariants above unchanged. The seam
ships **opt-in, default off** (`external_orchestrator.enabled: false`), so
removing every external orchestrator — or simply leaving it disabled — must leave
the loop fully working.

## Cross-references

- Stage owners: `lessons-accumulation.md`, `skill-promotion-loop.md`,
  `harness-autonomy.md`, `model-workaround-sunset.md`,
  `critical-rule-hook-promotion.md`.
- Loop rails: `commands/tidy.md` (APPLY), `commands/flowcheck.md` (SIGNAL).
- Typed-handoff + external seam: `external-orchestrator-entry.md`.
- Source lineage (by-reference): note 28 self-improvement-loop synthesis;
  `idea_wiki:research/agent-self-improvement/loop-engineering.md` (R-LOOP-I5
  eval-before-adopt, R-LOOP-I8 cost-tiered scoring).
