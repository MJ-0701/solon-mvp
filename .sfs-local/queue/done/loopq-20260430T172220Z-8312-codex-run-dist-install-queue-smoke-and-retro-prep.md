---
task_id: loopq-20260430T172220Z-8312
title: "[codex] run dist install queue smoke and retro prep"
status: done
priority: 3
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-loop
attempts: 1
max_attempts: 3
created_at: 2026-04-30T17:22:20Z
claimed_at: 2026-05-01T02:20:55Z
size: medium
target_minutes: 60
depends_on:
  - loopq-20260430T172200Z-8310
  - loopq-20260430T172210Z-8311
retried_at: 2026-05-01T02:07:55Z
completed_at: 2026-05-01T02:26:47Z
---

# [codex] run dist install queue smoke and retro prep

## Goal

Verify the queue MVP from the distributable install surface, then prepare sprint close evidence without committing.

Scope:
- Use a sandbox copy/install path only; do not mutate external stable repos.
- Install or copy the product dist into a temporary target and verify:
  - queue directories exist.
  - `sfs loop enqueue/queue/claim/verify/complete/fail/retry` help/path behavior works from installed template.
  - docs mention queue execution backlog, lifecycle, sizing, and non-live prompt artifacts.
- Update `.sfs-local/sprints/solon-loop-queue-mvp/log.md` with install smoke evidence.
- If appropriate, update `retro.md` draft with KPT/PDCA notes, but do not close the sprint automatically unless the task explicitly asks and review evidence is sufficient.
- Do not run `git add`, `git commit`, or `git push`.

## Files Scope

- `.sfs-local/sprints/solon-loop-queue-mvp/log.md`
- `.sfs-local/sprints/solon-loop-queue-mvp/retro.md`
- sandbox under `/private/tmp` only

## Verify

- `git diff --check`
- `test -f .sfs-local/sprints/solon-loop-queue-mvp/log.md`
- `grep -n "8312" .sfs-local/sprints/solon-loop-queue-mvp/log.md`
- `grep -n "dist install queue smoke" .sfs-local/sprints/solon-loop-queue-mvp/log.md`
