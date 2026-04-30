---
task_id: loopq-20260430T171110Z-8302
title: "[codex] implement queue verify runner and auto lifecycle"
status: done
priority: 2
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-overnight
attempts: 0
max_attempts: 3
created_at: 2026-04-30T17:11:10Z
claimed_at: 2026-04-30T17:14:57Z
size: large
target_minutes: 90
depends_on:
  - loopq-20260430T171100Z-8301
completed_at: 2026-04-30T17:18:53Z
---

# [codex] implement queue verify runner and auto lifecycle

## Goal

After a queue task has an execution/run artifact path, add a file-backed verification step that can close the lifecycle automatically.

Scope:
- Parse the claimed task markdown `## Verify` section into runnable shell commands using a conservative line format:
  - bullet lines beginning with ``- `command` `` or ``- command``.
  - ignore prose/TBD lines safely.
- Add a `verify` subcommand or internal helper, whichever best matches current `sfs-loop.sh` structure.
- For default loop execution:
  - after executor/prompt handling, run verify commands when explicitly enabled or when safe in non-live smoke mode.
  - write verify stdout/stderr and exit code to the queue run artifact directory.
  - on all verify commands passing, call the existing lifecycle path to move the task to `done/`.
  - on verify failure, move the task to `failed/` and preserve logs.
- Keep manual `complete`, `fail`, and `retry` commands working.
- Define a simple policy in code comments/log:
  - `retry` increments `attempts` when moving back to pending.
  - verification failure does not increment attempts until `retry`.
  - if max_attempts policy is not implemented in this slice, state that clearly as deferred.
- Sync active and product dist scripts byte-for-byte.
- Keep bash 3.2 compatible.
- Do not run `git add`, `git commit`, or `git push`.

## Files Scope

- `.sfs-local/scripts/sfs-loop.sh`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `.sfs-local/sprints/solon-loop-queue-mvp/log.md`
- Optional docs only if command/help wording changes:
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/README.md`
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md`

## Verify

- `bash -n .sfs-local/scripts/sfs-loop.sh`
- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `cmp -s .sfs-local/scripts/sfs-loop.sh 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- Sandbox smoke:
  - create isolated `SFS_LOCAL_DIR`
  - enqueue or create a task with `## Verify` containing a passing command
  - claim/run/verify it and confirm it moves to `done/`
  - create a second task with a failing verify command
  - run verify and confirm it moves to `failed/`
  - retry the failed task and confirm it returns to `pending/` with attempts incremented
  - confirm verify logs are written under the run artifact path
- `git diff --check`

## Notes

This is the second large autonomous slice. It is allowed to refine the exact interface if the existing code shape suggests a cleaner command boundary, but must stay file-backed and conservative.
