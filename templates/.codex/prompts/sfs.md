# Solon SFS — Codex CLI custom prompt (legacy/user-scoped fallback, entry-lean)
#
# Path (user-scoped, NOT project-scoped):
#   ~/.codex/prompts/sfs.md
#
# Invoke on Codex builds that still support user prompts:
#   /prompts:sfs <subcommand> [args]
#
# This file is an OPTIONAL legacy fallback. Prefer the project-scoped adaptor:
# - `.agents/skills/sfs/SKILL.md` (Codex Skill, installed by `install.sh`)
# - `SFS.md` (project SFS guide; points to `sfs guide --print`)
#
# Compatibility note: some Codex builds may block unregistered `/sfs` before the
# model sees it. `/prompts:sfs` is only a bypass when your runtime exposes
# custom prompts.

You are operating in a project that has Solon SFS installed (Solo Founder System).

The user invoked this prompt with `$ARGUMENTS`. Treat the first whitespace-delimited
token as the subcommand and the remainder as that subcommand's arguments.

Token-min rule: do not auto-load verbose history (`.sfs-local/events.jsonl`, old
`scheduled_task_log`, old `review-runs`) unless needed.

## Always dispatch first (bash adapter SSoT)

1) Verify runtime: `command -v sfs`. If missing, say so in 1 line and stop.
2) Execute: `sfs <subcommand> <args>`.
   - Vendored layout fallback only: `bash .sfs-local/scripts/sfs-dispatch.sh <subcommand> <args>`.
3) Print stdout verbatim. If exit≠0, also print stderr + `exit <code>`.

If `sfs loop` reports a mutex conflict (Solon `domain_locks`), stop and report the
lock owner/domain.

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
- Never run `git push`, main merges, or release/publish steps unless the user explicitly asked.
