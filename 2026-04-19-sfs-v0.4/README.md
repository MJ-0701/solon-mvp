# Solon

> **6명의 본부장이 있는 회사를, 1명으로 운영하는 OS.**
> PDCA · Gate · Division — 3가지 primitive 로 "회사를 코드처럼" 돌리는 솔로 창업가 전용 AI-native 조직 시뮬레이터.

`docset version: v0.4-r3` · `last_updated: 2026-04-20` · `status: draft (design)` · `audience: 채명정 본인 (Phase 1) → 자영업자/솔로 창업가 (Phase 2)`

---

## 1. Solon 한 줄 소개

**Solon** 은 "회사가 아닌 1명"이 **Strategy/PM · Taxonomy · Design · Dev · QA · Infra** 6개 본부를 동시 운영할 수 있도록, 각 본부장을 LLM 오퍼레이터(Sonnet Lead)로 대리하고, 본부장 간 조정을 PDCA 사이클과 Gate 검증으로 강제하는 **도메인 agnostic 조직 OS** 다.

- **제품명 (Brand)**: Solon
- **CLI prefix**: `/sfs` (Solo Founder System — 내부 명칭, 브랜드와 분리)
- **Phase 1 target**: 채명정 본인 dogfooding (product-image-studio 를 첫 Initiative 로)
- **Phase 2 target**: 자영업자/솔로 창업가가 install 한 번으로 자기 조직을 돌릴 수 있게 상품화

---

## 2. 이 docset은 무엇인가

이 폴더(`2026-04-19-sfs-v0.4/`) 는 **Solon 제품의 설계 Docset v0.4-r3** 다. 코드가 아니라 **설계 문서의 집합** 이며, Phase 1 구현은 이 docset 을 스펙으로 삼아 별도 저장소에서 진행된다.

### 이 docset의 3가지 역할

| 역할 | 의미 | 확인 방법 |
|------|------|-----------|
| **스펙 문서** | Phase 1 구현 agent 들이 읽고 따라 만드는 소스 오브 트루스 | 각 섹션의 `defines:` frontmatter |
| **설계 근거** | 왜 이 결정을 했는지의 근거 (원칙 → 결정 → 구현) 트레이싱 | `references:` + `affects:` 필드 |
| **계약서** | 본부장 agent / Evaluator / 사람 간 권한과 책임 경계 | §2 원칙 + §5 Gate + §6 Escalate |

### 이 docset이 아닌 것

- ❌ 구현 코드 (별도 레포 — `solon-phase1/` 이 Phase 1 에서 생성됨)
- ❌ 실행 가능한 CLI (설계만, 실행 바이너리는 `/sfs install` 의 Phase 1 산출)
- ❌ 마케팅 자료 (§9 차별화는 내부 경쟁 분석 용도)

### 읽는 순서 (권장)

1. **§00-intro.md** — 왜 Solon 인가 (2 제품 철학 선언)
2. **§02-design-principles.md** — 13대 원칙 (전체 의사결정 근거, 원칙 13 = Progressive Activation + Non-Prescriptive Guidance)
3. **§04-pdca-redef.md** + **§05-gate-framework.md** — Runtime
4. **§10-phase1-implementation.md** — 실제 16~20주 구현 플랜
5. **나머지는 need-basis** — 상황에 맞춰 INDEX.md 로 내비

---

## 3. 빠른 시작 (3-minute tour)

### 3.1 한 장으로 보는 Solon 구조

```
┌────────────────────────────────────────────────────────────────┐
│  사용자 1명 (채명정)                                              │
│                                                                 │
│  ↓ 의도 선언 (G0 Brainstorm Gate) — 철학 ① 작동                  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Initiative ⊃ N Sprint ⊃ N PDCA (3-layer hierarchy)      │    │
│  │                                                          │    │
│  │  PDCA 사이클 = P-1(brownfield) + Plan + Do + Check + Act │    │
│  │                                                          │    │
│  │  각 phase마다 Gate: G-1 / G1 / G2 / G3 / G4 / G5         │    │
│  │                                                          │    │
│  │  6 Division × 3 C-Level(CEO/CTO/CPO) 오퍼레이터          │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ↓ G4 수락 (사람 직접 실행·판정) — 철학 ② 작동                    │
│                                                                 │
│  산출물 → L1 events / L2 git / L3 driver (notion|none|...)      │
└────────────────────────────────────────────────────────────────┘
```

