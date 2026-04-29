---
doc_id: sfs-v0.4-index
title: "Solon (Solo Founder System) v0.4-r4 — INDEX"
version: 0.4-r4
status: draft
last_updated: 2026-04-28
role: navigation-hub
enforced_by: sfs-doc-validate
---

# Solon — 설계 제안서 v0.4-r4 (INDEX)

> **제품명/네이밍**: 제품 브랜드 = **Solon**, CLI prefix = **`/sfs`** (Solo Founder System, 내부 명칭). 두 이름은 의도적으로 분리 유지.
> doc_id 는 구조 식별자이므로 `sfs-v0.4-*` 유지 (브랜드 rename 무관).
>
> **이 문서의 역할**: 전체 문서셋의 **네비게이션 허브**.
> 각 섹션의 frontmatter에서 `depends_on` / `defines` / `references` / `affects`를 집계하여
> **누구든 어느 섹션부터 시작해도 필요한 맥락을 빠짐없이 로드하도록 보장**한다.
>
> **v0.4-r4 핵심 변경 요약** (자세한 diff 는 §7 changelog 참조):
> - AGENTS bootstrap shim 신설: root `AGENTS.md` → docset `AGENTS.md` → `CLAUDE.md` 실제 SSoT.
> - Startup team-agent full flow 를 13-step artifact chain 으로 정리하고, `04-pdca-redef.md`/`05-gate-framework.md`/schema/template 에 반영.
> - Foundation Invariants FI-1~4 추가: Artifact Contract First / Taxonomy Is Root / Shift-left Infra-Security / Continuous Documentation Ledger.
> - Gate vocabulary 를 `G-1 + G0 + G1~G5 + RELEASE` 로 정합화. Release Readiness 는 command 미정, gate vocabulary 로 먼저 고정.
> - MVP 7-step 은 full artifact chain 의 lightweight projection 임을 `phase1-mvp-templates/` 와 `solon-mvp-dist/` 에 명시.
>
> **v0.4-r3 핵심 변경 요약** (이전 Round, 유지):
> - 원칙 12개 → **13개** (원칙 13 `progressive-activation-non-prescriptive-guidance` 추가)
> - **activation_state** (abstract/active/deactivated) + **activation_scope** (full/scoped/temporal) 도입 → Phase 1 basic active = **dev + strategy-pm** 2개만, 나머지 4개(qa/design/infra/taxonomy)는 abstract
> - **Socratic 5-phase dialog** (A Context → B Why-now → C Clarify → D Option Card → E Terminal) 표준화, `dialog_trace_id` format: `dlg-YYYY-MM-DD-<target-id>-<seq>`
> - **Alternative Suggestion Engine**: 3-tier × 3-level intensity (👍 권장 / ⚪ 중립 / ⚠ 비권장), ALT-INV-1~3 (특히 ALT-INV-3 **never-hard-block**)
> - 사용자-facing `/sfs *` command = **13개** (`/sfs division` 포함, internal gate dispatcher 제외)
> - `division/pm` → `division/strategy-pm` 개명
> - Appendix 신규: `dialogs/` (5 phase 템플릿) + `engines/` (dialog-engine, alternative-suggestion-engine) + `dialog-state.schema.yaml` + `divisions.schema.yaml` v1.1
>
> **v0.4-r2 변경 요약** (이전 Round, 유지):
> - 원칙 9개 → 12개 (원칙 10 `human-final-filter` + 원칙 11/12 `brownfield-first-pass` / `brownfield-no-retro-brainstorm`)
> - P-1 Discovery Phase + G-1 Intake Gate
> - 13개 command spec 정식화
> - Solon brand 정식화, README.md 루트에 신규
> - Tier Profile + L3 backend driver 일반화

---

## 1. 문서셋 구성

### 루트 (5 files)

| 파일 | 제목 | 핵심 역할 |
|------|------|----------|
| [README.md](README.md) | Solon docset 10분 overview | 처음 들어오는 사람 진입점, 12 섹션 (v0.4-r4 업데이트) |
| [SYSTEM-IDENTITY.md](SYSTEM-IDENTITY.md) | Solon System Identity | 초기 아이디어, 해결하려는 문제, 방향성 north-star |
| [INDEX.md](INDEX.md) (본 파일) | Navigation hub | 완전 cross-reference matrix (v0.4-r4) |
| [CROSS-ACCOUNT-MIGRATION.md](CROSS-ACCOUNT-MIGRATION.md) | 계정 이관 체크리스트 | 회사 계정 → 개인 계정 이관 시 standalone 매뉴얼 (v1.0, 2026-04-20) |
| [HANDOFF-next-session.md](HANDOFF-next-session.md) | 다음 세션 작업 지시 | Round 3 산출 + cross-account handoff carrier (git 포함 — MIG-10 이후) |

### 본문 (11 files)

