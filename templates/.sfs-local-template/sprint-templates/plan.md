---
phase: plan
gate_id: G1
sprint_id: ""        # filled by /sfs start
goal: ""             # filled by /sfs start <goal>
created_at: ""       # filled by /sfs start
last_touched_at: ""  # filled by /sfs plan (auto, ISO8601 + tz)
---

# Plan — <sprint title>

> Sprint **G1 — Plan Gate** 산출물. 본 문서의 목적은 **요구사항·AC 의 측정 가능성 확보**.
> 변경 이력은 `.sfs-local/events.jsonl` 의 `phase_change` / `gate_review` event 로 추적.
> SSoT: `05-gate-framework.md §5.1` (Gate 매트릭스).
> 입력 기준: 같은 sprint 의 `brainstorm.md` (G0) 를 먼저 읽고 작성한다.

---

## §1. 요구사항 (Requirements)

본 sprint 가 풀어야 할 문제 / 사용자 니즈 / 비즈니스 입력. 1줄 요약 + 배경 컨텍스트.

- [ ] R1: …
- [ ] R2: …

## §2. Acceptance Criteria (AC, 측정 가능)

각 요구사항에 대해 **측정 가능한 통과 조건** 정의. "되면 안 되는 것" (anti-AC) 도 명시.

- [ ] AC1: <조건> — verify by <how>
- [ ] AC2: …

## §3. 범위 (Scope)

- **In scope**: 본 sprint 안에서 처리할 것.
- **Out of scope**: 의도적으로 제외 (다음 sprint 또는 별도 WU).
- **Dependencies**: 다른 sprint / 외부 리소스 / 결정 대기 (W10 후보).

## §4. G1 Gate 자기 점검

- [ ] R/AC 가 측정 가능 (정량 또는 binary)
- [ ] 범위가 sprint 1개 안에서 닫힘
- [ ] 의존성 / 결정 대기 항목이 명시됨

> 본 체크리스트 통과 = `/sfs review --gate G1` 진입 조건. verdict (pass / partial / fail) 는 `review.md` 에 기록.

## §5. Sprint Contract (Generator ↔ Evaluator)

`brainstorm.md` 의 G0 맥락을 기반으로 이번 sprint 의 실행 계약을 명시한다.

- **Generator agent 가 만들 것**:
  - 산출물:
  - 변경 파일/모듈:
  - 구현하지 않을 것:
- **Evaluator agent 가 검증할 것**:
  - AC 검증 방법:
  - 회귀/위험 체크:
  - 통과/부분통과/실패 기준:
- **사용자 최종 결정이 필요한 지점**:
  -
