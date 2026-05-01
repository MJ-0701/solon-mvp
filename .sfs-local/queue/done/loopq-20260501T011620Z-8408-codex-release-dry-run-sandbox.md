---
task_id: loopq-20260501T011620Z-8408
title: "[codex] release dry-run sandbox"
status: done
priority: 4
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-loop
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:16:20Z
claimed_at: 2026-05-01T02:28:03Z
size: medium
target_minutes: 60
depends_on:
  - loopq-20260501T011610Z-8407
completed_at: 2026-05-01T02:30:21Z
---

# [codex] release dry-run sandbox

## Goal

Run release readiness checks without mutating the stable repo. Current context:
v0.5.42-product is already released; this dry-run now validates the queued
docs-only 0.5.43-product staging changes before any apply/tag/push.

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
- `SOLON_STABLE_REPO=/Users/mj/tmp/solon-product bash 2026-04-19-sfs-v0.4/scripts/cut-release.sh --version 0.5.43-product --allow-dirty`
- `git diff --check`

## Runtime Assignment

- Intended runtime: Codex.
- Evidence only unless a tiny script syntax issue is found.

## Execution Evidence

- Ran at: 2026-05-01T02:29:27Z
- Mutex inspection: `2026-04-19-sfs-v0.4/PROGRESS.md` has `current_wu_owner: null`; no PROGRESS mutation performed because task scope is evidence-only.
- Stable repo inspected: `/Users/mj/tmp/solon-product` exists with `.git`.
- `bash -n 2026-04-19-sfs-v0.4/scripts/cut-release.sh`
  - Exit: 0
  - Output: none
- `SOLON_STABLE_REPO=/Users/mj/tmp/solon-product bash 2026-04-19-sfs-v0.4/scripts/cut-release.sh --version 0.5.43-product --allow-dirty`
  - Exit: 0
  - Mode: dry-run
  - Pre-flight: paths ok / git clean / no blocking stale `.git/index.lock`; P-13 divergence check passed.
  - Allowlist: verified.
  - Diff preview summary: changed=13, new=0, deleted=0.
  - Changed files previewed: `VERSION`, `CHANGELOG.md`, `README.md`, `CLAUDE.md`, `AGENTS.md`, `GUIDE.md`, `install.sh`, `install.ps1`, `upgrade.sh`, `upgrade.ps1`, `uninstall.sh`, `uninstall.ps1`, `.sfs-local-template/scripts/sfs-loop.sh`.
  - Apply: skipped, dry-run.
  - Post-flight: skipped.
  - Final line: `dry-run complete · 0 changes applied`.
  - Blockers: none reported.
- `git diff --check`
  - Exit: 0
  - Output: none
