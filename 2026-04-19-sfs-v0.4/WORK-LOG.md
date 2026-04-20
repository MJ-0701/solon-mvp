---
doc_id: sfs-v0.4-work-log
title: "Solon v0.4-r3 Work Log — 일주일 bridge 점진 작업 기록"
version: 1.0
created: 2026-04-20
author: "Claude (direct 지시 by 채명정)"
purpose: "회사 계정 migration 직후 ~ 새 Claude 환경 투입 전, 일주일 bridge 기간의 작은 작업 단위 (WU) 연속 기록. 새 Claude 가 이어받을 때 '이 repo 에서 무슨 일이 있었는지' 빠르게 파악 가능하도록."
scope: "v0.4-r3 docset 내부 정합성/내용 보강 작업만 (Phase 1 src/ 구현은 새 Claude 환경에서 시작)"
session_continuity: |
  각 WU (Work Unit) 는 다음 형식으로 기록:
    - WU-N: <제목>
    - intent: 왜 이 작업?
    - files: 수정된 파일 목록
    - commit: <short-sha> <제목>
    - pushed: <timestamp or "pending (user terminal)">
    - notes: 추가 컨텍스트
related_docs:
  - "HANDOFF-next-session.md (세션 간 연속성 본문)"
  - "MIGRATION-NOTES.md (계정 이관 타임라인)"
  - "cross-ref-audit.md (fabrication 추적)"
---

# Solon v0.4-r3 Work Log

> **역할**: 2026-04-20 이후 새 Claude 환경 투입 전까지, 작은 작업 단위로 repo 를 점진 개선한 기록.
> 각 항목은 로컬 커밋과 1:1 대응. Push 는 사용자가 터미널에서 일괄 또는 개별 수행.

---

## 범례

- **WU-N**: Work Unit 일련번호 (1 부터 시작)
- **infra**: 인프라/메타 작업 (WORK-LOG, HANDOFF, MIGRATION-NOTES 등 기록 계열)
- **content**: 도큐셋 본문/내용 수정
- **asset**: 재사용 자산 / 샘플 파일 생성
- **tooling**: 스크립트/훅/검증 도구 정비

---

## 2026-04-20 (Day 1)

### WU-1: WORK-LOG.md 신설 + d034d0d 기록

- **성격**: infra
- **intent**: 일주일 bridge 기간 동안 "작은 단위 → 기록 → 커밋" 루프의 출발점 문서. 새 Claude 가 이 repo 를 열었을 때 "2026-04-20~04-27 사이에 무슨 일이 있었지?" 를 WORK-LOG.md 한 파일만 봐도 파악 가능하게 만드는 것이 목표.
- **files**:
  - `2026-04-19-sfs-v0.4/WORK-LOG.md` (신규)
- **commit**: `7b8dae6` "WU-1: WORK-LOG.md 신설 + d034d0d backfill"
- **pushed**: pending (user terminal)
- **notes**:
  - bridge 기간 종료 (새 Claude 합류) 시점에 이 파일을 archive 로 이동 또는 MIGRATION-NOTES.md §3 로 병합할지는 그때 재결정.
  - WU 번호는 전역 단일 카운터 (WU-1, WU-2, ... — 날짜 구분 없이 증가).
  - FUSE 마운트 `.git/index.lock` unlink 불가 이슈 재발 시 우회 절차: `cp -r .git /tmp/agent_git_backup && rm /tmp/agent_git_backup/index.lock && GIT_DIR=/tmp/agent_git_backup GIT_WORK_TREE=<worktree> git <cmd>` → 완료 후 rsync 역전송.

### WU-0 (backfill): d034d0d — full-scope typo + stale-ref cleanup (Option ③)

> **backfill**: WU-1 신설 전에 이미 커밋된 작업을 소급 기록. d034d0d 는 공식적으로 WU-0 으로 표기.

