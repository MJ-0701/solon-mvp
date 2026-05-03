---
doc_id: sfs-v0.4-progress-live
title: "PROGRESS — live single-frame snapshot (compact)"
version: live
last_overwrite: 2026-05-03T10:27:58+09:00
session: "claude-cowork: handoff restructure — slash-command-global-stub hotfix promoted to priority 1"

# ── ENTRY POINTERS (2-file entry) ────────────────────────────────
current_wu: null
current_wu_path: null

# ── SESSION MUTEX (CLAUDE.md §1.12) ───────────────────────────────
# Keep scalar form for tool compatibility (.sfs-local/scripts/sfs-loop.sh stop/status, auto-resume contract).
current_wu_owner:
  session_codename: null
  claimed_at: null
  last_heartbeat: null
  ttl_minutes: 30

# ── SCHEDULED TRACE (scripts/append-scheduled-task-log.sh) ───────
# newest-first. rolling tail is allowed to be shorter than N during compaction.
scheduled_task_log:
  - ts: 2026-05-03T10:21:16+09:00
    codename: claude-cowork-doc-audit-split
    check_exit: 0
    action: "session end: PROGRESS trim + audit done + resume_hint re-aimed at MD split queue (Tier 1)"
    ahead_delta: "+0"
  - ts: 2026-05-03T02:52:38+09:00
    codename: claude-cowork-doc-audit-split
    check_exit: 99
    action: "session start: codex 0.5.87-95 drift recovery + PROGRESS trim + doc audit/split (in progress)"
    ahead_delta: "+0"
  - ts: 2026-05-03T02:00:00+09:00
    codename: codex-release-train-87-95
    check_exit: 0
    action: "release: 0.5.87-95 codex hotfix train (87 thin-context migration / 88 archive compaction / 89 thin-surface parity / 90 vendored→thin migration / 91 empty dir cleanup / 92 self-upgrade continuation / 93 scoop project hook / 94 scoop one-shot docs / 95 update UX); details in solon-mvp-dist/CHANGELOG.md and git log 6111010..e3c98ad"
    ahead_delta: "+9"
  - ts: 2026-05-02T23:45:52+09:00
    codename: release-0-5-86-docs-trim-internal-rationale
    check_exit: 0
    action: "release: 0.5.86 docs trim + KO/EN sync verified"
    ahead_delta: "+1"
  - ts: 2026-05-02T22:55:09+09:00
    codename: release-0-5-85-guide-readme-close-flow
    check_exit: 0
    action: "release: 0.5.85 GUIDE/README close flow verified"
    ahead_delta: "+1"
  - ts: 2026-05-02T22:48:00+09:00
    codename: release-0-5-84-ambient-token-harness-hygiene
    check_exit: 0
    action: "release: 0.5.84 ambient token/harness hygiene verified"
    ahead_delta: "+1"
  - ts: 2026-05-02T22:24:00+09:00
    codename: release-0-5-83-stale-version-notice
    check_exit: 0
    action: "release: 0.5.83 stale version notice verified"
    ahead_delta: "+1"
  - ts: 2026-05-02T22:05:00+09:00
    codename: release-0-5-82-product-docs-current-flow
    check_exit: 0
    action: "release: 0.5.82 product docs current flow verified"
    ahead_delta: "+1"
  - ts: 2026-05-02T21:46:16+09:00
    codename: release-0-5-81-retro-close-default
    check_exit: 0
    action: "release: 0.5.81 retro close default verified"
    ahead_delta: "+1"
  - ts: 2026-05-02T21:34:39+09:00
    codename: release-0-5-80-brainstorm-depth-modes
    check_exit: 0
    action: "release: 0.5.80 brainstorm depth modes verified"
    ahead_delta: "+1"
  - ts: 2026-05-02T21:16:12+09:00
    codename: release-0-5-79-review-lens-routing
    check_exit: 0
    action: "release: 0.5.79 review lens routing verified"
    ahead_delta: "+1"
  - ts: 2026-05-02T18:41:34+09:00
    codename: release-0-5-78-context-router-core-repair
    check_exit: 0
    action: "release: 0.5.78 context router same-version repair verified"
    ahead_delta: "+1"
  - ts: 2026-05-02T18:24:21+09:00
    codename: release-0-5-77-division-policy-ladders
    check_exit: 0
    action: "release: 0.5.77 division policy ladders verified"
    ahead_delta: "+1"
  - ts: 2026-05-02T18:17:02+09:00
    codename: codex-non-dev-division-policy-ladders
    check_exit: 0
    action: "WU-46 non-Dev division policy ladders closed locally"
    ahead_delta: "+1"
  - ts: 2026-05-02T18:10:45+09:00
    codename: codex-dev-hq-architecture-evolution
    check_exit: 0
    action: "WU-45 dev backend architecture ladder closed locally"
    ahead_delta: "+1"
  - ts: 2026-05-02T16:32:21+09:00
    codename: gate-numbering-plus-review-evidence-release
    check_exit: 0
    action: "release: 0.5.74 Gate 1~7 UX + review evidence bundle hotfix verified"
    ahead_delta: "+0"
  - ts: 2026-05-02T15:04:46+09:00
    codename: hotfix-sfs-context-router-modules
    check_exit: 0
    action: "release: 0.5.73 context router upgrade repair verified"
    ahead_delta: "+0"
  - ts: 2026-05-02T14:50:14+09:00
    codename: codex-handoff-drift-guard
    check_exit: 17
    action: "manual repair: PROGRESS/HANDOFF release drift after 0.5.72"
    ahead_delta: "+0"
  - ts: 2026-05-02T07:59:33+09:00
    codename: overnight-sfs-loop-deploy
    check_exit: 0
    action: "doc-refactor: slim gemini /sfs command (entry token trim)"
    ahead_delta: "+0"
  - ts: 2026-05-02T07:55:48+09:00
    codename: overnight-sfs-loop-deploy
    check_exit: 0
    action: "doc-refactor: CLAUDE.md entry token trim"
    ahead_delta: "+0"

