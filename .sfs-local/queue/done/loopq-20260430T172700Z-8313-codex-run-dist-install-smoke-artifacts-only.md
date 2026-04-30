---
task_id: loopq-20260430T172700Z-8313
title: "[codex] run dist install smoke artifacts-only"
status: done
priority: 2
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-overnight
attempts: 1
max_attempts: 3
created_at: 2026-04-30T17:27:00Z
claimed_at: 2026-04-30T17:29:45Z
size: medium
target_minutes: 45
depends_on:
  - loopq-20260430T172200Z-8310
  - loopq-20260430T172210Z-8311
failed_at: 2026-04-30T17:28:21Z
retried_at: 2026-04-30T17:29:42Z
completed_at: 2026-04-30T17:29:57Z
---

# [codex] run dist install smoke artifacts-only

## Goal

Run a sandbox-only distribution install smoke while the review/log task is blocked by another runtime.

Scope:
- Use `/private/tmp` only.
- Do not edit `.sfs-local/sprints/solon-loop-queue-mvp/log.md` or `retro.md`; those are currently blocked by Claude review ownership.
- Record evidence in this claimed queue task file before completion.
- Install/copy `2026-04-19-sfs-v0.4/solon-mvp-dist` into a temporary consumer project with `install.sh --yes --layout vendored`.
- Verify installed queue surface:
  - queue directories exist.
  - installed `.sfs-local/scripts/sfs-loop.sh` parses.
  - `enqueue --size small --target-minutes 5` writes metadata.
  - `queue` reports stale claimed tasks.
  - `verify`, `complete`, `fail`, `retry`, `abandon` paths are present in help/docs or work through one lightweight smoke.
- Do not run `git add`, `git commit`, or `git push`.

## Files Scope

- `.sfs-local/queue/claimed/codex-overnight/loopq-20260430T172700Z-8313-codex-run-dist-install-smoke-artifacts-only.md`
- sandbox under `/private/tmp`

## Verify

- `git diff --check`
- sandbox install exits 0
- installed `bash -n .sfs-local/scripts/sfs-loop.sh` passes
- installed queue smoke passes

## Evidence

### 2026-05-01T02:28:00+09:00 — failed

- Sandbox target: `/private/tmp/sfs-dist-install-debug.jGcQYx/target`
- Command: `2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh --yes --layout vendored`
- Install exited 0.
- Failure: installed `.sfs-local/queue/pending` was missing.
- Cause observed in `install.sh`: vendored install copies `.sfs-local-template/scripts`, `sprint-templates`, `personas`, and `decisions-template`, but does not create/copy `.sfs-local/queue/{pending,claimed,done,failed,abandoned}`.
- Action: leave this smoke task failed and queue a focused install scaffold fix task.

### 2026-05-01T02:32:00+09:00 — retry passed

- Retry after `loopq-20260430T172900Z-8314` fixed install queue scaffold.
- Sandbox target: `/private/tmp/sfs-dist-install.lQQw7E/target`.
- Install exited 0.
- Installed `.sfs-local/queue/{pending,claimed,done,failed,abandoned,runs}` all existed.
- Installed `.sfs-local/scripts/sfs-loop.sh` `bash -n` PASS.
- Installed queue smoke PASS:
  - `enqueue --size small --target-minutes 5`
  - stale claimed visibility
  - `verify` claimed pass task → `done/`
  - `retry` max-attempts-exceeded task → `abandoned/`
