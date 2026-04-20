---
doc_id: sfs-v0.4-s05-gate-framework
title: "§5. Gate Framework G-1 + G1~G5 + 7 Failure Modes"
version: 0.4-r2
status: draft
last_updated: 2026-04-20
audience: [architects, division-heads, evaluators, implementers]
required_reading_order: [s00, s02, s03, s04, s05]

depends_on:
  - sfs-v0.4-s03-c-level-matrix
  - sfs-v0.4-s04-pdca-redef

defines:
  - concept/gate
  - concept/g-1-intake-gate
  - concept/g1-plan-gate
  - concept/g2-design-gate
  - concept/g3-pre-handoff-gate
  - concept/g4-check-gate
  - concept/g5-sprint-retro-gate
  - schema/gate-call-contract
  - schema/gate-report-v1
  - schema/g-1-signature-v1
  - formula/g4-per-division
  - enum/failure-mode-7
  - concept/5-axis-cpo-evaluation
  - evaluator/discovery-report-validator

references:
  - division/strategy-pm (defined in: s03)  # v0.4-r3: 구 division/pm
  - division/design (defined in: s03)
  - division/dev (defined in: s03)
  - division/qa (defined in: s03)
  - division/taxonomy (defined in: s03)
  - division/infra (defined in: s03)
  - role/cpo (defined in: s03)
  - concept/evaluator-pool (defined in: s03)
  - concept/pdca-phase (defined in: s04)
  - phase/p-1-discovery (defined in: s04)
  - principle/gate-operator (defined in: s02)
  - principle/self-validation-forbidden (defined in: s02)
  - principle/human-final-filter (defined in: s02)
  - principle/brownfield-first-pass (defined in: s02)
  - principle/brownfield-no-retro-brainstorm (defined in: s02)
  - template/discovery-report (defined in: s07)
  - schema/discovery-report-v1 (defined in: s07)
  - mode/greenfield (defined in: s07)
  - mode/brownfield (defined in: s07)
  - schema/gate-report-v1.full (defined in: appendix/schemas/gate-report.schema.yaml)

affects:
  - sfs-v0.4-s06-escalate-plan
  - sfs-v0.4-s08-observability
  - sfs-v0.4-s09-differentiation
  - sfs-v0.4-s10-phase1-implementation
---

# §5. Gate Framework G-1 + G1~G5 + 7 Failure Modes

> **Context Recap (자동 생성, 수정 금지)**
> §4 PDCA 단계 전환점마다 **외부 검증 게이트**를 통과해야 한다. Gate는 도메인 agnostic이고, Evaluator만 본부별로 교체된다.
> 본부장은 Gate **오퍼레이터**(원칙 2.3) — Evaluator를 호출할 뿐 판단하지 않는다.
> 여기서 정의된 `schema/gate-report-v1`은 §6 Escalate 트리거 조건, §8 L2 SSoT 저장의 핵심 데이터.
>
> **v0.4-r2 변경 (brownfield 대응)**: Gate 집합이 **6개로 확장**됨 — G1~G5 (모든 모드 공통) + **G-1 Intake Gate (brownfield 전용)**.
> G-1은 §4.3에서 정의된 P-1 Discovery Phase의 종료 게이트로, `discovery-report.md`의 완성도와 **사람 최종 승인**(원칙 10 `human-final-filter`, 원칙 11 `brownfield-first-pass`)을 확인한다.
> G-1은 PDCA 사이클 내부 Gate가 아니라 **install 시점의 1회성 intake Gate**이므로 별도 섹션(§5.11)에서 상세 명세한다.

---

## TOC

- 5.1 Gate 매트릭스 (G-1 + G1~G5)
- 5.2 Gate별 Evaluator 매핑 (본부별)
- 5.3 Gate Call Contract (입력 표준)
- 5.4 GateReport Schema (출력 표준)
- 5.5 G4 Formula (본부별 가중치)
- 5.6 5-Axis CPO 평가 (G4 공통)
- 5.7 7 Failure Modes 정의
- 5.8 Gate별 Failure Mode 허용 매트릭스
- 5.9 Gate 실행 타임라인 (PDCA 위에 겹쳐보기)
- 5.10 Gate와 §6 Escalate의 연결점
- 5.11 G-1 Intake Gate 상세 명세 (brownfield 전용)

---

## 5.1 Gate 매트릭스

`concept/gate`: **PDCA 단계 전환 지점에서 실행되는 외부 검증 절차**. 자기가 만든 산출물은 자기가 통과시키지 못한다 (원칙 2.2). Gate는 **오퍼레이터 + Evaluator + GateReport**의 3요소로 구성된다.

| Gate | 의미 | 오퍼레이터 | 트리거 시점 | 적용 모드 | 통과 시 다음 단계 | 비용 예산 (Phase 1) |
|:---:|------|-----------|----------|:---:|----------------|-----------------|
| **G-1** 🆕 | Intake Gate — discovery-report 완성도 + **사람 최종 승인** (§5.11) | `strategy/ceo` | `install.sh --mode brownfield` 직후 P-1 완료 시점 | brownfield only | P-1 종료 → Plan(G1) 진입 허가 | Sonnet × 2~3회 (validator) + **human review time** |
| **G1** | Plan Gate — 요구사항·AC 측정 가능성 | `strategy/pm/lead` | Plan 문서 작성 완료 시 | 공통 | Design 진입 허가 | Opus × 1회 + Sonnet × N회 |
| **G2** | Design Gate — 설계 완성도 | 각 본부장 (lead) | Design 문서 작성 완료 시 | 공통 | Do 진입 허가 | Sonnet × 2~3회 |
| **G3** | Pre-Handoff Gate — 산출물 핸드오프 가능성 (binary) | 각 본부장 (lead) | Do 완료 직전 | 공통 | 핸드오프 OR Check 진입 | Sonnet × 1~2회 |
| **G4** | Check Gate — 실제 vs 설계 gap (정량+정성) | `quality/qa/lead` + `strategy/cpo` | Do 완료 후 | 공통 | Act 진입 OR Escalate | Sonnet × 3~5회 + Opus × 1회 |
| **G5** | Sprint Retro — 학습 루프 (정성) | `strategy/ceo` + `strategy/pm/lead` | Sprint 종료 시 | 공통 | 다음 Sprint 반영 | Opus × 1~2회 |

### 5.1.1 Gate 설계 3원칙

1. **외부성** — 동일 본부의 worker가 작성한 산출물은 같은 본부의 evaluator가 판정하지 **않음** (원칙 2.2 `principle/self-validation-forbidden`). Evaluator Pool에서 별도 fork된 read-only agent가 호출된다.
2. **표준성** — 입력(`schema/gate-call-contract`)·출력(`schema/gate-report-v1`)이 gate 종류에 관계없이 **동일 스키마**. 따라서 L2 SSoT에 동형 저장, L3 Notion 대시보드 단일 쿼리로 집계 가능.
3. **분리성** — Gate 통과 여부 판단은 **Evaluator**, Gate 실행 의사결정(언제 호출/누구에게/재시도)은 **오퍼레이터**. 이 둘은 다른 모델·다른 agent.

