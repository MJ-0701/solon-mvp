---
id: sfs-command-ingest
summary: Create a purpose-gated raw intake stub before compiling material into llm-wiki.
load_when: ["ingest", "raw intake", "source_type", "llm-wiki", "Gold In"]
---

# Ingest

`sfs ingest` records a small Raw-layer intake stub. It is not a crawler, RAG
sync, transcript recorder, summarizer, or wiki compiler.

Required inputs:

- `--source-type article|youtube|podcast|book|research`
- `--purpose "<why this source, for which question>"`

Optional inputs:

- `--title "<source title>"`
- `--url "<source URL>"`

Behavior:

- Fail before writing if the collection purpose is empty.
- Fail before writing if `source_type` is outside the enum.
- Write `.sfs-local/ingest/<timestamp>-<slug>.md` as Raw workbench state.
- Leave `compile_to_wiki: pending`; durable meaning moves to `llm-wiki/` later
  by source link, glossary seed, map update, or gap note.

Review questions:

- Is the purpose clear enough to decide whether this source belongs in the
  wiki later?
- Is the source type specific, or is the source being dumped as miscellaneous
  residue?
- Did the agent avoid copying bulky raw content into `llm-wiki/`?