domain_locks:
  D-A-WU-24:
    owner: null
    claimed_at: null
    last_heartbeat: null
    ttl_minutes: 30
    status: COMPLETE
    next_step: 14
    priority: 8
    prefer_mode: closed
    spec_doc: 2026-04-19-sfs-v0.4/sprints/WU-24.md
  D-B-WU-31:
    owner: null
    claimed_at: null
    last_heartbeat: null
    ttl_minutes: 30
    status: COMPLETE
    next_step: 9
    priority: 8
    prefer_mode: closed
    spec_doc: 2026-04-19-sfs-v0.4/sprints/WU-31.md
  D-C-WU-30:
    owner: null
    claimed_at: null
    last_heartbeat: null
    ttl_minutes: 30
    status: COMPLETE
    next_step: 8
    priority: 8
    prefer_mode: closed
    spec_doc: 2026-04-19-sfs-v0.4/sprints/WU-30.md
  D-D-meta-logs:
    owner_forward: null
    owner_reverse: null
    forward_idx: 5
    reverse_idx: 4
    stop_when: "forward_idx >= reverse_idx"
    ttl_minutes: 30
    status: COMPLETE
    priority: 8
    prefer_mode: closed
  D-E-meta-retro:
    owner_forward: null
    owner_reverse: null
    forward_idx: 5
    reverse_idx: 9
    list: [11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
    stop_when: "forward_idx >= reverse_idx"
    ttl_minutes: 30
    priority: 5
    prefer_mode: user-active-only
  D-F-meta-handoff:
    owner: null
    claimed_at: null
    last_heartbeat: null
    ttl_minutes: 30
    priority: 7
    prefer_mode: user-active-only
  D-G-WU-25:
    owner: null
    claimed_at: null
    last_heartbeat: null
    ttl_minutes: 30
    next_step: 10
    priority: 2
    prefer_mode: scheduled
    spec_doc: 2026-04-19-sfs-v0.4/sprints/WU-25.md
  D-H-WU-26:
    owner: null
    claimed_at: null
    last_heartbeat: null
    ttl_minutes: 30
    next_step: 2
    priority: 3
    prefer_mode: scheduled
    spec_doc: 2026-04-19-sfs-v0.4/sprints/WU-26.md
  D-I-WU-27:
    owner: null
    claimed_at: 2026-04-29T22:30:38+09:00
    last_heartbeat: 2026-04-29T23:00:00+09:00
    ttl_minutes: 30
    status: COMPLETE
    next_step: "8.7+"
    priority: 4
    prefer_mode: user-active-deferred
    spec_doc: 2026-04-19-sfs-v0.4/sprints/WU-27.md

resume_hint:
  default_action: |
    1) Read `CLAUDE.md`, then `PROGRESS.md`.
    2) Run: `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh` (expect exit 0).
    3) Read `2026-04-19-sfs-v0.4/HANDOFF-next-session.md` — §4.A is the TOP
       priority hotfix (slash-command-global-stub regression in 0.5.89-95).
       §4.B (MD split queue) and §4.C (§1.14 generalization) are deferred
       UNTIL §4.A lands and 0.5.96-product is verified 7/7.
    4) **§4.A — slash-command-global-stub hotfix → release as `0.5.96-product`**:
         a. Reproduce the regression: `cd ~/IdeaProjects/study-note && claude`
            then `/sfs` should fail "No commands match" (or
            `ls -la ~/.claude/commands/sfs.md` should show absent).
         b. Branch from clean `main`: `hotfix/sfs-slash-command-global-stub`.
         c. Reference scan first (see HANDOFF §4.A.4 step 1) to surface every
            place that touches `.claude/commands/sfs.md`, agent install, etc.
         d. Verify Codex CLI's user-global slash-discovery path BEFORE
            implementing — do not guess. Claude Code uses
            `~/.claude/commands/sfs.md`; Gemini CLI uses
            `~/.gemini/commands/sfs.toml`; Codex path needs confirmation.
         e. Implement helper `solon-mvp-dist/bin/install-global-adapter-stubs.sh`
            (+ `.ps1` for Windows): idempotent; SFS-managed marker probe;
            cross-platform HOME detection.
         f. Wire into `install.sh` / `install.ps1` / `upgrade.sh` /
            `upgrade.ps1` / Homebrew formula `post_install` / Scoop manifest
            `installer.script`. Conceptually keep separate from
            `sfs agent install all` (persona/skill domain).
         g. Update `templates/.claude/commands/sfs.md` etc. if needed for
            user-global stub usage.
         h. Update GUIDE / BEGINNER-GUIDE / docs/ko / docs/en to mention `/sfs`
            is globally available after install with no per-project setup.
         i. CHANGELOG entry under `### Fixed` (text in HANDOFF §4.A.4 step 10).
         j. Run `cut-release.sh --apply --version 0.5.96-product` flow,
            push stable + tag + Homebrew + Scoop, verify 7/7.
         k. Local verification: `cd ~/IdeaProjects/study-note && claude` then
            `/sfs` autocompletes; same in `~/agent_architect`. Idempotency
            test: `sfs upgrade` second run is a no-op for global stubs.
    5) After §4.A 7/7 green, ask user before starting §4.B (MD split queue)
       — that work is staged in HANDOFF §4.B and not auto-resumed.
  on_skip_patterns: ["아니", "잠깐", "다른", "stop", "다른거"]
  on_skip_action: "Top priority is the slash-command-global-stub hotfix → 0.5.96-product (HANDOFF §4.A). MD split queue (§4.B) is deferred. Latest product release is `0.5.95-product`. What do you want to do instead?"
  on_ambiguous: "Slash-command-global-stub hotfix is queued as top priority (HANDOFF §4.A). Latest product release is `0.5.95-product`. Start the hotfix, or different priority?"
  safety_locks:
    - "self-validation-forbidden: A/B/C 의미 결정은 사용자에게만"
    - "no destructive git"
    - "Hotfix §4.A: verify Codex user-global path before writing — do not guess. Idempotent stub install only — never overwrite user-modified content. Keep separate from `sfs agent install all` persona/skill domain."
    - "MD split (§4.B): never start until §4.A 0.5.96-product is verified 7/7."
    - "MD split (§4.B): pre-flight reference scan required + frontmatter 11 fields required + parent link stub required + atomic commit + resume-session-check exit 0 verification."
    - "MD split (§4.B): never touch DO NOT split list (CHANGELOG, templates/**, archives/**, root redirect stubs, .claude/agents/*, .agents/skills/*, .gemini/commands/*.toml, .sfs-local/**, recent-trim solon-mvp-dist/GUIDE.md/BEGINNER-GUIDE.md/README.md)."
  last_written: 2026-05-03T01:27:58Z
