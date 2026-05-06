---
id: sfs-command-tidy
summary: Close work by compressing workbench evidence into report and archive, not by deleting history.
load_when: ["tidy", "report", "retro", "archive", "close", "정리"]
---

# Tidy / Report / Retro

- Workbench files are temporary: brainstorm, plan, implement, log, review.
- Private close entry is `report.md` plus `retro.md`; shared handoff belongs in
  `docs/solon/` only when the team needs a durable shared document.
- `tidy --apply` archives workbench only after report evidence exists.
- `retro` is the normal final close command and ensures `report.md` before
  closing. Do not recommend `report` before `retro` in the normal close path.
  Use `report` only for preview or past-report rebuild. Use `retro --draft`
  only when the user explicitly wants an open-only retro scratchpad.
- Final report/retro should preserve the cross-phase fundamentals that mattered:
  shared design concept, glossary/domain language, feedback evidence, boundary
  decisions, and any gray-box delegation still risky or deferred.
