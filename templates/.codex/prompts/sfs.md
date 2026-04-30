# Solon SFS — Codex CLI custom prompt (user-scoped slash fallback)
#
# Path (user-scoped, NOT project-scoped):
#   ~/.codex/prompts/sfs.md
# Invoke:
#   /sfs $ARGUMENTS
#
# This file is an OPTIONAL fallback. The primary Codex 1급 entry point for
# Solon SFS is the project-scoped Skill at `.agents/skills/sfs/SKILL.md`,
# which is auto-installed by `install.sh` and works with implicit + explicit
# invocation.
#
# Use this user-scoped slash if you prefer the native `/sfs` popup over
# Skills implicit invocation. Install manually:
#   mkdir -p ~/.codex/prompts
#   cp <consumer-project>/templates/.codex/prompts/sfs.md ~/.codex/prompts/sfs.md
#
# Then in Codex CLI: type `/sfs status` (or `/prompts:sfs status`).

You are operating in a project that has Solon SFS installed.

The user has invoked `/sfs $ARGUMENTS`. Treat the first whitespace-delimited
token as the subcommand and the remainder as that subcommand's arguments.

## Behavior

If the first argument is `status`, `start`, `plan`, `review`, `decision`,
`retro`, or `loop`, dispatch to `.sfs-local/scripts/sfs-<name>.sh` and stop.
These seven subcommands are deterministic and must NOT be re-interpreted by
the model.

| First arg | Script |
|:--|:--|
| `status`   | `bash .sfs-local/scripts/sfs-status.sh <args>`   |
| `start`    | `bash .sfs-local/scripts/sfs-start.sh <args>`    |
| `plan`     | `bash .sfs-local/scripts/sfs-plan.sh <args>`     |
| `review`   | `bash .sfs-local/scripts/sfs-review.sh <args>`   |
| `decision` | `bash .sfs-local/scripts/sfs-decision.sh <args>` |
| `retro`    | `bash .sfs-local/scripts/sfs-retro.sh <args>`    |
| `loop`     | `bash .sfs-local/scripts/sfs-loop.sh <args>`     |

## Procedure

1. Verify `.sfs-local/scripts/sfs-<first-arg>.sh` exists and is executable.
   If missing, report 1 line and stop.
2. Re-quote args safely. Reject newline/NUL byte args.
3. Execute via shell. Capture stdout/stderr/exit.
4. Print stdout verbatim. If exit≠0, also print stderr + `exit <code>` line.
5. Stop. No paraphrase, no summary.

## ⚠️ Safety

- `/sfs retro --close` triggers auto-commit. Confirm explicit user intent.
- Never run `git push origin *` automatically — push is user-only (§1.5).

## Why this exists alongside the Skill

Codex CLI has two extension points:
1. **Skills** (`.agents/skills/<name>/SKILL.md`) — project-scoped, supports
   implicit + explicit (`$<name>`) invocation. Recommended primary.
2. **Custom prompts** (`~/.codex/prompts/<name>.md`) — user-scoped, native
   slash popup (`/<name>`). Optional fallback.

Solon SFS ships both for parity with Claude Code (slash) and Gemini CLI
(slash). Pick whichever feels native — they dispatch to the same bash adapter.
