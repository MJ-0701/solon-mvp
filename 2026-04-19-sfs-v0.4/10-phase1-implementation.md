---
doc_id: sfs-v0.4-s10-phase1-implementation
title: "§10. Phase 1 구현 계획 (15~19주, tier=minimal 기본 + brownfield optional)"
version: 0.4-r2
status: draft
last_updated: 2026-04-20
audience: [implementers, project-managers, c-level-self]
required_reading_order: [s00, s02, s03, s04, s05, s06, s07, s08, s09, s10]

depends_on:
  - sfs-v0.4-s02-design-principles
  - sfs-v0.4-s03-c-level-matrix
  - sfs-v0.4-s04-pdca-redef
  - sfs-v0.4-s05-gate-framework
  - sfs-v0.4-s06-escalate-plan
  - sfs-v0.4-s08-observability
  - sfs-v0.4-s07-plugin-distribution
  - sfs-v0.4-s09-differentiation

defines:
  - plan/phase1-scope-final
  - schedule/phase1-week-breakdown
  - rule/reuse-from-bkit
  - rule/reuse-from-cowork-inspired-rewrite
  - rule/tier-based-budget
  - criteria/phase1-success
  - criteria/brownfield-dogfooding-optional
  - concept/dogfooding-target
  - concept/phase1-seed-patterns
  - gate/phase1-to-phase2-transition
  - rule/cli-first-tool-selection
  - rule/mcp-justification-required

