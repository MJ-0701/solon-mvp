---
doc_id: claude-agent-sdk-zero-readme
title: "claude-agent-sdk-zero"
visibility: oss-public
doc_type: project-zero-template
language: en
updated: 2026-05-28
summary: "Solon-flavored Claude Agent SDK starter — Python project scaffold wired to the Solon MCP server and the solon-safe permission preset."
load_when: "Read when scaffolding a new Claude Agent SDK project that should follow the Solon 7-step methodology."
---

# claude-agent-sdk-zero

A minimal Python project scaffold for building an agent on the
[Claude Agent SDK](https://docs.claude.com/en/docs/build-with-claude/agent-sdk)
with Solon's 7-step methodology, MCP server, and permission preset
already wired in.

This template is **opinionated** — it bakes in the Solon defaults that
took the 0.6.x line many revisions to arrive at:

- Reads the Solon MCP server (`solon-mcp`) for `sfs_*` tools.
- Loads the Solon-safe permission preset
  (`solon-safe-permissions.yaml`) so the agent inherits "no auto-push,
  no destructive bash, mainline-first, Gate 6 before review".
- Has a single `agent.py` entrypoint with `<PROJECT-NAME>` and `<DOMAIN>`
  placeholders that the consumer fills in once.
- Ships a `pyproject.toml` with pinned-but-current dependencies.
- Includes a smoke test that does not need an API key (verifies
  the project loads, the MCP server is registered, and the preset
  parses).

If you do not want any of the above, use the upstream
[claude-agent-sdk Python quickstart](https://docs.claude.com/en/api/agent-sdk/python)
directly. This template is for teams who want Solon's review gates and
release discipline by default.

## What lands in your project

```
<PROJECT-NAME>/
├── pyproject.toml
├── README.md
├── .gitignore
├── agent.py                  # the agent entrypoint
├── system_prompt.md          # version-controlled system prompt
├── solon-safe-permissions.yaml  # copy of the preset (pin to your version)
└── tests/
    └── test_agent_smoke.py
```

After `sfs init --layout thin --yes` runs, your project also gains:

- `SFS.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` — agent adapters
- `.sfs-local/` — sprint workspace + decisions + events
- `.claude/`, `.gemini/`, `.codex/` — host-specific command/skill installs (optional)

## How to scaffold

From a fresh empty directory (Solon CLI must be installed):

```bash
sfs init --layout thin --yes
sfs bootstrap --template claude-agent-sdk-zero <project-name>
```

`sfs bootstrap` copies this template into the current directory,
substitutes `<PROJECT-NAME>` and `<DOMAIN>` placeholders, and prints the
next steps. (If your installed `sfs` predates 0.7.0, copy the files
manually from your `sfs` source clone.)

Then:

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -e .
pip install solon-mcp                   # MCP bridge for sfs_* tools
python -m pytest tests/                 # smoke test, no API key needed
```

Set your API key and run:

```bash
export ANTHROPIC_API_KEY=...
python agent.py "Help me draft a plan for <feature>"
```

The agent will:

1. Read `SFS.md` + `.sfs-local/divisions.yaml` to learn the project.
2. Run `sfs_status` to see the current sprint.
3. If no sprint is open, run `sfs_start` then `sfs_brainstorm` /
   `sfs_plan` based on your request.
4. Stop at Gate 6 and ask you to confirm before any merge / push.

## Solon principles baked in

The system prompt (`system_prompt.md`) inherits these from
`templates/.sfs-local-template/context/kernel.md`:

- **Bash adapter SSoT** — call `sfs_*` tools verbatim, never reshape.
- **Mainline-first** — handle the user's mainline request; treat
  auxiliary tooling/auth as unblockers only.
- **Gate 6 before review** — even Single Agent paths must run review.
- **Handoff-only is a stop contract** — if the user asks only for an
  artifact, write it and stop. No follow-on polling.
- **Korean-first projects** — start new source files with a one-line
  Korean role comment after the shebang or directive.

## When to step outside the template

This template is for **product-focused agents** (research, ops,
customer support, code assistance). It is not optimized for:

- High-throughput batch agents (use a queue + worker pool instead).
- Pure stateless chat (the Agent SDK's `query` one-shot path is fine).
- Multi-tenant SaaS (you'd want a session/auth layer this template
  intentionally omits).

For those cases, copy the bits you want from `agent.py` and leave the
rest.

## See also

- `mcp-server/README.md` — the MCP server this template registers.
- `templates/.sfs-local-template/presets/solon-safe-permissions.yaml`
  — the permission preset this template inherits.
- `templates/.sfs-local-template/context/policies/agent-build-review-lens.md`
  — the review lens used for projects built from this template.
