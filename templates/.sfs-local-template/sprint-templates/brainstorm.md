---
phase: brainstorm
gate_number: 2
gate_label: "Gate 2 (Brainstorm)"
gate_id: G0          # legacy storage id
sprint_id: ""        # filled by /sfs start
goal: ""             # filled by /sfs start <goal>
created_at: ""       # filled by /sfs start
last_touched_at: ""  # filled by /sfs brainstorm (auto, ISO8601 + tz)
brainstorm_depth: normal          # simple | normal | hard
brainstorm_depth_source: default  # default | explicit
status: draft        # draft | ready-for-plan | gate2-reviewed
---

# Brainstorm — <sprint title>

> Sprint **Gate 2 — Brainstorm** 산출물.
> 목적은 사용자의 raw 요구사항을 바로 plan 으로 굳히지 않고, 문제/대안/제약/범위를 먼저 정리하는 것.
> `/sfs start` 는 workspace 를 만들고, `/sfs brainstorm` 은 raw 를 §8 에 기록한 뒤
> AI runtime 에서 Solon CEO 가 §1~§7 을 채운다. direct bash 는 capture-only 다.
> 생명주기: 본 문서는 진행 중 workbench 이다. Sprint close 후 핵심 문제/성공상태만
> `report.md` 로 압축되고, raw history 는 `retro.md` / session log 가 담당한다.

---

## §0. AI-Era Fundamentals Gate

`/sfs brainstorm` 은 세 가지 깊이를 가진다. Guide 를 읽지 않아도 `/sfs start` 의 `next:`
line 이 선택지를 보여주며, AI runtime 은 frontmatter 의 `brainstorm_depth` 를 따른다.

- **simple** (`--simple`, alias `--easy`, `--quick`): 기존의 빠른 정리 모드.
  요구사항을 정리하고 빠진 부분을 가볍게 짚으며, 명시한 가정으로 plan 준비가 가능하다.
- **normal** (default): 기본 owner-thinking scaffold. 핵심 결정, 모순, 우선순위,
  성공 기준, feedback loop 중 2~5개를 되물어 사용자가 생각하게 만든다.
- **hard** (`--hard`): product-owner hard training. 의도, 모순, 우선순위, 포기할 것,
  검증 방식, 경계, 용어를 집요하게 캐묻고 중요한 owner decision 이 비어 있으면
  `status: ready-for-plan` 으로 넘기지 않는다.

Depth 선택은 사용자의 사고 부담을 조절하기 위한 것이다. 어느 모드든 raw 요구사항은 아직
plan 계약이 아니며, hard 는 특히 "자동 ㄱㄱ" 대신 사용자의 제품 소유권을 강화한다.

### Shared Understanding Fundamentals

이 gate 는 implement 전용이 아니다. AI 가 좋은 코드베이스/문서베이스에서만 잘 작동한다는
전제 때문에, Gate 2 부터 아래 다섯 가지를 확인한다.

- 공유 design concept: 문제 주체, 현재 pain, 성공 상태, in/out scope.
- 유비쿼터스 랭귀지: 같은 의미로 쓸 핵심 명사/행위자/상태/규칙.
- 작은 feedback loop: test, smoke, preview, review, manual inspection 중 무엇으로 확인할지.
- deep-module seed: 나중에 사람이 통제할 public interface / artifact boundary.
- gray-box delegation: 사용자가 결정할 전략/인터페이스와 AI 가 채울 내부 구현의 경계.

위 항목 중 plan 에 필요한 정보가 비어 있으면 `status: draft` 를 유지하고 1~3개 질문을 먼저 한다.

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

## §7. Gate 2 Checklist

- [ ] raw brief / 대화 메모가 남아 있다
- [ ] 문제와 성공 상태가 한 줄로 설명된다
- [ ] 대안 2개 이상을 비교했다
- [ ] in/out scope seed 가 있다
- [ ] 핵심 용어 / actor / 상태가 같은 단어로 정리됐다
- [ ] 최소 feedback loop 후보가 있다
- [ ] public interface / artifact boundary seed 가 있다
- [ ] 사용자 결정 영역과 AI 위임 영역이 분리됐다
- [ ] generator/evaluator 계약에 넘길 재료가 있다

> 위 checklist 중 plan seed 에 필요한 항목이 비어 있으면 `/sfs plan` 으로 이동하지 않는다.
> 먼저 1~3개 blocking question 에 답하고, 그 답을 본 문서에 반영한다.

## §8. Append Log

`/sfs brainstorm <text>` 또는 `/sfs brainstorm --stdin` 입력이 append 되는 영역.
