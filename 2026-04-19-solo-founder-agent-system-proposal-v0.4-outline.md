# Solo Founder Agent System — 설계 제안서 v0.4 (Outline)

> **문서 성격**: v0.3 → v0.4 구조 뼈대. 각 섹션의 목적/핵심 결정/산출물 placeholder만 명시.
> **독자**: 본인 + 향후 협업자. 이 뼈대가 확정되면 섹션별 풀 작성으로 전환.
> **작성일**: 2026-04-19
> **상태**: Outline Draft — 검토 후 풀 작성
> **선행 문서**: v0.3 (`solo-founder-agent-system-proposal.md`) — 이번 문서는 **완전 교체**가 아니라 **재프레이밍**

---

## 0. 한 줄 요약 (Elevator Pitch)

**1인 창업가가 스타트업 규모의 팀(기획·택소노미·디자인·개발·인프라·품질)을 에이전트로 대체해, 아이디어에서 시장 출시까지 끌고 갈 수 있게 하는 "회사 전체 운영 시스템(Company-as-Code)".**

*(v0.3와 달리, "에이전틱 시스템" 대신 "회사 전체 운영 시스템"으로 메타포 교체)*

---

## 1. v0.3 → v0.4 Delta (중요)

이 섹션은 v0.3를 읽은 독자가 **무엇이 바뀌었는지만** 빨리 파악하게 하는 용도.

### 1.1 유지된 것 (Preserved)
- 1인 창업가 타겟
- Sonnet 실행자 + Opus 판단자 쌍 (N:1 계층으로 확장)
- 페르소나 시스템 (기본 + 교체 가능)
- 본인 승인 게이트 필요성

### 1.2 근본적으로 재정의된 것 (Reframed)
| v0.3 | v0.4 |
|---|---|
| "에이전틱 시스템" (기술 중심) | "회사 전체 운영 시스템" (경영 중심) |
| 레이어 구조 (Layer 1~4) | **C-Level × N-Division 매트릭스** |
| PM/Designer/Backend… 평탄 agent 리스트 | **6개 본부 + C-Level** 계층 구조 |
| 단방향 파이프라인 MVP | **PDCA × Gate × Escalate-Plan** 사이클 |
| Orchestrator = 본인 | **Orchestrator = 본인 + CLI 상태 추적기 + Cowork GUI** |

### 1.3 새로 도입된 것 (New in v0.4)
- **3-Role × N-Domain 매트릭스**: CEO/CTO/CPO × 6 본부
- **G1~G5 Gate Framework**: 도메인 agnostic 품질 게이트
- **Escalate-Plan + AC 단위 부분 재오픈** (α-1 방식)
- **H6 Self-Learning Loop**: escalation → validator checklist 진화
- **3-Channel Observability**: S3 / docs submodule / Notion
- **단일 sfs-plugin 배포**: Claude Code CLI + Claude Desktop 공통
- **Phase 1 내부 사용 → Phase 2 상품화 로드맵**

### 1.4 폐기된 것 (Removed from v0.3)
- [OPEN] v0.3의 어떤 부분이 완전 폐기되는지 매핑 — 풀 작성 단계에서 1:1 대조

---

## 2. 핵심 설계 원칙 (Design Principles, v0.4)

1. **도메인 agnostic 프레임워크 + 도메인 specific evaluator** — G1~G5는 어떤 본부든 동일, evaluator는 본부별 교체
2. **자기검증 금지 (3-Tier Separation Rule)** — 검증은 항상 외부 agent 또는 다른 본부
3. **본부장 = Gate Operator (판단자 X, 오퍼레이터 O)** — C-Level이 기준을 정하고, 본부장이 외부 evaluator 호출
4. **All C-Level + 본부장 = Opus / 실무자 = Sonnet / 헬퍼 = Haiku** — 비용-품질 최적화
5. **Sprint ⊃ 다수 PDCA** — 스프린트는 여러 PDCA 사이클을 묶는 단위
6. **로컬 상태는 PC별 private, 공유는 git + Notion** — race condition 구조적 방지
7. **CLI + GUI 통합 백엔드** — Claude Code와 Claude Desktop이 같은 파일시스템 공유
8. **Phase 1 내부 사용 → Phase 2 상품화** — 본부 정의는 YAML로, 하드코딩 금지

---

## 3. C-Level × N-Division 매트릭스 (Architecture)

