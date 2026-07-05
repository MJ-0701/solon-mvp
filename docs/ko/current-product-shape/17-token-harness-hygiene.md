---
doc_id: sfs-current-product-shape-ko-17
title: "Token / Harness Hygiene"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-28
parent: docs/ko/current-product-shape.md
summary: "Token / Harness Hygiene"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Token / Harness Hygiene

SFS 는 토큰과 어텐션 낭비를 줄이고 하네스 품질을 높이는 운영 규칙을 routed context 안에 자동으로 깔아둡니다.
사용자가 별도 plugin 을 설치하지 않아도 같은 효과를 얻도록 다음 원칙을 흐름 안에 흡수합니다.

- 토큰 사용량 점검: 토큰이 빨리 닳는 느낌이 있으면 추측보다 usage report 를 먼저 확인한다.
- 어댑터 문서 슬림: `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` 같은 어댑터는
  frontmatter-only 로 유지하고, 긴 규칙은 routed context 나 docs 로 분리한다.
  `sfs agent doctor --fix` 는 SFS adapter 로 식별된 비대 문서를 archive 후 다시 얇게 쓴다.
- `SFS.md` 슬림: 이 파일은 프로젝트 router 와 `## 프로젝트 개요` 편집면으로만 유지한다.
  정책 덤프가 됐다면 `sfs doctor --fix` 로 개요를 보존한 채 thin router 로 되돌린다.
- 하네스 엔지니어링: 부탁이 아니라 구조로 AI 의 천장을 높인다. 현재 작업에 필요한 도구만
  남기고, 프로젝트 전체를 프롬프트로 다듬고, 검증을 자동화하며, 제품 이해와 설계 판단은
  사람이 소유한다.
- 큰 코드베이스 검색 우선순위: 전체 파일을 읽기 전에 symbol / semantic search 를 먼저 쓴다.
- 반복 실수의 자동화: 같은 실수를 말로 다시 설명하지 않고 guardrail / check / hook 으로 바꾼다.
- 캐시 프리픽스 규율: 고정 컨텍스트를 앞에, 휘발 상태를 뒤에 두고, prefix 표면
  (어댑터 문서 / 정책 / 모델 등급)은 세션 단위로 고정한다 — 세션 중간 변경은
  prompt cache 를 무효화하므로 변경을 반영한 뒤 새 세션으로 재시작하고, 무거운
  탐색은 스코프드 워커에 위임한다.
- AI-readiness 감사: `sfs harness doctor` 가 지도(map)를 그리기 전에 Sanity
  (테스트 / dead code / 컨벤션 일관성 / 엔트리 문서 신선도)를 축당 0-2점으로
  채점한다 — signal-only, `.sfs-local/readiness-waiver` 로 waive 가능.
- AI-friendly 표면 축: 같은 doctor 섹션이 저장소 표준 4요소(저장소 안내서 MD /
  routed 가드레일 / 반복 작업의 커맨드·스킬화 / AI 리뷰어 활성)를 별도 0-2 축
  그룹으로 채점한다 — solon 이 설치하는 표면과 1:1 매핑.
- AI 성숙도 셀프 진단: doctor 의 AI Maturity 섹션이 사용량이 아니라 워크벤치
  증거로 5단계 임팩트 사다리(채팅/보조 → WU 통째 위임 → 병렬 캡슐 → 무인
  가능)에서 현재 위치를 찾아 준다 — 도입 ≠ 임팩트, 온보딩의 첫 질문.

이 원칙은 특정 agent 에 묶이지 않습니다. Claude, Codex, Gemini 등 각 agent 의 usage report,
LSP/index, hook 수단으로 동일하게 적용할 수 있습니다.
