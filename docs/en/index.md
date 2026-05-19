# Solon Product Docs

**Language**: [한국어](../ko/index.md) / English

The README is the product overview and table of contents. These pages hold the
deeper operating model, judgment rules, philosophy, and examples.

## Start Here

| Page | When to read it |
|---|---|
| [Current product shape](./current-product-shape.md) | To understand the latest Solon operating flow |
| [Windows SFS wrapper incident report](./windows-wrapper-incident-0.6.56.md) | To understand the Windows `sfs.cmd` usage-only / empty-output / UTF-8 / upgrade fix |
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

Current Solon documents divisions, knowledge packs, and review lenses as
separate surfaces. `.sfs-local/divisions.yaml` is the six-slot compatibility
activation state for older projects, while actual guidance is read from the
backend, strategy/PM, QA, design/frontend, infra/DevOps, management-admin, and
taxonomy knowledge packs/review lenses. Backend is a dev specialization,
management-admin covers finance/bookkeeping/tax/accounting, and taxonomy is a
cross-cutting language/classification lens. The user does not need to memorize
those labels. Solon reads the relevant lens and turns it into plain questions,
plan criteria, or review judgment.

Useful agent-skills benchmark practices are absorbed into
`implement`, `review`, `adopt`, `tidy`, and `release` instead of becoming new
commands. This includes source-driven implementation, stop-the-line debugging,
deprecation/migration cleanup, shipping checks, and the `source-docs`,
`simplify`, `security`, `performance`, and `api-contract` review lenses.

Token Diet reduces routine output tokens without dropping evidence, risk, or
raw traceability. Use `SFS_OUTPUT_STYLE=compact`, `sfs status --compact`,
`sfs start --output-style compact`, or `sfs report --output-style compact` for
compact routine output. Warnings, decisions, reviews, and source evidence stay
in full clarity when compression would lower quality. Caveman/persona speech is
not the default.

As of 0.6.85, the release verifier follows the same rule. Successful internal
install/upgrade smoke logs stay quiet, while failures replay captured stdout and
stderr so release evidence remains traceable.

Model routing follows the same split and applies by default. Helper-grade simple
I/O uses lighter intake models (Codex `gpt-5.4-mini`), while question generation
and facilitation use standard facilitator models (Codex `gpt-5.4`). Lower-model
outputs that frame questions/options, interpret answers, or affect gate/plan
artifacts require top-model advisor review: Claude Opus 4.7, Codex `gpt-5.5`
xhigh, Gemini `gemini-3-pro-auto`, or the custom high-end equivalent.
Gemini uses `gemini-3-pro-auto` for every role; SFS does not use Gemini Flash or
2.5 fallback names. Codex normal workers use `gpt-5.4`, simple helpers use
`gpt-5.4-mini`, bounded coding helpers use `gpt-5.3-codex`, and judgment-free
mechanical implementation helpers use `gpt-5.3-codex-spark`. Claude coding-capable
workers/helpers use Sonnet 4.6; Haiku is non-coding helper-only.
Advisor calls do not replace self-CPO PASS. Before external/cross review, the
author records a self-CPO mini-check covering requirements to AC to
implementation slices to ADR/decision ids, every AC mapped to file/artifact/
evidence, and SEED/placeholder/mock/fallback material kept as non-acceptance
until replaced.
External review/check PASS is a continuation trigger, not a stopping point. All
LLM agents continue from PASS to self-CPO first, then cross review.
Session Continuation Guard also applies: `sfs upgrade` updates runtime/project
context, but it cannot shrink an already-open Claude/Codex/Gemini conversation.
At 30% token meter before a new WU/sprint action, or 50% before a new
gate/loop/cross-review, create a compact handoff and resume in a fresh session.

`sfs implement` defaults to Single Agent. Choose `--agent-mode parallel
--agents codex,claude[,gemini]` only when the plan splits into independent
commit units with disjoint files_scope. Parallel implementation records cross
review before Gate 6 review.
Commit messages default to the user's native or workspace language.

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