- **성격**: content (typo/stale-ref cleanup) + infra (root README 강제 브리핑)
- **intent**: 계정 이관 직후 docset 전역 오탈자/stale 참조 정리. 4 카테고리 (A: real typo / B: brand·version stale / C: principle ID 3종 통일 / D: 00-intro stale).
- **files** (7):
  - `README.md` (root — STOP & READ 강제 브리핑 embed + /sfs canonical)
  - `2026-04-19-sfs-v0.4/README.md` (docset — 10일→16~20주 4지점, HANDOFF git-포함 표기)
  - `2026-04-19-sfs-v0.4/INDEX.md` (3 files→4 files, 원칙 ID 3종, title archaic "Agent" 제거)
  - `2026-04-19-sfs-v0.4/00-intro.md` (last_updated, elevator pitch 브랜드/CLI 분리, G-1+G1~G5, appendix 38 files 표기)
  - `2026-04-19-sfs-v0.4/07-plugin-distribution.md` (plugin.json displayName + name)
  - `2026-04-19-sfs-v0.4/CROSS-ACCOUNT-MIGRATION.md` (frontmatter v0.4-r2→r3, 세션 경로 placeholder)
  - `2026-04-19-sfs-v0.4/HANDOFF-next-session.md` (columnm→column)
- **commit**: `d034d0d` "docs(solon): full-scope typo + stale-ref cleanup (Option full)"
- **pushed**: pending (user terminal — `git push origin main`)
- **notes**:
  - 원칙 ID 3종은 `INDEX.md §4 cross-ref` 를 `02-design-principles.md` frontmatter 의 canonical 쪽으로 정렬 (소수 수정 = 큰 리스크 최소화).
  - cross-ref-audit.md 의 historical audit 엔트리 (`principle/cli-gui-unified-backend` 언급) 는 archive 보존 — fabrication 추적 이력은 수정 대상 아님.
  - 커밋 중 FUSE 마운트에서 `.git/index.lock` unlink 불가 이슈 발생. 우회: `/tmp/agent_git_backup` 에 .git 복사 → 거기서 commit → rsync 로 역전송. 같은 증상 재발 시 동일 절차.

---

### WU-2: HANDOFF-next-session.md Round 4 Bridge open (v2.6-final → v2.7-bridge)

- **성격**: infra
- **intent**: Round 3 은 종결됐지만 새 Claude 투입 전까지 bridge 기간이 있음. HANDOFF 는 "handoff entry point" 역할만 남기고, 실제 진행 로그는 WORK-LOG.md 로 이관. frontmatter 에 `round4_bridge` 블록 신설 + top intro 에 🆕 [Round 4 Bridge 상태] 박스 추가.
- **files**:
  - `2026-04-19-sfs-v0.4/HANDOFF-next-session.md` (frontmatter 17줄 교체 + top intro 박스 1개 추가)
  - `2026-04-19-sfs-v0.4/WORK-LOG.md` (본 엔트리 + 큐 재정렬)
- **commit**: `54ac583` "WU-2: HANDOFF v2.6-final → v2.7-bridge (Round 4 Bridge open)"
- **pushed**: pending (user terminal)
- **notes**:
  - version 2.6-final → 2.7-bridge
  - valid_until 재정의: "새 Claude (개인 계정) 합류 후 첫 세션이 v3.0 으로 bump 할 때까지"
  - critical_rule: "README + INDEX + HANDOFF + WORK-LOG 이 유일한 인수인계 채널"
  - 세션 경로 stale 참조 (`optimistic-adoring-fermi`) 제거 → `<session-path>` placeholder

---

### WU-3: G1~G5 → "G-1 + G1~G5" 일관성 propagation (current-state doc 한정)

- **성격**: content
- **intent**: v0.4-r2 에서 G-1 Intake Gate 가 추가됐으나 일부 본문에서 여전히 "G1~G5" 만 언급. 범위를 (A) 현재 상태 summary (v0.4-r3) 와 (B) 역사적 delta/timeline 으로 분리하여 **A 만 수정**, B 는 역사 보존.
- **files**:
  - `00-intro.md:171` (프로세스 summary)
  - `02-design-principles.md:79` (원칙 6 "도메인 agnostic" 정의)
  - `09-differentiation.md:394` (학습 곡선 — 보너스 SFS→Solon 브랜드 swap 3개 포함)
- **보존 (역사적 맥락)**:
  - `01-delta-v03-to-v04.md:60,79,94` (v0.3→v0.4 delta 기록 — 당시엔 G1~G5만 존재)
  - `MIGRATION-NOTES.md:64` (Round 1 타임라인 — G-1 은 Round 2 에서 도입)
  - `05-gate-framework.md` 다수 (G-1 과 G1~G5 를 명시적으로 구분 기술)
  - `10-phase1-implementation.md` 다수 (구현 계획에서 G-1 / G1~G5 명시 구분)
  - `07-plugin-distribution.md:86,996` (config 주석 + greenfield 구분 표현)
  - `INDEX.md`, `README.md` 이미 올바른 "G-1 + G1~G5" 표기
  - `appendix/schemas/l1-log-event.schema.yaml:162` (log 주석 — 보존, 필요시 WU-10 에서 재검토)
