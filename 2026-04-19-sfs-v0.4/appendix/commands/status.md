---
command_id: "sfs-status"
command_name: "/sfs status"
version: "1.0.0"
phase: "any"
mode: "common"
operator: "any"         # 누구나 호출 가능 (read-only)
triggers:
  - "status"
  - "상태"
  - "현재 진행 상황"
  - "where am i"
  - "어디까지 했지"
requires_gate_before: []
produces:
  - "(stdout only, 선택적으로 .solon/last-status.md)"
calls_evaluators: []
model_allocation:
  default: "claude-haiku-4-5-20251001"
  opus_allowed: false
cost_budget_usd: 0.05
timeout_ms: 30000
tool_restrictions:
  allowed: ["Read", "Glob", "Grep", "Bash(read-only)"]
  forbidden: ["Write", "Edit", "NotebookEdit"]
audit_fields: ["called_by", "called_at"]
references:
  - "05-gate-framework.md §5.2 Gate Matrix"
  - "08-observability.md §8.3 3-Channel"
---

# /sfs status

## 의도 (Intent)

현재 Solon 프로젝트의 **PDCA / Gate / Sprint 상태를 스냅샷** 으로 출력한다. 읽기 전용이며 비용이 거의 들지 않는다 (Haiku 1회 호출).

주요 용도:
- 중단 후 재개 시 "어디까지 했지?" 파악
- Sprint 중간 점검
- Phase 1 metric 실시간 확인
- Dogfooding 증거 캡처 (체크포인트)

## 입력 (Input)

### 필수
- 없음

### 선택
- `--scope {current|sprint|initiative|project}`: 조회 범위 (기본값: current PDCA)
- `--format {text|json|markdown}`: 출력 형식 (기본값: text)
- `--save`: `.solon/last-status.md` 에 저장
- `--metrics`: Phase 1 secondary 지표 (§10.5.2) 포함

## 절차 (Procedure)

1. **Context 파악** (Haiku, <2s)
   - `.solon/config.yaml` 로드 (install_id, mode, tier_profile)
   - active sprint 감지 (`.solon/sprint-state.yaml`)
   - 현재 PDCA 감지 (in-progress도_state 또는 최근 Gate)
2. **Gate 상태 집계**
   - `docs/01-plan/PDCA-*/gate-g1.yaml` 스캔 → G1 통과 PDCA 목록
   - 동일하게 G2/G3/G4/G5 스캔
   - G-1 (brownfield): `.g-1-signature.yaml` 존재 여부
3. **PDCA 진행도 계산**
   - 각 PDCA별 어디까지 왔는지 (plan / design / do / check / act)
4. **3-Channel 데이터 존재 확인**
   - L1: `aws s3 ls s3://<solon-bucket>/` head 1건 (또는 설정된 backend)
   - L2: `cd docs/ && git log --oneline -5`
   - L3: driver ping (notion: API health check, none: skip)
5. **Metrics 계산** (`--metrics`)
   - Gate pass rate (first attempt)
   - Pattern recurrence rate (H6)
   - Active divisions count
   - 누적 비용 (current month)
6. **출력**

## 산출물 (Output)

### 기본 text 포맷

```
─── Solon Status (2026-04-20 14:23 KST) ───
Install: inst-01HXYZABC (greenfield, minimal tier, notion)
Initiative: pricing-v2   Sprint: S-2026-W17 (day 3/7)

Current PDCA: new-pricing
  ├─ Plan    ✓ G1 PASS (2026-04-19)
  ├─ Design  ✓ G2 PASS (2026-04-20, 3 divisions: design/infra/taxonomy)
  ├─ Do      ⏳ in-progress (dev division, checkpoint 2/~4)
  ├─ Check   — (pending)
  └─ Act     — (pending)

Gate Summary (all PDCAs this sprint):
  G1: 2/2 pass     G2: 2/2 pass     G3: 1/2 pass
  G4: 0/2 (pending)  G5: — (sprint not ended)

3-Channel Observability:
  L1 (S3):     ✓ 47 events this sprint
  L2 (git):    ✓ 12 commits, HEAD=a1b2c3d
  L3 (notion): ✓ last sync 2 min ago

Next Action: /sfs do --feature new-pricing --resume
```

### JSON 포맷 (`--format json`)

```json
{
  "install_id": "inst-01HXYZABC",
  "mode": "greenfield",
  "tier_profile": "minimal",
  "l3_backend": "notion",
  "active_sprint": {
    "id": "S-2026-W17",
    "day": 3,
    "duration_days": 7
  },
  "current_pdca": {
    "id": "new-pricing",
    "phase": "do",
    "gates": {"G1": "pass", "G2": "pass", "G3": null, "G4": null, "G5": null}
  },
  "gate_summary": {...},
  "channels": {...},
  "next_action": "/sfs do --feature new-pricing --resume"
}
```

### With metrics (`--metrics`)

추가 섹션:
```
Phase 1 Metrics (실시간):
  gate_pass_rate_first: 70% (7/10)       target: ≥70% ✓
  pattern_recurrence: 8% (1 of 12)       target: <10% ✓
  active_divisions: 4                     target: ≥4  ✓
  monthly_cost: $187 (day 3/30, 추정 $260) target: <$400 ✓
  h6_pattern_count: 7 (seed 5 + new 2)   target: ≥10 ⏳
```

## 오류 처리 (Error Handling)

| Error | 원인 | 복구 |
|-------|------|------|
| `E_NO_ARCHON` | `.solon/` 없음 | `/sfs install` 제안 |
| `E_CORRUPT_STATE` | sprint-state.yaml 깨짐 | 수동 복구 안내, 기본값 추측 |
| `E_L1_UNREACHABLE` | S3 접근 불가 | L1 status만 "?" 표시, 계속 진행 |
| `E_L3_UNREACHABLE` | driver ping 실패 | L3 status "?" 표시 |

## 예시 (Examples)

### 예시 1: 중단 후 재개

```bash
$ /sfs status
─── Solon Status ─── ...
Current PDCA: new-pricing (Do phase, checkpoint 2/4)
Next Action: /sfs do --feature new-pricing --resume
```

### 예시 2: Sprint 전체 조망

```bash
$ /sfs status --scope sprint
─── Sprint S-2026-W17 Status ───
PDCAs: 2 (new-pricing, payment-revamp)
Gate Pass Rate (first): 70%
Escalations: 1 (CONFLICT in design phase, resolved Option-D)
```

### 예시 3: 메트릭 포함

```bash
$ /sfs status --metrics --save
─── Solon Status ─── ...
Phase 1 Metrics: ... (위 형식)
Saved to .solon/last-status.md
```

## 관련 docs

- `05-gate-framework.md §5.2` — Gate Matrix
- `08-observability.md §8.3` — 3-Channel
- `10-phase1-implementation.md §10.5.2` — Phase 1 metrics 정의
- `appendix/commands/escalate.md` — 문제 발생 시 escalate
