---
doc_id: sfs-v0.4-s01-delta-v03-to-v04
title: "§1. v0.3 → v0.4 Delta"
version: 0.4
status: draft
last_updated: 2026-04-19
audience: [v0.3-readers]
required_reading_order: [s00, s01]

depends_on:
  - sfs-v0.4-s00-intro

defines:
  - table/delta-preserved
  - table/delta-reframed
  - table/delta-new
  - table/delta-removed
  - table/v03-v04-mapping

references:
  - concept/elevator-pitch (defined in: s00)
  - concept/company-as-code (defined in: s00)

affects: []

# v0.3 원본 위치 (참조용, 수정 대상 아님)
external_reference: /sessions/peaceful-dazzling-planck/mnt/agent_architect/solo-founder-agent-system-proposal.md
---

# §1. v0.3 → v0.4 Delta

> **Context Recap (자동 생성, 수정 금지)**
> v0.3를 이미 읽은 독자가 **바뀐 부분만 빠르게 파악**하게 한다.
> v0.3 원본은 외부 파일 참조(`solo-founder-agent-system-proposal.md`, 544줄), v0.4는 전면 **재프레이밍**이지 완전 교체가 아님.
> 핵심 변화: **"에이전틱 시스템(기술 중심)" → "회사 전체 운영 시스템(경영 중심)"**.

---

## TOC

- 1.1 유지된 것 (Preserved)
- 1.2 근본 재정의 (Reframed)
- 1.3 신규 도입 (New in v0.4)
- 1.4 폐기 (Removed / Deprecated)
- 1.5 v0.3 → v0.4 1:1 매핑 테이블

---

## 1.1 유지된 것 (Preserved)

v0.3의 **문제의식과 핵심 철학**은 그대로 계승된다.

| v0.3 개념 | v0.4 위치 | 비고 |
|-----------|----------|------|
| 1인 창업가 타겟 (v0.3 §1) | [§0.2](00-intro.md) "7 역할 병목" | 7개 역할로 **더 세분화** |
| 단계가 아니라 역할을 agent로 (v0.3 §2.1) | [§3](03-c-level-matrix.md) 본부 구조 | 본부(Division) 단위로 승격 |
| Sonnet 실행자 + Opus 판단자 쌍 (v0.3 §2.2) | [§3](03-c-level-matrix.md) model allocation | **3-tier로 확장** (Opus/Sonnet/Haiku) |
| Advisor Persona 시스템 (v0.3 §7) | [§3](03-c-level-matrix.md) evaluator pool | 페르소나 → evaluator agent로 승격 |
| Taxonomy = 뿌리 (v0.3 §2.4, §5) | [§3](03-c-level-matrix.md) Taxonomy 본부 | **독립 본부**로 승격 (6개 본부 중 하나) |
| 본인 승인 Gate (v0.3 §2.7) | [§5](05-gate-framework.md) G-series | Gate 체계로 **구조화** (G1~G5) |
| Critic 게이트 (v0.3 §9) | [§5](05-gate-framework.md) evaluator | Gate operator 개념으로 일반화 |
| ADR / 결정 기록 (v0.3 §8.2.4) | [§4](04-pdca-redef.md) PDCA 산출물 | `decisions/` → PDCA analysis/report로 흡수 |
| 3-트랙 문서화 (v0.3 §4.2) | [§8](08-observability.md) L2/L3 | Domain doc → Notion, Tech doc → git |

---

## 1.2 근본 재정의 (Reframed)

**"같은 것을 다른 이름으로"가 아니라, 같은 문제를 바라보는 프레임이 근본적으로 바뀌었다**.

| v0.3 프레임 | v0.4 프레임 | Why |
|-------------|-------------|-----|
| "에이전틱 시스템" (Agentic System) | **"회사 전체 운영 시스템" (Company-as-Code)** | 기술어 → 경영어. 투자자/공동창업자가 이해하는 언어로 |
| 레이어 구조 (Layer 1~4) | **C-Level × N-Division 매트릭스** | 레이어는 "아래가 위를 모른다"는 전제 강함. 회사는 본부가 서로 알아야 함 |
| PM/Designer/Backend… 평탄 agent 리스트 | **6개 본부 (PM/Taxonomy/Design/Dev/QA/Infra) + 3 C-Level** | 평탄 리스트는 역할 중복/누락 구멍 |
| 단방향 파이프라인 [0]~[10] (v0.3 §4) | **Sprint ⊃ PDCA 사이클** | 단방향은 재작업 공식 없음. 실패를 학습으로 전환 불가 |
| "Orchestrator = 본인" (v0.3 §2.5) | **"Orchestrator = 사람 + CLI 상태 + Cowork GUI"** | 본인 혼자 기억 부담 → 시스템이 상태 유지 |
| Advisor verdict (approve/revise/escalate) | **Gate report schema v1 + 7 Failure Modes** | 자연어 verdict → 구조화된 스키마 |
| "본인 승인 게이트" (sparse, 수동) | **G1~G5 Gate Framework** | 지점별 Gate 정의 + operator 명시 |
| Phase 1~6 (각 2주) (v0.3 §10) | **Phase 1 (14~18주) → Phase 2 상품화** | 내부 완주 확인 후 상품화. 무리한 SaaS 조기 진입 회피 |
| 페르소나 = advisor 프롬프트 속성 (v0.3 §7) | **evaluator = 독립 agent** (persona는 metadata) | 페르소나가 실행자와 분리 |
| Critic A/B (Claude vs Gemini) (v0.3 §9) | **evaluator pool 내 model 선택** | A/B 실험은 evaluator agent 간 설정으로 수렴 |

