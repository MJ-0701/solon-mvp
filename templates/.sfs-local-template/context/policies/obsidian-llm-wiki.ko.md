---
id: sfs-policy-obsidian-llm-wiki-ko
summary: SFS 프로젝트용 Obsidian LLM wiki 권고 구축 기준.
language: ko
load_when:
  - Obsidian
  - 옵시디언
  - llm wiki
  - 위키
  - 지식베이스
  - 문서 이관
  - 기존 프로젝트
  - 신규 프로젝트
  - sprint continuity
status: filled-v1
content_policy: "권고 기본값; 사용자가 거절하거나 프로젝트가 쓸 수 없으면 sprint 를 막지 않는다"
---

# Obsidian LLM Wiki Policy

Obsidian 은 무료, 로컬 우선, Markdown 기반이라 SFS 프로젝트의 LLM retrieval 동반 도구로 권장한다.
다만 필수 의존성처럼 강제하지 않는다. 사용자가 거절하거나, 환경에 Obsidian 이 없거나, repo 정책상
vault 를 둘 수 없으면 일반 `docs/solon/` 산출물로 진행하고 waiver 또는 blocker 를 기록한다.

## Activation Rules

- 신규 프로젝트: setup 또는 첫 문서 sprint 에 repo root Obsidian vault 와 작은 `llm-wiki/`
  navigation layer 를 권장한다.
- 기존 프로젝트: `sfs adopt` 시 기존 문서를 Obsidian 에서 읽을 수 있는 wiki 로 by-reference
  이관하는 것을 권장하고, 다음 실제 sprint 부터 그 wiki 를 함께 읽는다.
- 적용 프로젝트: `.obsidian/` 또는 `llm-wiki/` 가 있으면 Obsidian 을 active context 로 본다.
  broad scan 전 `llm-wiki/README.md` 와 `llm-wiki/ddd/README.md` 를 확인하고, 기대 map 이
  없으면 gap/waiver 를 기록한다.
- 여러 sprint 또는 여러 agent 가 이어서 작업하는 프로젝트는 core design, domain language, tests,
  CI, release path, decision history 를 wiki 로 찾을 수 있게 한다.
- 문서가 부족한 프로젝트: 문서가 없다는 이유로 지식이 없다고 보지 않는다. 코드, git commit history,
  test, config, release/deploy script, issue/PR 흔적, 사용자가 준 메모에서 최소 memory baseline 을
  복원한다. 추론한 항목에는 source link, confidence, gap 을 붙인다.
- 긴급 구현을 wiki 부재만으로 막지 않는다. gap 을 기록하고 follow-up 문서 slice 로 구축한다.

## Recommended Shape

- Vault root: repository root.
- Wiki root: `llm-wiki/`.
- DDD 운영 모델 root: `llm-wiki/ddd/`.
- source truth 는 기존 docs, code, tests, scripts 에 남긴다.
- wiki page 는 TopicHub, retrieval path, DDD context map, upgrade map, generated index 로 쓴다.
- 이 시스템은 **Raw / Wiki / Schema (+lint)** 의 3계층으로 본다. (구
  "raw data source / wiki / harness" 명칭을 대체한다. 단일 harness 계층은
  Schema(config) 와 lint(operation) 로 분해된다.)
  - **Raw**: read-only source truth — 코드, 테스트, 스크립트, CI, runtime
    config, 외부 capture, 참조. wiki 가 복제하지 않는다.
  - **Wiki**: AI 소유, write-time compile — Raw 의 navigation(TopicHub, DDD
    map, retrieval path, generated index, gap note, 참조 기반) 이자 산문 개념
    corpus(glossary, ubiquitous language) 의 home/SSoT.
  - **Schema**(config) + **lint**(operation): Schema = frontmatter, line/token
    budget, routing/`load_when`, review question. lint = verification 명령,
    link checker, generated-index 재생성, 사람 승인 규칙. 함께 지식 저장소가
    쓰레기 산이 되지 않게 막는다.
- Knowledge pack 은 이 모델의 **Schema 계층 review lens** 이지 wiki 페이지가
  아니다. read-only routed context(`knowledge-pack-router` 참조)로 남고 wiki 로
  이동하지 않는다.
- Taxonomy 는 독립 wiki 나 조직 본부가 아니다. domain language/classification lens 로 보고
  `llm-wiki/ddd/` 와 관련 TopicHub 에 연결한다.
- host-local tool/skill bundle 과 user-home folder 는 외부 실행 환경이지 project SSoT, wiki root,
  install target, migration source 가 아니다. 사용자가 명시적으로 요청하지 않는 한 wiki 구축 중
  설치, clone, scaffold, 승격을 하지 않는다. 참조가 필요하면 external environment evidence 로만
  기록한다. 이미 SFS 에 흡수된 개념은 host-local tool 대신 SFS command/policy surface 를 쓴다.
- 프로젝트가 원할 때만 공유 가능한 `.obsidian/` 설정을 둔다. 개인 workspace, cache, community plugin
  payload 는 커밋하지 않는다.

## New Project Flow

