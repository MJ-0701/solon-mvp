---
doc_id: solon-system-identity
title: "Solon System Identity — initial idea, problem, and north-star"
version: 0.1
status: draft
created: 2026-04-29
last_updated: 2026-04-29
visibility: business-only
role: north-star
depends_on:
  - 00-intro.md
  - 02-design-principles.md
  - 04-pdca-redef.md
  - 05-gate-framework.md
  - sprints/WU-27.md
defines:
  - concept/solon-system-identity
  - concept/solo-founder-operating-system
  - concept/context-loss-as-primary-enemy
references:
  - concept/company-as-code
  - concept/seven-role-bottleneck
  - principle/self-validation-forbidden
  - principle/human-final-filter
  - principle/progressive-activation-non-prescriptive-guidance
affects:
  - INDEX.md
  - README.md
---

# Solon System Identity

> 이 문서는 Solon 이 기능을 늘리다가 방향성을 잃지 않도록 붙잡아 두는 north-star 이다.
> 자세한 제품 설명은 `00-intro.md`, 운영 원칙은 `02-design-principles.md`, 실행 구조는 `04-pdca-redef.md` / `05-gate-framework.md` 를 따른다.

---

## 1. 초기 아이디어

Solon 의 출발점은 단순했다.

**"1인 창업가가 혼자 일하더라도, 실제 회사처럼 사고하고 실행하고 검증할 수 있으면 어떨까?"**

여기서 말하는 "회사처럼"은 사람 수를 흉내 내는 것이 아니다. 회사를 움직이게 하는 더 작은 단위들, 즉 역할, 책임, 의사결정, 산출물, 검증, 회고, 인수인계를 코드와 문서로 고정하는 것이다.

초기 직감은 다음 세 문장으로 요약된다.

1. 아이디어를 가장 빠르게 구현하는 길은 코드를 빨리 쓰는 것이 아니라, 의도와 경계를 먼저 선명하게 하는 것이다.
2. LLM agent 는 실행 속도를 크게 올릴 수 있지만, 자기검증과 맥락 유실을 방치하면 오히려 더 빠르게 잘못된 방향으로 간다.
3. 1인 창업가에게 필요한 것은 "똑똑한 챗봇" 하나가 아니라, 여러 역할이 서로 견제하고 인수인계하는 운영 체계다.

그래서 Solon 은 prompt pack 이 아니라 **solo founder operating system** 으로 설계한다.

---

## 2. 해결하려는 문제

Solon 이 해결하려는 핵심 문제는 "개발을 더 빨리 하는 법" 하나가 아니다.

진짜 문제는 **1인 창업가가 회사 전체의 역할을 혼자 떠안는 순간, 맥락과 판단과 품질이 계속 새어 나가는 것**이다.

### 2.1 7 역할 병목

MVP 하나를 시장에 내기 위해서도 CEO, CTO, CPO, PM, Designer, Developer, QA/Infra 의 사고가 최소한으로 필요하다. 한 사람이 이 역할들을 모두 하려 하면 다음 문제가 반복된다.

- 무엇을 만들지 결정하지 못해 실행이 늦어진다.
- 설계 없이 만들다가 나중에 갈아엎는다.
- 구현은 됐지만 사용자가 왜 써야 하는지 흐려진다.
- 테스트와 배포가 뒤로 밀려 출시 품질이 무너진다.
- 세션이 바뀔 때마다 의사결정 근거가 사라진다.

Solon 의 6 Division + 3 C-Level 구조는 이 역할 공백을 agent 조직으로 대체하려는 시도다.

### 2.2 맥락 유실

agent 작업의 가장 큰 적은 능력 부족보다 **맥락 유실**이다.

세션이 끊기고, 작업 단위가 커지고, commit 이 밀리고, 같은 파일을 여러 worker 가 건드리면 "왜 이 결정을 했는가"가 사라진다. 그러면 다음 agent 는 결과만 보고 다시 추측한다.

Solon 은 이 추측을 줄이기 위해 다음을 강제한다.

- `PROGRESS.md` live snapshot
- WU 단위 작업 기록
- gate / decision / event 로그
- frontmatter 기반 의존성
- commit 전후 backfill
- session retro 와 learning log

