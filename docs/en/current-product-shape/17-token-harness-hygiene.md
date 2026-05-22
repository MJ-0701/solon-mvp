---
doc_id: sfs-current-product-shape-en-17
title: "Token / Harness Hygiene"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/current-product-shape.md
summary: "Token / Harness Hygiene"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
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

