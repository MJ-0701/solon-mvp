---
name: sfs
description: Solon SFS workflow — dispatch /sfs (status, start, plan, review, decision, retro, loop) to bash adapter SSoT. Trigger when user types /sfs, sfs <command>, or asks Solon SFS to do something (e.g., "현재 상태 확인", "sprint 시작", "review 작성", "decision 기록", "retro close", "loop 자율 진행"). Bash adapter is single source of truth — paraphrase forbidden, exit codes verbatim.
---

# Solon SFS — Codex Skill

This project uses Solon SFS. When the user invokes `/sfs <command>` or
expresses a Solon SFS workflow intent, dispatch the request to the
corresponding bash script under `.sfs-local/scripts/` and stop.

The seven subcommands are **deterministic** and must NOT be re-interpreted by
the model. Bash adapter is single source of truth (SSoT).

## Dispatch Table

| User intent / first arg | Script to run | Notes |
|:--|:--|:--|
| `status` (또는 "현재 상태", "어디까지 했는지") | `bash .sfs-local/scripts/sfs-status.sh [--color=auto/always/never]` | 1줄 dashboard |
| `start <goal>` (또는 "sprint 시작", "새 sprint") | `bash .sfs-local/scripts/sfs-start.sh [<sprint-id>] [--force]` | sprint dir 초기화 + 5 templates cp |
| `plan` (또는 "plan 작성", "이번 sprint 계획") | `bash .sfs-local/scripts/sfs-plan.sh` | plan.md 진입 + plan_open event |
| `review --gate <id>` (또는 "review 작성", "검증 기록") | `bash .sfs-local/scripts/sfs-review.sh --gate <id>` | id ∈ G-1, G0, G1, G2, G3, G4, G5 |
| `decision <title>` (또는 "결정 기록", "ADR 추가") | `bash .sfs-local/scripts/sfs-decision.sh "<title>" [--id <id>]` | full ADR 또는 mini-ADR 분기 |
| `retro [--close]` (또는 "회고", "sprint close") | `bash .sfs-local/scripts/sfs-retro.sh [--close]` | `--close` 시 sprint close + auto commit |
| `loop [OPTIONS]` (또는 "자율 진행", "loop 시작") | `bash .sfs-local/scripts/sfs-loop.sh [OPTIONS]` | Ralph Loop + Solon mutex (see `--help`) |

## Procedure

1. **Existence check** — Use the shell tool to verify the target script
   exists and is executable (`ls -l .sfs-local/scripts/sfs-<name>.sh`). If
   missing, tell the user which script is missing in 1 line and stop (do NOT
   try to recreate the script — install/upgrade is user's responsibility via
   `install.sh` / `upgrade.sh`).

2. **Quote args safely** — Re-quote `<remaining args>` for the shell. Reject
   any argument containing a newline or NUL byte by reporting `unknown arg`.

3. **Execute** — Run the script via the shell tool. Capture stdout, stderr,
   and exit code. Do not pipe through any other transformer.

4. **Print output verbatim** — Emit the script's stdout exactly as produced.
   If exit code is non-zero, also print stderr and the exit code on a final
   line: `exit <code>`. Map known exit codes per the script contract:
   - status: `0`=ok, `1`=no `.sfs-local/`, `2`=corrupt `events.jsonl`,
     `3`=not a git repo, `99`=unknown.
   - start: `0`=ok, `1`=sprint id conflict (suggest `--force`), `4`=templates
     missing, `5`=permission, `99`=unknown.
   - plan: `0`=ok, `1`=no `.sfs-local/` or no active sprint, `4`=template
     missing, `99`=unknown.
   - review: `0`=ok, `1`=no `.sfs-local/` or no active sprint, `4`=template
     missing, `6`=gate id invalid or required, `7`=usage, `99`=unknown.
   - decision: `0`=ok, `1`=id conflict, `4`=template missing, `7`=usage,
     `99`=unknown.
   - retro: `0`=ok, `1`=no `.sfs-local/` or no active sprint, `4`=template
     missing, `7`=usage, `8`=`--close` requested but review.md missing,
     `99`=unknown.
   - loop: `0`=success, `1`=invalid usage, `2`=PROGRESS parse error,
     `3`=drift, `4`=mutex claim failed, `5`=safety_lock, `6`=spec missing,
     `7`=verify fail, `8`=heartbeat fail, `9`=executor resolve fail,
     `99`=unknown.

5. **Stop** — Do not summarize, paraphrase, or add commentary. The bash
   adapter is the SSoT.

## If first arg is empty or `help`

Print this 3-line usage and stop:

```
Usage: /sfs <command> [args]
Commands: status, start, plan, review, decision, retro, loop
Help: bash .sfs-local/scripts/sfs-<command>.sh --help
```

## ⚠️ Safety Locks

- `/sfs retro --close` triggers an auto-commit. Confirm the user explicitly
  requested it (don't infer from neighboring context, don't auto-invoke).
- Never run `git push origin *` automatically — push is user-only (§1.5).
- If the bash adapter is missing, do NOT try to fall back to a paraphrase
  workflow that simulates Solon SFS — instead tell the user the adapter is
  missing and suggest `install.sh` / `upgrade.sh`.

## Multi-adaptor Parity

This Skill is the Codex 1급 entry point for Solon SFS. The same workflow is
also exposed:

- **Claude Code**: `.claude/commands/sfs.md` (slash command, native dispatch)
- **Gemini CLI**: `.gemini/commands/sfs.toml` (TOML custom command, native slash)
- **Codex**: 본 Skill (`.agents/skills/sfs/SKILL.md`, project-scoped) +
  optional user-scoped fallback (`~/.codex/prompts/sfs.md`)

All four entry points dispatch to the SAME bash adapter (`.sfs-local/scripts/sfs-*.sh`).
Vendor-asymmetry between adapters is forbidden — if you find drift, it's a
bug to escalate via `/sfs decision` or report upstream.
