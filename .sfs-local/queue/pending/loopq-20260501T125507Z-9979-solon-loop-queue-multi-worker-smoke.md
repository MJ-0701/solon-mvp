---
task_id: loopq-20260501T125507Z-9979
title: "solon-loop-queue-multi-worker-smoke"
status: pending
priority: 5
mode: user-active-deferred
sprint_id: ""
owner: ""
attempts: 0
max_attempts: 3
created_at: 2026-05-01T12:55:07Z
claimed_at: ""
size: small
target_minutes: 30
---

# solon-loop-queue-multi-worker-smoke

## Goal

Prove the loop queue claim path is safe under concurrent workers. The smoke
should show that only one worker can claim a pending item and other workers fail
or back off without corrupting queue state.

Concrete outcome:
- Build a temp repo or temp queue fixture with one pending task.
- Run two or three workers/claim attempts as concurrently as practical.
- Capture which worker wins, where losing attempts land, and whether the task
  file remains valid markdown/frontmatter.

## Files Scope

- Prefer test/smoke scripts or temporary harness files under `/private/tmp`.
- `.sfs-local/scripts/sfs-loop.sh` and product template copy only if the smoke
  exposes a real race.
- Queue docs only if user-visible guidance changes.

## Verify

- Run the contention smoke at least 3 times.
- Confirm exactly one claimed owner per run.
- Confirm no duplicate task copies remain across pending/claimed/done/failed.
- Run `sfs loop queue` after each smoke and record counts.
