---
doc_id: sfs-v0.4-progress-live
title: "PROGRESS — live single-frame snapshot (compact)"
version: live
last_overwrite: 2026-05-02T22:24:00+09:00
session: "codex: 0.5.83 stale version notice released"

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
  - ts: 2026-05-02T07:49:37+09:00
    codename: overnight-sfs-loop-deploy
    check_exit: 0
    action: "doc-refactor: slim solon-mvp-dist entry docs (templates)"
    ahead_delta: "+0"
  - ts: 2026-05-02T06:49:54+09:00
    codename: overnight-sfs-loop-deploy
    check_exit: 16
    action: "resume-session-check: sched_log_drift repaired"
    ahead_delta: "+0"
  - ts: 2026-05-02T04:13:36+09:00
    codename: overnight-sfs-loop-deploy
    check_exit: 16
    action: "resume-session-check: sched_log_drift detected (this run)"
    ahead_delta: "+0"
  - ts: 2026-05-02T02:38:27+09:00
    codename: overnight-sfs-loop-deploy
    check_exit: 0
    action: "loop: WU-36 bookkeeping + loopq-9861/9920/9979 done (queue empty)"
    ahead_delta: "+5"
  - ts: 2026-05-02T02:14:34+09:00
    codename: overnight-sfs-loop-deploy
    check_exit: 0
    action: "WU-36 bookkeeping (cycle-end division recommender WU file/index/progress)"
    ahead_delta: "+0"

# ── DOMAIN LOCKS (SSoT) ──────────────────────────────────────────
# Keep only operational fields here; verbose history lives in the archive snapshot.

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
    2) Run: `bash scripts/resume-session-check.sh` (expect exit 0).
    3) Latest product release is `0.5.83-product`; ask user for the next
       WU/domain unless they provide a direct task.
    4) For a direct task, start from clean `main` and create a fresh
       `feature/<slug>` or `hotfix/<slug>` branch before edits.
  on_skip_patterns: ["아니", "잠깐", "다른", "stop"]
  on_skip_action: "What do you want to do instead (1 line)?"
  on_ambiguous: "0.5.83-product is released. What should Solon handle next?"
  safety_locks:
    - "self-validation-forbidden: A/B/C 의미 결정은 사용자에게만"
    - "no destructive git"
  last_written: 2026-05-02T13:24:00Z
---

# PROGRESS — compact

Full pre-compaction snapshot (verbatim): `archives/progress/PROGRESS-2026-05-01T181258Z-precompact.md`.

## ① Just-Finished

- WU-42 closed and released as `0.5.65-product`. Windows public docs now use
  `sfs.cmd` for PowerShell/cmd examples, keep `sfs` for Mac/Git Bash, and label
  source PowerShell installers as fallback rather than the recommended path.
- WU-43 closed locally at `6c4ca93`. `sfs start` now prints a readable
  `next: sfs brainstorm ...` line, and routed agent docs clarify that
  bash-first means no artifact refinement rather than no Next.
- WU-43 released as `0.5.66-product`: stable `d6af969` / tag
  `v0.5.66-product`; Homebrew `55dc2a2`; Scoop `36ad9c5`; release verifier
  passed and installed `sfs version --check` is up to date.
- WU-44 closed locally at `4430df2`. `sfs profile` is restored as a public
  command: packaged adapter, global CLI routing, dispatch routing, routed
  context, generated SFS.md overview placeholders, README/GUIDE, and agent
  adapter docs.
- WU-44 released as `0.5.67-product`: stable `dd6c018` / tag
  `v0.5.67-product`; Homebrew `a397a46`; Scoop `4d898da`; release verifier
  passed and installed `sfs version` reports `0.5.67-product`.
- User-directed SFS fundamentals + dual naming + runtime command-shape release
  shipped as `0.5.68-product`: stable `6546310` / tag `v0.5.68-product`;
  Homebrew `dbfdeb6`; Scoop `a2398d6`; release verifier passed and installed
  `sfs version --check` reports up to date.
