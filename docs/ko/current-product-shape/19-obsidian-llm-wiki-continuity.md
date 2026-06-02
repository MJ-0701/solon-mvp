---
doc_id: sfs-current-product-shape-ko-19
title: "Obsidian LLM Wiki Continuity"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-06-02
parent: docs/ko/current-product-shape.md
summary: "Obsidian LLM Wiki Continuity"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Obsidian LLM Wiki Continuity

SFS 는 프로젝트 기억을 위해 Obsidian 을 선택적 동반 도구로 권장합니다. 무료이고, 로컬 우선이며,
Markdown 기반이라 원문 문서를 대체하지 않는 LLM retrieval layer 로 쓰기 좋습니다.

실제 목적은 쿼리 가능한 회사 기억입니다. Raw work 는 source 위치에 두고, `llm-wiki/` 는
source link, map, glossary seed, decision, gap 을 남겨 다음 agent 가 사용자에게 같은 맥락을
다시 묻지 않고 project question 에 답하게 합니다.

다르게 말하면 `llm-wiki/` 는 agent 가 스스로 꺼내 쓰는 지식 냉장고입니다. agent 는 답변에
필요한 재료를 먼저 찾아야 하며, 사용자가 매번 context window 를 다시 채워 주는 구조를 줄여야
합니다.

제품 정체성 경계: wiki 기능과 볼륨 증가는 SFS 흐름을 돕는 수단이지 제품 방향이 아닙니다.
새 wiki 기능은 intent 정리, plan contract, review evidence, handoff, 반복 맥락 retrieval 중 하나를
개선할 때만 Solon 고도화로 봅니다. 이 핵심 루프를 개선하지 못하면 Solon product scope 가 아니라
wiki tooling follow-up 으로 미룹니다.

신규 프로젝트에서는 일반 scaffold 가 생긴 뒤 repo root vault 와 작은 `llm-wiki/` 폴더를 권장할 수
있습니다. wiki 는 product design, DDD/TDD method, tests, CI, release path, durable domain term 으로
이어지는 지도 역할을 합니다.

기존 프로젝트에서는 `sfs adopt` 이후 by-reference wiki migration 을 권장할 수 있습니다. 원문 docs 는
source truth 로 유지하고, 중요한 docs/component 를 색인한 뒤 다음 실제 sprint 부터 broad repo scan 전에
wiki map 을 먼저 읽습니다.
프로젝트에 문서관리 체계가 없었다면 같은 흐름은 memory formation 이 됩니다. SFS 는 코드, git commit
history, test, config, release/deploy script, issue/PR trace, 사용자 메모에서 최소 project memory 를
복원합니다. 문서 부재는 사용자가 프로젝트 전체를 다시 설명해야 하는 이유가 아니라 채워야 할 gap 입니다.

운영 모델은 Raw / Wiki / Schema (+lint) 3계층입니다. Raw source 는 docs, code, tests, scripts,
capture, external evidence 에 남깁니다. wiki 는 write-time compile 된 concept/navigation layer 입니다.
새 source material 이나 수용된 agent 답변이 들어오면 durable conclusion 을 source link 가 붙은 TopicHub,
context map, index entry, gap note 로 정리합니다. Schema 와 lint 는 frontmatter, routing, line budget,
link check, generated index 를 통해 wiki 가 정리되지 않은 문서 더미가 되지 않게 막습니다.

RAG/vector search 는 계속 쓸 수 있지만 curated source/wiki metadata 위의 query-time accelerator 입니다.
다음 agent 가 처음부터 의미를 재조립해야 하는 임의 chunk 더미가 되어서는 안 됩니다.

sprint close 시 `report.md` 와 `retro.md` 는 authoritative close record 로 남깁니다. `llm-wiki/` 는
그 위의 memory layer 이며, 재사용될 결정, domain term, architecture/release contract 변화, 반복 결함,
follow-up gap 같은 durable conclusion 만 받습니다. wiki 는 close artifact 전문을 복사하지 않고 링크합니다.

주기적 정리에서는 `sfs tidy --wiki-promote` 가 docs GC pre-pass 로 동작합니다.
`docs/solon` report/retro pair 를 스캔해 source link 와 promotion root 를 가진
`llm-wiki/promotion-candidates/` 노트를 만들고, source artifact 에도 후보 링크를 되꽂습니다.
source record 를 삭제하지 않고 report/retro 전문도 wiki 로 복사하지 않습니다.

최소 baseline 은 project map, domain 또는 DDD map, decision ledger, unknowns/gaps, questions ledger,
dev guardrails, 그리고 해당 표면이 있으면 bug/release/test memory 입니다. questions ledger 는 이미 답한
내용과 다시 물어도 되는 조건을 기록해서 agent 가 사용자의 암묵지 설명을 반복 질문하지 않게 합니다.

wiki 의 acceptance signal 도 여기에 있습니다. agent 가 알맞은 note 를 스스로 찾고 source artifact 를
인용하며, 남은 product 질문만 최소로 묻는다면 지식 냉장고가 작동하는 것입니다.

`sfs ingest` 는 새 source 를 넣는 Raw-layer 진입 mechanic 입니다. `.sfs-local/ingest/` 에 intake
초안을 쓰기 전에 수집 목적 1줄과 `source_type`(`article`, `youtube`, `podcast`, `book`,
`research`)을 요구합니다. 이 초안은 pointer 와 compile plan 일 뿐이며, durable meaning 은 나중에
source link, glossary, map, gap note 로 `llm-wiki/` 에 들어갑니다.

이미 `.obsidian/` 또는 `llm-wiki/` 가 있으면 SFS 는 Obsidian 적용 프로젝트로 취급합니다. 이 경우
agent 는 `llm-wiki/README.md` 와 `llm-wiki/ddd/README.md` 를 먼저 확인하고, 관련 map 이 없으면
작업을 막기보다 gap 또는 waiver 를 남깁니다.

host-local tool/skill bundle 과 user-home folder 는 외부 실행 환경이지 project source truth 가 아닙니다.
Obsidian wiki 작업은 사용자가 명시적으로 요청하지 않는 한 이런 외부 도구를 wiki root, SFS 개념,
install target, migration source 로 설치, clone, scaffold, 승격하지 않습니다.

agent 는 승격, 통합, 충돌 해결 patch 를 제안할 수 있지만 shared knowledge 변경, 삭제, 민감 권한,
private material 이동은 merge 전 사람 review 를 요구합니다.

이것은 권고 기본값이지 hard dependency 가 아닙니다. 사용자가 거절하거나 Obsidian 을 쓸 수 없거나 repo 에
vault 를 둘 수 없으면 SFS 는 `docs/solon/` 산출물로 계속 진행하고 gap 또는 waiver 를 기록합니다.
