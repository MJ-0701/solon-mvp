---
doc_id: handoff-2026-04-20-solon-v0.4-r3-complete
title: "인수인계 — Round 3 종결 + Round 4 Bridge (Solon v0.4-r3)"
version: 2.8-bridge-handoff
created: 2026-04-20 (오전)
updated: 2026-04-20 (심야 — 세션 이관 직전, WU-8 완료 + WU-11 사용자 대기 상태로 bump)
author: "Claude (direct 지시 by 채명정)"
valid_until: "새 Claude 세션 (동일 또는 개인 계정) 이 WU-11 결정 후 v3.0 으로 bump 할 때까지"
status: "Round 4 Bridge 진행중 (WU 루프, 세션 이관 지점) — 다음 세션이 WU-11 A/B/C 결정부터 재개"
account_context:
  current: "회사 계정 (jack2718@green-ribbon.co.kr) — GitHub origin (MJ-0701/solon) 에 로컬 커밋 존재 (push 는 사용자 터미널에서 수동)"
  will_move_to: "채명정 개인 계정 (약 1주 이내) — 단, 세션 이관은 동일 계정 내에서도 발생 가능"
  fork_possible: false
  migration_strategy: "GitHub clone + WORK-LOG.md 기반 continuation"
  critical_rule: "README (root STOP&READ) + INDEX + HANDOFF + WORK-LOG 이 유일한 인수인계 채널"
round3_summary:
  total_tasks: 11
  completed: 11
  in_progress: 0
  pending: 0
  closure_note: "v0.4-r3 설계 확정"
round4_bridge:
  opened: 2026-04-20 (오전)
  purpose: "새 Claude 환경 투입 전까지 repo 점진 개선 (작은 WU 단위 + WORK-LOG 기록)"
  active_log: "WORK-LOG.md (WU-1 부터)"
  session_handoff_point: 2026-04-20 (심야) — "세션 context window 포화 임박, 다음 세션으로 이관"
  completed_wus:
    - "WU-0: d034d0d — full-scope typo + stale-ref cleanup (14 files)"
    - "WU-1: 7b8dae6 — WORK-LOG.md 신설"
    - "WU-1.1: 11d1757 — WORK-LOG 에 commit sha 7b8dae6 기록 + FUSE lock 우회 절차 메모"
    - "WU-2: 54ac583 — HANDOFF v2.6-final → v2.7-bridge (Round 4 Bridge open)"
    - "WU-3: a67a408 — G1~G5 → G-1 + G1~G5 일관성 (current-state 3지점, 3 files)"
    - "WU-8: 764194f — SFS brand prose → Solon disambiguation (109 occurrences, 14 files)"
    - "WU-8.1: 4a1df93 — WORK-LOG 에 commit sha 764194f 기록 + WU-11 큐 추가"
    - "WU-HANDOFF: 30e4418 — HANDOFF v2.7-bridge → v2.8-bridge-handoff (세션 이관 지점)"
    - "WU-HANDOFF.1: 617efe2 — NEXT-SESSION-BRIEFING.md 신설 + WORK-LOG v1.3"
    - "WU-11 A: 4cd07e6 — RUNTIME-ABSTRACTION.md 신설 (multi-agent runtime abstraction MVP)"
    - "WU-11.1: eed4dd1 — sha 4cd07e6 backfill + 사용자 11번째 지시 기록 (HANDOFF §0)"
    - "WU-11.2: 6527252 — WORK-LOG 에 commit sha eed4dd1 backfill"
    - "WU-12: 7f8a635 — PHASE1-KICKOFF-CHECKLIST.md 신설 (Phase 1 MVP 경량 스파이크, v0.1-mvp-patch1)"
    - "WU-12.1: ff89ea1 — sha 7f8a635 backfill + HANDOFF frontmatter completed_wus 6 WU 일괄 추가"
    - "WU-12.2: 8ab660c — PHASE1-KICKOFF-CHECKLIST.md v0.1-mvp-patch2 (submodule 레지듀 2곳 cleanup, §3.7 + §6.2)"
    - "WU-12.3: b77fcb2 — sha 8ab660c backfill + HANDOFF frontmatter completed_wus 2 WU 추가 (WU-12.1 + WU-12.2) + unpushed_commits 갱신"
    - "WU-4: 7d982dc — appendix/dialogs/README.md 선제 생성 (cross-ref-audit §4 TODO #1 해결, index 허브)"
    - "WU-4.1: 1c375aa — sha 7d982dc backfill + HANDOFF frontmatter completed_wus 1 WU 추가 + unpushed_commits 갱신"
    - "WU-5: 20c3474 — 05-gate-framework.md §5.11 G-1 Intake Gate 교차 정합성 보정 (Option β minimal cleanup: L1 schema gate_id G-1 추가 + §5.11.7 base schema 주석 + cross-ref-audit §4.8 schema 결정 TODO)"
    - "WU-5.1: 9c4d6c0 — sha 20c3474 backfill + HANDOFF frontmatter completed_wus 2 WU 추가 (WU-4.1 + WU-5) + unpushed_commits 갱신"
    - "WU-9: 816d751 — 02-design-principles.md §2.13 원칙 13 Terminal 집합 교차 정합성 보정 (Option β minimal cleanup: 02 §2.13.5 표 4→5 + dialog.yaml frontmatter 5 terminal + cross-ref-audit §4 W10 schema/commands prefix 결정 TODO)"
    - "WU-9.1: 6884bbd — sha 816d751 backfill + HANDOFF frontmatter completed_wus 1 WU 추가 + unpushed_commits 갱신"
    - "WU-13: 101030f — NEXT-SESSION-BRIEFING.md 신설 (세션 간 진입 브리핑 9-섹션, ~180 lines, living handoff doc)"
    - "WU-13.1: (이 커밋) — sha 101030f backfill + HANDOFF frontmatter completed_wus 1 WU 추가 + unpushed_commits 갱신"
  unpushed_commits: "현 세션 새 로컬 커밋 = WU-12.2 (8ab660c) + WU-12.3 (b77fcb2) + WU-4 (7d982dc) + WU-4.1 (1c375aa) + WU-5 (20c3474) + WU-5.1 (9c4d6c0) + WU-9 (816d751) + WU-9.1 (6884bbd) + WU-13 (101030f) + WU-13.1 backfill (이 커밋) → 사용자가 `git push origin main` 수동 실행 필요 (총 10 커밋)."
  queue:
    next_blocking: "WU-7 07-plugin-distribution plugin.json 샘플 파일 분리 (Phase 1 asset 준비, WU-13 briefing 완료)"
    ready_after_wu13: [WU-7, WU-10]
    entry_point_for_next_session: "NEXT-SESSION-BRIEFING.md (9-섹션, 5분 진입 가이드)"
    blocked: [WU-6 (claude-shared-config/.git IP 경계 — 사용자 결정 필요)]
  user_new_directive:
    raw: "sfs를 claude 뿐만 아니라 codex랑 gemini-cli에서도 사용하고 싶거든?? 그래서 추상화 하는게 중요할듯?!"
    implication: "Claude Code 에 암묵적으로 lock-in 된 현 docset 에 runtime abstraction layer 추가 필요"
    proposed_scope: "WU-11 A (RUNTIME-ABSTRACTION.md 문서 1개만 신설, 저위험) / B (A + agent-specific 파일에 agnostic 힌트 주석) / C (B + Codex/Gemini 어댑터 초안)"
    recommendation: "A 부터 시작 (Phase 1 Claude 범위는 유지, Phase 2 에 본격 확장 예약)"
---

# 📋 다음 세션 인수인계 문서 (Round 3 종결 + Round 4 Bridge, v2.7-bridge)

