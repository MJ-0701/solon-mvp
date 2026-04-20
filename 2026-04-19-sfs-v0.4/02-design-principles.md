---
doc_id: sfs-v0.4-s02-design-principles
title: "§2. Design Principles (13대 원칙)"
version: 0.4
status: draft
last_updated: 2026-04-20
audience: [all, architects]
required_reading_order: [s00, s02]

depends_on:
  - sfs-v0.4-s00-intro

defines:
  - principle/domain-agnostic-framework
  - principle/self-validation-forbidden
  - principle/gate-operator
  - principle/model-allocation
  - principle/sprint-superset-pdca
  - principle/worker-parallelism
  - principle/local-state-private
  - principle/cli-gui-shared-backend
  - principle/phase1-phase2-separation
  - principle/brainstorm-gate-mandatory
  - principle/human-final-filter
  - principle/brownfield-first-pass                  # 🆕 v0.4-r2
  - principle/brownfield-no-retro-brainstorm         # 🆕 v0.4-r2
  - principle/progressive-activation                 # 🆕 v0.4-r3

references:
  - concept/company-as-code (defined in: s00)

affects:
  - sfs-v0.4-s03-c-level-matrix
  - sfs-v0.4-s04-pdca-redef
  - sfs-v0.4-s05-gate-framework
  - sfs-v0.4-s06-escalate-plan
  - sfs-v0.4-s08-observability
  - sfs-v0.4-s07-plugin-distribution
  - sfs-v0.4-s10-phase1-implementation
---

# §2. Design Principles — 13대 원칙

> **Context Recap (자동 생성, 수정 금지)**
> 이 문서는 이후 모든 섹션(§3~§10)의 **공통 전제**.
> 여기 정의된 13개 원칙은 문서 전반에 걸쳐 `references`로 인용된다.
> v0.4-r2에서 원칙 10(human-final-filter)에 이어 원칙 11·12(brownfield 계열)이 추가됐다.
> v0.4-r3에서 원칙 13(progressive-activation)이 추가됐다 — 6 본부를 추상 선언 기본으로 두고 Socratic dialog로 활성화하는 구조.
> Solon은 greenfield·brownfield를 모두 커버하고, 1인 창업부터 다본부 조직까지 heavy-by-default 없이 운영되어야 한다.
> 원칙 변경은 전 섹션에 영향 → `affects` 전부 재검토 필요.

---

## TOC

- 2.1 원칙 1 — 도메인 agnostic 프레임워크 + 도메인 specific evaluator
- 2.2 원칙 2 — 자기검증 금지 (3-Tier Separation Rule)
- 2.3 원칙 3 — 본부장 = Gate Operator (판단자 X, 오퍼레이터 O)
- 2.4 원칙 4 — 모델 할당 (C-Level/본부장 = Opus / 실무자 = Sonnet / 헬퍼 = Haiku)
- 2.5 원칙 5 — Initiative ⊃ N Sprint ⊃ N PDCA (3 레이어 위계)
- 2.6 원칙 6 — 로컬 상태 PC별 private, 공유는 git + Notion
- 2.7 원칙 7 — CLI + GUI 통합 백엔드 (zero GUI build cost)
- 2.8 원칙 8 — Phase 1 내부 사용 → Phase 2 상품화 (하드코딩 금지)
- 2.9 원칙 9 — Initiative 진입 = G0 Brainstorm Gate 필수
- 2.10 원칙 10 — 사람 최종 필터 (Human Final Filter)
- 2.11 원칙 11 — Brownfield First Pass (기존 프로젝트 도입 전 discovery 필수) 🆕 v0.4-r2
- 2.12 원칙 12 — Brownfield No Retro Brainstorm (이미 구현된 기능에는 G0 적용 안 함) 🆕 v0.4-r2
- 2.13 원칙 13 — Progressive Activation + Non-Prescriptive Guidance (본부 추상 선언 + Socratic 활성화) 🆕 v0.4-r3
- 2.14 원칙 간 관계 (의존 그래프)

---

## 2.1 원칙 1 — 도메인 agnostic 프레임워크 + 도메인 specific evaluator

`principle/domain-agnostic-framework`

### 정의

**프레임워크(Sprint, PDCA, G1~G5 Gate, Escalate-Plan)는 모든 본부에 동일 적용된다.**
**본부별 차이는 evaluator agent와 산출물 schema에서만 나타난다.**

### 구체

| 공통 (frame) | 본부별 (evaluator + artifact) |
|--------------|------------------------------|
| Sprint 길이, PDCA phase 4단계 | PM 본부: PRD evaluator / Design 본부: WCAG evaluator |
| G1 (input) ~ G5 (retro) 5 단계 | Dev 본부: code-reviewer / QA 본부: test-coverage-checker |
| Escalate-Plan trigger 조건 | Infra 본부: cost-estimator / Taxonomy 본부: consistency-checker |

### 왜 중요한가

- 본부 추가/제거가 **YAML 한 줄**로 가능 (원칙 8과 결합)
- 신규 본부 도입 시에도 프레임 학습 불필요 — 같은 PDCA, 같은 Gate
- bkit/cowork와 차별: 둘 다 도메인 specific (개발 / 디자인)

### 위반 사례

- ❌ "디자인 본부는 G3가 없다" → 본부별로 Gate 빠지면 도메인 agnostic 깨짐
- ✅ "디자인 본부 G3 evaluator는 design-critique" → frame 동일, evaluator 교체

---

## 2.2 원칙 2 — 자기검증 금지 (3-Tier Separation Rule)

`principle/self-validation-forbidden`

### 정의

**작성자(Producer)와 검증자(Evaluator)는 절대 동일 agent여서는 안 된다.**

이는 LLM이 "자기 출력의 결함을 보지 못함"이라는 알려진 약점에 대한 구조적 방어선이다.

### 3-Tier 분리 규칙

| Tier | 위치 | 누가 검증? | 강제력 |
|:----:|------|----------|--------|
| **Tier 1** | 동일 agent self-eval | **금지** | hard rule (위반 시 Gate fail) |
| **Tier 2** | 같은 본부 내 peer review | 중간 단계 OK (Plan→Design 등) | soft rule |
| **Tier 3** | 외부 본부 evaluator | 최종 Gate 필수 | hard rule (G3, G4) |

### 적용 사례

- Dev 본부 worker가 작성한 코드를 **같은 worker가 review** → ❌ Tier 1 위반
- Dev 본부 worker가 작성한 코드를 **Dev 본부장이 review** → ⚠️ Tier 2 (peer, 비공식 OK)
- Dev 본부 worker가 작성한 코드를 **QA 본부 evaluator가 review** → ✅ Tier 3 (G4 통과 가능)

