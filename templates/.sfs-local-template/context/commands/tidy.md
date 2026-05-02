---
id: sfs-command-tidy
summary: Close work by compressing workbench evidence into report and archive, not by deleting history.
load_when: ["tidy", "report", "retro", "archive", "close", "정리"]
---

# Tidy / Report / Retro

- Workbench files are temporary: brainstorm, plan, implement, log, review.
- Durable close entry is `report.md` plus `retro.md`.
- `tidy --apply` archives workbench only after report evidence exists.
- `retro --close` needs explicit user intent; refine report/retro before final close.
- Final report/retro should preserve the cross-phase fundamentals that mattered:
  shared design concept, glossary/domain language, feedback evidence, boundary
  decisions, and any gray-box delegation still risky or deferred.
