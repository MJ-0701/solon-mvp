---
doc_id: sfs-v0.4-progress-live
title: "PROGRESS — live single-frame snapshot (덮어쓰기 방식)"
version: live
last_overwrite: 2026-04-25T09:48:00+09:00
session: "19번째 세션 `eager-elegant-bell` (user-active). 사용자 우선순위 1→2→4→6→5→3→7→8 확정 (2026-04-25 10:00 KST). WU-22 (MVP next-feature roadmap & sequencing plan) 진행 중 — 8 후보 1-pager + 의존성 그래프 + release 그루핑 옵션 α/β/γ 제시 완료. 사용자 결정 (WU22-D1) 대기."
current_wu: WU-22
current_wu_path: 2026-04-19-sfs-v0.4/sprints/WU-22.md
current_wu_owner:
  session_codename: eager-elegant-bell
  claimed_at: 2026-04-25T09:48:00+09:00
  last_heartbeat: 2026-04-25T09:48:00+09:00
  ttl_minutes: 15
released_history:
  last_owner: confident-loving-ride
  last_claimed_at: 2026-04-25T09:15:00+09:00
  last_released_at: 2026-04-25T09:45:00+09:00
  last_reason: "18번째 세션 user-active (D-2). 사용자 지시 'a로 ㄱㄱ' → resume_hint default_action (a) Phase 1 킥오프 dry-run 실행. WU-21 sandbox /tmp/wu21-dry/ 에서 (1) install.sh v0.2.4-mvp 완전 dry-run (fake consumer + ASSUME_YES=1 + 재실행 멱등성) → exit 0 PASS, IP 경계 OK (내부 docset 경로 유출 0건) (2) setup-w0.sh pre-flight (env 검증 3건 + TEMPLATES_DIR 오탐 + 의존 파일 4건 존재 확인) → PASS (3) setup-w0.sh Step 4-8 시뮬 (clone bypass) 후 verify-w0.sh → exit 0 + WARN 3 (placeholder 치환 대기, 예상). **D-day 2026-04-27 (월) 실행 차단 요소 없음**. 후속 TODO 2건 (F-04): verify-w0.sh check #7 over-strict (install.sh output 에 대해 OSS 제품명 'Solon' 까지 차단) + check #6 설명용 placeholder 오탐."
  last_final_commits: [TBD_18TH_SNAPSHOT]   # 본 WU-21 완료 commit + PROGRESS snapshot. 실체 sha 는 다음 세션이 backfill (P-03 예방 패턴).
  prior_owner: admiring-fervent-dijkstra
  prior_claimed_at: 2026-04-25T09:06:00+09:00
  prior_released_at: 2026-04-25T09:10:00+09:00
  prior_reason: "17번째 세션 scheduled auto-resume. TBD_16TH_SNAPSHOT → 87b60ff 백필 + scripts/append-scheduled-task-log.sh v0.1 helper 신설 + resume-session-check.sh v0.2 → v0.3 (check #7 scheduled_task_log drift 감지 추가, exit 16) + HANDOFF mutex_state_schema sync. mutex 정상 release."
  prior_final_commits: [87b60ff]   # 17번째가 backfill 한 16번째 snapshot
  older_owner: nice-kind-babbage
  older_claimed_at: 2026-04-25T07:10:00+09:00
  older_released_at: 2026-04-25T07:30:00+09:00
  older_reason: "16번째 세션 scheduled auto-resume. 15번째의 '<cd41dff>' angle-bracket sha placeholder 를 P-03 변종으로 인식 + cleanup + resume-session-check.sh v0.2 (check #6) + scheduled_task_log 필드 신설."
  older_final_commits: [5d4c6c6_BACKFILLED, 87b60ff]
  oldest_owner: admiring-nice-faraday
  oldest_claimed_at: 2026-04-25T04:00:00+09:00
  oldest_released_at: 2026-04-25T04:18:00+09:00
  oldest_reason: "15번째 세션 scheduled auto-resume. 14번째의 staged-uncommitted WU-20.1 diff 실체화 (2709fcf, amend 로 final_sha 5525668 backfill) + P-03 learning pattern + resume-session-check.sh v0.1 신설."
  oldest_final_commits: [2709fcf, 5d4c6c6]

