---
doc_id: sfs-current-product-shape-ko-19
title: "Obsidian LLM Wiki Continuity"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/current-product-shape.md
summary: "Obsidian LLM Wiki Continuity"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Obsidian LLM Wiki Continuity

SFS 는 프로젝트 기억을 위해 Obsidian 을 선택적 동반 도구로 권장합니다. 무료이고, 로컬 우선이며,
Markdown 기반이라 원문 문서를 대체하지 않는 LLM retrieval layer 로 쓰기 좋습니다.

신규 프로젝트에서는 일반 scaffold 가 생긴 뒤 repo root vault 와 작은 `llm-wiki/` 폴더를 권장할 수
있습니다. wiki 는 product design, DDD/TDD method, tests, CI, release path, durable domain term 으로
이어지는 지도 역할을 합니다.

기존 프로젝트에서는 `sfs adopt` 이후 by-reference wiki migration 을 권장할 수 있습니다. 원문 docs 는
source truth 로 유지하고, 중요한 docs/component 를 색인한 뒤 다음 실제 sprint 부터 broad repo scan 전에
wiki map 을 먼저 읽습니다.

이미 `.obsidian/` 또는 `llm-wiki/` 가 있으면 SFS 는 Obsidian 적용 프로젝트로 취급합니다. 이 경우
agent 는 `llm-wiki/README.md` 와 `llm-wiki/ddd/README.md` 를 먼저 확인하고, 관련 map 이 없으면
작업을 막기보다 gap 또는 waiver 를 남깁니다.

host-local tool/skill bundle 과 user-home folder 는 외부 실행 환경이지 project source truth 가 아닙니다.
Obsidian wiki 작업은 사용자가 명시적으로 요청하지 않는 한 이런 외부 도구를 wiki root, SFS 개념,
install target, migration source 로 설치, clone, scaffold, 승격하지 않습니다.

이것은 권고 기본값이지 hard dependency 가 아닙니다. 사용자가 거절하거나 Obsidian 을 쓸 수 없거나 repo 에
vault 를 둘 수 없으면 SFS 는 `docs/solon/` 산출물로 계속 진행하고 gap 또는 waiver 를 기록합니다.