### 3.2 가장 빠른 실행 흐름 (Greenfield)

```bash
# 1. 새 Initiative 시작 (G0 Brainstorm 필수)
/sfs brainstorm --initiative my-first-initiative

# 2. Initiative 안에서 PDCA 1개 계획
/sfs plan --feature auth-refactor --initiative my-first-initiative --sprint S-2026-W17

# 3. Design → Do → Handoff → Check
/sfs design   --feature auth-refactor --division dev
/sfs do       --feature auth-refactor --division dev
/sfs handoff  --feature auth-refactor --division dev
/sfs check    --feature auth-refactor

# 4. Sprint 종료 retrospective
/sfs retro --sprint S-2026-W17
```

### 3.3 Brownfield (기존 코드베이스에 설치) 흐름

```bash
# 1. 설치 (tier 선택, default = minimal)
/sfs install --tier minimal
# → Socratic 5-phase dialog wizard 실행 (A Context → B Why-now → C Clarify → D Option Card → E Terminal)
# → 사용자가 시작 시 어떤 본부를 active 로 둘지 직접 선택 (원칙 13 Progressive Activation)

# 2. P-1 Discovery Phase (1회성, brownfield 전용)
/sfs discover
# → discovery-report.md 자동 생성 + G-1 Intake Gate 통과까지

# 3. 이후는 greenfield 와 동일 (/sfs plan …)
#    본부 활성화 상태는 /sfs division 으로 언제든 조회/변경 (사용자 전용 command)
```

---

## 4. 13대 원칙 요약표

> 전체 설계의 "헌법". 모든 /sfs command / Gate / Escalate 는 이 13개 원칙의 실질 구현.
> 자세한 내용은 [§02-design-principles.md](02-design-principles.md) 참조.

| # | 원칙 | 한 줄 요약 | 위반 시 효과 |
|---|------|-----------|-------------|
| 1 | 도메인 agnostic 프레임워크 + 도메인 specific evaluator | Framework 는 고정, Evaluator 만 도메인별로 교체 | 재사용성 상실, Phase 2 상품화 불가 |
| 2 | 자기검증 금지 (3-Tier Separation) | agent 가 자기 산출을 스스로 통과시키지 못함 | Gate FAIL-HARD |
| 3 | 본부장 = Gate Operator | 본부장은 판단자가 아니라 호출자 | Gate Operator 권한 박탈 |
| 4 | 모델 할당 규칙 | Opus(C-Level/Evaluator) / Sonnet(Lead/Worker) / Haiku(Helper) | 비용 폭주 또는 품질 저하 |
| 5 | Initiative ⊃ N Sprint ⊃ N PDCA (3 레이어) | 조직 주기 계층 고정 | 스케줄 충돌 |
| 6 | 로컬 상태 private, 공유는 git + Notion | `.solon/` 은 로컬 전용, SSoT 는 git | 상태 누수 / 충돌 |
| 7 | CLI + GUI 통합 백엔드 | `/sfs` 와 GUI 는 동일 백엔드 | 분기 유지 비용 |
| 8 | Phase 1 내부 사용 → Phase 2 상품화 | 본인 dogfooding 검증 전엔 상품화 불가 | 섣부른 출시 금지 |
| 9 | Initiative 진입 = G0 Brainstorm Gate 필수 | 설계 탄탄함의 기계적 강제 | Initiative 진입 거부 |
| 10 | 사람 최종 필터 (Human Final Filter) | G4 수락은 사람만 가능 | 자동 release 금지 |
| 11 | Brownfield First Pass | 기존 코드베이스는 P-1 Discovery 필수 | brownfield 에 G0 직행 금지 |
| 12 | Brownfield No Retro Brainstorm | 기존 코드를 이미 만든 사람에게 G0 요구 금지 | UX 붕괴 / 이중 작업 |
| 13 | Progressive Activation + Non-Prescriptive Guidance 🆕 | 본부는 단계적으로 열고, 시스템은 강제하지 않고 옵션만 제시 (ALT-INV-3 never-hard-block) | 사용자 선택권 박탈 / 초기 비용 폭주 |

### 원칙 간 이중 방어선

