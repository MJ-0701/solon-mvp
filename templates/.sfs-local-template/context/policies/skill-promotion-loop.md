---
id: sfs-skill-promotion-loop
summary: Suggest (never auto-create) skill/command candidates from repeated completed-work patterns or a single hard task, with explicit rejection criteria; the success-path twin of lessons-accumulation.
load_when: ["skill promotion", "promote to skill", "repeated task", "skill candidate", "tidy skill-promote", "compile a skill", "recurring workflow", "automate repeated work", "hard task", "skill rejection"]
---

# Skill Promotion Loop

`lessons-accumulation.md` captures repeated **failures** as avoidance rules. This
policy is its twin on the **success** side: a task done the same way three times
is a skill or command waiting to be compiled. Source: note 27 (Hermes turns
every completed task into a reusable, human-editable skill MD — "작업→스킬
자산화"). The unit of growth is an editable Markdown skill/command, exactly
Solon's docs-first format, so promotion is a curation step, not code generation.

## SUGGEST_ONLY

The loop is **read-only and suggest-only**. It surfaces candidates; a human (or
the agent under explicit instruction) decides whether to compile one. It never
writes a skill file, never edits the catalog, and never blocks. This keeps the
catalog from filling with ceremony skills — a candidate is only worth compiling
when a real repeated task needs it (see `skill-catalog-discipline.md`: do not pad
thin buckets).

## DETECTION

`sfs harness doctor` adds a **Skill Promotion Candidates** section that reads the
consumer project's completed-work logs only (`PROGRESS.md`,
`docs/solon/*/PROGRESS.md`, `HANDOFF-next-session.md`), never the shipped
distribution. It normalizes each finished task line (`- [x]` / `- [X]`) into a
signature — ASCII-lowercased, digits and punctuation stripped, whitespace
collapsed (non-ASCII text such as Korean task lines is preserved) — so
version/date-stamped repeats (`release cut 0.8.23/24/25`) collapse to one
`release cut` signature. When a signature recurs at the promote threshold
(**3+**) it emits an `info` candidate. The section emits only `info`/`ok`, so it
never changes the doctor exit code.

The signature is a coarse heuristic; it groups by shared wording, not semantic
intent. A surfaced candidate is a prompt to look, not a verdict.

A second candidate source is the lessons **curation pass**
(`lessons-accumulation.md` CURATION_PASS): its periodic read-only review of
the ledger and event archives surfaces success-side repeated patterns the
doctor's completed-work-log heuristic misses. Same contract — suggest-only,
consumed at the tidy rail.

A third candidate source is **success-side usage aggregation**: flowcheck's
tool-telemetry health reads the same `tool_call` ledger and surfaces the
most-invoked tool with 3+ successful calls as a `usage-value signal` line —
repeated real use is field-tested value, the strongest promotion evidence
there is (external case, by-reference: Claude blog admin spend controls,
2026-07-02 — org-scale dashboards treat repeated skill execution as the value
signal). Read-only, advisory, consumed here as DETECTION input.

A fourth signal is the **repeated-correction trigger**: the same human
correction given twice is a candidate immediately — a correction is costlier
evidence than a mere repeat, so it earns a lower floor (2) than the
completed-work signature (3+). The correction itself also flows to the
failure twin (`lessons-accumulation.md`), and the *reason* it was given is kept separately (`self-improvement-loop.md` REJECTION_REASON_CAPTURE) — this floor counts, that invariant explains. External validation (by-reference):
the same marketing-operations case (Claude blog, 2026-07-08) — the team's
standing rule is "corrected the same thing twice → promote it into the
skill", maintained by non-technical operators.

## COMPLEXITY_TRIGGER

Repetition (3+) is not the only signal. A **single hard task** is a candidate
immediately when the session burned real search cost before the approach
worked — multiple plan revisions, several distinct tool/command rounds, or
nontrivial debugging. Source: odysseus skill auto-extraction
(`github:pewdiepie-archdaemon/odysseus`, `services/memory/skill_extractor.py`
triggers at ≥2 agent rounds / ≥2 tool calls) — the cost already paid to find
the path is exactly what a compiled skill saves next time. At tidy/retro, ask
of each completed hard task: "would a written procedure have collapsed this to
one round?" If yes, it is a candidate at count 1. Suggest-only as ever; this
trigger is a human/agent judgment at the tidy rail, not a new detector.

