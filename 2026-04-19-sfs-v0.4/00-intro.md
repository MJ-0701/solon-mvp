---
doc_id: sfs-v0.4-s00-intro
title: "§0. Elevator Pitch & 왜 지금인가"
version: 0.4
status: draft
last_updated: 2026-04-20
audience: [all]
required_reading_order: [s00]

depends_on: []

defines:
  - concept/elevator-pitch
  - concept/company-as-code
  - concept/solo-founder-target
  - concept/seven-role-bottleneck

references: []

affects:
  - sfs-v0.4-s01-delta-v03-to-v04
  - sfs-v0.4-s09-differentiation
---

# §0. Elevator Pitch & 왜 지금인가

> **Context Recap (자동 생성, 수정 금지)**
> 이 문서는 전체 제안서의 **진입점**. 의존하는 선행 문서 없음.
> 여기서 정의되는 `concept/company-as-code`는 §3(조직도), §9(차별화)에서 반복 참조된다.

---

## 제품 철학 (사용자 선언, verbatim)

> **이 섹션은 채명정 본인이 직접 선언한 SFS 제품 철학이다. 두 선언이 전체 설계의 근거이며, 각각 [원칙 9](02-design-principles.md)·[원칙 10](02-design-principles.md)으로 구조화된다.**

### 철학 ① — 탄탄한 설계가 가장 빠른 구현

> **"떠오르는 아이디어를 가장 빠르게 구현할 수 있는 방법은 탄탄한 설계에서 부터 시작된다"**

구현 속도 ≠ 코드 빠르게 쓰기. 설계 단계에서 **의도·대안·경계**를 명시하지 않으면 잘못된 문제를 풀게 된다. "빨리 만든다"는 목표는 오히려 설계를 전제로만 달성 가능하다.

이 선언은 **원칙 9 `principle/brainstorm-gate-mandatory`** ([§02 §2.9](02-design-principles.md))의 근거다:
Initiative 진입 시 **G0 Brainstorm Gate를 반드시 통과**해야 하며, 6-필드 템플릿(intent, alternatives, scope, success_signal, sprint_decomposition, risk_pre_register)으로 설계 탄탄함을 기계적으로 강제한다.

### 철학 ② — 사람 최종 필터

> **"구현후 테스트는 사람이 직접 무조건 해야된다 (그래야 필터가 제대로 됨)"**

LLM은 자기 출력을 자기가 검증할 때 **확증 편향**에 빠진다. agent 간 분리(원칙 2)만으로는 같은 LLM 계열이 전체 파이프라인을 돌 때의 편향을 차단하지 못한다. "이것이 정말 사용자가 원한 것인가"의 최종 판정은 사람 고유 권한.

이 선언은 **원칙 10 `principle/human-final-filter`** ([§02 §2.10](02-design-principles.md))의 근거다:
G4 수락 테스트(`gate/g4-acceptance`)는 사람이 직접 실행·관찰·판정하며, 자동 E2E로 대체하지 않는다.

### 설계-검증 샌드위치

두 철학이 합쳐지면 전체 파이프라인이 **앞뒤에서 사람이 필터하는** 구조가 된다:

```
[사람: 의도 선언] → G0 Brainstorm → [agent 병렬: 실행] → G1~G3 Gate → G4 수락 → [사람: 최종 판정]
   ↑ 철학 ① 작동                                                       ↑ 철학 ② 작동
       (진입 필터)                                                        (출구 필터)
```

진입·출구 양 끝에서만 사람이 개입 → 내부 workflow는 agent 병렬로 최대 throughput을 낸다.
**이것이 1인 창업가가 6 본부를 동시 지휘할 수 있는 구조적 근거다.**

---

## TOC

- **제품 철학 (사용자 선언)** — 철학 ①②가 원칙 9·10의 근거
- 0.1 한 줄 요약 (Elevator Pitch)
- 0.2 문제 정의 — 1인 창업가의 7 역할 병목
- 0.3 기존 도구의 한계 (bkit, cowork, ChatGPT Teams 등)
- 0.4 SFS의 핵심 주장 (Company-as-Code)
- 0.5 이 문서셋을 어떻게 읽을지

---

## 0.1 한 줄 요약 (Elevator Pitch)

**Solon (brand) · /sfs (Solo Founder System, CLI prefix)** — 1인 창업가가 스타트업 규모의 팀(기획·택소노미·디자인·개발·QA·인프라)을 **구조화된 에이전트 조직**으로 대체해, 아이디어에서 시장 출시까지 홀로 끌고 갈 수 있게 하는 **"회사 전체 운영 시스템(Company-as-Code)"** 이다.