> **이 문서를 제일 먼저 읽어라.** Round 3 (11-task batch) **11/11 완료, 0개 남음.** v0.4-r3 설계 docset 확정 완료. **2026-04-20 Round 4 Bridge open** — 새 Claude 환경 투입 전까지 작은 WU 단위로 repo 점진 개선 중. **진행 로그는 [WORK-LOG.md](WORK-LOG.md) 참조.**
> 설계 docset 경로: `<session-path>/mnt/agent_architect/2026-04-19-sfs-v0.4/` (GitHub: https://github.com/MJ-0701/solon)
> ※ 세션 경로는 매번 바뀜. `2026-04-19-sfs-v0.4/` 이 폴더 이름만 고정.
>
> ⚠️ **[CROSS-ACCOUNT 경보]** 이 작업은 조만간 (약 1주 이내) 회사 계정 → 채명정 개인 계정으로 이관됨. 계정 간 session fork 불가 → GitHub repo (MJ-0701/solon) + 로컬 문서 = 유일한 인수인계 채널. §10 + `CROSS-ACCOUNT-MIGRATION.md` 참조.
>
> 🟢 **[Round 3 상태]** Round 3 종결. §2.R3 섹션은 Round 3 내역 아카이브. 본 HANDOFF 는 handoff entry point 역할만 수행하고, 실제 진행 로그는 **WORK-LOG.md** (WU-1 부터) 로 이관.
>
> 🆕 **[Round 4 Bridge 상태 — v2.8 세션 이관 지점]** (2026-04-20 심야)
> - 목적: 새 Claude 환경 투입 전 bridge 작업 (repo 정합성/보강)
> - 로그: [WORK-LOG.md](WORK-LOG.md) (WU 단위, 7 커밋 완료)
> - **완료**: WU-0 (d034d0d), WU-1 (7b8dae6), WU-1.1 (11d1757), WU-2 (54ac583), WU-3 (a67a408), WU-8 (764194f), **WU-8.1 (4a1df93, 본 v2.8 bump)**
> - **🚨 사용자 결정 대기 — WU-11 🆕 Multi-agent runtime abstraction**: 사용자가 "SFS 를 Claude 뿐 아니라 Codex / Gemini-CLI 에서도 쓰고 싶다 → 추상화 중요" 라고 지시. 범위 A (RUNTIME-ABSTRACTION.md 문서 1개만, 저위험 추천) / B (A + agnostic 힌트 주석) / C (B + 어댑터 초안) 중 **사용자 확정 필요**.
> - **큐 (WU-11 결정 후)**: WU-4 → WU-5 → WU-9 → WU-7 → WU-10
> - **BLOCKED**: WU-6 (claude-shared-config/.git IP 경계 재정리 — 사용자 결정 대기)
> - **Push 상태**: 7 커밋 (d034d0d ~ 4a1df93) origin/main 대비 ahead, **사용자가 터미널에서 `git push origin main` 직접 실행 필요**. FUSE 환경 git 인증 이슈 (MIG-8 때부터 동일 패턴).
> - **FUSE lock 우회**: `.git/index.lock` 이 FUSE 마운트에서 unlink 불가 → `cp -r .git /tmp/agent_git_backup && rm /tmp/agent_git_backup/index.lock && GIT_DIR=/tmp/agent_git_backup GIT_WORK_TREE=<wt> git <cmd>` → `rsync -a /tmp/agent_git_backup/ <wt>/.git/` (→ WORK-LOG §WU-1.1 참조).

---

## 0. 사용자 핵심 지시 (세션 중단 직전)

1. "나 잘거니까 쭉 이어서 작업해주고"
2. "토큰사용량이 너무 많을거 같거나 세션 사용량이 다 사용될거 같은 경우엔 다음세션에서 작업할 수 있도록 기록해둬 작업하진말고"
3. "중요한건 유실이 되면 안됨 너도 인수인계 받았을때 유실돼서 당황했지?? 깔끔하게 작업할 수 있도록 기억보단 기록해야됨"
4. (2026-04-20 오전): **"로컬 문서화를 시켜야되는 이유는 이 작업은 지금 이 회사 계정에서 진행할게 아니라 조만간 내 개인계정으로 옮겨서 해야되기 때문에 사실상 다른 계정으로 세션포크가 돼야함 -> 그게 불가능하니까 문서를 꼼꼼히(인수인계 + 히스토리)"**
5. (2026-04-20 오후, Round 3 GO 시점 관련 verbatim 지시):
   - "MCP에 관한것도 그 Bash CLI로 API연결해서 사용할 수 있는애들이 많잖아???" → §10.11 CLI-First Tool Selection Policy 신설 (Task #24, 완료)
   - "이걸 구현레벨이 아니라 추상화 레벨로... on-off 기능도 당연히 있으면 좋을거 같고, 또 필요할때 추상화 돼 있는걸 구현하는게 맞는거 같아" → 원칙 13 + divisions.schema v1.1 + /sfs division command (Task #17~#21, 완료)
   - "상황을 물어보고 더 좋은 방법이 있다면 안내, 그리고 구현 자체를 막는건 ㄴㄴ" → never-hard-block invariant (ALT-INV-3) + alternative-suggestion-engine (Task #23, 완료)
   - "Socratic dialog tree 를 좀 더 구체화 ㄱㄱ" → division-activation.dialog.yaml + 6 branch 파일 + dialog-state.schema.yaml (Task #20~#22, 완료)
   - "ㄱㄱ" → Round 3 batch 실행 GO signal (최종 11/11 종결)
6. (2026-04-20 심야 ①, Round 3 종결 직후): **"음 세션 재시작 해야될거 같은데. ㅇㅇ HANDOFF 문서 일단 최신화 가장먼저 해주고 다음 세션에서 전달할 내용 이어서 요약해줘 내가 복붙으로 바로 다음 세션에서 작업시키게"** → 당시 산출물이 v2.6-final 이었으나 바로 "일주일 bridge 기간 동안 점진 작업" 지시로 WU 루프 진입.
7. (2026-04-20 오후 ②, bridge 루프 개시): **"일단 내가 새 클로드에서 작업하기 전까지 점진적으로 작은작업단위로 쪼개서 하나씩 작업하고 계속 기록한 다음에 커밋 & push하자 일주일이라는 시간동안 놀 순 없으니 이 시간도 제대로 활용 해야지"** → WORK-LOG.md 신설 + WU 루프 (WU-1~8.1 커밋).
8. (2026-04-20 심야 ③, WU-8 완료 중): **"아 그리고 작업 먼저 끝나고 확인해주면 되는데 sfs를 claude 뿐만 아니라 codex랑 gemini-cli에서도 사용하고 싶거든?? 그래서 추상화 하는게 중요할듯?!"** → 🚨 **WU-11 Multi-agent runtime abstraction 지시**. Claude Code 에 lock-in 된 현 docset 에 abstraction layer 필요. 범위 A/B/C 제안 상태, **사용자 확정 대기**. (상세: WORK-LOG.md WU-11 큐 + frontmatter `round4_bridge.user_new_directive`).
9. (2026-04-20 심야 ④, 본 v2.8 bump 직전): **"일단 해당세션 context window가 많이 차서 다른세션으로 이관해서 작업하려고 하거든?? 폴더에 변경사항 커밋해서 기록해두고 handoff 문서도 최신화 시키고 다른 세션에서 브리핑 해야될 메세지 만들어줘"** → 현 v2.8-bridge-handoff + 다음 세션 브리핑 텍스트가 그 산출물.
10. (2026-04-20 심야 ⑤, 새 세션 WU-11 A 확정): **"A ㄱㄱ 일단 디테일은 나중에 잡는게 맞고 일단은 최대한 mvp 형태로 뽑아서 난 다음주 부터 사용하는게 목적."** → WU-11 A 범위 (RUNTIME-ABSTRACTION.md 1개만 신설, MVP) 확정. 커밋 `4cd07e6` 완료.
11. (2026-04-20 심야 ⑥, WU-11 A 커밋 직후 — **매우 중요**): **"sfs시스템으로 다음주부터 난 새로운 프로젝트 mvp를 구축할거야 이걸 염두해둬"** → 다음주 (2026-04-27~) 부터 Solon 을 실제 적용할 **새 프로젝트 MVP 착수** 예정. 함의:
    - 현재 bridge 큐 (WU-4 → WU-5 → WU-9 → WU-7 → WU-10) 와 "Phase 1 실 착수 준비" 가 경합. 다음 세션 개시 시 **WU-11.1 에서 우선순위 재점검 필수**.
    - RUNTIME-ABSTRACTION.md 의 MVP 지향이 바로 이 맥락과 직결 — 과도한 선제 추상화 금지, Claude 단일 레일 질주가 옳다는 사후 확증.
    - 실 프로젝트의 이름/도메인은 아직 미공지 (product-image-studio 일 가능성 — §4.3 Phase 1 kickoff 시나리오 참조).
    - 질문 trigger: 다음 세션은 "WU-4~10 계속" vs "Phase 1 킥오프 준비 (§10.4)" 중 사용자 의중 확인부터.
12. (2026-04-20 심야 ⑦, 새 세션 WU-12 착수 결정): **"킥오프 먼저 하고 실제로 내가 사용가능한 상태로 셋팅한 다음에 다음작업들 이어서 가는게 맞을듯?"** + 축 확정 **"1. 1번에 좀 더 가까운거 같은데 일단 기본적인 골자인 브레인스토밍 -> plan -> sprint -> 구현 -> review -> commit -> 문서화 / 2. B"** + 도메인 **"음 내가 새로가는 회사의 관리자 페이지 라고 생각하면 됨 매출, 현금영수증발행, 권한관리, 대시보드 등등 이 들어갈 예정"** → WU-12 `PHASE1-KICKOFF-CHECKLIST.md` 착수. axis 1 = ① lightweight spike (7-step) / axis 2 = B 새 별도 repo / domain = 관리자 페이지 / Gate = G0+G1+G2+G4 4개 축소판 / active 본부 = dev + strategy-pm. W0 준비 + W1 첫 cycle 체크박스화.
13. (2026-04-20 심야 ⑧, WU-12 checklist 작성 중 — **IP 배포 모델 정정**): **"Solon docset <-- 이건 내 개인자산이니까 사실 플러그인 형태로 배포가 돼야하는게 맞음"** → checklist v0.1-mvp 초안의 submodule 전제 제거. **결정**: (a) admin panel (회사 IP) repo 에 Solon 참조 zero (`.gitmodules` 없음, 경로 하드코딩 없음, `git ls-files | grep -i solon` 빈 결과). (b) end-state = `claude plugin install solon` (07-plugin-distribution.md + 풀스펙 §10.4 W13 Plugin Packaging). (c) MVP 단계 = 사용자 개인 workspace 의 로컬 clone 또는 개인 `~/.claude/plugins/solon-wip/` 참조 (양쪽 다 admin panel repo 밖). v0.1-mvp-patch1 로 §1.1/§2.2/§2.4/§2.5/§6.1/§7.1/§7.2 전반 정정 반영. **향후 함의**: Solon docset 쪽에서 풀스펙 W13 Plugin Packaging 선행 우선순위 상향 검토 여지 — "사용자 머신마다 수동 clone 이 비효율" 이라고 cycle 1~2 운용 중 느끼면 Solon docset repo 에서 별도 WU 로 조기 착수 가능.

→ **해석**:
- 기본 3원칙: 작업 진행 + 토큰 한계 도달 시 중단 + 기록 우선
- 🆕 추가 원칙 (cross-account): **계정 이관 = 재조립(reassembly)**. 다음 세션의 Claude는 아무것도 기억 못 하는 상태로 부팅됨. 따라서:
  - 모든 판단 근거 파일화 (어쩌다 그렇게 됐는지 포함)
  - cross-reference 링크 정확성 검증 — 회사 계정 MCP/도구 의존 제거
  - MEMORY.md 는 회사 계정 Claude Code 로컬 파일 이므로 **이관되지 않음** → 본 HANDOFF + docset 이 유일한 Cross-Account Carrier
  - 다음 세션 Claude 에게는 "Solon 을 만든 적 없고, docset 을 처음 읽는 사람" 으로 가정하고 문서를 작성할 것

---

## 1. 한 문장 현황

**Solon v0.4-r3 (Round 3) 종결 snapshot v2.6-final.** Round 2 종결 후 사용자가 "division 추상화 + on/off + 비차단 가이드" 요구를 추가하여 Round 3 (11-task batch) 로 확장했고 **11/11 완료**. 핵심 신설: **원칙 13 (Progressive Activation + Non-Prescriptive Guidance)** + **6 activation_state 기반 본부 (Phase 1 기본 = 2 active + 4 abstract)** + **Socratic division-activation dialog tree (5-phase)** + **6 branch 파일 (taxonomy/qa/design/infra/strategy-pm/custom)** + **dialog-state.schema (turn tracking, resume, override 감사)** + **alternative-suggestion-engine spec (3-tier × 👍/⚪/⚠)** + **§10.11 CLI-First Tool Selection Policy** + **install.md v2.0 Socratic wizard 재설계** + **§03/README/INDEX propagation (Task #26)** + **§03.7/§10.2.1/§10.4/§10.5.1 Phase 1 기본 활성 본부 재정의 + Progressive Activation 엔진 주차 편성 (Task #27)**. docset v0.4-r3 확정. **다음 세션은 사용자 의중**: (B) Phase 1 킥오프 (§10.4 W1~W20) / (C) 개인 계정 이관 (§10 + CROSS-ACCOUNT-MIGRATION.md) / (D) Round 4 추가 요구 시.

---

## 2.R3 ✅ Round 3 종결 아카이브 (v2.5 → v2.6-final 갱신분, 본 세션 범위)

### 2.R3.0 Round 3 배경

Round 2 종결 직후 사용자가 3 가지 추가 요구 제시:

1. **CLI-first 전략**: "MCP 말고 CLI + direct API 연결 우선"
2. **Division 추상화 레이어**: "본부는 구현이 아니라 추상 abstraction, on/off 가능, 필요할 때 구현"
3. **Socratic dialog**: "상황을 물어보고 더 좋은 방법이 있으면 안내, 구현 자체를 막는건 X"

→ 이 3 개를 축으로 **11 개 task (R3-01 ~ R3-11)** 을 Round 3 batch 로 정의하고 GO 신호 "ㄱㄱ" 후 병렬 실행.

### 2.R3.1 완료 Task 목록 (11/11)

| TaskList ID | 코드 | 작업 | 산출물 |
|:-:|:-:|------|--------|
| #17 | R3-01 | §02 원칙 13 신설 (Progressive Activation + Non-Prescriptive) | 02-design-principles.md (§2.13 + §2.14 dependency graph 갱신, 4-축 방어선 표 추가) |
| #18 | R3-02 | divisions.schema.yaml v1.0 → v1.1 확장 | appendix/schemas/divisions.schema.yaml (activation_state/activation_scope/parent_division/sunset_at/tier/dialog_trace_id + 13 validation rules + example_dialog_activated + migration 섹션) |
| #19 | R3-03 | /sfs division command spec 신규 | appendix/commands/division.md (activate/deactivate/list/add/recommend/status, 5 examples, user-only caller, agent 자동 호출 금지) |
| #20 | R3-04 | Socratic meta dialog tree 신규 | appendix/dialogs/division-activation.dialog.yaml (5-phase A→B→C→D→E + X, 6 invariants INV-1~6, 5 terminals, 완전한 example_trace) |
| #21 | R3-05 | 본부별 branch 예시 6개 작성 | appendix/dialogs/branches/{taxonomy, qa, design, infra, strategy-pm, custom}.yaml (각각 intent hints, option_templates with default intensity, warn_conditions, terminal side-effects, 채명정 persona 예시) |
| #22 | R3-06 | dialog-state.schema.yaml 신규 | appendix/schemas/dialog-state.schema.yaml (DialogState + DialogTurn + 3 L1 이벤트 + 12 validation rules + resume protocol + storage/retention) |
| #23 | R3-07 | alternative-suggestion-engine spec | appendix/engines/alternative-suggestion-engine.md (6 ALT-INV, 3-tier alternatives rule, 3-level intensity rule, decision tree, never-hard-block rule, edge cases, anti-patterns, Phase 1 checklist) |
| #24 | R3-08 | §10.11 CLI-First Tool Selection Policy 신규 | 10-phase1-implementation.md (§10.11.1 4-tier preference + §10.11.2 비교표 + §10.11.3 결정트리 + §10.11.4 MCP justification + §10.11.5 cross-account 연결 + §10.11.6 Phase 1 적용 스코프 + §10.11.7 anti-patterns + §10.11.8 예외, TOC/defines 갱신) |
| #25 | R3-09 | install.md v2.0 재설계 (Socratic wizard) | appendix/commands/install.md (Q1 repo 상태 → Q2 tier → Q3 L3 backend → Q4 brownfield coexist + discover → Q5 division activation preview → Q6 최종 확정, wizard_trace_id + L1 events, 4 예시 including override, division-activation dialog 와 통합 주석) |
| #26 | R3-10 | §03 / README / INDEX 에 원칙 13 + division abstraction propagation | 03-c-level-matrix.md (§3.3 activation_state 소개 + §3.7 Phase 1 Baseline active/abstract 분리, defines 에 `concept/division-activation-state` 추가), README.md (§2 13대 원칙 + §4 row 13 + §5.3 14개 commands + §6 `/sfs division` 행 + §9 Phase 1 status 표 + §10 파일 맵 확장 + §11 용어집 7종 추가 + §12 v0.4-r3 changelog), INDEX.md (frontmatter v0.4-r3, v0.4-r3 핵심 변경 요약 block, §1 appendix 헤더 확장, §1 Commands 14 + Dialogs 6 + Engines 2 섹션, §3.2 갱신 + §3.8 🆕 Progressive Activation reader path, §4 Cross-Reference 4 subsection 추가, §7 v0.4-r3 changelog), CROSS-ACCOUNT-MIGRATION.md (13→14 sanity check + 원칙 13 + /sfs division 질문 추가), 04-pdca-redef.md + 05-gate-framework.md frontmatter `division/pm` → `division/strategy-pm` 통일 |
| #27 | R3-11 | Phase 1 기본 활성 본부 재정의 + HANDOFF v2.6-final bump | 10-phase1-implementation.md (§10.2.1 본부장 agents row = active 2 + abstract 4, 신규 "원칙 13 엔진" row = dialog-engine + alternative-suggestion-engine 2항목 2.0주 Sonnet, 합계 27/15.5→30/18.0 + activation-aware 최적화 노트; §10.4 제목 15~19주→16~20주 🆕 v0.4-r3; §10.4.1 roadmap W2b 열 추가; §10.4.2 W2b 신규 원칙 13 엔진 task + W10 sfs-division skill row + invariant unit tests 메모; §10.4.3 parallelization 16/20/18 forecast; §10.4.4 Critical Path 의존 사슬 + 3 break conditions 추가; §10.5.1 condition 2 active/abstract 분리 + condition 6 Progressive Activation dogfooding ≥1 abstract→active 승격), HANDOFF-next-session.md v2.6 → v2.6-final (본 문서, Round 3 closure) |

### 2.R3.2 Round 3 수정/신규 파일 전량 (11/11 종결)

```
# 본문 / 루트 (수정)
02-design-principles.md                                          [수정]  원칙 13 + §2.14 의존 그래프 갱신
03-c-level-matrix.md                                             [수정]  §3.3 activation_state 소개 + §3.7 Phase 1 Baseline active/abstract 분리 + defines 추가
04-pdca-redef.md                                                 [수정]  frontmatter division/pm → division/strategy-pm 통일
05-gate-framework.md                                             [수정]  frontmatter division/pm → division/strategy-pm 통일
10-phase1-implementation.md                                      [수정]  §10.11 CLI-first Policy 신설 + §10.2.1 본부장/원칙 13 엔진 row + §10.4 16~20주 확장 + §10.4.1~.4 W2b 열 + §10.5.1 조건 6
README.md                                                        [수정]  §2 13대 원칙 + §4 row 13 + §5.3 14 commands + §6 /sfs division + §9 Phase 1 status + §10 파일 맵 + §11 용어집 + §12 v0.4-r3 changelog
INDEX.md                                                         [수정]  frontmatter v0.4-r3 + §1 Appendix 확장 + Commands 14 + Dialogs 6 + Engines 2 + §3.8 신설 + §4 4-subsection + §7 v0.4-r3 entry
CROSS-ACCOUNT-MIGRATION.md                                       [수정]  13→14 sanity check + 원칙 13 + /sfs division 질문
HANDOFF-next-session.md                                          [본 문서, v2.6 → v2.6-final Round 3 closure]

# Appendix (신규)
appendix/commands/division.md                                    [신규]
appendix/commands/install.md                                     [v2.0 재작성]
appendix/schemas/divisions.schema.yaml                           [v1.1 확장]
appendix/schemas/dialog-state.schema.yaml                        [신규]
appendix/dialogs/division-activation.dialog.yaml                 [신규]
appendix/dialogs/branches/taxonomy.yaml                          [신규]
appendix/dialogs/branches/qa.yaml                                [신규]
appendix/dialogs/branches/design.yaml                            [신규]
appendix/dialogs/branches/infra.yaml                             [신규]
appendix/dialogs/branches/strategy-pm.yaml                       [신규]
appendix/dialogs/branches/custom.yaml                            [신규]
appendix/engines/alternative-suggestion-engine.md                [신규]
```

**합계 — 본문/루트 수정 9 + appendix 신규 12 = 21 건** (폴더 2 신설: `appendix/dialogs/` + `appendix/engines/`)

### 2.R3.3 ✅ Round 3 종결 (11/11, 다음 세션 대기 상태)

본 섹션은 이전 버전 (v2.6) 에서 `미완료 Task (2개)` 로 존재했으며, Task #26 (R3-10) 과 Task #27 (R3-11) 이 본 세션 (v2.6-final) 에서 완료되어 **0 건 남음**. 상세 완료 내역은 §2.R3.1 표 마지막 2 행 (#26 / #27) 참조.

**Round 3 종결 판정 근거**:
1. 원칙 13 (Progressive Activation + Non-Prescriptive Guidance) 이 §02 / §03 / §10 / README / INDEX 전역에 propagation 완료 (Task #26).
2. Phase 1 기본 활성 본부가 "6개 전원 active" → "dev + strategy-pm 2 active + qa/design/infra/taxonomy 4 abstract" 로 재정의, §10.2.1 본부장 수량 감축 + 원칙 13 엔진 2 항목 (dialog-engine + alternative-suggestion-engine) 의 주차 편성 (W2b) 및 `sfs-division` skill 의 W10 편성 (Task #27).
3. §10.4 Phase 1 기간이 15~19주 → **16~20주** 로 확장 (원칙 13 엔진 0.5~1주 추가 + W2b 병렬화 흡수 고려).
4. §10.5.1 성공기준 condition 6 신설: "Phase 1 종료 시 최소 1 개 abstract 본부가 Socratic dialog 통해 active 로 승격된 이력" (원칙 13 dogfooding).
5. 본 HANDOFF v2.6 → v2.6-final 로 bump, round3_summary `completed: 11, in_progress: 0, pending: 0` 확정.

**다음 세션이 읽어야 할 곳** (분기별):
- 시나리오 B (Phase 1 킥오프): §4.3 + `10-phase1-implementation.md §10.4 (16~20주)` + `§10.11 (CLI-first)`
- 시나리오 C (개인 계정 이관): §4.4 + `CROSS-ACCOUNT-MIGRATION.md` 전체 + §10 Cross-Account Migration Playbook
- 시나리오 D (Round 4 요구): §4.5 — 중간 삽입 금지 원칙 준수

### 2.R3.4 Round 3 설계 결정 요점 (유실 방지용)

1. **3-level intensity 기호**: 👍 권장 / ⚪ 중립 / ⚠ 비권장. **정확히 1 개의 👍** (ALT-INV-2). ⚠ 도 선택 가능 (never-hard-block, ALT-INV-3).
2. **3 activation scope**: full / scoped (with parent_division) / temporal (with sunset_at). parent self-reference 와 순환은 schema violation (차단 허용).
3. **Phase 1 기본 active = dev + strategy-pm 만**. 나머지 4 개는 `activation_state: abstract`. 다른 조합은 경고만, 차단 금지.
4. **dialog_trace_id 형식**: `dlg-YYYY-MM-DD-<target-id>-<seq>` (install wizard 는 `dlg-install-…-00`).
5. **`/sfs division` 은 user-only caller**. agent 자동 호출 금지 (INV-5, rule/division-activate-user-only).
6. **override 시 rationale 강제 수집 금지** (원칙 13 paternalism 방지). 선택 질문만 허용.
7. **CLI > API > MCP > Claude-native** 4-tier. MCP 사용 시 `l1.tool.mcp.invoked` 에 rationale 필수.
8. **install v2.0 은 division-activation.dialog 와 동일한 5-phase 패턴 재사용** (`dialog_id: install-wizard`).

---

## 2. 이전 세션 (v2.4→v2.5) 추가 완료 요약 — Round 2 종결 (아카이브)

### 2.000 Task #9 (#22) 완료 — INDEX.md v0.4-r2 동기화 (직전 세션에서 완료)

- 12-point 체크리스트 전수 반영 (Solon 브랜드 / 원칙 10·11·12 / Gate 6개 (G-1 추가) / P-1 phase / 13 commands / README 링크 / Tier Profile / L3 driver / 8 Evaluators / 15~19주 / fabrication 수정 이력 / HANDOFF 제외)
- 파일: `INDEX.md` (v0.4 → v0.4-r2, ~340 line → ~420 line)
- §3 Reading orders 확장 (§3.0 10분 overview, §3.7 Brownfield user path)
- §4 Cross-reference matrix 대폭 확장 (카테고리별 그룹화, 🆕 마커로 v0.4-r2 신규 식별)
- §7 changelog entry 추가

### 2.001 Task #10 (#23) 완료 — auto-memory 업데이트

- 파일: `/sessions/optimistic-adoring-fermi/mnt/.claude/projects/-sessions-optimistic-adoring-fermi/memory/MEMORY.md` (신규)
- 7 섹션: project overview / Round 2 state / user directives verbatim / structural facts / mode Gate sequences / session history / next session expectations
- 원칙 7 명확화 테이블 포함 (원칙 7 ≠ "fail-hard-over-silent-degrade")
- Brownfield absolute rules + Phase 1 budget caps
- ⚠️ 단, MEMORY.md 는 **로컬 Claude Code 파일** — 개인 계정으로 이관되지 않음. 본 HANDOFF + docset 본문이 실질적 cross-account carrier (§10 참조).

### 2.002 Round 2 전체 종결 확인 (15/15)

| 분류 | 개수 | 상태 |
|:-:|:-:|:-:|
| P0 완료 | 13 | ✅ |
| 이번 세션 완료 | 2 (#9, #10) | ✅ |
| 남은 pending | 0 | — |

### 2.00 Task #3 (#16) 완료 — 도큐셋 루트 README.md 신규 작성 (직전 세션)

**생성 파일**: `/sessions/optimistic-adoring-fermi/mnt/agent_architect/2026-04-19-sfs-v0.4/README.md` (375 line, 목표 350~500 범위 내)

**12 섹션 구조 (HANDOFF v2.3 §4.3 지시 준수)**:
1. Solon 한 줄 소개 (hero, brand vs /sfs 분리 명시)
2. 이 docset 은 무엇인가 (스펙/근거/계약서 3 역할 + 읽기 순서)
3. 빠른 시작 (3-minute tour, greenfield 4단계 + brownfield 3단계)
4. 12대 원칙 요약표 (위반 시 효과 column 추가 + 이중 방어선 설명)
5. PDCA 계층 & Gate (3-layer + phase+gate 표 + G-1~G5 요약)
6. 13개 `/sfs *` command 개요 (operator/산출물 표)
7. 3-Channel Observability (L1/L2/L3 표)
8. Tier Profile (minimal/standard/collab + 선택 가이드)
9. Phase 1 구현 현황 (🟢/🟡/🔴 상태표)
10. Docset 파일 맵 (트리)
11. 용어집 (Solon / /sfs / Initiative / Sprint / PDCA / 6 본부 / 12 원칙 등 30+ 용어)
12. Contributing / Versioning / Changelog (v0.3→v0.4→v0.4-r1→v0.4-r2)
+ 하단 "지금 어디로 가야 하나요?" 독자별 내비 표

**중복 회피 원칙 (HANDOFF §4.4)**:
- INDEX.md = cross-ref matrix (완전 색인)
- §00-intro.md = 공식 서문 + 제품 철학 선언
- README.md = "10분 overview" — 앞 hook + 독자별 entry point

### 2.01 escalate.md 원칙 7 fabrication 수정 (부가 defect fix)

Grep 재확인 결과 원칙 7 = "CLI + GUI 통합 백엔드" 이며, "fail-hard-over-silent-degrade" 는 fabricated concept 이었음. 3 occurrence 수정:
- frontmatter references: → "§2.2 자기검증 금지 + §2.10 사람 최종 필터 (이중 방어선)"
- Intent 본문: → "원칙 2 + 원칙 10 의 이중 방어선 실질 창구" + "§6 Escalate Plan 은 fail-hard 규칙의 표준 출구"
- 관련 docs 섹션: → §2.2 + §2.10 2-line 분리

**이전 세션 (v2.2→v2.3) 의 원칙 5 fabrication 수정과 합쳐, 총 8 occurrence cross-reference defect 이 모두 해결됨** (plan.md / design.md / do.md / handoff.md / escalate.md).

---

## 2a. 이전 세션 (v2.2→v2.3) 추가 완료 요약 (아카이브)

### 2.0 Task #4 (#17) 완료 — 11 `/sfs *` command spec 전량 작성

**생성된 파일 (11개, `appendix/commands/` 내)**:

P0 (7개):
1. `install.md` — Haiku, 설치 + 모드 선택 (greenfield/brownfield 분기, --tier-profile, --l3-backend, --yes)
2. `plan.md` — Sonnet + Opus(plan-validator), G1 전, requires G-1 (brownfield) + G0
3. `design.md` — Sonnet(worker)+Opus(lead), division별 evaluator 매트릭스, CPO 5-Axis (design 본부), E_SELF_VALIDATION_ATTEMPT
4. `do.md` — Sonnet(worker)+Haiku, Opus 금지, 30min timeout, --resume, DoD yaml
5. `check.md` — Sonnet(QA)+Opus(CPO), G4 formula `Gap×0.4 + 5-Axis×0.6` ≥85, human-final-filter 6 체크박스, --yes warn
6. `act.md` — Sonnet, seed pattern matching, H6 DB 적재, --promote-to-seed
7. `status.md` — Haiku 단독, read-only, --scope/--format/--save/--metrics, text+JSON 샘플

P1 (3개):
8. `brainstorm.md` — Opus, G-1 vs G0 관계표, --pivot / --new-feature-from-brownfield 플래그로 원칙 12 강제
9. `handoff.md` — Sonnet (본부장), G3 Pre-Handoff, self-handoff 감지(원칙 5.3) + --delegate-to, gap-detector preview ≥85
10. `retro.md` — Opus (CEO + PM lead), G5, sprint-retro-analyzer + pattern-miner + CPO 5-Axis (β-3만), --link-to-initiative

P2 (1개):
11. `escalate.md` — β-1 Sonnet / β-2 Sonnet / β-3 Opus, Case α/β/γ 자동 분류 + 5-Option Protocol, --resolve/--abort-pdca, level 자동 승격 (24h)

**공통 준수사항**:
- schema/command-spec-v1 frontmatter 전수 준수
- 9 섹션 구조 (Intent / Input / Procedure / Output / Error Handling / Examples / 관련 docs)
- tool_restrictions 명시 (특히 check=read+test only, do=full, status=read-only)
- audit_fields 통일 (called_by, called_at, pdca_id, sprint_id, division 등)
- L1 이벤트 emit 경로 기록
- 각 command 2~4개 예시 (정상 PASS + 주요 FAIL + edge case)

---

## 2b. 이전 세션 (v2.1→v2.2) 추가 완료 요약 (참고용, 아카이브)

### 2.1 Task #14 (#27) 완료 — `/sfs discover` spec
- 파일: `appendix/commands/discover.md`
- 내용: frontmatter (phase=p-1, mode=brownfield, Opus forbidden, cost cap), Intent, Input, Procedure 3-pass pipeline (Haiku inventory → Sonnet evidence → Sonnet draft), Output (9 필수 섹션), Error Handling, Examples 3종, Phase 1 checklist

### 2.2 Task #13 (#26) 완료 — §05 G-1 Intake Gate (§5.11 신규)
- 파일: `05-gate-framework.md`
- 내용: §5.11 전 섹션 신규 (§5.11.1~5.11.10). G-1 위치와 1회성, discovery-report-validator spec (7축 검증), `.g-1-signature.yaml` schema, Pass/Fail 라우팅, 원칙 매핑, G-1 vs G0 관계표, L1 event schema, 비용 cap, G-1 vs G5 비교, Phase 1 implementation checklist

### 2.3 Task #8 (#21) + #15 (#28) 완료 — §10 tier-based Budget/Risk 재계산 + brownfield 시나리오
- 파일: `10-phase1-implementation.md`
- 내용 (9개 Edit 적용):
  1. Title: "14~18주" → "15~19주, tier=minimal 기본 + brownfield optional"
  2. Version: 0.4 → 0.4-r2, defines + references 확장
  3. Context Recap: v0.4-r2 3-point 변경 노트 추가
  4. TOC: 10.1~10.10 모두 업데이트, brownfield 관련 표기 추가
  5. §10.1.2 In-Scope: Install Mode / Phase / G-1 / Tier Profile / L3 Backend Driver / Brownfield Dogfooding 행 추가
  6. §10.1.3 Out-of-Scope: obsidian/logseq/confluence/custom driver, tier standard/collab 실제 차등, Brownfield Incremental Discovery, migrate/supersede 액션 추가
  7. §10.1.4 NEW: Install Mode 범위 (greenfield P0, brownfield P0-optional)
  8. §10.2.1 요약표: 7→8 evaluator, 4→5 skill, 합계 25→27, 공수 14→15.5주
  9. §10.2.2: "7 Evaluator" → "8 Evaluator", discovery-report-validator Sonnet 예외 설명
  10. §10.2.5: "4 Operation Skill" → "5 Operation Skill", sfs-discover 첫 행 추가 (brownfield only + read-only 강제)
  11. §10.4 주차별: W5에 discovery-report-validator, W9에 G-1 구현, W10에 sfs-discover, W13에 .solon-manifest.yaml coexistence 처리, W15 brownfield integration, W19 optional brownfield dogfooding
  12. §10.4.3 병렬화: 8 Evaluator + W9~W10 새 병렬 구간
  13. §10.4.4 Critical Path: 단절 조건에 W5 discovery-report-validator, W13 solon-manifest 2건 추가
  14. §10.5.1-b NEW: Optional 브라운필드 검증 조건 3개 (b1/b2/b3)
  15. §10.5.3: brownfield 비용 cap metrics 5개 추가 (P-1 <$15, G-1 <$0.30 등)
  16. §10.5.4: brownfield 관점의 성공 재해석 문단 추가
  17. §10.6.5 NEW: Brownfield Dogfooding (optional) 전체 섹션 — 목적, 후보 4종, 5일 진행 절차, 성공 판정, 실패 복구, W19 skip 조건
  18. §10.7: R9 (brownfield P-1 비용 폭주), R10 (기존 docs coexistence 갈등) 추가
  19. §10.10.1: 공수 표 — greenfield만 385h / + brownfield 410h 구분
  20. §10.10.2: tier-profile × mode 비용 매트릭스 (minimal/standard/collab + brownfield 1회성 repo-size별)
  21. §10.10.3: L3 Backend Driver / Legacy repo access 행 추가

---

## 3. Task 현황 (ID 기준 정확히)

### Round 2 완료 ✅ (15개, 아카이브)

| TaskList ID | 원래 ID | 작업 | 커밋된 파일 |
|:-:|:-:|------|-------------|
| #1 | #14 | §02 원칙 10 human-final-filter | 02-design-principles.md |
| #2 | #15 | §00-intro 제품 철학 블록 | 00-intro.md |
| #3 | #16 | README.md 신규 작성 (docset 루트, 375 line) | README.md |
| #4 | #17 | 11개 /sfs * command spec 작성 | appendix/commands/{install,plan,design,do,check,act,status,brainstorm,handoff,retro,escalate}.md |
| #5 | #18 | appendix/schemas/divisions.schema.yaml 확장 | appendix/schemas/divisions.schema.yaml |
| #6 | #19 | §08 L3 driver 일반화 + §8.11 | 08-observability.md |
| #7 | #20 | §07 plugin tier/backend + §7.10 brownfield | 07-plugin-distribution.md |
| #8 | #21 | §10 tier-based Budget/Risk 재계산 | 10-phase1-implementation.md |
| #9 | #22 | INDEX.md v0.4-r2 동기화 | INDEX.md |
| #10 | #23 | auto-memory 업데이트 | MEMORY.md (local) |
| #11 | #24 | §02 원칙 11·12 brownfield | 02-design-principles.md |
| #12 | #25 | §04 P-1 Discovery Phase | 04-pdca-redef.md |
| #13 | #26 | §05 G-1 Intake Gate (§5.11 신규) | 05-gate-framework.md |
| #14 | #27 | /sfs discover spec 추가 | appendix/commands/discover.md |
| #15 | #28 | §10 brownfield 시나리오 (§10.6.5) | 10-phase1-implementation.md |
| #16 | — | CROSS-ACCOUNT-MIGRATION.md 신설 + HANDOFF §10 | CROSS-ACCOUNT-MIGRATION.md, HANDOFF §10 |

### Round 3 완료 ✅ (11개, 아카이브)

| TaskList ID | 코드 | 작업 | 커밋된 파일 |
|:-:|:-:|------|-------------|
| #17 | R3-01 | §02 원칙 13 신설 (Progressive Activation + Non-Prescriptive) | 02-design-principles.md §2.13 + §2.14 |
| #18 | R3-02 | divisions.schema.yaml v1.0 → v1.1 | appendix/schemas/divisions.schema.yaml |
| #19 | R3-03 | /sfs division command spec | appendix/commands/division.md |
| #20 | R3-04 | Socratic meta dialog tree | appendix/dialogs/division-activation.dialog.yaml |
| #21 | R3-05 | 본부별 branch 6 개 | appendix/dialogs/branches/{taxonomy,qa,design,infra,strategy-pm,custom}.yaml |
| #22 | R3-06 | dialog-state.schema.yaml | appendix/schemas/dialog-state.schema.yaml |
| #23 | R3-07 | alternative-suggestion-engine spec | appendix/engines/alternative-suggestion-engine.md |
| #24 | R3-08 | §10.11 CLI-First Tool Selection Policy | 10-phase1-implementation.md §10.11 |
| #25 | R3-09 | install.md v2.0 재설계 (Socratic wizard) | appendix/commands/install.md |
| #26 | R3-10 | §03 / README / INDEX 원칙 13 + division abstraction propagation | 03-c-level-matrix.md (§3.3 / §3.7 / defines), README.md (§2/§4/§5.3/§6/§9/§10/§11/§12), INDEX.md (frontmatter/§1/§3.8/§4/§7), CROSS-ACCOUNT-MIGRATION.md (sanity check 갱신), 04-pdca-redef.md + 05-gate-framework.md (frontmatter division/pm → division/strategy-pm 통일) |
| #27 | R3-11 | Phase 1 기본 활성 본부 재정의 + HANDOFF v2.6-final bump | 10-phase1-implementation.md (§10.2.1 active/abstract 분리 + 원칙 13 엔진 row + 합계 30/18.0 + §10.4 16~20주 + §10.4.1 W2b 열 + §10.4.2 W2b 엔진 task + W10 sfs-division + §10.4.3 forecast 16/20/18 + §10.4.4 Critical Path 재계산 + §10.5.1 condition 6 Progressive Activation dogfooding), HANDOFF-next-session.md v2.6 → v2.6-final |

### Round 3 진행 중 / Pending — **없음 (0/11)**

Round 3 종결. 다음 세션은 사용자 의중에 따라 시나리오 B/C/D 분기 (§4 참조).

> **다음 세션 첫 행동**:
> 1. 이 HANDOFF 의 §2.R3.1 표와 §2.R3.3 종결 근거를 읽고 Round 3 종결 상태 확인
> 2. `TaskList` 호출 → Round 3 task 전원 completed 확인
> 3. 사용자에게 다음 단계 의중 확인: (B) Phase 1 킥오프 (§4.3) / (C) 개인 계정 이관 (§4.4 + CROSS-ACCOUNT-MIGRATION.md) / (D) Round 4 추가 요구 (§4.5, 중간 삽입 금지)
> 4. 사용자가 "ㄱㄱ" 등 짧은 GO 신호만 주면 기본값은 **시나리오 C (개인 계정 이관 준비)** — 본 docset 이관이 "1주 이내" 임박이라 Phase 1 코드 작성은 이관 후가 안전 (v2.6-final 기본 가정).
> 5. 사용자가 "Phase 1 킥오프", "구현 시작" 등 명시 지시 시에만 시나리오 B 로 진입.

---

## 4. 다음 세션 첫 행동 가이드 (Round 3 종결 후, v2.6-final)

### 4.1 진입 순서 (엄격 준수)

1. **이 HANDOFF-next-session.md 전체를 정독** (§1 + §2.R3.1/§2.R3.3 종결 근거 + §3 필수).
2. `TaskList` 호출 → Round 3 task (#17~#27) 전원 completed 확인.
3. docset 루트 cd: `/sessions/<session-id>/mnt/agent_architect/2026-04-19-sfs-v0.4/` (세션 prefix 는 매번 바뀜).
4. 신규/갱신 핵심 파일 sanity check (사용자 질문 대비):
   - `02-design-principles.md §2.13` (원칙 13)
   - `03-c-level-matrix.md §3.3 + §3.7` (activation_state + Phase 1 Baseline active/abstract 분리)
   - `10-phase1-implementation.md §10.2.1 + §10.4 + §10.5.1 + §10.11` (원칙 13 엔진 + 16~20주 + dogfooding condition + CLI-first)
   - `appendix/commands/division.md` + `appendix/commands/install.md` (v2.0 Socratic wizard)
   - `appendix/dialogs/division-activation.dialog.yaml` + `branches/*.yaml` (5-phase + 6 branch)
   - `appendix/schemas/divisions.schema.yaml` (v1.1) + `appendix/schemas/dialog-state.schema.yaml`
   - `appendix/engines/alternative-suggestion-engine.md`
   - `README.md` + `INDEX.md` + `CROSS-ACCOUNT-MIGRATION.md` (v0.4-r3 동기화 완료 상태)
5. 사용자 첫 메시지 수신 후 §4.3 / §4.4 / §4.5 분기 판단.

### 4.2 시나리오 A — (적용 불가, 아카이브)

Round 3 종결 (11/11) 로 본 시나리오는 v2.6 단계의 "Task #26+#27 마무리 경로" 였으며 v2.6-final 시점에는 **이미 완료 상태**. 다음 세션은 §4.3 (Phase 1 킥오프) / §4.4 (이관) / §4.5 (Round 4) 중 하나로 직접 진입.

**전제**: 사용자의 다른 지시 없으면 이 경로로 바로 진행.

**4.2.1~4.2.3 — 아카이브 (v2.6-final 시점 완료)**

Task #26 (§03 / README / INDEX propagation) 및 Task #27 (Phase 1 기본 활성 본부 재정의 + HANDOFF bump) 세부 Step 은 §2.R3.1 표 마지막 2 행 및 §2.R3.3 종결 근거 참조. 본 섹션은 이관 후 새 Claude 가 Round 3 종결 경위를 추적할 때 "이렇게 완료했다" 는 히스토리 기록으로 보존된다.

### 4.3 시나리오 B — Phase 1 구현 킥오프 (Round 3 종결 후)

- 참조 진입점: `10-phase1-implementation.md §10.4` (주차별 계획, v0.4-r3 갱신분 **16~20주** 반영)
- W1~W2 Foundation + W2b (원칙 13 엔진) 선결 조건:
  - divisions.schema.yaml v1.1 바인딩 (activation_state/scope/parent_division/sunset_at/dialog_trace_id 필드 handler)
  - dialog-state.schema.yaml 바인딩 (turn tracking + resume + override 감사)
  - gate-report schema 최종화
  - L3 driver interface test harness
  - 🆕 **W2b — division-activation dialog engine** 구현 (division-activation.dialog.yaml + branches/* 바인딩, 5-phase A→B→C→D→E + X + 6 invariants INV-1~6 + terminal side-effects)
  - 🆕 **W2b — alternative-suggestion-engine** 구현 (3-tier + 👍/⚪/⚠ 출력, ALT-INV-1~6 invariant unit tests, never-hard-block 시스템적 보장)
  - 🆕 **W10 — sfs-division skill** (user-only caller, INV-5, engines 호출, divisions.yaml update, L1 이벤트 `division.activation.changed` emit)
- 예산 feasibility: <$400/mo (greenfield minimal tier)
- 인원/모델: Opus (CEO/CTO 설계, plan-validator), Sonnet (2 active 본부장 + 4 abstract 본부 placeholder + Worker + evaluator + 원칙 13 엔진), Haiku (status/lint)
- 리스크 먼저 확인: §10.7 R1~R10 (특히 R9 brownfield 비용 폭주, R10 docs coexistence)
- **Phase 1 기본 active 본부 = dev + strategy-pm 2 개만** (원칙 13, §10.2.1 본부장 수량 2 + abstract 4). 필요 시 `/sfs install` Q5 또는 `/sfs division activate qa` Socratic dialog 로 승격.
- **성공기준 condition 6 (§10.5.1)**: Phase 1 종료 시 최소 1 개 abstract 본부가 Socratic dialog 통해 active 로 승격된 이력 존재 — 원칙 13 dogfooding.

### 4.4 시나리오 C — 개인 계정 이관

- **§10 Cross-Account Migration Playbook 반드시 먼저 정독**
- 이관 체크리스트 10단계 (§10.3) 수행
- 회사 계정에서만 가능한 작업 (내부 git history, 내부 Notion DB) 을 먼저 처리하고 이관
- 이관 후 첫 세션 Claude 에게 brief: "Solon 이라는 설계 프로젝트. HANDOFF-next-session.md 부터 읽어. Round 3 완료 상태."

### 4.5 시나리오 D — Round 4 추가 요구 (사용자가 새 요구 제기 시)

- **중간 삽입 절대 금지** (Round 2 → brownfield 중간 삽입으로 10→15 확장, Round 3 → division abstraction 중간 삽입으로 9→11 확장 전례)
- 새 요구는 "Round 4 batch" 로 묶어서 plan → batch → 실행 순서 재수립
- v0.4-r3 → v0.4-r4 doc_id bump, HANDOFF v3.x 계열 신규 생성

---

## 5. 다음 세션 재개 프로토콜 (v2.6-final)

1. **이 HANDOFF-next-session.md 를 제일 먼저 Read** (특히 §1 한 문장 현황 + §2.R3.1/§2.R3.3 종결 근거 + §3 완료 표 + §4 분기 가이드 + §9 30초 요약).
2. `TaskList` 호출 → Round 3 task 전원 completed 상태 확인.
3. **사용자가 "이어서", "ㄱㄱ", "계속" 같은 짧은 GO 신호만 주면**: v2.6-final 기본 가정은 **시나리오 C (이관 준비)** — docset 이관이 "1주 이내" 임박이라 Phase 1 코드 작성은 이관 후가 안전. 단 사용자가 "Phase 1 킥오프" / "구현 시작" / "바로 시작" 류로 명시하면 시나리오 B 로 진입.
4. **사용자가 새 요구를 섞으면**: §4.5 Round 4 batch 처리 원칙 준수 (중간 삽입 금지, 새 요구는 Round 4 batch 로 묶어 plan → execute 순서 재수립, v0.4-r3 → v0.4-r4 bump).
5. **사용자가 "이관 ㄱㄱ" / "옮기자" 류 이관 신호**: `CROSS-ACCOUNT-MIGRATION.md` 를 primary 가이드로 삼고 §1~§6 순서로 체크리스트 실행.

**남은 의존 관계** (Round 3 종결 후 관점):
- Round 3 잔여 task — **없음**
- Phase 1 착수 (시나리오 B) — 별도 선결 조건 없음. §10.4 W1 바로 진입 가능 (단 이관 임박 상태에서는 권장도 아님)
- 개인 계정 이관 (시나리오 C) — `CROSS-ACCOUNT-MIGRATION.md` 전체 참조. 이관은 Round 3 종결 상태에서 하는 것이 권장 (본 snapshot 이 그 상태)
- Round 4 (시나리오 D) — 사용자 새 요구 등장 시에만 개시. 현재 미확정.

### 5.1 Session addendum (2026-04-20 modest-busy-allen 세션 로그)

회사 계정 modest-busy-allen 세션에서 v2.6-final stamp 이후 다음 **Scenario C §1 (이관 전 체크) 전수 실행** 완료:

| Task | §참조 | 상태 | 산출물 |
|------|-------|:-:|--------|
| MIG-1 | §1.1 docset 자족성 확인 | ✅ | CROSS-ACCOUNT-MIGRATION.md §1.1 self-check 통과 |
| MIG-2 | §1.2 MEMORY 추출 | ✅ | `MIGRATION-NOTES.md` (9 섹션 narrative) |
| MIG-3 | §1.3 외부 자산 인벤토리 | ✅ | `external-assets.md` §1 외부 URL 4 |
| MIG-4 | §1.4 MCP/plugin 인벤토리 | ✅ | `external-assets.md` §2 MCP 8 namespace + §3 plugin bkit v1.5.6 |
| MIG-5 | §1.5 Cross-ref Grep 검증 | ✅ | `cross-ref-audit.md` (fabrication 11 건 + Phase 1 TODO 13 개) + INDEX.md / README.md 🚧 마커 반영 |
| MIG-6 | §2.2 .gitignore 작성 | ✅ | `2026-04-19-sfs-v0.4/.gitignore` (docset sub-scope) + `agent_architect/.gitignore` (repo 루트 scope, `*.zip` 등 추가 제외) |
| MIG-9 | Brand rename Archon → Solon | ✅ | docset 전역 278 occurrence (25 파일) sed 치환 + `.archon-*` → `.solon-*` + `/sfs` 재해석 "Solon Founder System" |
| MIG-10 | Repo scope 결정 (docset-only vs archive) | ✅ | **옵션 B 선택**: `agent_architect/` 전체 push. v0.3 proposal + v0.4 outline archive + `agents/` + `skills/` + `claude-shared-config/` 자산 통합. 루트 `README.md` + `.gitignore` 신설. |
| MIG-7 | §2.2 git init + initial commit | ⏳ user-Mac | 샌드박스 mount 권한 제약 (`.git/index.lock` 해제 불가) → 사용자 Mac 터미널 작업으로 이관 |
| MIG-8 | §2.2 GitHub remote add + push | ⏳ user | Repo URL 확정: `https://github.com/MJ-0701/solon` (사용자 개인 GitHub, private). 사용자 Mac 터미널에서 직접 push 예정 |

**Scenario C §1 (이관 전 체크) 100% closed + §2 packaging 95% closed** (push 만 남음). Push 기준점이 **`agent_architect/` 루트** 로 확정됨 (docset 단일 폴더가 아닌 아카이브 전체). 사용자 Mac 에서 다음 shell 실행하면 이관 완결:
```bash
cd /path/to/agent_architect                # ⚠️ 상위 루트! (이전 플랜의 2026-04-19-sfs-v0.4 아님)

# (1) 모든 .git 잔재 일괄 제거 — 샌드박스에서 시도됐던 git init 의 subdirectory .git 포함
#     이 step 을 skip 하면 "does not have a commit checked out" 에러 발생 (실제로 2026-04-20 최초 시도 시 겪음).
rm -rf .git 2>/dev/null
find . -name ".git" -type d -exec rm -rf {} + 2>/dev/null

# (2) 재확인 — 출력이 비어있어야 정상
find . -name ".git" -type d

# (3) 깨끗한 상태에서 init
git init --initial-branch=main
git add .
git status                                 # 검증: *.zip 3개 excluded / .DS_Store excluded / submodule 경고 없어야 함 / 합계 ~2.4M
git commit -m "solon v0.4-r3 initial snapshot — docset + archive + reusable assets"
git remote add origin https://github.com/MJ-0701/solon.git
git push -u origin main
```

**Push 전 확인 사항**:
- `find . -name ".git" -type d` 출력이 **완전히 비어있어야** 함 (step 2). 남아있으면 git 이 submodule 로 오인해서 `does not have a commit checked out` 에러.
- `git status` 에서 `agents.zip`, `claude-shared-config.zip`, `skills.zip` 이 **Untracked 에 없어야** 함 (`.gitignore` 의 `*.zip` 으로 제외). 만약 있으면 `.gitignore` 가 제대로 안 읽힌 것 → `git check-ignore -v agents.zip` 으로 디버깅.
- `.DS_Store` 도 제외 확인.
- GitHub repo (`https://github.com/MJ-0701/solon`) 는 **private** + initialize without README/gitignore/license (빈 repo 여야 non-fast-forward 안 남).

> 이관 후 개인 계정 첫 Claude 가 본 §5.1 을 읽으면 "§1 은 끝났고 §2 git commit/push 만 남았다" + "Archon → Solon 리브랜드 반영" + "repo scope = agent_architect 전체 (docset + archive + assets)" 를 3 초만에 파악 가능. 루트 `agent_architect/README.md` 가 repo 오리엔테이션 역할.

---

## 6. 절대 실수하지 말 것 (Pitfall 모음)

### 6.1 아키텍처 (브랜드/네이밍)
- **제품명은 Solon, command는 `/sfs`.** 사용자가 의도적으로 분리했음. 합치려 하지 말 것.
- **doc_id는 여전히 `sfs-v0.4-*`**. v0.5로 bump 안 함.
- **principle/* 태그는 구조 식별자** — 브랜드 rename 시에도 건드리지 말 것.

### 6.2 PDCA/Gate
- **G-1은 install 당 1회, P-1도 install 당 1회**. Sprint마다 반복하지 않음.
- **G0(Brainstorm Gate)는 Initiative 당 1회**. greenfield 모드 기본. brownfield에서는 원칙 12로 제한됨(§2.12.3 참조).
- **G-1 PASS 후에도 새 Sprint에 신기능(예: AI 검색 추가) 기획 시 G0 재호출 허용**. 전체 pivot 시에도 G0 허용.
- **원칙 2(self-validation-forbidden)와 원칙 10(human-final-filter) 혼동 금지**. 원칙 2 = agent↔agent, 원칙 10 = system↔human.
- **원칙 9·11·12 삼각관계**: 9 = greenfield brainstorm 강제, 11 = brownfield first pass = read-only, 12 = brownfield retro brainstorm 금지. 서로 보완.

### 6.3 Brownfield 규칙
- **P-1은 Read/Glob/Grep만 허용**, Write/Edit 금지 (`rule/brownfield-discovery-read-only`).
- **P-1에서 Opus 금지** — 원칙 11 비용 cap. Sonnet + Haiku만.
- **L3 back-fill 금지** — `rule/l3-no-backfill`. 기존 repo의 과거 데이터를 L3에 채워넣지 않음.
- **기존 docs/와 공존** — `.solon-manifest.yaml`로 마이그레이션 계획만 수립, 즉시 overwrite 금지.
- **6개 체크박스 + 이름/날짜 서명 없으면 G-1 PASS 불가** (§5.11.3).
- **`--yes` flag로 자동 서명 시** L1 event에 `warnings: ["auto_signed"]` flag 붙음.

### 6.4 모드별 Gate 순서
```
greenfield: install → brainstorm(G0) → plan(G1) → design(G2) → do → handoff(G3) → check(G4) → act → retro(G5)
brownfield: install --mode brownfield → discover(P-1) → G-1 → plan(G1) → ... (G0는 신기능 Sprint에서만)
```

### 6.5 §10 Tier/Budget 새 규칙
- **Phase 1 기본 tier는 minimal**. standard/collab은 schema 수준만.
- **greenfield 월 비용 < $400 (minimal tier)** — Phase 1 secondary 목표.
- **brownfield 1회 P-1 < $15 (medium repo)** — 원칙 11 cap.
- **G-1 1회 < $0.30** — §5.11.8.
- **abort threshold $80** — repo size 대형 시 강제 중단 (`abort_on_budget_exceeded`).

---

## 7. 파일 Inventory (2026-04-20 Round 3 종결 11/11 기준, v2.6-final)

### 본문 11개 + 루트 3개 + 이관 가이드 1개
```
00-intro.md                   §0 Elevator Pitch (+ 제품 철학 블록) ✅
01-delta-v03-to-v04.md        §1 v0.3 → v0.4 Delta (변경 없음)
02-design-principles.md       §2 13대 원칙 (🆕 §2.13 원칙 13 + §2.14 의존 그래프) ✅
03-c-level-matrix.md          §3 C-Level × Division (🆕 R3 §3.3 activation_state 소개 + §3.7 Phase 1 Baseline active/abstract 분리 + defines `concept/division-activation-state`) ✅
04-pdca-redef.md              §4 Initiative ⊃ Sprint ⊃ PDCA + P-1 Discovery (🆕 R3 frontmatter division/pm → division/strategy-pm 통일) ✅
05-gate-framework.md          §5 G-1 + G1~G5 + 7 Failure Modes (🆕 R3 frontmatter division/pm → division/strategy-pm 통일) ✅
06-escalate-plan.md           §6 Escalate-Plan + H6 (변경 없음)
07-plugin-distribution.md     §7 plugin tier/backend + §7.10 brownfield ✅
08-observability.md           §8 L1/L2/L3 + L3 driver 일반화 + §8.11 ✅
09-differentiation.md         §9 vs bkit 차별화 (변경 없음)
10-phase1-implementation.md   §10 Phase 1 계획 (🆕 R3 16~20주 + §10.2.1 active 2/abstract 4 + 원칙 13 엔진 row + §10.4 W2b 열 + §10.5.1 condition 6 dogfooding + §10.11 CLI-first Policy) ✅
INDEX.md                      🆕 R3 v0.4-r3 전면 동기화 (§1/§3/§4/§7) ✅
README.md                     🆕 R3 13대 원칙 + 14 commands + /sfs division + 용어집 7종 추가 + §12 v0.4-r3 changelog ✅
HANDOFF-next-session.md       ← 본 문서 (v2.6-final, 2026-04-20 새벽, Round 3 종결 11/11 snapshot)
CROSS-ACCOUNT-MIGRATION.md    🆕 R3 sanity check 13→14 + 원칙 13 + /sfs division 질문 추가 ✅
```

### Appendix 상태 (Round 3 신규 생성물 표기)
```
appendix/
├── commands/
│   ├── README.md                ✅ Round 2 신규 (12 command index, schema v1) (⚠️ Task #26 에서 13→14 command 갱신 권장)
│   ├── discover.md              ✅ Task #14 완료
│   ├── install.md               🆕 R3 Task #25 v2.0 재작성 (Socratic wizard Q1~Q6, wizard_trace_id, 4 examples)
│   ├── brainstorm.md            ✅ Task #4 완료 (Opus, G-1 vs G0 표)
│   ├── plan.md                  ✅ Task #4 완료 (Sonnet+Opus, plan-validator)
│   ├── design.md                ✅ Task #4 완료 (division 매트릭스)
│   ├── do.md                    ✅ Task #4 완료 (Sonnet worker, Opus 금지)
│   ├── handoff.md               ✅ Task #4 완료 (G3, self-handoff 감지)
│   ├── check.md                 ✅ Task #4 완료 (G4 formula, 6-checkbox)
│   ├── act.md                   ✅ Task #4 완료 (seed pattern matching)
│   ├── retro.md                 ✅ Task #4 완료 (Opus, G5, pattern-miner)
│   ├── status.md                ✅ Task #4 완료 (Haiku read-only)
│   ├── escalate.md              ✅ Task #4 완료 (β-1/2/3 + 5-Option)
│   └── division.md              🆕 R3 Task #19 (activate/deactivate/list/add/recommend/status, user-only caller)
├── dialogs/                     🆕 R3 신규 폴더
│   ├── division-activation.dialog.yaml   🆕 R3 Task #20 (5-phase A→B→C→D→E + X, 6 invariants, 5 terminals)
│   └── branches/                🆕 R3 신규 폴더
│       ├── taxonomy.yaml        🆕 R3 Task #21
│       ├── qa.yaml              🆕 R3 Task #21 (채명정 persona 예시 포함)
│       ├── design.yaml          🆕 R3 Task #21
│       ├── infra.yaml           🆕 R3 Task #21
│       ├── strategy-pm.yaml     🆕 R3 Task #21 (activate + deactivate 병존, 1인 창업자 예시)
│       └── custom.yaml          🆕 R3 Task #21 (insurance-ops 예시, INV-C1/C2/C3)
├── engines/                     🆕 R3 신규 폴더
│   └── alternative-suggestion-engine.md  🆕 R3 Task #23 (6 ALT-INV, 3-tier + 👍/⚪/⚠, never-hard-block, Phase 1 checklist)
├── drivers/
│   ├── _INTERFACE.md            ✅ L3 driver contract v1
│   ├── notion.manifest.yaml     ✅ default driver
│   └── none.manifest.yaml       ✅ L3 비활성 driver
├── hooks/                       (기존)
├── schemas/
│   ├── divisions.schema.yaml            🆕 R3 Task #18 v1.0 → v1.1 확장 (activation_state/scope/parent_division/sunset_at/tier/dialog_trace_id + 13 validation rules)
│   ├── dialog-state.schema.yaml         🆕 R3 Task #22 신규 (DialogState + DialogTurn + 3 L1 이벤트 + 12 validation rules)
│   ├── g-1-signature.schema.yaml        ❌ 아직 없음 — Phase 1 구현 시 작성
│   └── gate-report.schema.yaml          (기존)
├── templates/
│   ├── analysis.md, brainstorm.md, design.md, plan.md, report.md  (기존)
│   └── discovery-report.template.md  ❌ 아직 없음 — Phase 1 구현 시 작성
└── tooling/                     (기존)
```

### Round 3 신규/수정 파일 15 개 요약

**신규 파일 10 개 + 폴더 2 개**:
- `appendix/commands/division.md`
- `appendix/dialogs/division-activation.dialog.yaml`
- `appendix/dialogs/branches/{taxonomy,qa,design,infra,strategy-pm,custom}.yaml` (6 개)
- `appendix/schemas/dialog-state.schema.yaml`
- `appendix/engines/alternative-suggestion-engine.md`
- (신규 폴더) `appendix/dialogs/` 및 `appendix/engines/`

**수정 파일 5 개**:
- `02-design-principles.md` (§2.13 + §2.14 신설)
- `10-phase1-implementation.md` (§10.11 CLI-first Policy 신설)
- `appendix/commands/install.md` (v1.0 → v2.0 전면 재작성)
- `appendix/schemas/divisions.schema.yaml` (v1.0 → v1.1 확장)
- `HANDOFF-next-session.md` (본 문서, v2.5 → v2.6)

**합계**: 신규 10 + 수정 5 = **15 파일** (+ 폴더 2 신설)

---

## 8. 토큰/세션 예산 가이드 (Phase 1 킥오프 시 or Round 4 batch 시)

### Round 3 완료 Task 실제 규모 (참고 기준선)
- #26 [R3-10] propagation — 대 (README §2/§4/§5.3/§6/§9/§10/§11/§12 + INDEX frontmatter/§1/§3/§4/§7 + §03 §3.3/§3.7 + 04/05 frontmatter + CROSS-ACCOUNT sanity check = **약 18 Edit / 3 세션분 분량** → 한 세션에 다 못 끝냄 주의)
- #27 [R3-11] Phase 1 재정의 + HANDOFF bump — 중대 (§10.2.1 row + §10.4.1/.2/.3/.4 + §10.5.1 condition 6 + HANDOFF frontmatter/§1/§2.R3/§3/§4/§5/§7/§9 = 약 15 Edit)

### 다음 세션이 시나리오 B (Phase 1 킥오프) 진입 시 예상 cost
- W1~W2 Foundation 스캐폴드 (divisions.schema + gate-report + L3 driver harness) — 대
- W2b 원칙 13 엔진 2 항목 구현 (dialog-engine + alternative-suggestion-engine) — 대 (invariant unit tests 포함)
- W3~W4 본부장 agent 2 (dev + strategy-pm active) + 본부장 placeholder 4 (qa/design/infra/taxonomy abstract) — 중
- W5~W9 Evaluators (8 종, brownfield 비활성 범위 포함) — 대
- → 세션 1 회당 1~2 주차가 한계 추정. 주간 HANDOFF bump 권장.

### 다음 세션이 시나리오 C (이관) 진입 시 예상 cost
- `CROSS-ACCOUNT-MIGRATION.md §1` 체크리스트 8 개 항목 검증 — 소
- docset 자족성 Grep 검증 ~10 건 — 소
- MIGRATION-NOTES.md 신설 (회사 계정 MEMORY 사본) — 소
- external-assets.md 신설 — 소
- 전체 이관 세션 1 회로 종결 가능 (사용자 실행 위주)

### 세션 할당 전략 (Round 3 종결 이후)
- **본 세션 (v2.6-final)**: Round 3 종결 11/11 완료. 다음 세션 대기.
- **다음 세션 (사용자 의중에 따라)**:
  - B 루트 → v2.7 Phase 1 킥오프 week-1 HANDOFF
  - C 루트 → v3.0 이관 완료 HANDOFF (개인 계정에서 작성)
  - D 루트 → v0.4-r4 Round 4 batch plan HANDOFF
- 각 세션 종료 시 HANDOFF 반드시 업데이트.

---

## 9. 요약: "내가 이 문서를 30초만 본다면?" (v2.6-final, Round 3 closure)

1. **Solon v0.4-r3 Round 3 종결 완료. 11/11 ✅ 0 건 남음.** docset v0.4-r3 설계 확정.
2. **Round 3 핵심 신설/반영 정리** (docset 자체의 "기억" — 사라지면 안 되는 것):
   - **원칙 13** (Progressive Activation + Non-Prescriptive Guidance) — §02 §2.13 + §2.14 의존 그래프 + §03 §3.3/§3.7 + §10 §10.2.1/§10.5.1 + README §4 row 13 + INDEX §3.8/§4.
   - **divisions.schema v1.1** (activation_state 4축 abstract/active/deactivated/pending + scope 3종 full/scoped/temporal + parent_division/sunset_at/tier/dialog_trace_id + 13 validation rules).
   - **`/sfs division` command** (activate/deactivate/list/add/recommend/status, **user-only caller** INV-5, agent 자동 호출 금지).
   - **Socratic division-activation dialog tree** (5-phase A→B→C→D→E + X, 6 invariants INV-1~6, 5 terminals, 6 branch 파일 `taxonomy/qa/design/infra/strategy-pm/custom`).
   - **dialog-state.schema** (DialogState + DialogTurn + turn tracking + resume + override 감사 + 3 L1 이벤트 + 12 validation rules).
   - **alternative-suggestion-engine spec** (6 ALT-INV, 3-tier alternatives × 3-level intensity 👍/⚪/⚠, ALT-INV-3 **never-hard-block** 시스템적 보장).
   - **§10.11 CLI-First Tool Selection Policy** (CLI > API > MCP > Claude-native, MCP 사용 시 `l1.tool.mcp.invoked` rationale 필수).
   - **install.md v2.0** (Socratic wizard Q1~Q6, `dialog_id: install-wizard`, division-activation dialog 재사용).
   - **Phase 1 기본 active 본부 = dev + strategy-pm 2 개만** (나머지 qa/design/infra/taxonomy 4 개는 abstract). 본부장 agent 수 2 + placeholder 4.
   - **§10.4 Phase 1 기간 15~19주 → 16~20주** (원칙 13 엔진 W2b 추가분).
   - **§10.5.1 condition 6 dogfooding**: Phase 1 종료 시 최소 1 개 abstract 본부가 Socratic dialog 통해 active 로 승격된 이력 필수.
3. **다음 세션 첫 행동**: 사용자 GO 신호 수신 후 §4.3 / §4.4 / §4.5 분기 판단.
   - **기본 가정 (v2.6-final)**: 이관 임박 (약 1주 이내) → **시나리오 C (이관 준비)** 가 safer.
   - 명시 지시 시에만 시나리오 B (Phase 1 킥오프) 진입.
4. **다음 읽을 문서 (신규 진입 시)**: 본 HANDOFF §1 + §2.R3.1 + §2.R3.3 + §3 + §4 → 원칙 13 본문 `02-design-principles.md §2.13` → Phase 1 재정의 `10-phase1-implementation.md §10.2.1/§10.4/§10.5.1/§10.11` → appendix 의 engines/dialogs/schemas/commands 순.
5. **🔴 계정 이관 경보 여전히 유효**: 조만간 (약 1주) 회사 계정 → 개인 계정 이관 예정. 다음 세션 Claude 는 "Solon 을 처음 보는 사람" 가정, docset 본문이 유일한 carrier. §10 + `CROSS-ACCOUNT-MIGRATION.md` 참조.
6. **설계 결정 유실 방지 (8 항목)**: §2.R3.4 참조. 특히 "**override 시 rationale 강제 수집 금지**" + "**Phase 1 기본 active = dev + strategy-pm 만**" + "**`/sfs division` user-only caller (agent 자동 호출 금지)**" + "**ALT-INV-3 never-hard-block**" + "**CLI > API > MCP > Claude-native 4-tier**".

끝. (유실 방지: 본 문서 v2.6-final — Round 3 종결 11/11. 다음 업데이트는 Phase 1 킥오프 시 v2.7 / Round 4 시 v0.4-r4 + HANDOFF 신규 생성 / 이관 완료 후 개인 계정 첫 세션에서 v3.0 작성.)

---

## 10. Cross-Account Migration Playbook (v2.5 신설, v2.6 유지)

### 10.1 배경

2026-04-20 Round 2 종결 직후 사용자 (채명정) 가 새 컨텍스트 공유:

> "로컬 문서화를 시켜야되는 이유는 이 작업은 지금 이 회사 계정에서 진행할게 아니라 조만간 내 개인계정으로 옮겨서 해야되기 때문에 사실상 다른 계정으로 세션포크가 돼야함 -> 그게 불가능하니까 문서를 꼼꼼히(인수인계 + 히스토리)"

**핵심 제약**:
- 회사 계정 (jack2718@green-ribbon.co.kr) 의 Claude Code 세션을 개인 계정으로 **fork 할 수 없음**
- Claude 의 세션 메모리 (`~/.claude/projects/...`) 는 **로컬 파일이지만 계정 바인딩 됨** → 이관 불가 또는 이관 무의미
- MCP connector (Notion, Jira 등) 는 회사 계정 전용 인증 → 개인 계정에서 재인증 필요
- **실질적 유일한 인수인계 채널 = docset 폴더 자체** (`2026-04-19-sfs-v0.4/` 전체)

### 10.2 불변 원칙 (cross-account 용)

1. **자족성 (Self-Sufficiency)**: docset 은 외부 도구/메모리 없이도 읽기만으로 Solon 을 완전히 재현 가능해야 함.
2. **메타데이터 명시**: 모든 결정의 "왜 이렇게 됐는지" 를 파일에 남길 것 (커밋 히스토리 대신).
3. **MCP/도구 최소화**: docset 본문이 MCP 연결 없이도 100% 이해 가능해야 함.
4. **2인 검증 가정**: 이관 후 Claude 는 docset 만 보고, 사용자 (채명정) 의 구두 설명이 유일한 외부 정보원.

### 10.3 이관 체크리스트 (사용자 실행 용)

| # | 단계 | 실행 주체 | 상세 |
|:-:|------|:-:|------|
| 1 | docset 패키징 | 사용자 | `2026-04-19-sfs-v0.4/` 폴더를 zip 또는 개인 git repo 로 전체 복사. 경로명 의존 없음. |
| 2 | MEMORY.md 내용 추출 | 사용자 | 회사 계정의 `/sessions/.../.claude/projects/.../memory/MEMORY.md` 를 docset 루트로 옮겨 포함 (예: `MIGRATION-NOTES.md`). 이관 시 로컬 메모리는 사라짐. |
| 3 | 외부 자산 일람 작성 | 사용자 | Solon 개발 과정에서 쓴 외부 자산 (Notion page ID, Jira issue key, 참고 문서 URL) 을 `external-assets.md` 로 기록. 개인 계정에서 해당 자산 접근 가능 여부 사전 확인. |
| 4 | MCP 의존성 목록 | 사용자 | 회사 계정에만 있는 MCP (Notion workspace token 등) 목록화. 개인 계정에서 재인증/재연결 플랜 수립. |
| 5 | 개인 계정에서 cold boot | 사용자 + new Claude | 개인 계정 Claude Code 세션 열기 → docset 폴더를 `agent_architect` 또는 유사 워크스페이스로 연결 → README.md 부터 읽기. |
| 6 | Onboarding brief 작성 | 사용자 | 새 Claude 에게 30초 brief: "Solon 이라는 설계 프로젝트. 전 계정 Claude 가 만든 docset 이 있고, 네가 읽으면서 이어받는다. HANDOFF-next-session.md 부터 읽어." |
| 7 | 첫 sanity check | new Claude | README → INDEX → 00-intro 순서로 읽고, "Solon 이 뭐고, 12원칙이 뭐고, /sfs 는 뭐고, 다음에 뭘 해야 하나" 를 3문단으로 정리해 사용자에게 확인. |
| 8 | Phase 1 kickoff 또는 Round 3 | 사용자 | 사용자가 다음 작업 선택 (§4 A/B/C). |
| 9 | MEMORY.md 재생성 | new Claude | 개인 계정에서 새 MEMORY.md 작성. 이전 회사 계정 MEMORY 는 참고만. |
| 10 | HANDOFF v3.0 업데이트 | new Claude | 이관 완료 시점을 HANDOFF v3.0 으로 기록. 본 v2.5 가 "회사 계정 last snapshot" 이 됨. |

### 10.4 docset 자족성 검증 (이관 전에 사용자가 확인)

- [ ] README.md + INDEX.md + 00~10 본문 + appendix 만으로 "Solon 이 뭐다" 이해 가능한가?
- [ ] 외부 URL (GitHub, Notion) 참조가 있다면 해당 URL 이 개인 계정에서도 접근 가능한가?
- [ ] 의사결정 히스토리 (왜 G-1 을 추가했는가, 왜 brownfield 를 뒷북 추가했는가) 가 파일에 남아 있는가?
- [ ] docset 내 모든 cross-reference 가 깨지지 않는가? (Grep 으로 `02-design-principles.md §2.X` 류 참조 검증)
- [ ] 사용자 핵심 지시 (§0 의 4개 verbatim) 가 HANDOFF 에 보존되어 있는가?
- [ ] 다음 세션이 해야 할 행동 (시나리오 A/B/C) 이 명확한가?

### 10.5 로컬 vs 이관 대상 파일 구분

| 파일 유형 | 위치 | 이관 여부 |
|-----------|------|:-:|
| docset 본문 (00~10, README, INDEX) | `agent_architect/2026-04-19-sfs-v0.4/` | ✅ 이관 (핵심 asset) |
| appendix/* | 동상 | ✅ 이관 |
| HANDOFF-next-session.md | 동상 | ✅ 이관 (carrier 역할) |
| MEMORY.md (auto-memory) | `/sessions/.../.claude/projects/.../memory/` | ⚠️ 사본으로 docset 에 복제 후 이관 (원본은 회사 계정 잔존) |
| Claude Code 세션 transcript | `/sessions/.../.claude/projects/.../*.jsonl` | ❌ 이관 불가 (원한다면 요약만 추출) |
| MCP connector 설정 | 계정별 | ❌ 재설정 필요 |
| bkit plugin cache | `/sessions/.../.local-plugins/` | ❌ 재설치 필요 (bkit 1.5.6 버전 기록 필수) |

### 10.6 향후 주의사항 (Round 3 이전에 이관 발생 시)

- 회사 계정에서만 접근 가능한 자산 (내부 git, 내부 Slack 로그 등) 에 docset 이 의존하지 않도록 사전 분리.
- 이관 후 첫 세션에서 Claude 가 혼란 시 `/sfs status --scope docset --format verbose` 에 준하는 "docset health check" 을 수동 실행 (파일 존재 + cross-ref 정합성 확인).
- bkit plugin 은 재설치 가능하지만 bkit 기반 artifact (예: bkit memory, PDCA template) 의 회사 계정 잔존물은 개인 계정에서 재생성 필요.

### 10.7 한 줄 요약

**"docset 이 개인 계정에 도착했을 때, 아무것도 모르는 새 Claude 가 README → INDEX → HANDOFF 만 읽고도 Solon 을 이어받을 수 있어야 한다."** 이게 본 §10 의 존재 이유.