- **원칙 2 (agent↔agent 분리)** + **원칙 10 (system↔human 분리)** = 2-layer self-validation 차단
- **원칙 9 (진입 필터)** + **원칙 10 (출구 필터)** = 설계-검증 샌드위치
- **원칙 11 (brownfield 강제 Discovery)** + **원칙 12 (brownfield retro-brainstorm 금지)** = 기존 코드 UX 안전
- **원칙 13 (Progressive Activation)** + **원칙 10 (Human Final Filter)** = 사용자 주권 샌드위치 (시스템 제안 ↔ 사람 최종 결정)
- **원칙 13 (Non-Prescriptive Guidance)** + **원칙 1 (도메인 agnostic)** = Phase 2 tenant 자율성 보장 (본부 조합은 tenant 마다 다름)

---

## 5. PDCA 계층 & Gate

### 5.1 3-레이어 위계

```
Initiative                  (수개월, 전략 단위, 1 Initiative = 1 G0 Brainstorm)
  └─ Sprint                 (1~2주, 실행 단위, N개 PDCA 묶음)
       └─ PDCA              (1~수일, 기능 단위, 1 PDCA = Plan→Do→Check→Act)
```

### 5.2 PDCA Phase (원칙 11 로 P-1 추가)

| Phase | 설명 | Gate | 오퍼레이터 |
|-------|------|------|-----------|
| **P-1 Discovery** 🆕 | brownfield 전용 1회성 탐색 (greenfield skip) | **G-1 Intake** | strategy/pm/lead + 사람 서명 |
| Plan | PRD + AC 확정 | **G1 Plan** | strategy/pm/lead |
| Design | 본부별 설계 산출 | **G2 Design** | 각 본부장 (division-lead) |
| Do | 실제 구현 | (gate 없음, G3 에서 합산) | 각 본부 worker |
| (Do 종료 직후) | 본부장 사전 검수 | **G3 Pre-Handoff** | 본부장 (self-handoff 금지) |
| Check | Gap × 0.4 + 5-Axis × 0.6 | **G4 Check** | 본부장 + QA + CPO 3자 |
| Act | learnings / retro | — | 본부장 |
| (Sprint 종료) | 스프린트 회고 | **G5 Sprint Retro** | CEO + PM |

### 5.3 Gate 집합 (v0.4-r3 = 6개)

| Gate | 시점 | 오퍼레이터 | 모델 | 통과 조건 (요약) |
|------|------|-----------|------|------------------|
| **G-1 Intake** | brownfield install 직후 (1회성) | strategy/pm/lead + 사람 서명 | Sonnet + 사람 | `discovery-report.md` 완성 + 사람 서명 |
| G0 Brainstorm | Initiative 진입 전 (1회) | strategy/pm/lead | Opus | 6-필드 템플릿 완성 |
| G1 Plan | PRD 확정 시 | strategy/pm/lead | Opus (plan-validator) | AC 모두 measurable |
| G2 Design | 본부별 Design 완료 시 | 각 본부장 | Opus evaluator | 본부별 외부 evaluator PASS |
| G3 Pre-Handoff | Do 종료 직후 | 본부장 | Sonnet | preview_gap ≥ 85 + DoD 완료 |
| G4 Check | Check phase | 본부장 + QA + CPO | Opus | `Gap × 0.4 + 5-Axis × 0.6 ≥ 85` |
| G5 Sprint Retro | Sprint 종료 | CEO + PM | Opus | 모든 하위 PDCA resolve |

자세한 Gate 스펙은 [§05-gate-framework.md](05-gate-framework.md) 참조.

---

## 6. 14개 `/sfs *` command 개요

> 모든 command 는 `appendix/commands/<name>.md` 에 schema/command-spec-v1 형식으로 정의됨.
> 각 파일 상단 frontmatter 는 operator / model / cost budget / timeout 등 실행 계약을 명시한다.