references:
  - division/* (defined in: s03)
  - rule/model-allocation-concrete (defined in: s03)
  - concept/sfs-plugin (defined in: s07)
  - concept/tier-profile (defined in: s07)
  - concept/l3-backend (defined in: s07)
  - mode/greenfield (defined in: s07)
  - mode/brownfield (defined in: s07)
  - phase/p-1-discovery (defined in: s04)
  - concept/g-1-intake-gate (defined in: s05)
  - evaluator/discovery-report-validator (defined in: s05)
  - skill/sfs-discover (defined in: appendix/commands/discover.md)
  - principle/brownfield-first-pass (defined in: s02)
  - principle/human-final-filter (defined in: s02)
  - axis/h1-observability (defined in: s09)
  - axis/h2-role-scope (defined in: s09)
  - axis/h5-c-level-strategic-layer (defined in: s09)
  - axis/h6-self-learning (defined in: s09)
  - phase/phase2-roadmap (defined in: s07)
  - schema/gate-report-v1 (defined in: s05)
  - schema/escalation-v1 (defined in: s06)
  - channel/l1-s3 (defined in: s08)
  - channel/l2-git-docs-submodule (defined in: s08)
  - channel/l3-human-view (defined in: s08)
  - concept/h6-self-learning (defined in: s06)

affects: []  # 최종 섹션, 다운스트림 없음
---

# §10. Phase 1 구현 계획 (15~19주, tier=minimal 기본 + brownfield optional)

> **Context Recap (자동 생성, 수정 금지)**
> §2~§9의 설계를 실제로 구현하는 15~19주 계획 (v0.4-r1의 14~18주에서 brownfield 지원 +1주).
> Dogfooding 대상: `product-image-studio` (greenfield) + optional brownfield dogfooding 1건.
> Phase 1 성공 기준: 6 본부 모두 1회 PDCA + G1~G5 모두 1회 + Escalate 1회 + 3-Channel 데이터 보유.
>
> **v0.4-r2 변경**:
> 1. Budget/Risk를 **tier_profile 기반**으로 재계산 (minimal / standard / collab). Phase 1은 **minimal** 기본.
> 2. **Brownfield dogfooding이 optional 성공 기준**으로 추가됨 (P-1 + G-1 end-to-end 1회).
> 3. 신규 Evaluator 1개 추가 (`discovery-report-validator`) + 신규 Skill 1개 추가 (`/sfs discover`) → 8 Evaluator + 5 Skill.

---

## TOC

- 10.1 Phase 1 전체 범위 (In-Scope / Out-of-Scope / Install Mode 범위)
- 10.2 신규 개발 항목 (8 Evaluator + 3 C-Level + 6 Lead + 5 Skill + 기타)
- 10.3 재활용 항목 (bkit 직접 / cowork Inspired-Rewrite / Claude Code 기본)
- 10.4 15~19주 주차 breakdown (Foundation → Dogfooding + optional Brownfield)
- 10.5 Phase 1 성공 기준 (필수 + 측정 가능 + brownfield optional)
- 10.6 Dogfooding: product-image-studio (greenfield) + optional Brownfield 대상
- 10.7 Risk & Mitigation (8 Risk × Impact/Likelihood/Mitigation, R9·R10 brownfield 추가)
- 10.8 H6 Seed Patterns (5개 사전 정의 패턴)
- 10.9 Phase 1 → Phase 2 Transition Gate
- 10.10 예산 & 리소스 요약 (tier-profile × mode 기반)
- 10.11 🆕 CLI-First Tool Selection Policy (v0.4-r3)

---

## 10.1 Phase 1 전체 범위

### 10.1.1 Phase 1의 존재 이유

Phase 1은 **"Solon이 실제로 작동하는가?"** 를 자기 자신으로 증명하는 단계다.
기술 완성도보다 **dogfooding 증거**가 목적이다.

> 만약 Phase 1 종료 시점에 `product-image-studio` 프로젝트에
> Solon로 만들어진 Sprint Report + Gate Report + Escalation 1건 이상이 L2/L3에 남아있지 않다면,
> Phase 1은 실패한 것으로 간주한다. (§10.5 성공 기준 참조)

### 10.1.2 In-Scope

| 항목 | 범위 | 비고 |
|------|------|------|
| **본부 (Division)** | 6개 (strategy-pm / taxonomy / design / dev / qa / infra) | §3.3 Matrix 기준 |
| **C-Level** | 3개 (CEO / CTO / CPO) | Opus 할당, §3.2 |
| **Install Mode** | `greenfield` (default, P0) + `brownfield` (optional, P0) | §7.4 |
| **Phase** | P-1 Discovery (brownfield only) + Plan/Design/Do/Check/Act | §4.3 |
| **Gate** | G-1 Intake (brownfield only) + G1~G5 모두 구현 | §5.2 Gate Matrix |
| **Failure Mode** | 7개 모두 감지 + Mode × Gate Matrix 적용 (G-1 포함) | §5.7, §5.8 |
| **Escalate-Plan** | Case-α (α-1 only) + Case-β (β-3 only) | §6.3, §6.4 |
| **CONFLICT 5-Option Protocol** | 구현 | §6.5 |
| **H6 Self-Learning** | 1회 이상 실제 작동 증명 | §6.7 |
| **3-Channel Observability** | L1 S3 + L2 git-submodule + L3 Human View (notion driver default) | §8.3 |
| **Tier Profile** | `minimal` 기본 구현 + `standard`·`collab` schema 정의만 | §7.4 |
| **L3 Backend Driver** | `notion` (default) + `none` (no-op) 두 가지 구현; `obsidian`·`logseq`·`confluence`·`custom` schema만 | §8.4 |
| **solon-plugin** | 단일 플러그인 (namespace `sfs`), CLI + Cowork 공유 FS | §7.2, §7.6 |
| **Dogfooding** | product-image-studio에 최소 1 Sprint 완주 (greenfield) | §10.6 |
| **Brownfield Dogfooding** | optional, legacy repo 1건에 `/sfs install --mode brownfield` end-to-end | §10.6.5 |

### 10.1.3 Out-of-Scope (Phase 2 이후)

| 항목 | 제외 이유 | 대상 Phase |
|------|----------|------------|
| **RBAC / 다중 사용자** | 솔로 사용자 전제 | Phase 3+ |
| **실시간 협업 (Live Share)** | 솔로 전제 | Phase 3+ |
| **자동 PR 승인 / 머지** | 위험 대비 효익 낮음 | 검토 보류 |
| **Playwright 자동 QA** | 비용/공수 대비 단일 Sprint에서 검증 어려움 | Phase 2 |
| **Cost Estimator 정밀화** | 보수적 상수값으로 Phase 1은 충분 | Phase 2 |
| **브랜드 가이드라인 자동 추출** | 수작업 YAML로 시작 | Phase 2 |
| **α-2 / α-3 (부분 재설계 / 전면 재설계)** | α-1 + β-3 조합으로 Phase 1 커버 가능 | Phase 2 |
| **divisions.yaml 동적 추가 UI** | 수동 YAML 편집으로 Phase 1 커버 | Phase 2 |
| **L3 driver: obsidian / logseq / confluence / custom 구현** | schema만 정의하고 driver 자체는 Phase 2+에서 구현 | Phase 2 |
| **Tier standard / collab 의 실제 차등 모델 할당** | Phase 1은 `minimal` 기본, standard·collab은 schema 수준 | Phase 2 |
| **Brownfield Incremental Discovery** (repo 변경 시 자동 재-P-1) | 1회성 `rule/p-1-run-once-per-install` 만 지원 | Phase 2 |
| **Brownfield coexistence 자동 migration** (`.solon-manifest.yaml` migrate 액션) | keep/coexist/archive 만 Phase 1 지원, migrate/supersede 액션은 Phase 2 | Phase 2 |

**원칙**: Phase 1은 **"폭"보다 "깊이"**. 최소 기능으로 6 본부 × 5 Gate × H6 루프가 **end-to-end** 한 번 도는 것을 우선한다. Brownfield 지원은 **"동작 증명"** 수준 (end-to-end P-1 + G-1 1회) 만으로 P0에 포함한다.

### 10.1.4 Install Mode 범위

| Mode | Phase 1 우선순위 | 의존 Phase | 의존 Gate | 의존 Skill | 검증 지표 |
|------|:----------------:|-----------|-----------|-----------|----------|
| `greenfield` (default) | **P0 (must-ship)** | Plan/Design/Do/Check/Act | G1~G5 | `/sfs install`, `/sfs brainstorm`, `/sfs plan`, ... | §10.5.1 조건 1~5 |
| `brownfield` | **P0 (must-ship)** — optional 검증 | P-1 + Plan/Design/Do/Check/Act | G-1 + G1~G5 | 위 + `/sfs discover` | §10.5.1 조건 1~5 + §10.5.1-b |

> **"P0 — optional 검증"의 의미**: brownfield 구현(code path, /sfs discover, G-1, discovery-report-validator)은 P0으로 반드시 출하하되, **dogfooding 증명은 optional**. Phase 1 종료 시 brownfield dogfooding 1건이 없어도 greenfield 조건 5개가 모두 통과하면 Phase 1 성공으로 간주한다 (§10.5.1-b 참조).

---

## 10.2 신규 개발 항목

### 10.2.1 개발 항목 요약

| 카테고리 | 항목 | 수량 | 예상 공수 (주) | 담당 모델 |
|---------|------|:----:|:------------:|---------|
| C-Level agents | CEO / CTO / CPO | 3 | 1.0 | Opus |
| 본부장 agents (Lead) — **Phase 1 active 2개만 Sprint 0 로딩, 4개는 abstract** 🆕 R3 | strategy-pm-lead / dev-lead (active) + taxonomy-lead / design-lead / qa-lead / infra-lead (abstract, activation 시 로딩) | 6 (active 2 + abstract 4) | 1.5 (active 1.0 + abstract 0.5 spec-only) | Opus or Sonnet (§3.5) |
| 신규 Evaluator (Tier 2 - 외부) | plan-validator / prd-lock / user-flow-validator / cost-estimator / taxonomy-consistency-checker / taxonomy-draft-evaluator / sprint-retro-analyzer / **discovery-report-validator** | 8 | 4.0 | Opus (7) + Sonnet (1: discovery-report-validator, §5.11.2 원칙 11) |
| cowork 재작성 Evaluator | design-critique-rewrite / accessibility-review-rewrite / design-handoff-rewrite (design 본부 abstract 상태일 땐 로딩 생략, activate 시점에 로딩) 🆕 R3 | 3 | 2.0 | Opus |
| Operation skills | sfs-pdca (통합) / sfs-gates / sfs-escalate / sfs-retro / sfs-discover (brownfield only) / **sfs-division** 🆕 R3 (user-only, INV-5) | 6 | 4.0 | N/A (skill) |
| **원칙 13 엔진 (v0.4-r3)** 🆕 R3 | **dialog-engine** (Socratic 5-phase state machine, `dialog-state.schema.yaml` 준수) + **alternative-suggestion-engine** (3-tier × 3-level intensity, ALT-INV-1~3 enforcement) | 2 | 2.0 | Sonnet (worker 구현) |
| Observability pipeline | PostToolUse hook + Stop hook + post-commit hook + L3 sync worker (driver-aware) + **`division.activation.changed` L1 event handler** 🆕 R3 | 1 셋 | 2.0 | N/A (TS) |
| Brownfield 지원 도구 | `.solon-manifest.yaml` 스키마 + coexistence 처리 로직 (keep/coexist/archive 3 액션) | 1 | 0.5 | N/A (TS) |
| 도구 | sfs-doc-validate (frontmatter DAG 검증 + solon-manifest 검증 + **activation-state invariant 검증** 🆕 R3) | 1 | 1.0 | N/A (Python) |
| **합계** | | **30** | **18.0** | |

> **공수 18.0주는 "순차 가정" 최소값** (v0.4-r2의 15.5 → +2.0주 원칙 13 엔진 2종 신규 + +0.5주 `/sfs division` command). 10.4 주차별 breakdown에서 병렬화로 일부 단축, Dogfooding/안정화 버퍼 포함하면 최종 **16~20주** (이전 15~19주 → +1주).
>
> 🆕 v0.4-r3 activation-aware 공수 최적화: abstract 본부 4개는 Sprint 0 로딩 생략 → Phase 1 1~4주 차에 로딩 공수 -1.5주 절감. 즉 **"`activation_state = abstract` 덕분에 Phase 1 초기 부하가 낮아진다"** 가 설계 의도. 후반 activate 시 각 본부 로딩은 각 Sprint 내에 흡수.

### 10.2.2 8 Evaluator 상세

Evaluator 8개 중 7개는 Tier 2 외부 Evaluator (§2 원칙 5: 외부자 검증) 로서 **Opus** 를 사용한다. 1개 (`discovery-report-validator`) 만 **Sonnet** — brownfield P-1 cost cap (§2 원칙 11) 로 인한 예외.

| # | Evaluator | 담당 Gate | 담당 본부 / mode | 모델 | 핵심 기능 |
|:-:|-----------|-----------|----------------|------|----------|
| 1 | **plan-validator** | G1 Plan Gate | strategy-pm | Opus | PRD 체크리스트 검증, AC 명세 충분성 평가, 5-Axis CPO 평가 입력 제공 |
| 2 | **prd-lock** | G1→G2 전이 | strategy-pm | Opus | PRD 잠금 상태 확인, AC 메타데이터에 status: locked 기록 (§6.3.3) |
| 3 | **user-flow-validator** | G2 Design Gate | design | Opus | 사용자 플로우의 완결성, 엣지 케이스 커버리지, 접근성 접점 점검 |
| 4 | **cost-estimator** | G2 Design Gate (Infra 본부) | infra | Opus | AWS / Vercel / Gemini API 월 비용 추정, Phase 1은 보수적 상수값 기반 |
| 5 | **taxonomy-consistency-checker** | G2/G4 (Taxonomy 본부) | taxonomy | Opus | divisions.yaml + 본부별 용어 사전의 일관성 검사, 용어 충돌 탐지 |
| 6 | **taxonomy-draft-evaluator** | G2 Design Gate (Taxonomy 본부) | taxonomy | Opus | 신규 용어 초안 평가, 기존 용어와의 의미 중복 탐지 |
| 7 | **sprint-retro-analyzer** | G5 Sprint-Retro Gate | (cross-division) | Opus | Sprint 종료 시 H6 학습 패턴 추출, learnings-v1.md 생성 (§6.7.2) |
| 8 🆕 | **discovery-report-validator** | **G-1 Intake Gate** | **brownfield only** | **Sonnet** | P-1 Discovery 산출물 (discovery-report.md + evidence/*.yaml + inventory/*.json) 의 7축 검증 (structural completeness / evidence binding ≥80 / metric availability ≥80 / duplication / migration path / principle-9 / signature). 상세: §5.11.2 |

> **왜 discovery-report-validator만 Sonnet인가**: §2 원칙 11 (brownfield-first-pass cost cap, <$15 for medium repo) 에 따라 P-1 + G-1 전체 비용을 제한한다. 7축 검증은 정형화된 schema 매칭 중심이므로 Sonnet으로 충분. Opus 사용은 `rule/p-1-opus-forbidden` 위반.

### 10.2.3 3 C-Level Agent 상세

| Agent | 모델 | 역할 | 주요 호출 시점 |
|-------|------|------|--------------|
| **ceo-agent** | Opus | Sprint Plan 승인 / β-3 Escalate 의사결정 / 5-Axis Value-Fit 평가 | Sprint 시작 / Escalate 중 / G4 일부 |
| **cto-agent** | Opus | 기술 아키텍처 의사결정 / CONFLICT 5-Option 선택 / 5-Axis Soundness·Future-Proof 평가 | 본부장 간 충돌 / G4 일부 |
| **cpo-agent** | Opus | 5-Axis 주 evaluator / User-Outcome 판단 / Design Gate G2 최종 통과 승인 | G2 / G4 (Design 본부) |

### 10.2.4 6 Lead Agent 상세

본부장 = **Gate Operator (계약 발급자)**, **자기 본부의 평가자는 될 수 없음** (§2 원칙 5).
본부장은 **호출 전후 위임만** 하며, Tier 2 Evaluator를 반드시 외부에서 호출한다.

| Lead | 본부 | 모델 | 주요 책임 |
|------|------|------|----------|
| strategy-pm-lead | strategy-pm | Opus | PRD 작성 위임, plan-validator 호출, Case-β 진입 판단 |
| taxonomy-lead | taxonomy | Sonnet (초기), Opus (용어 충돌 시) | 용어 사전 관리, 본부 간 번역 담당 |
| design-lead | design | Opus (Cowork 통합 지점) | UI/UX Design 산출물 위임, user-flow-validator + cowork 재작성 evaluator 호출 |
| dev-lead | dev | Sonnet | 코드 구현 위임, gap-detector + code-analyzer 호출 |
| qa-lead | qa | Sonnet | 테스트 위임, qa-monitor 호출, defect leak 추적 |
| infra-lead | infra | Sonnet | 배포/인프라 위임, cost-estimator + infra-architect 호출 |

### 10.2.5 5 Operation Skill

| Skill | 역할 | 트리거 | 적용 mode |
|-------|------|--------|:---------:|
| **sfs-discover** 🆕 | P-1 Discovery Phase 실행 (3-pass: Haiku inventory → Sonnet evidence → Sonnet discovery-report draft). `.solon-manifest.yaml` 생성. 결과는 G-1 평가 대상. 상세: `appendix/commands/discover.md` | `/sfs install --mode brownfield` 직후 자동 호출 (1회성, `rule/p-1-run-once-per-install`) | brownfield only |
| **sfs-pdca** | Plan → Design → Do → Check → Act 5 phase 관리 (통합 skill) | `/sfs-pdca plan`, `/sfs-pdca design` 등 서브커맨드 | 공통 |
| **sfs-gates** | G-1 (brownfield) + G1~G5 Gate 실행, GateReport 생성, Failure Mode 분기 | `/sfs-gate g-1 <install-id>`, `/sfs-gate g1 <feature>` | 공통 |
| **sfs-escalate** | Case-α / β 분기, Escalate-Plan 생성, CONFLICT 5-Option 진행 | FAIL-HARD / CONFLICT / TIMEOUT 감지 시 자동 | 공통 |
| **sfs-retro** | Sprint 종료 시 G5 실행, sprint-retro-analyzer 호출, H6 패턴 저장. 단, brownfield 첫 Sprint는 P-1 산출물을 Sprint 0 pseudo-learnings으로 seeded (§2 원칙 12) | Sprint 종료 트리거 | 공통 |

> **sfs-discover 의 read-only 강제**: skill frontmatter의 `tool_restrictions.forbidden = [Write, Edit, NotebookEdit]` 로 보장. 단 Pass 3의 `discovery-report.md` 및 `.solon-manifest.yaml`·`.g-1-signature.yaml` 최초 생성만 whitelisted (§2 원칙 11 `rule/brownfield-discovery-read-only`).

---

## 10.3 재활용 항목

### 10.3.1 재활용 전략 3분법

| 전략 | 대상 | 원칙 |
|------|------|------|
| **Direct Reuse (그대로)** | bkit 플러그인 | sfs-plugin이 bkit의 agent를 직접 호출. 소스 복사 X, 참조만. |
| **Inspired-Rewrite (참조 후 독립 재작성)** | cowork plugin의 일부 skill | 아이디어는 참조하되 **코드는 Solon 내부 스타일로 새로 작성**. (§7.8) |
| **Platform Native (Claude Code/Desktop 기본)** | Task 도구 / Skill 시스템 / hooks | 플랫폼 제공 기능 그대로 사용 |

### 10.3.2 bkit 직접 재활용 (Direct Reuse)

bkit은 개발 본부를 중심으로 이미 성숙한 Evaluator/Agent를 가지고 있다. 그대로 호출한다.

| bkit asset | Solon 내 역할 | 담당 Gate / 본부 |
|-----------|--------------|-----------------|
| `gap-detector` | 설계-구현 갭 분석 | Dev 본부 G4 (기준값 Gap≥90) |
| `code-analyzer` | 코드 품질 정적 분석 | Dev 본부 G3 Pre-Handoff |
| `design-validator` | 설계 문서 완결성 | Design 본부 G2 (단, UX/브랜드 판단은 별도) |
| `qa-monitor` | 로그 기반 QA 감시 | QA 본부 G3/G4 |
| `infra-architect` | 인프라 구조 평가 | Infra 본부 G2/G3 |
| `report-generator` | PDCA 완료 보고서 | Act phase 보조, G5 입력 |

**재활용 시 주의**: bkit agent의 스코어 임계치는 Solon Gate 기준 (§5.5 G4 formula) 에 맞춰 매핑한다. 즉, bkit에서 Gap 90% = Pass지만, Solon Dev G4에서는 `Gap × 0.4 + 5-Axis × 0.6` 조합 중 Gap 성분만 담당한다.

### 10.3.3 cowork 재작성 (Inspired-Rewrite)

cowork plugin의 3개 skill만 Solon Design 본부로 재작성한다. **직접 의존성 금지** (§7.8 원칙).

| cowork skill (참조) | Solon 대응 Evaluator | 재작성 이유 |
|-------------------|-------------------|-------------|
| `design-critique` | `design-critique-rewrite` (Solon Design Evaluator) | cowork는 대화형 피드백 중심. Solon은 **Gate Report YAML** 로 구조화된 점수 출력이 필요. |
| `accessibility-review` | `accessibility-review-rewrite` | cowork는 WCAG AA 체크리스트 중심. Solon은 **Tier 2 외부 평가자**로서 Gate G4 점수 기여가 필요. |
| `design-handoff` | `design-handoff-rewrite` | cowork는 dev 팀 핸드오프 스펙 생성. Solon은 **Design → Dev 본부 핸드오프**로 변환, Gate G3 Pre-Handoff에서 소비. |

**NIH (Not Invented Here) 방지 원칙**:
1. 참조 대상은 **3 skill로 한정** (범위 고정).
2. 재작성 시 원본 출처를 `sfs-agents/design/*/README.md`에 명시 (지적 정직성).
3. 재작성 vs 직접 의존성 선택 근거는 §7.8에 기록되어 있으며 본 Phase 1에서 변경하지 않는다.

### 10.3.4 Claude Code / Desktop 플랫폼 기본 기능

| 플랫폼 기능 | Solon 활용 |
|------------|---------|
| Task 도구 (Subagent 호출) | Lead → Worker / Lead → Evaluator 호출 |
| Skill 시스템 | 4 Operation Skill (§10.2.5) + sfs-plugin |
| Hooks (PostToolUse / Stop / SessionStart) | §8.5 observability trigger |
| AskUserQuestion | CONFLICT Option-E (Escalate-Plan) 사용자 개입 |
| TodoWrite / TaskCreate | Sprint 내 task 상태 추적 |
| git plumbing | L2 submodule post-commit hook |
| `.claude/plugins/` + `~/.claude-desktop/plugins/` symlink | CLI ↔ Cowork 공유 FS (§7.6) |

---

## 10.4 16~20주 주차 breakdown 🆕 v0.4-r3 (원칙 13 엔진 2종 + `/sfs division` 반영)

### 10.4.1 주차별 로드맵

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Phase 0 │ Foundation │ P13 Eng │ Evaluators │ Skills │ Obs │ Pkg │ Integ │ Dog(GF) │ Dog(BF opt) │
│  (준비)  │            │ 🆕 R3  │            │        │     │     │       │         │             │
│  W0     │ W1-2       │ W2b    │ W3-7       │ W8-10  │W11-12│W13 │W14-15 │ W16-18  │ W19-20 (opt)│
│         │ (active 2  │ dialog │ (+disc-    │(+sfs-  │      │    │       │         │             │
│         │  only)     │ +alt-  │ validator  │discover│      │    │       │         │             │
│         │            │ engine │ at W5)     │ +sfs-  │      │    │       │         │             │
│         │            │        │            │division│      │    │       │         │             │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
```

