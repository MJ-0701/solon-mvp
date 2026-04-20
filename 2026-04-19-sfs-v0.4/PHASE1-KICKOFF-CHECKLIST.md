---
doc_id: sfs-v0.4-phase1-kickoff-checklist
title: "Solon Phase 1 — MVP Kickoff Checklist (7-step lightweight spike)"
version: 0.1-mvp
created: 2026-04-20
author: "Claude (WU-12, direct 지시 by 채명정)"
status: ready-for-use
scope: |
  사용자가 2026-04-27 주부터 새 회사 관리자 페이지 프로젝트 (`<PROJECT-NAME>`) 에
  Solon 을 "완전 구현" 이 아닌 "경량 7-step spike" 형태로 얹어서 즉시 사용 가능하게
  만들기 위한 W0 준비 + W1 첫 cycle 체크리스트.
  10-phase1-implementation.md §10.4 16~20주 풀스펙의 **압축 선행 런** 이며,
  풀스펙 자체를 대체하지 않는다.
axis_decisions:
  - axis_1_approach: "① lightweight spike — 브레인스토밍 → plan → sprint → 구현 → review → commit → 문서화 (7 step)"
  - axis_2_project: "B 새 별도 프로젝트 (admin panel for new company)"
  - repo_strategy: "admin panel = 독립 repo (회사 IP). Solon docset = 사용자 개인 workspace 에 분리 clone (개인 IP). 양 repo 는 물리적으로 격리 — admin panel repo 에는 Solon 참조 없음 (.gitmodules 조차 없음)."
  - docset_distribution_end_state: "claude plugin install solon (풀스펙 W13 Plugin Packaging 후). MVP 단계에서는 플러그인 미완성이므로 사용자 개인 workspace 의 로컬 경로 참조만 사용."
  - domain: "관리자 페이지 (매출, 현금영수증 발행, 권한 관리, 대시보드)"
active_divisions:
  - dev (active)
  - strategy-pm (active)
  - qa: abstract (MVP 1 cycle 에서는 미사용, 필요시 W1.5 이후 activate)
  - design: abstract
  - infra: abstract
  - taxonomy: abstract
gates_in_scope:
  - G0 (브레인스토밍 entry)
  - G1 (plan approval)
  - G2 (구현 entry — 정의 있음, 경량 실행)
  - G4 (review)
gates_out_of_scope:
  - G-1 (brownfield intake — 이 프로젝트는 greenfield 이므로 불필요)
  - G3 (design gate — design 본부 abstract 이므로 skip)
  - G5 (retrospective — MVP 1 cycle 범위 밖, 2~3 cycle 누적 후 재도입 검토)
observability:
  - L1: "수동 기록 (별도 S3 없음, .sfs-local/events.jsonl 로컬 파일만)"
  - L2: "git commit 자체가 L2 채널 역할"
  - L3: "none (외부 driver 미사용 — minimal tier)"
timebox:
  - W0: "1~2 일 (환경 준비)"
  - W1: "5~7 일 (첫 PDCA 1 cycle)"
related_docs:
  - "10-phase1-implementation.md §10.4 (풀스펙 16~20주 로드맵, 참조용)"
  - "RUNTIME-ABSTRACTION.md (Claude 단일 런타임 전제 — Codex/Gemini 미사용)"
  - "HANDOFF-next-session.md §0 10~11번 (이 checklist 작성 근거 사용자 지시)"
  - "WORK-LOG.md WU-12 (본 문서 신설 WU)"
---

# Solon Phase 1 — MVP Kickoff Checklist (7-step lightweight spike)

> **목적**: 2026-04-27 주부터 새 회사 관리자 페이지 프로젝트에 Solon 을 **최소 형태로** 적용해서 "실제 사용 가능한 상태" 까지 도달. 풀스펙 Phase 1 (16~20주) 의 선행 스파이크.
> **비목적**: 모든 Evaluator/Skill/Observability 를 완성하는 것. 이 checklist 는 `/sfs install` 이전의 수동 "손으로 굴리는" 단계.

---

## §0 배경 — 왜 이 문서가 필요한가

사용자 (채명정) 는 2026-04-27 주부터 새 회사 (= 이직한 회사) 의 관리자 페이지 MVP 를 자기가 직접 (또는 주도적으로) 구축한다. 이 프로젝트에 Solon 방법론 전체를 한 번에 도입하는 건 과투자 — 16~20주 풀스펙을 먼저 짓고 프로젝트에 들어가는 건 일정상 불가능하다.

