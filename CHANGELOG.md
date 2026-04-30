## [0.5.10-product] - 2026-04-30

**Interactive executor auth bootstrap fix.** `--auth-interactive` now attaches Codex/Claude/Gemini
login output directly to `/dev/tty` instead of hiding prompts in temp files while resolving the
executor command.

### Fixed

- **visible auth prompts** — browser/device/login prompts are shown in the user terminal during
  `--auth-interactive`; stdout is kept out of `EXECUTOR_CMD` command substitution.
- **clear bootstrap failure** — failed auth bootstrap now reports directly without pointing users
  to hidden temp files.

## [0.5.9-product] - 2026-04-30

**G0 brainstorm command and flow correction.** `/sfs start` remains the sprint workspace
scaffold command, while `/sfs brainstorm` becomes the explicit G0 context-capture command before
`/sfs plan`.

### Added

- **`/sfs brainstorm` command** — `.sfs-local/scripts/sfs-brainstorm.sh` creates or updates the
  active sprint's `brainstorm.md`, accepts raw/multiline context via `--stdin` or quoted args,
  appends a `brainstorm_open` event, and prints the artifact path.
- **`brainstorm.md` sprint template** — G0 artifact with raw brief, problem space, constraints,
  options, scope seed, plan seed, and generator/evaluator contract seed sections.
- **3 C-Level personas** — managed defaults for CEO, CTO Generator, and CPO Evaluator under
  `.sfs-local/personas/`.

### Changed

- **flow contract** — product docs/adapters now use `start → brainstorm → plan` as the intended
  first flow. `start` scaffolds the sprint, `brainstorm` captures context, `plan` turns it into the
  sprint contract.
- **C-Level sprint contract** — `plan.md` now frames the flow as CEO requirements/plan →
  CTO Generator ↔ CPO Evaluator contract → CTO implementation → CPO review → CTO rework/final
  confirmation → retro.
- **CPO review entrypoint** — `/sfs review` now appends a CPO Evaluator prompt to `review.md`,
  records `evaluator_executor` / `generator_executor`, and supports configurable review tools via
  `--executor` while keeping CPO review mandatory.
- **review executor bridge** — `/sfs review --run` now attempts an actual CPO bridge invocation
  (`codex`, `codex-plugin`, `gemini`, `claude`, or custom command). Missing bridges fail closed
  instead of leaving misleading metadata.
- **local executor auth env** — `.sfs-local/auth.env.example` documents gitignored headless
  credential handoff for Codex/Claude/Gemini. SFS loads `.sfs-local/auth.env` when present, checks
  named executor auth before prompt handoff, and supports explicit `--auth-interactive` bootstrap
  when the user discovers missing auth during review.
- **asymmetric bridge policy** — Claude → Codex may use a Claude-side Codex plugin/manual bridge
  or Codex CLI, while Codex → Claude uses Claude CLI or prompt handoff. `claude-plugin` is
  explicitly unsupported because Codex is not a Claude plugin host.
- **start scaffold** — `/sfs start` now copies `brainstorm.md` along with plan/log/review/retro.
- **newline handling** — `sfs-dispatch.sh` still rejects newline args for deterministic commands, but
  permits them for `brainstorm` so pasted raw requirements can be captured instead of dropped.

## [0.5.7-product] - 2026-04-30

**`/sfs guide` default context briefing.** Bare `/sfs guide` should orient the user, not dump a
full Markdown document and not merely print a file path.

### Changed

- **guide default UX** — `.sfs-local/scripts/sfs-guide.sh` now prints a compact context briefing:
  what Solon adds, which files the user should edit first, the first command flow, and where to
  find the full guide.
- **full guide preserved** — `/sfs guide --print` still prints the complete Markdown onboarding
  document. `/sfs guide --path` still prints only the guide path.

## [0.5.6-product] - 2026-04-30

**Local product clone freshness guard.** 실제 사용자는 `~/tmp/solon-product` 같은 로컬 clone 을
install/upgrade source 로 쓰므로, GitHub release 와 이 clone 이 어긋나면 `upgrade.sh` 가
낡은 VERSION 을 읽고 "이미 최신" 으로 오판할 수 있었다.

### Fixed

- **local clone stale guard** — `upgrade.sh` local mode 에서 source clone 이
  `MJ-0701/solon-product` GitHub main 보다 뒤처졌는지 `git fetch` 로 먼저 확인하고, 뒤처졌으면
  `git -C <clone> pull --ff-only --tags` 후 재실행하라고 중단한다.
