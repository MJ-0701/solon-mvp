---
doc_id: solon-product-release-policy
title: "Release policy — distribution / templating / versioning rules"
visibility: oss-public
doc_type: maintenance-doc
language: ko
updated: 2026-06-02
summary: "Release-policy principles and model-evolution config review cadence for install.sh / upgrade.sh / templates / VERSION / CHANGELOG / docs format / session transfer / mainline focus."
load_when: "Read before editing install.sh / upgrade.sh / uninstall.sh / templates/, before cutting a release, when deciding whether a change belongs in patch vs minor, or when reviewing stale agent config after model/runtime changes."
---

# Release policy — `solon-mvp` distribution

본 문서는 0.7.2 이전 CLAUDE.md 의 § 배포 원칙 1~8 섹션을 떼어내 분리한
maintenance doc 이다. CLAUDE.md 는 이제 agent 지침만 담고, 8개 운영 원칙은
본 문서가 정식 위치다.

## 1. Bash 호환

`install.sh` / `upgrade.sh` / `uninstall.sh` 는 **bash 호환** 이다 — macOS
zsh / Linux bash / WSL 모두에서 동작해야 하고 POSIX 친화 패턴을 쓴다.
Windows PowerShell 사용자는 `install.ps1` / `upgrade.ps1` / `uninstall.ps1`
wrapper 를 통해 Git Bash 기반 bash adapter SSoT 로 내려간다.

## 2. templates/ 하위는 consumer 배포본

`templates/` 하위 파일은 consumer 에게 그대로 배포된다. 수정 시 하위 호환성
을 고려한다. consumer 가 0.6.x → 0.7.x 로 `sfs upgrade` 했을 때 자기
프로젝트 상태가 깨지지 않아야 한다.

## 3. VERSION 은 semver

`VERSION` 은 semver `X.Y.Z-mvp` 또는 `X.Y.Z`. mvp suffix 는 풀스펙 수렴 전까지
유지한다. 작은 fix 묶음 = patch (Z 증가), 새 surface (MCP server / Agent SDK
template 등) = minor (Y 증가), breaking 호환성 변경 = major (X 증가, 아직
없음).

## 4. CHANGELOG.md 가 모든 릴리스를 기록

`CHANGELOG.md` 는 모든 릴리스를 기록한다. `upgrade.sh` 가 이 파일을 consumer
에게 안내하므로 사용자가 읽을 수 있는 한국어/영어 자연어로 작성한다. 같은
release 의 `RELEASE-NOTES.md` 는 사용자 친화 요약, `CHANGELOG.md` 는 세부
변경 목록을 담는다.

## 5. User-facing docs HTML-encouraged

AI Agent 참고용 운영 문서 / SSoT / 로그 / 스키마 / README 는 Markdown 을
유지한다. 실제 사용자 / 외부 독자 / 온보딩 대상이 읽는 설명서 / 가이드 /
보고서 / 핸드북 / 랜딩성 문서는 HTML 산출을 권장하지만, GitHub 안 렌더링
MD 가 이미 주 읽기 표면이라면 MD 유지도 허용한다 (현 `docs/` 는 전부 MD
유지 선택).

## 6. Fresh-session transfer autopilot

Session Continuation Guard 가 걸리면 같은 세션 / 새 세션 선택이나 `/clear`
입력을 묻지 않는다. 먼저 current branch / commit / status / evidence / next
prompt 를 담은 durable handoff / report 를 남긴 뒤, host-native transfer /
new-session / archive / clear+resume 제어가 있으면 직접 호출해 새 세션에서
즉시 이어간다. resume 없는 bare clear 는 금지한다. host 제어가 없으면 exact
next-session prompt 만 남기고 멈춘다.

상세 규약: [`policies/session-transfer-autopilot.md`](policies/session-transfer-autopilot.md).

## 7. 6본부 council always-on

strategy-pm / dev / QA / design / infra / taxonomy 는 brainstorm 부터 Gate 6
까지 개념적 sub-agent 로 evidence / waiver 를 남긴다. parallel worker 는 별도
opt-in 이다.