따라서:

1. 풀스펙은 **사용자 개인 workspace 의 분리 clone** 으로 참조한다 (= 현재 이 문서가 들어 있는 `2026-04-19-sfs-v0.4/` docset). **admin panel repo 는 Solon 의 존재 자체를 모른다** — submodule 도, `.gitmodules` 도, 경로 참조도 없음. 이유는 §1.1.
2. 실제 프로젝트 repo 는 **별도 신규 repo** 로 만들고, 거기서 7-step flow (브레인스토밍 → plan → sprint → 구현 → review → commit → 문서화) 를 **수동으로** 돌린다.
3. 이 7-step 이 Solon 의 PDCA (P-1/P/D/C/A) + Gate (G0/G1/G2/G4) 에 자연스럽게 매핑되는지 한 번 검증한다 (§4 매핑표).
4. 1 cycle (= 1 Sprint) 완주 후 retro 없이 그대로 2 cycle 진입. retro (G5) 는 2~3 cycle 누적되면 도입.

이 checklist 는 그 "수동 7-step" 을 행동 가능한 체크 박스 형태로 펼친 것이다.

> **IP 배포 모델 (중요)**: Solon docset 은 **사용자 (채명정) 개인 자산**. end-state 는 **`claude plugin install solon`** 플러그인 배포 (07-plugin-distribution.md 및 풀스펙 §10.4 W13 기준). 현재는 그 플러그인 자체가 Phase 1 구현 전이라 아직 없음. 따라서 MVP 단계에서는 **사용자 개인 workspace 의 로컬 clone 참조만** 사용 — admin panel repo 쪽에는 어떤 형태로든 Solon 을 끼워넣지 않음 (submodule 로 끼우면 `.gitmodules` 에 개인 repo URL 이 회사 repo 메타데이터로 진입 → IP 경계 오염). 플러그인 형태가 완성되면 `~/.claude/plugins/solon` 에만 설치되므로 회사 repo 쪽은 여전히 Solon 무관.

---

## §1 사전결정 (Prerequisites) — W0 시작 전에 반드시 확정

### §1.1 Repo ownership / IP 경계 결정 🚨

**핵심 원칙**: admin panel repo = 회사 IP. Solon docset = 사용자 개인 IP. **같은 repo 에 절대 섞이지 않는다**. submodule/경로 참조/하드코딩된 경로 등 어떤 형태로도 admin panel repo 에서 Solon 을 참조하지 않음.

**반드시 결정해야 하는 사항**:

- [ ] 새 관리자 페이지 repo 의 **소유 계정**
  - 옵션 A: 새 회사 org 계정 — 회사 IP 규정상 가장 명확, 입사 후 권한 세팅 완료되면 여기로.
  - 옵션 B: 사용자 개인 계정에 먼저 만들고, 회사 입사 후 transfer — MVP 단계에선 권한 세팅 부담 없음. transfer 시 history 는 유지되나 commit author 혼선 가능 → 입사 전 commit 은 개인 이메일, 입사 후는 회사 이메일로 분리하면 정리됨.
  - 옵션 C: 개인 계정 유지 + 회사와 라이선싱/기여 관계로 사용 — 현실적으로 관리자 페이지 같은 기간계는 이 옵션 부적합.
- [ ] **결정 기록 위치**: 결정 확정 후 HANDOFF-next-session.md §0 에 12번 지시로 추가 기록.
- [ ] **Solon 참조 방식 확정** (세 방법 중 택1, 모두 admin panel repo 에 Solon 흔적을 남기지 않음):
  - **방법 1 (권장, 현재)**: Solon docset 을 사용자 홈 디렉토리 아래 (예: `~/workspace/solon-docset/`) 에 별도 clone 해서 보관. admin panel 작업 시 Claude 에게 "참고로 내 Solon docset 이 `~/workspace/solon-docset/` 에 있다" 를 **대화에서만** 알려주고, CLAUDE.md 에는 이 경로를 적지 않음 (개인 머신 의존).
  - **방법 2 (임시, Claude Code 플러그인 skeleton)**: 사용자 개인 `~/.claude/plugins/solon-wip/` 에 수기로 껍데기 플러그인 디렉토리 만들어 docset 을 그 안에 복사. Claude Code 가 이 경로를 skill/agent 로 자동 인식하도록 `plugin.json` 최소 형태 작성. 풀스펙 W13 전 임시 준플러그인.
  - **방법 3 (end-state, Phase 1 완료 후)**: `claude plugin install solon` — 이건 Solon docset repo 쪽에서 Phase 1 이 끝나고 `solon-plugin/` 산출물이 완성돼야 가능. MVP cycle 1 에서는 불가.

