---
doc_id: sfs-current-product-shape-en-18
title: "Choosing A Mode"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/current-product-shape.md
summary: "Choosing A Mode"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Choosing A Mode

| Situation | Recommendation |
|---|---|
| Scope is already clear | `sfs brainstorm --simple` or go straight to `sfs plan` |
| Defining a new feature | `sfs brainstorm` |
| Intent and priority are unstable | `sfs brainstorm --hard` |
| Design, language, or validation is unclear | `sfs brainstorm --hard` |
| Continuing a previous plan/ADR | Record inheritance and start with `sfs implement` |

The point is not to move slowly. The point is to avoid moving faster than the
feedback loop can illuminate.
