---
command_id: "sfs-escalate"
command_name: "/sfs escalate"
version: "1.0.0"
phase: "any"                       # 어느 phase 에서나 발동 가능
mode: "common"
operator: "division-lead"          # 각 본부장이 주 호출자 (β-3 심화 시 C-Level 승격)
escalation_level_operators:
  beta-1: "division-lead"          # 본부 내 재시도
  beta-2: "strategy/pm/lead"       # PM 본부장 조정
  beta-3: "strategy/ceo"           # CEO 판단
triggers:
  - "escalate"
  - "에스컬레이트"
  - "막힘"
  - "blocked"
  - "stall"
  - "can't proceed"
  - "CONFLICT"
  - "충돌"
  - "재시도 실패"
requires_gate_before: []            # Escalate 는 gate 선행 조건 없음
produces:
  - "docs/05-escalation/PDCA-{pdca-id}.escalate.md"
  - "docs/05-escalation/PDCA-{pdca-id}.5-option.yaml"
  - "docs/05-escalation/PDCA-{pdca-id}.resolution.yaml"    # 해결 시
calls_evaluators:
  - "conflict-classifier"           # Sonnet, Case α/β/γ 분류
  - "option-generator"              # Sonnet, 5-Option 생성
  - "cpo-5axis"                     # Opus, β-3 에서만 (전략 영향 판단)
model_allocation:
  beta-1_default: "claude-sonnet-4-6"
  beta-2_default: "claude-sonnet-4-6"
  beta-3_default: "claude-opus-4-6"   # β-3 은 CEO 판단, Opus 필수
  helper: "claude-haiku-4-5-20251001"
  opus_allowed: true                  # β-3 에서만 실제 사용
cost_budget_usd:
  beta-1: 0.50
  beta-2: 1.00
  beta-3: 2.50
timeout_ms: 900000                    # 15분 (β-3 는 사람 대기 시 extend)
tool_restrictions:
  allowed: ["Read", "Write", "Edit", "Glob", "Grep", "Task"]
  forbidden: ["Bash(destructive)"]
audit_fields: ["called_by", "called_at", "pdca_id", "sprint_id", "escalation_level", "case_classification", "resolution_option_id"]
references:
  - "06-escalate-plan.md §6.3 Case α Gap 폭락"
  - "06-escalate-plan.md §6.4 Case β 재시도 실패"
  - "06-escalate-plan.md §6.5 5-Option Protocol"
  - "06-escalate-plan.md §6.6 Case γ CONFLICT"
  - "02-design-principles.md §2.2 자기검증 금지 + §2.10 사람 최종 필터 (이중 방어선)"
---

# /sfs escalate

## 의도 (Intent)

PDCA 또는 Sprint 진행 중 **정상 절차로 해결되지 않는 상황** 을 명시적으로 선언하고, **3단계 escalation level (β-1 → β-2 → β-3)** 에 따라 적절한 의사결정자에게 권한을 넘긴다.

§6 Escalate Plan 의 3가지 Case:
- **Case α (Gap 폭락)**: `/sfs check` 에서 gap_score < 70. G4 FAIL-HARD. → 본부 작업 일시 중단 + 복구 계획.
- **Case β (재시도 실패)**: Gate FAIL 후 `/sfs {phase} --resume` 2회째도 실패. 같은 축에서 무한 반복 위험.
- **Case γ (CONFLICT)**: 두 본부 산출물이 상호 모순 (예: taxonomy 용어 vs dev 코드 명명). 어느 한쪽만 수정해서는 해결 불가.

§2 원칙 2 (자기검증 금지) + 원칙 10 (사람 최종 필터) 의 "이중 방어선" 실질 창구:
- Agent 는 "조용히 돌아가는 우회"를 만들지 않는다 — gate FAIL 시 silent-degrade 금지.
- 대신 `/sfs escalate` 를 호출해 **사람 또는 상위 오퍼레이터에게 책임을 이전**.
- 즉, §6 Escalate Plan 은 fail-hard 규칙의 **표준 출구**.

Escalation Level 판정:
| Level | 조건 | 오퍼레이터 | Output |
|-------|------|-----------|--------|
| **β-1** | 최초 escalate, 본부 내 해결 가능성 존재 | 본부장 | 5-Option 중 Option A/B (본부 내 액션) 채택 |
| **β-2** | β-1 에서 option 실행했으나 24h 내 해결 안 됨 | PM 본부장 | cross-division 조정, Option C/D |
| **β-3** | β-2 에서도 해결 안 됨, 전략적 판단 필요 | CEO | Option E (전략 피벗 / PDCA 중단) |

