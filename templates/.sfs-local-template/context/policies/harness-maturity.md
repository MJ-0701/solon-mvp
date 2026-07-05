---
id: sfs-policy-harness-maturity
summary: AI maturity self-diagnosis rubric behind the `sfs harness doctor` maturity section — impact-signal ladder, not adoption counting; onboarding starts with locating the current level.
load_when:
  - maturity
  - adoption impact
  - self-diagnosis
  - delegation level
  - team rollout
  - 성숙도
---

# Harness Maturity (Self-Diagnosis)

Adoption is not impact (external case, cite: `idea_wiki:L087-I1`): a team can
use AI on ninety percent of its work and move no faster. What predicts impact
is *how* the work is delegated, so the diagnosis scores a maturity ladder from
impact evidence in the repo's own workbench artifacts — never from usage
counts. All of it is signal-only (ALT-INV-3): the level is info lines only and
can never change `sfs harness doctor`'s exit code or block any command.

## MATURITY_LADDER

Five levels (solon adaptation of the six-stage model, `idea_wiki:L087-I2`;
the original's stages 1-2 collapse into one artifact-free floor here).
Deterministic bash over `.sfs-local/` artifacts, no LLM in the loop:

| level | meaning | deterministic evidence |
|---|---|---|
| 1 | autocomplete only | leaves no repo artifact — indistinguishable from level 2 |
| 2 | chat/assist (code not landed through delegation) | SFS initialized, no completed WU (`report.md`) in any sprint |
| 3 | whole-task delegation + human inspection | >= 1 sprint with `report.md` (completed WU) |
| 4 | multi-agent / parallel capsules | >= 1 `.sfs-local/queue/done/` entry, or a sprint `implement.md` with a filled agent cross-review line |
| 5 | unattended-capable outputs | queue-done evidence AND sprint review evidence AND a release/check surface |

Level 2 is the honest floor for an initialized project: levels 1-2 cannot be
told apart from artifacts, and doctor says so rather than guessing.

## IMPACT_SIGNALS

Each doctor run prints the raw signals above the level line, exact tokens:

- `delegated-wu` — completed WUs (`report.md`) out of total sprints.
- `review-loop` — sprints carrying Gate 6 review evidence (`review.md`).
- `parallel-capsule` — autonomous queue completions + cross-review sprints.
- `rework` — `L-NNN` entries in `.sfs-local/lessons.md` per completed WU
  (caught-failure ledger as the rework proxy; high rework at a given level is
  a reason to consolidate, not to climb).

The scan shares the `.sfs-local` collection base with `sfs measure` and the
doctor cost signals — one evidence surface, three read-only lenses. Session
runtime signals (sidechain share, token mix) stay in the Cost Signals section
and are deliberately not double-counted here.

## ONBOARDING_FIRST_QUESTION

Rollout starts with locating the current level, not with training everyone:
run `sfs harness doctor` and read the AI Maturity section before choosing what
to improve. Climbing one level at a time is the pattern — delegate one whole
WU with review to reach 3, split work into parallel capsules for 4, and only
then consider unattended queue runs for 5. The team-rollout sequence
(champion + repository first) lives in GUIDE's team adoption section; the
repo-surface preconditions live in `policies/harness-readiness.md`
(AI_FRIENDLY_SURFACE). Readiness before maturity climbing is the same order
discipline as Sanity-before-Cartography.