### Memory 연결

이 원칙의 합의 근거는 `auto-memory/feedback_sfs_no_self_validation.md`에 영구 보존되어 있음.
v0.3 §2.2 "Sonnet 실행자 + Opus 판단자 쌍"을 더 엄격하게 명문화한 것.

---

## 2.3 원칙 3 — 본부장 = Gate Operator

`principle/gate-operator`

### 정의

**본부장(Division Lead)은 Gate를 직접 판단하지 않는다.**
**본부장의 역할은 "외부 evaluator를 호출하고, 결과를 받아 다음 액션을 결정"하는 오퍼레이터다.**

### 왜 본부장이 Gate를 판단하면 안 되는가

본부장은 같은 본부의 worker가 만든 산출물을 봤기 때문에 **앵커링 편향**이 발생한다.
또한 본부장이 평가자가 되면 **승급/평가 motivator** 가 작동해 객관성이 무너진다 (실제 회사 조직에서도 동일 이유로 외부 감사를 둠).

### 본부장의 4가지 책임

1. **Trigger** — Gate 호출 시점 결정 (PDCA phase 끝, 외부 변경 감지 등)
2. **Selection** — evaluator pool에서 적합한 evaluator 선택
3. **Receive** — GateReport 받아서 verdict 해석
4. **Route** — Pass → 다음 phase / Fail → Escalate-Plan / Partial → AC 부분 재오픈

### 위반 사례

- ❌ "Dev 본부장이 worker 코드를 직접 grade함" → operator가 evaluator 역할 침범
- ✅ "Dev 본부장이 code-reviewer evaluator를 호출하고, GateReport를 받아 routing" → 정상

---

## 2.4 원칙 4 — 모델 할당 규칙

`principle/model-allocation`

### 정의

**역할의 인지 부하 수준에 맞춰 모델을 차등 할당한다.**

| Role | 모델 | 이유 |
|------|------|------|
| C-Level (CEO/CTO/CPO) | **Opus 4.6** | 전략 판단, 본부 간 충돌 중재, 비용 정당화 |
| 본부장 (Division Lead) | **Opus 4.6** | Gate operator, 이상 징후 탐지, escalation 판단 |
| Evaluator | **Opus 4.6 + fork + read-only** | 독립성 + 객관성 (자기검증 금지) |
| 실무자 (Worker) | **Sonnet 4.6** | 실행 비용 최적화, 대량 호출 지점 |
| 헬퍼 (parsing, format 변환, sync) | **Haiku 4.5** | 초저비용 결정성 단순 작업 |

### 비용 절감 효과 (개략 추정)

100 PDCA 사이클 기준 (Phase 1 14주 dogfooding 가정):

| 모델 | 호출 수 | 단가 가중 | 비중 |
|------|--------|----------|-----|
| Opus | ~500 (Gate, escalate, retro) | × 5 | 30% |
| Sonnet | ~5,000 (worker 실행) | × 1 | 60% |
| Haiku | ~10,000 (sync, parse) | × 0.2 | 10% |

→ 모든 호출을 Opus로 했을 때 대비 **약 60% 비용 절감** (대략치, Phase 1 실측 후 갱신).

### Evaluator의 "fork + read-only" 조건

evaluator는 호출되는 시점에 **새 fork(별개 컨텍스트)에서 시작**하며, 입력은 산출물 + schema만 받고 **수정 권한 없음 (read-only)**. 이는 §2.2 자기검증 금지의 운영적 보장.

---

## 2.5 원칙 5 — Initiative ⊃ N Sprint ⊃ N PDCA (3 레이어 위계)

`principle/sprint-superset-pdca`

### 정의

**1 Initiative = 1 Brainstorm = N Sprint = N×M PDCA.** 3 레이어 위계:
- **Initiative** (scope 단위, 도메인급) — 원칙 9와 결합, G0 Brainstorm Gate로 진입
- **Sprint** (시간 단위, 2주 standard) — Initiative.sprint_decomposition에서 도출
- **PDCA** (본부별 작업) — Sprint 내 본부별로 병렬 N개