> **기본값 권고**: repo ownership = 옵션 B (개인 계정 생성 → 입사 후 transfer). Solon 참조 = 방법 1 (홈 디렉토리 clone). 이유: 권한 세팅 오버헤드 zero + IP 경계 가장 깔끔. 방법 2 는 사용자가 "Claude Code 가 자동으로 Solon skill 을 꺼내썼으면 좋겠다" 고 느낄 때 W1 도중 전환 가능.

### §1.2 Stack 확정

- [ ] **프레임워크**: (예: Next.js 15 App Router + TypeScript) — 회사 선호 스택 확인 후 기록
- [ ] **DB**: (예: PostgreSQL + Prisma / Supabase / 회사 기존 DB)
- [ ] **배포 타겟**: (예: Vercel / 회사 사내 K8s / AWS EC2)
- [ ] **권한 모델**: (예: RBAC 3단계 admin/manager/viewer — 실제 role 목록은 G0 브레인스토밍에서 확정)
- [ ] **현금영수증 발행**: 외부 API (국세청 홈택스 e-세로 / 나이스정보통신 등) 연동 여부

> **기록 위치**: 새 repo root 의 `README.md` 에 "Stack" 섹션으로.

### §1.3 Timeboxing

- [ ] W0 (2026-04-27 월 ~ 04-28 화): 환경 준비 (§2)
- [ ] W1 (2026-04-29 수 ~ 05-05 화): 첫 PDCA 1 cycle (§3)
- [ ] W1 종료 시점에 §6 MVP 성공/실패 판정. 실패여도 cycle 2 로 넘어가되 원인 기록.

---

## §2 Week 0 체크리스트 — 환경 준비 (1~2 일)

### §2.1 새 repo 생성

- [ ] GitHub 에 새 repo 생성: `<PROJECT-NAME>` (admin panel)
  - visibility: `private` (회사 IP 보호)
  - description: "관리자 페이지 MVP (매출/현금영수증/권한 관리/대시보드) — Solon 방법론 적용"
- [ ] 로컬 clone: `git clone <repo-url> && cd <PROJECT-NAME>`
- [ ] 초기 commit: 빈 README.md + `.gitignore` (Node + IDE 기본)

### §2.2 Solon docset 참조 경로 세팅 (admin panel repo 밖)

**중요**: 이 단계의 모든 작업은 admin panel repo **밖** 에서 일어난다. admin panel repo 의 파일/커밋에는 Solon 흔적이 남지 않는다.

- [ ] §1.1 에서 결정한 "Solon 참조 방식" 에 따라 분기:
  - **방법 1 선택 시 (권장)**:
    - [ ] 사용자 홈에 Solon docset clone 확인: `ls ~/workspace/solon-docset/2026-04-19-sfs-v0.4/README.md` (없으면 docset repo 에서 clone)
    - [ ] 경로만 사용자가 머리로 또는 개인 메모에 기억 — admin panel 에는 적지 않음
  - **방법 2 선택 시 (임시 플러그인 skeleton)**:
    - [ ] `mkdir -p ~/.claude/plugins/solon-wip/`
    - [ ] Solon docset 을 그 하위로 복사 또는 symlink: `ln -s ~/workspace/solon-docset ~/.claude/plugins/solon-wip/docs`
    - [ ] 최소 `plugin.json` 1개 작성 (name: solon-wip, version: 0.1-wip, description: "Solon docset 임시 참조")
    - [ ] Claude Code 재시작 후 플러그인 인식 확인
    - [ ] ⚠ 이 플러그인은 **사용자 개인 머신에만** 존재. 회사 머신에 배포하지 않음 (IP 경계).
  - **방법 3 선택 시 (end-state, 실질적으로 MVP 에서 미도달)**:
    - [ ] 풀스펙 Phase 1 W13 완료 전까지 불가. 이 checklist 스코프 밖.
- [ ] admin panel repo 에 Solon 관련 파일/경로가 **없음** 을 확인:
  - [ ] `git ls-files | grep -i solon` → 결과 비어있어야 함
  - [ ] `.gitmodules` 파일 자체가 없거나 Solon 관련 submodule 항목 없음

