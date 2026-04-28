---
command_id: "sfs-retro"
command_name: "/sfs retro"
version: "1.0.0"
phase: "sprint-close"              # Sprint 종료 (개별 PDCA 의 Act 와 구분)
mode: "common"
operator: "strategy/ceo"           # CEO 주관, Strategy-PM 본부장 co-operator
co_operator: "strategy-pm/lead"
triggers:
  - "retro"
  - "retrospective"
  - "sprint retro"
  - "스프린트 회고"
  - "회고"
  - "G5"
  - "sprint close"
  - "sprint 종료"
requires_gate_before:
  - "G4"                             # Sprint 내 모든 PDCA 가 G4 통과 (또는 명시적 deferred)
produces:
  - "docs/09-learnings/Sprint-{sprint-id}.retro.md"
  - "docs/00-governance/Sprint-{sprint-id}.gate-g5.yaml"
  - "docs/09-learnings/Sprint-{sprint-id}.metrics.yaml"
calls_evaluators:
  - "sprint-retro-analyzer"          # Opus, Sprint 전반 분석
  - "cost-estimator"                  # Sprint 누적 비용 집계
  - "pattern-miner"                   # H6 seed pattern 승격 후보 추출
model_allocation:
  default: "claude-opus-4-6"         # CEO 전략 회고 + 패턴 추출 Opus 필수
  helper: "claude-sonnet-4-6"        # Strategy-PM 본부장 집계
  opus_allowed: true
cost_budget_usd: 3.00                 # Sprint 1회, 상대적으로 고비용 허용
timeout_ms: 1200000                   # 20분
tool_restrictions:
  allowed: ["Read", "Write", "Edit", "Glob", "Grep", "Task", "Bash(read-only)"]
  forbidden: ["Bash(destructive)"]
audit_fields: ["called_by", "called_at", "sprint_id", "initiative_id", "pdca_count", "g5_verdict", "promoted_patterns"]
references:
  - "04-pdca-redef.md §4.5 Sprint 단위 종료"
  - "05-gate-framework.md §5.7 G5 Sprint-Retro Gate"
  - "06-escalate-plan.md §6.7 H6 Self-Learning"
  - "10-phase1-implementation.md §10.5 Phase 1 metrics"
  - "02-design-principles.md §2.9 brainstorm-before-plan (다음 Initiative 연결)"
---

# /sfs retro

## 의도 (Intent)

Sprint 의 **G5 Sprint-Retro Gate** 를 실행한다. Sprint 내 여러 PDCA 의 Act 단계 산출물(learnings)을 **Sprint 레벨로 집계·분석** 하고, 다음 Sprint 또는 다음 Initiative로 이어지는 전략 입력을 만든다.

G4 (개별 PDCA Check) 와의 구분:
- **G4**: PDCA 1개의 "구현 품질" 게이트. Gap + 5-Axis.
- **G5**: Sprint 전체의 "의사결정 품질" 게이트. 패턴·메트릭·전략 정합성.

§2 원칙 9 (brainstorm-before-plan) 와의 연결:
- G5 가 **다음 Initiative 의 G0 brainstorm 입력** 을 공급. Sprint retro 에서 발견된 "미해결 문제 / 다음에 도전할 주제" 가 다음 G0 의 inspiration 이 됨.

오퍼레이터는 **CEO (사용자) 주관** 이며, **Strategy-PM 본부장이 사전 집계 작업** 을 수행한다. CEO 는 집계 결과를 읽고 **전략적 판단**만 하므로 Opus 호출은 sprint-retro-analyzer + pattern-miner 2곳에 제한.

## 입력 (Input)

### 필수
- `--sprint <id>`: Sprint 식별자 (예: `S-2026-W17`)

### 선택
- `--defer-pdca <id>`: G4 미통과한 PDCA를 의도적으로 다음 Sprint 로 이월 (retro 시 블록하지 않음)
- `--promote-seed`: pattern-miner가 찾은 신규 seed 후보를 자동 승격 (기본 off — 수동 검토 권장)
- `--link-to-initiative <id>`: 다음 Initiative 의 G0 brainstorm 에 본 retro 를 `--from-inspiration` 으로 자동 연결
- `--metrics-only`: 메트릭 집계만 수행 (CEO 회고 파트 skip, 긴급 점검용)

