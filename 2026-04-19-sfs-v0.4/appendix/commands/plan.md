---
command_id: "sfs-plan"
command_name: "/sfs plan"
version: "1.0.0"
phase: "plan"
mode: "common"
operator: "strategy-pm/lead"
triggers:
  - "plan"
  - "계획"
  - "PRD"
  - "requirements"
  - "AC 작성"
  - "acceptance criteria"
requires_gate_before:
  - "G-1"    # brownfield 모드에서만 필요
  - "G0"     # greenfield 모드에서 Initiative 최초 PDCA에만 필요
produces:
  - "docs/01-plan/PDCA-{id}.plan.md"
  - "docs/01-plan/PDCA-{id}.ac.yaml"
calls_evaluators:
  - "plan-validator"
  - "prd-lock"
model_allocation:
  default: "claude-sonnet-4-6"       # PRD 초안 작성은 Sonnet
  evaluator: "claude-opus-4-6"       # plan-validator만 Opus
  opus_allowed: true                  # G1에서 5-Axis CPO 평가에 Opus 허용
cost_budget_usd: 0.80
timeout_ms: 300000
tool_restrictions:
  allowed: ["Read", "Write", "Edit", "Glob", "Grep", "Task"]
  forbidden: []
audit_fields: ["called_by", "called_at", "pdca_id", "sprint_id", "initiative_id"]
references:
  - "04-pdca-redef.md §4.4.1 Plan phase"
  - "05-gate-framework.md §5.3 G1 Plan Gate"
  - "05-gate-framework.md §5.2 Gate × Division Matrix"
  - "06-escalate-plan.md §6.3.3 PRD Lock"
  - "02-design-principles.md §2.5 외부자 검증"
---

# /sfs plan

## 의도 (Intent)

PDCA 사이클의 **Plan 단계** 를 실행한다. 새 PDCA 단위 기능을 정의하고 PRD(Product Requirements Document)와 AC(Acceptance Criteria)를 확정한 뒤, G1 Plan Gate 를 호출해 외부자 검증을 통과시킨다.

본 command는 **strategy-pm/lead** 본부장이 오퍼레이터로 호출한다. 단, PRD 초안 작성은 본부장이 Sonnet worker에게 위임하며 (§2 원칙 3 본부장=Gate Operator), plan-validator Evaluator는 Opus로 외부에서 호출된다 (§2 원칙 2 자기검증 금지).

Greenfield에서는 Initiative의 첫 PDCA 작성 전에 G0 Brainstorm PASS가 선행되어야 한다. Brownfield에서는 G-1 Intake Gate PASS가 선행되어야 한다 (둘 다 install 당 1회).

## 입력 (Input)

### 필수
- `--feature <id>`: PDCA 단위 기능 식별자 (snake-case 또는 PDCA ID)
- `--initiative <id>`: 소속 Initiative ID
- `--sprint <id>`: 소속 Sprint ID (현재 active sprint)

### 선택
- `--from-brainstorm <path>`: G0 산출물 (brainstorm report) 참조 경로 (greenfield 권장)
- `--from-discovery <path>`: P-1 산출물 (discovery-report.md) 참조 경로 (brownfield 권장)
- `--template <path>`: PRD 템플릿 override (기본: `appendix/templates/plan.md`)
- `--skip-validator`: plan-validator 호출 생략 (비권장, Tier 1 자기검증만으로는 §2.5 위반)

## 절차 (Procedure)

1. **전제 조건 확인** (Haiku, <5s)
   - brownfield: `.g-1-signature.yaml` 에 `signature.signed_at` 존재 확인
   - greenfield: 해당 Initiative 디렉토리에 `brainstorm-report.md` + G0 PASS 기록 확인
   - active sprint 존재 확인
2. **PRD 초안 작성** (Sonnet worker 위임, strategy-pm-lead → worker)
   - 템플릿: `appendix/templates/plan.md`
   - 필수 섹션: Problem, Goal, Non-Goals, Personas, Stories, AC (측정 가능), Edge Cases, Success Metrics
   - brownfield 시: discovery-report.md 의 Domain Evidence / Existing Docs 섹션을 입력으로 받음 (단, 재brainstorm 금지 — 원칙 12)
3. **AC 메타데이터 작성** (YAML frontmatter 별도 파일)
   - `docs/01-plan/PDCA-{id}.ac.yaml` 에 AC 각 항목에 id, measurable (bool), metric (string), status (draft|locked) 기록