### 5.1.2 왜 G3(Pre-Handoff)을 따로 두었는가

bkit에서는 Do 완료 → 바로 Check 게이트. 그러나 Solon은 **본부 간 핸드오프**가 잦기 때문에(디자인 → 개발 → QA), Do 단계 내에서 산출물이 "다음 본부가 받아먹을 수 있는 상태인지"를 **binary**로 먼저 자체 검증한다.

- G3 FAIL → 해당 본부 내 재작업, G4까지 가지 않음 (비용 절약)
- G3 PASS → Do 완료 처리 → G4 Check 진입

G3는 본부 **내부** 완료 조건, G4는 **전사** 품질 조건이라는 것이 핵심 구분이다.

### 5.1.3 왜 G5(Sprint Retro)가 필요한가

G1~G4는 PDCA **단일 사이클** 내부 게이트. G5는 **Sprint = N개 PDCA** 전체에 대한 **학습 게이트**:
- 6 본부 × N PDCA의 결과를 모아 패턴을 추출
- Gate FAIL 빈도·대기시간·비용 집계
- 실패 패턴 → `memory/learnings-v1.md` 축적 (H6 학습 루프, §6 참조)

G5 결과는 **다음 Sprint의 Plan 입력**으로 연결된다 (Sprint 간 학습 전파).

### 5.1.4 왜 G-1(Intake)이 필요한가 — brownfield 전용 게이트

`concept/g-1-intake-gate`: **`install.sh --mode brownfield` 직후 P-1 Discovery Phase의 종료점에서 실행되는 intake 게이트**. G1~G5가 PDCA 사이클 **내부** 게이트라면, G-1은 "Solon을 아직 투입할지 말지" 자체를 결정하는 **경계 게이트**이다.

네 가지 이유로 G-1을 G1과 합치지 않고 분리한다:

1. **적용 모드 비대칭** — greenfield는 P-1이 없으므로 G-1을 거치지 않는다(`rule/greenfield-vs-brownfield-entry`, §4). G1과 합치면 greenfield flow에 불필요한 분기 생성.
2. **오퍼레이터가 다름** — G1은 `strategy/pm/lead` 주도(요구사항 측정성 판단), G-1은 `strategy/ceo` 주도(전략적 "투입할 가치가 있는가" 판단 + 최종 승인).
3. **사람 승인이 필수** — G-1은 원칙 10(`human-final-filter`)을 가장 강하게 요구한다. `.g-1-signature.yaml` 파일에 **사용자 이름·날짜·6개 체크박스 서명**이 없으면 PASS 불가. G1은 자동 pass 가능.
4. **1회성 (per install)** — G-1은 Solon 도입 시 **1회**만 실행된다(`rule/p-1-run-once-per-install`, §4.3.10). G1~G5는 매 Sprint × 매 PDCA마다 반복. Gate 빈도·집계 로직이 전혀 다름.

### 5.1.5 Gate 집합의 모드별 가시성

| 모드 | 실행되는 Gate | 비고 |
|------|---------------|------|
| **greenfield** | G0(brainstorm, §4 정의) → G1 → G2 → G3 → G4 → G5 | G-1 skip |
| **brownfield** | **G-1 (intake)** → G0 or direct-to-G1 → G1 → G2 → G3 → G4 → G5 | G-1 PASS 후 G0 호출 여부는 원칙 12(`brownfield-no-retro-brainstorm`)로 제한됨 |

→ 두 모드에서 공통적으로 나타나는 게이트(G1~G5)는 본 섹션 이하에서 통합 기술하고, G-1 고유 스펙은 §5.11로 격리.

---

## 5.2 Gate별 Evaluator 매핑 (본부별)

| Gate | strategy/pm | taxonomy | design | dev | quality/qa | infra |
|:---:|---|---|---|---|---|---|
| **G-1** 🆕 | (공통, `discovery-report-validator` Sonnet — 본부별 축이 아니라 repo 전체 discovery 대상) | (공통) | (공통) | (공통) | (공통) | (공통) |
| **G1** | `plan-validator` + `prd-validator` | `plan-validator` + `taxonomy-reqs-validator` | `plan-validator` + `design-reqs-validator` | `plan-validator` + `tech-reqs-validator` | `plan-validator` + `qa-reqs-validator` | `plan-validator` + `infra-reqs-validator` |
| **G2** | `user-flow-validator` | `taxonomy-draft-validator` | `design-critique` (cowork plugin 재사용) | `design-validator` (bkit 재사용) | `test-case-validator` | `terraform-validator` / `k8s-manifest-validator` |
| **G3** | `prd-lock-validator` | `taxonomy-consistency` | `accessibility-review` + `design-handoff` (cowork 재사용) | `code-analyzer` (bkit 재사용) | `qa-readiness` | `cost-estimator` + `security-scan` |
| **G4** | [§5.5 formula] | [§5.5 formula] | [§5.5 formula] | [§5.5 formula] | [§5.5 formula] | [§5.5 formula] |
| **G5** | (공통, `sprint-retro-analyzer` Opus) | (공통) | (공통) | (공통) | (공통) | (공통) |

### 5.2.1 공통 Evaluator (`plan-validator`)

G1에서 **모든 본부**가 공유. 다음 6가지를 확인:
1. AC가 측정 가능한 동사로 작성되었는가 ("개선한다" X, "95% 이상" O)
2. 범위(scope)가 Sprint 기간 내 달성 가능한가
3. 선행 PDCA 의존성(`depends_on`)이 명시되었는가
4. `provides_to`에 하위 PDCA가 있다면 그것도 명시되었는가
5. 본부별 추가 AC(예: 개발은 성능 수치, 인프라는 비용 상한)가 존재하는가
6. AC ID가 `AC-{sprint}-{seq}` 포맷을 따르는가

### 5.2.2 기존 도구 재사용 매핑

| Solon Evaluator | 출처 | 재사용 방식 |
|---------------|------|-----------|
| `design-critique` | cowork plugin | 프롬프트 그대로, 호출 방식만 MCP 표준화 |
| `accessibility-review` | cowork plugin | 동일 |
| `design-handoff` | cowork plugin | 동일 |
| `code-analyzer` | bkit | sub-agent 호출 그대로, read-only flag만 추가 |
| `design-validator` | bkit | 동일 |
| `gap-detector` | bkit | G4 정량 축으로 사용 |

→ **기존 자산 재사용이 Phase 1 속도의 핵심**. Solon의 기여는 "언제/어떤 조합으로 호출할지"를 매트릭스로 정의한 것.

### 5.2.3 신규 Evaluator (Phase 1에서 만들어야 하는 것)

