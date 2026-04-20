---
command_id: "sfs-division"
command_name: "/sfs division"
version: "1.0.0"
phase: "any"                              # 어느 Phase 에서도 호출 가능
mode: "both"                              # greenfield + brownfield 모두
operator: "user"                          # 사용자가 직접 호출. agent 자동 호출 금지 (non-prescriptive guidance)
triggers:
  - "division"
  - "본부 활성화"
  - "본부 추가"
  - "division activate"
  - "division deactivate"
  - "division list"
  - "division recommend"
  - "division add"
subcommands:
  - "activate <division-id>"
  - "deactivate <division-id>"
  - "list"
  - "add <division-id>"
  - "recommend"
  - "status <division-id>"                # 🆕 detail
requires_gate_before: []                  # Gate 통과 없이 호출 가능 (단, Socratic dialog 필수)
produces:
  - "divisions.yaml (수정)"               # activation_state / scope / sunset_at 등
  - "appendix/dialogs/traces/<trace-id>.yaml"  # 대화 이력
  - "l1.division.dialog.*"                # 이벤트 스트림
  - "memory/<division-id>/" (active 전환 시 생성)
calls_evaluators: []                      # evaluator 호출 없음 (사용자 대화만)
model_allocation:
  default: "claude-sonnet-4-6"            # Socratic dialog 주도
  secondary: "claude-haiku-4-5-20251001"  # state parsing, yaml diff
  opus_allowed: false                     # 비용 cap (대화는 Sonnet 으로 충분)
cost_budget_usd:
  per_invocation: 0.50                    # dialog 1회당 cap
  abort_threshold: 2.00
timeout_ms: 1800000                       # 30분 (대화 중단·재개 가능)
tool_restrictions:
  allowed: ["Read", "Edit", "Write(divisions.yaml, traces/)"]
  forbidden: ["Bash(destructive)", "NotebookEdit"]
  note: "divisions.yaml 변경은 dialog Terminal 도달 후에만. 중간 turn 에서는 trace 만 기록."
audit_fields:
  - "invocation_id"
  - "subcommand"
  - "target_division_id"
  - "caller"
  - "invoked_at"
  - "dialog_trace_id"
  - "terminal_reached"                    # full | scoped | temporal | cancel
  - "pre_state"                            # abstract | active | deactivated
  - "post_state"
  - "recommendation_intensity_at_choice"   # 👍 / ⚪ / ⚠
  - "user_overrode_recommendation"         # true if user chose ⚠

references:
  - principle/progressive-activation (defined in: s02 §2.13)
  - principle/human-final-filter (defined in: s02 §2.10)
  - principle/phase1-phase2-separation (defined in: s02 §2.8)
  - schema/divisions-yaml-v1.1 (defined in: appendix/schemas/divisions.schema.yaml)
  - schema/dialog-state-v1 (defined in: appendix/schemas/dialog-state.schema.yaml)
  - dialog/division-activation (defined in: appendix/dialogs/division-activation.dialog.yaml)
  - engine/alternative-suggestion (defined in: appendix/engines/alternative-suggestion-engine.md)
  - rule/never-hard-block (defined in: s02 §2.13.4)
  - rule/phase1-basic-active-divisions (defined in: s02 §2.13.9)
  - event/l1.division.dialog.turn (defined in: appendix/schemas/l1-log-event.schema.yaml)
  - event/l1.division.dialog.complete (defined in: appendix/schemas/l1-log-event.schema.yaml)
---

# /sfs division

> **본부 활성화 / 비활성화 / 추가 / 조회를 담당하는 사용자 주도 CLI.**
> 모든 상태 변경은 Socratic dialog 를 거친다. 시스템이 자동 결정하지 않는다.
> 핵심 원칙: **Ask context first → Present alternatives → Never hard-block**.

---

## 1. 의도 (Intent)

`/sfs division` 은 **원칙 13 Progressive Activation + Non-Prescriptive Guidance** 의 운영 채널이다.

이 command 가 해결하는 문제:

