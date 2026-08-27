---
doc_id: sfs-current-product-shape-en-22
title: "Project Harness Map"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-08-27
parent: docs/en/current-product-shape.md
summary: "Project Harness Map"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Project Harness Map

Harness Engineering becomes useful when the environment around the model is
visible and testable. SFS now exposes that environment directly:

- `sfs harness doctor` checks whether the current project has thin entry docs,
  routed context, all six required council roles (five organization divisions
  plus the cross-cutting taxonomy product function/lens), artifact/memory surfaces, wiki or
  bug recurrence memory, tests, and release/check rails. It also scores the
  AI-readiness (Sanity) rubric (4 axes, 0-2 each) and surfaces session cost
  signals from the host log (Claude Code / Codex / Gemini adapters: tokens,
  cache-read ratio, explore/edit mix) — all signal-only, never blocking.
- `sfs harness map` prints the project harness: agents, skills/policies,
  orchestrator rails, artifacts, memory, tests, release loop, and human-owned
  boundaries.
- `sfs harness map --write` writes `.sfs-local/harness/harness-map.md` so long
  autonomous work and optional parallel-agent work can start from an explicit
  operating design. When no readiness audit or `.sfs-local/readiness-waiver` is
  recorded it prints a one-line readiness advisory (Sanity before cartography)
  — the map itself is always written.

The map also records harness-specific design evidence:

- generated-harness audit: declared agents, skills, orchestrator pointers, and
  change history must match the filesystem before extension;
- optional team architecture: pipeline, fan-out/fan-in, expert pool,
  producer-reviewer, supervisor, or hierarchical delegation;
- harness evolution: initial design vs shipped design, feedback source, and the
  tests/policies/skills/scaffold defaults promoted from repeated deltas.
- concrete ledger: `sfs harness map --write` also creates
  `.sfs-local/harness/evolution-ledger.md` when absent. It records source,
  baseline, shipped delta, hypothesis, acceptance signal, promotion target,
  decision, evidence paths, and next check.

The command does not run workers. It makes the project-as-prompt structure
auditable before the AI starts moving fast.
