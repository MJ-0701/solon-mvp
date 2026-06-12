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

## DEBT_FRAMING

A model workaround is harness debt with an expiry date, not permanent policy.
Tagging at write time costs one line; auditing untagged rules after a model
change costs an archaeology session. Prefer fixing the harness structurally
(narrower tool surface, better evidence rails) over coaching a specific
model's quirks — coaching is the workaround of last resort, and it is always
tagged.

## CROSS_REFERENCES

- Rule lifecycle tiers (prose → lint → hook): `critical-rule-hook-promotion.md`.
- Stale-rule conflicts with current defaults: `context-conflict-gate.md`.
- Retirement procedure (archive, never silent-delete): `deprecation-and-migration.md`.
- Tidy rail that surfaces sunset candidates: `commands/tidy.md`.
