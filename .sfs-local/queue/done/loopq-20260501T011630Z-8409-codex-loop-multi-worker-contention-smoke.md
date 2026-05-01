---
task_id: loopq-20260501T011630Z-8409
title: "[codex] loop multi-worker contention smoke"
status: done
priority: 3
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-release-loop
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:16:30Z
claimed_at: 2026-05-01T01:28:57Z
size: medium
target_minutes: 60
completed_at: 2026-05-01T01:31:08Z
---

# [codex] loop multi-worker contention smoke

## Goal

Exercise the loop queue with multiple owners in a sandbox so Claude/Codex
overnight work does not double-claim the same task or collide on files_scope.

Scope:
- Use a copied `.sfs-local` under `/private/tmp`.
- Create sandbox tasks with overlapping and non-overlapping `## Files Scope`.
- Verify dependency and files_scope blocking behavior.
- Do not edit product runtime unless a clear bug is found; record findings.
- Do not implement Windows/Scoop packaging.
- Do not run `git add`, `git commit`, `git push`, or release apply.

## Files Scope

- /private/tmp
- .sfs-local/queue/pending/loopq-20260501T011630Z-8409-codex-loop-multi-worker-contention-smoke.md

## Verify

- `bash -n .sfs-local/scripts/sfs-loop.sh`
- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `git diff --check`

## Runtime Assignment

- Intended runtime: Codex.
- This task is safe to run in parallel because all mutation is sandbox-only.

## Evidence

2026-05-01T01:32Z Codex sandbox smoke PASS.

Sandbox:
- `/private/tmp/sfs-loop-contention.8DM3vE/project`

Fixture:
- Claimed task `loopq-sandbox-claimed-shared` owned by `owner-a` with `## Files Scope` = `shared/path`.
- Pending task `loopq-sandbox-overlap` with `## Files Scope` = `shared/path/child`.
- Pending task `loopq-sandbox-dep` with `depends_on: [loopq-missing]`.
- Pending task `loopq-sandbox-free` with `## Files Scope` = `free/path`.

Observed behavior:
- `sfs-loop.sh queue --owner owner-b` reported `blocked · files_scope shared/path/child overlaps loopq-sandbox-claimed-shared@owner-a`.
- `sfs-loop.sh queue --owner owner-b` reported `blocked · deps loopq-missing · task loopq-sandbox-dep`.
- `sfs-loop.sh claim --owner owner-b` claimed only `.sfs-local/queue/claimed/owner-b/loopq-sandbox-free.md`.
- `sfs-loop.sh claim --owner owner-c` returned exit 6 with `queue: no pending task`, confirming the already-claimed task was not double-claimed.
- Final sandbox queue count: `queue · pending 2 · claimed 2 · done 0 · failed 0 · abandoned 0`; remaining pending tasks were still blocked by dependency/files_scope.

Verification:
- `bash -n .sfs-local/scripts/sfs-loop.sh` PASS.
- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh` PASS.
- `git diff --check` PASS.

Notes:
- No product runtime edits were needed.
- Windows/Scoop packaging was not touched; it is owned by another session.
