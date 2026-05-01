<!-- entry-min: keep latest full; older condensed -->

## Unreleased

**Entry-time doc token trim.** Keeps the default `/sfs guide` and release-history surface lean,
while preserving full detail under `archives/`.

### Changed

- **`GUIDE.md` slimmed** — `/sfs guide --print` now prints an entry-lean onboarding summary.
  The previous verbose guide is preserved at `archives/GUIDE.full.md`.
- **`CHANGELOG.md` condensed** — latest releases remain full; older releases collapse to
  version headings + summary. Full notes are preserved at `archives/CHANGELOG.full.md`.

## [0.5.57-product] - 2026-05-02

**Windows Scoop one-shot upgrade hotfix.** Tightens the Windows wrapper path so
Scoop installs can behave like Homebrew installs when users run `sfs upgrade`.

### Fixed

- **Scoop self-upgrade from Windows wrappers** — `sfs.cmd upgrade` and
  `sfs.ps1 upgrade` now run `scoop update` + `scoop update sfs` first when the
  runtime is installed under Scoop, then reload the updated runtime before
  refreshing the current project.

## [0.5.56-product] - 2026-05-02

**Combined division activation, loop lifecycle, and artifact cleanup release.**
SFS now ships the finished loop-session work together with the hotfix that keeps
review retries and runtime backups out of the visible `.sfs-local/tmp/` tree.

### Added

- **`/sfs division` command** — users can list, activate, and deactivate
  abstract divisions such as QA, design, infra, and taxonomy while recording
  decision/event evidence.
- **Cycle-end division recommender** — `/sfs report --compact` and
  `/sfs retro --close` write marker-based recommendations into `report.md` and
  `retro.md` based on project size, domain count, review verdict, and repo
  signals.
- **Loop queue lifecycle docs** — `GUIDE.md` now documents pending/claimed/done/
  failed/abandoned state meaning and when to promote oversized retro-light notes
  into real sprint report/retro artifacts.

### Fixed

- **Review retry cleanup** — before `/sfs review` writes a new prompt/run for
  the same sprint and gate, prior matching prompt/run files move to
  `.sfs-local/archives/review-runs/`, leaving only the latest run set in tmp.
- **Runtime upgrade backups** — `sfs upgrade` now preserves overwritten managed
  files under `.sfs-local/archives/runtime-upgrades/` instead of
  `.sfs-local/tmp/upgrade-backups/`.
- **Agent adapter backups** — `sfs agent install` now preserves overwritten
  adapters under `.sfs-local/archives/agent-install-backups/` instead of
  `.sfs-local/tmp/agent-install-backups/`.

## [0.5.54-product] - 2026-05-01

**Windows auth executor UX hotfix.** Tightens the `/sfs auth` and review bridge
path for Windows users who have Claude CLI installed but only desktop apps for
Codex or Gemini.

### Fixed

- **Positional auth executor** — `/sfs auth login codex` now works in addition
  to `/sfs auth login --executor codex`.
- **App-only executor fallback** — missing Codex/Gemini CLI errors now explain
  that desktop/web apps are manual prompt-only fallback surfaces, not headless
  SFS executor bridges.
- **Windows Store Codex path guard** — SFS now rejects package-private
  `WindowsApps\OpenAI.Codex_...\app\resources\codex.exe` command overrides and
  points users to the App Execution Alias or another executable shim.
- **Windows smoke coverage** — the Scoop smoke workflow now exercises
  `sfs auth status codex` so auth argument parsing stays covered.

## [0.5.53-product] - 2026-05-01

**Implementation guardrails and publish hygiene.** Strengthens `/sfs
implement` with practical code-development guardrails and publishes the
user-facing glossary / release discipline docs now needed by the product
runtime.

### Added

- **`/sfs implement` 6-division guardrails** — implementation now records
  strategy-pm, taxonomy, design/frontend, dev/backend, QA, and infra guardrail
  coverage in `implement.md` and `log.md`.
- **Backend Transaction discipline** — Spring/JPA/Batch/external API and
  consistency work now treats transaction boundaries, `REQUIRES_NEW`, JPA
  first-level cache behavior, outbox/idempotency, Hikari pool pressure, and
  risk-matched tests as always-on checks.
