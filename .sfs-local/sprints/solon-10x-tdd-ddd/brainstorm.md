---
phase: brainstorm
gate_id: G0
sprint_id: "solon-10x-tdd-ddd"
goal: "Solon 10x value planning: non-developer productivity + TDD/DDD AI coding workflow"
created_at: "2026-04-30T23:07:33+09:00"
last_touched_at: 2026-04-30T23:07:50+09:00
status: ready-for-plan        # draft | ready-for-plan | g0-reviewed
---

# Brainstorm — Solon 10x Value + TDD/DDD Coding Workflow

> Sprint **G0 — Brainstorm Gate** 산출물.
> 목적은 사용자의 raw 요구사항을 바로 plan 으로 굳히지 않고, 문제/대안/제약/범위를 먼저 정리하는 것.
> `/sfs start` 는 workspace 를 만들고, `/sfs brainstorm` 은 raw 를 §8 에 기록한 뒤
> AI runtime 에서 Solon CEO 가 §1~§7 을 채운다. direct bash 는 capture-only 다.

---

## §1. Raw Brief / Conversation Notes

Soongsil consumer 작업은 사용자가 별도 터미널 Claude 로 처리 중이므로 이번 sprint 범위에서 제외한다.

이번 sprint 의 원자료는 사용자가 요약한 AI coding failure 영상과 Solon 제품 방향성이다. 핵심 주장은 다음과 같다.

- AI coding 은 코드를 싸게 만드는 것이 아니라, 나쁜 코드베이스에서는 entropy 를 더 빠르게 키운다.
- AI 는 전체 시스템 디자인보다 눈앞의 변경에 집중하므로, 공유된 design concept / domain language / feedback loop / code regularity 가 없으면 결과물이 점점 망가진다.
- Spec-to-code 반복은 처음에는 그럴듯하지만, 두세 번 반복되면 구조가 흐트러지고 변경 비용이 증가한다.
- DDD 는 사람과 AI 가 같은 단어로 말하게 하는 장치이고, TDD 는 AI 를 작은 단위의 검증 가능한 루프로 묶는 장치다.
- Solon 의 10x 가치는 "AI가 코드를 많이 쓰게 함"이 아니라, 비개발자의 모호한 생각을 검증 가능한 work contract 로 바꾸고, 개발자는 그 contract 안에서 TDD/DDD 기반으로 안전하게 구현하게 만드는 데 있다.

---

## §2. Problem Space

- 누가 이 문제를 겪는가:
  - 비개발자 founder / 기획자 / 도메인 전문가: 만들고 싶은 것은 있지만, AI 에게 무엇을 어떻게 맡겨야 하는지 모른다.
  - AI coding 을 쓰는 개발자: 빠르게 코드를 만들 수는 있지만, 반복 변경 후 코드베이스가 무너지는 문제를 겪는다.
  - Solon product 사용자: brainstorm/plan/review/decision/retro 가 실제 개발 품질과 어떻게 연결되는지 명확한 onboarding 이 필요하다.
- 왜 지금 풀어야 하는가:
  - Solon Product 가 단순 SFS workflow 를 넘어 "AI-ready work/code operating system" 으로 포지셔닝되어야 한다.
  - 초기 사용자에게 10x 가치가 설명 가능한 형태로 보여야 onboarding 이 가능하다.
- 기존 방식의 불편함:
  - prompt/spec 만 던지고 code 를 다시 생성하는 방식은 공유 설계 없이 local patch 만 누적한다.
  - domain term 이 정리되지 않으면 AI 와 사람이 같은 단어를 다르게 이해한다.
  - test contract 없이 구현하면 작동 여부 검증이 늦고, 실패 원인도 커진다.
  - codebase rule 이 없으면 AI 는 기존 구조를 따르지 못하고 context explosion 을 일으킨다.