| # | 파일 | 제목 | 핵심 역할 |
|:-:|------|------|----------|
| 00 | [00-intro.md](00-intro.md) | Elevator Pitch + 제품 철학 선언 | 한 줄 요약, 2가지 철학 (탄탄한 설계 + 사람 최종 필터) |
| 01 | [01-delta-v03-to-v04.md](01-delta-v03-to-v04.md) | v0.3 → v0.4 Delta | 바뀐 것만 빠르게 파악 |
| 02 | [02-design-principles.md](02-design-principles.md) | Design Principles | **13대 원칙 + Foundation Invariants** (v0.4-r4 기준, FI-1~4 추가) |
| 03 | [03-c-level-matrix.md](03-c-level-matrix.md) | C-Level × Division Matrix | 조직도 (3 C-Level × 6 본부) + **§3.3.0 Division Activation State** (abstract/active/deactivated) 🆕 R3 |
| 04 | [04-pdca-redef.md](04-pdca-redef.md) | PDCA 재정의 | Initiative ⊃ Sprint ⊃ PDCA (3 레이어), **P-1 Discovery** + startup team-agent artifact chain |
| 05 | [05-gate-framework.md](05-gate-framework.md) | Gate Framework **G-1 + G0 + G1~G5 + RELEASE** | 품질/출시 게이트 + 7 Failure Modes (Release Readiness 포함) |
| 06 | [06-escalate-plan.md](06-escalate-plan.md) | Escalate-Plan + H6 | Case-α/β/γ, AC 부분 재오픈, 5-Option Protocol, 자기학습 |
| 07 | [07-plugin-distribution.md](07-plugin-distribution.md) | Plugin 배포 + Phase 2 로드맵 | solon-plugin 구조, tier profile, L3 backend driver |
| 08 | [08-observability.md](08-observability.md) | 3-Channel Observability | L1 S3 / L2 git SSoT / L3 driver (notion/none/obsidian/logseq/confluence/custom) |
| 09 | [09-differentiation.md](09-differentiation.md) | Differentiation vs bkit | H1/H2/H5/H6 차별화 |
| 10 | [10-phase1-implementation.md](10-phase1-implementation.md) | Phase 1 구현 계획 | **16~20주 breakdown** (tier=minimal 기본 + brownfield optional), 8 Evaluator |

### Appendix (12 files + 13 slash commands + 3 drivers + 5 schemas + 5 templates + 6 dialogs + 2 engines + 3 reviews)

#### Schemas (5)
| 파일 | 역할 |
|------|------|
| [appendix/schemas/gate-report.schema.yaml](appendix/schemas/gate-report.schema.yaml) | §5 GateReport 전체 스키마 (v1) |
| [appendix/schemas/escalation.schema.yaml](appendix/schemas/escalation.schema.yaml) | §6 Escalation + LearningRecord 스키마 (v1) |
| [appendix/schemas/l1-log-event.schema.yaml](appendix/schemas/l1-log-event.schema.yaml) | §8 L1 Log Event 스키마 (v1) |
| [appendix/schemas/divisions.schema.yaml](appendix/schemas/divisions.schema.yaml) | §7 divisions.yaml 스키마 (**v1.1** — activation_state/scope/parent_division/sunset_at 확장) 🆕 R3 |
| [appendix/schemas/dialog-state.schema.yaml](appendix/schemas/dialog-state.schema.yaml) 🆕 R3 | §02 §2.13 Socratic 5-phase dialog state + dialog_trace_id 규약 (v1) |

#### Command Files (14 incl. README, 13 slash commands) — v0.4-r4 command count 정합
| 파일 | Command | 역할 |
|------|---------|------|
| [appendix/commands/README.md](appendix/commands/README.md) | (index) | 13 slash command 전체 가이드 + schema/command-spec-v1 |
| [appendix/commands/install.md](appendix/commands/install.md) | `/sfs install` | 설치 + tier/mode 선택 + **Socratic 5-phase wizard** (Haiku) 🆕 R3 |
| [appendix/commands/discover.md](appendix/commands/discover.md) | `/sfs discover` | P-1 Discovery (brownfield 전용, read-only) |
| [appendix/commands/brainstorm.md](appendix/commands/brainstorm.md) | `/sfs brainstorm` | G0 Brainstorm Gate (Initiative 진입) |
| [appendix/commands/plan.md](appendix/commands/plan.md) | `/sfs plan` | Plan phase + G1 |
| [appendix/commands/design.md](appendix/commands/design.md) | `/sfs design` | Design phase + G2 (division별 evaluator) |
| [appendix/commands/do.md](appendix/commands/do.md) | `/sfs do` | Do phase (worker 구현, Opus 금지) |
| [appendix/commands/handoff.md](appendix/commands/handoff.md) | `/sfs handoff` | G3 Pre-Handoff (self-handoff 금지) |
| [appendix/commands/check.md](appendix/commands/check.md) | `/sfs check` | G4 Check (Gap×0.4 + 5-Axis×0.6 ≥85) |
| [appendix/commands/act.md](appendix/commands/act.md) | `/sfs act` | Act phase + learnings + seed pattern |
| [appendix/commands/retro.md](appendix/commands/retro.md) | `/sfs retro` | G5 Sprint Retro (CEO + PM) |
| [appendix/commands/escalate.md](appendix/commands/escalate.md) | `/sfs escalate` | β-1/β-2/β-3 + 5-Option Protocol |
| [appendix/commands/status.md](appendix/commands/status.md) | `/sfs status` | Read-only 상태 조회 (Haiku) |
| [appendix/commands/division.md](appendix/commands/division.md) 🆕 R3 | `/sfs division` | 본부 activation_state 조회/변경 (**user-only**, INV-5 agent auto-invocation 금지) |

#### Dialogs (6) 🆕 R3 — Socratic 5-phase templates
> **⚠️ README.md 는 WU-4 (2026-04-20) 에 선제 생성** — index / overview / dialog_trace_id 요약 / ALT-INV-1~3 요약 허브. 나머지 5 phase md 는 Phase 1 W1~W2 구현 시 작성 예정. 현재 실재하는 artifact: `appendix/dialogs/README.md` (✅ WU-4) + `division-activation.dialog.yaml` (통합 dialog spec) + `branches/` + `traces/`. 아래 phase-*.md 는 dialog spec 을 5개 phase 파일로 분해할 때 생성됨.

