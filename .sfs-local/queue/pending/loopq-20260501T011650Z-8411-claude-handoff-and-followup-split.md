---
task_id: loopq-20260501T011650Z-8411
title: "[claude] handoff and follow-up split"
status: pending
priority: 5
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: ""
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:16:50Z
claimed_at: ""
size: medium
target_minutes: 60
depends_on:
  - loopq-20260501T011610Z-8407
  - loopq-20260501T011620Z-8408
---

# [claude] handoff and follow-up split

## Goal

Prepare a concise handoff after the current release-prep queue has enough
evidence, while keeping Windows/Scoop as a post-release follow-up instead of
mixing it into the current release.

Scope:
- Summarize completed queue evidence and remaining blockers.
- Add Windows global runtime/Scoop as a follow-up only, not an active release
  item.
- Do not run handoff automation if it would overwrite richer current context;
  inspect first.
- Do not implement Windows/Scoop packaging.
- Do not run `git add`, `git commit`, `git push`, or release apply.

## Files Scope

- 2026-04-19-sfs-v0.4/HANDOFF-next-session.md
- .sfs-local/queue/pending/loopq-20260501T011650Z-8411-claude-handoff-and-followup-split.md

## Verify

- `git diff --check`

## Runtime Assignment

- Intended runtime: Claude.
- Keep handoff short. Do not turn this into a new planning sprint.