### §2.3 `.sfs-local/` 초기화 (프로젝트 로컬 운영 데이터)

- [ ] `mkdir -p .sfs-local/{events,sprints,decisions}`
- [ ] `.sfs-local/events.jsonl` (빈 파일) — L1 수동 이벤트 로그
- [ ] `.sfs-local/divisions.yaml` 작성 (초안, MVP minimal):

```yaml
# .sfs-local/divisions.yaml
version: 1.0-mvp-minimal
project: "<PROJECT-NAME>"
runtime: claude-code  # Codex/Gemini 미사용 (RUNTIME-ABSTRACTION.md Phase 1 scope)
divisions:
  dev:
    activation_state: active
    lead: "사용자 직접 (self-lead, no Opus lead agent yet)"
  strategy-pm:
    activation_state: active
    lead: "사용자 직접"
  qa:
    activation_state: abstract
    reason: "MVP 1 cycle 에서는 manual smoke test 로 대체"
  design:
    activation_state: abstract
    reason: "shadcn/ui 등 기존 디자인 시스템 차용, 자체 design 본부 불필요"
  infra:
    activation_state: abstract
    reason: "Vercel or 회사 기존 인프라 재사용 가정"
  taxonomy:
    activation_state: abstract
    reason: "관리자 페이지 도메인 taxonomy 는 cycle 2~3 누적 후 도입"
```

- [ ] `.gitignore` 에 `.sfs-local/events.jsonl` 추가할지 결정 (개인정보/비즈니스 로그 혼입 리스크 → 초기엔 ignore 권장)

### §2.4 Claude Code 세팅 확인

- [ ] `claude --version` (Claude Code CLI 설치 확인)
- [ ] 새 repo 에서 `claude` 첫 실행 — project scope memory 생성 확인
- [ ] bkit plugin 설치 여부 확인 (선택사항, 필수 아님) — 이 MVP 는 bkit 없이도 돌아가야 함
- [ ] `CLAUDE.md` 초안 작성 (새 repo root, **Solon 경로/repo URL 미언급** — IP 경계):
  - "이 프로젝트는 7-step flow 로 운영됩니다: 브레인스토밍 → plan → sprint → 구현 → review → commit → 문서화"
  - "각 cycle 의 산출물은 `.sfs-local/sprints/<sprint-id>/` 에 저장됩니다 (brainstorm.md / plan.md / review.md / retro-light.md)"
  - "Gate 는 G0 (브레인스토밍) / G1 (plan) / G2 (구현 entry) / G4 (review) 4 개만 운용. 각 Gate 는 hard-block 이 아니라 self-check signal."
  - "한국어 반말, 짧고 직설. 기록 > 기억."
  - (Solon 참조가 필요하면 대화에서 사용자가 별도로 "내 개인 메모에 있는 Solon docset 의 05-gate-framework 참고해서..." 처럼 지칭)

### §2.5 W0 exit 검증

- [ ] admin panel repo `git log --oneline` 에 최소 3 commit (init / CLAUDE.md / divisions.yaml)
- [ ] `git ls-files | grep -i solon` → **빈 결과** (Solon 파일이 repo 에 섞이지 않았음 확인)
- [ ] `.gitmodules` 없음 또는 Solon 관련 항목 없음
- [ ] 사용자 개인 workspace 에서 Solon docset 읽기 가능 확인 (§2.2 방법 1/2 중 선택한 것으로)
- [ ] `CLAUDE.md` 존재 + 7-step flow 명시 + Solon 경로 미언급
- [ ] 모든 체크박스 완료 시 W1 진입

---

## §3 Week 1 체크리스트 — 첫 PDCA 1 cycle (5~7 일)

### §3.1 Day 1~2: 브레인스토밍 (= P-1 + G0)

- [ ] 세션 시작 시 Claude 에게 "브레인스토밍 모드" 선언
- [ ] 브레인스토밍 산출물 (텍스트 or markdown):
  - 관리자 페이지가 해결하는 문제 1문장
  - 1차 기능 목록 (매출 / 현금영수증 / 권한 / 대시보드) 각 항목의 "이 cycle 에 넣을 것 / 미룰 것" 구분
  - 모호한 영역 3~5개 질문 정리
