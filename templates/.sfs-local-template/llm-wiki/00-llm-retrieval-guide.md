---
doc_id: llm-wiki-retrieval-guide
title: "LLM Retrieval Guide"
doc_type: wiki-guide
status: template
tags:
  - llm-wiki
  - retrieval
---

# LLM Retrieval Guide

How an agent should read this vault. This is a **manual** map: there is no
generated index. Keep this file current by hand as you add notes.

## Default Read Order

1. Start at [README.md](README.md) — the Raw / Wiki / Schema model and how this
   vault is organised.
2. Read [project-context.md](project-context.md) — the initial purpose, user,
   core output, core question, and known boundaries.
3. Read [_FRONTMATTER.md](_FRONTMATTER.md) before writing a new note.
4. For domain/behaviour questions, read [ddd/README.md](ddd/README.md) (bounded
   contexts + ubiquitous language).
5. For a recurring failure or "have we hit this before?", read
   [bug-reports/README.md](bug-reports/README.md).

## Entry Sequence

Observe first. Before broad scans or changes, gather the smallest useful
evidence set: running behavior, logs or metrics when available, git history,
tests, config, scripts, and release paths. Convert stable terms into glossary
seeds and update maps or gaps so the next query starts from structure.
Self-serve retrieval comes before broad questions: use this vault as the
knowledge refrigerator, then ask only for the missing product judgment.

## Topic Routing

Replace these stubs with your project's real entry points as the vault grows.
Each line should route a class of question to the note(s) that answer it.

- **Project operation / setup** → (link your operating doc here)
- **Product / domain design** → [ddd/README.md](ddd/README.md)
- **Initial project context** → [project-context.md](project-context.md)
- **Decisions & their rationale** → (link your decisions log here)
- **Recurring bugs / quality memory** → [bug-reports/README.md](bug-reports/README.md)
- **History / past reasoning** → (link your session or learning log here)

## Local vs Global Queries

- **Local question** (a specific entity, fact, or decision — "what is X",
  "why did we decide Y"): open that note, then follow its Markdown links to the
  few connected notes.
- **Global question** (a corpus-spanning trend — "what themes recur across the
  whole vault"): skim the topic-routing hubs above and synthesise. With no
  generator, *you* are the synthesiser at read time.

## Retrieval Rules

- Treat your project's operational state files as live state, not durable
  history.
- Prefer the smallest note set that answers the question; follow links rather
  than loading everything.
- When the vault has no note for a question, that is a signal to **write one**
  after you answer it.
- Do not ask the user to refill context that the vault already captures.