1. **Heavy by default 방지** — 6 본부가 첫 설치 시 전부 active 상태로 로드되는 것을 막는다.
2. **Paternalism 방지** — 시스템이 규칙 기반으로 "너는 taxonomy 필요 없어" 같은 자동 차단을 하지 않도록 한다.
3. **1인 창업 사각지대 해소** — IT 경험이 없는 사용자에게 "Infra 본부가 필요한지조차 모르는" 순간에 Socratic dialog 로 물어본다.
4. **감사 추적성** — 모든 활성화 변경은 `dialog_trace_id` 로 기록되어 retro 재검토 가능.

**명시적 non-goals**:
- ❌ 시스템이 본부를 **자동으로** activate/deactivate 하지 않는다 (agent 가 `/sfs division activate` 직접 호출 금지).
- ❌ 비권장 활성화를 **차단하지 않는다** (⚠ 표시 + 대안 제시 1회, 재선택 시 수락).
- ❌ 기존 본부를 `/sfs division remove` 로 **삭제하지 않는다** (tier=core 본부는 삭제 불가, abstract 로 전환만 가능).

---

## 2. Subcommands

### 2.1 `/sfs division list`

현재 모든 본부의 activation_state + scope 을 표로 출력. Socratic dialog 없음.

```bash
$ /sfs division list
┌────────────────┬───────────┬──────────────┬──────────────┬─────────────────────┐
│ id             │ tier      │ state        │ scope        │ detail              │
├────────────────┼───────────┼──────────────┼──────────────┼─────────────────────┤
│ dev            │ core      │ active       │ full         │ -                   │
│ strategy-pm    │ core      │ active       │ full         │ -                   │
│ qa             │ core      │ active       │ temporal     │ sunset: 2026-06-15  │
│ design         │ core      │ abstract     │ -            │ -                   │
│ infra          │ core      │ abstract     │ -            │ -                   │
│ taxonomy       │ core      │ active       │ scoped       │ parent: strategy-pm │
└────────────────┴───────────┴──────────────┴──────────────┴─────────────────────┘

Active: 3 | Abstract: 2 | Deactivated: 0
```

### 2.2 `/sfs division activate <id>`

Socratic dialog 실행 → Terminal 도달 시 `divisions.yaml` 의 activation_state 변경.

- abstract → active 전환
- active 인 본부에 재호출 시: "이미 active 입니다. scope 을 바꾸시겠습니까?" 로 분기
- deactivated → active 재활성화 (dialog_trace_id 신규 발급, 과거 sunset_at 은 deactivated_at 에 archive)

**입력**:
```bash
/sfs division activate qa
```

**대화 흐름** (요약, 상세는 §3):
- A. Context — "현재 Phase 1, Sprint 3, 본부 상태 (dev/strategy-pm active, 나머지 abstract)"
- B. Q1 — "왜 지금 qa 를 활성화하려 하시나요?"
- C. Q2 — "어떤 기간·범위로?"
- D. Option Card — Full / Scoped / Temporal / Cancel (각 옵션에 👍/⚪/⚠ 표시)
- E. Terminal — divisions.yaml 갱신 + L1 이벤트 발행

### 2.3 `/sfs division deactivate <id>`

active → deactivated 전환. Socratic dialog 로 이유 확인.

**제약**:
- `tier == core` 인 본부도 deactivate 가능 (단, 완전 삭제는 아님 — activation_state 만 변경, 이력 보존)
- deactivate 시 `deactivated_at: <now>` 자동 기록
- 해당 본부의 진행 중인 PDCA 가 있으면 **차단 없이** warning + 사용자 확인 ("진행 중 PDCA 3개가 있습니다. 그래도 비활성화?")

### 2.4 `/sfs division add <id>`

custom tier 본부 신규 추가. Socratic dialog 로 본부 schema 생성.

**조건**:
- id 가 기존 divisions 와 겹치지 않아야 함
- tier 는 자동 `custom` 설정
- 활성화 여부는 add dialog 의 연장으로 즉시 진행 (default: abstract 로 생성)

예시:
```bash
/sfs division add marketing
```
→ dialog 로 name, head_agent, workers, evaluators, g4_formula 수집 → divisions.yaml 에 추가

### 2.5 `/sfs division recommend`

