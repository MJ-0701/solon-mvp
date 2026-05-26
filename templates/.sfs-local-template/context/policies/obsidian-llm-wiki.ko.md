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
- 긴급 구현을 wiki 부재만으로 막지 않는다. gap 을 기록하고 follow-up 문서 slice 로 구축한다.

## Recommended Shape

- Vault root: repository root.
- Wiki root: `llm-wiki/`.
- DDD 운영 모델 root: `llm-wiki/ddd/`.
- source truth 는 기존 docs, code, tests, scripts 에 남긴다.
- wiki page 는 TopicHub, retrieval path, DDD context map, upgrade map, generated index 로 쓴다.
- 이 시스템은 raw data source, wiki, harness 의 3계층으로 본다. raw data source 는 source truth 이고,
  wiki 는 write-time compile 된 navigation/concept layer 이며, harness 는 frontmatter, line budget,
  routing, review, verification rule 로 지식 저장소가 쓰레기 산이 되지 않게 막는 규칙이다.
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
2. 코드 구조가 범위에 있으면 `--ddd-tdd-retrofit` 을 붙인다.
3. Obsidian wiki 는 by-reference 로 구축한다. 큰 원문 문서를 붙여넣지 않는다.
4. 기존 docs, scripts, tests, CI, package manifest, domain term 을 색인한다.
5. 다음 sprint 는 wiki 를 retrieval context 로, 원문 파일을 SSoT 로 삼아 시작한다.

## Write-Time Compile

- source document, 회의록, capture, decision, 쓸 만한 agent 답변이 들어오면 다음 질문 시점에
  query-time 재검색으로 떠넘기지 말고 관련 TopicHub, DDD map, index, gap note 로 즉시 컴파일한다.
- 큰 raw note, transcript, generated output, external reference 는 원래 위치에 둔다. wiki 에는 그 원문이
  무엇을 의미하는지, 어디에 있는지, 무엇과 연결되는지, 무엇이 비어 있는지를 기록한다.
- RAG/vector search 는 curated source/wiki metadata 위의 선택적 query-time accelerator 이지 source truth 가
  아니다. sync worker 는 임의 chunk 를 쌓기보다 컴파일된 wiki 와 source link 를 metadata 로 색인해야 한다.
- AI 답변은 source link 와 confidence/gap note 가 붙은 뒤에만 wiki 업데이트 후보가 된다. private/personal
  note 는 사람이 명시적으로 shared project knowledge 승격을 승인하기 전까지 private 로 남긴다.

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
- RAG/vector indexing 이 있다면 wiki/source truth 를 대체하지 않고 curated wiki/source metadata 를
  색인하는가?
- agent 가 host-local tool, skill, user-home folder 를 wiki/project SSoT, install target,
  migration source 로 취급하지 않았는가?
- active wiki 에 `llm-wiki/README.md` 와 `llm-wiki/ddd/README.md` 가 있거나 gap/waiver 가
  기록되어 있는가?
- 기존 프로젝트라면 다음 sprint 가 의존하기 전에 old docs 와 core component 를 색인했는가?
- sprint 가 domain language, release flow, tests, core runtime component 를 바꿨다면 관련 wiki map 을
  갱신했거나 follow-up gap 을 기록했는가?
- shared knowledge 승격, 삭제, 민감 권한, private material 이동이 사람 review 를 받았는가?

## Evidence

- `llm-wiki/README.md` 또는 동등한 wiki home.
- `llm-wiki/ddd/README.md` 또는 기록된 DDD wiki gap/waiver.
- source docs/components 로 이어지는 retrieval guide 또는 TopicHub.
- durable conclusion 을 by-reference 로 요약한 TopicHub/map/gap 업데이트.
- vector/search layer 가 연결된 경우 RAG/sync metadata policy 또는 waiver.
- private/member knowledge 에서 shared project knowledge 로 승격한 PR/diff 또는 approval note.
- host-local tool 을 사용자가 명시 요청했다면 project source truth 가 아니라 external environment
  evidence 라는 기록.
- Obsidian workspace/cache/plugin payload 를 제외하는 `.gitignore` 항목.
- 기존 프로젝트라면 adoption handoff 와 wiki migration note.
