# Solo Founder Agent System — 설계 제안서 v0.3

> **문서 성격**: 브레인스토밍 결과 정리. 구현 전 설계 초안(Design Draft).
> **독자**: 본인(집에서 이어받을 미래의 나) + 향후 합류할 협업자
> **작성일**: 2026-04-19
> **상태**: Draft — 아직 결정되지 않은 항목은 `[OPEN]` 표시

---

## 0. 한 줄 요약 (Elevator Pitch)

**1인 창업자가 스타트업 규모의 팀(기획 · 디자인 · 프론트 · 백엔드 · 인프라 · 보안 · 법무 · 문서)을 에이전트로 대체해 아이디어에서 시장 출시까지 끌고 갈 수 있게 해주는 에이전틱 시스템(Agentic System).**

---

## 1. 문제 정의 (Problem)

- **배경**: 본인은 백엔드(Backend) 전문성이 있으나, 기획(PM) · 디자인(Design) · 프론트엔드(Frontend) · 인프라(Infra/DevOps) · 보안(Security) · 법무(Legal) · 문서화(Documentation)는 상대적으로 약함.
- **1인 창업**이라는 제약 하에서 이 모든 역할을 혼자 감당해야 함.
- 단순 "AI 어시스턴트" 수준으로는 **단계 간 일관성**, **의사결정의 트레이드오프 판단**, **산출물의 품질**을 담보할 수 없음.
- 본인만 쓰는 도구가 아니라, **다른 1인 창업자도 쓸 수 있는 제품(Product)**으로 만들고 싶음.

---

## 2. 핵심 설계 원칙 (Design Principles)

1. **단계가 아니라 역할(Role)을 에이전트로 만든다** — 같은 에이전트가 여러 단계에 등장
2. **모든 에이전트는 Sonnet(실행자) + Opus Advisor(판단자) 쌍으로 구성** — 비용은 Sonnet 수준, 판단은 Opus 수준
3. **Advisor는 페르소나(Persona)를 가진다** — 팀장급의 경험/관점을 프롬프트로 주입
4. **공통 언어(Taxonomy)는 시스템의 뿌리** — 용어가 흔들리면 전체가 무너짐
5. **Orchestrator가 사라진 본인의 자리를 메운다** — "지금 뭘 할 차례인가"에 답하는 유일한 주체
6. **MVP는 단방향 파이프라인, 역류는 실제 사용 후 추가**
7. **본인 승인 게이트(Gate)는 반드시 몇 군데 남겨둔다** — 특히 배포 직전, 법무 이슈, 주요 방향 결정

---

## 3. 시스템 아키텍처 (Architecture)

### 3.1 레이어 구조

```
┌─────────────────────────────────────────────────┐
│  Layer 4: 에이전트들 (Agents)                    │
│  PM · Designer · Frontend · Backend · DevOps ·  │
│  Security · Legal · Tech Writer · Ideator       │
├─────────────────────────────────────────────────┤
│  Layer 3: Advisor Persona Pool                  │
│  Opus 기반, 교체/추가 가능한 페르소나 라이브러리   │
├─────────────────────────────────────────────────┤
│  Layer 2: Orchestrator (본인 자리)              │
│  상태 추적 · 다음 단계 결정 · 게이트 · 예산 관리    │
├─────────────────────────────────────────────────┤
│  Layer 1: Taxonomy (공통 언어)                  │
│  domain · technical · ui 사전 + 결정 기록        │
└─────────────────────────────────────────────────┘
```

**의존성 방향**: 위 레이어가 아래 레이어를 참조. 아래 레이어는 위를 모름.

### 3.2 구현 순서 (Build Order)

```
[1] Taxonomy 관리 체계      ← 뿌리
     ↓
[2] Orchestrator (CLI)      ← 줄기
     ↓
[3] Backend Agent + Advisor ← 레퍼런스 구현 (본인이 품질 판정 가능한 영역)
     ↓
[4] 나머지 에이전트          ← [3]의 패턴 복제
     ↓
[5] Persona Pool 교체/추가 기능
     ↓
[6] SaaS화 (CLI 안정화 이후)
```

---

## 4. 파이프라인 (Pipeline)