- [ ] **G0 (브레인스토밍 entry gate)**: 산출물이 아래 조건 충족하면 pass
  - [ ] 문제 1문장이 구체적 (예: "회사의 월별 매출 조회가 엑셀 수작업이라 1 시간 걸린다" → OK / "관리 도구가 필요하다" → fail)
  - [ ] 1차 기능 목록이 4개 기능에 대해 in-scope / out-of-scope 구분 완료
  - [ ] 모호 영역 질문이 다음 단계 (plan) 전에 답이 나와야 할 것만 남음 (나중 cycle 로 미룰 수 있는 건 미룸)
- [ ] 산출물 저장: `.sfs-local/sprints/2026-W18-sprint-1/brainstorm.md`
- [ ] `.sfs-local/events.jsonl` 에 한 줄 append:
  ```json
  {"ts":"2026-04-29T...","gate":"G0","verdict":"pass","sprint":"2026-W18-sprint-1"}
  ```

### §3.2 Day 2~3: Plan (= P + G1)

- [ ] Plan 산출물 (`.sfs-local/sprints/2026-W18-sprint-1/plan.md`):
  - [ ] 이 Sprint 의 **단 하나** 의 주 목표 문장 (예: "매출 조회 대시보드 최소 버전 — 월/일/채널별 매출 합계 테이블 + 차트 1개")
  - [ ] 구현 항목 리스트 (user story 형태, 5개 이하)
  - [ ] 각 항목 acceptance criteria 1~2줄
  - [ ] 명시적 out-of-scope (이번 cycle 에서 건드리지 않을 것)
  - [ ] 리스크 / 의존성 (외부 API, DB 스키마 미정 등)
- [ ] **G1 (plan approval)**: 자가 체크
  - [ ] 항목 5개 이하? (초과 시 가차없이 잘라냄)
  - [ ] acceptance criteria 가 "동작한다" 보다 구체적? ("매출 테이블이 월별 합계를 보여주고, 페이지 로드 3초 이내" 정도)
  - [ ] out-of-scope 에 "권한 관리" 와 "현금영수증" 은 이번 cycle 이면 제외 권장 (첫 cycle 은 대시보드만)
- [ ] `.sfs-local/events.jsonl` 에 G1 pass 이벤트 append

### §3.3 Day 3: Sprint 정의

- [ ] Sprint 정의 (plan.md 내부에 섹션으로):
  - 기간: 2026-04-29 ~ 2026-05-05 (W1)
  - 시작 commit: `<sha>`
  - 종료 commit: (cycle 완료 시 채움)
  - 담당 본부: dev (직접) + strategy-pm (직접, 사용자 본인)

### §3.4 Day 3~5: 구현 (= D + G2)

- [ ] **G2 (구현 entry)**: 구현 시작 전 자가 체크
  - [ ] plan 의 항목 중 지금 들어가는 것 1개를 명확히 선언
  - [ ] 해당 항목의 파일 경로 / 컴포넌트 이름 / API endpoint 를 구현 전에 한 줄로 적음
  - [ ] 이 항목이 끝난 뒤 어떻게 "동작" 을 확인할지 한 줄로 적음
- [ ] 구현 진행 — Claude Code 와 페어 프로그래밍
- [ ] 매 항목 완료 시 local commit (작게 자주)
- [ ] 어려운 결정 발생 시 `.sfs-local/decisions/<N>-<short-title>.md` 로 1~3줄 기록 (ADR mini)

### §3.5 Day 5~6: Review (= C + G4)

- [ ] Review 산출물 (`.sfs-local/sprints/2026-W18-sprint-1/review.md`):
  - [ ] plan.md 항목별 완료/미완료/변경 체크
  - [ ] acceptance criteria 실제 충족 여부 (스크린샷 경로 or 재현 커맨드)
  - [ ] 발견된 버그/이슈 리스트
  - [ ] plan 에 없었는데 추가된 것 (scope creep) 기록
- [ ] **G4 (review)**: 자가 체크
  - [ ] plan 의 주 목표 문장이 충족되었는가? (yes/partial/no)
  - [ ] acceptance criteria 중 pass 한 비율 (예: 4/5 통과)
  - [ ] 다음 cycle 에 가장 먼저 할 일 1개
- [ ] `.sfs-local/events.jsonl` 에 G4 verdict 이벤트 append

### §3.6 Day 6: Commit (= L2 git 확정)

