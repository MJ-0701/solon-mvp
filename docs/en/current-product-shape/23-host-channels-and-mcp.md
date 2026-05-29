---
doc_id: sfs-current-product-shape-en-23
title: "Host channels — CLI / MCP / Agent SDK"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-05-28
parent: docs/en/current-product-shape.md
summary: "Solon's 7-step flow is transport-agnostic. CLI / MCP / Agent SDK all land on the same bash adapter, the same sprint state, and the same review gates."
load_when: "Read when deciding how to drive Solon from a host other than the terminal, or when reviewing the 0.7.0+ host-agnostic surface."
---
## Host channels — CLI / MCP / Agent SDK

The Solon 7-step flow is transport-agnostic. From 0.7.0 onward three host
channels sit on the same `sfs` bash adapter as equals:

- **CLI** — the oldest entrypoint. A terminal invokes `sfs status`,
  `sfs start`, `sfs plan`, `sfs review` directly. Claude Code (`/sfs ...`),
  Gemini CLI (`sfs ...`), Codex CLI (`$sfs ...`), and Windows
  PowerShell/cmd (`sfs.cmd ...`) all expose the same surface under
  different triggers.
- **MCP** — `mcp-server/` ships a stdio MCP server that exposes the same
  commands as 12 `sfs_*` tools. Claude Desktop, Claude in Chrome, Cursor,
  and any other MCP-capable host pulls 7-step in through this channel.
  The server forwards the bash adapter stdout **verbatim**, so the
  `kernel.md` SSoT rule is preserved.
- **Agent SDK** — `templates/claude-agent-sdk-zero/` scaffolds a Python
  Claude Agent SDK project pre-wired to `solon-mcp` and
  `solon-safe-permissions.yaml`. An agent inside the SDK can call the
  `sfs_*` tools directly.

### What every host meets

All three channels share the same invariants:

- the same `.sfs-local/sprints/` state
- the same `divisions.yaml` activation states
- the same routed context (`sfs context cat kernel` / `index` /
  `commands/*` / `policies/*`)
- the same Gate 6 review contract (an empty six-division ledger is a
  partial verdict, not PASS)
- the same `kernel.md` SSoT rule (output is verbatim)
- the same review lenses (including agent-build auto-routing)

### Registration cheat sheet

| host | registration location | trigger style |
| --- | --- | --- |
| Claude Code | `.claude/commands/sfs.md` (`sfs agent install all` writes it) | CLI: `/sfs ...` |
| Gemini CLI | `.gemini/commands/sfs.toml` | CLI: `sfs ...` |
| Codex CLI | `.agents/skills/sfs/SKILL.md` | CLI: `$sfs ...` |
| Claude Desktop | `~/Library/Application Support/Claude/claude_desktop_config.json` → `mcpServers` | MCP |
| Claude in Chrome | extension MCP config panel | MCP |
| Cursor | `~/.cursor/mcp.json` → `mcpServers` | MCP |
| Claude Agent SDK | `AgentOptions(mcp_servers={...})` | Agent SDK |

Full registration snippets live in
[`mcp-server/README.md`](../../../mcp-server/README.md).

### Permission baseline

All three channels share the same permission baseline:
`templates/.sfs-local-template/presets/solon-safe-permissions.yaml`. Auto-push,
destructive bash, and hard resets are denied by default; mutating `sfs_*`
tools go through ask-approval; read-only tools are pre-approved. Consumers
import this preset into whatever permission shape their host uses.

### agent-build review lens, applied automatically

When the work itself ships a new agent — Agent SDK process, MCP server,
sub-agent harness — the Gate 6 review auto-routes to the `agent-build`
lens (0.7.1+). The CPO evaluator then checks the seven agent-build
subsections (tool surface scope, permission posture, sub-agent isolation,
system prompt drift, SSoT, evidence, agent-build failure modes). See
[`policies/agent-build-review-lens.md`](../../../templates/.sfs-local-template/context/policies/agent-build-review-lens.md).
