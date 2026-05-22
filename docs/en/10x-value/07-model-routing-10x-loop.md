---
doc_id: sfs-10x-value-en-7
title: "Model Routing 10x Loop"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/10x-value.md
summary: "Model Routing 10x Loop"
load_when: "Read when docs/en/10x-value.md routes to this section."
---
## Model Routing 10x Loop

Solon's model routing is not "use the most expensive model for everything." It
is an operating principle: match the model to the weight of the decision. Fast
helpers should stay fast. Product identity, architecture, acceptance criteria,
and review decisions should escalate to the strongest advisor because they are
expensive to reverse.

| Role | Solon contract | 10x effect |
|---|---|---|
| Helper-grade intake | simple relay, missing-argument questions, low-risk short summaries | reduce waiting time |
| Facilitator / question | brainstorm questions, option framing, answer summaries | sharpen scope through better questions |
| C-Level / review | intent, architecture, AC, review, escalation judgment | spend reasoning on expensive decisions |
| Worker | fixed implementation slices after plan and files_scope are locked | keep execution separate from approval |
| Bounded helper | grep, formatting, sync, deterministic chores | avoid spending top-model time on mechanical work |

This routing is the default. The user does not need to configure it first.
`current_model` is an explicit opt-out for projects that want to keep the
currently selected model without role separation. Model names are SFS
role/profile contracts; SFS does not assume every CLI supports a `--model` flag.
The default bridge requests the role through prompt and host/runtime settings.
Use `SFS_REVIEW_<EXECUTOR>_CMD` only for a verified explicit override.

For Codex, helper-grade intake and non-coding helpers map to `gpt-5.4-mini`,
question/facilitation and normal workers map to `gpt-5.4`, advisor/review maps
to `gpt-5.5` xhigh, bounded repo-aware coding helpers map to `gpt-5.3-codex`,
and judgment-free mechanical implementation helpers map to
`gpt-5.3-codex-spark`. Claude follows an Opus/Sonnet 4.6/Haiku responsibility
split: coding-capable worker/helper lanes use Sonnet 4.6, and Haiku is
non-coding helper-only. Gemini uses `gemini-3-pro-auto` for every role; SFS
does not use Gemini Flash or 2.5 fallback names. Substantive research should
prefer a Gemini 3 Pro auto researcher when available.

Helper-grade simple I/O can skip advisor review. But if lower-model output
frames questions/options, interprets user answers, or affects product identity,
architecture, gates, AC, or files_scope, top-model advisor review is required.

Advisor calls do not replace self-CPO PASS. Before external/cross review, the
author records a self-CPO mini-check covering requirements -> AC ->
implementation slices -> ADR/decision ids, every AC mapped to file/artifact/
evidence, and SEED/placeholder/mock/fallback material remaining
non-acceptance until replaced by real deliverables.

`gpt-5.3-codex` is a narrow coding helper, not the normal worker default.
`gpt-5.3-codex-spark` is narrower still: use it only for already-decided,
judgment-free mechanical implementation chores after scope, files_scope, AC, and
exact edit intent are locked. If architecture, public contract, security,
privacy, data-loss, release gate, or repeated failure risk appears, worker work
escalates to high reasoning.

