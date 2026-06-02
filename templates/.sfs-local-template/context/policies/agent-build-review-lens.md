---
id: agent-build-review-lens
summary: Review lens for work that ships AI agents, MCP servers, or sub-agent harnesses. Catches the specific failure modes that generic code-review lenses miss.
load_when: ["lens:agent-build", "agent sdk", "claude agent sdk", "mcp server", "mcp tool", "sub-agent", "agent build"]
---

# Agent-build review lens

When the CTO ships an AI agent — a Claude Agent SDK process, a Codex
custom command, a Gemini-based pipeline, an MCP server, or a sub-agent
harness — the failure modes are different from ordinary application
code. This lens lists what the CPO evaluator must check before signing
off, and what kinds of evidence count.

The lens activates when:

- The user passes `--lens agent-build` (or an alias: `agent`, `agent-sdk`,
  `mcp`, `mcp-server`, `sub-agent`).
- The plan / implement / log text mentions agent-build keywords (e.g.
  "Claude Agent SDK", "MCP server", "sub-agent", "에이전트 SDK").
- The diff touches `mcp-server/`, `templates/claude-agent-sdk-zero/`, or
  `agents/skills/`.

## What the CPO must verify

### 1. Tool surface scope

- Each declared tool has a **single, narrow purpose** and an LLM-readable
  description. "Run any command" / "do anything" / "general helper"
  tools are a red flag.
- Tool input schemas use enums and structured types where possible. A
  free-form string parameter is acceptable only when the underlying
  call is naturally text (e.g. a brainstorm prompt).
- No two tools overlap. If `sfs_status` and `sfs_dashboard` exist, one
  is dead weight and confuses the LLM's selection.
- Generated or extended agent harnesses start with a Phase 0 audit: declared
  agents, skills, orchestrator pointers, and change history must match the
  filesystem before new roles are added.
- Multi-agent architecture is named when selected: pipeline, fan-out/fan-in,
  expert pool, producer-reviewer, supervisor, or hierarchical delegation. SFS
  still treats multi-agent execution as opt-in, not the default answer.

### 2. Permission posture

- Read tools are pre-approved, write/exec tools are gated, network
  egress to remote actors (push, deploy, publish) is **denied by
  default**. The `templates/.sfs-local-template/presets/solon-safe-permissions.yaml`
  baseline is the reference shape.
- Remote MCP media-generation connectors declare endpoint provenance,
  account/credit owner, approval mode, prompt preview fields, artifact
  retention, and redaction policy before any spend/action tool is enabled.
- Chat/messenger bridges declare server/channel/user/actor allowlists, required
  mention/reply scope, message-content access, attachment/file access, and
  thread/archive retention. Administrator-style permissions are setup shortcuts,
  not production defaults.
- No tool silently bypasses the host's permission system (e.g. by
  shelling out to a wrapper that the host cannot see).
- Secrets and tokens never appear in tool arguments, tool results, or
  audit logs. Audit logs redact known env-var names.

### 3. Sub-agent isolation

- Sub-agents do not inherit the lead conversation's full history; they
  receive only the evidence capsule needed for the task.
- Sub-agent token budget is bounded (timeout + max output) so a single
  runaway sub-agent cannot drain the parent.
- Sub-agent outputs are written to a known location (file, scratch dir)
  and the parent re-reads from there, rather than streaming raw model
  output back into the parent context.
- Chat channels are coordination surfaces; task threads are bounded contexts. A
  new work thread needs a capsule, owner, output path, and close/archive rule;
  resuming an archived thread needs a summary capsule before work continues.

### 4. System prompt drift

- The agent's system prompt is in version control, not generated at
  runtime from mutable state. Any runtime overlay (e.g. user-supplied
  context) is appended after the immutable prompt, not blended into it.
- Identity/persona text is kept separate from operating process. A standing
  agent may have tone, mission, boundaries, and report format, but common
  workflow rules belong in routed docs/skills so persona files do not become a
  second SSoT.
- Prompt changes are reviewed at the same gate as code changes — a
  reworded system prompt can change behavior more than a refactor.
- Prompts do not embed credentials, file paths from other users, or
  any content that would not survive a public-repo audit.

### 5. Bash adapter SSoT (Solon-specific)