| # | Command | Phase | Operator | 주 산출물 | Spec 파일 |
|---|---------|-------|----------|-----------|-----------|
| 1 | `/sfs install` | (install) | user | `.solon/config.yaml` | [install.md](appendix/commands/install.md) |
| 2 | `/sfs discover` | P-1 (brownfield) | strategy/pm/lead | `docs/00-governance/discovery-report.md` | [discover.md](appendix/commands/discover.md) |
| 3 | `/sfs brainstorm` | (Initiative 진입) | strategy/pm/lead | `initiatives/{id}/brainstorm-report.md` | [brainstorm.md](appendix/commands/brainstorm.md) |
| 4 | `/sfs plan` | Plan | strategy/pm/lead | `docs/01-plan/PDCA-{id}.plan.md` | [plan.md](appendix/commands/plan.md) |
| 5 | `/sfs design` | Design | 각 본부장 | `docs/02-design/PDCA-{id}.{division}.design.md` | [design.md](appendix/commands/design.md) |
| 6 | `/sfs do` | Do | 각 본부 worker | `src/**` + `docs/03-implementation/…work-log.md` | [do.md](appendix/commands/do.md) |
| 7 | `/sfs handoff` | Do→Check 경계 | 본부장 (self 금지) | `docs/03-implementation/…gate-g3.yaml` | [handoff.md](appendix/commands/handoff.md) |
| 8 | `/sfs check` | Check | 본부장 + QA + CPO | `docs/04-check/PDCA-{id}.gate-g4.yaml` | [check.md](appendix/commands/check.md) |
| 9 | `/sfs act` | Act | 본부장 | `docs/04-check/PDCA-{id}.learnings.md` | [act.md](appendix/commands/act.md) |
| 10 | `/sfs retro` | Sprint 종료 | CEO + PM | `docs/06-sprint/SPRINT-{id}.retro.md` | [retro.md](appendix/commands/retro.md) |
| 11 | `/sfs escalate` | any | 본부장 → PM → CEO | `docs/05-escalation/PDCA-{id}.escalate.md` | [escalate.md](appendix/commands/escalate.md) |
| 12 | `/sfs status` | any (read-only) | anyone | (stdout only) | [status.md](appendix/commands/status.md) |
| 13 | `/sfs division` 🆕 | any (user-only) | **user 전용** (agent 자동 호출 금지, INV-5) | `.solon/state/divisions.yaml` 갱신 + L1 event `division.activation.changed` | [division.md](appendix/commands/division.md) |
| 14 | (내부) `/sfs gate <id>` | Gate 호출 dispatcher | command 내부 | gate-report yaml | (각 command 에 embedded) |

전체 CLI 가이드는 [appendix/commands/README.md](appendix/commands/README.md) 참조.

---

## 7. 3-Channel Observability

Solon 은 산출물·이벤트·집계를 **3개 독립 채널**로 분리한다 (원칙 6 로컬 상태 private 의 실질 구현).

| Channel | 용도 | 저장소 | 기본값 |
|---------|------|-------|--------|
| **L1 — Events** | 실시간 상태 스트림 (gate start/end, escalate triggered 등) | S3 (또는 호환 object store) + append-only JSONL | ON (Phase 1 minimal tier 에서도 활성) |
| **L2 — Docs SSoT** | 영속 산출물 (plan/design/check/retro .md + gate yaml) | git (main repo) + post-commit hook | ON (필수) |
| **L3 — Driver** | 조직 외부 공유 채널 (사람이 읽기 쉬운 형태) | driver 선택 (notion / none / obsidian / logseq / confluence / custom) | `none` (Phase 1 default) |

- Phase 1 default: `L3 driver = none` (채명정 혼자 쓰므로 외부 공유 불필요)
- Phase 2 상품화 시점: tenant 별 L3 driver 선택 가능, driver 플러그인 계약은 §07, §08 참조.

자세한 3-channel 스펙은 [§08-observability.md](08-observability.md) 참조.

---

## 8. Tier Profile

> `/sfs install --tier <profile>` 로 선택. 기본값은 `minimal`. 조직 규모·비용·GUI 필요 여부에 따라 결정.

| Tier | 대상 | 기본 LLM | L3 driver | GUI | Phase 1 default |
|------|------|----------|-----------|-----|-----------------|
| **minimal** | 솔로 창업가 (Phase 1 채명정) | Sonnet + Opus (Evaluator/C-Level 만) | `none` | CLI only | ✅ |
| **standard** | 소규모 팀 (2~5명) | Sonnet + Opus 확장 | `notion` 또는 `obsidian` | optional GUI | — |
| **collab** | 5명+ + 여러 tenant | Sonnet + Opus + 병렬 agent | `confluence` 또는 `custom` | GUI 필수 | — |

