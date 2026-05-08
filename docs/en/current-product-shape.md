# Current Product Shape

**Language**: [한국어](../ko/current-product-shape.md) / English

This page explains the recent Solon Product changes as one operating model. The
goal is not to make users memorize more commands. The goal is to help the user
keep product-owner judgment strong in an AI-assisted workflow.

## One-Line Summary

Solon turns `start -> brainstorm -> plan -> implement -> review -> retro`
into a loop that converts fuzzy intent into a verifiable work contract. AI can
move quickly, but the user's judgment, language, design intent, and validation
loop stay visible.

```text
fuzzy intent
-> shared understanding
-> plan contract
-> small implementation slice
-> artifact acceptance review
-> retro close with report
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

The user still types `sfs brainstorm`. Solon simply exposes the available
depth options for the shape of the work.

## Windows Wrapper Stabilization

The Windows PowerShell/cmd user entrypoint is fixed to `sfs.cmd`. Git Bash/WSL
keep using `sfs`, like macOS/Linux. As of 0.6.53, the Scoop manifest keeps the
generated shim target on packaged `bin\sfs.ps1`, but the post-install hook
overwrites the shims-directory `sfs.cmd`, `sfs.ps1`, and extensionless `sfs`
with deterministic wrappers because generated `sfs.cmd` / `sfs.ps1` shims can
drop arguments before the package sees them. The PowerShell/cmd smoke and user
guidance only treat the verified `sfs.cmd` route as the Windows pass condition.
Packaged `sfs.cmd` remains a direct-run compatibility trampoline and passes
arguments to `sfs.ps1` through the `SFS_NATIVE_ARGC` / `SFS_NATIVE_ARG_N`
numbered env bridge. If that is also empty, `sfs.ps1` reads the original
`SFS_NATIVE_RAW_ARGS`, delayed-expansion `SFS_NATIVE_CMDLINE`, and `CMDCMDLINE` as fallbacks.
Saved command-line parsing also trims `cmd.exe` shell-control tails such as `&& sfs.cmd --help`.
`sfs.ps1` owns both read-only commands and mutating commands such as
`start`. Mutating commands go through the `sfs.cmd -> sfs.ps1 -> Bash runtime`
bridge. The hardened Scoop `sfs.cmd` shim also keeps `%*` as a positional
fallback after writing the numbered env bridge; that is different from the old
single-source `-File ... %*` bridge that failed under generated Scoop shims. The
raw Git Bash `%*` path, batch-label forwarding path,
single-source `-File ... %*` bridge, `-Command @args` bridge, empty `%1..%n` path, generated bare
`sfs` PowerShell shim path, generated shim -> packaged `.cmd` path, and generated `sfs.cmd` shim path are no longer defaults because
they already failed for sandbox startup, argument forwarding,
UTF-8 output, and Scoop shims. `sfs.cmd upgrade` also delegates Scoop
self-upgrade to `sfs.ps1` instead of running `scoop update sfs` from the batch
file that Scoop replaces. `sfs.ps1` normalizes numbered env bridge args,
the raw arg tail, the saved cmdline, PowerShell automatic `$args`, `CMDCMDLINE`, and `$MyInvocation.UnboundArguments`, and owns `version`,
`status`, `guide`, `context`, Scoop self-upgrade, and Bash fallback. `sfs.cmd`
exits on the same parsed line after calling PowerShell, and Windows runtime `.ps1` / `.cmd`
files stay ASCII-safe for Windows PowerShell 5.1. That covers the `context cat`
/ `start` usage-only regression, the batch tail-fragment regression, and the
PowerShell parser regression.

An empty sprint directory after `sfs start` can be normal. Step files are created
later by `brainstorm`, `plan`, `review`, and `retro`. Empty command output,
usage-only `sfs.cmd status`, or usage-only `sfs.cmd context cat kernel` is a
failure signal. The full root cause and validation flow are in the
[Windows SFS wrapper incident report](./windows-wrapper-incident-0.6.53.md).

## Three Brainstorm Depths

| Mode | Aliases | Role |
|---|---|---|
| `--simple` | `--easy`, `--quick` | Quickly clean up an already clear direction and prepare a plan seed |
| default `normal` | none | Summarize requirements while asking focused questions about contradictions, priority, success criteria, and validation |
| `--hard` | none | Press the user to think like a product owner about intent, sacrifices, boundaries, and terms |

The three modes step up in pressure: quick cleanup, thinking scaffold, hard
training.

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
- management/admin evidence: invoices, receipts, cashflow, tax/accounting
  questions, monthly close notes

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
| `management-admin` | finance records, bookkeeping, tax/accounting questions, cash evidence |
| `release` | version, changelog, package channel, verification |

The user can keep saying `sfs review`. `--lens` is only an override when the
inference is wrong.

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

## Model Routing And Responsibility Boundaries

The same responsibility split applies to model selection. The model that plans
the contract and the worker that implements a fixed slice do not have the same
job.

| Role | Responsibility | Default model route |
|---|---|---|
| Helper-grade intake | Simple relay, missing-argument prompts, low-risk short summaries | Claude uses the Haiku tier; Codex uses `gpt-5.4-mini` |
| Facilitator / question | Brainstorm question generation, option framing, answer summaries | Claude uses the Sonnet tier; Codex uses `gpt-5.4` |
| C-Level / review | Intent, architecture, AC, review, escalation | High reasoning. Codex uses `gpt-5.5`; Claude uses the Opus tier |
| Claude worker | Fixed files_scope implementation slice | Sonnet tier |
| Codex worker | Fixed files_scope implementation slice | `gpt-5.3-codex` |
| Codex helper | Mechanical grep, formatting, sync, and similar chores | `gpt-5.3-codex-spark` |

This routing is the default. Users do not need to configure it separately.
`current_model` is an explicit opt-out for projects that want the currently
selected host model for every role. Helper-grade simple I/O is advisor-exempt.
When a lower-model output frames questions/options, interprets answers, or
affects product identity, architecture, gate, AC, or files_scope, top-model
advisor review is required before gate advancement. Advisor means Claude Opus
4.7, Codex `gpt-5.5` with xhigh reasoning, Gemini `gemini-3.1-pro-preview`,
or the custom high-end equivalent. Gemini helper-grade fallback uses
`gemini-3-flash-preview`; SFS does not use 2.5 fallback names.
Advisor calls do not replace self-CPO PASS. Before external/cross review, the
author records a self-CPO mini-check covering requirements to AC to
implementation slices to ADR/decision ids, every AC mapped to file/artifact/
evidence, and SEED/placeholder/mock/fallback material kept as non-acceptance
until replaced.

Spark is fast, but it is not the normal implementation worker. Use it only for
small mechanical subtasks after scope, files_scope, and acceptance criteria are
locked. If a slice touches architecture, public contracts, security, privacy,
data-loss risk, release gates, or repeated review failure, escalate to high
reasoning or send it back to C-Level.

Implement execution defaults to Single Agent. Users can opt into multiple
agents, but only after the plan is split into independent lanes. Each lane must
have disjoint files_scope and a one-sentence proposed commit message. If that
sentence is unclear, do not split the work. Parallel agent implementation must
record cross review evidence before `sfs review --gate 6` can pass, and Single
Agent implementation still requires Gate 6 review before completion.

Commit messages default to the user's native or workspace language. English is
the default only when English is the user/repo language; otherwise agents should
write the message in the language the user actually works in.

## Design.md And Anti-AI-Slop Guardrails

As of 0.6.26, design/frontend work treats `design.md` or
`docs/solon/design.md` as the AI-readable design-system contract. The file is a
small contract for colors, typography, spacing, radius, shadow, component
variants, icon style, forbidden values, and rationale.

The common AI failure mode is regression toward average-looking UI. If every
screen invents new colors, spacing, radius, icon weights, or generic SaaS
gradients, the feature can work while the product loses taste and identity.
Solon's design review treats that as AI-slop risk and checks token drift,
Korean typography fit, and desktop/mobile screenshot evidence.

Wanted Montage-style components, a coherent icon family such as Coolicons, and
a Korean-capable font such as Pretendard can be useful starter references for
Korean products. They are starting points, not vendor lock-in. If an existing
product design system exists, it wins.

## Division Knowledge Packs

As of 0.6.53, the backend, strategy/PM, QA, design/frontend, infra/DevOps,
management/admin, and taxonomy packs are no longer placeholders. Each pack gives
Solon a compact sense of what to watch, what to ask, and what evidence should
count for that kind of work.

The user should not need to memorize this list. Solon reads only the lens that
fits the work. A small docs edit stays light. A release, architecture change, or
risky workflow gets stronger questions and evidence checks. The criteria become
richer while the user-facing surface stays simple.
Taxonomy stays as a cross-cutting language/classification lens rather than a
business department. Finance, bookkeeping, tax, and accounting live under the
management/admin lens.

## Retro Closes The Sprint By Default

A sprint is complete when it is closed, and `sfs retro` does that in one step:

```text
sfs retro
```

It refines `report.md` and `retro.md`, packs workbench evidence and temporary
review scratch into one cold archive bundle, closes the sprint state, and
creates the local close commit. Use `sfs retro --draft` when you want to open
the draft without closing.
Older installs that still have loose sprint archives or separate review-run
archives are compacted by `sfs upgrade` into compressed migration bundles.
Runtime upgrade, agent install, and profile rollback backups are also kept as
`*.tar.gz` + `manifest.txt` bundles instead of loose project files.
In thin layout, project-local `.claude/`, `.gemini/`, and `.agents/`
command/skill adapters are also removed from the default surface. Root adapter
docs point agents at the global `sfs` runtime, and projects that still need
native slash/skill files can opt in with `sfs agent install all`.
Global `sfs` / `sfs.cmd upgrade` also promotes existing vendored projects to
the thin surface. Use `sfs upgrade --layout vendored` only when a project must
keep runtime files locally.

## Documentation Shape

README is the map, not the warehouse. Details live in focused pages.

```text
README.md
GUIDE.md
docs/ko/index.md          docs/en/index.md
docs/ko/current-product-shape.md   docs/en/current-product-shape.md
docs/ko/10x-value.md       docs/en/10x-value.md
docs/en/guide.md
```

Each page has a `Language` link at the top to swap between Korean and English.

## Token / Harness Hygiene

SFS bakes token and attention hygiene into routed context so users do not need
to install separate plugins. The normal operating flow absorbs four habits:

- Token usage check: when token drain feels abnormal, inspect the usage report
  before guessing.
- Thin adapter docs: keep `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` slim and move
  durable rules into routed context or docs.
- Search-before-read in large codebases: prefer symbol or semantic search before
  broad file reads.
- Automate repeated mistakes: turn the same recurring AI mistake into a
  guardrail, check, or hook instead of explaining it again.

The same hygiene applies to Claude, Codex, Gemini, and any other agent through
their equivalent usage reports, LSP/index tools, and hook mechanisms.

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
