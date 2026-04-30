---
phase: brainstorm
gate_id: G0
sprint_id: ""        # filled by /sfs start
goal: ""             # filled by /sfs start <goal>
created_at: ""       # filled by /sfs start
last_touched_at: ""  # filled by /sfs brainstorm (auto, ISO8601 + tz)
status: draft        # draft | ready-for-plan | g0-reviewed
---

# Brainstorm — <sprint title>

> Sprint **G0 — Brainstorm Gate** 산출물.
> 목적은 사용자의 raw 요구사항을 바로 plan 으로 굳히지 않고, 문제/대안/제약/범위를 먼저 정리하는 것.
> `/sfs start` 는 workspace 를 만들고, `/sfs brainstorm` 이 이 문서를 채운다.

---

## §1. Raw Brief / Conversation Notes

사용자가 처음 던진 긴 요구사항, AI 와 대화하며 나온 맥락, 아직 정제되지 않은 생각을 남긴다.

---

## §2. Problem Space

- 누가 이 문제를 겪는가:
- 왜 지금 풀어야 하는가:
- 기존 방식의 불편함:
- 성공하면 어떤 상태가 되는가:

## §3. Constraints / Context

- 기술 제약:
- 배포/운영 제약:
- 시간/비용 제약:
- 사용자 역량/학습 맥락:
- 아직 모르는 것:

## §4. Options

최소 2개 이상. "아무것도 안 한다" 도 유효한 옵션이다.

- **Option A**:
  - 장점:
  - 단점:
  - 버릴/보류할 이유:
- **Option B**:
  - 장점:
  - 단점:
  - 버릴/보류할 이유:
- **Option C**:
  - 장점:
  - 단점:
  - 버릴/보류할 이유:

## §5. Scope Seed

- 이번 sprint 에 넣을 것:
- 이번 sprint 에서 뺄 것:
- 다음 sprint 후보:

## §6. Plan Seed

`/sfs plan` 으로 넘길 때 필요한 최소 재료.

- Goal:
- Acceptance Criteria 후보:
- 주요 risk:
- generator agent 가 만들 산출물:
- evaluator agent 가 검증할 기준:

## §7. G0 Checklist

- [ ] raw brief / 대화 메모가 남아 있다
- [ ] 문제와 성공 상태가 한 줄로 설명된다
- [ ] 대안 2개 이상을 비교했다
- [ ] in/out scope seed 가 있다
- [ ] generator/evaluator 계약에 넘길 재료가 있다

> checklist 가 대체로 채워지면 `/sfs plan` 으로 이동한다.

## §8. Append Log

`/sfs brainstorm <text>` 또는 `/sfs brainstorm --stdin` 입력이 append 되는 영역.