### 3.1 개념도 Placeholder
```
[Mermaid or ASCII — 풀 작성 단계에서 그림]
- 상단: CEO · CTO · CPO
- 중단: 6개 본부 (PM · Taxonomy · Design · Dev · QA · Infra)
- 하단: 각 본부의 실무자들
- 우측: 외부 Evaluator Pool (fork + read-only)
```

### 3.2 C-Level (3명, 전원 Opus)
| 역할 | 이름 | 책임 |
|---|---|---|
| Planner | CEO | 비전, 스프린트 우선순위, 본부 간 조율 |
| Generator | CTO | 실행 총괄, 본부 간 의존성 관리 |
| Evaluator | CPO | 제품 가치, 5-Axis 최종 평가 |

### 3.3 6 본부 (Divisions)
| 본부 | 본부장 (Opus) | PDCA 산출물 | Phase 1 범위 |
|---|---|---|---|
| 기획 (PM) | pm-lead | PRD, user flow | 풀 구현 |
| 택소노미 | taxonomy-lead | 분류체계, 용어사전 | 풀 구현 (신규 evaluator 1개) |
| 디자인 | design-lead | Figma, 디자인 토큰, 컴포넌트 스펙 | cowork 참조 재작성 (3개 evaluator) |
| 기술개발 | dev-lead | 코드, API, 마이그레이션 | bkit evaluator 재활용 |
| 품질 (QA) | qa-lead | 테스트, QA 리포트 | bkit qa-monitor 재활용 |
| 인프라 | infra-lead | Terraform, CI/CD | **최소 범위** (bkit infra-architect 재활용 + 비용 추정) |

### 3.4 Agent 모델 할당 규칙
- C-Level: Opus (3명)
- 본부장: Opus (6명)
- Evaluator: Opus + fork context + read-only
- 실무자: Sonnet (본부별 1~3명, 정확한 수는 풀 작성 단계)
- 헬퍼 (간단 parsing/변환): Haiku

---

## 4. PDCA 재정의 (도메인 agnostic)

### 4.1 PDCA 단계별 산출물 매핑
| 단계 | 개발 본부 | 디자인 본부 | 기획 본부 | 택소노미 본부 |
|---|---|---|---|---|
| Plan | 기능 명세 + AC | UI 요구사항 | PRD | 분류 요구사항 |
| Design | API spec, DB schema | Figma 시안, 디자인 토큰 | User flow, 와이어프레임 | 분류체계, 라벨 가이드 |
| Do | 코드 구현 | 최종 디자인 | PRD 확정본 | 용어사전 구현 |
| Check | gap-detector | design-critique | prd-validator | taxonomy-consistency-checker |
| Act | 리포트 + 학습 | 리포트 + 학습 | 리포트 + 학습 | 리포트 + 학습 |

### 4.2 Sprint ⊃ 다수 PDCA
- 1 Sprint = N개 PDCA (본부별로 독립 진행 가능)
- Sprint start/end는 CEO가 결정
- Sprint 내 PDCA 의존성은 Orchestrator(CLI/Cowork)가 추적
- [OPEN] Sprint 내 PDCA 병렬 실행 한계치 — 풀 작성 단계에서 정의

---

## 5. Gate Framework (G1~G5)

### 5.1 Gate 매트릭스
| Gate | 프레임 의미 | 오퍼레이터 | Evaluator (도메인별) |
|:---:|---|---|---|
| G1 Plan Gate | AC 측정가능성, 범위 | strategy-lead | plan-validator (공통) + prd-validator (PM) |
| G2 Design Gate | 설계 완성도 | 본부장 | design-validator / design-critique / taxonomy-consistency-checker |
| G3 Pre-Handoff | 산출물 핸드오프 가능 상태 | 본부장 | code-analyzer / accessibility-review / brand-guideline-checker |
| G4 Check Gate | 실제 vs 설계 gap | qa-lead | gap-detector + CPO 5-Axis |
| G5 Sprint Retro | 학습 (도메인 agnostic) | CEO + strategy-lead | 정량적 평가 X, 정성적 학습 기록 |

