# CHANGELOG — Solon MVP

모든 릴리스는 [Semantic Versioning](https://semver.org/lang/ko/) 을 따른다. `-mvp` suffix 는
아직 풀스펙 (사용자 개인 방법론 docset) 으로 수렴하지 않은 최소 배포판임을 표시.

## [0.4.0-mvp] — 2026-04-29

`/sfs` 슬래시 커맨드 6 명령 완성 (status / start / plan / review / decision / retro).

### Added

- **`/sfs plan`** — 현재 sprint 의 `plan.md` 를 phase=plan 으로 열고 `last_touched_at` 자동 기록. `events.jsonl` 에 `plan_open` 이벤트 append.
- **`/sfs review --gate <id>`** — review.md 를 phase=review / gate=`<id>` 로 열고 `events.jsonl` 에 `review_open` 이벤트 append. Gate id 7-enum (`G-1, G0, G1, G2, G3, G4, G5`) 검증 + 직전 review_open 으로부터 자동 추론 fallback.
- **`/sfs decision`** — ADR 신설 (full template) 또는 sprint-local mini-ADR (light template) 자동 분기. `decisions/` 디렉토리 + `decisions-template/` 신설.
- **`/sfs retro --close`** — sprint retro G5 close + auto-commit. `decision-light.md` 템플릿 신설.
- **`.sfs-local/decisions-template/`** — `ADR-TEMPLATE.md` + `_INDEX.md` 신규 슬롯.
- **`.sfs-local/sprint-templates/decision-light.md`** — sprint-local mini-ADR 템플릿.

### Changed

- **`.claude/commands/sfs.md`** — adapter dispatch 6-row (status / start / plan / review / decision / retro). Bash adapter 가 single source of truth, Claude paraphrase fallback 은 script 부재 시만 동작.
- **`sfs-common.sh`** — `validate_gate_id` (7-enum), `infer_last_gate_id` (events.jsonl scan), `update_frontmatter` (BSD/GNU portable awk-based) helper 추가. `next_decision_id` / `sprint_close` / `auto_commit_close` (decision/retro 보조).

### Fixed

- **`upgrade.sh` rollback backup staging** — backup+overwrite 산출물을 `.sfs-local/tmp/upgrade-backups/` 로 이동하고 `.sfs-local/**/*.bak-*` 를 ignore. 근거: 0.3.1→0.4.0 upgrade 재현 시 기존 설계는 권장 `git add .sfs-local/` 가 rollback `.bak-*` 파일을 함께 stage 했음.
- **`upgrade.sh` executable bit** — README/usage 의 직접 실행 경로(`~/tmp/solon-mvp/upgrade.sh`)와 맞도록 배포 파일 실행 비트 복구.

### Notes

- 7-Gate enum + verdict 3-value (`pass` / `partial` / `fail`) 는 `gates.md` §1/§2 verbatim 정합.
- `events.jsonl` 형식은 0.3.0-mvp 와 호환.

## [0.3.1-mvp] — 2026-04-29

Release blocker hotfix.

### Fixed

- 0.3.0-mvp 직후 발견된 release-blocker 3건 + auxiliary scripts executable bit 정정.

## [0.3.0-mvp] — 2026-04-29

`/sfs status` + `/sfs start` 도입 (Claude paraphrase → bash adapter SSoT 전환).

### Added

- **`/sfs status`** — 현재 sprint / WU / 마지막 gate / git ahead / last_event 한 줄 출력. `--color=auto/always/never` 지원.
- **`/sfs start [<sprint-id>]`** — sprint 디렉토리 초기화 (`<YYYY-Wxx>-sprint-<N>` ISO week 자동 명명) + 4 templates (plan / log / review / retro) 복사 + `events.jsonl` 에 `sprint_start` 이벤트 append.
- **`.sfs-local/scripts/`** — `sfs-common.sh` (state reader / event append helper), `sfs-status.sh`, `sfs-start.sh` 3 종 bash adapter.
- **`.sfs-local/sprint-templates/`** — `plan.md` (phase=plan / gate=G1) + `log.md` (phase=do) + `review.md` (phase=review) + `retro.md` (phase=retro / gate=G5) 4 종.

### Changed

- **`.claude/commands/sfs.md`** — adapter dispatch 도입. `status` / `start` 는 bash adapter 가 SSoT. Claude-driven fallback 은 script 부재 시만 동작 (graceful degradation).
- 출력 형식은 `WU22-D4 deterministic output rule` 정합 (Claude 재해석 금지).

### Notes

- Sprint id 패턴 `<YYYY-Wxx>-sprint-<N>` 은 ISO 8601 week 기반. `--force` 로 충돌 시 덮어쓰기.

## [0.2.4-mvp] — 2026-04-24

### Fixed

- **upgrade.sh** — `prompt()`가 프롬프트 문구를 stdout으로 출력해 기본값 Enter가 취소로 처리되던 문제 수정.

## [0.2.3-mvp] — 2026-04-24

### Changed

- **upgrade.sh** — checksum 기반 자동 적용 정책으로 전환. 파일별 추가 질문 없이 신규 파일 설치,
  managed 파일 backup+overwrite, 프로젝트 지침 파일 보존을 자동 수행.

## [0.2.2-mvp] — 2026-04-24

### Changed

- **upgrade.sh** — 프리뷰 마지막에 사용자가 실제로 누를 키와 기본값 의미를 명시.

## [0.2.1-mvp] — 2026-04-24

### Changed

- **upgrade.sh** — 변경 프리뷰를 line diff 대신 checksum 기반으로 표시.
- **upgrade.sh** — 파일별 추천 선택(`install`, `skip`, `backup+overwrite`)과 checksum 값을 함께 출력.
- **upgrade.sh** — non-TTY dry-run 에서 `/dev/tty` 경고가 노출되지 않도록 보정.

## [0.2.0-mvp] — 2026-04-24

### Added

- **templates/SFS.md.template** — Claude Code / Codex / Gemini CLI 가 공유하는 공통 SFS core 지침.
- **templates/AGENTS.md.template** — Codex adapter 추가.
- **templates/GEMINI.md.template** — Gemini CLI adapter 추가.

### Changed

- **templates/CLAUDE.md.template** — 전체 방법론 복제 대신 `SFS.md` 를 참조하는 Claude Code adapter 로 축소.
- **install.sh / upgrade.sh / uninstall.sh** — SFS core + Claude/Codex/Gemini adapter 파일을 함께 관리.
- **README.md** — runtime abstraction 을 MVP 범위로 명시하고 런타임별 사용법 추가.

## [0.1.1-mvp] — 2026-04-24

### Added

- **templates/.claude/commands/sfs.md** — Claude Code 프로젝트 slash command (`/sfs`) 추가.
  `status/start/plan/sprint/review/decision/log/retro` 모드로 `.sfs-local/` 기반 SFS 운용.

### Changed

- **install.sh** — consumer 프로젝트에 `.claude/commands/sfs.md` 를 설치하도록 확장.
- **/sfs command** — `/sfs` 또는 `/sfs help` 실행 시 사용법과 추천 첫 명령을 함께 안내.
- **README.md** — 설치 후 시작 명령을 `/sfs status` / `/sfs start` 중심으로 갱신.

## [0.1.0-mvp] — 2026-04-24

### Added

- **install.sh** — dual-mode 설치 스크립트 (`curl | bash` + local exec). 대화형 파일 충돌 처리
  (skip / backup / overwrite / diff). `.sfs-local/` merge 모드 (기존 sprint 산출물 보존).
  `.gitignore` 마커 기반 idempotent append.
- **upgrade.sh** — consumer `.sfs-local/VERSION` 와 distribution VERSION 비교. 파일별 diff
  미리보기 + 대화형 갱신.
- **uninstall.sh** — `.sfs-local/` 제거 + `.gitignore` 블록 제거. sprint 산출물 보존 옵션.
- **templates/CLAUDE.md.template** — 도메인 중립 (관리자 페이지 특화 제거). 7-step flow + 4
  Gate 운용 + 6 본부 abstract/active 구조만 포함.
- **templates/.gitignore.snippet** — `.sfs-local/events.jsonl` + `.sfs-local/tmp/` 등
  Solon 운영 파일 규칙. 프로젝트 일반 개발 규칙 (node_modules 등) 은 제외 (consumer 가 이미
  가지고 있을 가능성 높음, 중복 append 방지).
- **templates/.sfs-local-template/** — `divisions.yaml` + `events.jsonl` + `sprints/.gitkeep`
  + `decisions/.gitkeep` 스캐폴드.

### Scope 확정

- `solon-mvp` repo 정체: **Solon/SFS 시스템의 설치 가능한 MVP 배포**. consumer 프로젝트가
  `install.sh` 로 Solon 을 주입받아 7-step flow 운용 가능.
- consumer 프로젝트 자체는 별도 repo. `solon-mvp` 는 도구, consumer 는 도구 사용자.

### 이전 세션 (Solon docset WU-17/18/19) 과의 연결

- Solon docset `2026-04-19-sfs-v0.4/phase1-mvp-templates/` 가 본 distribution 의 모태.
  WU-18/19 에서 만든 setup-w0.sh / verify-w0.sh 는 `solon-mvp` repo **내부에서는 제거** —
  이 둘은 "consumer 프로젝트 처음 생성" 용이므로 distribution repo 에는 부적합.
- setup/verify 스크립트 기능은 `install.sh` 에 대화형 + idempotent 형태로 재흡수.

## Unreleased (예정)

- **foundation note** — 7-step flow 가 full startup team-agent artifact chain 의 lightweight projection 임을 README / SFS template / installer banner 에 명시. Production open 전 Release Readiness evidence 를 review 또는 retro-light 에 남기도록 보강.
- **0.3.0** — `install.sh` 원격 모드 (`curl | bash`) 에 따른 보안 강화 (hash 검증).
- **0.4.0** — `claude plugin install solon` 네이티브 플러그인 변환 검토 (HANDOFF §0 #13 end-state).