- 성공하면 어떤 상태가 되는가:
  - 비개발자는 아이디어를 Design Concept, Domain Language, Acceptance Criteria, Work Unit 으로 변환할 수 있다.
  - 개발자는 Solon coding mode 에서 DDD/TDD 기본 루프를 따라 구현한다.
  - Solon 의 마케팅/제품 문구가 "AI coding tool" 이 아니라 "AI-safe execution system" 으로 정리된다.

## §3. Constraints / Context

- 기술 제약:
  - 현재 Solon 은 `.sfs-local` adapter + templates + docs 중심이므로, 이번 sprint 는 대형 UI 구현보다 product surface/docs/templates/skill prompts 개선이 현실적이다.
  - 기존 release/self-install 파일과 root self-install untracked 파일을 섞으면 안 된다.
- 배포/운영 제약:
  - Soongsil consumer 작업은 별도 진행 중이므로 본 sprint 산출물은 Solon product/docset 기준으로 분리한다.
  - git commit/push 는 사용자 manual 정책을 유지한다.
- 시간/비용 제약:
  - 먼저 1 sprint 에서 "10x value product contract" 를 만들고, 그 다음 release 후보로 내린다.
  - 구현은 작은 artifact 단위로 시작해야 한다.
- 사용자 역량/학습 맥락:
  - 사용자는 Solon 을 OSS/product 방향으로 만들고 있으며, 비개발자에게도 설명 가능한 제품 가치가 필요하다.
  - TDD/DDD 는 거창한 방법론으로 팔기보다 "AI가 망치지 않게 하는 기본 안전장치"로 설명해야 한다.
- 아직 모르는 것:
  - 첫 외부 사용자의 persona 를 founder/기획자/개발자 중 어디에 먼저 맞출지.
  - 이번 산출물을 product docs 로 바로 release 할지, 내부 planning artifact 로 먼저 둘지.

## §4. Options

최소 2개 이상. "아무것도 안 한다" 도 유효한 옵션이다.

- **Option A: Marketing-only 10x narrative**
  - 장점: 빠르게 README/landing copy 를 만들 수 있다.
  - 단점: 제품 루프와 연결되지 않으면 허공의 문구가 된다.
  - 버릴/보류할 이유: 지금 문제는 slogan 보다 실행 contract 가 필요하다.
- **Option B: Product-contract MVP**
  - 장점: 10x 가치, 비개발자 productivity, DDD/TDD coding workflow 를 하나의 sprint contract 로 묶을 수 있다.
  - 단점: 문서/템플릿/adapter 중 어디까지 구현할지 scope 관리가 필요하다.
  - 채택 이유: 이번 sprint 의 minimal 구현으로 적합하다.
- **Option C: Full coding-mode implementation**
  - 장점: `/sfs code` 같은 명령까지 만들면 제품성이 선명하다.
  - 단점: 지금 바로 들어가기엔 scope 가 크고, 기존 `/sfs loop`/review 흐름과 충돌 가능성이 있다.
  - 버릴/보류할 이유: 다음 sprint 후보로 둔다.

## §5. Scope Seed

- 이번 sprint 에 넣을 것:
  - Solon 10x value contract 작성.
  - 비개발자 생산성 루프 정의: fuzzy idea -> design concept -> domain language -> acceptance criteria -> work units.
  - Solon coding mode 원칙 정의: codebase analysis -> DDD-lite glossary -> TDD contract -> small implementation slices -> review gate.
  - MVP artifact 1개 이상 구현: product doc/template/prompt 중 하나에 10x/TDD/DDD 루프 반영.
- 이번 sprint 에서 뺄 것:
  - Soongsil consumer plan 수정.
  - `/sfs code` 신규 명령 전체 구현.
  - 대형 UI/서비스 구현.
  - TDD/DDD 전체 교재 작성.
- 다음 sprint 후보:
  - `/sfs code` 또는 `/sfs implement` command 설계.
  - Codebase Regularity Scanner.
  - Domain Language Builder template.
  - TDD Contract Builder template.
  - 외부 onboarding GUIDE 에 10x value path 반영.

