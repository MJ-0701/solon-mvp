# Agent Team Structure

## Organization Chart

```
┌─────────────────────────────────────────────────────────────────────┐
│  비서실장 (Sonnet) ── CEO 직속, 작업 현황 추적/브리핑/미완료 체크     │
├─────────────────────────────────────────────────────────────────────┤
│                     전략기획본부 (CEO)                                │
│                                                                     │
│  CEO (Opus)                                                         │
│  ├── 전략기획 본부장 (Opus) ── 요구사항 설계/검증, 분석 설계          │
│  └── 리서처 (Haiku) ────────── 시장 데이터 수집, 경쟁사 조사          │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                     기술개발본부 (CTO)                                │
│                                                                     │
│  CTO (Opus)                                                         │
│  ├── 기술개발 본부장 (Sonnet) ── 구현 계획, 코드 리뷰, 팀 조율       │
│  │   ├── 개발자 (Sonnet) ──── 기능 구현, 버그 수정                   │
│  │   └── 기술 리서처 (Haiku) ── 코드 검색, API 문서 조사             │
│  └── [CTO 직접] ─────────── 설계, 최종 검증, 크리티컬 수정           │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                     제품품질본부 (CPO)                                │
│                                                                     │
│  CPO (Opus)                                                         │
│  ├── 제품품질 본부장 (Opus) ── 테스트 전략 설계, 설계 검토            │
│  │   ├── QA 엔지니어 (Sonnet) ── Gap Analysis, 코드 품질 검사       │
│  │   ├── 프롬프트 분석관 (Sonnet) ── 피드백 로그 분석, 프롬프트 개선  │
│  │   └── 데이터 수집 (Haiku) ── 로그 수집, 메트릭 수집               │
│  └── [CPO 직접] ─────────── 평가 기준 설계, 최종 Pass/Fail          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Model Assignment Policy

| Level | Model | Role | Rationale |
|-------|-------|------|-----------|
| **C-Level** | Opus 4.6 | 설계, 최종 판단, 타팀 소통 | 최고급 추론 필요 |
| **Team Lead** | Opus/Sonnet | 설계 검토, 팀 조율, 실행 관리 | QA Lead=Opus (설계검토), Dev Lead=Sonnet (빠른 구현관리) |
| **Engineer** | Sonnet | 빠른 구현, 분석 실행 | 속도 최적화 |
| **Researcher** | Haiku | 데이터 수집, 검색 | 비용 효율 + 속도 |

## Communication Rules

| Rule | Description |
|------|-------------|
| **설계 = C-Level only** | PLAN.md, DESIGN.md, 평가 기준 → CEO/CTO/CPO 직접 작성 |
| **설계 검토 = 팀장급+** | DESIGN.md 리뷰 → QA Lead(Opus), Dev Lead(Sonnet) |
| **타팀 소통 = C-Level only** | CEO↔CTO, CEO↔CPO, CTO↔CPO 직접 소통 |
| **팀 내부 = 자유** | 팀장이 팀원 자유롭게 조율 |

## Agent Files

### CEO 직속
| File | Agent | Model | 역할 |
|------|-------|-------|------|
| `chief-of-staff.md` | 비서실장 | Sonnet | 작업 현황 추적, 브리핑, 미완료 체크 |

### C-Level (Opus)
| File | Agent | 본부 |
|------|-------|------|
| `planner.md` | CEO | 전략기획본부 |
| `generator.md` | CTO | 기술개발본부 |
| `evaluator.md` | CPO | 제품품질본부 |

### 본부장
| File | Agent | Model | 본부 |
|------|-------|-------|------|
| `strategy-lead.md` | 전략기획 본부장 | Opus | 전략기획본부 |
| `dev-lead.md` | 기술개발 본부장 | Sonnet | 기술개발본부 |
| `qa-lead.md` | 제품품질 본부장 | Opus | 제품품질본부 |

### 팀원
| File | Agent | Model | 본부 |
|------|-------|-------|------|
| `researcher.md` | 리서처 | Haiku | 전략기획본부 |
| `developer.md` | 개발자 | Sonnet | 기술개발본부 |
| `tech-researcher.md` | 기술 리서처 | Haiku | 기술개발본부 |
| `qa-engineer.md` | QA 엔지니어 | Sonnet | 제품품질본부 |
| `prompt-analyst.md` | 프롬프트 분석관 | Sonnet | 제품품질본부 |
| `data-collector.md` | 데이터 수집 | Haiku | 제품품질본부 |

## Sprint Execution Flow (PDCA)

```
사용자 요청
  ↓
[Plan]    전략기획본부: CEO(Opus) + 전략기획 본부장(Opus)
            └── 리서처(Haiku): 시장/경쟁사 데이터 수집
  ↓
[Design]  기술개발본부: CTO(Opus) DESIGN.md 작성
            └── 제품품질본부: 제품품질 본부장(Opus) DESIGN.md 리뷰
  ↓
[Do]      기술개발본부: CTO → 기술개발 본부장(Sonnet) → 개발자(Sonnet)
            ├── 기술 리서처(Haiku): 코드/API 조사
            ├── 기술개발 본부장(Sonnet): 코드 리뷰
            └── CTO(Opus): 최종 검증 + 크리티컬 수정
  ↓
[Check]   제품품질본부: CPO(Opus) → 제품품질 본부장(Opus)
            ├── QA 엔지니어(Sonnet): Gap Analysis + 코드 품질
            ├── 데이터 수집(Haiku): 로그/메트릭 수집
            └── CPO(Opus): 최종 Pass/Fail
  ↓
[Act]     Score < 90 → 기술개발본부 재작업 (max 3회)
          Score ≥ 90 → Sprint 완료
```

## Total: 13 Agents (3본부 + 비서실)

| Model | 인원 | 소속 |
|-------|:----:|------|
| Opus 4.6 | 5명 | CEO, CTO, CPO, 전략기획 본부장, 제품품질 본부장 |
| Sonnet 4.6 | 5명 | 비서실장, 기술개발 본부장, 개발자, QA 엔지니어, 프롬프트 분석관 |
| Haiku 4.5 | 3명 | 리서처, 기술 리서처, 데이터 수집 |
