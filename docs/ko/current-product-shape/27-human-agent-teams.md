---
doc_id: sfs-current-product-shape-ko-27
title: "인간-에이전트 팀으로 일하기"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-06-28
parent: docs/ko/current-product-shape.md
summary: "1인 운영자가 solon 을 작은 인간-에이전트 팀으로 운영하는 법: 명시 로스터, 신뢰-게이트 능동성을 가진 north star, 자율성의 전제인 검증, 인간 주의=희소자원."
load_when: "두 번째 에이전트(워커/리서처/릴리스 전문)를 붙일 때, 야심 목표를 세울 때, 에이전트가 묻지 않고 어디까지 할지 정할 때 읽는다."
---
## 인간-에이전트 팀으로 일하기

기본이 solo 라고 영원히 단일 에이전트인 건 아니다. 두 번째 runtime(워커,
리서처, 릴리스 전문)이 붙는 순간 이미 *팀* 이고, 팀은 몇 가지를 적어두지
않으면 사이드 채팅 더미로 흩어진다. 아래 4가지 습관이 작은 인간-에이전트
팀을 응집시킨다 (근거: 효과적 인간-에이전트 팀에 관한 Claude 블로그
2026-06-24, by-reference — 일반화; 벤더 제품/채널 디테일은 보류).

### 1. 로스터는 명시 산출물

누가 팀에 있고 각자 무엇을 owns 하는지 적어둔다. 에이전트라면 각자의
**owns / scope / tools** 를 durable 표면에 선언한다 — persona/skill 파일이나
routed-context 한 줄, `model-profiles.yaml` 이 이미 `role -> runtime` 을
바인딩하는 바로 그 자리. 핵심은 "어떤 에이전트가 어떤 도구로 무엇을 하는지"
가 암묵이 아니라 *검사 가능* 해진다는 것.

이게 막는 실패 모드: 역할을 명시하지 않으면 한 번 쓸 질문마다 개인 AI
도우미를 따로 띄우게 되고, 컨텍스트가 아무도 못 보는 곳으로 쪼개진다.
로스터가 해독제다 — 선수를 선언하고, 일을 산출물로 라우팅한다
(`policies/harness-autonomy.md`).

### 2. North star 가 에이전트를 능동적으로 만든다

방향이 있어야 에이전트가 반응만 하지 않고 다음 단계를 먼저 제안한다.
**야심 목표(north star)** 를 문서화하고, **어떤 에이전트가 묻지 않고
제안할 수 있는지** 명시한다. 둘 다 운영자 레이어에 산다 — `operator-context.md`
가 `<OPERATOR-NORTH-STAR>` 와 `<OPERATOR-PROACTIVE-AGENTS>` placeholder 를
배포한다 (`policies/user-context-separation.md`).

능동성은 **기본 ON 이 아니라 신뢰-게이트** 다: 에이전트는 작업 유형별로
컨텍스트와 네가 신뢰하는 검증 수단(습관 3)을 갖춘 뒤에야 제안 권한을 얻는다.
제안은 네가/게이트가 수락하기 전까지 suggest-only 이고, north star 가
inviolable gate 를 우회하지 않는다 (`policies/work-delegation-and-startup.md`
NORTH_STAR).

### 3. 검증이 자율성의 게이트

에이전트 자율성은 희망이 아니라 증거로 확장한다. 규칙:
**위임 작업은 검증 수단을 가질 때만 더 큰 자율성을 얻는다** — 테스트, 루브릭,
스타일가이드, 또는 별도 verifier — 네가 검토 전에 신뢰할 수 있는 수단.
검증 수단 없음 → 감독 유지. 작성자가 자기 작업의 유일한 reviewer 가 될 수
없다는 harness 불변식의 확장이다 (`policies/harness-autonomy.md`).

신뢰는 작업 유형별로 시간에 걸쳐 쌓인다. 이를 받치는 주기적 "lessons &
missteps" 리뷰가 lessons 큐레이션 패스다 (`policies/lessons-accumulation.md`
CURATION_PASS) — 무엇이 실패했고 무엇을 고쳤는지의 주기적 read-only 요약.

### 4. 인간 주의 = 희소자원

1인 팀에선 네가 병목이라, 좋은 에이전트는 네 주의를 예산처럼 쓴다
(`policies/work-delegation-and-startup.md` HUMAN_ATTENTION_IS_SCARCE):

- 막는 질문은 **batch** 해서 결정 지점에 모아 묻는다;
- **핵심 컨텍스트를 반복** 해서 네가 scrollback 을 다시 안 읽게 한다;
- **1회 노출 항목을 제한** — 한 번 보이고 마는 것보다 다시 찾을 수 있는
  durable 산출물을 선호한다;
- **작업량 guardrail 을 통신** 해서 네가 떠안는 양을 보고 제한할 수 있게 한다.

### Solon 워크플로와 만나는 지점

- 로스터는 멀티에이전트 작업이 실제 선택됐을 때만 의미 있다; solo 가 기본
  (`policies/harness-autonomy.md`).
- 운영자 레이어 세팅(north star, 능동 에이전트)은 온보딩에서 나머지
  `operator-context.md` 와 함께 채운다
  (`current-product-shape/25-wiki-onboarding-guide.md`).
- 로스터 에이전트의 접근 스코핑은 별도 주제다
  (`current-product-shape/28-agent-identity-and-compartments.md`).