## §6. Plan Seed

`/sfs plan` 으로 넘길 때 필요한 최소 재료.

- Goal:
  - Solon 의 10x value proposition 을 비개발자 productivity 와 TDD/DDD AI coding workflow 로 구체화하고, 즉시 구현 가능한 product artifact 로 내린다.
- Acceptance Criteria 후보:
  - AC1: 10x value 가 한 문장/한 paragraph/상세 루프로 각각 설명된다.
  - AC2: 비개발자 workflow 와 개발자 coding workflow 가 분리되면서도 하나의 Solon loop 로 연결된다.
  - AC3: DDD/TDD 가 optional buzzword 가 아니라 AI entropy 방지 장치로 정의된다.
  - AC4: 이번 sprint 의 구현 artifact 가 최소 1개 존재하고, release/docs 반영 후보가 명확하다.
  - AC5: out-of-scope 와 next sprint 후보가 명확해 scope creep 을 막는다.
- 주요 risk:
  - 10x narrative 가 marketing copy 로만 남고 실제 workflow 로 내려가지 않는 것.
  - TDD/DDD 를 너무 무겁게 설명해 비개발자가 겁먹는 것.
  - 기존 Solon SFS command 와 새 coding-mode 구상이 충돌하는 것.
- generator agent 가 만들 산출물:
  - `plan.md` 의 sprint contract.
  - 10x value product artifact 후보: docs/template/prompt 중 1차 구현.
  - 필요 시 Domain/TDD terminology section.
- evaluator agent 가 검증할 기준:
  - 영상 요약의 4 failure pattern 과 4 remedy 가 모두 반영됐는가.
  - 비개발자와 개발자 양쪽 가치가 각각 독립적으로 설득되는가.
  - 구현 artifact 가 지금 repo/product 구조에 무리 없이 들어가는가.
  - next implementation slice 가 1~2시간 안에 가능한가.

## §7. G0 Checklist

- [x] raw brief / 대화 메모가 남아 있다
- [x] 문제와 성공 상태가 한 줄로 설명된다
- [x] 대안 2개 이상을 비교했다
- [x] in/out scope seed 가 있다
- [x] generator/evaluator 계약에 넘길 재료가 있다

> checklist 가 대체로 채워지면 `/sfs plan` 으로 이동한다.

## §8. Append Log

`/sfs brainstorm <text>` 또는 `/sfs brainstorm --stdin` 입력이 append 되는 영역.

### 2026-04-30T23:07:50+09:00 — raw input

```text
Solon 10x value planning sprint. User direction: Soongsil work is being handled separately in terminal Claude. Now refine Solon 10x value proposition and implementation plan. Core idea from video summary: AI coding degrades code because AI focuses on local changes rather than whole-system design. Spec-to-code loops create software entropy. Good codebase means easy-to-change code; bad codebase becomes more expensive and AI accelerates decay. Failure patterns: mismatch between mental picture and AI output due to lack of shared design concept; verbose/inaccurate AI due to missing shared domain language; non-working code due to weak feedback loops; irregular codebase structure causing context explosion and functional bugs. Remedies: shared design concept, DDD ubiquitous language and domain model, TDD with small red/green/refactor cycles, static typing/browser/test feedback, regular codebase rules and refactoring. Solon implication: Solon is not a code generation tool; it is an operating system for AI-ready work. It should turn non-developer ideas into shared design concepts, domain language, acceptance criteria, test contracts, work units, review gates, and implementation slices. For coding with Solon, TDD and DDD must be default concepts, not optional extras. 10x value axes: non-developer productivity by converting fuzzy ideas into verifiable work contracts; developer productivity by making AI coding safe through DDD/TDD/codebase regularity; failure prevention by stopping spec-to-code entropy. Desired sprint result: create plan and start implementation for Solon 10x value offering, especially non-developer productivity and TDD/DDD coding workflow.
```
