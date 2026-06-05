---
doc_id: solon-product-contributing
title: "Contributing — modification checklists"
visibility: oss-public
doc_type: maintenance-doc
language: ko
updated: 2026-05-28
summary: "Checklists for install.sh / upgrade.sh / templates/ / mcp-server/ / packaging/ / docs changes. Verify each item before committing."
load_when: "Read before editing install.sh, upgrade.sh, uninstall.sh, templates/, mcp-server/, or packaging/."
---

# Contributing — modification checklists

본 문서는 0.7.2 이전 CLAUDE.md 의 § 수정 시 체크리스트 섹션을 떼어내 분리한
maintenance doc 이다. CLAUDE.md 는 이제 agent 지침만 담고, 영역별 작업
체크리스트는 본 문서가 정식 위치다.

## install.sh 변경 시

- [ ] 로컬 모드 (`./install.sh`) 동작 확인
- [ ] 원격 모드 (`curl | bash`) 동작 확인 — 특히 `read < /dev/tty` 처리
- [ ] Windows PowerShell wrapper (`install.ps1`) 가 Git Bash 로
  `install.sh` 를 호출하는 경로 확인
- [ ] 멱등성 — 재실행해도 기존 산출물 파괴 안 함
- [ ] 대화형 충돌 처리 4 옵션 (s/b/o/d) 전부 동작
- [ ] `<PROJECT-NAME>`, `<DATE>`, `<SOLON-VERSION>` 같은 자동 치환
  placeholder 가 새 분기에서도 작동
- [ ] `ASSUME_YES=1` 분기에서 한국어 prompt 가 stdout 으로 누설되지 않음
  (0.6.144 회귀, `confirm()` 의 `SFS_INSTALL_VERBOSE_CONFIRM` 게이트)

## upgrade.sh 변경 시

- [ ] `.sfs-local/VERSION` 형식 하위 호환
- [ ] dry-run 프리뷰 단계 유지 (파일 쓰기 전 사용자 확인)
- [ ] Windows PowerShell wrapper (`upgrade.ps1`) 와
  `.sfs-local/scripts/sfs.ps1` 갱신 경로 확인
- [ ] `--opt-in 0.6-storage` 같은 명시적 migration flag 보존

## templates/ 변경 시

- [ ] placeholder 형식 유지 (`<PROJECT-NAME>` / `<DATE>` / `<STACK>` /
  `<DEPLOY>` / `<DOMAIN>` 등)
- [ ] 도메인 특화 제거 — `solon-mvp` 는 도메인 중립 (관리자페이지 / SaaS
  등 특정 도메인 기술 금지)
- [ ] 외부 Solon docset 경로 / 파일명 하드코딩 금지
  ([test-private-dev-path-hygiene.sh](../../tests/test-private-dev-path-hygiene.sh)
  가 회귀 잠금)
- [ ] template `.md` / `.toml` / shell script 모두 200 줄 이하 유지
  ([test-product-md-frontmatter-line-budget.sh](../../tests/test-product-md-frontmatter-line-budget.sh))
- [ ] script header banner 가 `solon-mvp-dist` 같은 dev staging 라벨을 담지
  않음 (0.6.143 fix)

## mcp-server/ 변경 시 (0.7.0+)

- [ ] 신규 tool 추가 시 `sfs <cmd>` 와 1:1 매핑 보존 (`sfs_*` prefix)
- [ ] tool 안에서 `subprocess` 로 `sfs` shell out + stdout verbatim forward
  보존 (kernel.md SSoT)
- [ ] tool 의 docstring 첫 줄이 LLM 가독성 description
- [ ] [test-mcp-server-contract.sh](../../tests/test-mcp-server-contract.sh)
  의 expected_tools 갱신
- [ ] [README.md](../../mcp-server/README.md) 의 tool table 갱신

## packaging/ 변경 시

- [ ] `packaging/scoop/sfs.json` / `packaging/homebrew/sfs.rb` 는 source-side
  fixture (channel SoT 아님 — 외부 tap/bucket repo 가 SoT). version /
  URL / extract_dir 만 release cut 시 sync.
- [ ] `__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__` 유지 (실 SHA 는 cut-release
  도구가 외부 채널에서 채움).
- [ ] [test-packaging-channel-map.sh](../../tests/test-packaging-channel-map.sh)
  와 [scoop-manifest-validate.sh](../../tests/scoop-manifest-validate.sh)
  통과 확인.

## 실패 발생 시 (lessons 누적)

- [ ] WU / review / gate 에서 잡힌, 다른 세션에서도 재발 가능한 실패는
  `.sfs-local/lessons.md` 에 `L-NNN` 회피 규칙으로 1건 추가 (1회성 오타는 제외).
- [ ] **두 번 이상** 반복된 문제는 검증 도구(test / lint / gate / fixture)에
  재반영하고 lesson 의 `promoted` 필드에 그 도구를 기록 (feedback flywheel:
  record → reflect). 도구 메시지는 다음 에이전트용 actionable 교육 자료로 작성.
- [ ] 스키마 / 참조·누적 규약: routed context `policies/lessons-accumulation.md`.

## release cut 시

상세는 [release-policy.md](release-policy.md) 참조. 핵심 체크포인트:

- [ ] `VERSION` bump (semver 룰 — patch / minor / major)
- [ ] `CHANGELOG.md` 에 `## [X.Y.Z] - YYYY-MM-DD` entry + headline
  blockquote
- [ ] `RELEASE-NOTES.md` 에 `## X.Y.Z` 사용자 친화 요약
- [ ] `tests/test-version-release-headline.sh` 의 expected version +
  plain_output + headline 문자열 갱신
- [ ] `tests/test-docs-division-version-sync.sh` 의 `expected_version`
  갱신
- [ ] `packaging/scoop/sfs.json`, `packaging/homebrew/sfs.rb` 의 version /
  URL / extract_dir 동시 sync
- [ ] 전수 (`tests/test-*.sh`) PASS 확인

## 절대 하지 말 것 (agent 가 직접 따르는 룰은 CLAUDE.md 에 별도)

- 사용자 개인 Solon docset 의 경로 / 파일명 / 내용 유출 금지.
- `install.sh` 가 자동으로 `git push` 또는 `git commit` 하지 않음 —
  consumer 의 git 은 consumer 가 관리.
- `templates/` 에 프로젝트-특화 placeholder 없이 고정값 넣기 금지.

위 룰은 agent 가 직접 위반하지 말아야 하는 것이라 CLAUDE.md body 에도
남아 있다. 본 문서는 maintainer-facing 체크리스트 형태로 다시 정리.

## 관련 산출물

- [project-identity.md](project-identity.md)
- [release-policy.md](release-policy.md)
- [methodology-7-step.md](methodology-7-step.md)
