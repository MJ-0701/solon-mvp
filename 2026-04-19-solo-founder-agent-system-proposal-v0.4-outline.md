# Solo Founder Agent System — 설계 제안서 v0.4 (Outline)

> **문서 성격**: v0.3 → v0.4 구조 뼈대. 각 섹션의 목적/핵심 결정/산출물 placeholder만 명시.
> **독자**: 본인 + 향후 협업자. 이 뼈대가 확정되면 섹션별 풀 작성으로 전환.
> **작성일**: 2026-04-19
> **상태**: Outline Draft — 2026-04-28 사용자 재검토 반영
> **선행 문서**: v0.3 (`solo-founder-agent-system-proposal.md`) — 이번 문서는 **완전 교체**가 아니라 **재프레이밍**
> **리뷰 근거**: `2026-04-19-sfs-v0.4/appendix/reviews/2026-04-28-startup-team-agent-flow-review.md`

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
- **Artifact Contract First**: agent 호출 전 단계별 입력/출력/통과 기준을 먼저 고정
- **Shift-left Infra/Security**: 인프라·보안은 배포 직전 1회 리뷰가 아니라 기술 설계 초반부터 최소 체크리스트로 참여
- **Continuous Documentation**: 문서화는 마지막 단계가 아니라 각 단계 산출물의 누적 ledger, Notion은 사람용 뷰

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
9. **Artifact Contract First** — 각 단계는 다음 단계 agent가 읽을 수 있는 명시 산출물과 Gate 기준을 남겨야 함
10. **Taxonomy is Root, not Wireframe Appendix** — 택소노미는 화면 설계의 부속물이 아니라 도메인·API·UI·문서 전체의 공통 언어
11. **Shift-left Infra/Security** — 인프라와 보안은 구현 후 배포 직전만 보는 게 아니라 기술 설계 단계에서 최소 리스크를 먼저 드러냄
12. **Continuous Documentation Ledger** — 최종 문서화 agent는 기억으로 재구성하지 않고, 앞 단계 artifact를 조립·번역함

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

### 3.5 책임 경계 (2026-04-28 리뷰 반영)

에이전트는 "좋은 사람이 많다"가 아니라 "서로 다른 책임을 가진 작은 조직"이어야 한다.

| 역할 | 결정 권한 | 실행 권한 | 주요 산출물 |
|---|---|---|---|
| CEO / Orchestrator | 제품 방향, 우선순위, gate 승인 요청 | agent 호출, 상태 전이 | initiative brief, sprint plan, decision brief |
| CPO / Product Evaluator | 제품 가치, UX, 사용자 관점 PASS/FAIL | 수정 지시가 아닌 피드백 | product review, 5-axis evaluation |
| CTO / Technical Evaluator | 기술 리스크, 아키텍처, 구현 가능성 판단 | 기술 설계 승인, dev lead 조율 | technical design review |
| PM Lead | 요구사항 구조화 | PRD/user story 작성 | PRD, AC, user flow |
| Taxonomy Lead | 용어·엔티티·상태값 정합성 | taxonomy 초안/변경 제안 | domain glossary, entity map, naming ADR |
| Design Lead | UX flow, wireframe, design token 정합성 | 디자인 초안 작성 | wireframe, component spec |
| Dev Lead | 구현 계획, 코드 통합 | backend/frontend worker 조율 | API, DB, frontend implementation |
| QA / Review Pool | 검증 기준별 PASS/FAIL 리포트 | read-only review | code/product/security/gap reports |
| Infra / Security Lead | 배포 가능성, secret, rollback, threat checklist | infra plan 작성 | deploy plan, security checklist, runbook |

---

## 4. PDCA 재정의 (도메인 agnostic)

### 4.0 Startup Team-Agent Flow (full form)

사용자가 2026-04-28 재정리한 흐름은 방향이 맞다. 단, 제품화 가능한 agent system 으로 만들려면 "단계 이름"보다 "artifact contract + gate"가 먼저 잠겨야 한다.

Full form 은 다음 13단계다.