4. **plan-validator 호출** (Opus, 외부 Evaluator)
   - 입력: plan.md + ac.yaml
   - 출력: gate-report-v1 (plan-validator verdict + 5-Axis preview)
   - §10.8 seed pattern 001 (AC 모호성), 003 (design-dev handoff gap) 자동 체크
5. **G1 Plan Gate 실행** (via `/sfs gate g1 <feature>`)
   - PASS: 다음 단계 (`/sfs design`) 안내
   - FAIL-FIXABLE: 사용자에게 수정 부분 highlight 후 재시도
   - FAIL-HARD: Escalate-Plan Case-α 트리거 (§6.3)
   - CONFLICT: 5-Option Protocol (§6.5)
6. **prd-lock 호출** (G1 PASS 후)
   - AC 메타데이터 `status: locked` 변경
   - 이후 Design/Do 단계에서 AC 변경 불가 (변경 시 Case-α 필수)
7. **L1 이벤트 발행**
   - `l1.plan.complete` (result, duration, token_usage)

## 산출물 (Output)

- `docs/01-plan/PDCA-{id}.plan.md` — PRD 본문
- `docs/01-plan/PDCA-{id}.ac.yaml` — AC 메타데이터 (id, measurable, metric, status)
- `docs/01-plan/PDCA-{id}.gate-g1.yaml` — G1 gate report (plan-validator verdict + 5-Axis)

## 오류 처리 (Error Handling)

| Error | 원인 | 복구 |
|-------|------|------|
| `E_PREREQUISITE_GATE_MISSING` | brownfield인데 G-1 미통과 / greenfield인데 G0 미통과 | 선행 Gate 호출 안내 |
| `E_PDCA_ID_COLLISION` | 동일 feature id로 PDCA 이미 존재 | `--force` 또는 다른 id 요구 |
| `E_AC_NOT_MEASURABLE` | AC 중 measurable=false 항목 존재 | plan-validator가 FAIL-FIXABLE 반환, 수정 필요 |
| `E_VALIDATOR_TIMEOUT` | plan-validator 2분 초과 | 1회 retry, 연속 실패 시 TIMEOUT → §6.5 |
| `E_PRD_LOCK_CONFLICT` | 이미 locked된 PRD 재수정 시도 | Case-α Escalate 강제 (§6.3.3) |

## 예시 (Examples)

### 예시 1: 신규 기능 Plan (greenfield, G0 PASS 후)

```bash
$ /sfs plan --feature new-pricing --initiative pricing-v2 --sprint S-2026-W17
[plan] 전제조건 확인 ✓ (G0 pricing-v2/brainstorm-report.md)
[plan] PRD 초안 작성 중 (Sonnet worker)...
[plan] AC 5개 추출 ✓ (모두 measurable=true)
[plan] plan-validator 호출 (Opus)...
[plan] G1 PASS (5-Axis: 4.2/5, Soundness 4.5)
[plan] prd-lock 완료 (status=locked)
[plan] 다음: /sfs design --feature new-pricing
```

### 예시 2: Brownfield 신기능 Plan

```bash
$ /sfs plan --feature add-search --initiative search-v1 --sprint S-2026-W18 \
           --from-discovery docs/00-governance/discovery-report.md
[plan] 전제조건 확인 ✓ (.g-1-signature.yaml signed)
[plan] discovery-report에서 domain evidence 로드 ✓
[plan] PRD 초안 작성 중 (재brainstorm 금지, 원칙 12)...
[plan] G1 PASS
```

### 예시 3: AC 모호성으로 FAIL-FIXABLE

```bash
$ /sfs plan --feature notifications --initiative noti-v1 --sprint S-2026-W17
...
[plan] plan-validator 결과: FAIL-FIXABLE
[plan] AC-3 "사용자가 만족하도록 알림 표시" — measurable=false
[plan] 제안: "알림 수신 후 3초 내 dismiss 가능 (p95)"
[plan] 수정 후 재시도하려면 docs/01-plan/PDCA-notifications.ac.yaml 편집
```

## 관련 docs

- `04-pdca-redef.md §4.4.1` — Plan phase 정의
- `05-gate-framework.md §5.3` — G1 Plan Gate 상세
- `06-escalate-plan.md §6.3.3` — PRD Lock 규칙
- `appendix/templates/plan.md` — PRD 템플릿
- `appendix/commands/design.md` — 다음 단계
