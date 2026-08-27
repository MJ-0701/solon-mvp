---
doc_id: sfs-10x-value-ko-12
title: "왜 solon인가 — 남는 것은 작업 구조다"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-08-27
parent: docs/ko/10x-value.md
summary: "AI 조언 대부분은 빠르게 낡는다. 남는 자산은 작업 구조 — 컨텍스트 설계 / 평가 규율 / 하네스 — 이고, solon 이 바로 그 묶음이다."
load_when: "Read for the 'why Solon' framing when positioning the product or onboarding a skeptic."
---
## 왜 solon인가 — 남는 것은 작업 구조다

프롬프트, 확장프로그램, "이번 주 최강 모델" 같은 조언은 빠르게 낡는다. 모델이
바뀌면 효과가 변하고, 정책이 바뀌면 확장이 죽고, 순위는 다음 주에 뒤집힌다.
변화 속도만 새롭지(수년 주기 → 수개월), 현상은 IT 역사의 반복이다. (프레임 근거:
강의 노트 24 — Karpathy 의 "Software is changing again" 등 특정 인용은
by-reference.)

### 낡지 않는 10%

남는 자산은 모델 이름이 아니라 **작업 구조**다:

- **컨텍스트 설계** — 무엇을 알려주고, 기억하게 하고, 어떤 제약에서 일하게 할지.
- **평가 규율** — 결과 검증 기준과 통과 조건. AI 시대의 진짜 실력.
- **하네스 마인드셋** — 모델을 어떤 작업대에 올리고 어떤 입력·도구·검증 루프를
  줄지. 도구 설계 / 오케스트레이터·서브에이전트 / 표준 프로토콜(MCP)이 여기 든다.

### solon = 그 묶음

solon 은 이 셋을 제품으로 구현한 것이다:

- 컨텍스트 설계 → **routed context** (kernel / commands / policies, on-demand 로딩).
- 평가 규율 → **Gate 시스템**과 flowcheck (작업단위 자기점검·통과 조건).
- 하네스 → **7-step / loop** + 5개 조직 본부와 cross-cutting taxonomy lens로
  이루어진 6개 필수 council role + host-agnostic 진입(MCP 포함).

즉 solon 은 "최신 도구 모음"이 아니라 *낡지 않는 10%를 기본값으로 만든 작업대*다.
모델은 갈아끼우면 되고(설정 리뷰 cadence 가 그것을 전제한다), 그 위의 구조는
남는다. 북마크를 쌓는 대신 작은 것을 실행해 감각을 남기라는 조언과 같은 방향 —
solon 은 그 "작게 실행"을 7-step 으로 정형화한다.

### 외부 증거 (by-reference)

코딩 경험이 없던 영업 담당자가 가장 아픈 반복 작업 하나를 골라 AI 에게 해결책을
빌드시키는 것으로 시작해, 팀 워크플로를 직접 재설계하고 GTM PM 역할로 이동한
사례가 보고됐다 (근거: Anthropic 블로그 "How one Anthropic seller rebuilt his
team's workflows", 2026-06-05, by-reference — 수치/조직 디테일은 발신 시점
주장). 남은 자산이 "코딩 배경"이 아니라 *작업 구조를 설계하는 능력*이라는 위
주장의 외부 근거이며, solon 의 타깃(비기술 1인 운영자)에게 가장 직접적인 증거다.

대규모 사용 세션 분석에서도 같은 방향이 확인됐다: 사용의 대다수가 소프트웨어
개발이 아닌 업무였고, 가장 큰 덩어리는 역할과 역할 *사이*의 연결 작업 — 비즈니스
운영과 콘텐츠 제작(리포트·트래커·덱), 이른바 "work around the work" — 이었다
(근거: Claude 블로그 "How people are using Claude Cowork", 2026-07-07,
by-reference — 수치는 원문 참조, 본문 비복제). 1인 회사에서는 그 연결 작업이
전부 운영자 몫이다. 위임을 구조화하는 것이 가치의 절반이라는 solon 타깃 서사의
데이터 근거.
