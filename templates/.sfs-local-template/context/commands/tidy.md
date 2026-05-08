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
- Private close entry is `report.md` plus `retro.md`; shared handoff belongs in
  `docs/solon/` only when the team needs a durable shared document.
- `tidy --apply` archives workbench only after report evidence exists.
- `events.jsonl` is active state, not durable history. Closed-sprint event lines
  are pruned after `report.md`/archive evidence exists; an empty event ledger is
  deleted instead of kept as residue.
- `retro` is the normal final close command and ensures `report.md` before
  closing. Do not recommend `report` before `retro` in the normal close path.
  Use `report` only for preview or past-report rebuild. Use `retro --draft`
  only when the user explicitly wants an open-only retro scratchpad.
- Final report/retro should preserve the cross-phase fundamentals that mattered:
  shared design concept, glossary/domain language, feedback evidence, boundary
  decisions, and any gray-box delegation still risky or deferred.
