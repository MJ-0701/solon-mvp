---
doc_id: mcp-tool-zero-readme
title: "mcp-tool-zero"
visibility: oss-public
doc_type: project-zero-template
language: en
updated: 2026-05-29
summary: "Solon-safe scaffold for shipping one narrow custom MCP tool — FastMCP server, typed/bounded input, default-deny permission preset, smoke tests."
load_when: "Read when scaffolding a new custom MCP tool server that should follow the Solon agent-build review lens and capsule contract."
---

# mcp-tool-zero — custom MCP tool skeleton for `<PROJECT-NAME>`

A minimal, Solon-safe scaffold for shipping **one custom MCP tool** in the
`<DOMAIN>` domain. Unlike `templates/claude-agent-sdk-zero/` (which *consumes*
the `solon` MCP server), this template *produces* a new MCP server that exposes
a project-specific tool an agent host can call.

Materialize it with `sfs bootstrap` (placeholders `<PROJECT-NAME>`, `<DOMAIN>`,
`<TOOL-NAME>` get substituted), then:

```
cd <PROJECT-NAME>-mcp-tool
uv sync           # or: pip install -e .
python -m pytest  # smoke tests
python server.py  # serve over stdio
```

## What you get

- `server.py` — a FastMCP server exposing a single narrow tool `<TOOL-NAME>`
  with a typed input schema and an LLM-readable description. No "do anything"
  tool surface (the `agent-build` review lens fails that).
- `solon-safe-permissions.yaml` — default-deny permission preset; remote
  mutation (`git push`, `rm -rf`) denied, mutating tools ask approval.
- `tests/test_tool_smoke.py` — smoke contracts: tool registers, schema is
  typed, permission preset denies auto-push, no secrets committed.

## Capsule contract

When this tool is driven by a sub-agent, the calling lead must pass a capsule
that satisfies `policies/sub-agent-capsule-contract.md`
(goal / acceptance_criteria / files_scope / tools_allowed / output_paths /
token_budget / timeout / pii_rules). `<TOOL-NAME>` writes its result to
`output_paths`, never to the chat transcript.
