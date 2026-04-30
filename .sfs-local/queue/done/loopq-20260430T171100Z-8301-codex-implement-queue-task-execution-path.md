---
task_id: loopq-20260430T171100Z-8301
title: "[codex] implement queue task body execution path"
status: done
priority: 1
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-overnight
attempts: 0
max_attempts: 3
created_at: 2026-04-30T17:11:00Z
claimed_at: 2026-04-30T17:12:36Z
size: large
target_minutes: 60
depends_on:
  - loopq-20260430T165817Z-8208
completed_at: 2026-04-30T17:14:49Z
---

# [codex] implement queue task body execution path

## Goal

Make default `/sfs loop` do meaningful queue work after claim instead of only leaving the task in `claimed/`.

Scope:
- When the queue-first branch claims a task, parse the claimed markdown body and build a deterministic executor prompt artifact.
- Add a run artifact directory under `.sfs-local/queue/runs/<task-id>/<timestamp>/` or an equivalent file-backed path.
- Write at least:
  - `PROMPT.md` containing the claimed task body, files scope, verify section, and explicit no-git-add/commit/push guard unless the task says otherwise.
  - `metadata.env` or small metadata file with task_id, claimed_path, owner, executor, created_at.
  - optional `executor.out` / `executor.err` capture files when live execution is enabled.
- Keep the default safe when `SFS_LOOP_LLM_LIVE` is not `1`: create the prompt/run artifact and print where it is, but do not invoke an executor.
- When `SFS_LOOP_LLM_LIVE=1`, call the resolved executor with the generated prompt, preserving the existing Solon-wide executor convention.
- Preserve existing queue/enqueue/claim/complete/fail/retry behavior and domain_locks fallback.
- Sync the same implementation to `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`.
- Keep bash 3.2 compatible.
- Do not run `git add`, `git commit`, or `git push`.

## Files Scope

- `.sfs-local/scripts/sfs-loop.sh`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `.sfs-local/sprints/solon-loop-queue-mvp/log.md`
- Optional docs if help text changes:
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/README.md`
  - `2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md`

## Verify

- `bash -n .sfs-local/scripts/sfs-loop.sh`
- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `cmp -s .sfs-local/scripts/sfs-loop.sh 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- Sandbox smoke:
  - create isolated `SFS_LOCAL_DIR`
  - enqueue a task with concrete Files Scope and Verify sections
  - run default loop with `--max-iters 1 --no-review-gate` and `SFS_LOOP_LLM_LIVE=0`
  - confirm the task is claimed
  - confirm a run artifact directory exists
  - confirm `PROMPT.md` contains task title, Goal, Files Scope, Verify, and no-git guard
  - confirm no executor was invoked in non-live mode
- `git diff --check`

## Notes

This is intentionally a large autonomous slice. It turns the queue from a bookkeeping demo into an actual handoff mechanism.
