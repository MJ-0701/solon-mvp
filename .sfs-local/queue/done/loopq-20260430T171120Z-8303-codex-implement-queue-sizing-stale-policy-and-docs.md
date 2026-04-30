---
task_id: loopq-20260430T171120Z-8303
title: "[codex] implement queue sizing/stale policy and docs"
status: done
priority: 3
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-overnight
attempts: 0
max_attempts: 3
created_at: 2026-04-30T17:11:20Z
claimed_at: 2026-04-30T17:19:00Z
size: medium
target_minutes: 45
depends_on:
  - loopq-20260430T165820Z-8266
  - loopq-20260430T171100Z-8301
  - loopq-20260430T171110Z-8302
completed_at: 2026-04-30T17:21:25Z
---

# [codex] implement queue sizing/stale policy and docs

## Goal

Make the queue reflect the intended autonomous-driving contract: queue items should usually be chunky, and stale claimed tasks should be visible/recoverable.

Scope:
- Add or document `size` / `target_minutes` metadata policy for queue tasks:
  - `small` = batch-only or human quick-fix, generally not a standalone overnight item.
  - `medium` = 30-60 min autonomous item.
  - `large` = 60-120 min autonomous item.
- If code changes are small and natural:
  - teach `enqueue` optional `--size <small|medium|large>` and `--target-minutes <N>`.
  - include these fields in generated task frontmatter.
  - keep existing `enqueue <title>` behavior compatible.
- Add stale claimed visibility:
  - `queue` output may remain compact, but add a helper/subcommand or extra line that surfaces claimed tasks older than TTL if straightforward.
  - do not implement destructive auto-takeover without explicit task scope.
- Apply CPO review findings F-1/F-2:
  - README/GUIDE should document queue as execution backlog, not sprint scope SSoT.
  - README/GUIDE should mention manual lifecycle commands and the MVP/non-live execution behavior.
- Keep active/dist script sync if code changes are made.
- Do not run `git add`, `git commit`, or `git push`.

## Files Scope

- `.sfs-local/scripts/sfs-loop.sh`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/README.md`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/SFS.md.template`
- `.sfs-local/sprints/solon-loop-queue-mvp/log.md`

## Verify

- If script changed:
  - `bash -n .sfs-local/scripts/sfs-loop.sh`
  - `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
  - `cmp -s .sfs-local/scripts/sfs-loop.sh 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- If docs changed:
  - `rg -n "complete|fail|retry|target_minutes|queue.*SSoT|execution backlog|실행 대기열" 2026-04-19-sfs-v0.4/solon-mvp-dist/README.md 2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/SFS.md.template`
- Sandbox smoke:
  - `enqueue "small task" --size small --target-minutes 5` if options are implemented
  - confirm generated frontmatter includes size/target_minutes
  - existing `enqueue "compat task"` still works
- `git diff --check`

## Notes

This task exists because the prior queue item was too small for overnight autonomy. It should make that failure mode explicit in the product workflow.
