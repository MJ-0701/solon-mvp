# Division Activation Socratic Dialog — Index

---
doc_id: sfs-v0.4-appendix-dialogs-index
title: "Division Activation Socratic Dialog Index"
version: 1.0.0
status: draft
last_updated: 2026-04-20
audience: [implementers, plugin-developers, audit-reviewer, dialog-engine-author]

depends_on:
  - dialog/division-activation (appendix/dialogs/division-activation.dialog.yaml)
  - schema/dialog-state (appendix/schemas/dialog-state.schema.yaml)
  - engine/alternative-suggestion (appendix/engines/alternative-suggestion-engine.md)
  - principle/progressive-activation (s02 §2.13)
  - principle/human-final-filter (s02 §2.10)

defines:
  - index/socratic-5-phase-dialog
  - format/dialog_trace_id (canonical 재서술; 정의는 schema/dialog-state)
  - enum/dialog-phase-a-to-e (canonical 재서술; 정의는 dialog/division-activation.states)
  - summary/alt-inv-1-to-3 (canonical 재서술; 정의는 engine/alternative-suggestion)

references:
  - s02 §2.13, s03 §3.3.0, s03 §3.7 (Phase 1 Baseline)
  - appendix/commands/division.md
  - appendix/commands/install.md (Socratic wizard 차용)
  - appendix/dialogs/branches/*.yaml (6 본부 + _default)
  - appendix/dialogs/traces/<trace-id>.yaml (turn-by-turn checkpoint)
  - appendix/schemas/l1-log-event.schema.yaml (l1.division.dialog.* 3종)
---

> 본 파일은 **index only** — 각 phase 의 template·post-processing·emit 규약은 통합 spec
> `division-activation.dialog.yaml` 에 정의된다. Phase 1 W1~W2 에서 `phase-a~e.md` 5 파일로
> 분해될 때 본 README 가 상호참조 허브 역할을 맡는다.

---

## 1. 5-Phase 개요

`/sfs division activate|deactivate|add` 는 반드시 아래 5 phase 를 통과한다.
건너뛰기 (예: A → D jump) 는 `INV-1` (ask-context-first) 위반.

| Phase | 이름 | 질문 성격 | 화자 | 종료 조건 | 통합 spec 위치 |
|:-:|------|-----------|:-:|---------|---------------|
| **A** | Context | 현재 상황 재확인 (Phase / Sprint / active divisions / target 이력) | solon | 사용자가 "진행" 의사 표명 | `phase_A` block |
| **B** | Q1 Why now | "왜 지금 이 본부를 {activate\|deactivate} 하려 하나요?" (intent discovery) | solon → user free-text | intent label 분류 완료 | `phase_B` block |
| **C** | Q2 Clarify | scope / 기간 / parent_division / sunset_at 명확화 | solon → user `[1\|2\|3]` or free-text | scope_choice 확정 | `phase_C` block |
| **D** | Option Card | 3-tier × 👍⚪⚠ intensity + alternatives + `[C] cancel` | solon → user `[1\|2\|3\|C]` | 사용자 최종 선택 (⚠ override 포함) | `phase_D` block |
| **E** | Terminal | `divisions.yaml` update + memory scaffold + L1 events emit | solon (execute) | `l1.division.dialog.complete` 발행 | `phase_E` block |
| X | Exit (any→end) | 취소 — yaml 변경 없음, trace 만 저장 | — | `terminal/cancel` 도달 | 동 yaml `phase_E.terminals[terminal/cancel]` |

> **상태 머신 축약**: start → A → B → C → D → E → end. C/D 에서 사용자 재질문 시 한 단계 back-edge
> 허용 (C↔B, D↔C). B/C 에서 exit 키워드(`cancel`/`/cancel`/`quit`/`exit`) → X.

### 1.1 phase 간 되돌아가기 규칙

- **D → C (re-clarify)**: 사용자가 scope 재선정 요청 시 1회 허용 (해당 rephrase 는 `rephrase_policy: "at most 1 per dialog"` 카운터와 별개).
- **C → B (rephrase Q1)**: 사용자가 intent 를 다시 서술하고 싶을 때 1회 허용 (`post_processing.rephrase_policy`).
- **A → X, B → X**: 어느 시점이든 exit 키워드 시 즉시 X. Phase D 의 `[C] cancel` 도 동일 경로.
- `current_phase` 는 `ds-v-03` (append-only, 되돌아가기 금지) 에 따라 로그 상으로는 단조 진행으로 기록되며, back-edge 는 새 turn_no 로 다시 해당 phase 를 방문한 것으로 표현된다.

### 1.2 각 phase 의 L1 event

| Phase | 발행 이벤트 | 필수 필드 (요약) | 상세 |
|:-:|-----------|----------------|------|
| A | `l1.division.dialog.turn` | `{phase: A, trace_id, target}` | `dialog/division-activation.phase_A.emits` |
| B | `l1.division.dialog.turn` | `{phase: B, intent_label, user_utterance_hash}` | raw utterance 는 sha256 로만 이벤트화 (개인정보 보호) |
| C | `l1.division.dialog.turn` | `{phase: C, scope_choice, parent_division, sunset_at}` | — |
| D | `l1.division.dialog.turn` + (조건부) `l1.division.dialog.override` | `{phase: D, final_choice, override: bool}` + override 시 `{recommended_option_id, chosen_option_id, recommendation_trigger}` | ALT-INV-3 증거 |
| E | `l1.division.dialog.complete` + `l1.division.state-changed` | `{terminal_reached, total_turns, divisions_yaml_diff_hash}` | terminal 도달 직후 yaml 변경 직전 |

이벤트 schema 상세: `appendix/schemas/dialog-state.schema.yaml §3`, `appendix/schemas/l1-log-event.schema.yaml`.

### 1.3 Terminal 분기 (Phase E)

`division-activation.dialog.yaml` `phase_E.terminals` 5 종:

- `terminal/activate-full` — `activation_state: active` / `scope: full`
- `terminal/activate-scoped` — `scope: scoped` + `parent_division` 필수
- `terminal/activate-temporal` — `scope: temporal` + `sunset_at` 필수 (ISO 8601 또는 `Sprint N`). sunset 도달 시 `/sfs division deactivate --prompt-renew` 자동 대화 제안 (never-hard-block)
- `terminal/deactivate` — `deactivated_at` 기록 + `memory/<id>/ → memory/.archive/<id>/<date>/` 이동
- `terminal/cancel` — yaml 변경 **없음**, trace 만 7일 보존 후 expired

---

## 2. `dialog_trace_id` 규약

### 2.1 Canonical 정의

**정의 SSoT**: `appendix/schemas/dialog-state.schema.yaml §1 DialogState.fields.dialog_trace_id`

- **형식**: `dlg-YYYY-MM-DD-<target-id>-<seq>`
- **정규식**: `^dlg-\d{4}-\d{2}-\d{2}-[a-z0-9-]+-\d{2}$`
- **seq**: 2 자리 zero-pad, 같은 `(date, target-id)` 조합 내에서 `00` 부터 연속 증가
- **수명**: 대화 세션 시작부터 terminal 도달 (또는 expire) 까지 유지 — `immutable: true` (`ds-v-01`)

### 2.2 예시

```
dlg-2026-04-25-qa-03      # 2026-04-25 에 qa 본부 대상 3 번째 대화 (seq=03)
dlg-2026-04-26-infra-01   # infra 본부 첫 대화
dlg-2026-05-10-custom-ml-00   # custom 본부 id 는 여러 하이픈 허용
```

### 2.3 seq 증가 규칙

같은 일자 · 같은 target 내에서 새 대화가 시작될 때 seq 가 `+1`. 이때 기존 `status: active` 대화는
`ds-v-05` 에 따라 `status: superseded` 로 자동 closeout.

### 2.4 저장 위치 & 보존

- **파일**: `memory/dialog-trace/<YYYY-MM>/<dialog_trace_id>.yaml` (`dialog-state.schema.yaml §7 storage`)
- **보조 checkpoint**: `appendix/dialogs/traces/<trace-id>.yaml` (`INV-4 turn-checkpoint`, write-after-emit)
- **보존 정책** (gc):
  - `active` → 7일 무응답 시 `abandoned`
  - `cancelled` → 7일 후 archive
  - `completed` → 365일 후 archive
  - `override_record` 기록 있는 trace → **영구 보존** (audit 증거, 원칙 13)

### 2.5 L1 event 와의 관계

모든 dialog 관련 L1 이벤트 (`l1.division.dialog.turn|complete|override`) 의 **조인 키** 는
`dialog_trace_id` 다. observability 파이프라인은 이 id 로 turn 시퀀스 + override 조합 + 최종
`divisions_yaml_diff_hash` 를 하나의 감사 단위로 복원한다.

### 2.6 Resume Protocol

`status: active` 이며 `last_turn_at` 이 7일 이내 + `can_resume_until > now()` 인 trace 가
존재하면 `/sfs division resume <trace-id>` 로 재개 가능. 상세 절차는
`appendix/schemas/dialog-state.schema.yaml §5 resume_protocol`.

---

## 3. ALT-INV-1 ~ ALT-INV-3 요약

> **정의 SSoT**: `appendix/engines/alternative-suggestion-engine.md §1 Core Invariants`.
> 본 섹션은 **요약 + Phase D 와의 매핑** 만 제공. 변경 · 확장은 엔진 spec 에서만 한다.

### 3.1 ALT-INV-1 — three-tier-required

> **Rule**: 모든 Option Card (Phase D) 는 정확히 **3 개의 실행 옵션 + 1 개의 cancel 옵션**.

- 2개 → A/B 이분법으로 뉘앙스 손실 (예: `full` vs `temporal` 만 있으면 `scoped` 누락)
- 4개 이상 → 인지 부하 급증 (paradox of choice)
- 3개 → 본부 scope 자연 3 분법 (full / scoped / temporal) 과 일치
- `cancel` 은 "선택하지 않음" 의 의사 표현이므로 3개 옵션과 동등 비교 대상 아님. 항상 마지막 위치 (`[C] cancel`) 에 배치, intensity 없음 (`⚪` default).

### 3.2 ALT-INV-2 — exactly-one-recommended

> **Rule**: 3 개 실행 옵션 중 👍 (권장) 는 **정확히 1 개**. 없거나 복수는 금지.

- ⚪ 중립 / ⚠ 비권장 개수 제약은 없음 (2⚪+1👍, 1⚪+1⚠+1👍 등 자유 조합)
- `intensity-not-ranking` (ALT-INV-6): 👍 는 "더 나음" 이 아니라 "현 상황에 더 적합한 기본값". user override 는 정상 동작.
- Edge case (§6.3 엔진 spec): branch 의 default 가 모두 ⚪ 이면 엔진이 중간 index 옵션을 👍 로 승격 + product team warning log.

### 3.3 ALT-INV-3 — never-hard-block

> **Rule**: ⚠ 옵션도 **선택 가능** — UI 비활성화 / gray-out / 차단 금지.

- `override_handling` (dialog yaml `phase_D.override_handling`): 1회 대안 재제시 후 재선택 시 **반드시 수락**.
- `terminal=cancel 강제 금지` (dialog yaml `INV-3`).
- 차단되는 것은 오직 **schema violation** (ALT 엔진 spec §4.2): `scope=scoped` 인데 `parent_division` 없음 / `scope=temporal` 인데 `sunset_at` 없음 / parent 순환 / custom id 중복 등. 이는 "user preference 차단" 이 아니라 "system invariant" 이므로 ALT-INV-3 와 구분된다.
- 원칙 10 (human-final-filter) + 원칙 13 (progressive-activation non-prescriptive) 의 핵심 실행 조항.

### 3.4 Phase D 매핑 표

| ALT-INV | Phase D 어디서 enforce | 위반 시 | L1 증거 |
|:-:|----------------------|--------|---------|
| ALT-INV-1 | 옵션 배열 크기 == 3 (cancel 제외) | engine 검증 abort, `l1.engine.alternative.generated.invalid` | — |
| ALT-INV-2 | `count(intensity=='👍') == 1` | 엔진 경고 + 중간 index 승격 (§6.3) | `l1.engine.alternative.generated` intensities 배열 |
| ALT-INV-3 | UI `[1\|2\|3\|C]` 입력 수락 모두 허용 | 구현 bug — 절대 프로덕션 진입 금지 | `l1.division.dialog.override` (⚠ 선택 시) |

### 3.5 관련 Invariant 보조 3종 (요약만)

> 상세는 엔진 spec §1 참조.

- **ALT-INV-4 — reasoning-required**: 모든 옵션은 `reasoning` 1 줄 이내 제공 (opaqueness 금지).
- **ALT-INV-5 — warn-provides-alternatives**: ⚠ 옵션 제시 시 `alternatives_when_warned` 배열에 최소 2 개 대안 필수.
- **ALT-INV-6 — intensity-not-ranking**: 👍 는 "기본값" 이지 "상위 랭크" 가 아님. user override 는 drift 가 아니다.

---

## 4. 본부별 Branch Resolution

통합 spec `branch_resolution` 블록 참조:

- `target.id` → `appendix/dialogs/branches/<target-id>.yaml` 로드
- 없으면 `branches/_default.yaml` 사용 (custom 본부 `/sfs division add` 첫 호출 시 경로)
- merge 전략: **branch overrides meta, meta provides fallback**
- 지원 branches: `taxonomy`, `qa`, `design`, `infra`, `strategy-pm`, `custom`

branch 파일은 Phase B `examples_for_branch` 와 Phase C `intent_based_hint` 를 공급한다.
Phase D 옵션 배열은 엔진이 `branch.phase_D_option_rules` + `intent_specific_overrides` +
`warn_conditions` 조합으로 동적 생성 (engine spec §5 Decision Tree).

---

## 5. 파일 관계도 (context map)

```
                             ┌─────────────────────────────────────────┐
                             │  appendix/dialogs/README.md  (this)     │
                             │    - index / phase overview             │
                             │    - dialog_trace_id canonical summary  │
                             │    - ALT-INV-1~3 summary + D mapping    │
                             └───────────────────┬─────────────────────┘
                                                 │
                   ┌─────────────────────────────┼──────────────────────────────┐
                   │                             │                              │
                   ▼                             ▼                              ▼
    ┌────────────────────────────┐ ┌──────────────────────────┐ ┌──────────────────────────┐
    │ division-activation        │ │ schemas/dialog-state     │ │ engines/alternative-     │
    │ .dialog.yaml               │ │ .schema.yaml             │ │ suggestion-engine.md     │
    │  (5 phase template SSoT)   │ │  (trace_id / turn SSoT)  │ │  (ALT-INV SSoT)          │
    └──────────┬─────────────────┘ └─────────────┬────────────┘ └────────────┬─────────────┘
               │                                 │                           │
               ▼                                 ▼                           │
    ┌──────────────────────────┐    ┌──────────────────────────┐             │
    │ branches/{taxonomy, qa,  │    │ traces/<trace-id>.yaml   │             │
    │  design, infra,          │    │  (per-turn checkpoint,   │             │
    │  strategy-pm, custom,    │    │   INV-4 write-after-emit)│             │
    │  _default}.yaml          │    └──────────────────────────┘             │
    └──────────────────────────┘                                             │
                                                                             ▼
                                                               ┌──────────────────────────┐
                                                               │ Phase 1 W1~W2:           │
                                                               │  phase-a~e.md (5 files)  │
                                                               │  engines/dialog-engine.md│
                                                               │  (spec 분해 산출물)      │
                                                               └──────────────────────────┘
```

---

## 6. Phase 1 분해 계획 (W1~W2)

본 README 는 Phase 1 W1~W2 에서 통합 spec 이 분해될 때의 **index 허브** 역할로 선제 생성됐다.
분해 후 추가될 5 phase md 파일과 `dialog-engine.md` 는 다음 chunk 만 담당하도록 책임 범위를
협소하게 유지한다 (원칙 2 self-validation 회피 + 원칙 8 DRY):

| 파일 (Phase 1 W1~W2 생성) | 담을 내용 | SSoT 참조 방향 |
|---------------------------|-----------|----------------|
| `phase-a-context.md` | Context template + 변수 스키마 (`current_phase`, `active_divisions`, `target.history`) | yaml `phase_A` → phase-a.md (1:1 복제 금지, 사용 가이드 + 예시만) |
| `phase-b-why-now.md` | Q1 template + intent classifier 라벨 7종 + edge-case rephrase 정책 | yaml `phase_B` |
| `phase-c-clarify.md` | Q2 scope 3 분기 + `parent_division` / `sunset_at` 요청 절차 | yaml `phase_C` |
| `phase-d-option-card.md` | Option Card 렌더링 규약 + ALT-INV-1~5 enforcement + override handling | engine spec + yaml `phase_D` |
| `phase-e-terminal.md` | 5 terminal 분기별 side-effects + L1 `complete` 페이로드 | yaml `phase_E` |
| `appendix/engines/dialog-engine.md` | state machine (start → A→B→C→D→E→end, back-edges, X) + transition guards + resume protocol 구현 | yaml `states` + `transitions` + schema `§5 resume_protocol` |

---

## 7. 본 README 에서 **재정의하지 않는 것** (Single Source of Truth 유지)

- `phase_A` ~ `phase_E` 의 template 문자열 · emits 블록 · post_processing 스텝 → `division-activation.dialog.yaml`
- `DialogState` / `DialogTurn` / 3 종 L1 event 구조 · validation rules (`ds-v-01~12`) · resume protocol → `dialog-state.schema.yaml`
- ALT-INV-1 ~ ALT-INV-6 정의 · 할당 알고리즘 · warn_conditions 매칭 규칙 · edge-case 처리 → `alternative-suggestion-engine.md`
- 각 본부별 `examples_for_branch` · `intent_based_hint` · `option_templates` · `warn_conditions` → `branches/<div-id>.yaml`

위 항목들을 본 README 에서 "재작성" 하면 drift 위험이 발생한다. 상충 시 **SSoT 파일이 항상 우선**.

---

## 8. 관련 문서

- **통합 spec**: `appendix/dialogs/division-activation.dialog.yaml`
- **schema**: `appendix/schemas/dialog-state.schema.yaml`
- **engine**: `appendix/engines/alternative-suggestion-engine.md`
- **command**: `appendix/commands/division.md` (`/sfs division activate|deactivate|add`)
- **원칙**: `02-design-principles.md` §2.10 (human-final-filter), §2.13 (progressive-activation)
- **조직도**: `03-c-level-matrix.md` §3.3.0 (Division Activation State), §3.7 (Phase 1 Baseline = dev + strategy-pm)
- **상호참조 audit**: `cross-ref-audit.md` §4 TODO #1 (본 파일의 생성 근거)

끝.