단순한 "AI 프롬프트 모음"이나 "PDCA 체크리스트"가 아니다. Solon 은 다음 네 개의 축을 모두 코드·YAML·문서로 **명시화**한 meta-agent system이다.

1. **조직도** — 3 C-Level × 6 본부 매트릭스 (`concept/company-as-code`)
2. **프로세스** — Sprint ⊃ PDCA + **G-1 + G1~G5 (6 Gate)** + Escalate-Plan
3. **산출물** — 본부별 표준 산출물 + schema (gate-report-v1, escalation-v1, L1 log-event)
4. **관측성** — 3-Channel (L1 S3 / L2 git SSoT / L3 Notion) 일방향 sync

**한 문장으로**: "회사를 코드로 정의할 수 있다면, 1인도 회사를 운영할 수 있다."

---

## 0.2 문제 정의 — 1인 창업가의 7 역할 병목

`concept/seven-role-bottleneck`: 2026년 현재, 1인 창업가가 MVP를 시장에 내놓기까지 현실적으로 커버해야 하는 **최소 7개 역할**이 존재한다.

| # | 역할 | 핵심 책임 | 빠지면 어떤 일이? |
|:-:|------|----------|------------------|
| 1 | CEO | 비즈니스 방향, 우선순위, 출시 결정 | 만들 건 많은데 뭘 먼저 낼지 결정 못 함 |
| 2 | CTO | 아키텍처, 기술 스택, 부채 관리 | 초반에 잘못된 스택 → 2개월 뒤 재작성 |
| 3 | CPO | 제품 가치 제안, UX 의사결정 | 예쁘기만 하고 왜 사는지 모르는 제품 |
| 4 | PM (기획) | 요구사항, AC, 스프린트 운영 | 매일 "오늘 뭘 만들지?" 고민으로 시간 증발 |
| 5 | Designer | UX flow, 디자인 시스템, 핸드오프 | UI가 일관성 없어 셀러가 신뢰 못 함 |
| 6 | Developer | 구현, 테스트, 배포 | 코드는 있는데 배포가 안 됨 |
| 7 | QA + Infra | 품질 검증, 운영 안정성 | 출시 직후 장애 → 환불 + 신뢰 붕괴 |

### 2.1 왜 "7개 중 하나라도 빠지면 MVP도 완주 못 하는가"

실제 1인 창업 실패 사례의 공통 패턴:
- 개발자 1인 창업 → UX/기획이 약해 "기능은 되는데 아무도 안 쓰는" 제품
- 기획자 1인 창업 → 외주 개발비 폭증 + 핸드오프에서 명세 잃어버림
- 디자이너 1인 창업 → 배포·운영 막힘 + 백엔드 버그 방치

→ **어느 하나라도 공백이면 나머지가 다 의미 없어짐**. 이게 7-역할-병목의 본질.

### 2.2 기존 해결책의 한계

| 해결책 | 한계 |
|--------|------|
| **외주** | 커뮤니케이션 오버헤드, 의사결정 맥락 유실, 월 수백만원 |
| **공동창업자** | 적합한 사람 찾는 데만 6~12개월, 지분 희석, 일정 misalign |
| **노코드/로우코드** | 차별화 불가, vendor lock-in, 확장 천장 낮음 |
| **AI 챗봇 1:1** | 책임 분리 X, 자기검증 루프 존재, 학습 누적 X |

### 2.3 왜 "2026년 시점의 에이전트"가 이걸 메울 수 있는가

- Claude Opus 4.6 / Sonnet 4.6 / Haiku 4.5 → **역할별 모델 할당** 가능 (전략 vs 실무 vs 루틴)
- Claude Code / Claude Desktop (Cowork) → 로컬 파일시스템 기반 + MCP 표준
- Tool use + Plan mode → 다단계 작업 완주 가능
- Sub-agent orchestration → Gate/Evaluator 구조 구현 가능

즉, **"여러 명이 필요한 일"을 "여러 agent role로 분리"** 하는 것이 기술적으로 가능해진 첫 시점이 2026년이다.

---

## 0.3 기존 도구의 한계

| 도구 | 범위 | 커버하는 역할 | 핵심 한계 |
|------|------|-------------|----------|
| **bkit** | 개발 PDCA | Developer + 일부 QA | 기획·디자인·인프라 체계 없음, 1-프로젝트 scope |
| **cowork plugin** | 디자인 skill 7개 | Designer 일부 | 조직 구조 없음, orchestration 없음, 산출물 스키마 없음 |
| **ChatGPT Teams** | 범용 챗봇 | 부분 보조 | 역할 분리 없음, Gate 없음, 학습 루프 없음 |
| **AutoGPT / BabyAGI류** | 에이전트 실행 | 자동화 | C-Level 전략 없음, 3-Channel 관측 없음, 자기검증 루프(위험) |
| **Lovable / v0 / Bolt** | UI 생성 | Designer+Dev 일부 | UX flow 설계 없음, gate 없음, 프로덕션 운영 없음 |

