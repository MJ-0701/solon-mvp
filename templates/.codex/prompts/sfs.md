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

Command modes:
- **Bash-only**: `status`, `start`, `guide`, `auth`, `loop`. Stop after
  verbatim adapter output.
- **Always hybrid**: `brainstorm`, `plan`, `decision`, `retro`. Run the adapter,
  then perform the documented file refinement.
- **Conditional hybrid**: `review`. Continue only when the current runtime
  (`codex`) is the selected CPO evaluator and `--run` did not already execute
  an external bridge. Otherwise stop after adapter output/prompt handoff.

Special close guard: if the user invokes `retro --close` in an AI runtime, do
not run the close adapter first. Run `retro` without `--close`, refine
`retro.md`, then run `retro --close` exactly once.

| First arg | Script |
|:--|:--|
| `status`   | `bash .sfs-local/scripts/sfs-dispatch.sh status <args>`   |
| `start`    | `bash .sfs-local/scripts/sfs-dispatch.sh start <args>`    |
| `guide`    | `bash .sfs-local/scripts/sfs-dispatch.sh guide <args>`    |
| `auth`     | `bash .sfs-local/scripts/sfs-dispatch.sh auth <args>`     | Codex/Claude/Gemini auth status/login/probe |
| `brainstorm` | `bash .sfs-local/scripts/sfs-dispatch.sh brainstorm <args>` | raw capture, then Solon CEO refinement |
| `plan`     | `bash .sfs-local/scripts/sfs-dispatch.sh plan <args>`     | G1 open, then plan refinement |
| `review`   | `bash .sfs-local/scripts/sfs-dispatch.sh review <args>`   | CPO prompt/run. If evaluator=`codex` and no `--run`, Codex fills verdict; otherwise handoff only |
| `decision` | `bash .sfs-local/scripts/sfs-dispatch.sh decision <args>` | creates ADR, then Codex fills Context/Decision/Alternatives/Consequences |
| `retro`    | `bash .sfs-local/scripts/sfs-dispatch.sh retro <args>`    | opens retro.md, then Codex fills KPT/PDCA. With `--close`, refine before close |
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
5. Stop or continue by command mode:
   - `status`, `start`, `guide`, `auth`, `loop`: stop. No paraphrase, no summary.
   - `brainstorm`: Brainstorm CEO Refinement.
   - `plan`: Plan G1 Refinement.
   - `decision`: Decision ADR Refinement.
   - `retro`: Retro G5 Refinement.
   - `review`: Review CPO Refinement only when evaluator is `codex` and
     `--run` was not used.

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

## Plan G1 Refinement

After `/sfs plan` succeeds:

1. Resolve the active `plan.md` path from adapter stdout, or read
   `.sfs-local/current-sprint` and open
   `.sfs-local/sprints/<current-sprint>/plan.md`.
2. Open the same sprint's `brainstorm.md`; use §1~§7 and §8 Append Log as the
   source of truth.
3. Act as **Solon CEO** for requirements/scope, then write the
   **CTO Generator ↔ CPO Evaluator** sprint contract.
4. Fill/update `§1` measurable requirements, `§2` verifiable AC and anti-AC,
   `§3` scope/dependencies/decisions, `§4` G1 checklist, and `§5` sprint
   contract. Add `§6 Phase 1 구현 Backlog Seed` when helpful.
5. Preserve existing user edits.
6. Ask up to 3 questions only if critical information is missing.
7. Do not implement code or run `/sfs review` automatically.
8. Final response: `plan.md refined: <path>`, optional questions, and
   `next: /sfs review --gate G1 --executor codex --generator claude` when ready.

## Decision ADR Refinement

After `/sfs decision` succeeds:

1. Resolve the created ADR path from `decision created: <path>`, or open the
   newest file under `.sfs-local/decisions/`.
2. Read active sprint context if available: `brainstorm.md`, `plan.md`,
   `review.md`, `retro.md`, and `.sfs-local/events.jsonl`.
3. Act as **Solon CEO** and fill/update `Context`, `Decision`, `Alternatives`,
   `Consequences`, and `References`.
4. Preserve frontmatter and user edits. Do not implement code.
5. Ask up to 3 questions only if the ADR cannot be understood without them.
6. Final response: `decision refined: <path>`, optional questions, and
   `next: continue current sprint`.

## Review CPO Refinement

After `/sfs review` succeeds:

1. If `--run` was used, stop after adapter output.
2. If `evaluator_executor` is not `codex`, stop after adapter output/prompt
   handoff. Do not claim Codex performed the review.
3. If `evaluator_executor` is `codex` and `--run` was not used, act as
   **Solon CPO Evaluator**. Read `review.md`, latest CPO prompt/evidence,
   sprint artifacts, and relevant git diff/status. Fill `§1`, `§3`, `§4`, and
   leave `§5` for CTO response.
4. Verdict must be `pass`, `partial`, or `fail` (`G3` only `pass`/`fail`).
5. Final response: `review.md refined: <path>`, `verdict: ...`, and next action.

## Retro G5 Refinement

After `/sfs retro` succeeds:

1. Resolve `retro.md` from stdout or active sprint.
2. Read sprint artifacts, events, and related decisions.
3. Fill/update KPT, PDCA learning, evidence-backed metrics, next sprint handoff,
   and close checklist.
4. Preserve user edits and mark unknowns explicitly.
5. If the user invoked `retro --close`, refine `retro.md` first, then run
   `bash .sfs-local/scripts/sfs-dispatch.sh retro --close` exactly once and
   print its output verbatim.
6. Final response when not closing: `retro.md refined: <path>` plus next action.

## ⚠️ Safety

- `/sfs retro --close` triggers auto-commit. In AI runtimes, refine `retro.md`
  before running the close adapter, and only when the user explicitly requested
  close.
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