### 4.1 단계 흐름 (단방향 MVP)

```
[0] 아이디어 캡처 (Idea Capture)
      ↓
[1] 브레인스토밍 · 시장 가설   (Ideator + Critic-A/B)
      ↓ ◆ 본인 승인 게이트
[2] 플랜 · 로드맵 · 성공지표    (PM)
      ↓
[3] 기획서 · 택소노미 · 유저스토리 (PM + Critic)
      ↓ ◆ Legal 1차 플래그
[4] 와이어프레임 · 디자인 시스템 (Designer)
      ↓ ◆ 본인 승인 게이트
[5] 기술 설계 · API 스펙       (Backend)
      ↓
[6] MVP 구현                  (Frontend + Backend, 로컬테스트)
      ↓ ◆ Critic-A/B 코드리뷰 게이트
[7] 인프라 · 개발서버          (DevOps)
      ↓ ◆ Security 게이트 (필수)
      ↓ ◆ Legal 최종 검토
[8] 상용 배포 · 모니터링       (DevOps, 본인 수동 승인)
      ↓
[9] 문서화 (3트랙 병렬)        (Tech Writer)
      ↓
[10] 운영 · 피드백 수집        → [0]으로 순환
```

◆ = Gate. 게이트에서 STOP 발생 시 수동으로 이전 단계 재실행 지시.

### 4.2 3트랙 문서화 (Documentation Tracks)

단계 [9]에서 **같은 기능에 대해 3개 문서를 병렬 생성**:

- **도메인 문서 (Domain Doc)**: What & Why — 비개발자/비즈니스 관점
- **기술 문서 (Technical Doc)**: How — 개발자 관점 (API, 스키마, 아키텍처)
- **운영 문서 (Runbook)**: 장애 대응 · 롤백 · 모니터링 — 미래의 본인(온콜)용

저장 위치: 초기엔 Notion(도메인) + Git(기술 · 운영). 팀 문서와 도메인 문서 분리.

---

## 5. Layer 1 — Taxonomy 관리 체계

### 5.1 파일 구조

```
.agent/taxonomy/
├── domain.yaml       # 도메인 개념 (User, Order, Payment 등)
├── technical.yaml    # 기술 용어 (Entity, API Resource, Event)
├── ui.yaml           # 화면 / 컴포넌트 이름
└── decisions.md      # 용어 선택 근거 (ADR 스타일)
```

### 5.2 엔트리 스키마

```yaml
user:
  canonical: "User"                  # 영어 표준 (코드 · API)
  korean: "사용자"                    # 한국어 표준 (UI · 문서)
  aliases_forbidden: ["회원", "유저", "Member", "Customer"]
  definition: "서비스에 가입해 식별 가능한 계정을 가진 자연인"
  attributes: [id, email, created_at]
  related: [account, profile]
  decided_at: "2026-04-19"
  decided_by: "PM Agent + Orchestrator Advisor"
```

### 5.3 라이프사이클

1. **생성**: 단계 [3]에서 PM이 초안 생성
2. **확장**: 각 단계에서 에이전트가 PR 형태로 제안
3. **승인**: Orchestrator Advisor가 충돌 검토 후 승인
4. **동결(Freeze)**: 단계 [6] MVP 구현 시작 시 v1.0 고정
5. **마이그레이션(Migration)**: 동결 후 변경은 `migrations/rename-xxx.md` 생성 + 일괄 치환

### 5.4 에이전트 통합

모든 SKILL.md 상단에 **고정 Preamble**:
```markdown
## 작업 전 필수
1. .agent/taxonomy/*.yaml 전체 로드
2. 출력물에서 forbidden 용어 사용 금지
3. 신규 개념 발견 시 taxonomy/pending/ 에 제안 먼저
```

Critic 게이트에서 `aliases_forbidden` 단어 **grep 자동 검증**.

---

## 6. Layer 2 — Orchestrator

### 6.1 역할
**"지금 뭘 할 차례인가"에 답하는 유일한 주체.** 본인이 사라진 자리.