| Evaluator | 목적 | 모델 | 우선순위 |
|-----------|------|------|--------|
| `discovery-report-validator` 🆕 | G-1 공통 — discovery-report 완성도 + 서명 블록 검증 | Sonnet 4.6 | P0 (brownfield 지원 시) |
| `plan-validator` | G1 공통 | Sonnet 4.6 | P0 |
| `taxonomy-reqs-validator` | 택소노미 AC 검증 | Sonnet 4.6 | P0 |
| `taxonomy-consistency` | 택소노미 내부 일관성 | Sonnet 4.6 | P0 |
| `prd-lock-validator` | PRD freeze 조건 | Sonnet 4.6 | P1 |
| `user-flow-validator` | 사용자 흐름 완결성 | Sonnet 4.6 | P1 |
| `cost-estimator` | 인프라 비용 추정 | Sonnet 4.6 | P1 |
| `sprint-retro-analyzer` | G5 학습 패턴 추출 | **Opus 4.6** | P0 |

→ 총 8개 신규 agent(Phase 1에서 `discovery-report-validator` 포함 시). Phase 1 구현 범위는 §10에서 확정.

---

## 5.3 Gate Call Contract (입력 표준)

`schema/gate-call-contract`: 오퍼레이터가 Evaluator를 호출할 때 건네는 표준 입력.

```yaml
# ────────────────────────────────────────────────
# gate_call (오퍼레이터 → Evaluator)
# ────────────────────────────────────────────────
gate_call:
  # 호출 식별
  call_id: "GC-042-G3-001"           # 고유 ID (L1 logging key)
  sprint_id: "SP-005"
  pdca_id: "PDCA-042"
  gate_id: "G3"                      # G1 | G2 | G3 | G4 | G5
  target_division: "dev"
  target_phase: "do"                 # plan | design | do | check | act

  # Evaluator 지정
  evaluator:
    agent_id: "quality/qa/code-analyzer"
    version: "1.2.0"                 # semver, 재현성 보장
    model: "claude-sonnet-4-6"       # 필수: 어떤 모델로 돌렸는지 기록
    read_only: true                  # 파일 시스템 변경 금지 플래그

  # 검증 대상 (파일 경로 + git ref)
  context_refs:
    - path: "docs/02-design/PDCA-042.design.md"
      ref: "commit:abc123"
    - path: "src/services/UserService.kt"
      ref: "commit:def456"
    - path: "docs/01-plan/PDCA-042.plan.md"
      ref: "commit:abc123"

  # 정량 기준 (본부별 상이, §5.5)
  thresholds:
    min_score: 85                    # 0~100
    blocking_issues: 0               # critical/major 허용 개수
    required_axes:                   # 평가 축별 최소 기준
      accuracy: 80
      completeness: 80

  # 정책 옵션
  policy:
    on_timeout: "escalate"           # escalate | retry | user-prompt
    max_retries: 1
    budget_usd: 0.50                 # 이 호출의 최대 비용

  # 감사 메타
  called_by: "dev/lead"
  called_at: "2026-04-19T10:00:00Z"
```

### 5.3.1 필수 필드 vs 선택 필드

| 필드 | 필수 | 비고 |
|------|:---:|------|
| `call_id`, `gate_id`, `target_division`, `evaluator.agent_id`, `evaluator.model`, `context_refs` | ✅ | 없으면 Evaluator 호출 거부 |
| `thresholds`, `policy` | ⚠️ | 없으면 본부 기본값 사용 (§5.5) |
| `budget_usd` | ⚠️ | Phase 2에서 강제화 (Phase 1은 warn only) |

### 5.3.2 Evaluator의 read-only 강제

`evaluator.read_only: true`는 선언만이 아니라 **실행 환경에서 강제**된다:
- sub-agent sandbox 시 쓰기 권한 차단
- Evaluator는 `GateReport` 하나만 반환 (파일 생성·수정 금지)
- 이를 위반한 Evaluator는 Gate 자체를 FAIL 처리 (`ABORT` mode)

→ 원칙 2.2 (self-validation-forbidden)을 **프로세스**가 아니라 **런타임**으로 보장.

---

## 5.4 GateReport Schema (출력 표준)

`schema/gate-report-v1`: Evaluator가 반환하는 표준 응답. 전체 스키마는 [appendix/schemas/gate-report.schema.yaml](appendix/schemas/gate-report.schema.yaml)에 정의하고, 아래는 필드 요약.

```yaml
# ────────────────────────────────────────────────
# gate_report (Evaluator → 오퍼레이터)
# ────────────────────────────────────────────────
gate_report:
  # 호출 연결
  call_id: "GC-042-G3-001"           # gate_call.call_id와 동일
  report_id: "GR-042-G3-001"
  gate_id: "G3"
  schema_version: "v1"

  # 핵심 판정 (§5.7)
  verdict: "SUCCESS"                 # SUCCESS | FAIL-FIXABLE | FAIL-HARD | STALL | CONFLICT | TIMEOUT | ABORT
  score: 87                          # 0~100, 없으면 null
  pass: true                         # verdict == SUCCESS의 편의 필드

  # 세부 분석 (본부/gate별 가변)
  breakdown:
    accuracy: 90
    completeness: 85
    style: 88

  # 이슈 리스트
  issues:
    - id: "ISS-001"
      severity: "minor"              # critical | major | minor | info
      path: "src/services/UserService.kt:42"
      message: "Extract shared validation to util"
      blocking: false

  # 권고 조치
  recommendations:
    - "Extract shared validation to util (ISS-001)"
    - "Add edge case test for null email"

  # 에스컬레이션 필요 여부 (§6 트리거)
  escalation:
    required: false
    case: null                       # null | "alpha" | "beta"
    reason: null

  # 감사 (재현성)
  audit:
    evaluator_agent: "quality/qa/code-analyzer"
    evaluator_version: "1.2.0"
    evaluator_model: "claude-sonnet-4-6"
    started_at: "2026-04-19T10:00:00Z"
    ended_at: "2026-04-19T10:00:04Z"
    duration_ms: 4200
    input_tokens: 12450
    output_tokens: 820
    cost_usd: 0.042

  # 사용자 개입 필요 여부
  user_decision_needed: false
  user_prompt: null                  # needed == true일 때만
```

### 5.4.1 `verdict` vs `pass`의 관계

- `pass: true` ↔ `verdict: "SUCCESS"` (정확히 이 경우만 true)
- `pass: false`이면 오퍼레이터는 verdict 값에 따라 분기:
  - `FAIL-FIXABLE` → 같은 본부 재작업
  - `FAIL-HARD`, `ABORT` → §6 Escalate 트리거
  - `STALL`, `CONFLICT`, `TIMEOUT` → 사용자 개입 요청

### 5.4.2 왜 `audit` 블록이 필수인가

- **재현성**: 동일 model + version + input으로 다시 돌리면 같은 결과 (decision reproducibility)
- **비용 집계**: L3 Notion 대시보드의 "이번 Sprint 총 비용" 쿼리 소스
- **벤치마킹**: 같은 Evaluator가 시간이 지나며 점수가 바뀌면 drift 감지
- **디버깅**: FAIL 발생 시 어떤 모델·어떤 context로 호출했는지 복원

