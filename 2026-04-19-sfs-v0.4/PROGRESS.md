---
doc_id: sfs-v0.4-progress-live
title: "PROGRESS — live single-frame snapshot (덮어쓰기 방식)"
version: live
last_overwrite: 2026-04-25T23:14:12+09:00
session: "22번째 세션 `adoring-trusting-feynman` (user-active) — **정상 종료**. 사용자 §7 결정 7항목 일괄 수신 + 8 step batch 완료 (gates.md 신설 + CLAUDE.md §1.14 ≤200 lines 메타 규칙 + §14 분리 + WU-23 §7 resolved + WU-30 신설 + WU-24 entry). 사용자 'A ㄱㄱ' confirm 후 step 1~8 진행. 사용자 '본 세션 종료' 명시 → mutex 자연 release. 다음 세션 = 23번째, default = WU-24 step-1 entry (실 bash 구현). push 는 §1.5 사용자 터미널."
current_wu: WU-24   # 22nd entry 까지만 (frontmatter + 구현 spec). 실 bash 구현은 23번째 세션
current_wu_path: 2026-04-19-sfs-v0.4/sprints/WU-24.md
current_wu_owner: null   # 22nd 세션 정상 종료 release (2026-04-25T23:14:12+09:00). 23번째 진입 시 §1.12 self claim.
released_history:
  last_owner: adoring-trusting-feynman
  last_claimed_at: 2026-04-25T22:47:00+09:00
  last_released_at: 2026-04-25T23:14:12+09:00   # 사용자 명시 '본 세션 종료' → 자연 release
  last_reason: "22번째 세션 user-active. 21st mutex 자연 release + 22nd self claim 후 사용자 §7 결정 7항목 일괄 수신 + 8 step batch 일괄 진행. gates.md 신설 (sfs CLI 7-gate enum SSoT) + CLAUDE.md §1.14 ≤200 lines 메타 규칙 신설 + §14 → solon-status-report.md 분리 (CLAUDE.md 214→167 lines, P-06 후보) + WU-23 §7 7항목 resolved (WU22-D3~D9 frontmatter) + WU-30 (F-04 fix) 신설 + WU-24 (#1 sfs slash 구현 part 1) entry 준비 (frontmatter + 구현 spec). 사용자 명시 '본 세션 종료' → 자연 release. 다음 세션 default = WU-24 step-1 (실 bash 구현). push 사용자 터미널."
  last_final_commits: [bf180de, a35b669, 7be62b4, d1189c6, c1f1fa3, b990b8b, 7923336]   # 8 step batch 7 wip commits + 본 release commit 후속
  prior_owner: trusting-stoic-archimedes
  prior_claimed_at: 2026-04-25T17:37:22+09:00
  prior_released_at: 2026-04-25T22:47:00+09:00   # 22번째 진입 시 자연 release (mode=user-active-deferred 4시간 위임 시간 도과 + 사용자 복귀)
  prior_reason: "21번째 세션 user-active-deferred (사용자 4시간 운동 부재 자율 작업 위임). 3-agent 합의 protocol 도입 + .claude/agents/ 페르소나 alt B 등록 + WU-23 신설/close (V-1 vote PASS effective 3/3, 6 명령 contract spec 확정) + cd41dff cleanup + P-04/P-05 후보 + HANDOFF v3.5→v3.6 sync. 22번째 진입 시 사용자 §7 결정 7항목 수신 후 자연 release."
  prior_final_commits: [a66cf2e, f11dd4f, 1e0e6f1, 9f146e3, 449c4a6, 7ca88b0, a9dc7a5, 8215c43]   # WU-22 close (20th 작업 backfill) + 21st 자율 작업 commits 7건
  older_owner: epic-brave-galileo
  older_claimed_at: 2026-04-25T10:47:00+09:00
  older_released_at: 2026-04-25T17:37:22+09:00   # 21번째 진입 시 자연 release (자발 release 안 했지만 21번째가 정상 claim)
  older_reason: "20번째 세션 user-active, takeover. 19번째 hang 을 stale-mutex takeover. 사용자 'ㄴㄴ 이어받아서 바로 진행 ㄱㄱ' 명시 confirm 후 §1.12 충족. WU-22 close (β themed-bundles 채택) + sprints/_INDEX.md WU-21/WU-22 row 동시 추가 + §7 takeover 기록 (P-04 learning pattern 표준)."
  older_final_commits: [a66cf2e]   # WU-22 close commit
  oldest_owner: eager-elegant-bell
  oldest_claimed_at: 2026-04-25T09:48:00+09:00
  oldest_released_at: 2026-04-25T10:47:00+09:00   # 20번째 takeover 시점. 자발 release 안 함, hang.
  oldest_reason: "19번째 세션 user-active. WU-22 신설 + 8후보 1-pager + α/β/γ 그루핑 (wip 3471c12). 사용자 결정 β 수신 이후 hang (약 56분, 파일 수정 0 / 커밋 0). 20번째 세션이 stale takeover. P-04 learning pattern 후보."
  oldest_final_commits: [3471c12]   # 19번째 wip 만
  # 18번째 (confident-loving-ride) 가 rolling N=4 에서 drop — scheduled_task_log 에 trace 유지 (09:45 + 09:55 entries)
  # 17번째 (admiring-fervent-dijkstra), 16번째 (nice-kind-babbage), 15번째 (admiring-nice-faraday) 도 trace 유지