### 6.2 책임 5가지
1. **상태 추적 (State Tracking)**: 파이프라인 [0]~[10] 중 어느 단계인가
2. **다음 단계 결정**: 완료 조건 충족 시 다음 에이전트 호출
3. **Advisor 충돌 중재**: PM Advisor vs Security Advisor 상충 시 판단
4. **게이트 관리**: 사용자 승인 지점에서 대기 + 컨텍스트 요약 제공
5. **예산 관리 (Budget)**: Advisor 호출 횟수, 토큰 비용 추적

### 6.3 상태 모델

```yaml
# .agent/state.yaml
project:
  id: "proj-abc"
  domain: "SaaS / B2B"
  current_phase: 3
  taxonomy_version: "0.3-draft"

phases:
  - id: 0
    status: done
    artifact: docs/0-idea.md
  - id: 3
    status: in_progress
    started_at: "2026-04-19T14:20:00Z"
    active_agents: [PM, Critic-A, Critic-B]
    blockers: []

pending_gates:
  - type: user_approval
    reason: "기획서 v1 확정 필요"
    context_summary_path: docs/gates/g3-summary.md

advisor_budget:
  daily_opus_calls: 50
  used_today: 12
```

### 6.4 구현 형태
**CLI 자체가 Orchestrator 역할**을 하게 함:
- `agent next` — 다음 단계 진행
- `agent status` — 현재 상태 요약
- `agent gate approve` — 게이트 승인
- `agent advisor invoke <role>` — 수동 advisor 호출
- `agent persona set <role> <persona>` — 페르소나 교체

---

## 7. Layer 3 — Advisor Persona System ★

> 이번 버전에서 새로 추가된 핵심 레이어. 페르소나를 **데이터**로 다루는 것이 요점.

### 7.1 페르소나의 정의
Advisor는 단순한 프롬프트가 아니라 **경험 · 관점 · 판단 스타일을 가진 가상 인격**.

예:
- **Backend Advisor 기본 페르소나**: "20년차 대기업 CTO 출신, 3번 0→1 스타트업 경험, 오버엔지니어링 혐오하지만 지름길로 인한 사후 폭발도 혐오"
- **Design Advisor 기본 페르소나**: "10년차 B2C 프로덕트 디자이너, 토스/당근 레벨의 디테일 감각, 접근성 광신도"

### 7.2 페르소나 파일 구조

```
.agent/personas/
├── defaults/                    # 시스템 기본 제공 (수정 금지)
│   ├── backend-cto-20y.yaml
│   ├── pm-toss-style.yaml
│   ├── design-b2c-senior.yaml
│   ├── devops-sre-veteran.yaml
│   ├── security-owasp-hawk.yaml
│   └── legal-saas-counsel.yaml
├── custom/                      # 사용자 정의 (교체 · 추가)
│   └── backend-fintech-15y.yaml
└── active.yaml                  # 현재 활성 페르소나 매핑
```

### 7.3 페르소나 스키마

```yaml
# personas/defaults/backend-cto-20y.yaml
id: backend-cto-20y
role: backend-advisor
version: "1.0"

identity:
  title: "20년차 대기업 CTO 출신 시니어 백엔드 엔지니어"
  background: |
    네이버 · 카카오급 회사에서 10년, 초기 스타트업 CTO로 3회 경험.
    0→1과 1→100을 모두 해봄. 금융 · 커머스 도메인 깊음.
  
principles:
  - "MVP에 과한 것은 부채(Debt)다"
  - "하지만 데이터 모델은 처음에 틀리면 3개월 뒤 폭발한다"
  - "모든 결정에 근거를 남긴다 (ADR)"

expertise:
  strong: [data-modeling, transaction-boundaries, postgres, redis]
  moderate: [kubernetes, kafka, elasticsearch]
  weak: [mobile, ml-infra]  # 이 영역은 "모른다"고 답할 것

checklist_on_every_review:
  - "MVP 단계에 적절한 복잡도인가"
  - "1년 뒤 후회할 지점인가"
  - "트랜잭션 · 동시성 함정"
  - "N+1, 캐시 무효화, 타임존 3대 함정"
  - "민감정보 암호화 · 해싱"

response_style:
  tone: "직설적, 근거 중심, 공손한 영업멘트 금지"
  length: "필요한 만큼만, verdict는 항상 명시"
  forbidden_phrases:
    - "훌륭합니다"
    - "좋은 질문이네요"
```

