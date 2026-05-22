---
doc_id: sfs-current-product-shape-ko-17
title: "Token / Harness Hygiene"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/current-product-shape.md
summary: "Token / Harness Hygiene"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Token / Harness Hygiene

SFS 는 토큰과 어텐션 낭비를 줄이는 운영 규칙을 routed context 안에 자동으로 깔아둡니다.
사용자가 별도 plugin 을 설치하지 않아도 같은 효과를 얻도록 다음 원칙을 흐름 안에 흡수합니다.

- 토큰 사용량 점검: 토큰이 빨리 닳는 느낌이 있으면 추측보다 usage report 를 먼저 확인한다.
- 어댑터 문서 슬림: `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` 같은 어댑터는 얇게 유지하고,
  긴 규칙은 routed context 또는 docs 로 분리한다.
- 큰 코드베이스 검색 우선순위: 전체 파일을 읽기 전에 symbol / semantic search 를 먼저 쓴다.
- 반복 실수의 자동화: 같은 실수를 말로 다시 설명하지 않고 guardrail / check / hook 으로 바꾼다.

이 원칙은 특정 agent 에 묶이지 않습니다. Claude, Codex, Gemini 등 각 agent 의 usage report,
LSP/index, hook 수단으로 동일하게 적용할 수 있습니다.

