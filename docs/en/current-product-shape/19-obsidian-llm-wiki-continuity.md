---
doc_id: sfs-current-product-shape-en-19
title: "Obsidian LLM Wiki Continuity"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-31
parent: docs/en/current-product-shape.md
summary: "Obsidian LLM Wiki Continuity"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Obsidian LLM Wiki Continuity

SFS recommends Obsidian as an optional companion for project memory. It is free,
local-first, and Markdown-native, so it works well as an LLM retrieval layer
without replacing the source documents.

The practical aim is queryable company memory. Raw work stays in source
locations; `llm-wiki/` keeps source-linked maps, glossary seeds, decisions, and
gaps so future agents can answer project questions by reference instead of
asking the user to repeat context.

For a new project, SFS may recommend a repo-root vault and a small `llm-wiki/`
folder after the normal scaffold exists. The wiki should point to product
design, DDD/TDD method, tests, CI, release paths, and durable domain terms.

For an existing project, `sfs adopt` may recommend a by-reference wiki migration:
keep the original docs as source truth, index the important docs/components, and
start the next real sprint by reading the wiki map before broad repo scans.
If the project never had a real documentation system, the same flow becomes
memory formation: SFS reconstructs a minimal project memory from code, git
commit history, tests, config, release/deploy scripts, issue or PR traces, and
user notes. Missing docs are treated as a gap to fill, not as a reason to ask
the user to explain the whole project again.

The operating model is Raw / Wiki / Schema (+lint). Raw sources remain in docs,
code, tests, scripts, captures, or external evidence. The wiki is a write-time compiled concept/navigation layer:
when new source material or an accepted agent answer arrives, SFS expects the
durable conclusion to become a TopicHub, context map, index entry, or gap note
with source links. Schema and lint keep frontmatter, routing, line budgets,
link checks, and generated indexes from turning the wiki into an uncurated pile.

RAG/vector search can still help, but only as a query-time accelerator over
curated source/wiki metadata. It should not become a pile of arbitrary chunks
that future agents must reinterpret from scratch.

At sprint close, `report.md` and `retro.md` remain the authoritative close
records. `llm-wiki/` is the higher-level memory layer: it should receive only
durable conclusions such as reusable decisions, domain terms, architecture or
release contract changes, repeated defects, and follow-up gaps. The wiki links to the close artifacts instead of copying them wholesale.

The minimum useful baseline is a project map, domain or DDD map, decision
ledger, unknowns/gaps, questions ledger, development guardrails, and bug,
release, or test memory when those surfaces exist. The questions ledger should
mark what is already answered and when it may become stale, so agents do not
ask the user to repeat tacit knowledge that the project has already captured.

`sfs ingest` is the Raw-layer entry mechanic for new sources. It requires a
one-line collection purpose and a `source_type` (`article`, `youtube`,
`podcast`, `book`, or `research`) before writing an intake draft under
`.sfs-local/ingest/`. The draft is only a pointer and compile plan; durable
meaning moves into `llm-wiki/` later by source link, glossary, map, or gap note.

If `.obsidian/` or `llm-wiki/` already exists, SFS treats the project as
Obsidian-applied. Agents should check `llm-wiki/README.md` and
`llm-wiki/ddd/README.md` first, and record a gap or waiver when the expected map
is missing instead of blocking the work.

Host-local tool/skill bundles and user-home folders are external environment,
not project source truth. Obsidian wiki work must not install, clone, scaffold,
or promote them as wiki roots, SFS concepts, install targets, or migration
sources unless the user explicitly asks.

Agents may propose promotion, consolidation, or conflict-resolution patches, but
shared knowledge changes, deletion, sensitive permissions, and private material
movement require human review before merge.

This is a recommended default, not a hard dependency. If the user declines,
Obsidian is unavailable, or the repository cannot carry a vault, SFS continues
with `docs/solon/` artifacts and records the gap or waiver.
