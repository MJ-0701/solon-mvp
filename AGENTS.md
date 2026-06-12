---
doc_id: sfs-product-agents
title: "AGENTS.md — `solon-mvp` distribution repo (Codex/Cowork entry)"
visibility: oss-public
doc_type: agent-entry
language: en
updated: 2026-05-22
summary: "AGENTS.md — `solon-mvp` distribution repo (Codex/Cowork entry) entry document"
load_when: "Read when this product document is directly relevant."
---
# AGENTS.md — `solon-mvp` distribution repo (Codex/Cowork entry)

> 본 파일은 **`solon-mvp` repo 자체** (distribution) 를 다룰 때 Codex / Cowork 세션이
> 가장 먼저 자동으로 읽는 redirect stub. 실제 운영 지침은 `CLAUDE.md` 에 있다.
>
> 본 stub 에 규칙을 복제하지 말 것 (이중 SSoT 회피). Consumer 프로젝트에 배포되는
> Codex 어댑터는 별도 (`templates/AGENTS.md.template`) 이며 본 파일과 무관하다.

## 진입 순서 (Codex/Cowork)

1. 본 파일이 안내하는 **`CLAUDE.md` 를 즉시 read**. `solon-mvp` 배포 원칙·수정 체크리스트는 거기 있다.
2. `VERSION` 으로 현재 배포 버전 확인. `CHANGELOG.md` 로 직전 release 변경분 확인.
3. 작업 종류 결정:
   - **`install.sh` / `upgrade.sh` / `uninstall.sh` 변경** → CLAUDE.md "수정 시 체크리스트" 준수.
   - **`templates/` 변경** → consumer 호환성 영향 평가, placeholder 형식 유지.
   - **새 release cut** → 본 repo 에서 직접: `scripts/sfs-release-sequence.sh` (AC11 phases) + 수동 채널 publish + `scripts/verify-product-release.sh`. 절차 SSoT 는 `docs/maintenance/release-policy.md` (dev-staging `cut-release.sh` 경유는 2026-06-06 폐기).

## 비동작 (Non-Goals)

- 본 stub 에 `CLAUDE.md` 본문을 복제하지 말 것.
- 본 stub 을 SSoT 로 격상하지 말 것.
- 본 stub 을 일반 진행 상황으로 갱신하지 말 것 (변경 시 `CLAUDE.md` 또는 `CHANGELOG.md` 갱신).

## 참고

- 실제 agent 지침 SSoT: [`CLAUDE.md`](CLAUDE.md)
- repo 정체성 / IP / 도메인 경계: [`docs/maintenance/project-identity.md`](docs/maintenance/project-identity.md)
- 배포 원칙 / dev staging 관계 (R-D1): [`docs/maintenance/release-policy.md`](docs/maintenance/release-policy.md)
- 영역별 수정 체크리스트: [`docs/maintenance/contributing.md`](docs/maintenance/contributing.md)
- 변경 이력: [`CHANGELOG.md`](CHANGELOG.md)
- 현재 배포 버전: [`VERSION`](VERSION)
- Consumer 어댑터 템플릿: `templates/AGENTS.md.template` (별도 파일, 혼동 주의)
