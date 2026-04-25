---
doc_id: handoff-2026-04-20-solon-v0.4-r3-complete
title: "인수인계 (Pointer Hub v3.0-reduced) — 사용자 지시 SSoT + 참조 허브"
version: 3.5-reduced
created: 2026-04-20
updated: 2026-04-25 (17번째 세션 admiring-fervent-dijkstra scheduled auto-resume: mutex_state_schema sync + append-scheduled-task-log.sh helper 신설 + check.sh v0.3 반영)
author: "Claude (direct 지시 by 채명정)"
valid_until: "WU 규율 유지되는 동안 계속 (현재 상태는 PROGRESS.md, 이관은 sprints/_INDEX.md, 본 파일은 frontmatter + §0 사용자 지시 원문 SSoT 역할)"
status: "Pointer hub. 현재 상태는 PROGRESS.md 참조."
session_continuity_note: |
  Workflow v2 이관 (WU-15/16 계열) 및 HANDOFF/BRIEFING 축소 (WU-17) 완료. 본 파일은 더 이상
  상태 SSoT 가 아니며 (1) 사용자 지시 raw 텍스트 SSoT + (2) account_context 고정 사실 + (3)
  user_new_directive 아카이브 + (4) BLOCKED / Phase 2 포인터 역할만 한다. 현재 상태 확인은
  PROGRESS.md frontmatter / sprints/_INDEX.md / sessions/_INDEX.md 를 사용하라.
account_context:
  current: "회사 계정 (jack2718@green-ribbon.co.kr) — GitHub origin (MJ-0701/solon) 에 로컬 커밋 존재"
  will_move_to: "채명정 개인 계정 (약 1주 이내) — 계정 간 session fork 불가"
  fork_possible: false
  migration_strategy: "GitHub clone + sprints/_INDEX.md + sessions/_INDEX.md + WORK-LOG.md 기반 continuation"
  critical_rule: "README (root STOP&READ) + INDEX + 본 HANDOFF + WORK-LOG + sprints/ + sessions/ 가 유일한 cross-account 인수인계 채널"
queue_pointers:
  current_status: "→ PROGRESS.md frontmatter"
  active_wu: "→ PROGRESS.md current_wu + sprints/<id>.md"
  completed_wus: "→ sprints/_INDEX.md (v2 native + 이관 + v1 형식 3-섹션)"
  session_retrospectives: "→ sessions/_INDEX.md"
  unpushed_commits: "→ PROGRESS.md ① Just-Finished + `git rev-list --count origin/main..HEAD`"
  blocked:
    - "WU-6: claude-shared-config/.git IP 경계 — 사용자 결정 필요"
  phase2_queue:
    - "WU-11 B: Claude-specific 파일 frontmatter layer: 필드 + agnostic 힌트 주석 (Phase 1 안정화 후)"
    - "WU-11 C: Codex / Gemini-CLI 어댑터 초안 (appendix/runtime-adapters/, Phase 2 Go/No-Go 후)"
    - "WU-16b: 앞선 WU (WU-0~5.1 / 8/8.1 / 11/12 시리즈) 확장 이관 (필요 시)"
  phase1_kickoff_date: "2026-04-27 (월) — PHASE1-KICKOFF-CHECKLIST.md §2 W0 선행 필요"
mutex_state_schema:
  # 세션 종료 시 여기에 기록 (PROGRESS.md 는 live mirror — authoritative source)
  # 17번째 세션 admiring-fervent-dijkstra 가 sync — 16번째 nice-kind-babbage → 17번째 로 교체.
  # 본 필드는 참조용. 최신 release 는 PROGRESS.md frontmatter.released_history.last_* 확인.
  # 16번째부터 scheduled_task_log (PROGRESS.md frontmatter) 가 hourly trace 의 SSoT.
  # 17번째부터 scripts/append-scheduled-task-log.sh helper 가 hourly trace append 의 표준 절차.
  last_released_session: admiring-fervent-dijkstra
  last_released_at: 2026-04-25T09:10:00+09:00
  last_released_reason: "17번째 세션 scheduled auto-resume. 16번째가 남긴 `TBD_16TH_SNAPSHOT` 토큰을 실체 sha `87b60ff` 로 backfill. 사용자 지시 '매 시 마다 스케줄 도니까 인수인계가 확실하게 자동화' 직접 처리: (1) scripts/append-scheduled-task-log.sh helper 신설 — hourly run 마다 한 줄 호출만으로 PROGRESS.md frontmatter scheduled_task_log 에 entry append + N=20 rolling 자동 enforce (race + 누락 방지). (2) resume-session-check.sh v0.2 → v0.3 — check #7 추가 (scheduled_task_log 첫 entry > 90분 시 exit 16, hourly cron 끊김 추적). (3) HANDOFF mutex_state_schema sync. 새 WU 착수 없음 (scheduled task 모드, 원칙 2 준수)."
  prior_sessions:
    - session: nice-kind-babbage  # 16번째, scheduled_task_log 신설 + check.sh v0.2 + cd41dff backfill
      released_at: 2026-04-25T07:30:00+09:00
    - session: admiring-nice-faraday  # 15번째, P-03 resolved + check.sh v0.1
      released_at: 2026-04-25T04:18:00+09:00
    - session: funny-pensive-hypatia  # 14번째, staged uncommitted (P-03 피해)
      released_at: 2026-04-25T00:20:00+09:00
    - session: funny-sweet-mayer  # 13번째
      released_at: 2026-04-24T23:15:00+09:00
