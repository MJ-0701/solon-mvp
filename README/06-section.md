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
| `SFS.md` | 프로젝트 운영 지침 |
| `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` | 각 AI 도구가 Solon 을 찾는 입구 |
| `.sfs-local/` | gitignored private active workbench/state |
| `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/report.md` | 도메인 중심 공유 작업 결과 인계 문서 |
| `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/retro.md` | 도메인 중심 회고/후속 인계 문서 |

`.sfs-local/` 은 영구 히스토리 폴더가 아닙니다. 현재 sprint 를 진행하는 데 필요한 상태만 보이고,
팀이나 미래의 내가 읽어야 할 내용은 `docs/solon/...` 공유 문서와 git history 로 남깁니다.
`sfs start "<goal>"` 이 자연어 목표에서 높은 확신의 도메인 신호를 자동 추론합니다. 도메인이 아직
불명확한 early exploration 만 legacy `docs/solon/<english-workspace>/<yyyyMMdd>/` 폴더를 fallback 으로
씁니다.

---

