---
name: sfs
description: |
  Solon SFS workflow command.

  Usage: /sfs [command] [goal/details]

  Commands:
  help      사용법 보기
  status    현재 SFS 상태 확인 (bash adapter)
  start     새 sprint 시작 또는 이어가기 (bash adapter)
  plan      현재 sprint plan.md 작성/갱신
  sprint    plan을 구현 단계와 gate 체크로 정리
  review    현재 변경사항 review.md 작성/갱신
  decision  짧은 결정 기록 남기기
  log       events.jsonl에 이벤트 기록
  retro     sprint 회고 작성/갱신
  loop      Ralph Loop + Solon mutex 기반 자율 진행 (bash adapter, WU-27)
argument-hint: "[command] [goal/details]"
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# Solon SFS Command

You are running the Solon SFS workflow for this project.

The user's arguments are interpolated below. Treat the first whitespace-delimited
token as the subcommand and the remainder as that subcommand's arguments.

```text
$ARGUMENTS
```

## Adapter Dispatch (status / start / plan / review / decision / loop) — execute first

If the first argument is **`status`**, **`start`**, **`plan`**, **`review`**,
**`decision`**, or **`loop`**, dispatch the request to the corresponding bash
script under `.sfs-local/scripts/` and stop. These six subcommands are
deterministic and must NOT be re-interpreted by the model.

Dispatch table:

| First arg | Script to run | Notes |
|:--|:--|:--|
| `status`   | `.sfs-local/scripts/sfs-status.sh <remaining args>`   | passes flags such as `--color=auto/always/never` verbatim |
| `start`    | `.sfs-local/scripts/sfs-start.sh <remaining args>`    | passes `<sprint-id>` and/or `--force` verbatim |
| `plan`     | `.sfs-local/scripts/sfs-plan.sh <remaining args>`     | takes no flags currently; remaining args reserved for future (WU-25 §1) |
| `review`   | `.sfs-local/scripts/sfs-review.sh <remaining args>`   | passes `--gate <id>` / `--gate=<id>` verbatim (gates.md §1 7-enum: G-1, G0, G1, G2, G3, G4, G5; WU-25 §2) |
| `decision` | `.sfs-local/scripts/sfs-decision.sh <remaining args>` | passes `<title>` and optional `--id <override>` / `--id=<override>` verbatim (WU-26 §1, WU-29 hotfix wired-up). Uses `sprint-templates/decision-light.md`. |
| `loop`     | `.sfs-local/scripts/sfs-loop.sh <remaining args>`     | Ralph Loop + Solon mutex + executor convention (claude/gemini/codex). passes `--mode`, `--executor`, `--max-iters`, `--parallel`, `--dry-run`, etc. verbatim (WU-27 §3) |

Procedure (apply in order):

1. **Existence check** — Use the Bash tool to verify the target script exists
   and is executable. If `.sfs-local/scripts/sfs-{status,start,plan,review,decision,loop}.sh`
   is missing or not executable, fall back to the **Claude-driven mode** below
   for that subcommand and tell the user which script is missing (1 line, no
   speculation about the cause).
2. **Quote args safely** — Re-quote `<remaining args>` for the shell. Reject
   any argument containing a newline or NUL byte by reporting `unknown arg`
   instead of executing.
3. **Execute** — Run the script via the Bash tool. Capture stdout, stderr, and
   exit code. Do not pipe through any other transformer.
4. **Print output verbatim** — Emit the script's stdout exactly as produced
   (preserve whitespace and any ANSI color escape codes from `--color=always`).
   If exit code is non-zero, also print stderr and the exit code on a final
   line: `exit <code>`. Map known exit codes per the script contract:
   - status: `0`=ok, `1`=no `.sfs-local/`, `2`=corrupt `events.jsonl`,
     `3`=not a git repo, `99`=unknown.
   - start: `0`=ok, `1`=sprint id conflict (suggest `--force`), `4`=templates
     missing, `5`=permission, `99`=unknown.
   - plan: `0`=ok, `1`=no `.sfs-local/` or no active sprint,
     `2`=corrupt `current-sprint`, `4`=template missing, `99`=unknown.
   - review: `0`=ok, `1`=no `.sfs-local/` or no active sprint,
     `4`=template missing, `6`=gate id invalid or required
     (`unknown gate <id>, valid: G-1, G0, G1, G2, G3, G4, G5`),
     `7`=unknown CLI flag, `99`=unknown.
   - decision: `0`=ok, `1`=`--id` conflict (decision already exists),
     `2`=corrupt `events.jsonl`, `3`=not a git repo,
     `4`=`sprint-templates/decision-light.md` missing, `5`=permission,
     `7`=`<title>` missing or unknown CLI flag, `99`=unknown.
   - loop: `0`=ok, `1`=invalid usage, `2`=PROGRESS frontmatter parse,
     `3`=drift detected (resume-check exit 16), `4`=mutex claim failed,
     `5`=safety_lock tripped, `6`=WU spec missing/corrupt,
     `7`=artifact verify fail, `8`=heartbeat write fail (FUSE),
     `9`=executor resolve fail, `99`=unknown.