1. **Idea Capture** — 아이디어 원문, 배경, 사용자 직감 기록
2. **Discovery / Brainstorm** — 문제 크기, 타겟 사용자, 대체재, 시장 가설, 성공 지표 탐색
3. **Product Plan** — MVP 범위, 로드맵, out-of-scope, 리스크 정리
4. **PRD + Acceptance Criteria** — 요구사항을 측정 가능한 AC로 고정
5. **Taxonomy + Domain Model** — 도메인 용어, 엔티티, 상태값, API/UI naming 기준 확정
6. **UX Flow + Wireframe + Design Draft** — 사용자 흐름, 정보 구조, 와이어프레임, 디자인 초안
7. **Technical Design** — API, DB, frontend architecture, integration, infra sketch
8. **MVP Implementation** — backend/frontend worker가 AC 단위로 빠르게 구현
9. **Multi-Agent Review** — Claude/Gemini/Codex 등으로 code/product/UX/security 관점 분리 리뷰
10. **Dev Deploy + QA** — 개발 서버 배포, smoke/e2e/manual QA
11. **Production Infra + Release Gate** — secret, monitoring, rollback, security checklist, 비용 점검
12. **Production Deploy + Monitoring** — 상용 배포, 로그·알림·핵심 지표 확인
13. **Docs + Retro + Learning Loop** — 도메인/기술/운영 문서 조립, 회고, evaluator checklist 진화

사용자의 기존 8단계는 이 full form 의 좋은 축약판이다. 다만 `Discovery`, `Artifact Contract`, `Shift-left Infra/Security`, `Continuous Documentation` 이 빠지면 agent가 "잘 만든 엉뚱한 제품"을 만들거나, 마지막에 문서를 기억으로 재구성하는 위험이 커진다.

### 4.1 단계별 Artifact Contract

| # | 단계 | 필수 산출물 | 다음 단계 입력 | Gate |
|:-:|---|---|---|---|
| 1 | Idea Capture | `idea.md` | raw intent | none |
| 2 | Discovery / Brainstorm | `brainstorm.md`, market assumptions | validated problem hypothesis | G0 |
| 3 | Product Plan | `plan.md`, MVP scope | bounded sprint target | G1 |
| 4 | PRD + AC | `prd.md`, `acceptance-criteria.yaml` | measurable requirements | G1 |
| 5 | Taxonomy + Domain Model | `taxonomy/*.yaml`, entity map, naming ADR | shared language for design/dev/docs | G2 |
| 6 | UX + Wireframe + Design Draft | wireframe, user flow, component spec | buildable UI/UX spec | G2 |
| 7 | Technical Design | API spec, DB schema, infra sketch, security notes | implementation plan | G3 |
| 8 | MVP Implementation | code, migrations, local test report | review target | G3 |
| 9 | Multi-Agent Review | review reports by axis | fix list or release candidate | G4 |
| 10 | Dev Deploy + QA | dev URL, QA report, test evidence | release readiness input | G4 |
| 11 | Production Infra + Release Gate | deploy plan, rollback plan, security checklist | production approval brief | Release Gate |
| 12 | Production Deploy + Monitoring | production URL, metrics, incident hooks | operating product | Release Gate |
| 13 | Docs + Retro + Learning | domain docs, tech docs, runbook, retro | next sprint seed | G5 |

### 4.2 PDCA 단계별 산출물 매핑
| 단계 | 개발 본부 | 디자인 본부 | 기획 본부 | 택소노미 본부 |
|---|---|---|---|---|
| Plan | 기능 명세 + AC | UI 요구사항 | PRD | 분류 요구사항 |
| Design | API spec, DB schema | Figma 시안, 디자인 토큰 | User flow, 와이어프레임 | 분류체계, 라벨 가이드 |
| Do | 코드 구현 | 최종 디자인 | PRD 확정본 | 용어사전 구현 |
| Check | gap-detector | design-critique | prd-validator | taxonomy-consistency-checker |
| Act | 리포트 + 학습 | 리포트 + 학습 | 리포트 + 학습 | 리포트 + 학습 |

### 4.3 Sprint ⊃ 다수 PDCA
- 1 Sprint = N개 PDCA (본부별로 독립 진행 가능)
- Sprint start/end는 CEO가 결정
- Sprint 내 PDCA 의존성은 Orchestrator(CLI/Cowork)가 추적
- [OPEN] Sprint 내 PDCA 병렬 실행 한계치 — 풀 작성 단계에서 정의

### 4.4 Lightweight MVP Projection

Phase 1 에서 full form 13단계를 모두 "무거운 본부 활성화"로 실행하면 과투자다. 따라서 MVP projection 은 다음처럼 압축한다.

| 사용자 8단계 | Full form 매핑 | MVP 운영 |
|---|---|---|
| 1. 아이디어 제출 | 1 | `idea.md` 한 장 |
| 2. 브레인스토밍 | 2 | G0 signal, 시장조사 deep dive는 필요할 때만 |
| 3. 플랜설계 | 3~4 | `plan.md` + AC를 한 파일로 시작 |
| 4. 기획서 및 택소노미/와이어프레임 | 4~6 | PRD, taxonomy, wireframe을 분리하되 각 1~2 page 제한 |
| 5. 구현 | 7~8 | technical design 최소화 후 MVP 구현 |
| 6. 분석 및 코드리뷰 | 9~10 | Claude/Gemini/Codex 다중 리뷰는 위험도 높은 변경에만 호출 |
| 7. 인프라 구축 및 배포 | 10~12 | infra sketch는 기술 설계 때 작성, production gate에서 최종 확인 |
| 8. 문서화 | 13 | 마지막에 새로 쓰지 않고 앞 artifact를 도메인/기술/운영 문서로 조립 |

