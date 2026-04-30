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
   - **새 release cut** → 사용자 macbook (`~/agent_architect`) 의 `scripts/cut-release.sh` 에서 진행 (본 repo 에는 cut tooling 없음).

## 본 repo 와 docset 관계

- 본 `solon-mvp` 는 사용자 개인 Solon docset (`agent_architect/2026-04-19-sfs-v0.4/`) 의 **MVP 배포판**.
- 실 개발 (dev staging) = docset 안 `solon-mvp-dist/`. **본 repo (stable) = release cut 결과물 mirror**.
- 따라서 본 repo 에서는 직접 commit 하지 말고, dev staging 에서 변경 후 `cut-release.sh` 로 sync 받는 것을 권장 (R-D1 dev-first 원칙).
- 예외 (R-D1 hotfix path): 사용 중 stable 에서 발견된 critical bug 만 stable 직접 수정 허용. 단 같은 사이클 안 dev staging 에 동일 변경 반영 (`sync(stable): <sha>` commit message 패턴).

## 비동작 (Non-Goals)

- 본 stub 에 `CLAUDE.md` 본문을 복제하지 말 것.
- 본 stub 을 SSoT 로 격상하지 말 것.
- 본 stub 을 일반 진행 상황으로 갱신하지 말 것 (변경 시 `CLAUDE.md` 또는 `CHANGELOG.md` 갱신).

## 참고

- 실제 SSoT: [`CLAUDE.md`](CLAUDE.md)
- 변경 이력: [`CHANGELOG.md`](CHANGELOG.md)
- 현재 배포 버전: [`VERSION`](VERSION)
- Consumer 어댑터 템플릿: `templates/AGENTS.md.template` (별도 파일, 혼동 주의)