# ── scheduled_task_log (16번째 세션 신설, 17번째 helper 화) ──────────
# Cowork scheduled_task hourly auto-resume 의 explicit trace. rolling N=20.
# 필드: ts (ISO8601 +09:00) · codename · check_exit · action · ahead_delta
# 18번째 세션은 user-active (scheduled 아님) 이지만 trace 연속성 위해 한 줄 append.
scheduled_task_log:
  - ts: 2026-04-25T09:48:00+09:00
    codename: eager-elegant-bell
    check_exit: 15   # bracket_sha_unrealized:1:cd41dff (16번째 narrative false-positive, 후속 cleanup TODO)
    action: "19번째 세션 user-active. 사용자 우선순위 #1→#2→#4→#6→#5→#3→#7→#8 확정. WU-22 신설 (8후보 1-pager + 의존성 그래프 + release 그루핑 α/β/γ). 사용자 결정 대기."
    ahead_delta: "+1 예상 (WU-22 wip commit + final, 사용자 결정 후)"
  - ts: 2026-04-25T09:55:00+09:00
    codename: confident-loving-ride
    check_exit: 0
    action: "handoff 갱신: next default = MVP next-feature 사이클 brainstorming (v0.2.4-mvp 초기틀 확정, 사용자 push 완료)"
    ahead_delta: "+1 (handoff snapshot, push 후 또 push 필요)"
  - ts: 2026-04-25T09:45:00+09:00
    codename: confident-loving-ride
    check_exit: 0   # clean (진입 시)
    action: "WU-21 Phase 1 킥오프 dry-run (install.sh PASS + setup-w0.sh PASS + verify-w0.sh exit 0) — user-active, D-2"
    ahead_delta: "+2 (WU-21 파일 신설 commit + 18th PROGRESS snapshot)"
  - ts: 2026-04-25T09:10:00+09:00
    codename: admiring-fervent-dijkstra
    check_exit: 0
    action: "TBD_16TH_SNAPSHOT→87b60ff backfill + append-scheduled-task-log.sh helper 신설 + check.sh v0.3 (#7 drift 감지) + HANDOFF sync"
    ahead_delta: "+1 (17th snapshot commit)"
  - ts: 2026-04-25T07:30:00+09:00
    codename: nice-kind-babbage
    check_exit: 15   # bracket_sha_unrealized:cd41dff
    action: "cd41dff→5d4c6c6 backfill + check.sh v0.2 + scheduled_task_log 신설"
    ahead_delta: "+1 (16th snapshot commit = 87b60ff)"
  - ts: 2026-04-25T04:18:00+09:00
    codename: admiring-nice-faraday
    check_exit: 10   # staged 14번째 diff 감지 (P-03 발동)
    action: "WU-20.1 staged diff 실체화 (2709fcf) + P-03 + check.sh v0.1 신설"
    ahead_delta: "+2 (refresh + snapshot)"
  - ts: 2026-04-25T00:20:00+09:00
    codename: funny-pensive-hypatia
    check_exit: null
    action: "WU-20.1 refresh 작업 staged (commit 누락 → P-03 피해)"
    ahead_delta: "0"
purpose: "context reset 시 다음 세션이 본 파일 1개만 읽고 즉시 이어받을 수 있도록, 매 micro-step 마다 덮어쓰는 live snapshot."
companions:
  - "CLAUDE.md (§1 13 규율 + §1.12 mutex + §1.13 R-D1 + §2.1 용어집)"
  - "scripts/resume-session-check.sh v0.3 (17번째 세션 강화, check #7 drift 감지)"
  - "scripts/append-scheduled-task-log.sh v0.1 (17번째 세션 신설)"
  - "sprints/WU-21.md (**18번째 세션 신설** — Phase 1 킥오프 dry-run PASS, F-01~F-04 findings)"
  - "phase1-mvp-templates/setup-w0.sh + verify-w0.sh (dry-run 결과로 동작 확인 완료)"
  - "~/workspace/solon-mvp/install.sh v0.2.4-mvp (dry-run sandbox PASS)"
  - "learning-logs/2026-05/P-03 (resolved)"
  - "sprints/_INDEX.md (WU-21 row 추가 필요 — 다음 작업)"
  - "HANDOFF-next-session.md v3.3-reduced"
  - "NEXT-SESSION-BRIEFING.md v0.7"
  - "PHASE1-MVP-QUICK-START.md (사용자 Mac runbook — D-day **D-2**, 차단 요소 없음)"
  - "solon-mvp-dist/ (v0.2.4-mvp stable checksum 일치)"