| 파일 | Phase | 역할 | 상태 |
|------|-------|------|:-:|
| [appendix/dialogs/README.md](appendix/dialogs/README.md) | (index) | 5-phase 구조 개요 + `dialog_trace_id` 규약 + ALT-INV-1~3 | ✅ WU-4 |
| appendix/dialogs/phase-a-context.md | A | Context 수집 (user intent / current state) | ❌ Phase 1 |
| appendix/dialogs/phase-b-why-now.md | B (Q1) | "Why now" — 활성화 시점 필요성 확인 | ❌ Phase 1 |
| appendix/dialogs/phase-c-clarify.md | C (Q2) | Clarify — scope/tradeoff 명확화 | ❌ Phase 1 |
| appendix/dialogs/phase-d-option-card.md | D | Option Card (3-tier alternatives × 3-level intensity 👍⚪⚠) | ❌ Phase 1 |
| appendix/dialogs/phase-e-terminal.md | E | Terminal — 사용자 최종 선택 확정 + L1 event append | ❌ Phase 1 |
| [appendix/dialogs/division-activation.dialog.yaml](appendix/dialogs/division-activation.dialog.yaml) | (통합) | R3 시점 dialog 통합 spec (6개 분해 전) | ✅ R3 |

#### Engines (2) 🆕 R3
| 파일 | 역할 | 상태 |
|------|------|:-:|
| appendix/engines/dialog-engine.md | Socratic 5-phase dialog 상태 머신 spec (A~E transition + trace id) | ❌ Phase 1 |
| [appendix/engines/alternative-suggestion-engine.md](appendix/engines/alternative-suggestion-engine.md) | 3-tier × 3-level intensity 대안 제시 엔진 (ALT-INV-1~3, 특히 never-hard-block) | ✅ R3 |

#### Drivers (3, L3 channel)
| 파일 | 역할 |
|------|------|
| [appendix/drivers/_INTERFACE.md](appendix/drivers/_INTERFACE.md) | §8 L3 Driver Interface 계약 (v1) |
| [appendix/drivers/notion.manifest.yaml](appendix/drivers/notion.manifest.yaml) | §8 L3 Driver — Notion (optional) |
| [appendix/drivers/none.manifest.yaml](appendix/drivers/none.manifest.yaml) | §8 L3 Driver — None (Phase 1 default) |

#### Templates (5)
| 파일 | 역할 |
|------|------|
| [appendix/templates/plan.md](appendix/templates/plan.md) | §4 PDCA Plan 템플릿 |
| [appendix/templates/design.md](appendix/templates/design.md) | §4 PDCA Design 템플릿 |
| [appendix/templates/analysis.md](appendix/templates/analysis.md) | §4 PDCA Analysis/Check 템플릿 |
| [appendix/templates/report.md](appendix/templates/report.md) | §4 PDCA Report/Act 템플릿 |
| [appendix/templates/brainstorm.md](appendix/templates/brainstorm.md) | §4 G0 Brainstorm 템플릿 (Initiative 진입) |

#### Hooks & Tooling & Samples (3)
| 파일 | 역할 |
|------|------|
| [appendix/hooks/observability-sync.sample.ts](appendix/hooks/observability-sync.sample.ts) | §8 동기화 Hook 샘플 구현 |
| [appendix/tooling/sfs-doc-validate.md](appendix/tooling/sfs-doc-validate.md) | 의존성 검증 도구 스펙 |
| [appendix/samples/plugin.json.sample](appendix/samples/plugin.json.sample) 🆕 WU-7 | §7.2 plugin.json 전체 예시 — Phase 1 W13 `claude plugin install solon` seed 매니페스트 (필드 의미 SSoT: 07 §7.2.1/§7.2.2) |

#### Reviews (3) — 설계 검토 메모
| 파일 | 역할 |
|------|------|
| [appendix/reviews/2026-04-28-startup-team-agent-flow-review.md](appendix/reviews/2026-04-28-startup-team-agent-flow-review.md) | 사용자 8단계 startup team-agent flow 리뷰 + v0.4 outline 수정 근거 + Claude 반박 예상 답변 |
| [appendix/reviews/2026-04-28-foundation-structural-defects-review.md](appendix/reviews/2026-04-28-foundation-structural-defects-review.md) | docset AGENTS missing target + README/§10/template/MVP-dist drift 수정 근거 + 남은 foundation 리스크 |
| [appendix/reviews/2026-04-29-contradiction-sweep.md](appendix/reviews/2026-04-29-contradiction-sweep.md) | v0.4-r4 모순 전수검사 결과 + 수정 내역 + historical exception 기준 |

#### Phase 1 에서 생성 예정 (미존재 ❌)
| 파일 | 역할 |
|------|------|
| appendix/schemas/g-1-signature.schema.yaml | §5.11 G-1 Intake 서명 schema (Phase 1 W9) |
| appendix/schemas/discovery-report.schema.yaml | §4.3.11 P-1 Discovery Report 9-섹션 validation (Phase 1 W10) — 04/07 에서 "v1 frozen" 표현은 설계 의도 / 실물 Phase 1 |
| appendix/schemas/existing-implementation.schema.yaml | §4.3.11 P-1 evidence yaml validation (Phase 1 W10) |
| appendix/templates/discovery-report.template.md | §4 P-1 Discovery 템플릿 (Phase 1 W10) — `discovery-report.md` 로도 지칭되지만 템플릿은 `.template.md` 접미사 |
| appendix/dialogs/phase-a~e.md (5) | §2.13 Socratic 5-phase dialog 개별 템플릿 (Phase 1 W1~W2) — 현재는 `division-activation.dialog.yaml` 통합 spec 으로 대체. README.md 는 ✅ WU-4 선제 생성 (index 허브 역할) |
| appendix/engines/dialog-engine.md | §2.13 Socratic 5-phase dialog 상태 머신 spec (Phase 1 W1~W2) |
| src/engines/dialog-engine.ts (코드) | §02 §2.13 Socratic 5-phase dialog state machine 구현 (Phase 1 D1~D2) |
| src/engines/alternative-suggestion-engine.ts (코드) | §02 §2.13 3-tier × 3-level intensity 대안 엔진 구현 (Phase 1 D1~D2) |

