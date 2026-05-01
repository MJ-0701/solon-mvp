---
task_id: loopq-20260501T011610Z-8407
title: "[claude] release readiness audit 0.5.40"
status: claimed
priority: 4
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: claude-overnight
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:16:10Z
claimed_at: 2026-05-01T01:46:00Z
size: medium
target_minutes: 60
depends_on:
  - loopq-20260501T011540Z-8404
  - loopq-20260501T011550Z-8405
  - loopq-20260501T011600Z-8406
---

# [claude] release readiness audit 0.5.40

## Goal

Perform a read-only release readiness audit for the current dirty 0.5.39/0.5.40
work before any release cut.

Scope:
- Check VERSION/CHANGELOG coherence.
- Check README/GUIDE public wording for the model profile feature.
- Check that Windows/Scoop is not mixed into this release line.
- Record release blockers and non-blockers in this task file only.
- Do not modify product files unless explicitly tiny typo-only.
- Do not run `git add`, `git commit`, `git push`, or release apply.

## Files Scope

- .sfs-local/queue/pending/loopq-20260501T011610Z-8407-claude-release-readiness-audit-0540.md

## Verify

- `test -f 2026-04-19-sfs-v0.4/solon-mvp-dist/VERSION`
- `test -f 2026-04-19-sfs-v0.4/solon-mvp-dist/CHANGELOG.md`
- `git diff --check`

## Runtime Assignment

- Intended runtime: Claude.
- This is review/evidence only.
