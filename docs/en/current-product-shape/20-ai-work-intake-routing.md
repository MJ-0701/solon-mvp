---
doc_id: sfs-current-product-shape-en-20
title: "AI Work Intake Routing"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-26
parent: docs/en/current-product-shape.md
summary: "AI Work Intake Routing"
load_when: "Read when docs/en/current-product-shape.md routes to this section."
---
## AI Work Intake Routing

Solon treats useful AI work as an intake contract before it becomes a sprint,
plan, or implementation. The contract has four parts:

- Goal: what is being produced and why it matters.
- Materials: notes, files, screenshots, prior docs, code, links, examples, or
  project memory.
- Ask-back rule: what the agent should ask before drafting, and what it can
  infer from SFS history, wiki, docs, or the current sprint.
- Output format: the artifact shape, such as a note, checklist, table, PR, plan,
  HTML guide, report, or per-file output plus master index.

SFS also chooses the amount of machinery by work size. One-off work can stay in
the current chat. Repeated work should promote stable goal/material/format rules
into project memory, `SFS.md`, `docs/solon/`, or `llm-wiki/`. Batch workspace
work preserves raw inputs, creates per-source outputs, and then builds the
requested aggregate artifact.

When the project has weak or missing docs, intake starts with memory formation:
check code, git history, tests, config, deployment traces, and existing notes,
then record knowns, unknowns, and already-answered questions before asking the
user to restate broad background.

This is vendor-neutral. Claude chat/project/cowork, Codex threads, local
folders, Obsidian, Git, and future tools can all implement the same shape. SFS
records the durable contract, evidence, and artifact paths instead of making the
user repeat context.
