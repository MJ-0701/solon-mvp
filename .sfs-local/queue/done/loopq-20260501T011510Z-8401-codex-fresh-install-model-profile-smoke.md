---
task_id: loopq-20260501T011510Z-8401
title: "[codex] fresh install model profile smoke"
status: done
priority: 1
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-release-loop
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:15:10Z
claimed_at: 2026-05-01T01:20:30Z
size: medium
target_minutes: 60
depends_on:
  - loopq-20260501T011500Z-8400
completed_at: 2026-05-01T01:21:08Z
---

# [codex] fresh install model profile smoke

## Goal

Verify that a fresh project install receives `.sfs-local/model-profiles.yaml`
and that the file uses the current-runtime fallback by default.

Scope:
- Use sandbox directories under `/private/tmp` only.
- Test vendored install first. Thin layout can be inspected if global runtime
  is available, but do not block the task on Homebrew state.
- Record exact commands, target paths, and pass/fail evidence in this task file.
- If a product fix is required, stop and record the finding instead of editing
  files owned by another task.
- Do not implement Windows/Scoop packaging in this task.
- Do not run `git add`, `git commit`, `git push`, or release apply.

## Files Scope

- /private/tmp
- .sfs-local/queue/pending/loopq-20260501T011510Z-8401-codex-fresh-install-model-profile-smoke.md

## Verify

- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh`
- `test -f 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/model-profiles.yaml`
- `git diff --check`

## Runtime Assignment

- Intended runtime: Codex.
- This is a smoke/evidence task, not an implementation task.

## Evidence

### 2026-05-01T10:20:53+09:00 — passed

- Fresh vendored install sandbox:
  `/private/tmp/sfs-fresh-install-profile.Mv0hjx/project`
- Procedure:
  fresh git repo -> `install.sh --yes`.
- Assertions passed:
  - `.sfs-local/model-profiles.yaml` exists.
  - `status: "current_model_fallback"` present.
  - `selected_runtime: "current"` present.
  - `selected_policy: "current_model"` present.
  - installer output reports `model profile 선택: runtime=current, policy=current_model`.
  - installer output reports `model-profiles.yaml 생성`.
  - installer final summary includes `Model profiles: .sfs-local/model-profiles.yaml`.
- Verification:
  - `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh` PASS.
  - `test -f 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/model-profiles.yaml` PASS.
  - `git diff --check` PASS.
- No product files changed.
- No Windows/Scoop work performed.
- No git add/commit/push performed for this task.
