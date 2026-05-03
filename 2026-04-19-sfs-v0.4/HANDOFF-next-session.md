---
doc_id: handoff-next-session
title: "Next session handoff — slash-command-global-stub hotfix priority + queued MD split work"
written_at: 2026-05-03T01:27:58Z
written_at_kst: 2026-05-03T10:27:58+09:00
last_known_main_commit: c3157e3
visibility: raw-internal
source_task: claude-cowork-handoff-restructure-for-hotfix
session_codename: modest-charming-keller
---

# Next Session Handoff

## 1. Current Truth

- Latest Solon Product release: **`0.5.95-product`** (codex hotfix train 0.5.87-95 shipped 2026-05-03).
- Dev repo main commit at this handoff: `c3157e3` (chore: append session-end scheduled_task_log + resume_hint version-anchor) atop `7bdf755` / `68ce1f5` / `e3c98ad` / ...
- `solon-mvp-dist/VERSION` = `0.5.95-product`.
- `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh` → exit 0 (clean).

## 2. What Last Session (claude-cowork:modest-charming-keller) Did

- Phase A — recovered 0.5.87-95 codex hotfix-train drift in PROGRESS.md (frontmatter + scheduled_task_log + resume_hint + on_ambiguous + ③ Next).
- Phase B — rotated PROGRESS.md ① + ④ pre-0.5.93 bullets to `archives/progress/PROGRESS-bullets-rotation-2026-05-03-pre-0.5.93.md` (verbatim, strict 11-field frontmatter). PROGRESS 463 → 324 lines.
- Phase C — full repo MD line-count audit at `2026-04-19-sfs-v0.4/MD-SIZE-AUDIT-2026-05-03.md`. 7-tier classification with split recommendations + auto-load hard-no list + 11-field frontmatter standard.
- Phase D — splits NOT executed (deferred per safety constraint while user was asleep).
- Phase F — resume_hint re-aimed at MD split queue, then RE-aimed again at the new top-priority hotfix below.
- **End-of-session diagnosis** (user-driven): user attempted `/sfs` in Claude Code v2.1.126 inside `~/IdeaProjects/study-note` after upgrading that project from 0.5.89-product → 0.5.95-product. Got "No commands match '/sfs '". Witnessed at ~10:22 KST 2026-05-03. **This is the regression that is now §4.A priority below.**

## 3. Validation Evidence

- PROGRESS.md trim verified by `wc -l` (463 → 324).
- Archive file integrity: 222 lines, frontmatter compliant.
- Auto-load chain unchanged this session (no entry stub touched).
- `release_handoff_drift` check in `resume-session-check.sh` is clean (resume_hint and HANDOFF both reference `0.5.95-product`).

## 4. Default Action for Next Session

> **Read this section in order**, then read `MD-SIZE-AUDIT-2026-05-03.md` only when reaching §4.B.

### 4.A — TOP PRIORITY: slash-command-global-stub hotfix → release as `0.5.96-product`

#### 4.A.1 Problem statement

The 0.5.89~0.5.95 codex hotfix train made thin installs **stop creating** project-local `.claude/commands/sfs.md`, `.gemini/commands/sfs.toml`, and `.agents/skills/sfs/SKILL.md` adapter files. The intent was to clean the project surface and migrate slash-command discovery to the global runtime (brew/scoop). However the brew/scoop install path **does not** install user-global slash-command stubs at `~/.claude/commands/sfs.md`, `~/.gemini/commands/sfs.toml`, etc. As a result, after a thin upgrade Claude Code/Gemini/Codex no longer surface the `/sfs` slash command in any directory, which violates the explicit user requirement that "the sfs feature must remain visible to the user — never feel like it disappeared."

The current opt-in workaround `sfs agent install all` is the wrong fix — that command installs **agent persona / skill artifacts** (CTO/CPO/CEO/evaluator/generator/planner), which is a separate concern from slash-command discovery. These two concerns should not be conflated by a single toggle.

#### 4.A.2 Live witness

- 2026-05-03 ~10:22 KST: user reproduced in `~/IdeaProjects/study-note`. Output: `No commands match "/sfs "`.
- `cat ~/.claude/commands/sfs.md 2>&1` from user's machine should error or be missing — confirm during session start.

#### 4.A.3 Design intent (what the right behavior is)

