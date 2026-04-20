# Alternative Suggestion Engine

---
doc_id: sfs-v0.4-appendix-engine-alternative-suggestion
title: "Alternative Suggestion Engine Specification"
version: 1.0.0
status: draft
last_updated: 2026-04-20
audience: [implementers, dialog-engine-author, product-reviewer]

depends_on:
  - principle/progressive-activation (s02 §2.13)
  - dialog/division-activation (appendix/dialogs/division-activation.dialog.yaml)
  - schema/dialog-state (appendix/schemas/dialog-state.schema.yaml)
  - schema/divisions (appendix/schemas/divisions.schema.yaml, v1.1+)

defines:
  - engine/alternative-suggestion
  - rule/never-hard-block
  - rule/three-tier-alternatives
  - rule/three-level-intensity

references:
  - principle 2 (자기검증 금지)
  - principle 10 (human-final-filter)
  - principle 13 (progressive-activation + non-prescriptive)
---

## 0. Purpose

사용자가 `/sfs division activate <id>` 와 같은 요청을 했을 때,
**차단하지 않고 상황을 안내** 하기 위한 option 생성 엔진의 사양.

핵심 책임 3 가지:

1. **3-tier alternatives** — 모든 선택 지점에서 반드시 3 개의 실행 가능 옵션 + 취소 옵션 제시
2. **3-level intensity** — 옵션마다 👍(권장) / ⚪(중립) / ⚠(비권장) 중 하나 부여
3. **never-hard-block** — 어떤 조합이든 사용자가 최종 선택 가능 (⚠ 포함)

---

## 1. Core Invariants

| ID | 이름 | 설명 |
| --- | --- | --- |
| **ALT-INV-1** | three-tier-required | 모든 option card 는 정확히 3 개의 실행 옵션 + 1 개의 cancel 옵션 |
| **ALT-INV-2** | exactly-one-recommended | 3 개 중 👍 는 정확히 1 개 (없음/복수 금지) |
| **ALT-INV-3** | never-hard-block | ⚠ 옵션도 선택 가능해야 함 (UI 비활성화 금지) |
| **ALT-INV-4** | reasoning-required | 모든 옵션은 1 줄 이내 reasoning 제공 (opaqueness 금지) |
| **ALT-INV-5** | warn-provides-alternatives | ⚠ 가 제시되면 `alternatives_when_warned` 배열 필수 (최소 2 개) |
| **ALT-INV-6** | intensity-not-ranking | 👍 ≠ "더 나음", 단지 "현 상황에 더 적합한 기본값". user override 는 정상 동작 |

---

## 2. 3-Tier Alternatives Rule

### 2.1 왜 3 개인가

- **2 개**: A/B 이분법 → 선택 피로 낮지만 뉘앙스 손실 (예: full vs temporal 만 있으면 scoped 누락)
- **4 개 이상**: 인지 부하 급증 → paradox of choice
- **3 개**: 의사결정 이론상 optimal trade-off + 본부 scope 의 자연스러운 3 분법 (full/scoped/temporal)

### 2.2 Cancel 은 별도 취급

- cancel 은 "선택하지 않음" 의 의사 표현이므로 3 개 옵션과 동등 비교 X
- 항상 마지막 위치 (D4) 에 배치
- intensity 부여하지 않음 (⚪ default, never 👍, never ⚠)

### 2.3 Option Card 구조 (표준)

```yaml
option_card:
  options:
    - option_id: option-full
      scope: full
      intensity: "👍" | "⚪" | "⚠"
      label: "<한 줄 설명>"
      reasoning: "<왜 이 옵션이 이 intensity 인지>"
    - option_id: option-scoped
      scope: scoped
      parent_suggestion: strategy-pm
      intensity: ...
    - option_id: option-temporal
      scope: temporal
      sunset_at_suggestion: "Sprint 7"
      intensity: ...
  cancel:
    option_id: option-cancel
    label: "취소 (현재 상태 유지)"
```

---

## 3. 3-Level Intensity Rule

### 3.1 의미

| 기호 | 이름 | 해석 |
| --- | --- | --- |
| 👍 | 권장 | 현재 맥락(intent + persona + project state)에서 first-choice default |
| ⚪ | 중립 | 합리적 선택지, 상황에 따라 적합 |
| ⚠ | 비권장 | 이 선택은 알려진 리스크가 있음. **단 차단되지 않음** (사용자 final filter) |

### 3.2 할당 알고리즘

**입력 신호** (모두 hint, 강제 아님):

