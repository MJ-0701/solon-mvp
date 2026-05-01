---
task_id: loopq-20260501T125504Z-9920
title: "solon-adapter-dispatch-audit"
status: pending
priority: 5
mode: user-active-deferred
sprint_id: ""
owner: ""
attempts: 0
max_attempts: 3
created_at: 2026-05-01T12:55:04Z
claimed_at: ""
size: medium
target_minutes: 45
---

# solon-adapter-dispatch-audit

## Goal

Create a 1:1 audit of documented SFS commands versus the actual dispatch
surface, then fix any drift between `bin/sfs`, active adapters, product
templates, and Claude/Codex/Gemini entry docs.

Concrete outcome:
- Build a command matrix for status/start/guide/auth/adopt/upgrade/update/
  version/brainstorm/plan/implement/review/decision/report/tidy/retro/commit/
  loop.
- Identify missing, stale, or asymmetric dispatch paths.
- Patch only confirmed drift; leave new command design as backlog.

## Files Scope

- `2026-04-19-sfs-v0.4/solon-mvp-dist/bin/sfs`
- `.sfs-local/scripts/sfs-dispatch.sh`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-dispatch.sh`
- `.agents/skills/sfs/SKILL.md`
- `.claude/commands/sfs.md`
- `.gemini/commands/sfs.toml`
- Product template copies of the same adapter docs.

## Verify

- `bash -n` on dispatch/bin scripts.
- `sfs <command> --help` smoke where help is supported; avoid enqueue-like
  commands that interpret `--help` as data unless behavior is explicitly fixed.
- `rg` matrix proving every documented command has a dispatch entry and every
  dispatch entry has docs.
- Record any intentionally unsupported help behavior as a finding or fix it in
  scope if small.
