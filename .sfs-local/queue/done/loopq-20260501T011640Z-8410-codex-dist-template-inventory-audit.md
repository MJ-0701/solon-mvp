---
task_id: loopq-20260501T011640Z-8410
title: "[codex] dist template inventory audit"
status: done
priority: 3
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-release-loop
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:16:40Z
claimed_at: 2026-05-01T01:31:28Z
size: medium
target_minutes: 60
completed_at: 2026-05-01T01:34:29Z
---

# [codex] dist template inventory audit

## Goal

Audit the distributable template inventory so newly added model profiles,
implementation worker persona, queue runtime, and commit command assets are
all reachable by install/update.

Scope:
- Compare `solon-mvp-dist/templates/.sfs-local-template/` against install and
  upgrade copy/update lists.
- Fix only manifest/copy-list omissions in `install.sh` or `upgrade.sh` if
  discovered and if no overlapping worker owns those files.
- Otherwise record blockers in this task file.
- Do not implement Windows/Scoop packaging.
- Do not run `git add`, `git commit`, `git push`, or release apply.

## Files Scope

- 2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh
- 2026-04-19-sfs-v0.4/solon-mvp-dist/upgrade.sh
- 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template

## Verify

- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh`
- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/upgrade.sh`
- `git diff --check`

## Runtime Assignment

- Intended runtime: Codex.
- If this task is blocked by an overlapping claimed task, leave it pending.

## Evidence

2026-05-01T01:34Z Codex audit PASS.

Inventory comparison:
- Managed template files covered by install/update: 39.
- Intentional non-managed template/state files: 9.
- Missing managed template files: 0.

Key managed assets confirmed covered:
- `.sfs-local-template/model-profiles.yaml`
- `.sfs-local-template/personas/implementation-worker.md`
- `.sfs-local-template/scripts/sfs-commit.sh`
- `.sfs-local-template/scripts/sfs-loop.sh`

Intentional non-managed files:
- `.codex/prompts/sfs.md` remains a manual Codex prompt fallback; `install.sh` prints a notice and does not write to user home.
- `.sfs-local-template/events.jsonl` and `.gitkeep` state placeholders are intentionally not upgrade-managed; install/runtime create state paths while preserving project state.

Sandbox install/update smoke:
- Fresh vendored install sandbox: `/private/tmp/sfs-inventory-install.2DQx9n/project`
  - Confirmed `model-profiles.yaml`, `sfs-loop.sh`, `sfs-commit.sh`, `implementation-worker.md`, `.agents/skills/sfs/SKILL.md`, `.gemini/commands/sfs.toml`, and queue directories.
- Old-project vendored upgrade sandbox: `/private/tmp/sfs-inventory-upgrade.8uhZ2Y/project`
  - Started from minimal `.sfs-local/VERSION` at `0.5.40-product`.
  - `upgrade.sh --yes` installed/restored `model-profiles.yaml`, `sfs-loop.sh`, `sfs-commit.sh`, `implementation-worker.md`, Codex Skill, and Gemini command.
  - `sfs-loop.sh queue --owner smoke` returned `queue · pending 0 · claimed 0 · done 0 · failed 0 · abandoned 0`, confirming queue runtime creates state directories on demand.

Verification:
- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/install.sh` PASS.
- `bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/upgrade.sh` PASS.
- `git diff --check` PASS.

Outcome:
- No manifest/copy-list omission found.
- No product runtime edits were needed.
- Windows/Scoop packaging was not touched; it is owned by another session.