**공통 빈 칸**:
- 조직도 수준의 **책임 분리**
- 산출물 간 **의존성 그래프**
- **외부 검증자(Gate Operator)** 개념
- **자기학습 루프(H6)** — 실패가 다음 Sprint 문서에 반영

SFS는 이 공통 빈 칸을 **구조**로 메운다. (자세한 축별 비교는 [§9](09-differentiation.md))

---

## 0.4 SFS의 핵심 주장 (Company-as-Code)

`concept/company-as-code`: **회사는 다음 4축의 합으로 정의 가능**하고, 이 4축을 코드·YAML·문서로 명시화하면 1인도 회사 전체를 운영할 수 있다.

```
Company = Org(조직도) × Process(프로세스) × Artifact(산출물) × Observability(관측성)
```

### 3대 주장

**주장 1. 회사는 코드로 정의 가능**
- 조직도 → `divisions.yaml` (6 본부 + 3 C-Level)
- 프로세스 → PDCA + G-1 + G1~G5 Gate (6 Gate) + Escalate-Plan 규칙
- 산출물 → `gate-report.schema.yaml`, `escalation.schema.yaml`
- 관측성 → 3-Channel sync hook (`observability-sync.ts`)

→ 코드화되면 **재현 가능**, **검증 가능**, **개선 가능**.

**주장 2. 평탄한 agent 리스트는 회사가 아니다**
"AI 비서 10명" 나열만으로는 회사가 안 움직인다. **C-Level × Division 매트릭스**가 있어야:
- 책임 중복/누락 방지
- 품질 Gate가 "누가 누굴 검증하는가" 명확히 정의
- 모델 할당(Opus 전략/Sonnet 실무/Haiku 루틴)이 타당해짐

→ 평탄 구조 vs 매트릭스 구조의 차이는 §3에서 구조적으로 설명.

**주장 3. 자기검증 금지 + 외부 검증 + 학습 루프**
회사 운영의 불문율을 agent 시스템에 이식:
- 작성한 agent는 스스로 검증 금지 (원칙 `principle/self-validation-forbidden`)
- Gate는 반드시 외부 evaluator agent가 수행
- Gate 실패 → Escalate-Plan → 학습 패턴으로 축적 (H6)

→ 이 루프가 없으면 agent 시스템은 **장기적으로 품질이 하락**한다. (bkit/cowork가 이 축을 안 가짐)

---

## 0.5 이 문서셋을 어떻게 읽을지

문서셋 전체는 **11 body + 8 appendix 디렉터리 (commands/dialogs/drivers/engines/hooks/schemas/templates/tooling, 파일 총 38)**로 구성되며, 각 파일의 frontmatter(`depends_on`, `defines`, `references`, `affects`)로 의존성이 **기계적으로 검증 가능**하다 (sfs-doc-validate).

### Role별 진입점

| 독자 | 권장 진입점 | 이유 |
|------|-----------|------|
| **완전 신규 독자** | 00 → 01 → 02 → ... → 10 순차 | 전체 맥락 |
| **v0.3 이미 읽음** | [01-delta](01-delta-v03-to-v04.md) | 변경점만 빠르게 |
| **의사결정자/투자자** | 00 → 02 → 09 → 10.5(성공 기준) | WHY + 차별화 + 지표 |
| **구현자** | 10 → 03 → 04 → 05 → 07 + appendix | 실전 수순 |
| **Gate 평가자** | 03 → 04 → 05 → appendix/schemas | 평가 규칙 |
| **운영자** | 08 → appendix/hooks → 06 | 관측성 + 학습 |

→ 상세 네비게이션은 [INDEX.md](INDEX.md) 참조.

### 문서 읽는 규칙

- 각 섹션 최상단의 `> Context Recap` 블록은 **수정 금지** (자동 생성/검증).
- 개념 참조는 `({sNN})` 표기로 doc_id 기반 링크 (파일명 변경 시에도 live).
- `[TBD-풀작성]`이 남아있는 섹션은 skeleton 단계. draft 진입 시 제거.
- `status: locked`인 파일은 변경 금지 (Phase 1 착수 후에만 적용).

---

*(끝)*
