---
doc_id: sfs-current-product-shape-ko-26
title: "표준 위임 레퍼토리 — 1인 운영자용"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-06-11
parent: docs/ko/current-product-shape.md
summary: "공식 공통 워크플로를 1인 운영자 맥락으로 번안한 표준 위임 패턴 모음 — 무엇을, 어느 런타임 티어에, 어떤 산출물로 위임할지."
load_when: "Read when deciding which recurring knowledge work to hand the agent, or building a personal delegation menu."
---
## 표준 위임 레퍼토리 — 1인 운영자용

매번 "이걸 AI 에게 줄까"를 0부터 고민하면 위임이 늘지 않는다. 자주 반복되는 지식
노동을 *이름 붙은 패턴*으로 정리해 두면, 다음에 같은 일이 오면 패턴을 고르기만 하면
된다. 아래는 공식 공통 워크플로 묶음을 1인 운영자 맥락으로 번안한 출발 메뉴다
(근거: "The Claude Cowork product guide", 2026-06-05, by-reference — 정확한 워크플로
이름/개수는 발신 시점 제품 디테일이라 일반화해 옮긴다).

각 패턴은 `policies/work-delegation-and-startup.md` 의 다섯 요소 테스트를 통과하는
일을 가정한다. 티어 선택은 같은 정책의 런타임 축(대화형 / 감독형 세션 / 자율 코드)을
따른다.

### 패턴 메뉴

1. **리서치 브리프** — 주제 하나를 다출처로 조사해 결론·근거·열린 질문으로 압축.
   티어: 감독형 세션. 산출물: 인용이 달린 브리프 문서.
2. **결정/미팅 준비** — 흩어진 자료를 모아 핵심 쟁점·선택지·권장안으로 정리.
   티어: 감독형 세션. 산출물: 1쪽 결정 노트.
3. **반복 리포트** — 같은 형식의 주간/월간 보고를 소스에서 자동 생성.
   티어: 감독형 세션 + 스케줄 트리거. 산출물: 정형 리포트.
   외부 검증 사례: 스프레드시트 → 주간 리포트, 로그/메트릭 watch → 이상 보고
   ("New in Claude Managed Agents", 2026-06-09, by-reference). 스케줄 실행의
   운영 계약은 `policies/work-delegation-and-startup.md` SCHEDULED_RUN_CONTRACT.
4. **인박스/이슈 트리아지** — 들어온 항목을 분류·우선순위화하고 초안 응답을 단다.
   티어: 감독형 세션. 산출물: 분류된 큐 + 응답 초안.
5. **소스 기반 초안** — 기존 문서/노트를 근거로 새 발신물(메일·공지·문서) 작성.
   티어: 감독형 세션. 산출물: 검토 대기 초안 (최신 소스 재조회 후 작성,
   `policies/source-pointer-citation.md`).
6. **데이터 추출·요약** — 로그/시트/응답을 뽑아 한 화면 요약과 다음 행동으로.
   티어: 감독형 세션 또는 자율 코드(repo 데이터일 때). 산출물: 요약 + 행동 목록.
7. **장기 실행 작업** — 멀티스텝 빌드·마이그레이션·감사 등 한 턴에 안 끝나는 일.
   티어: 자율 코드 + 게이트된 `loop`, 인계 문서 동반 (`commands/loop.md`).

### Solon 워크플로와의 접점

- 하루 단위 진입/마무리는 bookend 운영 루프로 묶는다 — 아침 브리프가 1·6번을,
  저녁 리캡이 3번을 정기화한다 (`commands/daily.md`).
- 어떤 패턴이든 산출물을 읽고 이해하고 의견을 갖는 사람 몫은 그대로다
  (`current-product-shape/24-topdown-learning-guide.md`).
- 일회성/반복/배치 라우팅은 `policies/ai-work-intake-routing.md` 를 따른다.
