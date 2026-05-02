## [0.5.95-product] - 2026-05-03

### Changed

- **Windows one-shot update command clarified** — Windows docs now lead with
  `sfs.cmd update`, not a two-line Scoop sequence. The command owns the full
  runtime + project update flow by running `scoop update`, `scoop update sfs`,
  reloading the updated runtime, and then applying project migration.
- **`sfs update` no longer discourages itself** — the compatibility-warning
  line was removed so `sfs.cmd update` can serve as a clean user-facing
  one-shot command on Windows.

## [0.5.94-product] - 2026-05-03

### Changed

- **Windows upgrade docs now lead with Scoop one-shot flow** — README, GUIDE,
  BEGINNER-GUIDE, and the English guide now show `scoop update sfs` as the
  primary Windows update path from an initialized project, with
  `sfs.cmd upgrade` kept as the project-only fallback when Scoop already has
  the latest runtime.

## [0.5.93-product] - 2026-05-03

### Added

- **Scoop project upgrade hook** — running `scoop update sfs` from an
  initialized Solon project now updates the global runtime and then continues
  into project upgrade automatically. Running Scoop outside a project still
  leaves project files untouched.

### Fixed

- **No duplicate project migration during `sfs.cmd upgrade`** — Windows
  self-upgrade paths temporarily set `SFS_SCOOP_PROJECT_UPGRADE=0` while they
  call `scoop update sfs`, then run the project upgrade themselves.

## [0.5.92-product] - 2026-05-03

### Fixed

- **Windows self-upgrade now continues into project upgrade** — `sfs.cmd`
  no longer exports the internal `SFS_SELF_UPGRADE_DONE` guard before reloading
  the updated Scoop runtime. The reloaded `sfs.cmd upgrade` now actually runs
  the project migration instead of returning immediately after
  `reloading installed sfs runtime...`.

## [0.5.91-product] - 2026-05-03

### Fixed

- **Thin migration removes empty runtime directories too** — after a vendored
  project is promoted to thin layout, upgrade now removes the empty
  `.sfs-local/scripts`, `sprint-templates`, `personas`, and
  `decisions-template` directories that were briefly recreated by the
  compatibility update loop.

## [0.5.90-product] - 2026-05-03

### Fixed

- **Existing Windows/Scoop projects now convert to thin surface on upgrade** —
  global `sfs` / `sfs.cmd upgrade` now requests thin layout explicitly, so old
  projects recorded as `vendored` or missing layout metadata no longer preserve
  project-local command/skill adapters by accident.
- **Vendored runtime assets are migrated, not stranded** — when global upgrade
  converts a project to thin layout, managed `.sfs-local/scripts`,
  `sprint-templates`, `personas`, `decisions-template`, and `.sfs-local/GUIDE.md`
  move into `project-runtime-assets.tar.gz` with a manifest.
- **PowerShell wrapper parity** — `upgrade.ps1` now defaults to `-Layout thin`,
  and `install.ps1` accepts `-Layout thin|vendored` plus optional
  `-WithAgentAdapters`.

## [0.5.89-product] - 2026-05-03

### Fixed

- **Windows/Scoop thin-surface parity** — thin installs no longer create
  project-local `.claude/`, `.gemini/`, or `.agents/` command/skill adapter
  files by default. Existing thin projects migrate those files into a compressed
  runtime migration bundle during `sfs upgrade`, and `sfs agent install all`
  remains available as an explicit opt-in.
- **Upgrade no longer rehydrates command adapters** — `sfs upgrade` skips the
  post-upgrade agent adapter sync for thin projects, so the cleanup applies on
  both Homebrew and Scoop paths instead of being immediately undone.
- **Install and channel guidance aligned** — README, GUIDE, Homebrew caveats,
  and Scoop notes now present command/skill adapters as optional instead of
  part of the default project surface.

## [0.5.88-product] - 2026-05-03

### Fixed

- **Project-surface archive compaction audit** — `sfs upgrade` now cleans more
  than context docs. Existing loose `runtime-upgrades`, old `agent-install`
  backups, stale `.sfs-local/tmp` backup/review scratch, and nested loose files
  inside legacy sprint archives are compacted into `*.tar.gz` + `manifest.txt`
  bundles.
- **Future rollback backups are bundled** — runtime upgrade backups and
  `sfs agent install` backups now create one compressed bundle per run instead
  of timestamp folders full of flattened Markdown files.
- **Profile rollback backup moved out of tmp** — `sfs profile --apply` now keeps
  its pre-edit `SFS.md` rollback copy under compressed `archives/profile-backups`
  instead of `.sfs-local/tmp/profile-backups`.

## [0.5.87-product] - 2026-05-03

### Changed

- **Thin runtime context migration** — thin installs no longer copy managed
  routed context docs into `.sfs-local/context`. Agent adapters now resolve the
  same command/policy context through `sfs context path ...`, with optional
  project-local overrides still honored first.
- **Upgrade cleanup for existing projects** — `sfs upgrade` migrates old
  project-local managed context docs into a compressed runtime migration backup
  and explains that the guidance moved to the packaged Homebrew/Scoop runtime
  rather than disappearing.
- **Cold archive bundles** — sprint close/tidy now packs verbose workbench
  files and latest review scratch into one `sprint-evidence.tar.gz` plus
  `manifest.txt`. Legacy loose sprint archives and old per-run review archives
  are compacted during upgrade.
- **Adopt baseline handoff** — `sfs adopt` report/retro output now focuses on a
  useful project snapshot, documentation topology, submodule/subrepo signals,
  product change signals, verification entry points, and a next sprint seed
  instead of mostly listing paths and commits.

## [0.5.86-product] - 2026-05-02

### Changed

- **User-facing docs trimmed** — `README.md`, `GUIDE.md`, and the
  `docs/ko` / `docs/en` pages no longer surface dev-internal rationale,
  migration tone, internal implementation thresholds, or near-duplicate
  sections. Onboarding readers now see only what they need to act on, while
  deeper judgment material remains in the focused detail pages.
- **`sfs guide` is now in the README Command Surface** — the in-terminal short
  guide that BEGINNER-GUIDE already pointed users at is no longer absent from
  the README command list, removing a quiet inconsistency.
- **GUIDE first-sprint example replaced** — the §14 example was a
  self-referential `README/GUIDE 정리` flow; it now uses a concrete
  `todo 앱 v0` example that first-time readers can follow without context
  about the Solon repo itself.
- **`sfs retro --draft` repositioned** — the option moved from the §10 retro
  onboarding body into the §11 "필요할 때만 쓰는 명령" reference table, so
  retro stays a single clean default for new users while the option remains
  documented.
- **Token / harness hygiene reworded** — README and GUIDE now describe the
  hygiene notices in one user-actionable line each, with the four-bullet
  capability detail consolidated under the `docs/ko` / `docs/en`
  current-product-shape pages and stripped of plugin-specific naming.