- `intent_classified`: Phase B 에서 LLM 이 추론한 intent label
- `project_state.team_size`: 1 / 2~5 / 6+
- `project_state.dau_band`: 0 / <100 / <1k / <10k / ≥10k
- `project_state.phase`: 0 / 1 / 2 / 3
- `project_state.active_divisions`: 현재 active 본부 count
- `branch.phase_D_option_rules.option_templates[].default_intensity`
- `branch.warn_conditions[]`

**결정 순서** (branch 파일 우선):

1. `intent_specific_overrides[intent]` 매치 시 → 해당 intensity 적용
2. 미매치 시 → `option_templates[].default_intensity` 사용
3. `warn_conditions[pattern]` 매치 시 → 매치된 option 의 intensity = ⚠ 강제
4. 검증: ALT-INV-2 (👍 정확히 1개) 위반 시 engine 경고 + product team 알림 (runtime 은 첫 👍 유지)

### 3.3 Intensity Drift 방지

- 같은 (target_division, persona-signature) 조합에서 intensity 가 **세션마다 달라지면 안 됨** — 결정 이력은 L1 에 기록되어 재현 가능성 확보
- Drift 감지: `divisions_yaml_diff_hash` + `intent_classified` + `persona_hash` 조합이 같은데 intensity 가 다르면 log warning

---

## 4. Never-Hard-Block Rule

### 4.1 차단되지 않는 것

- ⚠ 옵션 선택 — UI 로 회색화(gray-out) 금지, enter/click 가능
- 모든 warn_conditions 매치 — 경고만 표시, terminal 진입 허용
- recommendation 과 다른 선택 — override 기록 후 정상 진행

### 4.2 차단되는 것 (예외)

schema violation 만 차단. 이는 "user preference" 가 아니라 "시스템 불변성" 이기 때문.

| 차단 사유 | 예시 |
| --- | --- |
| scope = scoped 인데 parent_division 없음 | ds-v 유사 schema rule |
| scope = temporal 인데 sunset_at 없음 | 동일 |
| parent_division self-reference | taxonomy → parent=taxonomy |
| parent chain 순환 | a→b→c→a |
| custom id 중복 | 기존 id 재사용 |

> schema violation 은 hard block 이지만, 이는 user choice 와 구분된다.
> "temporal 선택" 은 허용, "temporal + sunset_at 미지정" 은 불가 (입력 요청).

### 4.3 Override 시 엔진 동작

1. `recommendation_trigger = declined` 기록
2. `l1.division.dialog.override` 이벤트 발행
3. 사용자 rationale 수집 — **선택적 질문** (INV-5, 원칙 13 paternalism 방지)
   - 좋은 예: "간단히 메모 남기시겠어요? (선택)"
   - 나쁜 예: "⚠ 옵션을 선택하셨습니다. 사유를 반드시 입력해주세요."
4. terminal 진입 — 정상 처리

---

## 5. Decision Tree (Phase D 옵션 생성)

```
입력: target_division_id, branch (resolved), dialog_state.turns[:D)
│
├─ 1. branch.phase_D_option_rules.option_templates 로드
│
├─ 2. intent 추출 (dialog_state.turns[B].user_response.classified_intent)
│
├─ 3. IF branch.intent_specific_overrides[intent] EXISTS
│     │
│     └─ options = intent_specific_overrides[intent]  # 우선 적용
│
│     ELSE
│     │
│     └─ options = option_templates (default intensity 유지)
│
├─ 4. warn_conditions 매칭
│     │
│     └─ FOR each pattern in warn_conditions:
│          IF match(pattern, project_state):
│             mark_matching_option_as_warn(pattern.applies_to)
│             attach(pattern.alternatives) as alternatives_when_warned
│
├─ 5. 검증
│     │
│     ├─ ALT-INV-1: len(options) == 3
│     ├─ ALT-INV-2: count("👍" in intensities) == 1
│     └─ ALT-INV-5: 모든 ⚠ 옵션에 alternatives_when_warned 존재
│
├─ 6. cancel 옵션 append
│
└─ 출력: option_card (options[3] + cancel[1])
```

---

## 6. Edge Cases

### 6.1 branch 없음 (custom 본부 최초 추가)

→ `branches/custom.yaml` 로 fallback. Phase A Step 0 (mapping check) 선행.

### 6.2 같은 target 으로 두 번째 대화

→ `dialog-state.schema.yaml` ds-v-05 에 따라 기존 active 대화 status=superseded 로 closeout 후 새 대화 개시.

### 6.3 branch 에서 default 가 모두 ⚪

→ ALT-INV-2 위반. engine 이 중간 옵션(중간 index) 을 👍 로 승격 + product team 에 warning log.

### 6.4 warn_conditions 가 3 개 option 모두에 매치

