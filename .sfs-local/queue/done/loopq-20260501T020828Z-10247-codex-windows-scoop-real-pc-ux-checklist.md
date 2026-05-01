---
task_id: loopq-20260501T020828Z-10247
title: "codex Windows Scoop real-PC UX checklist"
status: done
priority: 7
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-loop
attempts: 0
max_attempts: 3
created_at: 2026-05-01T02:08:28Z
claimed_at: 2026-05-01T02:35:40Z
completed_at: 2026-05-01T02:37:34Z
size: small
target_minutes: 30
---

# codex Windows Scoop real-PC UX checklist

## Goal

Turn the Windows/Scoop real-PC validation notes into a concise follow-up
checklist that can be handed to a human tester after CI is green.

Scope:
- Treat Scoop bucket implementation as complete in the other session.
- Mention the release checklist split: Brew formula update + Scoop bucket
  manifest update.
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
- `grep -n "Brew" 2026-04-19-sfs-v0.4/HANDOFF-next-session.md`
- `grep -n "Scoop bucket" 2026-04-19-sfs-v0.4/HANDOFF-next-session.md`
- `grep -n "real-PC UX" 2026-04-19-sfs-v0.4/HANDOFF-next-session.md`

## Execution Evidence

- Updated `2026-04-19-sfs-v0.4/HANDOFF-next-session.md` instead of creating a new doc.
- Expanded the Windows/Scoop follow-up into a human tester checklist that runs only after CI is green.
- Preserved the release split: Brew formula update for macOS/global runtime plus Scoop bucket manifest update for Windows.
- Kept scope to UX validation only: PATH refresh, PowerShell/cmd/Git Bash shims, Git for Windows `bash.exe` lookup, PowerShell ExecutionPolicy, and Korean/space paths.
- Did not change packaging behavior.

## Verification Evidence

- `git diff --check` — PASS.
- `grep -n "Brew" 2026-04-19-sfs-v0.4/HANDOFF-next-session.md` — PASS, hits lines 18, 19, and 39.
- `grep -n "Scoop bucket" 2026-04-19-sfs-v0.4/HANDOFF-next-session.md` — PASS, hits lines 19, 25, 38, and 39.
- `grep -n "real-PC UX" 2026-04-19-sfs-v0.4/HANDOFF-next-session.md` — PASS, hits lines 20, 25, and 38.
