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
- 여러 sprint 또는 여러 agent 가 이어서 작업하는 프로젝트는 core design, domain language, tests,
  CI, release path, decision history 를 wiki 로 찾을 수 있게 한다.
- 긴급 구현을 wiki 부재만으로 막지 않는다. gap 을 기록하고 follow-up 문서 slice 로 구축한다.

## Recommended Shape

- Vault root: repository root.
- Wiki root: `llm-wiki/`.
- source truth 는 기존 docs, code, tests, scripts 에 남긴다.
- wiki page 는 TopicHub, retrieval path, DDD context map, upgrade map, generated index 로 쓴다.
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

## Review Questions

- Obsidian/wiki 상태가 recommended, declined, blocked, already present 중 무엇인가?
- wiki 가 큰 문서 복사본이 아니라 source truth 링크를 제공하는가?
- 기존 프로젝트라면 다음 sprint 가 의존하기 전에 old docs 와 core component 를 색인했는가?
- sprint 가 domain language, release flow, tests, core runtime component 를 바꿨다면 관련 wiki map 을
  갱신했거나 follow-up gap 을 기록했는가?

## Evidence

- `llm-wiki/README.md` 또는 동등한 wiki home.
- source docs/components 로 이어지는 retrieval guide 또는 TopicHub.
- Obsidian workspace/cache/plugin payload 를 제외하는 `.gitignore` 항목.
- 기존 프로젝트라면 adoption handoff 와 wiki migration note.
