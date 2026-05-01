---
task_id: loopq-20260501T011500Z-8400
title: "[codex] same-version model profile update repair"
status: done
priority: 1
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-release-loop
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:15:00Z
claimed_at: 2026-05-01T01:19:38Z
size: large
target_minutes: 90
completed_at: 2026-05-01T01:20:24Z
---

# [codex] same-version model profile update repair

## Goal

Finish the 0.5.40 repair path: when a project is already on the same Solon
version but `.sfs-local/model-profiles.yaml` is missing, `sfs update` must
recreate it with the safe current-runtime fallback and explain the fallback.

Scope:
- Inspect the current dirty implementation before editing.
- Keep the fix narrowly focused on same-version update repair.
- Preserve local edits and existing project artifacts.
- Do not implement Windows/Scoop packaging in this task.
- Do not run `git add`, `git commit`, `git push`, release tooling with
  `--apply`, or any stable repo mutation.

## Files Scope

- 2026-04-19-sfs-v0.4/solon-mvp-dist/upgrade.sh
- 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/model-profiles.yaml
- /private/tmp

## Verify

- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/upgrade.sh`
- `git diff --check`

## Runtime Assignment

- Intended runtime: Codex.
- Write evidence into this task file under `## Evidence` before completing.
- If another worker owns an overlapping file, leave the task pending.

## Evidence

### 2026-05-01T10:20:10+09:00 — passed after v0.5.41 deploy

- Dev release commit already contains the same-version repair implementation:
  `1d2dc09 release(stable): v0.5.41-product`.
- Verified `upgrade.sh` same-version repair branch:
  - detects missing `.sfs-local/model-profiles.yaml`
  - copies the packaged template
  - replaces placeholders with `selected_runtime: "current"`,
    `selected_policy: "current_model"`, and
    `status: "current_model_fallback"`
  - prints the missing-file repair message.
- Sandbox:
  `/private/tmp/sfs-update-repair.hJNNhV/project`
- Sandbox procedure:
  fresh git repo -> `install.sh --yes` -> move
  `.sfs-local/model-profiles.yaml` aside -> `upgrade.sh --yes`.
- Sandbox assertions passed:
  - regenerated `.sfs-local/model-profiles.yaml` exists
  - `selected_runtime: "current"` present
  - `selected_policy: "current_model"` present
  - `status: "current_model_fallback"` present
  - upgrade output contains `model-profiles.yaml 누락 감지`
- Verification:
  - `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/upgrade.sh` PASS
  - `git diff --check` PASS
- No Windows/Scoop work performed.
- No git add/commit/push performed for this task.
