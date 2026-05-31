---
doc_id: sfs-current-product-shape-en-15
title: "Retro Closes The Sprint By Default"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-31
parent: docs/en/current-product-shape.md
summary: "Retro Closes The Sprint By Default"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## Retro Closes The Sprint By Default

A sprint is complete when it is closed, and `sfs retro` does that in one step:

```text
sfs retro
```

It refines `report.md` and `retro.md`, packs workbench evidence and temporary
review scratch into one cold archive bundle, closes the sprint state, and
creates the local close commit. In an Obsidian-applied project, close also
leaves a wiki compile checklist: report/retro stay the sprint evidence SSoT,
while only durable meaning is promoted into `llm-wiki/`. Use `sfs retro --draft`
when you want to open the draft without closing.
Older installs that still have loose sprint archives or separate review-run
archives are compacted by `sfs upgrade` into compressed migration bundles.
Runtime upgrade, agent install, and profile rollback backups are also kept as
`*.tar.gz` + `manifest.txt` bundles instead of loose project files.
`events.jsonl` is not durable history. It is visible only as the current
active-sprint ledger. Once there is no active sprint, or once stale events
belong only to older sprints, upgrade/tidy removes or archives that residue.
The durable handoff is the shared
`docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/` document set plus git
history. `llm-wiki/` sits above those artifacts as the long-horizon retrieval
and domain-memory layer; it links to close records instead of duplicating them.
Repeated surface-cleanup runs are also compacted by date: the visible surface is
`.sfs-local/archives/adopt/surface-cleanup/<yyyyMMdd>/manifest.txt` plus
`surface-cleanup.tar.gz`, not a list of same-day timestamp directories.
In thin layout, project-local `.claude/`, `.gemini/`, and `.agents/`
command/skill adapters are also removed from the default surface. Root adapter
docs point agents at the global `sfs` runtime, and projects that still need
native slash/skill files can opt in with `sfs agent install all`.
Global `sfs` / `sfs.cmd upgrade` also promotes existing vendored projects to
the thin surface. Use `sfs upgrade --layout vendored` only when a project must
keep runtime files locally.
