---
doc_id: sfs-10x-value-en-5
title: "Parallel Agent 10x Loop"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-22
parent: docs/en/10x-value.md
summary: "Parallel Agent 10x Loop"
load_when: "Read when docs/en/10x-value.md routes to this section."
---
## Parallel Agent 10x Loop

Using multiple agents is not valuable because "more agents means more output."
In Solon, parallelism creates 10x value only when the work is split into
commit-sized lanes that can be described clearly, verified locally, and reviewed
by a different agent.

Single Agent is the default. Use `--agent-mode parallel` only when the plan
already splits into independent lanes, each lane has disjoint files_scope, and
each lane can name its one-sentence commit message. If that sentence is unclear,
the work is not ready to split.

That commit message should be written in the user's native or workspace
language. English is the default only when English is the user/repo language;
for a Korean user, Korean commit messages are the friendly default.

```text
fixed plan
-> commit-unit lanes
-> disjoint files_scope
-> lane verification
-> agent cross review
-> Gate 6 review
```

With that structure, Codex, Claude, and Gemini can increase both speed and
quality control. Without it, parallelism mostly creates collisions and duplicate
review work.