## 절차 (Procedure)

1. **G4 집계 확인** (Haiku, <5s)
   - Sprint 에 속한 모든 PDCA 의 gate-g4.yaml 스캔
   - 모든 PDCA 가 `result=pass` 또는 `--defer-pdca` 명시됐는지 확인
   - 위반 시 FAIL-HARD (미통과 PDCA 목록 표시)
2. **Sprint 산출물 집계** (Sonnet, Strategy-PM 본부장)
   - 각 PDCA 의 `docs/09-learnings/PDCA-*.learnings.md` 병합
   - `docs/04-qa/PDCA-*.5-axis.yaml` 5축 점수 sprint 평균 계산
   - `docs/05-escalation/*.md` 이 있다면 escalate 사례 요약
   - L1 이벤트 덤프 from S3 (sprint 기간 전체)
3. **Metrics 계산** (cost-estimator, Sonnet)
   - Sprint 총 비용 (LLM + 인프라 추정)
   - Gate pass rate (first attempt) across PDCAs
   - Cycle time per PDCA (plan → act)
   - Pattern recurrence rate (H6 seed match 빈도)
   - `docs/09-learnings/Sprint-{id}.metrics.yaml` 저장
4. **Sprint-Retro Analyzer 실행** (sprint-retro-analyzer, Opus)
   - Input: 병합된 learnings + metrics + escalate 요약
   - Output: 5 섹션 분석
     - Sprint Goals Review (Plan vs Reality)
     - Cross-PDCA Themes (반복되는 블로커)
     - System-Level Improvements (divisions/gates/seed 조정 제안)
     - Team Load Signals (각 본부 소진도 추정)
     - Next Sprint Seeds (다음 Sprint 초점 2~3개)
5. **Pattern Miner 실행** (pattern-miner, Opus)
   - Input: 본 Sprint 의 learnings + escalate + 기존 `h6-live-patterns.yaml`
   - Output: 신규 seed 승격 후보 목록 (각 후보: 출현 횟수, 영향 범위, 유사 seed)
   - `--promote-seed` flag 에 따라 자동 merge 또는 수동 검토 queue
6. **CEO Retro Narrative 작성** (Opus, CEO)
   - Analyzer + Pattern 결과를 입력으로 CEO 관점의 서술형 회고 작성
   - 필수 4 질문: What went well / What didn't / What we learned / What we'll try next
   - Initiative-level pivot 여부 판단 (이 Sprint 결과로 현 Initiative 의 방향을 유지/조정/중단)
7. **G5 Verdict 산출**
   - PASS 조건: retro 문서 6 섹션 완결 + metrics yaml 존재 + pattern-miner 결과 기록 + 다음 Sprint 시드 ≥1
   - FAIL-FIXABLE: 섹션 누락 (보강 후 재실행)
   - FAIL-HARD: `--metrics-only` 외 상황에서 CEO narrative 누락
8. **L1 이벤트 발행**
   - `l1.gate.g5.complete` (sprint_id, pdca_count, promoted_patterns, cost_total, pass_rate_first)
9. **다음 Initiative 연결** (`--link-to-initiative`)
   - 지정 시 `docs/00-governance/Initiative-{id}/brainstorm-seed.md` 에 본 retro 링크 기록
   - 실제 brainstorm 은 `/sfs brainstorm` 호출 시 수행

## 산출물 (Output)

- `docs/09-learnings/Sprint-{sprint-id}.retro.md` — Sprint 회고 본문
  - 필수 섹션: Goals Review / Cross-PDCA Themes / System Improvements / Team Load / CEO Narrative / Next Sprint Seeds
- `docs/00-governance/Sprint-{sprint-id}.gate-g5.yaml` — G5 gate report
- `docs/09-learnings/Sprint-{sprint-id}.metrics.yaml` — Phase 1 metrics snapshot

## 오류 처리 (Error Handling)

