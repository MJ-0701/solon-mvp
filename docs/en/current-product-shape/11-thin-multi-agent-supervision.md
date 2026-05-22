---
doc_id: sfs-current-product-shape-en-11
title: "Thin Multi-Agent Supervision"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/current-product-shape.md
summary: "Thin Multi-Agent Supervision"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Thin Multi-Agent Supervision

SFS does not ask Claude, Codex, and Gemini to run at the same time by default.
The default is one small work unit, with role separation only when it reduces
context pollution or self-validation risk.

- A researcher is useful when the codebase, domain, or dependency change needs
  broad read-only mapping before edits.
- A worker is useful after the plan and files_scope are fixed.
- An evaluator is useful when the generator should not approve its own work.
- Shared memory is not a long transcript. It is the sprint workbench,
  `review.md`, `report.md`, and, when terminology needs to survive the sprint,
  `docs/solon/domain-map.md`.

This is a thin supervisor pattern that keeps the useful independence of
multiple agents without making coordination the product.