- **commit**: (WU-3 커밋 시 채워짐)
- **pushed**: pending (user terminal)
- **notes**:
  - Gate 집합은 총 6개 = G-1 (brownfield 전용, 1회성 intake) + G1~G5 (PDCA cycle 내부, 매 sprint 반복)
  - 09-differentiation.md 에서 SFS → Solon 브랜드 swap 도 함께 진행 (컨텍스트 연계, WU-8 범위 일부 선반영)

### WU-8: 도큐셋 "SFS" 단독 표기 disambiguation (brand prose → Solon)

- **성격**: content (브랜드 일관성) + tooling (GH Action display name)
- **intent**: MIG-9 Archon→Solon rename 이후에도 v0.3 시절 브랜드 이름 "SFS" 가 브랜드 프로즈로 112 occurrence 잔존. 이를 정리하여 v0.4-r3 현재 상태에서는 브랜드 = Solon 으로 통일. `/sfs` CLI prefix 와 `sfs-*` 구조적 식별자는 그대로 유지 (brand-decoupled CLI).
- **rule**:
  - **change (brand prose → Solon)**: "SFS는/의/가/를/과", "SFS H6", "SFS 본부", "SFS 5-Axis", "SFS Evaluator", "SFS Doc Validate" 등
  - **keep (structural identifiers)**: `/sfs` CLI prefix, `sfs-plan`/`sfs-gates`/`sfs-doc-validate` 등 ID, `sfs-v0.4-*` doc_id, `.sfs-local/` 경로, 파일명
  - **keep (historical refs)**: `이전 SFS/bkit 프로젝트`, `SFS-v0.3` 등 pre-rename 시절을 가리키는 명시적 역사 참조
- **files** (14):
  - 본문 10: `00-intro.md`, `02-design-principles.md`, `03-c-level-matrix.md`, `04-pdca-redef.md`, `05-gate-framework.md`, `06-escalate-plan.md`, `07-plugin-distribution.md`, `08-observability.md`, `09-differentiation.md`, `10-phase1-implementation.md`
  - appendix 4: `appendix/drivers/none.manifest.yaml`, `appendix/hooks/observability-sync.sample.ts`, `appendix/schemas/l1-log-event.schema.yaml`, `appendix/tooling/sfs-doc-validate.md`
- **치환 방식**:
  - Korean particle 연쇄 (`SFS는/이/을/과/의`) → (`Solon은/이/을/과/의`) 로 발음 정합 매핑
  - uppercase `SFS` 단독 → `Solon` (lowercase `/sfs`, `sfs-*` 는 미영향)
  - 복원 3곳: `07-plugin-distribution.md:917` (이전 SFS/bkit), `07-plugin-distribution.md:1050` (SFS-v0.3 버전), `02-design-principles.md:527` (이전 SFS/bkit) → 역사 참조 그대로
- **commit**: `764194f` "WU-8: SFS brand prose → Solon disambiguation (109 occurrences, 14 files)" + `4a1df93` "WU-8.1: WORK-LOG.md 에 commit sha 764194f 기록 + WU-11 큐 추가"
- **pushed**: pending (user terminal)
- **notes**:
  - 최종 잔존 `SFS` (전체 6개): 3 역사 참조 + 3 WORK-LOG 자기 참조 (WU-8 작업 기록 그 자체) — 모두 의도된 보존.
  - `sfs-doc-validate.md:122` GH Action display name `"SFS Doc Validate"` → `"Solon Doc Validate"` 로 함께 변경. 파일명 `sfs-doc-validate.md` 는 structural ID 로 보존 (단, 장기적으로는 `solon-doc-validate.md` 로 파일명까지 정렬하는 게 맞음 — 별도 WU 로 분리 가능).
  - **Multi-agent abstraction 연계**: 사용자가 WU-8 진행 중 "Codex/Gemini-CLI 에서도 사용하려면 추상화가 중요" 라고 제기. `/sfs` CLI prefix 가 이미 brand-decoupled 되어 있다는 사실이 이 질문과 직결. 별도 WU (WU-11 로 제안 예정) 에서 agent runtime 추상화 계획 수립.

---