### 7.4 페르소나 교체 · 추가 메커니즘

**기본값 설정 (Default Setup)**:
시스템 최초 실행 시 `active.yaml`이 자동 생성:
```yaml
# active.yaml
backend-advisor: defaults/backend-cto-20y
pm-advisor: defaults/pm-toss-style
design-advisor: defaults/design-b2c-senior
# ...
```

**교체 (Replace)**:
```bash
agent persona set backend-advisor custom/backend-fintech-15y
```

**추가 (Add)**:
```bash
agent persona create backend-advisor --from defaults/backend-cto-20y
# → custom/backend-cto-20y-forked.yaml 생성, 에디터 오픈
```

**나열 (List)**:
```bash
agent persona list              # 활성 페르소나 모두
agent persona list --role backend-advisor  # 특정 역할의 후보
```

**검증 (Validate)**:
페르소나 파일은 schema validation 필수 (id, role, identity, checklist 최소 요건).

### 7.5 페르소나 설계 가이드

- **한 문장으로 요약 가능해야 함** (예: "토스 스타일 PM")
- **금지 문구(forbidden_phrases)가 톤을 결정** — "훌륭합니다" 같은 AI스러운 멘트 차단
- **약점(weak)을 명시해야 함** — 모르는 걸 모른다고 해야 신뢰 가능
- **체크리스트는 5~10개 고정** — 너무 많으면 리뷰가 산만해짐
- **버전 관리** — 페르소나 자체도 v1 → v2 진화 (실사용 피드백 반영)

### 7.6 향후 확장 아이디어 `[OPEN]`
- **페르소나 마켓플레이스**: 다른 사용자가 만든 페르소나 공유 (예: "토스 출신 PM 페르소나", "아마존 SDE 페르소나")
- **페르소나 블렌딩**: 두 페르소나 조합 (예: "CTO 페르소나 60% + 보안 전문가 40%")
- **도메인 프리셋**: "핀테크 스타트업 팀 세트", "커머스 스타트업 팀 세트"

---

## 8. Layer 4 — 에이전트 상세

### 8.1 에이전트 구성표

| 에이전트 | Sonnet 실행자 역할 | Opus Advisor 역할 | 기본 페르소나 |
|---|---|---|---|
| Ideator | 아이디어 확장, 경쟁사 리서치 | 시장성 · 실현가능성 판단 | `vc-partner-early-stage` |
| PM | 기획서 · 유저스토리 · 택소노미 | 우선순위 · 범위 관리 | `pm-toss-style` |
| Designer | 와이어프레임 · 디자인 시스템 | UX 원칙 · 접근성 | `design-b2c-senior` |
| Frontend | 컴포넌트 구현 | 상태관리 · 성능 · 에러 경계 | `fe-lead-10y` |
| **Backend** | **스키마 · API · 도메인 모델** | **데이터모델링 · 확장성** | `backend-cto-20y` |
| DevOps | IaC · CI/CD · 모니터링 | 비용 · 가용성 · 롤백 | `devops-sre-veteran` |
| Security | 취약점 스캔 · 리뷰 | OWASP · 실제 위험도 | `security-owasp-hawk` |
| Legal | 약관 · 정책 초안 | 도메인 규제 플래그 | `legal-saas-counsel` |
| Tech Writer | 3트랙 문서 생성 | 독자 적절성 · 일관성 | `tech-writer-dev-focused` |
| **Orchestrator** | **파이프라인 진행** | **"지금 뭘 할 차례인가" 메타판단** | `founder-coach` |

### 8.2 Backend Agent (레퍼런스 구현)

#### 8.2.1 입출력 계약 (I/O Contract)

**입력**:
- 기획서 `docs/3-spec.md`
- 택소노미 `.agent/taxonomy/*.yaml`
- 와이어프레임 `designs/`
- 이전 결정 `decisions/`

**출력**:
- DB 스키마 `backend/schema.sql`
- API 명세 `backend/api.yaml` (OpenAPI 3)
- 도메인 모델 `backend/models/`
- 결정 기록 `decisions/backend-XXX.md`
- Advisor 대화 로그 `backend/advisor-log.md`