1. 일반 SFS scaffold 를 먼저 만든다.
2. 최소 `llm-wiki/README.md` 와 retrieval guide 를 권장한다.
3. SFS docs, product design, DDD/TDD method, tests, CI, release path 를 링크한다.
4. 다음 sprint 부터 broad repo scan 전에 wiki map 을 먼저 읽는다.

## Existing Project Flow

1. baseline handoff 는 `sfs adopt --apply "<brief>"` 로 만든다.
2. 문서 성숙도를 `sfs-native`, `documented-legacy`, `documentation-poor` 로 분류한다.
3. 코드 구조가 범위에 있으면 `--ddd-tdd-retrofit` 을 붙인다.
4. Obsidian wiki 는 by-reference 로 구축한다. 큰 원문 문서를 붙여넣지 않는다.
5. 기존 docs, scripts, tests, CI, package manifest, git history, domain term 을 색인한다.
6. documentation-poor 프로젝트는 project map, domain/DDD map, decision ledger, unknowns/gaps,
   questions ledger, dev guardrails, bug/release/test memory 로 최소 memory baseline 을 만든다.
7. 다음 sprint 는 wiki 를 retrieval context 로, 원문 파일을 SSoT 로 삼아 시작한다.

## Memory Formation And Migration

- **Memory migration** 은 이미 있는 것을 보존한다. SFS sprint 기록, `docs/solon/` 산출물, legacy docs,
  ADR, README/GUIDE, issue/PR note, git history 를 원문으로 링크하고 wiki 에는 durable meaning 만 남긴다.
- **Memory formation** 은 문서관리 체계가 없던 프로젝트의 공백을 메운다. 코드 구조, 테스트, config,
  migration, script, package manifest, commit message, release note, 운영 trace 를 읽어 현재 프로젝트
  모델을 추론하되, source link, confidence, owner, gap 을 남겨 날조를 막는다.
- 개발자가 문서를 남기는 이유는 다음 maintainer 가 기존 maintainer 의 암묵지를 빨리 습득해 도메인지식
  레벨을 올리게 하기 위해서다. wiki 는 이 전이를 도구화해서 다음 agent/developer 가 feature work 전에
  프로젝트 맥락을 획득하게 해야 한다.
- 문서가 없다고 사용자에게 프로젝트 전체를 다시 설명하라고 묻지 않는다. 먼저 가능한 증거를 검색하고,
  아는 것과 모르는 것을 기록한 뒤 product 의미가 바뀌는 최소 질문만 묻는다.
- questions ledger 는 `answered`, `open`, `stale`, `ask-again-only-if` 를 구분해서 이미 답한 설명을 다시
  묻지 않게 한다.

## Write-Time Compile

- source document, 회의록, capture, decision, 쓸 만한 agent 답변이 들어오면 다음 질문 시점에
  query-time 재검색으로 떠넘기지 말고 관련 TopicHub, DDD map, index, gap note 로 즉시 컴파일한다.
- 큰 raw note, transcript, generated output, external reference 는 원래 위치에 둔다. wiki 에는 그 원문이
  무엇을 의미하는지, 어디에 있는지, 무엇과 연결되는지, 무엇이 비어 있는지를 기록한다.
- RAG/vector search 는 curated source/wiki metadata 위의 선택적 query-time accelerator 이지 source truth 가
  아니다. sync worker 는 임의 chunk 를 쌓기보다 컴파일된 wiki 와 source link 를 metadata 로 색인해야 한다.
- AI 답변은 source link 와 confidence/gap note 가 붙은 뒤에만 wiki 업데이트 후보가 된다. private/personal
  note 는 사람이 명시적으로 shared project knowledge 승격을 승인하기 전까지 private 로 남긴다.

## Sprint Close Compile Contract

- `report.md` 와 `retro.md` 는 sprint close record 로 남긴다. 최종 범위, 결정 증거, 검증, 위험,
  KPT, PDCA 학습을 담는 완료 sprint 의 transaction log 이며 장기 의미 index 가 아니다.
- `llm-wiki/` 는 long-horizon memory layer 다. `sfs retro` close 시 wiki 에는 재사용될 결정, domain
  term, architecture/release/test contract 변화, 반복 결함, follow-up gap 처럼 durable meaning 만
  컴파일한다.
- report/retro 전문을 wiki 에 복사하지 않는다. source artifact 로 링크하고, 필요한 최소
  TopicHub/map/glossary/bug-report 업데이트만 남긴다.
- `.obsidian/` 또는 `llm-wiki/` 가 있으면 close artifact 에 wiki compile checklist 또는 gap/waiver 를
  남긴다. wiki 표면이 없으면 일반 `docs/solon/` report/retro 산출물만으로 충분하다.
- 주기적 docs GC 는 **먼저 승격 후보를 만들고, 그 다음 compact/archive** 한다.
  `sfs tidy --wiki-promote` 는 report/retro source 를 링크하는 `llm-wiki/promotion-candidates/`
  후보 노트를 만들 수 있지만, source record 를 삭제하거나 report/retro 전문을 wiki 에 복사하지 않는다.
- shared knowledge 승격, 삭제, 민감/private material 이동, wiki/source-truth 충돌 해결은 사람 review 를
  거친다.