### 5.4.3 Unknown 필드 처리 규칙

Evaluator가 스키마 외 필드를 추가해서 반환할 수 있다. 오퍼레이터는:
- 알려진 필드 → 정규 처리
- 알려지지 않은 필드 → L2 SSoT에 **보존**, 경고 로그 emit
- 추후 schema v2로 승격될 수 있음

→ **forward-compatible** 설계 (bkit의 단방향 호환성 문제 회피).

---

## 5.5 G4 Formula (본부별 가중치)

G4는 **정량 축 40% + 정성 축(5-Axis CPO) 60%**의 가중합. 정량 축은 본부별로 다르다.

| 본부 | G4 Formula | 정량 축 세부 | 비고 |
|------|-----------|-------------|------|
| **dev** | `G4 = gap-detector × 0.4 + 5-Axis(CPO) × 0.6` | gap-detector = bkit 재사용, design ↔ code 일치도 | G3 binary가 pre-check |
| **design** | `G4 = design-guide-match × 0.4 + 5-Axis × 0.6` | design-guide-match = 디자인 시스템 토큰 준수율 | accessibility-review가 pre-check |
| **strategy/pm** | `G4 = AC-coverage × 0.4 + 5-Axis × 0.6` | AC-coverage = PRD의 AC 중 Do 결과가 충족한 비율 | prd-lock이 pre-check |
| **taxonomy** | `G4 = taxonomy-consistency × 0.4 + 5-Axis × 0.6` | taxonomy-consistency = 용어 충돌/중복 스캔 점수 | — |
| **quality/qa** | `G4 = test-coverage-delta × 0.3 + defect-leak × 0.1 + 5-Axis × 0.6` | 타 본부 상호검증 필요 없음 — qa의 산출물은 **타 본부의 Do 결과 자체를 검증한 리포트**이므로 메타-self-validation 문제 없음 | defect-leak = 테스트 후 프로덕션 버그 수 (역지표) |
| **infra** | `G4 = cost-variance × 0.2 + stability-score × 0.2 + 5-Axis × 0.6` | cost-variance = 예산 대비 실집행, stability-score = 가용성/에러율 | cost-estimator + security-scan이 pre-check |

### 5.5.1 [OPEN → RESOLVED] 품질·인프라 본부 공식

이전 skeleton의 [OPEN] 항목 해결:

**품질 본부 G4**: QA 산출물은 **타 본부의 Do 결과에 대한 테스트 리포트**이지, QA 자체가 만든 기능이 아니다. 따라서 self-validation 우려는 원칙적으로 없음 — QA evaluator가 평가하는 것은 "테스트 설계·실행의 완결성"이지 "자신이 만든 기능"이 아니다. 다만 두 가지 안전장치:
1. `test-coverage-delta`는 **다른 본부 code-analyzer**가 측정 (QA 본부 스스로 측정 X)
2. `defect-leak`은 Sprint+1 이후에만 확정 (시간차 검증)

**인프라 본부 G4**: `cost-variance`(예산 ±10% 이내)와 `stability-score`(가용성 99% / 에러율 1% 이하)의 조합. 두 지표 모두 **외부 observability 시스템**(Datadog 등)에서 측정 — 인프라 agent 스스로가 측정하지 않음.

### 5.5.2 `min_score`의 본부별 기본값

| 본부 | 기본 `min_score` | 근거 |
|------|:---:|------|
| dev | 85 | bkit 경험치, 코드 품질 게이트 표준 |
| design | 80 | 주관성 영향, 조금 낮게 |
| strategy/pm | 85 | AC 측정 가능성이 높음 |
| taxonomy | 90 | 일관성은 binary에 가까움, 높게 |
| quality/qa | 85 | 테스트 커버리지 목표 |
| infra | 85 | 비용/안정성 모두 측정 가능 |

`gate_call.thresholds.min_score`에서 본부별 override 가능.

---

## 5.6 5-Axis CPO 평가 (G4 공통)

**CPO가 모든 본부 G4에서 60% 가중치로 수행하는 정성 평가 5축**. 도메인 agnostic이고 Solon 수명 동안 고정.

| # | 축 이름 | 정의 | 평가 포커스 | 0~100 루브릭 예시 |
|:-:|--------|------|-----------|---------------|
| 1 | **Value-Fit** | 이 결과물이 제품/조직의 핵심 가치 주장을 얼마나 강화하는가 | "만든 이유"가 살아있는지 | 100=핵심 가치 직격, 50=기능만 동작, 0=가치와 무관 |
| 2 | **User-Outcome** | 실제 사용자(또는 다음 본부 = 내부 고객)가 체감하는 결과 | 누가 무엇을 더 쉽게/빠르게 하게 되는가 | 100=측정된 outcome 개선, 50=outcome 추정, 0=기능만 존재 |
| 3 | **Soundness** | 기술·구조적 견고함 — 재발 위험, 부채 수준 | 편법 vs 정공법 | 100=정공법, 50=수용 가능한 단기 해결, 0=폭탄 |
| 4 | **Maintainability** | 6개월 후의 나 / 다음 Sprint가 감당할 수 있는가 | 문서·테스트·네이밍·모듈화 | 100=혼자 유지 가능, 50=일부 부채, 0=블랙박스 |
| 5 | **Future-Proof** | 로드맵 다음 단계와의 정합 (v0.4 → Phase 2 확장 내성) | 지금 만든 것이 나중에 바꿔야 할 확률 | 100=확장점만 추가, 50=일부 재작성, 0=전체 폐기 |

### 5.6.1 5-Axis 계산식

```
5-Axis score = (Value-Fit + User-Outcome + Soundness + Maintainability + Future-Proof) / 5
```

단순 평균. 축별 가중치 변경은 Phase 2 이후 검토.

### 5.6.2 CPO가 정량 축을 무시해야 할 때

5-Axis 평가 시 CPO는 **정량 점수를 사전 참조하지 않는다** (인지 편향 방지). 프로세스:
1. 오퍼레이터가 CPO에게 **context_refs만** 전달 (정량 점수 포함 X)
2. CPO가 독립적으로 5-Axis 평가 → `breakdown` 생성
3. 오퍼레이터가 정량 40% + 5-Axis 60%을 **합산** (이 합산은 CPO가 아니라 오퍼레이터의 책임)

→ 정량과 정성의 **교차 오염 방지**. 이게 없으면 CPO가 정량 점수에 동조하는 편향 발생.

### 5.6.3 5-Axis vs 기존 평가 시스템

| 시스템 | 축 | Solon 5-Axis와의 차이 |
|--------|---|-----------------|
| RICE (Reach/Impact/Confidence/Effort) | 4축 | Solon은 **평가 도메인**(이미 만든 것)에 특화, RICE는 **우선순위** |
| OKR | Objective + Key Results | Solon 5-Axis는 **결과물 품질**, OKR은 **목표 설정** |
| DORA (lead time, deploy freq, MTTR, CFR) | 4축 | Solon은 **엔지니어링 메트릭이 아니라 결과물 자체**의 품질 |
| bkit `breakdown: {accuracy/completeness/style}` | 3축 | Solon은 **비즈니스 가치 축**(Value-Fit, User-Outcome)이 추가됨 |