## 입력 (Input)

### 필수
- `--feature <id>`: PDCA 식별자 (또는 `--sprint <id>` for Sprint 레벨)
- `--case {alpha|beta|gamma}`: Case 분류 (자동 감지 가능, 하지만 명시 권장)
- `--reason <text>`: 1~2문장 요약 (왜 escalate 하는지)

### 선택
- `--level {beta-1|beta-2|beta-3}`: 시작 레벨 (기본 β-1). 재호출 시 자동 상승.
- `--division <name>`: 특정 본부 범위 (없으면 cross-division 으로 간주)
- `--resolve <option-id>`: 이전에 생성된 5-Option 중 하나를 채택해 해소
- `--abort-pdca`: Option E 채택 (PDCA 중단)

## 절차 (Procedure)

1. **Escalation Context 수집** (Haiku, <5s)
   - `.solon/escalation-state.yaml` 에 동일 PDCA + 동일 Case 로 이전 호출 존재 여부 확인
   - 존재 시 자동 level up (β-1 → β-2 → β-3)
   - Sprint phase 감지, 현재까지의 gate 이력, 관련 산출물 path 수집
2. **Case 자동 분류** (conflict-classifier, Sonnet — `--case` 없는 경우)
   - 입력: 최근 gate yaml + work-log + 사용자 `--reason`
   - 출력: α / β / γ 중 하나 + confidence
   - confidence < 0.7 시 사용자에게 명시 확인 요구
3. **5-Option Protocol 실행** (option-generator, Sonnet — `--resolve` 없는 경우)
   - §6.5 의 표준 5 옵션 생성:
     - **A. Retry with same spec**: 동일 조건 재시도 (β-1 에서만 의미)
     - **B. Relax AC / Defer AC**: 일부 AC 연기 (G4 기준 완화)
     - **C. Re-design division output**: cross-division handoff 재설계
     - **D. Split PDCA**: 현재 PDCA 를 2개로 분할
     - **E. Abort PDCA**: 중단 + 다음 Sprint 재배치 또는 백로그 park
   - 각 option 에 대해: 예상 비용, 예상 소요, 위험, 재발 확률
4. **CPO 5-Axis 영향 평가** (cpo-5axis, Opus — β-3 에서만)
   - 각 option 이 Initiative 전체의 User-Outcome / Value-Fit / Soundness / Future-Proof / Integrity 에 미치는 영향
   - Option 선택에 전략적 근거 제공
5. **사용자/오퍼레이터 결정** (blocking, human-final-filter)
   - 5 옵션을 표 형태로 제시 + 권장 옵션 marking
   - 사용자가 option id 선택 (또는 `--resolve`로 사전 지정)
   - 선택 없이 24h 경과 시 `E_ESCALATION_TIMEOUT` (STALL)
6. **Resolution 실행**
   - 선택된 option 에 따라 적절한 sfs command 자동 호출 또는 안내
     - A → 해당 phase command `--resume`
     - B → `/sfs plan --feature ... --amend-ac`
     - C → `/sfs design --feature ... --division ... --redo`
     - D → `/sfs plan --feature ... --split-into <id1> <id2>`
     - E → `--abort-pdca` flag 경로, learnings 에 abort 사유 기록
7. **Resolution 기록**
   - `docs/05-escalation/PDCA-{id}.resolution.yaml` 에 option_id, 선택자, 후속 액션 ID 기록
   - escalation level, case, 경과 시간, LLM 비용 sum 도 기록
8. **L1 이벤트 발행**
   - `l1.escalate.triggered` (level, case, pdca_id)
   - `l1.escalate.resolved` (option_id, duration_h)

## 산출물 (Output)

- `docs/05-escalation/PDCA-{pdca-id}.escalate.md` — Escalate 서술 본문
  - 필수 섹션: Trigger / Case Classification / Timeline / 5-Option / Decision
- `docs/05-escalation/PDCA-{pdca-id}.5-option.yaml` — 5 옵션 구조화 (schema/escalation-option-v1)
- `docs/05-escalation/PDCA-{pdca-id}.resolution.yaml` — 최종 채택 option 과 후속 action item

## 오류 처리 (Error Handling)