### Moved

- `solon-mvp-dist/10X-VALUE.md` is now `solon-mvp-dist/docs/en/10x-value.md`,
  giving the 10x value page the same `docs/en/` location as every other
  English doc and matching the Korean `docs/ko/10x-value.md` it pairs with.
  All inbound `Language` links and the README Documentation Map were updated.
- `solon-mvp-dist/APPLY-INSTRUCTIONS.md` was historical (the file itself
  declared `historical 참조용. 다시 실행할 필요 없음.`) and has been moved
  out of the OSS-facing `solon-mvp-dist/` tree into the docset archive. The
  `cut-release.sh` blocklist now also cleans out the legacy root
  `10X-VALUE.md` from the stable repo on the next `--apply`.

## [0.5.85-product] - 2026-05-02

### Changed

- **Beginner-first GUIDE rewrite** — GUIDE is now a practical first-sprint
  walkthrough instead of a dense internal manual. It explains the default
  `status -> start -> brainstorm -> plan -> implement -> review -> retro`
  path, keeps backend/design/QA/ops depth in detail docs, and clarifies
  brainstorm simple/normal/hard as three thinking levels.
- **Retro-centered close documentation** — README, docs indexes, current-product
  pages, English guide, and installer onboarding now present `sfs retro` as the
  normal sprint close. `sfs report` and `sfs tidy` are documented as optional
  helpers for report preview/rebuild and old workbench cleanup.

## [0.5.84-product] - 2026-05-02

### Added

- **Ambient token/harness hygiene** — SFS now applies token and harness hygiene
  inside the normal command flow instead of asking users to remember extra
  commands. Routed context adds cross-agent guidance for thin adapter memory,
  symbol/semantic search before broad reads, usage-report checks, and converting
  repeated AI mistakes into guardrails/checks.
- **Hygiene notices** — initialized projects get a throttled terminal notice
  when adapter docs, current workbench files, or large codebases look likely to
  waste tokens. Notices are cached under `.sfs-local/cache/`, ignored by Git,
  and can be disabled with `SFS_HYGIENE_NOTICE=0`.

## [0.5.83-product] - 2026-05-02

### Added

- **Stale version notice** — initialized projects now get a soft terminal
  notice when `sfs` detects that the project/runtime is at least five product
  releases behind the latest published tag. The notice is throttled by a local
  cache, skipped for install/upgrade/version/help commands, and can be disabled
  with `SFS_VERSION_NOTICE=0`. On interactive `sfs status`, Solon also asks
  whether to run `sfs upgrade` now.

## [0.5.82-product] - 2026-05-02

### Changed

- **Current product documentation** — README and GUIDE now explain the current
  Solon Product shape after the recent release train: brainstorm depth,
  plan-as-contract, artifact-based implementation, review lens routing, evidence
  bundles, context-router repair, and retro-as-close.
- **Bilingual docs architecture** — README is now a high-level map rather than a
  detail warehouse, with Korean/English detail pages under `docs/ko` and
  `docs/en`, including current product shape, 10x value, and an English
  onboarding guide. Docs also clarify that GitHub Markdown has no native
  language-switch tabs, so Solon uses explicit language links.
- **Documentation quality bar** — onboarding docs now state that Solon documents
  should be high-signal handoff artifacts: enough context for the next human/AI
  session to know what was done, why, how it was verified, and what action comes
  next, without turning every sprint into documentation sprawl.

## [0.5.81-product] - 2026-05-02

### Changed

- **Retro close default** — `sfs retro` is now the normal sprint completion
  command: it refines/opens `retro.md`, ensures `report.md`, archives workbench
  evidence, closes the sprint, and creates the local close commit. `--close`
  remains a backward-compatible alias, while `--draft` / `--no-close` keep the
  old open-only behavior.
- **Current README flow** — README and guide examples now end with `sfs retro`
  instead of splitting completion across `retro` and `retro --close`.

## [0.5.80-product] - 2026-05-02

### Changed

- **Brainstorm depth modes** — `sfs brainstorm` now supports `--simple`
  (`--easy` / `--quick` aliases), default normal, and `--hard`. The adapter
  records depth in `brainstorm.md` frontmatter and events so AI runtimes can
  choose between quick requirement cleanup, owner-thinking scaffold, and
  product-owner hard training.
- **Start handoff discoverability** — `sfs start` now prints one `next:` line
  that exposes simple/normal/hard brainstorm options and recommends normal, so
  users discover the new thinking-depth flow without reading the guide first.

## [0.5.79-product] - 2026-05-02

### Changed

- **Review lens routing** — `sfs review` now keeps the same user-facing command
  while automatically selecting an artifact acceptance lens (`code`, `docs`,
  `strategy`, `design`, `taxonomy`, `qa`, `ops`, `release`, or generic
  `artifact`) from sprint evidence and changed artifact paths. `--lens` remains
  available only as an override when inference is wrong.
- **Review next action contract** — CPO prompts now ask for an explicit next
  action alongside verdict/findings, and docs clarify that code review is only
  the `code` lens, not the default meaning of review.

## [0.5.78-product] - 2026-05-02

### Fixed

- **Context router same-version repair** — `sfs upgrade` now repairs
  `.sfs-local/context/_INDEX.md` and `kernel.md` as first-class router files
  when an already-latest project is missing its local context directory, and
  fails closed if either core router file is absent after repair.
- **Owner release guard** — product release verification now checks that both
  `_INDEX.md` and `kernel.md` are packaged before validating routed command and
  policy modules.

## [0.5.77-product] - 2026-05-02

### Changed

- **Dev backend architecture ladder** — `/sfs implement` now records the
  default backend architecture path: clean layered monolith for MVP/small
  projects, CQRS for non-initial backend work even on one DB, Hexagonal
  transition guidance when domain seams grow, and MSA transition guidance only
  after explicit approval for independent service boundaries.
- **Non-Dev division policy ladders** — Strategy-PM, Taxonomy,
  Design/Frontend, QA, and Infra guardrails now start with lightweight MVP
  defaults, strengthen only when trigger evidence appears, and require user
  acceptance/approval before large roadmap, rename/schema, redesign,
  release-readiness, or infra/ops transitions.

## [0.5.76-product] - 2026-05-02

### Fixed

- **Gate 6 review scope filtering** — `/sfs review` now treats
  `.claude/skills/sfs/**` as SFS system scope, excludes nested generated
  build outputs such as `backend/dist/**` and `backend/build/**` from
  reviewable manifests, and emits declared first-class source/config excerpts
  before the generic first-N excerpt cap so core implementation evidence is not
  hidden by incidental files.

## [0.5.75-product] - 2026-05-02

### Fixed