# ── scheduled_task_log (16번째 세션 신설, 17번째 helper 화) ──────────
# Cowork scheduled_task hourly auto-resume 의 explicit trace. rolling N=20.
# 필드: ts (ISO8601 +09:00) · codename · check_exit · action · ahead_delta
# 18번째 세션은 user-active (scheduled 아님) 이지만 trace 연속성 위해 한 줄 append.
scheduled_task_log:
  - ts: 2026-04-25T22:50:01+09:00
    codename: adoring-trusting-feynman
    check_exit: 0
    action: "22번째 세션 user-active. 21st mutex 자연 release (mode=user-active-deferred 4시간 위임 종료 + 사용자 복귀) + 22nd self claim. 사용자 §7 결정 7항목 일괄 수신 (gates 별도 파일 + CLAUDE.md ≤200 lines 메타 규칙 + ISO week + 파일 준비만 + 하이브리드 ADR + auto commit + F-04 정규식+검증기 분리). 8 step 일괄 진행 시작."
    ahead_delta: "+0 진입"
  - ts: 2026-04-25T18:00:16+09:00
    codename: trusting-stoic-archimedes
    check_exit: 16
    action: "21번째 세션 user-active-deferred (사용자 4시간 자율 작업 위임). 3-agent 합의 protocol 도입 (CEO+CTO+CPO 동등 2/3 vote, fallback A general-purpose 호출). .claude/agents/{generator,evaluator,planner}.md 페르소나 등록 (alt B mid-session reload 안 됨 → fallback A). a66cf2e backfill + WU-23 신설/close (V-1 vote PASS, 3 conditions applied) + final_sha 1e0e6f1 backfill. cd41dff false-positive narrative cleanup (single-quote → backtick escape 1 line 정정). §7 사용자 복귀 시 결정 대기 6항목 정리. FUSE bypass 발동 (lock stale 0-bytes)."
    ahead_delta: "+3 (f11dd4f + 1e0e6f1 + 9f146e3)"
  - ts: 2026-04-25T10:47:00+09:00
    codename: epic-brave-galileo
    check_exit: 15   # bracket_sha_unrealized:1:cd41dff (16번째 narrative false-positive, 계속 누적 — 후속 cleanup 독립 WU 로 분리 필요)
    action: "20번째 세션 user-active, takeover. 19번째 eager-elegant-bell hang (β 수신 후 56분 정지) 을 stale-mutex takeover (TTL 15분 × 3.7배). 사용자 'ㄴㄴ 이어받아서 바로 진행 ㄱㄱ' 로 §1.12 확인 충족. WU-22 §3 β (themed-bundles) 채택 문서 반영 + §5 체크리스트 완결 + §7 takeover 기록 + sprints/_INDEX.md (WU-21/WU-22 2 row 동시 추가) + 본 PROGRESS 덮어쓰기. WU-22 close."
    ahead_delta: "+1 (WU-22 close commit = a66cf2e, 21번째 세션 backfill 완료)"
  - ts: 2026-04-25T09:48:00+09:00
    codename: eager-elegant-bell
    check_exit: 15   # bracket_sha_unrealized:1:cd41dff (16번째 narrative false-positive, 후속 cleanup TODO)
    action: "19번째 세션 user-active. 사용자 우선순위 #1→#2→#4→#6→#5→#3→#7→#8 확정. WU-22 신설 (8후보 1-pager + 의존성 그래프 + release 그루핑 α/β/γ). 사용자 β 결정 수신 후 hang (파일 수정 0 / 커밋 0 / PROGRESS 덮어쓰기 0). 20번째 세션이 takeover 하여 완결."
    ahead_delta: "+1 실제 (wip 3471c12 만). 결정 반영은 20번째에서."
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
  - "sprints/WU-22.md (**19번째 open / 20번째 close** — 8후보 1-pager + 의존성 그래프 + β release grouping 채택 + §7 takeover 기록)"
  - "sprints/WU-21.md (18번째 세션 신설 — Phase 1 킥오프 dry-run PASS, F-01~F-04 findings)"
  - "phase1-mvp-templates/setup-w0.sh + verify-w0.sh (dry-run 결과로 동작 확인 완료)"
  - "~/workspace/solon-mvp/install.sh v0.2.4-mvp (dry-run sandbox PASS)"
  - "learning-logs/2026-05/P-03 (resolved), P-04 후보 (session-hang takeover, 20번째 세션 패턴)"
  - "sprints/_INDEX.md (**20번째 세션 갱신** — WU-21 cd94f65 + WU-22 TBD_20TH row 동시 추가)"
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
  - "20번째 이후: session-hang 감지 시 stale-mutex takeover 는 사용자 명시 confirm 필요 (§1.12), WU 문서 안에 §N takeover 기록 섹션 남김, P-04 learning pattern 후보"
