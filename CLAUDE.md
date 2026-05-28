---
doc_id: sfs-product-claude
title: "CLAUDE.md — solon-mvp distribution repo agent entry"
visibility: oss-public
doc_type: agent-entry
agent: claude-code
language: ko
updated: 2026-05-28
summary: "Thin agent entry for the solon-mvp distribution repo. Project state / release policy / dev checklists / methodology live in docs/maintenance/."
load_when: "Read at agent boot when working on this repo (the distribution itself, not a consumer project)."
detail_sources:
  - docs/maintenance/project-identity.md
  - docs/maintenance/release-policy.md
  - docs/maintenance/contributing.md
  - docs/maintenance/methodology-7-step.md
  - docs/maintenance/policies/
  - CHANGELOG.md
  - VERSION
do_not_inline:
  - project identity / IP / domain boundary
  - distribution / release policy details
  - install.sh / upgrade.sh / templates/ modification checklists
  - 7-step / Gate label reference
  - routed context module bodies
maintenance:
  detect_or_fix_bloat: "sfs agent doctor --fix"
---

# CLAUDE.md — `solon-mvp` distribution repo agent entry

본 파일은 **`solon-mvp` repo 자체** (distribution) 를 다룰 때 Claude Code
세션이 먼저 읽는 thin agent entry 다. **운영 문서 / 프로젝트 상태 /
아키텍처 / 인프라 / 방법론 reference 는 본 파일에 넣지 않는다** — 그런
내용은 `docs/maintenance/` 의 dedicated doc 으로 분리돼 있고, 본 파일은
frontmatter 의 `detail_sources` 로만 연결한다.

Consumer 프로젝트에 설치되는 어댑터는 `templates/CLAUDE.md.template`
이며 본 파일과 무관하다.

## 작업 전 읽을 것

1. [`docs/maintenance/project-identity.md`](docs/maintenance/project-identity.md)
   — repo 정체성 / IP / 도메인 경계.
2. [`docs/maintenance/release-policy.md`](docs/maintenance/release-policy.md)
   — 8개 배포 원칙 (bash 호환 / templates 호환성 / VERSION semver /
   CHANGELOG / HTML-encouraged docs / session transfer / 6본부 council /
   mainline-first + Gate 6).
3. 작업 영역별 체크리스트는
   [`docs/maintenance/contributing.md`](docs/maintenance/contributing.md)
   (`install.sh` / `upgrade.sh` / `templates/` / `mcp-server/` /
   `packaging/` / release cut).
4. 7-step / Gate 표기 빠른 참조는
   [`docs/maintenance/methodology-7-step.md`](docs/maintenance/methodology-7-step.md).
   실제 SSoT 는 routed context (`sfs context cat kernel` / `index` /
   `commands/*` / `policies/*`).

## Agent 가 절대 하지 말 것

본 섹션은 agent 직접 행동 규칙이라 thin agent entry 에 유지한다.

- **사용자 개인 Solon docset 의 경로 / 파일명 / 내용 유출 금지**. Active
  제품 파일에는 private dev staging checkout 이름이나 절대경로를 쓰지
  않는다. 단 "solon" 단독 키워드 (repo 이름 포함) 와 historical
  changelog / handoff evidence 의 최소 맥락은 허용. 회귀 잠금:
  `tests/test-private-dev-path-hygiene.sh`.
- **install.sh 가 자동으로 `git push` 또는 `git commit` 하지 않음** —
  consumer 의 git 은 consumer 가 관리.
- **`templates/` 에 프로젝트-특화 placeholder 없이 고정값 넣기 금지**.
- **본 CLAUDE.md 본문에 프로젝트 운영 내용을 다시 박지 않음**. 새로
  추가하고 싶은 정책 / 체크리스트 / 방법론 설명은
  `docs/maintenance/` 또는 routed context 에 넣고, 본 파일은
  frontmatter `detail_sources` + body 의 짧은 cross-link 로만 연결.
  회귀 잠금: `tests/test-agent-entry-doc-hygiene.sh` (0.7.2+).

## Changelog

[CHANGELOG.md](./CHANGELOG.md) 에 모든 릴리스 기록.