- **Gate 6 review excerpt prioritization** — `/sfs review` now separates the
  full reviewable manifest from the bounded excerpt priority list, promotes
  declared `implement.md`/`plan.md` target paths ahead of incidental untracked
  files, includes safe `.env.example` evidence, compacts `.gitignore` to
  product-owned hunks outside the Solon managed block, and asks evaluators to
  report same-tool review risk as a separate warning axis.

## [0.5.74-product] - 2026-05-02

### Changed

- **Gate numbering UX** — Solon reports and new docs now use plain Gate 1
  through Gate 7 labels, and `/sfs review` accepts `--gate 1..7` while keeping
  older storage ids as a compatibility layer.
- **Review evidence bundle coverage** — `/sfs review` now unions indexed and
  auto-discovered implementation files after hard ban-list and text-file
  filtering, treats `.gitignore` as mixed product/system evidence, matches
  verification-style headings, and drops nonexistent indexed paths from the
  reviewable manifest.
- **Release regression guard** — the owner-side product release verifier now
  extracts both release archives and checks that every context router target
  referenced by `_INDEX.md` is packaged, preventing missing routed modules from
  reaching Homebrew/Scoop release validation again.

## [0.5.73-product] - 2026-05-02

### Fixed

- **Context router upgrade repair** — `sfs upgrade` now manages every context
  module referenced by `.sfs-local/context/_INDEX.md`, including
  `commands/start.md` and `commands/profile.md`, repairs missing router targets
  even when the installed project already reports the latest version, and fails
  closed if the router index still points at a missing module.

## [0.5.72-product] - 2026-05-02

### Fixed

- **Global runtime safety guards** — `sfs` now runs commands under a bounded
  watchdog by default, stops recursive command re-entry before it can loop,
  caps adapter recursion/CPU time, limits symlink resolution while finding the
  runtime, and applies explicit executor timeouts to review/loop live executor
  calls so a deadlock or circular invocation fails closed instead of burning
  tokens indefinitely.

## [0.5.71-product] - 2026-05-02

### Fixed

- **Targeted G4 code-review evidence** — `/sfs review` now follows
  `implement.md` file excerpt index line numbers into bounded source snippets,
  includes small indexed review targets in full, keeps indexed files ahead of
  auto-discovered files, classifies SFS/runtime adapter changes outside the
  product implementation scope, and preserves same-session generator executor
  labels such as `codex, same study-note session`.

## [0.5.70-product] - 2026-05-02

### Fixed

- **Code-level G4 review packaging** — `/sfs review` now follows
  `implement.md` file excerpt indexes into bounded source diffs and excerpts,
  includes smoke script bodies when referenced, filters IDE/build metadata such
  as `.idea/`, excludes unrelated cache/temp/log/secret/vendor/binary files
  from automatic evidence collection, and infers generator executor labels more
  robustly.

## [0.5.69-product] - 2026-05-02

### Fixed

- **G4 review evidence bundle** — `/sfs review` now embeds `implement.md`,
  prioritized build/smoke/source evidence sections, untracked file manifests,
  and bounded source excerpts so CPO review sees implementation evidence even
  when a new app surface is still untracked.
- **Review executor attribution** — when `--generator` is omitted, review now
  infers the generator executor from `implement.md` or `log.md` evidence before
  recording self-validation risk metadata.

## [0.5.68-product] - 2026-05-02

### Changed

- **Cross-phase AI fundamentals** — brainstorm, plan, routed context, Codex
  skill, README, and GUIDE now state that shared design concept, ubiquitous
  language, feedback loops, deep-module/interface boundaries, and gray-box
  delegation apply from G0 onward, not only during implementation; review and
  report templates now preserve those checks through close.
- **G0/G1 questioning gate** — brainstorm keeps `status: draft` and asks 1-3
  blocking questions when shared understanding is missing; plan must not hide
  unresolved G0 questions behind assumptions.
- **SFS naming** — README, GUIDE, and generated `SFS.md` now explain the dual
  meaning: terminal-facing `sfs` is Sprint Flow System, while Solon Product's
  broader SFS is Solo Founder System.
- **Runtime command shapes** — docs and installer output now spell out the
  three agent-facing invocations: Claude Code uses `/sfs ...`, Gemini CLI uses
  `sfs ...`, and Codex CLI uses `$sfs ...`.

## [0.5.67-product] - 2026-05-02

**Restore project profile command.** Reconnects the `sfs profile` public command
that refreshes only `SFS.md` project overview from bounded project metadata.

### Fixed

- **`sfs profile` routing** — the global CLI and runtime dispatch table now
  route `profile` to the packaged `sfs-profile.sh` adapter again.
- **Project overview template** — generated `SFS.md` includes a
  `## 프로젝트 개요` section for `sfs profile` to update.
- **Agent/docs surface** — Claude, Codex, Gemini, README, GUIDE, and routed
  context docs describe `profile` as a narrow hybrid command, not a broad
  project scan.

## [0.5.66-product] - 2026-05-02

**Start next-action UX.** Makes `sfs start` point directly to the next usable
Solon step without implying that start creates a final sprint report.

### Fixed

- **`sfs start` next action** — start now prints one copy-pasteable
  `next: sfs brainstorm ...` line after scaffold creation.
- **Bash-first agent routing** — Claude, Codex, Gemini, and routed context docs
  now state that bash-first means no artifact refinement, not "no Next".

## [0.5.65-product] - 2026-05-02

**Windows Scoop command docs alignment.** Makes Windows onboarding consistent
across README, beginner guide, GUIDE, and Scoop packaging docs.

### Changed

- **Windows command shape** — PowerShell/cmd examples now use `sfs.cmd ...`,
  while Mac/Git Bash examples keep `sfs ...`.
- **Scoop-first docs** — README Quickstart, Version Check, Upgrade, and agent
  install examples now separate Windows/Scoop commands from Mac/Git Bash
  commands, and source `install.ps1` paths are marked as fallback.
- **Scoop package notes** — the Scoop manifest template and packaging README now
  show `sfs.cmd` for first-time setup, status, upgrade, and agent install.

## [0.5.64-product] - 2026-05-02

**Audience wording cleanup.** Refines the beginner onboarding language so it
describes users by CLI familiarity rather than by job title.

### Changed

- **Beginner guide audience** — public docs now say the guide is for people who
  are not yet comfortable with development, terminal, or CLI workflows, avoiding
  job-title generalizations.

## [0.5.63-product] - 2026-05-02

**Beginner onboarding for CLI-unfamiliar users.** Adds a dedicated guide for
people who are blocked before they understand terminal, Scoop, Homebrew,
project folders, or the first `sfs status` success signal.

### Added

- **`BEGINNER-GUIDE.md`** — a plain-language install and first-use guide with
  Windows/Scoop, Mac/Homebrew, test project setup, first AI commands,
  troubleshooting, and what information to send when asking for help.

