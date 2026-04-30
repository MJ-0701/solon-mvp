---
task_id: loopq-20260430T172210Z-8311
title: "[codex] implement queue dependency and files-scope guard"
status: done
priority: 2
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-overnight
attempts: 0
max_attempts: 3
created_at: 2026-04-30T17:22:10Z
claimed_at: 2026-04-30T17:24:05Z
size: large
target_minutes: 90
depends_on:
  - loopq-20260430T172200Z-8310
completed_at: 2026-04-30T17:25:55Z
---

# [codex] implement queue dependency and files-scope guard

## Goal

Prevent queue workers from claiming tasks whose dependencies are not complete, and surface obvious files-scope collisions.

Scope:
- Teach queue picking/claiming to respect simple `depends_on` task IDs:
  - a pending task is eligible only when every listed dependency is in `done/`.
  - blocked tasks should be skipped, not failed.
- Add a non-destructive visibility line to `queue` output for blocked pending tasks if straightforward.
- Add a conservative files-scope collision check:
  - read `## Files Scope` bullet paths from pending and claimed tasks.
  - if a pending task overlaps with a claimed task owned by another worker, skip it or surface it as blocked.
  - keep matching simple string/prefix based; no complex glob engine required.
- Preserve existing behavior for tasks without dependencies/files scope.
- Sync active and product dist scripts byte-for-byte.
- Keep bash 3.2 compatible.
- Do not run `git add`, `git commit`, or `git push`.

## Files Scope

- `.sfs-local/scripts/sfs-loop.sh`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `.sfs-local/sprints/solon-loop-queue-mvp/log.md`

## Verify

- `bash -n .sfs-local/scripts/sfs-loop.sh`
- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `cmp -s .sfs-local/scripts/sfs-loop.sh 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- Sandbox smoke:
  - pending task A with no dependency is claimable
  - pending task B depending on missing/done-not-present task is skipped
  - after placing dependency task in done/, B becomes claimable
  - pending task C with overlapping Files Scope against another claimed worker is skipped or surfaced as blocked
  - pending task D without Files Scope remains claimable
- `git diff --check`
