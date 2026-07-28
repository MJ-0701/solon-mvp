---
id: sfs-skill-catalog-discipline
summary: Bucket routed commands/policies into nine skill categories to find coverage gaps; keep load_when trigger-centric; on-demand guardrail candidates; setup-via-placeholder.
load_when: ["skill catalog", "category gap", "coverage gap", "load_when", "trigger description", "careful", "freeze", "guardrail", "config setup", "skill audit"]
---

# Skill Catalog Discipline

Operating lens for auditing Solon's routed `commands/` and `policies/` the way a
mature skill catalog is audited: bucket every routed file into one of nine
categories, surface the thin buckets, and keep each file's `load_when` trigger
honest so the router fires it at the right moment. Source: Anthropic
"Lessons from building Claude Code: how we use skills" (2026-06-03).

## NINE_CATEGORY_LENS

Nine buckets. Audit by mapping each routed file to one bucket (a file may sit in
one primary bucket); a bucket with no real coverage is a gap candidate, not an
order to invent a skill.

- `library-reference` — framework/library/source recall.
  Solon: `source-driven-development`, `search-tooling`, `knowledge-pack-router`,
  the `*-knowledge-pack` family, `domain-knowledge-assets`, `obsidian-llm-wiki`.
  Coverage: RICH.
- `product-verification` — assert output quality before it ships.
  Solon: `commands/review`, `commands/flowcheck`, `commands/healthcheck`,
  `flow-conformance-postflight`, `gate6-data-validation-pack`,
  `enterprise-evidence-pack`, `postdev-external-review-pack`.
  Coverage: RICH. This is Solon's spine. The source names verification the
  single highest measurable-impact skill class; Solon already saturates it via
  the Gate system, so the generic "verification is usually thin" guess does NOT
  hold here — record it as a strength, not a gap.
- `data-analysis` — query/transform a dataset into an answer.
  Solon: none. Out of scope by design — Solon is a methodology distribution, not
  a data product. Mark N/A-by-design, not a gap to fill.
- `work-automation` — drive repeated multi-step work.
  Solon: `commands/loop`, `commands/release`, `harness-autonomy`,
  `ai-work-intake-routing`. Coverage: MODERATE.
- `scaffolding` — stand up new structure.
  Solon: `commands/start`, `commands/adopt`, `ddd-tdd-knowledge-pack`,
  `templates/*-zero`. Coverage: RICH.
- `code-quality-review` — review/lint/shape artifacts.
  Solon: `review-lens-routing`, `agent-build-review-lens`,
  `lean-procedure-refactor-pack`, `writing-discipline`, `md-line-budget`.
  Coverage: RICH.
- `ci-cd` — release/promote/migrate.
  Solon: `commands/release`, `shipping-and-launch`, `deprecation-and-migration`.
  Coverage: MODERATE.
- `runbook` — repeatable operational procedure with an append-only run log.
  Solon: partial via `commands/recall` + `lessons-accumulation`; no first-class
  runbook bucket. GAP CANDIDATE — the source's append-only log-per-workflow
  pattern lands here; the natural home is per-workflow run logs SFS already
  emits (`docs/solon/<workspace>/<yyyyMMdd>/`).
- `infra-ops` — environment/runtime health.
  Solon: `infra-knowledge-pack`, `commands/healthcheck`, `mutex`.
  Coverage: MODERATE.

Audit verdict (2026-06-06): one real gap (`runbook`), one deliberate absence
(`data-analysis`); the rest are MODERATE-to-RICH. Do not pad thin buckets with
ceremony skills — a gap is only worth filling when a real repeated task needs it.

## TRIGGER_CENTRIC_LOAD_WHEN

The router (`_INDEX.md`) loads a file only when the active task matches its
`load_when`. So `load_when` is a trigger set, not a summary.

- Every `commands/*` and routed `policies/*` file MUST carry a non-empty
  `load_when`. Locked by `tests/test-skill-catalog-discipline.sh`.
- `load_when` entries are the words a user/agent actually says when the file
  should fire (verbs, command names, error phrases, synonyms) — not a paraphrase
  of the title. Prefer the phrase a confused operator would type.
