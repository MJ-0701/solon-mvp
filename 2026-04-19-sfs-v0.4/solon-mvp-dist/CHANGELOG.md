# CHANGELOG — Solon MVP

모든 릴리스는 [Semantic Versioning](https://semver.org/lang/ko/) 을 따른다. `-mvp` suffix 는
아직 풀스펙 (사용자 개인 방법론 docset) 으로 수렴하지 않은 최소 배포판임을 표시.

## [0.2.0-mvp] — 2026-04-24 (WU-20 Phase A 보강)

### Added — runtime-neutral core + 3 adapter

- **templates/SFS.md.template** 🆕 — runtime-agnostic core. 7-step flow / 4 Gate /
  산출물 규칙 / 6 본부 / 관찰성 / `/sfs` prefix 정의의 **단일 출처**. Claude/Codex/Gemini
  모두 공통으로 읽음.
- **templates/AGENTS.md.template** 🆕 — OpenAI Codex CLI adapter (thin). Codex 가 repo
  instructions 로 자동 로드. `/sfs` 는 natural-language alias (native slash command 아님).
- **templates/GEMINI.md.template** 🆕 — Google Gemini-CLI adapter (thin). project
  instruction context 로 로드. long context 활용 힌트 포함.
- **templates/.claude-template/commands/sfs.md** 🆕 — Claude Code 용 `/sfs` slash
  command 정의. install.sh 가 `.claude/commands/sfs.md` 로 복사. subcommand 6종
  (status / brainstorm / plan / review / retro / decision).

### Changed — CLAUDE.md.template → thin adapter 로 재작성

- **templates/CLAUDE.md.template** — 기존 7-step / Gate / 산출물 본문 제거 → SFS.md
  위임. Claude-specific 힌트 (Task tool / sub-agent / MCP / 모델 tier) 만 유지.
  thin adapter 원칙 유지 (SFS.md 본문 중복 복사 금지).

### Changed — install.sh / upgrade.sh / uninstall.sh 확장

- **install.sh** — SFS.md + 3 adapter + `.claude/commands/sfs.md` 복사 로직 추가.
  placeholder 치환 helper (`substitute_placeholders`) 로 리팩터. 배너 / 완료 메시지에
  3 runtime 진입 예시 추가.
- **upgrade.sh** — diff 대상 확장 (SFS.md / CLAUDE.md / AGENTS.md / GEMINI.md /
  `.claude/commands/sfs.md` / divisions.yaml).
- **uninstall.sh** — 4 adapter + slash command 파일 각각 대화형 삭제. `.claude/` 빈
  디렉토리 자동 정리.

### Scope — MVP 범위 정정 반영 (RUNTIME-ABSTRACTION.md v0.2-mvp-correction 대응)

- Solon docset `RUNTIME-ABSTRACTION.md` 의 `rule/mvp-runtime-neutral-core` 에 따라
  **MVP 배포 시점부터** SFS core 와 runtime adapter 가 분리된 형태로 제공.
- 기존 v0.1.0-mvp 는 CLAUDE.md 단일 파일에 플로우 + Claude-specific 가 섞여 있어
  Claude lock-in 위반이었음. 본 v0.2.0-mvp 가 정정 적용.
- SDK/plugin 수준 adapter (OpenAI Agents SDK / Gemini SDK / `claude plugin install`)
  는 후속 릴리스로 유지.

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

- **0.3.0-mvp** — `install.sh` 원격 모드 (`curl | bash`) 에 따른 보안 강화 (hash 검증) +
  `sfs.sh` 폴리필 CLI (runtime 밖에서도 `.sfs-local/` 조회).
- **0.4.0-mvp** — SDK/plugin 수준 runtime adapter (OpenAI Agents SDK / Gemini SDK)
  편입 판정 (RUNTIME-ABSTRACTION.md §7 기준 충족 시).
- **0.5.0** — `claude plugin install solon` 네이티브 플러그인 변환 검토 (HANDOFF §0
  #13 end-state).
