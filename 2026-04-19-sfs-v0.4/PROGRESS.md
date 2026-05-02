---
doc_id: sfs-v0.4-progress-live
title: "PROGRESS — live single-frame snapshot (compact)"
version: live
last_overwrite: 2026-05-02T02:17:19Z
session: "idle: WU-43 closed"

# ── ENTRY POINTERS (2-file entry) ────────────────────────────────
current_wu: null
current_wu_path: null

# ── SESSION MUTEX (CLAUDE.md §1.12) ───────────────────────────────
# Keep scalar form for tool compatibility (.sfs-local/scripts/sfs-loop.sh stop/status, auto-resume contract).
current_wu_owner: null

# ── SCHEDULED TRACE (scripts/append-scheduled-task-log.sh) ───────
# newest-first. rolling tail is allowed to be shorter than N during compaction.
scheduled_task_log:
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
    3) WU-43 is closed locally at `6c4ca93`; ask user whether to release
       0.5.66-product or choose the next WU/domain.
  on_skip_patterns: ["아니", "잠깐", "다른", "stop"]
  on_skip_action: "What do you want to do instead (1 line)?"
  on_ambiguous: "WU-43 is closed locally. Release 0.5.66-product or pick next WU?"
  safety_locks:
    - "self-validation-forbidden: A/B/C 의미 결정은 사용자에게만"
    - "no destructive git"
  last_written: 2026-05-02T02:01:07Z
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

## ② In-Progress

- None.

## ③ Next

- Ask user whether to release `0.5.66-product` or choose the next WU/domain.

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