→ 5-Axis는 **CPO Tier(전략)**의 관점이지, Developer Tier(실무)의 관점이 아니다.

---

## 5.7 7 Failure Modes 정의

`enum/failure-mode-7`: Gate verdict의 전체 경우의 수. **7개로 고정**, 임의 확장 금지.

| Mode | 의미 | 트리거 조건 | 오퍼레이터 대응 | §6 연결 |
|------|------|-----------|-------------|--------|
| **SUCCESS** | 모든 기준 통과 | `score ≥ min_score` & `blocking_issues == 0` & `required_axes` 모두 충족 | 다음 PDCA 단계 진입 | — |
| **FAIL-FIXABLE** | 기준 미달, 같은 본부 내 수정으로 해결 가능 | `score < min_score` & `blocking_issues ≤ N` & 설계 근본 문제 아님 | 같은 본부 내 재작업 (최대 `policy.max_retries`회) | — |
| **FAIL-HARD** | 설계 근본 문제 — 같은 본부 내 수정으로 해결 불가 | Evaluator가 "design-level rework required" 판단 | **Escalate 필수** | §6 Case-α |
| **STALL** | FAIL-FIXABLE이 `policy.max_retries + 1`회 반복됨, 진척 없음 | 동일 Gate에서 3회 연속 FAIL + score 개선 < 5점 | 사용자 개입 요청 (Haiku가 prompt 생성) | §6.7 user-prompt |
| **CONFLICT** | 다른 본부 산출물과 모순 | evaluator가 cross-division consistency 위반 탐지 | **5-option protocol** (§6) | §6 5-option |
| **TIMEOUT** | Evaluator 실행 시간이 `policy.timeout_ms` 초과 | runtime 측정 | 사용자 개입 요청 + 리소스/예산 점검 | §6.7 |
| **ABORT** | 요구사항(AC/PRD) 자체가 무효/모순 | evaluator가 plan-level 근본 결함 탐지 | **Case-β**: 새 PDCA 생성 + 원 PDCA archive | §6 Case-β |

### 5.7.1 왜 7개인가

- **SUCCESS/FAIL** 2축 분류는 bkit 수준으로 너무 단순
- **10+ mode**는 운영 복잡도 폭발 + 데이터 분석 불가능
- **7개**는 경험적 sweet spot: Google SRE의 alert severity(5~7개), Linear의 issue status(~6개)와 유사

**세 그룹**으로 묶어서 기억하면 쉽다:
- **Pass 계열 (1)**: SUCCESS
- **Retry 계열 (2)**: FAIL-FIXABLE, STALL
- **Escalate 계열 (4)**: FAIL-HARD, CONFLICT, TIMEOUT, ABORT

### 5.7.2 Mode 간 전이 규칙

```
FAIL-FIXABLE ──(retry N회)──> STALL
FAIL-FIXABLE ──(설계 문제 재발견)──> FAIL-HARD
TIMEOUT ──(재시도 + 동일 TIMEOUT)──> STALL
CONFLICT ──(5-option 선택 후)──> SUCCESS / FAIL-HARD
```

→ 가역 전이는 없다 (한 방향).

### 5.7.3 Mode를 늘리지 않는 이유

"부분 성공"이나 "조건부 통과" 같은 중간 mode를 만들고 싶은 유혹이 생긴다. 그러나:
- 부분 성공 = `FAIL-FIXABLE` + 높은 score (80~85)로 표현 가능
- 조건부 통과 = `SUCCESS` + `recommendations` 필드로 표현 가능

**Mode는 분기 로직이 있을 때만 추가**한다. 오퍼레이터의 코드가 `switch(verdict)`를 더 복잡하게 만들지 않는 선.

---

## 5.8 Gate별 Failure Mode 허용 매트릭스

각 Gate에서 **발생할 수 있는 mode**와 **즉시 에스컬레이션되어야 할 mode**를 명시.

| Gate | SUCCESS | FAIL-FIXABLE | FAIL-HARD | STALL | CONFLICT | TIMEOUT | ABORT |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **G-1** 🆕 | ✅ | ✅ (report 재생성 ≤2회) | 🚨 abort install (Solon 미도입 결정) | 🚨 user-prompt (사람 서명 거부 누적 시) | — (단일 보고서) | ✅ | 🚨 repo 무결성 문제 시 |
| **G1** | ✅ | ✅ | 🚨 즉시 escalate | ✅ | ⚠️ 드물게 | ✅ | 🚨 Case-β |
| **G2** | ✅ | ✅ | 🚨 즉시 escalate | ✅ | ✅ | ✅ | ⚠️ G1에서 잡혔어야 |
| **G3** | ✅ | ✅ | 🚨 즉시 escalate | 🚨 즉시 escalate | ✅ | ✅ | ⚠️ |
| **G4** | ✅ | ✅ | 🚨 즉시 escalate (Case-α) | ✅ | ✅ | ✅ | 🚨 Case-β |
| **G5** | ✅ (정성) | — | ⚠️ Sprint 실패 → 재기획 | — | — | — | — |

범례:
- ✅ 정상 발생 가능 → 오퍼레이터가 standard 대응
- 🚨 발생 시 즉시 §6 Escalate 루틴 진입
- ⚠️ 발생 가능하지만 이전 Gate에서 탐지했어야 → L3 대시보드 alarm
- — 해당 Mode는 이 Gate에서 논리적으로 불가능

### 5.8.1 해석 가이드

- **G-1에서 CONFLICT은 논리적으로 불가**: G-1은 단일 discovery-report에 대한 단일 판정이므로 cross-division conflict 개념이 없음.
- **G-1의 STALL = 사용자 서명 거부 누적**: validator가 2회 이상 PASS 권고했는데도 사용자가 signature block에 서명하지 않으면 STALL → user-prompt로 "왜 보류하는가"를 되묻는다(원칙 10 작동).
- **G-1의 ABORT = Solon 미도입 결정**: repo 무결성 문제(예: shallow clone, detached HEAD, submodule 미초기화)로 discovery 자체가 불가능한 경우 → install abort.
- **G3에서 STALL은 즉시 escalate**: G3는 binary pre-check이므로 3회 반복된 FAIL은 구조적 문제 신호.
- **G2의 ABORT은 이상신호**: Design 단계에서 요구사항 무효가 드러났다는 건 G1 plan-validator가 놓쳤다는 뜻 → L3 대시보드에서 추적해 plan-validator 개선.
- **G5는 정성 평가**: PASS/FAIL이 엄격한 의미가 아니라 "Sprint 회고에서 학습할 것이 있는가"의 표현.

### 5.8.2 Failure Mode 집계 메트릭 (§8 연결)

