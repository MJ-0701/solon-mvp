---
id: sfs-policy-agent-adapter-doc-refactor
summary: Keep root LLM agent Markdown files as frontmatter-only SFS pointers and review them as models evolve.
load_when: ["agent", "adapter", "CLAUDE.md", "AGENTS.md", "GEMINI.md", "frontmatter", "docs bloat", "config review", "model evolution"]
---

# Agent Adapter Doc Refactor

Root LLM agent files are auto-load pointers, not policy homes. In SFS projects,
`CLAUDE.md`, `AGENTS.md`, and `GEMINI.md` should contain only frontmatter that
points to the real sources of detail.

## Contract

- Keep root agent docs frontmatter-only.
- Put durable SFS behavior in packaged runtime context or optional
  `.sfs-local/context/` overrides. `SFS.md` should remain a small router to
  those sources.
- Do not inline SFS command tables, model routing, gates, review policy,
  division packs, wiki policy, release policy, prompt bodies, or transcripts.
- A file is safe to auto-refactor only when it is clearly an SFS agent adapter,
  for example it has `doc_type: agent-adapter-bootstrap`, `sfs_detail_sources`,
  `Solon SFS` plus `sfs context cat`, or the old full command-table marker.
- Non-SFS project instructions are never rewritten automatically. Report them
  as skipped so the user can decide how to split them.

## Config Review Cadence

- Review root agent adapters, `SFS.md`, skills, hooks, plugins, permissions, and
  `.sfs-local/context/` overrides every 3-6 months, after a major model/runtime
  release, or when performance plateaus.
- Remove stale workaround instructions that compensate for limitations the
  current model/tooling no longer has. Keep durable critical gotchas, but move
  detailed policy to routed context instead of bloating the adapter.
- Record the review trigger, date, removed stale rule, and retained critical
  gotcha in the current sprint report or maintenance note.

## Command Surface

- `sfs agent doctor` scans root `CLAUDE.md`, `AGENTS.md`, and `GEMINI.md`.
- `sfs agent doctor --fix` archives any recognized SFS adapter with body text
  under `.sfs-local/archives/agent-doc-refactor/<timestamp>/` and replaces it
  with the packaged frontmatter-only template.
- `sfs upgrade` runs the same safe fix by default for recognized SFS adapters.
  Set `SFS_AGENT_DOC_REFACTOR=0` to audit only.

## Review Questions

- Did the root agent doc stay frontmatter-only?
- Are the detailed rules reachable through `SFS.md` and then `sfs context cat ...`?
- Was the old body archived before overwrite?
- If a bloated file was skipped, was it skipped because SFS ownership was not
  provable?
