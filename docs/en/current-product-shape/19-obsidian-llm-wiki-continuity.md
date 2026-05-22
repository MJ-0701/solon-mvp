---
doc_id: sfs-current-product-shape-en-19
title: "Obsidian LLM Wiki Continuity"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/current-product-shape.md
summary: "Obsidian LLM Wiki Continuity"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Obsidian LLM Wiki Continuity

SFS recommends Obsidian as an optional companion for project memory. It is free,
local-first, and Markdown-native, so it works well as an LLM retrieval layer
without replacing the source documents.

For a new project, SFS may recommend a repo-root vault and a small `llm-wiki/`
folder after the normal scaffold exists. The wiki should point to product
design, DDD/TDD method, tests, CI, release paths, and durable domain terms.

For an existing project, `sfs adopt` may recommend a by-reference wiki migration:
keep the original docs as source truth, index the important docs/components, and
start the next real sprint by reading the wiki map before broad repo scans.

If `.obsidian/` or `llm-wiki/` already exists, SFS treats the project as
Obsidian-applied. Agents should check `llm-wiki/README.md` and
`llm-wiki/ddd/README.md` first, and record a gap or waiver when the expected map
is missing instead of blocking the work.

Host-local tool/skill bundles and user-home folders are external environment,
not project source truth. Obsidian wiki work must not install, clone, scaffold,
or promote them as wiki roots, SFS concepts, install targets, or migration
sources unless the user explicitly asks.

This is a recommended default, not a hard dependency. If the user declines,
Obsidian is unavailable, or the repository cannot carry a vault, SFS continues
with `docs/solon/` artifacts and records the gap or waiver.
