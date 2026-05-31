---
doc_id: llm-wiki-frontmatter-convention
title: "Frontmatter convention (Schema layer)"
doc_type: wiki-schema
status: template
tags:
  - llm-wiki
  - schema
---

# Frontmatter convention

Every note in this vault begins with a YAML frontmatter block. This is the
**Schema** layer of the Raw / Wiki / Schema model — the structural contract that
keeps notes machine-discoverable without a generator.

## Required keys

```yaml
---
doc_id: <stable-kebab-slug>     # unique within the vault; never reuse
title: "<human-readable title>"
doc_type: <wiki-root|wiki-guide|wiki-schema|note|map|decision|bug-report>
tags:
  - <topic>                     # 1+ topic tags for routing
---
```

## Conventions

- `doc_id` is stable: rename the file freely, but keep `doc_id` so links and
  references survive.
- `title` is what an agent shows the user; keep it short and specific.
- `tags` route the note in [00-llm-retrieval-guide.md](00-llm-retrieval-guide.md);
  add the note's primary topic.
- Link between notes with normal Markdown links (`[text](path.md)`). Backlinks
  are implicit — keep links bidirectional where it helps retrieval.
- Optional keys you may add per project: `created`, `updated`, `status`,
  `visibility`, `related`. Add-only; do not repurpose the required keys.

## Why no generator

The contract above is enough for an agent to read and route the vault by hand.
A lint check can enforce presence of the required keys; a generator is optional
and additive. Keeping the Schema lint-enforced (not generator-enforced) means
the vault is always valid even in a fresh clone with no tooling installed.
