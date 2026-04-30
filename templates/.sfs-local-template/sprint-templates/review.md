---
phase: review
gate_id: ""          # one of G2, G3, G4 (set by /sfs review --gate <id>) — 미설정 시 빈 문자열
sprint_id: ""        # filled by /sfs start
goal: ""             # filled by /sfs start <goal>
created_at: ""       # filled by /sfs start
last_touched_at: ""  # filled by /sfs review (auto, ISO8601 + tz)
---

# Review — <sprint title>

> Sprint **review** 단계 산출물. G2/G3/G4 중 하나의 gate 에 대한 verdict 기록.
> 각 gate review 마다 `.sfs-local/events.jsonl` 의 `gate_review` event append.
> SSoT: `gates.md §1` (7-Gate enum) + `05-gate-framework.md §5.1` (매트릭스).
> 동일 sprint 안에서 G2/G3/G4 review 가 여러 번 발생할 경우 본 파일에 §2 섹션을 추가 append.

---

## §1. 대상 Gate

- **gate_id**: G2 / G3 / G4 (해당 review 시점에서 1개로 고정)
- **scope**: 본 review 가 평가하는 산출물 / 변경 범위 / 검증 방법
- **trigger**: `/sfs review --gate <id>` 호출 시각

## §2. 평가 항목

### G2 — Design Gate (해당 시)

- [ ] 설계 완성도 (interface 명세, 데이터 모델, 동작 흐름)
- [ ] 위험 요소 식별 / 완화 plan
- [ ] AC 와의 연결 (Plan G1 산출물 참조)

### G3 — Pre-Handoff Gate (해당 시, **binary**)

- [ ] 산출물 self-contained
- [ ] 핸드오프 받을 사람이 추가 컨텍스트 없이 진행 가능
- [ ] verdict ∈ { pass, fail } only (partial 미사용 — `gates.md §2`)

### G4 — Check Gate (해당 시, 5-Axis CPO)

- [ ] 설계 vs 구현 gap (정량)
- [ ] 5-Axis (사용자가치 / 안정성 / 일정 / 비용 / 학습) 점수
- [ ] partial 시 잔여 작업 → 다음 sprint 또는 별도 WU 로 분기

## §3. Verdict

- **verdict**: pass / partial / fail (G3 만 pass/fail)
- **근거 (정량)**: …
- **근거 (정성)**: …
- **partial 시 잔여 항목**: …

## §4. 다음 액션

- pass → 다음 phase 진입 (Do / G3 후 Handoff / G4 후 Retro)
- partial → Do 보강 또는 별도 WU 분기
- fail → root cause 회귀 (Plan 재검토 또는 Design 재검토)
