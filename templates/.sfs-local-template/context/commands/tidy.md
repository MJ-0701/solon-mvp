---
id: sfs-command-tidy
summary: Close work by keeping only durable artifacts and cold-archiving recoverable evidence.
load_when: ["tidy", "report", "retro", "archive", "close", "정리"]
---

# Tidy / Report / Retro

- Retention rule: keep only artifacts with a one-line reason to remain visible.
  If the reason is not clear in one sentence, remove it or pack it into cold
  history after report evidence exists.
- Workbench files are temporary: brainstorm, plan, implement, log, review.
- Shared handoff docs prefer
  `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/report.md` and
  `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/retro.md`.
  Legacy `docs/solon/<english-workspace>/<yyyyMMdd>/` folders are fallback
  only. `tidy --all --apply` may rehome high-confidence flat legacy folders
  into the domain-first path without overwriting existing files; ambiguous or
  conflicting folders stay visible for review.
- Report/retro prose should use the user's native/workspace language, matching
  the native-language commit message rule. Do not force English when the work
  conversation is Korean or another non-English language.
- `tidy --apply` archives workbench only after report evidence exists.
- Apply `policies/deprecation-and-migration.md`: every visible leftover needs a
  replacement/handoff reason, cold archive path, or explicit user decision.
  Advisory cleanup may wait; compulsory cleanup needs risk such as stale state,
  data loss, security, or automation breakage.
- `events.jsonl` is allowed only while it has a one-line active-sprint reason:
  current sprint status/gate/review routing. It must be compact, not append-only
  history; repeated command opens replace older lines for the same sprint/gate.
  After the sprint closes, `report.md`/archive evidence and git history are the
  durable record, so closed-sprint event lines are pruned and an empty ledger is
  deleted.
- Post-adopt surface cleanup is valid even when no sprint folders remain:
  `sfs tidy --all --apply` removes project-local cache notice files, placeholder
  `auth.env`, orphan `events.jsonl`, empty workbench dirs, and collapses
  top-level non-adopt archive buckets into `archives/adopt/surface-cleanup/...`.
- `retro` is the normal final close command and ensures `report.md` before
  closing. Do not recommend `report` before `retro` in the normal close path.
  Use `report` only for preview or past-report rebuild. Use `retro --draft`
  only when the user explicitly wants an open-only retro scratchpad.
- Final report/retro should preserve the cross-phase fundamentals that mattered:
  shared design concept, glossary/domain language, feedback evidence, boundary
  decisions, and any gray-box delegation still risky or deferred.