---

## 2. 의존성 그래프 (DAG)

```
                                         ┌──────────────────┐
                                         │   00-intro       │
                                         └────────┬─────────┘
                                                  │
                          ┌───────────────────────┼───────────────────────┐
                          ▼                       ▼                       ▼
                 ┌──────────────┐       ┌──────────────────┐    ┌──────────────────┐
                 │  01-delta    │       │ 02-principles    │    │  (glossary)      │
                 └──────────────┘       └────────┬─────────┘    └──────────────────┘
                                                  │
                                                  ▼
                                       ┌────────────────────┐
                                       │  03-c-level-matrix │
                                       └────────┬───────────┘
                                                  │
                                                  ▼
                                       ┌────────────────────┐
                                       │  04-pdca-redef     │
                                       └────────┬───────────┘
                                                  │
                              ┌───────────────────┼───────────────────┐
                              ▼                   ▼                   ▼
                    ┌──────────────────┐  ┌──────────────┐  ┌──────────────────┐
                    │ 05-gate-framework│  │              │  │                  │
                    └────────┬─────────┘  │              │  │                  │
                             │            │              │  │                  │
                             ▼            │              │  │                  │
                    ┌──────────────────┐  │              │  │                  │
                    │ 06-escalate-plan │──┘              │  │                  │
                    └────────┬─────────┘                 │  │                  │
                             │                           │  │                  │
                             ▼                           │  │                  │
                    ┌──────────────────┐                 │  │                  │
                    │ 07-plugin-dist   │ (정적 구조)       │  │                  │
                    └────────┬─────────┘                    │                  │
                             │                              │                  │
                             ▼                              │                  │
                    ┌──────────────────┐                    │                  │
                    │ 08-observability │─────────────────┘  │                  │
                    │ (런타임 + hook)   │                                       │
                    └────────┬─────────┘                                       │
                             │                              │                  │
                             ▼                              │                  │
                    ┌──────────────────┐                    │                  │
                    │ 09-differentiation                                        │
                    └────────┬─────────┘                                        │
                             │                                                  │
                             ▼                                                  │
                    ┌──────────────────┐                                        │
                    │ 10-phase1-impl   │◀───────────────────────────────────────┘
                    └──────────────────┘
```

---

## 3. 권장 읽기 순서 (Role별)

### 3.0 10분 overview (최단 경로)
`README.md` 만 읽어도 전체 구조 파악 가능. 그 다음 필요한 섹션으로 drill-down.

### 3.1 완전 신규 독자 (전체 그림)
`README.md → 00 → 01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10`

### 3.2 v0.3를 이미 읽은 독자 (v0.4-r3 기준)
`01 (Delta만) → 02 (§2.10~2.13 원칙 10/11/12/13) → 03 (§3.3.0 activation_state) → 05 (§5.11 G-1) → 06 → 09`

### 3.3 구현자 (Phase 1 개발 시작)
`10 (implementation plan) → 03 (조직도) → 04 (PDCA 흐름, P-1 포함) → 05 (Gate 규칙, G-1 포함) → 07 (plugin 구조) → appendix/commands/ + templates + schemas`

### 3.4 평가자 / Gate Operator
`03 (본부 역할) → 04 (PDCA 산출물) → 05 (G-1 + G1~G5 매트릭스) → appendix/schemas/gate-report.schema.yaml → appendix/commands/handoff|check|retro.md`

### 3.5 관측성 / 운영자
`08 (3-Channel) → appendix/hooks/observability-sync.sample.ts → appendix/drivers/_INTERFACE.md → 06 (learning log 저장 위치)`

### 3.6 의사결정자 (투자자 / 공동창업자 후보)
`README.md → 00 → 02 → 09 → 10.5 (성공 기준)`

### 3.7 Brownfield 사용자 (기존 repo 에 Solon 도입) — v0.4-r2
`README.md §3.3 → 07 §7.10 (brownfield plugin) → 02 §2.11/§2.12 (원칙 11/12) → 04 §4.3 (P-1) → 05 §5.11 (G-1) → appendix/commands/install.md + discover.md → 10 §10.6.5 (brownfield dogfooding)`

### 3.8 Progressive Activation / 본부 활성 관리 독자 🆕 v0.4-r3
`README.md §3.3 + §11 Glossary (activation_state/scope) → 02 §2.13 (원칙 13) + §2.14 (의존 그래프) → 03 §3.3.0 (Division Activation State) + §3.7 (Phase 1 Baseline) → appendix/dialogs/README.md (✅ WU-4 index 허브) → appendix/engines/alternative-suggestion-engine.md (✅ R3) → appendix/dialogs/division-activation.dialog.yaml (✅ R3 통합 spec) → appendix/commands/division.md → appendix/schemas/dialog-state.schema.yaml + divisions.schema.yaml`