rules:
  - "본 파일은 append 아님 — 매 micro-step 완료 시 완전히 덮어씀"
  - "4 필드 구조 유지: ① Just-Finished / ② In-Progress / ③ Next / ④ Artifacts"
  - "WU 경계 (커밋 직후) 에도 갱신"
  - "15번째 세션 이후: 진입 직후 scripts/resume-session-check.sh 필수 실행"
  - "16번째 이후: scheduled auto-resume 마다 scheduled_task_log 한 줄 append (no-op 포함)"
  - "17번째 이후: scheduled_task_log append 는 scripts/append-scheduled-task-log.sh helper 사용"
  - "18번째 이후: sandbox dry-run 패턴 (/tmp/wu21-dry/ 류) 은 user 실제 자산 접촉 금지 — D-day 전 검증에 유효"
resume_hint:
  purpose: "다음 세션 첫 발화가 positive confirm 한 마디여도 히스토리 파악 + 자동 resume + P-03 방지"
  trigger_positive: [ㄱㄱ, 고, ㅇㅋ, ok, OK, 시작, 가자, ㅇㅇ, 진행, go, Go, start]
  trigger_negative: [ㄴㄴ, 잠깐, stop, 아니, 중단, 다른거, 다른, no]
  default_action: |
    0. **scripts/resume-session-check.sh 실행 (v0.3)** — exit 0 이면 진행, exit 15 (`<cd41dff>` false-positive narrative) 면 그대로 진행 (16번째 세션이 이미 backfill 완료, narrative 안 잔재).
    1. **§1.12 mutex**: current_wu_owner 확인. 19번째 (eager-elegant-bell) 가 WU-22 active 면 takeover 협의 (TTL 15분 초과 시 stale).
    2. **git status** + `git rev-list --count origin/main..HEAD` 확인.
    3. **WU-22 active**: 사용자가 옵션 α/β/γ 결정했는지 §3 확인. 결정됨 → WU-22 close + WU-23 (#1 sfs slash detail design) 진입. 미결정 → 결정 받기.
    3'. (WU-22 종료 후 한정) **③ Next 메뉴** (원칙 2). **new default = WU-23 #1 sfs slash command detail design** (사용자 명시 의도 2026-04-25 09:55 KST: "mvp 기본기능 어느정도 완료 + 다음 기능 개발배포 준비"):
       (a) **MVP next-feature brainstorming** (default) — v0.2.4-mvp 초기틀 잡힘 확정. 다음 release (0.3.x or 0.4.0-mvp) 에 어떤 기능을 넣을지 후보 정리 + 사용자 결정 → plan 문서. 후보 (raw, 사용자 결정 대상):
            · sfs slash command 실제 logic (현재 어댑터에 정의만 있음, 실제 동작 부재)
            · upgrade.sh checksum-based diff preview 정교화
            · uninstall.sh 시나리오 보강 (clean removal + .gitignore marker block 정리)
            · .sfs-local/events.jsonl schema 표준화
            · decisions/ ADR mini 자동 생성 helper
            · Sprint cycle CLI helper (sprint dir 자동 scaffold)
            · 신규 어댑터 (예: cursor / windsurf / aider)
            · solon-mvp doctor 진단 스크립트
       (a2) Phase 1 킥오프 실전 — 사용자 본인 D-day (2026-04-27 월) 에 본인 Mac 에서 직접 실행. **Claude 세션 자동 진행 대상 아님**.
       (b) verify-w0.sh 후속 TODO (F-04 2건) — raw-internal, MVP 배포 대상 아님.
       (c) sync/cut-release 자동화 (R-D1, 0.4.0-mvp 예약).
       (d) upgrade.sh / uninstall.sh sandbox dry-run 추가 검증.
       (e) 11~18번째 세션 retrospective 실체화 (누적 8건).
       (f) HANDOFF mutex_state_schema 재sync.
       (g) W10 결정 세션 — cross-ref-audit §4 #14/#18/#19.
       (h) WU-16b 확장 이관.
       (i) resume-session-recover.sh (P-03 후속 자동화).
    4. 사용자 번호 지정 / 자연어 confirm 한 마디 → 해당 경로.
    5. **scheduled task auto-resume 이면** — step 3 메뉴 skip + staged/TBD/`<sha>`/stale-mutex cleanup 만 + snapshot + mutex release + helper 호출.
  on_negative: |
    "현 상태만 요약 보고 후 대기" — WU-21 Phase 1 dry-run 완료, v0.2.4-mvp 초기틀 잡힘 확정.
    install.sh + setup-w0.sh sandbox 검증 통과 + 사용자 push 완료. verify-w0.sh false-positive 2건은 raw-internal 후속.
    git ahead = 0 (push 완료 후) 또는 1 (handoff snapshot 추가 push 대기). 활성 WU 없음.
  on_ambiguous: "1-line clarifying Q (예: 'MVP next-feature brainstorming (a) 진행? 후보 중 우선순위 정해줄까? 아니면 다른 옵션?')"
  safety_locks:
    - "원칙 2 (self-validation-forbidden): A/B/C 의미 결정 자동 실행 금지"
    - "§1.5: git push 자동 실행 금지 — 사용자 터미널에서만"
    - "destructive git 금지"
    - "§1.6 FUSE bypass 는 자동 적용 허용"
    - "PROGRESS.md 덮어쓰기는 자동 허용"
    - "§1.12 Session mutex: 진입 시 current_wu_owner null 확인 → claim"
    - "§1.13 R-D1: dev-first, stable hotfix 는 같은 세션 back-port"
    - "scheduled task 모드: 사용자 부재 → 새 WU 착수 금지"
    - "15번째 P-03: staged diff 감지 → 세션 A 의도 보존"
    - "16번째 check #6: `<sha>` angle-bracket 감지 → backfill"
    - "17번째 helper: scheduled_task_log append helper 사용"
    - "17번째 check #7: drift 90분 초과 시 exit 16"
    - "18번째 sandbox 원칙: dry-run 은 /tmp/ 한정, 사용자 ~/workspace 와 GitHub 건드리지 않음"
    - "18번째 handoff (09:55 갱신): MVP 0.2.4 초기틀 확정 → 다음 default = MVP next-feature 사이클. Phase 1 킥오프 실전은 사용자 본인이 D-day 에 직접 진행 (Claude 세션 자동 X)."
  version: 6   # v1 (14번째) → v2 (15번째 P-03) → v3 (16번째 #6) → v4 (17번째 helper + #7) → v5 (18번째 sandbox-dry-run) → v6 (18번째 handoff: MVP next-feature default)
---

# PROGRESS — live snapshot (19번째 세션 eager-elegant-bell, WU-22 in_progress)

> 🚨 **본 파일 최우선 진입.** mutex **claimed** by `eager-elegant-bell` (2026-04-25T09:48+09:00).
> WU-22 = MVP next-feature roadmap brainstorming + sequencing plan. 사용자 우선순위 1→2→4→6→5→3→7→8 확정, **release 그루핑 옵션 (α/β/γ) 결정 대기**.
> 19번째 세션 로컬 커밋 예상: WU-22 wip + final (사용자 결정 후) + PROGRESS snapshot.

---

## ① Just-Finished

### 19번째 세션 (eager-elegant-bell, user-active, 2026-04-25 09:48 KST~)

**사용자 인계 요청 → 8후보 confirm → 우선순위 1→2→4→6→5→3→7→8 확정 → WU-22 신설**.

- **WU-22 신설** — `sprints/WU-22.md` (frontmatter + 본문 §1~§6). 8 후보 1-pager + 의존성 그래프 + release 그루핑 옵션 α/β/γ 제시. status: in_progress.
- **사용자 결정 대기 (WU22-D1)**: release 그루핑 — α (sequential 8 release) / β (themed bundles 4-5 release, default) / γ (big bang, 권장 X).
- **mutex claim**: confident-loving-ride 가 09:45 KST 에 release 한 후 09:48 KST 에 eager-elegant-bell claim.
- **resume-check exit 15 인지**: `<cd41dff>` historical narrative false-positive (16번째 세션이 5d4c6c6 로 이미 backfill 완료한 건의 텍스트 잔재). cleanup 은 사용자 결정 사안으로 후속 처리.

### 18번째 세션 (confident-loving-ride, user-active, 2026-04-25 09:14→09:45 KST)

**사용자 지시 '이전세션 이어서 작업 가능??' → 'a로 ㄱㄱ' (default_action a). Phase 1 킥오프 D-2 dry-run sandbox 실행 — D-day 차단 요소 없음 확인.**

- **WU-21 완료** — `sprints/WU-21.md` 신설 + 본 PROGRESS 덮어쓰기. status: done (다음 세션이 final_sha backfill).
- **install.sh v0.2.4-mvp sandbox dry-run (F-01)** — `/tmp/wu21-dry/fake-consumer/` 에서 `bash ~/workspace/solon-mvp/install.sh --yes` → **exit 0**, 멱등성 OK, IP 경계 OK (내부 docset 경로 유출 0건). 재실행도 exit 0.
- **setup-w0.sh pre-flight + 시뮬 (F-02)** — env 검증 3건 정상, 의존 파일 4건 전부 존재, clone bypass 후 Step 4-8 수동 재현 → 3 commits 정상.
- **verify-w0.sh (setup-w0.sh 출력) — exit 0 + WARN 3 (F-03)** — placeholder 치환 대기만 WARN (정상, 사용자 Stack 결정 후 치환).
- **verify-w0.sh false-positive 2건 발견 (F-04, 후속 TODO)** —
  (a) check #7 이 install.sh output 에 over-strict (OSS 제품명 'Solon' 까지 차단). verify-w0.sh 는 setup-w0.sh 전용임을 명시하거나 mode flag 추가 필요.
  (b) check #6 이 설명용 placeholder (`<N>-<short-title>`, `<YYYY-W>-sprint-<N>`) 까지 오탐. 정규식 튜닝 필요.
  → D-day 차단 요소 **아님** (이건 dry-run 도구의 노이즈). D-day 이후 WU 로 분리.
- **D-day (2026-04-27 월, 오늘 기준 D-2) 실행 차단 요소: 없음**. QUICK-START.md §2 runbook 그대로 사용자 Mac 에서 5 분 exit 가능.
- **규율 준수**: §1.3 원칙 2 (의미 결정 0건) · §1.5 push 는 사용자 터미널 · §1.8 매 step PROGRESS 갱신 · §1.12 mutex (claim → release 동일 세션) · §1.13 R-D1 (solon-mvp/ read-only) · sandbox 원칙 (dry-run = /tmp/ 한정).

### 17번째 세션 (admiring-fervent-dijkstra, scheduled auto-resume, 2026-04-25 09:06→09:10 KST)

- TBD_16TH_SNAPSHOT → 87b60ff 백필, scripts/append-scheduled-task-log.sh 신설, resume-session-check.sh v0.3 (check #7 drift).

### 16번째 세션 (nice-kind-babbage, scheduled auto-resume, 2026-04-25 07:10→07:30 KST)

- `<cd41dff>` → `5d4c6c6` backfill, resume-session-check.sh v0.2 (check #6), scheduled_task_log 신설.

### 15번째 세션 (admiring-nice-faraday, scheduled auto-resume, 2026-04-25 종료)

- WU-20.1 staged diff → 2709fcf 실체화, P-03 learning log, resume-session-check.sh v0.1.

### 14번째 이전 세션 — 요약 유지 (이전 snapshot 참조)

- 14번째 (funny-pensive-hypatia): WU-20.1 staged, commit 누락 (P-03 피해).
- 13번째 (funny-sweet-mayer): agent_architect/CLAUDE.md stub + WU-20 close.
- 12번째 (laughing-keen-shannon): R-D1 rule 채택.
- 11번째 (dreamy-busy-tesla): WU-20 Phase A + Back-port 14 파일.
- 10/9번째 (ecstatic-intelligent-brahmagupta): WU-17/18/19.

---

## ② In-Progress

**WU-22 — MVP next-feature roadmap & sequencing plan** (19번째 세션 eager-elegant-bell, 2026-04-25T09:48+09:00 claim).

- §1 8 후보 1-pager 작성 완료
- §2 의존성 그래프 정리 완료
- §3 release 그루핑 옵션 α/β/γ 제시 완료
- ⏳ **사용자 결정 대기 (WU22-D1)**: α / β / γ 중 택일
- 결정 후: WU-22 close commit + WU-23 (#1 sfs slash detail design) 진입

활성 WU: **WU-22** (`2026-04-19-sfs-v0.4/sprints/WU-22.md`).

---

## ③ Next — WU-22 결정 후 → WU-23 (#1 sfs slash detail design)

> 사용자 우선순위 (2026-04-25 10:00 KST): **#1 → #2 → #4 → #6 → #5 → #3 → #7 → #8** 확정.
> WU-22 §3 의 release 그루핑 옵션 (α/β/γ) 결정 후 WU-23 진입.

**WU-23 entry conditions** (사용자 결정 후 자동 활성):

- WU-22 §3 의 옵션 α/β/γ 중 1개 채택 (또는 변형)
- WU-22 commit + close
- WU-23 새 frontmatter 작성 → #1 sfs slash command (`/sfs status`/`start`/`plan`/`review`/`decision`/`retro`) **minimal contract spec**
- WU22-D2 사용자 결정: 6개 명령 전부 vs 핵심 2-3개 우선 (MVP scope)

**WU-22 결정 후 후속 후보 (사용자 우선순위 순)**:

- **#1 (1순위)** sfs slash command 실제 logic — 6 명령 (status/start/plan/review/decision/retro) dispatcher + logic. **WU-23 부터 detail design + 구현 진입 예정**.
- **#2 (2순위)** upgrade.sh checksum-based diff preview 정교화.
- **#4 (3순위)** .sfs-local/events.jsonl schema 표준화 (gate verdict + ts + sprint-id 필수 필드 + validator).
- **#6 (4순위)** Sprint cycle CLI helper (sprint dir 자동 scaffold).
- **#5 (5순위)** decisions/ ADR mini 자동 생성 helper.
- **#3 (6순위)** uninstall.sh 시나리오 보강 (clean removal + .gitignore marker + 4 옵션).
- **#7 (7순위)** 신규 어댑터 (cursor / windsurf / aider).
- **#8 (8순위)** solon-mvp doctor 진단 스크립트 (.sfs-local 무결성 + VERSION drift + events.jsonl validity).
- **(a2)** Phase 1 킥오프 실전 — **사용자 본인이 D-day 2026-04-27 (월) 에 본인 Mac 에서 직접 실행**. Claude 세션 자동 진행 대상 아님 (회사 IP 도메인이라 raw-internal).
- **(b)** verify-w0.sh 후속 TODO (F-04 2건) — raw-internal, MVP 배포 대상 아님.
- **(c)** sync/cut-release 자동화 (R-D1, 0.4.0-mvp 예약).
- **(d)** upgrade.sh / uninstall.sh sandbox dry-run 추가 검증 (WU-21 시 미실시).
- **(e)** 11~18번째 세션 retrospective 실체화 (누적 8건).
- **(f)** HANDOFF mutex_state_schema 재sync.
- **(g)** W10 결정 세션 — cross-ref-audit §4 #14/#18/#19.
- **(h)** WU-16b 확장 이관.
- **(i)** resume-session-recover.sh (P-03 후속, 0.4.0-mvp 예약).

**참고**: D-day (2026-04-27 월) 는 사용자 본인 작업 일정이지 Claude 세션이 자동 진행할 작업 아님. (a2) 로 분리.

---

## ④ Artifacts (18번째 세션 현 시점 인벤토리)

| 산출물 | 경로 | 상태 |
|--------|------|:-:|
| **sprints/WU-22.md** | — | ✨ **19번째 세션 신설** — MVP next-feature roadmap & sequencing plan, 8 후보 1-pager + α/β/γ 옵션, status: in_progress (사용자 결정 대기) |
| **sprints/WU-21.md** | — | ✅ 18번째 세션 신설 — Phase 1 킥오프 dry-run PASS, F-01~F-04 findings, status: done (final_sha TBD) |
| **PROGRESS.md (본 파일)** | — | ✨ **18번째 세션 덮어쓰기** — resume_hint v5 (sandbox-dry-run 규율 + next default = Phase 1 실전) · released_history rolling (18th last) · scheduled_task_log 18th entry |
| scripts/resume-session-check.sh | v0.3 | ✅ 17번째 세션 강화 (check #7 drift) |
| scripts/append-scheduled-task-log.sh | v0.1 | ✅ 17번째 세션 신설 |
| phase1-mvp-templates/setup-w0.sh | — | ✅ **WU-21 sandbox 검증 통과** — env 검증 3건 + 의존 파일 4건 + Step 4-8 시뮬 OK |
| phase1-mvp-templates/verify-w0.sh | — | ⚠️ **WU-21 결과: setup-w0.sh 출력에는 PASS + WARN 3**, **install.sh 출력에는 FAIL 2** (false-positive). F-04 후속 TODO |
| ~/workspace/solon-mvp/install.sh v0.2.4-mvp | — | ✅ **WU-21 sandbox PASS** — 멱등성 OK, IP 경계 OK |
| learning-logs/2026-05/P-01~P-03 | — | ✅ all resolved |
| HANDOFF-next-session.md | — | ✅ 17번째 세션 sync |
| sprints/_INDEX.md | — | ⏳ WU-21 row 추가 대기 (다음 WU 에서 동시 처리) |
| sprints/WU-{17,18,19,20,20.1}.md | — | ✅ all status: done |
| sessions/_INDEX.md | — | ⏳ 11~18번째 retrospective 미작성 누적 8건 |
| CLAUDE.md v1.17 | `2026-04-19-sfs-v0.4/CLAUDE.md` | ✅ §1 13 규율 |
| PHASE1-MVP-QUICK-START.md | — | ✅ **D-day 차단 요소 없음 확인** (WU-21) |
| solon-mvp-dist/ | — | ✅ v0.2.4-mvp stable checksum 일치 |

## 운영 규칙 (18번째 세션 추가)

1. 다음 세션 진입 시 **step 0: `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh`** 필수.
2. §1.12 mutex 프로토콜 (claim → heartbeat → release).
3. 매 WU 경계에서 PROGRESS.md 덮어쓰기 + commit.
4. **sandbox dry-run 은 /tmp/ 한정** — 사용자 ~/workspace 와 GitHub 건드리지 않음 (18번째 세션 WU-21 확립 원칙).
5. scheduled task 모드 = 새 WU 착수 금지, cleanup 만.

---

**다음 세션 진입 체크리스트 (v1.0, 18번째 세션 반영)**:

1. `CLAUDE.md §1` + `§1.12` + `§1.13` 읽기 (13 규율).
2. `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh` 실행.
3. `PROGRESS.md` frontmatter `current_wu_owner` 확인 → self claim.
4. `PROGRESS.md` 본문 `① Just-Finished` + `③ Next` 확인 — (a) Phase 1 실전 실행이 default.
5. `git status` + `git rev-list --count origin/main..HEAD` 로 ahead 현황 확인.
   - 18번째 세션 종료 시점 로컬 ahead 예상: **6** (2709fcf + 5d4c6c6 + 87b60ff + 17th snapshot + WU-21 + 18th snapshot). 사용자 push 후 0.
6. 사용자 첫 발화 매칭 → `resume_hint.default_action` 경로.
7. **D-day (2026-04-27 월) 임박 — 오늘 기준 갱신 필요**. Phase 1 실전 실행 시 사용자 Mac 에서 QUICK-START.md §2 runbook.
8. WU 완료 시 본 PROGRESS.md 즉시 덮어쓰기 + commit.
