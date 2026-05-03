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

The user's original design intent was **plugin-per-CLI** (concrete prior art:
bkit pdca — they designed and shipped this themselves). Plugin pattern itself
is acceptable. The objection is to the **multi-install friction**: if user
runs Claude + Codex + Gemini-CLI all together, they should NOT need to run
three separate plugin installs as separate user actions — but ONE user
action triggering all three at install time IS acceptable.

Therefore the constraint is:

- **One user-visible install action** covers all three CLIs. `brew install
  sfs` (and Scoop equivalent) is the unified entry point. Per-CLI plugin
  install commands run *inside* the brew/scoop hook, not as separate user
  steps.
- **Project surface clean of plugin-mechanism files, but RICH with work
  artifacts**. The dividing line is critical: see §4.A.1.4 below for the
  hard list.
- **Plugin-managed user-home location is acceptable** (e.g.,
  `~/.claude/plugins/solon/` is plugin-internal, conceptually like brew's
  Cellar — installed software, not user file). Direct config-style files at
  `~/.claude/commands/sfs.md` are NOT acceptable.
- `sfs upgrade` re-runs the same coverage idempotently.

The "no file outside brew location" interpretation from the first handoff
draft was wrong. The "user-global stub" interpretation from the second draft
was also wrong. The right interpretation: **mirror the bkit pdca plugin
pattern across Claude Code + Gemini CLI + Codex CLI under a single brew
install umbrella.** See §4.A.1.2 for the concrete reference setup.

#### 4.A.1.4 Project-local vs. plugin-internal — hard split (multi-CLI continuity)

The user works across Codex / Claude / Gemini CLI on the same projects and
must be able to **switch CLIs mid-work and resume** (per user 2026-05-03). For
this, work artifacts MUST live in the project (git-tracked, portable across
agents). Plugin/extension mechanism files MUST NOT live in the project (they
are CLI-specific install state, not portable, and clutter the project).

**Stays in project (git-tracked, never removed by `sfs init`/`upgrade`)**:

