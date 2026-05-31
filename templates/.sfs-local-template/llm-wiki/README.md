---
doc_id: llm-wiki-readme
title: "llm-wiki — long-horizon knowledge vault"
doc_type: wiki-root
status: template
tags:
  - llm-wiki
  - knowledge
---

# llm-wiki

This folder is your project's **long-horizon knowledge vault** — the durable,
human- and agent-readable layer that survives individual sessions. It is created
by `sfs init` / `sfs upgrade` as an **empty, manually maintained skeleton**. You
own it; you grow it.

## The Raw / Wiki / Schema model

Solon separates knowledge into three layers:

- **Raw** — source material as captured: session transcripts, logs, meeting
  notes, lecture dumps, pasted research. High volume, low structure. Lives
  outside this folder (e.g. session logs, `.sfs-local/` state).
- **Wiki** — *this folder*. Distilled, linked notes that a human or an agent
  reads to understand the project: retrieval maps, domain language, decisions,
  recurring-bug memory. Curated by hand from Raw.
- **Schema** — the structural contract every Wiki note follows: frontmatter
  conventions (`doc_id`, `title`, `tags`, …) and index/link rules. See
  [_FRONTMATTER.md](_FRONTMATTER.md). The contract is enforced by lint, not by
  a generator.

## Manually maintained — no generator dependency

This skeleton ships **without** a graph/index generator. Nothing here depends on
a generated index to be readable. Add notes by hand, link them with normal
Markdown links, and keep the frontmatter contract. If you later adopt a
generator or graph tool, it is purely additive — the vault stays valid without
it.

## Layout

- [00-llm-retrieval-guide.md](00-llm-retrieval-guide.md) — how an agent should
  read this vault (read order + topic routing). Edit it as your map grows.
- [_FRONTMATTER.md](_FRONTMATTER.md) — the frontmatter convention every note
  follows.
- [ddd/README.md](ddd/README.md) — domain-model (DDD) operating root: bounded
  contexts, ubiquitous language.
- [bug-reports/README.md](bug-reports/README.md) — recurring-failure memory:
  one note per bug class, so the same defect is not re-debugged from zero.

## How to grow it

1. Capture Raw as it happens (don't pre-curate).
2. When a fact, decision, or boundary stabilises, write one focused Wiki note
   here with the frontmatter from [_FRONTMATTER.md](_FRONTMATTER.md).
3. Link it from [00-llm-retrieval-guide.md](00-llm-retrieval-guide.md) so agents
   find it.
4. Keep notes short and atomic; prefer linking over duplicating.
