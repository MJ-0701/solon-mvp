---
task_id: loopq-20260501T020828Z-10246
title: "codex fix queue same-owner files-scope guard"
status: done
priority: 2
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-loop
attempts: 0
max_attempts: 3
created_at: 2026-05-01T02:08:28Z
claimed_at: 2026-05-01T02:09:26Z
size: medium
target_minutes: 45
completed_at: 2026-05-01T02:13:38Z
---

# codex fix queue same-owner files-scope guard

## Goal

Fix the queue picker regression observed during the 8404/8405/8407 chain:
claimed tasks owned by the same loop owner must still participate in the
files_scope overlap guard. The owner may be the same process, but overlapping
claimed work is still active work and must block a second pending task.

Scope:
- Update the distributable `sfs-loop.sh` template and the installed local copy.
- Preserve dependency filtering and scheduled/user-active mode filtering.
- Add a sandbox smoke that creates a same-owner claimed task plus an overlapping
  pending task and confirms the pending task is blocked.
- Do not change unrelated queue lifecycle commands.
- Git commit/push is allowed after verification for this task.

## Files Scope

- 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh
- .sfs-local/scripts/sfs-loop.sh
- .sfs-local/queue/pending/loopq-20260501T020828Z-10246-codex-fix-queue-same-owner-files-scope-guard.md

## Verify

- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `bash -n .sfs-local/scripts/sfs-loop.sh`
- `git diff --check`

## Verification Evidence

- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh` — PASS
- `bash -n .sfs-local/scripts/sfs-loop.sh` — PASS
- Sandbox smoke in `/tmp/sfs-loop-same-owner.*` — PASS for both script copies:
  - created claimed task `smoke-claimed` owned by `codex-smoke` with `Files Scope: src/shared`
  - created pending task `smoke-pending` with overlapping `Files Scope: src/shared/file.txt`
  - `queue --owner codex-smoke` reported `blocked · files_scope src/shared/file.txt overlaps smoke-claimed@codex-smoke`
  - `claim --owner codex-smoke` exited `6` and left the pending task unmoved
