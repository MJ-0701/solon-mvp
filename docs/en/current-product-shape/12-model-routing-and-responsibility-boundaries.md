---
doc_id: sfs-current-product-shape-en-12
title: "Model Routing And Responsibility Boundaries"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/current-product-shape.md
summary: "Model Routing And Responsibility Boundaries"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Model Routing And Responsibility Boundaries

The same responsibility split applies to model selection. The model that plans
the contract and the worker that implements a fixed slice do not have the same
job.

| Role | Responsibility | Default model route |
|---|---|---|
| Helper-grade intake | Simple relay, missing-argument prompts, low-risk short summaries, tiny read-only notes | Claude uses the Haiku tier for non-coding helpers only; Codex uses `gpt-5.4-mini` |
| Facilitator / question | Brainstorm question generation, option framing, answer summaries | Claude uses the Sonnet 4.6 tier; Codex uses `gpt-5.4` |
| C-Level / review | Intent, architecture, AC, review, escalation | High reasoning. Codex uses `gpt-5.5`; Claude uses the Opus tier |
| Claude worker | Fixed files_scope implementation slice | Sonnet 4.6 tier |
| Codex worker | Fixed files_scope implementation slice that still needs code judgment | `gpt-5.4` |
| Codex helper | Simple relay, grep summaries, formatting, and non-coding helper chores | `gpt-5.4-mini` |
| Codex coding helper | Narrow repo-aware code support | `gpt-5.3-codex` |
| Codex mechanical implementation helper | Already-decided, judgment-free simple implementation chores | `gpt-5.3-codex-spark` |

This routing is the default. Users do not need to configure it separately.
`current_model` is an explicit opt-out for projects that want the currently
selected host model for every role. Helper-grade simple I/O is advisor-exempt.
When a lower-model output frames questions/options, interprets answers, or
affects product identity, architecture, gate, AC, or files_scope, top-model
advisor review is required before gate advancement. Advisor means Claude Opus
4.7, Codex `gpt-5.5` with xhigh reasoning, Gemini `gemini-3-pro-auto`,
or the custom high-end equivalent. Gemini uses `gemini-3-pro-auto` for every
role; SFS does not use Gemini Flash or 2.5 fallback names.
Advisor calls do not replace self-CPO PASS. Before external/cross review, the
author records a self-CPO mini-check covering requirements to AC to
implementation slices to ADR/decision ids, every AC mapped to file/artifact/
evidence, and SEED/placeholder/mock/fallback material kept as non-acceptance
until replaced.

For Codex, the normal implementation worker is `gpt-5.4`. `gpt-5.3-codex` is a
bounded repo-aware coding helper, not the normal worker default. Spark is
narrower: use `gpt-5.3-codex-spark` only for already-decided mechanical
implementation chores after scope, files_scope, acceptance criteria, and exact
edit intent are locked. Examples include file moves, import/path rewrites,
generated index sync, and deterministic test expectation updates. If a slice
touches architecture, public contracts, security, privacy, data-loss risk,
release gates, or repeated review failure, escalate to high reasoning or send
it back to C-Level. Claude coding-capable worker/helper lanes use Sonnet 4.6;
Haiku must not write code. Substantive research should prefer a Gemini 3 Pro
auto researcher when available.

Implement execution defaults to Single Agent. Users can opt into multiple
agents, but only after the plan is split into independent lanes. Each lane must
have disjoint files_scope and a one-sentence proposed commit message. If that
sentence is unclear, do not split the work. Parallel agent implementation must
record cross review evidence before `sfs review --gate 6` can pass, and Single
Agent implementation still requires Gate 6 review before completion.

Named executor review for Gemini, Codex, and Claude must pass auth preflight
before SFS creates the full CPO prompt. On a new project or terminal, an
unauthenticated `sfs review --executor gemini` stops without writing review
artifacts. Run `sfs auth login --executor gemini` in a real terminal, verify the
bridge with `sfs auth probe --executor gemini`, then rerun the same review
command. Use `--prompt-only` for manual web/app handoff.

Commit messages default to the user's native or workspace language. English is
the default only when English is the user/repo language; otherwise agents should
write the message in the language the user actually works in.
Solon commit grouping belongs to the SFS command surface, not a host-local
`/commit` skill. Use `sfs commit plan` to inspect groups and
`sfs commit apply --group <name>` to commit and push the selected group. Use
`--no-push` only for SFS release sandboxes or explicitly offline work.

