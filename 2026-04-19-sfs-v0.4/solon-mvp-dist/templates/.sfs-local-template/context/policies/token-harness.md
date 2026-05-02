---
id: sfs-policy-token-harness
summary: Ambient token and harness hygiene for any LLM runtime.
load_when: ["token", "harness", "context", "Claude", "Codex", "Gemini", "MCP", "Serena", "Hookify"]
---

# Token And Harness Hygiene

- Apply this silently during normal SFS work. Do not ask the user to run extra
  hygiene commands unless a concrete risk appears.
- Keep adapter memory thin: `SFS.md`, `CLAUDE.md`, `AGENTS.md`, and `GEMINI.md`
  should hold entry rules and project identity, not changelog, long history, or
  full API docs. Move durable detail to routed context modules, docs, reports,
  or ADRs.
- Prefer context routing before broad reads: start from `sfs status`, current
  `report.md`/`retro.md`, `_INDEX.md`, and the command module, then inspect only
  files needed for the slice.
- Prefer symbol/semantic navigation for large codebases. Claude users may use
  Serena; other agents should use LSP, IDE index, repo graph, or precise `rg`
  before reading entire directories.
- Treat repeated AI mistakes as harness debt. During review/retro, convert
  repeated corrections into guardrails, hooks, checks, or a short adapter/context
  rule instead of re-explaining the same warning every session.
- Use usage reports when token drain feels abnormal. Claude users may use
  Session Report; other agents should use their own usage dashboard/logs. Do
  not guess blindly from vibes.
- CLAUDE.md Management is useful as audit/report input, but do not auto-apply
  its suggestions to SFS adapter docs. Propose only small, stable, high-signal
  edits.
