---
task_id: loopq-20260430T172900Z-8314
title: "[codex] fix install queue scaffold"
status: done
priority: 1
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-overnight
attempts: 0
max_attempts: 3
created_at: 2026-04-30T17:29:00Z
claimed_at: 2026-04-30T17:28:37Z
size: medium
target_minutes: 45
depends_on:
  - loopq-20260430T172200Z-8310
  - loopq-20260430T172210Z-8311
completed_at: 2026-04-30T17:29:38Z
---

# [codex] fix install queue scaffold

## Goal

Fix the install smoke failure: vendored installs must create queue state directories.

Scope:
- Update `2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh` so install creates `.sfs-local/queue/{pending,claimed,done,failed,abandoned,runs}` and `.gitkeep` files where appropriate.
- Keep existing sprint/decision state preservation behavior.
- Do not mutate stable repo or run release tooling.
- After the fix, rerun the sandbox install queue smoke from the failed artifacts-only task.
- Do not run `git add`, `git commit`, or `git push`.

## Files Scope

- `2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh`
- `.sfs-local/queue/failed/loopq-20260430T172700Z-8313-codex-run-dist-install-smoke-artifacts-only.md`
- `.sfs-local/queue/claimed/codex-overnight/loopq-20260430T172900Z-8314-codex-fix-install-queue-scaffold.md`

## Verify

- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh`
- sandbox install exits 0
- installed queue directories exist
- installed `bash -n .sfs-local/scripts/sfs-loop.sh` passes
- installed queue smoke passes:
  - `enqueue --size small --target-minutes 5`
  - stale claimed visibility
  - `verify` claimed pass task
  - `retry` max_attempts exceeded task moves to abandoned
- `git diff --check`

## Evidence

### 2026-05-01T02:31:00+09:00 — passed

- Changed `install.sh` to create `.sfs-local/queue/{pending,claimed,done,failed,abandoned,runs}` with `.gitkeep` files.
- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh` PASS.
- Sandbox target: `/private/tmp/sfs-dist-install.lQQw7E/target`.
- `install.sh --yes --layout vendored` exited 0.
- Installed queue directories existed for all six states including `runs`.
- Installed `.sfs-local/scripts/sfs-loop.sh` `bash -n` PASS.
- Installed queue smoke PASS:
  - `enqueue "installed small" --size small --target-minutes 5`
  - frontmatter `size: small` + `target_minutes: 5`
  - stale claimed visibility for `old-task`
  - `verify` moved claimed pass task to `done/`
  - `retry` with attempts=max moved failed task to `abandoned/`
