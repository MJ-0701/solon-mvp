---
name: sfs
description: |
  Solon SFS workflow command (bash adapter SSoT).

  Usage: /sfs <command> [args]

  Commands:
    status | start | guide | auth | division | adopt | upgrade | update | version
    brainstorm | plan | implement | review | decision | report | tidy | retro
    commit | loop
argument-hint: "<command> [args]"
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# Solon SFS — `/sfs` (entry-lean)

SFS commands are owned by the Solon runtime (`sfs <command>` deterministic bash adapter).
Always dispatch to the adapter first; adapter I/O is SSoT (no paraphrase).

Token-min entry/resume:
- Prefer: `sfs status` → current sprint `report.md`.
- Do not auto-load verbose history (`.sfs-local/events.jsonl`, old `scheduled_task_log`, old `review-runs`) unless needed.

User arguments (first token = subcommand, rest = args):
```text
$ARGUMENTS
```

## Dispatch (always)

1. Verify runtime: `command -v sfs`. If missing, say so in 1 line and stop.
2. Execute via Bash: `sfs <subcommand> <args>`.
   - Vendored layout fallback only: `bash .sfs-local/scripts/sfs-dispatch.sh <subcommand> <args>`.
3. Print stdout verbatim. If exit≠0, also print stderr + `exit <code>`.

If `/sfs loop` reports a mutex conflict (Solon `domain_locks`), stop and report the lock owner/domain.

## After adapter (only when applicable)

Command modes:
- **Bash-first**: `status|start|guide|auth|division|upgrade|update|version|commit|loop` → stop after verbatim output.
- **Adapter-run**: `review` → stop after verbatim output unless explicitly asked to summarize recorded results.
- **Hybrid refinement**: `adopt|brainstorm|plan|implement|decision|report|retro` and `tidy` (only if it created/touched `report.md`).

Hybrid refinement rules:
- Use adapter stdout (paths) as metadata, then open the created/pointed artifacts and refine them.
- Use each artifact’s own guardrails (`plan.md`, `implement.md`, etc.) as SSoT for what to write.
- Final user-facing response is a Solon report in a fenced `text` block (localized).
- For `review`: summarize from recorded `review.md`/`result_path` metadata; do not dump raw executor markdown or create a new verdict.

Minimal Solon report shape:
```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 SOLON REPORT — /sfs <command>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Command <command> · <goal/gate>      [<status>]
🔧 Steps   <adapter + refinement summary>
📁 Files   <paths>
💾 Commits <sha or 없음>
⚠️ Escalation <없음/summary>
⏭️ Next  <one next action>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Guard:
- Never run `retro --close` unless the user explicitly asked. If asked, refine `retro` + `report` first, then run the close step exactly once.