현재 상황 (Sprint 진행 / 최근 brainstorm / discovery-report / hot-paths) 을 분석하여 **활성화 recommendation** 을 제시. **활성화 자체는 수행하지 않음** — 사용자가 이후 `/sfs division activate <id>` 를 명시 호출해야 함.

```bash
$ /sfs division recommend
📊 현재 상황 요약
  - Phase 1, Sprint 5 진행 중
  - 최근 brainstorm: "보험 도메인 용어 통일 필요" (Initiative-002)
  - discovery-report 에서 추출된 도메인 용어 후보 47건

🎯 추천 변경 (최대 3개)
  1. 👍 taxonomy 활성화 (scoped → strategy-pm 하위)
     근거: Initiative-002 가 taxonomy 작업을 전제로 함
     실행: /sfs division activate taxonomy

  2. ⚪ qa 활성화 (temporal → Sprint 7 까지)
     근거: MVP 출시 목표일(2026-06-15) 5 sprint 남음
     실행: /sfs division activate qa

  3. ⚠ infra 활성화 비권장 (현재 Vercel 배포로 충분)
     근거: 배포 규모 < 1000 DAU, hot-paths 에 infra 코드 없음
     대안: Vercel analytics + uptime monitoring 수동 체크 유지
     그래도 활성화하려면: /sfs division activate infra

※ 추천은 참고용. 최종 결정은 사용자가 합니다. (원칙 10, 13)
```

### 2.6 `/sfs division status <id>`

단일 본부 상세 상태 조회. activation_history + dialog_trace_id + 관련 PDCA 목록.

---

## 3. Socratic Dialog 흐름 (activate 기준)

상세 tree 는 [appendix/dialogs/division-activation.dialog.yaml](../dialogs/division-activation.dialog.yaml) 참조. 본 섹션은 command 실행 관점의 흐름.

### 3.1 Phase A — Context

```
solon: 현재 상황입니다.
        • Phase: 1 (dogfooding)
        • Sprint: 5 (진행 중)
        • 활성 본부: dev, strategy-pm
        • 최근 brainstorm: "보험 도메인 용어 통일" (Initiative-002)
        • qa 본부 현재 상태: abstract

        qa 를 활성화하려는 맥락에 대해 몇 가지 여쭙겠습니다.
```

### 3.2 Phase B — Q1: Why now

```
solon: Q1. 왜 지금 qa 를 활성화하려 하시나요? (자유 서술)
        예: "MVP 출시 전 버그 줄이고 싶어", "regression 테스트 체계화" 등

user: MVP 출시가 2달 남았는데 수동 테스트로는 한계야.
```

→ agent 가 의도 분류 (intent_label: `pre-mvp-quality-gate`). L1 이벤트 `l1.division.dialog.turn { phase: B }` emit.

### 3.3 Phase C — Q2: Clarify

```
solon: Q2. 활성화 기간·범위를 명확히 하고 싶습니다.
        (1) 전사 도입 (MVP 이후에도 계속 유지) — full
        (2) 개발 본부 하위 worker 로만 활용 — scoped
        (3) MVP 출시 시점까지 한정 (예: Sprint 7 까지) — temporal

        MVP 출시가 2달 남았다고 하셨으니, 3번이 현재 상황에 맞아 보이지만
        어떻게 생각하시나요?

user: 3번. Sprint 7 까지만.
```

### 3.4 Phase D — Option Card

```
solon: 확인하겠습니다. 3개 옵션을 제시합니다.

  [1] 👍 temporal (Sprint 7 까지) ← 권장
      sunset_at: 2026-06-15T00:00:00Z
      이후 Sprint 7 종료 시 "계속 유지할까요?" 재질문

  [2] ⚪ full (장기 유지)
      sunset_at 없음. MVP 이후에도 유지.

  [3] ⚠ scoped (dev 본부 하위로만)
      MVP 품질 gate 목적에는 독립 본부가 더 적합
      대안: qa 의 test-coverage-checker evaluator 만 dev 하위에서 호출 (full activation 없이)

  [C] cancel

user: 1
```

### 3.5 Phase E — Terminal

