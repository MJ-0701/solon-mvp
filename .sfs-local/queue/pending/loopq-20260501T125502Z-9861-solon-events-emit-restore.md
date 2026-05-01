---
task_id: loopq-20260501T125502Z-9861
title: "solon-events-emit-restore"
status: pending
priority: 5
mode: user-active-deferred
sprint_id: ""
owner: ""
attempts: 0
max_attempts: 3
created_at: 2026-05-01T12:55:02Z
claimed_at: ""
size: large
target_minutes: 90
---

# solon-events-emit-restore

## Goal

Audit and restore missing event emission for the SFS adapter paths where the
human-readable artifact changes but `.sfs-local/events.jsonl` does not reliably
show the same lifecycle.

Concrete outcome:
- Check review, report, retro, decision, start, loop queue claim/complete/fail,
  and close paths for event emission.
- Add missing `append_event` calls with stable event names and small payloads.
- Keep event writes deterministic and adapter-owned; do not invent AI-side event
  narration as a substitute.

## Files Scope

- `.sfs-local/scripts/sfs-*.sh`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-*.sh`
- `.sfs-local/events.jsonl` only in temporary smoke projects, not the real
  project history unless the command itself naturally appends events.
- README/GUIDE only if public event semantics change.

## Verify

- `bash -n` on touched adapter scripts.
- Fresh temp repo smoke for at least start, review prompt-only, report, retro,
  decision, and one queue completion/failure path.
- Inspect temp `.sfs-local/events.jsonl` and record exact event types emitted.
- Confirm no duplicate event spam for repeated dry-runs.