- **consumer/developer path separation** — README/GUIDE 에 `~/agent_architect` (dev SSoT),
  `~/workspace/solon-mvp` (owner stable release clone), `~/tmp/solon-product` (사용자 install/upgrade
  source clone) 역할을 혼동하지 않도록 local clone upgrade 전 최신화 절차를 명시.

## [0.5.5-product] - 2026-04-30

**Codex desktop app `/sfs` canonical path 복구.** `/sfs ...` 메시지가 Codex desktop app /
compatible Codex surface 에서 모델 또는 Skill 까지 도달하면, 그 순간 정상 Solon command 로
간주하고 bash adapter 로 즉시 dispatch 하도록 Skill/AGENTS/README/GUIDE/install 안내를 강화.

### Fixed

- **Codex app `/sfs` unsupported 오판 방지** — 모델이 `/sfs ...` 메시지를 읽을 수 있으면 이미
  runtime parser 를 통과한 것이므로 `unsupported command` 로 답하지 않고 `.sfs-local/scripts/sfs-dispatch.sh`
  로 내려보내도록 Codex Skill 과 AGENTS adapter template 에 명시.
- **Codex CLI gap 범위 축소** — bare `/sfs` 가 native slash parser 에서 차단되는 경우만
  Codex CLI adaptor compatibility gap 으로 분류. `$sfs ...`, `sfs ...`, 자연어, direct bash 는
  그 blocking build 에서만 쓰는 임시 bypass 로 유지.
- **install/onboarding 문구 정렬** — Codex app 은 `/sfs status` 정상 1급 경로로 안내하고,
  command chip 표시 여부와 Solon dispatch 가능 여부를 분리해서 설명.

## [0.5.4-product] - 2026-04-30

- (release cut → stable 2baee1d)

# CHANGELOG — Solon Product