user_new_directive:
  raw: "sfs를 claude 뿐만 아니라 codex랑 gemini-cli에서도 사용하고 싶거든?? 그래서 추상화 하는게 중요할듯?!"
  date: 2026-04-20
  implication: "Claude Code 에 암묵적으로 lock-in 된 현 docset 에 runtime abstraction layer 추가 필요"
  resolution: "WU-11 A (RUNTIME-ABSTRACTION.md 신설, 4cd07e6) 완료. WU-11 B/C 는 Phase 1 안정화 / Phase 2 Go/No-Go 이후 예약."
user_new_directive_16:
  raw: "난 지금 solon mvp(sfs 로 실행하는 단계)를 내 개인프로젝트랑, 새로시작할 프로젝트에서 사용하기 위해서 mvp 출시를 하겠다는거임 그래서 내가 repo 이름을 solon-mvp로 진행했던건데 프로젝트에서 sh로 임시 설치해서 사용할 수 있게 만들어 둔거면 내가 진행하고있는 사이드프로젝트, 그리고 앞으로 만들 신규 프로젝트에서 sh로 설치하면 되나?"
  date: 2026-04-24
  decisions_3:
    install_method: "둘 다 지원 (curl | bash + local ./install.sh)"
    conflict_handling: "대화형 prompt (s/b/o/d)"
    upgrade_mechanism: "upgrade.sh (VERSION 기반)"
  implication: "solon-mvp 정체 재정의: consumer project → SFS distribution. install.sh / upgrade.sh / uninstall.sh 필요. phase1-mvp-templates/ 은 distribution 에 재흡수."
  resolution: "WU-20 (amazing-happy-hawking 세션) — solon-mvp-dist/ staging + APPLY-INSTRUCTIONS.md 작성. 사용자 Mac 에서 로컬 solon-mvp repo 전환 apply 대기."
user_new_directive_17:
  raw: "ㄴㄴㄴ mvp는 배포버전이고 solon이 개발버전이어야 함 solon-mvp가 한마디로 stable 버전이어야 함"
  date: 2026-04-24
  context: |
    11번째 세션 (dreamy-busy-tesla) 에서 사용자 git log 확인 결과 solon-mvp stable 에
    이미 Codex CLI 작업 6 커밋 (0.1.1~0.2.4-mvp, `786900a`~`ac98497`) 이 merge+push 된
    상태 발견. staging (방금 만든 v0.2.0-mvp) 대비 stable 이 선행. 재조정 방향 3안
    제시 — (A) stable SSoT / (B) 양방향 reconcile / (C) staging mirror — 사용자 답.
  decision:
    dev_ssot: "solon (Solon docset 내 solon-mvp-dist/ staging)"
    stable_release: "solon-mvp (GitHub MJ-0701/solon-mvp, release cut 결과만)"
    flow_direction: "dev → stable (staging 검증 끝나면 release cut)"
  implication: |
    (1) dev 가 SSoT. Codex/Gemini CLI 에서 작업 시에도 dev 먼저 수정 → stable cut.
    (2) stable hotfix 는 예외 허용이지만 같은 세션 안에 staging 으로 back-port 커밋 필수.
    (3) 본 세션의 reverse back-port (stable→dev) 는 1회성 divergence 해소. 향후 재발
        방지를 위해 R-D1 규율 제안.
  resolution: |
    WU-20 Phase A Back-port 완료 — 14 파일 stable HEAD (`ac98497`) → dev staging 완전
    동기화 (checksum full match). learning-logs/2026-05/P-02-dev-stable-divergence.md
    실체화. R-D1 정식 채택 (CLAUDE.md §1 에 규칙 추가) 은 다음 세션 사용자 승인 후.