| Error | 원인 | 복구 |
|-------|------|------|
| `E_PDCA_NOT_CLOSED` | Sprint 내 PDCA 가 G4 미통과 + `--defer-pdca` 없음 | `/sfs check --feature ...` 완료 또는 `--defer-pdca <id>` 명시 |
| `E_SPRINT_NOT_FOUND` | sprint-state.yaml 에 해당 sprint 없음 | sprint ID 오타 확인 |
| `E_LEARNINGS_MISSING` | 어느 PDCA 에 learnings.md 없음 | `/sfs act --feature ...` 선행 |
| `E_OPUS_BUDGET_EXCEEDED` | cost_budget_usd 3.00 초과 예상 | Opus 호출을 sprint-retro-analyzer 1회로 축소 |
| `E_PATTERN_MERGE_CONFLICT` | 승격 대상 seed 가 기존 seed 와 중복 | `--promote-seed` off 유지, 수동 merge |
| `E_NO_NEXT_SEEDS` | Next Sprint Seeds 섹션 공란 | 최소 1개 seed 기록 요구 (FAIL-FIXABLE) |

## 예시 (Examples)

### 예시 1: Sprint 정상 종료

```bash
$ /sfs retro --sprint S-2026-W17
[retro] Sprint S-2026-W17: PDCAs=2 (new-pricing, payment-revamp)
[retro] G4 집계: 2/2 PASS ✓
[retro] Sprint 산출물 집계 (Sonnet)... learnings 16 insights 병합
[retro] Metrics 계산:
   - Gate pass rate (first): 70% (7/10) ✓
   - Cycle time: new-pricing 4d, payment-revamp 5d
   - Cost total: $287 (target <$400) ✓
[retro] sprint-retro-analyzer (Opus)... 5 섹션 생성
[retro] pattern-miner (Opus)... 신규 후보 1개 (seed-006 push-token-silent-fail)
[retro] CEO Narrative 작성 (Opus)...
[retro] Next Sprint Seeds: 2개 (subscription-invoicing, admin-audit-ui)
[retro] G5 PASS. 다음: /sfs brainstorm --initiative ... 또는 /sfs plan --feature ...
```

### 예시 2: G4 미통과 PDCA deferred

```bash
$ /sfs retro --sprint S-2026-W17 --defer-pdca payment-revamp
[retro] Sprint S-2026-W17: PDCAs=2
[retro] G4 집계: 1/2 PASS, payment-revamp deferred → 다음 Sprint 로 이월
[retro] 이월 조건 기록 (E_GAP_BORDERLINE 로 carry)
...
[retro] G5 PASS. payment-revamp 는 S-2026-W18 PDCA 리스트에 자동 추가됨.
```

### 예시 3: 다음 Initiative 로 연결

```bash
$ /sfs retro --sprint S-2026-W17 --link-to-initiative subscription-v1
[retro] ... 정상 절차 ...
[retro] docs/00-governance/Initiative-subscription-v1/brainstorm-seed.md 에 링크 기록 ✓
[retro] 다음 액션: /sfs brainstorm --initiative subscription-v1 --from-inspiration docs/09-learnings/Sprint-S-2026-W17.retro.md
```

### 예시 4: Metrics-only (긴급 점검)

```bash
$ /sfs retro --sprint S-2026-W17 --metrics-only
[retro] metrics-only 모드 — analyzer/narrative/pattern-miner skip
[retro] metrics.yaml 갱신 ✓
[retro] NOTE: 이 호출은 G5 PASS 로 카운트되지 않음. 정식 retro 필요 시 --metrics-only 제거 후 재실행.
```

## 관련 docs

- `04-pdca-redef.md §4.5` — Sprint 단위 종료 정의
- `05-gate-framework.md §5.7` — G5 Sprint-Retro Gate 상세
- `06-escalate-plan.md §6.7` — H6 Self-Learning, seed 승격 기준
- `10-phase1-implementation.md §10.5` — Phase 1 metric targets
- `appendix/commands/brainstorm.md` — 다음 Initiative 시작 (연결)
- `appendix/commands/act.md` — 개별 PDCA 학습 (retro 입력)