resume_hint:
  purpose: "23번째 세션이 본 PROGRESS.md 1개만 읽고 즉시 WU-24 step-1 entry 가능 + P-03 방지"
  trigger_positive: [ㄱㄱ, 고, ㅇㅋ, ok, OK, 시작, 가자, ㅇㅇ, 진행, go, Go, start]
  trigger_negative: [ㄴㄴ, 잠깐, stop, 아니, 중단, 다른거, 다른, no]
  default_action: |
    0. **scripts/resume-session-check.sh 실행 (v0.3)** — exit 0 예상 (cd41dff false-positive narrative 는 21st cleanup, 22nd 가 commit 정책 정합 유지).
    1. **§1.12 mutex**: current_wu_owner null 확인 (22nd 세션 종료 시 release). 22nd 는 user-active 정상 종료 가정.
    2. **git status** + `git rev-list --count origin/main..HEAD` 확인. 22nd 세션 종료 예상 ahead = **14+** (8 step batch commits 7건 + 최종 PROGRESS snapshot). 사용자 push 안 했다면 사용자 터미널에서 push 필요.
    3. **default = WU-24 (#1 sfs slash 구현 part 1) step-1 entry**. WU-24.md §5 체크리스트 row 5 부터 진행:
       - sfs-common.sh 실 작성 (helper 함수 시그니처는 WU-24 §3 정의)
       - sfs-status.sh 실 작성 (WU-24 §1)
       - sfs-start.sh 실 작성 (WU-24 §2)
       - sprint-templates/{plan,log,review,retro}.md 4 신설
       - .claude/commands/sfs.md adapter dispatch 추가
       - VERSION + CHANGELOG 0.3.0-mvp 예약 entry
       - dry-run sandbox (/tmp/wu24-dry/) 검증
    3'. (R-D1 정합) 본 작업은 `solon-mvp-dist/templates/` 안 dev staging only. stable 동기화는 0.3.0-mvp release cut 타이밍.
    3''. 대안 메뉴 (원칙 2, 사용자 다른 길 선택 시):
       (a) **WU-24 step-1 entry** (default, 위 3).
       (b) **WU-30 (F-04 fix) 진행** — 이 부분도 frontmatter 만 신설된 상태, 실 정규식 fix + 검증기 분리 구현.
       (c) **WU-25 part 2 entry** (`/sfs plan` + `/sfs review`) — gates.md §3 사용. WU-24 끝나야 자연스럽지만 병렬 가능.
       (d) **Claude Code 재시작** (P-05 fallback A 졸업, native subagent 호출 활성).
       (e) **push** (사용자 터미널, §1.5).
       (f) Phase 1 킥오프 실전 = D-day 2026-04-27 월 (오늘 기준 D-2). 사용자 본인 Mac 직접.
       (g) sync/cut-release 자동화 (R-D1, 0.4.0-mvp 예약).
       (h) 11~22번째 세션 retrospective 실체화 (누적 12건, 22번째 포함).
       (i) HANDOFF mutex_state_schema 재sync + P-04/P-05/P-06 learning pattern 실체화.
       (j) `.visibility-rules.yaml` scope 확장 (`.claude/agents/**` + `gates.md` + `solon-status-report.md`).
       (k) resume-session-recover.sh (P-03 후속 자동화).
    4. 사용자 번호 지정 / 자연어 confirm 한 마디 → 해당 경로.
    5. **scheduled task auto-resume 이면** — step 3 메뉴 skip + staged/TBD/`<sha>`/stale-mutex cleanup 만 + snapshot + mutex release + helper 호출.
  on_negative: |
    "현 상태만 요약 보고 후 대기" — 22nd 세션 8 step batch 완료. WU-23 §7 사용자 결정 7항목 모두 resolved.
    WU-24 (current_wu, pending) frontmatter + 구현 spec 작성 완료, 실 bash 구현 대기. WU-30 (pending) frontmatter only.
    git ahead = 14 예상 (22nd 세션 종료 시점), 활성 WU 2 (WU-24 + WU-30).
  on_ambiguous: "1-line clarifying Q: 'WU-24 step-1 entry (sfs-common.sh + sfs-status.sh + sfs-start.sh 실 작성) 으로 갈까, 아니면 push 먼저?'"
  safety_locks:
    - "원칙 2 (self-validation-forbidden): A/B/C 의미 결정 자동 실행 금지"
    - "§1.5: git push 자동 실행 금지 — 사용자 터미널에서만 (commit auto, push manual)"
    - "destructive git 금지"
    - "§1.6 FUSE bypass 는 자동 적용 허용"
    - "PROGRESS.md 덮어쓰기는 자동 허용"
    - "§1.12 Session mutex: 진입 시 current_wu_owner null 확인 → claim"
    - "§1.13 R-D1: dev-first, stable hotfix 는 같은 세션 back-port"
    - "§1.14 (22nd 신설): CLAUDE.md ≤200 lines 항상 유지 — 초과 시 부록 § 분리 + link 1줄 대체"
    - "scheduled task 모드: 사용자 부재 → 새 WU 착수 금지"
    - "15번째 P-03: staged diff 감지 → 세션 A 의도 보존"
    - "16번째 check #6: `<sha>` angle-bracket 감지 → backfill"
    - "17번째 helper: scheduled_task_log append helper 사용"
    - "17번째 check #7: drift 90분 초과 시 exit 16"
    - "18번째 sandbox 원칙: dry-run 은 /tmp/ 한정, 사용자 ~/workspace 와 GitHub 건드리지 않음"
    - "18번째 handoff (09:55 갱신): MVP 0.2.4 초기틀 확정 → 다음 default = MVP next-feature 사이클"
    - "20번째 takeover 원칙: session-hang 감지 시 사용자 명시 confirm 필요"
    - "21번째 user-active-deferred mode: 사용자 명시 부재 + 자율 작업 위임 시 mutex mode=user-active-deferred + takeover 보호 비활성화"
    - "22번째 batch 진행 원칙: 사용자 §7 일괄 결정 7항목 + 8 step batch 일괄 진행. minimal cleanup default 적용 + step 별 wip commit (FUSE bypass 자동) + 매 step PROGRESS heartbeat 갱신"
  version: 8   # v1 (14th) → v7 (20th) → v8 (22nd: §7 7항목 일괄 resolved + WU-24 entry default + §1.14 메타 규칙 + auto commit policy + alt B native 활성 가이드)
---

# PROGRESS — live snapshot (22번째 세션 adoring-trusting-feynman, 8 step batch 완료 / WU-24 current)

> 🚨 **본 파일 최우선 진입.** mutex **claimed by adoring-trusting-feynman** (mode=user-active). 21st (`trusting-stoic-archimedes`) 자연 release + 22nd self claim 완료. 사용자 §7 결정 7항목 일괄 수신 + 8 step batch 완료.
> **22nd 핵심**: gates.md 신설 (sfs CLI gate enum SSoT, SSoT pointer = 05-gate-framework.md) + CLAUDE.md §1.14 ≤200 lines 메타 규칙 신설 + §14 → solon-status-report.md 분리 (CLAUDE.md 214→167 lines) + WU-23 §7 7항목 resolved (decision_points WU22-D3~D9) + WU-30 (F-04 fix) 신설 + WU-24 (#1 sfs slash 구현 part 1) entry 준비 (frontmatter + 구현 spec).
> **current_wu = WU-24** — frontmatter + 구현 spec only, 실 bash 구현 (sfs-common.sh + sfs-status.sh + sfs-start.sh + sprint-templates 4 + adapter dispatch) 다음 세션.
> release 로드맵 (β bundle): 0.3.0-mvp (#1+#4+#6) → 0.3.x patch (#5) → 0.4.0-mvp (#2+#3) → 0.5.0-mvp (#7) → 0.6.0-mvp (#8).
> **22nd 세션 ahead = 14** (8 step batch commits 7건 + 본 PROGRESS 최종). 사용자 push 는 §1.5 정합 사용자 터미널.

---

## ① Just-Finished

### 22번째 세션 (adoring-trusting-feynman, user-active, 2026-04-25 22:47 KST → 23:00 KST, 8 step batch 완료)

**사용자 발화**: "22번째 세션 진행해야되지?" → 22nd 진입 + 21st mutex 자연 release. 이어 사용자 §7 결정 7항목 일괄 수신 ("A ㄱㄱ" = 8 step batch 일괄 진행 confirm).

**8 step batch 결과** (commits: bf180de → b990b8b, 7건 wip + 본 최종 PROGRESS):

- **Step 1** (`bf180de`): 21st mutex 자연 release (mode=user-active-deferred 4시간 위임 시간 도과 + 사용자 복귀) + 22nd self claim + scheduled_task_log 22nd entry append (helper, kept 10 entries) + released_history rolling (17th+16th drop, 21st last 신규 + 20th prior recovery 21st 누락 보정).
- **Step 2+3** (`a35b669`): **CLAUDE.md §1.14 ≤200 lines 메타 규칙 신설** (사용자 결정 1번 부속) + **§14 (Solon Status Report) → `solon-status-report.md` 분리** (의미 변경 0). CLAUDE.md 214 → **167 lines** (≤200 충족, 33 lines 여유). solon-status-report.md = 85 lines. P-06 후보 패턴.
- **Step 4** (`7be62b4`): **`gates.md` 신설** (사용자 결정 1번 (c) 별도 spec 파일). 7-gate enum (G-1 + G0 + G1~G5) + verdict enum (pass/partial/fail, G3 만 binary) + sfs CLI 매핑 + WU-23 §1.4 draft 정정 기록 (valid `G0/G1/G2/G4` → `G-1, G0, G1, G2, G3, G4, G5` 7-gate). SSoT pointer = `05-gate-framework.md` (1원 유지).
- **Step 5** (`d1189c6`): WU-23 §7 일괄 resolved 마킹 — frontmatter `decision_points` WU22-D3~D9 7건 추가 (사용자 결정 + impacts 명시). §7.4 처리 방법 update (✅ 22nd 일괄 수행 완료). §7.6 신설 = 22nd 결정 인덱스 dashboard. learning_patterns_emitted P-06 후보 추가.
- **Step 6** (`c1f1fa3`): **WU-30 신설** (F-04 verify-w0.sh fix) — frontmatter only + 작업 plan 본문 §0~§5. 사용자 결정 WU22-D9 사전 적용: §1 7.5.1 (i) `[A-Z]{2,}` minimal regex + §2 7.5.2 (b) 두 검증기 분리 (`verify-install.sh` 신설 + `verify-w0.sh` setup-w0 전용). R-D1 dev-first (phase1-mvp-templates/), 실 fix 다음 세션 또는 사용자 컨펌 후.
- **Step 7** (`b990b8b`): **WU-24 신설** (#1 sfs slash 구현 part 1) — frontmatter + 구현 spec §0~§6. 사용자 결정 WU22-D3~D5 사전 적용: §1 `/sfs status` (output `sprint <id> · WU <wu_id> · gate <last>:<verdict> · ahead <N> · last_event <ISO8601>` + `--color=auto/always/never` flag) + §2 `/sfs start` (sprint-id pattern `<YYYY-Wxx>-sprint-<N>` ISO week + 4 templates 신설) + §3 `sfs-common.sh` 함수 시그니처 정의. R-D1 dev-first (`solon-mvp-dist/templates/`).
- **Step 8** (본 PROGRESS): sprints/_INDEX.md frontmatter `updated` + 활성 WU 섹션 갱신 (WU-24 + WU-30 row 추가) + 본 PROGRESS.md ①~④ 22nd 결과 반영 + last_heartbeat 갱신 (22:47 → 23:00 KST) + resume_hint v8 (다음 세션 default = WU-24 step-1 entry, alt B native subagent 활성 가이드, §1.14 safety_lock 추가).

**규율 준수**: §1.3 self-validation (의미 결정은 사용자 7항목 모두 사전 수신) · §1.4 Option β default 적용 (3번 ISO week, 5번 하이브리드 ADR 등) · §1.5 push 금지 (사용자 터미널) · §1.6 FUSE bypass (step 1 commit 시 발동, lock stale 0-bytes) · §1.8 매 step PROGRESS heartbeat 갱신 + wip commit · §1.12 mutex (claim, mode=user-active) · §1.13 R-D1 (`solon-mvp-dist/` + `phase1-mvp-templates/` 안 dev staging only) · §1.14 ≤200 lines (본 22nd 신설, 즉시 자체 적용).

### 21번째 세션 (trusting-stoic-archimedes, user-active-deferred, 자율 작업 mode, 2026-04-25 17:37 KST~ 진행 중)

**사용자 운동 부재 4시간 자율 작업 위임. 메시지 verbatim**: "내가 앞으로 4시간동안 운동을 하고 올거라서 그동안 작업 계속 이어서 네 판단하에 쭉 진행해줘 ... sub agent 2개 evaluator역할과, generator역할 셋이서 리뷰를 하고, 결정전에 3명중 2명이상이 동의 할때만 진행하도록".

**핵심 산출**:

- **3-agent 합의 protocol 도입** — CEO (Claude main session) + CTO (`.claude/agents/generator.md`) + CPO (`.claude/agents/evaluator.md`) 동등 권한 + 2/3 다수결. Q1~Q7 사용자 답변 (default + Q2 alt B) 적용.
- **페르소나 alt B 등록** — `agent_architect/.claude/agents/{generator,evaluator,planner}.md` 신설 (Solon docset 도메인 override). Product Image Studio 의 Kotlin/Python/Gemini/Playwright/이미지 5축 → Solon 5축 (fact/rule/SSoT/risk/repro). C-Level 동등 권한 + 2/3 다수결 + max 1 retry round + 본부 leaf 호출 안 함.
- **alt B mid-session reload 미작동 발견** — Claude Code agent loader 가 startup-only. fallback A (general-purpose + Read .claude/agents/<persona>.md) 자동 전환. P-05 후보 (학습 패턴, agent_loader_startup_only). 사용자 복귀 후 Claude Code 재시작 시 native alt B 활성 예상.
- **`TBD_20TH_SNAPSHOT` → `a66cf2e` backfill** — WU-22.md frontmatter (status: done 의 final_sha) + §5 체크리스트 + sprints/_INDEX.md WU-22 row + PROGRESS released_history.last_final_commits + scheduled_task_log 21st entry. P-03 예방 완료.
- **WU-23 open + close** — `sprints/WU-23.md` 신설 (frontmatter + §0~§7), §1 6 명령 minimal contract spec (status/start/plan/review/decision/retro) 1차 draft (CEO 작성), §3 V-1 vote 진행 (CEO CONDITIONAL 88 + CTO CONDITIONAL 83 + CPO CONDITIONAL 90 = effective 3/3 PASS), 3 conditions 적용 (§1.4 gate id 보강 + §2 naming pattern + §7 신설), close (status: done, session_closed=trusting-stoic-archimedes, final_sha=`1e0e6f1` backfill 완료).
- **사용자 복귀 시 결정 대기 6항목** (WU-23 §7) — (1) gate id schema 정의 위치 (block) / (2-6) 출력 포맷·sprint-id auto naming·editor auto-launch·mini-ADR 5섹션·`--close` auto commit (product decisions). 사용자 복귀 시 일괄 처리.
- **§1.6 FUSE bypass 발동** — `f11dd4f` commit 시 `.git/index.lock` 충돌, `cp -a .git /tmp/solon-git-1777106879/` → 작업 → rsync back 패턴으로 우회. rsync 시 lock 파일 unlink 만 실패 (0 bytes 빈 파일, 영향 0).
- **규율 준수**: §1.3 self-validation (의미 결정은 3-agent vote 또는 사용자 복귀 시 escalate) · §1.5 push 금지 (사용자 복귀 후) · §1.6 FUSE bypass 적용 · §1.7 escalation 6항목 §7 정리 · §1.8 매 step PROGRESS 갱신 · §1.12 mutex (claim, mode=user-active-deferred) · §1.13 R-D1 (`~/workspace/solon-mvp/` read-only).

### 20번째 세션 (epic-brave-galileo, user-active, takeover, 2026-04-25 10:47 KST~)

**사용자 보고 요청 "이전 세션에서 β 작업하라고 했는데 어디까지 됏는지 확인 가능?? 펜딩이 50분 넘게 돌고 있어서" → 상태 점검 → 진척 0 확인 → 사용자 "ㄴㄴ 이어받아서 바로 진행 ㄱㄱ" → stale-mutex takeover 승인 → WU-22 close.**

- **hang 진단** — git log 에서 마지막 커밋 3471c12 (09:51 KST, brainstorm wip 만). 이후 56분간 파일 수정 0 / 커밋 0 / PROGRESS 덮어쓰기 0 확인. WU-22.md §5 체크리스트도 `[ ] 사용자 결정 받기 (WU22-D1)` 미체크 → 19번째 eager-elegant-bell 가 β 수신 직후 hang.
- **stale-mutex takeover** — TTL 15분 × 3.7배 초과. §1.12 에 따라 사용자 명시 confirm 필요 → "ㄴㄴ 이어받아서 바로 진행 ㄱㄱ" 로 요건 충족.
- **WU-22.md 편집** — frontmatter (status: done, closed_at, session_closed=epic-brave-galileo, final_sha=TBD_20TH_SNAPSHOT, decision_points.WU22-D1.resolved=β) + §3 β CHOSEN 표기 + §3 β 확장 (sprint roadmap WU-23~29 추가) + §5 체크리스트 완결 + §6 close 반영 + **§7 takeover 기록** (hang cause + takeover 근거 + 작업 + P-04 learning pattern 후보).
- **sprints/_INDEX.md 편집** — frontmatter updated 갱신 + 활성 WU 섹션 "현재 없음 (WU-23 entry 준비)" + **WU-21 (cd94f65) + WU-22 (TBD_20TH_SNAPSHOT) row 동시 추가** (WU-21 은 18번째 세션부터 밀려있던 미처리).
- **PROGRESS.md 덮어쓰기** — frontmatter last_overwrite 갱신 + session narrative 갱신 + current_wu/current_wu_owner=null + released_history rolling (19번째 eager-elegant-bell 을 last, 15번째 admiring-nice-faraday drop) + scheduled_task_log 20th entry prepend + companions 갱신 + rules 20번째 takeover 원칙 추가 + resume_hint default_action 재작성 (새 default=WU-23) + safety_locks + version 7 + 본문 ①~④ 덮어쓰기.
- **resume-check 결과** — exit 15 (`<cd41dff>` narrative false-positive, 알려진 사항. 독립 cleanup WU 로 분리 필요).
- **규율 준수**: §1.3 원칙 2 (β 는 사용자 명시 결정, Claude 는 반영만) · §1.5 push 는 사용자 터미널 · §1.8 매 step PROGRESS 갱신 · §1.12 mutex (stale takeover 사용자 confirm) · §1.13 R-D1 (solon-mvp/ read-only 유지).

### 19번째 세션 (eager-elegant-bell, user-active, 2026-04-25 09:48→10:47 KST, **hang + forced takeover**)

- **WU-22 신설** — `sprints/WU-22.md` (frontmatter + 본문 §1~§6). 8 후보 1-pager + 의존성 그래프 + release 그루핑 옵션 α/β/γ 제시. wip commit 3471c12 (09:51 KST).
- **사용자 우선순위 확정 (10:00 KST)**: #1→#2→#4→#6→#5→#3→#7→#8.
- **WU22-D1 β 결정 수신**: 사용자 "β" 응답 수신.
- **⚠️ hang**: β 응답 이후 약 56분간 진척 0 (파일 수정 0, 커밋 0, PROGRESS 덮어쓰기 0). → 20번째 세션이 takeover 하여 완결.
- **mutex**: 09:48 claim → 자발 release 없이 20번째 takeover 로 expired 처리 (released_history.last).

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

**current_wu = WU-24** — #1 sfs slash 구현 part 1 (`/sfs status` + `/sfs start`). frontmatter + 구현 spec (§0~§6) 작성 완료. 실 bash 구현 (§5 체크리스트 row 5~10): sfs-common.sh / sfs-status.sh / sfs-start.sh / sprint-templates {plan,log,review,retro}.md / adapter dispatch / VERSION+CHANGELOG entry. 다음 세션 또는 사용자 컨펌 후 본 세션 진행 가능.

**WU-30** (F-04 fix, pending) — frontmatter + 작업 plan §0~§5 only. 실 정규식 fix (`[A-Z]{2,}`) + 검증기 분리 (`verify-install.sh` 신설) 다음 세션.

mutex: **claimed by adoring-trusting-feynman** (mode=user-active). 22nd 8 step batch 완료 시점. 사용자 복귀 시 자연 release 판단.

---

## ③ Next

> **22nd 8 step batch 완료**. WU-23 §7 사용자 결정 7항목 모두 resolved. WU-24 = current_wu, WU-30 = pending. 사용자 답변 대기 0건.

### 3.1 사용자 답변 대기 — 0건

22nd 세션 진입 시 §7 7항목 일괄 수신 완료 (WU22-D3~D9 frontmatter resolved). 상세 = `sprints/WU-23.md §7.6` 인덱스 표.

### 3.2 다음 세션 우선순위

1. **WU-24 step-1 entry** (default) — `sfs-common.sh` + `sfs-status.sh` + `sfs-start.sh` 실 작성 + sprint-templates 4 신설 + `.claude/commands/sfs.md` adapter dispatch + VERSION/CHANGELOG 0.3.0-mvp 예약 + dry-run sandbox (`/tmp/wu24-dry/`).
2. **push** (§1.5) — 사용자 터미널 `git push origin main` (22nd ahead 14, 누적 commits).
3. **Claude Code 재시작** — P-05 fallback A 졸업, native `subagent_type=generator/evaluator/planner` 활성. V-2 부터 native vote 시도.
4. **WU-30 진행** — F-04 정규식 fix (`[A-Z]{2,}` minimal) + 검증기 분리 (`verify-install.sh` 신설). WU-24 와 병렬 가능.

### 3.3 미해결 후속 (non-block, 정보)

- (a) Phase 1 킥오프 D-day 2026-04-27 월 (D-2 기준). 사용자 본인 Mac 직접 진행 (Claude 세션 자동 X).
- (b) sync/cut-release 자동화 (R-D1, 0.4.0-mvp 예약) — `scripts/sync-stable-to-dev.sh` + `scripts/cut-release.sh`.
- (c) 11~22번째 세션 retrospective 실체화 (누적 12건, 22nd 포함).
- (d) HANDOFF-next-session.md mutex_state_schema 재sync (22nd 결정 7항목 + WU-24/WU-30 entry 반영).
- (e) P-04 / P-05 / P-06 learning logs 실체화 (`learning-logs/2026-05/`):
  - P-04 = session-hang takeover (WU-22 §7 표준)
  - P-05 = agent-loader-startup-only (Claude Code mid-session reload 안 됨, fallback A 패턴)
  - P-06 = claude-md-line-limit-meta-rule (22nd 신설, §1.14 + §14 분리 사례)
- (f) `.visibility-rules.yaml` scope 확장 — `.claude/agents/**` + `gates.md` + `solon-status-report.md` + `agent_architect/` 루트 포함.
- (g) W10 결정 세션 — `cross-ref-audit.md §4` #14/#18/#19 (22nd 미접촉).
- (h) WU-16b 확장 이관.
- (i) resume-session-recover.sh (P-03 후속 자동화, 0.4.0-mvp 예약).
- (j) WU-25 entry (#1 sfs slash 구현 part 2 = `/sfs plan` + `/sfs review`) — gates.md §3 valid enum 사용.
- (k) WU-26 entry (#1 sfs slash 구현 part 3 = `/sfs decision` + `/sfs retro`) — 하이브리드 mini-ADR template + `--close` auto commit (push 는 §1.5 수동).
- (l) WU-27 (#4 events.jsonl schema 표준화) + WU-28 (#6 Sprint cycle CLI helper) — 0.3.0-mvp 번들 마무리.
- (m) WU-29 (#5 ADR helper) — 0.3.x patch 시 분리.

---

## ④ Artifacts (22번째 세션 8 step batch 종료 시점)

### 4.1 22nd 신설/갱신 산출물

| 산출물 | 경로 | 상태 / sha |
|--------|------|:-:|
| **gates.md** | `2026-04-19-sfs-v0.4/gates.md` | ✨ **22nd 신설** (`7be62b4`) — 7-gate enum (G-1+G0+G1~G5) + verdict enum (pass/partial/fail) + sfs CLI 매핑 + WU-23 §1.4 draft 정정 기록. SSoT pointer = 05-gate-framework.md. visibility business-only. |
| **CLAUDE.md §1.14** | `2026-04-19-sfs-v0.4/CLAUDE.md` | ✨ **22nd 신설** (`a35b669`) — ≤200 lines 메타 규칙. 첫 분리 사례 (§14) inline 기록 + 분리 우선순위 (부록 > 본문 § / 라인 수 > 의미 밀도). |
| **solon-status-report.md** | `2026-04-19-sfs-v0.4/solon-status-report.md` | ✨ **22nd 신설** (`a35b669`) — CLAUDE.md §14 본문 분리. 의미 변경 0. doc_id=solon-status-report-spec, version 0.6.3, visibility raw-internal. |
| **CLAUDE.md** (슬림화) | `2026-04-19-sfs-v0.4/CLAUDE.md` | ✅ **22nd 갱신** — 214 → **167 lines** (≤200 충족, 33 lines 여유). §1 13규율 → 14규율. §14 link 1줄로 대체. |
| **sprints/WU-30.md** | — | ✨ **22nd 신설** (`c1f1fa3`) — F-04 verify-w0.sh fix WU. frontmatter (status: pending, decision_points: 0) + 작업 plan §0~§5. 사용자 결정 WU22-D9 사전 적용. 실 fix 다음 세션. |
| **sprints/WU-24.md** | — | ✨ **22nd 신설** (`b990b8b`) — #1 sfs slash 구현 part 1 (`/sfs status` + `/sfs start`). frontmatter (status: pending, current_wu) + 구현 spec §0~§6. 사용자 결정 WU22-D3~D5 사전 적용. 실 bash 구현 다음 세션. |
| **sprints/WU-23.md** | — | ✅ **22nd 갱신** (`d1189c6`) — frontmatter `decision_points` WU22-D3~D9 7건 추가 (resolution + impacts) + `learning_patterns_emitted` P-06 후보 추가 + §7.4 update (✅ 22nd 일괄 수행 완료) + §7.6 신설 (22nd 결정 인덱스 dashboard). |
| **sprints/_INDEX.md** | — | ✅ **22nd 갱신** — frontmatter `updated` + 활성 WU 섹션 (현재 없음 → WU-24 + WU-30 row 추가). 완료 WU 섹션 그대로. |
| **PROGRESS.md (본 파일)** | — | ✨ **22nd 다중 덮어쓰기** — frontmatter (`current_wu_owner=adoring-trusting-feynman` mode=user-active, claimed_at + last_heartbeat 22:47→23:00, `released_history` rolling 17th+16th drop + 21st last 신규 + 20th prior recovery, `scheduled_task_log` 22nd entry append helper, `resume_hint` v8) + 본문 ①~④ 22nd 추가. |
| `scripts/append-scheduled-task-log.sh` | v0.1 | ✅ 22nd 호출 (`bf180de`) — 10 entries kept (rolling N=20). |
| `scripts/resume-session-check.sh` | v0.3 | ✅ 22nd 미접촉 — 21st cd41dff cleanup 후 exit 0 가능 (commit 정책 정합). |

### 4.2 21번째 이전 산출물 (22nd 미접촉, 인벤토리 보존)

| 산출물 | 경로 | 상태 |
|--------|------|:-:|
| **sprints/WU-23.md** | — | ✅ **21번째 신설/close** — frontmatter (V-1 vote PASS, final_sha=`1e0e6f1`) + §0 작업 진행 원칙 + §1 6 명령 contract spec (3 conditions applied) + §2 공통 모듈 (.sfs-local/current-sprint naming pattern) + §3 V-1 verbatim vote_record + §4 sprint roadmap + §5 체크리스트 close + §6 결론 + §7 사용자 복귀 시 결정 대기 (block 1 + product 5 + non-block + F-04 escalate) |
| **.claude/agents/{generator,evaluator,planner}.md** | `agent_architect/.claude/agents/` | ✨ **21번째 신설** — Solon docset edition 페르소나 3 (CTO/CPO/CEO 동등 + 2/3 vote + max 1 retry + 본부 leaf 호출 안 함). alt B 등록, mid-session reload 안 됨 → fallback A 운영 (P-05). 사용자 복귀 후 Claude Code 재시작 시 native 활성. |
| **learning-logs/2026-05/P-04-session-hang-takeover.md** | — | ✨ **21번째 신설** — 19th hang → 20th takeover (WU-22 §7) 일반화. visibility raw-internal. §1.12 stale-mutex confirm 원칙 + WU §N takeover 기록 표준. 21st user-active-deferred mode 변종. |
| **learning-logs/2026-05/P-05-agent-loader-startup-only.md** | — | ✨ **21번째 신설** — Claude Code agent loader startup-only. fallback A 패턴 (general-purpose + Read .claude/agents/<persona>.md). visibility business-only. solon-mvp consumer 영향 명시. |
| **PROGRESS.md (본 파일)** | — | ✨ **21번째 다중 덮어쓰기** — frontmatter (current_wu_owner mode=user-active-deferred, last_overwrite/heartbeat 갱신, scheduled_task_log 21st entry append helper 호출, released_history.last_final_commits TBD_20TH→a66cf2e backfill, oldest_reason cd41dff backtick escape) + 본문 ①~④ 21st 추가 + ③ Next 6 결정 대기 항목 정리. |
| **HANDOFF-next-session.md** | — | ✨ **21번째 sync v3.5 → v3.6** — 18~21st 세션 prior_sessions rolling + current_active_* 필드 신설 (mode/intent) + session_continuity_note 21st 6 항목 추가 + 20th/21st 원칙 주석. |
| **sprints/_INDEX.md** | — | ✨ **21번째 갱신** — WU-22 row final_sha (TBD_20TH→a66cf2e) + WU-23 row 추가 (final_sha=1e0e6f1) + 활성 WU 섹션 비움 + frontmatter updated. |
| **sprints/WU-22.md** | — | ✅ **21번째 backfill** — final_sha TBD_20TH_SNAPSHOT → a66cf2e + §5 체크리스트 commit row 정리. (close 자체는 20th 작업) |
| sprints/WU-21.md | — | ✅ 18번째 신설, final_sha cd94f65 — Phase 1 킥오프 dry-run PASS, F-01~F-04 findings (F-04 21st escalate 후 WU-30 후보) |
| scripts/resume-session-check.sh | v0.3 | ✅ 17번째 강화 (check #7 drift). 21st cd41dff false-positive 제거 후 exit 0 (clean) 가능. |
| scripts/append-scheduled-task-log.sh | v0.1 | ✅ 17번째 신설. 21st 세션이 helper 호출 (rolling N=20, 9 entries kept). |
| phase1-mvp-templates/setup-w0.sh + verify-w0.sh | — | ⏳ WU-21 sandbox 검증 통과. F-04 (verify-w0.sh check #6/#7 false-positive 2건) 21st escalate → WU-30 후보 (사용자 결정 대기, 정규식 트레이드오프). |
| ~/workspace/solon-mvp/install.sh v0.2.4-mvp | — | ✅ R-D1 read-only 유지. 21st 자율 작업 mode 에서 미접촉. |
| sprints/WU-{17,18,19,20,20.1,21,22,23}.md | — | ✅ all status: done |
| sessions/_INDEX.md | — | ⏳ 11~21번째 retrospective 미작성 누적 **11건** (21번째 본 세션 포함). 후속 (i) 항목. |
| CLAUDE.md | `2026-04-19-sfs-v0.4/CLAUDE.md` | ✅ §1 13 규율. 21번째 세션 user-active-deferred mode 는 PROGRESS frontmatter 에만 반영 (CLAUDE.md §1.12 본문 편집 보류 — 사용자 복귀 후 결정). |
| cross-ref-audit.md §4 W10 TODO | — | ⏳ 19 항목, 사용자 결정 영역. 21st 세션 자율 작업 mode 에서 미접촉. |
| PHASE1-MVP-QUICK-START.md | — | ✅ D-day 차단 요소 없음 (오늘 기준 D-2, 2026-04-27 월). |
| solon-mvp-dist/ | — | ✅ v0.2.4-mvp stable checksum 일치. 21st 자율 작업에서 미접촉. |

## 운영 규칙 (22nd 세션까지 누적)

1. 다음 세션 진입 시 **step 0: `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh`** 필수.
2. §1.12 mutex 프로토콜 (claim → heartbeat → release) + **stale-mutex takeover 시 사용자 명시 confirm 필수** (20번째 확립).
3. 매 WU 경계에서 PROGRESS.md 덮어쓰기 + commit.
4. sandbox dry-run 은 /tmp/ 한정 (18번째 원칙 유지).
5. scheduled task 모드 = 새 WU 착수 금지, cleanup 만.
6. **session-hang 감지 후 takeover 시**: 대상 WU 문서 안에 §N takeover 기록 섹션 추가. PROGRESS released_history.last_reason 에 hang 사실 명시 (20번째 확립).
7. **user-active-deferred mode** (21번째 신설): 사용자 명시 부재 + 자율 작업 위임 시 mutex `mode: user-active-deferred` + `current_active_intent` 명시. takeover 보호 비활성화. P-04 변종.
8. **3-agent 합의 protocol** (21번째 신설): 의미 결정은 CEO+CTO+CPO 2/3 다수결. CONDITIONAL 모두 ≤2-line fix → effective PASS. max 1 retry round. 부결 시 ⚠️ escalate (사용자 복귀 시 결정).
9. **fallback A 패턴** (21번째 P-05): mid-session 신설 페르소나는 native subagent_type 호출 안 됨 → general-purpose + Read .claude/agents/<persona>.md inline 지시.
10. **CLAUDE.md ≤200 lines 메타 규칙** (22nd 신설, §1.14): 본 SSoT 합산 line 수 ≤200 항상 유지. 초과 시 부록 § 별도 파일 분리 + link 1줄 대체. 분리 우선순위 = 부록 > 본문 § / 라인 수 > 의미 밀도. 첫 사례 §14 → solon-status-report.md (의미 변경 0). P-06 후보 패턴.
11. **사용자 §N 일괄 결정 batch 패턴** (22nd 확립): 결정 대기 항목 N건 누적 시 사용자에게 한 번에 컨텍스트 + 옵션 + trade-off + β default 제시 → 사용자 일괄 답 → step batch 일괄 진행. 매 step wip commit + heartbeat 갱신. Cf. WU-23 §7 7항목 / 8 step batch 22nd 사례.
12. **auto commit policy** (22nd WU22-D8): commit 자동, push 수동 (§1.5). PROGRESS.md 가 히스토리 보유하므로 commit 자동화 OK. 단 push 는 사용자 터미널 책임 유지.
13. **gate enum SSoT 1원** (22nd WU22-D3): `gates.md` = sfs CLI 참조용 컴팩트 reference, `05-gate-framework.md` = 진짜 SSoT. gates.md 변경 시 05 먼저 갱신 후 sync. 7-gate enum (G-1 + G0 + G1~G5).

---

**다음 세션 (23번째) 진입 체크리스트 (v1.3, 22nd 세션 8 step batch 반영)**:

1. `CLAUDE.md §1` + `§1.12` + `§1.13` + **§1.14 (22nd 신설 ≤200 lines)** 읽기 (총 14 규율).
2. `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh` 실행. **exit 0 예상** (cd41dff 정합 + 22nd commit 정책 정합).
3. `PROGRESS.md` frontmatter `current_wu_owner` 확인. 22nd 자연 release 시 null + claim. 실 release 안 됐으면 §1.12 mutex 절차 (mode=user-active 단순 release).
4. `git status` + `git rev-list --count origin/main..HEAD` 확인. **22nd 종료 시점 예상 ahead = 14** (8 step batch commits 7건 + 본 PROGRESS 최종 + 실 14는 push 안 했을 때). 사용자 터미널 push 후 0.
5. **default = WU-24 step-1 entry** (resume_hint v8 default_action). `sprints/WU-24.md §5` 체크리스트 row 5~10 진행:
   - sfs-common.sh + sfs-status.sh + sfs-start.sh 실 작성
   - sprint-templates 4 (plan/log/review/retro) 신설
   - .claude/commands/sfs.md adapter dispatch 추가
   - VERSION + CHANGELOG 0.3.0-mvp 예약 entry
   - dry-run sandbox `/tmp/wu24-dry/`
6. **사용자 결정 대기 = 0건** (22nd 세션 §7 7항목 모두 resolved). 추가 결정 필요 시 ⚠️ marker + escalate.
7. **Claude Code 재시작 후 native subagent_type=generator/evaluator/planner** 호출 가능 (P-05 fallback A 졸업). V-2 부터 native vote 시도 권장.
8. **D-day = 2026-04-27 월 (D-2)** — 사용자 본인 Mac 실행, Claude 세션 자동 아님. PHASE1-MVP-QUICK-START.md §2 runbook 사용.
9. WU 완료 시 본 PROGRESS.md 즉시 덮어쓰기 + commit (FUSE bypass 자동 적용 허용).

**22번째 세션 8 step batch 종료 시점 핵심 메시지** (다음 세션 한 줄 요약):

> 사용자 §7 결정 7항목 일괄 resolved + gates.md 신설 (7-gate enum SSoT) + CLAUDE.md §1.14 ≤200 lines 메타 규칙 + §14 → solon-status-report.md 분리 (167 lines, 33 여유) + WU-23 §7 resolved 마킹 + WU-30 신설 (F-04 fix) + WU-24 entry 준비 (#1 sfs slash 구현 part 1, 구현 spec까지). 다음 세션 = WU-24 step-1 실 bash 구현부터. push 사용자 터미널.
