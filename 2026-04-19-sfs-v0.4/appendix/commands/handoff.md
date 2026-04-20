---
command_id: "sfs-handoff"
command_name: "/sfs handoff"
version: "1.0.0"
phase: "do"                       # Do phase 종료 직후
mode: "common"
operator: "division-lead"         # 각 본부장 (Sonnet)
triggers:
  - "handoff"
  - "핸드오프"
  - "pre-handoff"
  - "G3"
  - "work-log 검수"
  - "이관"
requires_gate_before:
  - "G2"                           # Design gate 통과 전제
produces:
  - "docs/03-implementation/PDCA-{id}.{division}.gate-g3.yaml"
  - "docs/03-implementation/PDCA-{id}.{division}.handoff-report.md"
calls_evaluators:
  - "gap-detector"                 # bkit 재활용, design-vs-work-log preview
  - "code-analyzer"                # bkit 재활용, worker 코드 quick lint (dev 본부)
model_allocation:
  default: "claude-sonnet-4-6"     # 본부장 검수
  helper: "claude-haiku-4-5-20251001"  # DoD 체크리스트 파싱
  opus_allowed: false              # G3는 lead 레벨까지 (Opus는 G4에서만)
cost_budget_usd: 0.80
timeout_ms: 300000                  # 5분
tool_restrictions:
  allowed: ["Read", "Glob", "Grep", "Bash(read-only)", "Task", "Write(handoff-report only)"]
  forbidden: ["Edit(on src/)", "Write(on src/)"]   # 핸드오프는 검수만, 코드 수정 금지
audit_fields: ["called_by", "called_at", "pdca_id", "sprint_id", "division", "g3_verdict", "gap_preview_score"]
references:
  - "04-pdca-redef.md §4.4.3 Do phase 종료"
  - "05-gate-framework.md §5.5 G3 Pre-Handoff Gate"
  - "02-design-principles.md §2.5 외부자 검증 원칙"
  - "10-phase1-implementation.md §10.3.2 bkit 재활용"
---

# /sfs handoff

## 의도 (Intent)

PDCA **Do 단계 종료 직후** 각 본부장이 실행하는 **G3 Pre-Handoff Gate**. Worker 산출물(코드·테스트·work-log)이 **Check 단계 (G4) 로 넘어갈 자격이 있는지** 본부장 선에서 1차 검수한다. G3를 통과해야 `/sfs check` 호출이 가능.

§2 원칙 2 (자기검증 금지, 3-Tier Separation Rule) 의 실질적 적용:
- Worker는 자기 산출물을 스스로 통과시키지 못한다 (Tier 1 금지).
- 본부장은 **자기 본부 worker**를 검수할 수 있으나 (Tier 2, 비공식 OK), **본인이 코드를 쓴 경우** 다른 본부장 또는 QA 본부장에게 handoff을 위임해야 함 (Tier 1 위반 방지, self-handoff 금지).
- G4 Check 는 **본부장 + QA 본부장 + CPO 3자** 가 공동 검증 (Tier 3 필수), G3 는 **본부장 1인** 이 담당하는 "빠른 사전 필터".

Do 단계가 여러 worker / 여러 checkpoint 로 나뉜 경우, 각 본부장은 **division 단위 1회** G3 호출로 집계 검수한다.

## 입력 (Input)

### 필수
- `--feature <id>`: PDCA 식별자
- `--division <name>`: 본부 식별자 (dev/qa/design/infra/taxonomy/strategy-pm)

### 선택
- `--skip-gap-preview`: gap-detector preview 생략 (강력 비권장, 증적 없는 handoff가 됨)
- `--delegate-to <lead-id>`: 본인이 직접 코드 작성에 참여한 경우 다른 본부장에게 위임 (원칙 2, self-handoff 금지)
- `--fast-mode`: DoD 체크리스트만 확인 후 PASS (fixtures/docs-only 변경 등 경량 PDCA)

## 절차 (Procedure)

1. **G2 PASS 확인** (Haiku, <2s)
   - `docs/02-design/PDCA-{id}.{division}.gate-g2.yaml` result=pass 확인
   - 해당 design 산출물이 실제 Do 단계에서 참조됐는지 work-log spot-check
2. **Self-handoff 방지 체크** (Haiku, <3s)
   - `docs/03-implementation/PDCA-{id}.{division}.work-log.md` 의 commit author 목록 수집
   - 본부장(caller) 의 identity가 commit author에 포함되면:
     - `--delegate-to` flag 필수 요구 (없으면 FAIL-HARD)
     - delegate 대상이 동일 본부 다른 lead 이거나 QA 본부장이어야 함
3. **DoD 체크리스트 검증** (Haiku)
   - `docs/03-implementation/PDCA-{id}.dod.yaml` 로드
   - 모든 필수 항목 체크 여부 확인
   - 일부 미충족 시 handoff-report에 warning 기록 (`--fast-mode` 에서는 PASS 가능하나 warning은 남음)
4. **Gap Preview** (bkit gap-detector, Sonnet)
   - Design spec vs work-log + 실제 코드 diff 로 **preview gap_score** 산출
   - 이는 G4 의 최종 gap_score 가 아니라, **G3 단계의 빠른 사전 평가** 용도
   - Preview 기준치 (Phase 1): `preview_gap >= 85` (G4의 90 보다 완화 — G3은 "통과 가능성 평가")