- G4 review evidence upgrades shipped through `0.5.69-product` →
  `0.5.71-product`: evidence bundles now include implementation files, bounded
  source excerpts/diffs, indexed line targets, build/smoke evidence, scoped
  SFS/runtime classification, and generator executor attribution.
- Runtime safety release shipped as `0.5.72-product`: stable `3cb52b0` / tag
  `v0.5.72-product`; Homebrew `106c9a2`; Scoop `a2c7368`; installed
  `sfs version --check` reports up to date.
- Release verifier hardening landed at dev `4650738`: network checks, installed
  runtime checks, and clean handoff checks are bounded; verifier passed for
  `0.5.72-product` with dev/stable/Homebrew/Scoop all clean + synced.
- External study-note validation confirmed the upgraded G4 path: first Codex
  CPO run produced a real code-level `partial`, rework fixed read-mode PDF
  pointer pass-through, smoke/build passed, and rerun returned G4 `pass`.
- Context router upgrade repair shipped as `0.5.73-product`: stable `df8552a` /
  tag `v0.5.73-product`; Homebrew `9a30c0b`; Scoop `be4134e`; installed
  `sfs version --check` reports up to date. `sfs upgrade` now repairs missing
  context router targets even when the project already reports latest.
- Gate numbering/report-label cleanup validated locally: Solon report/CLI
  surfaces now prefer Gate 1~7 labels and `/sfs review --gate 6` for review,
  while older storage ids stay compatibility-only.
- Gate numbering/report-label cleanup + review evidence bundle hotfix shipped
  together as `0.5.74-product`: dev `ebf8a4a`; stable `2062971` / tag
  `v0.5.74-product`; Homebrew `7e00696`; Scoop `24f4aa8`; full release
  verifier passed and installed `sfs version --check` reports up to date.
- Gate 6 review evidence excerpt-priority hotfix shipped as
  `0.5.75-product`: stable `b9e3276` / tag `v0.5.75-product`; Homebrew
  `508162d`; Scoop `9d3eb60`; full release verifier passed and installed
  `sfs version --check` reports up to date. Collector now separates full
  manifests from bounded excerpt priority, promotes declared implement/plan
  target paths, includes safe `.env.example`, compacts `.gitignore`
  product-owned hunks, and separates same-tool review risk as warning metadata.
- Gate 6 review scope filter refinement shipped as `0.5.76-product`: stable
  `28366b1` / tag `v0.5.76-product`; Homebrew `4f7683b`; Scoop `291a03b`;
  full release verifier passed and installed `sfs version --check` reports up
  to date. `.claude/skills/sfs/**` is classified as SFS system scope, nested
  generated outputs like `backend/dist/**` and `backend/build/**` are excluded
  from reviewable manifests, and declared first-class source/config excerpts
  are emitted before the generic first-N cap.
- WU-45 closed locally at `8f16102`: Dev backend architecture guardrails now
  record the clean layered monolith → CQRS → Hexagonal guidance → MSA guidance
  ladder in `/sfs implement`, with Hexagonal refactor gated on user acceptance
  and MSA refactor gated on explicit approval.
- WU-46 closed locally at `a67d9b3`: Strategy-PM, Taxonomy, Design/Frontend,
  QA, and Infra now have lightweight-start policy ladders with trigger-evidence
  strengthening and user acceptance/approval before major roadmap,
  rename/schema, redesign, release-readiness, or infra/ops transitions.
- Dev/Division policy ladders shipped as `0.5.77-product`: stable `953f36f` /
  tag `v0.5.77-product`; Homebrew `d3510fb`; Scoop `54d8918`; full release
  verifier passed and installed `sfs version --check` reports up to date.