**tier 선택 가이드:**
- 월 LLM 비용 ≤ $30 / 혼자 쓰기 / GUI 불필요 → `minimal`
- 팀원 1~2명이 본부 보조 / 외부 공유 문서 필요 → `standard`
- 여러 tenant / 다중 시간대 협업 / audit 필요 → `collab`

Tier 별 cost budget 은 [§10-phase1-implementation.md §10.4](10-phase1-implementation.md) 참조.

---

## 9. Phase 1 구현 현황

Phase 1 목표: **채명정 본인이 product-image-studio 를 첫 Initiative 로 Solon 위에서 완료**.

| Area | 상태 | 비고 |
|------|------|------|
| Docset v0.4-r3 | 🟢 설계 완료 (이 문서 포함) | Round 3 완료 → Phase 1 구현 진입 |
| 8 Evaluators (spec) | 🟢 정의 완료 | §10.2.2 참조 |
| Socratic dialog engine (spec) | 🟢 정의 완료 | 5-phase A~E, ALT-INV-1~3, §10.2.1 |
| Alternative suggestion engine (spec) | 🟢 정의 완료 | 3-tier × 3-level intensity, §10.2.1 |
| `/sfs install` (Socratic wizard 포함) | 🔴 미구현 | 16~20주 플랜 W1 |
| `/sfs brainstorm`/`plan`/`design` | 🔴 미구현 | 16~20주 플랜 W2-W8 |
| `/sfs do`/`handoff`/`check` | 🔴 미구현 | 16~20주 플랜 W9-W14 |
| `/sfs retro`/`escalate`/`division` | 🔴 미구현 | 16~20주 플랜 W15-W20 |
| L1/L2 channel | 🟡 스펙 완료 | bkit 재활용 가능 |
| L3 driver (notion plugin) | 🔴 Phase 2 | Phase 1 에선 `none` |

16~20주 세부 플랜은 [§10-phase1-implementation.md](10-phase1-implementation.md) 참조.

---

## 10. Docset 파일 맵

```
2026-04-19-sfs-v0.4/
├── README.md                          ← 이 문서 (10분 overview)
├── INDEX.md                           ← 전체 문서 navigation hub + cross-ref
├── HANDOFF-next-session.md            ← 다음 세션 작업 지시 (git 포함 — MIG-10 이후 cross-account carrier)
│
├── 00-intro.md                        Elevator pitch + 2 제품 철학 선언
├── 01-delta-v03-to-v04.md             v0.3 → v0.4 변경 diff
├── 02-design-principles.md            13대 원칙 전문 (원칙 13 = Progressive Activation)
├── 03-c-level-matrix.md               6 본부 × 3 C-Level(CEO/CTO/CPO) 매트릭스 + activation_state
├── 04-pdca-redef.md                   PDCA 재정의 (+ P-1 Discovery)
├── 05-gate-framework.md               G-1 + G1~G5 + 7 Failure Modes
├── 06-escalate-plan.md                Case α/β/γ + 5-Option Protocol
├── 07-plugin-distribution.md          Plugin 배포 + tenant 패키징 (Phase 2)
├── 08-observability.md                3-Channel L1/L2/L3 상세
├── 09-differentiation.md              경쟁 제품 대비 차별화
├── 10-phase1-implementation.md        16~20주 구현 플랜 + 8 Evaluator 상세
│
└── appendix/
    ├── commands/                      ← /sfs * 14개 command spec
    │   ├── README.md                  CLI 전체 가이드
    │   ├── install.md                 (Socratic 5-phase wizard 포함)
    │   ├── discover.md                (brownfield 전용)
    │   ├── brainstorm.md
    │   ├── plan.md
    │   ├── design.md
    │   ├── do.md
    │   ├── handoff.md
    │   ├── check.md
    │   ├── act.md
    │   ├── retro.md
    │   ├── escalate.md
    │   ├── status.md
    │   └── division.md                🆕 (본부 activation_state 조회/변경, 사용자 전용)
    ├── dialogs/                       🆕 ← Socratic 5-phase dialog 템플릿 (A~E)
    │   ├── division-activation.dialog.yaml   ✅ R3 통합 dialog spec (6개 분해 전)
    │   ├── branches/                        ✅ R3 (7 branch scenario)
    │   ├── traces/                          ✅ R3 (runtime trace 저장 공간)
    │   ├── README.md                  ✅ WU-4 — 5-phase 구조 개요 + dialog_trace_id 규약 + ALT-INV-1~3 요약 (index 허브)
    │   ├── phase-a-context.md         🚧 Phase 1 — Context 수집
    │   ├── phase-b-why-now.md         🚧 Phase 1 — Q1 Why now
    │   ├── phase-c-clarify.md         🚧 Phase 1 — Q2 Clarify
    │   ├── phase-d-option-card.md     🚧 Phase 1 — Option Card (3-tier × 👍⚪⚠)
    │   └── phase-e-terminal.md        🚧 Phase 1 — Terminal (사용자 최종 선택 확정)
    ├── engines/                       🆕 ← 엔진 spec (dialog / alternative)
    │   ├── dialog-engine.md           🚧 Phase 1 — 5-phase dialog 상태 머신
    │   └── alternative-suggestion-engine.md   ✅ R3 — 3-tier × 3-level intensity
    ├── templates/                     ← 문서 템플릿 (plan/design/brainstorm 등)
    └── schemas/                       ← YAML schema
        ├── gate-report.schema.yaml
        ├── divisions.schema.yaml      (v1.1 activation_state/scope 반영)
        └── dialog-state.schema.yaml   🆕 (Socratic dialog state + trace id)
```