5. **Stop** — After dispatch, do not add Claude-driven commentary,
   recommendations, or alternative suggestions. The bash script is the
   single source of truth for output format (WU22-D4: `·` separator + ISO8601
   timestamp + per-field color rules; WU-25 §1.1/§2.1: `plan.md ready: <path>`
   / `review.md ready: <path> | gate <id> awaiting verdict`).

If `$ARGUMENTS` is empty, treat it as if the user typed `status` (run the
status adapter) so that bare `/sfs` produces the canonical compact status line.

## Read Context (Claude-driven modes only)

For the remaining subcommands (`help`, `sprint`, `log`, `retro`)
and for adapter fallbacks (including `plan` / `review` / `decision` when their
scripts are missing), first read these files if they exist:

- `CLAUDE.md`
- `.sfs-local/VERSION`
- `.sfs-local/divisions.yaml`
- `.sfs-local/events.jsonl`
- Recent files under `.sfs-local/sprints/`
- Recent files under `.sfs-local/decisions/`

## Command Behavior (Claude-driven modes)

If `$ARGUMENTS` is empty and the status adapter is unavailable, show a compact
SFS status and a short usage guide:

- Current Solon version from `.sfs-local/VERSION`
- Latest sprint directory, if any
- Recent gate or decision signals from `.sfs-local/events.jsonl`
- Suggested next SFS action
- Quick examples for `help`, `start`, `plan`, `review`, and `decision`

If the first argument is one of the modes below, follow that mode.

- `help`: Explain how to use `/sfs`, show available modes, and recommend the best first command.
- `status`: **Adapter (above).** Fallback only: summarize the current SFS state and next action from the files listed under "Read Context".
- `start`: **Adapter (above).** Fallback only: scaffold a sprint under `.sfs-local/sprints/<YYYY-Wxx-sprint-n>/` based on `sprint-templates/`.
- `plan`: **Adapter (above).** Fallback only: produce or update the current sprint `plan.md` based on `sprint-templates/plan.md`.
- `sprint`: Convert the current plan into implementation steps and gate checks.
- `review`: **Adapter (above).** Fallback only: review the current sprint output and write/update `review.md` (require `--gate <id>` from gates.md §1 7-enum).
- `decision`: **Adapter (above).** Fallback only: write a short ADR-style decision under `.sfs-local/decisions/` based on `sprint-templates/decision-light.md`.
- `log`: Append a one-line JSON event to `.sfs-local/events.jsonl`.
- `retro`: Write or update the current sprint `retro-light.md`.
- `loop`: **Adapter (above).** Fallback only: explain Ralph Loop + Solon mutex pattern and recommend running `.sfs-local/scripts/sfs-loop.sh --help` directly (WU-27).

## Usage Guide Output

When showing usage, keep it compact and practical. Include this shape:

```text
/sfs help                 사용법 보기
/sfs status               현재 SFS 상태 확인
/sfs start <goal>         새 sprint 시작 또는 이어가기
/sfs plan                 현재 sprint plan.md 작성/갱신
/sfs review               현재 변경사항 review.md 작성/갱신
/sfs decision <decision>  짧은 결정 기록 남기기
/sfs retro                sprint 회고 작성/갱신
```

Also explain this in one or two sentences:

- Solon MVP is a lightweight scaffold, not the full Solon system yet.
- The main artifacts live under `.sfs-local/`, and `/sfs` is the Claude Code command layer for operating them.

## Rules

- Preserve existing user work.
- Ask only when a decision changes project behavior or could discard work.
- Keep sprint artifacts concise and operational.
- Do not invent completed work. If evidence is missing, mark it as unknown.
- Prefer concrete next actions over broad methodology explanations.
- For `status`, `start`, `plan`, `review`, `decision`, and `loop`, the bash adapter is authoritative — do not paraphrase or augment its output.