> **변경 요약 (v0.4-r3 vs v0.4-r2)**:
> - W2b (Foundation 내부 증설): **dialog-engine + alternative-suggestion-engine 2 개 task 신설** (Sonnet worker, 각 1 주). §10.2.1 "원칙 13 엔진" 행에 대응.
> - W10 에 **sfs-division skill 추가** (sfs-discover / sfs-escalate 와 병렬 — `/sfs division` 이 엔진 호출만 하면 됨).
> - W1-W2 abstract 본부 4개 (qa/design/infra/taxonomy) 는 spec 파일만 커밋 — active 2 (dev + strategy-pm) 만 Sprint 0 로딩.
> - W15 Integration Test-2 에 **원칙 13 invariant 검증** 추가: `sfs-doc-validate` 의 activation-state invariant 체크 (ALT-INV-1~3 / INV-5).
> - 총 15~19주 → **16~20주** (+1 주, 병렬화로 현실 예상 17→18주).
>
> **변경 요약 (v0.4-r2 vs v0.4-r1)**: W5에 `discovery-report-validator` 추가, W10에 `sfs-discover` 추가, W13에 `.solon-manifest.yaml` 스키마 추가, W19에 optional brownfield dogfooding 신규.

### 10.4.2 주차별 상세

| 주차 | Phase | 주요 산출물 | Deliverable (L2 경로) | Gate 검증 |
|:----:|-------|------------|----------------------|-----------|
| **W0** | 준비 | 개발 환경 (Claude Code CLI + Cowork 설치 확인, git 저장소 init) | `sfs-plugin/` git repo | — |
| **W1** | Foundation-1 | C-Level 3 agent 정의 (prompt + config) | `sfs-plugin/agents/c-level/*.md` | self-review |
| **W2** | Foundation-2 | **active 2 본부장** (strategy-pm-lead, dev-lead) 정의 + **abstract 4 본부장** spec-only (qa/design/infra/taxonomy) + divisions.yaml 초안 (v1.1, activation_state 필드) 🆕 R3 | `sfs-plugin/agents/leads/*.md`, `divisions.yaml` | schema validate (v1.1, activation_state) |
| **W2b** 🆕 R3 | Foundation-3 원칙 13 엔진 | **dialog-engine** 구현 (Socratic 5-phase A~E state machine, `dialog-state.schema.yaml` v1 준수, `dialog_trace_id` 생성 + L1 event emit) **+ alternative-suggestion-engine** 구현 (3-tier × 3-level intensity, ALT-INV-1~3 enforce, **특히 ALT-INV-3 never-hard-block**) | `solon-plugin/src/engines/dialog-engine.ts`, `solon-plugin/src/engines/alternative-suggestion-engine.ts`, unit tests | invariant unit test: ALT-INV-1 (3 tiers) / ALT-INV-2 (exactly one 👍) / ALT-INV-3 (no hard-block path) / INV-5 (`/sfs division` user-only) 자동 검증 |
| **W3** | Evaluators-신규-1 | plan-validator / prd-lock 개발 | `solon-plugin/agents/evaluators/plan-*.md` | mock 시나리오 |
| **W4** | Evaluators-신규-2 | user-flow-validator / cost-estimator | 동 | mock 시나리오 |
| **W5** | Evaluators-신규-3 | taxonomy-consistency-checker / taxonomy-draft-evaluator / sprint-retro-analyzer / **discovery-report-validator** 🆕 | 동 + `evaluators/discovery-report-validator.md` | mock 시나리오 (brownfield mock repo 포함) |
| **W6** | Evaluators-재작성-1 | design-critique-rewrite / accessibility-review-rewrite | `solon-plugin/agents/evaluators/design-*.md` | 참조 cowork skill과 diff |
| **W7** | Evaluators-재작성-2 | design-handoff-rewrite + Phase 1 seed pattern 5개 정의 (§10.8) | 동 + `seed-patterns/*.yaml` | 검토 |
| **W8** | Skills-1 | sfs-pdca (통합 skill) + 4 PDCA 템플릿 링크 (§Appendix) | `solon-plugin/skills/sfs-pdca/` | self-test |
| **W9** | Skills-2 | sfs-gates (**G-1** + G1~G5 구현) + GateReport schema 연결 (§5.4) + `.g-1-signature.yaml` schema | `solon-plugin/skills/sfs-gates/` | mock Gate 실행 (G-1 포함) |
| **W10** | Skills-3 | sfs-escalate (Case α/β + CONFLICT 5-Option) + sfs-retro (G5) + sfs-discover (3-pass pipeline, tool_restrictions 강제) + **sfs-division** 🆕 R3 (user-only, INV-5, dialog-engine + alternative-suggestion-engine 호출, `divisions.yaml` 갱신, L1 event `division.activation.changed`) | `solon-plugin/skills/sfs-escalate/`, `sfs-retro/`, `sfs-discover/`, `sfs-division/` | mock escalate + mock discovery run + mock division activate (abstract → active 플로우 완주) |
| **W11** | Observability-1 | L1 S3 구현 + PostToolUse/Stop hook (§8.5) | `solon-plugin/hooks/observability-sync.ts` | S3 bucket log 확인 |
| **W12** | Observability-2 | L2 git-submodule + post-commit hook + L3 driver-aware sync worker (`notion` + `none`) | 동 + L3 대시보드 | 3-Channel 데이터 흐름 E2E |
| **W13** | Plugin Packaging | solon-plugin 빌드 + `/sfs install` (CLI, greenfield+brownfield modes) + `plugin.json` + **`.solon-manifest.yaml` 스키마 & coexistence 처리 로직 (keep/coexist/archive)** 🆕 | `solon-plugin/install.sh`, `plugin.json`, `solon-manifest.schema.yaml` | `claude plugin install solon` 동작 (두 mode 모두) |
| **W14** | Integration Test-1 | Mock 시나리오로 6 본부 × PDCA 1회 통합 실행 (greenfield) | `tests/integration/greenfield/*.yaml` | G1~G5 전부 통과 |
| **W15** | Integration Test-2 / 안정화 | Mock brownfield repo로 P-1 → G-1 → Plan 통합 실행, sfs-doc-validate로 frontmatter 검증 | `tests/integration/brownfield/*.yaml`, bug fix commits | G-1 mock 통과 + sfs-doc-validate pass |
| **W16** | Dogfooding-GF-1 | product-image-studio에 `claude plugin install solon && /sfs install` (greenfield), 첫 Sprint Plan 작성 | `product-image-studio/docs/sprints/2026-*/` | G1 통과 |
| **W17** | Dogfooding-GF-2 | Sprint 실행 (Design → Dev → QA 본부 작동), Escalate 1회 트리거 시도 | Sprint 산출물 + Escalation | G1~G5 전부 1회 |
| **W18** | 안정화 | 버그 수정, 문서 정리, Phase 2 Plan 착수 | retrospective doc | Phase 1 성공 기준 (§10.5) 확인 |
| **W19** 🆕 | **Dogfooding-BF (optional)** | 별도 legacy repo 1건에 `/sfs install --mode brownfield` → P-1 (3-pass) → G-1 서명 → 첫 Sprint Plan 진입. 실패 시 §10.5.1-b만 미충족 (Phase 1 성공 여부는 §10.5.1 5개 조건으로 판정) | `legacy-repo/.solon-manifest.yaml`, `legacy-repo/discovery-report.md` + G-1 서명 | G-1 통과 + §10.5.1-b 확인 |