## Governance

- agent 는 wiki 승격, 통합, 충돌 해결을 patch/PR 로 제안할 수 있지만 shared knowledge 변경은 merge 전
  사람 review 를 거친다.
- 팀 지식 삭제, 민감 권한, private material, security exception 은 사람이 결정한다. agent 는 evidence 와
  safe diff 를 준비할 수 있지만 조용히 결정하지 않는다.
- member/private note 에서 shared `docs/solon/` 또는 `llm-wiki/` map 으로 승격할 때는 작고 review 가능한
  변경을 선호한다. 이렇게 해야 반복 설명을 chat 밖으로 빼면서 Git history 와 rollback 을 보존한다.

## Review Questions

- Obsidian/wiki 상태가 recommended, declined, blocked, already present 중 무엇인가?
- `.obsidian/` 또는 `llm-wiki/` 가 있으면 agent 가 이를 active project context 로 취급했는가?
- wiki 가 큰 문서 복사본이 아니라 source truth 링크를 제공하는가?
- 새 source material 이 query-time RAG residue 로 남지 않고 TopicHub/map/gap note 로 write-time compile
  되었는가?
- sprint close 시 report/retro 는 close evidence 로 남기고 durable meaning 만 wiki 로 컴파일했는가?
- docs GC 때 archive/compact 전에 source link 가 있는 promotion candidate 를 만들었고,
  report/retro 전문 복사를 피했는가?
- RAG/vector indexing 이 있다면 wiki/source truth 를 대체하지 않고 curated wiki/source metadata 를
  색인하는가?
- agent 가 host-local tool, skill, user-home folder 를 wiki/project SSoT, install target,
  migration source 로 취급하지 않았는가?
- active wiki 에 `llm-wiki/README.md` 와 `llm-wiki/ddd/README.md` 가 있거나 gap/waiver 가
  기록되어 있는가?
- documentation-poor 프로젝트라면 broad project question 전에 code/git/tests/config 에서 최소 memory
  baseline 을 형성했는가?
- wiki 에 already-answered/questions ledger 가 있어 사용자가 이미 설명한 내용을 반복 질문하지 않는가?
- 기존 프로젝트라면 다음 sprint 가 의존하기 전에 old docs 와 core component 를 색인했는가?
- sprint 가 domain language, release flow, tests, core runtime component 를 바꿨다면 관련 wiki map 을
  갱신했거나 follow-up gap 을 기록했는가?
- shared knowledge 승격, 삭제, 민감 권한, private material 이동이 사람 review 를 받았는가?

## Evidence

- `llm-wiki/README.md` 또는 동등한 wiki home.
- `llm-wiki/ddd/README.md` 또는 기록된 DDD wiki gap/waiver.
- source docs/components 로 이어지는 retrieval guide 또는 TopicHub.
- durable conclusion 을 by-reference 로 요약한 TopicHub/map/gap 업데이트.
- documentation-poor 프로젝트의 최소 memory baseline: project map, domain/DDD map, decision ledger,
  unknowns/gaps, questions ledger, dev guardrails, bug/release/test memory.
- vector/search layer 가 연결된 경우 RAG/sync metadata policy 또는 waiver.
- private/member knowledge 에서 shared project knowledge 로 승격한 PR/diff 또는 approval note.
- host-local tool 을 사용자가 명시 요청했다면 project source truth 가 아니라 external environment
  evidence 라는 기록.
- Obsidian workspace/cache/plugin payload 를 제외하는 `.gitignore` 항목.
- 기존 프로젝트라면 adoption handoff 와 wiki migration note.

## WIKI-AIERA - AI 시대 wiki 진입 lens

2026-05/06 실무 강연에서 추린 review-lens 프롬프트. AI 시대 wiki 온보딩의 토의용
체크이지 hard rule 이 아니며, 인용 주장은 강연 시점 주장이다. 여기서는 review 질문만
다루고, 이 질문이 가리키는 wiki 수집·셋업 메커닉은 core-product 표면으로 남겨 본
Schema 층 lens 밖에 둔다.

- WIKI-AIERA-001: 낯선 코드베이스·도메인에 진입할 때, agent 가 돌아가는 시스템을
  먼저 관측했는지 묻는다 — runtime/log/metric 과 git/test/config 신호를, 운영자가
  프로덕션을 만지기 전에 APM 을 읽듯 — 그리고 그것을 용어집(glossary)과 맵으로 옮긴
  뒤 넓은 변경에 들어갔는지. wiki 의 glossary 와 `NN-*-map` 페이지가 그 관측의 durable
  산출물이며 작업 후 형식치레가 아니다. 위 documentation-poor 재구성 질문과는 구분되는
  진입 규율이다.
- WIKI-AIERA-002: 수집·작업 전에 목적을 먼저 확인했는지 묻는다 — 왜 이 자료를, 어떤
  질문을 위해(Gold In, Gold Out). 목적이 무엇을 wiki 에 컴파일할 가치가 있는지
  결정한다. 먼저 담고 이유는 나중에 묻는 방식은 wiki 를 잔여물로 채운다. ask-first 및
  최소 질문 규율과 합치.
