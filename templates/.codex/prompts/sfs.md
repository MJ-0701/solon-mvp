# Solon SFS — Codex CLI custom prompt (legacy/user-scoped fallback)
#
# Path (user-scoped, NOT project-scoped):
#   ~/.codex/prompts/sfs.md
# Invoke on Codex builds that still support user prompts:
#   /prompts:sfs $ARGUMENTS
#
# This file is an OPTIONAL/legacy fallback. In Codex, the project-scoped Skill
# at `.agents/skills/sfs/SKILL.md` is the primary adaptor asset installed by
# `install.sh`; use `$sfs ...` / `sfs ...` when the host slash UI blocks `/sfs`.
#
# Current Codex app/CLI builds may reserve leading slash names for native
# commands and reject unregistered `/sfs` before the model sees it (`커맨드 없음`
# / `Unrecognized command`). Treat that as a runtime adaptor compatibility gap;
# `/prompts:sfs` is only a bypass when your Codex build exposes `/prompts:<name>`
# custom prompts:
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
`retro`, or `loop`, dispatch to `.sfs-local/scripts/sfs-<name>.sh` first.
For every command except `brainstorm`, stop after printing adapter output.
For `brainstorm`, capture raw input first and then fill `brainstorm.md` §1~§7
as Solon CEO.

| First arg | Script |
|:--|:--|
| `status`   | `bash .sfs-local/scripts/sfs-dispatch.sh status <args>`   |
| `start`    | `bash .sfs-local/scripts/sfs-dispatch.sh start <args>`    |
| `guide`    | `bash .sfs-local/scripts/sfs-dispatch.sh guide <args>`    |
| `auth`     | `bash .sfs-local/scripts/sfs-dispatch.sh auth <args>`     | Codex/Claude/Gemini auth status/login/probe |
| `brainstorm` | `bash .sfs-local/scripts/sfs-dispatch.sh brainstorm <args>` | raw capture, then Solon CEO refinement |
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
5. For non-brainstorm commands, stop. No paraphrase, no summary.

## Brainstorm CEO Refinement

After `/sfs brainstorm` succeeds:

1. Resolve the active `brainstorm.md` path from adapter stdout, or read
   `.sfs-local/current-sprint` and open
   `.sfs-local/sprints/<current-sprint>/brainstorm.md`.
2. Read `§8. Append Log`; preserve it as raw user data.
3. Act as **Solon CEO** and fill/update `§1`~`§6`: raw brief, problem space,
   constraints, options, scope seed, and plan seed.
4. Update `§7` checklist only for satisfied items.
5. Add up to 3 open questions if critical information is missing.
6. Set frontmatter `status: ready-for-plan` only when `/sfs plan` has enough
   material; otherwise keep `draft`.
7. Do not implement code or run `/sfs plan` automatically.
8. Final response: `brainstorm.md refined: <path>`, optional questions, and
   the next command.

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
(slash). In Codex, current app/CLI surfaces can reject unknown leading-slash
commands before the model sees them, so `$sfs ...`, natural language, and
direct bash are the practical entry paths. `/prompts:sfs ...` is a legacy
fallback only when that feature is available.
