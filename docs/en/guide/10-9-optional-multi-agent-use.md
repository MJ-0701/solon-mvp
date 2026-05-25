---
doc_id: sfs-product-guide-en-10
title: "9. Optional Multi-Agent Use"
visibility: oss-public
doc_type: user-guide
language: en
updated: 2026-05-22
parent: docs/en/guide.md
summary: "9. Optional Multi-Agent Use"
load_when: "Read when docs/en/guide.md routes to this section."
---
## 9. Optional Multi-Agent Use

You can use Claude, Codex, and Gemini as a small team, but SFS keeps that pattern
thin by default.

- Use a read-only researcher when a large codebase, dependency change, or domain
  map needs broad context before edits.
- Use implementation workers only after the plan and files_scope are fixed.
- Use an independent evaluator when the generator should not approve its own
  work.
- Share conclusions through the sprint workbench and `docs/solon/domain-map.md`,
  not through long copied transcripts.

Model routing follows that boundary and is applied by default. Helper-grade
simple I/O and non-coding helpers use lighter intake models; Codex maps that to
`gpt-5.4-mini`. Question generation, facilitation, and normal implementation
workers use standard models; Codex maps them to `gpt-5.4`. C-Level and review
use high reasoning. Claude workers and coding helpers use Sonnet 4.6; Haiku is
non-coding helper-only. Gemini routes strategic/research/review to `gemini-3.1-pro-preview`, agentic coding/bounded implementation helpers to `gemini-3-flash-preview`, and relay/probe/economy helpers to `gemini-3.1-flash-lite`.
Lower-model output that frames questions/options, interprets answers, or affects
product identity, architecture, gate, AC, or files_scope requires top-model
advisor review before gate advancement. Advisor means Claude Opus 4.7, Codex
`gpt-5.5` with xhigh reasoning, Gemini `gemini-3.1-pro-preview`, or the custom
high-end equivalent. Gemini routes strategic/research/review to `gemini-3.1-pro-preview`, agentic coding/bounded implementation helpers to `gemini-3-flash-preview`, and relay/probe/economy helpers to `gemini-3.1-flash-lite`; supported Gemini routes stay on 3.x or newer, and SFS does
not use unsupported fallback names such as 2.x, 2.5, or unavailable auto aliases. Helper-grade simple relay and missing-argument prompts are
advisor-exempt. Advisor calls do not replace self-CPO PASS. Before
external/cross review, the author records a self-CPO mini-check covering
requirements to AC to implementation slices to ADR/decision ids, every AC
mapped to file/artifact/evidence, and SEED/placeholder/mock/fallback material
kept as non-acceptance until replaced. `gpt-5.3-codex` is the bounded
repo-aware coding helper for narrow work that still needs code judgment.
`gpt-5.3-codex-spark` is only for already-decided, judgment-free mechanical
implementation chores after scope, files_scope, acceptance criteria, and exact
edit intent are locked. Escalate to high reasoning when a slice touches
architecture, public contracts, security, privacy, data-loss risk, release
gates, or repeated review failure.

Implementation starts in Single Agent mode. Use parallel agents only when the
plan already splits into disjoint files_scope lanes and each lane can name its
own one-sentence commit message. The explicit command is `sfs implement
--agent-mode parallel --agents codex,claude[,gemini] "<work slice>"`. Parallel
lanes need cross review before the final Gate 6 review. Single Agent work also
needs `sfs review --gate 6` after implementation.

When you first run review through a named executor such as Gemini, Codex, or
Claude, SFS checks auth before it creates the full CPO prompt. If auth is
missing, the review stops without recording a failed review run. Run
`sfs auth login --executor gemini` in a real terminal, verify the bridge with
`sfs auth probe --executor gemini`, then rerun the same
`sfs review ... --executor gemini` command. Use `--prompt-only` for manual
web/app handoff.

Commit messages should use the user's native or workspace language unless the
repo explicitly requires English.

Long-running commands can also be wrapped with `sfs measure --alive -- <command>`
when you want visible progress instead of a silent terminal.