→ 가능하지만 비정상. 모두 ⚠ 가 되면 👍 가 없어 ALT-INV-2 위반.
→ engine 처리: alternatives_when_warned 의 **대안 옵션을 4 번째로 제시** 하는 대신, 기본값 1 개 를 👍 로 유지하고 나머지만 ⚠ 로 강등 (product team 수동 검토 필요 flag).

### 6.5 engine 이 intent 추출 실패

→ `branch.default_hint` 사용 + `option_templates[].default_intensity` 그대로 적용.

---

## 7. L1 Event Integration

engine 은 옵션 생성 시점에 아래 debug 이벤트를 발행 (옵션 노출 전):

```json
{
  "event": "l1.engine.alternative.generated",
  "dialog_trace_id": "dlg-2026-04-25-qa-03",
  "target": "qa",
  "intent": "pre-mvp-quality-gate",
  "options_count": 3,
  "intensities": ["👍", "⚪", "⚠"],
  "warn_conditions_matched": [],
  "branch_source": "qa.yaml"
}
```

이 이벤트는 audit 및 drift 감지에 사용된다.

---

## 8. Anti-Patterns (금지)

| Anti-Pattern | 왜 금지 |
| --- | --- |
| 옵션 4 개 이상 제시 | ALT-INV-1 위반, 선택 피로 |
| 👍 복수 / 👍 없음 | ALT-INV-2 위반, 의사결정 불명확 |
| ⚠ 옵션 UI disabled | ALT-INV-3 위반, paternalism |
| reasoning 생략 | ALT-INV-4 위반, opaque recommendation |
| override 시 rationale 강제 입력 | 원칙 13 위반 (paternalism) |
| engine 이 자동으로 option 선택 실행 | INV-3 위반 (user agency) |
| 같은 맥락에서 intensity drift | 재현성 상실, L1 audit 실패 |

---

## 9. 채명정 예시 — 실제 동작

### 9.1 Input

- user: `/sfs division activate qa`
- dialog_state.turns[1]=A(confirmed), turns[2]=B(classified_intent=pre-mvp-quality-gate), turns[3]=C(확정)
- project_state: team_size=1, dau_band=<100, phase=1, active_divisions=2

### 9.2 Engine 처리

1. branch = `branches/qa.yaml`
2. intent = `pre-mvp-quality-gate`
3. intent_specific_overrides[pre-mvp-quality-gate] 매치 →
   - option-temporal (scope=temporal, intensity=👍, label="temporal (launch_date 까지)")
4. 나머지 2 옵션은 option_templates 에서 가져옴 —
   - option-full (⚪, "full (지속 본부)")
   - option-scoped (⚠, "scoped (dev 본부 하위)") + alternatives_when_warned
5. warn_conditions: 매치 없음 (qa 는 pre-MVP 에 warn 없음)
6. 검증 통과
7. output:

```yaml
option_card:
  options:
    - option_id: option-temporal
      intensity: "👍"
      label: "temporal (launch_date 까지)"
      reasoning: "MVP 시점 기반 품질 gate"
    - option_id: option-full
      intensity: "⚪"
      label: "full (지속 본부)"
      reasoning: "regression 방어 지속 과제면 적합"
    - option_id: option-scoped
      intensity: "⚠"
      label: "scoped (dev 본부 하위)"
      reasoning: "자기검증 편향 위험 (원칙 2)"
      alternatives_when_warned:
        - "full 로 독립 본부 활성화"
        - "temporal full 로 출시까지만 독립 활성"
  cancel:
    option_id: option-cancel
    label: "취소 (현재 상태 유지)"
```

---

## 10. Phase 1 구현 체크리스트

- [ ] `option_templates` 로더 (yaml → struct)
- [ ] `intent_specific_overrides` 매처
- [ ] `warn_conditions` 매처 (pattern DSL 최소 구현)
- [ ] ALT-INV-1/2/5 validator
- [ ] override detection + L1 이벤트 발행
- [ ] drift 감지 (persona_hash + intent + target 시그니처)
- [ ] branch fallback (custom.yaml)
- [ ] cancel 옵션 자동 추가
- [ ] reasoning string sanitizer (max 80 chars)
- [ ] schema violation 차단 vs user-preference 통과 구분 로직
- [ ] `alternatives_when_warned` 최소 2 개 enforcement
- [ ] test fixture: qa/taxonomy/infra 3 개 시나리오 + override 1 개

---

## 11. Out-of-Scope (Phase 2+)

- Multi-language reasoning string (현재는 한국어 고정)
- Persona 자동 추론 (현재는 사용자 입력 의존)
- Intensity 의 학습 기반 재조정 (Phase 2 에서 G5 Retro 데이터 기반)
- engine 이 branch 파일 자동 생성 (custom 본부 확장 시)
