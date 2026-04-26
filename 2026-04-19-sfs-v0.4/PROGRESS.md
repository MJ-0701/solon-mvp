---
doc_id: sfs-v0.4-progress-live
title: "PROGRESS — live single-frame snapshot (덮어쓰기 방식)"
version: live
last_overwrite: 2026-04-26T10:25:30+09:00
session: "24번째 사이클 11번째 진입 = 사용자 user-active conversation `great-dazzling-babbage`. 사용자가 직전 10번째 scheduled run (`friendly-serene-galileo`, 10:13~10:14 KST, row 11 dry-run sandbox 검증 + install.sh gap fix) 결과를 확인 후 '다음작업 이어서 ㄱㄱ' 발화 (resume_hint trigger_positive 매칭). 진입 시 current_wu_owner=null + D-A-WU-24 = unowned (직전 friendly-serene-galileo 자연 release, next_step=8). resume-session-check exit 0 (clean). default_action priority 1 = D-A-WU-24 row 12 (WU-24 frontmatter close) 자유 claim → micro-step 진행 → release. **row 12 작업** = WU-24.md frontmatter status: pending→done / closed_at: null→2026-04-26T10:24:39+09:00 / session_closed: null→great-dazzling-babbage / final_sha: null→TBD_24TH_great-dazzling-babbage placeholder (§1.5' AI commit 권한 회수, 사용자 manual commit 후 backfill). §5 row 12 체크박스 마킹 + row 13 (PROGRESS+_INDEX 갱신) 및 row 14 (commit) 는 다음 step 으로 명시 (사용자 manual). domain_locks.D-A-WU-24.next_step 8→9 (다음 = row 13 sprints/_INDEX 갱신). 본 conversation = 24th 정책 정합 = 자기 codename mutex 안 잡고 도메인만 claim → release. git mutate 0 (§1.5' 정합). **D-B-WU-31 cross-dep 충족 유지** (next_step 9 ≥ 6, 다음 scheduled run 부터 D-B 또는 D-A row 13 양쪽 가능, priority order = D-A row 13 > D-B row 4 권장)."
current_wu: WU-24   # 23rd 부터 유지. 24th 가 변경 안 함.
current_wu_path: 2026-04-19-sfs-v0.4/sprints/WU-24.md
current_wu_owner: null   # 24번째 = 본 conversation 정리만, mutex claim 안 함. scheduled run 들 (1:00 AM 부터 hourly) 이 mode=user-active-deferred 로 자유 claim. 도메인 sub-mutex 는 frontmatter 의 domain_locks block 참조.
released_history:
  last_owner: dazzling-sharp-euler
  last_claimed_at: 2026-04-25T23:43:12+09:00
  last_released_at: 2026-04-25T23:55:00+09:00   # 사용자 manual commit + push 완료 (10f5e8f 까지, 24th 진입 시 ahead=0 확인)
  last_reason: "23번째 세션 user-active. WU-31 (Release tooling Phase 0) 신설 spec only + 사용자 결정 (옵션 β + '계획만') + sandbox file:// clone 패턴 채택 (단기 α 변형) + §1.5' 격상 결정 (24th 첫 작업) + .git/index.lock FUSE bypass 사고 (P-08 후보, 복구 완료, commit 사용자 manual). 자연 release."
  last_final_commits: [beb9f0e, 3a7693e, 10f5e8f]   # WU-31 신설 + resume_hint v9→v10→v11 + 운영 규칙 16~20
  prior_owner: adoring-trusting-feynman
  prior_claimed_at: 2026-04-25T22:47:00+09:00
  prior_released_at: 2026-04-25T23:14:12+09:00
  prior_reason: "22번째 세션 user-active. 8 step batch — gates.md 신설 + CLAUDE.md §1.14 + §14 분리 + WU-23 §7 7항목 resolved + WU-30 + WU-24 entry."
  prior_final_commits: [bf180de, a35b669, 7be62b4, d1189c6, c1f1fa3, b990b8b, 7923336, cb1d85a]
  older_owner: trusting-stoic-archimedes
  older_claimed_at: 2026-04-25T17:37:22+09:00
  older_released_at: 2026-04-25T22:47:00+09:00
  older_reason: "21번째 세션 user-active-deferred (4시간 자율 위임). 3-agent 합의 + alt B persona + WU-23 close + P-04/P-05 후보."
  older_final_commits: [a66cf2e, f11dd4f, 1e0e6f1, 9f146e3, 449c4a6, 7ca88b0, a9dc7a5, 8215c43]
  oldest_owner: epic-brave-galileo
  oldest_claimed_at: 2026-04-25T10:47:00+09:00
  oldest_released_at: 2026-04-25T17:37:22+09:00
  oldest_reason: "20번째 세션 user-active takeover. 19번째 hang stale takeover + WU-22 close (β) + sprints/_INDEX 갱신."
  oldest_final_commits: [a66cf2e]
  # 20번째 (epic-brave-galileo) 까지 rolling N=4. 19번째 (eager-elegant-bell), 18번째 (confident-loving-ride), 17번째 (admiring-fervent-dijkstra), 16번째 (nice-kind-babbage), 15번째 (admiring-nice-faraday) 는 scheduled_task_log 에 trace 유지.

