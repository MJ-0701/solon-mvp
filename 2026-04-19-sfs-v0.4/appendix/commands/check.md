---
command_id: "sfs-check"
command_name: "/sfs check"
version: "1.0.0"
phase: "check"
mode: "common"
operator: "quality/qa/lead"    # QA 본부장 + CPO 공동
co_operator: "strategy/cpo"
triggers:
  - "check"
  - "검증"
  - "qa"
  - "quality gate"
  - "G4"
  - "verify"
requires_gate_before:
  - "G3"
produces:
  - "docs/04-qa/PDCA-{id}.check-report.md"
  - "docs/04-qa/PDCA-{id}.gate-g4.yaml"
  - "docs/04-qa/PDCA-{id}.5-axis.yaml"
calls_evaluators:
  - "gap-detector"                        # bkit 재활용, Dev 본부 G4
  - "qa-monitor"                          # bkit 재활용
  - "code-analyzer"                       # bkit 재활용
  - "cost-estimator"                      # 실측 대비 검증
  - "cpo-5axis"                           # CPO Opus 5-Axis
model_allocation:
  worker_default: "claude-sonnet-4-6"      # 보조 분석
  lead_default: "claude-sonnet-4-6"        # QA 본부장
  cpo_eval: "claude-opus-4-6"              # CPO 5-Axis는 Opus 필수
  opus_allowed: true                        # CPO Axis 호출 한정
cost_budget_usd: 1.50
timeout_ms: 600000
tool_restrictions:
  allowed: ["Read", "Glob", "Grep", "Bash(test-execution)", "Task"]
  forbidden: ["Write(on src/)", "Edit(on src/)"]   # check는 읽기/테스트만
audit_fields: ["called_by", "called_at", "pdca_id", "sprint_id", "gap_score", "5axis_score"]
references:
  - "04-pdca-redef.md §4.4.4 Check phase"
  - "05-gate-framework.md §5.6 G4 Check Gate"
  - "09-differentiation.md §9.10 Phase 1 metrics"
  - "02-design-principles.md §2.10 human-final-filter"
---

# /sfs check

## 의도 (Intent)

PDCA 의 **Check 단계** 를 실행한다. Do 단계 산출물 (코드 + 테스트) 의 **품질을 외부 evaluator로 검증** 하고, G4 Check Gate 를 통과시킨다. G4는 다음 두 축의 **가중 합산** 으로 판정:

```
G4 score = gap-detector (Gap × 0.4) + CPO 5-Axis (평균 × 0.6)
```

본 command는 **quality/qa/lead (QA 본부장)** 와 **strategy/cpo (CPO)** 가 공동 오퍼레이터. QA 본부장은 Gap / 기능 정확성 축을, CPO는 User-Outcome / Value-Fit / Soundness / Future-Proof / Integrity 5축을 책임진다.

§2 원칙 10 (human-final-filter) 적용: G4 PASS 후에도 사용자가 마지막 확인 체크박스를 통과시켜야 Act phase로 이동 가능 (--yes 시 L1에 `auto_approved: true` 기록).

## 입력 (Input)

### 필수
- `--feature <id>`: PDCA 식별자

### 선택
- `--skip-5axis`: CPO 5-Axis 생략 (비권장, design 본부 산출물에 필수)
- `--skip-gap`: gap-detector 생략 (mock 테스트에만)
- `--evidence-dir <path>`: qa-monitor가 읽을 실행 로그 디렉토리

## 절차 (Procedure)

1. **G3 PASS 확인** (Haiku, <3s)
   - `docs/03-implementation/PDCA-{id}.gate-g3.yaml` result=pass 확인
   - DoD 완료 확인
2. **Gap Analysis** (bkit gap-detector, Sonnet)
   - Design spec vs 실제 구현 gap 계산
   - 출력: gap_score (0~100), 미충족 AC 목록
   - Phase 1 Pass 기준: `gap_score >= 90`
3. **Code Analysis** (bkit code-analyzer, Sonnet)
   - 보안 / 성능 / 아키텍처 준수 분석
   - 출력: issue list (severity별)
4. **QA Evidence Collection** (bkit qa-monitor, Sonnet + Bash)
   - 테스트 실행 로그 수집 (zero-script QA 방식)
   - 출력: test coverage, pass rate, defect list