- **Security / Infra / DevOps scale gate** — expensive checks are selected once
  per project/sprint as `light`, `full`, or `skip`; MVP-overkill work is
  recorded as `deferred` or `risk-accepted` instead of blocking implementation.
- **Product glossary docs** — acronym and division glossaries are included in
  the user-facing docs so new installs have the same language as the runtime.

### Changed

- **Publish discipline docs** — concurrent-session release guidance now makes
  final integration, main sync, Homebrew, and Scoop publish responsibilities
  explicit.
- **Scoop bucket URL docs** — product docs now point at the real Scoop bucket
  location.

## [0.5.52-product] - 2026-05-01

**Product documentation sync.** Publishes the Solon 10x value guide in the
packaged release archive so README links resolve from Homebrew and Scoop
installs.

### Added

- **`10X-VALUE.md` in release archives** — the product value guide is now part
  of the stable tagged package, matching the README link.

### Fixed

- **Release allowlist coverage** — release tooling now includes
  `10X-VALUE.md`, preventing future documentation-only package drift.

## [0.5.51-product] - 2026-05-01

**Legacy adoption visible-surface fix.** Tightens `sfs adopt --apply` for
over-documented projects where moving old files into an expanded archive still
leaves the IDE tree noisy.

### Fixed

- **Cold archives for legacy intake** — `adopt --apply` now collapses
  pre-existing sprint folders and expanded archive folders into `.tar.gz`
  files plus short manifests under `.sfs-local/archives/adopt/`, instead of
  leaving another visible document tree.
- **Dry-run disclosure** — `adopt` dry-run now prints
  `would_archive_existing_sprints` and `would_collapse_existing_archives` with
  the target tarball/manifest paths before any mutation.
- **Re-adopt safety** — when `legacy-baseline` already exists and another
  current sprint is active, `adopt --force` preserves that current sprint as
  post-adopt real work instead of archiving it with legacy workbench folders.

## [0.5.50-product] - 2026-05-01

**Legacy adoption release re-cut.** Publishes the `sfs adopt` feature under a
fresh immutable release tag after `v0.5.49-product` was found to already point
at an older stable commit.

### Changed

- **Release tag freshness** — the legacy project adoption runtime, docs, and
  adapter surface from `0.5.49-product` are now published behind
  `v0.5.50-product` so Homebrew can install the correct tarball without moving
  an existing tag.

## [0.5.49-product] - 2026-05-01

**Legacy project adoption.** SFS can now take over projects that predate SFS,
including both over-documented repos and repos with almost no documentation, by
creating a compact report-first baseline from git/code/docs signals.

### Added

- **`sfs adopt` command** — dry-run by default; with `--apply`, creates a
  `legacy-baseline` sprint containing only `report.md` and `retro.md` as the
  visible handoff entry.
- **Archived adoption evidence** — raw scan details such as recent commits,
  stack signals, high-change paths, docs/test counts, and submodule signals are
  preserved under `.sfs-local/archives/adopt/` instead of expanding the visible
  sprint folder.

### Changed

- **Legacy onboarding guidance** — README, GUIDE, SFS docs, and agent adapters
  now describe report-first adoption before starting the first real SFS sprint.
- **Adapter surface** — global CLI, vendored dispatch, upgrade packaging, Claude,
  Codex, and Gemini adapters recognize `adopt` as a first-class SFS command.


## Older releases (condensed)

Full details (all notes): [archives/CHANGELOG.full.md](./archives/CHANGELOG.full.md).

## [0.5.48-product] - 2026-05-01
**Persist agent model profile selections.** Fixes a regression where choosing
an agent model profile during `sfs upgrade` printed a confirmation but left
`.sfs-local/model-profiles.yaml` unchanged, causing the same question to appear
again on the next upgrade.

## [0.5.47-product] - 2026-05-01
**Short sprint references for tidy.** `sfs tidy --sprint` now accepts an exact
sprint id or a unique suffix reference, so users can type refs like
`W18-sprint-1` instead of the full `2026-W18-sprint-1` when the match is
unambiguous.

