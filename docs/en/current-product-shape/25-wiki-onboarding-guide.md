---
doc_id: sfs-current-product-shape-en-25
title: "Wiki start guide — why strongly recommended, and the 10-minute path"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-06-06
parent: docs/en/current-product-shape.md
summary: "Why the LLM wiki is strongly recommended, a 10-minute project llm-wiki start, opening the Obsidian vault, a personal external knowledge wiki, and the pointer-citation rule."
load_when: "Read at onboarding (new project before the first sprint, existing project at sfs adopt) when deciding whether and how to build the wiki."
---
## Wiki start guide — why strongly recommended, and the 10-minute path

The LLM wiki is **strongly recommended by default**, not optional decoration.
This guide is the active-guidance entry that `install.sh`, `sfs adopt`, and
`sfs harness doctor` point to. It never gates a sprint — declining is allowed,
it only costs you the leverage below (record `.sfs-local/llm-wiki.waiver` and
continue). The policy SSoT is `policies/obsidian-llm-wiki.md`; this page is the
operator-facing how-to, not a re-statement of it.

### 1. Why strongly recommended

- **Agent self-serve context.** A compiled `llm-wiki/` lets the next agent load
  the slice it needs instead of re-deriving the project from raw code each time.
- **Cross-session memory.** Durable meaning survives `/clear`, new sessions, and
  handoff — the long-horizon layer that report/retro logs are not.
- **No repeated explanation.** A questions ledger plus TopicHubs stop you from
  re-explaining the same project on every cold start.

When: a **new** project builds it before the first real sprint; an **existing**
project builds it at `sfs adopt`, before the next sprint relies on it.

### 2. Start the project `llm-wiki/` (10-minute course)

The install scaffold ships four starting files under `llm-wiki/`. Fill them by
reference — link to source truth, do not paste large docs:

1. `README.md` — wiki home: what this project is, the top TopicHubs/maps.
2. `00-llm-retrieval-guide.md` — how an agent should retrieve before broad scans.
3. `project-context.md` — purpose, primary user, core output, first question,
   the boundary that must not be confused (the install interview pre-fills this).
4. `_FRONTMATTER.md` + `ddd/` + `bug-reports/` — DDD language home and bug
   recurrence memory.

That is the minimum baseline. Deeper migration/memory-formation flows live in
`policies/obsidian-llm-wiki.md` (New / Existing project flow).

### 3. Open the Obsidian vault

Vault root is the repository root; wiki root is `llm-wiki/`. Open the repo folder
as an Obsidian vault to get backlinks and graph view over the same Markdown the
agent reads. Keep personal workspace state out of git (the `.gitignore` snippet
already excludes `.obsidian/workspace.json` and plugins).

### 4. Start a personal external knowledge wiki (git repo)

Separate from the project wiki, keep a **personal external knowledge wiki** —
your lectures, insights, and ideas — as a private git repo. Multi-machine use is
a `clone`/`pull`. Record its name and checkout path in `operator-context.md`
(the `External knowledge wiki` line). This is advisory: every command behaves
identically without it.

### 5. Pointer-citation rule

Cite the external wiki by a **namespaced pointer**, never by copying its content
into product artifacts: `{{EXTERNAL_WIKI_NAMESPACE}}:LNNN-In` plus a one-line
gist in your own words. The full contract (no content copy, advisory /
runtime-independent, no absolute paths) is in
`policies/source-pointer-citation.md`.

### Where it meets the Solon workflow

- Run this before the first sprint, or at `sfs adopt` for an existing project.
- Pair it with the [Top-down Learning Guide](./24-topdown-learning-guide.md):
  the wiki is where the durable output of that learning protocol lands.
- Continuity rationale and the standalone guarantee:
  [Obsidian LLM Wiki Continuity](./19-obsidian-llm-wiki-continuity.md).
</content>
