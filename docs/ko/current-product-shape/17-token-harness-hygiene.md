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

이 원칙은 특정 agent 에 묶이지 않습니다. Claude, Codex, Gemini 등 각 agent 의 usage report,
LSP/index, hook 수단으로 동일하게 적용할 수 있습니다.
