---
doc_id: llm-wiki-ddd-root
title: "DDD operating model — root"
doc_type: wiki-root
status: template
tags:
  - llm-wiki
  - ddd
  - domain
---

# DDD operating model

The domain-language root for this project. Domain-Driven Design here is an
**operating model**, not ceremony: it keeps the team and the agents using the
same words for the same things, and it draws the boundaries that decide which
source set to load for a task.

## What lives here

Create these notes as the domain stabilises (this skeleton ships them as stubs
to fill in):

- **Bounded contexts** — the major sub-domains and the boundary between them.
  One note per context, or a single `bounded-context-map.md` while small.
- **Ubiquitous language** — the canonical glossary: each domain term, its exact
  meaning, and the terms it must not be confused with. Put it in
  `ubiquitous-language.md`.
- **Migration / evolution model** — how the model changes over time without
  breaking existing data or consumers.

## How to use it

1. When you name a new concept, add it to the ubiquitous language first.
2. When two parts of the system mean different things by the same word, that is
   a context boundary — record it.
3. When entering unfamiliar code, observe behavior and source signals first,
   then record glossary seeds and map gaps before broad change.
4. Route domain questions here from
   [../00-llm-retrieval-guide.md](../00-llm-retrieval-guide.md).

Keep this aligned with how the code actually names things; the value is a shared
vocabulary, not a separate ontology.