### 10.4.3 병렬화 가능 구간

| 구간 | 병렬 작업 | 단축 가능 |
|------|----------|----------|
| W2b (R3) | dialog-engine / alternative-suggestion-engine 두 엔진 독립적 구현 가능 (schema 계약만 지키면) | 0.5주 단축 🆕 R3 |
| W3~W5 | 8 Evaluator는 독립적 (discovery-report-validator 포함) → 2명 이상의 AI 세션으로 병렬 | 최대 1주 단축 |
| W6~W7 | 재작성 Evaluator 3개 독립 | 0.5주 단축 |
| W9~W10 | sfs-discover / sfs-escalate / sfs-retro / **sfs-division** 4개가 상호 독립 (경로 충돌 없음) 🆕 R3 | 0.5주 단축 |
| W11~W12 | L1/L2/L3 파이프라인 부분 병렬 (L1 → L2 → L3 순서만 지키면) | 0.5주 단축 |

→ **낙관 16주, 비관 20주, 현실 예상 18주**. W19-20는 optional이므로 낙관값에서 생략 가능.

### 10.4.4 Critical Path

```
W1 C-Level → W2 Leads (active 2) + W2b 원칙 13 엔진 2개 🆕 R3 → W3-5 Eval-신규 (incl. discovery-report-validator) → W8-10 Skills (incl. sfs-discover + sfs-division 🆕 R3) → W11-12 Obs → W13 Packaging + solon-manifest → W14-15 Integ (greenfield + brownfield + **activation invariant** 🆕 R3) → W16-18 Dogfooding (greenfield) → [W19-20 optional brownfield + abstract → active 실사용 🆕 R3]
```

**Critical Path 단절 조건** (v0.4-r3 추가 3건 포함):
- W2 divisions.yaml (v1.1) 스키마 미확정 → W3 이후 전체 지연
- W10 sfs-escalate 미완성 → W14 통합 테스트 불가
- W12 L3 sync 미완성 → Phase 1 성공 기준 미달 (H1 검증 불가)
- W5 discovery-report-validator 미완성 → W9 sfs-gates의 G-1 구현 불가 → W15 brownfield integration test 불가 → W19 brownfield dogfooding 불가
- W13 `.solon-manifest.yaml` 스키마 미확정 → W15 brownfield integration 불가 (coexistence 로직 없음)
- **W2b dialog-engine 미완성** → W10 sfs-division skill 불가 → §10.5.1 조건 6 (abstract → active 1회 승격 dogfooding) 미충족 🆕 R3
- **W2b alternative-suggestion-engine 미완성** → `/sfs install` Socratic wizard 작동 불가 → W13 패키징 단계에서 install 시나리오 전체 실패 🆕 R3
- **W15 activation-state invariant 검증 미완성** (ALT-INV-1~3 / INV-5) → `sfs-doc-validate` 가 원칙 13 위반을 잡지 못함 → Phase 2 상품화 시 tenant 별 본부 조합 오류 위험 🆕 R3

