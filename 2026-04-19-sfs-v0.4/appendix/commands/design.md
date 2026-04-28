---
command_id: "sfs-design"
command_name: "/sfs design"
version: "1.0.0"
phase: "design"
mode: "common"
operator: "division-lead"   # strategy-pm / taxonomy / design / dev / qa / infra 중 해당 본부장
triggers:
  - "design"
  - "설계"
  - "architecture"
  - "아키텍처"
  - "spec"
  - "스펙 작성"
requires_gate_before:
  - "G1"
produces:
  - "docs/02-design/PDCA-{id}.{division}.design.md"
  - "docs/02-design/PDCA-{id}.gate-g2.yaml"
calls_evaluators:
  - "user-flow-validator"                # design 본부
  - "cost-estimator"                      # infra 본부
  - "taxonomy-consistency-checker"        # taxonomy 본부
  - "taxonomy-draft-evaluator"            # taxonomy 본부 (신규 용어 시)
  - "design-critique-rewrite"             # design 본부 (cowork-inspired)
  - "accessibility-review-rewrite"        # design 본부
  - "design-handoff-rewrite"              # design 본부
  - "design-validator"                    # bkit 재활용
model_allocation:
  worker_default: "claude-sonnet-4-6"     # 본부 worker (설계 초안 작성)
  lead_default: "claude-sonnet-4-6"       # 본부장 (오퍼레이터)
  lead_escalation: "claude-opus-4-6"      # CONFLICT / 본부장 간 충돌 시 Opus
  evaluator: "claude-opus-4-6"            # 외부 Evaluator는 모두 Opus
  opus_allowed: true                       # evaluator / lead escalation 한정
cost_budget_usd: 1.20
timeout_ms: 600000
tool_restrictions:
  allowed: ["Read", "Write", "Edit", "Glob", "Grep", "Task"]
  forbidden: []
audit_fields: ["called_by", "called_at", "pdca_id", "sprint_id", "division"]
references:
  - "04-pdca-redef.md §4.4.2 Design phase"
  - "05-gate-framework.md §5.4 G2 Design Gate"
  - "03-c-level-matrix.md §3.3 C-Level × Division Matrix"
  - "02-design-principles.md §2.5 외부자 검증"
  - "10-phase1-implementation.md §10.2.2 8 Evaluator 상세"
---

# /sfs design

## 의도 (Intent)

PDCA 의 **Design 단계** 를 실행한다. G1에서 확정된 PRD/AC를 입력으로 받아, **해당 본부** 의 설계 산출물 (architecture spec / user flow / infra plan / taxonomy update / qa strategy) 을 생성하고, G2 Design Gate를 통과시킨다.

본 command는 **본부별로 여러 번 호출될 수 있다** — 한 PDCA에 대해 design 본부가 UX spec, infra 본부가 cost estimate, taxonomy 본부가 용어 업데이트를 각자 `/sfs design` 으로 만든다. 본부장(Lead)은 각자의 본부 worker에게 작성을 위임하며 (§2 원칙 3 본부장=Gate Operator), **자기 본부 evaluator 는 호출 불가** — 외부 evaluator를 반드시 호출 (§2 원칙 2 자기검증 금지, 3-Tier Separation Rule).

## 입력 (Input)

### 필수
- `--feature <id>`: PDCA 식별자 (plan 단계와 동일)
- `--division <name>`: 설계 작성 본부 (strategy-pm / taxonomy / design / dev / qa / infra 중 하나)

### 선택
- `--based-on <path>`: 참조할 선행 design 산출물 (다른 본부의 design 완료본)
- `--skip-evaluator <name>`: 특정 Evaluator 건너뛰기 (Phase 1 mock 시나리오 전용, production 금지)
- `--cpo-5axis`: CPO 5-Axis 평가 강제 호출 (design 본부 권장, 다른 본부 optional)

## 절차 (Procedure)

1. **G1 PASS 확인** (Haiku, <3s)
   - `docs/01-plan/PDCA-{id}.gate-g1.yaml` 에서 `result: pass` 확인
   - AC 메타데이터 `status: locked` 확인 (prd-lock 완료)
2. **본부 worker 위임** (Sonnet)
   - 본부장(Lead)이 설계 작성 지시 (본부 prompt + Plan 산출물 + 참조 design)
   - 본부별 템플릿: `appendix/templates/design.md` + 본부 특화 섹션
3. **Division-specific Evaluator 호출** (Opus, 외부)
   | 본부 | 필수 Evaluator | Optional |
   |------|--------------|---------|
   | design | user-flow-validator, design-critique-rewrite, accessibility-review-rewrite, design-handoff-rewrite | design-validator (bkit) |
   | infra | cost-estimator | infra-architect (bkit) |
   | taxonomy | taxonomy-consistency-checker, taxonomy-draft-evaluator (신규 용어 시) | — |
   | dev | (G2에서는 비관여, G4에서 gap-detector 등 사용) | — |
   | qa | (G2에서 test strategy spec만, evaluator 없음 — G4에서 qa-monitor) | — |
   | strategy-pm | (G2에서는 전략 검토만, evaluator 없음) | — |