```
solon: ✅ qa 본부를 temporal 활성화 합니다.
        • state: active
        • scope: temporal
        • sunset_at: 2026-06-15T00:00:00Z
        • dialog_trace_id: dlg-2026-04-25-qa-03
        • recommendation_trigger: manual

        변경 사항:
        - divisions.yaml qa 섹션 업데이트
        - memory/qa/ 생성 (본부별 메모리 디렉터리)
        - L1 이벤트: l1.division.dialog.complete { outcome: activate-temporal }

        Sprint 7 종료 시 "qa 본부를 계속 유지할까요?" 를 다시 여쭙습니다.
        지금 바로 첫 PDCA 시작하시려면 `/sfs plan --division qa` 를 입력하세요.
```

### 3.6 Dialog 중단·재개

- 각 turn 종료 시 `appendix/dialogs/traces/<trace-id>.yaml` 에 checkpoint 저장
- 사용자가 Ctrl-C 또는 timeout 으로 중단 시 divisions.yaml **변경 없음**
- 재실행 시: `/sfs division activate qa --resume <trace-id>` → 마지막 turn 이후부터 재개
- 7일 이상 미사용 trace 는 `expired` 로 표시 (삭제는 하지 않음, audit 보존)

---

## 4. 예시 (Examples)

### 4.1 taxonomy scoped 활성화 (보험 도메인 1인 창업)

```bash
$ /sfs division activate taxonomy

solon: [Phase A] 현재 strategy-pm 에서 보험 도메인 용어 통일 Initiative 진행 중.
        taxonomy 는 현재 abstract. 활성화에 대해 여쭙겠습니다.

solon: [Phase B] Q1. 왜 지금 taxonomy 를 활성화하려 하시나요?
user: 보험 상품 약관 용어가 계속 흔들려서 agent 들이 서로 다른 이름으로 부름.

solon: [Phase C] Q2. 규모·범위:
        (1) full: 독립 본부로 taxonomy lead + worker + evaluator 전부 활성
        (2) scoped: strategy-pm 하위 worker 로만 활성 (용어 통일이 기획의 일부)
        (3) temporal: 특정 Sprint 만 한정
user: 2번. 지금은 strategy-pm 하위로 충분.

solon: [Phase D] Option Card
        [1] 👍 scoped (parent: strategy-pm)
        [2] ⚪ full
        [3] ⚠ temporal (보험 용어는 지속 관리가 필요 — 한시 종료 부적합)
        [C] cancel
user: 1

solon: [Phase E] ✅ taxonomy scoped (parent: strategy-pm) 활성화 완료.
        dialog_trace_id: dlg-2026-04-25-taxo-01
```

### 4.2 비권장 선택 (user override)

```bash
$ /sfs division activate infra

solon: [Phase A] 현재 Vercel 배포, DAU < 100, hot-paths 에 infra 코드 없음.

solon: [Phase B] Q1. 왜 지금 infra 를 활성화하려 하시나요?
user: 앞으로 AWS EKS 로 옮길 계획이라 미리 준비하고 싶어.

solon: [Phase C] Q2. 규모·범위:
        (1) full: 전사 infra 본부
        (2) scoped: dev 하위
        (3) temporal: 이전 완료까지만
user: 1번.

solon: [Phase D] Option Card
        [1] ⚠ full — 현재 DAU 100 미만으로는 비권장
           대안 A: ⚪ temporal (이전 완료까지만 활성, sunset_at 지정)
           대안 B: 👍 "Vercel 유지 + 이전 시점에 재협의"
           대안 C: scoped (dev 하위 SRE worker)
        [C] cancel

user: 그래도 1번.

solon: 이해했습니다. ⚠ 비권장 옵션을 선택하셨습니다.
        recommendation_trigger: declined 로 L1 기록 후 진행합니다.

solon: [Phase E] ✅ infra full 활성화.
        G5 Sprint Retro 에서 "infra 활성화가 실제로 가치를 냈는가" 를 재검토합니다.
```

→ 원칙 13 의 핵심 동작: **비권장이어도 차단하지 않고 수용 + 추적 기록**.

### 4.3 `/sfs division add` custom 본부