### Changed

- **README guide path** — the README now points first-time CLI-unfamiliar users
  to the beginner guide before the regular installation and product sections.

## [0.5.62-product] - 2026-05-02

**Context-routing adapter structure.** Solon adapters now stay short and route
Claude, Codex, and Gemini to small context modules only when a command needs
them.

### Added

- **`.sfs-local/context/` modules** — installs now include a router index,
  kernel, command modules for implement/review/release/upgrade/tidy/loop, and a
  mutex policy module with compact `summary` / `load_when` frontmatter.
- **Unified README installation section** — the README now presents
  Windows/Scoop, Mac/Homebrew, source fallback, project init, and upgrade in
  one install section so CLI-unfamiliar users can choose the right path quickly.

### Changed

- **Entry docs as routers** — `SFS.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`,
  Claude command, Codex Skill/prompt, and Gemini command now point to routed
  context instead of carrying repeated long guidance inline.
- **Upgrade coverage** — `sfs upgrade` previews and updates context modules with
  runtime-upgrade archive safety, including thin-layout installs.

## [0.5.61-product] - 2026-05-02

**Release-channel verification hotfix.** Prevents a product release from being
called complete while a local Homebrew tap clone is still serving an older
formula.

### Added

- **Product release verifier** — release owners can run
  `scripts/verify-product-release.sh --version <VERSION>` to check the product
  tag, Homebrew remote formula, local Homebrew tap clone freshness, Scoop remote
  manifest, archive hashes, and installed `sfs version --check` result.

### Fixed

- **Homebrew self-upgrade freshness** — `sfs upgrade` now explicitly
  fast-forwards the `MJ-0701/solon-product` Homebrew tap before upgrading the
  fully qualified formula `MJ-0701/solon-product/sfs`, preventing stale tap
  clones from stopping at older versions such as `0.5.57-product`.

## [0.5.60-product] - 2026-05-02

**Implementation is now an execution contract, not a developer-only coding
surface.** `/sfs implement` still supports code work, but it now treats
taxonomy, design handoff, QA evidence, infra/runbook, decisions, and docs as
first-class implementation artifacts.

### Changed

- **`/sfs implement` runtime handoff** — adapter output now tells AI runtimes to
  execute the requested work slice and record evidence instead of saying they
  must "implement code now".
- **Implementation artifact template** — `implement.md` now records changed
  artifact types, non-code review evidence, domain language, and feedback-first
  plans while keeping code-specific DDD/TDD and backend transaction guardrails
  conditional on code being touched.
- **Product docs and Codex Skill** — README, GUIDE, 10X-VALUE, installed Codex
  Skill, legacy Codex prompt, and implementation persona now describe
  implementation as division-aware execution across code, taxonomy, design, QA,
  infra, decisions, and docs.

## [0.5.59-product] - 2026-05-02

**Codex and Windows invocation docs alignment.** Clarifies the supported SFS
entry points across Codex CLI, Codex app surfaces, and Windows PowerShell.

### Changed

- **Codex CLI entry shape** — product docs now describe `$sfs ...` as the
  official Codex CLI Skill invocation instead of treating it as a temporary
  fallback for bare `/sfs`.
- **Windows PowerShell shell entry** — onboarding now shows `sfs.cmd ...` for
  direct PowerShell usage, while keeping `sfs ...` for Git Bash/WSL/POSIX
  shells.

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

## [0.5.48-product] - 2026-05-01

**Persist agent model profile selections.** Fixes a regression where choosing
an agent model profile during `sfs upgrade` printed a confirmation but left
`.sfs-local/model-profiles.yaml` unchanged, causing the same question to appear
again on the next upgrade.

### Fixed

- **Model profile persistence** — `sfs upgrade` now writes `status`,
  `selected_runtime`, `selected_policy`, `confirmed_by`, and `confirmed_at`
  correctly when users choose Claude recommended, all-high, custom, or fallback
  policy.
- **Fail-visible profile writes** — profile write failures now stop the upgrade
  instead of being silently ignored after printing a success message.

## [0.5.47-product] - 2026-05-01

**Short sprint references for tidy.** `sfs tidy --sprint` now accepts an exact
sprint id or a unique suffix reference, so users can type refs like
`W18-sprint-1` instead of the full `2026-W18-sprint-1` when the match is
unambiguous.

### Changed

- **Tidy sprint targeting UX** — `--sprint <id-or-ref>` resolves exact ids
  first, then unique suffix matches. Ambiguous refs fail with the matching
  sprint ids instead of guessing.
- **Tidy documentation** — README/GUIDE/help text now describe `id-or-ref`
  targeting and keep `--all` as the recommended bulk cleanup path.

## [0.5.46-product] - 2026-05-01

**Document tidy command and release-note preflight.** SFS now has an explicit
cleanup command for completed sprint workbench docs, and release cuts require a
versioned changelog entry before publishing.

### Added

- **`sfs tidy` command** — dry-run by default; with `--apply`, it creates
  `report.md` when missing and moves original workbench docs into archive.
- **Local workbench/tmp archive** — compaction now preserves original
  brainstorm/plan/implement/log/review files and matching tmp review artifacts
  under `.sfs-local/archives/`, then removes them from visible sprint/tmp
  folders.
- **Release note preflight** — `scripts/cut-release.sh --apply` now requires a
  target `CHANGELOG.md` entry before cutting a release.

### Changed

- **Report/retro cycle cleanup** — existing `report --compact` and
  `retro --close` cycle paths now use the same archive-first cleanup helper as
  `sfs tidy`.
- **Report template wording** — new reports point readers to archived
  workbench sources instead of implying verbose files stay in the sprint folder.
- **Release documentation** — README/GUIDE describe `sfs tidy`, update
  discovery, and the Added/Changed/Fixed release note rule.

### Fixed

- **Workbench cleanup ambiguity** — completed sprint cleanup is now a named
  explicit command that leaves only durable sprint docs in the main folder.

## [0.5.45-product] - 2026-05-01

**Upgrade command UX and SFS naming.** SFS is now explicitly documented as
Solo Founder System, while `sfs upgrade` becomes the recommended user-facing
command for checking package-manager updates and refreshing project adapters.

### Added

- **`sfs version --check`** — prints the installed runtime version, the latest
  published product tag, and whether an upgrade is available.
- **Scoop-aware upgrade path** — `sfs upgrade` can self-upgrade Scoop installs
  with `scoop update` + `scoop update sfs` before refreshing project files.
- **SFS acronym definition** — README, GUIDE, SFS template, and agent adapters
  now define SFS as Solo Founder System.

### Changed

- **`sfs upgrade` as the primary command** — promoted `upgrade` to the
  recommended one-command path. `sfs update` remains a compatibility alias.