4. **5-Axis CPO 평가** (Opus, design 본부 권장)
   - User-Outcome / Value-Fit / Soundness / Future-Proof / Integrity
   - Design 본부는 G2에서 CPO 필수 호출 (user-facing 산출물 검증)
5. **G2 Design Gate 실행** (via `/sfs gate g2 <feature>`)
   - 모든 Evaluator verdict 집계
   - PASS / FAIL-FIXABLE / FAIL-HARD / STALL / CONFLICT / TIMEOUT 분기
   - CONFLICT (본부장 간 불일치 등) 는 5-Option Protocol (§6.5)
6. **L1 이벤트 발행**
   - `l1.design.complete` (division, result, evaluators_called, duration, token_usage)

## 산출물 (Output)

- `docs/02-design/PDCA-{id}.{division}.design.md` — 본부별 설계 산출물
  - design 본부: UX spec + user-flow + accessibility notes
  - infra 본부: infrastructure diagram + cost estimate
  - taxonomy 본부: 본부 간 용어 매핑 + 신규 용어 초안
  - dev 본부: architecture spec + data model (optional)
  - qa 본부: test strategy + coverage target
  - strategy-pm 본부: priority matrix + stakeholder plan
- `docs/02-design/PDCA-{id}.gate-g2.yaml` — G2 gate report (본부별 section)

## 오류 처리 (Error Handling)

| Error | 원인 | 복구 |
|-------|------|------|
| `E_G1_NOT_PASSED` | G1 Plan Gate 미통과 | `/sfs plan --feature ...` 선행 안내 |
| `E_SELF_VALIDATION_ATTEMPT` | 본부장이 자기 본부 evaluator 호출 시도 | FAIL-HARD, §2 원칙 2 위반 로그 |
| `E_EVALUATOR_UNAVAILABLE` | 호출된 evaluator 미설치 또는 crash | 1회 retry, 실패 시 TIMEOUT |
| `E_AC_CHANGE_DETECTED` | AC가 Plan 이후 변경됨 (prd-lock 위반) | Case-α Escalate 강제 (§6.3.3) |
| `E_CROSS_DIVISION_CONFLICT` | 본부 간 설계 불일치 (e.g., design vs infra) | 5-Option Protocol (§6.5) 자동 트리거 |

## 예시 (Examples)

### 예시 1: Design 본부 UX spec 작성

```bash
$ /sfs design --feature new-pricing --division design --cpo-5axis
[design] G1 PASS 확인 ✓
[design] design-lead → worker 위임 (Sonnet)
[design] UX spec 작성 ✓
[design] user-flow-validator 호출 (Opus)... PASS
[design] design-critique-rewrite 호출... PASS (4.1/5)
[design] accessibility-review-rewrite 호출... PASS (WCAG AA)
[design] design-handoff-rewrite 호출... PASS (edge-case 섹션 존재)
[design] CPO 5-Axis 평가 (Opus)... 4.3/5
[design] G2 PASS
```

### 예시 2: Infra 본부 cost estimate

```bash
$ /sfs design --feature new-pricing --division infra \
              --based-on docs/02-design/PDCA-new-pricing.design.design.md
[design] G1 PASS 확인 ✓
[design] infra-lead → worker 위임 (Sonnet)
[design] 인프라 도식 + cost estimate 작성 ✓
[design] cost-estimator 호출 (Opus)... PASS ($47/월 예상)
[design] G2 (infra 섹션) PASS
```

### 예시 3: Taxonomy 용어 충돌로 CONFLICT

```bash
$ /sfs design --feature new-pricing --division taxonomy
...
[design] taxonomy-consistency-checker 결과: CONFLICT
[design] Strategy-PM 본부 "플랜" vs Design 본부 "프라이싱 티어" 용어 불일치
[design] 5-Option Protocol 진입:
   A) PM 용어 채택  B) Design 용어 채택  C) 제3 용어 신규 정의
   D) 본부 간 alias  E) Escalate to CEO
[design] 사용자 입력 대기...
```

## 관련 docs

- `04-pdca-redef.md §4.4.2` — Design phase 정의
- `05-gate-framework.md §5.4` — G2 Design Gate 상세
- `03-c-level-matrix.md §3.3` — 본부별 Evaluator 책임 매트릭스
- `10-phase1-implementation.md §10.2.2` — 8 Evaluator 상세 스펙
- `appendix/commands/do.md` — 다음 단계
