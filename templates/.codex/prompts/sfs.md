# Solon SFS — Codex CLI custom prompt (legacy/user-scoped fallback)
#
# Path (user-scoped, NOT project-scoped):
#   ~/.codex/prompts/sfs.md
# Invoke on Codex builds that still support user prompts:
#   /prompts:sfs $ARGUMENTS
#
# This file is an OPTIONAL/legacy fallback. `/sfs` remains the Solon public
# command surface. The project-scoped Skill at `.agents/skills/sfs/SKILL.md`
# is the primary Codex adaptor asset installed by `install.sh`.
#
# Current Codex CLI builds may reserve leading slash names for native commands
# and reject unregistered `/sfs` before the model sees it. Treat that as a
# runtime adaptor compatibility gap; `/prompts:sfs` is only a bypass when your
# Codex build exposes `/prompts:<name>` custom prompts:
#   mkdir -p ~/.codex/prompts
#   cp <consumer-project>/templates/.codex/prompts/sfs.md ~/.codex/prompts/sfs.md
#
# Then in Codex CLI: type `/prompts:sfs status`.

You are operating in a project that has Solon SFS installed.

The user has invoked this prompt with `$ARGUMENTS`. Treat the first
whitespace-delimited token as the subcommand and the remainder as that
subcommand's arguments.

## Behavior

If the first argument is `status`, `start`, `guide`, `auth`, `brainstorm`, `plan`, `review`, `decision`,
`retro`, or `loop`, dispatch to `.sfs-local/scripts/sfs-<name>.sh` and stop.
These ten subcommands are deterministic and must NOT be re-interpreted by
the model.

| First arg | Script |
|:--|:--|
| `status`   | `bash .sfs-local/scripts/sfs-dispatch.sh status <args>`   |
| `start`    | `bash .sfs-local/scripts/sfs-dispatch.sh start <args>`    |
| `guide`    | `bash .sfs-local/scripts/sfs-dispatch.sh guide <args>`    |
| `auth`     | `bash .sfs-local/scripts/sfs-dispatch.sh auth <args>`     | Codex/Claude/Gemini auth status/login/probe |
| `brainstorm` | `bash .sfs-local/scripts/sfs-dispatch.sh brainstorm <args>` |
| `plan`     | `bash .sfs-local/scripts/sfs-dispatch.sh plan <args>`     |
| `review`   | `bash .sfs-local/scripts/sfs-dispatch.sh review <args>`   | CPO Evaluator review; pass `--gate`, `--executor`, `--generator`, `--run`, `--allow-empty` verbatim |
| `decision` | `bash .sfs-local/scripts/sfs-dispatch.sh decision <args>` |
| `retro`    | `bash .sfs-local/scripts/sfs-dispatch.sh retro <args>`    |
| `loop`     | `bash .sfs-local/scripts/sfs-dispatch.sh loop <args>`     |

## Procedure

1. Verify `.sfs-local/scripts/sfs-dispatch.sh` and
   `.sfs-local/scripts/sfs-<first-arg>.sh` exist and are executable. If
   missing, report 1 line and stop.
   On Windows PowerShell, `.sfs-local/scripts/sfs.ps1 <command> [args]` is the
   wrapper entry point; it requires Git Bash. WSL users should invoke the bash
   adapter from inside the WSL shell.
2. Re-quote args safely. Reject newline/NUL byte args, except for `brainstorm`.
3. Execute via shell. Capture stdout/stderr/exit.
4. Print stdout verbatim. If exit≠0, also print stderr + `exit <code>` line.
5. Stop. No paraphrase, no summary.

## ⚠️ Safety

- `/sfs retro --close` triggers auto-commit. Confirm explicit user intent.
- Never run `git push origin *` automatically — push is user-only (§1.5).

## Why this exists alongside the Skill

Codex CLI has two partial extension points:
1. **Skills** (`.agents/skills/<name>/SKILL.md`) — project-scoped, supports
   implicit + explicit (`$<name>`) invocation.
2. **Custom prompts** (`~/.codex/prompts/<name>.md`) — user-scoped, optional
   legacy fallback on Codex builds that expose `/prompts:<name>`.

Solon SFS ships both for parity with Claude Code (slash) and Gemini CLI
(slash). Codex desktop app / compatible Codex surfaces where `/sfs` reaches
the model are already first-class paths. Parity is incomplete only for Codex
CLI builds that reject unknown leading-slash commands before the model sees
them. `$sfs ...`, natural language, and `/prompts:sfs ...` are temporary
bypasses for those builds, not a separate Solon API.