---

## 5. Gate Framework (G1~G5)

### 5.0 Gate 배치 원칙

Code review 는 구현 후 1회 이벤트가 아니라 여러 gate 중 하나다. Gate 는 agent를 멈추게 하는 장치라기보다 "다음 단계로 넘겨도 되는 artifact인지"를 판단하는 계약이다.

| Gate | 위치 | 핵심 질문 | 대표 evaluator |
|:---:|---|---|---|
| G0 | Discovery / Brainstorm 종료 | 만들 문제가 충분히 구체적인가? | CPO + intent-discovery-validator |
| G1 | Plan / PRD 종료 | AC가 측정 가능하고 scope가 작게 잘렸는가? | plan-validator + prd-validator |
| G2 | Taxonomy / UX / Design 종료 | 용어·흐름·화면이 구현 가능한 공통 언어로 정리됐는가? | taxonomy-consistency + design-critique |
| G3 | Technical Design / Implementation 전후 | handoff 가능한 설계·코드·테스트 증거가 있는가? | code-analyzer + architecture reviewer |
| G4 | Review / QA / Dev Deploy | 실제 결과가 PRD·디자인·기술 설계와 일치하는가? | gap-detector + CPO 5-Axis |
| Release Gate | Production 전 | secret, monitoring, rollback, security, cost가 확인됐는가? | infra-lead + security reviewer |
| G5 | Docs / Retro | 다음 sprint 에 반영할 학습이 남았는가? | CEO + strategy lead |

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
- 문서화는 마지막 단계에서 "새로 쓰기"가 아니라 각 단계 artifact를 L2에 계속 쌓고, L3(Notion)는 비개발자가 읽기 좋게 투영한다.
- 도메인 문서 / 팀별 문서 / 전문가용 문서 / 비전문가용 문서는 같은 L2 artifact에서 파생되어야 한다. 사람이 Notion에서 임의 편집한 내용이 SSoT가 되면 agent 간 drift가 발생한다.

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
- 구현 우선순위: agent 수를 늘리기 전에 `Artifact Contract`, `GateReport`, `division activation_state` 를 먼저 구현한다.
- 모든 본부를 처음부터 active 로 만들지 않는다. 초기에는 strategy-pm + dev 중심, taxonomy/design/infra/qa 는 필요 시 scoped activation 한다.

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
- 동일 feature 에 대해 domain/technical/runbook 문서가 같은 artifact source 에서 파생됨을 확인
- 구현 후 리뷰만이 아니라 PRD/Taxonomy/Design/Tech/Release gate 중 최소 4종 이상 실행

---

## 부록 A. 용어 사전 (Terminology)

- [Placeholder] C-Level, 본부장, Gate, Evaluator, Escalate, Case-α/β, Sprint, PDCA 등 — 풀 작성 단계에서 정의

## 부록 B. v0.3 산출물과의 매핑 테이블

- [Placeholder] v0.3의 각 섹션이 v0.4 어디로 갔는지/폐기됐는지 1:1 매핑 — 풀 작성 단계

## 부록 C. Open Questions

- [ ] Sprint 내 PDCA 병렬 실행 한계와 agent 동시 실행 비용 상한
- [ ] G4 formula (품질/인프라 본부)
- [ ] Escalation 스키마 YAML 확정
- [ ] Observability hook 구체 구현
- [ ] Phase 2 일정 (Phase 1 완주 후 재산정)
- [ ] 본부별 실무자 agent 수와 역할 분담
- [ ] Release Gate 를 G4의 하위로 둘지, 별도 gate 로 둘지
- [ ] Taxonomy freeze 시점: PRD 직후인지, UX draft 직후인지

---

## 부록 D. 2026-04-28 리뷰 반영 메모

상세 리뷰, 수정 이유, Claude agent 반박 예상과 답변은 다음 파일에 기록한다.

- `2026-04-19-sfs-v0.4/appendix/reviews/2026-04-28-startup-team-agent-flow-review.md`

---

## Outline 끝

다음 단계: 이 뼈대 검토 → 승인 후 각 섹션 풀 작성 (예상 분량 3000~4000줄 마크다운)
