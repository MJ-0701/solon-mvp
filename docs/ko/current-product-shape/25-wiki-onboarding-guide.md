---
doc_id: sfs-current-product-shape-ko-25
title: "위키 시작 가이드 — 왜 강력 권고인가, 그리고 10분 코스"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-06-06
parent: docs/ko/current-product-shape.md
summary: "LLM wiki 가 왜 강력 권고인가, 프로젝트 llm-wiki 10분 시작, Obsidian vault 열기, 개인 외부 지식 위키, 포인터 인용 규칙."
load_when: "Read at onboarding (new project before the first sprint, existing project at sfs adopt) when deciding whether and how to build the wiki."
---
## 위키 시작 가이드 — 왜 강력 권고인가, 그리고 10분 코스

LLM wiki 는 **강력 권고 기본값(strongly recommended by default)** 이지 장식이
아니다. 이 문서는 `install.sh`, `sfs adopt`, `sfs harness doctor` 가 가리키는
능동 안내 진입점이다. sprint 를 막지는 않는다 — 거절해도 되며, 아래 레버리지를
포기하는 비용만 든다(`.sfs-local/llm-wiki.waiver` 기록 후 진행). 정책 SSoT 는
`policies/obsidian-llm-wiki.md` 이고, 본 페이지는 그 재서술이 아니라 운영자용
실행 가이드다.

### 1. 왜 강력 권고인가

- **에이전트 셀프서비스 컨텍스트.** 컴파일된 `llm-wiki/` 가 있으면 다음 agent
  가 매번 raw 코드에서 재추론하지 않고 필요한 조각만 로드한다.
- **세션 간 기억.** durable meaning 이 `/clear`, 새 세션, handoff 를 넘어
  살아남는다 — report/retro 로그가 아닌 long-horizon 계층이다.
- **반복 설명 제거.** questions ledger 와 TopicHub 가 매 cold start 마다 같은
  프로젝트를 다시 설명하는 일을 막는다.

언제: **신규** 프로젝트는 첫 실제 sprint 전에, **기존** 프로젝트는 다음 sprint
가 의존하기 전 `sfs adopt` 시점에 구축한다.

### 2. 프로젝트 `llm-wiki/` 시작 (10분 코스)

install 스캐폴드는 `llm-wiki/` 아래 시작 파일 4개를 깐다. by-reference 로 채운다
— source truth 를 링크하고 큰 문서를 붙여넣지 않는다:

1. `README.md` — wiki home: 이 프로젝트가 무엇인지, 상위 TopicHub/map.
2. `00-llm-retrieval-guide.md` — broad scan 전에 agent 가 어떻게 검색할지.
3. `project-context.md` — 목적, 주요 사용자, 핵심 산출물, 먼저 답할 질문,
   헷갈리면 안 되는 경계(install 인터뷰가 미리 채운다).
4. `_FRONTMATTER.md` + `ddd/` + `bug-reports/` — DDD 언어 home 과 버그 재발 기억.

여기까지가 최소 baseline 이다. 더 깊은 migration/memory-formation 흐름은
`policies/obsidian-llm-wiki.md` (New / Existing project flow) 에 있다.

### 3. Obsidian vault 열기

Vault root 는 repo root, wiki root 는 `llm-wiki/`. repo 폴더를 Obsidian vault 로
열면 agent 가 읽는 같은 Markdown 위에서 backlink 와 graph view 를 쓴다. 개인
workspace 상태는 git 에서 제외한다(`.gitignore` snippet 이 이미
`.obsidian/workspace.json` 과 plugin 을 제외).

### 4. 개인 외부 지식 위키(git repo) 시작

프로젝트 wiki 와 별개로, 강의·인사이트·아이디어를 모으는 **개인 외부 지식
위키**를 private git repo 로 유지한다. 멀티 머신은 `clone`/`pull`. 이름과
checkout 경로를 `operator-context.md` 의 `External knowledge wiki` 줄에 기재한다.
advisory 다 — 없어도 모든 명령은 동일하게 동작한다.

### 5. 포인터 인용 규칙

외부 wiki 는 내용을 제품 산출물에 복사하지 말고 **namespaced 포인터**로 인용한다:
`{{EXTERNAL_WIKI_NAMESPACE}}:LNNN-In` + 한 줄 자기 표현 gist. 전체 계약(내용
복사 금지, advisory / runtime-independent, 절대경로 금지)은
`policies/source-pointer-citation.md` 에 있다.

### Solon 워크플로우와의 접점

- 첫 sprint 전, 또는 기존 프로젝트는 `sfs adopt` 시점에 실행한다.
- [탑다운 학습 가이드](./24-topdown-learning-guide.md) 와 함께 — wiki 는 그 학습
  프로토콜의 durable 산출물이 안착하는 곳이다.
- 연속성 근거와 standalone guarantee:
  [Obsidian LLM Wiki Continuity](./19-obsidian-llm-wiki-continuity.md).
