---
task_id: loopq-20260501T011540Z-8404
title: "[claude] cpo review model profile contract"
status: claimed   # defanged duplicate (real claim at claimed/claude-overnight/, FUSE delete blocked)
priority: 3
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: ""
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:15:40Z
claimed_at: ""
size: large
target_minutes: 90
depends_on:
  - loopq-20260501T011500Z-8400
  - loopq-20260501T011510Z-8401
  - loopq-20260501T011520Z-8402
  - loopq-20260501T011530Z-8403
---

# [claude] cpo review model profile contract

## Goal

Run a CPO-style review of the runtime-neutral model profile work for 0.5.39
and 0.5.40.

Scope:
- Review product risk, onboarding clarity, and role-boundary clarity.
- Confirm current-runtime fallback does not imply Solon decides the user's
  model choice.
- Confirm C-Level high / worker standard / helper economy are recommendations,
  not hard blocks.
- Write findings into this task file only.
- Do not modify product files unless a tiny typo fix is obviously blocking.
- Do not implement Windows/Scoop packaging.
- Do not run `git add`, `git commit`, `git push`, or release apply.

## Files Scope

- .sfs-local/queue/pending/loopq-20260501T011540Z-8404-claude-cpo-review-model-profile-contract.md

## Verify

- `test -f 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/model-profiles.yaml`
- `git diff --check`

## Runtime Assignment

- Intended runtime: Claude.
- If Codex claims this by mistake, perform read-only review and leave a note;
  do not self-approve Codex-authored changes.