## REJECTION_CRITERIA

A candidate must be a concrete, repeatable **computer procedure** (a sequence
of commands, file edits, API/tool calls). Reject — do not compile — when:

- the real work happened outside the computer (done physically, in person, or
  on another device; the agent only discussed or advised it);
- it is one-off, personal, or context-specific (a specific person/place/date)
  and will not recur;
- it is pure Q&A or explanation with no transferable method;
- the approach failed or is not worth repeating — that is
  `lessons-accumulation.md` territory (the failure twin), not a skill.

When in doubt, reject: a candidate the author is unsure about is catalog
clutter (`skill-catalog-discipline.md`: do not pad thin buckets). Before
compiling, check the catalog for a same-intent skill and extend it instead of
creating a near-duplicate title.

## EVOLUTION_ADOPTION_GATE

Compiling a new skill and *evolving an existing one* are both adoptions, and an
edit that reads "better" can still be worse. Before adopting either — a fresh
skill or a change to one already in the catalog — clear four gates; failing any
one rejects the adoption no matter how good it otherwise looks:

- **Line budget intact** — the skill still fits `md-line-budget.md`; an edit
  that bloats it past the ceiling is rejected, not flattened.
- **Description integrity** — frontmatter `summary`/`load_when` still names what
  the skill actually does, so the router fires it at the right moment
  (`skill-catalog-discipline.md`: TRIGGER_CENTRIC_LOAD_WHEN). An edit that
  silently breaks the trigger surface is rejected.
- **No scope drift (most important)** — the change stays inside the skill's
  original purpose. A "smarter" edit that quietly widens or repurposes the skill
  is rejected; split a genuinely new purpose into its own candidate.
- **Human sign-off** — adoption is a human/agent-under-instruction decision, as
  everywhere in this loop (SUGGEST_ONLY); there is no auto-adopt on score.

Safe over smart: a higher-scoring edit that drifts scope or breaks the trigger
is rejected in favor of the steady version. Source: Hermes skill-cleanup eval
(note 27) — held-out scoring sits behind these adoption checks, never overrides
them.

## HELD_OUT_SCORING

The four gates above are pass/fail *checks*. Held-out scoring is the **measured**
leg they don't give, and it sits **behind** them: it runs only after all four
pass, and it is **necessary-but-not-sufficient** — an evolution must show a
measurable gain to be worth adopting, but a tie or regression keeps the steady
version, and no score ever overrides a failed gate or the human sign-off
(SUGGEST_ONLY). This is what makes adoption measured rather than vibes; without
it the gate is human review only. Source: `idea_wiki:research/agent-self-improvement/loop-engineering.md`
(R-LOOP-I5 eval-before-adopt, R-LOOP-I8 cost-tiered scoring) — Voyager/ACE/SkillOpt
all gate a skill/policy change on a held-out set the change was not trained on.