---

## 1.3 신규 도입 (New in v0.4)

v0.3에는 없었거나 단편적 언급 수준이었던 것을 v0.4에서 **정식 구조**로 도입.

| # | 신규 요소 | 정의 위치 | 해결하는 v0.3의 구멍 |
|:-:|-----------|----------|--------------------|
| 1 | **C-Level (CEO/CTO/CPO)** 별도 계층 | [§3](03-c-level-matrix.md) | v0.3의 Orchestrator가 과부하 (상태추적+중재+승인+예산 4역) |
| 2 | **6 본부(Division) 구조** 명시 | [§3](03-c-level-matrix.md) | v0.3 평탄 agent 리스트의 역할 중복/누락 |
| 3 | **G1~G5 Gate Framework** (도메인 agnostic) | [§5](05-gate-framework.md) | v0.3의 Gate가 자연어 조건, 재현 불가 |
| 4 | **7 Failure Modes** enum | [§5](05-gate-framework.md) | Gate 실패를 패턴으로 분류 → 학습 가능 |
| 5 | **Escalate-Plan + AC 부분 재오픈** | [§6](06-escalate-plan.md) | v0.3는 "STOP → 수동 재실행" 만 존재. 부분 재오픈 개념 없음 |
| 6 | **H6 Self-Learning Loop** | [§6](06-escalate-plan.md), [§9](09-differentiation.md) | v0.3 Critic A/B는 로그만 쌓음. 다음 Sprint 자동 반영 X |
| 7 | **3-Channel Observability** (L1 S3 / L2 git SSoT / L3 Notion) | [§8](08-observability.md) | v0.3는 Notion/Git 저장만, 일방향 sync 규칙 없음 |
| 8 | **sfs-plugin 단일 배포** (CLI + Cowork) | [§7](07-plugin-distribution.md) | v0.3는 "CLI 안정화 후 SaaS"만. plugin 패키징 전략 없음 |
| 9 | **divisions.yaml 커스터마이징** | [§7](07-plugin-distribution.md) | v0.3는 본부 추가/제거 확장점 없음 |
| 10 | **frontmatter 의존성 그래프** + `sfs-doc-validate` | [INDEX](INDEX.md), [appendix/tooling](appendix/tooling/sfs-doc-validate.md) | v0.3는 문서 간 참조 자동 검증 없음 |
| 11 | **5-Axis 차별화 지표** (H1/H2/H5/H6) | [§9](09-differentiation.md) | v0.3는 vs bkit/cowork 비교 명시 없음 |
| 12 | **Phase 2 상품화 로드맵** (RBAC/multi-tenant/marketplace) | [§7](07-plugin-distribution.md) | v0.3는 "Phase 6: SaaS화" 한 줄 |

---

## 1.4 폐기 (Removed / Deprecated)

v0.4에서 **명시적으로 제거**했거나 다른 개념으로 **흡수**된 것.

| v0.3 요소 | v0.4 처리 | 이유 |
|-----------|----------|------|
| "Layer 1~4" 프레임 (v0.3 §3.1) | **폐기** | 본부 매트릭스로 대체 |
| 파이프라인 단계 번호 [0]~[10] (v0.3 §4.1) | **흡수** → PDCA 사이클 | 번호 대신 PDCA phase로 |
| Ideator agent (v0.3 §8.1) | **흡수** → PM 본부 | 독립 agent 불필요, PM Plan 단계 일부 |
| Legal agent (v0.3 §8.1) | **Phase 2 이관** | Phase 1 solo dogfooding에 법무 필수 아님 |
| Tech Writer agent (v0.3 §8.1) | **흡수** → 모든 본부의 PDCA report | 독립 agent 대신 각 본부가 자기 Report 작성 |
| Critic A/B (Claude vs Gemini 비교) (v0.3 §9) | **폐기 또는 Phase 2** | Phase 1은 Claude 단일. 비용/복잡도 대비 가치 불명 |
| "advisor_budget" 예산 예시 (v0.3 §6.3) | **폐기** | Observability L1 log-event로 사후 측정 |
| `agent` CLI 명령어 세트 (v0.3 §6.4) | **흡수** → Claude Code slash commands | `/pdca`, `/sprint`, `/escalate` 등 |
| Open Questions Q1~Q7 (v0.3 §11) | **해소됨** | Q1~Q3은 v0.4에서 결정, Q4~Q7은 Phase 2로 |
| "Phase 1~6 각 2주" (v0.3 §10) | **재산정** | Phase 1 단독 14~18주로 재산정 (§10) |

