---
task_id: loopq-20260501T011530Z-8403
title: "[codex] agent adapter model profile parity"
status: done
priority: 2
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: codex-release-loop
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:15:30Z
claimed_at: 2026-05-01T01:21:47Z
size: large
target_minutes: 90
completed_at: 2026-05-01T01:23:02Z
---

# [codex] agent adapter model profile parity

## Goal

Ensure active agent adapters and distributable templates describe the same
runtime-neutral model profile behavior.

Scope:
- Compare active `.agents`, `.claude`, `.gemini` entry points with dist
  templates.
- Fix drift only inside the files listed below.
- Keep Codex `$sfs` guidance, Claude/Gemini `/sfs` guidance, and bash adapter
  SSoT wording aligned.
- Do not touch Windows/Scoop packaging.
- Do not run `git add`, `git commit`, `git push`, or release apply.

## Files Scope

- .agents/skills/sfs/SKILL.md
- .claude/commands/sfs.md
- .gemini/commands/sfs.toml
- 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.agents/skills/sfs/SKILL.md
- 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.claude/commands/sfs.md
- 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.codex/prompts/sfs.md
- 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.gemini/commands/sfs.toml

## Verify

- `git diff --check`

## Runtime Assignment

- Intended runtime: Codex.
- If adapter wording requires product-level decision, stop and record it as a
  finding instead of widening scope.

## Evidence

### 2026-05-01T10:22:50+09:00 — active adapter parity restored

- Compared active adapters with distributable templates.
- Initial result:
  - Codex Skill active/template already byte-identical.
  - Claude command active file lagged the dist template.
  - Gemini command active file lagged the dist template.
- Applied narrow sync inside task scope:
  - copied dist Claude command template to `.claude/commands/sfs.md`
  - copied dist Gemini command template to `.gemini/commands/sfs.toml`
- Post-sync parity:
  - `cmp -s .agents/skills/sfs/SKILL.md .../.agents/skills/sfs/SKILL.md` PASS
  - `cmp -s .claude/commands/sfs.md .../.claude/commands/sfs.md` PASS
  - `cmp -s .gemini/commands/sfs.toml .../.gemini/commands/sfs.toml` PASS
- Resulting wording is aligned on:
  - global `sfs` runtime as primary dispatch surface
  - vendored dispatch as fallback only
  - `implement` and `commit` command surfaces
  - AI-owned Git Flow lifecycle wording
  - non-Solon footer prohibition
- Verification:
  - `git diff --check` PASS
- No Windows/Scoop work performed.
- No git add/commit/push performed for this task.