**Eval-first (the held-out set is fixed before the change is written).** The
scoring set is a *plan* artifact, not a post-hoc rationalization: the ground-truth
cases and scoring dimensions are pinned before the skill edit (or the WU's code)
exists — "eval = first commit". A measurement bar invented after the work scores
the work to look good; one fixed first tells the plan what "good" even means. This
is the success-side mirror of the flowcheck Plan-gate `eval-first` check
(`commands/flowcheck.md`). External validation (by-reference): Claude blog
hackathon-winners interviews (2026-06-15) — a winning builder's takeaway that the
eval should be the first commit, fixed against concrete ground-truth cases before
the product code; generalized principle adopted, hackathon/name/model-version
specifics held out.

Hold out a small scenario set the edit was **not** tuned on (keep it in `evals/`,
never read while editing — the fixture axis includes wrong-premise cases, `evals/README.md` WRONG_PREMISE_EVAL_FIXTURE), then score the skill before vs after on that set in
two stages, cheap first:

1. **Stage 1 — cheap keyword / deterministic check (free, runs always).**
   Grep-style assertions that the output carries the required anchors and fires
   the right trigger — the same `has`-assertion shape solon's `tests/` and
   `sfs harness doctor` already use. Objectively verifiable outcomes settle here.
2. **Stage 2 — LLM-judge (cost-gated).** Only when stage 1 passes *and* the
   change is non-trivial, escalate to a grader-style judge for the quality
   keywords can't see. The judge is the expensive leg — skip it whenever stage 1
   already settles the call. This is the cost gate.

Adopt only on a positive before/after delta **and** four green gates **and**
human sign-off.

Score reports expose their formula and inputs, and the inputs stay adjustable
("every formula is visible" — external admin-analytics case, by-reference):
a black-box score cannot be audited or challenged, so it cannot serve as the
measured leg. After adoption, sustained real usage (the DETECTION
usage-value signal) is the field twin of the held-out delta — same
necessary-but-not-sufficient standing, never overriding a gate. Dogfooding-beats-bench carries the same standing (external validation, by-reference: a frontier-lab adoption gate, Claude blog 2026-07-10 — "trust no eval"): real-work dogfooding confirms what the bench claims before adoption, and a bench score alone never adopts (`self-improvement-loop.md` measured-but-not-sufficient). The held-out surface also grows release-over-release — a saturated static bench reads as "no gain" — and model swaps score incumbent vs candidate head-to-head on the same domain set (`model-workaround-sunset.md` MODEL_HEAD_TO_HEAD_ON_UPGRADE, same field-twin standing).

Reuse, don't reinvent (no new eval system): this is the
**skill-creator eval harness** pattern — held-out `evals.json` prompts →
with/without runs →
programmatic assertions, then a grader subagent → `aggregate_benchmark`
before/after delta (`anthropic-skills:skill-creator`: `scripts/run_eval.py`,
`agents/grader.md`, `scripts/aggregate_benchmark.py`). That harness is host-side
Python + `claude -p` + a browser viewer, so it is **not** shipped into solon's
bash/docs distribution; solon reuses the *shape* **by reference**, running stage 1
on its existing doctor/test harness and stage 2 as a grader-style judge at the
tidy rail. No scoring engine is added to `bin/sfs`.

DGM-style code self-modification (an agent rewriting its own implementation from
eval scores; `github:jennyzzt/dgm` Darwin-Gödel Machine) stays **by-reference
only** — cited as prior art, never wired into solon's body. Adoption here edits
human-readable skill MD; it never auto-patches code.

## ACTING_ON_A_CANDIDATE

This runs on the existing `tidy` rail — no new lifecycle command (the kernel
absorbs disciplines as policies/lenses, not commands). At `tidy`/retro time, run
`sfs harness doctor`, read the candidates, and for a worthwhile one compile a
skill/command the normal way: give it a trigger-centric `load_when`, an `_INDEX`
route, and the workflow+guard shape from `skill-catalog-discipline.md` (GENERALIZATION_BEFORE_SHARING is the precondition on that edit: parameterize the one-project particulars or hold the promotion); its quality bar may be given as a before/after artifact-pair pointer instead of rule prose (REFERENCE_PAIR_STANDARD_INFERENCE — the model infers the standard from one representative pair, e.g. draft→final; pointers, never pasted payloads, `source-pointer-citation.md`; pair slots live in `operator-context.md`). Record
the decision (promoted, or deferred with reason) so a candidate is not re-surfaced
without context.

## CROSS_REFERENCES

- End-to-end loop map (this policy owns PROPOSE / MEASURE / GATE; invariants
  declared once there): `self-improvement-loop.md`.
- Failure-side twin (avoidance rules): `lessons-accumulation.md`.
- Catalog discipline + nine-category lens the new skill must fit: `skill-catalog-discipline.md`.
- Tidy/retro rail that consumes candidates: `commands/tidy.md`.
- Line budget for this file: `md-line-budget.md`.