- **User release discovery docs** — README now explains how users can notice new
  releases through `sfs version --check`, Homebrew, or Scoop metadata.

## [0.5.44-product] - 2026-05-01

**SFS document lifecycle and implement harness.** Sprint workbench documents now
stay useful while work is active, then collapse into a concise final report at
close. The implementation entrypoint also makes the four harness principles a
first-class coding guardrail, not just a reporting convention.

### Added

- **`sfs report` command** — creates/refines sprint `report.md` as the compact
  final work summary and can compact workbench docs with explicit `--compact`.
- **Report template and lifecycle helpers** — packaged `report.md` and shared
  compaction helpers preserve retro/history while pointing completed
  workbench files toward the final report.
- **Active implement adapter** — packaged and active `sfs-implement.sh` now
  states that AI runtimes must apply Think Before Coding, Simplicity First,
  Surgical Changes, and Goal-Driven Execution before editing code.

### Changed

- **Retro close flow** — `retro --close` now expects the final report to exist
  and compacts completed workbench docs after report refinement.
- **Agent adapters and templates** — Codex, Claude, Gemini, SFS.md, GUIDE.md,
  and sprint templates now describe workbench-vs-report lifecycle and the
  implementation harness as the default coding discipline.

## [0.5.43-product] - 2026-05-01

**Same-runtime CPO review wording.** Documentation now clarifies that
`self-validation-forbidden` means separating the CTO implementer from the CPO
reviewer, not banning same-vendor or same-runtime review.

### Changed

- **Adaptor design intent** — documented cross-vendor review as useful but not
  mandatory, with same-runtime review valid when a separate CPO
  role/agent/instance reviews evidence and records verdict/actions.
- **Guide review flow** — reframed CPO review as role separation plus evidence
  instead of a token-heavy multi-tool requirement.

## [0.5.42-product] - 2026-05-01

**Windows Scoop packaging path.** The distribution now carries Scoop manifest
scaffolding, Windows PATH wrappers, and a `windows-latest` smoke workflow that
installs SFS through a temporary Scoop bucket before exercising thin project
initialization.

### Added

- **Scoop manifest template** — `packaging/scoop/sfs.json.template` defines the
  release archive, SHA256, `extract_dir`, `bin` shim, `checkver`, and
  `autoupdate` contract for an own bucket.
- **Windows global wrappers** — `bin/sfs.cmd` and `bin/sfs.ps1` locate Git Bash
  and delegate to the packaged Bash entrypoint so PowerShell, cmd, and Git Bash
  can call `sfs` from PATH.
- **Windows Actions smoke** — `.github/workflows/windows-scoop-smoke.yml`
  builds a local archive, installs via Scoop, runs `sfs version`, `sfs --help`,
  `sfs init --layout thin --yes`, `sfs status`, and `sfs agent install all`,
  then asserts runtime assets were not copied into the project.

## [0.5.41-product] - 2026-05-01

**AI-owned Git Flow lifecycle.** Product adapters now match the project-wide
rule that users can simply describe work while the AI runtime owns branch
creation, commits, branch push, main absorption, and origin main push.

### Changed

- **SFS core and runtime adapters** — replaced old "push is manual/user-only"
  guidance with AI-owned Git Flow lifecycle rules for Claude, Codex, and Gemini.
- **`sfs commit` wording** — clarified that the command remains a local grouping
  and commit helper, while the surrounding branch push/main merge/main push is
  owned by the AI runtime.
- **Guides and command prompts** — documented the fallback cases where the AI
  must stop and ask: destructive git, unrelated dirty work, merge conflicts,
  failing tests, protected branch/remote rejection, and auth prompts.

## [0.5.40-product] - 2026-05-01

**Model profile repair path.** `sfs update` now notices when an already-current
project is missing `.sfs-local/model-profiles.yaml` and recreates it with the
safe `current_model` fallback instead of exiting silently as "already latest."

### Fixed

- **Same-version update repair** — if model profiles are missing, generate the
  project-local settings file with `selected_runtime: current` and
  `selected_policy: current_model`.
- **Unconfigured profile guidance** — when a profile is still on fallback/unset,
  `sfs update` reminds users that Solon will use the current runtime model and
  points them at the agent-specific settings file.

## [0.5.39-product] - 2026-05-01

**Runtime-neutral agent model profiles.** Solon now exposes Claude/Codex/Gemini
as peer runtimes for C-Level, evaluator, worker, and helper model selection.

### Added

- **`.sfs-local/model-profiles.yaml`** — a project-local reasoning tier registry
  mapping `strategic_high`, `review_high`, `execution_standard`, and
  `helper_economy` to Claude, Codex, Gemini, current-runtime, or custom profiles.
- **Implementation Worker persona** — fixed-scope `execution_standard` worker
  persona separated from the `strategic_high` CTO contract owner.

### Changed

- **SFS core docs and sprint templates** — model selection now records
  reasoning tier + runtime + resolved model instead of treating Claude model
  names as canonical.
- **Install/update flows** — new projects receive `model-profiles.yaml`; existing
  projects get it via `sfs update` when missing, while preserving local edits.
- **Current model fallback** — when users skip, refuse, or forget model setup,
  Solon uses the active model/reasoning setting already selected in the current
  runtime instead of blocking the workflow.

## [0.5.38-product] - 2026-05-01

**Commit grouping command.** Solon now has an explicit `sfs commit` step for
the gap between sprint close bookkeeping and real product/runtime changes.

### Added

- **`sfs commit` command** — `status`/`plan` groups staged, unstaged, and
  untracked files into `product-code`, `sprint-meta`, `runtime-upgrade`, and
  `ambiguous`.
- **Group apply flow** — `sfs commit apply --group <name>` stages every file in
  the selected group, auto-generates a Git Flow-aware Conventional Commit
  message plus file summary body, and creates one local commit while aborting
  if unrelated files are already staged.
- **Branch preflight placeholder** — `sfs commit plan/apply` prints current
  branch guidance first, including `main`/`develop` warnings and the planned
  Solon branch helper placeholder. It does not auto-create or switch branches
  yet.

### Changed

- **Agent adapters and docs** — Claude/Gemini/Codex command surfaces now route
  `commit` through the deterministic bash adapter and document that it never
  pushes.

## [0.5.37-product] - 2026-05-01

**Hotfix: package the commit command consistently.** 0.5.36 exposed
`sfs commit` in docs and dispatch metadata but missed the packaged script,
which made `sfs update` fail while checksumming managed files.

### Fixed

- Add missing `templates/.sfs-local-template/scripts/sfs-commit.sh` to the
  stable tarball.
- Sync `sfs-dispatch.sh` so `commit` routes to the packaged script.

## [0.5.36-product] - 2026-05-01