## [0.5.46-product] - 2026-05-01
**Document tidy command and release-note preflight.** SFS now has an explicit
cleanup command for completed sprint workbench docs, and release cuts require a
versioned changelog entry before publishing.

## [0.5.45-product] - 2026-05-01
**Upgrade command UX and SFS naming.** SFS is now explicitly documented as
Solo Founder System, while `sfs upgrade` becomes the recommended user-facing
command for checking package-manager updates and refreshing project adapters.

## [0.5.44-product] - 2026-05-01
**SFS document lifecycle and implement harness.** Sprint workbench documents now
stay useful while work is active, then collapse into a concise final report at
close. The implementation entrypoint also makes the four harness principles a
first-class coding guardrail, not just a reporting convention.

## [0.5.43-product] - 2026-05-01
**Same-runtime CPO review wording.** Documentation now clarifies that
`self-validation-forbidden` means separating the CTO implementer from the CPO
reviewer, not banning same-vendor or same-runtime review.

## [0.5.42-product] - 2026-05-01
**Windows Scoop packaging path.** The distribution now carries Scoop manifest
scaffolding, Windows PATH wrappers, and a `windows-latest` smoke workflow that
installs SFS through a temporary Scoop bucket before exercising thin project
initialization.

## [0.5.41-product] - 2026-05-01
**AI-owned Git Flow lifecycle.** Product adapters now match the project-wide
rule that users can simply describe work while the AI runtime owns branch
creation, commits, branch push, main absorption, and origin main push.

## [0.5.40-product] - 2026-05-01
**Model profile repair path.** `sfs update` now notices when an already-current
project is missing `.sfs-local/model-profiles.yaml` and recreates it with the
safe `current_model` fallback instead of exiting silently as "already latest."

## [0.5.39-product] - 2026-05-01
**Runtime-neutral agent model profiles.** Solon now exposes Claude/Codex/Gemini
as peer runtimes for C-Level, evaluator, worker, and helper model selection.

## [0.5.38-product] - 2026-05-01
**Commit grouping command.** Solon now has an explicit `sfs commit` step for
the gap between sprint close bookkeeping and real product/runtime changes.

## [0.5.37-product] - 2026-05-01
**Hotfix: package the commit command consistently.** 0.5.36 exposed
`sfs commit` in docs and dispatch metadata but missed the packaged script,
which made `sfs update` fail while checksumming managed files.

## [0.5.36-product] - 2026-05-01
**One-command project update.** Users no longer need to remember a separate
`brew upgrade` step before refreshing a project.

## [0.5.35-product] - 2026-05-01
**Short Homebrew upgrade path and version command.** Users can now verify the
installed SFS runtime directly and docs no longer imply the long fully-qualified
formula name is required for normal upgrades.

## [0.5.34-product] - 2026-04-30
(see full notes in archives)

## [0.5.33-product] - 2026-05-01
**Implementation command and AI-safe coding guardrails.** Solon now has an
explicit implementation layer so agents do not stop at planning artifacts.

## [0.5.32-product] - 2026-05-01
**First-run guidance for Homebrew users.** Empty projects now explain the
difference between installing the global CLI and initializing a project.

## [0.5.31-product] - 2026-05-01
**Project update command and Solon-only positioning.** Users can now refresh a
project with `sfs update` instead of uninstalling/reinstalling, and generated
instructions no longer mention external workflow products.

## [0.5.30-product] - 2026-05-01
**Guide command surface clarity.** The short guide now distinguishes terminal
commands from agent commands so users do not think they must type
`sfs /sfs guide` in a shell.

## [0.5.29-product] - 2026-05-01
**Uninstall command hardening.** Project cleanup is now usable from the global
`sfs` CLI and can run non-interactively for real consumer repo migration tests.

## [0.5.28-product] - 2026-05-01
**Agent-first install flow.** Homebrew remains the deterministic runtime
delivery path, while Claude/Gemini/Codex integration is now explicit through
`sfs agent install`.

## [0.5.27-product] - 2026-04-30
**Thin runtime layout foundation.** Solon can now run as a packaged `sfs`
runtime while consumer projects keep only state, docs, config, and custom
overrides.

