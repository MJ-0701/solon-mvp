---
doc_id: cross-account-migration-solon-v0.4-r2
title: "Cross-Account Migration Checklist — 회사 계정 → 개인 계정 이관 가이드"
version: 1.0
created: 2026-04-20
author: "Claude (direct 지시 by 채명정)"
applies_to: "Solon v0.4-r2 docset"
status: "draft — 실제 이관 시점 미정 ('조만간')"
related_docs:
  - "HANDOFF-next-session.md §10 Cross-Account Migration Playbook"
  - "README.md §12 Contributing / Versioning"
  - "INDEX.md §1 루트"
---

# Cross-Account Migration Checklist

> **읽어야 할 사람**: Solon docset 을 회사 계정에서 개인 계정으로 옮기는 사용자 (채명정) 본인, 또는 이관 후 새 세션에서 이어받는 Claude.
>
> **이 문서가 존재하는 이유**: Claude 의 세션은 계정 바인딩이라 다른 계정으로 fork 가 안 됨. 따라서 **docset (이 폴더) 자체가 유일한 인수인계 채널**. 로컬 MEMORY, 세션 transcript, MCP 인증은 계정을 못 넘는다.

---

## 0. TL;DR

1. 이 docset 폴더 (`2026-04-19-sfs-v0.4/`) 를 **통째로** 개인 계정 워크스페이스에 복사.
2. 개인 계정 Claude 에게 "HANDOFF-next-session.md 부터 읽어" 라고 30초 brief.
3. 그 Claude 가 README → INDEX → HANDOFF 를 읽고 "내가 뭘 이어받았는지" 3문단 요약 → 사용자 승인.
4. 이후 작업 = Phase 1 구현 또는 Round 3.

---

## 1. 이관 전 체크 (회사 계정에서)

### 1.1 docset 자족성 확인
- [ ] `ls 2026-04-19-sfs-v0.4/` 전체 파일 목록이 README.md §10 Docset 파일 맵과 일치.
- [ ] `README.md`, `INDEX.md`, `HANDOFF-next-session.md` 모두 최신 상태 (v0.4-r2 / v2.5 이상).
- [ ] 본문 11개 파일 (00~10) 모두 존재 + doc_id 에 `sfs-v0.4` 계열 유지.
- [ ] `appendix/commands/` 에 13개 spec (install, discover, brainstorm, plan, design, do, handoff, check, act, retro, escalate, status + README) 모두 존재.
- [ ] `appendix/schemas/`, `appendix/drivers/`, `appendix/templates/`, `appendix/hooks/`, `appendix/tooling/` 디렉터리 구조 유지.

### 1.2 MEMORY 추출
- [ ] 회사 계정 로컬 메모리 (`/sessions/<세션>/.claude/projects/<proj>/memory/MEMORY.md`) 내용을 docset 루트의 `MIGRATION-NOTES.md` 로 복사 (없으면 본 체크리스트와 함께 생성).
- [ ] 이 파일은 "회사 계정 시절의 Claude 가 남긴 유언" 같은 역할. 이관 후 참고용.

### 1.3 외부 자산 인벤토리
- [ ] `external-assets.md` 작성 — 외부 URL, Notion page, Jira issue, 참고 논문/블로그 링크 등.
- [ ] 각 항목에 "개인 계정에서도 접근 가능한가?" Y/N 표시.
- [ ] N 인 자산은 별도 처리 계획 (예: 회사 Notion → 개인 Notion 복제, 회사 Jira → personal tracking 으로 migrate).

### 1.4 MCP / plugin 인벤토리
- [ ] 사용 중인 MCP connector 목록 (Notion, Jira, Slack 등) + 개인 계정 대체 가능 여부.
- [ ] `bkit` plugin 버전 (현재 1.5.6) 기록 — 개인 계정에서 동일 버전 재설치 필요.
- [ ] 기타 설치된 plugin/skill 목록.

### 1.5 Cross-reference 정합성
- [ ] `grep -r "02-design-principles.md" 2026-04-19-sfs-v0.4/` 등으로 모든 cross-ref 유효성 확인.
- [ ] 원칙 번호 참조 (§2.1~§2.12) 가 모두 실제 §02 내 존재하는 원칙을 가리키는지 확인.
- [ ] fabrication 경보: 과거 "§2.5 외부자 검증", "§2.7 fail-hard-over-silent-degrade" 수정 이력이 §02 에 반영되어 있는지.

---

## 2. 이관 실행 (패키징 → 배송)

### 2.1 방법 A — zip 아카이브
```bash
cd /sessions/optimistic-adoring-fermi/mnt/agent_architect
zip -r solon-v0.4-r2-migration-$(date +%Y%m%d).zip 2026-04-19-sfs-v0.4/
# zip 을 개인 기기로 다운로드 → 개인 계정 워크스페이스에 업로드/압축해제
```

### 2.2 방법 B — git repo (권장)
```bash
cd /sessions/optimistic-adoring-fermi/mnt/agent_architect/2026-04-19-sfs-v0.4
git init                                    # 아직 repo 아닌 경우
git add .
git commit -m "solon v0.4-r2 pre-migration snapshot"
git remote add origin <채명정-개인-GitHub-repo-URL>
git push -u origin main
```
→ 개인 계정 Claude 가 `git clone` 으로 받으면 히스토리도 함께 이관됨.

