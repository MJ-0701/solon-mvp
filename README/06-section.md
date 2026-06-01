---
doc_id: sfs-product-readme-6
title: "어디에 기록되나"
visibility: oss-public
doc_type: product-intro
language: ko
updated: 2026-05-22
parent: README.md
summary: "어디에 기록되나"
load_when: "Read when README.md routes to this section."
---
## 어디에 기록되나

| 경로 | 역할 |
|---|---|
| `SFS.md` | 프로젝트 개요와 routed context 로 가는 얇은 운영 입구 |
| `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` | 각 AI 도구가 Solon 을 찾는 입구 |
| `.sfs-local/` | gitignored private active workbench/state |
| `.sfs-local/harness/harness-map.md` | `sfs harness map --write` 가 남기는 프로젝트 하네스 설계도 |
| `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/report.md` | 도메인 중심 공유 작업 결과 인계 문서 |
| `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/retro.md` | 도메인 중심 회고/후속 인계 문서 |
| `llm-wiki/` | 선택적 Obsidian/LLM 탐색 지도. 원문을 복사하지 않고 source link, glossary, map 으로 쿼리 가능한 회사 기억을 만듭니다. |
| `.sfs-local/ingest/` | `sfs ingest` 가 만드는 Raw intake 초안. 목적과 `source_type` 이 있어야 wiki 로 컴파일할 가치가 판단됩니다. |

`.sfs-local/` 은 영구 히스토리 폴더가 아닙니다. 현재 sprint 를 진행하는 데 필요한 상태만 보이고,
팀이나 미래의 내가 읽어야 할 내용은 `docs/solon/...` 공유 문서와 git history 로 남깁니다.
SFS root agent 문서가 비대해졌다면 `sfs agent doctor --fix` 가 SFS adapter 여부를 감지해
백업 후 frontmatter-only 입구로 되돌립니다.
`SFS.md` 자체가 정책 덤프가 됐다면 `sfs doctor --fix` 가 백업 후 `## 프로젝트 개요` 를
보존한 thin router 로 되돌립니다.
긴 자율 작업이나 parallel-agent 작업 전에는 `sfs harness doctor` 로 프로젝트 하네스를 점검하고,
필요하면 `sfs harness map --write` 로 agent 역할, artifact, memory, test, release loop 를 설계도로 남깁니다.
`sfs start "<goal>"` 이 자연어 목표에서 높은 확신의 도메인 신호를 자동 추론합니다. 도메인이 아직
불명확한 early exploration 만 legacy `docs/solon/<english-workspace>/<yyyyMMdd>/` 폴더를 fallback 으로
씁니다.

---