즉, Solon 의 문서는 설명서가 아니라 **작업 기억 장치**다.

### 2.3 자기검증 루프

LLM 은 자기 산출물을 스스로 통과시키기 쉽다. "좋아 보이는 답"과 "실제로 통과한 결과"가 섞이면 시스템은 조용히 부패한다.

Solon 은 이를 막기 위해 자기검증 금지를 핵심 원칙으로 둔다.

- 만든 agent 와 검증 agent 를 분리한다.
- gate operator 를 따로 둔다.
- 사람의 최종 필터를 남긴다.
- 실패를 learning log 로 남겨 다음 sprint 의 입력으로 되돌린다.

이 구조가 없으면 Solon 은 그냥 자동화된 낙관주의가 된다.

---

## 3. Solon 의 정체성

Solon 은 **1인 창업가를 위한 Company-as-Code 시스템**이다.

Company-as-Code 란 회사를 다음 네 축으로 정의하고, 각 축을 문서와 파일과 명령으로 재현 가능하게 만드는 것이다.

```text
Company = Org x Process x Artifact x Observability
```

- **Org**: 누가 어떤 책임을 가지는가.
- **Process**: 어떤 순서로 생각하고 실행하고 검증하는가.
- **Artifact**: 무엇을 남겨야 다음 사람이 이어받을 수 있는가.
- **Observability**: 지금 어디까지 왔고 무엇이 막혔는가.

따라서 Solon 의 정체성은 "AI 가 대신 일하는 도구"보다 좁고, "회사 운영을 코드화하는 체계"보다 넓다. agent 가 일하게 하되, agent 가 방향을 결정하지 못하게 하는 시스템이다.

---

## 4. Solon 이 아닌 것

Solon 은 다음이 아니다.

- 단순한 `/sfs` slash command 묶음
- 예쁜 markdown template 모음
- agent 를 많이 띄우는 자동화 장치
- 사람이 확인하지 않아도 되는 fully autonomous 회사
- 특정 도메인에 묶인 SaaS 개발 방법론

`/sfs` 는 Solon 의 사용자 인터페이스 중 하나일 뿐이다. 핵심은 command 가 아니라 command 가 남기는 산출물, gate, 의사결정 기록, 회복 가능성이다.

---

## 5. 방향성을 잃는 신호

다음 신호가 보이면 Solon 은 원래 문제에서 멀어지고 있는 것이다.

1. 문서가 실행을 돕지 않고 문서 자체를 위한 문서가 된다.
2. agent 가 "사용자 결정 영역"을 대신 확정한다.
3. gate 가 품질 검증이 아니라 통과 의례가 된다.
4. `/sfs` 명령이 늘어났지만 작업 기억과 회복력이 늘지 않는다.
5. 병렬 worker 가 독립적으로 일하지 않고 서로의 타이밍을 눈치 본다.
6. "빠른 구현"이라는 명분으로 초기 의도, 대안, 실패 조건을 생략한다.
7. 사용자 최종 필터 없이 자동 통과를 release 로 착각한다.

이 중 하나라도 반복되면 새 기능보다 시스템 정렬을 먼저 한다.

---

## 6. 설계 판단의 기준

Solon 에 새 기능을 넣을지 판단할 때는 다음 질문을 먼저 던진다.

1. 이 기능은 1인 창업가의 역할 병목을 실제로 줄이는가?
2. 세션이 바뀌어도 다음 worker 가 더 적게 추측하게 만드는가?
3. 자기검증 루프를 줄이는가, 아니면 더 숨기는가?
4. 산출물과 gate 를 더 명확하게 하는가?
5. 사용자의 최종 결정권을 보존하는가?
6. Phase 1 dogfooding 에서 바로 검증 가능한가?

답이 흐리면 보류한다. Solon 의 기본값은 기능 추가가 아니라 **minimal cleanup** 이다.

---

## 7. 한 문장 정체성

**Solon 은 1인 창업가가 회사를 흉내 내는 것이 아니라, 회사가 하던 역할 분리·검증·기억·회복을 파일과 agent 로 재현하게 만드는 운영 시스템이다.**

이 문장이 흔들리면, 기능보다 정체성을 먼저 고친다.