- `summary` is the one-line router display; `load_when` is the firing trigger.
  Keep them distinct: summary tells a human what the file is, `load_when` tells
  the router when to open it.
- This is authoring guidance, not a machine-graded prose rule. The test only
  asserts presence and non-emptiness; trigger quality stays a review concern.

## ON_DEMAND_GUARDRAIL_CANDIDATES

Session-scoped protective modes, proposed (not yet wired). They complement
Gate 6 mainline-first (`mainline-focus-guard`) and the install-time Stop-hook
registration added in 0.8.23 (`install.sh` -> `.claude/settings.json`).

- `/careful` — block irreversible shell (`rm -rf`, `git push --force`, history
  rewrite) for the session unless re-confirmed. Wiring home: the same
  `settings.json` hook surface WU-0 registers.
- `/freeze <dir>` — block edits outside `<dir>` for the session; debugging scope
  lock. Wiring home: same hook surface.

Status: candidates. Do not wire without owner sign-off; record here so they are
tracked proposals, not orphaned ideas.

## SETUP_VIA_PLACEHOLDER

Consumer-specific setup follows the existing placeholder convention, not a new
config mechanism: ship a `{{PLACEHOLDER}}` in `templates/`, and when a skill
needs an unset value at runtime, ask via `AskUserQuestion` rather than baking a
default. This mirrors the source's "config.json + prompt-when-unset" pattern onto
machinery Solon already has. The hard placeholder rule lives in the root
`CLAUDE.md`; `tests/test-private-dev-path-hygiene.sh` is a related guard that
locks the narrower invariant (no leaked private path), not placeholder format or
prompt-when-unset. This section only points there; it adds no new mechanism.

## CURATION_SAFETY

Catalog tidying — pruning stale entries, collapsing near-duplicates — is a
curation step, and it carries one hard boundary: **only ever touch
agent-generated artifacts; never auto-edit or auto-archive a human-authored
skill/command.** A person who wrote a routed file owns its lifecycle; automated
or agent-driven cleanup leaves it alone and at most *surfaces* it for the author
to decide (SUGGEST_ONLY, like the rest of this lens). Staleness moves a candidate
toward dormancy and then an archive path, **never a delete** — overflow and
disuse are archived as evidence, not flattened (`md-line-budget.md`: archive
rotation, not deletion). This is additive curation discipline, not a new janitor
mechanism. Source: Hermes cleanup janitor (note 27) — agent-made skills age
into archive on disuse while human-made skills are never auto-touched.

## SHADOW_MODE_TRUST_LADDER

A new automated reviewer, checker, or skill does not enter the catalog with
authority — it enters in **shadow**: it runs on real work and writes its
findings where a human reads them, but nothing it says gates or auto-applies.
Authority is earned in three steps and one of them never ends:

1. **Shadow** — suggest-only output, compared against what the human decided
   anyway. False positives and misses are the data being collected.
2. **Promote** — once its findings hold up across a run of real cases, it is
   wired to the surface it belongs on and named in the catalog.
3. **Sample after promotion** — a promoted checker keeps a sampling audit: a
   fraction of its auto-approvals is re-reviewed by a human on an ongoing
   basis. A checker nobody re-checks silently becomes an unowned gate.

Scoring the shadow period is not a new mechanism: `skill-promotion-loop.md`
HELD_OUT_SCORING owns how candidate quality is measured on held-out cases, and
this section only names the deployment ladder that consumes that score
(promotion itself stays SUGGEST_ONLY, like the rest of this lens). The model
counterpart is `model-workaround-sunset.md` MODEL_UPGRADE_SETUP_AUDIT — same
shape, applied to a swapped model instead of a new reviewer. External
validation (by-reference): a Claude blog AI-SDLC security guide (2026-07-21) —
new AI reviewers run in shadow mode to build trust before promotion, and
auto-approvals stay sampled afterwards; vendor, org, and measurement figures
held out.

## CROSS_REFERENCES

- Gotchas accumulation: `lessons-accumulation.md` (the Gotchas slot for caught
  failures already lives there; do not duplicate).
- Line budget for this file: `md-line-budget.md` (200-line ceiling).
- Mainline protection that `/careful` and `/freeze` reinforce:
  `mainline-focus-guard.md`.