---

# 📋 인수인계 — Pointer Hub (v3.0-reduced)

> **v3.0 축소 원칙**: 본 파일은 이제 "상태 문서" 가 아니라 **포인터 허브 + 사용자 지시 SSoT**
> 역할만 한다. 현재 상태는 `PROGRESS.md` + `sprints/_INDEX.md` + `sessions/_INDEX.md` 를
> 읽어라. 본 파일은 (1) §0 사용자 지시 raw 텍스트 원문 (13건, 훼손 금지) + (2) account
> migration 컨텍스트 + (3) BLOCKED / Phase 2 포인터만 유지한다.

## 진입 순서 (재확인)

1. [CLAUDE.md](CLAUDE.md) §1 (절대 규칙 12) + §2.1 (용어집)
2. [PROGRESS.md](PROGRESS.md) frontmatter (resume_hint + mutex) + ③ Next
3. 필요 시 [sprints/_INDEX.md](sprints/_INDEX.md) (활성 WU) / [sessions/_INDEX.md](sessions/_INDEX.md) (retrospective)
4. 본 HANDOFF §0 (사용자 지시 원문 검색용) / [NEXT-SESSION-BRIEFING.md](NEXT-SESSION-BRIEFING.md) (FUSE bypass 템플릿)

---

## 0. 사용자 핵심 지시 (verbatim, 13 건 원문 SSoT)

> ⚠️ **본 섹션은 사용자 raw 텍스트 아카이브로 훼손 금지**. 인용 형태 변경 / 요약 / 재해석
> 금지 (원칙 2 self-validation-forbidden + 원칙 9 데이터 전수 기록). 새 지시는 번호 추가.

1. "나 잘거니까 쭉 이어서 작업해주고"
2. "토큰사용량이 너무 많을거 같거나 세션 사용량이 다 사용될거 같은 경우엔 다음세션에서 작업할 수 있도록 기록해둬 작업하진말고"
3. "중요한건 유실이 되면 안됨 너도 인수인계 받았을때 유실돼서 당황했지?? 깔끔하게 작업할 수 있도록 기억보단 기록해야됨"
4. (2026-04-20 오전): **"로컬 문서화를 시켜야되는 이유는 이 작업은 지금 이 회사 계정에서 진행할게 아니라 조만간 내 개인계정으로 옮겨서 해야되기 때문에 사실상 다른 계정으로 세션포크가 돼야함 -> 그게 불가능하니까 문서를 꼼꼼히(인수인계 + 히스토리)"**
5. (2026-04-20 오후, Round 3 GO 시점 verbatim):
   - "MCP에 관한것도 그 Bash CLI로 API연결해서 사용할 수 있는애들이 많잖아???" → §10.11 CLI-First Tool Selection Policy
   - "이걸 구현레벨이 아니라 추상화 레벨로... on-off 기능도 당연히 있으면 좋을거 같고, 또 필요할때 추상화 돼 있는걸 구현하는게 맞는거 같아" → 원칙 13 + divisions.schema v1.1 + /sfs division command
   - "상황을 물어보고 더 좋은 방법이 있다면 안내, 그리고 구현 자체를 막는건 ㄴㄴ" → never-hard-block invariant (ALT-INV-3) + alternative-suggestion-engine
   - "Socratic dialog tree 를 좀 더 구체화 ㄱㄱ" → division-activation.dialog.yaml + 6 branch 파일 + dialog-state.schema.yaml
   - "ㄱㄱ" → Round 3 batch 실행 GO signal