**One-command project update.** Users no longer need to remember a separate
`brew upgrade` step before refreshing a project.

### Changed

- **`sfs update` self-upgrades Homebrew runtime first** — when the CLI is running
  from the `mj-0701/solon-product/sfs` Homebrew formula, `sfs update` runs
  `brew update` + `brew upgrade sfs`, reloads the installed runtime, then updates
  the current project's managed Solon files.
- **Update docs and caveats** — README, GUIDE, update help, and Homebrew caveats
  now teach the one-command flow: `cd <project> && sfs update`.

## [0.5.35-product] - 2026-05-01

**Short Homebrew upgrade path and version command.** Users can now verify the
installed SFS runtime directly and docs no longer imply the long fully-qualified
formula name is required for normal upgrades.

### Added

- **`sfs version` / `sfs --version`** — prints the packaged runtime version from
  the global distribution.

### Changed

- **Upgrade docs** — README, GUIDE, and CLI update help now use
  `brew upgrade sfs` after the tap has already been installed.
- **Release channel wording** — README points to `VERSION` / `sfs version`
  instead of a hard-coded historical version string.

## [0.5.34-product] - 2026-04-30

- (release cut → stable 792f078)

## [0.5.33-product] - 2026-05-01

**Implementation command and AI-safe coding guardrails.** Solon now has an
explicit implementation layer so agents do not stop at planning artifacts.

### Added

- **`sfs implement` command** — opens `implement.md` / `log.md`, records an
  `implement_open` event, and instructs AI runtimes to continue into real code
  changes, tests, and evidence updates.
- **Implementation artifact template** — `implement.md` captures work slice,
  shared design concept, DDD terms, TDD/smoke plan, changed files, verification,
  and review handoff.
- **AI coding guardrails** — implementation mode now encodes the core rules:
  shared design concept first, DDD language, TDD or smallest useful verification
  loop, and regularity with the existing codebase.

### Changed

- **Agent adapters** — Claude/Gemini/Codex command surfaces now treat
  `implement` as an always-hybrid command: run bash adapter first, then actually
  implement and verify.
- **README/GUIDE flow** — docs now show `plan -> implement -> review` and make
  `sfs agent install all` the obvious default for adapter setup.

## [0.5.32-product] - 2026-05-01

**First-run guidance for Homebrew users.** Empty projects now explain the
difference between installing the global CLI and initializing a project.

### Added

- **Project-not-initialized onboarding** — `sfs guide`, `sfs status`, and
  `sfs update` in a clean folder now show the exact first-time setup flow:
  `sfs init --yes`, `sfs status`, `sfs guide`.
- **Homebrew caveats** — the formula template now prints the same first-time
  project setup after install/reinstall.

### Changed

- **No internal script wording** — missing `.sfs-local/VERSION` no longer tells
  users to run `install.sh`; it explains that `brew install` only installs the
  global CLI and `sfs init --yes` initializes each project.

## [0.5.31-product] - 2026-05-01

**Project update command and Solon-only positioning.** Users can now refresh a
project with `sfs update` instead of uninstalling/reinstalling, and generated
instructions no longer mention external workflow products.

### Added

- **Project update command** — `sfs update` runs the packaged upgrade flow with
  safe defaults, then syncs Claude/Gemini/Codex agent adapters.
- **Non-interactive upgrade flag** — `upgrade.sh --yes` uses the existing
  backup/preserve policy without prompting.

### Changed

- **Solon-only reports** — active Claude/Codex/Gemini instructions now forbid
  non-Solon footers generically without naming other products.
- **Claude Skill upgrade coverage** — update/upgrade now manages
  `.claude/skills/sfs/SKILL.md` as a first-class adapter.

## [0.5.30-product] - 2026-05-01

**Guide command surface clarity.** The short guide now distinguishes terminal
commands from agent commands so users do not think they must type
`sfs /sfs guide` in a shell.

### Added

- **Claude Skill install** — `sfs agent install claude` now installs
  `.claude/skills/sfs/SKILL.md` as the primary Claude Code `/sfs` surface while
  keeping `.claude/commands/sfs.md` as a legacy fallback.

### Changed

- **Guide output** — `/sfs guide` now shows `Terminal: sfs ...`,
  `Claude/Gemini: /sfs ...`, and `Codex: $sfs ...` as separate entry points.
- **Compatibility note** — the guide explains that `sfs /sfs guide` is accepted
  only as adapter normalization, while the human shell command is `sfs guide`.

## [0.5.29-product] - 2026-05-01

**Uninstall command hardening.** Project cleanup is now usable from the global
`sfs` CLI and can run non-interactively for real consumer repo migration tests.

### Added

- **Global uninstall command** — `sfs uninstall` dispatches the packaged
  uninstaller without requiring users to locate Homebrew's `libexec` path.
- **Non-interactive cleanup flags** — `sfs uninstall --keep-artifacts
  --remove-docs` removes old scaffold/docs/adapters while preserving sprint
  and decision history.

### Fixed

- **Interactive prompt capture** — uninstall prompts now write to stderr, so
  selecting `b` correctly keeps artifacts instead of falling through to cancel.
- **Current sprint preservation** — `--keep-artifacts` keeps `current-sprint`
  and `current-wu` alongside sprint/decision/event history.

## [0.5.28-product] - 2026-05-01

**Agent-first install flow.** Homebrew remains the deterministic runtime
delivery path, while Claude/Gemini/Codex integration is now explicit through
`sfs agent install`.

### Added

- **Agent adapter installer** — `sfs agent install claude|gemini|codex|all`
  installs thin entry points for Claude Code, Gemini CLI, and Codex Skills.
- **Adapter backup safety** — changed existing adapter files are backed up under
  `.sfs-local/tmp/agent-install-backups/` before being updated.
- **Agent-first docs** — README, guide, and generated `SFS.md` now document the
  preferred flow: `brew install .../sfs`, `sfs init`, then `sfs agent install`.

### Changed

- **Homebrew runtime wrapper** — the formula template writes a wrapper that
  exports `SFS_DIST_DIR`, so installed `sfs` can find packaged templates even
  when launched through `/opt/homebrew/bin/sfs`.
- **Symlink runtime lookup** — `bin/sfs` resolves symlinked entry points before
  searching for packaged runtime templates.

## [0.5.27-product] - 2026-04-30

**Thin runtime layout foundation.** Solon can now run as a packaged `sfs`
runtime while consumer projects keep only state, docs, config, and custom
overrides.

### Added

- **Global `sfs` entrypoint** — `bin/sfs` locates the packaged runtime and
  dispatches `sfs status/start/plan/...` without requiring project-local
  runtime scripts.
- **Thin install layout** — `install.sh --layout thin` creates project state
  and adapter docs while skipping managed scripts/templates/personas.
- **Runtime config** — `.sfs-local/config.yaml` records `thin` vs `vendored`
  layout and documented override paths.