L3 Notion 대시보드에 다음 5개 핵심 지표로 표면화:
1. `gate_pass_rate` = SUCCESS / Total (Gate별)
2. `mean_time_to_pass` = FAIL 첫 발생 → SUCCESS까지 시간
3. `escalation_rate` = (FAIL-HARD + ABORT) / Total
4. `stall_rate` = STALL / Total (건강성 역지표)
5. `cost_per_pdca` = Σ gate_report.audit.cost_usd / PDCA 수

→ §8.X Notion 대시보드 스키마 참조.

---

## 5.9 Gate 실행 타임라인 (PDCA 위에 겹쳐보기)

§4의 PDCA 단계별 Gate 호출 지점을 시간축으로 표현:

> **🆕 brownfield에서는 PLAN phase 이전에 P-1 Discovery phase + G-1 Intake Gate가 먼저 실행된다.**
> ```
> [INSTALL --mode brownfield]
>   │ install.sh discovery plan prompt
>   │
> [P-1 DISCOVERY phase] (§4.3)
>   │ /sfs discover skill 실행 (Haiku+Sonnet, Opus 금지)
>   │ discovery-report.md 작성 + evidence/ + inventory/
>   ├──> G-1 intake (discovery-report-validator + human signature)
>   │       ├─ SUCCESS ─> [PLAN phase]로 진입
>   │       ├─ FAIL-FIXABLE ─> report 재생성 (≤2회)
>   │       ├─ STALL ─> user-prompt
>   │       └─ ABORT ─> install abort (repo 무결성 문제)
>   │
> [greenfield는 여기부터 시작]
> ```
> 아래 greenfield 흐름은 G-1 PASS 이후에도 동일하게 실행된다.

```
[PLAN phase]
  │ plan document draft
  │ plan document finalize
  ├──> G1 plan-validator (+ 본부별 reqs-validator)
  │       │
  │       ├─ SUCCESS ─┐
  │       ├─ FAIL-FIXABLE ─> replan (max retries)
  │       ├─ FAIL-HARD ─> §6 Case-α
  │       └─ ABORT ─> §6 Case-β
  │                   │
[DESIGN phase] <──────┘
  │ design document draft
  │ design document finalize
  ├──> G2 design-validator (+ 본부별 sub-validator)
  │       └─> SUCCESS 시에만 Do 진입
  │
[DO phase]
  │ implementation / artifact production
  │ (중간중간 code-analyzer, design-critique 등 소규모 Gate 가능 — Gate 미기록)
  │ implementation finalize
  ├──> G3 pre-handoff (binary)
  │       ├─ SUCCESS ─┐
  │       └─ FAIL ─> Do 재작업 or 다음 Phase 진입
  │                   │
[CHECK phase] <───────┘
  │ gap analysis
  │ 5-axis CPO 평가
  ├──> G4 check (정량 + 5-Axis)
  │       └─> Act 진입 or Escalate
  │
[ACT phase]
  │ improvement / learning recording
  │ memory update
  │ (Gate 없음, PDCA 완료)
  │
(Sprint 끝)
  │
[SPRINT RETRO]
  ├──> G5 sprint-retro-analyzer (Opus)
  │       └─> next sprint plan 입력
```

### 5.9.1 Gate 간 평균 소요 시간 (목표치)

| 구간 | 목표 | 비고 |
|------|------|------|
| **G-1** validator 응답 | < 5분 | Sonnet × 2~3회 (schema 검증 + 완성도 scoring) |
| **G-1** human review | 대기시간 제외 | repo 규모 Small 10~20분 / Medium 30~60분 / Large 2~4시간 (§7.10.8) |
| G1 호출 → 응답 | < 2분 | Sonnet 단일 호출 + 병렬 sub |
| G2 호출 → 응답 | < 5분 | design-critique + design-validator 병렬 |
| G3 호출 → 응답 | < 3분 | binary check 위주 |
| G4 호출 → 응답 | < 10분 | gap-detector(스캔) + CPO(Opus) 직렬 |
| G5 호출 → 응답 | < 20분 | Sprint 전체 데이터 분석 |

→ 이를 넘으면 `TIMEOUT` verdict. `policy.timeout_ms`에 본부별로 override 가능.

---

## 5.10 Gate와 §6 Escalate의 연결점

§6에서 정의되는 Escalate-Plan은 **Gate가 FAIL을 뱉은 순간 시작**된다. Gate → Escalate 연결 조건:

| Gate Verdict | §6 루트 | 트리거 |
|-------------|--------|-------|
| `ABORT` (G-1) 🆕 | **install-abort** — Solon 미도입 결정 | `gate_report.escalation = {required: true, case: "install-abort"}` (§6에서 별도 루트) |
| `STALL` (G-1) 🆕 | **user-prompt** (서명 보류 사유) | discovery-report는 PASS였는데 사용자가 signature 보류 |
| `FAIL-HARD` (G1/G2/G3/G4) | **Case-α** — AC-level reopen | `gate_report.escalation = {required: true, case: "alpha"}` |
| `ABORT` (G1/G4) | **Case-β** — 새 PDCA 생성 | `gate_report.escalation = {required: true, case: "beta"}` |
| `CONFLICT` (G2~G4) | **5-option protocol** | cross-division evaluator의 conflict 발견 |
| `STALL`/`TIMEOUT` (G1~G4) | **user-prompt** | Haiku가 user 개입 prompt 생성 |

→ Gate가 뱉은 `gate_report`는 그 자체로 Escalate 입력이 된다. §6에서 Escalation schema는 `gate_report`를 **참조**(`gate_report_ref`)하는 구조.

### 5.10.1 Gate 실패가 Memory로 들어가는 경로

1. Evaluator → `gate_report` 생성
2. 오퍼레이터가 L2 SSoT에 commit: `docs/sprint-NN/PDCA-MMM/gates/GR-MMM-GN-SSS.yaml`
3. G5 시점에 `sprint-retro-analyzer`가 Sprint 전체 gate_report를 스캔
4. 패턴 발견 시 `memory/learnings-v1.md`에 "which Gate, which Mode, what pattern" 기록
5. 다음 Sprint Plan 작성 시 `plan-validator`가 memory를 읽어 동일 실패 회피

→ 이 사이클이 §9에서 설명하는 **H6 자기학습 루프**의 핵심.

---

## 5.11 G-1 Intake Gate 상세 명세 (brownfield 전용)

G-1은 구조가 G1~G5와 충분히 다르기 때문에 별도 섹션으로 격리한다. 본 섹션은 §4.3 (P-1 Discovery Phase), §7.10 (install.sh --mode brownfield), §2.10~2.12 (원칙 10·11·12)의 교차점이다.

### 5.11.1 G-1의 위치와 1회성

