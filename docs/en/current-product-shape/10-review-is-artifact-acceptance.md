---
doc_id: sfs-current-product-shape-en-10
title: "Review Is Artifact Acceptance"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-25
parent: docs/en/current-product-shape.md
summary: "Review Is Artifact Acceptance"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Review Is Artifact Acceptance

`sfs review` is not always code review. The command stays the same, while Solon
infers the right lens from sprint evidence and changed artifacts.

GitHub `@codex` PR/code review is external evidence only. A PR approval,
GitHub check PASS, or `@codex` comment does not replace `sfs review`,
self-CPO, SFS cross review, or Gate 3/Gate 6 PASS.

External review/check PASS is a continuation trigger, not a stopping point.
Codex, Claude, Gemini, and future LLM agents do not end at PASS; they continue
with the next unmet SFS review command: self-CPO first, then the configured
cross-review order after self-CPO PASS.

Session Continuation Guard covers the host conversation itself. Even when
`sfs upgrade` is current, an already-open Claude/Codex/Gemini conversation
keeps its history and token meter. At 30% before the first implementation or
review action of a new WU/sprint, 50% before a new gate/loop/cross-review, or
after multiple WUs/sprints or loop wakeups in the same chat, agents write a
compact handoff with `report.md`, `review.md`, capture ids, commit/branch, and
the next SFS command, then resume in a fresh session. This is autopilot, not a
same-session-vs-fresh-session question: use host clear/new-session when
available, otherwise stop with the exact next-session prompt/command.

| Lens | Primary concern |
|---|---|
| `code` | correctness, tests, regressions, maintainability |
| `docs` | reader flow, accuracy, stale claims, missing links |
| `source-docs` | official docs/source/version evidence |
| `simplify` | behavior-preserving simplification, dead-code removal |
| `security` | auth, secrets, PII, untrusted input boundaries |
| `performance` | baseline, target metric, measured regression risk |
| `api-contract` | public interface, schema, errors, compatibility |
| `strategy` | decision quality, tradeoffs, feasibility, next action |
| `design` | user flow, consistency, visual/interaction evidence |
| `taxonomy` | terms, categories, naming boundaries |
| `qa` | coverage, smoke evidence, reproduction, residual risk |
| `ops` | runbook, deployment, rollback, observability |
| `management-admin` | finance records, bookkeeping, tax/accounting questions, cash evidence |
| `release` | version, changelog, package channel, verification |

The user can keep saying `sfs review`. Agent-skills-style judgment stays inside
existing review lenses rather than becoming new commands. `--lens` is only an
override when the inference is wrong.

Review loops should close small deterministic findings without bouncing work
back to the user. If a partial/fail result points at grep scope, stale measured
evidence, missing AC-to-file/artifact mapping, an evidence path typo, or
documentation consistency that preserves meaning, the agent should patch it,
run the smallest verification, and invoke the same gate review again in the
same cycle. Ask the user only when product judgment is required: scope,
architecture, public contract, security/privacy/data-loss posture,
cost/latency/model policy, destructive behavior, or changed AC meaning.

Current `sfs review` is commit-aware. A clean working tree no longer means
the review prompt is empty: SFS includes reviewable files from the latest commit,
current shared handoff docs, and small ADR/report documents in full within the
bounded evidence cap.

When a closed sprint needs another review, do not hand-edit
`.sfs-local/current-sprint` or extract archives manually. Use
`sfs review --sprint <id> --gate <n>`. SFS restores the latest cold archive into
the workbench and does not overwrite already visible workbench docs.