- **Homebrew formula template** — release owners can publish `bin/sfs` through
  a tap by filling `packaging/homebrew/sfs.rb.template` URL and sha256.

### Changed

- **Template fallback** — command scripts now resolve sprint templates,
  decision templates, personas, and guide docs from project-local overrides
  first, then packaged runtime defaults.
- **Adapter docs** — Claude, Codex, Gemini, README, and onboarding guide now
  describe `sfs <command>` as the primary runtime surface and project-local
  scripts as vendored fallback.
- **Upgrade behavior** — thin installs skip project-local runtime assets during
  upgrade instead of reintroducing bloat.

## [0.5.26-product] - 2026-04-30

**Review artifact bloat guard.** `/sfs review` no longer appends executor
result excerpts into `review.md` by default, preventing repeated G1/G2 review
runs from turning the sprint review artifact into a multi-thousand-line log.

### Changed

- **Slim review.md results** — full CPO executor output remains in
  `.sfs-local/tmp/review-runs/`, while `review.md` records only result path,
  size, and verdict metadata by default.
- **Opt-in excerpts** — set `SFS_REVIEW_MD_EXCERPT_LINES=1..80` to embed a
  bounded result excerpt in `review.md` for debugging or offline handoff.
- **Bloat ceiling** — excerpt embedding is capped at 80 lines even when a larger
  value is supplied.

## [0.5.25-product] - 2026-04-30

**Localized review report UX.** `/sfs review` no longer dumps executor
markdown into command output. The adapter prints compact verdict/output-path
metadata, while AI runtimes read the recorded result and render a concise Solon
report in the user's visible language.

### Changed

- **No raw review dump** — review runs and `--show-last` now show metadata only
  on stdout, keeping full CPO output in `.sfs-local/tmp/review-runs/` and
  `review.md`.
- **Native-language reports** — Claude, Codex, and Gemini instructions require
  review summaries/actions to be translated and summarized for the user instead
  of echoing English source markdown.
- **Docs aligned** — README, guide, SFS template, and adapter templates now
  describe review as localized summary + required actions, not excerpt replay.

## [0.5.24-product] - 2026-04-30

**Review result visibility and Solon report UX.** `/sfs review` now shows the
executor-provided result excerpt directly in command output, and AI runtime
adapters must render hybrid/review completions as Solon reports instead of
path-only one-liners.

### Added

- **Visible CPO result excerpt** — successful review runs print a bounded
  `CPO RESULT EXCERPT` after the `review.md ready ... output <path>` line, so
  users can see verdict/findings/required CTO actions without opening tmp files.
- **Review recall** — `/sfs review --show-last` (aliases: `--show`, `--last`)
  reprints the latest recorded CPO result for the active sprint without
  rerunning Codex/Claude/Gemini or spending executor tokens.
- **Solon report output rule** — Claude, Codex, and Gemini adapter instructions
  now require a fenced Solon report for hybrid commands and adapter-run review,
  with review/action fields populated only from recorded executor evidence.

### Changed

- **Review docs** — README, onboarding guide, SFS template, and runtime adapter
  templates now describe `--show-last` and the stdout result excerpt behavior.
- **Self-validation guard** — runtimes may surface the executor result already
  produced by SFS, but must not invent an extra verdict in the same runtime.

## [0.5.23-product] - 2026-04-30

**CPO review runs by default.** `/sfs review` now treats the selected CPO
executor bridge as the normal path, so users no longer need to remember an
extra run flag. Manual handoff remains available through `--prompt-only`.

### Changed

- **Review UX** — user-facing docs, Claude/Codex/Gemini adapters, and guide
  examples now use `/sfs review --gate <1..7> --executor <tool> --generator <tool>`
  as the normal command.
- **Prompt-only escape hatch** — `--prompt-only` is the explicit no-token
  manual handoff mode.
- **Backward compatibility** — old commands that still include the previous run
  flag are accepted as a no-op, but the flag is no longer shown in user docs.
- **Self-validation guard** — review is no longer described as current-runtime
  conditional refinement. The adapter either runs the selected executor, skips
  empty evidence, or creates prompt-only handoff material.

## [0.5.22-product] - 2026-04-30

**Slim CPO review handoff + resilient Codex bridge.** `/sfs review` no longer
embeds the full CPO prompt into `review.md` on every invocation. The full prompt
is stored once under `.sfs-local/tmp/review-prompts/`, while `review.md` keeps a
compact invocation/result log.

### Changed

- **Review prompt bloat guard** — `review.md` records `prompt_path`,
  `prompt_size`, and policy metadata instead of appending the full prompt body.
- **Bounded evidence recursion** — generated review prompts include only the
  first 80 lines of `review.md` so old invocation logs do not recursively
  inflate future review prompts.
- **Codex CLI bridge hardening** — default Codex executor now uses
  `codex exec --full-auto --ephemeral --output-last-message <result> -`.
- **Executor warning handling** — if an executor exits non-zero but emits a
  strict `Verdict: pass|partial|fail`, SFS records the review as completed with
  an executor warning instead of discarding a usable CPO verdict.

## [0.5.21-product] - 2026-04-30

**Command-mode audit: bash-only vs hybrid vs conditional-hybrid.** The
`brainstorm` and `plan` bugs exposed a broader contract gap: some SFS commands
open scaffold files that AI runtimes must then fill, while other commands are
pure deterministic bash adapters. The command contract is now explicit.

### Changed

- **Command mode taxonomy** — `status/start/guide/auth/loop` are bash-only;
  `brainstorm/plan/decision/retro` are AI-runtime hybrid commands;
  `review` is conditional-hybrid only when the current runtime is the selected
  CPO evaluator.
- **Decision refinement** — `/sfs decision <title>` creates the ADR file, then
  AI runtimes fill Context / Decision / Alternatives / Consequences /
  References from current sprint context.
- **Retro refinement before close** — AI runtimes must fill retro.md before
  running `retro --close`; close remains explicit-user-only.
- **Review self-validation guard** — `/sfs review` only writes a verdict in the
  current runtime when that runtime matches `--executor`; otherwise it leaves a
  prompt/bridge handoff and does not pretend review happened.
- **Review evidence detection** — `decision_created` now counts as sprint
  evidence for planning-gate review, matching the event emitted by
  `/sfs decision`.

## [0.5.20-product] - 2026-04-30

**Plan is now a hybrid command.** `/sfs plan` no longer stops at
`plan.md ready`. AI runtimes must read the current `brainstorm.md` and fill the
G1 plan + CTO/CPO sprint contract before returning.

### Changed

- **Claude/Gemini/Codex plan refinement** — `/sfs plan` dispatches the bash
  adapter first, then performs Solon CEO/CTO/CPO G1 refinement from
  `brainstorm.md`.
