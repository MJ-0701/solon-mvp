# Current Product Shape

**Language**: [한국어](../ko/current-product-shape.md) / English

This page explains the recent Solon Product changes as one operating model. The
goal is not to make users memorize more commands. The goal is to help the user
keep product-owner judgment strong in an AI-assisted workflow.

## One-Line Summary

Solon turns `start -> brainstorm -> plan -> implement -> review -> report -> retro`
into a loop that converts fuzzy intent into a verifiable work contract. AI can
move quickly, but the user's judgment, language, design intent, and validation
loop stay visible.

```text
fuzzy intent
-> shared understanding
-> plan contract
-> small implementation slice
-> artifact acceptance review
-> report
-> retro close
```

## Handoff After Start

`sfs start "<goal>"` creates the sprint workspace. For new product exploration,
brainstorm is usually the next useful step, so the successful start output shows
the depth options even if the user has not read the guide.

```text
next: sfs brainstorm --simple "..."  # quick cleanup
      sfs brainstorm "..."           # default normal thinking scaffold
      sfs brainstorm --hard "..."    # product-owner hard training
```

This does not replace the core command. The user still says `sfs brainstorm`.
Solon simply exposes the available depth for the shape of the work.

## Three Brainstorm Depths

| Mode | Aliases | Role |
|---|---|---|
| `--simple` | `--easy`, `--quick` | Quickly clean up an already clear direction and prepare a plan seed |
| default `normal` | none | Summarize requirements while asking focused questions about contradictions, priority, success criteria, and validation |
| `--hard` | none | Press the user to think like a product owner about intent, sacrifices, boundaries, and terms |

`normal` is not passive summarization. It is the default thinking scaffold. The
difference between the modes is intensity.

- `simple`: fast cleanup when the answer is already mostly known
- `normal`: the default for most work
- `hard`: hard training when product judgment or system design is blurry

## Purpose Of Hard Mode

`brainstorm --hard` intentionally slows down the "sure, I will just build it"
motion. It keeps asking small but important questions until these things are
visible:

- the real problem being solved
- conflicting desires
- priority and sacrifice
- how success or failure will be judged
- the boundary of the work
- the terms the project should use

This is not less AI assistance. It is AI assistance that strengthens user
ownership before execution starts.

## Plan Is A Contract

`sfs plan` is not a pretty transcript of the brainstorm. The plan should contain:

- measurable acceptance criteria
- in-scope and out-of-scope boundaries for the sprint
- feedback loop, smoke test, review, or validation method
- evaluator criteria for pass, hold, or fail
- the next implementation slice

If a key owner decision is missing, Solon should not fill it with a guess. It
should keep the question open.

## Implement Is Not Only Code

In Solon, implementation artifacts include code, but also:

- documentation updates
- strategy memos
- design handoffs
- taxonomy or domain language work
- QA evidence
- ops/runbooks
- release packaging

In the AI coding era, treating implementation as only code makes the workflow
too narrow. Solon reviews the actual artifact that moved the product forward.

## Review Is Artifact Acceptance

`sfs review` is not always code review. The command stays the same, while Solon
infers the right lens from sprint evidence and changed artifacts.

| Lens | Primary concern |
|---|---|
| `code` | correctness, tests, regressions, maintainability |
| `docs` | reader flow, accuracy, stale claims, missing links |
| `strategy` | decision quality, tradeoffs, feasibility, next action |
| `design` | user flow, consistency, visual/interaction evidence |
| `taxonomy` | terms, categories, naming boundaries |
| `qa` | coverage, smoke evidence, reproduction, residual risk |
| `ops` | runbook, deployment, rollback, observability |
| `release` | version, changelog, package channel, verification |

The user can keep saying `sfs review`. `--lens` is only an override when the
inference is wrong.

## Retro Closes The Sprint By Default

The old split between `retro` and `retro --close` made the final step feel
optional, but a sprint is only complete when it is closed. The current default is:

```text
sfs retro
```

It refines report/retro, archives workbench evidence, closes the sprint state,
and creates the local close commit. Use `sfs retro --draft` only when you want to
open the draft without closing.

## Documentation Shape

README is the map, not the warehouse. Details live in focused pages.

```text
README.md
docs/ko/index.md
docs/en/index.md
docs/ko/current-product-shape.md
docs/en/current-product-shape.md
docs/ko/10x-value.md
10X-VALUE.md
GUIDE.md
docs/en/guide.md
```

GitHub Markdown does not support native language tabs, so Solon uses a
`Language` link at the top of each page.

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
