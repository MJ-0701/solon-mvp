---
doc_id: sfs-docs-index-en
title: "Solon Product Docs"
visibility: oss-public
doc_type: docs-index
language: en
updated: 2026-08-27
summary: "Solon Product Docs entry document"
load_when: "Read when this product document is directly relevant."
---
# Solon Product Docs

**Language**: [한국어](../ko/index.md) / English

The README is the product overview and table of contents. These pages hold the
deeper operating model, judgment rules, philosophy, and examples.

## The Problem

Making things with AI is already fast. The bottleneck is flow, not speed.

- Conversations grow long, but **decisions land nowhere**.
- AI changes a lot, yet **what counts as the pass bar blurs**.
- The implementer approves their own output and **independent review slides to the back**.
- Run Claude, Codex, and Gemini together and each agent **behaves as if it sees a different project**.
- A sprint ends with **no one-page context** for whoever picks it up next.

Solon does not build the app skeleton for you. Frameworks and AI do that; Solon
owns **product operation** after that point — intent shaping, verifiable
contracts, independent review, records, handoff — on a thin rail a human can
follow.

## What Solon Provides

The full table is [Feature Overview](./current-product-shape/29-feature-overview.md).
In short, six axes:

| Axis | What it does | Representative surface |
|---|---|---|
| 7-step work rail | deterministic rails own the flow; LLMs are called only inside gates, long or unattended runs recheck intent mid-run, and a self-refutation pass runs before implementation | `sfs start` / `plan` / `implement` / `review` / `retro` |
| Evidence & record | pin approvals, decisions, waivers, external evidence as minimal facts, and the reasoning log on the top risk tier | `sfs capture` / `note` / `recall` |
| Harness engineering | readiness/maturity/cost diagnosis, blueprint, undocumented-codebase excavation, static security audit, overconstraint and redundant-guidance detection, gate activity reading | `sfs harness doctor` / `dig` / `audit` |
| Context & token hygiene | routed context, thin adapters, delegation capsule contracts, instruction classification (inviolable gate vs narrative advisory), cost-per-outcome framing | `sfs context` / `agent doctor` |
| Teams & orchestration | team presets, five organization divisions plus the cross-cutting taxonomy lens as six required council roles, work routing/loops, selective advisor coaching binding, per-stage effort allocation | `sfs team` / `division` / `route` |
| Memory & wiki | long-horizon memory, raw intake, promotion pipeline, derived-doc annotation survival, security finding class closed loop | `sfs ingest` / `tidy --wiki-promote` |

You do not need to memorize commands — tell an agent in plain language and it
maps to these rails (e.g. "배포해줘" → readiness → tests → review → cut → tag →
channel publish → install verify → report).

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

Current Solon documents organization divisions, knowledge packs, and review lenses as
separate surfaces. It has five organization divisions: `dev`, `strategy-pm`,
`qa`, `design`, and `infra`. `.sfs-local/divisions.yaml` retains six compatibility
activation slots for older projects; the `taxonomy` slot is the foundational
cross-cutting product function/lens, not an organization division. Actual guidance is read from the
product-level DDD/TDD, backend, strategy/PM, QA, design/frontend, infra/DevOps,
management-admin, and taxonomy knowledge packs/review lenses. DDD/TDD is the
cross-cutting product behavior floor. Backend is a dev specialization,
management-admin covers finance/bookkeeping/tax/accounting, and taxonomy is a
cross-cutting language/classification lens. The user does not need to memorize
those labels. Solon reads the relevant lens and turns it into plain questions,
plan criteria, or review judgment.
At the same time, all six roles always participate in the conceptual council.
Activation controls read depth and escalation, not whether a council role participates.

Useful agent-skills benchmark practices are absorbed into
`implement`, `review`, `adopt`, `tidy`, and `release` instead of becoming new
commands. This includes source-driven implementation, stop-the-line debugging,
deprecation/migration cleanup, shipping checks, and the `source-docs`,
`simplify`, `security`, `performance`, and `api-contract` review lenses.
When adopting an existing codebase, `sfs adopt --ddd-tdd-retrofit --apply`
diagnoses the DDD-lite boundary state and plants a contract so the next sprint
writes characterization/TDD evidence first, then refactors just one behavior
slice.

Obsidian can be used as a recommended project memory layer. New SFS projects may
start a repo-root vault and `llm-wiki/` map after the scaffold exists; existing
projects can migrate docs by reference after `sfs adopt` so the next sprint
starts from a wiki map instead of a broad repo scan. This is recommended, not a
hard dependency.

Domain expertise becomes leverage when it is compiled into AI-usable assets:
glossaries, domain maps, playbooks, checklists, knowledge packs, review lenses,
skills, fixtures, tests, or wiki TopicHubs. Solon keeps raw source by reference,
records owner/confidence/gaps, and requires human approval before private
know-how becomes shared, public, paid, or cross-team material.

Token Diet reduces routine output tokens without dropping evidence, risk, or
raw traceability. Use `SFS_OUTPUT_STYLE=compact`, `sfs status --compact`,
`sfs start --output-style compact`, or `sfs report --output-style compact` for
compact routine output. Warnings, decisions, reviews, and source evidence stay
in full clarity when compression would lower quality. Caveman/persona speech is
not the default.

As of 0.6.85, the release verifier follows the same rule. Successful internal
install/upgrade smoke logs stay quiet, while failures replay captured stdout and
stderr so release evidence remains traceable.
When the user tells an agent "배포해줘", Solon treats it as "배포 프로세스 쭉
진행해줘", not as publish-only. The release is complete only after readiness
checks, relevant tests, review/검수, release cut, stable tag, Homebrew/Scoop
channel updates, installed runtime verification, and evidence reporting.

Model routing follows the same split and applies by default. Helper-grade simple
I/O uses lighter intake models (Codex `gpt-5.4-mini`), while question generation
and facilitation use standard facilitator models (Codex `gpt-5.4`). Lower-model
outputs that frame questions/options, interpret answers, or affect gate/plan
artifacts require top-model advisor review: Claude Opus 4.7, Codex `gpt-5.5`
xhigh, Gemini `gemini-3.1-pro-preview`, or the custom high-end equivalent.
Gemini routes strategic/research/review to `gemini-3.1-pro-preview`, agentic coding/bounded implementation helpers to `gemini-3-flash-preview`, and relay/probe/economy helpers to `gemini-3.1-flash-lite`; SFS does not use Gemini models below 3.x. Codex normal workers use `gpt-5.4`, simple helpers use
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
RELEASE-NOTES stays for user-facing version changes, CHANGELOG stays for
implementation-level history, and `docs/ko` / `docs/en` hold deeper explanations.