### 5.2 G4 Formula (본부별)
- 개발 본부: `G4 = gap-detector × 0.4 + 5-Axis × 0.6` (G3 binary pre-check)
- 디자인 본부: `G4 = 디자인 가이드 일치도 × 0.4 + 5-Axis × 0.6`
- 기획 본부: `G4 = AC 충족도 × 0.4 + 5-Axis × 0.6`
- 택소노미 본부: `G4 = taxonomy-consistency score × 0.4 + 5-Axis × 0.6`
- 품질/인프라: [OPEN] 풀 작성 단계에서 정의

### 5.3 Gate Call Contract (표준 입력)
`{ gate_id, target, evaluator, context_refs, inputs, thresholds }`

### 5.4 GateReport Schema (표준 출력)
`{ gate_id, verdict, score, breakdown, recommendations, escalation, audit, user_decision_needed? }`

### 5.5 7 Failure Modes
SUCCESS / FAIL-FIXABLE / FAIL-HARD / STALL / CONFLICT / TIMEOUT / ABORT

---

## 6. Escalate-Plan + Self-Learning Loop (H6)

### 6.1 Case 구분
- **Case-α** (요구사항 수정): AC 표현 정정. Escalate-Plan으로 처리. **α-1 방식 (AC 단위 부분 재오픈)**
- **Case-β** (방향 전환): 요구사항 자체가 틀림. **Escalate-Plan 대상 아님**, 새 PDCA로 처리

### 6.2 Escalate-Plan 메커니즘 (Case-α 전용)
- 트리거: auto (G4 FAIL-HARD/STALL → request_user_decision) OR manual (/pdca escalate)
- 브랜치 전략: **신규 브랜치** (`feature/X-escalated-v2`)
- 무효화 범위: **AC 단위** — `status: locked | reopened` 필드로 관리
- 전제: AC-Design-Do 매핑을 메타데이터로 강제 (`relates_to_ac: [...]`)

### 6.3 CONFLICT 5-option protocol
1. Align-Impl (Do 재오픈)
2. Align-Design (Design 재오픈)
3. Merge (Design+Do 동시 재오픈)
4. Record (deviation note)
5. **Escalate-Plan** (SFS 추가)

### 6.4 Self-Learning Loop (H6)
- Escalation 로그 → `docs/03-analysis/escalations/*.md`
- G5 Sprint Retro에서 자동 집계
- 패턴 발견 시 → plan-validator / 기타 evaluator 체크리스트에 추가
- 다음 Sprint의 gate 기준을 **escalation 경험으로 강화**

### 6.5 Escalation 스키마
- [Placeholder] 풀 작성 단계에서 YAML 스키마 확정

---

## 7. 3-Channel Observability

### 7.1 3개 채널
| 채널 | 수신자 | 저장소 | 용도 |
|:---:|---|---|---|
| L1 Raw Logs | Machine | S3 | agent JSON 로그, metric, trace |
| L2 Versioned Docs | Git / 감사 | docs submodule | **Single Source of Truth**, PDCA 산출물, GateReport |
| L3 Collaboration View | Human / 이해관계자 | Notion | 읽기 뷰, 비개발자 UX, Sprint 대시보드 |

### 7.2 동기화 원칙
- 방향: L1 → L2 → L3 **일방향만**
- L2가 SSoT, Notion 편집은 L2로 역류 금지
- Notion sync는 **post-commit hook**
- 로컬 상태(`.bkit-memory.json` 등)는 gitignore, PC별 private

### 7.3 동기화 파이프라인 Placeholder
- [OPEN] 구체적 hook 구현 — 풀 작성 단계

---

## 8. Plugin 배포 (Phase 1) + 상품화 로드맵 (Phase 2)

### 8.1 Phase 1: 단일 sfs-plugin
```
sfs-plugin/
├── plugin.json
├── install.sh
├── config/divisions.yaml          # 본부 정의 (커스터마이징 진입점)
├── agents/{c-level, division-leads, evaluators, workers}/
├── skills/{sfs-pdca, sfs-gates, sfs-escalate, sfs-retro, domain-specific}/
├── commands/
├── hooks/observability-sync.js
└── templates/
```

### 8.2 배포 방식
- CLI (Claude Code) + Desktop (Cowork) 동시 설치
- 같은 파일시스템 공유 → 백엔드 통합

### 8.3 Phase 2 상품화 (로드맵)
- RBAC 풀 구현 (본부별 권한 분리)
- 플러그인 모듈화 (core + 본부별 선택 설치)
- Multi-tenant 데이터 격리
- 마켓플레이스 / 문서 사이트 / 온보딩
- 라이선싱 체계
- [OPEN] Phase 2 일정은 Phase 1 검증 후 산정

