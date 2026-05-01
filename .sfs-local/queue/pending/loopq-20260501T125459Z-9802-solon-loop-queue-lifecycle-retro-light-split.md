---
task_id: loopq-20260501T125459Z-9802
title: "solon-loop-queue-lifecycle retro-light split"
status: pending
priority: 5
mode: user-active-deferred
sprint_id: ""
owner: ""
attempts: 0
max_attempts: 3
created_at: 2026-05-01T12:54:59Z
claimed_at: ""
size: medium
target_minutes: 45
---

# solon-loop-queue-lifecycle retro-light split

## Goal

Split the queue MVP lifecycle follow-up into a light retro/backlog path instead
of mixing lifecycle, verify, sizing, dependency, and files-scope work into one
large inline patch.

Concrete outcome:
- Define the minimal queue lifecycle states and when an item should move between
  pending, claimed, done, failed, and abandoned.
- Decide which learnings belong in a short retro-light note versus a full sprint
  retro.
- Capture backlog seeds for anything larger than this task instead of expanding
  scope.

## Files Scope

- `.sfs-local/scripts/sfs-loop.sh`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `.sfs-local/GUIDE.md`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md`
- Relevant queue docs/templates only if lifecycle wording must be user-visible.

## Verify

- `bash -n` on touched loop scripts.
- `sfs loop queue` shows stable counts before/after.
- Add or run a focused smoke that moves a synthetic item through the documented
  lifecycle without touching unrelated queue items.
- Record any deferred work as separate pending queue tasks, not inline TODOs.
