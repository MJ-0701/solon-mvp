---
doc_id: sfs-current-product-shape-en-7
title: "Plan Is A Contract"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/current-product-shape.md
summary: "Plan Is A Contract"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Plan Is A Contract

`sfs plan` is not a pretty transcript of the brainstorm. The plan should contain:

- measurable acceptance criteria
- in-scope and out-of-scope boundaries for the sprint
- feedback loop, smoke test, review, or validation method
- evaluator criteria for pass, hold, or fail
- the next implementation slice

If a key owner decision is missing, Solon should not fill it with a guess. It
should keep the question open.

Decision prompts do not end at opaque `Q1`, `A/B/C/D`, or "recommended A"
labels. When options exist, Solon shows every viable option with its meaning
and consequence, then marks the recommendation as the default. If that would be
too dense, Solon asks the decisions one at a time instead of hiding choices.
Compact bundles such as `A/A/A/C/C confirmed` are not user-facing confirmation
phrases; use natural language such as "confirm the recommended path".