---

## 11. 용어집 (Glossary)

| 용어 | 정의 |
|------|------|
| **Solon** | 이 제품의 Brand name (제품명) |
| **/sfs** | CLI prefix (Solo Founder System 약자, 브랜드와 분리) |
| **Initiative** | 수개월 단위 전략 주제 (1 Initiative = 1 G0 Brainstorm) |
| **Sprint** | 1~2주 실행 단위, N개 PDCA 묶음 (bkit 의 "1 Sprint = 1 PDCA" 와 다름) |
| **PDCA** | 본 docset 의 원자 작업 단위 (P-1/Plan/Do/Check/Act) |
| **Division / 본부** | 6개 (strategy-pm / taxonomy / design / dev / qa / infra) — Phase 1 basic active = dev + strategy-pm 2개만, 나머지 4개는 abstract |
| **activation_state** | 본부의 활성 상태 — `abstract` (spec만 존재, 호출 불가) / `active` (호출 가능) / `deactivated` (한때 active 였다가 꺼짐). 변경은 `/sfs division` 으로만 가능 (원칙 13) |
| **activation_scope** | 활성화 범위 — `full` (전역) / `scoped` (parent_division 필수) / `temporal` (sunset_at 필수, 기한 만료 시 자동 abstract 복귀) |
| **Progressive Activation** | 원칙 13 전반부 — 본부는 필요 시점에 단계적으로 열며, 기본은 최소 조합. Phase 1 basic 2 active → 필요에 따라 `/sfs division activate` 로 확장 |
| **Non-Prescriptive Guidance** | 원칙 13 후반부 — 시스템은 3-tier 대안과 3-level intensity(👍 권장 / ⚪ 중립 / ⚠ 비권장)를 제시할 뿐 강제하지 않음 (ALT-INV-3 never-hard-block). ALT-INV-2: 3-tier 중 정확히 하나만 👍 |
| **Socratic dialog (5-phase)** | `/sfs install` 및 activation 변경 시 실행되는 사용자 대화 플로우 — A Context → B Q1 Why now → C Q2 Clarify → D Option Card → E Terminal. state 는 `appendix/schemas/dialog-state.schema.yaml` 로 기술 |
| **dialog_trace_id** | Socratic dialog 세션 식별자 — 형식 `dlg-YYYY-MM-DD-<target-id>-<seq>` (예: `dlg-2026-04-20-install-001`). L1 event correlation key |
| **/sfs division** | 본부 activation_state 조회/변경 CLI — **사용자 전용** (INV-5: agent 자동 호출 금지). 모든 변경은 L1 event `division.activation.changed` 로 append |
| **본부장 / Lead** | Sonnet 오퍼레이터, Gate 호출자 (판단자 아님). `abstract` 상태 본부의 Lead 는 로드되지 않음 |
| **Worker** | Sonnet 구현자, 본부장 위임 받아 실제 산출물 작성 |
| **Evaluator** | Opus 외부 검증자, 본부장이 호출할 뿐 자기 본부 evaluator 호출 금지 |
| **C-Level** | CEO/CTO/CPO — 전략·기술·제품 층위 escalation 대상 |
| **Gate** | phase 전환점 검증 관문 (G-1/G1/G2/G3/G4/G5) |
| **G4 Formula** | `final_score = Gap × 0.4 + 5-Axis × 0.6` (≥ 85 PASS) |
| **5-Axis** | CPO 5축 평가 (User-Outcome / Value-Fit / Soundness / Future-Proof / Integrity) |
| **Gap Score** | design spec vs 실제 구현의 일치도 (bkit gap-detector 재활용) |
| **DoD** | Definition of Done (체크리스트) |
| **Greenfield / Brownfield** | 새 코드 vs 기존 코드 (원칙 11/12 로 구분) |
| **Discovery Phase (P-1)** | brownfield 1회성 탐색 단계 (read-only) |
| **Tier Profile** | install 시 선택 (minimal / standard / collab) |
| **L1 / L2 / L3** | Observability 3채널 (events / git docs SSoT / driver) |
| **5-Option Protocol** | escalate 시 표준 선택지 5개 (A Retry / B Relax AC / C Re-design / D Split / E Abort) |
| **Case α / β / γ** | escalate 케이스 (Gap 폭락 / 재시도 실패 / CONFLICT) |
| **β-1 / β-2 / β-3** | escalation level (본부 내 / PM 조정 / CEO 판단) |
| **human-final-filter** | 원칙 10 — G4 수락은 사람만 |
| **3-Tier Separation** | 원칙 2 — agent 가 자기 검증 못하게 분리 (Tier 1/2/3) |