## [0.5.26-product] - 2026-04-30
**Review artifact bloat guard.** `/sfs review` no longer appends executor
result excerpts into `review.md` by default, preventing repeated G1/G2 review
runs from turning the sprint review artifact into a multi-thousand-line log.

## [0.5.25-product] - 2026-04-30
**Localized review report UX.** `/sfs review` no longer dumps executor
markdown into command output. The adapter prints compact verdict/output-path
metadata, while AI runtimes read the recorded result and render a concise Solon
report in the user's visible language.

## [0.5.24-product] - 2026-04-30
**Review result visibility and Solon report UX.** `/sfs review` now shows the
executor-provided result excerpt directly in command output, and AI runtime
adapters must render hybrid/review completions as Solon reports instead of
path-only one-liners.

## [0.5.23-product] - 2026-04-30
**CPO review runs by default.** `/sfs review` now treats the selected CPO
executor bridge as the normal path, so users no longer need to remember an
extra run flag. Manual handoff remains available through `--prompt-only`.

## [0.5.22-product] - 2026-04-30
**Slim CPO review handoff + resilient Codex bridge.** `/sfs review` no longer
embeds the full CPO prompt into `review.md` on every invocation. The full prompt
is stored once under `.sfs-local/tmp/review-prompts/`, while `review.md` keeps a
compact invocation/result log.

## [0.5.21-product] - 2026-04-30
**Command-mode audit: bash-only vs hybrid vs conditional-hybrid.** The
`brainstorm` and `plan` bugs exposed a broader contract gap: some SFS commands
open scaffold files that AI runtimes must then fill, while other commands are
pure deterministic bash adapters. The command contract is now explicit.

## [0.5.20-product] - 2026-04-30
**Plan is now a hybrid command.** `/sfs plan` no longer stops at
`plan.md ready`. AI runtimes must read the current `brainstorm.md` and fill the
G1 plan + CTO/CPO sprint contract before returning.

## [0.5.19-product] - 2026-04-30
**Solon report shape, not external footer shape.** The previous
the previous usage footer borrowed too much from a non-Solon report design.
Solon now keeps usage facts only as optional content inside the existing Solon
Session Status Report shape.

## [0.5.18-product] - 2026-04-30
**Codex slash parser reality check.** Codex desktop can show `커맨드 없음` for
bare `/sfs` before the message reaches the model/Skill. The Codex entry path is
now documented as `$sfs ...` / Skill mention first, with direct bash as the
deterministic fallback.

## [0.5.17-product] - 2026-04-30
**Brainstorm CEO refinement flow.** `/sfs brainstorm` now matches the intended
G0 flow in AI runtimes: capture raw requirements first, then have Solon CEO fill
`brainstorm.md` §1~§7 and ask concise follow-up questions when needed.

## [0.5.16-product] - 2026-04-30
**Solon-owned usage footer.** The Claude `/sfs` command now keeps any useful
usage facts inside a Solon-owned report shape instead of suppressing reports
entirely.

## [0.5.15-product] - 2026-04-30
**Claude `/sfs` runtime boundary hardening.** The Claude command template now
explicitly suppresses non-Solon usage footers after Solon commands.

## [0.5.14-product] - 2026-04-30
**Auth probe early success return.** `/sfs auth probe` now returns as soon as the expected
`SFS_AUTH_PROBE_OK` marker appears in stdout, instead of waiting for CLIs that keep their process
open briefly after emitting the response.

## [0.5.13-product] - 2026-04-30
**Auth probe timeout guard.** `/sfs auth probe` now has a hard timeout and validates that the
executor actually returned the probe marker before reporting success.

## [0.5.12-product] - 2026-04-30
**Review auth command and empty-review cutoff.** `/sfs review --run` now checks whether there
is reviewable evidence before spending executor tokens, and `/sfs auth` provides explicit
status/login/probe flows for Codex/Claude/Gemini review bridges.

## [0.5.11-product] - 2026-04-30
**Executor review visibility and evidence bundle fix.** `/sfs review --run` now embeds sprint
evidence in the prompt and prints output paths before invoking external CLIs.

## [0.5.10-product] - 2026-04-30
**Interactive executor auth bootstrap fix.** `--auth-interactive` now attaches Codex/Claude/Gemini
login output directly to `/dev/tty` instead of hiding prompts in temp files while resolving the
executor command.

