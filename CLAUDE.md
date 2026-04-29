# CLAUDE.md — `solon-product` distribution repo 유지보수 지침

> 본 파일은 **`solon-product` repo 자체** (distribution) 를 다룰 때 Claude Code 세션이 참조하는 지침.
> Consumer 프로젝트에 설치될 `CLAUDE.md` 와는 별개 (그건 `templates/CLAUDE.md.template`).

## Repo 정체성

- **이름**: `solon-product` (Solon 방법론의 설치 가능한 product 배포판)
- **목적**: 사용자 개인 / 회사 프로젝트에 **Solon 7-step flow** 스캐폴드를 `install.sh` 로 주입
- **해석 경계**: 7-step 은 full startup team-agent artifact chain 의 lightweight projection 이다. templates 수정 시 Discovery/PRD/Taxonomy/UX/Technical Design/Release Readiness 를 제거한 것으로 오해시키면 안 된다.
- **IP**: 사용자 (채명정) 개인 자산. 공개 범위는 TBD (현재 private 권장).
- **연계**: 풀스펙 방법론은 사용자 개인 Solon docset 에 있음 (본 repo 에는 경로 / 내용 미반영).

## 배포 원칙

1. **install.sh / upgrade.sh / uninstall.sh** 는 **bash 호환** (macOS zsh / Linux bash 공통). POSIX 친화.
2. **templates/** 하위는 consumer 에게 그대로 배포되는 파일. 수정 시 하위 호환성 고려.
3. **VERSION** 은 semver `X.Y.Z-mvp` 또는 `X.Y.Z`. mvp suffix 는 풀스펙 수렴 전까지 유지.
4. **CHANGELOG.md** 는 모든 릴리스를 기록. upgrade.sh 가 이 파일을 consumer 에게 안내.

## 수정 시 체크리스트

### 공통
- [ ] 파일을 수정하면 `CHANGELOG.md` 의 Unreleased 또는 해당 릴리스 섹션에 변경 범위, 변경 이유, 검증 결과를 남긴다.
      후속 Claude/Codex 세션이 정합성과 합리성을 cross-check 할 수 있어야 한다.

### install.sh 변경 시
- [ ] 로컬 모드 (`./install.sh`) 동작 확인
- [ ] 원격 모드 (`curl | bash`) 동작 확인 — 특히 `read < /dev/tty` 처리
- [ ] 멱등성 — 재실행해도 기존 산출물 파괴 안 함
- [ ] 대화형 충돌 처리 4 옵션 (s/b/o/d) 전부 동작

### templates/ 변경 시
- [ ] placeholder 형식 유지 (`<PROJECT-NAME>` / `<DATE>` / `<STACK>` / `<DEPLOY>` / `<DOMAIN>` 등)
- [ ] 도메인 특화 제거 — `solon-product` 는 도메인 중립 (관리자페이지/SaaS 등 특정 도메인 기술 금지)
- [ ] 외부 Solon docset 경로 / 파일명 하드코딩 금지

### upgrade.sh 변경 시
- [ ] `.sfs-local/VERSION` 형식 하위 호환
- [ ] dry-run 프리뷰 단계 유지 (파일 쓰기 전 사용자 확인)

## 7-step flow 요약 (본 repo 자체 개발에도 적용)

1. 브레인스토밍 (G0)
2. plan (G1)
3. sprint
4. 구현 (G2 entry)
5. review (G4)
6. commit
7. 문서화

Gate 는 all signal-only (ALT-INV-3 never-hard-block).
Production open 을 수반하면 Release Readiness evidence(secret/auth/data/monitoring/rollback/cost) 를 review 또는 retro-light 에 남긴다.

## 절대 금지

- **사용자 개인 Solon docset 의 경로 / 파일명 / 내용 유출** (예: `agent_architect` / `sfs-v0.4` / `solon-docset`).
  단 "solon" 단독 키워드 (repo 이름 포함) 는 허용.
- **install.sh 가 자동으로 git push / commit** — consumer 의 git 은 consumer 가 관리.
- **templates/ 에 프로젝트-특화 placeholder 없이 고정값** 넣기.

## Changelog

[CHANGELOG.md](./CHANGELOG.md) 에 모든 릴리스 기록.