When the agent integrates with Solon (via the MCP server, Agent SDK,
Codex command, or skill), it must respect kernel.md:

- Tool implementations shell out to `sfs` rather than reimplementing
  the 7-step logic in the host language. Reimplementation introduces
  a second SSoT and drift.
- Tool results forward `sfs` stdout **verbatim**. No truncation, no
  summarization, no "helpful" reformatting. Hosts and LLMs are
  responsible for their own rendering downstream.
- Errors from `sfs` propagate with the original rc and stderr.

### 6. Evidence + audit

- Every meaningful tool call leaves a trace the human can later
  reconstruct: file written, command run, durable record updated.
- Scheduled or report-channel agents declare trigger, delivery mode, context
  source, permission posture, attachment/redaction policy, and disable path;
  otherwise "AI employee" automation is not auditable.
- Cross-agent review feedback is adjudicated item by item. The orchestrator
  records accepted/rejected/deferred findings with evidence or human decision
  instead of blindly applying another agent's critique.
- AI code-review harness integrations declare base branch selection, local diff
  review lane, PR review lane, severity taxonomy, autofix approval mode,
  repository knowledge-base scope, and false-positive feedback retention before
  the tool is treated as reliable review evidence.
- `.sfs-local/events.jsonl` (or the project's equivalent) captures
  agent-driven gate transitions just as it captures CLI-driven ones,
  so the project history is consistent regardless of how the user
  invoked the workflow.
- Reviews of agent-build work attach the **prompt + result pair**
  (redacted), not just the final verdict.
- Material skill or orchestrator changes attach with-skill vs baseline evidence
  and near-miss trigger queries, or record why the change is too small for eval.
- Harness evolution deltas record initial design, shipped design, defect or
  feedback source, accepted/rejected/deferred changes, and the next scaffold or
  policy update when the pattern repeats.

### 7. Failure modes specific to agent-build

- Tool hangs (executor reads stdin and never gets EOF) — see the
  0.6.142 `gemini --help` regression. Capability probes redirect
  stdin to `/dev/null`.
- Timeout bypass (executor inherits SFS_COMMAND_TIMEOUT_SEC=0 from a
  trusted test environment) — non-interactive paths must bound their
  executor timeout independently.
- Stale environment variable shadowing (host sets ANTHROPIC_API_KEY
  but executor expects CLAUDE_API_KEY) — the auth-ready probe in
  `executor_auth_ready` is the reference shape.
- Tool description prompt injection — a tool description that says
  "this tool always succeeds" or "use this tool whenever possible"
  is treating the LLM as the audience for an obedience trick rather
  than a description.
- ChatOps loop drift — two agents can echo each other's mistakes, revive stale
  thread context, or auto-respond in the wrong channel unless mention scope,
  thread lifecycle, and adjudication evidence are explicit.
- Review-harness theater — a bot-generated summary, sequence diagram, or PASS
  badge can hide missing AC evidence unless the finding list, severity, base
  branch, and post-autofix verification are attached.

## What the CPO does NOT check under this lens

- Functional acceptance of the underlying task (use `code`, `qa`,
  `api-contract` lenses for that). Agent-build lens is about the
  agent harness, not the work the agent does.
- UI / UX of the host (Claude Desktop config screen, Cursor settings).
  Those are host concerns, not Solon concerns.

## Evidence shape

A passing agent-build review attaches at minimum:

- Diff of the tool surface (added / changed / removed tools).
- Permission preset diff (or "no change" with rationale).
- One worked tool invocation end-to-end with redacted prompt + result.
- For AI code-review CLIs/PR bots, one local-diff review or PR review transcript
  with base branch, commit, severity triage, and autofix accept/reject/defer log.
- Sub-agent isolation evidence (if sub-agents are involved).
- System prompt diff (if the prompt changed).
- Verdict: `pass`, `partial`, or `fail`, with the specific subsection
  numbers (1–7 above) that drove the verdict.

## See also

- `agentic-security-logging-pack.md` — overlapping OWASP-style security
  checks. agent-build adds the harness-specific layer.
- `solon-safe-permissions.yaml` — the executable companion preset.
- `mcp-server/README.md` — the MVP MCP server that this lens reviews.