모든 릴리스는 [Semantic Versioning](https://semver.org/lang/ko/) 을 따른다. suffix 규약:
- `-mvp` (0.5.0-mvp 까지) — 풀스펙 (사용자 개인 방법론 docset) 으로 수렴하지 않은 최소 배포판.
- `-product` (0.5.1+) — Solon Product 로 rebrand 후 외부 onboarding 가능한 단계. repo identity 와 release suffix 는 product track 기준.

## [0.5.3-product] — 2026-04-30

**`/sfs guide` command.** 0.5.2-product 의 외부 onboarding guide 를 설치된 consumer 프로젝트 안에서
바로 발견하고 출력할 수 있도록 8번째 deterministic bash adapter command 를 추가.

### Added

- **`/sfs guide` command** — `.sfs-local/scripts/sfs-guide.sh` 신설. 기본 출력은 `guide.md ready: .sfs-local/GUIDE.md`, `--path` 는 path only, `--print` 는 guide 본문 출력.
- **managed guide asset** — install/upgrade 가 `.sfs-local/GUIDE.md` 와 `sfs-guide.sh` 를 managed asset 으로 설치/갱신. consumer root 의 `GUIDE.md` 와 충돌하지 않도록 `.sfs-local/` 아래에 둠.
- **8-command adapter parity** — Claude Code / Codex Skill / Codex prompt / Gemini CLI / SFS core template 의 dispatch table 을 `status/start/guide/plan/review/decision/retro/loop` 로 정렬.
- **runtime adaptor dispatcher** — `.sfs-local/scripts/sfs-dispatch.sh` 신설. `/sfs`, `$sfs`, `sfs` runtime surface 를 normalize 한 뒤 `sfs-<command>.sh` 로 dispatch 해서 vendor별 문서/Skill의 command mapping drift 를 줄임.
- **Windows PowerShell wrappers** — `install.ps1` / `upgrade.ps1` / `uninstall.ps1` 과 installed `.sfs-local/scripts/sfs.ps1` 를 추가. Windows PowerShell 사용자는 Git for Windows 의 Git Bash 를 통해 동일한 bash adapter SSoT 로 내려간다. WSL 사용자는 WSL shell 안에서 bash adapter 를 직접 호출한다.

### Fixed

- **Codex CLI `/sfs` adapter gap 분류** — `/sfs` 는 Solon 의 public command surface 로 유지한다. 다만 현재 `codex-cli 0.125.0` TUI 는 unknown leading slash 를 model/Skill 전에 차단하므로, 이 문제를 사용자 호출법 차이가 아니라 Codex CLI runtime adapter compatibility gap 으로 명시. `$sfs ...`, `sfs ...`, 자연어, direct bash 는 임시 bypass/fallback 이며 parity 완료 상태가 아니다. `~/.codex/prompts/sfs.md` 는 지원 build 에서만 쓰는 optional/legacy `/prompts:sfs ...` fallback 으로 격하.
- **Codex desktop app `/sfs` 보존 명시** — `/sfs ...` 가 모델/Skill 에 도달하는 Codex desktop app / compatible surface 는 정상 1급 경로로 유지한다. CLI native parser 가 선점하는 build 에서만 gap 으로 분류한다.
- **`/sfs start <goal>` runtime contract 복구** — `sfs-start.sh` 가 free-text goal 을 받고, custom sprint id 는 `--id <sprint-id>` 로 분리한다. 단일 old-style `*sprint-*` positional id 는 하위 호환으로 유지한다.
- **uninstall managed entry cleanup** — uninstall 이 `.gemini/commands/sfs.toml`, `.agents/skills/sfs/SKILL.md`, `.sfs-local/scripts`, sprint/decision templates, installed guide 까지 scaffold 제거 대상으로 인식한다.

## [0.5.2-product] — 2026-04-30

**External onboarding guide + release-note hygiene.** 0.5.1-product 로 product rebrand baseline 을
정렬한 뒤, 실제 첫 외부 사용자 onboarding 에 필요한 30분 walk-through 를 stable 배포판에 포함.
동시에 release helper 의 CHANGELOG 중복 prepend 를 막아 tag 기준 release note 가 깨끗하게 남도록 보정.

### Added

- **`GUIDE.md` 신설 (외부 onboarding 30분 walk-through)** — 친구가 install.sh 실행 직후 처음 30분 안에 `SFS.md` placeholder 치환, 첫 sprint 시작, plan/review/decision/retro 흐름까지 따라가는 가이드. "SFS.md 에 프로젝트 스택 적어도 되는지" 같은 자주 묻는 mental model 오해 해소 + 7 슬래시 cheatsheet + multi-vendor (Claude/Codex/Gemini) parity 안내 + FAQ 5건 + 트러블슈팅 4건. README 와 함께 ship 되어 GitHub repo 첫 시선 영역에서 즉시 reference 가능.

### Fixed

- **README onboarding pointer** — Quickstart 직후와 Installed Files 표에서 `GUIDE.md` 를 바로 발견할 수 있게 연결.
- **release note hygiene** — `cut-release.sh` 가 이미 해당 버전 CHANGELOG entry 를 포함한 dev staging 을 stable 로 rsync 한 뒤 같은 버전의 자동 stub 을 한 번 더 prepend 하지 않도록 보정.

## [0.5.1-product] — 2026-04-30

**Codex stable hotfix narrative sync-back + multi-adaptor 1급 정합 통합.** 26th-2 의 0.5.0-mvp release cut (`99b2313`) 이 dev staging 의 mvp 본을 stable 에 rsync 하면서 codex 가 stable 에서 직접 작업한 product positioning narrative 3 commits (`ced9cc1` + `5765abb` + `7977a75`) 를 overwrite. 본 release 는 codex 의 narrative 개선분을 dev staging 으로 sync-back 하고 (R-D1 §1.13 정합), 본 cycle (26th-2) 의 multi-adaptor 1급 정합 (Codex Skills + Gemini commands + 7-Gate enum) 과 통합.

### Fixed (codex stable hotfix sync-back)

- **README product-facing rewrite** — 초안성/내부 농담 톤의 "친구야" 섹션을 제거하고, 제품 설명 → 문제 정의 → core model → quickstart → commands → 설치/업그레이드/제거 → 운영 원칙 순서로 재구성. 외부 독자가 Solon Product 를 제품으로 이해하고, Claude/Codex/Gemini runtime 계약을 같은 문서에서 확인할 수 있게 함. (`ced9cc1` + `7977a75` 의도 보존)
- **README product-level hardening** — README 첫 화면에서 `MVP / private beta` 상태 문구와 "MVP 에서의 형태" 같은 최소 배포판 중심 표현을 제거하고, product promise / operating model / product surface / safety contract 중심으로 재구성. 0.5.1-product 부터 repo identity 가 제품을 대표.
- **public terminology cleanup** — 외부 독자가 뜻을 추측해야 하는 내부자 약어를 `기준 문서` / `기준 구현` 으로 치환. README, CHANGELOG, consumer 템플릿, runtime script comment 에서 후속 agent 가 같은 용어로 정합성을 확인할 수 있게 함.
- **`/sfs start <goal>` contract** — `sfs-start.sh` 가 free-text goal 을 받도록 변경되어 있고, custom sprint id 는 `--id <sprint-id>` 로 분리. canonical old-style sprint id 한 개 입력은 하위 호환으로 유지. README/Claude/Codex/Gemini adapter 가 이미 start 를 goal 기반 명령으로 설명하고 있었던 것과 정합.
- **`upgrade.sh` runtime asset sync** — upgrade preview/apply 대상에 `.sfs-local/scripts/`, `.sfs-local/sprint-templates/`, `.sfs-local/decisions-template/` 가 포함됨. `.claude/commands/sfs.md` 는 bash adapter 를 dispatch 하는 얇은 layer 이므로, adapter 문서만 갱신하고 실제 script/template 을 갱신하지 않으면 0.3.x consumer 가 0.4.x+ 명령을 사용할 수 없는 문제 회피.
- **non-TTY upgrade/uninstall handling** — upgrade 는 `/dev/tty` 를 열 수 없으면 멈추고, 자동 진행은 `--yes` 명시 시에만 허용. uninstall 도 동일.
- **decision JSONL integrity** — `json_escape` helper + parser-backed `events.jsonl` validation 추가, decision title/path/id 를 escape 해서 따옴표가 들어간 제목도 valid JSONL.
- **distribution hygiene** — consumer 템플릿의 도메인/스택 고정 예시를 중립 표현으로 정리.
- **artifact contract docs** — runtime 이 실제 생성하는 `plan.md` / `log.md` / `review.md` / `retro.md` 와 SFS/adapter 템플릿 설명 일치.
- **local executable path** — `upgrade.sh` / `uninstall.sh` 실행 권한을 설치 스크립트와 맞추고, README 는 `bash <script>` 형식도 명시.
- **maintenance history contract** — root `AGENTS.md` / `CLAUDE.md` 에 모든 파일 수정 시 `CHANGELOG.md` 의 Unreleased 또는 해당 릴리스 섹션에 변경 범위, 변경 이유, 검증 결과를 남기는 규칙을 명시.
- **repository rename** — GitHub repository rename 에 맞춰 배포 repo identity 와 remote URL 을 `MJ-0701/solon-product` 로 변경. README one-liner, install/upgrade remote clone source, local clone 예시, issue/changelog 링크, root agent 지침을 새 repo 이름으로 정렬.

### Added (본 cycle multi-adaptor 1급 정합 통합 + 0.5.1-product 신설)

- **legacy GIT_MARKER fallback** — `install.sh` / `upgrade.sh` / `uninstall.sh` 모두 `LEGACY_GIT_MARKER_BEGIN/END="### BEGIN/END solon-mvp ###"` 상수 보유. `.gitignore` 갱신 영역에서 legacy marker 감지 시 product marker 로 자동 교체 (idempotent rename). consumer 가 0.5.0-mvp 이전 install 한 프로젝트도 `upgrade.sh` 실행 시 자동 정합.
- **Codex Skill (project-scoped)** — `templates/.agents/skills/sfs/SKILL.md` 신설 (agentskills.io 표준 호환, frontmatter `name: sfs` + `description` + body). Codex CLI / IDE / app 모두에서 implicit invocation (자연어 매칭) + explicit invocation (`$sfs status`) 양쪽 작동. `install.sh` 가 자동 install.
- **Gemini CLI native slash** — `templates/.gemini/commands/sfs.toml` 신설 (TOML format, `prompt` + `description` + `{{args}}` placeholder). Gemini CLI 에서 `/sfs status` native slash 1급. `install.sh` 가 자동 install.
- **Codex user-scoped slash fallback (optional)** — `templates/.codex/prompts/sfs.md` 신설. install.sh 가 user `$HOME` 에 자동 cp 하지 않음 (사용자 영역 보호) — manual cp 안내.
- **`scripts/cut-release.sh` semver 검증 확장** — 정규식 `^[0-9]+\.[0-9]+\.[0-9]+-(mvp|product)$`. -product suffix release 통과.

### Changed

- **Solon-wide multi-adaptor narrative 정합** — runtime adapter template 4 종 (`SFS.md.template` / `CLAUDE.md.template` / `AGENTS.md.template` / `GEMINI.md.template`) 모두 7 슬래시 명령 전체에 대해 bash adapter 직접 호출 안내. paraphrase 금지, 결정성 유지. Claude Code / Codex / Gemini CLI 가 동등 1급 (이전: Claude Code 만 dispatch table 명시 + Codex/Gemini 는 paraphrase only).
- **VERSION** — `0.5.0-mvp` → `0.5.1-product`. `-mvp` → `-product` rebrand 후 첫 정합 baseline.

### Notes

- 0.5.0-mvp tag (`v0.5.0-mvp`) 는 외부 노출 미흡 상태로 남음 (rename + narrative 회귀 영향). 0.5.1-product 가 외부 onboarding 정합 baseline.
- 본 release 의 핵심 = codex 의 product positioning narrative 를 R-D1 §1.13 hotfix sync-back path 따라 dev staging 으로 동기화 + 본 cycle (26th-2) 의 multi-adaptor 1급 정합 통합. 단순 string rename 이 아님.

### Design Notes

- `.sfs-local/scripts/`, `.sfs-local/sprint-templates/`, `.sfs-local/decisions-template/` 는 배포판 관리 영역. consumer 산출물인 `.sfs-local/sprints/`, `.sfs-local/decisions/`, `.sfs-local/events.jsonl` 과 달리 upgrade 때 overwrite 해도 사용자 작업을 덮지 않는다.
- `/sfs start` 의 primary argument 는 **goal**. sprint id 는 시스템이 생성하고, 사람이 꼭 지정해야 할 때만 `--id` 를 쓴다.
- product rename 후에도 consumer 하위 호환성을 위해 `.gitignore` legacy marker `### BEGIN solon-mvp ###` / `### END solon-mvp ###` 는 install/upgrade/uninstall 에서 계속 인식한다.

## [0.5.0-mvp] — 2026-04-29

**Solon-wide multi-adaptor invariant 정합 + `/sfs loop` 추가.** Solon 의 7 슬래시 명령 전체가
Claude Code / Codex / Gemini CLI 어느 1급 환경에서든 동등한 bash adapter SSoT 로 동작하도록
runtime adapter (CLAUDE / AGENTS / GEMINI / SFS template) narrative 정합. `/sfs loop` 는 그
invariant 의 첫 LLM-호출 site 로 Ralph Loop + Solon mutex + executor convention 을 정착.

### Added

- **`/sfs loop`** — Ralph Loop 패턴 + Solon `domain_locks` mutex 기반 자율 iter loop. `cmd_loop_run` (단일 worker) / `cmd_loop_coord` (다중 worker spawn) / `cmd_loop_status` / `cmd_loop_stop` / `cmd_loop_replay` 5 sub-command.
- **Multi-worker coordinator** — `--parallel <N>` + `--isolation process|claude-instance|sub-session` (현재 `process` 만 active) + auto-codename (adjective-adjective-surname) + Worker Independence Invariant 강제 (`--no-mental-coupling` default).
- **Pre-execution review gate** — `--review-gate` (default on) PLANNER (CEO) + EVALUATOR (CPO) 페르소나 호출. 페르소나 파일 부재 시 `_builtin_persona_text` fallback (planner/evaluator known kind 만, 그 외는 fail-closed rc=99). `is_big_task` 5 criteria (wall_min ≥10 / files_touched ≥3 / decision_points ≥1 / spec_change / visibility_change).
- **Optimistic locking + 4-state FSM** — `claim_lock` / `release_lock` / `mark_fail` / `mark_abandoned` / `auto_restart` / `escalate_w10_todo`. `mkdir`-based atomic claim 으로 TOCTOU race 차단 (POSIX-portable, macOS+Linux 양립). Status 4-state = `PROGRESS` / `COMPLETE` / `FAIL` / `ABANDONED`. `retry_count >= 3` → ABANDONED + auto W10 escalate.
- **Pre-flight check** — `pre_flight_check` PROGRESS.md drift (90분 임계, exit 3) + `.git/index.lock` warn + staged diff warn + YAML frontmatter parse.
- **`SFS_LOOP_LLM_LIVE` env** — live LLM 호출 모드 gating. CLI shape 미해결 (claude/gemini/codex stdin/flag/exit parsing 차이) 영역 = `live=1` 시 fail-closed (rc=99) 로 silent degradation 차단. `live=0` (default) = MVP stub PASS-with-conditions.

### Changed

- **Solon-wide multi-adaptor 1급 정합** — Claude Code 외에 Codex / Gemini CLI 도 native slash entry point 1급 등록 (이전: Claude Code 만 `.claude/commands/sfs.md` 1급, Codex/Gemini 는 paraphrase only):
  - **`templates/.gemini/commands/sfs.toml`** (신설) — Gemini CLI native custom command (TOML format, `prompt` + `description` + `{{args}}` placeholder). `.gemini/commands/sfs.toml` 자동 install → `gemini` 에서 `/sfs status` native slash 1급.
  - **`templates/.agents/skills/sfs/SKILL.md`** (신설) — Codex Skill (project-scoped, `.agents/skills/sfs/`). frontmatter `name: sfs` + `description` + body. Codex CLI / IDE / app 모두에서 implicit invocation (자연어 매칭) + explicit invocation (`$sfs status`) 양쪽 작동. agentskills.io 표준 호환.
  - **`templates/.codex/prompts/sfs.md`** (신설, optional fallback) — Codex user-scoped slash (`~/.codex/prompts/sfs.md`). install.sh 가 user $HOME 에 자동 cp 하지 않음 (사용자 영역 보호) — 원하면 manual cp.
  - `install.sh` + `upgrade.sh` 모두 위 신규 slot 자동 install / upgrade. 기존 user 산출물 (sprints/decisions/events.jsonl) 보존.
- **Solon-wide multi-adaptor narrative 정합** — runtime adapter template 4 종 갱신 (`SFS.md.template` / `CLAUDE.md.template` / `AGENTS.md.template` / `GEMINI.md.template`):
  - 7 슬래시 명령 전체에 대해 **bash adapter (`.sfs-local/scripts/sfs-*.sh`) 직접 호출** 안내. paraphrase 금지, 결정성 유지. Claude Code / Codex / Gemini CLI 가 동등 1급.
  - 7-Gate enum (G-1..G5) + verdict 3-enum (pass/partial/fail, G3 만 binary) 표기 — 4-Gate 축소판 narrative 폐기.
  - 산출물 5 파일 (brainstorm / plan / log / review / **retro** = `retro.md`, 옛 `retro-light.md` 폐기) + decisions full ADR (decisions-template/ADR-TEMPLATE.md, 5-section) + mini-ADR (sprint-templates/decision-light.md) 양쪽 도입 명시.
  - `--executor claude|gemini|codex|<custom>` LLM CLI 선택 + `SFS_EXECUTOR` env + custom passthrough 가 Solon-wide invariant 임을 SFS / AGENTS / GEMINI 양쪽에 명시.
- **`.claude/commands/sfs.md`** — adapter dispatch 7-row (status / start / plan / review / decision / retro / **loop**). `loop` 도 deterministic bash adapter SSoT 로 합류.
- **`sfs-common.sh`** — WU-27 helpers 11종 추가 (`resolve_executor`, `resolve_progress_path`, `pre_flight_check`, `_domain_locks_field`, `detect_stale`, `claim_lock`, `release_lock`, `mark_fail`, `mark_abandoned`, `auto_restart`, `escalate_w10_todo`, `is_big_task`, `_builtin_persona_text`, `review_with_persona`, `submit_to_user`, `cascade_on_fail`).

### Notes

- `/sfs loop` MVP = stub 모드 (PROMPT.md 부재 시 LLM 호출 skip). 실 LLM 호출은 `SFS_LOOP_LLM_LIVE=1` 명시 + executor CLI shape 결정 후속 (`WU27-D6`).
- Pre-execution review gate 는 `agents/planner.md` + `agents/evaluator.md` 페르소나 파일 우선, 부재 시 known kind 만 built-in fallback. 알 수 없는 페르소나 이름 = fail-closed (review 의미 왜곡 방지).
- 도메인 lock 은 host `PROGRESS.md` frontmatter `domain_locks.<X>` block 직접 manipulation. python3 (preferred) 또는 awk fallback.
- multi-adaptor 정합은 0.2.0-mvp 부터 설계 의도였으나 runtime adapter narrative 가 vendor-asymmetric (Claude Code 1급 / Codex+Gemini paraphrase only) 으로 drift 됐던 것을 본 release 에서 정합 회복.

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
- **0.6.0** — `/sfs loop` live LLM 호출 site (`SFS_LOOP_LLM_LIVE=1` 활성) — claude/gemini/codex CLI shape 결정 후 wire (`WU27-D6`).
- **0.6.x** — consumer mirror (Solon docset → consumer .sfs-local mirror 자동 sync, `WU-28 D3`).
- **0.7.0** — `claude plugin install solon` 네이티브 플러그인 변환 검토.
- **install.sh 원격 모드 보안 강화** — `curl | bash` 에 hash 검증 추가.
