---
doc_id: solon-mcp-server-readme
title: "Solon MCP Server"
visibility: oss-public
doc_type: mcp-server-doc
language: en
updated: 2026-05-28
summary: "MCP server exposing the Solon `sfs` 7-step flow as host-agnostic tools (Claude Desktop, Claude in Chrome, Cursor, Claude Agent SDK, etc.)."
load_when: "Read when registering Solon with an MCP-capable host or when extending the MCP tool surface."
---

# Solon MCP Server

This is an **optional bridge**, not part of the Solon runtime itself. It
exposes the bash-first `sfs` CLI as a small set of [MCP](https://modelcontextprotocol.io)
tools so any MCP-capable host — Claude Desktop, Claude in Chrome, Cursor,
the Claude Agent SDK, and others — can drive a Solon project without
shelling out to bash manually.

Solon stays bash-first. The MCP server is a thin Python process that
shells out to `sfs` and forwards its stdout **verbatim**, in line with
the `kernel.md` SSoT rule: bash adapter output is the source of truth
and must not be reshaped.

## What it ships

12 tools that map 1:1 onto the `sfs` 7-step flow plus a handful of
read-only and evidence surfaces:

| Tool name             | `sfs` command          | Purpose                                   |
| --------------------- | ---------------------- | ----------------------------------------- |
| `sfs_status`          | `sfs status`           | Current sprint / gate / divisions         |
| `sfs_version`         | `sfs version --check`  | Installed version + latest headline       |
| `sfs_report`          | `sfs report`           | Active sprint `report.md`                 |
| `sfs_harness_doctor`  | `sfs harness doctor`   | Project readiness diagnosis               |
| `sfs_start`           | `sfs start <slug>`     | Open a new sprint                         |
| `sfs_brainstorm`      | `sfs brainstorm`       | Gate 2 (Brainstorm)                       |
| `sfs_plan`            | `sfs plan`             | Gate 3 (Plan)                             |
| `sfs_implement`       | `sfs implement`        | Gate 4 (Implement)                        |
| `sfs_review`          | `sfs review`           | Gate 6 (Review)                           |
| `sfs_retro`           | `sfs retro`            | Gate 7 (Retro)                            |
| `sfs_decision`        | `sfs decision`         | Durable decision record                   |
| `sfs_capture`         | `sfs capture`          | Side-quest / incident evidence note       |

Intentionally excluded from this MVP: `sfs commit`, `sfs loop`, `sfs tidy`.
Those need MCP-specific UX work (confirmation flows, multi-stream output,
audit framing) and will land in follow-up patches.

## Install

You need a working `sfs` CLI on `PATH` first. Then install the bridge.

> ℹ️ **Source-clone is the only path supported in 0.7.x.** The
> `pipx install solon-mcp` command below is the *target shape* once
> `solon-mcp` is published to PyPI, which is tracked as a 0.7.x follow-up.
> Until then, use the source-clone path.

```bash
# 0.7.x — source clone (the only currently supported path):
cd /path/to/solon-product/mcp-server
pip install -e .

# Future (post-PyPI publish; do not run until announced):
# pipx install solon-mcp
```

The package exposes a `solon-mcp` console script. Verify with:

```bash
solon-mcp --help 2>/dev/null || echo "ready"   # FastMCP prints no help; absence is fine
which solon-mcp
```

`solon-mcp` reads `SOLON_MCP_TIMEOUT_SEC` (default 300s) and
`SOLON_MCP_SFS_PATH` (default: whatever `which sfs` resolves).

## Register with a host

### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`
(macOS) or `%APPDATA%\Claude\claude_desktop_config.json` (Windows):

```json
{
  "mcpServers": {
    "solon": {
      "command": "solon-mcp"
    }
  }
}
```

Restart Claude Desktop. The 12 `sfs_*` tools appear in the tool list.

### Claude in Chrome

Same JSON shape, in the extension's MCP configuration panel. Use the
`solon-mcp` console script (absolute path is safer on Chrome's PATH).

### Cursor

Add to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "solon": {
      "command": "solon-mcp"
    }
  }
}
```

### Claude Code

`claude-code` honors `~/.claude/mcp_servers.json` (path may vary):

```json
{
  "solon": {
    "command": "solon-mcp",
    "transport": "stdio"
  }
}
```

### Claude Agent SDK (Python)

```python
from claude_agent_sdk import ClaudeSDKClient, AgentOptions
from claude_agent_sdk.mcp import StdioMCPServer

options = AgentOptions(
    mcp_servers={
        "solon": StdioMCPServer(command="solon-mcp"),
    },
    pre_approved_tools=[
        "solon.sfs_status",
        "solon.sfs_version",
        "solon.sfs_report",
        "solon.sfs_harness_doctor",
    ],
)

async with ClaudeSDKClient(options=options) as client:
    ...
```

(The exact import path follows the Agent SDK's MCP integration API; adjust
to whatever your installed version exposes.)

### Generic stdio

Any host that speaks MCP-over-stdio can launch `solon-mcp` directly. The
process reads JSON-RPC frames from stdin and writes them to stdout.

## Where it runs

The MCP server is **stateless** — every tool call runs in the host's
current working directory. To drive a specific Solon project, change
the host's working directory to that project, or set `cwd` explicitly
in the host's MCP server config when the host supports it.

```json
{
  "mcpServers": {
    "solon": {
      "command": "solon-mcp",
      "cwd": "/Users/you/work/my-project"
    }
  }
}
```

This matches how `sfs` itself behaves from a terminal.

## What it does NOT do

- Does not parse, summarize, or reshape `sfs` output. The host's LLM
  reads the raw adapter output, exactly as a terminal user would.
- Does not bypass the Solon permission model. `sfs review` still asks
  the executor for auth, still respects timeouts, still records evidence.
- Does not become the SSoT. `sfs` and `.sfs-local/` remain authoritative.
  If the MCP server and the CLI disagree, the CLI is right.

## Hacking on it

The server is a single file: `solon_mcp_server.py`. Tools are declared
as `@mcp.tool()`-decorated functions. To add a new tool:

1. Add the function with a clear docstring (the docstring becomes the
   tool description LLMs see).
2. Inside, call `_run_sfs([...])` with the bash adapter args.
3. Update the table at the top of this README.
4. Update `tests/test-mcp-server-contract.sh` to assert the new tool
   is declared.