- `SFS.md` — project operating identity (project-name, stack, deploy, domain).
- `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` — thin agent adapter root files
  (these are *adapter content*, not slash command definitions; analogous to
  `AGENTS.md` being Codex's auto-loaded root file).
- `.sfs-local/` — project state, sprint workbench, decisions, events,
  VERSION, model-profiles, etc.
- `.sfs-local/sprints/<sprint-id>/` — brainstorm.md / plan.md / implement.md
  / log.md / review.md / retro.md / report.md (the 7-gate work artifacts).
- `.sfs-local/decisions/` — ADR-style decisions.
- `.sfs-local/events.jsonl` — append-only event log.
- Any `docs/<gate-output>/...` style files the user creates (Solon doesn't
  prescribe `docs/` location; user's `01-plan/features/...` style is fine).

**Does NOT live in project (lives in plugin/extension areas under user-home;
removed if currently present from old installs)**:

- `.claude/commands/sfs.md` — slash command definition. Now lives in
  `~/.claude/plugins/<solon-plugin>/commands/sfs.md` (plugin-internal).
- `.gemini/commands/sfs.toml` — Gemini extension command. Now lives in
  Gemini extension area (extension-internal).
- `.agents/skills/sfs/SKILL.md` — Codex skill. Per §4.A.1.3 user decision,
  either lives in `~/.codex/...` user-global or stays project-local
  asymmetrically (decision deferred).

**Multi-CLI continuity test**: user works in Claude Code, commits work
artifacts (`.sfs-local/sprints/<id>/plan.md` etc.) to git, opens the same
project in Codex CLI, runs `$sfs status` — Codex should see the same sprint
state and continue without missing context. This works because:

1. The sprint state files are project-local (git-tracked).
2. The `sfs` binary (brew/scoop installed, in PATH) reads/writes the same
   `.sfs-local/` regardless of which CLI invokes it.
3. Plugin-mechanism files are not part of the work artifact surface — they
   only provide command discovery for each CLI.

#### 4.A.1.2 Concrete reference: bkit pdca install commands (user-provided 2026-05-03)

This is the EXACT pattern that sfs/solon must replicate. Read these repos
first; do not reinvent the manifest format.

| CLI | bkit install command | sfs/solon equivalent (to create) |
|---|---|---|
| Claude Code | `/plugin marketplace add popup-studio-ai/bkit-claude-code` | New marketplace repo — recommend `MJ-0701/solon-claude-code` (matches Solon Product naming) |
| Gemini CLI | `gemini extensions install https://github.com/popup-studio-ai/bkit-gemini.git` | New extension repo — recommend `MJ-0701/solon-gemini` |
| Codex CLI | **미지원** (no plugin/extension marketplace mechanism in Codex CLI) | **DESIGN DECISION REQUIRED** — see §4.A.1.3 |

**Pre-implementation reading list (mandatory)**:
1. https://github.com/popup-studio-ai/bkit-claude-code — read manifest, plugin metadata, slash command definition format, file layout. Mirror this exactly for `solon-claude-code`.
2. https://github.com/popup-studio-ai/bkit-gemini — read extension structure, install hook, command/extension declaration. Mirror for `solon-gemini`.

**Goal output of plugin/extension installs**:
- Claude Code: `/sfs <command>` (or `/solon <command>` — naming TBD with user) auto-completes in any directory.
- Gemini CLI: `sfs <command>` (or `solon <command>`) auto-completes.
- Project tree: zero plugin-mechanism files. Only `.sfs-local/` state and work artifacts.

#### 4.A.1.3 Codex CLI strategy (user decision required)

Codex has no plugin marketplace, but `sfs` works in Codex via shell-out:
`$sfs status` invokes the `sfs` binary which brew installs to PATH. This
**already works today** with zero Codex-specific install — as long as `sfs`
is in PATH (brew handles this).

The remaining question for Codex is workflow-context: how does Codex *know*
that the current project uses SFS conventions (sprint structure, gate
framework, retro semantics) so that `$sfs <command>` invocations get
appropriate AI handling? Today this is provided by `.agents/skills/sfs/SKILL.md`
project-local file. Options for the brew-umbrella + clean-project model:

- **C-1**: User-global `~/.codex/skills/sfs/SKILL.md` (or whatever Codex
  auto-loads from user-home). Verify Codex CLI's user-global discovery path
  before implementing.
- **C-2**: Accept that Codex requires project-local `.agents/skills/sfs/SKILL.md`
  (asymmetry — Claude/Gemini have plugin, Codex has small project file).
- **C-3**: Just shell-out — Codex users get `$sfs` invocation but no SKILL-mediated
  workflow context. Acceptable if Codex CLI infers context from `AGENTS.md`
  alone.
- **C-4**: Use `AGENTS.md` (Codex auto-loaded root file) as the carrier — keep
  AGENTS.md in project (already standard) but don't add additional files.

User must pick C-1/2/3/4 in §4.A.5 decision gate.

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

#### 4.A.3 Implementation work (concrete after §4.A.1.2 / §4.A.1.3)

The "research" framing of the previous handoff draft is mostly obsolete now —
user provided concrete bkit install commands. The actual work is largely
*replication* of bkit's pattern, not exploration of unknowns. Steps:

##### 4.A.3.1 Read bkit prior art (mandatory first step, do not skip)

```
git clone https://github.com/popup-studio-ai/bkit-claude-code.git /tmp/bkit-claude-code
git clone https://github.com/popup-studio-ai/bkit-gemini.git /tmp/bkit-gemini
```

Then for each repo, locate and study:
- Plugin manifest / extension descriptor file (typically a JSON / TOML / YAML
  at the repo root or in a known location).
- Slash command definitions and where they live inside the plugin/extension.
- Install-time scripts, if any.
- Naming conventions, scope of commands exposed, error/help patterns.

This determines the EXACT structure that `solon-claude-code` and
`solon-gemini` repos must follow.

##### 4.A.3.2 Decide naming with user

Plugin name: `solon` vs `sfs` — user decision. Record their choice in the
research report. Existing convention: the binary is `sfs` (Sprint Flow
System), the product is "Solon Product." Recommendation to surface to user:
plugin marketplace IDs use `solon` (product brand), slash commands inside
the plugin still use `/sfs <subcommand>` (matches existing CLI surface and
existing user muscle memory).

##### 4.A.3.3 Create solon-claude-code marketplace repo

- New repo: `MJ-0701/solon-claude-code` (or as user names).
- Mirror bkit-claude-code's structure 1:1.
- Inside the plugin: include slash command definitions equivalent to current
  `solon-mvp-dist/templates/.claude/commands/sfs.md` (one definition per
  exposed command if applicable, or a single dispatcher).
- Plugin commands ultimately call the global `sfs` binary (brew/scoop
  installed). The plugin's role is *discovery and routing*, not duplicating
  business logic.
- Verify install path: `/plugin marketplace add MJ-0701/solon-claude-code`
  works in Claude Code v2.x test session.

##### 4.A.3.4 Create solon-gemini extension repo

- New repo: `MJ-0701/solon-gemini` (or as user names).
- Mirror bkit-gemini's structure.
- Verify install path:
  `gemini extensions install https://github.com/MJ-0701/solon-gemini.git`.

##### 4.A.3.5 Codex CLI handling (per user §4.A.1.3 decision)

Implement the chosen option (C-1/2/3/4) from §4.A.1.3.

##### 4.A.3.6 Brew umbrella wiring

- `solon-mvp-dist/packaging/homebrew/sfs.rb.template` — add `post_install`
  block that:
  - Detects each CLI (claude, gemini, codex) on PATH.
  - For each detected CLI, runs the corresponding install command
    non-interactively (with `--yes` or equivalent if needed).
  - Failure of one CLI's hook does NOT abort the brew install; degrade
    gracefully + emit a warning summary at the end.
- Idempotent on second run.

##### 4.A.3.7 Scoop equivalent

- `solon-mvp-dist/packaging/scoop/sfs.json.template` — `installer.script`
  block runs PowerShell that mirrors §4.A.3.6.
- Same idempotency + graceful-degrade behavior.

##### 4.A.3.8 Update install/upgrade scripts

- `solon-mvp-dist/install.sh`, `install.ps1`: trigger the same hook so users
  who run install via curl-pipe or local install.sh also get plugin coverage.
- `solon-mvp-dist/upgrade.sh`, `upgrade.ps1`: trigger the same hook so
  existing 0.5.89-95 installations get the missing plugin coverage on next
  upgrade.

##### 4.A.3.9 Remove the project-local adapter templates from default install

- `solon-mvp-dist/install.sh` thin layout: ensure `.claude/commands/sfs.md`,
  `.gemini/commands/sfs.toml`, `.agents/skills/sfs/SKILL.md` are NOT created
  in the project. (Already largely true since 0.5.89; confirm and document.)
- `sfs agent install all` semantics: confirm this still does what it should
  for *persona/skill* artifacts (CTO/CPO/CEO/evaluator/generator/planner) but
  NOT for slash command discovery (different concern).

##### 4.A.3.10 Update docs

- `solon-mvp-dist/README.md`, `GUIDE.md`, `BEGINNER-GUIDE.md`,
  `docs/ko/...`, `docs/en/...` — install instructions should show:
  ```
  brew install MJ-0701/solon-product/sfs
  # → automatically registers /sfs slash command in Claude Code (via plugin)
  #   and Gemini CLI (via extension). Codex CLI uses shell-out via $sfs.
  ```
- Make clear: project surface stays clean. No `.claude/commands/` etc. are
  created by `sfs init`.

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