---

# PROGRESS — compact

Full pre-compaction snapshot (verbatim): `archives/progress/PROGRESS-2026-05-01T181258Z-precompact.md`.

## ① Just-Finished

> 0.5.60-0.5.86 narratives rotated to
> `archives/progress/PROGRESS-bullets-rotation-2026-05-03-pre-0.5.93.md`
> (verbatim, frontmatter-tagged). 0.5.87-0.5.92 codex hotfix train was not
> recorded in PROGRESS bullets at release time — see `solon-mvp-dist/CHANGELOG.md`
> entries `^## \[0\.5\.(8[7-9]|9[0-2])\]` and git log `6111010..6322079`.

- 0.5.87-product (codex, 2026-05-03): thin runtime context migration — thin
  installs no longer copy managed routed context docs into `.sfs-local/context`;
  agent adapters resolve via `sfs context path`. `sfs upgrade` migrates legacy
  project-local managed context into a compressed runtime migration backup.
  Sprint close/tidy now packs verbose workbench files into one
  `sprint-evidence.tar.gz`. `sfs adopt` report/retro now produces a useful
  project snapshot instead of mostly listing paths.
- 0.5.88-0.5.92 (codex hotfix train, 2026-05-03): project-surface archive
  compaction + thin-surface parity (no project-local `.claude/.gemini/.agents`
  by default; `agent install all` is opt-in) + Windows/Scoop thin migration +
  empty runtime dir cleanup + Windows self-upgrade now continues into project
  upgrade. See CHANGELOG `0.5.88-0.5.92` for per-release details.