5. **Code Quick Lint** (bkit code-analyzer, Sonnet — dev 본부에 한함)
   - critical severity issue 0건 요구
   - medium+ issue는 handoff-report에 목록화 (G4 에서 재평가)
6. **Work-log 완결성 확인** (Sonnet)
   - 모든 checkpoint commit 에 대응하는 work-log entry 존재
   - 블록된 지점 / 의사결정 기록이 누락된 경우 FAIL-FIXABLE
7. **G3 Verdict 산출**
   - PASS 조건: DoD 완료 + preview_gap ≥ 85 + critical-issue 0 + work-log 완결
   - FAIL-FIXABLE: 위 중 하나라도 미충족 (단, 각 항목별 재실행 가이드 제공)
   - FAIL-HARD: self-handoff 감지 시 즉시
8. **L1 이벤트 발행**
   - `l1.handoff.complete` (division, g3_verdict, preview_gap_score, critical_issue_count, dod_completion_pct)

## 산출물 (Output)

- `docs/03-implementation/PDCA-{id}.{division}.gate-g3.yaml` — G3 gate report
  - 필수 필드: `result`, `preview_gap_score`, `dod_completion_pct`, `critical_issue_count`, `delegated_from`(optional), `signed_by`
- `docs/03-implementation/PDCA-{id}.{division}.handoff-report.md` — 핸드오프 사유 본문
  - 필수 섹션: Summary / DoD Status / Gap Preview / Issue List / Known Risks / Approval

## 오류 처리 (Error Handling)

| Error | 원인 | 복구 |
|-------|------|------|
| `E_G2_NOT_PASSED` | Design G2 미통과 | `/sfs design --feature ... --division ...` 선행 |
| `E_SELF_HANDOFF_ATTEMPT` | 본부장 자신이 commit author 인데 `--delegate-to` 없음 | `--delegate-to <다른-lead>` 명시 (원칙 2 self-handoff 금지) |
| `E_DOD_INCOMPLETE` | DoD 필수 항목 미체크 + `--fast-mode` 아님 | Do phase 추가 작업 후 `/sfs do --resume` |
| `E_GAP_PREVIEW_LOW` | preview_gap_score < 85 | FAIL-FIXABLE, work-log 보완 후 재handoff |
| `E_CRITICAL_ISSUE_PRESENT` | code-analyzer critical 1건+ | FAIL-FIXABLE, 코드 수정 후 재handoff |
| `E_WORKLOG_INCOMPLETE` | commit과 work-log entry mismatch | work-log 보강 후 재handoff |
| `E_DELEGATE_INVALID` | `--delegate-to` 대상이 동일인 또는 권한 없음 | 유효한 다른 lead ID 지정 |

## 예시 (Examples)

### 예시 1: Dev 본부 정상 PASS

```bash
$ /sfs handoff --feature new-pricing --division dev
[handoff] G2 PASS 확인 ✓
[handoff] Self-handoff 체크: commit author = worker-dev-01, caller = lead-dev-01 ✓
[handoff] DoD: 8/8 완료 ✓
[handoff] gap-detector preview... preview_gap=88 ✓
[handoff] code-analyzer... 0 critical, 2 minor (향후 리팩토링 목록 기록)
[handoff] Work-log 완결성 ✓ (12 commits ↔ 12 entries)
[handoff] G3 PASS. 다음: /sfs check --feature new-pricing
```

### 예시 2: Self-handoff 시도 → FAIL-HARD

```bash
$ /sfs handoff --feature new-pricing --division dev
[handoff] Self-handoff 체크: commit author 에 lead-dev-01(caller) 포함
[handoff] FAIL-HARD: 원칙 2 위반 (본부장이 직접 구현한 PDCA — Tier 1 self-handoff)
[handoff] 해결: --delegate-to lead-qa-01 (또는 다른 본부장) 으로 위임 필수
```

### 예시 3: Gap preview 낮음 → FAIL-FIXABLE

```bash
$ /sfs handoff --feature notifications --division dev
[handoff] G2 PASS ✓ / DoD 8/9 (1개 warning) / critical 0 OK
[handoff] gap-detector preview... preview_gap=72
[handoff] 미충족 영역:
   - AC-3 (retry on 5xx): 구현 있으나 backoff 누락
   - AC-7 (metrics emit): 코드 상 없음
[handoff] FAIL-FIXABLE. /sfs do --feature notifications --division dev --resume 권장.
```

### 예시 4: Delegation 사용

```bash
$ /sfs handoff --feature fast-lane-search --division dev --delegate-to lead-qa-01
[handoff] 본 handoff는 lead-dev-01 → lead-qa-01 로 위임됨
[handoff] delegated_from: lead-dev-01, signed_by: lead-qa-01
[handoff] G3 PASS (preview_gap=91)
```

## 관련 docs

- `04-pdca-redef.md §4.4.3` — Do phase 종료 조건
- `05-gate-framework.md §5.5` — G3 Pre-Handoff Gate 상세
- `02-design-principles.md §2.2` — 자기검증 금지 (3-Tier Separation Rule), Tier 1 self-handoff 방지
- `02-design-principles.md §2.3` — 본부장 = Gate Operator (위임 원칙)
- `10-phase1-implementation.md §10.3.2` — bkit gap-detector / code-analyzer 재활용
- `appendix/commands/check.md` — 다음 단계 (G4 Check Gate)
- `appendix/commands/escalate.md` — G3 반복 실패 시
