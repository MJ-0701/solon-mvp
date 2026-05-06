# Solon Product Docs

**Language**: [한국어](../ko/index.md) / English

The README is the product overview and table of contents. These pages hold the
deeper operating model, judgment rules, philosophy, and examples.

## Start Here

| Page | When to read it |
|---|---|
| [Current product shape](./current-product-shape.md) | To understand the latest Solon operating flow |
| [Solon 10x value](./10x-value.md) | To understand why Solon trains judgment instead of only automating output |
| [30-minute guide](./guide.md) | To run the first sprint after install |
| [Beginner guide](../../BEGINNER-GUIDE.md) | Korean beginner guide for Git, terminal, and CLI basics |
| [Release notes](../../RELEASE-NOTES.md) | User-facing version notes (Korean for now) |
| [Detailed changelog](../../CHANGELOG.md) | Implementation-level version history |

## Current Flow

```text
sfs status
-> sfs start "<goal>"
-> sfs brainstorm [--simple|--hard] "<raw context>"
-> sfs plan
-> sfs implement "<first slice>"
-> sfs review
-> sfs retro
```

The point is not to outsource all thinking to AI. Solon lets AI assist the work
while the user keeps product ownership over intent, priority, tradeoffs,
validation, boundaries, and language.

As of 0.6.1, backend, strategy/PM, QA, design/frontend, infra/DevOps,
management/admin, and taxonomy knowledge packs are filled with practical
guidance. Finance, bookkeeping, tax, and accounting belong to the
management/admin lens. The user does not need to memorize those labels. Solon
reads the relevant lens and turns it into plain questions, plan criteria, or
review judgment.

The normal close command is `sfs retro`. `sfs report` is an optional helper when
you want to preview or rebuild the report separately.

## Brainstorm Depth

| Mode | Use it when | Expected result |
|---|---|---|
| `--simple` | The direction is already clear and you only need cleanup | Requirements summary, explicit assumptions, plan seed |
| default `normal` | Most new product exploration | 2-5 focused questions that help the user think before plan |
| `--hard` | Ambiguity, product judgment, or system design matters | Relentless questioning about intent, contradictions, priority, sacrifice, validation, boundaries, and terms |

`normal` is the default thinking scaffold: it asks focused questions before
plan. `hard` keeps pressing until owner decisions are clear enough to plan.

## Documentation Policy

Solon does not reward writing more documents. A good document lets the next
human or AI session quickly understand:

- what changed
- why it changed
- how it was verified
- what should happen next

That is why README stays as a map, GUIDE stays as a practical walkthrough, and
`docs/ko` / `docs/en` hold deeper explanations.