#### 8.2.2 Sonnet 실행자 프롬프트 골격

```markdown
# Backend Engineer Agent

## 역할
기획서와 택소노미를 받아 DB 스키마, API 명세, 도메인 모델을 생성.

## 작업 전 필수
- .agent/taxonomy/*.yaml 로드
- docs/3-spec.md 로드
- decisions/ 기존 결정 스캔

## 작업 흐름
1. 엔티티 식별 (택소노미 기반, 추측 금지)
2. 관계 모델링 → [Trigger] 복잡도 높으면 Advisor 호출
3. API 리소스 설계 → [Trigger] REST vs GraphQL 선택 시 Advisor
4. 스키마 작성
5. Advisor 최종 게이트 리뷰
6. 산출물 커밋 + ADR 작성

## Advisor 호출 트리거
- 엔티티 3개 이상의 관계 설계
- 트랜잭션 경계 결정
- 인덱스 전략
- 3rd party 연동 설계
- 이전 결정과 충돌 감지
- 스스로 "추측하고 있다"고 느낄 때

## 금지
- 택소노미에 없는 용어 사용
- 근거 없는 기본값 선택
- 테스트 불가능한 API 설계
```

#### 8.2.3 Opus Advisor 응답 스키마

```json
{
  "verdict": "approve | revise | escalate",
  "critical_issues": [],
  "suggestions": [],
  "rationale": "왜 이 판단을 내렸는지",
  "handoff_to_sonnet": "실행자에게 전달할 구체 지시"
}
```

- **approve**: Sonnet이 산출물 확정
- **revise**: Sonnet이 `handoff_to_sonnet` 따라 재작업 (최대 2회)
- **escalate**: Orchestrator로 전달 (기획서 구멍, 택소노미 변경 필요 등)

#### 8.2.4 ADR 형식 (Architecture Decision Record)

```markdown
# decisions/backend-001-user-account-relation.md

Status: Accepted
Date: 2026-04-19
Agents: Backend Sonnet + Backend Advisor (persona: backend-cto-20y)

## Context
User와 Account 분리 여부.

## Options Considered
1. 통합 (User = Account)
2. 분리 (1 User : N Account)

## Decision
2번 채택.

## Rationale (Advisor 판단)
기획서 3.2절 "한 사용자가 여러 조직 소속" 요건 → 2번 필수.
나중에 마이그레이션 비용 큼.

## Consequences
- auth 플로우에서 account 선택 UI 필요 → Frontend로 전달
- 택소노미에 Account 개념 추가 필요 → PM으로 전달
```

### 8.3 나머지 에이전트 (복제 패턴)

Backend 구조를 템플릿 삼아 체크리스트만 교체:
- **PM**: 기능 우선순위, MVP 범위, 삭제 결정
- **Designer**: 접근성, 일관성, 모바일 대응
- **Frontend**: 상태관리, 성능, 에러 경계
- **DevOps**: 비용, 가용성, 롤백 가능성
- **Security**: OWASP Top 10, 개인정보, 시크릿
- **Legal**: 약관 필수 항목, 개인정보처리방침, 도메인 규제
- **Tech Writer**: 독자 적절성, 3트랙 일관성

---

## 9. Critic A/B 실험 (Critic A/B Test)

### 9.1 구조
- **Critic-A**: Claude (Opus)
- **Critic-B**: Gemini / Codex (외부 모델)
- 단계 [1], [3], [6]에서 **동일 입력을 양쪽에 동시 투입**
- 같은 체크리스트로 리뷰 → 결과 나란히 저장

### 9.2 측정
- 한 달 누적 후: Claude 우위 단계 / Gemini 우위 / Codex 우위 분리
- 가설: 코드는 Codex, 기획은 Claude, 외부 시선은 Gemini 우위일 가능성

### 9.3 로그 위치
`.agent/critic-log/phase-{N}/run-{timestamp}/` 에 input · output-a · output-b · user-verdict 저장.

---

## 10. MVP 우선순위 (Phased Build)

