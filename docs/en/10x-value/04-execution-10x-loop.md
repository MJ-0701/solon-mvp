---
doc_id: sfs-10x-value-en-4
title: "Execution 10x Loop"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/10x-value.md
summary: "Execution 10x Loop"
load_when: "Read when docs/en/10x-value.md routes to this section."
---
## Execution 10x Loop

For execution work, Solon assumes domain language and tight feedback are
defaults. DDD-lite and TDD-lite are product-level rules: product behavior,
domain terms, boundaries, and evidence are named before implementation. When
code is touched, that also becomes code structure; for non-code slices, it means
named terms, artifact boundaries, and the smallest useful review/check.

They are not ceremony. They are AI safety rails.

| Practice | Solon meaning | Why it matters for AI |
|---|---|---|
| System analysis | ask what patterns already exist before editing | AI should follow the system, not invent a new one |
| Domain language | name terms, entities, states, labels, and invariants | AI uses the user's real language across artifacts |
| Feedback contract | define behavior, review, or smoke evidence before implementation | AI must work in smaller feedback loops |
| Small slice | implement one bounded change | Local failure stays local |
| Review gate | independent CPO verdict and CTO actions | The generator does not self-approve |

Good implementation artifacts remain easy to change. Good AI execution
preserves that property.

