---
phase: review
gate_id: ""          # one of G2, G3, G4 (set by /sfs review --gate <id>) — 미설정 시 빈 문자열
sprint_id: "sfs-doc-tidy-release-notes"
goal: "SFS doc tidy command + update awareness + release notes policy"
created_at: "2026-05-01T18:27:08+09:00"
last_touched_at: ""  # filled by /sfs review (auto, ISO8601 + tz)
evaluator_role: CPO
evaluator_persona: ".sfs-local/personas/cpo-evaluator.md"
evaluator_executor: ""  # filled by /sfs review --executor <profile>
generator_executor: ""  # optional, filled by /sfs review --generator <profile>
---

# Review — <sprint title>

> Sprint **CPO Evaluator review** 산출물. G2/G3/G4 중 하나의 gate 에 대한 verdict 기록.
> 각 gate review 마다 `.sfs-local/events.jsonl` 의 `review_open` event append.
> SSoT: `gates.md §1` (7-Gate enum) + `05-gate-framework.md §5.1` (매트릭스).
> 동일 sprint 안에서 G2/G3/G4 review 가 여러 번 발생할 경우 본 파일에 §2 섹션을 추가 append.
> 자체검증 방지: CTO Generator 와 CPO Evaluator 는 같은 산출물을 같은 agent instance 가 통과시키지 않는다.
> 생명주기: review 중에는 verdict evidence 를 기록하되, close 후 최종 verdict/action 만
> `report.md` 에 남기고 본 파일 원문은 archive 로 이동해 보존한다.

---

## §1. 대상 Gate

- **gate_id**: G2 / G3 / G4 (해당 review 시점에서 1개로 고정)
- **scope**: 본 review 가 평가하는 산출물 / 변경 범위 / 검증 방법
- **trigger**: `/sfs review --gate <id>` 호출 시각
- **CPO persona**: `.sfs-local/personas/cpo-evaluator.md`
- **review executor/tool**: codex / gemini / claude / custom
- **generator executor/tool**: CTO 구현에 사용한 tool

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

- pass → CTO 최종 확인 후 G5 retro 진입
- partial → CPO 가 지정한 항목만 CTO 재구현 후 재리뷰
- fail → CTO 재구현 또는 CEO plan/scope 재검토

## §5. CTO 응답 / 재구현 확인

- **CTO 확인**: pass / rework-started / plan-escalation
- **반영한 CPO finding**:
- **재구현 변경 파일/모듈**:
- **재리뷰 필요 여부**:

## §6. CPO Review Invocation Log

`/sfs review` 호출 시 CPO evaluator prompt 가 append 된다.