# ── scheduled_task_log (16번째 세션 신설, 17번째 helper 화) ──────────
# Cowork scheduled_task hourly auto-resume 의 explicit trace. rolling N=20.
# 필드: ts (ISO8601 +09:00) · codename · check_exit · action · ahead_delta
# 18번째 세션은 user-active (scheduled 아님) 이지만 trace 연속성 위해 한 줄 append.
scheduled_task_log:
  - ts: 2026-04-26T10:24:39+09:00
    codename: great-dazzling-babbage
    check_exit: 0
    action: "24번째 사이클 11번째 진입 = **사용자 user-active conversation** (mode=user-active, scheduled run 아님 — 사용자 직전 10번째 run `friendly-serene-galileo` 결과 확인 후 '다음작업 이어서 ㄱㄱ' trigger). resume-check exit 0 (clean). 진입 시 D-A-WU-24 = unowned (직전 friendly-serene-galileo 10:14 KST 자연 release, next_step=8) + current_wu_owner=null → 도메인만 claim (자기 codename mutex 안 잡음, 24th 정책 정합 = 본 conversation 도 도메인 단위 진행). **row 12 작업**: WU-24.md frontmatter close — status: pending→done / closed_at: null→2026-04-26T10:24:39+09:00 / session_closed: null→great-dazzling-babbage / final_sha: null→TBD_24TH_great-dazzling-babbage (placeholder, §1.5' AI commit 권한 회수 정합 — 사용자 manual commit 후 backfill). §5 row 12 체크박스 마킹 (시각/주체/작업 narrative 명시). domain_locks.D-A-WU-24 release (next_step 8→9, last_step_done.row 12 기록). 다음 row 13 = PROGRESS.md ②/③ 갱신 + sprints/_INDEX.md row 추가 (다음 scheduled run 또는 사용자 manual). row 14 = git commit (사용자 manual). 17번째 helper `scripts/append-scheduled-task-log.sh` 사용 안 함 (본 entry 는 user-active conversation 의 in-line 갱신, helper 는 scheduled run 만)."
    ahead_delta: "+0 (§1.5' AI commit 권한 회수, file 편집 + PROGRESS heartbeat 만)"
  - ts: 2026-04-26T10:13:30+09:00
    codename: friendly-serene-galileo
    check_exit: 0
    action: "24번째 사이클 10번째 scheduled run (user-active-deferred). resume-check exit 0 (clean). 진입 시 D-A-WU-24 = unowned (직전 blissful-modest-goldberg 09:11 KST 자연 release + next_step=7) + current_wu_owner=null → 자유 claim. WU-24.md §5 **row 11 (dry-run sandbox 검증)** 진행. **gap 발견 + fix 같은 micro-step**: install.sh 가 `.sfs-local-template/scripts/` + `sprint-templates/` 를 copy 안 함 → install.sh §7 끝부분에 2 블록 추가 (scripts/ + sprint-templates/, 각 cp + executable). bash -n PASS. 통합 smoke T1~T9 전부 PASS — T1 status no sprint exit 0 / T2 start auto-id `2026-W17-sprint-1` exit 0 / T3 post-start status populated exit 0 / T4 install 재실행 idempotent / T5 --color=always ANSI / T6 --color=never plain / T7 동일 id no --force exit 1 / T8 --force overrides exit 0 / T9 install 재실행 후 sprint + events 보존. domain_locks.D-A-WU-24 release (next_step 7→8, last_step_done.row 11 기록). 다음 row 12 = WU-24 frontmatter status=done + closed_at + final_sha. **D-B-WU-31 cross-dep 충족** (8≥6) — 다음 scheduled run 부터 D-B claim 가능."
    ahead_delta: "+0 (§1.5' AI commit 권한 회수, file 편집 + PROGRESS heartbeat 만)"
  - ts: 2026-04-26T09:10:36+09:00
    codename: blissful-modest-goldberg
    check_exit: 0
    action: "24번째 사이클 9번째 scheduled run (user-active-deferred). resume-check exit 0 (clean). 진입 시 D-A-WU-24 = unowned (직전 vigilant-fervent-dirac 08:35 KST 자연 release, next_step=6) + current_wu_owner=null → 자유 claim. WU-24.md §5 row 10 (solon-mvp-dist/VERSION + CHANGELOG.md 0.3.0-mvp 예약 entry) 진행. VERSION = 첫 줄 0.2.4-mvp 유지 (install.sh L293/L380 head -1 정합 PASS) + 주석 블록 3줄 (next/cut/scope). CHANGELOG.md = '## [0.3.0-mvp] — Unreleased (예약, WU-31 cut 대기)' 섹션 prepend (0.2.4-mvp 위에) + Added 7항목 + Changed 2항목 + Notes 2항목. Added: sfs-common.sh (293L) / sfs-status.sh (129L) / sfs-start.sh (182L) / sprint-templates 4 (plan G1 / log do / review empty / retro G5). Changed: sfs.md adapter dispatch + VERSION 주석. Notes: gates.md SSoT 정합 + R-D1 dev-first. β bundle 매핑 명시 (#1 + #4 + #6). domain_locks.D-A-WU-24 release (next_step 6→7, last_step_done row 10). 다음 row 11 = dry-run sandbox 검증 /tmp/wu24-dry/ (install.sh + sfs-status.sh + sfs-start.sh 통합)."
    ahead_delta: "+0 (§1.5' AI commit 권한 회수, file 편집 + PROGRESS heartbeat 만)"
  - ts: 2026-04-26T08:35:00+09:00
    codename: vigilant-fervent-dirac
    check_exit: 0
    action: "24번째 사이클 8번째 진입 = 사용자 user-active conversation (mode=user-active, 사용자 직접 ㄱㄱ 트리거). resume-check exit 0 (clean). 진입 시 current_wu_owner=null + D-A-WU-24 unowned (직전 cool-magical-volta 06:12 KST 자연 release 후, modest-wonderful-tesla 08:02 KST 는 drift report only 도메인 claim 0). 자유 claim → WU-24.md §5 row 9 (.claude/commands/sfs.md adapter dispatch 추가). 진입 시 working copy 에 sfs.md mtime=07:34 KST 로 어떤 unlogged 세션이 75줄 diff 이미 추가해 둠 (HEAD=3ca7f56 vs working — frontmatter `allowed-tools: Bash, Read, Write, Edit, Grep, Glob` 추가 + `## Adapter Dispatch (status / start) — execute first` 섹션 신설 + 5단계 절차 (Existence check → Quote args safely → Execute → Print output verbatim → Stop) + dispatch table 2 row + exit code mapping + WU22-D4 SSoT 명시 + Rules 마지막 줄 추가). 본 conversation 검증 7항목 PASS — [1] frontmatter 보존 / [2] adapter dispatch 섹션 + 5단계 절차 / [3] dispatch table (status→sfs-status.sh + start→sfs-start.sh, consumer-side `.sfs-local/scripts/` path) / [4] exit code mapping (status: 0/1/2/3/99 + start: 0/1/4/5/99 정합 sfs-status.sh + sfs-start.sh 실 smoke 결과) / [5] empty $ARGUMENTS→status default / [6] WU22-D4 (`·` separator + ISO8601 + per-field color, bash single source of truth) / [7] Rules 섹션 `bash adapter is authoritative` 추가. fallback only 명시 (Claude-driven mode 는 status/start 외 7개 + script missing 시만). domain_locks.D-A-WU-24 release (next_step 5→6, last_step_done.row 9 기록). 다음 row 10 = `solon-mvp-dist/VERSION` + `CHANGELOG.md` 0.3.0-mvp 예약 entry."
    ahead_delta: "+0 (§1.5' AI commit 권한 회수, file 편집 + PROGRESS heartbeat 만)"
  - ts: 2026-04-26T08:02:38+09:00
    codename: modest-wonderful-tesla
    check_exit: 16
    action: "24번째 사이클 7번째 scheduled run (user-active-deferred). resume-check exit 16 = sched_log_drift:110m (직전 cool-magical-volta @ 06:12 KST, 본 run @ 08:02 KST = 110분, 90분 threshold 초과 → 07:00 hourly cron skip 추정). 직전 run 의 도메인 lock D-A-WU-24 = 정상 release 상태 (owner=null, next_step=5), stale takeover 불필요. scheduled_task spec '§3 exit 0 아니면 원인만 PROGRESS 기록 후 종료' 준수 + funny-hopeful-tesla 03:29 KST 선례 정합 (drift report only, 도메인 claim 안 함) → 본 entry append + PROGRESS last_overwrite/last_heartbeat 갱신만, 도메인 lock claim/takeover 안 함. 다음 scheduled run (예상 09:00 KST) 이 row 9 (.claude/commands/sfs.md adapter dispatch) 진행 권장."
    ahead_delta: "+0 (§1.5' AI commit 권한 회수, file 편집만)"
  - ts: 2026-04-26T06:12:00+09:00
    codename: cool-magical-volta
    check_exit: 0
    action: "24번째 사이클 6번째 scheduled run (user-active-deferred). resume-check exit 0 (clean). D-A-WU-24 unowned (relaxed-gallant-maxwell 05:10 KST 자연 release 후) → 자유 claim → WU-24.md §5 row 8 (sprint-templates {plan,log,review,retro}.md 4파일 신설). plan.md (`phase: plan`/`gate_id: G1` + 요구사항/AC/범위/G1 자기점검 4 §) / log.md (`phase: do` + 시간순 append/decision-블로커/핸드오프 3 §) / review.md (`phase: review`/`gate_id: \"\"` set by --gate G2|G3|G4 + 대상 gate/평가 항목/verdict/다음 액션 4 §) / retro.md (`phase: retro`/`gate_id: G5`/`closed_at: \"\"` + KPT/PDCA 학습/정량 메트릭/다음 sprint 인계/G5 close 체크 5 §) — gates.md §1 (7-Gate enum) + §2 (verdict) + 05-gate-framework.md §5.1 SSoT pointer 명시. 4파일 smoke 통합 PASS — sfs-start.sh dry-run sandbox /tmp/wu24-row8-dry-XXXX 에서 T1 --help exit 0 / T2 happy `/sfs start` (auto-id `2026-W17-sprint-1`) → 4 templates copy + current-sprint 'cool-magical-volta'-time 의 ISO week 17 sprint-1 정합 + events.jsonl `{ts:<ISO>,type:sprint_start,sprint_id:2026-W17-sprint-1,by:sfs-start}` append + 4 file copy 확인 / T3 frontmatter 무결 (plan→G1, log→phase:do no gate_id, review→empty gate_id (--gate 가 set), retro→G5+closed_at empty) / T4 review.md 삭제 시 exit 4 + `templates not found: .sfs-local/sprint-templates/review.md`. 산출 dev path = solon-mvp-dist/templates/.sfs-local-template/sprint-templates/{plan,log,review,retro}.md. domain_locks.D-A-WU-24 release (next_step 4→5). 다음 row 9 = .claude/commands/sfs.md adapter dispatch."
    ahead_delta: "+0 (§1.5' AI commit 권한 회수)"
  - ts: 2026-04-26T05:10:00+09:00
    codename: relaxed-gallant-maxwell
    check_exit: 0
    action: "24번째 사이클 5번째 scheduled run (user-active-deferred). resume-check exit 0 (clean). D-A-WU-24 unowned (brave-gifted-thompson 04:05 KST 자연 release 후) → 자유 claim → WU-24.md §5 row 7 (sfs-start.sh 신설, 182 lines, bash -n PASS, T1~T10 10개 smoke 전부 PASS — T1 --help exit 0 / T2 unknown flag exit 99 / T3 no .sfs-local/sprint-templates dir exit 4 / T4 conflict no --force exit 1 / T5 --force overrides exit 0 / T6 happy auto sprint-id `2026-W17-sprint-1` + 4 templates copy + current-sprint 갱신 + events.jsonl `sprint_start` JSONL append / T7 explicit id `my-custom-id` exit 0 / T8 path traversal `../escape` exit 99 / T9 multiple positional args exit 99 / T10 missing single template file exit 4) → release (next_step 3→4). 산출 = solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-start.sh. dev path 동일 (.sfs-local-template/scripts/). 다음 row 8 = sprint-templates {plan,log,review,retro}.md 4파일 신설."
    ahead_delta: "+0 (§1.5' AI commit 권한 회수)"
  - ts: 2026-04-26T04:04:37+09:00
    codename: brave-gifted-thompson
    check_exit: 0
    action: "24번째 사이클 4번째 scheduled run (user-active-deferred). D-A-WU-24 stale lock takeover (affectionate-exciting-thompson @ 02:15:18, now 04:05 KST = 110분, 3.7× TTL 30분, mode=user-active-deferred 정합 자동 takeover). WU-24.md §5 row 6 (sfs-status.sh 신설, 129 lines, bash -n PASS, T1~T8d 11개 smoke 전부 PASS — T1 --help / T2 invalid color exit 99 / T3 no init exit 1 / T4 corrupt jsonl exit 2 / T5 no git exit 3 / T6 happy empty placeholders / T7 happy populated state / T8a no ANSI in never / T8b ANSI in always / T8c equal-form / T8d space-form). 산출 = solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-status.sh. dev path 동일 (.sfs-local-template/scripts/). domain_locks.D-A-WU-24 release (next_step 2→3). 다음 row 7 = sfs-start.sh."
    ahead_delta: "+0 (§1.5' AI commit 권한 회수)"
  - ts: 2026-04-26T03:29:15+09:00
    codename: funny-hopeful-tesla
    check_exit: 16
    action: "24th 사이클 3번째 scheduled run (user-active-deferred). resume-check exit 16 = sched_log_drift:127m. 직전 affectionate-exciting-thompson 가 D-A-WU-24 claim @ 2026-04-26T02:15:18+09:00 후 release 미수행 (TTL 30분 vs now 03:18 KST = 64분 stale, 2.1× 초과). scheduled_task spec '§3 exit 0 아니면 원인만 PROGRESS 기록 후 종료' 준수 → 본 entry append + PROGRESS last_overwrite/last_heartbeat 갱신 + heartbeat 만, 도메인 lock takeover 안 함. 다음 scheduled run (04:00 KST) 이 stale lock 자동 takeover (user-active-deferred 정합) 후 row 6 sfs-status.sh 진행 권장."
    ahead_delta: "+0 (§1.5' AI commit 권한 회수, file 편집만)"
  - ts: 2026-04-26T01:11:30+09:00
    codename: friendly-magical-galileo
    check_exit: 0
    action: "24번째 사이클 1번째 scheduled run (user-active-deferred). domain_locks D-A-WU-24 claim → WU-24.md §5 row 5 (sfs-common.sh 신설, 293 lines, validate_sfs_local + readers + generate_sprint_id_iso_week + render_status_line + append_event 함수 군) → bash -n PASS + T1~T8 smoke OK → release (next_step 1→2, last_step_done 기록). dev path = `.sfs-local-template/scripts/` (install.sh L326+ 정합, WU-24 spec 의 `.sfs-local/` 약식). §1.5' 정합 host .git mutate 0."
    ahead_delta: "+0 (§1.5' AI commit 권한 회수 — 사용자 manual)"
  - ts: 2026-04-26T00:45:32+09:00
    codename: serene-sharp-edison
    check_exit: 0
    action: "24번째 세션 user-active 정리만 (mutex claim 안 함). 23rd 자연 release 후 진입. 사용자 결정 D3 (dual-track 유지) + D6 (WU-31 default 4건 OK) + D7 #14 (A schema 신설) 수신. 24th 신설 = §1.5' 격상 (CLAUDE.md 1줄 수정) + domain_locks 도메인 sub-mutex 시스템 (6 + 양방향 2) + scheduled task 1:00 AM hourly 등록 + 본 conversation mutex 안 잡음. 다음 = scheduled run 들 picking up."
    ahead_delta: "+1 예상 (PROGRESS 갱신 + CLAUDE.md §1.5 수정 commit)"
  - ts: 2026-04-25T23:43:12+09:00
    codename: dazzling-sharp-euler
    check_exit: 0
    action: "23번째 세션 user-active. 22nd mutex 자연 release (정상 종료) + 23rd self claim. 사용자 결정 수신 = 배포 자동화 옵션 β (로컬 sh 우선, GitHub Action 후속 Phase 1+2 별도 WU) + 명시 '계획만 만들어 둬' → WU-31 (Release tooling Phase 0) 신설 (spec only, frontmatter + 본문 §0~§8). 실 bash 다음 세션. dual-track / single-track OSS 전환 결정 = 보류 (영향범위 인지)."
    ahead_delta: "+1 예상 (WU-31 신설 commit + 본 PROGRESS 갱신)"
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

