---
task_id: loopq-20260430T172200Z-8310
title: "[codex] implement max-attempts and abandoned policy"
status: done
priority: 1
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-overnight
attempts: 0
max_attempts: 3
created_at: 2026-04-30T17:22:00Z
claimed_at: 2026-04-30T17:22:25Z
size: medium
target_minutes: 45
depends_on:
  - loopq-20260430T171110Z-8302
completed_at: 2026-04-30T17:24:01Z
---

# [codex] implement max-attempts and abandoned policy

## Goal

Finish the retry policy left deferred by the verify runner slice.

Scope:
- Add explicit abandoned lifecycle support if it fits the current `sfs-loop.sh` shape:
  - `abandon <task-id-or-path>` manual command, or an internal helper plus automatic move.
- Enforce `max_attempts` conservatively:
  - `retry` increments attempts when returning a failed/abandoned/claimed task to pending.
  - if retry would exceed `max_attempts`, move task to `abandoned/` instead of `pending/`.
  - verification failure itself must not increment attempts.
- Preserve current `complete`, `fail`, `retry`, `verify`, queue-first run artifact, and stale visibility behavior.
- Sync active and product dist scripts byte-for-byte.
- Update README/GUIDE/SFS template only if command help changes.
- Keep bash 3.2 compatible.
- Do not run `git add`, `git commit`, or `git push`.

## Files Scope

- `.sfs-local/scripts/sfs-loop.sh`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/README.md`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/SFS.md.template`
- `.sfs-local/sprints/solon-loop-queue-mvp/log.md`

## Verify

- `bash -n .sfs-local/scripts/sfs-loop.sh`
- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `cmp -s .sfs-local/scripts/sfs-loop.sh 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- Sandbox smoke:
  - create failed task with `attempts: 0`, `max_attempts: 2`
  - `retry` moves it to pending with `attempts: 1`
  - claim/fail it again, then `retry` moves it to pending with `attempts: 2`
  - claim/fail it again, then `retry` moves it to abandoned and keeps `attempts` at 3 or records the exceeded attempt clearly
  - if manual `abandon` exists, verify it moves a claimed task to abandoned with `abandoned_at`
- `git diff --check`
