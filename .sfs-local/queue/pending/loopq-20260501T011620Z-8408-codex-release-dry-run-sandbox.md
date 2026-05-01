---
task_id: loopq-20260501T011620Z-8408
title: "[codex] release dry-run sandbox"
status: pending
priority: 4
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: ""
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:16:20Z
claimed_at: ""
size: medium
target_minutes: 60
depends_on:
  - loopq-20260501T011610Z-8407
---

# [codex] release dry-run sandbox

## Goal

Run release readiness checks without mutating the stable repo.

Scope:
- Run only dry-run commands and local inspections.
- Do not use `--apply`.
- Do not tag, push, or commit.
- If `cut-release.sh` reports blockers, record the exact exit/output summary in
  this task file.
- Do not implement Windows/Scoop packaging.

## Files Scope

- /private/tmp
- .sfs-local/queue/pending/loopq-20260501T011620Z-8408-codex-release-dry-run-sandbox.md

## Verify

- `bash -n 2026-04-19-sfs-v0.4/scripts/cut-release.sh`
- `git diff --check`

## Runtime Assignment

- Intended runtime: Codex.
- Evidence only unless a tiny script syntax issue is found.