---

## 9. 차별화 (Differentiation vs bkit)

### 9.1 차별화 축 (H1, H2, H5, H6)
| # | 축 | bkit | SFS |
|:---:|---|---|---|
| H1 | Observability | 로컬 `.bkit-memory.json` only | 3-Channel (S3/git/Notion) |
| H2 | Role Scope | 개발 워크플로우 중심 | **6 본부 (PM/Taxonomy/Design/Dev/QA/Infra)** |
| H5 | C-Level 전략 레이어 | 평탄 agent | **CEO/CTO/CPO** 전략 판단 |
| H6 | Self-Learning | 없음 | **Escalation → validator 진화** |

*(H3 Customization, H4 Production Ops는 Phase 2에서 본격 차별화)*

### 9.2 포지션 문장
> **bkit** = 개발자 PDCA 워크플로우 도구 (MVP/Starter/Dynamic/Enterprise 레벨)
> **SFS** = 1인 창업가의 회사 전체 운영 시스템 (6 도메인, C-Level 전략, 3-Channel 관측성, 자기학습)

---

## 10. Phase 1 구현 계획

### 10.1 전체 범위
- 본부: 6개 (PM + Taxonomy + Design + Dev + QA + Infra 최소)
- RBAC: 제외 (솔로 사용 가정)
- 플러그인: 단일 sfs-plugin
- cowork: 참조 후 독립 재작성 (Option E, 3 skill만)

### 10.2 신규 개발 항목
- C-Level agents 3개 (CEO, CTO, CPO)
- 본부장 agents 6개
- 신규 Evaluator 4개: plan-validator, prd-validator, taxonomy-consistency-checker, brand-guideline-checker
- cowork 재작성 Evaluator 3개: design-critique, accessibility-review, design-handoff
- Gate operation skills: sfs-pdca, sfs-gates, sfs-escalate, sfs-retro
- Observability pipeline (S3 + git + Notion sync)
- 간단 인프라 비용 추정 skill 1개

### 10.3 재활용 항목
- bkit: gap-detector, code-analyzer, design-validator, qa-monitor, infra-architect
- Claude Code 기본: Task 도구, Skill 시스템, hooks

### 10.4 예상 일정 (대략)
- [OPEN] **풀 작성 단계에서 주 단위 breakdown**
- 개략: 14~18주
  - Week 1-2: C-Level + 본부장 agent 정의 (YAML + prompt)
  - Week 3-5: 신규 evaluator 4개 개발
  - Week 6-8: cowork 참조 재작성 3개
  - Week 9-11: Gate skills + PDCA 통합
  - Week 12-13: Observability pipeline
  - Week 14-15: 통합 테스트 + product-image-studio에 dogfooding
  - Week 16-18: 버그 수정 + 안정화

### 10.5 성공 기준 (Phase 1)
- product-image-studio 프로젝트에 SFS 적용 → 한 Sprint 완주
- 6개 본부 모두 1회 이상 PDCA 완료
- G1~G5 Gate 모두 1회 이상 실행
- Escalate-Plan 1회 이상 트리거 + H6 학습 로그 1개 이상 생성
- 3-Channel observability 모두 데이터 보유

---

## 부록 A. 용어 사전 (Terminology)

- [Placeholder] C-Level, 본부장, Gate, Evaluator, Escalate, Case-α/β, Sprint, PDCA 등 — 풀 작성 단계에서 정의

## 부록 B. v0.3 산출물과의 매핑 테이블

- [Placeholder] v0.3의 각 섹션이 v0.4 어디로 갔는지/폐기됐는지 1:1 매핑 — 풀 작성 단계

## 부록 C. Open Questions

- [ ] Sprint 내 PDCA 병렬 실행 한계
- [ ] G4 formula (품질/인프라 본부)
- [ ] Escalation 스키마 YAML 확정
- [ ] Observability hook 구체 구현
- [ ] Phase 2 일정 (Phase 1 완주 후 재산정)
- [ ] 본부별 실무자 agent 수와 역할 분담

---

## Outline 끝

다음 단계: 이 뼈대 검토 → 승인 후 각 섹션 풀 작성 (예상 분량 3000~4000줄 마크다운)
