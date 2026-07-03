---
doc_id: sfs-current-product-shape-en-17
title: "Token / Harness Hygiene"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-28
parent: docs/en/current-product-shape.md
summary: "Token / Harness Hygiene"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Token / Harness Hygiene

SFS bakes token, attention, and harness hygiene into routed context so users do
not need to install separate plugins. The normal operating flow absorbs these habits:

- Token usage check: when token drain feels abnormal, inspect the usage report
  before guessing.
- Thin adapter docs: keep `CLAUDE.md` / `AGENTS.md` / `GEMINI.md`
  frontmatter-only and move durable rules into routed context or docs.
  `sfs agent doctor --fix` archives and rewrites recognized SFS adapter bloat.
- Thin `SFS.md`: keep it as the project router and editable overview, not a
  policy archive. `sfs doctor --fix` preserves `## 프로젝트 개요` while
  restoring the packaged thin router.
- Harness Engineering: raise the AI ceiling with structure, not pleading.
  Keep the active tool surface small, treat the project as the prompt, automate
  verification, and leave product understanding/design choices human-owned.
- Search-before-read in large codebases: prefer symbol or semantic search before
  broad file reads.
- Automate repeated mistakes: turn the same recurring AI mistake into a
  guardrail, check, or hook instead of explaining it again.
- Cache-prefix discipline: static context first, volatile state last, and
  prefix surfaces (adapter docs, policies, model tier) frozen per session —
  a mid-session change invalidates the prompt cache, so land it and restart
  in a fresh session; heavy exploration goes to a scoped worker.
- AI-readiness audit: `sfs harness doctor` scores Sanity (tests, dead code,
  convention consistency, entry-doc freshness) 0-2 per axis before you draw
  the codebase map — signal-only, waivable via `.sfs-local/readiness-waiver`.

The same hygiene applies to Claude, Codex, Gemini, and any other agent through
their equivalent usage reports, LSP/index tools, and hook mechanisms.