```
[install.sh --mode brownfield 실행]
    │
    ▼
[P-1 Discovery phase — §4.3]
    │ /sfs discover 실행
    │ discovery-report.md + evidence/ + inventory/ 생성
    ▼
[G-1 Intake Gate — 본 섹션]
    │ 1. discovery-report-validator 호출 (자동)
    │ 2. .g-1-signature.yaml 검증 (반자동)
    │ 3. 사람 서명 필요 시 user-prompt (수동)
    ├─ SUCCESS ─> P-1 종료 → Plan phase 진입 → G0(brainstorm) or G1(plan)
    ├─ FAIL-FIXABLE ─> discovery-report 재생성 (최대 2회)
    ├─ STALL ─> user-prompt ("왜 승인 보류하는가?")
    └─ ABORT ─> install 중단 + repo 원상복귀
```

**1회성 (per install)**: G-1은 Solon을 해당 repo에 도입할 때 **단 1번** 실행된다. 이후 Sprint가 몇 회 돌든, Initiative가 몇 개 추가되든 G-1은 다시 호출되지 않는다. 이는 `rule/p-1-run-once-per-install` (§4.3.10)과 일관된다.

### 5.11.2 G-1 Evaluator: `discovery-report-validator`

G-1의 core evaluator로 Phase 1에서 신규 구현.

| 항목 | 값 |
|------|----|
| agent_id | `strategy/ceo/discovery-report-validator` |
| model | `claude-sonnet-4-6` (Opus 사용 금지 — 원칙 11 비용 cap) |
| version | `1.0.0` (Phase 1) |
| read_only | `true` (강제) |
| 호출 위치 | `install.sh --mode brownfield` → P-1 종료 직후 |
| 입력 | `discovery-report.md` + `evidence/*.yaml` + `inventory/*.json` |
| 출력 | `gate_report` (schema: `gate-report-v1`) + `.g-1-signature.yaml` 검증 결과 |
| 최대 재시도 | 2 (3회째 FAIL이면 STALL) |

**검증 축 (7개)**:

1. **완성도 (structural completeness)** — `discovery-report.md` 9개 필수 섹션(§7.10.4)이 모두 존재하는가 — binary 0/1
2. **증거 링크 (evidence binding)** — 각 claim이 `evidence/{claim-id}.yaml`에 연결되어 있는가 — 0~100%
3. **수치 가용성 (metric availability)** — 최소 repo 규모(loc, file count, test count)와 tech stack이 수치로 기재 — 0~100%
4. **중복 판정 (duplication detection)** — `docs/`, `README.md`, `CLAUDE.md`와의 중복을 탐지하고 "공존 전략"이 기술되어 있는가 — binary
5. **마이그레이션 경로 (migration path)** — 기존 docs → Solon L2 SSoT로의 이관 계획이 있는가(Phase 2 cookbook 참조 허용) — binary
6. **원칙 9 준수 (evidence-only, no retro brainstorm)** — 보고서 내 "우리는 X를 하지 못했다" 식의 **회고 brainstorm 흔적**이 없는가 — binary (원칙 12)
7. **서명 블록 완결성** — `.g-1-signature.yaml`의 6개 체크박스 + 이름 + 날짜 + 모드 확인이 모두 채워졌는가 — binary

**PASS 조건**: 1·4·5·6·7 모든 binary 축이 ✅ AND 2·3 모두 ≥80.

### 5.11.3 `.g-1-signature.yaml` 스키마 (schema/g-1-signature-v1)

`/sfs discover` 종료 시 생성되는 사람 승인 블록. Solon이 도입되기 직전의 **마지막 human-final-filter**(원칙 10).

```yaml
# ────────────────────────────────────────────────
# .g-1-signature.yaml (schema: g-1-signature-v1)
# 위치: <repo-root>/.solon/.g-1-signature.yaml
# ────────────────────────────────────────────────
schema_version: "g-1-signature-v1"
install_id: "INST-20260420-001"       # install.sh가 생성
repo_root: "/Users/jack/work/my-legacy-app"
mode: "brownfield"
tier_profile: "minimal"                # 또는 standard | collab
l3_backend: "notion"                   # 또는 none | obsidian | ...

# P-1 Discovery 결과 참조
discovery_report_ref:
  path: "docs/discovery-report.md"
  git_ref: "commit:a1b2c3d"            # Solon 도입 직전 HEAD
  generated_at: "2026-04-20T10:30:00Z"
  generated_by: "solon discover v1.0.0 (Sonnet + Haiku)"

# ── 사용자 최종 승인 체크박스 (6개, 모두 ✅ 필수) ──
human_approval:
  - item: "discovery-report.md를 처음부터 끝까지 읽었다"
    checked: true
  - item: "repo 규모 추정치(loc, file count)와 비용 범위(§7.10.8)를 확인했다"
    checked: true
  - item: "기존 docs/와의 공존 전략 또는 마이그레이션 cookbook을 이해했다"
    checked: true
  - item: "원칙 9 (evidence-only)와 원칙 12 (no retro brainstorm)가 의미하는 바를 이해했다"
    checked: true
  - item: "Solon이 기존 repo에 생성할 파일 목록(.solon/, docs/00-meta/, etc.)을 검토했다"
    checked: true
  - item: "이 install은 취소 가능하지만, 생성된 docs/는 manual rollback이 필요함을 이해했다"
    checked: true

# ── 사용자 서명 ──
signature:
  name: "채명정"                       # 필수
  role: "Solo Founder"                 # 자유 입력
  signed_at: "2026-04-20T11:45:00Z"
  method: "cli-interactive"            # cli-interactive | cli-yes-flag | web-ui
  # 주의: --yes 플래그로 자동 서명 시 method = "cli-yes-flag"
  #       이 경우 L1 event에 warning flag 붙음 (§5.11.7)

# ── G-1 evaluator 판정 ──
validator_verdict:
  verdict: "PENDING"                   # PENDING | PASS | FAIL | STALL | ABORT
  # validator가 채우기 전엔 PENDING, 채우고 나면 고정
```

**6개 체크박스의 설계 근거**: 너무 많으면 클릭 피로로 무의미한 서명이 되고(원칙 10 무력화), 너무 적으면 사용자가 실제로 이해했는지 확인 불가. 6개는 (1) 읽었는가 (2) 비용 알았는가 (3) 공존 전략 알았는가 (4) 원칙 이해 (5) 파일 생성 검토 (6) 롤백 절차 인지 — 회피 불가능한 최소 set.

### 5.11.4 Pass/Fail 라우팅

| verdict | 다음 동작 | 산출물 |
|---------|-----------|--------|
| **SUCCESS** | `install.sh` 계속 진행 → `.solon/` 디렉토리 생성 → Plan phase 진입 | `.g-1-signature.yaml` + `gate_report` L2 commit |
| **FAIL-FIXABLE** | discovery-report validator가 지적한 필드 재생성 → G-1 재호출 (최대 2회) | 재생성 diff 로그 |
| **STALL** | `/sfs discover` 호출부터 cache 보존 + user-prompt "승인 보류 사유는?" | stall-note.md |
| **TIMEOUT** | validator 호출 자체가 타임아웃 → retry 1회 → 그래도 타임아웃이면 ABORT | timeout-note.md |
| **ABORT** | install 전체 중단 + `.solon/` 디렉토리 생성 안 함 + 사용자에게 rollback 안내 | abort-report.md |