6. (2026-04-20 심야 ①, Round 3 종결 직후): **"음 세션 재시작 해야될거 같은데. ㅇㅇ HANDOFF 문서 일단 최신화 가장먼저 해주고 다음 세션에서 전달할 내용 이어서 요약해줘 내가 복붙으로 바로 다음 세션에서 작업시키게"**
7. (2026-04-20 오후 ②, bridge 루프 개시): **"일단 내가 새 클로드에서 작업하기 전까지 점진적으로 작은작업단위로 쪼개서 하나씩 작업하고 계속 기록한 다음에 커밋 & push하자 일주일이라는 시간동안 놀 순 없으니 이 시간도 제대로 활용 해야지"**
8. (2026-04-20 심야 ③, WU-8 완료 중): **"아 그리고 작업 먼저 끝나고 확인해주면 되는데 sfs를 claude 뿐만 아니라 codex랑 gemini-cli에서도 사용하고 싶거든?? 그래서 추상화 하는게 중요할듯?!"** → WU-11 Multi-agent runtime abstraction
9. (2026-04-20 심야 ④, bridge-handoff v2.8): **"일단 해당세션 context window가 많이 차서 다른세션으로 이관해서 작업하려고 하거든?? 폴더에 변경사항 커밋해서 기록해두고 handoff 문서도 최신화 시키고 다른 세션에서 브리핑 해야될 메세지 만들어줘"**
10. (2026-04-20 심야 ⑤, 새 세션 WU-11 A 확정): **"A ㄱㄱ 일단 디테일은 나중에 잡는게 맞고 일단은 최대한 mvp 형태로 뽑아서 난 다음주 부터 사용하는게 목적."** → WU-11 A (RUNTIME-ABSTRACTION.md MVP) 확정, 커밋 `4cd07e6`
11. (2026-04-20 심야 ⑥, WU-11 A 커밋 직후 — **매우 중요**): **"sfs시스템으로 다음주부터 난 새로운 프로젝트 mvp를 구축할거야 이걸 염두해둬"** → Phase 1 실 착수 (2026-04-27~) 예정. 과도한 선제 추상화 금지, Claude 단일 레일 질주 ok.
12. (2026-04-20 심야 ⑦, 새 세션 WU-12 착수): **"킥오프 먼저 하고 실제로 내가 사용가능한 상태로 셋팅한 다음에 다음작업들 이어서 가는게 맞을듯?"** + 축 확정 **"1. 1번에 좀 더 가까운거 같은데 일단 기본적인 골자인 브레인스토밍 -> plan -> sprint -> 구현 -> review -> commit -> 문서화 / 2. B"** + 도메인 **"음 내가 새로가는 회사의 관리자 페이지 라고 생각하면 됨 매출, 현금영수증발행, 권한관리, 대시보드 등등 이 들어갈 예정"** → WU-12 PHASE1-KICKOFF-CHECKLIST.md, axis 1 = lightweight spike (7-step), axis 2 = B 새 별도 repo, domain = 관리자 페이지, Gate = G0+G1+G2+G4, active 본부 = dev + strategy-pm
13. (2026-04-20 심야 ⑧, WU-12 checklist 작성 중 — IP 배포 모델 정정): **"Solon docset <-- 이건 내 개인자산이니까 사실 플러그인 형태로 배포가 돼야하는게 맞음"** → admin panel (회사 IP) repo 에 Solon 참조 zero. End-state = `claude plugin install solon`. MVP 단계 = 사용자 개인 workspace 로컬 clone 또는 `~/.claude/plugins/solon-wip/` 참조.
14. (2026-04-24, WU-15 이후 장소 이동 전): **"일단 세션 release 하고 다음세션은 내가 장소를 옮겨야해서 그 다음에 하자 인수인계문서만 빡씨게 ㄱㄱ"** → brave-hopeful-euler 세션 release + v0.5 refresh.
15. (2026-04-24, WU-17 착수 trigger): **"이전세션 이어서 작업해야될것들 있을거야 파악 후 ㄱㄱ"** + **"sfs프로젝트 말하는거임"** + **"일단 당분간은 깃도 자동화 하자 너가 커밋하고 push까지 진행해 그리고 이어서 ㄱㄱ"** + **"당분간만임 깃 자동화는"** → WU-17 resume_hint (a) 자동 진입 + §1.5 git push 금지 임시 해제 (환경 제약으로 실 push 는 사용자 터미널 유지).

