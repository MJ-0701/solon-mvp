---
task_id: loopq-20260501T125459Z-9802
title: "solon-loop-queue-lifecycle retro-light split"
status: done
priority: 5
mode: user-active-deferred
sprint_id: ""
owner: chaemyeongjeong-ui-MacBookPro-2
attempts: 2
max_attempts: 3
created_at: 2026-05-01T12:54:59Z
claimed_at: 2026-05-01T16:14:39Z
size: medium
target_minutes: 45
failed_at: 2026-05-01T16:14:21Z
retried_at: 2026-05-01T16:14:38Z
completed_at: 2026-05-01T16:14:39Z
---

# solon-loop-queue-lifecycle retro-light split

## Goal

Split the queue MVP lifecycle follow-up into a light retro/backlog path instead
of mixing lifecycle, verify, sizing, dependency, and files-scope work into one
large inline patch.

Concrete outcome:
- Define the minimal queue lifecycle states and when an item should move between
  pending, claimed, done, failed, and abandoned.
- Decide which learnings belong in a short retro-light note versus a full sprint
  retro.
- Capture backlog seeds for anything larger than this task instead of expanding
  scope.

## Files Scope

- `.sfs-local/scripts/sfs-loop.sh`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `.sfs-local/GUIDE.md`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md`
- Relevant queue docs/templates only if lifecycle wording must be user-visible.

## Verify

- `bash -n .sfs-local/scripts/sfs-loop.sh`
- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh`
- `bash .sfs-local/scripts/sfs-loop.sh queue`
- `bash -lc 'set -euo pipefail; root=$(mktemp -d /private/tmp/solon-queue-smoke.XXXXXX); mkdir -p "$root/.sfs-local"; export SFS_LOCAL_DIR="$root/.sfs-local"; bash /Users/mj/agent_architect/.sfs-local/scripts/sfs-loop.sh enqueue "smoke: queue lifecycle" --size small --target-minutes 5 >/dev/null; pending=$(find "$root/.sfs-local/queue/pending" -type f -name "*.md" | head -1); test -f "$pending"; claimed=$(bash /Users/mj/agent_architect/.sfs-local/scripts/sfs-loop.sh claim | sed -E "s/^claimed: //"); test -f "$claimed"; bash /Users/mj/agent_architect/.sfs-local/scripts/sfs-loop.sh complete "$claimed" >/dev/null; test -f "$root/.sfs-local/queue/done/$(basename "$claimed")"; rm -rf "$root"'`
- `rg -n 'Queue lifecycle \\(minimal\\)|Retro-light vs sprint retro' .sfs-local/GUIDE.md 2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md`

## Retro-Light

- Enqueue template now includes `depends_on`, `## Retro-Light`, and `## Backlog Seeds` to keep scope tight.
- GUIDE now spells out the minimal queue lifecycle states and when to use sprint retro/report instead.

## Backlog Seeds

- `loopq-20260501T125502Z-9861` — events emission audit/restore (larger than this note).
- `loopq-20260501T125504Z-9920` — dispatch matrix audit + drift fixes.
- `loopq-20260501T125507Z-9979` — multi-worker claim contention smoke.