### 2.3 방법 C — 수동 파일 복사
최악의 경우. 파일별 수동 다운로드/업로드. 순서는 README → INDEX → HANDOFF → 본문 11개 → appendix 순 권장.

---

## 3. 이관 후 개인 계정 Cold Boot

### 3.1 사용자가 새 Claude 에게 줘야 할 Brief (30초)
```
이 폴더는 "Solon" 이라는 AI 조직 운영 프레임워크 설계 문서야.
회사 계정에서 만들다가 개인 계정으로 넘어왔고, 너는 이관 후 첫 Claude 야.
HANDOFF-next-session.md 를 제일 먼저 읽어. 그 다음 README, INDEX 순서.
읽고 나서 "내가 뭘 이어받았는지, 다음 할 일이 뭔지" 3문단으로 요약해줘.
내 이름은 채명정이고, Solon 은 내가 1인 창업용으로 쓸 도구야.
```

### 3.2 새 Claude 의 첫 행동
1. `HANDOFF-next-session.md` Read
2. `README.md` Read
3. `INDEX.md` Read (특히 §3 Reading orders 의 §3.0 10분 overview)
4. `00-intro.md` + `02-design-principles.md` (12원칙) Read
5. 사용자에게 요약 전달 + 다음 작업 확인 (Phase 1 착수 / Round 3 / 기타)

### 3.3 새 Claude 가 피해야 할 실수
- "Solon 이 뭐예요?" 사용자에게 재질문 금지 — docset 에 다 있음.
- MEMORY.md 가 없다고 해서 "컨텍스트가 부족하다" 고 주장 금지 — MIGRATION-NOTES.md 가 대체.
- 회사 계정 MCP 를 호출 시도 금지 — 개인 계정에서 재인증된 connector 만 사용.
- docset 구조를 임의로 바꾸지 말 것 — 우선 읽고, 변경은 사용자 허가 후.

### 3.4 새 Claude 가 해야 할 첫 sanity check 질문들
- 원칙 7 의 실제 내용은? (정답: "CLI + GUI 통합 백엔드". "fail-hard-over-silent-degrade" 아님)
- 원칙 13 의 실제 내용은? (정답: "Progressive Activation + Non-Prescriptive Guidance". v0.4-r3 신규, 본부 단계 활성화 + 시스템 강제 금지)
- G-1 Gate 는 언제 발동? (정답: brownfield 모드 install 당 1회, P-1 Discovery 완료 후)
- 14개 `/sfs *` command 중 Opus 가 기본 인 것? (정답: brainstorm, retro, escalate β-3)
- `/sfs division` 은 누가 호출 가능? (정답: **사용자만**, INV-5 agent auto-invocation 금지)
- Phase 1 기본 active 본부? (정답: dev + strategy-pm 2개, 나머지 4개는 abstract)
- tier 기본값? (정답: minimal, Phase 1 에서 유일한 실제 구현)
- L3 backend driver 중 Phase 1 지원 목록? (정답: notion + none, 나머지는 out-of-scope)

정답을 맞추면 → 이관 성공. 틀리면 → docset 을 더 꼼꼼히 읽을 것.

---

## 4. 이관 후 HANDOFF v3.0 업데이트

이관이 실제로 일어나면 새 Claude 가 HANDOFF 를 v3.0 으로 bump:
- `account_context.current` 를 개인 계정 이메일로 변경
- `account_context.will_move_to` 를 `null` 로
- `status` 를 "이관 완료 — 개인 계정에서 Phase 1/Round 3 진행" 으로
- §2 에 "v2.5 → v3.0 이관 기록" 섹션 추가 (날짜, 이관 방식, sanity check 결과)
- §10 은 유지 (다음 이관 시 재사용 또는 history 로 남김)

---

## 5. 왜 이 파일이 docset 루트에 있나?

- `HANDOFF-next-session.md §10` 과 중복이지만, **이관 체크리스트는 docset 자체에 딸려 다녀야** 안전함.
- HANDOFF 는 "매 세션마다 업데이트되는 carrier" → 이관 중 쓰기 작업으로 오염될 수 있음.
- 본 파일 = "이관이라는 특정 사건에 대한 standalone 매뉴얼" → 세션 간섭 없이 참조.

---

## 6. 관련 문서

- `HANDOFF-next-session.md §10` — Cross-Account Migration Playbook 본문 (상세)
- `README.md §12` — Contributing / Versioning (이관 후 version bump 규칙)
- `INDEX.md §1` — 루트 파일 리스트 (본 파일 포함)
- `00-intro.md` — docset 첫 진입 (이관 후 새 Claude 가 읽음)
- `02-design-principles.md` — 13대 원칙 (새 Claude sanity check 용, v0.4-r3 부터 원칙 13 Progressive Activation 포함)

---

**끝.** 이관 성공 = 새 Claude 가 이 문서만 보고도 Solon 을 이어받는 것.
