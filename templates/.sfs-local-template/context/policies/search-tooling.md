---
id: sfs-policy-search-tooling
summary: Agents prefer `rg` (ripgrep) for code/text search; reserve `grep` only when `rg` is unavailable. AST-aware tools (ast-grep) are an opt-in consumer choice for language-specific projects; they are not part of the SFS bash SSoT.
load_when: ["search", "grep", "ripgrep", "rg", "find code", "find files", "code lookup", "ast-grep", "aider", "tool choice", "performance"]
---

# Search tooling

Agents searching code, docs, logs, or evidence inside an SFS project default to
`rg` (ripgrep). Plain `grep` is acceptable only when `rg` is not installed on
the host runtime.

## Why `rg` first

- ripgrep is the de-facto baseline for both Claude Code and Codex CLI runtimes,
  and is faster than `grep -r` on every directory size SFS projects realistically
  hit.
- `rg` respects `.gitignore`, `.ignore`, and binary detection by default, so
  agents avoid scanning `node_modules/`, `.sfs-local/archives/`, packaged
  `tar.gz` fixtures, or compiled assets unless explicitly opted in.
- Output stays line-numbered (`-n` is implicit) and color-tagged, which keeps
  the runtime context compact when the result is replayed into reviewer
  prompts.

Quick reference for agent prompts and policy docs:

- code/text search → `rg <pattern> <path>` (not `grep -rn <pattern> <path>`).
- file-name patterns → `rg --files | rg <pattern>` or `fd <pattern>`; avoid
  `find . -name '<pattern>'` unless `fd`/`rg` are unavailable.
- multi-line patterns → `rg -U '<pattern>'` (`grep -P` is non-portable).

## What stays opt-in / out of scope

These tools were evaluated against SFS's "perf↑ vs token↑" decision frame and
recorded as PASS for the SFS core surface; they may still earn their keep
inside a specific consumer project.

- **ast-grep (`sg`)** — AST-aware pattern matching. SFS source is ~85% bash +
  Markdown, where ast-grep gives little to no advantage over `rg`. PASS as a
  core dependency; consumer projects in Java / TypeScript / Python / Rust /
  Go may install it as a CI/lint helper and surface it through their own
  routed context. Do not add ast-grep into SFS's bash SSoT or agent default
  toolbelt.
- **Aider-style standalone CLI coding loops** — overlap with SFS's own
  brainstorm/plan/implement/review (Gate 3/6) + sub-agent council + harness
  doctor flow. PASS to avoid dual-loop conflict. Agents stick to SFS plus the
  configured runtime (Claude Code / Codex / Gemini).

If a consumer project chooses to add ast-grep or another AST tool, the agent
treats it as a project-local extension: respect the project's wiki / routed
context entries, but never assume the binary exists in the global SFS toolbelt.

## Falsifiable signal

- Agent emits `grep -r` against a project tree larger than a handful of files
  → log it as a lens-routing finding (use `rg` instead).
- Agent recommends Aider / ast-grep as part of the SFS core install path →
  reject; route to consumer-project routed context.

## Related policies

- `context-pollution-guard.md` — keeps search output bounded; this policy
  picks the tool that produces less noise to begin with.
- `ai-work-intake-routing.md` — search/lookup is part of intake; the tool
  baseline applies.