---

## 10.5 Phase 1 성공 기준

### 10.5.1 필수 조건 (모두 충족, greenfield 기준)

| # | 조건 | 검증 방법 | 미충족 시 |
|:-:|------|---------|----------|
| 1 | product-image-studio에 Solon 적용 → 한 Sprint 완주 (greenfield) | L2 git에 `sprint-2026-W??-*/` 디렉토리 존재 + report.md 커밋 | Phase 1 실패 |
| 2 | **active 본부** (dev + strategy-pm) 모두 1회 이상 PDCA 완료 + **최소 1개 abstract 본부** 가 Phase 1 중 active 로 승격되어 1회 이상 PDCA 완료 🆕 R3 | L2 에 active 2 본부 산출물 + 승격된 최소 1 본부 산출물 존재 | 본부 확장 검증 실패 (H2 미검증) |
| 3 | G1~G5 Gate 모두 1회 이상 실행 | L1 S3 log에 `gate_id: G1/G2/G3/G4/G5` 이벤트 존재 | Gate 프레임워크 검증 실패 |
| 4 | Escalate-Plan 1회 이상 트리거 + H6 학습 로그 1개 생성 | L2 escalation-plan.md 1건 + learnings-v1.md에 새 패턴 1건 | H6 자기학습 검증 실패 (H6 미검증) |
| 5 | 3-Channel observability 모두 데이터 보유 | S3 objects > 0, git docs submodule 커밋 > 0, L3 대시보드 갱신됨 (driver 무관) | H1 관측성 검증 실패 |
| **6** 🆕 R3 | **Phase 1 종료 시 최소 1 개 `abstract` 본부가 Socratic 5-phase dialog 를 거쳐 `active` 로 승격된 이력이 존재** (원칙 13 Progressive Activation + Non-Prescriptive Guidance dogfooding) | L1 S3 log 에 `dialog_trace_id: dlg-*` 이벤트 + `division.activation.changed` event (from: abstract, to: active) 1 건 이상 + `divisions.yaml` diff 에 해당 본부 activation_state 변경 커밋 존재 + Option Card 선택 로그 (3-tier 중 사용자가 1 개 선택한 trace) 존재 | 원칙 13 실증 실패 → Phase 2 상품화 시 본부 조합 자율화 근거 부족 |

### 10.5.1-b Optional 브라운필드 검증 조건 (선택 충족, 1개 이상 권장)

| # | 조건 | 검증 방법 | 미충족 시 |
|:-:|------|---------|----------|
| b1 | `/sfs install --mode brownfield` 1건 end-to-end 성공 | `.solon-manifest.yaml` + `.g-1-signature.yaml` + `discovery-report.md` 3종 생성, 서명 완료 | Phase 1 성공은 유지되나 brownfield 실증 미완 (§10.5.4 참고) |
| b2 | G-1 Intake Gate 1회 이상 PASS | L1 S3 `l1.gate.g-1.complete` 이벤트에 `verdict: success` + `signature.signed_at` 존재 | 동상 |
| b3 | discovery-report-validator 7축 검증 모두 통과 | gate-report yaml의 `validator_verdict.axes` 7개 모두 PASS | 동상 |

> **결정 규칙**: 10.5.1의 5개 필수 조건은 AND. 10.5.1-b는 **Phase 1 성공 여부에 영향을 주지 않는 optional**. 단 §9.10 지표 (H5/H6 자기학습)에 brownfield 루프 데이터가 없으면 Phase 2 scope 결정 시 근거 부족 (§10.9 Transition 입력 감소). 따라서 **1건 수행을 강력 권장**.

### 10.5.2 측정 가능 지표

§9.10의 5 metric을 Phase 1 종료 시점에 측정한다.

| Metric | Target | 측정 소스 |
|--------|--------|----------|
| Sprint recovery time | < 24h | L3 Notion Sprint 대시보드 (첫 escalate → Sprint 재개) |
| Pattern recurrence rate | < 10% | H6 learnings-v1.md의 중복 trigger 카운트 / 전체 trigger |
| Active divisions | ≥ 4 | L2 `01-design/`, `02-implementation/`, `03-qa/`, `04-escalation/` 내 division 태그 |
| Gate pass rate (first attempt) | ≥ 70% | L1 S3 gate events `result: pass` / `total gate events` (재시도 제외) |
| L2 → L3 sync success | ≥ 99% | Notion sync worker 로그 `success / total` |

### 10.5.3 Secondary 지표 (참고용, Phase 2 개선 입력)

| Metric | Phase 1 참고 목표 | 비고 |
|--------|-----------------|------|
| 월 토큰 비용 (greenfield, minimal tier) | < $400 | Opus 호출 빈도에 크게 의존. tier=standard는 < $700, collab은 < $1200 (§10.10.2) |
| P-1 1회 비용 (brownfield, medium repo) | < $15 | §2 원칙 11 강제. 초과 시 `abort_on_budget_exceeded` |
| G-1 1회 비용 | < $0.30 | discovery-report-validator (Sonnet ×2~3) + 사람 서명 (비용 0). §5.11.8 |
| Evaluator 호출 평균 응답 시간 | < 60초 | Opus 본부장 evaluator 기준 |
| discovery-report-validator 응답 시간 | < 5분 | Sonnet ×2~3 호출 상한. §5.9.1 |
| Dogfooding Sprint 완주 수 (greenfield) | ≥ 1 | 2개면 이상적 (§10.6 시나리오 2개 완주) |
| Dogfooding P-1+G-1 완료 수 (brownfield, optional) | ≥ 1 | §10.6.5 |
| H6 learnings-v1 패턴 누적 | ≥ 10 | 시드 5 + Sprint 중 추가 5 |
| Escalate → ABORT 비율 | ≤ 1/Sprint | ABORT 남발은 Gate 기준이 너무 엄격하다는 신호 |

### 10.5.4 Phase 1 "성공"의 의미 재확인

Phase 1 성공 = "실제로 작동하는 최소한의 자기검증 시스템 확보".
**Phase 1 실패 ≠ 프로젝트 실패**. 실패 시 Phase 1을 1~2개월 연장하여 H6가 작동하는지 확인하는 것이 더 가치 있다.

Brownfield 관점에서 Phase 1 성공은 **"코드는 출하됐고 (P0), dogfooding도 1회 수행됨 (optional 권장)"** 를 의미. 10.5.1-b가 미충족이어도 Phase 1은 성공하며, 다만 Phase 2 Roadmap 작성 시 brownfield 실데이터가 부족해 **incremental discovery / migrate 액션 등 Phase 2 기능 우선순위 판단이 부실해진다** (§10.9.1 Transition 판정 입력 감소).

---

## 10.6 Dogfooding: product-image-studio (greenfield) + optional Brownfield 대상

### 10.6.1 왜 product-image-studio인가 (greenfield)

| 기준 | 점검 결과 |
|------|---------|
| 실제 수익이 걸린 프로젝트인가 | ✅ (셀러 대상 B2B SaaS, 이미 운영 중) |
| 6 본부가 모두 존재하는가 | ✅ PM(셀러 요구) / Taxonomy(상품 분류) / Design(이미지/상세페이지) / Dev(크롤링+AI+합성) / QA(이미지 정확도) / Infra(Docker/Gemini 비용) |
| 복잡도가 적절한가 | ✅ (소규모지만 AI/크롤링/이미지 처리 등 다축) |
| L2/L3 분리 저장소 실험 가능한가 | ✅ 별도 git 저장소로 git submodule 실험 적합 |

### 10.6.2 적용 시나리오 후보 (Phase 1에서 1~2개 선택)

| # | 시나리오 | 관여 본부 | 난이도 | 예상 소요 |
|:-:|---------|---------|:-----:|----------|
| A | **신규 도매 사이트 파서 추가** (예: 또다른 도매 플랫폼) | Dev 主 / PM / QA | 低 | 1주 이내 1 Sprint |
| B | **라이프스타일 이미지 프롬프트 개선** (특정 카테고리의 CTR 개선) | PM / Dev / QA / Design | 中 | 1.5주 1 Sprint |
| C | **상세페이지 신규 섹션 추가** (예: 사용 시나리오 섹션) | Design / Dev / QA | 中 | 2주 1 Sprint |

### 10.6.3 권장 진행 순서

1. **W16**: 시나리오 A 선택 (가장 간단) → Sprint Plan (PRD + divisions.yaml 참조)
2. **W17**: Sprint 실행 → G1~G4 통과 + 의도적으로 한 번 FAIL → Case-α 에스컬레이트 → 복구
3. **W18**: G5 Sprint-Retro → H6 패턴 1건 추출 → Phase 1 성공 기준 검증

### 10.6.4 "의도적 실패" 유도 원칙