- brew/scoop install (and `sfs upgrade`) installs **user-global** slash-command stubs idempotently:
  - Claude Code: `~/.claude/commands/sfs.md`
  - Gemini CLI: `~/.gemini/commands/sfs.toml`
  - Codex CLI: research and confirm correct path before writing (likely `~/.codex/prompts/sfs.md` or `~/.codex/skills/sfs/SKILL.md` — verify against codex CLI docs / the templates folder convention).
- Stubs are tiny — they delegate to the global `sfs` bash runtime, no doc bloat.
- **Idempotent**: don't overwrite user-modified content. Probe for an SFS-managed marker (e.g. `# managed by sfs runtime` header) before writing.
- Project-local thin surface (no `.claude/commands/`, `.gemini/commands/`, `.agents/skills/` in project) stays as-is.
- `sfs agent install all` continues to do its persona/skill job, **unchanged**, conceptually separate from this hotfix.

#### 4.A.4 Implementation plan (file-by-file)

1. **Reference scan first**:
   ```bash
   grep -rn 'agent install\|.claude/commands/sfs\|.gemini/commands/sfs\|.agents/skills/sfs\|user-global\|home.*\.claude' \
     2026-04-19-sfs-v0.4/solon-mvp-dist/ \
     --include='*.sh' --include='*.ps1' --include='*.rb*' --include='*.json*' --include='*.md'
   ```
2. **New helper**: `solon-mvp-dist/bin/install-global-adapter-stubs.sh` (and `.ps1`) — single-source idempotent installer that:
   - Detects target HOME location (cross-platform)
   - For each agent (claude / gemini / codex), checks for existing stub + SFS marker
   - Copies the template from `templates/.claude/commands/sfs.md` etc. to user-global location
   - Logs each action verbatim
   - Returns 0 if all stubs are healthy after run