> 🚧 `appendix/engines/dialog-engine.md` + `phase-a~e.md` 는 Phase 1 W1~W2 구현 시 생성 예정 (현재는 `division-activation.dialog.yaml` 한 파일이 통합 dialog spec 역할). `appendix/dialogs/README.md` 는 ✅ WU-4 (2026-04-20) 선제 생성 — index 허브.

---

## 4. 정의 대 참조 요약 테이블 (Cross-Reference Matrix)

> **용도**: "이 개념은 어디서 정의되고, 어디서 쓰이는가?" 를 한 눈에 파악.
> 각 본문 파일의 frontmatter에서 자동 집계 가능 (sfs-doc-validate 도구가 생성).

| 개념 / 스키마 | 정의 (defines) | 주요 사용처 (references) |
|--------------|---------------|------------------------|
| **Brand / Naming** | | |
| `brand/solon` | README.md + 00 | 전 문서 |
| `cli/sfs-prefix` | README.md + appendix/commands/README.md | 전 command spec |
| **Principles (13)** | | |
| `principle/domain-agnostic-framework` (#1) | 02 §2.1 | 03, 07, 10 |
| `principle/self-validation-forbidden` (#2) | 02 §2.2 | 03, 04, 05, appendix/commands/handoff.md, escalate.md |
| `principle/gate-operator` (#3) | 02 §2.3 | 03, 05, 06, appendix/commands/design.md, plan.md, do.md, handoff.md |
| `principle/model-allocation` (#4) | 02 §2.4 | 03, 10, 전 command spec |
| `principle/sprint-superset-pdca` (#5) | 02 §2.5 | 03, 04, 10 |
| `principle/local-state-private` (#6) | 02 §2.6 | 08 |
| `principle/cli-gui-shared-backend` (#7) | 02 §2.7 | 07 |
| `principle/phase1-phase2-separation` (#8) | 02 §2.8 | 07, 10 |
| `principle/brainstorm-gate-mandatory` (#9) | 02 §2.9 | 03, 04, 05, appendix/commands/brainstorm.md |
| `principle/human-final-filter` (#10) | 02 §2.10 | 04, 05, appendix/commands/check.md, escalate.md |
| `principle/brownfield-first-pass` (#11) | 02 §2.11 | 04, 05, 07, 10 |
| `principle/brownfield-no-retro-brainstorm` (#12) | 02 §2.12 | 04, 05, appendix/commands/brainstorm.md, discover.md |
| `principle/progressive-activation` (#13) 🆕 R3 | 02 §2.13 | 03 §3.3.0/§3.7, README, appendix/commands/install.md, division.md, engines/*, dialogs/* |
| `principle/non-prescriptive-guidance` (#13) 🆕 R3 | 02 §2.13 | 03, appendix/engines/alternative-suggestion-engine.md, dialogs/phase-d-option-card.md |
| **Division Activation (v0.4-r3)** 🆕 R3 | | |
| `concept/division-activation-state` | 02 §2.13 + 03 §3.3.0 | README, appendix/commands/division.md, appendix/schemas/divisions.schema.yaml |
| `enum/activation-state-3` (abstract/active/deactivated) | 03 §3.3.0 + appendix/schemas/divisions.schema.yaml | 전 division 행 + appendix/commands/division.md |
| `enum/activation-scope-3` (full/scoped/temporal) | appendix/schemas/divisions.schema.yaml v1.1 | 03 §3.3.0, appendix/commands/division.md |
| `rule/parent-division-required-when-scoped` | appendix/schemas/divisions.schema.yaml v1.1 | 03 §3.3.0 |
| `rule/sunset-at-required-when-temporal` | appendix/schemas/divisions.schema.yaml v1.1 | 03 §3.3.0, appendix/commands/division.md |
| `phase/phase-1-basic-active-set` (dev + strategy-pm only) | 03 §3.7 + 10 §10.5.1 | README §9, appendix/commands/install.md |
| **Socratic Dialog (v0.4-r3)** 🆕 R3 — 🚧 `engines/dialog-engine.md` + `phase-a~e.md` 는 Phase 1 W1~W2 작성 예정. `dialogs/README.md` 는 ✅ WU-4 (2026-04-20) 선제 생성 (§5 Dialogs 표 참조) | | |
| `concept/socratic-5-phase-dialog` | 02 §2.13 + 🚧 appendix/engines/dialog-engine.md (Phase 1) + [appendix/dialogs/division-activation.dialog.yaml](appendix/dialogs/division-activation.dialog.yaml) | 🚧 appendix/dialogs/phase-*.md (Phase 1), appendix/commands/install.md, division.md |
| `enum/dialog-phase-a-to-e` | [appendix/dialogs/README.md](appendix/dialogs/README.md) ✅ WU-4 (재서술, 정의는 dialog yaml `states`) + [appendix/schemas/dialog-state.schema.yaml](appendix/schemas/dialog-state.schema.yaml) | 🚧 appendix/engines/dialog-engine.md (Phase 1) |
| `format/dialog_trace_id` (`dlg-YYYY-MM-DD-<target-id>-<seq>`) | [appendix/schemas/dialog-state.schema.yaml](appendix/schemas/dialog-state.schema.yaml) | 🚧 appendix/dialogs/phase-*.md (Phase 1), appendix/commands/install.md, division.md, [appendix/schemas/l1-log-event.schema.yaml](appendix/schemas/l1-log-event.schema.yaml) |
| `schema/dialog-state-v1` | [appendix/schemas/dialog-state.schema.yaml](appendix/schemas/dialog-state.schema.yaml) | 🚧 appendix/engines/dialog-engine.md (Phase 1), 🚧 전 dialogs/phase-*.md (Phase 1) |
| **Alternative Suggestion Engine (v0.4-r3)** 🆕 R3 | | |
| `engine/alternative-suggestion` | [appendix/engines/alternative-suggestion-engine.md](appendix/engines/alternative-suggestion-engine.md) ✅ | 🚧 appendix/dialogs/phase-d-option-card.md (Phase 1) |
| `structure/3-tier-alternatives` | [appendix/engines/alternative-suggestion-engine.md](appendix/engines/alternative-suggestion-engine.md) ✅ | 🚧 appendix/dialogs/phase-d-option-card.md (Phase 1) |
| `enum/3-level-intensity` (👍 권장 / ⚪ 중립 / ⚠ 비권장) | [appendix/engines/alternative-suggestion-engine.md](appendix/engines/alternative-suggestion-engine.md) ✅ | 🚧 appendix/dialogs/phase-d-option-card.md (Phase 1), README §11 |
| `invariant/alt-inv-1-always-three-tiers` | [appendix/engines/alternative-suggestion-engine.md](appendix/engines/alternative-suggestion-engine.md) ✅ | 🚧 appendix/dialogs/phase-d-option-card.md (Phase 1) |
| `invariant/alt-inv-2-exactly-one-thumbs-up` | [appendix/engines/alternative-suggestion-engine.md](appendix/engines/alternative-suggestion-engine.md) ✅ | 🚧 appendix/dialogs/phase-d-option-card.md (Phase 1) |
| `invariant/alt-inv-3-never-hard-block` | [appendix/engines/alternative-suggestion-engine.md](appendix/engines/alternative-suggestion-engine.md) ✅, 02 §2.13 | 🚧 전 dialogs/phase-*.md (Phase 1), appendix/commands/division.md, install.md |
| `invariant/inv-5-division-command-user-only` | appendix/commands/division.md | README §6, 03 |
| **Organization (C-Level × Division)** | | |
| `role/ceo`, `role/cto`, `role/cpo` | 03 | 04, 05, 06, 07, appendix/commands/retro.md, escalate.md |
| `division/strategy-pm` (구 `division/pm`, 🆕 R3 rename) | 03 §3.3.1 | 04, 05, 08, 10, 전 command spec |
| `division/*` (6개: strategy-pm / taxonomy / design / dev / qa / infra) | 03 | 04, 05, 08, 10, 전 command spec |
| `concept/evaluator-pool` | 03 | 05, 06 |
| `rule/model-allocation` | 03 | 10, 전 command spec |
| **PDCA Runtime** | | |
| `concept/initiative` | 04 | 02, 03, 06, 10 |
| `concept/sprint` | 04 | 02, 05, 06, 08, 10 |
| `concept/pdca-phase` | 04 | 05, 06, 08 |
| `phase/p-1-discovery` 🆕 | 04 §4.3 | 05, 07, 10, appendix/commands/discover.md |
| `rule/brownfield-discovery-read-only` 🆕 | 04 §4.3 | 07, 10, appendix/commands/discover.md |
| `template/plan-pdca`, `design-pdca`, `analysis-pdca`, `report-pdca` | 04 | appendix/templates |
| `template/brainstorm` | appendix/templates/brainstorm.md | 02, 04, appendix/commands/brainstorm.md |
| `template/discovery-report` 🆕 | 04 (+ Phase 1 W10) | 05, appendix/commands/discover.md |
| **Gates (6)** | | |
| `gate/g-1-intake` 🆕 | 05 §5.11 | 04, 07, 10, appendix/commands/install.md, discover.md |
| `gate/g0-brainstorm` | 04, 05 | 02, 10, appendix/commands/brainstorm.md |
| `gate/g1-plan-gate` | 05 | 06, 08, 10, appendix/commands/plan.md |
| `gate/g2-design-gate` | 05 | 06, 08, 10, appendix/commands/design.md |
| `gate/g3-pre-handoff-gate` | 05 | 06, 08, 10, appendix/commands/handoff.md |
| `gate/g4-check-gate` | 05 | 06, 08, 10, appendix/commands/check.md |
| `gate/g5-sprint-retro-gate` | 05 | 06, 08, 10, appendix/commands/retro.md |
| `formula/g4-per-division` | 05 §5.5 | 10, appendix/commands/check.md |
| `concept/5-axis-cpo-evaluation` | 05 §5.6 | 10, appendix/commands/check.md, escalate.md |
| `schema/gate-call-contract` | 05 | 06, 08, appendix/schemas |
| `schema/gate-report-v1` | 05 + appendix/schemas/gate-report.schema.yaml | 06, 08 |
| `schema/g-1-signature-v1` 🆕 | 05 §5.11 (+ Phase 1 W9) | 07, appendix/commands/install.md |
| `enum/failure-mode-7` | 05 | 06 |
| **Evaluators (8)** | | |
| `evaluator/plan-validator` | 10 §10.2.2 | 05, appendix/commands/plan.md |
| `evaluator/design-validator` | 10 §10.2.2 | 05, appendix/commands/design.md |
| `evaluator/user-flow-validator` | 10 §10.2.2 | 05, appendix/commands/design.md |
| `evaluator/cost-estimator` | 10 §10.2.2 | 05, appendix/commands/design.md, retro.md |
| `evaluator/gap-detector` (bkit 재활용) | 10 §10.3 | 05, appendix/commands/handoff.md, check.md |
| `evaluator/code-analyzer` (bkit 재활용) | 10 §10.3 | 05, appendix/commands/handoff.md |
| `evaluator/qa-monitor` (bkit 재활용) | 10 §10.3 | 05, appendix/commands/check.md |
| `evaluator/discovery-report-validator` 🆕 | 05 §5.11.2 + 10 §10.2.2 | appendix/commands/discover.md |
| **Escalate** | | |
| `concept/escalate-plan` | 06 | 08 (L2 로그), 09 (H6 차별화) |
| `concept/case-alpha`, `case-beta`, `case-gamma` | 06 | appendix/commands/escalate.md |
| `concept/5-option-protocol` | 06 §6.5 | appendix/commands/escalate.md |
| `concept/ac-level-reopen` | 06 | appendix/commands/escalate.md |
| `schema/escalation-v1` | 06 + appendix/schemas/escalation.schema.yaml | 08 |
| `concept/h6-self-learning` | 06 | 09 (차별화 축) |
| **Commands (13 slash commands) — internal gate dispatcher 제외** | | |
| `schema/command-spec-v1` | appendix/commands/README.md | 전 command spec |
| `command/sfs-install` (Socratic wizard 포함) | appendix/commands/install.md | 07, 10, 02 §2.13 |
| `command/sfs-discover` | appendix/commands/discover.md | 04, 05 |
| `command/sfs-brainstorm` | appendix/commands/brainstorm.md | 02, 04 |
| `command/sfs-plan` | appendix/commands/plan.md | 04, 05 |
| `command/sfs-design` | appendix/commands/design.md | 04, 05 |
| `command/sfs-do` | appendix/commands/do.md | 04 |
| `command/sfs-handoff` | appendix/commands/handoff.md | 04, 05 |
| `command/sfs-check` | appendix/commands/check.md | 04, 05 |
| `command/sfs-act` | appendix/commands/act.md | 04, 06 |
| `command/sfs-retro` | appendix/commands/retro.md | 04, 05 |
| `command/sfs-escalate` | appendix/commands/escalate.md | 06 |
| `command/sfs-status` | appendix/commands/status.md | 08 |
| `command/sfs-division` 🆕 R3 (**user-only**, INV-5) | appendix/commands/division.md | 02 §2.13, 03 §3.3.0, README §6 |
| **Plugin & Tier** | | |
| `concept/solon-plugin` (구 sfs-plugin) | 07 | 10 |
| `structure/solon-plugin-tree` | 07 | 10 |
| `phase/phase1-scope`, `phase/phase2-roadmap` | 07 | 10 |
| `rule/divisions-yaml-customization` | 07 | 10 |
| `concept/cli-cowork-shared-fs` | 07 | — |
| `tier/minimal` 🆕, `tier/standard` 🆕, `tier/collab` 🆕 | 07 §7.3 | 10 §10.10 |
| `mode/greenfield` 🆕, `mode/brownfield` 🆕 | 07 | 04, 05, 10 |
| **Observability (3-Channel)** | | |
| `channel/l1-s3`, `channel/l2-git`, `channel/l3-driver` | 08 | 07 (plugin hook 위치 참조) |
| `rule/unidirectional-sync` | 08 | 07 |
| `rule/l3-no-backfill` 🆕 | 08 §8.11 | 07, 10 |
| `concept/ssot-l2` | 08 | — |
| `concept/observability-hook` | 08 | 07 (plugin이 hook 패키징) |
| `rule/local-state-gitignore` | 08 | — |
| `schema/l1-log-event` | 08 + appendix/schemas/l1-log-event.schema.yaml | — |
| `schema/divisions-yaml-v1` | appendix/schemas/divisions.schema.yaml | 07, 10 |
| `contract/l3-driver-interface-v1` | appendix/drivers/_INTERFACE.md | 07, 08 |
| `driver/notion-manifest-v1` | appendix/drivers/notion.manifest.yaml | 07, 08 |
| `driver/none-manifest-v1` | appendix/drivers/none.manifest.yaml | 07, 08 |
| `rule/driver-manifest-required-fields` | appendix/drivers/_INTERFACE.md | 07 |
| `rule/driver-compatibility-warn-not-block` | appendix/drivers/_INTERFACE.md | 07 |
| **Differentiation & Phase 1** | | |
| `axis/h1~h6` | 09 | 10.5 (Phase 1 차별화 검증 기준) |
| `plan/phase1-scope-final` | 10 | — (최종 섹션) |
| `schedule/phase1-week-breakdown` | 10 | — (16~20주, tier=minimal 기본) |
| `criteria/phase1-success` | 10 | — |
| `gate/phase1-to-phase2-transition` | 10 | — |
| `concept/phase1-seed-patterns` | 10 | — |
| `scenario/brownfield-dogfooding` 🆕 | 10 §10.6.5 | — (W19 optional) |

---

## 5. 수정 시 영향 전파 규칙

문서 수정 시 반드시 다음 절차를 따른다.

1. 수정할 파일의 frontmatter `affects` 필드 확인
2. `affects`에 나열된 모든 파일의 해당 부분 재검토
3. `defines` 필드에 명시된 개념을 수정했다면, **전체 문서셋에서 해당 개념을 `references`하는 모든 파일** 동기화
4. `sfs-doc-validate` 실행 (Phase 1 tooling)
5. `status: locked` 파일은 변경 금지. 변경이 필요하면 먼저 `status: review`로 내리고 INDEX에 공지

---

## 6. 검증 도구 (Phase 1 동반 구현)

[appendix/tooling/sfs-doc-validate.md](appendix/tooling/sfs-doc-validate.md) 참조.

핵심 검사:
- `defines` / `references` 일치 (dangling reference 검출)
- `depends_on` 그래프의 DAG 성립 (순환 검출)
- `affects` 쌍방향 일관성 (A.affects=[B] 이면 B.depends_on ⊇ {A} 이거나 B가 A를 references)
- `status: locked` 파일의 무단 변경 감지 (git blame 기반)

---

## 7. 변경 이력 (이 INDEX 기준)

| 날짜 | 버전 | 변경 요약 |
|------|------|----------|
| 2026-04-19 | v0.4-skeleton | 전체 뼈대 최초 작성 (frontmatter only) |
| 2026-04-19 | v0.4-draft | §00~§10 본문 풀 작성 완료, appendix 10 파일 완결 (schemas 4 + templates 4 + hooks 1 + tooling 1) |
| 2026-04-20 | v0.4-r1 | **원칙 9 추가** (`brainstorm-gate-mandatory`) + **Initiative 레이어 도입** (Initiative ⊃ Sprint ⊃ PDCA 3 레이어 위계). G0 Brainstorm Gate · `concept/initiative` · `gate/g0-brainstorm` · `template/brainstorm` 신규. §02/§03/§04 + INDEX cross-ref 동기화. L3 Driver Interface (`contract/l3-driver-interface-v1`) + notion/none manifest 3종 appendix 추가. `principle/worker-parallelism` 별도 항목화. |
| 2026-04-20 | v0.4-r2 | brownfield 대응 + 브랜드 정식화 + command spec 정식화 대규모 업데이트. (1) 원칙 10 `human-final-filter` + 11 `brownfield-first-pass` + 12 `brownfield-no-retro-brainstorm` 3개 신규. (2) P-1 Discovery Phase (§4.3) + G-1 Intake Gate (§5.11) 추가. (3) 13개 `/sfs *` command spec 정식화. (4) README.md 신규. (5) Solon brand 정식화. (6) Tier Profile + L3 backend driver 일반화. (7) 8개 evaluator. (8) §00-intro 제품 철학 선언 블록. (9) §07 plugin tier + §7.10 brownfield plugin. (10) §08 L3 driver 일반화. (11) §10 Budget/Risk 재계산. (12) cross-reference defect 8 occurrence 수정. |
| **2026-04-20** | **v0.4-r3** | **Progressive Activation + Non-Prescriptive Guidance 대규모 확장**. (1) **원칙 13 `progressive-activation-non-prescriptive-guidance`** 신규 (§02 §2.13 + §2.14 의존 그래프). (2) **activation_state** 3-state (abstract/active/deactivated) + **activation_scope** 3-scope (full/scoped/temporal) 도입 — §03 §3.3.0 Division Activation State 신설, 전 division 행에 activation_state 반영, §3.7 Phase 1 Baseline 재작성 (active worker 수 before/after 비교표 포함). (3) `divisions.schema.yaml` **v1.1** 확장 — activation_state/scope/parent_division/sunset_at 4 필드 + 13 validation rule. (4) **Socratic 5-phase dialog** 표준화 — appendix/dialogs/ 6개 파일 (README + phase-a~e), appendix/engines/dialog-engine.md 신설, `dialog-state.schema.yaml` 신규, `dialog_trace_id` format `dlg-YYYY-MM-DD-<target-id>-<seq>` 표준. (5) **Alternative Suggestion Engine** 도입 — appendix/engines/alternative-suggestion-engine.md 신설, 3-tier × 3-level intensity (👍 권장 / ⚪ 중립 / ⚠ 비권장), ALT-INV-1 (항상 3-tier) / ALT-INV-2 (정확히 1개 👍) / **ALT-INV-3 never-hard-block**. (6) `/sfs division` command 신설 — appendix/commands/division.md, **user-only** (INV-5 agent auto-invocation 금지), L1 event `division.activation.changed`. (7) `/sfs install` 에 Socratic wizard 통합. (8) **`division/pm` → `division/strategy-pm`** rename (§03 §3.3.1, agent id 포함). (9) **Phase 1 basic active = dev + strategy-pm 2개만**, 나머지 4개 (qa/design/infra/taxonomy) abstract, 필요 시 `/sfs division activate` 로 확장. (10) README.md §4 13대 원칙 표 + 이중 방어선 2행 추가 (원칙 13 × 10, 원칙 13 × 1) + §6 command registry + §10 파일 맵 확장 + §11 Glossary 7개 용어 추가 (activation_state/scope, Progressive Activation, Non-Prescriptive Guidance, Socratic dialog, dialog_trace_id, /sfs division) + §12 Changelog v0.4-r3 entry. (11) INDEX.md §1/§3.8/§4/§7 동기화. |
| **2026-04-28** | **v0.4-r4** | **기초공사 구조 보강**. (1) AGENTS bootstrap shim 신설 및 root redirect 정합. (2) startup team-agent 13-step artifact chain 과 Artifact Contract First 를 §04 에 반영. (3) G0/Release Readiness gate vocabulary 를 §05/schema/README/§10 에 정합. (4) Foundation Invariants FI-1~4 추가. (5) MVP 7-step projection 경계와 Release Readiness evidence 를 phase1 templates 및 solon-mvp-dist 에 명시. (6) appendix/templates 에 taxonomy_contract / Release Readiness evidence slot 추가. (7) 구조 리뷰 문서 2건 추가. |
| — | v0.4-review | 내부 리뷰 완료 (예정) |
| — | v0.4-locked | Phase 1 착수 전 락 (예정) |

---

*(끝)*