Phase 1은 **Escalate 루프를 한 번은 타야 한다** (§10.5.1 조건 4).
실제 프로젝트에서 자연 발생을 기대하기보다, 다음 중 하나를 의도적으로 유도한다.

| 유도 기법 | 어떤 Failure Mode로 |
|----------|------------------|
| Gate 기준치를 의도적으로 타이트하게 설정 | FAIL-FIXABLE |
| Dev 구현과 Design 명세 간 미세한 불일치 주입 | CONFLICT |
| 일부 Evaluator를 mock fail 모드로 실행 | FAIL-HARD 시뮬레이션 |
| 의도적으로 PRD AC 1개를 모호하게 작성 | STALL → Case-α 트리거 |

→ 실패 이벤트 생성은 dogfooding 완결성의 일부다. Phase 1 성공 기준 조건 4와 결합.

### 10.6.5 Brownfield Dogfooding (optional) 🆕

#### 10.6.5.1 목적과 범위

Brownfield 코드 경로를 **실제 레거시 repo에 한 번 돌려보고**, P-1 Discovery + G-1 Intake Gate가 end-to-end 작동하는지 확인. Phase 1 성공 필수 조건은 아니지만 (§10.5.1-b optional), Phase 2 Roadmap 입력으로 가치가 크다.

**의도적으로 product-image-studio 외 별도 repo를 선택**하는 이유:
1. product-image-studio는 greenfield dogfooding에 이미 사용됨 → `/sfs install --mode greenfield` 로 초기화됨 → brownfield 적용 불가 (`rule/p-1-run-once-per-install`)
2. brownfield의 가치는 **"모르는 코드 기반을 Solon이 얼마나 정확히 파악하는지"** 검증. 이미 아는 repo에 적용하면 validation 의미가 감소.

#### 10.6.5.2 후보 대상 (사용자가 선택)

| # | 후보 | 조건 점검 | 난이도 | 예상 비용 (1회 P-1) |
|:-:|------|---------|:-----:|-----------------|
| α | 사용자 본인의 다른 사이드 프로젝트 (예: 개인 portfolio, blog) | ✅ 변경 권한 있음 / ❌ 너무 작아 evidence 부족 위험 | 低 | < $2 (small) |
| β | 사용자 지인의 MVP-stage repo (허가 필요) | ✅ 복잡도 적절 / ❌ 비공개 코드 다루는 윤리 고려 | 中 | $2~$15 (medium) |
| γ | Open-source repo (Apache/MIT, 중소 규모) | ✅ 공개라 부담 적음 / ❌ 소유 X → merge 불가, dry-run만 가능 | 中 | $2~$15 (medium) |
| δ | 의도적으로 구축한 "legacy mock repo" (고의적 나쁜 코드 포함) | ✅ 완전한 제어 / ❌ 실제 레거시와 온도 차이 | 低 | < $2 (small) |

> **Phase 1 권장**: **δ → α → β** 순서로 시도. γ는 정식 merge 없이 **dry-run 만** 수행 (라이선스·정책 고려).

#### 10.6.5.3 진행 절차 (W19, 5일 예상)

```
Day 1: 대상 repo 선정 + git clone (full clone, shallow 금지 per rule/brownfield-discovery-read-only)
Day 2: /sfs install --mode brownfield 실행
       ├─ Pass 1: Haiku inventory (read-only Glob/Grep/Bash 허용) → inventory/*.json
       ├─ Pass 2: Sonnet evidence collection → evidence/{claim-id}.yaml
       └─ Pass 3: Sonnet discovery-report draft → discovery-report.md + .solon-manifest.yaml
Day 3: discovery-report-validator (G-1 evaluator) 7축 검증 실행
       ├─ FAIL-FIXABLE → 사람이 draft 수정 → 재평가
       └─ SUCCESS → .g-1-signature.yaml 초안 생성
Day 4: 사람 서명 (6개 체크박스 확인 + CEO signature)
       ├─ STALL (서명 거부 누적) → user-prompt
       └─ G-1 complete → l1.gate.g-1.complete 이벤트 발행
Day 5: 첫 Sprint Plan 진입 (Sprint 0 pseudo-learnings = P-1 산출물, 원칙 12)
       + W19 retrospective 작성 → Phase 2 input으로 archive
```

#### 10.6.5.4 성공 판정 기준

| 항목 | 기준 | 관련 §10.5 조건 |
|------|------|----------------|
| `/sfs install --mode brownfield` 정상 종료 | exit code 0 | b1 |
| 3종 산출물 생성 | `.solon-manifest.yaml` + `discovery-report.md` + `.g-1-signature.yaml` | b1 |
| G-1 PASS (서명 완료) | `signature.signed_at` 존재, `validator_verdict=success` | b2 |
| 7축 검증 통과 | `validator_verdict.axes` 7개 모두 PASS | b3 |
| 비용 cap 준수 | 총 비용 ≤ §10.6.5.2 예상 비용의 1.5배 | Secondary |
| Brownfield 첫 Sprint Plan G1 통과 | G1 `result: pass` | — (있으면 보너스) |

#### 10.6.5.5 실패 복구

- **예산 초과 (`abort_on_budget_exceeded`)**: repo 크기 over-estimate. 다음 시도 시 `tier_profile: minimal`로 제한 + `budget_cap_override=small`
- **읽기 전용 위반 (Write/Edit 시도 감지)**: 심각한 위반. `sfs-discover` skill의 tool_restrictions 미준수 → 수정 후 재시작
- **서명 거부 STALL**: 사용자가 discovery-report 신뢰 못함 → discovery-report를 사람이 직접 수정 후 서명 (Option-A of §5.11.2 route)
- **validator FAIL-HARD (7축 중 3축 이상 실패)**: repo 접근 제한 또는 repo 구조 이상 → repo 재선정 (후보 리스트 다음 아이템)

#### 10.6.5.6 W19 skip 조건

다음 중 하나라도 해당하면 W19를 **명시적으로 skip** 하고 Phase 1 종료 (greenfield 5조건만 충족 시 성공):
- W18 말 greenfield Phase 1 성공 조건 중 1개 이상 미충족 (brownfield보다 먼저 greenfield 복구)
- Phase 1 누적 비용이 $1,500 초과 (brownfield 추가 투자 위험)
- 사용자 피로도 "지속 불가" (솔로 창업자 번아웃 방지)

---

## 10.7 Risk & Mitigation

| # | Risk | Impact | Likelihood | Mitigation | 감지 지표 |
|:-:|------|:------:|:----------:|-----------|----------|
| R1 | Opus 토큰 비용 초과 ($500+/월) | 高 | 中 | 본부장 호출 빈도 제한 (Sprint당 Lead 호출 상한 20회), Sonnet fallback 옵션 (§3.5), Cost Estimator 미리 추정 | L1 S3 tokens/cost_usd 집계 |
| R2 | cowork 재작성 시 Inspired-Rewrite 일탈 (NIH 경향) | 中 | 高 | 3 skill로 범위 한정 (§10.3.3), W7 완료 시 원본 대비 기능 매트릭스 리뷰 | W7 완료 체크리스트 |
| R3 | L2 Notion sync 충돌 / 데이터 유실 | 中 | 中 | 일방향 sync 강제 (§8.2), Notion은 뷰 전용, 재동기화 스크립트 준비 | L3 sync worker 로그 |
| R4 | H6 학습 루프 데이터 부족 (Sprint 1~2회로는 패턴 추출 부실) | 高 | 中 | Phase 1 시드 패턴 5개 사전 정의 (§10.8), sprint-retro-analyzer가 시드를 입력으로 사용 | §10.8 완료 여부 |
| R5 | 본부장 = Gate Operator 원칙 위반 (본부장이 자기검증) | 高 | 中 | Tier 1 자기검증 정적 검증 (sfs-doc-validate가 evaluator 호출 주체 확인), code review 필수 | 자동 검증 스크립트 |
| R6 | Cowork / CLI 공유 FS symlink 깨짐 (환경 차이) | 中 | 中 | install.sh에서 symlink 생성 + 검증 단계 (§7.7), 실패 시 수동 설치 가이드 | install.sh 종료 코드 |
| R7 | product-image-studio Sprint가 14주 안에 완주 불가 | 高 | 低 | 시나리오 A (가장 간단) 우선 선택, W15까지 integration test 완결 강제 | W16 entry 시점 점검 |
| R8 | Claude Desktop Cowork API 변경으로 플러그인 호환성 깨짐 | 中 | 低 | CLI 먼저 완결 → Cowork 통합은 W13 이후 진행, 플랫폼 변경 시 Phase 1 scope를 CLI만으로 축소 | Cowork 공식 공지 모니터링 |
| R9 🆕 | Brownfield P-1 비용 폭주 (medium repo에서 $15 cap 초과) | 高 | 中 | `/sfs discover` frontmatter에 `cost_budget_usd.abort: $80` 하드 상한 + `abort_on_budget_exceeded` 자동 종료. Pass 1 (Haiku) → Pass 2 (Sonnet) 순차 cap으로 early-exit. tier=minimal 강제 | L1 S3 `cost_usd` 집계 실시간 모니터링 |
| R10 🆕 | 기존 docs / coexistence 갈등 (사용자가 이미 docs/ 디렉토리 보유 → Solon이 덮어쓸 위험) | 高 | 高 | `.solon-manifest.yaml`의 `coexistence_strategy` 필수 지정 (keep/coexist/archive). W13 packaging 시 파괴적 쓰기 금지. 서명 체크박스에 "기존 docs 처리 방식 확인" 필수 포함 | G-1 서명 완료 여부, L2 git pre-commit에서 기존 docs 수정 탐지 |