- WU-47 closed locally at `3f11052`: context-router audit confirmed fresh user
  `sfs init` installs routed context correctly, found the same-version upgrade
  repair gap for `_INDEX.md`/`kernel.md`, and slimmed this dev repo's Codex SFS
  Skill to the same 36-line router used by product projects.
- Context router same-version repair shipped as `0.5.78-product`: stable
  `aef689e` / tag `v0.5.78-product`; Homebrew `ce55700`; Scoop `252c75c`;
  package/runtime verifier passed and installed `sfs version --check` reports
  up to date.
- Review lens routing shipped as `0.5.79-product`: dev `be01069`; stable
  `d6b753f` / tag `v0.5.79-product`; Homebrew `f179e68`; Scoop `1215135`;
  full release verifier passed and installed `sfs version --check` reports up
  to date. `sfs review` now auto-selects code/docs/strategy/design/taxonomy/QA/
  ops/release/artifact acceptance lens and asks CPO for a concrete next action.
- Brainstorm depth modes shipped as `0.5.80-product`: dev `561aab9`; stable
  `68aa669` / tag `v0.5.80-product`; Homebrew `0ff49c5`; Scoop `7011133`;
  full release verifier passed and installed `sfs version --check` reports up
  to date. `sfs brainstorm` now supports `--simple`/`--easy`/`--quick`, default
  normal, and `--hard`; `sfs start` exposes the depth selector in its `next:`
  line so users discover the flow without reading the guide first.
- Retro close default shipped as `0.5.81-product`: dev `8e9e548`; stable
  `2ceedde` / tag `v0.5.81-product`; Homebrew `aa6fe33`; Scoop `c6d63c5`;
  full release verifier passed and installed `sfs version --check` reports up
  to date. `sfs retro` is now the normal close command; `--close` remains a
  compatibility alias and `--draft`/`--no-close` preserve open-only behavior.
- Product docs current flow shipped as `0.5.82-product`: dev `adc967f`; stable
  `a691e4c` / tag `v0.5.82-product`; Homebrew `90b157b`; Scoop `1c9c5da`;
  full release verifier passed and installed `sfs version --check` reports up
  to date. README is now a high-level map/TOC, detail docs live under
  `docs/ko` and `docs/en`, Korean 10x value docs were added, the English guide
  was added, and the docs explicitly state that GitHub Markdown has no native
  language-switch tabs.
- Stale version notice shipped as `0.5.83-product`: dev `a1fab8c`; stable
  `34bc0b2` / tag `v0.5.83-product`; Homebrew `054abff`; Scoop `49cf67a`;
  full release verifier passed and installed `sfs version --check` reports up
  to date. Initialized projects now get a throttled terminal notice when their
  project/runtime is at least five product releases behind latest; interactive
  `sfs status` asks whether to run `sfs upgrade` now; `SFS_VERSION_NOTICE=0`
  disables the notice.

## ② In-Progress

- None.

## ③ Next

- Current truth is `0.5.83-product`; no active WU. Ask user for the next
  WU/domain unless they provide a direct task. For any new direct task, create a
  fresh branch from clean `main` first (`feature/<slug>` or `hotfix/<slug>`).

## ④ Artifacts

- Archive: `archives/progress/PROGRESS-2026-05-01T181258Z-precompact.md`.
- Sandbox smoke: `/private/tmp/sfs-implement-contract-smoke2.9N6vXf`.
- Context-routing smoke: `/private/tmp/sfs-context-thin.DHCD92`, `/private/tmp/sfs-context-vendored.QH1mja`, `/private/tmp/sfs-context-upgrade.i5uEER`.
- Product release: stable `72b2543` / tag `v0.5.60-product`; Homebrew `97ceb6c`; Scoop `d4c8866`.
- Product hotfix release: stable `39dd076` / tag `v0.5.61-product`; Homebrew `b60c810`; Scoop `0681b4e`.
- Product context-routing release: stable `fb60524` / tag `v0.5.62-product`;
  Homebrew `1a7d1f1`; Scoop `a5362d2`.
