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
> 생명주기: 본 문서는 진행 중 sprint contract 이다. Close 후 최종 scope/AC/결과만
> `report.md` 에 남고, 본 파일은 compact stub 로 줄어든다.

---

## §0. Cross-Phase AI Fundamentals

G1 은 G0 의 raw 요구를 그대로 수용하는 단계가 아니라, AI 가 안전하게 실행할 수 있는 계약으로
바꾸는 단계다. 아래 항목은 implement 뿐 아니라 plan/review/report 에도 계속 전달된다.

- 공유 design concept:
- 유비쿼터스 랭귀지 / glossary:
- feedback loop / evidence source:
- public interface 또는 artifact boundary:
- gray-box delegation: 사용자/CEO 가 직접 결정할 것 vs AI worker 가 채울 내부:

위 항목이 비어 있으면 `brainstorm.md` 로 돌아가 1~3개 blocking question 을 먼저 해결한다.

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
- [ ] G0 의 핵심 질문이 해소됐거나 명시적으로 defer 됨
- [ ] glossary/domain language 가 AC 와 산출물 이름에 반영됨
- [ ] feedback loop 가 `verify by ...` 로 연결됨
- [ ] interface/artifact boundary 와 gray-box 위임 경계가 명시됨

> 본 체크리스트 통과 = `/sfs review --gate G1` 진입 조건. verdict (pass / partial / fail) 는 `review.md` 에 기록.

## §5. Sprint Contract (Generator ↔ Evaluator)

`brainstorm.md` 의 G0 맥락을 기반으로 이번 sprint 의 실행 계약을 명시한다.
역할 흐름은 **CEO → CTO Generator ↔ CPO Evaluator → CTO 구현 → CPO 리뷰 → CTO rework/final confirm → retro** 이다.

- **CEO 요구사항/plan 결정**:
  - 문제 정의:
  - 최종 목표:
  - 이번 sprint 에서 버릴 것:
- **CTO Generator 가 만들 것**:
  - persona: `.sfs-local/personas/cto-generator.md`
  - reasoning_tier: `strategic_high` for architecture/contract; worker 실행은 `execution_standard`
  - model profile source: `.sfs-local/model-profiles.yaml`
  - selected runtime / policy:
  - fallback when unset: current runtime model
  - preferred executor: claude / codex / gemini / custom:
  - implementation worker persona: `.sfs-local/personas/implementation-worker.md`
  - 산출물:
  - 변경 파일/모듈:
  - 구현하지 않을 것:
- **CPO Evaluator 가 검증할 것**:
  - persona: `.sfs-local/personas/cpo-evaluator.md`
  - reasoning_tier: `review_high`
  - preferred executor: codex / gemini / claude / custom:
  - self-validation 방지: 구현한 agent/tool 과 다른 evaluator instance/tool 사용 권장
  - AC 검증 방법:
  - 회귀/위험 체크:
  - 통과/부분통과/실패 기준:
- **CTO ↔ CPO 재작업 계약**:
  - CPO `pass`: 최종 통과 + retro 진입
  - CPO `partial`: 지정된 항목만 CTO 재구현 후 재리뷰
  - CPO `fail`: plan/scope 재검토 또는 구현 재작업
- **사용자 최종 결정이 필요한 지점**:
  -