### 10.7.1 Risk Ownership

모든 Risk는 CEO (사용자 자기 자신) 가 오너. 주 1회 risk-check.md 업데이트 (sfs-plugin install 후 자동 생성).

---

## 10.8 H6 Seed Patterns (5개 사전 정의)

Phase 1 시작 시점에 **H6 학습 데이터베이스가 비어있는 문제**를 해결하기 위해, 5개 시드 패턴을 사전 정의한다. 이는 sprint-retro-analyzer의 최초 입력이 된다.

### 10.8.1 Seed Pattern 1: "AC 모호성으로 인한 G1 fail"

```yaml
pattern_id: seed-001-ac-ambiguity
trigger: "G1 Plan Gate에서 plan-validator가 AC 중 1개를 '수용 기준 측정 불가' 로 판정"
root_cause: "PRD AC가 정성적 (예: '사용자가 만족하도록')"
fix_strategy: "AC에 측정 가능한 기준 추가 (예: 'p95 response time < 500ms')"
plan_validator_check_to_add: "각 AC가 최소 1개의 측정 가능한 수치 포함 여부"
```

### 10.8.2 Seed Pattern 2: "Evaluator 외부성 위반"

```yaml
pattern_id: seed-002-evaluator-self-validation
trigger: "본부장이 자기 본부 산출물을 evaluate함"
root_cause: "Tier 2 외부 evaluator 호출을 누락"
fix_strategy: "sfs-doc-validate에 evaluator call provenance 체크 추가"
plan_validator_check_to_add: "Gate 실행 전 evaluator 소속 본부 vs 피평가 본부 비교"
```

### 10.8.3 Seed Pattern 3: "Design-Dev 핸드오프 갭"

```yaml
pattern_id: seed-003-design-dev-handoff-gap
trigger: "Dev 본부 G4에서 gap-detector가 Gap < 70 결과, 원인이 Design 스펙 누락"
root_cause: "design-handoff-rewrite 산출물에 edge case 케이스가 빠짐"
fix_strategy: "design-handoff-rewrite 템플릿에 edge-case 섹션 의무화"
plan_validator_check_to_add: "Design 산출물에 edge_cases 필드 존재 여부"
```

### 10.8.4 Seed Pattern 4: "Infra 비용 예측 실패"

```yaml
pattern_id: seed-004-infra-cost-underestimate
trigger: "Sprint 종료 시 실측 비용이 cost-estimator 추정치의 1.5배 이상"
root_cause: "Gemini API 호출 빈도 또는 S3 storage 누적 미고려"
fix_strategy: "cost-estimator에 storage_growth_rate 변수 추가"
plan_validator_check_to_add: "Design 단계에서 storage 성장률 명시 여부"
```

### 10.8.5 Seed Pattern 5: "Taxonomy 용어 충돌 (본부 간)"

```yaml
pattern_id: seed-005-taxonomy-cross-division-conflict
trigger: "PM 본부는 '라이프스타일 이미지', Design 본부는 '배경 합성 이미지'로 동일 개념을 다른 이름 사용"
root_cause: "taxonomy-consistency-checker가 본부 경계를 넘는 용어를 검증하지 않음"
fix_strategy: "taxonomy-consistency-checker에 cross-division alias 표 유지"
plan_validator_check_to_add: "용어 추가 시 다른 본부 사전에서 유사 의미 용어 탐색"
```

### 10.8.6 Seed → Live 전환

5개 시드는 `sfs-plugin/memory/h6-seed-patterns.yaml` 에 저장되어, Phase 1 첫 Sprint의 G5 실행 시 sprint-retro-analyzer가 입력으로 받는다. Sprint 1 종료 후 실제 발생한 패턴이 추가되면서 live pattern DB로 진화한다.

---

## 10.9 Phase 1 → Phase 2 Transition Gate

Phase 1 종료 시점에 **"Phase 2로 진입 가능한가"** 를 평가한다. 이 게이트 자체도 Solon의 G-series 확장 개념이지만, Phase 1의 최종 G5를 재활용한다.

### 10.9.1 Transition 판정 기준

| 조건 | 통과 기준 | 관련 §10.5 조건 |
|------|---------|----------------|
| Phase 1 필수 5 조건 모두 충족 | All PASS | §10.5.1 |
| 월 비용 < $500 | pass | §10.5.3 |
| H6 패턴 누적 ≥ 10 | pass | §10.5.3 |
| 사용자 (솔로 창업자) 피로도 자가평가 | "지속 가능" 이상 | 정성 |
| Phase 2 필요성 체크 | "Phase 1 기능으로 부족한 영역 ≥ 2개 식별" | 분석 |

### 10.9.2 Transition 분기

| 결과 | 다음 행동 |
|------|---------|
| **PASS** | Phase 2 Plan 작성 착수 (§7.9 Phase 2 로드맵 기반) |
| **DEFER** | Phase 1을 1~2개월 연장, 추가 Dogfooding Sprint 1회 이상 |
| **PIVOT** | Phase 1 설계 재검토 (§6.4 Case-β 에 준하는 전면 재설계), v0.5 논의 |

### 10.9.3 Transition 판정자

- 주 판정자: **사용자 자기 자신 (CEO)**
- 보조 입력: sprint-retro-analyzer가 Phase 1 Full Retrospective 생성 (모든 Sprint 데이터 집계)
- 의사결정 기록: `sfs-docs/00-governance/phase-1-to-2-transition.md`

---

## 10.10 예산 & 리소스 요약

### 10.10.1 공수 (Solo Founder)

| 단계 | 주차 | 주당 시간 | 누적 시간 |
|------|:----:|:-------:|:-------:|
| Foundation + Evaluators + Skills + Obs + Packaging | W1~W13 | ~20h | ~260h |
| Integration + Dogfooding (greenfield) + Stabilization | W14~W18 | ~25h | ~385h |
| Brownfield Dogfooding (optional, 1주) | W19 | ~25h | ~410h |
| **총계 (greenfield만)** | **15~18주** | — | **~385h (평균 주 21h)** |
| **총계 (greenfield + brownfield)** | **15~19주** | — | **~410h (평균 주 21.6h)** |

> 솔로 창업자의 생존 시간 확보를 위해 주 20~25h 상한을 기준으로 한다. 초과 시 Phase 1 기간 연장이 올바른 선택. W19는 **피로도 신호 발생 시 즉시 skip** (§10.6.5.6).

### 10.10.2 월 비용 추정 (tier-profile × mode 매트릭스)

#### 10.10.2.1 Greenfield 월 운영 비용 (Sprint 2회/월 가정)

| 항목 | `minimal` (Phase 1 기본) | `standard` | `collab` | 비고 |
|------|:-------:|:-------:|:-------:|------|
| Opus 토큰 (C-Level + 7 Evaluator) | $150~$280 | $300~$500 | $500~$800 | tier 상승 시 CPO 5-Axis 호출 확대 |
| Sonnet 토큰 (Worker + discovery-report-validator) | $30~$60 | $60~$100 | $100~$180 | standard부터 design-critique 호출 증가 |
| Haiku / 보조 | $5~$10 | $10~$20 | $15~$30 | 로그 요약 자동화 강화 |
| S3 (L1 log + evidence 누적) | $5~$10 | $10~$20 | $15~$30 | collab은 다중 observer 권한 |
| L3 backend (driver별) | $0 (none) / $10 (notion) | $10 (notion) | $10~$20 (notion/confluence) | driver=none이면 $0 |
| **합계** | **$190~$370** | **$390~$650** | **$640~$1,060** | Phase 1 기본은 minimal |

> Phase 1 성공 기준 secondary 목표 ($400/월 이내, minimal tier) 에 여유 있게 적합. tier=standard/collab은 Phase 2 이후 고려.

#### 10.10.2.2 Brownfield 1회성 비용 (install 당 추가, repo 크기별)

| Repo 크기 | Pass 1 (Haiku) | Pass 2 (Sonnet) | Pass 3 (Sonnet) | G-1 (Sonnet ×2~3) | **합계 (1회성)** |
|----------|:-------:|:-------:|:-------:|:-------:|:-------:|
| small (<10k LoC) | $0.10 | $0.30 | $0.40 | $0.20 | **< $2** |
| medium (10k~100k LoC) | $0.50 | $3~$6 | $4~$7 | $0.30 | **$2~$15** |
| large (100k~1M LoC) | $2~$4 | $15~$25 | $20~$30 | $0.30 | **$37~$60** (abort 전 cap) |
| abort threshold (hard) | — | — | — | — | **$80 이상 시 강제 중단** |