- [ ] 모든 local commit 을 정리 (원한다면 작은 fixup 만 squash — rebase -i 는 사용자 터미널에서)
- [ ] 최종 push 는 사용자 터미널에서 `git push origin main` (Claude 는 push 하지 않음 — 보안 규칙)
- [ ] push 완료 후 `.sfs-local/sprints/.../review.md` 에 end commit sha 기록

### §3.7 Day 6~7: 문서화 (= A + learning capture)

- [ ] `.sfs-local/sprints/2026-W18-sprint-1/retro-light.md` 작성 (5분 분량):
  - 잘 된 것 2줄
  - 안 된 것 2줄
  - 다음 cycle 반영할 것 1줄
- [ ] 프로젝트 `README.md` 업데이트: 구현된 기능 리스트 1줄씩 추가
- [ ] (선택) `CHANGELOG.md` 생성 또는 업데이트
- [ ] Solon 방법론 쪽 피드백이 발생하면 → Solon docset repo (= 이 repo 밖) 로 별도 issue/WU 로 올림 (admin panel repo 에는 어떤 Solon 관련 파일도 커밋 금지)

### §3.8 W1 exit 검증

- [ ] `.sfs-local/sprints/2026-W18-sprint-1/` 에 brainstorm.md + plan.md + review.md + retro-light.md 4개 파일 존재
- [ ] `.sfs-local/events.jsonl` 에 G0/G1/G2/G4 각 1개 이상 이벤트
- [ ] `git log` 에서 cycle 시작 ~ 종료 commit 범위 확인 가능
- [ ] §6 성공/실패 판정 수행

---

## §4 7-step flow → Solon PDCA/Gate 매핑표

| # | 7-step | Solon PDCA | Solon Gate | 산출물 (이 MVP) |
|---|--------|-----------|-----------|----------------|
| 1 | 브레인스토밍 | P-1 (pre-plan discovery) | G0 (brainstorm entry) | `brainstorm.md` |
| 2 | plan | P (plan) | G1 (plan approval) | `plan.md` |
| 3 | sprint | — (P 의 metadata) | — | plan.md 내 sprint 섹션 |
| 4 | 구현 | D (do) | G2 (구현 entry) | 실제 코드 + local commits |
| 5 | review | C (check) | G4 (review) | `review.md` |
| 6 | commit | — (L2 channel 물리 확정) | — | `git push origin main` |
| 7 | 문서화 | A (act / learn) | — | `retro-light.md` + README 업데이트 |

**주의**:
- G-1 (brownfield intake) 는 이 프로젝트 = greenfield 이므로 없음.
- G3 (design gate) 는 design 본부 abstract 이므로 skip.
- G5 (retro gate) 는 cycle 2~3 누적되면 도입 — MVP 1 cycle 에는 대신 `retro-light.md` 로 경량 대체.
- 풀스펙 PDCA (§10-phase1 §10.4) 에서는 G3/G5 도 필수이지만, 이 MVP 는 **명시적 축소판**.

---

## §5 Gate 축소 근거 (G0/G1/G2/G4 only)

**풀스펙 Gate 집합** (00-intro.md, 05-gate-framework.md 기준):
G-1 (brownfield intake) + G1 (plan) + G2 (design→dev) + G3 (dev→qa) + G4 (qa→review) + G5 (retro)

**MVP 축소판이 쓰는 Gate** (4개):
G0 (brainstorm) + G1 + G2 + G4

**축소 근거**:

| Gate | 축소 판단 | 이유 |
|------|----------|------|
| G-1 | skip | 이 프로젝트는 greenfield (legacy repo 위에 얹는 게 아님). intake 자체가 불필요. |
| G0 | **추가** (풀스펙 미정의) | 풀스펙은 brainstorm 을 P-1 안의 비정형 단계로 보지만, 사용자 7-step flow 의 첫 단계가 브레인스토밍이므로 entry gate 필요. 풀스펙 재통합 시 P-1 entry gate 로 흡수 가능. |
| G1 | 유지 | plan approval 은 MVP 여도 필수. plan 없이 바로 구현하면 cycle 경계가 소실됨. |
| G2 | 유지 (경량) | 구현 entry 자가 체크만 수행. design 본부가 abstract 이므로 "design→dev" 가 아니라 "plan→dev" 의 entry 로 해석. |
| G3 | skip | qa 본부 abstract. dev→qa 경계 자체가 없으므로 불필요. 대신 구현 중 self-smoke test 로 대체. |
| G4 | 유지 | review 는 필수 — 없으면 "돌아감" 을 주장할 수가 없음. |
| G5 | skip | retrospective 는 cycle 1개로 판단 재료 부족. cycle 3 누적 후 도입. |

