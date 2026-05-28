---
doc_id: solon-product-project-identity
title: "Project identity — `solon-mvp` distribution repo"
visibility: oss-public
doc_type: maintenance-doc
language: ko
updated: 2026-05-28
summary: "What this repo is, who owns it, and how it relates to the full Solon methodology."
load_when: "Read when discussing the repo's role, IP boundary, or relationship to the maintainer's private docset."
---

# Project identity — `solon-mvp` distribution repo

본 문서는 0.7.2 이전 CLAUDE.md 의 § Repo 정체성 섹션을 떼어내 분리한
maintenance doc 이다. CLAUDE.md 는 이제 agent 지침만 담고, repo 정체성 /
도메인 경계 / IP 같은 프로젝트 정보는 본 문서를 참조한다.

## 이름

- **이름**: `solon-mvp` (Solon 방법론의 설치 가능한 MVP 배포판)
- **GitHub**: `MJ-0701/solon-product` — 사용자 머신의 working tree 는
  `~/tmp/solon-product/` (또는 사용자 선택).

## 목적

- 사용자 개인 / 회사 프로젝트에 **Solon 7-step flow** 스캐폴드를
  `install.sh` (혹은 `install.ps1` Windows wrapper) 로 주입.
- consumer 가 `sfs init --layout thin --yes` 한 번으로 `SFS.md`,
  `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.sfs-local/` 를 받고 7-step 을
  돌릴 수 있게 한다.

## 해석 경계

- 7-step 은 full startup team-agent artifact chain 의 **lightweight
  projection** 이다. templates 수정 시 Discovery / PRD / Taxonomy / UX /
  Technical Design / Release Readiness 를 *제거* 한 것으로 오해시키면 안
  된다. 풀스펙은 maintainer 의 private docset 에 따로 있고, 본 repo 는
  그것의 stable mirror 다.
- `solon` 키워드와 `solon-mvp` 이름은 본 repo 가 공개 채널로 노출하는 정식
  표현이다. maintainer 의 dev staging workdir 이름 (`agent_architect`),
  dated docset 디렉토리 (`YYYY-MM-DD-sfs-v*`), 풀스펙 fixture (`solon-mvp-dist`,
  `phase1-mvp-templates`) 등은 active 제품 파일에서 등장하면 안 된다 —
  `tests/test-private-dev-path-hygiene.sh` 가 이 누설을 회귀-잠근다.

## IP / 소유

- IP 는 사용자 (채명정) 개인 자산이다.
- 공개 범위는 TBD — 현재는 GitHub repo 가 public 상태지만, license 는
  `Proprietary` (LICENSE 파일 참조).
- 풀스펙 방법론은 maintainer 의 개인 Solon docset 에 있고, 본 repo 는
  거기서 release cut 된 결과물의 mirror 다 ([dev staging 관계는
  `docs/maintenance/release-policy.md` 의 R-D1 절 참고](release-policy.md)).

## 관련 산출물

- [release-policy.md](release-policy.md) — 배포 원칙 1~8 + dev staging 관계.
- [contributing.md](contributing.md) — install.sh / upgrade.sh / templates/
  변경 시 체크리스트.
- [methodology-7-step.md](methodology-7-step.md) — 7-step flow + Gate 표기.
- [policies/session-transfer-autopilot.md](policies/session-transfer-autopilot.md)
  — Session Continuation Guard 가 걸렸을 때 fresh-session transfer 규약.
- [policies/six-division-council.md](policies/six-division-council.md)
  — 6본부 council 의 항상-개입 원칙 (실 구현은
  `templates/.sfs-local-template/context/policies/division-subagent-council.md`).
