---
task_id: loopq-20260501T011520Z-8402
title: "[codex] install flow model profile coverage"
status: done
priority: 2
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-release-loop
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:15:20Z
claimed_at: 2026-05-01T01:21:13Z
size: medium
target_minutes: 75
depends_on:
  - loopq-20260501T011500Z-8400
completed_at: 2026-05-01T01:21:42Z
---

# [codex] install flow model profile coverage

## Goal

Check and, if needed, minimally fix `install.sh` so fresh installs create
model profile state consistently with the 0.5.39/0.5.40 docs.

Scope:
- Own only the install path. Do not edit `upgrade.sh`; that belongs to the
  same-version repair task.
- Preserve existing install behavior for queue scaffold, agent adapters, and
  `.gitignore` markers.
- Keep generated defaults safe: current runtime, current model policy.
- Do not implement Windows/Scoop packaging in this task.
- Do not run `git add`, `git commit`, `git push`, or release apply.

## Files Scope

- 2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh
- /private/tmp

## Verify

- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh`
- `git diff --check`

## Runtime Assignment

- Intended runtime: Codex.
- Add concise evidence to this task file before completing.

## Evidence

### 2026-05-01T10:21:28+09:00 — passed, no product edit needed

- Inspected `install.sh` model profile flow:
  - reads `SFS_MODEL_RUNTIME` with default `current`
  - reads `SFS_MODEL_POLICY` with default `current_model`
  - normalizes unknown/skip values back to safe fallback
  - sets `MODEL_PROFILE_STATUS=current_model_fallback` unless user selects a
    non-default runtime or policy
  - writes `.sfs-local/model-profiles.yaml` only when missing, preserving local
    user settings otherwise
  - substitutes `<DEFAULT-RUNTIME>`, `<MODEL-POLICY>`, and
    `<MODEL-PROFILE-STATUS>` into the template
  - shows the model profile path in the final install summary
- Reused fresh install smoke evidence from
  `loopq-20260501T011510Z-8401`: a clean sandbox install created
  `.sfs-local/model-profiles.yaml` with `current/current_model/current_model_fallback`.
- Verification:
  - `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh` PASS
  - `git diff --check` PASS
- No product files changed.
- No Windows/Scoop work performed.
- No git add/commit/push performed for this task.