**언제 풀스펙 Gate 로 복귀하는가**:
- qa 본부 activate (abstract → active) 필요성 느끼면 → G3 도입
- cycle 3 누적 시점 → G5 도입 + retro 정식화
- brownfield repo 에 Solon 적용 시 → G-1 도입

---

## §6 MVP 1 cycle 성공 / 실패 판정 기준

**1 cycle = W1 종료 시점에 아래 5개 조건으로 판정**.

### §6.1 성공 조건 (5개 중 4개 이상 충족 → 성공)

| # | 조건 | 검증 |
|:-:|------|-----|
| 1 | W1 주 목표 문장의 acceptance criteria 가 최소 70% 통과 | review.md 체크박스 |
| 2 | 7-step 모두 실제로 거쳤다 (skip 없음) | `.sfs-local/sprints/.../` 4 파일 존재 + events.jsonl G0/G1/G2/G4 4 이벤트 |
| 3 | G1~G4 중 1개 이상 verdict 가 "fail" 또는 "partial" 인데도 cycle 진행을 막지 않았음 | 즉 Gate 가 hard-block 이 아니라 signal 로 작동했음 (원칙 13 ALT-INV-3) |
| 4 | Solon docset 을 1회 이상 참조했다 (사용자 개인 workspace 의 HANDOFF / 05-gate-framework / 10-phase1 어느 것이든) | 구체적 참조 기록 1줄 이상 retro-light.md 에 존재. 단 admin panel repo 에는 Solon 경로 하드코딩 없음 확인. |
| 5 | 이 방법론 계속 쓸 가치가 있다고 W1 종료 시점에 판단됨 | retro-light.md "다음 cycle 계속?" 질문에 yes |

### §6.2 실패 신호 (아래 중 1개라도 해당하면 재검토)

- [ ] 7-step 중 3 step 이상 skip 됨 → MVP 가 너무 가볍거나 플로우가 맞지 않음
- [ ] Gate 가 심리적 부담만 주고 실제 의사결정에 도움이 안 됐음 → §5 축소를 더 해야 함
- [ ] `.sfs-local/` 이 비즈니스 로직 구현을 실제로 방해했음 → 경로/스키마 단순화
- [ ] Solon docset 을 한 번도 안 봤음 → docset 자체가 MVP 에 맞춰져 있지 않다는 신호

### §6.3 판정 결과 반영

- **성공**: cycle 2 진입. §3 동일 구조 반복. cycle 3 누적 시 G5/G3 도입 검토.
- **실패 (1 신호)**: 원인 기록 후 cycle 2 는 그래도 진행 (완전 중단 금지). §3 중 문제된 단계만 조정.
- **실패 (2+ 신호)**: cycle 2 시작 전 Solon docset 쪽 HANDOFF 에 "MVP kickoff 실패 신호" WU 로 기록. 필요시 이 checklist v0.2 로 개정.

---

## §7 알려진 리스크 + 다음 단계

### §7.1 알려진 리스크

| 리스크 | 완화 |
|-------|------|
| 회사 입사 초기에 방법론까지 챙기면 에너지 분산 | 체크리스트 항목이 "1~3줄 쓰기" 수준이라 총 오버헤드 <30분/cycle. 초과하면 축소. |
| IP 경계 혼재 (개인 IP Solon + 회사 IP admin panel) | §1.1 원칙: admin panel repo 에 Solon 참조 제로. 양 repo 를 물리적으로 격리. `git ls-files \| grep -i solon` 으로 주기적 자가 검증. |
| Solon 을 참조는 하고 싶은데 경로가 개인 머신에만 있어 회사 머신에서 불편 | 방법 2 (개인 `~/.claude/plugins/solon-wip/`) 로 전환 검토. 회사 머신에는 설치 안 함. 또는 풀스펙 W13 플러그인 배포를 우선순위 올림. |
| Claude 가 brownfield 스펙 (G-1, `/sfs install --mode brownfield`) 을 자꾸 제안 | 이 프로젝트는 greenfield 라고 CLAUDE.md 에 명시. Claude 가 잘못 제안하면 즉시 교정. |
| cycle 1 의 성공 조건이 너무 관대/엄격 | cycle 2 시작 시점에 §6.1 조건 5개를 재검토. 조건은 경험에 따라 자라나는 대상. |
| Solon docset 의 A4 57페이지 분량이 사용자를 압도 | W0 에 전부 읽을 필요 없음 — HANDOFF/INDEX/README 3개만. 나머지는 실제 Gate 에서 막힐 때 해당 섹션만 펼쳐 읽음. |