```bash
$ /sfs division add marketing

solon: custom 본부 'marketing' 추가를 시작합니다.
solon: 이름(한글) — "마케팅 본부"
solon: head_agent id — marketing-lead
solon: head_agent 모델 — sonnet / opus / haiku? (권장: sonnet) → sonnet
solon: workers — (생략, Socratic 로 수집)
solon: evaluators — 어떤 Gate 를 담당? (G3/G4) → G4
solon: g4_formula — 단일 evaluator? (formula: "<eval> × 1.0") → y

solon: ✅ divisions.yaml 에 marketing 본부 추가 (tier=custom, state=abstract).
        활성화는 `/sfs division activate marketing` 로 별도 수행.
```

---

## 5. 오류 처리 (Error Handling)

| 상황 | 처리 |
|------|------|
| 존재하지 않는 division id | "해당 id 없음. `/sfs division list` 로 확인" 후 종료 (abort, 아무 변경 없음) |
| 이미 active 인 본부에 activate 호출 | dialog 시작 → Phase A 에서 "현재 이미 active. scope 변경을 원하세요?" 분기 |
| `tier == core` 본부에 remove 시도 | rule/core-division-not-removable — "core 본부는 삭제 불가. `/sfs division deactivate` 로 abstract 전환 가능" |
| scoped 선택 시 parent_division 미존재 또는 abstract | dialog 재질문 → "parent 는 active 본부만 가능. 다른 parent 선택 또는 full 로 변경" |
| temporal 선택 시 sunset_at 과거 | dialog 재질문 → "과거 시점은 무효. 미래 날짜 입력" |
| dialog 중 Ctrl-C | divisions.yaml 변경 없음 + trace 파일에 partial 저장 + 재개 힌트 출력 |
| Budget cap 초과 | dialog 중단 → "현재 대화 비용 $X. 계속하시겠어요?" 1회 확인 |
| agent 가 `/sfs division activate` 자동 호출 시도 | rule/division-activate-user-only 위반 → abort + L1 `l1.rule-violation.division-auto-activation` |

---

## 6. Phase 1 구현 체크리스트

`/sfs division` skill 을 코드로 구현할 때 확인할 항목:

- [ ] subcommand parser (activate/deactivate/list/add/recommend/status)
- [ ] Socratic dialog engine 연동 (→ `appendix/dialogs/division-activation.dialog.yaml`)
- [ ] alternative-suggestion-engine 연동 (→ `appendix/engines/alternative-suggestion-engine.md`)
- [ ] divisions.yaml diff 생성 + 사용자 확인 후 write
- [ ] L1 이벤트 emitter: `l1.division.dialog.turn`, `l1.division.dialog.complete`, `l1.division.state-changed`
- [ ] `⚠ 비권장` 선택 시 hard-block 금지 테스트 (rule/never-hard-block 회귀 테스트)
- [ ] agent 가 이 command 를 자동 호출하지 못하도록 caller 검증 (caller=user 만 허용)
- [ ] dialog resume (`--resume <trace-id>`) 기능
- [ ] tier=core 본부 삭제 방지
- [ ] scoped 순환 참조 검출 (A→B→A)
- [ ] 재활성화 시 과거 sunset_at 을 deactivated_at 으로 archive
- [ ] `memory/<id>/` 자동 생성/삭제 (activate/deactivate 시)

---

## 7. 관련 docs

- §2.13 원칙 13 — Progressive Activation + Non-Prescriptive Guidance
- §2.10 원칙 10 — Human Final Filter (이 command 의 상위 선언)
- `appendix/schemas/divisions.schema.yaml` v1.1 — activation_state/scope 필드 정의
- `appendix/schemas/dialog-state.schema.yaml` — dialog turn tracking
- `appendix/dialogs/division-activation.dialog.yaml` — 5-phase meta dialog tree
- `appendix/dialogs/branches/{taxonomy,qa,design,infra,strategy-pm,custom}.yaml` — 본부별 branch
- `appendix/engines/alternative-suggestion-engine.md` — 3-tier 대안 + 3-level intensity
- `appendix/commands/README.md` — 전체 command index
- `appendix/commands/install.md` — 설치 시 본부 초기 활성화 (Socratic wizard)

---

*(끝)*
