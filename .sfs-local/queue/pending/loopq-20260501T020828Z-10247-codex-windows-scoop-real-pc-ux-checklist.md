---
task_id: loopq-20260501T020828Z-10247
title: "codex Windows Scoop real-PC UX checklist"
status: pending
priority: 7
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: ""
attempts: 0
max_attempts: 3
created_at: 2026-05-01T02:08:28Z
claimed_at: ""
size: small
target_minutes: 30
---

# codex Windows Scoop real-PC UX checklist

## Goal

Turn the Windows/Scoop real-PC validation notes into a concise follow-up
checklist that can be handed to a human tester after CI is green.

Scope:
- Do not change packaging behavior unless a typo blocks understanding.
- Keep CI as the exact pass/fail gate already implemented.
- Capture manual checks for PATH refresh, PowerShell/cmd/Git Bash shims,
  Git for Windows bash lookup, ExecutionPolicy, and Korean/space paths.
- Prefer updating an existing release/handoff doc over creating a new doc.
- Git commit/push is allowed after verification for this task.

## Files Scope

- 2026-04-19-sfs-v0.4/HANDOFF-next-session.md
- 2026-04-19-sfs-v0.4/solon-mvp-dist/README.md
- 2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md
- .sfs-local/queue/pending/loopq-20260501T020828Z-10247-codex-windows-scoop-real-pc-ux-checklist.md

## Verify

- `git diff --check`