Sprint 계층만 보면 "1 Sprint = N PDCA" (본부별 병렬). Initiative 계층까지 보면 "1 Initiative → 다수 Sprint → 더 많은 PDCA". 상세는 [§4.2](04-pdca-redef.md#42-initiative--n-sprint--n-pdca-3-레이어-위계).

### bkit과의 차이

| | bkit | SFS |
|---|------|-----|
| 단위 | 1 Sprint = 1 PDCA | 1 Sprint = N PDCA |
| 본부 | 단일 본부 (Dev) | 6 본부 병렬 |
| Sprint 끝 | PDCA report | G5 Sprint Retro (모든 본부 PDCA 종합) |

### 본부별 PDCA 병렬 예시 (1 Sprint 내)

```
Sprint #5 (2주)
├── PM PDCA-051: 결제 PRD
├── Design PDCA-052: 결제 화면 디자인
├── Dev PDCA-053: 결제 API 구현
├── QA PDCA-054: 결제 테스트 시나리오
├── Infra PDCA-055: 결제 모니터링 셋업
└── Taxonomy PDCA-056: "결제" 용어 정의
```

각 PDCA는 G1~G4를 독립적으로 통과하며, Sprint 종료 시 **G5 Retro**가 모든 PDCA를 묶어서 평가한다.

### Sprint 내 PDCA 동시성 한계 [OPEN→해소]

- 같은 본부 내에서는 **순차 실행** (worker 1명 가정, Phase 1)
- 본부 간에는 **병렬 가능** (각 본부가 독립 worker 보유)
- 의존성 있는 PDCA(예: Design은 PM Plan 필요)는 **DAG로 명시** (PDCA frontmatter `depends_on`)

### 2.5.4 Worker 병렬 실행 (Multi-Agent Parallelism)

`principle/worker-parallelism`

#### 정의

**Sonnet worker는 본부 내·간 병렬 실행을 기본 동작으로 한다.**
Orchestrator(human)가 N개 task를 한 번에 dispatch → 본부별 worker가 동시 실행 → 결과 aggregate.

#### 왜 병렬이 기본인가

- **Opus(판단)와 Sonnet(실행)의 비대칭 활용**: 판단은 직렬(C-Level/Lead), 실행은 본질적으로 분산 가능
- **Sprint 처리량 최대화**: 6 본부 동시 진행 시 throughput ~6배
- **모델 병목 해소**: Sonnet은 Opus보다 호출 캡 여유 → 병렬화로 wall-clock 단축

#### 병렬 실행의 4 단위

| 단위 | 병렬도 | 비고 |
|------|--------|------|
| 본부 내 worker N명 | Phase 1=1, Phase 2 증설 | §3.7 |
| 본부 간 worker (6 본부) | **Phase 1부터 즉시 가능** | DAG `depends_on` 준수 |
| Tier 2 evaluator 다수 | 동일 산출물에 N evaluator 병렬 | GateReport aggregation 시 종합 |
| PDCA phase 내 sub-task | 산출물 multi-section 동시 작성 | Phase 2 worker 증설 후 |

#### Phase 1 baseline 정책

- 본부당 worker 1명 → **본부 간 6-way 병렬은 Phase 1부터 default**
- 본부 내 sub-task 병렬은 Phase 2 worker 증설 후 (§3.7.2)
- Tier 2 evaluator 병렬 호출은 Phase 1부터 (§3.5.3 contract)

#### tier 별 병렬도 차이

| tier | Opus 호출 | Sonnet 병렬 | 비고 |
|------|----------|------------|------|
| minimal | 최소화 (escalate only) | 6-way 본부 간 OK | Pro 플랜 Sonnet 캡 내 |
| standard | 정상 | 6-way + evaluator 다수 | Team/Max에서 자연스러움 |
| collab | 정상 + cache 적극 | 본부당 N worker (Phase 2) | 다자 사용 시 wall-clock 최소화 |

#### 비병렬화의 안티패턴

- ❌ 본부장이 worker를 순차 호출 ("dev 끝나고 design") → wall-clock 낭비
- ✅ Orchestrator가 dependency-free PDCA들을 한 번에 dispatch → aggregate

---

## 2.6 원칙 6 — 로컬 상태 private, 공유는 git + Notion

`principle/local-state-private`

### 정의

**PC별 로컬 상태는 절대 공유하지 않는다. 공유가 필요한 것은 명시적 export로만 L2(git) → L3(Notion)에 흘려보낸다.**

### gitignore 대상

| 파일/디렉토리 | 이유 |
|--------------|------|
| `.bkit-memory.json` | bkit 본부별 PC별 캐시 |
| `~/.claude/projects/*/memory/MEMORY.md` | Claude Code auto-memory (PC별) |
| `.sfs-local/` | SFS 임시 캐시 디렉토리 |
| `.env`, `.env.local` | 시크릿 |

### Race Condition 구조적 방지

| 시나리오 | 결과 |
|---------|------|
| PC-A와 PC-B가 동시에 같은 PDCA 작업 | ✅ 각자 로컬에서 작업, L2 commit 시점에 git이 conflict 처리 |
| PC-A의 memory를 PC-B가 직접 read | ❌ 발생 불가 (gitignore되어 공유 X) |
| PC-A에서 학습한 패턴을 PC-B에서 활용 | ✅ 사용자가 명시적으로 `learning/patterns.md`에 export → L2로 commit |

### v0.3에서의 진화

v0.3는 `.agent/state.yaml`을 git에 포함하는 가정이었음 → 멀티 PC 동기화 시 conflict 빈발 위험.
v0.4는 **로컬은 private, 공유는 명시적**으로 전환.

---

## 2.7 원칙 7 — CLI + GUI 통합 백엔드

`principle/cli-gui-shared-backend`

### 정의

**Claude Code (CLI)와 Claude Desktop Cowork (GUI)는 같은 파일시스템과 같은 plugin을 공유한다. 별도 GUI 빌드 비용은 0이다.**

### 작동 원리

```
[프로젝트 루트] (예: ~/projects/my-startup/)
├── docs/                 ← L2 SSoT (CLI/GUI 모두 read/write)
├── .sfs-local/           ← gitignore (PC별)
└── ~/.claude/projects/   ← Claude Code 표준 (CLI/GUI 모두 인식)

[같은 sfs-plugin이 양쪽에 설치]
  ├── Claude Code CLI:  $ claude  (개발자, 터미널)
  └── Claude Desktop Cowork: GUI (비개발자, 마우스)
```

### 사용 분리

| 사용자 | 인터페이스 | 시나리오 |
|--------|----------|---------|
| 개발자 본인 | Claude Code CLI | 코드 작성, git 작업, hook 설정 |
| 비개발자 (디자이너/PM 협업자, Phase 2) | Claude Desktop Cowork | docs 편집, Sprint 진척 확인, evaluator 호출 |

### 의의

- Phase 1 dogfooding 시 본인이 양쪽 다 사용 → 같은 plugin 검증
- Phase 2 multi-tenant 시 별도 GUI 개발 불필요
- bkit과 차별: bkit은 CLI 전용, GUI 부재

---

## 2.8 원칙 8 — Phase 1 내부 사용 → Phase 2 상품화

`principle/phase1-phase2-separation`

### 정의

**모든 본부 정의, 모델 할당, evaluator 매핑은 YAML로 관리한다. 코드 하드코딩 금지.**
**Phase 1은 솔로 dogfooding, Phase 2는 RBAC + multi-tenant + marketplace 상품화.**

### YAML로 관리되는 것

- `config/divisions.yaml` — 본부 정의 (id, head_agent, workers, evaluators, artifacts)
- `agents/*.yaml` — 모든 agent (C-Level, lead, evaluator, worker)
- `plugin.json` — plugin 메타 + hook 매핑

### 하드코딩 금지의 구체

- ❌ `if (division === 'pm') { /* PM 전용 로직 */ }` → divisions.yaml에서 도출 불가, Phase 2에서 본부 추가 불가능
- ✅ `divisions[divisionId].evaluators.forEach(...)` → YAML driven

### Phase 1 → Phase 2 분리

| 차원 | Phase 1 (내부) | Phase 2 (상품화) |
|------|--------------|----------------|
| 사용자 | 본인 1명 | N tenant |
| RBAC | 없음 (전권) | 본부별 권한 |
| 데이터 격리 | 없음 (단일 디렉토리) | tenant 격리 |
| 마켓플레이스 | 없음 | 본부 템플릿 마켓 |
| 라이선스 | MIT (내부) | dual license |

→ Phase 1 코드가 YAML driven이면 Phase 2 진입 시 **구조 변경 0**, RBAC/tenant 레이어만 추가하면 됨.

---

## 2.9 원칙 9 — Initiative 진입 = G0 Brainstorm Gate 필수

`principle/brainstorm-gate-mandatory`

### 정의

**도메인급 작업 단위(=Initiative; TF, 신규 도메인, 기능군)는 Sprint decomposition 전에 G0 Brainstorm Gate를 반드시 통과해야 한다.**
Sprint 단위마다 brainstorm을 강제하는 것이 아니다. **1 Initiative = 1 brainstorm = N sprint.**

### 왜 Brainstorm이 필수인가

- 의도 발견(intent discovery) 없이 구조부터 세우면 잘못된 문제를 잘 풀게 됨
- Sprint scope가 brainstorm 없이 정해지면 over-engineering 또는 under-scoping 발생
- Plan phase의 G1은 "이미 정해진 의도가 명확한가"만 검증 — "그 의도 자체가 옳은가"는 G0의 책임

### G0 산출물

[appendix/templates/brainstorm.md](appendix/templates/brainstorm.md) 6 필드:

| 필드 | 의미 |
|------|------|
| `intent` | 풀려는 진짜 문제 (1줄, measurable 권장) |
| `alternatives_considered` | 검토·기각한 대안 (최소 2개 — 단일안 G0 Fail) |
| `scope_boundary` | 포함/제외 명시 |
| `success_signal` | Initiative 종료 판정 기준 (measurable=true 필수) |
| `sprint_decomposition` | Sprint 1~3개로의 분해 초안 |
| `risk_pre_register` | 알려진 리스크 + mitigation |

### G0 통과/실패 routing

- **Pass** → CEO가 sprint_decomposition을 sprint plan으로 전개
- **Fail** → Initiative reject 또는 re-scope (Sprint 시작 불가)

### 자기검증 금지(원칙 2)와의 관계

G0 평가도 Tier 3 (외부 evaluator) 원칙 적용. brainstorm 작성자(CEO)와 G0 평가자는 분리.
Phase 1 baseline: CPO + `intent-discovery-validator` (신규 evaluator) 호출.

### 위반 사례

- ❌ "PRD부터 쓰고 sprint 짠 다음 brainstorm은 다음에" → G0 우회, 원칙 9 위반
- ❌ "alternatives 1개만 검토 후 G0 통과 시도" → G0 Fail (intent discovery 부족)
- ✅ "Initiative 선언 → brainstorm.md 6 필드 작성 → CPO + intent-discovery-validator 통과 → Sprint decomposition"

---

## 2.10 원칙 10 — 사람 최종 필터 (Human Final Filter)

`principle/human-final-filter`

### 정의

**구현 후 최종 품질 검증(테스트·QA·수락)은 사람이 직접 수행해야 한다. LLM agent는 필터가 되지 못한다.**

이는 원칙 2(self-validation-forbidden)를 system-to-human 층으로 확장한 방어선이다.
원칙 2가 agent-to-agent 차원의 차단이라면, 원칙 10은 LLM 시스템 전체가 자기 산출을 최종 수락하는 것을 막는다.

### 2.10.1 철학적 근거

채명정의 제품 철학 ② ([§00 참조](00-intro.md)):

> "구현후 테스트는 사람이 직접 무조건 해야된다 (그래야 필터가 제대로 됨)"

LLM은 자기가 생성한 산출물을 자기가 검증할 때 **확증 편향**에 빠진다.
agent 간 분리(원칙 2)만으로는 같은 LLM 계열이 전체 파이프라인을 돌 때의 편향을 차단하지 못한다.
"이 산출물이 정말 사용자가 원한 것인가"라는 최종 판정은 **사람 고유 권한**.

### 2.10.2 적용 범위

| 대상 | 사람 책임 | agent 책임 |
|------|----------|-----------|
| G4 수락 테스트 (`gate/g4-acceptance`) | **Pass/Fail 판정 (전권)** | Report 제출까지만 |
| Zero Script QA 수동 실행 | **직접 실행 + 관찰** | 로그 수집, 요약 |
| Phase 1 dogfooding 수락 | **본인(채명정)** | product-image-studio 산출 |
| Phase 2 productization 수락 테스트 | **각 tenant 사람 사용자** | 자동 E2E (회귀만) |

### 2.10.3 무엇이 아닌가 (non-goals)

- ❌ 모든 테스트를 사람이 쳐야 한다는 뜻 아님 — 단위/통합 테스트는 자동화 권장
- ❌ agent가 PR/merge 권한 가질 수 없다는 뜻 아님 — Gate 통과 후 merge 자동화 OK
- ❌ 자동 E2E 금지 아님 — 회귀 방어용 자동 E2E는 허용
- ✅ **"이것이 정말 사용자가 원한 것인가"라는 최종 판정만** 사람 고유

### 2.10.4 원칙 2 와의 관계 (이중 방어선)

| 구분 | 원칙 2 (self-validation-forbidden) | 원칙 10 (human-final-filter) |
|---|---|---|
| 차단 대상 | agent가 자기를 평가 | LLM 시스템 전체가 최종 수락 |
| 방어선 위치 | 내부 (agent↔agent) | 외부 (system→human) |
| 강제력 | Gate fail (hard rule) | G4 수락 권한 제한 |
| 목적 | 본부장 중립성 | 제품 품질 최종 필터 |

두 원칙 모두 **"검증자가 생성자와 분리돼야 한다"** 원리의 다른 층위 표현.
원칙 2는 agent 간, 원칙 10은 시스템 간 — 합쳐서 이중 차단.

### 2.10.5 원칙 9 와의 관계 (설계-검증 샌드위치)

- 원칙 9(brainstorm-gate-mandatory): **진입 지점**에서 의도 필터 — 잘못된 문제를 풀지 않도록
- 원칙 10(human-final-filter): **출구 지점**에서 수락 필터 — 산출이 실제 의도와 맞는지

진입·출구 양 끝에서 사람이 개입 → **사용자 철학 ①(탄탄한 설계) + ②(사람 최종 필터)의 구조적 구현**.

### 위반 사례

- ❌ "G4 Gate가 Pass 나왔으니 자동 release" → 원칙 10 위반 (최종 수락 주체가 사람이 아님)
- ❌ "agent가 E2E 돌려서 green이면 수락 완료 간주" → 원칙 10 위반
- ✅ "G4 evaluator가 Report 제출 → 채명정 본인이 직접 실행·관찰 → 수락/재오픈 결정"

---

## 2.11 원칙 11 — Brownfield First Pass 🆕 v0.4-r2

`principle/brownfield-first-pass`

### 정의

**이미 source code, 기존 `docs/`, 외부 archive(Notion/Jira 등) 중 하나라도 존재하는 프로젝트에 Solon을 도입할 때는, `/sfs discover` → `discovery-report.md` 산출 → G-1 Intake Gate(사용자 승인) 통과를 거친 후에만 정식 PDCA에 진입할 수 있다.**

신규 프로젝트(greenfield)는 이 원칙의 적용 대상이 아니다 — 즉시 G0 Brainstorm Gate로 진입한다.

### 2.11.1 왜 이 원칙이 필요한가

신제품만을 가정한 설계에는 다음 맹점이 있다:
- 기존 코드/문서의 **맥락을 모르는 상태에서 agent가 Plan을 작성**하면 hallucination 위험 최고
- 사용자가 "agent에게 알아서 파악하라"고 위임 시 **맥락 획득 비용과 품질이 모두 sub-optimal**
- L2 SSoT (`docs/`)가 이미 존재하는 경우 **덮어쓰기/충돌 위험** 구조적 발생

brownfield는 discovery라는 전용 단계 없이는 원칙 1(도메인 agnostic)·원칙 9(brainstorm)가 모두 약화된다.

### 2.11.2 필수 3단계 (brownfield 진입 파이프라인)

| 단계 | 산출물 | 소요 | 강제력 |
|---|---|---|---|
| 1. `/sfs discover` 실행 | `docs/00-discovery/discovery-report.md` 9 섹션 | 10분~6시간 (repo 규모별) | Hard (§5 G-1 fail 시 PDCA block) |
| 2. Human Approval Block 서명 | `signed_by` + `signed_at` + 6 checkbox all | 사용자 검토 시간 | Hard (원칙 10 이중 방어) |
| 3. `.solon-manifest.yaml` 생성 | 기존 경로 → Solon 역할 맵핑 테이블 | 자동 생성, 수동 보정 | Soft (이후 PDCA 참조용) |

### 2.11.3 적용 범위

| 프로젝트 상태 | 이 원칙 적용 여부 | 우회 가능성 |
|---|:---:|---|
| 빈 git repo (commit 0개) | ❌ | greenfield로 진행 |
| 기존 commit ≥ 1개 OR `docs/` 존재 | ✅ 필수 | 우회 불가 (block) |
| 이전 SFS/bkit 프로젝트 마이그레이션 | ✅ 필수 | migration mode (Phase 2 cookbook) |
| 외부 archive (Notion DB, Jira project)만 존재 | ✅ 필수 (코드 없어도 맥락 있음) | archive 링크를 discovery 입력으로 |

### 2.11.4 비용 cap (brownfield 전용)

Discovery 단계는 `tier_profile=minimal` 강제 + **Opus 사용 금지** (`rule/brownfield-discovery-cost-cap`). 이는 "맥락 확보 단계에서 Opus로 전체 코드베이스를 태우는" 안티패턴 차단.

- 모델 할당: Haiku 70% (scan/count/extract) + Sonnet 30% (synthesize only)
- Budget cap: Small <$2, Medium <$15, Large <$60 (§7.10.8)
- Cap 초과 감지 시 자동 pause → 사용자에게 분할 실행 제안

### 2.11.5 원칙 1, 9와의 관계

- **원칙 1 (도메인 agnostic)**: discovery는 도메인 agnostic framework의 **입력 단계** — 기존 repo의 도메인 context를 frame에 주입하는 공식 경로
- **원칙 9 (G0 Brainstorm Gate)**: brownfield에서도 **신규 기능은 G0 필수**. 하지만 이미 구현된 기능은 **원칙 12**에 따라 G0 skip → 중복 방지

### 위반 사례

- ❌ 기존 repo에 install 후 바로 `/pdca plan` 호출 → 원칙 11 위반 (discovery skip)
- ❌ discovery-report.md를 작성하되 Human Approval Block 서명 없이 PDCA 시작 → 원칙 11 + 원칙 10 동시 위반
- ❌ Opus로 전체 코드베이스 read 후 Plan 작성 → budget cap 무시 (원칙 11 ∧ 원칙 4 약화)
- ✅ brownfield 감지 → `/sfs discover` 자동 실행 → report + signature → PDCA 진입

---

## 2.12 원칙 12 — Brownfield No Retro Brainstorm 🆕 v0.4-r2

`principle/brownfield-no-retro-brainstorm`

### 정의

**이미 구현·운영 중인 기능에 대해서는 G0 Brainstorm Gate(원칙 9)를 소급 적용하지 않는다. 대신 `evidence/existing-implementation` 레코드로 기록하고 현재 상태에서 출발한다.**

G0는 **미래 기능의 의도 발견(intent discovery)** 장치이지, **과거 결정의 합리화** 장치가 아니다.

### 2.12.1 왜 이 원칙이 필요한가

retroactive(소급) brainstorm은 2가지 심각한 위험을 초래한다:

| 위험 | 메커니즘 | 결과 |
|---|---|---|
| **자기검증 편향 재발** | LLM이 구현 결과를 먼저 보고 "그럴듯한" intent/alternatives를 역생성 | 원칙 2·원칙 10 우회 |
| **서사 날조 (narrative fabrication)** | agent가 실제 없던 "대안 검토"를 사후에 창작 | 감사·재현 불가능 문서 양산 |

→ G0는 **결정하기 전**에만 의미가 있다. 결정 이후의 brainstorm은 문서적 허구.

### 2.12.2 대체 레코드 — `evidence/existing-implementation`

이미 구현된 기능은 discovery 단계에서 다음 schema로 기록:

```yaml
evidence/existing-implementation:
  feature_id: <자동 생성>
  discovered_at: <ISO 8601>
  evidence_sources:
    - type: code
      path: src/payment/checkout.ts
    - type: doc
      path: docs/existing-PRD.md
    - type: external
      uri: notion://...
  current_behavior: <관찰된 동작 요약, 1~2줄>
  current_owner: <사람|unknown>
  known_debt: [debt_1, debt_2]
  solon_role_mapping: <Solon 6 본부 중 어디 소속인지>
  future_g0_required: <true|false — 이 기능에 대한 변경이 Initiative급이면 true>
```

G0 대신 이 레코드가 **맥락 고정점**이 된다.

### 2.12.3 언제 G0가 다시 필요한가

기존 기능에도 다음 변경이 생기면 G0 필수:

| 변경 유형 | G0 필요 여부 | 이유 |
|---|:---:|---|
| 버그 수정 / 소소한 refactor | ❌ | Initiative급 아님 |
| 성능 개선 / 리팩토링 프로젝트 | ✅ (Initiative면) | 의도 재설정 필요 |
| 기능 확장 (새 flow 추가) | ✅ | 신규 기능 = 미래 결정 |
| 기능 폐기 / 마이그레이션 | ✅ | 폐기 결정 자체가 Initiative |
| 재설계 (architecture 변경) | ✅ (반드시) | 원칙 9 정면 적용 대상 |

→ "기존 기능에 대한 **미래 변경**"은 G0 적용 대상. **과거 존재 자체**는 아님.

### 2.12.4 L1/L2/L3 기록 규칙

- **L1 (S3 raw)**: discovery 시점의 scan 이벤트 기록
- **L2 (git docs)**: `docs/00-discovery/evidence/*.yaml`에 기능별 파일 저장
- **L3 (human view)**: discovery-report.md 내에 인벤토리 섹션으로 렌더링

→ `rule/l3-no-backfill` (§7.10.2): L3에 과거 이력 역삽입 금지 — L1 원본과 불일치 방지.

### 2.12.5 원칙 9 / 원칙 10 / 원칙 11과의 관계

- **원칙 9 보완**: G0는 **도입 이후 신규 Initiative**에만 적용. 과거에는 적용 안 함.
- **원칙 10 공조**: 원칙 10의 "사람 최종 필터"는 discovery-report 최종 서명에도 적용 — 과거 기록의 정확성은 agent가 아닌 사람이 승인.
- **원칙 11 후속**: 원칙 11이 "discovery를 반드시 거쳐라"라면, 원칙 12는 "discovery 단계에서 G0를 역설계하지 마라" — 역할 분담.

### 위반 사례

- ❌ 3년 된 결제 flow에 대해 "왜 이렇게 설계했는가" brainstorm을 사후 작성 → 허구 생산
- ❌ 기존 코드 읽고 agent가 alternatives_considered 3개를 역추정 → `principle/self-validation-forbidden` 동반 위반
- ❌ discovery-report에 "intent: …" 섹션을 agent가 자동 채움 (과거 개발자 의도가 아닌 agent 추측) → 서사 날조
- ✅ 기존 결제 flow는 `evidence/existing-implementation`으로 기록만 하고, 앞으로의 "결제 리팩토링" Initiative가 시작될 때 비로소 G0 진행

---

## 2.13 원칙 13 — Progressive Activation + Non-Prescriptive Guidance 🆕 v0.4-r3

`principle/progressive-activation`

### 정의

**Solon의 6 본부(dev, strategy-pm, qa, design, infra, taxonomy)는 기본적으로 추상 선언(abstract)으로 존재하며, 사용자 상황에 따라 필요한 것만 활성(active) 상태로 전환된다. 시스템은 사용자가 모를 수 있는 경우 recommendation·대안을 제공하되, 구현 자체를 막지 않는다 (non-prescriptive).**

이 원칙은 "처음부터 6 본부를 전부 구현"이라는 heavy-by-default 안티패턴과, "사용자 <10명이니 taxonomy 자동 차단" 같은 prescriptive paternalism 안티패턴을 **동시에** 차단하는 구조 원칙이다.

### 2.13.1 왜 이 원칙이 필요한가

v0.4-r2까지의 설계는 6 본부를 모두 Phase 1 기본 구현 대상으로 가정했다. 이는 다음 문제를 낳는다:

| 문제 | 메커니즘 | 결과 |
|---|---|---|
| **Heavy by default** | 1인 창업자가 개발+기획만 필요해도 Design·Infra·QA·Taxonomy 본부가 강제 로드 | 인지 부하 폭증, 불필요한 Opus 비용, 설치 첫날 abandon |
| **Prescriptive paternalism** | "사용자 <10명이니 taxonomy 불필요" 같은 규칙 기반 자동 차단 | 사용자 고유 상황(예: 보험 도메인 1인 작업자 — taxonomy는 필수) 무시 |
| **IT 경험 부재 사각지대** | 1인 창업자가 "Infra 본부가 필요한지조차 모름" | 필요할 때 놓치는 구조적 사각지대 (가이드 부재) |

→ **추상화(abstract)** 로 인지 부하를 낮추고, **활성화 대화(Socratic dialog)** 로 사각지대를 메우되, **최종 결정은 사용자** 가 한다. 세 층위를 분리하는 것이 본 원칙의 핵심.

### 2.13.2 3가지 Activation State

| State | 의미 | 리소스 점유 | 파일 생성 |
|---|---|---|---|
| `abstract` | schema 선언만 존재, worker/evaluator 미로딩 | 0 | divisions.yaml `activation_state` 필드만 |
| `active` | worker + evaluator + hook 모두 활성 | 정상 (본부별 기본치) | agents/*.yaml, evaluators/*.yaml |
| `deactivated` | 과거 active였다가 sunset, 재활성 가능 | 0 (로그만 유지) | divisions.yaml `sunset_at`, 과거 agents/*.yaml 은 archive |

- **기본값**: 모든 본부는 `abstract` 로 선언됨 (`divisions.schema.yaml` default)
- **Phase 1 기본 active**: **dev + strategy-pm** 2개만 (최소 1인 창업 조합)
- **나머지 4 본부** (qa/design/infra/taxonomy): abstract 상태로 대기 + recommendation trigger 감지

### 2.13.3 3가지 Activation Scope

활성화 방식도 상황에 맞게 범위 조절 가능:

| Scope | 의미 | 전형 사용 | sunset 필수? |
|---|---|---|:---:|
| `full` | 장기 활성, 독립 본부로 운영 | "앞으로 계속 QA 본부 쓸 거야" | ❌ |
| `scoped` | 다른 본부 하위 worker로만 활성 | "QA는 Dev 본부 하위 worker로만 돌려" | ❌ |
| `temporal` | 특정 Phase/Sprint에만 활성 | "Sprint 5~7 동안만 Design 활성" | ✅ (필수) |

- **scoped 해결 문제**: "디자인 본부를 별도 두기에는 부담스럽고, 아예 안 하기에는 아쉬운" 1인 창업 edge case
- **temporal 해결 문제**: "MVP 출시까지만 필요한 QA" 같은 기한성 활성 — `sunset_at` 도달 시 자동 deactivate 후보 알림

### 2.13.4 Non-Prescriptive Guidance (필수 절대 규칙)

시스템이 recommendation을 제공할 때 지켜야 할 **3가지 절대 규칙**:

1. **Ask context first** — 규칙 기반 자동 판단 금지. 사용자 상황·의도를 먼저 물어본다 (Q1: Why now).
2. **Present alternatives** — 비추천 시에도 대안 ≥ 1개 함께 제공 (예: "full 비권장 → scoped 고려?").
3. **Never hard-block** — 사용자가 "그래도 활성화"를 선택하면 **항상 허용**. 시스템이 차단하지 않는다.

Recommendation intensity **3단계** (§[appendix/engines/alternative-suggestion-engine](appendix/engines/alternative-suggestion-engine.md) 에서 구현):

| 강도 | 표기 | 의미 | 차단? |
|:---:|:---:|---|:---:|
| 권장 | 👍 | 현재 상황에 적합 | No |
| 중립 | ⚪ | 상황에 따라 다름, 사용자 판단 | No |
| 비권장 | ⚠ | 일반적으로 부적합하나 edge case 존재 | **Never Yes** |

→ `⚠ 비권장`이라도 사용자가 활성화를 선택하면 Solon은 **반드시 승인**. 대신 `recommendation_trigger: declined` 로 L1 로깅 → Sprint Retro(G5) 재검토 재료.

### 2.13.5 Socratic Dialog로 구현 (5-Phase)

모든 활성화 결정은 다음 5-phase Socratic dialog로 전달된다 (시스템 자동 판단 금지):

```
A. Context      — 사용자 현재 상황 요약
                   (지난 N sprint 데이터 + brainstorm frame + recommendation trigger)
B. Q1: Why now  — "왜 지금 활성화하려 하는가?" (intent discovery)
                   사용자가 자유 텍스트 응답 → agent가 의도 분류
C. Q2: Clarify  — 규모 / 기간 / 범위 명확화
                   (예: "전사 도입이야? 특정 Sprint 한정이야?")
D. Option Card  — Full / Scoped / Temporal / Cancel 4택
                   각 옵션에 recommendation intensity 라벨 표시 (👍/⚪/⚠)
                   사용자 선택이 ⚠ 인 경우 경고 + 대안 재제시 1회, 재선택 시 수락
E. Terminal     — 선택 반영 + divisions.yaml 갱신 + L1 event 발행
                   + HANDOFF 에 activation 기록
```

- **상세 tree**: [appendix/dialogs/division-activation.dialog.yaml](appendix/dialogs/division-activation.dialog.yaml)
- **본부별 branch 6종**: taxonomy·qa·design·infra·strategy-pm·custom (→ Round 3 Task #21)
- **Event schema**: `l1.division.dialog.turn` (각 turn) + `l1.division.dialog.complete` (Terminal 도달)
- **dialog-state** 는 turn 단위 checkpoint → 중단 후 재개 가능 (`appendix/schemas/dialog-state.schema.yaml`)

**Terminal 4 가지**:

| Terminal | 조건 | 후속 효과 |
|---|---|---|
| `terminal/activate-full` | Full 선택 | divisions.yaml `state=active, scope=full` |
| `terminal/activate-scoped` | Scoped 선택 + parent division 지정 | `state=active, scope=scoped, parent_division=<id>` |
| `terminal/activate-temporal` | Temporal 선택 + sunset_at 지정 | `state=active, scope=temporal, sunset_at=<ISO>` |
| `terminal/cancel` | Cancel 또는 Q1 에서 exit | divisions.yaml 변경 없음, dialog trace 로깅만 |

### 2.13.6 원칙 10 (Human Final Filter) 과의 관계 — 운영 채널

원칙 13은 원칙 10의 **운영 채널(operational channel)** 이다:

| 구분 | 원칙 10 | 원칙 13 |
|---|---|---|
| 추상도 | 선언적 ("사람이 최종") | 운영적 ("어떻게 물어볼지") |
| 범위 | 모든 Gate 수락 결정 | 본부 활성화 결정 |
| 관계 | 원칙 13이 원칙 10의 한 구현 사례 | 원칙 10의 dialog protocol 구체화 |
| 차단? | 사람만 Pass 판정 가능 | 사람이 ⚠ 선택해도 시스템은 수용 |

→ 원칙 10이 "사람이 최종 결정"이라는 선언이라면, 원칙 13은 "본부 구성"이라는 구체 맥락에서 그 선언을 **어떻게 운영 프로토콜로 구현할지** 명문화한다.

### 2.13.7 원칙 8 (YAML Driven) 과의 관계 — 3-state 확장

- **원칙 8**: 본부 정의는 YAML (`divisions.yaml`)
- **원칙 13**: YAML의 `activation_state` 필드가 abstract/active/deactivated 세 상태를 표현
- **결합 효과**: Phase 2 marketplace 에서도 동일 schema 로 tenant 별 본부 활성화 가능 → "상품화 분리"(원칙 8) 와 "추상 활성화"(원칙 13) 가 같은 YAML 기반 위에서 직교(orthogonal) 구성.

→ 원칙 13 은 원칙 8 의 **3-state 확장**. 코드 하드코딩 없이 본부 생명주기 전체를 YAML 로 표현.

### 2.13.8 원칙 11 (Brownfield First Pass) 과의 관계 — discovery 입력

brownfield 프로젝트에 Solon 을 도입할 때 discovery 단계에서 다음이 자동 수행된다:

- 기존 repo 의 언어·디렉터리 구조 분석 → 필요 가능성 높은 본부 후보 목록
- `recommendation_trigger: discovery-detected` 로 L1 기록
- `/sfs install --brownfield` 마지막 단계에서 **후보 본부별로 Socratic dialog** 순차 실행
- 사용자가 각 본부에 대해 Full/Scoped/Temporal/Cancel 선택

→ brownfield 에서도 "자동 활성화" 없음. 모든 본부는 abstract 로 시작, dialog 로만 active 전환.

### 2.13.9 1인 창업 맥락 (Phase 1 dogfooding 기본)

Phase 1 채명정 본인 1인 사용 기준:

- **Active (기본)**: dev (본인 개발) + strategy-pm (본인 기획)
- **Abstract (상황 물어본 뒤 결정)**: qa, design, infra, taxonomy
- **기대 시나리오** (Socratic dialog 로 사용자가 결정):
  - 보험 도메인 작업 → taxonomy **scoped** 활성 (strategy-pm 하위 worker)
  - MVP 출시 임박 → qa **temporal** 활성 (Sprint N~N+2, sunset_at 지정)
  - 초기 유입 발생 → design **full** 활성
  - 배포 자동화 필요 → infra **temporal** 또는 **full**

→ 매 순간 "지금 이 상황에 본부를 뭘 켤까"는 **사용자가 Socratic dialog 통해 직접 결정**. 시스템은 사각지대(모름)만 메운다.

### 2.13.10 Phase 2 확장 (multi-tenant, collab tier)

Phase 2 에서는:

- tenant 별 divisions.yaml 분리 → tenant A는 design active, tenant B는 abstract 가능
- collab tier 에서는 **역할별 activation 제안** (예: 디자이너 합류 → design 본부 활성화 recommendation)
- 본부 custom 추가 (예: "marketing" 본부 신규) → `/sfs division add` + Socratic dialog 로 schema 정의

→ 원칙 13 은 Phase 1 과 Phase 2 **공통 기반**. Phase 전환 시 재설계 불필요.

### 위반 사례

- ❌ "기본 설치 시 6 본부 전부 active" → heavy-by-default (원칙 13 위반, 원칙 4 비용 원칙 동반 약화)
- ❌ "사용자 규모 <10이니 taxonomy 자동 비활성 처리" → prescriptive auto-decision (원칙 13 · 원칙 10 동반 위반)
- ❌ "⚠ 비권장이므로 활성화 block" → hard-block (원칙 13 핵심 위반)
- ❌ 사용자 의사 확인 없이 agent 가 임의로 design 본부를 active 로 전환 → 원칙 10 + 원칙 13 동시 위반
- ❌ temporal scope 선택 시 `sunset_at` 누락 → schema validation fail (원칙 13 · 원칙 8 동반 위반)
- ✅ 6 본부 abstract 선언 → 사용자가 `/sfs division activate qa` 호출 → Socratic dialog 실행 → temporal scope, sunset_at=Sprint7 한정 활성 → L1 이벤트 기록 → Sprint 7 종료 시 deactivate 후보 알림

---

## 2.14 원칙 간 관계 (의존 그래프)

```
[원칙 1: 도메인 agnostic frame]
   └─→ 가능하게 함 → [원칙 5: Initiative ⊃ N Sprint ⊃ N PDCA] (본부 추가/제거 자유)
   └─→ 가능하게 함 → [원칙 8: YAML driven] (frame 코드 / domain 데이터 분리)
   └─→ 전제 → [원칙 11: Brownfield First Pass] (discovery가 domain context를 frame에 주입)
   └─→ 전제 → [원칙 13: Progressive Activation] (abstract/active 전환 = frame은 동일, 본부만 가변)

[원칙 2: 자기검증 금지]
   └─→ 운영 보장 → [원칙 3: 본부장 = operator]
   └─→ 운영 보장 → [원칙 4: evaluator = fork + read-only]
   └─→ 운영 보장 → [원칙 9: G0 평가 = Tier 3 (brainstorm 작성자 ≠ G0 평가자)]
   └─→ 운영 보장 → [원칙 12: retro brainstorm 금지] (agent가 자기 입력을 역설계하지 못하도록)

[원칙 5: 3 레이어 위계]
   └─→ 전제 → [원칙 9: Initiative 단위에만 G0 적용 — Sprint 단위 강제 X]
   └─→ 보강 → [원칙 13: Phase 1 기본 active 본부 = dev + strategy-pm 2개만]

[원칙 9: G0 Brainstorm]
   └─→ 보강 → [원칙 5: Sprint scope가 intent discovery 후 결정됨]
   └─→ 범위 제한 → [원칙 12: 기존 기능에는 G0 skip, 미래 결정에만 적용]
   └─→ 프로토콜 유사 → [원칙 13: Socratic dialog도 intent discovery 패턴 공유]

[원칙 6: 로컬 private]
   └─→ 가능하게 함 → [원칙 7: CLI + GUI 공유] (race 없음)

[원칙 7: CLI + GUI 공유]
   └─→ 전제 → [원칙 8: 상품화 분리] (Phase 2 GUI 추가 비용 0)

[원칙 8: YAML driven]
   └─→ 3-state 확장 → [원칙 13: activation_state = abstract/active/deactivated]

[원칙 10: 사람 최종 필터]
   └─→ 이중 방어 → [원칙 2: 자기검증 금지] (agent→agent 차단을 system→human 층에서 재확인)
   └─→ 보완 → [원칙 9: G0 Brainstorm Gate] (진입 필터 + 출구 필터 = LLM self-loop 이중 차단)
   └─→ 제약 → [gate/g4-acceptance] (최종 수락 권한은 사람 고유)
   └─→ 운영 공조 → [원칙 11: G-1 Intake Gate의 Human Approval Block]
   └─→ 운영 공조 → [원칙 12: discovery-report 최종 서명]
   └─→ 운영 채널 → [원칙 13: 본부 활성화 dialog protocol이 원칙 10의 한 구현]

[원칙 11: Brownfield First Pass]          🆕 v0.4-r2
   └─→ 선행 조건 → [원칙 9: brownfield 진입 시 G-1 먼저, 이후 G0 (신규 기능에만)]
   └─→ 범위 설정 → [원칙 12: discovery 단계에서 retro brainstorm 금지]
   └─→ 비용 제약 → [원칙 4: discovery는 Haiku+Sonnet만 (Opus 금지)]
   └─→ 데이터 보호 → [원칙 6: 기존 docs/는 read-only, .sfs-local/에만 쓰기]
   └─→ 입력 공급 → [원칙 13: discovery 결과가 본부 recommendation trigger로 연결]

[원칙 12: Brownfield No Retro Brainstorm] 🆕 v0.4-r2
   └─→ 범위 제한 → [원칙 9: G0는 미래 결정에만, 과거에는 evidence/existing-implementation]
   └─→ 보강 → [원칙 2: agent가 자기 입력을 역설계하지 못하도록 추가 장벽]
   └─→ 기록 규칙 → [rule/l3-no-backfill] (L3에 과거 이력 역삽입 금지)

[원칙 13: Progressive Activation + Non-Prescriptive Guidance] 🆕 v0.4-r3
   └─→ 운영 구현 → [원칙 10: human-final-filter의 dialog protocol 구체화]
   └─→ 3-state 확장 → [원칙 8: YAML의 activation_state 필드 추가]
   └─→ Phase 1 재정의 → [원칙 5: 기본 active = dev + strategy-pm 2개만]
   └─→ 차단 금지 → [rule/never-hard-block] ⚠ 비권장도 사용자 선택 시 수용
   └─→ 기록 규칙 → [l1.division.dialog.*] (모든 활성화 결정은 L1 이벤트화)
```

→ **13개 원칙은 상호 강화** 관계. 어느 하나를 빼면 다른 원칙도 약화된다.
→ v0.4-r2 에서 추가된 원칙 10·11·12 는 **"LLM 자체 순환(self-loop)을 system/human/time 3축에서 차단"** 하는 방어선.
→ v0.4-r3 에서 추가된 원칙 13 은 **"LLM paternalism을 user-agency 축에서 차단"** 하는 보완 방어선.

| 차단 축 | 담당 원칙 | 방어선 위치 |
|---|---|---|
| agent ↔ agent | 원칙 2, 4 | 같은 LLM 시스템 내부 |
| system ↔ human | 원칙 10 | 시스템 경계 외부 |
| 현재 ↔ 과거 | 원칙 11, 12 | 시간축 (brownfield 맥락) |
| **system → user agency** | **원칙 13** 🆕 | **선택권 축 (paternalism 방지)** |

→ 4축 방어가 합쳐지면 **LLM 시스템이 자기 출력·자기 판단·자기 과거·자기 권한을 모두 스스로 검증·결정할 수 없는 구조** 가 완성된다.
이것이 Solon 이 "AI agent 조직"이면서도 사람의 통제를 벗어나지 않는 구조적 이유.

---

*(끝)*
