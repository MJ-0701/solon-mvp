---
id: sfs-policy-md-line-budget
summary: Active markdown stays loadable. Operational logs, routed context, top-level project docs, and user-authored long-form md must stay under 200 lines per file; overflow is archived, not flattened.
load_when: ["writing", "readme", "progress", "handoff", "session index", "200 line", "md cleanup", "log retention", "operational log", "routed context", "policy doc", "wiki", "guide", "report", "artifact size", "fits in head"]
---

# MD line budget

Markdown that the agent loads in context — or that a human review must walk
through — has a hard size ceiling. Beyond the ceiling, the file stops being a
loadable artifact and becomes archived evidence.

## Thresholds

- **warn** at 180 lines (cushion: actively shrinking surfaces should not push
  past this without rotating).
- **partial** at 200 lines (size violation; harness doctor reports it,
  contract test fails for in-scope paths).
- **fail** at 250 lines (size violation is past cushion; release-blocking).

The thresholds apply per-file. A 600-line PROGRESS.md is the same violation as
six 200-line ones — the fix is archive rotation, not multi-file flattening.

## In scope

The 200-line ceiling applies to:

- `templates/.sfs-local-template/context/**/*.md` (routed context / skill /
  policy / kernel docs).
- Top-level `*.md` in the product distribution root (`SFS.md`, `CLAUDE.md`,
  `AGENTS.md`, `GEMINI.md`, `README.md`, `GUIDE.md`, agent adapter docs).
- **Operational logs** — chronological append/overwrite files that hold
  release ledger, session history, scheduled task trace, or handoff state.
  Concrete instances: `PROGRESS.md`, `HANDOFF-next-session.md`,
  `NEXT-SESSION-BRIEFING.md`, `sessions/_INDEX.md`, sprint-level
  `handoff*.md` stubs, learning-log per-month indexes.
- **User-authored long-form md** — README / GUIDE / 학습노트 / 보고서 /
  retro / postmortem inside a project the agent operates on. The ceiling
  keeps these loadable; long-form thinking belongs in linked child docs.

## Out of scope (exception list)

These intentionally exceed 200 lines and are not policy violations:

- `CHANGELOG.md` and `RELEASE-NOTES.md` — append-only release logs. The
  existing harness checks that they *do* exceed 200 lines as a
  release-log-exception sanity proof.
- `QA-REPORT-*.md` / `INTEGRATION-VERIFY-*.md` — one-shot evidence docs.
  Frontmatter check still applies (so LLMs can load shape), but size is
  unrestricted.
- `tests/` fixtures and any other test data.
- Archived files under any `archives/`, `.sfs-local/archives/`, or
  `docs/solon/<workspace>/<yyyyMMdd>/archive/` path.

## Overflow rotation

When an in-scope file crosses 200 lines, the fix is **archive rotation**, not
content compression that loses evidence:

1. Copy the current file to a dated archive path:
   - operational logs (PROGRESS / HANDOFF / sessions/_INDEX / handoff stubs):
     `.sfs-local/archives/operational-log/<yyyyMMdd>/<original-filename>` or,
     in workspace-scoped docsets,
     `docs/solon/<workspace>/<yyyyMMdd>/archive/<original-filename>`.
   - routed context / top-level / user-authored: closest existing archive
     pattern; if none, create `archives/<doc-kind>/<yyyyMMdd>/`.
2. Rewrite the live file with **only**: active WU, current sprint pointer,
   unresolved decisions, recent N session/release rows (N small — usually
   3-8), current handoff state.
3. Add `history_archive:` (or equivalent) pointer in the live file so
   agents know where the older rows went.
4. Closed scheduled task traces, deferred domain locks, and old release
   evidence go to the archive as well.

`recent N`, in practice: PROGRESS.md keeps ~5-8 session rows; sessions/_INDEX
keeps the most recent ~15 ledger rows; HANDOFF keeps the latest single
handoff body; learning-log indexes keep current month + previous month.

## ARTIFACT_FITS_IN_HEAD

The ceiling is not a formatting preference — it is the design rationale shared
by every decomposition surface SFS runs. An artifact no reader can hold in
their head is an artifact nobody can review, so the loop returns to where it
started: unreviewable output. The same rationale, by-reference rather than
restated, backs the thin agent entry (adapter docs carry pointers; bodies live
in routed context) and capsule decomposition
(`sub-agent-capsule-contract.md`) — three surfaces, one reason. When a new
artifact kind is added, the question is not "how many lines may it have" but
"can one reader hold it", and the answer sets the budget. External validation
(by-reference): a Claude blog deterministic-kernel writeup (2026-07-21) — an
output too large to fit in a head sends the work back to square one; vendor and
product names held out.

## Why this exists

Two failures keep recurring otherwise:

- Operational logs grow silently. PROGRESS.md hit 455 lines (16 release lag)
  before a Cowork session noticed; HANDOFF stayed pinned 18 releases stale.
  Because no routed policy carried the ceiling, the agent saw no rule when
  writing those files.
- Contract tests already lock the ceiling for routed context and top-level
  docs, but operational logs and user-authored long-form md sit outside the
  test scope. The promotion in 0.7.10 widens scope to match this policy.

## Harness enforcement

- Contract: `tests/test-product-md-frontmatter-line-budget.sh` (top-level)
  and `tests/test-context-md-split-frontmatter.sh` (routed context) lock
  scope they already cover.
- 0.7.10 extension: `sfs harness doctor` adds an
  `md-line-budget-violation` detector that walks the policy scope (above)
  and reports per-path warn/partial counts so projects without the contract
  tests still see violations.
- 0.7.10 adds an `operational-log-lag` detector for the sibling failure
  (release lag between the product `VERSION` and `PROGRESS.md`
  `last_completed_release.version`).

## Related policies

- `context-pollution-guard.md` — keeps durable context thin; this policy
  enforces the numeric ceiling that pollution-guard implies.
- `session-transfer-autopilot.md` — handoff durable artifact set explicitly
  includes the operational logs covered here, so size enforcement and
  handoff completeness stay aligned.