# ── domain_locks (24번째 신설) ─────────────────────────────────────
# 도메인별 sub-mutex (§1.12 mutex 의 도메인 단위 확장).
# 동시 세션 (다른 conversation + scheduled run) race 0 보장.
# 각 도메인은 자기 files_scope 만 만짐 → 거의 disjoint.
# scheduled run 진입 시: priority 순서로 unowned 중 highest claim → 1 micro-step (5~10분) → release.
# TTL 30분 — 초과 시 다른 세션이 stale takeover 자동 (mode=user-active-deferred 정합).
# 양방향 도메인 (D-D / D-E): forward + reverse 동시 owner 가능, forward_idx >= reverse_idx 시 stop.
# Cross-dependency: D-B 는 D-A.next_step >= 6 (0.3.0-mvp 예약 entry 후) 후만 claim.

domain_locks:
  D-A-WU-24:
    owner: null   # released 2026-04-26T10:25:30+09:00 by great-dazzling-babbage (24th 사이클 11번째 진입 = 사용자 user-active conversation, scheduled run 아님). 직전 friendly-serene-galileo 10:14 KST release (row 11 dry-run + install.sh gap fix) → 본 conversation 자유 claim → row 12 (WU-24 frontmatter close) → 자연 release. WU-24 frontmatter status=done 마킹 완료 (final_sha = TBD placeholder, 사용자 manual commit 후 backfill 필요). git mutate 0 (§1.5'). **다음 priority order**: D-A row 13 (sprints/_INDEX 갱신, 가벼움) > D-A row 14 (사용자 manual commit) > D-B row 4 (cut-release.sh, cross-dep 충족 유지 next_step 9 ≥ 6).
    claimed_at: null
    last_heartbeat: null
    ttl_minutes: 30
    next_step: 9   # WU-24.md §5 row 12 (frontmatter close = status=done + closed_at + session_closed + final_sha placeholder) 완료. 다음 = row 13 = sprints/_INDEX.md frontmatter `updated` 갱신 + 활성 WU 섹션에서 WU-24 제거 + done 섹션 row 추가. row 14 (commit) 는 사용자 manual.
    last_step_done:
      step: "row 12 — WU-24 frontmatter close (status: pending→done / closed_at / session_closed / final_sha placeholder)"
      by: great-dazzling-babbage
      at: 2026-04-26T10:24:39+09:00
      files:
        - "2026-04-19-sfs-v0.4/sprints/WU-24.md"
      claim_note: "진입 시 D-A-WU-24 = unowned (직전 friendly-serene-galileo 10:14 KST 자연 release + next_step=8). current_wu_owner=null + resume-check exit 0 → 자유 claim (no takeover). **mode=user-active** (사용자 user-active conversation, scheduled run 아님 — 24th 정책 정합 = 본 conversation 도 자기 codename mutex 안 잡고 도메인만 claim → release)."
      close_design: "WU-24.md frontmatter 4 필드 갱신 = (1) status: pending→done / (2) closed_at: null→2026-04-26T10:24:39+09:00 / (3) session_closed: null→great-dazzling-babbage / (4) final_sha: null→`TBD_24TH_great-dazzling-babbage` placeholder (§1.5' 정합 = AI commit 권한 회수, 사용자 manual commit 후 자연 backfill — WU-22 의 `TBD_20TH_SNAPSHOT` 선례 정합). §5 체크리스트 row 12 체크박스 [x] 마킹 + narrative 명시 (시각/주체/작업/사용자 발화 매칭). row 13/14 는 다음 step 으로 보존 (open checkbox)."
      ssot_note: "본 close = file 편집만 (host repo .git mutate 0). final_sha placeholder 는 사용자 manual commit 후 PROGRESS + WU-24 frontmatter + sprints/_INDEX 동시 backfill 권장 (P-03 staged-diff 패턴 정합 — 다음 세션 에서 sha 확보 즉시 sed/edit 1회 처리). 19번째 ~ 20번째 세션의 `cd41dff`→`5d4c6c6` backfill 패턴과 동일."
      cross_dep_note: "D-A-WU-24.next_step 9 = 6 임계값 충족 유지. 다음 scheduled run 또는 사용자 active session 진입 시 priority order = D-A row 13 (가벼움 = sprints/_INDEX 1 row 추가, 1 micro-step 안에 처리 가능) > D-B row 4 (cut-release.sh, 그러나 WU-24 final_sha 가 backfill 안 된 상태 = 0.3.0-mvp release cut 시 cut-release.sh 가 final_sha=TBD 인 WU 를 찾으면 dry-run 단계 abort 권장). 따라서 D-A row 13 → 사용자 manual commit (row 14) → D-B row 4 순차 권장."
      prior_step_history: "row 11 (friendly-serene-galileo, 10:13~14 KST) = dry-run sandbox + install.sh gap fix. row 10 (blissful-modest-goldberg, 09:08~11 KST) = VERSION + CHANGELOG 0.3.0-mvp 예약 entry. row 9 (vigilant-fervent-dirac, 08:35 KST) = sfs.md adapter dispatch. row 8 (cool-magical-volta, 06:12 KST) = sprint-templates 4. row 7 (relaxed-gallant-maxwell, 05:10 KST) = sfs-start.sh. row 6 (brave-gifted-thompson, 04:05 KST) = sfs-status.sh. row 5 (friendly-magical-galileo, 01:11 KST) = sfs-common.sh. 상세 design notes 는 git history 의 직전 PROGRESS overwrite 참조."
    files_scope:
      - "2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/**"
      - "2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/sprint-templates/**"
      - "2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.claude/commands/sfs.md"
      - "2026-04-19-sfs-v0.4/solon-mvp-dist/{VERSION,CHANGELOG.md,install.sh}"
      - "2026-04-19-sfs-v0.4/sprints/WU-24.md"
    priority: 1
    spec_doc: "2026-04-19-sfs-v0.4/sprints/WU-24.md"
  D-B-WU-31:
    owner: null
    claimed_at: null
    last_heartbeat: null
    ttl_minutes: 30
    next_step: 1   # WU-31.md §7 row 4 (cut-release.sh 신설) 부터
    files_scope:
      - "2026-04-19-sfs-v0.4/scripts/{cut-release,sync-stable-to-dev,check-drift,_README}.{sh,md}"
      - "2026-04-19-sfs-v0.4/.visibility-rules.yaml"
    depends_on: "D-A-WU-24.next_step >= 6"   # 0.3.0-mvp 예약 entry 후
    priority: 2
    spec_doc: "2026-04-19-sfs-v0.4/sprints/WU-31.md"
  D-C-WU-30:
    owner: null
    claimed_at: null
    last_heartbeat: null
    ttl_minutes: 30
    next_step: 1   # WU-30.md §1 부터
    files_scope:
      - "2026-04-19-sfs-v0.4/phase1-mvp-templates/{verify-w0,verify-install}.sh"
    priority: 3
    spec_doc: "2026-04-19-sfs-v0.4/sprints/WU-30.md"
  D-D-meta-logs:
    owner_forward: null
    owner_reverse: null
    forward_idx: 0   # P-04 (1번째)
    reverse_idx: 5   # P-09 (6번째)
    list:
      - P-04-session-hang-takeover
      - P-05-agent-loader-startup-only
      - P-06-claude-md-line-limit-meta-rule
      - P-07-release-tooling-phased
      - P-08-fuse-bypass-cp-a-broken
      - P-09-sandbox-file-clone-isolation
    files_scope:
      - "2026-04-19-sfs-v0.4/learning-logs/2026-05/P-*.md"
    stop_when: "forward_idx >= reverse_idx"
    ttl_minutes: 30
    priority: 4
  D-E-meta-retro:
    owner_forward: null
    owner_reverse: null
    forward_idx: 0   # 11번째 세션
    reverse_idx: 12  # 23번째 세션
    list: [11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]
    files_scope:
      - "2026-04-19-sfs-v0.4/sessions/**"
    stop_when: "forward_idx >= reverse_idx"
    ttl_minutes: 30
    priority: 5
  D-F-meta-handoff:
    owner: null
    claimed_at: null
    last_heartbeat: null
    ttl_minutes: 30
    files_scope:
      - "2026-04-19-sfs-v0.4/HANDOFF-next-session.md"
      - "2026-04-19-sfs-v0.4/NEXT-SESSION-BRIEFING.md"
    priority: 6