3. **Wire into install path**: `solon-mvp-dist/install.sh` and `install.ps1` call the helper at the end.
4. **Wire into upgrade path**: `solon-mvp-dist/upgrade.sh` and `upgrade.ps1` call the helper. This recovers all existing 0.5.89-95 installations.
5. **Wire into Homebrew**: `solon-mvp-dist/packaging/homebrew/sfs.rb.template` — add `post_install` block that runs the helper. (Or rely on the upgrade path.)
6. **Wire into Scoop**: `solon-mvp-dist/packaging/scoop/sfs.json.template` — `installer.script` block that runs the helper. (Or rely on `scoop update sfs` upgrade hook from 0.5.93.)
7. **Codex path verification** — before committing the helper, confirm Codex CLI's user-global discovery convention. Don't guess.
8. **Update GUIDE / BEGINNER-GUIDE / docs/ko / docs/en** to mention that `/sfs` is now globally available after install (no per-project setup needed for slash commands).
9. **Update `templates/.claude/commands/sfs.md` (etc.)** if any content needs adjusting for global use vs project-local use. (Currently they're written assuming project-local; verify they still work as user-global stubs.)
10. **CHANGELOG entry** (under `### Fixed`):
    > **Slash command global discovery restored** — brew/scoop install + `sfs upgrade` now install user-global slash-command stubs at `~/.claude/commands/sfs.md`, `~/.gemini/commands/sfs.toml`, and `~/.codex/<path>/sfs.md`. Thin installs that previously dropped only project-local files now have a globally available `/sfs`/`$sfs` slash command without per-project opt-in. Persona/skill installation via `sfs agent install all` remains a separate, optional concern.

#### 4.A.5 Verification

After implementing:
1. **Local verification on study-note**: `cd ~/IdeaProjects/study-note` then `claude` then `/sfs` autocompletes. Same in `~/agent_architect` and any clean directory.
2. **Idempotency**: run `sfs upgrade` twice, confirm second run is no-op for global stubs.
3. **Cross-channel**: same behavior in Codex CLI (`$sfs` discovers) and Gemini CLI.
4. **Release verifier**: `bash 2026-04-19-sfs-v0.4/scripts/verify-product-release.sh --version 0.5.96-product` — 7/7 pass.

#### 4.A.6 Branch + commit + release

- Branch from clean `main`: `hotfix/sfs-slash-command-global-stub`
- Multiple commits acceptable per implementation step (helper / install wiring / upgrade wiring / brew / scoop / docs / CHANGELOG / version bump)
- Final release commit: `release: 0.5.96-product handoff`
- Release flow per `cut-release.sh --apply --version 0.5.96-product`
- Homebrew formula + Scoop bucket update + verifier 7/7 → done

### 4.B — DEFERRED (until §4.A lands): MD split execution queue

> **Do not start this until 0.5.96-product release verifier is 7/7 green.**

- Read [`MD-SIZE-AUDIT-2026-05-03.md`](MD-SIZE-AUDIT-2026-05-03.md) for per-file detail and the strict 11-field frontmatter standard.
- Branch: `feature/md-size-split-tier1` from clean `main` (post-0.5.96).
- **Tier 1 order**: 07-plugin-distribution.md (1022) → 05-gate-framework.md (956) → 02-design-principles.md (940) → 10-phase1-implementation.md (827) → 08-observability.md (709) → 04-pdca-redef.md (645) → 03-c-level-matrix.md (622) → 06-escalate-plan.md (605).
- **Tier 2 order**: WU-23.md (406) → WU-20.md (340) → WU-26.md (312) into `sprints/WU-XX/` directories. Precedent: `sprints/WU-27/`.
- **Per-split flow** (HARD):
  1. Reference scan: `grep -rn '<target>' --include='*.md' --include='*.sh' --include='*.yaml' --include='*.toml' --exclude-dir='.git' --exclude-dir='archives' --exclude-dir='.claude/worktrees'`
  2. Identify §-boundaries: `grep -n '^# §\|^## §' <file>`
  3. Create subdir + sub-files with strict 11-field frontmatter (`doc_id` / `title` / `parent_doc` / `split_from_section` / `split_reason` / `split_at` / `split_by_session` / `visibility` / `auto_load_required` / `replaces_in_parent` / `last_updated`)
  4. Replace each removed § in parent with 1-line link stub: `> §X moved to [<file>](<path>) — split: <reason>. <session>, <ISO>.`
  5. Atomic commit per file: `split: <file> §X+Y → <subdir>/`
  6. Post-commit: `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh` → exit 0
- **DO NOT touch**: `solon-mvp-dist/CHANGELOG.md`, `WORK-LOG.md`, `archives/**`, `.sfs-local/**`, root CLAUDE/AGENTS/GEMINI redirect stubs, `.claude/agents/*`, `.agents/skills/*`, `.gemini/commands/*.toml`, `solon-mvp-dist/templates/**`, recently-trimmed `solon-mvp-dist/GUIDE.md` / `BEGINNER-GUIDE.md` / `README.md`.

### 4.C — FURTHER DEFERRED (after §4.B lands): §1.14 generalization + automation

After Tier 1+2 splits exercise the pattern:
1. Generalize CLAUDE.md §1.14 from "CLAUDE.md ≤200" to "single-SSoT MD ≤200, accumulation files (CHANGELOG / WORK-LOG / sessions / learning-logs / scheduled_task_log) explicitly excepted."
2. New `scripts/check-md-size.sh` + wire into `resume-session-check.sh` as check #9 (exit 18 = size warning).
3. `cut-release.sh --apply` post-flight hook: rotate oldest ① + ④ release bullet to `archives/progress/PROGRESS-bullets-rotation-<period>.md` automatically per release.
4. New learning log `learning-logs/2026-05/P-XX-md-rotation-pattern.md` companion to P-06 for the PROGRESS-style accumulation case.

## 5. Guardrails

- **§4.A first**. Do not start §4.B until 0.5.96-product is verified.
- Pre-flight reference scan before any split (§4.B) is non-negotiable.
- Frontmatter discipline (11 fields) per `MD-SIZE-AUDIT-2026-05-03.md` is non-negotiable per user "절대 누락 0" constraint.
- Do not modify auto-loaded files unless §4.A explicitly requires (and even then, only via the helper script, idempotently).
- Do not undo recent 0.5.86 work on `solon-mvp-dist/GUIDE.md` / `BEGINNER-GUIDE.md` / `README.md`.
- Do not bypass the `cut-release.sh` divergence guards or release verifier.
- After branch merge into `main`, do not reuse for next task; fresh branch from `main`.

## 6. Outstanding work the user asked about

- ✅ PROGRESS.md slim (rotated pre-0.5.93 entries, this session).
- ✅ Codex 0.5.87-95 drift recovery (this session).
- ✅ Full repo MD audit (this session — `MD-SIZE-AUDIT-2026-05-03.md`).
- ⏳ **§4.A slash-command-global-stub hotfix → 0.5.96-product** (top priority next session).
- ⏳ §4.B MD split execution (waits for §4.A).
- ⏳ §4.C §1.14 generalization + check-md-size.sh + cut-release rotation hook + P-XX learning log.