5. **Cost Verification** (cost-estimator, Opus)
   - Design 단계의 cost estimate vs Do 단계 실측
   - Phase 1 허용 편차: 1.5배 이내 (seed pattern 004)
6. **CPO 5-Axis 평가** (cpo-agent, Opus)
   - User-Outcome / Value-Fit / Soundness / Future-Proof / Integrity
   - 각 축 1~5점, 평균 4.0 이상 PASS
7. **G4 집계** (via `/sfs gate g4 <feature>`)
   - `G4 score = gap × 0.4 + 5axis × 0.6` (둘 다 100점 scale로 정규화)
   - PASS 기준: `G4 score >= 85`
8. **Human-final-filter 적용** (원칙 10)
   - G4 PASS 후 사용자에게 6개 체크박스 제시 (spec 준수 / cost 허용 / 보안 OK / UX OK / 배포 준비 완료 / 문서 반영)
   - `--yes` flag 시 자동 통과 + `auto_approved: true` 기록
9. **L1 이벤트 발행**
   - `l1.check.complete` (gap_score, 5axis_score, g4_score, human_approved)

## 산출물 (Output)

- `docs/04-qa/PDCA-{id}.check-report.md` — Check phase 통합 보고서
- `docs/04-qa/PDCA-{id}.gate-g4.yaml` — G4 gate report (gap + 5axis + g4_score)
- `docs/04-qa/PDCA-{id}.5-axis.yaml` — CPO 5-Axis 세부 scoring

## 오류 처리 (Error Handling)

| Error | 원인 | 복구 |
|-------|------|------|
| `E_G3_NOT_PASSED` | G3 Pre-Handoff Gate 미통과 | `/sfs handoff --feature ...` 선행 |
| `E_GAP_TOO_LOW` | gap_score < 70 | FAIL-HARD, Case-α Escalate (§6.3) |
| `E_GAP_BORDERLINE` | 70 ≤ gap_score < 90 | FAIL-FIXABLE, 수정 후 재시도 |
| `E_5AXIS_BELOW_THRESHOLD` | CPO 평균 < 4.0 | FAIL-FIXABLE |
| `E_HUMAN_APPROVAL_TIMEOUT` | 체크박스 24h 미응답 | STALL, `/sfs escalate` 안내 |
| `E_COST_DEVIATION_HIGH` | 실측이 estimate의 1.5배 초과 | FAIL-FIXABLE + seed-004 패턴 기록 |

## 예시 (Examples)

### 예시 1: 정상 PASS

```bash
$ /sfs check --feature new-pricing
[check] G3 PASS 확인 ✓
[check] gap-detector 실행... gap_score=93 ✓
[check] code-analyzer... 0 critical, 2 minor
[check] qa-monitor... coverage 87%, 42 tests pass
[check] cost-estimator 실측 대비 1.1x ✓
[check] CPO 5-Axis (Opus)... 평균 4.3/5
[check] G4 score = 93*0.4 + 86*0.6 = 88.8 → PASS
[check] human-final-filter: 6개 체크박스 확인 필요
> 모두 OK입니까? [y/n]: y
[check] 완료. 다음: /sfs act --feature new-pricing
```

### 예시 2: Gap borderline → FAIL-FIXABLE

```bash
$ /sfs check --feature new-pricing
...
[check] gap-detector... gap_score=78
[check] 미충족 AC: AC-2 (search-highlight missing), AC-5 (e2e timeout)
[check] FAIL-FIXABLE. /sfs do --resume 으로 보완 권장.
```

### 예시 3: Auto-approval (--yes)

```bash
$ /sfs check --feature new-pricing --yes
...
[check] G4 PASS (score 88.8)
[check] human-final-filter: --yes flag → auto_approved=true
[check] WARNING: L1 event에 auto_approved flag 기록됨. 원칙 10 정신 권장 위반.
```

## 관련 docs

- `04-pdca-redef.md §4.4.4` — Check phase 정의
- `05-gate-framework.md §5.6` — G4 Check Gate 상세 (수식)
- `02-design-principles.md §2.10` — human-final-filter (원칙 10)
- `09-differentiation.md §9.10` — Phase 1 metric targets
- `appendix/commands/act.md` — 다음 단계