16. (2026-04-24 심야, WU-20 scope pivot — **매우 중요**):
    - W0 실행 단계 verify-w0.sh check #7 false-positive FAIL 발견 (repo 이름 `solon-mvp` 가 `solon` grep 에 걸림).
    - 사용자 원 의도 재확인: **"난 지금 solon mvp(sfs 로 실행하는 단계)를 내 개인프로젝트랑, 새로시작할 프로젝트에서 사용하기 위해서 mvp 출시를 하겠다는거임 그래서 내가 repo 이름을 solon-mvp로 진행했던건데 프로젝트에서 sh로 임시 설치해서 사용할 수 있게 만들어 둔거면 내가 진행하고있는 사이드프로젝트, 그리고 앞으로 만들 신규 프로젝트에서 sh로 설치하면 되나?"**
    - **의미 전환**: 원래 기획 (#11~#13: admin-panel MVP + Solon 참조 zero) → **`solon-mvp` 자체가 SFS 시스템의 설치 가능한 배포판**. consumer 프로젝트 (사이드프로젝트 + 신규 프로젝트) 가 `install.sh` 로 Solon 을 주입받는 구조.
    - **3개 설계 결정 (사용자 직접)**:
      1. 설치 방법: **둘 다 지원** (`curl -sSL ... | bash` one-liner + local `git clone + ./install.sh`)
      2. CLAUDE.md 등 기존 파일 충돌: **대화형 prompt** (s/b/o/d = skip/backup/overwrite/diff)
      3. 업데이트: **upgrade.sh ㄱㄱ** — VERSION 기반 대화형 merge
    - **ㄱㄱ signal**: 자율 진행 승인 → WU-20 재정의 → Solon docset `solon-mvp-dist/` staging 구축 → apply-instructions.md 생성.
    - **admin-panel MVP 플랜 상태**: 보류. `solon-mvp` 배포 완료 + 사이드프로젝트에 install 한 뒤, 신규 프로젝트 중 하나로 admin-panel 재활성화 검토. 현재 #11~#13 은 "예약" 상태.
    - **phase1-mvp-templates/ 및 setup-w0.sh / verify-w0.sh 운명**: 기능은 `solon-mvp-dist/install.sh` 에 재흡수됨. 원본 phase1-mvp-templates/ 는 docset 에서 archive 또는 제거 결정 필요 (WU-20 후속).

17. (2026-04-24 저녁, 11번째 세션 `dreamy-busy-tesla` — dev/stable 방향 확정):
    - **상황**: WU-20 Phase A 보강 (v0.2.0-mvp) 커밋 push 후 사용자 `git log --oneline -5`
      결과 공유:
      ```
      ac98497 fix: honor upgrade prompt defaults
      a48b7fd feat: automate checksum-based upgrades
      41e15ed feat: add checksum-based upgrade preview
      8134a2c feat: add runtime-neutral SFS adapters
      e9cf47a docs: improve /sfs autocomplete help
      ```
      → solon-mvp stable 에 Codex CLI 작업 6 커밋 (v0.1.1 → v0.2.4-mvp) 이미 merge 완료.
      staging (방금 만든 v0.2.0-mvp) 대비 stable 선행 = divergence.
    - **사용자 답변 verbatim**: **"ㄴㄴㄴ mvp는 배포버전이고 solon이 개발버전이어야
      함 solon-mvp가 한마디로 stable 버전이어야 함"** → dev SSoT 방향 확정.
    - **함의**: 방향 역전 = 규율 위반 상태. 해소 절차 필요.
    - **해소 (WU-20 Phase A Back-port)**: stable HEAD `ac98497` → dev staging reverse
      reconcile. 14 파일 cp 로 full sync (`VERSION` / `CHANGELOG.md` / `README.md` /
      `install.sh` / `upgrade.sh` / `uninstall.sh` / `CLAUDE.md` (distribution) /
      `templates/{SFS,CLAUDE,AGENTS,GEMINI}.md.template` / `templates/.claude/commands/sfs.md`
      / `templates/.gitignore.snippet` / `templates/.sfs-local-template/divisions.yaml`).
      `diff -q` 모두 same + `bash -n` 3 스크립트 OK.
    - **레거시 정리**: `solon-mvp-dist/templates/.claude-template/` 은 bash FUSE lock
      으로 agent 삭제 실패 → 사용자 터미널 `git rm -rf` 위임.
    - **Learning**: `learning-logs/2026-05/P-02-dev-stable-divergence.md` 실체화.
      **R-D1 규율 제안**: "배포 artifact 수정은 dev 먼저. stable hotfix 는 같은
      세션 안에 즉시 staging back-port 커밋 생성." CLAUDE.md §1 정식 채택은
      다음 세션 사용자 승인 후 (원칙 2).
    - **APPLY-INSTRUCTIONS.md 상태**: historical 로 retrograde. 신규 consumer 프로젝트
      설치는 `install.sh` 만 사용.

→ **해석 요약**:
- 기본 3원칙: 작업 진행 + 토큰 한계 도달 시 중단 + **기록 우선**
- Cross-account 원칙: 계정 이관 = 재조립. 다음 세션 Claude 는 아무것도 기억 못 하는
  상태 전제. 모든 판단 근거 파일화 + MEMORY.md 는 이관되지 않음.
- "ㄱㄱ" = resume_hint.trigger_positive (자율 진행 승인, 원칙 2 위반 action 제외).
- git push 자동화 는 사용자 지시 시 임시 해제 가능하나 현 FUSE Cowork 샌드박스 환경
  제약 (자격 전무) 으로 실제 push 는 사용자 터미널 유지.

---

## 1. 현 상태 (포인터만)

| 항목 | 포인터 |
|---|---|
| 현 상태 live snapshot | [PROGRESS.md](PROGRESS.md) |
| 완료 WU 전량 | [sprints/_INDEX.md](sprints/_INDEX.md) (3-섹션: v2 native + 이관 + v1 형식) |
| 세션 히스토리 (1~8) | [sessions/_INDEX.md](sessions/_INDEX.md) |
| Append-only 히스토리 | [WORK-LOG.md](WORK-LOG.md) |
| 절대 규칙 / 용어집 / 운영 규율 | [CLAUDE.md](CLAUDE.md) |
| 진입 5분 브리핑 + FUSE bypass | [NEXT-SESSION-BRIEFING.md](NEXT-SESSION-BRIEFING.md) |
| Phase 1 킥오프 체크리스트 | [PHASE1-KICKOFF-CHECKLIST.md](PHASE1-KICKOFF-CHECKLIST.md) |
| Cross-account 이관 플레이북 | [CROSS-ACCOUNT-MIGRATION.md](CROSS-ACCOUNT-MIGRATION.md) |
| W10 결정 TODO SSoT | [cross-ref-audit.md §4](cross-ref-audit.md) |
| Runtime 추상화 MVP | [RUNTIME-ABSTRACTION.md](RUNTIME-ABSTRACTION.md) |
| docset 루트 orientation | [../README.md](../README.md) |

---

## 2. Cross-Account 이관 상태 요약

Scenario C (개인 계정 이관) §1 (이관 전 체크) + §2 (packaging) 이 회사 계정 세션들에서
전수 완료되어 있고, GitHub push (`https://github.com/MJ-0701/solon`, private) 는
사용자 Mac 터미널에서 이미 수차례 실행된 상태. 현재 인수인계 채널은 GitHub clone
+ 본 docset 이며, 이관 자체는 "추가 사용자 결정" 없이 실행 가능한 상태다.

세부 절차 / 체크리스트는 [CROSS-ACCOUNT-MIGRATION.md](CROSS-ACCOUNT-MIGRATION.md)
+ [MIGRATION-NOTES.md](MIGRATION-NOTES.md) + [external-assets.md](external-assets.md).

---

## 3. BLOCKED / Phase 2 (포인터)

- **BLOCKED**: WU-6 (claude-shared-config/.git IP 경계) — 사용자 결정 필요. 세부는
  `sprints/_INDEX.md` BLOCKED 섹션.
- **Phase 2 예약**: WU-11 B / WU-11 C / WU-16b. 상세는 `sprints/_INDEX.md` Phase 2
  섹션.
- **Phase 1 킥오프**: 2026-04-27 (월). 체크리스트: `PHASE1-KICKOFF-CHECKLIST.md §2 W0`.

---

## 4. 본 파일 축소 이력 (WU-17)

- v2.9 (2026-04-24, brave-hopeful-euler): Workflow v2 이관 완료 반영 (786 lines 최대).
- **v3.0-reduced (2026-04-24, ecstatic-intelligent-brahmagupta, WU-17): -80% 축소**.
  §1~§10 상세 아카이브 섹션 제거, §0 사용자 지시 원문 13 건 보존 + 포인터 hub 로 전환.
  상세 히스토리 (Round 2 / Round 3 archive, 시나리오 B/C/D 가이드, Pitfall, 파일
  Inventory, 토큰 예산, Cross-Account Playbook) 은 각각 [sprints/_INDEX.md] +
  [sessions/_INDEX.md] + [WORK-LOG.md] + [README.md] + [CLAUDE.md] +
  [CROSS-ACCOUNT-MIGRATION.md] + [INDEX.md] 로 위임.

> 상세 archive 가 필요하면 `git log --follow HANDOFF-next-session.md` 로 v2.9 (`f673cc2`)
> 이전 버전 조회 가능. 또는 WU-16.1 sha `227f900` 시점 snapshot 참조.

끝.