### 폐기된 "Critic A/B"에 대한 보충

v0.3 §9의 Critic A/B (Claude vs Gemini) 실험은 **아이디어 자체는 좋지만 Phase 1의 스코프가 아니다**:
- Gemini/Codex 연동 = 추가 MCP 설정 부담
- 비교 지표(우위 단계 분리) = 한 달 누적 필요 → Phase 2
- evaluator pool 안에서 **model 필드로 설정 가능**하게 열어둠 (§3.4)

즉 "폐기"가 아니라 "지연". evaluator schema에 `model: sonnet-4-6 | gemini-2-5 | codex-...` 필드 존재.

---

## 1.5 v0.3 → v0.4 1:1 매핑 테이블

v0.3 14개 섹션(§0~§14) 각각이 v0.4에서 어디로 갔는지.

| v0.3 | v0.3 섹션 제목 | 처리 | v0.4 위치 |
|------|-------------|------|----------|
| §0 | Elevator Pitch | **reframed** | [§0.1](00-intro.md) (Company-as-Code 프레임) |
| §1 | Problem | **expanded** | [§0.2](00-intro.md) (7-Role Bottleneck) |
| §2.1~2.7 | Design Principles (7개) | **reframed + expanded** | [§2](02-design-principles.md) (8개 원칙, 재구성) |
| §3.1 | Layer 구조 | **폐기** | — |
| §3.2 | Build Order | **reframed** | [§10](10-phase1-implementation.md) (Phase 1 breakdown) |
| §4.1 | 파이프라인 단계 | **reframed** | [§4](04-pdca-redef.md) (Sprint ⊃ PDCA) |
| §4.2 | 3-트랙 문서화 | **reframed** | [§8](08-observability.md) (L2/L3 채널) |
| §5 | Taxonomy 관리 | **reframed** | [§3](03-c-level-matrix.md) (Taxonomy 본부) |
| §6 | Orchestrator | **reframed** | [§3](03-c-level-matrix.md) (C-Level + CLI 공유) |
| §7 | Advisor Persona | **reframed** | [§3](03-c-level-matrix.md) (evaluator pool) |
| §8.1 | 에이전트 구성표 | **reframed** | [§3](03-c-level-matrix.md) (본부 × role 매트릭스) |
| §8.2 | Backend Agent 상세 | **기반으로 흡수** | [§3](03-c-level-matrix.md) Dev 본부 + [§4](04-pdca-redef.md) PDCA 산출물 |
| §8.2.3 | Advisor verdict JSON | **reframed** | [§5](05-gate-framework.md) `schema/gate-report-v1` |
| §8.2.4 | ADR 형식 | **reframed** | [§4](04-pdca-redef.md) PDCA analysis/report |
| §8.3 | 나머지 에이전트 복제 | **흡수** | [§3](03-c-level-matrix.md) 본부별 role 매트릭스 |
| §9 | Critic A/B | **Phase 2로 이관** | [§3](03-c-level-matrix.md) evaluator.model 필드 |
| §10 | MVP 우선순위 | **재산정** | [§10](10-phase1-implementation.md) |
| §11 | Open Questions | **부분 해소 / 이관** | §11 전체 ↓ 아래 세부 |
| §12 | Risks | **reframed** | [§10.4](10-phase1-implementation.md) Phase 1 Risk |
| §13 | Next Actions | **구체화** | [§10](10-phase1-implementation.md) breakdown |
| §14 | Glossary | **흡수** | frontmatter `defines` 필드 + INDEX Cross-Reference Matrix |

### v0.3 §11 Open Questions 개별 처리

| Q | v0.3 질문 | v0.4 처리 |
|:-:|---------|---------|
| Q1 | agent 통신: 파일 vs 메시지 버스 | **해소**: 파일 (L2 docs submodule) — [§8](08-observability.md) |
| Q2 | Git 모노레포 vs Git+Notion 하이브리드 | **해소**: Git SSoT + Notion view — [§8](08-observability.md) |
| Q3 | 배포 자동화 수준 | **Phase 2 이관** — [§7.6](07-plugin-distribution.md) |
| Q4 | Pack 경계 (도메인별 페르소나 세트) | **reframed** → `divisions.yaml` 커스터마이징 — [§7.3](07-plugin-distribution.md) |
| Q5 | 페르소나 마켓플레이스 | **Phase 2 이관** — [§7.6](07-plugin-distribution.md) |
| Q6 | 역류 메커니즘 자동화 시점 | **해소**: Escalate-Plan으로 역류 구조화 — [§6](06-escalate-plan.md) |
| Q7 | Advisor 호출 예산 초과 | **해소**: Observability L1 log로 측정, hard budget Phase 2 — [§8](08-observability.md) |

---

*(끝)*