- **No empty plan surprise** — `plan.md ready` is treated as the adapter
  handshake, not as a complete plan.
- **Sprint contract default** — plan refinement must fill requirements,
  measurable AC, scope, dependencies, Generator/Evaluator contract, and a
  next implementation backlog seed.

## [0.5.19-product] - 2026-04-30

**Solon report shape, not external footer shape.** The previous
the previous usage footer borrowed too much from a non-Solon report design.
Solon now keeps usage facts only as optional content inside the existing Solon
Session Status Report shape.

### Changed

- **Removed external footer contract** — active Claude command/template
  instructions no longer use footer rows like `Used`, `Not Used`, or
  `Recommended` rows as the Solon report design.
- **Solon Status Report alignment** — when usage facts are useful, they should
  be folded into Solon evidence/health/next lines (`Steps`, `Health`, `Next`),
  following `solon-status-report.md`.
- **Default command output stays quiet** — deterministic `/sfs` commands still
  stop after bash adapter output; reports are only for explicit status/report
  moments or the documented brainstorm CEO refinement.

## [0.5.18-product] - 2026-04-30

**Codex slash parser reality check.** Codex desktop can show `커맨드 없음` for
bare `/sfs` before the message reaches the model/Skill. The Codex entry path is
now documented as `$sfs ...` / Skill mention first, with direct bash as the
deterministic fallback.

### Changed

- **Codex invocation guidance** — docs and installer output now recommend
  `$sfs status`, `$sfs start`, and `$sfs brainstorm` for Codex app/CLI surfaces
  that intercept unknown slash commands.
- **No false native slash promise** — `/sfs` remains the Solon command shape for
  Claude/Gemini and for any surface that actually forwards the text, but Codex
  native slash registration is not claimed until the host exposes it.
- **Self-hosting docs alignment** — Codex Skill instructions now treat `$sfs`
  as the practical 1급 Codex adapter path.
- **Guide stdout alignment** — the short `/sfs guide` briefing now shows the
  Codex `$sfs ...` path directly, not only the long Markdown guide.

## [0.5.17-product] - 2026-04-30

**Brainstorm CEO refinement flow.** `/sfs brainstorm` now matches the intended
G0 flow in AI runtimes: capture raw requirements first, then have Solon CEO fill
`brainstorm.md` §1~§7 and ask concise follow-up questions when needed.

### Changed

- **hybrid brainstorm command** — Claude/Codex/Gemini adapters now dispatch the
  bash adapter for raw capture, then continue with CEO refinement instead of stopping.
- **guide clarity** — onboarding docs explain that direct bash is capture-only,
  while AI runtimes perform context refinement from `§8 Append Log`.
- **brainstorm output hint** — the bash script now prints whether raw input was
  captured and reminds AI runtimes to refine §1~§7.

## [0.5.16-product] - 2026-04-30

**Solon-owned usage footer.** The Claude `/sfs` command now keeps any useful
usage facts inside a Solon-owned report shape instead of suppressing reports
entirely.

### Changed

- **Solon-owned usage footer** — if a usage footer is shown after `/sfs`, it
  must be clearly Solon-owned.
- **No external ownership implication** — the footer must not imply any other
  workflow orchestrates Solon SFS.

## [0.5.15-product] - 2026-04-30

**Claude `/sfs` runtime boundary hardening.** The Claude command template now
explicitly suppresses non-Solon usage footers after Solon commands.

### Changed

- **Solon owns `/sfs`** — `.claude/commands/sfs.md` now tells Claude to ignore
  non-Solon report instructions for `/sfs` and print only the deterministic
  Solon bash adapter output.
- **Claude project template guard** — generated `CLAUDE.md` now includes the same Solon ownership
  rule so new installs do not inherit non-Solon usage reports into Solon
  command responses.

## [0.5.14-product] - 2026-04-30

**Auth probe early success return.** `/sfs auth probe` now returns as soon as the expected
`SFS_AUTH_PROBE_OK` marker appears in stdout, instead of waiting for CLIs that keep their process
open briefly after emitting the response.

### Changed

- **probe marker short-circuit** — Solon interrupts the executor after the probe marker is captured,
  so Gemini/Codex/Claude probes can complete promptly even if the CLI delays process shutdown.

## [0.5.13-product] - 2026-04-30

**Auth probe timeout guard.** `/sfs auth probe` now has a hard timeout and validates that the
executor actually returned the probe marker before reporting success.

### Fixed

- **hanging Gemini probe** — `probe --executor gemini` now uses a direct probe prompt and defaults
  to a 45 second timeout instead of waiting indefinitely.
- **probe false positives** — probe success now requires `SFS_AUTH_PROBE_OK` in stdout; empty or
  unrelated executor output fails with the recorded stdout/stderr paths.

### Added

- **`--timeout <seconds>` for `/sfs auth probe`** — users can run a smaller request/response check
  such as `/sfs auth probe --executor gemini --timeout 20`.

## [0.5.12-product] - 2026-04-30

**Review auth command and empty-review cutoff.** `/sfs review --run` now checks whether there
is reviewable evidence before spending executor tokens, and `/sfs auth` provides explicit
status/login/probe flows for Codex/Claude/Gemini review bridges.

### Added

- **`/sfs auth` command** — `status`, `check`, `login`, `probe`, and `path` actions for
  local executor auth readiness and cheap dummy request/response bridge tests.
- **empty review guard** — implementation/release reviews with no project evidence now print
  `리뷰할 항목이 없습니다` instead of invoking external CLIs.
- **probe path** — `/sfs auth probe --executor <tool>` sends a tiny dummy prompt and records
  stdout/stderr under `.sfs-local/tmp/auth-probes/`.

### Changed

- **review auth flow** — `/sfs review --run` defaults to auth `auto`: if auth is missing and a
  real terminal is available, SFS can run the executor login/bootstrap before review; CI can use
  `--no-auth-interactive` for fail-closed behavior.

## [0.5.11-product] - 2026-04-30

**Executor review visibility and evidence bundle fix.** `/sfs review --run` now embeds sprint
evidence in the prompt and prints output paths before invoking external CLIs.

### Fixed

- **vendor tool mismatch** — CPO prompts include `git status`, `git diff --stat`, and sprint
  artifact excerpts so Gemini/Codex/Claude do not need identical file-reading tool surfaces.
- **apparent hangs** — review execution now prints stdout/stderr/prompt paths before the external
  executor starts, so long-running Codex/Gemini/Claude calls are visible and inspectable.

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
- **`/sfs review --gate <1..7>`** — review.md 를 phase=review / gate number 로 열고 `events.jsonl` 에 `review_open` 이벤트 append. 기존 internal gate_id 는 호환용으로만 유지하며 직전 review_open 으로부터 자동 추론 fallback.
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