### §7.2 다음 단계 (cycle 1 이후)

1. **cycle 2 시작 전** (2026-05-06 주): §6.1 판정 결과를 Solon docset 쪽 HANDOFF §0 에 추가 기록 (사용자 12번째 지시로).
2. **cycle 3 누적 후**: G5 도입 + 풀 retro 정식화. `.sfs-local/learnings-v1.md` 생성 시작.
3. **qa 필요성 느끼면**: qa 본부 abstract → active 승격 + G3 도입 (원칙 13 dogfooding 의 첫 실증 케이스가 됨 — Phase 1 풀스펙 §10.5.1 조건 6 에 대응).
4. **Solon docset 자체 개선**: 이 MVP 수행 중 docset 의 모호함/오류가 발견되면 **docset repo 쪽으로** issue/WU (WU-13, 14, ...) 로 올림. 관리자 페이지 repo 에는 올리지 않음 (IP 경계).
5. **플러그인 배포 우선순위 상향 검토**: MVP cycle 1~2 운용 중 "Solon 을 사용자 머신마다 매번 수동으로 두는 게 비효율" 라고 느끼면, 풀스펙 §10.4 W13 (Plugin Packaging) 을 16~20주 후반부가 아니라 **선행 우선순위** 로 끌어올리는 것을 고려 — Solon docset repo 쪽에서 별도 WU 로 착수. 목표 end-state: `claude plugin install solon` 한 줄로 개인 머신에 설치 (admin panel repo 와는 무관).
6. **풀스펙 복귀 시점**: cycle 5~7 누적되고 팀이 생기면 `/sfs install` CLI + 플러그인 형태로 전환. 그 전까지는 수동 7-step + (선택) 방법 2 임시 플러그인.

---

## §8 이 문서 사용법 (요약)

1. W0 시작 시점에 §1 prerequisites 5개 결정 → HANDOFF §0 에 12번 지시로 기록
2. §2 W0 체크박스 전부 완료 → W1 진입
3. §3 W1 체크박스를 매일 확인 — Day 1~7 순서대로
4. W1 종료일 (2026-05-05) 에 §6 판정 수행
5. 판정 결과에 따라 cycle 2 조정 or Solon docset 개선 WU 발행

**이 체크리스트는 cycle 1 전용**. cycle 2 부터는 §3 만 반복하면 되고, cycle 3 누적 시점에 v0.2 로 개정 (G5 추가 등).

---

## Changelog

- **v0.1-mvp** (2026-04-20): WU-12 로 신설. 사용자 지시 "A ㄱㄱ + MVP + 다음주부터 사용 + 7-step flow + B 새 프로젝트 + 관리자 페이지 도메인" 에 대응. axis 1 = ① lightweight spike / axis 2 = B. G0+G1+G2+G4 4 gate 축소판.
- **v0.1-mvp-patch1** (2026-04-20, 동일 WU-12 커밋 범위 내): 사용자 추가 지시 "Solon docset 은 내 개인자산이니까 사실 플러그인 형태로 배포가 돼야하는게 맞음" 반영. §1.1/§2.2/§2.4/§2.5/§6.1/§7.1/§7.2 전반에서 **submodule 전제 제거 → Solon 참조는 admin panel repo 밖 (홈 디렉토리 or 개인 `~/.claude/plugins/solon-wip/`) 으로 분리**. end-state = `claude plugin install solon` (풀스펙 W13) 명시. admin panel repo 는 Solon 존재를 모른다 (IP 경계 엄격화).
- **v0.1-mvp-patch2** (2026-04-20 심야, WU-12.2): patch1 grep 에서 누락된 `submodule` 단어 레지듀 2곳 cleanup. §3.7 ("submodule 쪽에 직접 commit 금지" → "admin panel repo 에는 어떤 Solon 관련 파일도 커밋 금지") + §6.2 ("Solon docset submodule" → "Solon docset"). 문서 의미 변경 없음 — patch1 정신에 대한 일관성 보정만. 발견 경위: 다음 세션 재개 시 전체 재독 중 검출.