- Scoop project upgrade hook shipped as `0.5.93-product`: running
  `scoop update sfs` from an initialized project updates the global runtime
  and continues into project upgrade automatically; running outside a project
  is unchanged. Windows self-upgrade paths set `SFS_SCOOP_PROJECT_UPGRADE=0`
  while reloading runtime to avoid duplicate project migration.
- Windows upgrade docs lead with Scoop one-shot flow as `0.5.94-product`:
  README, GUIDE, BEGINNER-GUIDE, and the English guide now show
  `scoop update sfs` as the primary Windows update path, with `sfs.cmd upgrade`
  as the project-only fallback.
- Windows one-shot update command clarified as `0.5.95-product`: Windows docs
  lead with `sfs.cmd update` (not a two-line Scoop sequence). The command owns
  the full runtime + project update flow. `sfs update` no longer prints a
  compatibility-warning line, so `sfs.cmd update` is a clean user-facing
  one-shot on Windows.

## ② In-Progress

- None.

## ③ Next

- Current truth is `0.5.95-product`. claude-cowork session is mid-flight on
  PROGRESS trim + full doc audit/split (TaskList #17~#21+). Codex hotfix
  train 0.5.87-95 already shipped (see CHANGELOG.md `^## \[0\.5\.(8[7-9]|9[0-5])`)
  but never recorded in PROGRESS bullets — drift surfaced via
  `release_handoff_drift` from `resume-session-check.sh` and is being repaired
  in this same commit chain.

## ④ Artifacts

> 0.5.60-0.5.86 release ledger entries rotated to
> `archives/progress/PROGRESS-bullets-rotation-2026-05-03-pre-0.5.93.md`.
> 0.5.87-0.5.92 codex hotfix train: see git log `6111010..6322079` and
> `solon-mvp-dist/CHANGELOG.md` (sha details not individually entered into
> PROGRESS at release time).

- Pre-compaction snapshot: `archives/progress/PROGRESS-2026-05-01T181258Z-precompact.md`.
- Pre-0.5.93 bullets archive: `archives/progress/PROGRESS-bullets-rotation-2026-05-03-pre-0.5.93.md`.
- Sandbox smoke: `/private/tmp/sfs-implement-contract-smoke2.9N6vXf`.
- Context-routing smoke: `/private/tmp/sfs-context-thin.DHCD92`, `/private/tmp/sfs-context-vendored.QH1mja`, `/private/tmp/sfs-context-upgrade.i5uEER`.
- Product Scoop project upgrade hook release: tag `v0.5.93-product`; dev
  commit `6f61de1`.
- Product Windows Scoop one-shot docs release: tag `v0.5.94-product`; dev
  commits `6f61de1` (release handoff) + `dbfda2b` (test guard).
- Product Windows update UX release: tag `v0.5.95-product`; dev commit
  `e3c98ad`. Stable / Homebrew / Scoop tap commit shas not individually
  recorded in PROGRESS at release time — see release verifier outputs and
  tap repo logs.
- Study-note G4 validation: `.sfs-local/tmp/review-runs/2026-W18-sprint-5-G4-20260502T054452Z.result.md`
  returned `pass` after code-level rework.