상세 규약 + plan-stage council 메서드는 routed context 의
`policies/division-subagent-council.md` 와 `policies/enterprise-plan-council-pack.md`
가 SSoT 다. 본 문서는 cross-link 만.

## 8. Mainline-first + Gate 6 data/security

보조 도구 / 인증 / 모델 설정은 본 작업의 `unblocker` 일 때만 최소 처리하고
즉시 본론으로 복귀한다. Gate 6 는 다음을 확인한다:

- mock / fixture / seed / API / UI / auth / session / persistence 데이터
  검증
- OWASP-style security / logging, production console / debug log 제거
- Datadog / equivalent observability evidence
- 긴 컨텍스트 wiki checklist reconciliation
- postdev external review, lean procedure review
- `process-lean` lens

## Config-review cadence for model evolution

모델과 agent runtime 이 진화하면 예전 `CLAUDE.md` / `AGENTS.md` / `GEMINI.md`,
skills, hooks, permissions, local routed-context override 가 더 이상 도움이 되지
않거나 오히려 agent 를 묶을 수 있다. Consumer 는 다음 cadence 로 config review 를
수행한다:

- 기본 주기: 3-6개월마다 1회.
- 이벤트 주기: major model release, runtime/tooling release, 또는 성능 정체가
  보일 때 즉시 1회.
- 점검 범위: root agent adapter, `SFS.md`, installed skills/hooks/plugins,
  permissions, `.sfs-local/context/` overrides, project maps, test/lint command
  scope.
- 처리 원칙: thin adapter 는 frontmatter pointer 로 유지하고, durable policy 는
  routed context 또는 `docs/maintenance/` 로 옮긴다. **stale workaround
  instruction 의 제거는 임의 삭제가 아니라** routed context
  `policies/model-workaround-sunset.md` 의 tagged sunset review (keep /
  retire / generalize, archive-never-silent-delete) 를 거친다.
- 근거 기록: sprint report / `docs/solon/...` maintenance note / CHANGELOG 중
  현재 작업 표면에 맞는 곳에 review date, trigger, removed stale rule, retained
  critical gotcha 를 남긴다.

Historical evidence: Anthropic, "How Claude Code works in large codebases"
(2026-05-14) notes that model evolution can make old CLAUDE.md guidance
unnecessary or constraining and recommends meaningful config review every
three to six months or after major model releases.

## Release cut 절차 (R-D1 dev-first 는 2026-06-06 폐기)

본 repo 가 SSoT 다 — 변경은 본 repo 에 직접 commit 하고, release cut 도 본
repo 에서 수행한다. (구 R-D1 dev-first 원칙 — dev staging 에서 작성 후
`cut-release.sh` 로 forward-sync — 은 2026-06-06 `solon-mvp-dist` 미러
제거와 함께 폐기됐다. historical changelog 에만 남는다.)

현행 cut 시퀀스 (0.8.34-36 에서 검증):

1. `git push origin main` (default branch push 가 `Fixes #N` 을 닫는다).
2. `scripts/sfs-release-sequence.sh --phase tag-push|audit --version X.Y.Z`.
3. 수동 채널 publish: GitHub archive tar/zip sha256 계산 → `packaging/`
   템플릿을 Homebrew tap / Scoop bucket 클론에 렌더 → commit + push.
   (`SOLON_RELEASE_BOT_TOKEN` 있으면 workflow dispatch 가능 — preflight 가
   판정.)
4. `--phase tap-update` 마커 → 로컬 brew tap pull → `--phase post-audit`
   (`brew audit --strict --online sfs`).
5. `scripts/verify-product-release.sh --version X.Y.Z` 로 출하 검증
   (VERSION / tag / 4 phase markers / 채널 manifest / 설치본).

## 관련 산출물

- [project-identity.md](project-identity.md) — repo 정체성 / IP / 도메인
  경계.
- [contributing.md](contributing.md) — install.sh / upgrade.sh / templates/
  변경 시 체크리스트.
- [methodology-7-step.md](methodology-7-step.md) — 7-step flow + Gate 표기.