- Product beginner-guide release: stable `1bb4209` / tag `v0.5.63-product`;
  Homebrew `a2c72cd`; Scoop `093fac3`.
- Product beginner wording cleanup release: stable `60ba10b` / tag
  `v0.5.64-product`; Homebrew `7dfbf95`; Scoop `4c01e25`.
- Product Windows command docs release: stable `b8fc3c2` / tag
  `v0.5.65-product`; Homebrew `6538fda`; Scoop `9dd73fe`.
- Product start next-action release: stable `d6af969` / tag
  `v0.5.66-product`; Homebrew `55dc2a2`; Scoop `36ad9c5`.
- Product profile command restore release: stable `dd6c018` / tag
  `v0.5.67-product`; Homebrew `a397a46`; Scoop `4d898da`.
- Product SFS fundamentals + runtime command-shape release: stable `6546310` /
  tag `v0.5.68-product`; Homebrew `dbfdeb6`; Scoop `a2398d6`.
- Product G4 evidence bundle release: stable `f44a53c` / tag
  `v0.5.69-product`; Homebrew `867b3e4`; Scoop `c88e2c2`.
- Product code-level G4 packaging release: stable `13c1dcb` / tag
  `v0.5.70-product`; Homebrew `05b9c7d`; Scoop `60f4e66`.
- Product targeted G4 source evidence release: stable `b91d433` / tag
  `v0.5.71-product`; Homebrew `821e908`; Scoop `b799fba`.
- Product runtime safety guard release: stable `3cb52b0` / tag
  `v0.5.72-product`; Homebrew `106c9a2`; Scoop `a2c7368`.
- Product context router upgrade repair release: stable `df8552a` / tag
  `v0.5.73-product`; Homebrew `9a30c0b`; Scoop `be4134e`.
- Product Gate 1~7 UX + review evidence bundle release: stable `2062971` /
  tag `v0.5.74-product`; Homebrew `7e00696`; Scoop `24f4aa8`.
- Product Gate 6 review evidence prioritization release: stable `b9e3276` /
  tag `v0.5.75-product`; Homebrew `508162d`; Scoop `9d3eb60`.
- Product Gate 6 review scope filter release: stable `28366b1` / tag
  `v0.5.76-product`; Homebrew `4f7683b`; Scoop `291a03b`.
- WU-45 local dev commit: `8f16102`.
- WU-46 local dev commit: `a67d9b3`.
- Product division policy ladders release: stable `953f36f` / tag
  `v0.5.77-product`; Homebrew `d3510fb`; Scoop `54d8918`; dev `5f32322`.
- WU-47 local dev commit: `3f11052` (backfill `cc9785d`).
- Product context router same-version repair release: stable `aef689e` / tag
  `v0.5.78-product`; Homebrew `ce55700`; Scoop `252c75c`; dev `cc9785d`.
- Product review lens routing release: stable `d6b753f` / tag
  `v0.5.79-product`; Homebrew `f179e68`; Scoop `1215135`; dev `be01069`.
- Product brainstorm depth modes release: stable `68aa669` / tag
  `v0.5.80-product`; Homebrew `0ff49c5`; Scoop `7011133`; dev `561aab9`.
- Product retro close default release: stable `2ceedde` / tag
  `v0.5.81-product`; Homebrew `aa6fe33`; Scoop `c6d63c5`; dev `8e9e548`.
- Product docs current flow release: stable `a691e4c` / tag
  `v0.5.82-product`; Homebrew `90b157b`; Scoop `1c9c5da`; dev `adc967f`.
- Product stale version notice release: stable `34bc0b2` / tag
  `v0.5.83-product`; Homebrew `054abff`; Scoop `49cf67a`; dev `a1fab8c`.
- Study-note G4 validation: `.sfs-local/tmp/review-runs/2026-W18-sprint-5-G4-20260502T054452Z.result.md`
  returned `pass` after code-level rework.