### WU-11: RUNTIME-ABSTRACTION.md 신설 (multi-agent runtime abstraction, A scope)

- **성격**: content (신설 reference 문서)
- **intent**: 사용자 지시 "sfs를 claude 뿐만 아니라 codex랑 gemini-cli에서도 사용하고 싶거든?? 그래서 추상화 하는게 중요할듯?!" + "A ㄱㄱ 일단 디테일은 나중에 잡는게 맞고 일단은 최대한 mvp 형태로 뽑아서 난 다음주 부터 사용하는게 목적". → 기존 본문 비파괴, `RUNTIME-ABSTRACTION.md` 1개 파일만 신설해서 4-layer 추상화 골격 + 현 docset 의 lock-in map + Phase 1/Phase 2 슬롯 선언. MVP 범위 (A scope) 만 포함, B/C 는 후속 WU 로 예약.
- **scope 확정**: **A** (본문 수정 없음). B (Claude-specific 파일에 layer 힌트 주석) / C (Codex/Gemini 어댑터 초안) 는 Phase 1 Claude 구현 안정화 후 재검토.
- **files**:
  - `2026-04-19-sfs-v0.4/RUNTIME-ABSTRACTION.md` (신규, v0.1-mvp, 9 섹션 + Changelog)
- **주요 설계 결정**:
  1. **4-layer 모델**: L0 Domain Core (agnostic, 이미 존재) / L1 Execution Contract (agnostic, 신설) / L2 Runtime Adapter (per-runtime) / L3 Install-Package (per-runtime).
  2. **의존 방향**: L0 → L1 → L2 → L3 단방향. 역방향 (e.g. 02-design-principles.md 에서 plugin.json 직접 언급) 은 violation.
  3. **Phase 1 runtime scope**: Claude 단일 레일. Codex / Gemini-CLI 어댑터는 "abstract state" 로 선언 (원칙 13 progressive-activation 과 동치 구조).
  4. **L1 6 operation 카테고리** (MVP 선언): `invoke_agent` / `spawn_worker` / `read|write|edit_file` / `invoke_tool` (§10.11 4-tier 와 직결) / `emit_l1_event` / `run_in_background + monitor`.
  5. **Phase 1 → Phase 2 이관 4 조건**: Phase 1 success condition 6 충족 + L1 spec 이 실 Claude 구현으로 역검증 + 사용자 go 결정 + Codex/Gemini 우선순위 1개 택일 (동시 착수 금지).
  6. **DO NOT TOUCH 고정 목록 재확인**: `/sfs` prefix, `sfs-*` IDs, `.sfs-local/`, 역사 참조 3곳, 원칙 ID 3종.
  7. **⚠ v0.2 재판정 항목** 4개 기록: (a) §2.2 model allocation L0/L2 경계, (b) MCP 언급의 agnostic 가능성, (c) `cli-gui-shared-backend` 원칙의 GUI 정의 확장, (d) `agents/*.md` frontmatter `model:` 필드 추상화.
- **non-goals**:
  - 기존 본문 11개 + appendix 파일 수정 (B scope 이상 영역).
  - L1 execution-contract.v1.yaml 실제 파일 작성 (v0.2 예정).
  - Codex / Gemini-CLI 어댑터 실물 (v0.3 예정).
- **commit**: (커밋 후 채워짐)
- **pushed**: pending (user terminal)
- **notes**:
  - 문서 상한선 "A4 6~8장" 자기 제약 명시 — 비대화 방지.
  - INDEX.md 에는 아직 등록하지 않음. INDEX 갱신은 WU-11.1 또는 다음 infra WU 로 분리 가능 (의도적 분리: 이 문서가 transient reference 인지 영구 멤버인지 Phase 1 구현 진행 보며 판정).
  - 원칙 13 (progressive-activation) 구조를 runtime 축에 재적용한 셈 — Codex/Gemini 어댑터 = "abstract division" 와 동치 (§9 참조).

---

### WU-HANDOFF: HANDOFF v2.7-bridge → v2.8-bridge-handoff (세션 이관 지점)

