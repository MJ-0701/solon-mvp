---
task_id: loopq-20260430T165817Z-8208
title: "[codex] implement queue lifecycle subcommands"
status: done
priority: 1
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-overnight
attempts: 0
max_attempts: 3
created_at: 2026-04-30T16:58:17Z
claimed_at: 2026-04-30T16:59:28Z
completed_at: 2026-04-30T17:07:49Z
---

# [codex] implement queue lifecycle subcommands

## Goal

Implement the next code slice for `solon-loop-queue-mvp`: queue lifecycle subcommands.

Scope:
- Add `/sfs loop complete <task-id-or-path>`, `fail <task-id-or-path>`, and `retry <task-id-or-path>` to active `.sfs-local/scripts/sfs-loop.sh`.
- Sync the same implementation to `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`.
- Keep queue MVP file-backed and bash 3.2 compatible.
- Preserve existing queue/enqueue/claim/default queue-first/domain_locks fallback behavior.
- Do not run `git add`, `git commit`, or `git push`.

## Files Scope

- `.sfs-local/scripts/sfs-loop.sh`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `.sfs-local/sprints/solon-loop-queue-mvp/log.md`
- Optional docs only if needed for command help consistency:
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/README.md`
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md`

## Verify

- `bash -n .sfs-local/scripts/sfs-loop.sh`
- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `cmp -s .sfs-local/scripts/sfs-loop.sh 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- Sandbox smoke:
  - enqueue a task
  - claim it
  - complete it and confirm it moves to `done/`
  - enqueue/claim another task
  - fail it and confirm it moves to `failed/`
  - retry it and confirm it returns to `pending/` with attempts incremented or preserved according to the simplest documented policy
- `git diff --check`

## Runtime Assignment

- Intended runtime: Codex.
- If Claude claims this task by mistake, stop after reading and leave it pending/failed with a note; do not implement.