### 11.1 Workflow / 세션 운영 용어 (SSoT: `CLAUDE.md §2.1`)

> 본 subsection 은 사용자 ↔ Claude **세션 협업 시** 쓰는 운영 용어.
> 제품 내부 용어(§11 본표) 와 명확히 분리. 규칙·정의가 중복되면 `CLAUDE.md §2.1` 을 진실로 간주.

| 용어 | 의미 |
|------|------|
| **WU** (Work Unit) | **1 회 git commit 으로 완결되는 최소 작업 단위**. 순차 번호 (`WU-7`, `WU-10`, ...). `WU-<id>.1` 은 forward sha backfill 전용 refresh WU (squash 제외) |
| **micro-step** | WU 내부의 sub-step. **1 회 `PROGRESS.md` 덮어쓰기 단위**. 완료 시 wip 커밋 → WU 완료 시점에 squash |
| **SSoT** (Single Source of Truth) | **유일 정보원**. 규칙·정의가 여러 곳에 나타나면 원본 문서 하나만 진실로 간주. 본 docset 운영 규율 SSoT = `CLAUDE.md` |
| **FUSE bypass** | Cowork 마운트의 `.git/index.lock` 경합 회피 절차 — `cp -a .git /tmp/solon-git-<ts>/` → 작업 → `rsync back` (SSoT: `CLAUDE.md §1.6`) |
| **Option α / β / γ** | 결정 갈림길의 선택지. **β = minimal cleanup default** 제안. 확정은 항상 사용자 (원칙 2) |
| **Visibility tier** | 파일 단위 공개 범위 3-tier — `oss-public` / `business-only` / `raw-internal`. `.visibility-rules.yaml` 에서 관리 |
| **W10 TODO** | `cross-ref-audit.md §4` 의 W-series 결정 대기 항목 SSoT (현 19건). Option A/B/C 결정이 escalate 된 항목 집적소 |
| **resume_hint** | `PROGRESS.md` frontmatter 필드 — 다음 세션 첫 발화 1건 (예: `ㄱㄱ`) 으로 자동 resume 가능하게 하는 규약. `trigger_positive/negative` · `default_action` · `safety_locks` 구성. 진입 규칙: `CLAUDE.md §1.11` |
| **Solon Session Status Report (§14)** | WU 전환 시 1회 출력되는 dashboard 리포트. topic별 1줄 summary + triple-backtick code fence 필수 (`CLAUDE.md §14`) |
| **sprint / session / learning-log** | v2 3대 폴더. `sprints/WU-*.md` (WU 파일) · `sessions/<date>-<codename>.md` (세션 3-part 로그) · `learning-logs/YYYY-MM/P-*.md` (장기 학습 패턴) |

