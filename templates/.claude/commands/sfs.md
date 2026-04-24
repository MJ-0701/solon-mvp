---
description: Run the Solon SFS workflow in this project
argument-hint: "[help|status|start|plan|sprint|review|decision|log|retro] [details]"
---

# Solon SFS Command

You are running the Solon SFS workflow for this project.

First, read these files if they exist:

- `CLAUDE.md`
- `.sfs-local/VERSION`
- `.sfs-local/divisions.yaml`
- `.sfs-local/events.jsonl`
- Recent files under `.sfs-local/sprints/`
- Recent files under `.sfs-local/decisions/`

Then interpret the user arguments:

```text
$ARGUMENTS
```

## Command Behavior

If no arguments are provided, show a compact SFS status and a short usage guide:

- Current Solon version from `.sfs-local/VERSION`
- Latest sprint directory, if any
- Recent gate or decision signals from `.sfs-local/events.jsonl`
- Suggested next SFS action
- Quick examples for `help`, `start`, `plan`, `review`, and `decision`

If the first argument is one of the modes below, follow that mode.

- `help`: Explain how to use `/sfs`, show available modes, and recommend the best first command.
- `status`: Summarize the current SFS state and next action.
- `start`: Create or continue a sprint under `.sfs-local/sprints/<YYYY-Wxx-sprint-n>/`.
- `plan`: Produce or update the current sprint `plan.md`.
- `sprint`: Convert the current plan into implementation steps and gate checks.
- `review`: Review the current sprint output and write/update `review.md`.
- `decision`: Record a short ADR-style decision under `.sfs-local/decisions/`.
- `log`: Append a one-line JSON event to `.sfs-local/events.jsonl`.
- `retro`: Write or update the current sprint `retro-light.md`.

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