- **Phase 1 (2주)**: Taxonomy + Orchestrator CLI + PM Agent + Backend Agent + Critic-A. 단계 [0]~[5] 흐름.
- **Phase 2 (2주)**: Designer + Frontend. 단계 [4], [6] 보강.
- **Phase 3 (2주)**: DevOps + Security + Legal 게이트. 단계 [7], [8].
- **Phase 4 (2주)**: Tech Writer + Critic-B (외부 모델) + Persona 교체/추가 기능.
- **Phase 5**: 실사용 피드백 기반 역류 메커니즘 추가.
- **Phase 6**: SaaS화.

---

## 11. 열린 질문 (Open Questions)

| # | 질문 | 현재 생각 |
|---|---|---|
| Q1 | 에이전트 간 통신은 파일 vs 메시지 버스? | 파일 시스템 (MVP 단순성) |
| Q2 | 산출물 저장소는 Git 모노레포 vs Git+Notion 하이브리드? | Git 모노레포 → 문서만 Notion 동기화 |
| Q3 | 배포 자동화 수준? | 스테이징 자동 + 프로덕션 수동 승인 |
| Q4 | Pack 경계(도메인별 페르소나 세트) 설계? | 추후 Phase 4에서 결정 |
| Q5 | 페르소나 마켓플레이스 운영 정책? | SaaS 단계에서 고려 |
| Q6 | 역류 메커니즘 자동화 시점? | Phase 5, 실사용 로그 분석 후 |
| Q7 | Advisor 호출 예산 초과 시 동작? | Sonnet 단독 진행 + 경고 로그 |

---

## 12. 리스크 (Risks)

- **R1** — Advisor 호출 비용 폭증: Trigger 조건을 엄격히. Phase 1에서 실제 비용 측정 필수.
- **R2** — 택소노미 동결 후 대규모 변경: Migration 자동화 스크립트 필요.
- **R3** — 페르소나 품질 편차: 기본 페르소나는 실제 시니어에게 리뷰 받는 것이 이상적.
- **R4** — symlink/CLI 환경 의존: Windows 사용자 대응은 Phase 6(SaaS)에서.
- **R5** — 에이전트가 Advisor 우회/무시: Critic 게이트에서 "Advisor 로그 존재" 체크로 강제.
- **R6** — 1인 창업자가 게이트에서 병목: 게이트 수를 최소화, 컨텍스트 요약 자동 생성으로 의사결정 시간 단축.

---

## 13. 다음 작업 (Next Actions)

집에 들어가서 이어받을 순서:

1. **Git 레포 초기화**: `agent-core` 저장소 생성
2. **디렉토리 스캐폴드**: `.agent/`, `docs/`, `decisions/` 골격
3. **Taxonomy 스키마 YAML 샘플**: `domain.yaml`, `technical.yaml`, `ui.yaml` 예시 작성
4. **Orchestrator CLI 뼈대**: `agent status`, `agent next` 최소 명령어
5. **Backend Agent SKILL.md 초안**: Sonnet 실행자 + Opus Advisor 프롬프트
6. **기본 페르소나 3~4개 작성**: `backend-cto-20y`, `pm-toss-style`, `design-b2c-senior`, `founder-coach`
7. **샘플 프로젝트 하나로 [0]~[3] 돌려보기**: 가장 작은 아이디어로 end-to-end 검증

---

## 14. 용어 사전 (Glossary)

| 용어 | 설명 |
|---|---|
| Agent | 특정 역할을 수행하는 Sonnet + Advisor 쌍 |
| Advisor | Opus 기반 판단자. 페르소나 보유 |
| Persona | Advisor의 경험 · 관점 · 스타일을 정의한 데이터 |
| Orchestrator | 파이프라인 진행을 관리하는 메타 에이전트 (= CLI) |
| Taxonomy | 프로젝트 전체의 공통 언어 사전 |
| Gate | 다음 단계로 넘어가기 전 검증/승인 지점 |
| ADR | Architecture Decision Record. 결정 근거 기록 |
| Critic | 단계 종료 시 외부 시선으로 리뷰하는 역할 |
| Trigger | Advisor 자동 호출 조건 |
| Verdict | Advisor의 판정 (approve/revise/escalate) |

---

**문서 끝 — v0.3 Draft**