**중요**: G-1은 **`FAIL-HARD` / `CONFLICT` verdict를 생성하지 않는다**. discovery-report는 단일 문서이므로 cross-division conflict 개념이 없고, "설계 근본 문제"라는 판단은 brownfield intake 단계에서 시기상조(그건 G1 이후 책임).

### 5.11.5 원칙과의 대응

| 원칙 | G-1에서의 구체적 작동 |
|------|------------------|
| **10 human-final-filter** | `.g-1-signature.yaml`의 6개 체크박스 + 이름·날짜 없으면 PASS 불가 |
| **11 brownfield-first-pass** | discovery-report-validator가 "수치 가용성" 축으로 Pass 1(Read-only inventory) 결과가 실제로 반영되었는지 검증 |
| **12 brownfield-no-retro-brainstorm** | validator 축 6(원칙 9 준수)에서 회고 brainstorm 흔적 탐지 → 있으면 FAIL-FIXABLE |
| **2 self-validation-forbidden** | `/sfs discover`를 실행한 agent와 `discovery-report-validator`는 **다른 evaluator pool의 다른 instance** |
| **3 gate-operator** | `strategy/ceo`가 오퍼레이터 — validator를 호출만 하고 판단하지 않음 |

### 5.11.6 G-1과 G0(Brainstorm)의 관계

G-1 PASS 후 곧바로 G1(Plan Gate)로 가지 않고 **G0(Brainstorm Gate, §4 정의)** 을 거칠지 말지는 원칙 12로 제한된다:

| 케이스 | G0 재실행? | 근거 |
|--------|:---:|------|
| brownfield 첫 Initiative (제품 방향 고정됨) | ❌ | 원칙 12 (no retro brainstorm) |
| brownfield 내 **새로운 Sprint에서 신기능**(예: "AI 검색 추가") 기획 | ✅ | §2.12.3, 신기능은 greenfield 성격 |
| brownfield 내 기존 기능 **리팩토링 Sprint** | ❌ | 기존 기능 유지 = no brainstorm needed |
| install 2년 후 **대규모 pivot** 논의 | ✅ | 제품 방향이 바뀌므로 G0 필요 |

→ G-1은 "지금 이 repo를 Solon으로 운영할지"를 결정할 뿐, 기존 제품 방향은 **사전에 결정된 것**으로 간주한다 (원칙 12). 제품 방향 자체를 다시 brainstorm하고 싶다면 **새 Initiative**를 만들어 G0를 명시적으로 호출해야 한다.

### 5.11.7 L1 Event Schema — `l1.gate.g-1.complete`

G-1이 verdict를 확정할 때 L1(S3 raw log)에 기록되는 event.

> **주의**: 아래 JSON은 `l1-log-event-v1` base schema 위에 얹히는 **G-1 고유 필드**만 표기한다. 실제 L1 기록 시 base 필수 필드(`event_id`, `timestamp`, `session_id`, `agent_id`, `agent_role`, `model`, `tool_calls`, `input_tokens`, `output_tokens`, `latency_ms`, `trace_id`, `classification: "gate-execution"`, `gate_id: "G-1"`)가 함께 포함된다. base 스키마는 `appendix/schemas/l1-log-event.schema.yaml` 참조.

```json
{
  "event_type": "l1.gate.g-1.complete",
  "timestamp": "2026-04-20T11:45:30Z",
  "install_id": "INST-20260420-001",
  "repo_root_hash": "sha256:7f8a9b...",
  "mode": "brownfield",
  "tier_profile": "minimal",
  "l3_backend": "notion",
  "verdict": "SUCCESS",
  "validator_score": 92,
  "validator_breakdown": {
    "structural_completeness": 1,
    "evidence_binding": 88,
    "metric_availability": 95,
    "duplication_detection": 1,
    "migration_path": 1,
    "principle_9_compliance": 1,
    "signature_completeness": 1
  },
  "signature": {
    "signed_by": "채명정",
    "method": "cli-interactive",
    "warnings": []
  },
  "cost_usd": 0.18,
  "duration_ms": 182400,
  "human_review_duration_sec": 4200,
  "next_phase": "plan"
}
```

`signature.method == "cli-yes-flag"`이면 `warnings: ["auto_signed"]`가 추가 — L3 대시보드에서 auto-sign 남용을 추적하기 위함.

### 5.11.8 G-1 비용 예산 (Phase 1)

| 항목 | 비용 | 비고 |
|------|------|------|
| `discovery-report-validator` 2~3회 | $0.10 ~ $0.25 | Sonnet 4.6 |
| 기존 `/sfs discover` 비용 (§7.10.8) | Small <$2 / Medium <$15 / Large <$60 | 이는 G-1 이전 P-1 비용 |
| human review time | 10분 ~ 4시간 | 인건비 제외 시 $0 |
| **G-1 자체 추가 비용** | **< $0.30** | validator만 해당 |

→ G-1은 P-1 전체 비용의 **1% 미만**으로 설계되었다. 주 비용은 P-1 Discovery 단계이며, G-1은 그 결과를 검증하고 서명을 수집하는 **저비용 게이트**.

### 5.11.9 G5와의 비교 (왜 G-1은 학습 루프에 들어가지 않는가)

| 측면 | G-1 | G5 |
|------|-----|----|
| 빈도 | install 당 1회 | Sprint 당 1회 |
| 대상 | repo 전체 (static) | Sprint N개 PDCA의 gate_report 집합 (dynamic) |
| 학습 루프 반영 | 없음 — 한 번 통과하면 재호출 불가 | memory/learnings-v1.md로 다음 Sprint 입력 |
| Opus 사용 | 금지 (원칙 11 비용 cap) | 필수 (sprint-retro-analyzer) |
| 결과의 휘발성 | `.g-1-signature.yaml`로 영구 보존 | learnings-v1.md에 누적 |

→ G-1은 **도입 게이트**, G5는 **학습 게이트**. 둘 다 "정성적" 요소가 있으나 기능적으로 완전히 다르다.

### 5.11.10 구현 순서 (Phase 1 체크리스트)

Phase 1에서 G-1을 지원하려면 다음 순서로 구현:

1. [ ] `appendix/schemas/g-1-signature.schema.yaml` 작성
2. [ ] `appendix/templates/discovery-report.template.md` 작성 (§7.10.4에서 구체화)
3. [ ] `strategy/ceo/discovery-report-validator` agent 정의 (Sonnet 4.6)
4. [ ] `/sfs discover` skill 구현 (§7.10.4, appendix/commands/)
5. [ ] `install.sh --mode brownfield` 분기 구현 (§7.10.3)
6. [ ] L1 event `l1.gate.g-1.complete` emitter 구현
7. [ ] L3 대시보드 "G-1 pass rate" 패널 (선택, tier=collab 이상)

→ 1~6은 Phase 1 필수, 7은 Phase 2로 이연 가능 (§7.6).

---

*(끝)*
