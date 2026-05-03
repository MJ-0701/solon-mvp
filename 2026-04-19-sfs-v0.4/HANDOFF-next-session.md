---
doc_id: handoff-next-session
title: "Next session handoff — slash-command-zero-file discovery research + 0.5.96-product hotfix design"
written_at: 2026-05-03T01:34:12Z
written_at_kst: 2026-05-03T10:34:12+09:00
last_known_main_commit: 30ff6ae
visibility: raw-internal
source_task: claude-cowork-handoff-research-first-rewrite
session_codename: modest-charming-keller
---

# Next Session Handoff

## 1. Current Truth

- Latest Solon Product release: **`0.5.95-product`** (codex hotfix train 0.5.87-95 shipped 2026-05-03).
- Dev repo main commit at this handoff: `30ff6ae` atop `c3157e3` / `7bdf755` / `68ce1f5` / `e3c98ad`.
- `solon-mvp-dist/VERSION` = `0.5.95-product`.
- `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh` → exit 0 (clean).

## 2. What Last Session (claude-cowork:modest-charming-keller) Did

- **Phase A** — recovered 0.5.87-95 codex hotfix-train drift in PROGRESS.md (frontmatter + scheduled_task_log + resume_hint + on_ambiguous + ③ Next).
- **Phase B** — rotated PROGRESS.md ① + ④ pre-0.5.93 bullets to `archives/progress/PROGRESS-bullets-rotation-2026-05-03-pre-0.5.93.md` (verbatim, strict 11-field frontmatter). PROGRESS 463 → 324 lines.
- **Phase C** — full repo MD line-count audit at `2026-04-19-sfs-v0.4/MD-SIZE-AUDIT-2026-05-03.md`. 7-tier classification with split recommendations + auto-load hard-no list + 11-field frontmatter standard.
- **Phase D (deferred)** — splits NOT executed; queued for after §4.A hotfix lands.
- **End-of-session diagnosis** — surfaced the slash-command regression (study-note `/sfs` not recognized) + corrected the misframed "user-global stub" fix idea after user clarified intent (zero file in project AND in user home, brew alone should provide discovery). HANDOFF restructured to research-first (this document).

## 3. Validation Evidence

- PROGRESS.md trim verified by `wc -l` (463 → 324).
- Archive file integrity: 222 lines, frontmatter compliant.
- Auto-load chain unchanged this session (no entry stub touched).
- `release_handoff_drift` check is clean (resume_hint and HANDOFF both reference `0.5.95-product`).

## 4. Default Action for Next Session

> Read this section in order. §4.A is a RESEARCH problem first; do not jump to implementation.

### 4.A — TOP PRIORITY: slash-command zero-file discovery research → design → 0.5.96-product hotfix

#### 4.A.1 The actual question (do not assume an answer)

> Can a user who installed `sfs` via brew/scoop get the `/sfs` slash command in Claude Code AND `$sfs` in Codex CLI AND `sfs` (slash equivalent) in Gemini CLI, **without any new file appearing in either the project (`<project>/.claude/commands/`, `.gemini/commands/`, `.agents/skills/`) OR the user home (`~/.claude/commands/sfs.md`, `~/.gemini/commands/sfs.toml`, `~/.codex/.../sfs.md`)?**
>
> If yes — by what mechanism (plugin / MCP / extension / built-in registration / something else)?
> If no — what is the minimum-footprint trade-off, and what does the user need to decide?

#### 4.A.1.1 User-stated design constraints

The user's original design intent was **plugin-per-CLI** (reference: bkit pdca — a Claude Code plugin pattern they have designed before). Plugin pattern itself is acceptable. The objection is to the **multi-install friction**: if user runs Claude + Codex + Gemini-CLI all together, they should NOT need to run three separate plugin installs.

Therefore the constraint is:

- **One user-visible install action** covers all three CLIs. `brew install sfs` (and its Scoop equivalent) is the unified entry point. Per-CLI plugin install commands run *inside* the brew/scoop hook, not as separate user steps.
- **Project surface clean** — no project-local files dropped by install.
- **Plugin-managed user-home location is acceptable** (e.g., `~/.claude/plugins/solon/` is plugin-internal, not "user file"). Direct config-style files at `~/.claude/commands/sfs.md` are less acceptable but **negotiable** if the trade-off is necessary.
- `sfs upgrade` re-runs the same coverage idempotently for already-installed setups.

