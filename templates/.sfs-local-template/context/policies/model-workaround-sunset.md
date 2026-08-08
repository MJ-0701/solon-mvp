---
id: sfs-policy-model-workaround-sunset
summary: Model-specific workaround rules must carry a model/date source tag and surface for sunset review on model change; untagged behavior workarounds are review findings.
load_when: ["model workaround", "model-specific", "model behavior", "context reset", "model upgrade", "model swap", "new model", "model migration", "sunset review", "model quirk", "prompt workaround"]
---

# Model-Workaround Sunset

A harness that does not evolve with the model turns its workarounds into debt.
A rule written to compensate for one model's behavior is overhead — or actively
harmful — on the next model. Source pattern: a context-reset workaround built
for one model's context anxiety became unnecessary overhead on its successor
("The evolution of agentic surfaces: building with Claude Managed Agents",
2026-06-10, by-reference; vendor infrastructure held out, the lifecycle
principle adopted).

This is the model-specific form of rule lifecycle management — the same vein as
`critical-rule-hook-promotion.md` (rules graduate between enforcement tiers)
and `context-conflict-gate.md` (stale rules conflict with current reality).

## MODEL_TAG_REQUIRED

Any rule added to routed context, skills, hooks, or agent entry docs that
compensates for a **specific model's observed behavior** — context resets,
token-saving phrasing, retry/nudge wording, tool-call style coaching,
verbosity dampeners — must carry a source tag at the rule site:

```
model-workaround: {model: <id or family>, date: YYYY-MM-DD, behavior: <one line>}
```

(or an inline equivalent naming the same three fields). The tag records *which
model* exhibited the behavior and *when*, so the rule can be re-judged when
either changes. An untagged model-behavior workaround is a review finding —
not because the rule is wrong, but because it can never be safely retired.

General rules (good engineering regardless of model) need no tag. The test:
"would this rule survive a model swap unexamined?" If yes, it is a general
rule; if unsure, tag it.

## SUNSET_REVIEW_ON_MODEL_CHANGE

On a model swap or upgrade, every tagged rule becomes a re-review candidate
with three outcomes:

- **keep** — the behavior persists on the new model; refresh the tag's
  `model`/`date`.
- **retire** — the behavior is gone; archive the rule per
  `deprecation-and-migration.md` (replacement reason: model change), never
  silent-delete.
- **generalize** — the behavior turned out to be model-independent; drop the
  tag and promote the rule to a general rule.

`tidy` surfaces tagged rules whose `model` no longer matches the active model
as sunset-review candidates (suggest-only, same rail as skill-promotion
candidates — a human decides). Carrying a stale workaround past a model change
unexamined is the finding; the review itself may well conclude "keep".

## MODEL_HEAD_TO_HEAD_ON_UPGRADE

The swap decision that triggers sunset review is itself measured, not
impressionistic: judge a candidate model by running the **same domain eval
head-to-head** against the incumbent — the held-out set the harness already
keeps (`skill-promotion-loop.md` HELD_OUT_SCORING; eval-first means the set
predates the candidate). An upgrade adopted on vibes cannot be safely
reversed, exactly like an untagged workaround. And the **benchmark surface
expands release-over-release**: as models improve, a static bench saturates
and reads as "no gain" — grow the measured surface (new cases, new scoring
dimensions) with each release so stagnation and improvement stay
distinguishable (`self-improvement-loop.md` MEASURE). Keep one real project
pinned as the **fixed reference repository** the head-to-head always runs
against, so successive swaps are compared on constant ground rather than on
whichever codebase happened to be open. External validation
(by-reference): a frontier finance-diligence platform benchmarks every new
model head-to-head against its incumbent on domain evals and widens the bench
each release (Claude blog, 2026-07-13); vendor, product, and performance
figures held out.

## MODEL_UPGRADE_SETUP_AUDIT

SUNSET_REVIEW_ON_MODEL_CHANGE re-judges rules that carry a `model-workaround:`
tag — but untagged standing instructions absorb old-model corrections too.
Skills, lessons, operator-context notes, and memory-grade docs written while
driving one model quietly encode that model's failure modes as standing
guidance, and those corrections constrain the next model the same way a tagged
workaround does. On a model swap, run one **read-only setup audit delegated to
the new model itself**: hand it the standing-instruction surfaces (skills /
`.sfs-local/lessons.md` / operator-context / memory docs) and ask which
instructions read like corrections for an older model. Output is a candidate
list — retire / generalize / keep, with the reason — consumed at the `tidy`
rail; suggest-only, nothing is edited by the audit pass itself. The new model
is the best detector of scaffolding it no longer needs (the same delegation
STOP_DOING_REVIEW makes for capability scaffolds). Boundary design stays
operator-owned either way: what the audit retires is old-model *coaching*,
never the operator's permission boundaries
(`harness-autonomy.md` BOUNDS_OUTLIVE_MODEL_LIMITS).

## STOP_DOING_REVIEW

Sunset review asks "is this workaround still needed?" Its complement at every
model upgrade: **"what can the harness stop doing?"** Scaffolding built to
compensate for a capability gap — pre-filtering tool outputs the model could
filter itself, pre-digesting context it could route on demand, externally
orchestrating steps it could sequence on its own — is reviewed for handover to
the model, not just for deletion. Vendor evidence (same source, by-reference):
letting the model filter its own tool outputs moved a search benchmark from
45.3% to 61.6%; self-managed context reached 84% where static context scored
lower. Same tidy rail, suggest-only, and each handover is verified like any
harness change (`token-harness.md` discriminating-evals bullet) — capability
claims are tested, not assumed.

Don't settle for the first method that works when it is expensive. A second
external validation (by-reference): a Claude blog build-day hackathon writeup
(2026-06-17) — a costly approach that merely *worked* was reworked into a
self-evolving clustering scheme for a roughly 10–100x inference-cost reduction.
Cost, not just correctness, is a sunset trigger: a workaround that ships but
burns tokens is harness debt to refactor, not a finished answer (generalized;
vendor/name/model specifics held by-reference).

## DEBT_FRAMING

A model workaround is harness debt with an expiry date, not permanent policy.
Tagging at write time costs one line; auditing untagged rules after a model
change costs an archaeology session. Prefer fixing the harness structurally
(narrower tool surface, better evidence rails) over coaching a specific
model's quirks — coaching is the workaround of last resort, and it is always
tagged.

## CROSS_REFERENCES

- End-to-end loop map (sunset re-review is part of the GATE stage; invariants
  declared once there): `self-improvement-loop.md`.
- Rule lifecycle tiers (prose → lint → hook): `critical-rule-hook-promotion.md`.
- Stale-rule conflicts with current defaults: `context-conflict-gate.md`.
- Retirement procedure (archive, never silent-delete): `deprecation-and-migration.md`.
- Tidy rail that surfaces sunset candidates: `commands/tidy.md`.