> §2 원칙 11 cost cap. medium repo 1회 $15 이하가 Phase 1 성공 기준 (§10.5.3 secondary).
> **Phase 1 권장**: Dogfooding은 small 또는 medium 대상만. large repo는 Phase 2에서 incremental discovery 도입 후 재검토.

#### 10.10.2.3 Tier 간 차등의 의미 (Phase 1 범위)

| Tier | Phase 1 구현 범위 | Phase 2 확장 |
|------|------------------|-------------|
| `minimal` | **전체 구현** (C-Level + 6 Lead + 8 Evaluator + 5 Skill + observability) | — |
| `standard` | schema/config 레벨만 정의, Phase 1은 `minimal` 폴백 | worker 인원 확장, evaluator 병렬화 |
| `collab` | schema/config 레벨만 정의, Phase 1은 `minimal` 폴백 | 공동작업자 권한, multi-CEO |

### 10.10.3 도구 / 의존성

| 도구 | 목적 | 비용 | Mode 영향 |
|------|------|------|----------|
| Claude Code CLI | 에이전트 실행 환경 | 플랜 구독 | 공통 |
| Claude Desktop Cowork | GUI 실행 환경 | 플랜 구독 | 공통 |
| git + git-submodule | L2 SSoT | 무료 | 공통 |
| AWS S3 | L1 로그 저장 | 사용량 과금 | 공통 |
| **L3 Backend Driver** | L3 대시보드 | driver별: notion=$10/월, none=$0, obsidian/logseq=자체 호스팅, confluence=기존 계정 활용 | 공통 |
| bkit plugin | Dev/QA 본부 Evaluator 재활용 | 무료 | 공통 |
| cowork plugin (inspired-rewrite 참조) | Design evaluator 설계 참조 | 무료 | 공통 |
| **Legacy repo access (brownfield only)** | Brownfield dogfooding 대상 | 라이선스/권한에 따름 | brownfield only |

---

## 10.11 CLI-First Tool Selection Policy 🆕 (v0.4-r3)

> **의도**: Solon 은 MCP 이전에 **CLI 와 직접 API 연결을 1 순위** 로 선택한다.
> 근거: (1) 설치/의존성 최소화, (2) 다른 계정·머신으로의 포팅 용이성 (cross-account migration 대비), (3) 실패 시 디버깅 가시성 우수, (4) 재현 가능성.

### 10.11.1 4-Tier Tool Preference

도구 선택은 아래 순서로 우선한다. **상위 tier 가 불가능할 때만 하위 tier 로 하강**:

| 우선순위 | Tier | 선택 기준 | 예시 |
| --- | --- | --- | --- |
| **1순위** | **CLI** | 서비스가 공식 CLI 를 제공 & Bash 로 호출 가능 | `gh`, `aws`, `gcloud`, `notion-cli` (있다면), `jq`, `yq` |
| **2순위** | **Direct API (Bash + curl/http)** | 공식 REST API + Bearer token 또는 OAuth device flow | `curl -H "Authorization: Bearer $TOKEN" https://api.notion.com/v1/...` |
| **3순위** | **MCP** | CLI/API 로 표현하기 어렵거나 stateful 인 경우만 | notion-fetch (search semantics 복잡), desktop file watchers |
| **4순위** | **Claude-native tools** | L0 필수 도구 (Read/Write/Edit/Bash/Grep/Glob) + 내부 skill | 세션 내 파일 조작, 문서 생성 |

### 10.11.2 왜 CLI-first 인가 — 원칙 13 연결

| 속성 | CLI | API 직접 | MCP | 비고 |
| --- | --- | --- | --- | --- |
| 포팅성 (계정 이동) | 높음 | 높음 | 낮음 (MCP 서버 재설치) | cross-account 시 MCP 는 reconnect 비용 |
| 재현성 (같은 명령 같은 결과) | 매우 높음 | 높음 | 중간 (MCP 서버 버전 의존) | |
| 실패 가시성 | stderr 명확 | HTTP status + body | tool error → abstraction | 디버깅 |
| 설치 비용 | `brew install` 1 회 | 0 (curl 이미 존재) | MCP 서버 설정 + 재시작 | |
| 권한 모델 | OS credential 재사용 | env var / keychain | MCP 서버 credential 관리 | |
| 버전 고정 | 사용자 통제 | URL version pin 가능 | MCP 서버 업그레이드 시 breaking | |

### 10.11.3 선택 가이드 (rule/cli-first-tool-selection)

agent 가 외부 리소스에 접근해야 할 때 아래 의사결정 트리:

```
요청: "<외부 리소스> 에 <작업> 해야 함"
│
├─ Q1: 공식 CLI 가 존재하고, 이 작업을 지원하는가?
│     │
│     ├─ YES → Bash 로 CLI 호출 (1 순위)
│     │
│     └─ NO → Q2
│
├─ Q2: 공식 REST/GraphQL API 가 존재하고, 인증 가능한가?
│     │
│     ├─ YES → Bash + curl 또는 workspace.web_fetch (2 순위)
│     │
│     └─ NO → Q3
│
├─ Q3: MCP 서버가 이 작업을 지원하는가?
│     │
│     ├─ YES → MCP 호출 (3 순위) + rationale 명시
│     │
│     └─ NO → Q4
│
└─ Q4: Claude-native 도구로 대체 가능한가?
     │
     └─ Read/Write/Edit/Bash/Grep 조합 (4 순위)
```

### 10.11.4 MCP 사용 정당화 (rule/mcp-justification-required)

MCP 선택 시 **L1 event 에 rationale 기록 필수**:

```json
{
  "event": "l1.tool.mcp.invoked",
  "tool": "notion-search",
  "reason_not_cli": "Notion CLI 공식 미제공",
  "reason_not_api": "search 의 semantic ranking 이 MCP 로만 노출됨",
  "fallback_plan": "CLI 출시 시 마이그레이션 예정 (tracking issue #XXX)"
}
```

이 기록은 향후 MCP 의존도를 정량 측정하고, cross-account 이주 시 영향 범위를 산출하는 데 사용된다.

### 10.11.5 Cross-Account Migration 과의 연결

본 정책은 **§CROSS-ACCOUNT-MIGRATION.md 의 핵심 전제**:

- MCP 가 적을수록 계정/머신 이주 비용이 낮다
- CLI + direct API 기반 agent 는 `~/.solon/config.yaml` 한 파일과 credential 파일만으로 이주 가능
- Phase 1 은 MCP 의존도를 **전체 tool call 의 30% 미만** 으로 유지 (측정: l1.tool.* 이벤트 기반)

### 10.11.6 Phase 1 적용 스코프

| 작업 영역 | 1순위 도구 | 실제 채택 |
| --- | --- | --- |
| git 조작 | git CLI | ✅ |
| GitHub 이슈/PR | `gh` CLI | ✅ |
| AWS S3 (L1 저장) | `aws` CLI | ✅ (sdk fallback) |
| YAML/JSON 편집 | `yq` / `jq` | ✅ |
| 웹 문서 fetch | `curl` / workspace.web_fetch | ✅ |
| 스케줄링 | cron / launchd | ✅ |
| Notion 업로드 (L3 backend=notion 시) | notion REST API (curl) | ✅ 1순위, MCP 는 fallback |
| 파일 시스템 | Bash + Read/Write/Edit | ✅ (Claude-native) |

### 10.11.7 Anti-Patterns

| Anti-Pattern | 왜 금지 | 대체 |
| --- | --- | --- |
| CLI 존재하는데 MCP 로 우회 | 의존성·이주 비용 증가 | CLI 사용 |
| curl 대신 MCP web-fetch 고집 | 투명성 저하 | curl + workspace.web_fetch 병용 |
| agent 가 자체 HTTP 구현 (Python requests 등) 을 Bash 에서 호출 | 재현성 ↓, 디버깅 어려움 | curl / gh / aws CLI 우선 |
| MCP 호출에 rationale 미기록 | Anti-pattern 누적 감지 불가 | l1.tool.mcp.invoked 필수 발행 |

### 10.11.8 Exceptions (예외 허용 사례)

다음은 예외적으로 MCP 또는 agent-side tool 을 1 순위로 허용:

- 세션 내 사용자 파일 조작 → Read/Write/Edit (Claude-native) 가 오히려 적합
- 사용자 승인 필요 작업 (`request_cowork_directory`) → MCP 만 제공
- 실시간 watcher 가 필요한 작업 → MCP 의 stateful 연결 필요

예외 사용 시에도 **근거를 codebase 주석 또는 L1 event 에 기록**.

---

*(끝 — §10 완료, 다음은 Appendix 검증 + 11개 command spec 작성)*