- **성격**: infra
- **intent**: 현 세션 context window 포화 임박 → 다음 세션으로 이관 필요. 사용자가 "폴더에 변경사항 커밋해서 기록해두고 handoff 문서도 최신화 시키고 다른 세션에서 브리핑 해야될 메세지 만들어줘" 지시. HANDOFF 에 (a) 세션 이관 지점 frontmatter, (b) 완료 WU 전량 sha 맵, (c) 🚨 WU-11 사용자 대기 상태, (d) push 미완 7+커밋, (e) FUSE lock 우회 절차 링크 반영.
- **files**:
  - `2026-04-19-sfs-v0.4/HANDOFF-next-session.md` (frontmatter 재구성 + top intro 박스 갱신 + §0 지시 7~9번 추가)
  - `NEXT-SESSION-BRIEFING.md` (repo root, 신규 — 다음 세션 첫 메시지로 복붙할 텍스트)
  - `2026-04-19-sfs-v0.4/WORK-LOG.md` (본 엔트리 + WU-8.1 sha 보강)
- **commit**: `30e4418` "WU-HANDOFF: HANDOFF v2.7-bridge → v2.8-bridge-handoff (세션 이관 지점, WU-11 대기 반영)" + (WU-HANDOFF.1 커밋 시 채워짐 — BRIEFING + WORK-LOG)
- **pushed**: pending (user terminal)
- **notes**:
  - `NEXT-SESSION-BRIEFING.md` 는 docset 밖 (repo root) 에 배치. 이유: transient (다음 세션 첫 응답 이후 stale). docset 자체의 self-containedness 를 건드리지 않음.
  - 다음 세션 첫 행동 순서는 BRIEFING.md "🚨 첫 행동" 섹션 참조. WU-11 결정 (A/B/C) 이 최우선.

---

## 다음 실행 예정 (재정렬된 큐 — WU-11 A 완료 후)

| 순서 | WU | 성격 | 비고 |
|:-:|----|------|------|
| next | WU-4 | cross-ref-audit.md Phase 1 pending 중 #1 해결 | audit 소비 시작 |
| 2 | WU-5 | 05-gate-framework.md G-1 완전성 점검 | 가벼운 read+validate |
| 3 | WU-9 | 02-design-principles.md 원칙 13 완전성 재검증 | R3 신규 — 일찍 검증 |
| 4 | WU-7 | 07-plugin-distribution plugin.json 샘플 파일 분리 | Phase 1 asset 준비 |
| 5 | WU-10 | appendix/dialogs/branches/ 6 본부 YAML schema 정합성 | 중위험 batch |
| later | WU-11 B | Claude-specific 파일 frontmatter `layer:` 필드 + 본문 힌트 주석 | Phase 1 안정화 후 재검토 |
| Phase 2 | WU-11 C | Codex / Gemini-CLI 어댑터 초안 (`appendix/runtime-adapters/`) | Phase 2 go 결정 후 |
| — | WU-6 | claude-shared-config/.git IP 경계 재정리 | **BLOCKED** (사용자 결정 필요) |

---

## 기록 규칙

1. **WU 번호는 단조 증가** — 실패/철회해도 번호 재사용 금지 (철회 시 "WU-N (withdrawn)" 표기)
2. **각 WU 커밋 메시지 prefix** — `WU-N: <짧은 제목>` 선호 (git log 에서 WORK-LOG 와 대조 가능)
3. **commit sha 는 풀 7-char short-sha 로 기록** — 사용자가 `git log --oneline` 과 즉시 대조 가능
4. **pushed 필드** — `pending (user terminal)` 또는 `<YYYY-MM-DD HH:MM>` (사용자가 push 후 알리면 업데이트)
5. **Day N 헤더는 KST 기준 날짜** — 자정 넘어가면 새 Day 섹션

---

## Changelog

- **v1.0** (2026-04-20 오전): WU-1 신설 + WU-0 backfill (d034d0d)
- **v1.1** (2026-04-20 오후): WU-2/3 추가 + HANDOFF v2.7-bridge 연동
- **v1.2** (2026-04-20 심야): WU-8/8.1 완료 (109 SFS → Solon) + WU-11 큐 추가 (사용자 multi-agent abstraction 지시 반영)
- **v1.3** (2026-04-20 심야): WU-HANDOFF (세션 이관 지점, HANDOFF v2.8-bridge-handoff + NEXT-SESSION-BRIEFING.md 신설)
- **v1.4** (2026-04-20 심야, 새 세션): WU-11 A 완료 (RUNTIME-ABSTRACTION.md v0.1-mvp 신설, 4-layer 모델 + lock-in map + Phase 1/2 슬롯 선언) + 큐 재정렬 (WU-4 가 다음, WU-11 B/C 는 Phase 1 안정화 / Phase 2 이후로 이동)
