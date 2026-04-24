---
description: Run the Solon SFS workflow in this project
argument-hint: "[status|start|plan|sprint|review|decision|log|retro] [details]"
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

If no arguments are provided, show a compact SFS status:

- Current Solon version from `.sfs-local/VERSION`
- Latest sprint directory, if any
- Recent gate or decision signals from `.sfs-local/events.jsonl`
- Suggested next SFS action

If the first argument is one of the modes below, follow that mode.

- `status`: Summarize the current SFS state and next action.
- `start`: Create or continue a sprint under `.sfs-local/sprints/<YYYY-Wxx-sprint-n>/`.
- `plan`: Produce or update the current sprint `plan.md`.
- `sprint`: Convert the current plan into implementation steps and gate checks.
- `review`: Review the current sprint output and write/update `review.md`.
- `decision`: Record a short ADR-style decision under `.sfs-local/decisions/`.
- `log`: Append a one-line JSON event to `.sfs-local/events.jsonl`.
- `retro`: Write or update the current sprint `retro-light.md`.

## Rules

- Preserve existing user work.
- Ask only when a decision changes project behavior or could discard work.
- Keep sprint artifacts concise and operational.
- Do not invent completed work. If evidence is missing, mark it as unknown.
- Prefer concrete next actions over broad methodology explanations.
