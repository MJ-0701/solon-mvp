---
doc_id: sfs-current-product-shape-ko-24
title: "탑다운 학습 가이드 — 1인 운영자용"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-06-06
parent: docs/ko/current-product-shape.md
summary: "문제 중심 진입 + AI 질문 배터리 + 이해 검증으로 새 도메인을 빠르게 잡는 1인 운영자 학습 프로토콜."
load_when: "Read when an operator needs to learn a new domain/codebase fast to drive Solon work."
---
## 탑다운 학습 가이드 — 1인 운영자용

1인 운영자는 새 도메인(코드베이스 / 세무 / 마케팅 / 인프라)을 자주 마주친다.
기초부터 쌓는 바텀업은 실전 도달 전에 지친다. AI 시대 학습은 **문제 → 필요지식
역방향(탑다운)** 이 빠르다 — 단, 탑다운은 *이해 생략*이 아니라 *이해 순서의
역전*이다. "바이브 코딩 거부": 산출물을 반드시 읽고 이해하고 명확한 의견을 가져야
한다. (근거: 강의 노트 20 — 수치/사례는 강연 시점 주장, by-reference.)

### 프로토콜 4단계

1. **문제 중심 진입.** AI 에게 전체 동작 예시(코드 / 보고서 / 워크플로)를 요청해
   먼저 실행·관찰한다. 이해 못 해도 돌려보고 깨뜨려본다.
2. **AI 질문 배터리.** 각 부분의 역할을 파고든다:
   - "이 부분이 없으면 무엇이 깨지나"
   - "기존 방식과 무엇이 다른가" (논문/문서는 이 목록 요약부터 — 처음부터 정독 금지)
   - "왜 이렇게 했나, 대안은 무엇이었나"
   - "12살에게 설명하듯" 비유 요청으로 직관 확보
3. **이해 검증.** 자기 이해를 AI 에게 **설명해 보고** 틀린 곳을 교정받는다.
   설명하지 못하면 아직 이해한 게 아니다.
4. **의견 형성.** 분야 최전선일수록 전부 이해하고 명확한 판단을 가진다. 이해와
   소유는 사람 몫이고 AI 는 가속기다.

### Solon 워크플로와의 접점

- **brainstorm / plan 진입 전** 이 프로토콜로 도메인을 잡으면 Gate 2~3 의 질문
  품질이 올라간다.
- 운영자 학습 성향(설명 깊이 / 기술 깊이)은 `operator-context.md` (user 레이어)
  에 적어두면 에이전트가 그 수준에 맞춰 설명한다.
- 착수 전 복창+질문(`policies/work-delegation-and-startup.md`)은 이 프로토콜의
  2단계와 같은 사상 — 모호하면 먼저 묻는다.
- 비기술 진입의 외부 사례: 코딩 경험 없는 영업 담당자가 "가장 아픈 작업 하나를
  골라 AI 에게 해결책을 빌드시킨다"로 시작한 경로 (근거: Anthropic 블로그 "How
  one Anthropic seller rebuilt his team's workflows", 2026-06-05, by-reference)
  는 1단계 문제 중심 진입과 같은 형태다.