## [0.5.9-product] - 2026-04-30
**G0 brainstorm command and flow correction.** `/sfs start` remains the sprint workspace
scaffold command, while `/sfs brainstorm` becomes the explicit G0 context-capture command before
`/sfs plan`.

## [0.5.7-product] - 2026-04-30
**`/sfs guide` default context briefing.** Bare `/sfs guide` should orient the user, not dump a
full Markdown document and not merely print a file path.

## [0.5.6-product] - 2026-04-30
**Local product clone freshness guard.** 실제 사용자는 `~/tmp/solon-product` 같은 로컬 clone 을
install/upgrade source 로 쓰므로, GitHub release 와 이 clone 이 어긋나면 `upgrade.sh` 가
낡은 VERSION 을 읽고 "이미 최신" 으로 오판할 수 있었다.

## [0.5.5-product] - 2026-04-30
**Codex desktop app `/sfs` canonical path 복구.** `/sfs ...` 메시지가 Codex desktop app /
compatible Codex surface 에서 모델 또는 Skill 까지 도달하면, 그 순간 정상 Solon command 로
간주하고 bash adapter 로 즉시 dispatch 하도록 Skill/AGENTS/README/GUIDE/install 안내를 강화.

## [0.5.4-product] - 2026-04-30
(see full notes in archives)

## [0.5.3-product] — 2026-04-30
**`/sfs guide` command.** 0.5.2-product 의 외부 onboarding guide 를 설치된 consumer 프로젝트 안에서
바로 발견하고 출력할 수 있도록 8번째 deterministic bash adapter command 를 추가.

## [0.5.2-product] — 2026-04-30
**External onboarding guide + release-note hygiene.** 0.5.1-product 로 product rebrand baseline 을
정렬한 뒤, 실제 첫 외부 사용자 onboarding 에 필요한 30분 walk-through 를 stable 배포판에 포함.
동시에 release helper 의 CHANGELOG 중복 prepend 를 막아 tag 기준 release note 가 깨끗하게 남도록 보정.

## [0.5.1-product] — 2026-04-30
**Codex stable hotfix narrative sync-back + multi-adaptor 1급 정합 통합.** 26th-2 의 0.5.0-mvp release cut (`99b2313`) 이 dev staging 의 mvp 본을 stable 에 rsync 하면서 codex 가 stable 에서 직접 작업한 product positioning narrative 3 commits (`ced9cc1` + `5765abb` + `7977a75`) 를 overwrite. 본 release 는 codex 의 narrative 개선분을 dev staging 으로 sync-back 하고 (R-D1 §1.13 정합), 본 cycle (26th-2) 의 multi-adaptor 1급 정합 (Codex Skills + Gemini commands + 7-Gate enum) 과 통합.

## [0.5.0-mvp] — 2026-04-29
**Solon-wide multi-adaptor invariant 정합 + `/sfs loop` 추가.** Solon 의 7 슬래시 명령 전체가
Claude Code / Codex / Gemini CLI 어느 1급 환경에서든 동등한 bash adapter SSoT 로 동작하도록
runtime adapter (CLAUDE / AGENTS / GEMINI / SFS template) narrative 정합. `/sfs loop` 는 그
invariant 의 첫 LLM-호출 site 로 Ralph Loop + Solon mutex + executor convention 을 정착.

## [0.4.0-mvp] — 2026-04-29
(see full notes in archives)

## [0.3.1-mvp] — 2026-04-29
(see full notes in archives)

## [0.3.0-mvp] — 2026-04-29
(see full notes in archives)

## [0.2.4-mvp] — 2026-04-24
(see full notes in archives)

## [0.2.3-mvp] — 2026-04-24
(see full notes in archives)

## [0.2.2-mvp] — 2026-04-24
(see full notes in archives)

## [0.2.1-mvp] — 2026-04-24
(see full notes in archives)

## [0.2.0-mvp] — 2026-04-24
(see full notes in archives)

## [0.1.1-mvp] — 2026-04-24
(see full notes in archives)

## [0.1.0-mvp] — 2026-04-24
(see full notes in archives)