---

## 12. Contributing / Versioning / Changelog

### 12.1 Versioning

- **Docset version** = `v{major}.{minor}[-r{revision}]`
- 현재 = `v0.4-r3` (v0.4 → Round 3 expansion: 원칙 13 Progressive Activation + Socratic dialog + division abstraction)
- **Docset version ≠ Phase 1 Code version** (코드는 별도 semver)

### 12.2 Contributing (Phase 1 기준)

- 기여자: 채명정 본인 1명 (+ 보조 agent)
- 변경 절차:
  1. HANDOFF-next-session.md 에 작업 항목 기록 (TaskCreate 로 동기화)
  2. 해당 §섹션 수정 → cross-reference 깨지지 않는지 Grep 확인
  3. INDEX.md 동기화 (필요 시)
  4. Git commit + auto-memory 업데이트

### 12.3 Changelog 요약

| Version | 날짜 | 주요 변경 |
|---------|------|---------|
| v0.3 | 2026-04 이전 | 초기 6-본부 프레임 + G1~G4 |
| v0.4 | 2026-04-19 | CEO/CTO/CPO 3-layer 추가, G5 Sprint Retro 추가, 8 Evaluator 정의, tier profile 도입 |
| v0.4-r1 | 2026-04-19 | 10 task 초기 배치 완료 (observability L3 일반화, plugin tier 반영 등) |
| v0.4-r2 | 2026-04-20 | Brownfield First Pass 대응 — 원칙 10/11/12 추가, P-1 Discovery Phase, G-1 Intake Gate, `/sfs discover`, 13개 command spec, Solon brand 정식화 |
| **v0.4-r3** | **2026-04-20** | **Progressive Activation + Non-Prescriptive Guidance — 원칙 13 추가, activation_state 3-state 도입 (abstract/active/deactivated), activation_scope 3-scope (full/scoped/temporal), Socratic 5-phase dialog (A Context → E Terminal), 3-tier × 3-level intensity alternative suggestion engine (ALT-INV-1~3, never-hard-block), `/sfs division` command 신설 (user-only, INV-5), `division/pm` → `division/strategy-pm` 개명, Phase 1 basic active = dev + strategy-pm 만, dialog-state.schema.yaml / divisions.schema.yaml v1.1 / dialog-engine.md / alternative-suggestion-engine.md 신설** |

### 12.4 다음 Round 예상

- v0.4-r4 (예상): Phase 1 dogfooding 피드백 반영 (실제 구현 중 발견된 원칙 충돌 / 누락 spec)
- v0.5 (예상): Phase 2 상품화 준비 — multi-tenant, L3 driver SDK, GUI 백엔드 통합

---

## 🚦 지금 어디로 가야 하나요?

| 당신이… | 먼저 읽을 파일 |
|--------|---------------|
| "이 docset 이 무엇인지 확인만 원한다" | 이 README 여기까지 — 끝 |
| "왜 이렇게 설계했는지 알고 싶다" | [§00 제품 철학](00-intro.md) → [§02 12원칙](02-design-principles.md) |
| "어떻게 돌아가는지 runtime 이 궁금하다" | [§04 PDCA](04-pdca-redef.md) + [§05 Gate](05-gate-framework.md) |
| "실제 구현 언제/어떻게 할 거냐" | [§10 Phase 1 구현](10-phase1-implementation.md) |
| "내가 이걸 직접 쓰려면?" | [appendix/commands/README.md](appendix/commands/README.md) |
| "전체 지도가 필요하다" | [INDEX.md](INDEX.md) |
| "이관 후 첫 Claude 라서 아무것도 모른다" | [HANDOFF-next-session.md](HANDOFF-next-session.md) → [CROSS-ACCOUNT-MIGRATION.md §3.4 sanity check](CROSS-ACCOUNT-MIGRATION.md) |

---

> **이 docset 은 "회사가 아닌 1명"이 설계·구현·검증을 통합 운영할 수 있는 구조적 근거다.**
> 문서 버전이 v0.5 이상으로 올라갔다면 이 README 도 업데이트 되어야 한다.