# 공통 영역 — last-writer-wins (§1.5' 정합으로 git race 0)
shared_files:
  - "2026-04-19-sfs-v0.4/PROGRESS.md"           # 매 step heartbeat
  - "2026-04-19-sfs-v0.4/sprints/_INDEX.md"     # 도메인 종료 시만
  - "2026-04-19-sfs-v0.4/sprints/WU-*.md"       # 자기 도메인 WU 만

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
  purpose: "24번째 세션이 본 PROGRESS.md 1개만 읽고 (a) 23rd 미완 commit 마무리 + (b) sandbox file:// clone 패턴 채택 + (c) WU-24 + WU-31 병렬 default 자동 진행"
  trigger_positive: [ㄱㄱ, 고, ㅇㅋ, ok, OK, 시작, 가자, ㅇㅇ, 진행, go, Go, start, "이전 세션 이어서", "이어서 ㄱㄱ", "이어서", 이어, "이어서 진행"]
  trigger_negative: [ㄴㄴ, 잠깐, stop, 아니, 중단, 다른거, 다른, no]
  default_action: |
    🎯 **scheduled run / 다른 세션 진입 표준 절차** (24th 신설, 1:00 AM hourly + 사용자 다른 conversation 양쪽 정합):

    1. **CLAUDE.md SSoT Read** — §1 14규율 + §1.5' (commit/push 사용자 manual) + §1.12 mutex + §1.14 ≤200 lines.
    2. **PROGRESS.md (본 파일) Read** — frontmatter `domain_locks` + `current_wu_owner` 확인.
    3. **scripts/resume-session-check.sh 실행** — exit 0 확인 (아니면 원인 PROGRESS 기록 후 종료).
    4. **§1.12 + domain_locks 통합 mutex check**:
       - `current_wu_owner=null` → 자유 진행 (자기 codename 안 잡음, 도메인만 잡음, mode=user-active-deferred)
       - `current_wu_owner != null` + 다른 codename + TTL 미만 + mode=user-active → STOP + 사용자 confirm
       - TTL 초과 stale → mode 확인 후 자동 takeover (user-active-deferred 한정)
    5. **domain_locks scan (priority 1→6)**:
       - D-A WU-24 → D-B WU-31 (D-A.next_step >= 6 cross-dep) → D-C WU-30 → D-F HANDOFF → D-D fwd → D-D rev → D-E fwd → D-E rev
       - unowned + dep 통과 중 highest priority claim (owner=자기 codename, claimed_at, last_heartbeat, ttl_minutes=30)
    6. **1 micro-step 진행** (5~10분, WU spec §5 row 그대로). 양방향 도메인은 forward_idx / reverse_idx 기준.
    7. **release** — owner=null + last_step / forward_idx / reverse_idx 갱신.
    8. **PROGRESS heartbeat** (frontmatter `last_overwrite`) + **scheduled_task_log entry append** (helper `scripts/append-scheduled-task-log.sh`).
    9. **본문 ② In-Progress + ③ Next 1줄 갱신**.
    10. **WU 전환 발생 시 Solon Status Report** (code fence, `solon-status-report.md` v0.6.3 spec).
    11. **종료** — git commit/push 안 함 (§1.5'). 사용자 깬 후 누적 결과 검토 + manual commit + push.

    ## 사용자 결정 (24th resolved, 적용 OK)
    - D3 dual-track 유지 (single 전환 보류 — 영향범위 큼)
    - D6 WU-31 default 4건 모두 OK (allowlist 8파일 + checksum sha256 + commit msg 표준 + Phase timing)
    - D7 #14 dialog-branch.schema.yaml 신설 (A 채택, 우선순위 낮음)

    ## 절대 금지
    - 새 WU 신설 (사용자 결정 영역, §1.12 safety_lock)
    - git add/commit/push (§1.5')
    - destructive git
    - 사용자 유보 결정 자율 해석 (D7 #18/#19, dual-track 단일화 등)
    - TTL 30분 초과 작업

    ## 대안 메뉴 (사용자 깬 후 선택 시)
    (a) Phase 1 킥오프 실전 = D-day 2026-04-27 월
    (b) Claude Code 재시작 (P-05 fallback A 졸업, native subagent 활성)
    (c) dual-track / single-track OSS 전환 재논의
    (d) WU-32 (Phase 1 GitHub Action 알림) / WU-33 (Phase 2 tag trigger) 신설

    ## 참고: sandbox file:// clone (23rd 채택, 24th §1.5' 격상으로 우선순위 ↓)
    24th §1.5' = AI 의 git commit 권한 자체 회수. host `.git` mutate 0. file 편집 + PROGRESS heartbeat 만. sandbox clone 은 사용자가 patch 검토 필요할 때만 사용:
    ```sh
    SRC=/sessions/<codename>/mnt/agent_architect
    WORK=/tmp/work-24-clone
    rm -rf $WORK && git clone file://$SRC $WORK
    ```
  on_negative: |
    "현 상태만 요약 보고 후 대기" — 24th 정리 완료 (§1.5' + domain_locks + scheduled task 1:00 AM hourly 등록).
    활성 WU 3 (WU-24/30/31, 모두 spec only). 사용자 결정 대기 = 0건 (D3/D6/D7 resolved).
    scheduled run 들은 1:00 AM 부터 hourly 자동 picking up (mode=user-active-deferred).
    domain_locks 6 + 양방향 2 = race 0 보장. 공통 영역 (PROGRESS / sprints/_INDEX) 은 last-writer-wins.
  on_ambiguous: "1-line clarifying Q: 'domain_locks priority 1 (D-A WU-24 step-1.1 sfs-common.sh) 부터 1 micro-step 진행할까, 아니면 다른 도메인 우선?'"
  on_resume_signal: |
    사용자 "이어서 ㄱㄱ" 등 trigger_positive 매칭 시 default_action step 1~11 자동 진행.
    scheduled run auto-resume 도 동일 (mode=user-active-deferred, TTL 30분, 1 micro-step only).
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
    - "23번째 spec-only WU 패턴: 사용자 '계획만 만들어 둬' 명시 시 frontmatter + 본문 spec 만 신설, 실 구현 코드 (bash/python 등) 작성 금지. WU-31 사례. 22nd WU-24 / WU-30 와 동일 패턴."
    - "23번째 release tooling 결정 원칙: 본 docset 의 dev↔stable 배포는 (a) Phase 0 = 로컬 sh, (b) Phase 1 = GitHub Action 알림만, (c) Phase 2 = release tag trigger. 각 phase 승급 = 1~2 사이클 실 운영 검증 통과 시. push-trigger 자동화 = §1.5 push manual + raw-internal leak 방지 + 1인 운영 비용 균형 결정."
    - "23번째 §1.6 FUSE bypass cp -a 사고 (P-08 후보): cp -a $SRC/.git $TMP/ 단계에서 .git 일부 누락 (FUSE 마운트 특성) → rsync back --delete 가 깨진 .git 으로 host SRC 덮어씀 → ref/index 오염. 복구는 .git/refs/heads/main 직접 덮어쓰기 + GIT_INDEX_FILE 우회 read-tree. 24th 부터 cp -a 패턴 우선순위 ↓, GIT_INDEX_FILE / commit-tree low-level 우회 우선."
    - "23번째 가상화 결정 (사용자 final): 단기 = sandbox file:// clone 패턴 (α 변형 = β 보강) 채택 — claude 가 host .git mutate 안 함, /tmp/work-XX-clone 안에서 commit, host 는 patch/file:// push back 으로 동기. 장기 = ε VM (UTM/Multipass/Lima) 검토 항목."
    - "24th 부터 §1.5' 격상 결정: AI 의 commit 권한도 회수. file 편집 + sandbox clone commit 까지만. host repo 의 add/commit/push 는 사용자 터미널 만. CLAUDE.md §1.5 1줄 수정 = 24th 첫 작업."
    - "23번째 commit message 전달 패턴: heredoc inline (`git commit -F - << EOF ... EOF`) 우선, outputs/COMMIT-MSG-*.txt 는 fallback only. outputs path relative 사고 (cd ~/agent_architect 후 outputs/... 안 잡힘) 계기. RECOVERY.md / 인수인계 문서에 heredoc block 직접 포함."
    - "23번째 commit 명명 표준 명문화: wip(NNth/scope/step): ... / WU-N: ... (final) / WU-N.1: ... (refresh) / release: vX.Y.Z-mvp / sync(stable): <sha> / chore(NNth/scope): .... CLAUDE.md §8 + 본 운영 규칙 양쪽 SSoT."
    - "24번째 §1.5' 격상 (commit-manual): AI commit 권한도 회수. CLAUDE.md §1.5 1줄 수정 완료 (file 편집 + sandbox file:// clone 안 commit 까지만, host repo add/commit/push 모두 사용자 터미널 만). P-08 (fuse-bypass-cp-a-broken) 사고 방지 + 23rd 결정 자연 적용."
    - "24번째 domain_locks 신설 (도메인 sub-mutex): §1.12 mutex 의 도메인 단위 확장. 6 도메인 (D-A WU-24, D-B WU-31, D-C WU-30, D-D meta-logs, D-E meta-retro, D-F HANDOFF) + 양방향 2 (D-D, D-E forward/reverse). priority 1~6 + TTL 30분 + cross-dependency (D-B depends on D-A.next_step >= 6). 동시 세션 race 0 보장 — 실무 협업 패턴 (도메인 분리 + 순차 step + 양방향 메타). files_scope 거의 disjoint."
    - "24번째 본 conversation 세션 mutex 안 잡음: 24th 정리 only. current_wu_owner=null. scheduled run 들이 mode=user-active-deferred 로 picking up. 1:00 AM hourly scheduled task 등록. domain_locks 가 actual lock primitive — 사용자 결정 D3/D6/D7 수신 + §1.5' 1줄 수정 + scheduled task description 작성 + PROGRESS 갱신 의 정리 작업만."
    - "24번째 사용자 결정 3건 resolved: D3 dual-track 유지 (single 전환 영향범위 큼 → 보류) / D6 WU-31 spec default 4건 모두 OK (allowlist 8파일 + checksum sha256 + commit msg 표준 + Phase timing) / D7 #14 dialog-branch.schema.yaml 신설 (A 채택, 우선순위 낮음) — D7 #18/#19 는 W10 schema 작업 시 자연 처리."
    - "24번째 1 micro-step only 원칙: scheduled run 매 사이클 = 1 micro-step (5~10분). TTL 30분 안 끝나게 micro 단위. R3 PROGRESS overwrite race 자동 차단."
  version: 12   # v11 (23rd 종료) → v12 (24th: §1.5' + domain_locks + 본 세션 mutex 안 잡음 + 사용자 결정 D3/D6/D7 = 운영 규칙 21~26 추가)
---

# PROGRESS — live snapshot (23번째 세션 dazzling-sharp-euler, WU-31 신설 spec only / WU-24 current 유지)

> 🚨 **본 파일 최우선 진입.** mutex **claimed by dazzling-sharp-euler** (mode=user-active). 22nd (`adoring-trusting-feynman`) 정상 종료 + 23rd self claim 완료.
> **23rd 핵심**: 사용자 결정 = 배포 자동화 옵션 β (로컬 sh 우선, GitHub Action 후속 Phase 1+2 별도 WU). 명시 "계획만 만들어 둬" → **WU-31 (Release tooling Phase 0) 신설** — frontmatter + 본문 §0~§8 spec only. 실 bash 3 sh (`cut-release.sh` + `sync-stable-to-dev.sh` + `check-drift.sh`) + `.visibility-rules.yaml` 갱신은 다음 세션 또는 사용자 컨펌 후. dual-track / single-track OSS 전환 결정 = 보류 (영향범위 인지, 추후 재개).
> **current_wu = WU-24 유지** — 23rd 가 변경 안 함 (사용자 변경 지시 없음). 활성 WU = WU-24 + WU-30 + WU-31 (모두 pending, spec only).
> **22nd 핵심 (직전 세션, 보존)**: gates.md 신설 + CLAUDE.md §1.14 ≤200 lines 메타 규칙 + §14 분리 + WU-23 §7 7항목 resolved + WU-30 + WU-24 entry. 22nd 종료 commit cb1d85a (release: mutex 자연 release).
> release 로드맵 (β bundle): 0.3.0-mvp (#1+#4+#6) → 0.3.x patch (#5) → 0.4.0-mvp (#2+#3) → 0.5.0-mvp (#7) → 0.6.0-mvp (#8). **WU-31 cut-release.sh 첫 활용 = 0.3.0-mvp release cut 직전**.
> **23rd 세션 ahead = +1~2** (WU-31 신설 wip + 본 PROGRESS final). 22nd 분은 cb1d85a 까지 사용자 push 완료 (entry 시 ahead 0 확인). 사용자 push 는 §1.5 정합 사용자 터미널.

---

## ① Just-Finished

### 23번째 세션 (dazzling-sharp-euler, user-active, 2026-04-25 23:43 KST → 진행 중, WU-31 신설 spec only)

**사용자 발화 흐름**:
1. "23번째 세션 ㄱㄱ 하기 전에 ... 지금 여기서 개발한걸 solon에 적용을 시켜야되는데 적용하는 방식이 배포방식이 아니라 복붙인가?? 배포하는 방식으로 바꿔야되는데 어떻게 바꾸지?" — 23rd 사전 컨텍스트 질문
2. AI 정리 응답 = 현 상태 (R-D1 policy + tooling 0) + 옵션 A/β/γ + Phase 분할 spec
3. "음 근데 굳이 이걸 내가 비공개로 해야될까 ... 그냥 오픈소스로 공개하고 ... 상품화가 힘들거 같음" — single-track OSS 전환 시사
4. AI 영향범위 정리 = §2 dual-track / §7 visibility 3-tier / 라이선스 결정 stack 등
5. "그럼 그냥 배포방식만 재정의 하고 가자 영향범위가 이정도로 클줄은 몰랐네 ... 깃헙에 push가 되면 트리거가 돼서 solon-mvp 레포에도 적용이 되게 ... 아니면 sh로 직접 ...?" — track 단일화 보류 + 배포 자동화 question
6. AI 정리 응답 = 본 케이스 특수성 4가지 + Phase 분할 (β default) + γ 하이브리드
7. **"그래 깃헙은 나중에 지금은 sh로 하는게 맞겠다 계획만 만들어 둬"** — 23rd 결정 final: 옵션 β + spec only 명시

**23rd 결과** (현 본 PROGRESS 갱신 시점, 1 wip commit + 본 PROGRESS final 예정):

- **WU-31 신설** — `sprints/WU-31.md` (frontmatter `status: pending` + 본문 §0~§8 spec). title: "Release tooling Phase 0 — local sh (cut-release + sync-stable-to-dev)". visibility: business-only. decision_points 0 (의미 결정은 23rd 사전 resolved). related_wu: WU-22 / WU-30 / WU-24~26 명시.
  - **§1 Phase 분할** — Phase 0 (본 WU 로컬 sh) / Phase 1 (후속 WU-32 GitHub Action 알림) / Phase 2 (후속 WU-33 tag trigger). 각 phase 승급 = 1~2 사이클 운영 검증 통과 시.
  - **§2 cut-release.sh 사양** — `--version X.Y.Z-mvp` 필수 + `--dry-run` default. visibility filter 적용 (allowlist + APPLY-INSTRUCTIONS.md 제외 hard-coded blocklist). VERSION/CHANGELOG bump + git commit + tag (push 안 함, §1.5 정합).
  - **§3 sync-stable-to-dev.sh 사양** — hotfix path. `--stable-sha <sha>` + `--dry-run` default. stable → dev cp + git add (commit msg `WU-31/sync(stable): <sha>` 표준).
  - **§4 .visibility-rules.yaml allowlist 갱신** — 22nd PROGRESS ③ 3.3 (f) 해소: `.claude/agents/**` (business-only) + `gates.md` (oss-public) + `solon-status-report.md` (raw-internal) + agent_architect 루트 stub (raw-internal) + Phase 2 enforcement_active=true.
  - **§5 (선택) check-drift.sh** — release cut 직전 dry-run preview helper.
  - **§6 R-D1 + visibility 메모** — sh 들 자체는 stable 동봉 안 함 (운영자 도구). OSS fork 동봉 결정은 후속.
  - **§7 본 WU 진행 체크리스트** — row 4~12 = 다음 세션 또는 사용자 컨펌 후 (실 bash + dry-run sandbox).
  - **§8 결론 / 다음 발화** — 23rd 세션 default_action 후보 (a/b/c/d) 정리.

- **sprints/_INDEX.md 갱신** — frontmatter `updated` + 활성 WU 섹션에 WU-31 row 추가 (WU-24 + WU-30 + WU-31 = 3개 모두 pending). 23rd 결과 narrative 추가.

- **PROGRESS.md (본 파일) 다중 덮어쓰기** —
  (a) frontmatter `last_overwrite` 갱신 + `session` narrative 23rd 진입 + `current_wu_owner` claim (`session_codename: dazzling-sharp-euler`, `mode: user-active`, `current_active_intent` 명시)
  (b) `scheduled_task_log` 23rd entry append (rolling N=20 = 11 entries kept, helper 호출 예정)
  (c) `resume_hint` v8 → **v9** (default_action 에 WU-31 step-1 entry 옵션 추가, 대안 메뉴 (b)~(j) 재정렬, dual-track 전환 (j) 신설, version 9 갱신)
  (d) safety_locks 23rd 추가 2건 (spec-only WU 패턴 + release tooling 결정 원칙)
  (e) 본문 헤더 narrative 23rd 진입 갱신 (22nd 핵심 보존)
  (f) ① Just-Finished 본 섹션 추가
  (g) ② In-Progress 갱신 (current_wu = WU-24 유지 명시 + WU-31 추가)
  (h) ③ Next 우선순위 갱신 (WU-31 step-1 옵션 추가, dual-track 전환 보류 항목 (h) 추가)
  (i) ④ Artifacts 4.0 (23rd 신설) 추가

- **사용자 결정 영역 — 의미 결정 0건 본 세션**:
  - (a) 옵션 β 배포 방식 = 사용자 직접 결정 (AI 는 trade-off 정리만)
  - (b) "계획만 만들어 둬" 명시 = 사용자 직접 지시 (AI 는 spec only 진행)
  - (c) dual-track / single-track OSS 전환 = 사용자 보류 결정 (추후 재개)
  - (d) **병렬 ㄱㄱ** = 사용자 결정 (24th 에서 WU-24 + WU-31 둘 다 진행)
  - (e) **가상화 = 단기 α 변형 (sandbox file:// clone) + 장기 ε (VM)** = 사용자 직접 결정. 즉 24th 부터 claude 는 host `.git` mutate 안 함.
  - (f) **§1.5' commit-manual 격상** = 위 (e) 의 자연 귀결. CLAUDE.md §1.5 1줄 수정 = 24th 첫 작업.

- **23rd 후반 사고 (P-08 후보)** — `.git/index.lock` 0-byte stale 충돌 → §1.6 FUSE bypass `cp -a .git` 패턴 시도 → cp 단계에서 .git 일부 누락 (FUSE 마운트 특성) → `rsync back --delete` 가 깨진 .git 으로 host 덮어씀 → `refs/heads/main` 옛 commit `54ac583` 으로 회복. **복구 완료**: ref 직접 덮어쓰기 + `GIT_INDEX_FILE` 우회 read-tree 로 깨끗한 index 재생성. **단 commit 자체는 못 함** (.git/index.lock unlink FUSE 거부) → 사용자 manual 필요.

- **outputs/23rd-session-backup/ 백업 4 파일** — `WU-31.md` / `_INDEX.md` / `PROGRESS.md` / `RECOVERY.md` (manual 복구 절차 + commit 명령). 사용자 mac 에서 work tree 가 살아있다면 그대로 add+commit+push, 죽었다면 백업에서 복원.

**규율 준수**:
- §1.3 self-validation (의미 결정 0, 모두 사용자 사전 결정) ·
- §1.4 Option β default (Phase 분할 minimal cleanup, push-trigger 즉시 자동화 안 함) ·
- §1.5 push 금지 (commit 까지만) ·
- §1.6 FUSE bypass (commit 시 발동 시 자동 적용) ·
- §1.7 escalation (dual-track 전환 보류 = ⚠️ marker 후 사용자 결정 대기, 본 PROGRESS ③ 3.3 (j) 으로 이관) ·
- §1.8 매 step PROGRESS heartbeat 갱신 ·
- §1.12 mutex (claim, mode=user-active, ttl 15분) ·
- §1.13 R-D1 (WU-31 본문 자체가 R-D1 spec 정합 — sh 들이 dev-first / stable hotfix sync-back 의 backbone) ·
- §1.14 ≤200 lines (CLAUDE.md 본 세션 미접촉, 167 lines 유지)

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

**current_wu = WU-24 (유지)** — 23rd 가 변경 안 함 (사용자 변경 지시 없음). #1 sfs slash 구현 part 1 (`/sfs status` + `/sfs start`). frontmatter + 구현 spec (§0~§6) 작성 완료. 실 bash 구현 (§5 체크리스트 row 5~11): **row 5 완료** (24th 사이클 1번째 scheduled run `friendly-magical-galileo`, 2026-04-26T01:11:30+09:00 — sfs-common.sh 293 lines, T1~T8 smoke OK, dev path `.sfs-local-template/scripts/`) + **row 6 완료** (24th 사이클 4번째 scheduled run `brave-gifted-thompson`, 2026-04-26T04:05:00+09:00 — sfs-status.sh 129 lines, T1~T8d 11개 smoke 전부 PASS, stale lock takeover 후 진행) + **row 7 완료** (24th 사이클 5번째 scheduled run `relaxed-gallant-maxwell`, 2026-04-26T05:10:00+09:00 — sfs-start.sh 182 lines, T1~T10 10개 smoke 전부 PASS, 자유 claim 후 진행, ISO week auto-id `2026-W17-sprint-1` 정합 확인) + **row 8 완료** (24th 사이클 6번째 scheduled run `cool-magical-volta`, 2026-04-26T06:12:00+09:00 — sprint-templates `{plan,log,review,retro}.md` 4파일 신설, 4파일 frontmatter 정합 (plan→`phase: plan`/`gate_id: G1`, log→`phase: do` no gate_id, review→`phase: review`/`gate_id: ""` for --gate G2|G3|G4, retro→`phase: retro`/`gate_id: G5`/`closed_at: ""`), gates.md §1/§2 + 05-gate-framework.md §5.1 SSoT pointer 명시, sfs-start.sh 통합 smoke T1~T4 PASS — auto-id `2026-W17-sprint-1` + 4 templates copy + events.jsonl sprint_start append + 단일 file 누락 시 exit 4 정합) + **row 9 완료** (24th 사이클 8번째 진입 = 사용자 user-active conversation `vigilant-fervent-dirac`, 2026-04-26T08:35:00+09:00 — `.claude/commands/sfs.md` adapter dispatch 추가, 75줄 diff vs HEAD 3ca7f56, 정합 검증 7항목 PASS — frontmatter 보존 / `## Adapter Dispatch (status / start) — execute first` 섹션 + 5단계 절차 / dispatch table 2 row (consumer-side `.sfs-local/scripts/sfs-{status,start}.sh`) / exit code mapping (status: 0/1/2/3/99 + start: 0/1/4/5/99) / empty `$ARGUMENTS`→status default / WU22-D4 SSoT 명시 / Rules `bash adapter is authoritative`. fallback only 명시 — Claude-driven mode 는 status/start 외 7개 + script missing 시만) + **row 10 완료** (24th 사이클 9번째 scheduled run `blissful-modest-goldberg`, 2026-04-26T09:11:00+09:00 — `solon-mvp-dist/VERSION` 4 lines (1 data + 3 comment 예약, install.sh L293/L380 head -1 정합 검증 PASS) + `solon-mvp-dist/CHANGELOG.md` `## [0.3.0-mvp] — Unreleased (예약, WU-31 cut 대기)` 섹션 prepend, 0.2.4-mvp 위에. Added 7항목 + Changed 2항목 + Notes 2항목. β bundle 매핑 (#1 + #4 + #6) 명시. **D-B-WU-31 cross-dep 충족** = next_step 7 ≥ 6, 다음 scheduled run 부터 D-B claim 가능) + **row 11 완료** (24th 사이클 10번째 scheduled run `friendly-serene-galileo`, 2026-04-26T10:14:00+09:00 — dry-run sandbox `/tmp/wu24-dry-friendly-serene-galileo/fake-consumer/` 통합 검증. **gap 발견 + fix 같은 micro-step**: install.sh §7 이 `.sfs-local-template/scripts/` + `.sfs-local-template/sprint-templates/` 를 copy 안 함 → adapter dispatch path mismatch 결과 → install.sh §7 끝부분에 2 블록 추가 (scripts/ overwrite + chmod +x / sprint-templates/ overwrite, 13 lines). bash -n PASS. 통합 smoke T1~T9 전부 PASS — T1 status no sprint exit 0 / T2 start auto-id `2026-W17-sprint-1` 4 templates copy + events.jsonl sprint_start append exit 0 / T3 post-start status populated exit 0 / T4 install 재실행 idempotent (기존 sprint dir + events 보존) / T5 --color=always ANSI / T6 --color=never plain / T7 동일 id no --force exit 1 / T8 --force overrides exit 0 / T9 install 재실행 후 sprint dir + events 2 lines 보존). 남은 row 12~13 = WU-24 frontmatter status=done + closed_at + final_sha + sprints/_INDEX.md row + commit. domain_locks D-A-WU-24.next_step = 8. **D-B-WU-31 cross-dep 충족** (8≥6) — 다음 scheduled run 부터 D-A row 12 또는 D-B row 4 양쪽 priority 검토.

**WU-30** (F-04 fix, pending) — frontmatter + 작업 plan §0~§5 only. 실 정규식 fix (`[A-Z]{2,}`) + 검증기 분리 (`verify-install.sh` 신설) 다음 세션.

**WU-31 (23rd 신설, pending)** — Release tooling Phase 0 (로컬 sh). frontmatter + 본문 §0~§8 spec only. 실 bash 3 sh (`cut-release.sh` + `sync-stable-to-dev.sh` + `check-drift.sh`) + `.visibility-rules.yaml` allowlist 갱신 + `scripts/_README.md` 신설 + dry-run sandbox `/tmp/wu31-dry/` 검증 = §7 체크리스트 row 4~12 다음 세션.

**활성 WU = 3 (모두 pending, 모두 spec only — 실 코드 0)**:
- WU-24 (`current_wu`, sfs slash) — 22nd 신설
- WU-30 (F-04 fix) — 22nd 신설
- WU-31 (release tooling) — 23rd 신설 (본 세션)

mutex: **claimed by dazzling-sharp-euler** (mode=user-active, ttl 15분). 23rd 본 세션 종료 시 자연 release 판단 (사용자 명시 종료 또는 작업 완료 시점).

---

## ③ Next

> **23rd 세션 = WU-31 신설 spec only (계획만)**. 22nd 8 step batch 의 산출물 + WU-23 §7 사용자 결정 7항목 모두 resolved 유지. **사용자 결정 대기 = 0건** (23rd 세션도 의미 결정 0).

### 3.1 사용자 답변 대기 — 0건

23rd 세션도 의미 결정 0 (사용자 옵션 β 결정 + "계획만" 명시 사전 수신). 22nd §7 7항목 + 23rd 결정 모두 resolved.

### 3.2 다음 세션 우선순위

> **23rd 사용자 결정 = "병렬 ㄱㄱ"**: 24th 에서 WU-24 + WU-31 둘 다 진행 (한 세션에 한 개는 실 bash 구현 + 다른 한 개는 spec 정합성 검증). 추천 순서 = WU-24 우선.
> **23rd 사용자 결정 = sandbox file:// clone 패턴 + §1.5' commit-manual 격상**: 24th 첫 작업 = CLAUDE.md §1.5 1줄 수정 + sandbox clone setup (`git clone file://$SRC /tmp/work-24-clone`) + 그 안에서 git 작업.

0. **(prereq, 사용자 manual)** 23rd 미완 commit 마무리 — `rm -f .git/index.lock` + `git add 3 files` + `git commit -F outputs/23rd-session-backup/COMMIT-MSG.txt` + `git push origin main`. RECOVERY.md 참조.
1. **CLAUDE.md §1.5 1줄 수정** (24th 첫 작업) — "AI 는 file 편집 + sandbox file:// clone 안 commit 까지만, host repo 의 add/commit/push 는 사용자 터미널 만". 즉 §1.5'.
2. **sandbox clone setup** — `git clone file://$SRC /tmp/work-24-clone` + cwd 그 안으로. 모든 git 작업 거기서.
3. **WU-24 step-1 entry** (병렬 default) — ~~`sfs-common.sh`~~ ✅ 24th 사이클 1번째 `friendly-magical-galileo` 완료 (2026-04-26T01:11:30+09:00, 293 lines, T1~T8 smoke OK, path `.sfs-local-template/scripts/`) + ~~`sfs-status.sh`~~ ✅ 24th 사이클 4번째 `brave-gifted-thompson` 완료 (2026-04-26T04:05:00+09:00, 129 lines, T1~T8d 11개 smoke 전부 PASS, stale lock takeover) + ~~`sfs-start.sh`~~ ✅ 24th 사이클 5번째 `relaxed-gallant-maxwell` 완료 (2026-04-26T05:10:00+09:00, 182 lines, T1~T10 10개 smoke 전부 PASS) + ~~sprint-templates 4 신설~~ ✅ 24th 사이클 6번째 `cool-magical-volta` 완료 (2026-04-26T06:12:00+09:00, 4 파일 frontmatter 정합 + 통합 smoke PASS) + ~~adapter dispatch (.claude/commands/sfs.md)~~ ✅ 24th 사이클 8번째 user-active `vigilant-fervent-dirac` 완료 (2026-04-26T08:35:00+09:00, 75줄 diff vs HEAD, 정합 검증 7항목 PASS, fallback only 명시) + ~~VERSION/CHANGELOG entry~~ ✅ 24th 사이클 9번째 `blissful-modest-goldberg` 완료 (2026-04-26T09:11:00+09:00, VERSION 4 lines + CHANGELOG `## [0.3.0-mvp] — Unreleased` prepend, β bundle 매핑) + ~~dry-run sandbox 검증 (`/tmp/wu24-dry/`)~~ ✅ 24th 사이클 10번째 `friendly-serene-galileo` 완료 (2026-04-26T10:14:00+09:00, install.sh gap fix 13 lines + 통합 smoke T1~T9 전부 PASS). **다음 scheduled run = WU-24 row 12 (frontmatter status=done + closed_at + final_sha) 또는 D-B-WU-31 row 4 (cut-release.sh)** — D-A-WU-24.next_step=8. **D-B-WU-31 cross-dep 충족** (8≥6) → priority 1 vs 2 비교 = D-A row 12~13 close 가 더 빠르고 가벼움 (권장).
4. **WU-31 step-1 entry** (병렬, WU-24 와 동시 또는 sub-step 단위 교차) — `cut-release.sh` + `sync-stable-to-dev.sh` + (선택) `check-drift.sh` 실 bash + `.visibility-rules.yaml` allowlist 갱신 + `scripts/_README.md` + dry-run sandbox (`/tmp/wu31-dry/`).
5. **결과 export** — sandbox clone 안 commit 들을 `git format-patch` 로 outputs/ 백업 + 또는 `file://` push back to host (host .git lock 정상 시).
6. **사용자 commit + push** — host repo 에서 사용자가 patch apply (또는 file:// push 받은 후) commit + push.
7. **WU-30 진행** — F-04 정규식 fix + 검증기 분리. WU-24/WU-31 가 안정되면 병렬 추가.
8. **Claude Code 재시작** — P-05 fallback A 졸업.

### 3.3 미해결 후속 (non-block, 정보)

- (a) Phase 1 킥오프 D-day 2026-04-27 월 (D-2 기준). 사용자 본인 Mac 직접 진행.
- (b) ~~sync/cut-release 자동화 (0.4.0-mvp 예약)~~ → **WU-31 spec 신설 완료 (23rd)**, 실 bash 구현 다음 세션. Phase 1+2 (GitHub Action) 는 WU-32/WU-33 후속.
- (c) 11~23번째 세션 retrospective 실체화 (누적 13건, 23rd 포함).
- (d) HANDOFF-next-session.md mutex_state_schema 재sync (22nd 결정 7항목 + WU-24/WU-30/**WU-31** entry 반영).
- (e) P-04 / P-05 / P-06 / P-07 / **P-08 / P-09 후보** learning logs 실체화 (`learning-logs/2026-05/`):
  - P-04 = session-hang takeover (WU-22 §7 표준)
  - P-05 = agent-loader-startup-only (Claude Code mid-session reload 안 됨, fallback A 패턴)
  - P-06 = claude-md-line-limit-meta-rule (22nd 신설, §1.14 + §14 분리 사례)
  - P-07 (23rd 후보) = release-tooling-phased (push-trigger 자동화 vs 로컬 sh 우선)
  - **P-08 (23rd 후반 후보) = fuse-bypass-cp-a-broken** — `cp -a $SRC/.git $TMP/` 가 FUSE 마운트 위에서 일부 파일 누락 + `rsync back --delete` 가 깨진 .git 으로 host 덮어씀. 21st 작동, 23rd 깨짐 — 환경/race 의존. 24th 부터 cp -a 우선순위 ↓, low-level (GIT_INDEX_FILE / write-tree / commit-tree / update-ref) 우선. cp -a 사용 시 sanity (`git -C $WORKDIR log -1`) 필수, rsync `--delete` 절대 금지.
  - **P-09 (23rd 사용자 결정) = sandbox-file-clone-isolation** — claude 가 host `.git` mutate 안 함, `git clone file://$SRC /tmp/work-NN-clone` 으로 격리, 결과는 patch 또는 push back. host 0 mutation 보장 → P-08 류 사고 원천 차단. 단기 채택, 장기 ε VM 으로 발전.
- (f) `.visibility-rules.yaml` scope 확장 — **WU-31 §4 spec 그대로**, 실 적용은 WU-31 step-1 시.
- (g) W10 결정 세션 — `cross-ref-audit.md §4` #14/#18/#19 (23rd 미접촉).
- (h) **dual-track / single-track OSS 전환 재논의** (23rd 보류 결정) — §2 dual-track 폐기 + §7 visibility 3-tier → 2-tier + 라이선스 (MIT/Apache-2.0/AGPL/BSL) + 거버넌스 (CONTRIBUTING/CoC) + public repo 공개 절차. 사용자 직감 "상품화 힘듦" 의 근거 (a 확신 / b 직감 / c 시점) 명료화 후 재개.
- (i) WU-16b 확장 이관.
- (j) resume-session-recover.sh (P-03 후속 자동화).
- (k) WU-25 entry (#1 sfs slash 구현 part 2 = `/sfs plan` + `/sfs review`) — gates.md §3 사용.
- (l) WU-26 entry (#1 sfs slash 구현 part 3 = `/sfs decision` + `/sfs retro`) — 하이브리드 mini-ADR template + `--close` auto commit.
- (m) WU-27 (#4 events.jsonl schema 표준화) + WU-28 (#6 Sprint cycle CLI helper) — 0.3.0-mvp 번들 마무리.
- (n) WU-29 (#5 ADR helper) — 0.3.x patch 시 분리.
- (o) **WU-32 (Phase 1 GitHub Action drift 알림)** — WU-31 실 구현 + 1~2 사이클 운영 검증 후 신설.
- (p) **WU-33 (Phase 2 release tag trigger 자동화)** — WU-32 검증 후 신설.

---

## ④ Artifacts (23번째 세션 진행 시점)

### 4.0 23rd 신설/갱신 산출물

| 산출물 | 경로 | 상태 / sha |
|--------|------|:-:|
| **sprints/WU-31.md** | `2026-04-19-sfs-v0.4/sprints/WU-31.md` | ✨ **23rd 신설** (sha TBD) — Release tooling Phase 0 (로컬 sh) spec only. frontmatter (status: pending, decision_points 0, visibility business-only) + 본문 §0~§8 (Phase 분할 + cut-release 사양 + sync-stable-to-dev 사양 + check-drift + .visibility-rules.yaml 갱신 + R-D1 메모 + 체크리스트 + 결론). 실 bash 다음 세션. |
| **sprints/_INDEX.md** | — | ✅ **23rd 갱신** — frontmatter `updated` + 활성 WU 섹션에 WU-31 row 추가 (WU-24 + WU-30 + WU-31 = 3 pending). 23rd 결과 narrative 추가. |
| **PROGRESS.md (본 파일)** | — | ✨ **23rd 다중 덮어쓰기** — frontmatter (`current_wu_owner = dazzling-sharp-euler` mode=user-active claim, `last_overwrite` + `last_heartbeat`, `scheduled_task_log` 23rd entry append, `resume_hint` v8 → **v9** with WU-31 옵션 + dual-track 재논의 항목, safety_locks 23rd 2건 추가) + 본문 헤더 narrative + ① Just-Finished 23rd 섹션 + ② current_wu 유지 + WU-31 추가 + ③ Next 우선순위 갱신 (WU-31 step-1 + WU-32/WU-33 후속 명시) + ④ 본 4.0 섹션. |

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

## 운영 규칙 (23rd 세션까지 누적)

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
14. **spec-only WU 패턴** (23rd 확립): 사용자 "계획만 만들어 둬" 명시 시 frontmatter + 본문 spec 만 신설, 실 코드 (bash/python 등) 작성 금지. 실 구현은 다음 세션 또는 사용자 컨펌 후. 22nd WU-24/WU-30 + 23rd WU-31 동일 패턴. 의미 결정 0 + 실 구현 0 = "기록 + spec" 만 남기는 가벼운 WU 전환 방법. token 비용 제어 + 결정 stack 정리에 유리.
15. **release tooling Phase 분할 원칙** (23rd 확립): 본 docset 의 dev↔stable 배포 자동화는 (a) Phase 0 = 로컬 sh / (b) Phase 1 = GitHub Action 알림만 / (c) Phase 2 = release tag trigger. 각 phase 승급 = 1~2 사이클 실 운영 검증 통과 시. push-trigger 즉시 자동화 안 하는 이유 = §1.5 push manual 정합 + raw-internal leak 방지 + 1인 운영 비용. P-07 후보.
16. **§1.6 FUSE bypass cp -a 신뢰도 약화** (23rd 후반, P-08 후보): cp -a $SRC/.git $TMP/ 가 FUSE 마운트 위에서 일부 .git 파일 누락 가능 (race 또는 FUSE 권한). 21st 사례에서는 작동했지만 23rd 에서 깨짐 → 환경/타이밍 의존. 24th 부터 cp -a 패턴 우선순위 ↓, GIT_INDEX_FILE / write-tree / commit-tree / update-ref low-level 우회 우선. cp -a 사용 시 직후 sanity (`GIT_DIR=$WORKDIR git log -1` HEAD 검증 필수). rsync back 시 `--delete` 옵션 절대 금지 (host .git 손실 위험).
17. **sandbox file:// clone 패턴** (23rd 사용자 결정 = α 변형 = β 보강, 24th 부터): claude 가 host `.git` 직접 mutate 안 함. 진입 시 `git clone file://$SRC /tmp/work-NN-clone` 으로 깨끗한 sandbox clone 생성. 모든 git 작업은 clone 안에서, 결과는 patch (`git format-patch`) 또는 `file://` push back. host filesystem 0 mutation 보장 → P-08 류 사고 원천 차단. file 편집 자체는 host work tree 직접 OK (사용자 commit 위해). **§1.5' 격상 (commit + push 모두 사용자 manual)** 와 함께 24th 첫 작업으로 CLAUDE.md §1.5 1줄 수정.
18. **장기 ε VM 검토 항목** (23rd 사용자 장기 결정): UTM/Multipass/Lima 등 VM 안에서 cowork 자체 동작 → host filesystem 과 완전 분리 → FUSE 류 race/lock 문제 자체 부재. 0.5.0-mvp 또는 1.0 시점 도입 검토. 비용 = VM 셋업 + cowork-VM compatibility 검증 + 사용자 학습. 단기 = 17번 sandbox file:// clone 으로 충분, ε 는 후속.
19. **commit message 전달 패턴** (23rd 후반 사용자 결정 — outputs path 사고 계기): claude 가 commit message 초안 만들 때:
    - **우선 = heredoc inline 형식** (`git commit -F - << 'EOF' ... EOF`) — 사용자 mac 터미널에서 그대로 복사 붙여넣기. relative path 충돌 없음. RECOVERY.md / 인수인계 문서에 직접 포함.
    - **fallback = outputs/COMMIT-MSG-*.txt 백업** — long message 보존 + 시나리오 B/C (work tree 죽음) 시 backup 에서 복원용. 단 사용자가 절대 path quote 사용해야 함 (공백 포함 path).
    - outputs/COMMIT-MSG-*.txt 만 만들고 heredoc 안 보여주는 건 anti-pattern (23rd 사고 = `cd ~/agent_architect` 후 `outputs/...` relative path "No such file or directory").
    - 짧은 message (< 5 lines) 는 `git commit -m "..."` inline OK, 긴 message 는 heredoc 우선.
20. **commit 명명 표준** (CLAUDE.md §8 정합 + 본 PROGRESS 운영 규칙 명문화):
    - **wip commit** (세션 안 micro-step) = `wip(<NNth>/<scope>/<step-or-tag>): <요약>` 또는 `wip(WU-<id>/step-<n>/<tag>): <요약>` (CLAUDE.md §8 v1 형식 호환). 예: `wip(23rd/wu31-create): WU-31 신설`, `wip(22nd/step8/progress-final): ...`.
    - **final commit** (WU 완료, squash 후) = `WU-<id>: <제목>`. 예: `WU-15: Workflow v2 인프라 설정`.
    - **refresh commit** (sha backfill) = `WU-<id>.1: <제목> forward sha backfill`. squash 제외.
    - **release commit** (cut-release.sh 산출, WU-31 spec) = `release: <version>` 또는 `release(stable): <version>`. 예: `release: 0.3.0-mvp`.
    - **sync commit** (R-D1 hotfix back-port, WU-31 spec) = `sync(stable): <stable-sha>` 또는 `WU-31/sync(stable): <stable-sha>`.
    - **chore commit** (mutex release, snapshot 등 운영) = `chore(<NNth>/<scope>): <요약>`. 예: `chore(22nd/release): mutex 자연 release`.
    - 본 표준은 §8 본문 + 본 운영 규칙 양쪽 SSoT (의미 동일, 운영 빈도 차이로 본 규칙이 quick reference).

---

**다음 세션 (24번째) 진입 체크리스트 (v1.4, 23rd 세션 WU-31 신설 반영)**:

1. `CLAUDE.md §1` + `§1.12` + `§1.13` + `§1.14 (≤200 lines)` 읽기 (총 14 규율).
2. `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh` 실행. **exit 0 예상**.
3. `PROGRESS.md` frontmatter `current_wu_owner` 확인. 23rd 자연 release 시 null + claim. 실 release 안 됐으면 §1.12 mutex 절차.
4. `git status` + `git rev-list --count origin/main..HEAD` 확인. **23rd 종료 시점 예상 ahead = +1~2** (WU-31 신설 + 본 PROGRESS final). 사용자 터미널 push 후 0.
5. **default = WU-24 step-1 entry** (resume_hint v9 default_action 유지) — `sprints/WU-24.md §5` 체크리스트 row 5~10:
   - sfs-common.sh + sfs-status.sh + sfs-start.sh 실 작성
   - sprint-templates 4 (plan/log/review/retro) 신설
   - .claude/commands/sfs.md adapter dispatch 추가
   - VERSION + CHANGELOG 0.3.0-mvp 예약 entry
   - dry-run sandbox `/tmp/wu24-dry/`
5'. **alt = WU-31 step-1 entry** (23rd 신설 spec 그대로 실 bash 구현):
   - `scripts/cut-release.sh` 신설 (정방향, dry-run default)
   - `scripts/sync-stable-to-dev.sh` 신설 (역방향, hotfix path)
   - `scripts/check-drift.sh` 선택 신설
   - `.visibility-rules.yaml` allowlist 갱신 (WU-31 §4)
   - `scripts/_README.md` 신설/갱신
   - dry-run sandbox `/tmp/wu31-dry/`
6. **사용자 결정 대기 = 0건** (23rd 세션 의미 결정 0). 추가 결정 필요 시 ⚠️ marker + escalate.
7. **Claude Code 재시작 후 native subagent_type=generator/evaluator/planner** 호출 가능 (P-05 fallback A 졸업).
8. **D-day = 2026-04-27 월 (D-2 → 다음 세션 시점에 따라 D-1 또는 당일)** — 사용자 본인 Mac 실행. PHASE1-MVP-QUICK-START.md §2 runbook.
9. WU 완료 시 본 PROGRESS.md 즉시 덮어쓰기 + commit (FUSE bypass 자동 적용 허용).
10. **dual-track / single-track OSS 전환 결정** = 23rd 보류. 사용자가 "상품화 힘듦" 근거 (a 확신 / b 직감 / c 시점) 명료화 + 결정 시점 = 0.3.0-mvp release 직전 또는 추후. 추후 재개 시 WU 신설 (가칭 WU-XX "track 단일화 + license + governance").

**23번째 세션 종료 시점 핵심 메시지** (다음 세션 한 줄 요약, v2):

> **사용자 23rd 결정 6항목**: (a) 배포 자동화 옵션 β (로컬 sh 우선, GitHub Action 후속) + (b) "계획만 만들어 둬" (spec only) + (c) WU-24 + WU-31 **병렬** (24th default) + (d) **sandbox file:// clone 패턴** 채택 (α 변형 = β 보강, 24th 부터 claude host .git mutate 안 함) + (e) **§1.5' 격상** (commit + push 둘 다 사용자 manual, CLAUDE.md 1줄 수정 = 24th 첫 작업) + (f) 장기 ε VM 검토 항목.
> **23rd 사고 (P-08 후보)**: §1.6 FUSE bypass cp -a 깨짐 → ref/index 복구 완료, **commit 자체는 사용자 manual 필요** (.git/index.lock unlink FUSE 거부). outputs/23rd-session-backup/ 4 파일 백업 (WU-31.md / _INDEX.md / PROGRESS.md / RECOVERY.md).
> **24th 진입 신호** = "이전 세션 이어서 ㄱㄱ" — resume_hint v10 의 default_action 자동: ① 사용자 manual lock 제거 + commit + push (RECOVERY.md 절차) → ② sandbox clone setup → ③ §1.5 1줄 수정 → ④ WU-24 + WU-31 병렬.
> **활성 WU 3** (WU-24 + WU-30 + WU-31, 모두 pending spec only). git ahead = 사용자 manual 후 0.
