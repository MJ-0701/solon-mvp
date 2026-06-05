---
id: sfs-policy-source-pointer-citation
summary: Cite external knowledge by namespaced pointer (idea_wiki:LNNN-In), never by copying content; advisory and runtime-independent.
load_when:
  - source pointer
  - external knowledge
  - citation
  - idea_wiki
  - evidence pointer
---

# Source Pointer Citation

Plan, review, and retro evidence often draws on an external knowledge base. Cite
it by a **namespaced pointer**, never by copying its content into product
artifacts. Copying launders provenance and drifts out of sync; a pointer keeps
the source authoritative and the citation auditable.

## Pointer format

- `idea_wiki:LNNN-In` — a numbered lesson/insight entry.
- `idea_wiki:theme-N` — a theme cluster.
- `idea_wiki:product-idea-N` — a product idea.

The namespace prefix names the external wiki; the suffix is its stable internal
id. Cite the pointer plus a one-line gist in your own words — not the source
text. Consumers point the namespace at their own external wiki via the
`{{EXTERNAL_WIKI_NAMESPACE}}` placeholder, keeping the format while swapping the
target (templates-compatibility principle).

## Contract

- **No content copy.** A pointer and a short original gist are allowed; pasted
  source passages are not. If the meaning matters durably, compile it into the
  project's own docs/wiki and cite that, with the external pointer as origin.
- **Advisory, runtime-independent.** Pointers are evidence, not a dependency.
  Every command behaves identically in an environment that cannot resolve them
  (no wiki present). Never gate, block, or error on an unresolvable pointer.
- **No absolute paths.** Cite the namespace (`idea_wiki:`), never a filesystem
  path to anyone's private wiki checkout.

## Cross-references

- External orchestrator entry: `policies/external-orchestrator-entry.md`.
- Durable-meaning promotion: `policies/lessons-accumulation.md`,
  `policies/obsidian-llm-wiki.md`.
