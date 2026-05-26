---
doc_id: sfs-current-product-shape-ko-20
title: "AI Work Intake Routing"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-26
parent: docs/ko/current-product-shape.md
summary: "AI Work Intake Routing"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## AI Work Intake Routing

Solon 은 AI 에게 일을 맡기기 전에 intake contract 를 먼저 잡습니다. 이 계약은 네 부분입니다.

- 목표: 무엇을 만들고 왜 필요한지.
- 재료: 메모, 파일, 스크린샷, 과거 문서, 코드, 링크, 예시, project memory.
- 먼저 물어볼 조건: agent 가 작성 전에 물어야 할 애매함과 SFS history, wiki, docs, current sprint 에서
  안전하게 추론할 수 있는 것.
- 결과 형식: 회의록, 체크리스트, 표, PR, plan, HTML guide, report, 파일별 결과와 master index 같은
  산출물 모양.

SFS 는 일의 크기에 따라 도구 사용량도 고릅니다. 단일 작업은 현재 chat 에서 끝낼 수 있습니다.
반복 작업은 안정된 목표/재료/형식 규칙을 project memory, `SFS.md`, `docs/solon/`, `llm-wiki/` 로
승격합니다. 대량 작업은 raw input 을 보존하고 source 별 산출물을 만든 뒤 요청된 master table,
index, report 로 합칩니다.

이 규칙은 특정 vendor 에 묶이지 않습니다. Claude chat/project/cowork, Codex thread, local folder,
Obsidian, Git, 이후 도구 모두 같은 구조를 구현할 수 있습니다. SFS 는 사용자가 맥락을 반복하지
않도록 durable contract, evidence, artifact path 를 기록합니다.