| Error | 원인 | 복구 |
|-------|------|------|
| `E_NO_PRIOR_FAILURE` | escalate 조건 아님 (정상 gate) | escalate 불가, 정상 command 사용 |
| `E_CASE_AMBIGUOUS` | classifier confidence < 0.7, `--case` 미지정 | `--case alpha/beta/gamma` 명시 재호출 |
| `E_ESCALATION_TIMEOUT` | 24h 내 option 미선택 | 자동 level-up (β-1 → β-2, β-2 → β-3) |
| `E_LEVEL_OUT_OF_RANGE` | β-3 에서도 해결 안 됨 | Option E(abort) 강제 권고 또는 CEO pivot 회의 |
| `E_RESOLVE_OPTION_INVALID` | `--resolve <id>` 가 5-Option yaml 에 없음 | 5-option.yaml 재참조 후 유효 id |
| `E_BUDGET_EXCEEDED` | β-3 cost cap $2.50 초과 | Opus 호출 1회로 제한, Sonnet fallback |
| `E_CONCURRENT_ESCALATE` | 동일 PDCA 에 open escalate 2개 이상 | 기존 escalate 먼저 resolve |

## 예시 (Examples)

### 예시 1: Case α Gap 폭락 (β-1)

```bash
$ /sfs escalate --feature new-pricing --case alpha --reason "G4 gap_score=63, AC-2/5 미구현"
[escalate] Level β-1, Case α 확정
[escalate] 5-Option 생성 (Sonnet)...
   A. Retry: gap 3~5점 상승 추정, 리스크 중
   B. Relax AC-2 (defer search-highlight): 1주 내 해결, 사용자 impact 중
   C. Re-design work split: dev ↔ qa 협업 재설계
   D. Split PDCA: new-pricing-core / new-pricing-search
   E. Abort: 다음 Sprint 에 재시도
[escalate] 추천: D (Split PDCA) — 두 AC 독립성 높음
> Option 선택 [a/b/c/d/e]: d
[escalate] Option D 채택. /sfs plan --feature new-pricing --split-into new-pricing-core new-pricing-search 자동 호출 준비
[escalate] resolution.yaml 기록 ✓
```

### 예시 2: β-2 자동 승격

```bash
$ /sfs escalate --feature notifications --case beta
[escalate] 이전 β-1 호출 감지 (25h 전) → β-2 자동 승격
[escalate] 오퍼레이터: PM 본부장
[escalate] cross-division 조정 관점 5-Option 재생성...
   A. [skip, β-1 에서 이미 시도]
   B. Relax AC-3 (backoff policy 기본값): 적용 시 재호출 1회
   ...
> Option 선택: b
[escalate] PM 본부장 → dev 본부장 에게 후속 handoff 지시 기록.
```

### 예시 3: β-3 CEO pivot 판단 (Case γ)

```bash
$ /sfs escalate --feature taxonomy-overhaul --case gamma --reason "taxonomy 용어 vs 기존 dev 명명 완전 충돌, 양쪽 모두 수정 불가"
[escalate] Level β-3 (이전 β-2 도 실패)
[escalate] CPO 5-Axis 영향 평가 (Opus)...
   Option E (Abort): Soundness +2, Future-Proof +1, User-Outcome -1 — 전략 손실 감수 가능
   Option D (Split): 4개 하위 PDCA 로 분할, 6주 + $500 추가 예상
[escalate] 추천: E (Abort) + 다음 Initiative 에서 taxonomy 재설계
> CEO 결정 [d/e]: e
[escalate] Option E 채택. PDCA taxonomy-overhaul abort 처리.
[escalate] learnings 에 abort 사유 기록 ✓
[escalate] 다음 Initiative G0 에 '용어 체계 재검토' seed 자동 추가.
```

### 예시 4: `--resolve` 로 사전 결정 반영

```bash
$ /sfs escalate --feature search-v2 --case beta --resolve B
[escalate] Level β-1, Case β
[escalate] --resolve B 지정됨, 5-Option 생성 후 B 자동 채택
[escalate] Option B (Relax AC-7): AC-7 은 다음 PDCA 로 이월
[escalate] /sfs plan --feature search-v2 --amend-ac 자동 호출 안내
```

## 관련 docs

- `06-escalate-plan.md §6.3` — Case α Gap 폭락 상세
- `06-escalate-plan.md §6.4` — Case β 재시도 실패
- `06-escalate-plan.md §6.5` — 5-Option Protocol 전체 spec
- `06-escalate-plan.md §6.6` — Case γ CONFLICT (cross-division)
- `02-design-principles.md §2.2` — 자기검증 금지 (silent self-pass 차단)
- `02-design-principles.md §2.10` — 사람 최종 필터 (silent auto-release 차단)
- `appendix/commands/check.md` — Case α 주요 발생처 (G4)
- `appendix/commands/retro.md` — Sprint 레벨 escalate 집계