The "no file outside brew location" interpretation from the previous handoff draft was wrong. The user accepts files in CLI-managed plugin areas (because those are "installed software," conceptually equivalent to brew's Cellar). They do **not** accept files in user-curated config-file areas (`~/.claude/commands/`).

#### 4.A.2 Live witness data points (collected 2026-05-03 by user)

- `cd ~/IdeaProjects/study-note && claude` → `/sfs` returns "No commands match `/sfs `". Project was upgraded 0.5.89-product → 0.5.95-product (thin migration removed project-local `.claude/commands/sfs.md`).
- `cd ~/IdeaProjects/product-image-studio && claude` (IntelliJ terminal) → `/sfs <command> [args]` autocompletes. Hypothesis: this project still retains a project-local `.claude/commands/sfs.md` that pre-dates 0.5.89 thin migration (was never upgraded, or was opted in via `sfs agent install all`, or sfs-init pre-0.5.89). **Confirm at session start**:
  ```bash
  ls -la ~/IdeaProjects/product-image-studio/.claude/commands/sfs.md
  ls -la ~/IdeaProjects/study-note/.claude/commands/sfs.md
  ```
  Expected: product-image-studio has the file (or some override), study-note doesn't.
- `ls -la ~/.claude/commands/ ~/.gemini/commands/ ~/.codex/ 2>&1` to confirm the user-global state (likely empty or missing).

The product-image-studio observation is **not** evidence that brew provides global discovery. It is a stale project-local artifact. The actual user goal — zero file in project AND zero file in home — is still unmet.

#### 4.A.3 Research mechanisms to investigate (one section per CLI)

The unifying question across all three CLIs:

> Does this CLI have a non-interactive plugin/extension install command that a brew/scoop hook can invoke during `brew install sfs`? If yes, what does it accept as input (URL / local path / marketplace ID)? If no, what is the closest file-drop alternative inside a CLI-plugin-managed location (NOT user-curated config dirs)?

##### Claude Code (v2.x)

Reference: bkit pdca plugin (user has designed this pattern before — investigate its install/registration mechanism for prior art). Investigate, in priority order:

1. **Plugin system** — `claude plugin install <something>`: does it exist? Local path supported? Marketplace ID supported? URL supported? Does Claude Code load slash commands from a plugin's bundled `commands/` directory inside `~/.claude/plugins/<plugin>/` (plugin-internal, acceptable per §4.A.1.1)? Reference: `claude --help`, `claude plugin --help`, official Claude Code docs, plugin marketplace.
2. **MCP server** — `claude mcp add` registers an MCP server with one config edit. Useful for the *tool* side (`@sfs.status` etc.), but a literal `/sfs` slash command from MCP is a separate question — investigate whether MCP servers can declare slash commands or if it's tool-only.
3. **Skills / Agents path** — Claude Code subagent system (`.claude/agents/`). Does it have an analogous slash-from-skill mechanism that lives in a CLI-plugin-managed location?
4. **Config-only registration** — does `~/.claude/settings.json` accept a `commands:` block that defines slash commands inline without separate files?

For each path, record: (a) feasibility, (b) what brew formula's `post_install` can call to set it up non-interactively, (c) what footprint appears in user filesystem (plugin-internal acceptable, user-config-file not), (d) idempotency on `sfs upgrade`.

##### Codex CLI

Investigate the equivalent landscape for Codex. Codex uses `AGENTS.md` for agent behavior + `~/.codex/prompts/<name>.md` (or similar) for prompts. Determine:

1. Plugin/skill marketplace? Non-interactive install command?
2. MCP server registration (Codex's MCP support)?
3. Closest file-drop equivalent in a Codex-managed plugin/skill folder (NOT `~/.codex/prompts/` if that's user-curated)?
4. What does `brew install codex` (or its install path) typically wire up?

##### Gemini CLI

Same questions as Codex, but for Gemini CLI. Gemini uses `~/.gemini/commands/*.toml` for slash commands per the existing solon templates. Investigate:

1. Gemini extension/plugin system (`gemini extension install`?). Non-interactive install?
2. MCP server registration in Gemini config?
3. Where do Gemini-managed extensions live vs. user-curated commands files?

#### 4.A.3.1 Cross-CLI common path

After per-CLI research, identify the **common umbrella mechanism**:

- Best case: all three have a non-interactive plugin install command. brew formula `post_install` runs three lines, one per CLI, all silent. Failure of one CLI's hook does NOT block the others or the brew install itself (degrade gracefully + warn).
- Acceptable: two of three have plugin-install CLIs; the third needs a file-drop into a CLI-managed location (not `~/.claude/commands/` etc.). Document the asymmetry.
- Worst case: file-drop into user-curated config dirs is the only option for one or more CLIs. Surface the trade-off to user explicitly via §4.A.5.

#### 4.A.3.2 Scoop equivalent

For Windows Scoop the same logic applies. Scoop manifest's `installer.script` block runs at install time and can call PowerShell. Investigate whether Claude Code / Gemini CLI / Codex CLI have Windows-equivalent non-interactive plugin install paths.

#### 4.A.4 Output of research phase

A short report at `2026-04-19-sfs-v0.4/tmp/slash-command-discovery-research-2026-05-03.md` with:

- Per-CLI feasibility matrix: zero-file possible? with what mechanism? steps?
- Common denominator across the three CLIs (if any).
- Trade-off table: best vs. acceptable vs. unacceptable footprint per CLI.
- Recommended approach AND acceptable fallback.

#### 4.A.5 User decision gate

After the research report, **stop and present findings to the user**. Do NOT proceed to implementation autonomously. The user will pick:

- (i) Pursue zero-file approach (if research says feasible) — proceed to implementation.
- (ii) Accept minimum-footprint trade-off (e.g., one-time `claude plugin install` is acceptable but `~/.claude/commands/sfs.md` is not, or the reverse) — proceed with the chosen footprint.
- (iii) Revert 0.5.89's thin-surface decision — restore project-local `.claude/commands/sfs.md` as the install/upgrade default and treat "clean surface" as a different (later) concern.
- (iv) Other.

#### 4.A.6 Implementation (only after §4.A.5 user decision)

Branch: `hotfix/sfs-slash-command-discovery`. Implementation steps depend on the chosen mechanism. Common requirements regardless of choice:

- Idempotent (repeated `sfs upgrade` is a no-op for slash discovery).
- Cross-platform (macOS Homebrew + Windows Scoop).
- Conceptually separate from `sfs agent install all` (persona/skill domain). Do NOT conflate.
- Clear diagnostic / verification command (e.g., `sfs doctor` or section in `sfs status` that says "slash command discovery: ✅ via <mechanism>").

#### 4.A.7 Release as 0.5.96-product

Standard `cut-release.sh --apply --version 0.5.96-product` flow, push stable + tag + Homebrew + Scoop, verifier 7/7. Local verification: `cd <any project> && claude` then `/sfs` autocompletes (if the chosen mechanism delivers global slash); `cd <any project> && $sfs` works in Codex CLI; same for Gemini.

CHANGELOG entry under `### Fixed` written after implementation lands so it accurately describes the chosen mechanism (do not pre-write).

### 4.B — DEFERRED (until §4.A 0.5.96-product is verified): MD split execution queue

> Do not start until `bash 2026-04-19-sfs-v0.4/scripts/verify-product-release.sh --version 0.5.96-product` returns 7/7 OK.

- Read [`MD-SIZE-AUDIT-2026-05-03.md`](MD-SIZE-AUDIT-2026-05-03.md) for per-file detail and the strict 11-field frontmatter standard.
- Branch: `feature/md-size-split-tier1` from clean `main` (post-0.5.96).
- **Tier 1 order**: 07-plugin-distribution.md (1022) → 05-gate-framework.md (956) → 02-design-principles.md (940) → 10-phase1-implementation.md (827) → 08-observability.md (709) → 04-pdca-redef.md (645) → 03-c-level-matrix.md (622) → 06-escalate-plan.md (605).
- **Tier 2 order**: WU-23.md (406) → WU-20.md (340) → WU-26.md (312) into `sprints/WU-XX/` directories. Precedent: `sprints/WU-27/`.
- **Per-split flow** (HARD):
  1. Reference scan: `grep -rn '<target>' --include='*.md' --include='*.sh' --include='*.yaml' --include='*.toml' --exclude-dir='.git' --exclude-dir='archives' --exclude-dir='.claude/worktrees'`
  2. Identify §-boundaries: `grep -n '^# §\|^## §' <file>`
  3. Create subdir + sub-files with strict 11-field frontmatter (`doc_id` / `title` / `parent_doc` / `split_from_section` / `split_reason` / `split_at` / `split_by_session` / `visibility` / `auto_load_required` / `replaces_in_parent` / `last_updated`)
  4. Replace each removed § in parent with 1-line link stub: `> §X moved to [<file>](<path>) — split: <reason>. <session>, <ISO>.`
  5. Atomic commit per file.
  6. Post-commit: `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh` → exit 0.
- **DO NOT touch**: `solon-mvp-dist/CHANGELOG.md`, `WORK-LOG.md`, `archives/**`, `.sfs-local/**`, root CLAUDE/AGENTS/GEMINI redirect stubs, `.claude/agents/*`, `.agents/skills/*`, `.gemini/commands/*.toml`, `solon-mvp-dist/templates/**`, recently-trimmed `solon-mvp-dist/GUIDE.md` / `BEGINNER-GUIDE.md` / `README.md`.

### 4.C — FURTHER DEFERRED (after §4.B lands): §1.14 generalization + automation

After Tier 1+2 splits exercise the pattern:
1. Generalize CLAUDE.md §1.14 from "CLAUDE.md ≤200" to "single-SSoT MD ≤200, accumulation files (CHANGELOG / WORK-LOG / sessions / learning-logs / scheduled_task_log) explicitly excepted."
2. New `scripts/check-md-size.sh` + wire into `resume-session-check.sh` as check #9 (exit 18 = size warning).
3. `cut-release.sh --apply` post-flight hook: rotate oldest ① + ④ release bullet to `archives/progress/PROGRESS-bullets-rotation-<period>.md` automatically per release.
4. New learning log `learning-logs/2026-05/P-XX-md-rotation-pattern.md` companion to P-06 for the PROGRESS-style accumulation case.

## 5. Guardrails

- **§4.A is research-first.** Do not implement before the report and user decision in §4.A.5.
- **Do not assume the answer.** "User-global stub" was the wrong assumption last session. Treat the question in §4.A.1 as genuinely open.
- **Do not conflate slash-command discovery with `sfs agent install all`.** Persona/skill installation is a different domain.
- **Do not start §4.B until §4.A 0.5.96-product is verified.**
- Pre-flight reference scan before any split (§4.B) is non-negotiable.
- Frontmatter discipline (11 fields) per `MD-SIZE-AUDIT-2026-05-03.md` is non-negotiable per user "절대 누락 0" constraint.
- Do not modify auto-loaded files unless §4.A.6 implementation explicitly requires after user approval.
- Do not undo recent 0.5.86 work on `solon-mvp-dist/GUIDE.md` / `BEGINNER-GUIDE.md` / `README.md`.
- Do not bypass the `cut-release.sh` divergence guards or release verifier.
- After branch merge into `main`, do not reuse for next task; fresh branch from `main`.

## 6. Outstanding work the user asked about

- ✅ PROGRESS.md slim (rotated pre-0.5.93 entries, last session).
- ✅ Codex 0.5.87-95 drift recovery (last session).
- ✅ Full repo MD audit (last session — `MD-SIZE-AUDIT-2026-05-03.md`).
- ⏳ **§4.A slash-command zero-file discovery research → user decision → 0.5.96-product hotfix** (top priority next session).
- ⏳ §4.B MD split execution (waits for §4.A).
- ⏳ §4.C §1.14 generalization + check-md-size.sh + cut-release rotation hook + P-XX learning log.
