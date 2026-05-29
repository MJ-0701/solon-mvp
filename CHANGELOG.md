## [Unreleased]

## [0.7.10] - 2026-05-29

> **Session-transfer durable-handoff enumeration + 200-line md routed policy + harness operational-log-lag / md-line-budget detectors + `sfs handoff verify`.**

두 버그가 한 뿌리에서 나온다: 운영 로그(릴리스 ledger / 세션 history /
handoff state)를 first-class 로딩 표면으로 다루지 않아 조용히 drift 하고
(`0.6.141 → 0.7.9`, 16 release lag) 비대해진다(PROGRESS.md 455줄). 0.7.10 은
탐지·차단 표면을 추가하고 규칙을 routed policy 로 승격한다.

### Added

- `templates/.sfs-local-template/context/policies/md-line-budget.md`
  (+ `.ko.md`) — 200줄 ceiling 을 정식 routed policy 로 승격. scope(라우티드
  컨텍스트 / 최상위 문서 / 운영 로그 / 사용자 long-form), threshold
  (warn 180 / partial 200 / fail 250), archive 회전 절차, 예외 목록
  (CHANGELOG / RELEASE-NOTES / QA-REPORT / INTEGRATION-VERIFY / archives /
  tests fixtures)을 본문에 명시. `_INDEX.md` 에 라우팅 등록.
- `sfs harness doctor` 에 두 detector 추가 ("Operational Logs And Size"
  섹션):
  - `operational-log-lag` — `VERSION` 과 `PROGRESS.md`
    `last_completed_release.version` 비교. 같은 major.minor 의 patch
    distance ≥1 → warn, minor/major 차이거나 ≥5 → partial.
  - `md-line-budget-violation` — 프로젝트 작업트리의 in-scope md 를 walk,
    파일별 warn(180) / partial(200) / fail(250). fail 은 doctor 를
    non-zero 로 종료.
- `sfs handoff verify [--dir <docset-root>]` 신규 명령 — session-transfer
  -autopilot.md 의 8-item mandatory sync surface(VERSION / CHANGELOG
  headline / `last_completed_release` / `recent_session_owner_history` /
  `resume_hint.default_action` / HANDOFF stub / `sessions/_INDEX.md` /
  200줄 준수)를 PASS / MISMATCH / N/A 로 한 페이지 출력. mismatch 1건이라도
  있으면 exit 1.
- `tests/test-md-line-budget-policy.sh` — policy 문서 자체가 frontmatter +
  200줄 budget + scope/threshold/exception 키워드 + detector 참조를
  유지하는지 잠금.
- `tests/test-operational-log-lag-detector.sh` — synthetic PROGRESS.md /
  VERSION fixture 로 in-sync→ok, patch lag→warn, minor lag→partial,
  260줄 운영 로그→md-line-budget fail + doctor non-zero 를 잠금.

### Changed

- `docs/maintenance/policies/session-transfer-autopilot.md` — durable
  handoff artifact 정의에 `## Durable handoff artifact — mandatory sync
  surface` 8-item enumeration 추가. (8) 은 `sfs handoff verify` 의 검사
  항목 SSoT.

## [0.7.9] - 2026-05-29

> **Broad-substring sibling sweep — `auth` / `perf` / `tax` / `aggregate` / `memory` / `query` / `api` / `ui` / `ddd` / `tdd` patterns tightened in both text and path branches of infer_review_lens.**

0.7.1 fixed the `*"ui"*` (→ "build") and `*"ops"*` (→ "develops")
false-positive routings but did not sweep the sibling patterns in the
same case chain. 0.7.9 is the proactive cleanup: each remaining bare
substring that risked matching a common English word or path fragment
is tightened to word-boundary / dir-style / high-signal phrase form,
or dropped when it duplicated another pattern in the same branch.

### Changed

- `infer_review_lens` TEXT branches tightened:
  - **security**: `*"auth"*` → word-boundary + `authn` / `authz` /
    high-signal phrases. `*"secret"*` → `secret key` / `secret token` /
    `secret manager` / `secret rotation` / `secret storage` / `secrets/`.
    `*"token"*` → `api token` / `bearer token` / `access token` /
    `oauth token` / `refresh token`.
  - **performance**: dropped `*"perf"*` (redundant with `*"performance"*`,
    matched "perfect" / "perform"). `*"query"*` → `sql query` /
    `db query` / `slow query` / `queries`. `*"memory"*` → `memory leak`
    / `memory usage` / `out of memory` / `oom` / `heap usage`.
  - **ddd-tdd**: `*"aggregate"*` → ` aggregate ` / `aggregate root` /
    `aggregate boundary` / `ddd aggregate`.
  - **management-admin**: `*"tax"*` → ` tax ` / `tax form` / `taxpayer`
    / `taxation` / `taxes` / `tax record`.
- `review_path_lens_signal` PATH branches tightened:
  - **security**: bare `*auth*` / `*token*` / `*secret*` / `*pii*` →
    dir-style + high-signal forms (`auth/`, `authn`, `authz`, `oauth*`,
    `secrets/`, `secret-manager`, `tokens/`, `api-token`, `pii-*`).
  - **performance**: dropped bare `*perf*` (redundant with `*performance*`).
    Compound forms required for `*query*` and `*memory*` (`sql-query`,
    `slow-query`, `memory-leak`, `memory-profile`, `heap-profile`).
    `*bundle*` → `*bundle-size*`.
  - **api-contract**: bare `*api*` → `api/` / `apis/` / `public-api` /
    `restapi`. bare `*interface*` → `src/main/*/interfaces` /
    `interface.py` / `interfaces.py`.
  - **design**: bare `*ui*` / `*ux*` / `*design*` → dir-style
    (`ui/`, `ux/`, `-ui-`, `-ux-`, `react-ui`, `ui-kit`, `design-system`).
  - **ddd-tdd**: bare `*ddd*` / `*tdd*` (3-char substring matched
    "daddy", "boundaddyd") → `ddd/` / `-ddd-` / `tdd/` / `-tdd-`.

### Tests

- `tests/test-review-lens-false-positive-rejection.sh` pairs each
  rejection case with the legitimate positive case. Every formerly-loose
  substring is probed against a common English word that previously
  triggered it ("author", "perfect", "taxonomy", "aggregated data",
  "queryable", "guide", "build", "library", "auxiliary", "rapid",
  "scrappy", "daddy") and asserted to NOT match; the high-signal
  form (e.g. "authentication", "out of memory", "sql query", "src/ui/",
  "src/api/users.py", "src/main/*/domain") is asserted to STILL match.
  A regression that re-broadens any pattern fails immediately with a
  pointer to the offending case.
- The six existing review tests (`agent-build-review-lens`,
  `review-auto-lens-lock`, `review-lens-aliases`,
  `review-auth-preflight`, `review-cosmetic-boundary`,
  `review-implementation-sequence`) continue to pass — the sweep
  preserved every legitimate routing decision.

## [0.7.8] - 2026-05-29

> **Writing discipline policy — the compactness floor in kernel.md now has a ceiling: no preamble, hedging, self-congratulation, re-statement, or filler conclusions in user-facing artifacts.**

User report (study-note README cut by hand after codex shipped a fluffy
first pass): the "caveman" policy that was supposed to keep user-facing
writing tight was not enforced. Investigation found the existing
`docs/ko/10x-value/06-token-diet-10x.md` only treated Caveman as a
playful *opt-in persona*, and `kernel.md` only had a compactness
*floor* (do not lose evidence). No actual writing-quality contract
existed for README / GUIDE / RELEASE-NOTES / reports / study notes.
0.7.8 ships that contract as a routed policy.

### Added

- `templates/.sfs-local-template/context/policies/writing-discipline.md`
  and the `.ko.md` mirror. The policy enumerates six forbidden categories
  (preamble, self-congratulation, hedging without information,
  re-statement, filler conclusions, marketing prose), five categories
  to keep (facts, decisions, evidence, boundaries, risk warnings), the
  review-time check, and an explicit "Caveman persona vs
  writing-discipline" disambiguation.
- `templates/.sfs-local-template/context/kernel.md` cross-links the
  new policy with a one-line summary so an agent reading only the
  kernel still meets the rule. The line lists the forbidden categories
  inline, intentionally — kernel readers should not need to follow
  the link to know what counts as fluff.
- `templates/.sfs-local-template/context/_INDEX.md` registers
  `policies/writing-discipline.md` between `source-driven-development`
  and `debugging-and-error-recovery`.
- `docs/ko/10x-value/06-token-diet-10x.md` "Persona opt-in" row now
  carries a one-line disambiguation noting Caveman is a style toggle
  and pointing at `policies/writing-discipline.md` for the quality
  contract.

### Tests

- `tests/test-writing-discipline-policy.sh` locks the whole wiring:
  both policy files exist with the right `load_when` triggers
  (EN: `readme`, `writing`, `report`, `documentation`, `docs`,
  `caveman`, `README.md`, `RELEASE-NOTES.md`; KO: `보고서`,
  `문서 작성`, `안내서`, `미사여구`); the six forbidden categories
  and five keep-categories are enumerated in both bodies; the
  Caveman disambiguation heading is present in both; kernel.md
  cross-links the policy and inlines the forbidden categories;
  `_INDEX.md` registers the new file; `06-token-diet-10x.md` carries
  the disambiguation; `sfs context cat policies/writing-discipline`
  resolves to the EN policy.

## [0.7.7] - 2026-05-28

> **Flow integration #4 — run-all.sh now reports per-category pass/fail alongside the existing flat summary. Final patch in the 0.7.x flow-integration series.**

The test suite grew from 110 (pre-0.7.0) to 122 (0.7.7) and the flat
"PASS: N / FAIL: M" summary started losing useful signal — a reader
could not tell at a glance whether failures were in the new host-channel
surface, the harness, the review path, or the legacy core. 0.7.7 adds a
per-category breakdown to the run-all summary without changing the
existing flat shape; CI consumers that grep the old format keep working.

### Added

- `tests/run-all.sh` classifies every `test-*.sh` into one of eight
  categories — `host-channel`, `harness`, `release`, `packaging`,
  `review`, `doc-and-context`, `hygiene-and-policy`, `sfs-core`, plus an
  `other` catch-all — and prints per-category PASS / FAIL counts under
  a new "by category:" header after the existing flat summary. The
  category label is also surfaced in the per-test header line
  (`=== test-X.sh [category] ===`) so a streaming reader can see the
  classification without waiting for the summary.
- `tests/test-run-all-categorization.sh` — locks the classifier. The
  test sources the `categorize()` function out of run-all.sh and probes
  it with at least one representative filename from each category
  (including a fall-through case to `other`). Editing run-all.sh to
  drop a category, rename the summary header, or break the parallel-
  array bookkeeping triggers an immediate failure.

### Notes

- The flat `--- run-all summary --- / PASS: N / FAIL: M / Failed scripts:`
  shape is preserved verbatim. The per-category lines appear *after*
  that block, separated by a `  by category:` header line.
- Bash 3.2 compat is preserved: the implementation uses parallel arrays
  (`cat_keys[]`, `cat_pass[]`, `cat_fail[]`) instead of an associative
  array.
- This closes the four-patch 0.7.x **Flow Integration** series:
  0.7.4 (entry surfaces) → 0.7.5 (bootstrap + install) → 0.7.6 (harness
  doctor + map) → 0.7.7 (test harness categorization). Each patch is
  pure additive — zero existing flow signature changed, zero rewrite.

## [0.7.6] - 2026-05-28

> **Flow integration #3 — harness doctor + map now know about the 0.7.0 host-channel surface.**

0.7.0~0.7.5 added MCP server, permission preset, Agent SDK scaffold, and
the agent-build review lens, but `sfs harness doctor` and `sfs harness
map` did not check or report any of them. 0.7.6 closes that gap. The
existing harness checks (entry, divisions, tests, release) are unchanged;
the new "Host Channels And 0.7.0 Surface" section runs alongside them
and the harness map gains one new row.

### Added

- `sfs harness doctor` now ends with a "Host Channels And 0.7.0 Surface"
  section that confirms (or warns about) four signals: the MCP server
  artifact under the distribution, the Solon-safe permission preset
  (distribution-side or consumer-side `.sfs-local/presets/`), the
  Claude Agent SDK scaffold under `templates/`, and whether the
  consumer project itself looks like an agent-build track (an `agent.py`,
  `mcp-server/`, `system_prompt.md`, or `solon-safe-permissions.yaml`
  in the project root). The agent-build-track signal is informational
  only — it tells the user when Gate 6 review will auto-route to the
  `agent-build` lens.
- `sfs harness map` (and `sfs harness map --write`) now emits one extra
  row in the Harness Components table: **Host channels (0.7.0+)**. The
  row inlines the four channel statuses so the written map captures the
  same information the doctor prints.
- Four new detection helpers in `scripts/sfs-harness.sh`:
  `detect_mcp_server_artifact`, `detect_solon_safe_preset`,
  `detect_agent_sdk_template`, `detect_agent_build_track`.

### Tests

- `tests/test-harness-host-channel-surface.sh` locks the contract.
  After a `sfs init`, the doctor section appears with all four signal
  lines, the map row appears with the same four channel labels, every
  detector function is statically present, and a positive `agent.py`
  case is actually classified as the agent-build track.

## [0.7.5] - 2026-05-28

> **Flow integration #2 — bootstrap + install. `sfs bootstrap --template <name>` now scaffolds any directory under `templates/`, and the install completion message lists the four 0.7.0 host-agnostic surfaces.**

0.7.0 shipped `templates/claude-agent-sdk-zero/` but `sfs bootstrap` only
knew about `spring-kotlin-zero`. The README directed users to
`sfs bootstrap --template ...`, which did not work. 0.7.5 closes that
gap and also pulls the four 0.7.0+ surfaces (MCP server, permission
preset, agent-build lens, Agent SDK template) into the post-install
hint. Additive — existing Spring/Kotlin bootstrap path is unchanged.

### Added

- `sfs bootstrap --experimental --template <name> <project-name>`
  scaffolds any directory shipped under `templates/<name>/` (today:
  `claude-agent-sdk-zero` and `spring-kotlin-zero`; future templates
  will Just Work). The generic-template path runs only the always-on
  placeholder substitutions (`<PROJECT-NAME>`, `<DATE>`, `<DOMAIN>`)
  so non-Spring scaffolds do not get Java values injected. Spring-only
  flags (`--java-version`, `--spring-boot`, `--package`, `--refresh`)
  are quietly ignored when `--template` is set; the original
  `--stack spring-kotlin` path stays default-on for legacy callers.
- `install.sh` completion message now ends with a §8 "0.7.0+
  host-agnostic 진입" section that names the MCP bridge install path
  (with the source-clone caveat), the permission preset path, the
  scaffold command for `claude-agent-sdk-zero`, and the auto-routing
  of `agent-build` lens. New users see the four 0.7.0 surfaces on the
  first `./install.sh` run instead of discovering them later.

### Tests

- `tests/test-bootstrap-template-flag.sh` — locks the contract:
  `--help` advertises the new flag, scaffold of `claude-agent-sdk-zero`
  produces the seven expected files with all placeholders substituted,
  Spring tokens stay absent from the generic path, and a `--template ../escape`
  attempt is rejected with a clear error.
- `tests/test-install-completion-hints.sh` — locks the completion
  message so the four 0.7.0 surface keywords (`solon-mcp`,
  `mcp-server/README.md`, `solon-safe-permissions.yaml`,
  `claude-agent-sdk-zero`, `agent-build`) and the source-clone caveat
  cannot quietly drop out.

## [0.7.4] - 2026-05-28

> **Flow integration #1 — host-agnostic entry surfaces. CLI / MCP / Agent SDK are documented as three equal channels into the same 7-step flow.**

0.7.0~0.7.3 added the host-agnostic surface (`mcp-server/`,
`solon-safe-permissions.yaml`, `agent-build` review lens,
`claude-agent-sdk-zero` scaffold) but kept the doc shape from before
they existed. 0.7.4 closes that documentation gap. Every change is
additive — no existing section was rewritten, no flow signature changed.

### Added

- `docs/ko/current-product-shape/23-host-channels-and-mcp.md` and the
  English mirror, registered in each parent index's `split_children`.
  The new child explains the three host channels (CLI / MCP / Agent SDK)
  as equal entries into the same bash adapter, lists the per-host
  registration locations, and cross-links to the underlying 0.7.0
  artifacts (mcp-server/README.md, agent-build-review-lens.md,
  solon-safe-permissions.yaml).
- `README/04-section.md` (설치) gained an "MCP host 채널 (0.7.0+)"
  subsection right after the existing CLI runtime table, so a first-time
  reader sees the three channels in one page.
- `docs/maintenance/methodology-7-step.md` gained a "Host-agnostic 진입
  (0.7.0+)" section that names the three channels and notes the
  `agent-build` Gate 6 auto-routing.
- `templates/SFS.md.template` gained a "Host channel detection (0.7.0+)"
  router-doc section so the consumer's SFS.md routes the same way under
  any host.
- `templates/CLAUDE.md.template`, `templates/AGENTS.md.template`,
  `templates/GEMINI.md.template`, `templates/SFS.md.template`
  `detail_sources` frontmatter now lists
  `.sfs-local/presets/solon-safe-permissions.yaml` and
  `mcp-server/README.md` alongside the existing routed-context entries.
  The adapter docs themselves stay thin (CLAUDE/AGENTS/GEMINI stay
  `frontmatter_only: true`); the new sources are only referenced, never
  inlined.

### Tests

- `tests/test-host-channel-docs-coverage.sh` locks the additions:
  the new children exist and are registered in the parent index,
  every host-channel label (CLI / MCP / Agent SDK) appears, the
  adapter frontmatter detail_sources include both new pointers, and
  the SFS.md router gained the Host channel detection section. New
  host channels added later only need to extend this test's
  expected-phrase list.

## [0.7.3] - 2026-05-28

> **Consumer-side AS surface + PyPI publishing recipe + sandbox build artifact hygiene.**

0.7.2 fixed the doc-concern-separation bug inside this distribution repo
and locked the maintainer-side regression. 0.7.3 closes the consumer-side
loop: a polluted root adapter doc in an installed Solon project now
surfaces itself the next time the user runs `sfs status`, with a one-line
hint pointing at the existing `sfs agent doctor --fix` AS path.

### Added

- `sfs status` (and other interactive commands) now emit a single-line
  hygiene notice when a root adapter doc (`CLAUDE.md`, `AGENTS.md`,
  `GEMINI.md`) declares `frontmatter_only: true` in its frontmatter but
  carries body content. The notice names the polluted files and points
  the user at `sfs agent doctor --fix`. The detection lives in
  `sfs_maybe_emit_hygiene_notice` (templates/.sfs-local-template/scripts/
  sfs-common.sh) and respects the existing `SFS_HYGIENE_NOTICE` /
  `SFS_HYGIENE_NOTICE_TTL_SEC` gates.
- `mcp-server/PUBLISHING.md` — maintainer-side recipe for cutting a
  `solon-mcp` release to PyPI. Until that publish workflow lands,
  the recipe documents the manual cut path step by step (`build`,
  `twine check`, TestPyPI smoke, real PyPI upload, tag namespace
  `mcp-server-v*`). `mcp-server/README.md` cross-links to it so users
  who hit the documented "future shape" `pipx install solon-mcp` have a
  clear pointer to the cut schedule.
- `tests/test-polluted-adapter-hygiene-notice.sh` — regression lock.
  Materializes a polluted CLAUDE.md (frontmatter_only:true marker +
  bleed body containing "프로젝트 개요" / "배포 원칙" / "수정 시 체크리스트"
  H2s), runs `sfs status` with `SFS_HYGIENE_NOTICE_FORCE=1`, and asserts
  the WARN + `sfs agent doctor --fix` hint appear in stderr.

### Changed

- `.gitignore` extended to cover Python build artifacts that sandbox or
  local imports generate from the new 0.7.0 MCP server scaffold:
  `__pycache__/`, `*.py[cod]`, `*.egg-info/`, `build/`, `dist/`,
  `.pytest_cache/`, `.venv/`. The 0.7.2 release added a
  `mcp-server/__pycache__/` to the working tree as an untracked file —
  0.7.3 closes that hole.

### AS path recap (no code change)

The actual refactor flow for already-polluted consumer projects has not
changed; it has been working since 0.6.139:

- `sfs upgrade` automatically runs `auto_refactor_root_agent_docs` and
  archives the old body under `.sfs-local/archives/agent-doc-refactor/`.
- `sfs agent doctor --fix` can be run manually anytime.

0.7.3's contribution is purely making this AS discoverable to consumers
who do not know the doctor command exists.

## [0.7.2] - 2026-05-28

> **Doc concern separation — agent entry docs are now agent guidance only; project state / release policy / dev checklists / methodology live in docs/maintenance/.**

This patch closes a documented product bug: the top-level `CLAUDE.md`
(and to a lesser extent `AGENTS.md`) had accumulated project content
(repo identity, deployment policy, modification checklists, methodology
reference) that should never have lived inside an agent entry document.
0.7.2 separates those concerns and locks them with a new hygiene test
so the pollution cannot recur.

### Changed

- `CLAUDE.md` slimmed from 83 lines to a thin agent entry (~77 lines)
  whose body is now: a one-paragraph framing, a 4-item "작업 전 읽을 것"
  cross-link block, and the genuinely agent-rule "Agent 가 절대 하지 말
  것" section. Everything else moved to `docs/maintenance/`.
- `AGENTS.md` dropped its embedded "본 repo 와 dev staging 관계" section
  (R-D1 content moved to `docs/maintenance/release-policy.md` § R-D1).
  Cross-links in § 참고 now point at the new maintenance docs.

### Added

- `docs/maintenance/` directory — top-level repo's own maintenance docs.
  Five files:
  - `project-identity.md` — repo identity / IP / domain boundary (was
    CLAUDE.md § Repo 정체성).
  - `release-policy.md` — 8 release-policy principles + R-D1 dev-first
    (was CLAUDE.md § 배포 원칙).
  - `contributing.md` — install.sh / upgrade.sh / templates/ / mcp-server/
    / packaging/ / release-cut checklists (was CLAUDE.md § 수정 시
    체크리스트).
  - `methodology-7-step.md` — 7-step + Gate label reference (was
    CLAUDE.md § 7-step flow 요약).
  - `policies/session-transfer-autopilot.md` — full Continuation Guard
    transfer protocol (was CLAUDE.md § 배포 원칙 6).
  - `policies/six-division-council.md` — maintainer-facing pointer to
    the routed 6-division council policies (was CLAUDE.md § 배포 원칙 7).
- `tests/test-agent-entry-doc-hygiene.sh` — regression lock. Fails if:
  1. top-level `CLAUDE.md` / `AGENTS.md` exceed 100 lines or contain
     forbidden project-content H2 (`## Repo 정체성`, `## 배포 원칙`,
     `## 수정 시 체크리스트`, `## 7-step flow 요약`, …);
  2. consumer adapter templates lose their `frontmatter_only: true`
     marker;
  3. `SFS.md.template` loses its `router_doc: true` marker;
  4. any of the five new `docs/maintenance/` doc paths goes missing.

### Notes — AS for existing consumer projects

The existing `sfs agent doctor --fix` capability (shipped in 0.6.139)
already covers the AS path for already-installed consumer projects: it
detects polluted root adapter docs (anything beyond frontmatter) and
overwrites them with the clean `frontmatter_only: true` template,
backing up the prior body under `.sfs-local/archives/agent-doc-refactor/`.
0.7.2 does not change that flow — it only locks the same hygiene shape
inside the maintainer's own repo, so the pollution does not get
re-introduced upstream.

## [0.7.1] - 2026-05-28

> **0.7.0 flow integration patch — agent-build auto-routing rescued, broad-substring lens patterns tightened, `sfs context list` shipped, MCP install path clarified.**

This patch closes the four findings from the 0.7.0 integration verification
(`INTEGRATION-VERIFY-2026-05-28.md`) without changing any existing flow
signature. Every change is additive: existing CLI signatures, routed
context module list, test surfaces, and release cadence are preserved.

### Fixed

- **agent-build lens auto-routing** was outranked by broader-substring
  patterns earlier in the `infer_review_lens` case chain. A plan containing
  the word "build" was matching `*"ui"*` ("**bui**ld") and routing to
  `design`; a plan containing "develops" was matching `*"ops"*` and routing
  to `ops`. The agent-build keyword branch is now checked **first**, before
  any other lens, so the 0.7.0 routing for "MCP server", "Claude Agent SDK",
  and "sub-agent" actually fires under `--lens auto`.
- **Broad-substring lens patterns tightened**. `*"ui"*` / `*"ux"*` /
  `*"ops"*` in the `design` and `ops` branches are now word-boundary forms
  (`*" ui "*`, `*" ops "*`, `*"ui/"*`, `*"ops/"*`, etc.) plus a few
  high-signal alternatives (`devops`, `sre`, `design system`, `figma`,
  `wireframe`). The duplicated `*"secret"*` entry was removed from the
  `ops` branch — the `security` branch above already catches it. False
  positives from common English words like "guide", "build", "fluid",
  "develops", "auxiliary" no longer route real plans into the wrong lens.

### Added

- `sfs context list [commands|policies|all]` — discoverability helper that
  prints every routed module slug an agent can target with `sfs context
  cat` / `sfs context path`. New routed modules introduced in 0.7.0
  (`policies/agent-build-review-lens`, `presets/solon-safe-permissions`,
  ...) are now findable without grepping `_INDEX.md`. Implementation is
  intentionally `set -e` tolerant; the bare `[[ -d ]] && find` /
  `while read` pattern was returning rc=1 on legitimate empty-directory /
  EOF cases.
- `tests/test-context-list-command.sh` — locks the contract: top-level /
  commands / policies sections, agent-build-review-lens visible under
  policies, bad scope rejected with a clear error, usage banner advertises
  the new subcommand.

### Changed

- `mcp-server/README.md` now leads with a callout that 0.7.x only supports
  the source-clone install path. `pipx install solon-mcp` is documented as
  the **target shape** post-PyPI publish, not a currently working command.
  Removes the trap of users running `pipx install solon-mcp` and being
  surprised by a missing package.

## [0.7.0] - 2026-05-28

> **Agent SDK / MCP / sub-agent integration surface — Solon goes host-agnostic without giving up bash SSoT.**

This minor bump adds the first set of host-agnostic agent-building
surfaces to Solon. The 0.6.x line stayed bash-first and runtime-neutral
across Claude / Codex / Gemini. 0.7.0 keeps that invariant and adds
four new ways to drive a Solon project from non-bash hosts: an MCP
server, a portable permission preset, a review lens that catches
agent-build failure modes, and a Claude Agent SDK starter template.

### Added — Solon MCP server (0.7.0-A)

- New `mcp-server/` directory with a Python MCP server
  (`solon_mcp_server.py`) that wraps the `sfs` 7-step flow as MCP tools.
  Compatible with Claude Desktop, Claude in Chrome, Cursor, the
  Claude Agent SDK, and any other stdio-MCP host.
- Twelve tools shipped in the MVP: `sfs_status`, `sfs_version`,
  `sfs_report`, `sfs_harness_doctor`, `sfs_start`, `sfs_brainstorm`,
  `sfs_plan`, `sfs_implement`, `sfs_review`, `sfs_retro`,
  `sfs_decision`, `sfs_capture`. Mutating tools that need new UX
  patterns (`sfs commit`, `sfs loop`, `sfs tidy`) are intentionally
  deferred to follow-up patches.
- The server shells out to the installed `sfs` binary and forwards
  stdout **verbatim**, per kernel.md SSoT. No JSON reshaping, no
  helpful reformatting. `$SOLON_MCP_SFS_PATH` and
  `$SOLON_MCP_TIMEOUT_SEC` are the only configuration knobs.
- `mcp-server/pyproject.toml` exposes a `solon-mcp` console script
  with a sane `mcp>=1.0.0` dep pin; the rest of Solon takes no Python
  runtime dependency.
- `mcp-server/README.md` covers registration for Claude Desktop,
  Claude in Chrome, Cursor, Claude Code, and the Claude Agent SDK,
  plus an explicit "what it does NOT do" section.
- New `tests/test-mcp-server-contract.sh` statically verifies the
  server file shape and the README's registration coverage.

### Added — Solon-safe permission preset (0.7.0-B)

- New `templates/.sfs-local-template/presets/solon-safe-permissions.yaml`
  translates the CLAUDE.md "절대 금지" rules + kernel.md
  mainline-first / Gate 6 contract into a runtime-agnostic permission
  shape. Auto-push, destructive bash, hard resets, and history
  rewrites are denied by default; the `.sfs-local/` mutation surface
  must go through `sfs` rather than direct edit.
- New `tests/test-solon-safe-permissions-preset.sh` locks the
  preset's load-bearing rules so a future edit cannot quietly weaken
  the safety contract.

### Added — `agent-build` review lens (0.7.0-C)

- `sfs review --lens agent-build` (aliases: `agent`, `agents`,
  `agent-sdk`, `mcp`, `mcp-server`, `sub-agent`) registered in
  `sfs-review.sh`'s lens normalizer, label resolver, and
  infer-review-lens heuristic. The lens auto-routes when the diff
  touches `mcp-server/`, `templates/claude-agent-sdk-zero/`, or
  `agents/skills/`, or when the plan/log text mentions agent SDK /
  MCP / sub-agent keywords (EN + KO).
- New routed policy
  `templates/.sfs-local-template/context/policies/agent-build-review-lens.md`
  lists the seven CPO subsections (tool surface scope, permission
  posture, sub-agent isolation, system prompt drift, bash adapter
  SSoT, evidence + audit, failure modes specific to agent-build),
  with concrete failure examples drawn from the 0.6.142 stdin-hang
  regression and the 0.6.143 dev-staging-label leak.
- New `tests/test-agent-build-review-lens.sh` end-to-end contract test
  for the lens registration.

### Added — `claude-agent-sdk-zero` template (0.7.0-D)

- New `templates/claude-agent-sdk-zero/` scaffold: minimal Python
  project that ships an `agent.py` entrypoint, a version-controlled
  `system_prompt.md`, a pinned copy of `solon-safe-permissions.yaml`,
  and a `pyproject.toml` that pulls `claude-agent-sdk` and
  `solon-mcp` as runtime deps. Consumers materialize via
  `sfs bootstrap --template claude-agent-sdk-zero <name>`.
- Smoke pytest (`tests/test_agent_smoke.py`) inside the template
  verifies system-prompt principles, preset shape, MCP registration,
  and that no obvious secret material was committed. Runs without
  an API key.
- New top-level `tests/test-claude-agent-sdk-zero-template.sh`
  statically verifies the template's required files, placeholders,
  Solon principle coverage in the system prompt, and that the
  template's preset stays in sync with the upstream preset's
  load-bearing rules.

## [0.6.145] - 2026-05-28

> **User-facing docs policy softened from HTML-first to HTML-encouraged — current docs/ stays MD by explicit choice.**

### Changed

- Reworded the rule from "User-facing docs HTML-first" to "User-facing docs
  HTML-encouraged" across all eight agent surfaces (`CLAUDE.md`,
  `templates/.sfs-local-template/context/kernel.md`,
  `commands/sfs.toml`, `templates/.claude/commands/sfs.md`,
  `templates/.gemini/commands/sfs.toml`, `plugins/solon/commands/sfs.md`,
  `templates/codex-skill/SKILL.md`, `templates/.agents/skills/sfs/SKILL.md`).
  The rule now explicitly allows Markdown when GitHub-rendered MD is the
  primary read surface, which matches the actual state of `docs/`, `GUIDE/`,
  `README/`, and `BEGINNER-GUIDE/` (104 MD files, zero HTML).
- Closes the policy-vs-implementation gap flagged in
  `QA-REPORT-2026-05-28.md` §2.3: the previous wording would have required
  an HTML build pipeline that the thin distribution intentionally avoids.
- Synced source-side packaging fixtures (`packaging/scoop/sfs.json`,
  `packaging/homebrew/sfs.rb`) from the stale `v0.6.17` reference up to
  `v0.6.145`. The fixtures are not channel SoT — per
  `packaging/README.md`, the authoritative homebrew tap and scoop bucket
  live in external repos — but keeping the source-side copy current
  reduces grep/onboarding confusion 127 releases later. SHA256 stays at
  the cut-release placeholder.

### Tests

- `tests/test-user-facing-docs-html-first.sh` now asserts the
  HTML-encouraged wording AND the presence of the `MD remains acceptable`
  clause. Prevents the policy from quietly drifting back to HTML-first
  without an accompanying build pipeline.

## [0.6.144] - 2026-05-28

> **Test harness noise floor + nounset static-check coverage both tightened.**

### Fixed

- `install.sh` `confirm()` no longer emits the `"<question> (y/N) [N]: y"`
  Korean prompt line when `ASSUME_YES=1`. The previous behavior pushed this
  line to stderr; whenever a test runner merged stderr into stdout (notably
  `run-all.sh`'s default), the Korean prompt leaked into integration test
  output and made progress lines harder to read. `SFS_INSTALL_VERBOSE_CONFIRM=1`
  preserves the old verbose behavior as an opt-in.

### Added

- `tests/test-nounset-empty-array-expansion.sh` gained a coverage section
  that scans every bash script under `scripts/` and
  `templates/.sfs-local-template/scripts/` for unsafe `"${arr[@]}"`
  expansions. Each site must either use the `${arr[@]+"${arr[@]}"}` idiom,
  keep an explicit `${#arr[@]}` length-guard somewhere in the file, or be
  explicitly annotated with `# nounset-safe: <reason>` on the line above.
  Reduces the chance of recurring the 0.6.2 macOS bash 3.2 + `set -u`
  empty-array crash class in newly-introduced scripts.
- Hardened 11 call sites flagged by the new coverage check:
  `scripts/sfs-harness.sh`, `scripts/sfs-storage-precommit.sh`,
  `scripts/sfs-bootstrap.sh`, `scripts/sfs-sprint-yml-validator.sh`,
  `scripts/sfs-migrate-artifacts.sh` (x2),
  `templates/.sfs-local-template/scripts/sfs-adopt.sh`,
  `templates/.sfs-local-template/scripts/sfs-common.sh`,
  `templates/.sfs-local-template/scripts/sfs-tidy.sh`. Sites that are
  always populated by construction got `# nounset-safe:` annotations;
  sites that can legitimately be empty got explicit length guards.

## [0.6.143] - 2026-05-28

> **Maintainer-side dev-staging label removed from active product surfaces.**

### Fixed

- Stripped the `solon-mvp-dist/...` path prefix from the header banners of
  the eight template scripts (`sfs-plan`, `sfs-retro`, `sfs-decision`,
  `sfs-review`, `sfs-common`, `sfs-start`, `sfs-loop`, `sfs-status`). Header
  `Path note` now points at the in-repo path
  (`templates/.sfs-local-template/scripts/sfs-X.sh`) and `Visibility` reads
  `distribution template` instead of `business-only (solon-mvp-dist staging
  asset)`.
- Reworded `AGENTS.md` §"본 repo 와 dev staging 관계" to describe the
  maintainer-side dev workflow without naming the private staging workdir.
- Replaced the `solon-mvp-dist root` comment in `install-cli-discovery.sh`
  with the generic `distribution root` wording.
- Cleaned three `tests/fixtures/token-diet/*.md` review-finding samples to
  cite the in-repo template path instead of the private staging path.
- Relaxed `tests/test-md-split-audit.sh`'s assertion from the
  `solon-mvp-dist/CHANGELOG.md` substring to plain `CHANGELOG.md` — the
  audit still asserts that the largest file is the changelog, but no longer
  pins the maintainer-side dev path.

### Tests

- Extended `test-private-dev-path-hygiene.sh` regex patterns with
  `solon-mvp-dist`. The leak class that was grandfathered in 0.6.142 is now
  blocked at the source.

## [0.6.142] - 2026-05-28

> **Review executor capability probe no longer hangs on caller stdin; project harness paths drop maintainer-private docset names.**

### Fixed

- Review executor capability probe (`sfs_gemini_supports_model_flag`) now
  redirects `gemini --help` stdin to `/dev/null`. The 0.6.139 thin-router
  refactor left the probe inheriting its caller's stdin, so any executor
  (real or fake bridge in tests) that reads stdin would block until the
  outer process gave up. `test-review-auth-preflight` reproduced this as
  a 35s+ hang in the authenticated branch.
- Same `</dev/null` close applied to `claude auth status` and
  `codex login status` capability checks in `executor_auth_ready` so future
  CLI versions that read stdin on `status` cannot reintroduce the same
  silent hang.
- Removed two hardcoded maintainer-private dev-staging paths
  (`2026-04-19-sfs-v0.4/...`) from `scripts/sfs-harness.sh` `detect_test_surface`
  and `detect_release_surface`. Replaced with documented
  `SFS_HARNESS_EXTRA_TEST_DIRS` / `SFS_HARNESS_EXTRA_RELEASE_FILES`
  environment variables for consumers that want to declare non-standard
  test/release homes.
- `install.sh` now substitutes `<PROJECT-NAME>` in `divisions.yaml` to match
  the existing substitution in `model-profiles.yaml`. Consumer
  `.sfs-local/divisions.yaml` no longer ships the raw placeholder.

### Tests

- Strengthened `test-private-dev-path-hygiene.sh` patterns to fail loudly on
  dated docset directories (`YYYY-MM-DD-sfs-v\d`) and `phase1-mvp-templates`
  references — the 0.6.141 leak slipped through because the prior pattern set
  only watched the canonical workdir name. `QA-REPORT-*.md` historical
  evidence files are exempted alongside `CHANGELOG.md` / `RELEASE-NOTES.md`.

## [0.6.141] - 2026-05-28

> **Project harness maps make the AI work environment inspectable.**

### Added

- Added `sfs harness doctor` to diagnose the current project as the environment
  around the model: thin entry docs, routed context, six-division council,
  artifacts/memory, wiki/bug recurrence memory, tests, and release/check rails.
- Added `sfs harness map` and `sfs harness map --write`, which print or write
  `.sfs-local/harness/harness-map.md` with agent roles, inputs, outputs,
  quality gates, autonomy loop, and human-owned product boundaries.
- Added routed `commands/harness.md` and `policies/harness-autonomy.md` so
  agents can load the harness contract without bloating `SFS.md` or root agent
  docs.

### Changed

- Routed Harness Engineering from ambient principle into explicit project
  readiness evidence before long autonomous or optional parallel-agent work.
- Updated EN/KO product docs, README, GUIDE, SFS template, kernel, and token
  harness policy to expose the new harness doctor/map surface.

### Tests

- Added `test-sfs-harness-command.sh` and extended harness guardrails to cover
  CLI usage, context routing, map output, write path, docs, and SFS template.

## [0.6.140] - 2026-05-28

> **SFS.md router release artifact is test-clean.**

### Fixed

- Re-cut the thin `SFS.md` router release with version-regression tests synced
  to the released version, superseding the partial 0.6.139 artifact whose
  packaged test suite still expected 0.6.138.

### Tests

- Updated version-headline and docs/version-sync regressions to the release
  version before cutting the stable artifact.

## [0.6.139] - 2026-05-28

> **SFS.md is back to a thin router.**

### Fixed

- Rebuilt `SFS.md.template` as a thin project router instead of a policy
  archive. Detailed SFS behavior now stays in routed runtime context, while
  `SFS.md` keeps frontmatter, project overview, read order, default entry,
  output contract, and maintenance pointers.
- Added `sfs doctor --fix` and an upgrade post-step that detect recognized
  bloated `SFS.md` files, archive the old file, rewrite the thin router, and
  preserve the `## 프로젝트 개요` section even when `sfs upgrade` exits early
  because the runtime is already current.
- Restored `CLAUDE.md`, `AGENTS.md`, and `GEMINI.md` project templates to thin
  frontmatter-backed agent bootstraps. Durable SFS policy now stays routed
  through packaged runtime context and optional `.sfs-local/context/` overrides
  instead of being copied into every root agent file.
- Tightened those root agent templates to frontmatter-only pointers and added
  `sfs agent doctor --fix`, which detects recognized SFS adapter bloat, archives
  the old file, and rewrites it to the packaged frontmatter-only template.

### Tests

- Added `test-thin-agent-adapter-docs.sh` and updated policy regressions so
  root agent adapters are checked for routing/frontmatter/size, while detailed
  SFS rules are checked in skills, commands, and routed context.
- Added `test-sfs-router-doc-refactor.sh` for `SFS.md` bloat detection,
  archive, rewrite, upgrade post-step coverage, and project overview
  preservation.
- Added `test-agent-doc-refactor.sh` for detection, archive, rewrite, and
  non-SFS skip behavior.

## [0.6.138] - 2026-05-28

> **Domain knowledge assets now flow through six-division ledgers.**

### Changed

- Added a domain-knowledge-assets policy so expert know-how, repeated
  explanations, and craft rules can become AI-usable glossaries, playbooks,
  skills, knowledge packs, fixtures, tests, review questions, or wiki TopicHubs.
- Connected the six-division council to that asset loop so strategy-PM,
  taxonomy, design, dev, QA, and infra rows record reusable `asset_candidate`
  decisions instead of acting as decorative review ceremony.
- Promoted `asset_candidate` into executable plan, implement, and review
  ledgers so domain know-how moves from raw source to reusable artifact path,
  verification, and publication boundary.
- Routed the policy through brainstorm, plan, implement, review, the context
  index, knowledge-pack routers, kernel, agent adapters, and EN/KO product docs.

### Tests

- Added focused regression coverage for the domain knowledge asset surface,
  six-division `asset_candidate` loop, and sprint artifact ledgers.

## [0.6.137] - 2026-05-28

> **Harness Engineering guardrails are productized.**

### Changed

- Added Harness Engineering guardrails so SFS raises an agent's ceiling with
  structure, verification, and bounded tool surfaces instead of relying on
  prompt-only persuasion.
- Routed structure-over-pleading, active tool-surface budget,
  project-as-prompt audits, verification automation, and human-owned
  understanding/design boundaries through the token harness, plan, implement,
  and review contexts.
- Updated Claude/Codex/Gemini/SFS adapter surfaces, EN/KO product docs, and
  LLM Wiki maps/indexes so the same harness contract is ambient project
  context for future work.

### Tests

- Added `test-harness-engineering-guardrails.sh`.
- Regenerated LLM Wiki indexes and verified focused regressions plus the full
  product suite at 105 PASS / 0 FAIL before release prep.

## [0.6.136] - 2026-05-26

> **LLM Wiki and AI work intake routing are productized.**

### Changed

- Added an LLM Wiki/RAG boundary policy so write-time curated knowledge and
  query-time retrieval stay complementary instead of collapsing into one
  ungoverned document pile.
- Added an AI work intake routing policy that carries goal, materials,
  ask-back rule, output format, and work-size classification through
  `start`, `brainstorm`, `plan`, and sprint templates.
- Updated product-shape docs and LLM Wiki maps/indexes so these knowledge and
  work-intake harnesses are visible in the current product flow.

### Tests

- Added focused regressions for LLM Wiki/RAG boundary routing and AI work
  intake routing.
- Verified the full product suite at 104 PASS / 0 FAIL before release prep.

## [0.6.135] - 2026-05-26

> **Clarify packaging channel authority.**

### Fixed

- Clarified that product repo `packaging/homebrew/sfs.rb` and
  `packaging/scoop/sfs.json` are source-side fixtures, not the latest
  Homebrew/Scoop channel source of truth.
- Added a packaging channel map and regression coverage so maintainers can
  distinguish templates, fixtures, external tap/bucket repos, and installed
  runtime verification.

### Tests

- Added `test-packaging-channel-map.sh`.

## [0.6.134] - 2026-05-26

> **Review auth hang regression coverage is CI-stable.**

### Fixed

- Relaxed the outer wall-clock timeout in the non-interactive review-auth hang
  regression so slower CI runners do not fail before SFS can return its bounded
  executor error path.

### Tests

- Re-ran the review-auth focused regression and full product suite after the
  GitHub Codex P2 finding on 0.6.133.

## [0.6.133] - 2026-05-26

> **Linux/GNU residual QA failures are closed.**

### Fixed

- Normalized GNU `sha256sum` escaped digest prefixes so filenames containing
  backslashes do not produce false no-data-loss mismatches.
- Aligned archive branch sync locking across `flock` and advisory PID-lock
  environments, so race-lock checks graceful-exit on both paths.
- Added a non-interactive review executor timeout guard so an unbounded Gemini
  review cannot hang headless QA.

### Tests

- Extended quoted-path migration coverage with a fake GNU-style `sha256sum`.
- Reworked archive race-lock coverage to hold a real `flock` when available.
- Added a non-interactive hanging Gemini regression to `test-review-auth-preflight.sh`.
- Verified full product suite PASS 102 / FAIL 0.

## [0.6.132] - 2026-05-26

> **Stable product tests are part of release verification.**

### Fixed

- Made release cuts delete stale files inside allowlisted product directories,
  so removed tests and docs cannot survive in `solon-product` artifacts.
- Removed maintainer-only `HANDOFF-*.md` and `archives/` files from stable
  product releases.
- Made owner-docset tests portable in standalone product layout instead of
  failing only because parent maintainer scripts are absent.
- Added local stable product `tests/run-all.sh` to the release verifier.

### Tests

- Reproduced the 0.6.131 stable-product failures for private path hygiene,
  stale capture-flow, handoff line budget, and standalone layout tests.
- Verified the product test suite and release verifier close those failures
  before channel publish.

## [0.6.131] - 2026-05-26

> **Private dev staging path stays out of active product surfaces.**

### Fixed

- Removed private dev staging checkout names from active product entry docs and
  release-sequence output while preserving generic release delegation guidance.

### Tests

- Added a private-dev-path hygiene regression so active product surfaces cannot
  reintroduce the private checkout name or absolute path.

## [0.6.130] - 2026-05-25

> **Korean memo app intent tolerates extra spaces.**

### Fixed

- Normalized Korean note/memo intent spacing before matching, so valid note
  app requests such as `메모   앱 검색` still route to `tooling/cli/note-cli`
  without reintroducing broad `메모리` substring matching.

### Tests

- Extended shared handoff/domain inference tests with an extra-whitespace
  Korean memo-app positive case.

## [0.6.129] - 2026-05-25

> **Korean memo matching no longer catches memory leaks.**

### Fixed

- Narrowed note CLI natural-language inference so Korean `메모리` words, such
  as `메모리 누수 수정`, are not misclassified as `tooling/cli/note-cli`.
  Korean note/memo app intents still route to note CLI when the goal explicitly
  says `메모 앱`, `메모장`, `노트 앱`, or similar note-tool phrases.

### Tests

- Extended shared handoff/domain inference tests with a Korean memo-app
  positive case and a `메모리 누수 수정` negative case.

## [0.6.128] - 2026-05-25

> **Gate 6 cross review sees the latest self-CPO PASS.**

### Fixed

- Embedded the latest same-gate self-CPO PASS metadata and result excerpt
  directly into cross-review prompts. Gate 6 cross review no longer depends on
  the first 80 lines of `review.md` to discover prior self-CPO PASS evidence.
- Fixed review next-action rendering so partial Gate 6 reviews point back to
  `sfs review --gate 6`, not the internal `G4` artifact id or a placeholder
  gate label.
- Refined `sfs start` natural-language domain inference so `production` is not
  mistaken for `product`, and note CLI goals route to
  `tooling/cli/note-cli` instead of `catalog/products/search`.
- Added explicit Gate 6 guidance that zero-test command output is not
  acceptance evidence even when the command exits 0.

### Tests

- Added `test-sfs-review-cross-self-pass-capsule.sh` to reproduce the Gate 6
  cross-review self-PASS evidence gap and the bad next-action formatting.
- Extended shared handoff/domain inference tests with a note CLI goal that
  contains both `production` and `search` words.
- Extended behavior guardrail tests for zero-test evidence and same-gate
  self-CPO cross-review capsule guidance.

## [0.6.127] - 2026-05-25

> **Release channel workflow YAML is syntax-guarded.**

### Fixed

- Replaced an unindented heredoc inside `publish-product-channels.yml` with
  YAML-safe `printf` lines. The previous file parsed in humans' editors but
  GitHub Actions rejected it before job creation, leaving zero-job failed
  release checks.

### Tests

- Extended `test-workflow-permissions.sh` to parse every packaged workflow with
  Ruby YAML before checking permissions, so malformed workflow files fail before
  release.

## [0.6.126] - 2026-05-25

> **Release channel workflow push validation is no-op safe.**

### Fixed

- Added a push-validation no-op job to `publish-product-channels.yml` for
  workflow-file changes on product `main`, so optional missing channel
  automation auth does not leave a red zero-job release check during normal
  stable product pushes.
- Gated the real Homebrew/Scoop channel publish job to `workflow_dispatch` only.
  Local channel publish remains the release path when preflight reports
  `manual_required`.

### Tests

- Extended `test-release-channel-auth-preflight.sh` to verify the manual-only
  publish job gate and the push no-op guard.

## [0.6.125] - 2026-05-25

> **Release channel workflow auth is preflighted before dispatch.**

### Added

- Added `scripts/sfs-channel-publish-preflight.sh` to classify the optional
  `publish-product-channels.yml` automation lane before dispatch. It reports
  `workflow_ready` when `SOLON_RELEASE_BOT_TOKEN` is configured and
  `manual_required` when the release should skip the workflow and use the local
  Homebrew/Scoop channel-publish fallback.

### Changed

- Updated release and shipping policy context so missing workflow automation
  auth is not treated as a user blocker when local channel credentials are
  already available.
- Updated `publish-product-channels.yml` failure guidance to point to the
  preflight and manual channel publish fallback instead of failing as a vague
  missing-secret dead procedure.
- Updated release sequence and owner docs to run channel workflow preflight
  before dispatching cross-repo channel automation.

### Tests

- Added `test-release-channel-auth-preflight.sh` covering secret-present,
  secret-missing, and `gh secret list` failure classifications plus routed docs
  and workflow guidance.

## [0.6.124] - 2026-05-25

> **Capture is an evidence primitive, not a lifecycle flow step.**

### Changed

- Reframed `sfs capture` and `sfs note` as minimal evidence primitives for
  explicit approval, waiver, decision, blocker, review-order override, scope
  change, and accepted external evidence.
- Updated current product docs, user guide, context router, kernel, and command
  context so capture is not presented as a default SFS lifecycle step or routine
  next action.
- `sfs capture` now writes non-collapsing `evidence_capture` events. Review and
  implement readers still accept legacy `flow_capture` events for existing
  projects.
- Renamed the focused capture regression to
  `test-sfs-capture-evidence-primitive.sh`.

### Tests

- Updated capture, context-pollution, version, and docs sync tests to verify the
  new evidence-primitive contract and version metadata.

## [0.6.123] - 2026-05-25

> **Post-development Claude/Gemini review lanes and lean procedure refactoring.**

### Added

- Added post-development external review guidance for Claude Cowork, Gemini,
  GitHub `@codex`, and future reviewer bridges after implementation evidence
  exists. External reviews remain evidence and do not replace self-CPO, SFS
  cross review, Gate 3, or Gate 6.
- Added lean procedure refactor guidance so SFS can identify process
  bottlenecks, shrink or remove unnecessary ceremony, and preserve the safety
  invariant with automated evidence instead of user-visible ritual.
- Added the `process-lean` review lens and aliases for process/ceremony/
  bottleneck review.

### Tests

- Added `test-postdev-review-lean-guardrails.sh` and extended review lens alias
  coverage for `process-lean`. Focused guardrail tests verify routing through
  kernel, router, review/implement/release contexts, agent templates, and the
  review CLI lens normalizer.

## [0.6.122] - 2026-05-25

> **Mainline focus, Gate 6 data validation, OWASP/logging evidence, and checklist closure.**

### Fixed

- Added a Mainline Focus Guard so helper/tool/auth/model setup cannot hijack the
  user's real objective. Side work must be classified as `mainline`,
  `unblocker`, `deferred_followup`, `blocked`, or `out_of_scope`; only true
  unblockers may interrupt mainline work.
- Added Gate 6 data validation policy for data shape, fixture/mock/seed, API
  payload, UI state, auth/session, migration/backfill, cache, persistence, and
  log/analytics changes. Mock-only evidence is partial unless named fixtures,
  invariants, boundary/negative coverage, and command results are recorded.
- Added agentic security/logging policy mapped to OWASP-style web/API/LLM/MCP
  risks, with release checks for authz, secrets/PII, prompt/tool scope, stray
  production `console.log`/`debugger`/probe logs, and Datadog or equivalent
  redacted telemetry evidence/waiver.
- Added a wiki/workbench mission checklist skill for high-context work so
  repeated user findings are tracked from audit through edit, test, review,
  release, and final evidence instead of being lost in chat context.

### Tests

- Added `test-mainline-data-security-guardrails.sh` and extended existing
  context, behavior, line-budget, DDD/TDD, review-order, runtime-token-firewall,
  and enterprise-pack tests. Full product suite: `PASS: 98`, `FAIL: 0`.

## [0.6.121] - 2026-05-25

> **Enterprise 6-division agent-team planning and measurable review packs.**

### Added

- Added split enterprise knowledge packs for the 6-division agent team:
  `enterprise-agent-team-pack`, `enterprise-plan-council-pack`,
  `enterprise-evidence-pack`, and `enterprise-performance-review-pack`, with
  Korean mirrors and frontmatter routing.
- Gate 3 planning now treats non-trivial product-bearing work as an enterprise
  council design step: strategy-pm, dev, QA, design, infra, and taxonomy must
  record risk flags plus finding/evidence/waiver rows instead of empty ceremony.
- Gate 6 review now requires enterprise evidence ledgers for SFS/harness policy
  changes and performance/algorithm evidence when hot paths, queries, browser
  runtime, payload, memory, or concurrency can change.
- Gemini runtime routing now uses current Gemini 3.x routes: `gemini-3.1-pro-preview`
  for strategic/research/review, `gemini-3-flash-preview` for agentic coding and
  bounded implementation helpers, and `gemini-3.1-flash-lite` for relay/probe/
  economy helper work.

### Tests

- Added `test-enterprise-agent-team-knowledge-packs.sh` and updated context,
  behavior, and docs tests so the new packs are routed, line-budgeted, and
  regression-checked.

## [0.6.120] - 2026-05-25

> **Fresh-session transfer is host-owned, lossless, and resumes immediately without user `/clear`.**

### Fixed

- Session Continuation Guard now separates host-owned session transition from
  user copy-paste work: agents must first write a durable handoff/transfer
  capsule with current branch/commit/status, evidence paths, and the exact
  resume prompt.
- Host-owned transfer must then resume immediately in the fresh session via
  transfer/new-session/archive/clear+resume. Bare clear without resume is not
  allowed because it can lose continuity.
- If no host-owned transition+resume control exists, agents must stop with the
  exact next-session prompt only. They must not repeatedly tell the user to type
  `/clear` or frame manual clear input as the required next step.
- Adapter and documentation wording now treats manual `/clear` instructions as
  a product bug, not as an acceptable fresh-session autopilot fallback.

### Tests

- Tightened Session Continuation Guard regression tests so policy, adapter
  surfaces, and docs reject user-owned `/clear` fallback wording, bare clear,
  missing durable transfer capsule, and missing immediate resume wording.

## [0.6.119] - 2026-05-25

> **Division sub-agent council and fresh-session transfer are now enforced by the harness.**

### Fixed

- Session Continuation Guard now treats fresh-session transfer as autopilot:
  write compact handoff/report, use a host transition control when available,
  and otherwise stop with the exact next-session prompt instead of asking the
  user to choose same-session vs fresh-session continuation. SFS 0.6.120 later
  tightened this to forbid user-owned `/clear` instructions.
- The six core divisions now participate as an always-on conceptual sub-agent
  council from brainstorm through Gate 6: strategy-pm, dev, QA, design, infra,
  and taxonomy must record finding/evidence/waiver or not-applicable status.
- `.sfs-local/divisions.yaml` activation now controls read depth/escalation,
  not whether a division participates. Actual parallel worker lanes remain
  opt-in and separate from division council review.

### Tests

- Added regression coverage for division council policy routing, sprint
  templates, model profile boundaries, adapter surfaces, SFS.md, and
  fresh-session autopilot wording.

## [0.6.118] - 2026-05-25

> **Review profile evidence now comes from SFS bridge metadata, not LLM self-attestation.**

### Fixed

- SFS review now extracts sanitized executor profile evidence from the bridge
  probe banner, including Codex `model: gpt-5.5` and `reasoning effort: xhigh`
  when present.
- The generated CPO review capsule now includes an explicit "SFS Executor
  Profile Bridge Evidence" section before the full review runs.
- Reviewers must treat matched SFS-collected bridge evidence as profile
  attestation and must not block solely because the reviewer LLM cannot
  self-attest its own runtime model.

### Tests

- Added a regression test with a fake Codex bridge that emits `gpt-5.5` /
  `xhigh` on stderr and fails unless the full review prompt includes the
  matched SFS profile evidence.

## [0.6.117] - 2026-05-25

> **Natural-language SFS activation now binds to real SFS intent evidence.**

### Fixed

- Natural-language SFS/DDD/TDD/sprint/review requests now require routed SFS
  context plus reconciliation of current user wording, latest handoff/docs,
  active sprint plan, and wiki/DDD maps.
- Approved sprint state no longer overrides newer handoff or user intent; when
  the record proves a conflict, agents must classify mis-scoped work and
  re-plan or hand off instead of asking the user to restate documented facts.
- DDD/TDD review now treats broad-entrypoint growth that adds product behavior
  as a Gate 6 finding unless boundary extraction evidence or approved deferral
  is recorded.

### Tests

- Extended agent behavior and DDD/TDD guardrails across runtime context,
  Claude/Codex/Gemini/Solon adapter surfaces, SFS template, and plugin README.

## [0.6.116] - 2026-05-25

> **Handoff-only requests now interrupt active PR/review loops.**

### Fixed

- Tightened the handoff-only stop contract so it applies to already active or
  queued PR/review/merge/deploy/monitor batches, not only newly started work.
- Required agents to write the handoff artifact immediately and never "finish
  the current PRs first" unless the same user request explicitly says to
  continue.
- Added a violation-reporting rule: if post-request PR/review/merge work already
  happened, the agent must report it as a scope breach, not justify the delay.

### Tests

- Extended agent behavior guardrails to assert active-loop interruption, no
  current-PR batch completion, and no justification framing across kernel,
  loop/review context, adapter surfaces, SFS template, and plugin README.

## [0.6.115] - 2026-05-24

> **Handoff-only requests now stop instead of quietly continuing review loops.**

### Fixed

- Added a handoff-only stop contract: when the user asks only for a handoff,
  next-session brief, session report, or `인계문서`, the agent writes the
  artifact, records current state/blockers/first next command, cleans
  heartbeat/automation evidence when relevant, and stops.
- Made the stop contract override continuation triggers: external review/check
  PASS does not justify PR polling, review retriggers, merges, implementation,
  deploy, or monitor loops unless the same user request explicitly says to
  continue.
- Propagated the rule through kernel, loop/review context, session continuation
  guard, SFS template, Claude/Codex/Gemini/Solon adapter surfaces, and Solon
  plugin docs.

### Tests

- Extended agent behavior guardrails so the handoff-only stop contract is
  asserted across runtime context, adapter surfaces, SFS template, and plugin
  README.
- Verified with focused guardrail/context/line-budget checks plus the full SFS
  test suite.

## [0.6.114] - 2026-05-24

> **Monitor checkpoints now classify progress instead of vague watching.**

### Added

- Added a monitor checkpoint contract for long-running SFS watch/monitor work:
  every checkpoint must classify state as `progressing`, `slow`, `stalled`,
  `dead`, or `auth_blocked`.
- Required checkpoint evidence now includes commit delta, PR/head delta, local
  dirty state, test/check delta, review status delta, worker liveness probe
  result, lane-utilization evidence or waiver, and next action `wait`, `probe`,
  `revive`, or `close`.
- Monitor close now requires heartbeat/automation cleanup plus durable
  wiki/report evidence.

### Fixed

- Worker liveness for monitor purposes must use a request-response probe, not
  process presence, CLI login state, or auth-status output alone.
- Probe evidence is now security-bounded: static benign payload only, no
  workspace/user content, and durable evidence limited to
  status/category/timestamp/redacted error class.
- Raw stdout/stderr, bearer/auth tokens, env vars, prompt bodies, model
  responses, workspace/user content, and PII are forbidden as durable monitor
  evidence.

### Tests

- Extended agent behavior guardrails across runtime context and CLI adapter
  surfaces so the monitor state/evidence/probe/close contract cannot disappear.
- Rechecked context/product markdown line budgets after compacting the new
  monitor guidance.

## [0.6.113] - 2026-05-24

> **Auth probes now prove worker liveness, not just CLI login state.**

### Fixed

- Changed the Claude executor auth probe to perform a tiny request-response
  worker call instead of trusting a stale CLI process, `claude doctor`, or local
  login state as sufficient liveness evidence.
- Removed the default `--dangerously-skip-permissions` probe bridge from the
  Claude path; explicit executor overrides remain available through the
  existing environment override contract.
- Redacted auth probe stdout/stderr artifacts so bearer headers and common
  secret-like environment values are not persisted in `.sfs-local/tmp`.

### Tests

- Added auth probe liveness coverage for successful worker calls, 401/fail-closed
  behavior, dangerous-bridge rejection, prompt minimization, and persisted
  artifact redaction.
- Extended agent behavior guardrails so stale Claude probe defaults cannot
  re-enter the product runtime.

## [0.6.112] - 2026-05-23

> **Gate 6 now proves the plan across every product-bearing layer.**

### Added

- Made DDD/TDD explicit across all product-bearing entrypoints, not only
  backend or frontend code. UI bootstraps, routers, controllers, jobs,
  repositories, DTO mappers, CLI flags, scripts, migrations, docs wording,
  observability glue, and external adapters are not default homes for product
  policy without a named boundary, evidence, or explicit waiver.
- Added a Gate 6 Implementation Acceptance Ledger requirement. Review must map
  every planned AC/ADR/decision to implemented, missing, deferred, or waived,
  with files/artifacts plus tests/evidence before PASS.
- Added a wiki QA/QC closure expectation when `llm-wiki/` exists: repeated
  harness/product failures must record problem, root cause, product fix, local
  tests, project-applied result, production/applied status when relevant, and
  follow-up/waiver.
- Tightened parallel sub-agent lanes: each lane now needs AC/ADR subset
  ownership, expected tests/evidence, output report path, merge/conflict policy,
  disjoint files_scope, and a native-language commit message before coding.

### Tests

- Extended guardrails to assert cross-layer DDD/TDD coverage, Gate 6 acceptance
  ledger output, wiki QA/QC evidence closure, and richer parallel sub-agent lane
  contracts across runtime context, policy packs, review, implementation, and
  adapter surfaces.

## [0.6.111] - 2026-05-23

> **Legit small review findings now stay on autopilot instead of calling the
> user for permission.**

### Added

- Added User-call minimalism as an SFS review invariant: brainstorm and plan
  review are where the user co-designs product intent and decision boundaries;
  later review loops must treat those artifacts as SoT and call the user only
  for genuinely new product decisions.
- Strengthened bounded micro-rework autopilot: when a partial/fail review has
  only deterministic, low-risk findings inside the approved contract, agents
  must patch, verify, rerun self-CPO, and rerun cross review without asking a
  generic "proceed?" question.
- Made common small review findings agent-owned by default, including missing
  self-CPO evidence, narrow guard/test gaps, regex fixes, evidence path gaps,
  and meaning-preserving artifact consistency fixes.

### Tests

- Extended agent behavior guardrail coverage to reject user-confirmation
  handoffs for autopilot micro-rework and to require the user-call-minimalism
  contract across kernel, plan, review, CPO, prompt, and adapter surfaces.

## [0.6.110] - 2026-05-23

> **Review findings now pass a premise check before they become user
> questions.**

### Added

- Added a User-escalation premise guard across kernel, plan, review, CPO, and
  agent adapter surfaces. Before relaying a self/cross-review finding to the
  user, agents must normalize the finding's premise and check it against the
  brainstorm, plan, domain SoT, schema, code, and recorded decisions.
- Findings whose premise is contradicted by the SoT, already answered by the
  artifact, or just over-modeled must be patched and re-reviewed in the same
  cycle instead of being escalated as a product question.
- Lifecycle/delete proposals now default to the smallest data-preserving
  policy: do not invent cascade soft-delete/restore flows unless the product
  contract requires them; prefer rejecting delete while dependents exist.

### Tests

- Extended agent behavior guardrail coverage to require the premise guard and
  the data-preserving delete-policy default across runtime context, CPO prompt,
  and adapter surfaces.

## [0.6.109] - 2026-05-23

> **Plain version commands keep their single-line contract while
> `sfs version --check` carries the installed release headline evidence.**

### Fixed

- Restored `sfs version`, `sfs --version`, and native Windows `sfs.cmd version`
  to the pre-existing single-line `sfs X.Y.Z` output contract.
- Kept `installed_release_headline` scoped to `sfs version --check`, where it
  is used as freshness/evidence metadata rather than a machine-version string.

### Tests

- Extended version-headline coverage so plain version output cannot accidentally
  gain the headline field again.

## [0.6.108] - 2026-05-23

> **Installed version summaries now fall back to release notes when packaged
> runtimes omit the large CHANGELOG file.**

### Fixed

- `sfs version --check` now reads `RELEASE-NOTES.md` when `CHANGELOG.md` is not
  present in the installed Homebrew/Scoop payload, so `installed_release_headline`
  is emitted from the actual packaged runtime.
- The product release verifier now fails if the installed runtime lacks
  `installed_release_headline`, preventing a channel release from passing while
  the headline anchor is missing.

### Tests

- Extended version-headline coverage to simulate an installed payload with
  `RELEASE-NOTES.md` but no `CHANGELOG.md`.

## [0.6.107] - 2026-05-23

> **Version and freshness summaries now anchor to the exact release headline
> instead of reusing older release facts from conversation memory.**

### Fixed

- Added an `installed_release_headline` line to `sfs version --check` so agents
  can pair the observed runtime version with the matching local CHANGELOG entry.
- Strengthened upgrade/freshness guidance: when reporting what is current,
  agents must use the exact version's `VERSION` + `CHANGELOG` / `RELEASE-NOTES`
  entry and must not infer from previous release summaries.
- Added a guard against saying "no major invariant changed" without checking
  the exact version entry.

### Tests

- Added version-headline coverage so `sfs version --check` proves the installed
  runtime summary is anchored to the exact release entry.

## [0.6.106] - 2026-05-23

> **Agents now own runnable execution steps and distinguish true blockers from
> approval gates, including session-scoped authorization such as "알아서 해".**

### Added

- Added Executable Action Ownership to the runtime kernel, implementation
  context, SFS project router, and Claude/Codex/Gemini adapter surfaces.
- Agents must run executable shell/tool steps themselves when auth, runtime, and
  approval are available, instead of handing users copy-paste commands for work
  the agent can perform.
- Added a session-scoped authorization rule: when the user grants autonomous
  execution for the current scope, approval-gated steps such as pushes or
  deploy/release operations continue in that session until scope changes or a
  true blocker appears.
- Shell state is now explicitly agent-owned: use one-shot inline environment,
  mask secrets, and do not ask the user to export variables across terminals.

### Tests

- Extended `test-agent-behavior-guardrails.sh` to verify executable action
  ownership, true-blocker/approval-gate separation, session authorization, and
  shell-state ownership across runtime and adapter surfaces.

## [0.6.105] - 2026-05-23

> **Freshness and upgrade summaries now keep the parallel-agent implementation
> contract visible instead of collapsing "latest" into the newest release
> headline.**

### Fixed

- Added upgrade-context guidance so agents distinguish the latest release
  headline from the installed capability surface when users ask what is current,
  latest, or applied.
- When the user asks about sub-agents, parallel work, multi-agent
  implementation, or worker lanes, agents now must explicitly name the
  implementation mode contract: single-agent default, optional
  `sfs implement --agent-mode parallel --agents codex,claude[,gemini]`,
  disjoint files_scope, lane verification, native/workspace-language lane commit
  message, and agent cross review before Gate 6 PASS.
- Added the same implementation-mode summary to install and upgrade completion
  output so "latest applied" reports do not hide the already-shipped parallel
  agent contract.

### Tests

- Added `test-upgrade-freshness-summary.sh` to guard the upgrade context and
  install/upgrade completion surfaces.

## [0.6.104] - 2026-05-23

> **Korean "배포해줘" now means the full release process, including tests,
> review/검수, channel publication, installed-runtime verification, and
> evidence reporting.**

### Added

- Added the Korean deploy trigger contract to the routed release context:
  "배포해줘" is interpreted as "배포 프로세스 쭉 진행해줘", not as publish-only.
- Added release-trigger guidance to the Codex/Claude/Gemini/SFS adapter surfaces
  so every LLM agent loads the release context and runs readiness checks, tests,
  review/검수, release cut, stable tag, Homebrew, Scoop, installed runtime
  verification, and evidence reporting end to end.
- Added documentation coverage in README and product docs for the new natural
  language release trigger.

### Tests

- Added release policy and adapter guardrail assertions for the Korean deploy
  trigger, review/검수, and installed runtime verification.

## [0.6.103] - 2026-05-22

> **Agent instructions now distinguish agent-facing Markdown from real
> user-facing documents, which should default to HTML for browser-grade reading
> and visual verification.**

### Added

- Added a User-facing docs HTML-first rule to the source SSoT, product
  maintenance guide, installed `CLAUDE.md` template, runtime kernel, Codex
  skill templates, Claude slash command template, Gemini command templates, and
  shipped plugin command prompt.
- Added `test-user-facing-docs-html-first.sh` to verify the rule is present in
  every agent entry surface that can create or guide documentation work.

### Changed

- Bumped product docs/version checks to `0.6.103` so release verification covers
  the new documentation rule instead of shipping only the source docset change.

### Tests

- Full source regression passed with 90 tests.
- Focused user-facing docs HTML-first guard, docs/version sync, product
  Markdown budget, shell syntax, and `git diff --check` verification passed
  before release preparation.

## [0.6.102] - 2026-05-22

> **Obsidian wiki adoption now keeps host-local tool bundles out of project
> source truth, install flow, and migration scope unless the user explicitly
> asks for that external environment reference.**

### Added

- Added host-local/user-home boundary guidance to the Obsidian LLM wiki policy,
  runtime kernel, Codex/Claude/Gemini/SFS templates, and current-product-shape
  docs.
- Added `test-obsidian-host-local-boundary.sh` to verify Obsidian wiki guidance
  does not promote named host-local tools or user-home folders into project SoT,
  wiki roots, install targets, or migration sources.
- Extended the Obsidian applied-project runtime harness so the ambient notice
  reminds agents that host-local tools are external environment, not project
  SSoT.

### Changed

- Obsidian wiki migration now explicitly says concepts already absorbed by SFS
  should use the SFS command/policy surface instead of a host-local tool.
- The project wiki working guideline now carries the same boundary for this
  repository's own Obsidian workflow.

### Tests

- Full source regression passed with 89 tests.
- Focused Obsidian host-local, active-project, guidance, docs/version, shell
  syntax, zero named host-local tool reference, wiki index, wiki link, and
  `git diff --check` verification passed before release preparation.

## [0.6.101] - 2026-05-22

> **SFS now detects projects that already have Obsidian or `llm-wiki/` and
> reminds agents to use the wiki as active retrieval context instead of missing
> it during broad scans.**

### Added

- Added an ambient Obsidian wiki runtime notice for SFS projects. When
  `.obsidian/` or `llm-wiki/` exists, SFS points agents to `llm-wiki/`,
  `llm-wiki/ddd/`, taxonomy-as-domain-language, and the expected map/gap update
  rule.
- Added `test-obsidian-applied-project-harness.sh` to verify active wiki
  detection, missing DDD wiki gap reporting, `.obsidian/`-only gap reporting,
  and opt-out behavior.
- Added policy and template guidance so Codex, Claude, Gemini, and project-local
  SFS agents treat existing Obsidian/wiki surfaces as active project context.

### Changed

- The Obsidian LLM wiki policy now distinguishes new project, existing project,
  and already-applied project flows.
- `llm-wiki/` documentation and generated indexes now include the runtime notice
  harness and quality map references.

### Tests

- Full source regression passed with 88 tests.
- Focused Obsidian, agent behavior, DDD/TDD, shell syntax, wiki link, and
  `git diff --check` verification passed before release preparation.

## [0.6.100] - 2026-05-22

> **SFS now recommends an Obsidian LLM wiki continuity layer for new and
> existing SFS projects without making Obsidian a hard dependency.**

### Added

- Added an Obsidian LLM wiki policy for SFS projects. New projects can create a
  repo-root vault plus `llm-wiki/` baseline after scaffold; existing projects
  can migrate docs by reference after `sfs adopt` before the next sprint relies
  on retrieval context.
- Added English and Korean current-product-shape docs describing the Obsidian
  continuity rule and its non-blocking fallback.
- Added product template guidance for Codex, Claude, Gemini, and project-local
  SFS agents so future installs can surface the same recommendation.
- Added `test-obsidian-llm-wiki-guidance.sh` to guard policy routing,
  non-coercive wording, new/existing project hooks, `.gitignore` boundaries,
  adapter template guidance, and product docs.

### Changed

- `start`, `adopt`, `plan`, `implement`, kernel, and knowledge-pack routing now
  know when to recommend or update an Obsidian-backed LLM wiki.
- Obsidian workspace/cache/plugin payloads are excluded from generated project
  `.gitignore` guidance while shared vault settings remain allowed.
- Root project guidance now points non-trivial work through the Obsidian LLM
  wiki TopicHub/index workflow without replacing source files as SSoT.

### Tests

- Full source regression passed with 87 tests.
- Wiki link checking, Obsidian JSON parsing, and `git diff --check` passed
  before release preparation.

## [0.6.99] - 2026-05-22

> **Product markdown is now frontmatter-loadable, split below the active
> 200-line budget, and covered by harness tests that follow split child docs.**

### Changed

- Long active product docs were split into thin index files plus routed child
  markdown files, keeping active docs below the 200-line harness budget.
- Active user, agent, packaging, plugin, and prompt docs now carry explicit
  frontmatter so doc loaders can classify them consistently.
- Doc content assertions now search both a parent `.md` file and its sibling
  split-doc directory, so model-routing and product-contract checks still bind
  after the split.
- Release packaging now includes top-level split-doc payload directories
  (`README/`, `GUIDE/`, and `BEGINNER-GUIDE/`) instead of shipping only their
  thin parent index files.

### Tests

- Added `test-product-md-frontmatter-line-budget.sh` for frontmatter, 200-line
  budget, and release allowlist coverage.
- Added negative harness probes for missing frontmatter, over-budget markdown,
  and split-child doc search during release verification.
- Full source regression passed with 86 tests.

## [0.6.98] - 2026-05-22

> **Existing projects can now enter SFS with a DDD/TDD retrofit path instead of
> treating legacy structure as fixed.**

### Added

- `sfs adopt --ddd-tdd-retrofit` scans tracked source paths for DDD-lite
  boundaries and classifies the current code shape as `no-code`, `missing`,
  `partial`, or `present`.
- Adoption now writes a focused `ddd-tdd-retrofit.md` plan and seeds
  `docs/solon/domain-map.md` so durable product/domain terms have a home from
  the first real sprint.
- The generated handoff records the retrofit status, layer counts, hotspots,
  and next DDD refactor actions.

### Changed

- Legacy code adoption now explicitly says old code was not retroactively
  test-first. If DDD is missing, the next real sprint must pick one behavior
  slice, add characterization/failing/smoke evidence, and then move only that
  slice behind `domain`, `application`, `interfaces`, and `infrastructure`.
- User-facing guides and adopt command context now expose the retrofit option
  as part of the product-level DDD/TDD flow.

### Tests

- Added `test-sfs-adopt-ddd-tdd-retrofit.sh`.
- Extended `test-ddd-tdd-guardrails.sh` for the adopt retrofit context.
- Full source regression passed with 85 tests.

## [0.6.97] - 2026-05-22

> **DDD/TDD guardrails are now product-level SFS rules, not backend-only
> reminders.**

### Changed

- The DDD/TDD knowledge pack now activates for product behavior, acceptance
  criteria, UI/API/CLI/docs/data/workflow changes, and backend scaffolds.
- Brainstorm, plan, implement, kernel, bootstrap, and adapter prompts now ask
  for product behavior boundaries, canonical domain language, and a first
  failing/characterization/smoke/review evidence path before implementation
  proceeds.
- The DDD/TDD review lens now checks product rules that hide in UI labels,
  CLI flags, docs wording, migrations, workflow glue, adapters, controllers,
  repositories, or jobs instead of treating DDD as a backend package layout.
- GitHub @codex help text now keeps the corrected order: self-CPO PASS, cross
  CPO PASS, then GitHub @codex as final external evidence.

### Tests

- `test-ddd-tdd-guardrails.sh` now verifies the real `sfs context cat` command
  surface for product-level DDD/TDD context loading.
- `test-review-implementation-sequence.sh` now guards against the old
  "between self and cross" GitHub @codex wording.
- `test-sfs-version-notice-cache-global.sh` is non-interactive in unattended
  full-suite runs.
- Full source regression passed with 84 tests.

## [0.6.96] - 2026-05-21

> **Implementation review now runs self-CPO, cross CPO, then GitHub @codex
> last.**

### Fixed

- `sfs review --gate 6` now separates implementation review stages:
  self-CPO first, cross CPO second, and GitHub @codex only as final
  post-implementation PR/code review evidence.
- GitHub @codex review is no longer requested, triggered, or counted during
  brainstorm or Gate 3 plan review.
- `sfs commit apply --group product-code` blocks product-code push after
  implementation until Gate 6 self-CPO PASS and cross CPO PASS exist, while
  still allowing a recorded self-CPO fallback for users who only have self-CPO.

### Changed

- SFS kernel, review/implement/capture contexts, and agent adapter prompts now
  share the same GitHub/SFS review boundary.
- Backend and design knowledge packs are split into routed child docs so active
  context stays under 200 lines with frontmatter-based loading.

### Tests

- Added `test-review-implementation-sequence.sh` and
  `test-context-md-split-frontmatter.sh`.
- Full source regression passed with 83 tests.

## [0.6.95] - 2026-05-21

> **Gate 3 review PASS no longer substitutes for the user's product approval
> when a plan changes product intent, IA, acceptance criteria, or another
> decision boundary.**

### Fixed

- `sfs implement` now blocks plans marked `user_approval_required: true` or
  `user_approval_status: pending`, even when Gate 3 cross review has already
  passed. Agents must capture the user's approval or waiver before entering
  implementation.
- Gate 3 review next-action guidance now routes approval-pending plans to
  `sfs capture --kind user-approval --gate 3 ...` instead of telling the agent
  to implement.
- Plan guidance now treats product meaning, IA, visible UI, acceptance-criteria
  meaning, public contract, security/privacy/data, cost/latency/model policy,
  and destructive behavior changes as user approval boundaries.

### Added

- Added `user-approval` / `approval` capture kinds so the active sprint ledger
  can record explicit user approval before implementation.
- Added a plan template approval boundary section that makes user review status
  visible instead of hiding it behind Gate 3 review results.

### Tests

- Added regression coverage for capture flow, Gate 3 implement preflight
  blocking, and Gate 3 review next-action routing when user approval is pending.

## [0.6.94] - 2026-05-21

> **Gate 3 implement preflight now respects cross review and realistic
> self-CPO fallback, while frontend UI work gets browser evidence before user
> inspection.**

### Fixed

- `sfs implement` no longer treats a bare Gate 3 self-CPO PASS as enough to
  start implementation. Gate 3 now requires cross-review evidence, a recorded
  self-CPO fallback reason for no other agent subscription / external agent
  token exhaustion / cross-review bridge unavailability, or an explicit user
  waiver.
- `sfs review` now records Gate 3 review run events with `review_stage` and
  `cross_review` metadata so `sfs implement` can distinguish cross review from
  self-only review evidence.

### Added

- Added a regression case proving self-CPO-only Gate 3 PASS blocks
  implementation, while a documented self-CPO fallback PASS can proceed.
- Added visible frontend/UI implementation guidance requiring Playwright,
  Cypress, Storybook, or equivalent browser automation evidence before asking
  the user to inspect the UI.

### Tests

- Full source regression passed with 81 tests.

## [0.6.93] - 2026-05-19

> **Stale project-local context no longer hides freshly shipped token guards.**

### Fixed

- `sfs context cat/path` now prefers packaged runtime context when a project
  still records an older SFS version, so old `.sfs-local/context/kernel.md`
  files cannot shadow newly released safety policies such as Session
  Continuation Guard.
- `sfs upgrade --layout vendored` now syncs every managed context module found
  under `templates/.sfs-local-template/context/` instead of relying on a
  hard-coded list, preventing new routed policy files from being missed.
- Vendored context verification now checks the full managed context module set,
  including `.ko.md` knowledge-pack routes and newly added policies.

### Added

- Added `test-context-stale-project-runtime-precedence.sh`.
- Added `test-sfs-upgrade-vendored-context-sync.sh`.

### Tests

- Full source regression target is 81 tests.

## [0.6.92] - 2026-05-19

> **Session Continuation Guard stops long-running agent chats from becoming the
> hidden token budget.**

### Added

- Added `policies/session-continuation-guard.md` and routed it through the
  context index, kernel, token-harness, runtime-token-firewall, loop, implement,
  review, model profiles, adapters, and docs.
- Added explicit host-token thresholds: if the token meter is 30% or higher
  before the first implementation/review action of a new WU/sprint, or 50% or
  higher before a new gate, loop wakeup, worker handoff, or cross-review, agents
  must stop and create a compact fresh-session handoff.
- Added the upgrade boundary: `sfs upgrade` updates runtime/project context but
  cannot shrink an already-open Claude/Codex/Gemini conversation.
- Added `test-session-continuation-token-guard.sh`.

### Changed

- Runtime Token Firewall now separates bridge budget from host-session budget.
  Full-history workers/reviewers remain blocked, and long host sessions must
  hand off through artifacts instead of spawning another history-forwarding
  helper.
- Loop guidance now stops repeated wakeups in the same chat after more than two
  wakeups or when the token meter crosses the handoff threshold.

### Tests

- Added `test-session-continuation-token-guard.sh`.
- Full source regression target is 79 tests.

## [0.6.91] - 2026-05-19

> **External review PASS now resumes the SFS gate instead of becoming a quiet
> stopping point.**

### Added

- Added a Gate continuation guard: GitHub/@codex/PR/check PASS is a trigger to
  continue to the next unmet SFS review step, not a final verdict.
- Added explicit all-agent wording for Codex, Claude, Gemini, and future LLM
  agents: self-CPO runs first, then the configured cross-review order after
  self-CPO PASS.
- Added `test-review-gate-continuation.sh` to lock the continuation contract
  across kernel context, review/implement/capture guidance, CPO persona,
  model profiles, generated adapters, and user docs.

### Changed

- Review guidance now tells agents to use `sfs review --sprint <id> --gate <n>`
  when a closed sprint id is known, instead of manually restoring
  `.sfs-local/current-sprint` or extracting archives.
- Context Pollution Guard now treats review continuation as a compact
  checkpoint: store the external PASS evidence and exact next SFS command, not
  the whole review transcript or prompt thread.

### Tests

- Added `test-review-gate-continuation.sh`.
- Full source regression passed with 78 tests.

## [0.6.90] - 2026-05-19

> **Natural-language flow checkpoints and Context Pollution Guard keep SFS
> continuity durable without turning prompts, transcripts, or scratch output
> into permanent product context.**

### Added

- Added `sfs capture` and `sfs note` so natural-language decisions, review
  order, scope changes, exceptions, blockers, and evidence can be recorded in
  the active sprint before the next command loses that flow state.
- Added non-collapsing `flow_capture` events with `capture_id` so multiple
  conversation checkpoints survive active-ledger compaction.
- Added `sfs review --sprint <id>` restore support for closed sprint archives,
  letting a review gate resume from the latest cold `sprint-evidence.tar.gz`
  without manually editing `.sfs-local/current-sprint`.
- Added `policies/context-pollution-guard.md` and wired it through the context
  router, kernel, token-harness, review, tidy, capture, README/GUIDE, and
  current-product-shape docs.
- Added a `sfs capture` text budget guard. Captures default to 2000 bytes and
  reject prompt/transcript dumps unless `SFS_CAPTURE_ALLOW_LONG=1` is used for
  an explicit local exception.
- Added release guidance that separates "no surprise push" from "no push":
  when the user explicitly authorizes autonomous deploy, SFS agents may push
  source, stable, tag, Homebrew, and Scoop refs and record that evidence. The
  rule applies to all LLM agents, including Codex, Claude, Gemini, and future
  adapters.

### Changed

- Runtime dispatch now exposes `capture` and the `note` alias from Bash and
  Windows entrypoints.
- Capture guidance now treats bulky prompt/run output as an artifact/archive
  pointer plus accepted conclusion, not as durable flow text.
- Review and tidy guidance now flag prompt bodies, raw transcripts, bridge/run
  scratch, `.sfs-local/tmp/...` residue, and long review blobs in core docs as
  product findings before release.
- `cut-release.sh` now supports `--push` for user-authorized stable main/tag
  publishing while retaining no-push as the default safety mode.

### Fixed

- CPO review prompt rendering now uses quoted static heredocs plus explicit
  variable printing so Markdown backticks such as `sfs review` stay text and do
  not execute hidden shell commands while building the prompt.
- `test-review-auth-preflight.sh` now forces the missing-auth case through
  headless preflight and disables bridge probing for the fake authenticated
  executor, avoiding accidental installed-runtime recursion during tests.

### Tests

- Added `test-sfs-capture-flow.sh`.
- Added `test-sfs-review-closed-sprint-restore.sh`.
- Added `test-context-pollution-guard.sh`.
- Added `test-release-authorized-push-policy.sh`.
- Full source regression passed with 77 tests.

## [0.6.89] - 2026-05-19

> **Shared sprint handoff docs can now use a domain-first path instead of a
> flat feature workspace slug, and worker/review handoff now has a runtime
> token firewall.**

### Added

- `sfs start "<goal>"` now infers high-confidence domain metadata from the
  natural-language goal and prepares `report.md` and `retro.md` under
  `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/`.
- `--domain`, `--subdomain`/`--sub`, and `--feature`/`--feat` remain available
  as explicit override levers when inference needs correction.
- `sfs tidy --all --apply` now rehomes high-confidence legacy flat shared docs
  such as `docs/solon/order-items-quantity-update/<yyyyMMdd>/` into the
  inferred domain-first path without overwriting existing files.
- Added `policies/runtime-token-firewall.md` to make worker/review handoff
  capsule-only: goal, AC, files_scope, commands, expected output paths, and
  compact evidence instead of full lead-agent conversation history.
- Added `test-runtime-token-firewall.sh` to lock the no-full-history forwarding
  contract.

### Changed

- Updated start routing guidance and adapter templates so agents do not ask
  users to type domain flags for normal work; `--workspace` is retained as a
  fallback for early exploration.
- Updated tidy routing guidance to describe automatic flat-doc rehoming and the
  skip-on-conflict behavior.
- Updated kernel, token-harness, implement, and review context so worker,
  plugin, rescue-subagent, and external-review handoffs are capsule-only and
  poll artifacts instead of main-thread chat state.
- `sfs review --executor codex-plugin` is now blocked by Runtime Token Firewall;
  Claude in-process Codex/Gemini wrappers must use `--prompt-only` or a real
  CLI bridge instead of forwarding lead conversation history.
- `SFS_REVIEW_CODEX_CMD` now rejects known history-forwarding bridge patterns
  such as `codex-rescue`, `codex:codex`, forked context, and full-history
  wrappers.

### Tests

- Extended `test-sfs-shared-handoff-docs.sh` to cover automatic inference of
  the `order/order-items/quantity-update` handoff path and frontmatter.
- Extended `test-sfs-tidy-retention.sh` to cover rehoming an existing flat
  `order-items-quantity-update` shared-doc folder during `tidy --all --apply`.
- Full source regression passed with 73 tests.

## [0.6.88] - 2026-05-16

> **Shared report/retro docs now recover from manual sprint-id folders back to
> the intended workspace folder.**

### Fixed

- `sfs report` and `sfs retro` now recover manually misplaced shared docs from
  `docs/solon/<sprint-id>/<yyyyMMdd>/` into the canonical
  `docs/solon/<workspace>/<yyyyMMdd>/` path when a custom week-prefixed sprint
  id was used with a separate workspace name.

### Tests

- Extended `test-sfs-shared-handoff-docs.sh` to cover custom sprint ids such as
  `2026-W21-security-audit` with `--workspace security-audit`.

## [0.6.87] - 2026-05-14

> **GitHub `@codex` PR/code review is now explicitly separate from SFS review
> gates, and review scratch files are isolated per invocation.**

### Added

- Added `test-review-github-codex-boundary.sh` to prove GitHub `@codex`
  PR/code review, PR approval, and GitHub check PASS stay external evidence
  only and do not satisfy self-CPO, SFS cross review, `sfs review`, Gate 3, or
  Gate 6 PASS.
- Added `test-review-scratch-tidy-retention.sh` to prove per-invocation review
  prompt/run scratch is still packed into the sprint cold archive and removed
  from `.sfs-local/tmp` on tidy close.

### Changed

- Updated SFS kernel, review/implement routed context, review prompt, CPO
  persona, model profiles, adapter templates, plugin command surface, and
  Korean/English docs with the GitHub/SFS review boundary.
- Isolated `sfs review` prompt/run scratch under per-invocation directories so
  nested or installed-runtime review probes cannot clobber the current prompt or
  result files.
- Updated tidy/retro scratch selection to archive both legacy `sprint-id*`
  scratch files and the new nested per-invocation review scratch directories.
- Reasserted review lens frontmatter after prompt/executor side effects so an
  explicit lens override remains visible in `review.md`.
- Shortened the lens alias regression's bridge-probe timeout so prompt-only
  alias normalization remains a fast deterministic test even when a host has an
  installed review bridge.

### Tests

- Full source regression passed with 72 tests.
- Codex `gpt-5.5` xhigh self-CPO review returned PASS for the GitHub/SFS review
  boundary change.

## [0.6.86] - 2026-05-13

> **Token Diet now has an explicit quality-audit release: compact output stays
> bounded to proven routine surfaces, while evidence-heavy paths keep full
> traceability.**

### Added

- Added `test-token-diet-quality-audit.sh` to prove Token Diet compact output
  stays scoped to routine status/start/report surfaces and does not shrink
  review, decision, safety, source, or verification evidence when that would
  weaken traceability.
- Added `test-status-dashboard-contract.sh` so the Solon status dashboard can
  stay compact without dropping source, evidence, decision, or next-action
  fields.
- Added read-only Markdown split audit tooling with
  `scripts/md-split-audit.sh`, `test-md-split-audit.sh`, and the current
  `md-split-queue.md` backlog artifact. Historical evidence docs are audited,
  not rewritten.

### Changed

- Clarified quiet release-verifier failure replay: failed internal smokes now
  state that captured stdout/stderr is being replayed before emitting prefixed
  evidence lines.
- Updated owner release tooling so stable clone defaults consistently point to
  `~/tmp/solon-product`, matching the current Homebrew/Scoop release ritual.
- Completed the April 19/20 historical session retro/index cleanup and closed
  the D-E meta-retro queue in the operating record.

### Tests

- Full source regression passed with 70 tests.
- Self-CPO review reached PASS at R6 after stale/future-dated handoff evidence
  was removed and current 0.6.86 artifact pointers were restored.

## [0.6.85] - 2026-05-13

> **Release verifier smoke output is quieter on success while preserving full
> failure evidence.**

### Changed

- `scripts/verify-product-release.sh` now captures internal install/upgrade
  smoke output and replays it only if that smoke fails. Successful release
  verification stays compact, and failed verification still prints the captured
  stdout/stderr lines with `[verify-product-release]` evidence prefixes.

### Tests

- Added `test-release-verifier-quiet-smokes.sh` to keep the quiet-success /
  evidence-on-failure contract from regressing.
- Full source regression passed with 65 tests.

## [0.6.84] - 2026-05-13

> **Token Diet adds opt-in compact command output while preserving evidence,
> warnings, decisions, source traceability, and verification fields.**

### Added

- Added a quality-preserving compact-output contract to SFS agent surfaces:
  compactness is never a pass condition by itself, and full clarity remains the
  fallback when evidence, risk, raw-source traceability, or decision context
  would weaken.
- Added `SFS_OUTPUT_STYLE=compact` and `--output-style compact` for routine
  `sfs start` and `sfs report` stdout. `sfs start` compact output keeps the
  created sprint path, current sprint pointer, shared-doc path, lazy step-doc
  state, recommended brainstorm command, simple/hard alternatives, and
  `recommended=normal`. `sfs report` compact output keeps report/archive paths
  and the compact/finalization state.
- Added compact `sfs status` output through `SFS_OUTPUT_STYLE=compact`,
  `sfs status --compact`, and `sfs status --output-style compact`, preserving
  `sprint`, `wu`, `gate`, `verdict`, `ahead`, and `last_event`.
- Added Windows native `sfs.cmd status` parity for the compact status output
  shape.
- Added Token Diet benchmark fixtures and runtime tests:
  `test-token-diet-compact-output.sh`,
  `test-token-diet-runtime-compact-status.sh`, and
  `test-token-diet-runtime-compact-next-report.sh`.

### Changed

- Documented Context Diet guidance inspired by `park-jun-woo/filefunc`:
  prefer precise routed context, concept-grained artifacts, stable search
  vocabulary, one-line summaries, raw-text fallback, and verification.
- Explicitly rejected direct filefunc transplantation into SFS: no SFS-wide
  one-file-one-function/type rule, no mandatory annotation campaign, and no
  automatic SSoT compression before proof.
- Kept Caveman/persona-style output as an opt-in concept only; SFS defaults to
  professional compact output, not joke/persona speech.

### Tests

- Routine compact fixtures show 69%, 70%, and 72% character reduction while
  retaining source and verification traces.
- Negative fixtures fail when compact text drops review evidence, data-loss
  warning severity, or decision alternatives.
- Full source regression passed with 64 tests.

## [0.6.83] - 2026-05-10

> **Claude, Codex, and Gemini model routing now has explicit role boundaries,
> and completed work requires a top-model self-CPO PASS loop.**

### Changed

- Claude coding-capable worker, facilitator, code-helper, and mechanical helper
  lanes now resolve to Sonnet 4.6. Haiku is documented as a non-coding helper
  tier only and must not write code or own implementation.
- Gemini runtime routing now uses `gemini-3.1-pro-preview` for strategic/research/review, `gemini-3-flash-preview` for agentic coding/bounded implementation helpers, and `gemini-3.1-flash-lite` for relay/probe/economy helpers. Gemini models below 3.x are not part of recommended routing
  surface.
- Substantive research now prefers the Gemini researcher executor with Gemini 3
  Pro auto when available; Claude research remains a read-only Sonnet 4.6
  fallback.
- Work completion now requires self-agent top-model CPO evidence: Claude Opus
  4.7, Codex `gpt-5.5` with xhigh reasoning, Gemini `gemini-3.1-pro-preview`, or
  the configured custom top-model equivalent. Partial/fail redirects the work
  and repeats verification plus self-CPO until PASS or explicit user waiver.

### Tests

- Extended agent behavior guardrails to verify Claude Sonnet 4.6 coding lanes,
  Haiku non-coding boundaries, Gemini 3.x role-specific routing, and the
  post-work self-CPO loop.
- Extended docs routing checks so GUIDE, beginner docs, current-product docs,
  and 10x docs reject stale Gemini preview/models-below-3.x names and document
  the Claude/Gemini/Codex responsibility split.

## [0.6.82] - 2026-05-10

> **Codex worker/helper routing now separates normal work, code helpers, and
> Spark-only mechanical implementation.** Claude and Gemini keep their existing
> tier families.

### Changed

- Codex `execution_standard` now resolves normal implementation workers to
  `gpt-5.4`.
- Added a bounded `code_helper` lane for repo-aware coding support that is
  smaller than a normal worker slice but still needs code judgment; Codex maps
  it to `gpt-5.3-codex`.
- Added a dedicated `mechanical_implementation_economy` lane for already
  decided, judgment-free implementation chores. Codex maps that lane to
  `gpt-5.3-codex-spark` only after scope, files_scope, AC, and exact edit
  intent are locked.
- Kept Claude and Gemini runtime mappings on their existing tier families while
  documenting the Codex-only split in kernel, plan, implement, adapter, install,
  upgrade, and user docs.

### Tests

- Updated agent behavior guardrails to reject the stale
  "`gpt-5.3-codex` is the Codex worker default" contract and require the new
  `gpt-5.4` / `gpt-5.3-codex` / `gpt-5.3-codex-spark` role split.
- Updated docs routing checks so user-facing docs describe Spark as the
  judgment-free mechanical implementation helper, not a broad helper fallback.

## [0.6.81] - 2026-05-09

> **Review executors authenticate before review starts.** First-time Gemini,
> Codex, and Claude review bridges now stop at auth preflight instead of
> generating a full CPO prompt and then failing as if the review had run.

### Fixed

- `sfs review --executor gemini|codex|claude` now checks named executor auth
  before creating `review.md`, full CPO prompt files, run scratch, or
  `review_open` events.
- Headless sessions now verify that `/dev/tty` is actually openable before
  trying interactive auth, avoiding the `Device not configured` failure mode.
- Missing auth now tells the user to run `sfs auth login --executor <tool>`,
  optionally verify with `sfs auth probe --executor <tool>`, and then rerun the
  same review command. `--prompt-only` remains the manual handoff path.

### Tests

- Added `test-review-auth-preflight.sh` to prove unauthenticated Gemini review
  does not generate review artifacts, while an authenticated fake bridge still
  probes and completes review normally.
- Extended guardrail tests to keep auth preflight ahead of full prompt
  generation.

## [0.6.80] - 2026-05-09

> **README is now a product introduction, not a release-note dump.** Detailed
> value, model-routing, and operating-policy explanations moved to 10x/current
> docs where they belong.

### Changed

- Rewrote `README.md` around the product promise: Solon turns AI speed into a
  product operating loop with intent, scope, AC, implementation slices,
  independent review, and handoff.
- Removed release-version prose, division/lens registry details, model routing,
  review evidence packaging, and other operating specs from README.
- Added detailed model-routing explanation to Korean and English 10x value docs,
  including default role routing, advisor boundaries, Spark helper limits, and
  self-CPO requirements.
- Replaced several current-doc "as of 0.6.79" phrasings with current-state
  wording so guide pages do not read like release notes.

### Tests

- Added `test-readme-intro-hygiene.sh` to keep README short and free of
  release/model/lens-registry detail.
- Updated model-routing and division-sync docs tests so deep detail is required
  in 10x/current docs, while README points readers there.

## [0.6.79] - 2026-05-09

> **Product docs now keep divisions, knowledge packs, and review lenses in sync.**
> README and current-product docs no longer mix stale 0.6.26/0.6.27 wording
> with the current guidance-pack model.

### Changed

- Documented `.sfs-local/divisions.yaml` as the six-slot compatibility
  activation state for existing projects, not the full knowledge-pack/review-lens
  registry.
- Clarified that backend is a `dev` specialization, management-admin covers
  finance/bookkeeping/tax/accounting, and taxonomy is a cross-cutting
  language/classification lens rather than an org division.
- Updated README, GUIDE, Korean/English index docs, current-product-shape docs,
  the knowledge-pack router, and the default `divisions.yaml` template with the
  same terminology.

### Tests

- Added `test-docs-division-version-sync.sh` to block stale 0.6.26/0.6.27
  version text and lock the division/lens boundary in docs and templates.
- Extended model-routing docs tests to reject stale 0.6.26/0.6.27 references.

## [0.6.78] - 2026-05-09

> **Review evidence stays bounded on real projects.** 0.6.77 made review
> evidence commit-aware; this release fixes the real-project prompt generation
> cost when plan evidence names broad source directories.

### Fixed

- `sfs review` now caps directory/glob expansion with `SFS_REVIEW_DIR_EXPANSION_MAX`
  (default 80, max 200) so broad tokens such as `backend/src` do not make
  prompt-only review look stuck.
- Indexed evidence path extraction is cached during prompt rendering instead of
  being recomputed for every excerpt.
- Full-file embedding is now reserved for small first-class durable documents
  such as shared handoff reports and ADRs; source/config targets remain bounded
  excerpts.

### Tests

- Extended guardrails to lock bounded directory expansion and indexed evidence
  caching.
- Verified the patched review command against the real `study-note` sprint:
  `sfs review --gate 4 --prompt-only` completed and produced a full prompt with
  latest-commit, shared-handoff, and first-class evidence sections.

## [0.6.77] - 2026-05-09

> **Review evidence is commit-aware.** Gate reviews no longer lose ADR/report
> evidence just because the sprint deliverables were already committed and the
> working tree is clean.

### Fixed

- `sfs review` now adds a latest-commit reviewable file manifest and includes
  reviewable files from `HEAD` alongside dirty/untracked evidence.
- Current sprint shared handoff docs under
  `docs/solon/<english-workspace>/<yyyyMMdd>/report.md` and `retro.md` are
  included explicitly in review prompts.
- Small first-class review documents such as `docs/solon/decisions/*.md` and
  shared handoff reports are embedded in full up to the bounded small-file cap,
  so late ADR sections such as operational assumptions are not cut away.
- `review.md` frontmatter refreshes the sprint goal and workspace on each
  review invocation, avoiding stale round-1 goal wording after the sprint scope
  has been clarified.

### Tests

- Added `test-sfs-review-commit-aware-evidence.sh`, which creates a clean
  committed ADR + shared report sprint and verifies `sfs review --gate 4
  --prompt-only` contains the latest commit manifest, handoff manifest, full ADR
  tail section, handoff report body, and refreshed review frontmatter.

## [0.6.76] - 2026-05-09

> **SFS commit is the commit+push surface.** Solon commit guidance now points to
> `sfs commit`, not host-local `/commit` skills, and `sfs commit apply` pushes
> the current branch by default for user projects.

### Changed

- `sfs commit apply --group <name>` now stages the selected group, commits it,
  and pushes the current branch by default. If the branch has no upstream, it
  runs `git push -u origin <branch>`.
- Added `--no-push` for local sandbox/release testing and explicitly offline
  work. Push preflight now stops before commit when the repo is detached or has
  no `origin` remote.
- Runtime-upgrade grouping now includes root SFS entry files such as `SFS.md`,
  `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, and `.gitignore`.
- Claude/Codex/Gemini templates, plugin command, kernel, and `SFS.md` now
  explicitly forbid routing Solon commit guidance to a host-local `/commit`
  skill. The portable command is `sfs commit plan` followed by
  `sfs commit apply --group <name>`.
- Install/upgrade/uninstall completion hints now recommend `sfs commit` instead
  of raw `git add` / `git commit` / `git push` sequences.

### Tests

- Added `test-sfs-commit-push.sh`, which uses a local bare remote to verify
  that `sfs commit apply` updates the remote branch and that `--no-push` leaves
  the remote untouched.
- Extended agent guardrail and native commit-message tests to lock the SFS
  commit surface and reject stale raw-git or host-local commit guidance.

## [0.6.75] - 2026-05-09

> **Same-cycle review micro-rework.** Agents should not bounce deterministic
> tiny review findings back to the user. They should patch, verify, and rerun
> the same gate review unless product judgment is required.

### Changed

- Added a same-cycle micro-rework rule to the SFS kernel, Gate 3 plan context,
  review context, `SFS.md` template, Claude/Codex/Gemini entry templates,
  Codex skill, plugin command, README/GUIDE, and English/Korean current-shape
  docs.
- Deterministic low-risk findings such as grep scope holes, stale measured
  evidence, missing AC/file/artifact mapping, evidence path typos, and
  meaning-preserving documentation consistency now route to automatic patch,
  smallest verification, and same-gate review rerun.
- User escalation is reserved for product judgment: scope, architecture, public
  contract, security/privacy/data-loss posture, cost/latency/model policy,
  destructive behavior, changed AC meaning, or repeated partial/fail on the same
  micro-fix.

## [0.6.74] - 2026-05-09

> **Retention policy docs refresh.** The user-facing docs, runtime entry
> templates, Codex skill, and plugin command now describe `.sfs-local/` as an
> active workbench, not a durable history stack.

### Changed

- Clarified that visible `.sfs-local` files must have a clear one-line keep
  reason.
- Documented `events.jsonl` as current-sprint active ledger state only; stale,
  orphan, or closed-sprint-only events are removed or archived by
  `sfs upgrade` / `sfs tidy --all --apply`.
- Documented daily surface-cleanup bundling under
  `.sfs-local/archives/adopt/surface-cleanup/<yyyyMMdd>/surface-cleanup.tar.gz`.
- Synced the policy across README, GUIDE, English/Korean current-shape docs,
  `SFS.md` template, Claude/Codex/Gemini entry templates, Codex skill, and the
  Solon plugin command.

## [0.6.73] - 2026-05-09

> **Daily surface-cleanup verification.** Release and Windows smoke checks now
> understand the new daily `surface-cleanup.tar.gz` bundle shape.

### Fixed

- Updated Windows Scoop smoke verification so opt-in adapter archives can be
  found after they are nested under
  `.sfs-local/archives/adopt/surface-cleanup/<yyyyMMdd>/surface-cleanup.tar.gz`.
- This keeps CI aligned with the 0.6.72 surface policy: one visible daily
  directory, with recovery evidence preserved inside tar bundles.

## [0.6.72] - 2026-05-09

> **Daily surface-cleanup bundle.** Same-day post-adopt/surface cleanup archive
> evidence no longer leaves many timestamp directories visible under
> `.sfs-local/archives/adopt/surface-cleanup/`.

### Changed

- `sfs tidy --all --apply` and `sfs upgrade --yes` now consolidate direct
  `surface-cleanup` run directories into
  `.sfs-local/archives/adopt/surface-cleanup/<yyyyMMdd>/surface-cleanup.tar.gz`
  with a small `manifest.txt`.
- Recovery evidence is preserved inside the daily bundle, but the visible
  archive surface is date-bucketed so repeated same-day cleanup runs do not
  make the project tree noisy.
- Existing same-day run directories are compacted on the next normal
  `sfs tidy --all --apply` or `sfs upgrade --yes`; no manual deletion is
  required.

### Tests

- Updated tidy/upgrade surface-cleanup tests to require a single visible daily
  directory and verify nested cold evidence is still recoverable.

## [0.6.71] - 2026-05-09

> **Codex review routing is prompt/host-runtime based again.** 0.6.69/0.6.70
> fixed the intended review_high profile but incorrectly reintroduced default
> Codex CLI model flags. This release restores the prior bridge contract:
> request review_high in the CPO prompt and rely on the host/runtime profile,
> unless the user explicitly supplies a custom `SFS_REVIEW_CODEX_CMD`.

### Fixed

- Removed default `codex exec --model ... -c model_reasoning_effort=...` flags
  from the built-in Codex review bridge and bridge probe.
- Strengthened the CPO prompt so Codex review explicitly requests
  `review_high` (`gpt-5.5` + xhigh) and rejects silent fallback to
  `gpt-5.3-codex`/normal worker routing.
- Kept `SFS_REVIEW_CODEX_CMD` as the explicit opt-in path for environments
  where the user knows concrete Codex CLI model flags are supported.

### Tests

- Updated guardrail tests to require prompt/host-runtime routing and reject
  default Codex model/reasoning CLI flags.

## [0.6.70] - 2026-05-09

> **events.jsonl is current-sprint state only.** The active ledger now prunes
> closed-sprint and no-sprint log residue during normal event writes, tidy, and
> upgrade.

### Fixed

- `append_event` now keeps only event lines that belong to the current sprint;
  closed-sprint lines and global log-like lines no longer survive as visible
  `.sfs-local/events.jsonl` history.
- `sfs tidy --all --apply` prunes event lines for any non-current sprint even
  when that sprint folder has already been archived and is no longer part of
  the visible `--all` target set.
- `sfs upgrade` applies the same current-sprint-only ledger rule to existing
  projects, so rerunning the normal upgrade command removes stale historical
  event lines without manual deletion.

### Tests

- Extended `test-sfs-events-active-ledger-compaction.sh` to cover closed-sprint
  event pruning while a new sprint remains active.
- Extended `test-sfs-upgrade-minimal-residue-migration.sh` so upgrade removes
  stale closed-sprint/adoption migration events from the active ledger.

## [0.6.69] - 2026-05-09

> **Codex review bridge uses the review tier.** `sfs review --executor codex`
> now invokes Codex with the review/advisor profile by default instead of
> relying on the CLI's worker-oriented default model.

### Fixed

- The default Codex review prompt now names the intended review_high profile
  (`gpt-5.5` + xhigh), so the evaluator should not silently use worker routing.
- Note: the 0.6.69/0.6.70 bridge implementation briefly tried concrete Codex
  CLI model flags; 0.6.71 supersedes that with the prompt + host/runtime
  contract and keeps `SFS_REVIEW_CODEX_CMD` as the explicit custom-command path.
- Added guardrail coverage so future review routing cannot silently fall back
  to `gpt-5.3-codex` normal for CPO/cross-review work.

## [0.6.68] - 2026-05-09

> **Compact active event ledger.** `events.jsonl` is no longer treated as
> append-only history. It may remain only while it has a one-line active-sprint
> reason: current sprint status/gate/review routing.

### Changed

- `append_event` now rewrites `events.jsonl` as a compact active ledger:
  repeated command opens replace the previous line for the same natural key
  such as sprint, gate, division, decision, or WU.
- `sfs tidy --all --apply` compacts duplicate active event lines, prunes closed
  sprint event lines after report/archive evidence exists, and removes
  `events.jsonl` when no active sprint needs it.
- `sfs upgrade` compacts legacy event ledgers during surface migration so
  already-running projects converge when the user runs normal SFS commands.

### Tests

- Added `test-sfs-events-active-ledger-compaction.sh` covering repeated
  brainstorm/plan opens and removal after no active sprint remains.
- Full source test suite: `tests/run-all.sh` PASS 55/0.

## [0.6.67] - 2026-05-09

> **No-overwrite collapsed archive evidence.** Repeated surface-cleanup archive
> collapses now create unique directories so one cold-evidence bundle cannot
> overwrite another in the same second.

### Fixed

- `upgrade` now allocates a unique
  `.sfs-local/archives/adopt/surface-cleanup/...` directory whenever multiple
  archive-bucket collapses happen in one upgrade run.
- `tidy --all --apply` uses the same unique-directory guard for targetless
  surface cleanup.
- Added regression coverage ensuring vendored-to-thin upgrade preserves
  `project-runtime-assets.tar.gz`, `project-agent-adapters.tar.gz`, and
  `project-local-context.tar.gz` inside collapsed cold archives.

## [0.6.66] - 2026-05-09

> **Release guard parity for collapsed archives.** The Windows Scoop smoke and
> owner-side release verifier now understand the 0.6.65 policy that runtime
> migration/upgrade buckets are folded under `archives/adopt/surface-cleanup`.

### Fixed

- Updated the Windows Scoop smoke workflow so thin-upgrade adapter backup checks
  pass when `project-agent-adapters.tar.gz` is inside the collapsed
  `preexisting-archives.tar.gz` bundle.
- Updated owner release verification to accept both legacy top-level
  `archives/runtime-migrations/...` evidence and the new collapsed
  `archives/adopt/surface-cleanup/...` evidence.

## [0.6.65] - 2026-05-09

> **Post-adopt surface residue cleanup.** `sfs tidy --all --apply` now works
> even when no sprint folders remain, and `sfs upgrade` no longer leaves
> project-local cache notices or split archive buckets visible.

### Changed

- `sfs tidy --all --apply` can run as a targetless surface cleanup after adopt:
  it removes project-local cache notice files, placeholder-only `auth.env`,
  orphan `events.jsonl`, empty workbench dirs, and visible non-adopt archive
  buckets.
- `tidy` collapses top-level `.sfs-local/archives/runtime-migrations`,
  `.sfs-local/archives/runtime-upgrades`, and `.sfs-local/archives/sprints`
  into `.sfs-local/archives/adopt/surface-cleanup/.../preexisting-archives.tar.gz`
  so the visible archive surface remains one recovery lane.
- `upgrade` now removes `.sfs-local/cache/*notice.env`, removes placeholder-only
  `auth.env`, migrates orphan event ledgers, and folds runtime migration/upgrade
  backup buckets under `archives/adopt/surface-cleanup/...` before completion.
- Version stale-notice state moved out of the project workbench into the user's
  SFS cache directory, so ordinary `sfs status`/command use no longer recreates
  `.sfs-local/cache/version-notice.env`.

### Tests

- Added `test-sfs-tidy-targetless-surface-cleanup.sh` for post-adopt cleanup
  with no visible sprint folders.
- Extended upgrade/tidy retention tests so cache notices, placeholder auth,
  orphan logs, and non-adopt archive buckets cannot remain visible.

## [0.6.64] - 2026-05-09

> **Adopt visible residue + global handoff path hardening.** `sfs adopt --apply`
> now removes remaining workbench clutter, and shared SFS docs use
> `docs/solon/<english-workspace>/<yyyyMMdd>/`.

### Changed

- `adopt` now removes empty workbench surface directories such as
  `.sfs-local/cache`, `.sfs-local/tmp`, empty `queue`, empty `sprints`, and empty
  `decisions` after archiving their recoverable evidence.
- `current-sprint` is treated only as an active pointer reset, not as a
  nonessential residue file to double-count.
- `install` and `upgrade` no longer create or refresh a project-local
  `.sfs-local/auth.env.example`; the sample stays in the packaged runtime.
- `upgrade` archives old project-local `auth.env.example` copies and removes
  empty workbench dirs so already-adopted projects can converge to the same thin
  surface after `sfs upgrade`.
- Shared handoff/history docs now default to
  `docs/solon/<english-workspace>/<yyyyMMdd>/`; `sfs start` accepts
  `--workspace <english-name>` so agents can choose a clear English folder name
  instead of leaking sprint ids such as `2026-W19-sprint-5`.
- `sfs review --last` and review-run stdout now surface a global `next:` action;
  Gate 3 PASS points to `sfs implement`, while later review PASS can point to
  `sfs retro`.

### Tests

- Extended `test-sfs-adopt-freeform.sh` to cover `auth.env`, `auth.env.example`,
  cache residue, and empty workbench dir cleanup after adopt.
- Extended `test-sfs-upgrade-minimal-residue-migration.sh` to ensure upgrade
  removes stale `auth.env.example` and empty `cache`/`tmp`/`queue` dirs.
- Updated shared handoff tests for `docs/solon/<english-workspace>/<yyyyMMdd>/`
  and added a Gate 3 review-next-action assertion.

## [0.6.63] - 2026-05-09

> **Plan review-readiness wording cleanup.** The plan template no longer uses
> the awkward literal phrase `열린 결정이 이름 붙어 있다`.

### Changed

- Replaced the Gate 3 `## 7. 리뷰 준비` checklist with concrete checks:
  Gate 2 decisions are mapped to requirements/AC, files/artifacts are mapped
  per slice, and worker model routing is explicit with Spark limited to locked
  mechanical implementation helper work.
- Added plan-context guidance to avoid translationese in review-readiness
  Korean output.

### Tests

- Extended `test-agent-behavior-guardrails.sh` to reject the awkward
  open-decision wording and require the new Gate 2/AC, slice artifact, and
  Spark-boundary checklist items.

## [0.6.62] - 2026-05-09

> **Decision prompt parity for Claude, Codex, and Gemini.** SFS now explicitly
> bans compact option-bundle confirmations such as `A/A/A/C/C 확정` across all
> packaged agent adapters and routed Gate 2/3 context.

### Changed

- Strengthened the kernel, brainstorm, and plan context so "show the
  recommendation again" must re-present the recommended path in plain language,
  not as internal option labels or a recommendation-only row.
- Added the same compact-bundle guardrail to Claude templates, Gemini command
  templates, Codex skill/prompt templates, SFS.md, plugin command text, and the
  shared command adapter.
- Updated GUIDE/current-product docs to state that confirmation uses natural
  language such as `권장안 그대로 확정`, not label bundles.

### Tests

- Extended `test-agent-behavior-guardrails.sh` so kernel, brainstorm, plan, and
  every Claude/Codex/Gemini adapter surface must carry the compact-bundle ban.

## [0.6.61] - 2026-05-09

> **Agent-skills benchmark absorption.** SFS now absorbs useful
> agent-skills-style practices as routed policies and review lenses instead of
> adding more lifecycle commands.

### Changed

- Added source-driven implementation, stop-the-line debugging,
  deprecation/migration cleanup, and shipping-launch policies to packaged SFS
  context.
- Strengthened `implement`, `review`, `adopt`, `tidy`, and `release` routed
  context so those practices run inside existing commands.
- Added public review lenses and aliases for `source-docs`, `simplify`,
  `security`, `performance`, and `api-contract`.
- Added review severity language (`Critical`, `Required`, `Important`,
  `Optional`, `FYI`) so findings can separate blocking risk from advisory
  cleanup.
- Updated Claude/Codex/Gemini adapter docs plus README/GUIDE/current-product
  and 10x docs to state that benchmarked practices strengthen existing SFS
  commands rather than becoming new commands.
- Added the benchmark report under
  `docs/agent-skills-benchmark/20260509/report.md`.

### Tests

- Added `test-agent-skills-benchmark-absorption.sh` for packaged context,
  policy files, adapter text, and review lens exposure.
- Extended `test-review-lens-aliases.sh` to exercise the new review lenses and
  aliases.

## [0.6.60] - 2026-05-09

> **Strict adopt cleanup under `docs/solon/<english-workspace>/<yyyyMMdd>`.** `sfs adopt`
> now applies the same visible-file rule as tidy: if a file cannot be justified
> in one line, it is archived or removed from the visible project surface.

### Changed

- `sfs adopt --apply` now writes the durable handoff to
  `docs/solon/<english-workspace>/<yyyyMMdd>/handoff.md`. For adopt, `<workspace>` defaults
  to the adopt id (`legacy-baseline` by default, or `--id <name>`).
- Legacy flat adoption docs such as
  `docs/solon/<id>-adoption-summary.md` are cold-archived and removed from the
  visible docs surface.
- Adopt now cold-archives pre-existing sprints, pre-existing archive folders,
  `.sfs-local/tmp`, old `events.jsonl`, `decisions/*.md`, adapter/runtime dust,
  and other `.sfs-local` residue that does not have a one-line keep reason.
- Existing `current-sprint` pointers are treated as legacy adoption state and
  removed after archiving, so a freshly adopted project starts with no active
  SFS sprint unless the user explicitly runs `sfs start`.
- The only visible `.sfs-local` files left by baseline adoption are runtime
  configuration files with one-line keep reasons: `VERSION`, `config.yaml`,
  `divisions.yaml`, and `model-profiles.yaml`.
- Shared report/retro/tidy docs now consistently use
  `docs/solon/<english-workspace>/<yyyyMMdd>/`; `docs/solon/` remains available for
  project-wide Solon reference docs such as domain maps or design contracts.

### Tests

- Extended `test-sfs-adopt-freeform.sh` to cover strict adopt retention:
  no visible `events.jsonl`, no preserved active sprint pointer, private cold
  archives for tmp/decision/runtime residue, archived flat docs/solon adoption
  summaries, and the new `docs/solon/<english-workspace>/<yyyyMMdd>/handoff.md` location.
- Updated upgrade, tidy, and shared-handoff tests for the root `docs/`
  handoff path.

## [0.6.59] - 2026-05-09

> **Shared handoff docs under `docs/solon`.** Sprint close artifacts now live
> in the repository's shared documentation surface instead of the private
> `.sfs-local` sprint folder.

### Changed

- `sfs report` now creates or updates
  `docs/solon/<workspace>/<yyyyMMdd>/report.md`. `<workspace>` defaults to the
  path-safe form of the `sfs start "<goal>"` text, so `sfs start "결제 오류 수정"`
  writes handoff docs under `docs/solon/결제-오류-수정/<yyyyMMdd>/`.
- `sfs retro` and `sfs retro --draft` now create or update the matching
  `docs/solon/<workspace>/<yyyyMMdd>/retro.md`.
- Legacy `.sfs-local/sprints/<id>/report.md` or `retro.md` files are migrated
  to the shared handoff location when possible; conflicting legacy copies are
  moved into the sprint cold archive instead of staying as visible residue.
- `sfs retro` close commits now stage the shared `docs/solon/` handoff docs
  along with `.sfs-local` state cleanup.
- Report/retro templates and routed tidy context now state that handoff prose
  should use the user's native/workspace language, matching the commit-message
  language rule.

### Tests

- Added `test-sfs-shared-handoff-docs.sh`, covering Korean `sfs start` goal
  based path generation, shared report/retro creation, native-language template
  guidance, and auto-close commit staging.
- Extended tidy retention and native-language guardrail tests for the new
  shared handoff location.

## [0.6.58] - 2026-05-09

> **Strict `.sfs-local` retention for tidy.** `sfs tidy` now follows the
> rule that visible `.sfs-local` residue must have a one-line keep reason.
> Closed-sprint workbench evidence is recoverable in a cold archive, while
> historical event ledger dust and placeholder files stop staying visible.

### Changed

- `sfs tidy --all --apply` now prunes `events.jsonl` when it no longer backs an
  active sprint/current state. Closed-sprint event lines are removed after
  `report.md` and the cold archive carry the durable evidence; an empty ledger
  file is deleted instead of kept as residue.
- Tidy now removes broken `current-sprint` pointers, empty placeholder
  directories, and legacy `.gitkeep` dust from `.sfs-local`.
- Tidy dry-run/apply output now reports the retention rule, event pruning, and
  residue cleanup so Windows/macOS users can tell whether the strict cleanup
  policy is actually active.
- Sprint archive manifests now state the one-line keep-reason policy and the
  reason `report.md`/`retro.md` may remain visible.

### Tests

- Added `test-sfs-tidy-retention.sh`, covering closed-sprint `events.jsonl`
  pruning, broken `current-sprint` cleanup, placeholder removal, and cold
  archive manifest retention text.

## [0.6.57] - 2026-05-09

> **Mac-side release cut for the Windows wrapper fix.** The Windows-side
> 0.6.56 proof commits are cut as 0.6.57 for Homebrew and Scoop publication,
> keeping the already-pushed 0.6.56 tag as the proof baseline and using
> 0.6.57 as the user-facing package version.

### Changed

- Cut the completed Windows `sfs.cmd version/context/start/upgrade` fix set as
  the package-channel release version after origin sync on macOS.
- User-facing current-version documentation now points at 0.6.57 while the
  detailed Windows incident report remains the 0.6.56 baseline report.

## [0.6.56] - 2026-05-08

> **Windows usable-args root cause fix.** A pre-release Windows trace run
> (`25554923214`) proved the loop was not caused by batch losing `%1/%*`.
> `sfs.cmd` delivered `version` through `SFS_NATIVE_ARGC`, `SFS_NATIVE_RAW_ARGS`,
> and `SFS_NATIVE_ARG_1`, but `sfs.ps1` repeatedly collapsed the command at
> function boundaries that used the PowerShell-sensitive parameter name `$Args`.

### Fixed

- `bin/sfs.ps1` now avoids `$Args` as a function parameter, named call, or
  runtime reload splat. `Test-SfsUsableArgs` uses `$Items`, and native
  dispatch/self-upgrade helpers use `$InvocationArgs`, so a valid one-item env
  bridge such as `version` survives into `Invoke-SfsNativeVersion`.
- `bin/sfs.cmd` and the Scoop post-install hardened `sfs.cmd` shim reverted the
  experimental `--% %SFS_NATIVE_RAW_ARGS%` bridge. The Windows trace showed it
  reached `sfs.ps1` as `--SFS_NATIVE_RAW_ARGS`, which hid the real env-bridge
  bug and made the wrapper more complex.
- Windows smoke now requires `SFS_ARGTRACE_PS_SELECTED_SOURCE=env` and
  `SFS_ARGTRACE_PS_FINAL_ARGS=.*version` before accepting `sfs.cmd version`.
- Guardrail tests and the release verifier now fail if the broken `$Args`
  predicate or `--% %SFS_NATIVE_RAW_ARGS%` dispatch returns.
- `sfs.cmd upgrade` now restores WindowsPowerShell module paths, imports
  `Microsoft.PowerShell.Utility`, and installs a scoped `Get-FileHash` fallback
  with path and stream hashing before calling Scoop self-upgrade, matching the
  Windows runner path where `scoop update sfs` needs that cmdlet to validate
  the downloaded zip.
- The post-Scoop reload now normalizes `InvocationArgs` into an explicit
  `string[]` before splatting, preventing `upgrade` from being replayed as the
  single-letter command `u` after runtime self-upgrade.
- The post-Scoop reload now resolves through Scoop's `current\bin\sfs.ps1`
  before replaying the command, so self-upgrade does not return to the
  pre-update package path.
- The Windows post-Scoop reload canonicalizes `upgrade` to `update` and strips
  wrapper-level `--yes`/`-y` before entering the Bash runtime. This keeps
  `sfs.cmd upgrade` as a compatibility spelling while executing the stable
  one-command update path after the runtime refresh.
- The post-Scoop reload now rewrites the numbered env bridge before invoking the
  new runtime. Trace run `25558767614` showed `PS_RELOAD_ARGS=update`, but the
  stale parent `SFS_NATIVE_ARG_1=upgrade` still won source selection and replayed
  `upgrade` into Bash. `Set-SfsNativeArgEnv` now clears stale numbered args,
  writes canonical `update`, and preserves one-token arrays as `[update]`.
- `upgrade.sh` no longer reopens `/dev/tty` in CI, and the Windows Scoop smoke
  runs user-facing `sfs.cmd upgrade` while teeing live trace output. This
  prevents the GitHub runner from waiting forever at the interactive "continue
  upgrade" prompt during self-upgrade verification.
- `upgrade.sh` has an opt-in `SFS_UPGRADE_TRACE=1` phase trace for development
  and CI diagnosis. Production remains quiet unless the variable is set.
- The post-profile upgrade tail is now traceable through `model profile notice`,
  `cli-discovery hook`, and `completion output` markers. Trace run
  `25559894888` proved the Windows reload had reached Bash as `[update]`, then
  stopped after `maybe_prompt_model_profile after`; the new markers make the
  next phase boundary explicit.
- `upgrade.sh` wraps the whole CLI discovery hook in a watchdog controlled by
  `SFS_CLI_DISCOVERY_TIMEOUT_SEC`, and `install-cli-discovery.sh` wraps external
  `claude`/`gemini`/`git clone` probes with `SFS_DISCOVERY_CMD_TIMEOUT_SEC`.
  Discovery failures now warn and continue instead of allowing self-upgrade to
  wait forever on an external CLI.
- `bin/sfs` now uses POSIX `timeout(1)` with kill-after support before its
  fallback background watchdog. The fallback watchdog redirects its own stdio
  away from the caller, so a Windows Git Bash `sleep` child cannot keep a
  PowerShell `Tee-Object` pipeline open after `upgrade.sh` has printed
  `completion output after`.
- `bin/sfs.ps1` now emits an opt-in
  `SFS_ARGTRACE_PS_AFTER_BASH_BRIDGE_LASTEXITCODE` marker after the final
  PowerShell-to-Git-Bash bridge returns. The Windows Scoop smoke requires that
  marker for `sfs.cmd upgrade`, proving the wrapper returned from Bash instead
  of only proving that Bash printed its final line.
- The Windows Scoop smoke no longer assigns the `Tee-Object` upgrade pipeline
  to a variable. That assignment captured output and hid live trace lines until
  the command exited, so failures can now be traced from the last emitted line.
- The final PowerShell-to-Git-Bash bridge now also normalizes `SfsArgs` into an
  explicit `string[]`, covering the single-token `upgrade` path after reload.
- Decision-output guardrails now reject recommendation-only choice tables.
  Agents must define option labels such as `A/B/C/D`, show every viable option
  with meaning and consequence, and ask sequentially when the full option set is
  too wide.
- `.sfs-local/` is reaffirmed as private workbench state: runtime logs,
  `events.jsonl`, cache, tmp, archives, and queue run logs stay ignored and
  disposable; durable shared conclusions belong in `docs/solon/<english-workspace>/<yyyyMMdd>/` or the sprint
  close report.

## [0.6.55] - 2026-05-08

> **Windows raw-tail automatic args bridge.** The 0.6.54 GitHub Windows Scoop
> smoke run `25548381094` still showed the first post-install `sfs.cmd version`
> falling through to usage-only output. The hardened shim had the env/raw/saved
> command-line contracts, but child PowerShell still reached `sfs.ps1` without a
> usable direct argv source on that runner.

### Fixed

- `bin/sfs.cmd` and the Scoop post-install hardened `sfs.cmd` shim now call
  `powershell.exe -File "%SFS_NATIVE_SCRIPT%" --% %SFS_NATIVE_RAW_ARGS%`, so the
  raw tail saved before `shift` also reaches `sfs.ps1` as automatic `$args`.
- The existing numbered env bridge, raw env fallback, saved command-line
  fallback, parent `cmd.exe` command-line fallback, and child `CMDCMDLINE`
  fallback stay in place; 0.6.55 adds a direct argv source instead of removing
  recovery layers.
- Windows guardrails, release verifier, Windows smoke shim text checks, and the
  incident report now record P22 with run `25548381094`.
- `sfs.cmd` / `sfs.ps1` now expose opt-in `SFS_WINDOWS_ARG_TRACE=1` diagnostics
  so Windows smoke logs show batch args, PowerShell args, selected source, and
  final resolved args before another usage-only failure can become guesswork.

## [0.6.54] - 2026-05-08

> **Windows parent command-line fallback.** The 0.6.53 GitHub Windows Scoop
> smoke run `25546859759` still showed the first `sfs.cmd version` falling
> through to usage-only output. The delayed-expansion saved-cmdline bridge was
> present in the hardened shim, but did not recover the original wrapper command
> line on the runner.

### Fixed

- `bin/sfs.ps1` now falls back to the parent `cmd.exe` process command line via
  `Get-CimInstance -ClassName Win32_Process` when env args, raw args, and
  `SFS_NATIVE_CMDLINE` are all unusable.
- The parent command-line fallback uses the same `sfs.cmd` tail parser and
  shell-control tail trimming as the saved-cmdline fallback, so chained command
  lines still stop before `&& sfs.cmd --help`.
- The command-line parser now extracts the tail after the `sfs.cmd` command
  name before whitespace splitting, so parent command lines with spaces before
  `sfs.cmd` in the path do not get split into fake arguments.
- Windows guardrails, release verifier, and the incident report now record P21
  with run `25546859759`.

## [0.6.53] - 2026-05-08

> **Windows saved command-line bridge.** The 0.6.52 GitHub Windows Scoop smoke
> run `25545120029` still showed `sfs.cmd version` falling through to
> usage-only output even though the hardened shim contained `SFS_NATIVE_RAW_ARGS`.
> The cmd shim now saves the batch process's original command line as
> `SFS_NATIVE_CMDLINE` through delayed expansion before starting child PowerShell.

### Fixed

- `bin/sfs.cmd` and the Scoop post-install hardened `sfs.cmd` shim now capture
  `SFS_NATIVE_CMDLINE=!CMDCMDLINE!` inside the delayed-expansion dispatch block,
  avoiding raw `%CMDCMDLINE%` expansion on command lines that contain quotes,
  shell operators, or redirection.
- `bin/sfs.ps1` now reads `SFS_NATIVE_CMDLINE` after the raw-arg fallback and
  before child PowerShell's own `CMDCMDLINE` fallback. The saved-command-line
  parser also trims `cmd.exe` shell-control tails such as `&& sfs.cmd --help`.
- Windows smoke, guardrails, release verifier, and the Windows incident report
  now assert the saved-command-line bridge, force the env/raw-empty fallback
  path, and record P20 with run `25545120029`.

## [0.6.52] - 2026-05-08

> **Windows raw arg tail hardening.** The 0.6.51 GitHub Windows Scoop smoke run
> `25543802195` reached the runtime install but showed hardened `sfs.cmd version`
> still falling through to usage-only output. The cmd shim now preserves the
> original `%*` tail before `shift` and exposes it as `SFS_NATIVE_RAW_ARGS`.

### Fixed

- `bin/sfs.cmd` and the Scoop post-install hardened `sfs.cmd` shim now capture
  `SFS_NATIVE_RAW_ARGS=%*` before the `%1..%n` collection loop consumes args.
- `bin/sfs.ps1` now reads `SFS_NATIVE_RAW_ARGS` after the numbered env bridge
  and before the `CMDCMDLINE` fallback; all-empty resolved arg arrays are treated
  as unusable so fallback paths are not blocked by a broken bridge.
- Windows guardrails, release verifier, and the Windows incident report now
  assert the raw-arg fallback contract and record P19 with run `25543802195`.

## [0.6.51] - 2026-05-08

> **Windows smoke tag refspec fix.** The 0.6.50 GitHub Windows Scoop smoke run
> `25542777986` failed before install because PowerShell parsed
> `$brokenVersion:` inside the `git fetch` refspec as scoped variable syntax.
> The known-broken package fetch now uses `${brokenVersion}` braces.

### Fixed

- `.github/workflows/windows-scoop-smoke.yml` now fetches and archives the real
  known-broken `v0.6.49` package with `refs/tags/v${brokenVersion}` and
  `v${brokenVersion}` so PowerShell cannot rewrite the refspec to
  `refs/tags/v/tags/v0.6.49`.
- Windows guardrails and the release verifier now assert the braced refspec and
  archive-tag contract along with the cloned-bucket refresh contract.

## [0.6.50] - 2026-05-08

> **Windows hardened shim dual forwarding.** The 0.6.49 GitHub Windows Scoop
> smoke run `25541086874` proved that post-install shim overwrite did run, but
> the env-only hardened `sfs.cmd` shim still let `sfs.cmd version` fall through
> to generic usage. The hardened shim now keeps the numbered env bridge and also
> forwards `%*` to packaged `sfs.ps1`.

### Fixed

- `bin/sfs-scoop-post-install.ps1` now writes a hardened `sfs.cmd` shim that
  calls `powershell.exe -File "%SFS_NATIVE_SCRIPT%" %*` after storing `%1..%n`
  in `SFS_NATIVE_ARGC` / `SFS_NATIVE_ARG_N`. This gives `sfs.ps1` both the env
  source and the PowerShell automatic-args source.
- Windows Scoop smoke now checks the installed `sfs.cmd` shim text immediately
  after install and fails if either `SFS_NATIVE_ARGC` or `%*` is missing.
- Windows Scoop smoke now also installs the real known-broken `v0.6.49` archive,
  confirms `sfs.cmd version` falls through to usage, and verifies direct
  `scoop update` plus `scoop update sfs` recovers to the current runtime.

### Tests

- Windows guardrails and the release verifier now require env+positional
  forwarding in the post-install hardened shim and require the broken-0.6.49
  direct-Scoop recovery smoke.
- Windows wrapper incident reports are refreshed to the 0.6.50 baseline with
  the P17 env-only hardened shim finding and run `25541086874` evidence.

## [0.6.49] - 2026-05-08

> **Windows Scoop shim hardening.** The 0.6.48 GitHub Windows Scoop smoke run
> `25539387684` proved that pinning the workflow to `sfs.cmd` was not enough:
> the generated `sfs.cmd` shim still dropped `version` before packaged
> `bin\sfs.ps1` could see it. Scoop post-install now overwrites the generated
> `sfs.cmd`, `sfs.ps1`, and extensionless `sfs` shims with deterministic
> wrappers owned by Solon.

### Fixed

- `bin/sfs-scoop-post-install.ps1` now hardens the Scoop shims directory after
  every install/update. The `sfs.cmd` shim stores `%1..%n` as the numbered env
  bridge and invokes packaged `sfs.ps1` on the same parsed line; the PowerShell
  shim forwards `$args`; the Git Bash shim executes packaged `bin/sfs`.
- `bin/sfs.ps1` now passes resolved arrays to internal PowerShell functions via
  named parameters so multi-word commands such as `context cat kernel` cannot be
  truncated by implicit argument enumeration.

### Tests

- Windows guardrails now require post-install shim hardening and the named-array
  forwarding path inside `sfs.ps1`.
- Windows wrapper incident reports are refreshed to the 0.6.49 baseline with
  the P16 generated `sfs.cmd` shim finding, run `25539387684` evidence, and the
  existing `ci-korean-sprint-test` smoke contract.

## [0.6.48] - 2026-05-08

> **Windows PowerShell/cmd contract pinned to `sfs.cmd`.** The 0.6.47 GitHub
> Windows Scoop smoke run `25535059980` proved that the generated bare `sfs`
> shim can still drop arguments before the package sees them. The user-facing
> Windows path is now treated as `sfs.cmd`; bare `sfs` remains for Git Bash/WSL.

### Fixed

- Windows Scoop smoke now uses `sfs.cmd version`, `sfs.cmd --help`,
  `sfs.cmd init`, `sfs.cmd status`, `sfs.cmd auth`, `sfs.cmd agent install`,
  `sfs.cmd upgrade`, and Korean `sfs.cmd start` for the PowerShell/cmd path.
- Windows docs now state that PowerShell/cmd users should use `sfs.cmd`, while
  Git Bash/WSL users can continue to use `sfs`.

### Tests

- Windows guardrails now check that the workflow's PowerShell/cmd and cmd.exe
  smoke paths are pinned to `sfs.cmd`, while the Git Bash path still validates
  bare `sfs`.
- Windows wrapper incident reports are refreshed to the 0.6.48 baseline with
  the P15 bare generated-shim finding and run `25535059980` evidence.

## [0.6.47] - 2026-05-08

> **Windows Scoop PowerShell shim automatic args.** The 0.6.46 GitHub Windows
> Scoop smoke run `25534566676` proved that the manifest target change did take
> effect: `Get-Command sfs` pointed at `sfs.ps1`. But `sfs version` still fell
> through to generic usage, so `ValueFromRemainingArguments` remained unreliable
> under generated Scoop PowerShell shims.

### Fixed

- `bin/sfs.ps1` no longer declares a script param block. It reads PowerShell
  automatic `$args` after the numbered env bridge and before `CMDCMDLINE` /
  unbound fallback recovery.
- `bin/sfs.cmd` remains a direct-run compatibility trampoline; direct `.cmd`
  invocation still has the numbered env bridge and `%*` fallback into
  PowerShell.

### Tests

- Windows guardrails and release verification now reject
  `ValueFromRemainingArguments` in packaged `sfs.ps1` and require the explicit
  `$SfsParamArgs = @()` disabled-param source.
- Windows wrapper incident reports are refreshed to the 0.6.47 baseline with
  the P14 generated Scoop PowerShell shim -> script-param finding.

## [0.6.46] - 2026-05-08

> **Windows Scoop primary shim target.** The 0.6.45 GitHub Windows Scoop smoke
> run `25533332634` proved that the `CMDCMDLINE` recovery was still too late
> when the generated Scoop shim targeted packaged `bin\sfs.cmd`: the very first
> `sfs version` call still fell through to generic usage. Scoop now targets
> packaged `bin\sfs.ps1` directly.

### Fixed

- `packaging/scoop/sfs.json.template` now exposes `sfs` through `bin\sfs.ps1`
  instead of `bin\sfs.cmd`, so Scoop's generated PowerShell shim is the primary
  Windows path.
- `bin/sfs.ps1` accepts `ValueFromRemainingArguments` positional args again for
  the Scoop PowerShell shim path, while keeping the env bridge, `$args`,
  `CMDCMDLINE`, and unbound-arg fallbacks.
- `bin/sfs.cmd` remains a direct-run compatibility trampoline and passes `%*`
  to `sfs.ps1` as an additional fallback while keeping the numbered env bridge.

### Tests

- Windows guardrails and release verification now require the Scoop manifest to
  target `bin\sfs.ps1` and reject `bin\sfs.cmd` as the primary generated-shim
  target.
- Windows wrapper incident reports are refreshed to the 0.6.46 baseline with
  the P13 generated shim -> packaged `.cmd` finding.

## [0.6.45] - 2026-05-08

> **Windows `CMDCMDLINE` fallback.** The 0.6.44 GitHub Windows Scoop smoke
> run `25532838102` proved that even the numbered `%1..%n` env bridge can start
> empty under the generated Scoop shim: `sfs version` still fell through to
> generic usage. `sfs.ps1` now has one last native Windows recovery source: the
> original `CMDCMDLINE` command line.

### Fixed

- `bin/sfs.ps1` now parses `CMDCMDLINE` only when the numbered env bridge,
  positional param args, and automatic `$args` are empty. It finds the `sfs` /
  `sfs.cmd` invocation tail and converts it into the same SFS argument list.
- The fallback keeps `sfs.cmd` as the thin batch trampoline while covering the
  observed Scoop shim case where the target batch receives no `%1..%n`.

### Tests

- Windows guardrails and release verification now require the `CMDCMDLINE`
  fallback reader and command-line splitter.
- Windows wrapper incident reports are refreshed to the 0.6.45 baseline with
  the P12 empty `%1..%n`/Scoop shim finding and the existing
  `ci-korean-sprint-test` smoke evidence.

## [0.6.44] - 2026-05-08

> **Windows numbered env arg bridge.** The 0.6.43 GitHub Windows Scoop smoke
> run `25532139459` proved that PowerShell `-Command @args` also lost shim
> arguments: `sfs version` again fell through to generic usage. Windows now
> avoids PowerShell CLI argument binding for the `sfs.cmd` -> `sfs.ps1` hop.

### Fixed

- `bin/sfs.cmd` now collects `%1..%n` into numbered environment variables
  (`SFS_NATIVE_ARGC`, `SFS_NATIVE_ARG_N`) with delayed expansion disabled during
  capture, then invokes packaged `sfs.ps1` through `powershell.exe -File`
  without argv.
- `bin/sfs.ps1` now reads the numbered env arg bridge before positional param
  args, automatic `$args`, and `$MyInvocation.UnboundArguments`. This keeps the
  older direct/agent-shaped fallbacks while making the Scoop shim path
  independent of PowerShell CLI argument binding.

### Tests

- Windows guardrails and release verification now reject both old bridges:
  `powershell.exe -File sfs.ps1 %*` and PowerShell
  `-Command "& $env:SFS_NATIVE_SCRIPT @args"`.
- Windows wrapper incident reports are refreshed to the 0.6.45 baseline with
  the P11 `-Command @args`/Scoop shim finding and the existing
  `ci-korean-sprint-test` smoke evidence.

## [0.6.43] - 2026-05-08

> **Windows PowerShell `-Command @args` bridge hardening.** The 0.6.42
> label-free `sfs.cmd` package still failed in the real GitHub Windows Scoop
> smoke: `sfs version` again fell through to generic usage under the Scoop shim.
> That proved the remaining unstable bridge was `powershell.exe -File
> sfs.ps1 %*`, not just batch labels.

### Fixed

- `bin/sfs.cmd` now invokes packaged `sfs.ps1` through PowerShell
  `-Command "& $env:SFS_NATIVE_SCRIPT @args"` instead of `-File ... %*`.
  This keeps `sfs.cmd` as a label-free trampoline while letting PowerShell pass
  the shim arguments through `$args`.
- `bin/sfs.ps1` now accepts a positional `[object[]] $SfsParamArgs` source before
  falling back to automatic `$args` and `$MyInvocation.UnboundArguments`.
  Direct script calls, `-Command @args` calls, and older agent-shaped arrays are
  normalized into the same SFS argument list.

### Tests

- Windows guardrails and release verification now reject the old
  `powershell.exe -File sfs.ps1 %*` bridge and require the explicit
  `SFS_NATIVE_SCRIPT @args` path. This was superseded by 0.6.45 after the real
  Windows smoke showed `-Command @args` also loses args under Scoop shims.
- Windows wrapper incident reports are refreshed to the 0.6.45 baseline with the
  P10-P12 PowerShell/Scoop shim findings, while keeping the Korean
  `ci-korean-sprint-test` smoke evidence.

## [0.6.42] - 2026-05-08

> **Windows `sfs.cmd` thin trampoline hardening.** The 0.6.41 source/package
> checks fixed the PowerShell parser issue, but the real GitHub Windows Scoop
> smoke still showed `sfs version` falling through to usage under the Scoop shim.
> The remaining unstable piece was batch-label forwarding itself.

### Fixed

- `bin/sfs.cmd` is now a label-free thin PowerShell trampoline. It forwards
  `%*` directly to packaged `sfs.ps1` and exits on the same parsed line.
- Native Windows read-only ownership moved fully into `sfs.ps1`: `version`,
  `status`, `guide`, and `context` are handled there before Bash fallback.
- Release verification and Windows guardrails now reject any `call :...` batch
  labels in `sfs.cmd`, while continuing to reject raw Git Bash `%*`,
  `SFS_ORIGINAL_ARGS`, direct batch-owned `scoop update`, and batch tail
  fragments.

### Tests

- Windows wrapper incident reports are refreshed to the 0.6.42 baseline with the
  P9 batch-label/Scoop shim finding.
- `test-windows-agent-adapter-fallback.sh` and `verify-product-release.sh` now
  enforce the thin `sfs.cmd -> sfs.ps1` contract.

## [0.6.41] - 2026-05-08

> **Windows PowerShell 5.1 / Scoop shim hardening.** The 0.6.40 source and
> package checks passed locally, but the real GitHub Windows Scoop smoke still
> failed before project smoke: Scoop post-install parsed a BOM-less UTF-8
> PowerShell script as legacy ANSI, and `sfs version` still fell through to
> usage because cached batch arguments were empty under the Scoop shim path.

### Fixed

- Windows PowerShell/cmd scripts are now ASCII-only. This avoids Windows
  PowerShell 5.1 parser corruption when BOM-less UTF-8 strings such as em
  dashes or arrows are decoded through a legacy code page during Scoop
  post-install.
- `bin/sfs.cmd` no longer caches `%*` into `SFS_ORIGINAL_ARGS`. Both native
  read-only dispatch and non-native PowerShell bridge calls forward the
  call-label `%*` directly to `sfs.ps1`, matching the path that Windows/Scoop
  actually preserves.

### Tests

- Windows wrapper guardrails now fail if any packaged `.ps1` / `.cmd` file
  contains non-ASCII bytes.
- Guardrails and release verification now reject `SFS_ORIGINAL_ARGS` and require
  direct `%*` forwarding on the same parsed line as `exit /b !ERRORLEVEL!`.
- The Windows wrapper incident report is updated to the 0.6.41 baseline with the
  PowerShell 5.1 parser and Scoop shim argument findings.

## [0.6.40] - 2026-05-08

> **Windows `sfs.cmd` exit/parser follow-up.** The 0.6.39 source tests passed,
> but the real GitHub Windows Scoop smoke still failed: `sfs version` printed
> usage through the Scoop shim, and `install-cli-discovery.ps1` hit a Windows
> PowerShell parser error during post-install.
> This release was superseded by 0.6.41 after the real Windows Scoop smoke
> showed that BOM-less UTF-8 PowerShell scripts and cached batch args still
> failed under Windows PowerShell 5.1 / Scoop shims.

### Fixed

- `bin/sfs.cmd` now enables delayed expansion and uses same-line
  `exit /b !ERRORLEVEL!` after both the non-native PowerShell dispatch and the
  actual `powershell.exe -File sfs.ps1 ...` call. This preserves the
  self-upgrade tail-fragment fix without relying on unstable
  `call exit /b %%ERRORLEVEL%%` double expansion.
- `scripts/install-cli-discovery.ps1` now catches failures in the Claude
  filesystem-direct deploy path before `finally` cleanup, avoiding the Windows
  post-install parser failure seen in Actions.

### Tests

- Windows wrapper guardrails now require `EnableDelayedExpansion`, require the
  `exit /b !ERRORLEVEL!` same-line contract, and reject the old
  `call exit /b %%ERRORLEVEL%%` form.
- The release verifier enforces the same packaged `sfs.cmd` contract for both
  tarball and zip archives.

## [0.6.39] - 2026-05-08

> **Windows `sfs.cmd` argument and start smoke hotfix.** A real Windows 0.6.38
> install still printed generic usage for `sfs.cmd context cat ...` and
> `sfs.cmd start ...`, and a 0.6.36 -> 0.6.38 wrapper upgrade could still leave
> short batch tail fragments such as `e` and `*` after the successful install.
> This release was superseded by 0.6.40 after the real Windows Scoop smoke
> exposed an additional batch exit/parser issue.

### Fixed

- `bin/sfs.ps1` no longer relies on a `ValueFromRemainingArguments` script param,
  which proved unreliable for Windows PowerShell 5.1 `powershell.exe -File ...`
  field calls. It now normalizes automatic `$args`,
  `$MyInvocation.UnboundArguments`, nested arrays, literal `-SfsArgs`, and `--%`
  into the command argument list.
- `bin/sfs.cmd` now exits on the same parsed batch line after non-native
  PowerShell dispatch and after the actual `powershell.exe -File sfs.ps1 ...`
  call, so a Scoop self-upgrade cannot return into arbitrary lines from a
  replaced batch file.

### Tests

- Windows Scoop smoke now explicitly runs `sfs.cmd context cat kernel`,
  `sfs.cmd context cat commands/start.md`, `sfs.cmd start --id ci-sprint-test
  "sprint-create-test"`, verifies `.sfs-local/current-sprint`, checks the
  `sprint_start` event goal, and confirms `sfs.cmd status` sees the new sprint.
- The same Windows smoke now installs a local previous Scoop package first,
  publishes the current package to the local bucket, runs `sfs.cmd upgrade`,
  rejects batch tail-fragment output (`TIVE_READONLY_DONE`, `LF_UPGRADE_DONE`,
  `e`, `*`), and then verifies a Korean free-text `sfs.cmd start --id
  ci-korean-sprint-test --force "스프린트 생성 테스트"` event.
- Windows wrapper guardrails now reject `ValueFromRemainingArguments` in
  `sfs.ps1` and require the same-line batch exit contract.

### Docs

- Refreshed the Windows wrapper incident report for the 0.6.39 interim baseline,
  including the attached `sfs.cmd start "스프린트 생성 테스트"` usage-only report
  and the `e` / `*` tail-fragment evidence.

## [0.6.38] - 2026-05-08

> **Installed incident-report test layout hotfix.** The 0.6.37 Windows Scoop
> runtime fix is unchanged, but the new incident-report documentation test
> assumed `CHANGELOG.md` and `RELEASE-NOTES.md` lived under `libexec/` in
> installed Homebrew packages.

### Fixed

- `tests/test-windows-wrapper-incident-report.sh` now resolves `CHANGELOG.md`
  and `RELEASE-NOTES.md` from the source/runtime root first, then falls back to
  the Homebrew Cellar version root (`../CHANGELOG.md`, `../RELEASE-NOTES.md`)
  when running from `libexec/tests`.

### Docs

- The Windows wrapper incident reports now use the final 0.6.38 report links and
  include a P1-P6 issue summary for the sandbox, argument forwarding, raw Bash
  bridge, partial-success, Scoop self-upgrade, and installed-layout findings.

### Verified

- Re-ran the focused installed Homebrew incident-report/docs/Windows tests
  before cutting the follow-up release.

## [0.6.37] - 2026-05-08

> **Windows Scoop self-upgrade hotfix.** A real Windows 0.6.36 `sfs.cmd upgrade`
> upgraded Scoop successfully, then `cmd.exe` resumed the replaced batch file at
> an invalid offset and tried to execute tail fragments such as
> `TIVE_READONLY_DONE` and `LF_UPGRADE_DONE`.

### Fixed

- `bin/sfs.cmd` no longer owns Scoop self-upgrade. It handles native read-only
  dispatch, then hands all remaining commands to the packaged PowerShell
  entrypoint.
- `bin/sfs.ps1` remains the owner of `scoop update`, `scoop update sfs`, and
  reloading the updated runtime, avoiding continued execution from the batch
  file that Scoop replaces.

### Docs

- Added Korean and English Windows wrapper incident reports for the 0.6.35 /
  0.6.38 sequence, covering the usage-only regression, empty-output partial
  success risk, Korean mojibake, Homebrew installed docs layout finding, and
  Scoop batch self-replacement failure.
- Linked the incident report from the docs indexes, product-shape pages, GUIDE,
  and release notes.

### Verified

- Added a documentation guard for the Windows wrapper incident report and linked
  docs.

## [0.6.36] - 2026-05-08

> **Installed docs test layout hotfix.** The 0.6.35 Windows wrapper fix shipped
> correctly, but the installed Homebrew runtime exposed that
> `test-docs-model-routing.sh` still assumed `CHANGELOG.md` lived under
> `libexec/`. Homebrew keeps `CHANGELOG.md` at the Cellar version root.

### Fixed

- `tests/test-docs-model-routing.sh` now resolves `CHANGELOG.md` from the
  source/runtime root first, then falls back to the Homebrew Cellar version root
  (`../CHANGELOG.md`) when running from `libexec/tests`.
- The same release-notes path resolution now supports source and installed
  layouts consistently.
- User-facing docs are refreshed to `0.6.36` while keeping the 0.6.35 Windows
  wrapper behavior note.

### Verified

- Re-ran focused docs and Windows wrapper tests before cutting the follow-up
  release.

## [0.6.35] - 2026-05-07

> **Windows wrapper bridge hotfix.** A Windows Scoop install could still show
> generic usage for `sfs.cmd status` / `sfs.cmd context cat ...`, and a
> `sfs.cmd start "<Korean goal>"` run from an agent host could leave only the
> sprint pointer/event behind while losing reliable output or UTF-8 text.

### Fixed

- `bin/sfs.ps1` now binds command arguments positionally, falls back to
  PowerShell automatic `$args`, and normalizes accidental `-SfsArgs` array
  shapes so direct `powershell.exe -File sfs.ps1 status` and
  `context cat kernel` cannot degrade to generic usage.
- `bin/sfs.cmd` now routes non-native commands through the packaged PowerShell
  bridge instead of forwarding raw `%*` directly into Git Bash. PowerShell owns
  the Unicode-safe argument array, then invokes the Bash SFS runtime.
- The PowerShell bridge now sets UTF-8 console/native-command encoding and a
  UTF-8 Git Bash locale when the host has not already chosen one.
- The Windows adapter fallback test now locks the PowerShell bridge contract
  and, on Windows runners, executes the exact `powershell.exe -File ... context
  cat kernel` / `status` shapes that regressed.

### Verified

- Re-ran the Windows adapter fallback guard locally; Windows runtime execution
  is also covered by the optional `powershell.exe` branch when the test runs on
  a Windows host.

## [0.6.34] - 2026-05-07

> **Default facilitator model routing.** SFS now applies role-based model
> routing by default instead of asking the user to configure it. Question
> generation is separated from product-direction review, with Codex mapped to
> `gpt-5.4-mini` for helper-grade intake, `gpt-5.4` for facilitator/question
> work, `gpt-5.5` xhigh for top-model advisor review, `gpt-5.3-codex` for fixed
> implementation slices, and `gpt-5.3-codex-spark` for bounded mechanical
> helpers.

### Fixed

- New projects now default to `solon_recommended` role routing; `current_model`
  is an explicit opt-out instead of the implicit fallback.
- Upgrade now repairs missing or legacy fallback model profiles to the default
  recommended role routing without requiring a user prompt.
- Added `intake_economy` and `facilitator_standard` tiers to
  `model-profiles.yaml`.
- Helper-grade simple I/O remains advisor-exempt, while lower-model outputs
  that frame questions/options, interpret answers, or affect brainstorm/plan/gate
  artifacts require top-model advisor review before gate advancement.
- Advisor calls no longer substitute for self-CPO. Before external/cross review,
  the author must record self-CPO pass/partial/fail evidence covering
  requirements-to-AC-to-slice-to-ADR traceability, AC-to-file/artifact/evidence
  mapping, and SEED/placeholder/mock/fallback non-acceptance.
- Named review executors now run a tiny bridge probe before the full CPO prompt.
  If Claude/Codex/Gemini cannot return the marker within the bounded probe
  timeout, SFS fails before spending the full review request and points the user
  at `/sfs auth probe` or an explicit `SFS_REVIEW_<EXECUTOR>_CMD` path.
- The default Claude review bridge now uses the known-good prompt-argument
  shape `claude -p "$(cat)"` instead of the brittle
  `claude -p --dangerously-skip-permissions` stdin bridge.
- Gemini routing now names the allowed 3.x targets explicitly:
  `gemini-3.1-pro-preview` for facilitator/advisor/review routes and
  `gemini-3-flash-preview` for helper-grade fallback. 3.x 미만 fallback names are
  not used.
- Claude/Codex/Gemini adapter surfaces and user docs now describe the same
  default model map and advisor rule.

### Verified

- Expanded agent guardrail and docs model routing tests to assert default
  `solon_recommended` routing, Codex `gpt-5.4-mini`/`gpt-5.4` facilitator
  mapping, top-model advisor review, and self-CPO-before-cross-review evidence.

## [0.6.33] - 2026-05-07

> **SFS adapter language hygiene hotfix.** Claude could render missing-argument
> prompts for `sfs start` as mixed Korean/English UI copy, including app
> placeholder labels such as `Other` and `Type something`. SFS now treats
> taxonomy/native-language hygiene as a product-function contract across the
> kernel and Claude, Codex, and Gemini adapter surfaces.

### Fixed

- SFS runtime kernel now forbids machine-translating command/domain terms into
  mixed phrases and forbids exposing app placeholder labels as product choices.
- Claude, Codex, and Gemini project/global adapter templates now require one
  plain-language question in the user's language when a command argument is
  missing instead of opening a multi-choice prompt.
- Korean `sfs start` guidance now gives a concrete one-line goal prompt:
  `이번 sprint 목표를 한 줄로 말해 주세요. 예: "docker compose 구조 리디자인"`.
- The taxonomy rule is explicit that taxonomy is a product function, not an org
  division or copy polish.

### Verified

- Expanded the agent behavior guardrail test to assert the taxonomy/language
  contract across the kernel and every Claude/Codex/Gemini adapter surface.
- Re-ran focused adapter tests, Windows fallback tests, docs routing tests,
  whitespace checks, and the full `tests/run-all.sh` suite before release.

## [0.6.32] - 2026-05-07

> **Windows CMD top-level argument forwarding hotfix.** The 0.6.31 fix still
> captured arguments inside the `:maybe_native_readonly` batch subroutine.
> Windows CMD can route into the PowerShell native read-only branch while leaving
> that subroutine `%*` expansion empty, so `sfs.ps1` received no arguments and
> printed generic usage for `sfs.cmd status` / `sfs.cmd version --check`.

### Fixed

- `bin/sfs.cmd` now captures the original command arguments at top-level before
  any `call :label` subroutine dispatch.
- Native read-only dispatch now forwards the top-level captured argument string
  to PowerShell, while self-upgrade reload and the final Git Bash fallback keep
  the pre-0.6 raw `%*` forwarding behavior.
- The Windows fallback guard now asserts top-level argument capture and
  PowerShell forwarding through `SFS_ORIGINAL_ARGS`.

### Verified

- Re-ran the Windows adapter fallback, agent guardrail, docs routing, and full
  `tests/run-all.sh` suite before release.

## [0.6.31] - 2026-05-07

> **Windows native read-only argument forwarding hotfix.** The 0.6.30 Windows
> wrapper correctly routed `status`, `version`, and `context` away from Git
> Bash, but it invoked PowerShell after a batch subroutine jump using `%*`.
> In Windows batch execution that can lose the original command arguments, so
> `sfs.cmd status` and `sfs.cmd version --check` printed generic usage instead
> of executing the requested native read-only command.

### Fixed

- `bin/sfs.cmd` now captures the original native read-only argument string before
  dispatch and forwards that captured value into `sfs.ps1`.
- The Windows fallback guard test now locks both argument capture and argument
  forwarding so `status`, `version --check`, and `context cat ...` cannot
  silently degrade to help output again.

### Verified

- Re-ran the Windows agent adapter fallback test and focused agent/doc routing
  tests.

## [0.6.30] - 2026-05-07

> **Windows Codex app native read-only hotfix.** Windows PowerShell could run
> SFS successfully, but Codex launched from Git Bash or the Windows Codex app
> could still fail when adapter recovery tried `sfs.cmd status` or
> `sfs.cmd context path ...`: those commands still entered Git Bash after the
> wrapper layer.

### Fixed

- `bin/sfs.cmd` now routes `status`, `version`, and `context path/cat` through
  the packaged PowerShell entrypoint before probing Git Bash.
- `bin/sfs.ps1` now has native read-only implementations for `status`,
  `version`, and `context path/cat`, so Windows agents can read SFS state and
  routed context without starting Git Bash.
- Claude, Gemini, and Codex adapters now prefer `sfs.cmd context cat ...` for
  Windows read-only context loading and explicitly tell users to run mutating
  commands in PowerShell/cmd when the agent runner cannot launch Git Bash.
- Beginner and main guides now document the Windows native read-only fallback
  for Codex/Claude/Gemini sandbox failures.

### Verified

- Expanded `tests/test-windows-agent-adapter-fallback.sh` to lock the native
  `status`/`version`/`context` wrapper contract and adapter guidance.

## [0.6.29] - 2026-05-07

> **Windows agent command hotfix.** Windows Claude, Gemini, and Codex adapter
> surfaces could route SFS commands through Git Bash inside a sandbox that fails
> before SFS starts with
> `couldn't create signal pipe, Win32 error 5`. Some retries then reported
> `exit 0` with empty stdout/stderr as success even though no SFS artifact was
> created.

### Fixed

- `bin/sfs.cmd` now serves read-only `--help` and `guide` output before probing
  Git Bash, so PowerShell/cmd users and Windows agent sanity checks have a
  native fallback path.
- Claude, Gemini, and Codex SFS adapter templates now route Windows
  PowerShell/cmd execution through `sfs.cmd ...`, document the Git Bash
  signal-pipe failure, and forbid treating empty adapter output as success.
- `start` handling in agent guidance now requires `.sfs-local/current-sprint`
  and the sprint directory to exist before reporting success.
- Beginner and main guides now include the Windows agent recovery path and the
  empty-output guardrail.

### Verified

- Added `tests/test-windows-agent-adapter-fallback.sh` to lock the wrapper and
  Claude/Gemini/Codex guidance contract.
- Ran focused Windows fallback, agent behavior, docs routing, Scoop manifest,
  and whitespace checks.

## [0.6.28] - 2026-05-07

> **Installed native-language test layout hotfix.** Homebrew keeps `README.md`
> at the Cellar root while runtime tests execute from `libexec`, so the new
> native-language commit message guard test needed the same installed-layout
> fallback as the model-routing docs test.

### Fixed

- `tests/test-native-language-commit-messages.sh` now resolves `README.md` from
  the source root or the Homebrew Cellar root fallback.

### Verified

- Re-ran the native-language commit message test in source and installed
  Homebrew layout.

## [0.6.27] - 2026-05-07

> **Native-language commit messages.** SFS now tells agents to write commit
> messages in the user's native or workspace language by default, instead of
> silently falling back to English.

### Changed

- Added native/workspace-language commit message guidance to implement and
  review contexts, including multi-agent lane commit units.
- Updated Claude, Codex, Gemini, plugin, and command adapter templates so
  future agent sessions inherit the same rule.
- Changed install, upgrade, and uninstall completion examples from English
  `chore:` messages to Korean examples when the surrounding UX is Korean.
- Updated user docs to explain that English commit messages are correct only
  when English is the user/repo language or the repo explicitly requires them.

### Verified

- Added guardrail coverage for native-language commit messages across context,
  adapters, docs, and installer prompts.

## [0.6.26] - 2026-05-07

> **Design-system anti-AI-slop guardrails.** The design/frontend division now
> treats `design.md` as an AI-readable design-system contract and reviews token
> drift as evidence, not taste-only commentary.

### Added

- Added `design.md` / `docs/solon/design.md` governance to the design/frontend
  knowledge pack in English and Korean.
- Added anti-AI-slop review criteria: arbitrary colors, type sizes, spacing,
  radius, shadows, icon weights, generic SaaS visual language, and screen-level
  token drift.
- Added Korean product starter guidance for design-system seeds: small token
  menus, coherent icon family, Korean-capable font, line-height checks, and
  `letter-spacing: 0` by default.
- Updated implement/review contexts so visible UI work reads the design
  contract before editing and checks token drift after editing.
- Updated 10x value docs so multi-agent implement and design-system governance
  are framed as AI-era leverage, not side features.

### Verified

- Added guardrail coverage for `design.md`, anti-AI-slop criteria, token drift,
  Korean typography, and 10x value documentation.

## [0.6.25] - 2026-05-07

> **Optional multi-agent implement lane.** Users who operate Codex, Claude,
> Gemini, or other agents together can now choose a parallel implementation mode
> without making it the default path.

### Added

- `sfs implement --agent-mode parallel --agents codex,claude[,gemini] ...`
  records an explicit multi-agent execution contract in `implement.md`.
- Default `sfs implement` output now advertises Single Agent as the default and
  shows the optional parallel command before coding begins.
- Parallel implement mode requires disjoint files_scope, lane-level
  verification, a one-sentence proposed commit message per lane, and agent cross
  review before Gate 6 can pass.
- All implementation modes now print the mandatory next review handoff:
  `sfs review --gate 6`.

### Verified

- Added CLI and guardrail tests for default Single Agent mode, optional parallel
  mode, invalid parallel splits, post-implement review handoff, and multi-agent
  cross-review requirements.

## [0.6.24] - 2026-05-07

> **Installed docs test layout hotfix.** Homebrew installs the main README at
> the Cellar root while runtime files live under `libexec`, so the new docs
> routing test passed in source but failed when run from the installed package.

### Fixed

- `tests/test-docs-model-routing.sh` now resolves `README.md` from the source
  root or the Homebrew Cellar root fallback.

### Verified

- Re-ran the docs model routing test in source and against the installed
  Homebrew package layout.

## [0.6.23] - 2026-05-07

> **Model routing docs refresh.** After the Codex worker model routing hotfix,
> user-facing docs still had stale 0.6.17 framing and did not clearly explain
> the Codex worker versus Spark helper boundary.

### Changed

- Updated README, GUIDE, BEGINNER-GUIDE, Korean docs, and English docs to the
  current 0.6.23 documentation surface.
- Added user-facing model routing explanation: C-Level/review high reasoning,
  Claude worker Sonnet tier, Codex worker `gpt-5.3-codex`, and Spark helper-only.
- Documented escalation triggers for architecture, public contracts, security,
  privacy, data-loss risk, release gates, and repeated review failure.

### Verified

- Added a docs guardrail test so key user docs mention the Codex worker model,
  Spark helper boundary, and escalation triggers, while stale 0.6.17 doc claims
  stay out of the current user documentation set.

## [0.6.22] - 2026-05-07

> **Codex worker model routing hotfix.** Real model handoff discussion showed
> that Codex still looked like it might use the C-Level model for implementation
> by default, or use the Spark model too broadly.

### Fixed

- Codex `execution_standard` now resolves to `gpt-5.3-codex` in the Solon
  recommended profile.
- Codex `helper_economy` now resolves to `gpt-5.3-codex-spark`, with explicit
  helper-only boundaries.
- Spark is reserved for bounded mechanical subtasks after C-Level has locked
  scope, files_scope, and acceptance criteria.
- Complex implementation slices that touch architecture, public contracts,
  security, privacy, data-loss risk, release gates, or repeated review failure
  escalate to strategic high reasoning before coding.

### Verified

- Expanded agent behavior guardrails so packaged model profiles, routed
  context, and all Claude/Codex/Gemini adapters preserve the Codex worker
  default and Spark boundary.

## [0.6.21] - 2026-05-07

> **Self-before-cross review hotfix.** Real Gate 3 planning showed an Action
> Rail could still ask whether to implement after many review rounds even when
> the review outcome had not passed. That weakens Goal-Driven Execution.

### Fixed

- Gate 3 review guidance now requires self-review to PASS before cross review.
- Cross review is independent confirmation after self-review, not a replacement
  for it.
- Any self or cross partial/fail routes back to plan rework and same-gate
  self-review before cross review or implementation can be offered again.
- Review volume, lens count, advisor count, or "enough review" no longer count
  as implementation readiness.

### Verified

- Expanded agent behavior guardrails so packaged context and adapters preserve
  self-before-cross, pass-before-advance, and no-round-count-as-pass rules.
- Extended the plan-review preflight test so an older PASS followed by a later
  partial still blocks `sfs implement`.

## [0.6.20] - 2026-05-06

> **Review lens convergence hotfix.** Real Gate 3 review loops showed that
> `--lens auto` could choose `docs` on one run and `design` on the next because
> it re-inferred the lens from updated sprint artifacts every time.

### Fixed

- `sfs review --lens auto` now reuses the previous lens for the same sprint and
  gate once a review lane has been established.
- The source is recorded as `auto-locked` when a later auto review reuses the
  prior lens.
- Explicit `--lens <name>` still overrides the lane when the user intentionally
  changes review scope.

### Verified

- Added a regression test where the first Gate 3 auto review chooses `docs`,
  the plan text later changes to design/UX signals, and the second auto review
  remains locked on `docs`.

## [0.6.19] - 2026-05-06

> **Plan review and worker split hotfix.** Real Gate 3 usage showed that a
> ready-for-implement report could still ask the user to choose between
> C-Level direct implementation and generator delegation, and could skip the
> plan-review gate entirely.

### Fixed

- `sfs implement` now requires a passing Gate 3 Plan review
  (`sfs review --gate 3`) before it opens the implementation artifact.
- Added an explicit `--allow-unreviewed-plan` escape hatch for true user-waived
  exceptions; the waiver is recorded in `events.jsonl`.
- Strengthened kernel, plan, implement, review, personas, model profiles, and
  adapter templates so C-Level owns intent/contract/review orchestration while
  worker/generator owns fixed implementation slices.
- Updated Action Rail guidance so a ready Gate 3 plan points to plan review
  first, not implementation/model-choice options.

### Verified

- Added `tests/test-sfs-implement-plan-review-preflight.sh` for blocked,
  waived, and passing-review paths.
- Expanded `tests/test-agent-behavior-guardrails.sh` to keep plan-review and
  C-Level/worker split guidance in packaged context and adapters.

## [0.6.18] - 2026-05-06

> **Friendly UX contract hotfix.** Real planning feedback showed that an Action
> Rail could still frame user-facing validation as "UI warning + server 4xx",
> which is technically safe but cold and unhelpful for a real user.

### Changed

- Added a repair-first validation rule to the design/frontend knowledge pack:
  field-level location, friendly coaching copy, direct recovery action, and
  server 4xx only as the final safety net.
- Added implement-context guidance that visible UX validation needs an explicit
  S0 repair contract before coding; warning/blocking alone is not a complete
  UX.
- Synchronized the active repo context and product template context so current
  and newly installed Solon projects see the same guidance.

### Verified

- Added `tests/test-friendly-ux-contract.sh` so the repair-first UX contract
  cannot silently disappear from packaged context.
- `bash tests/test-friendly-ux-contract.sh` passed.

## [0.6.17] - 2026-05-06

> **Retro close guidance hotfix.** Real use showed that the review prompt still
> told passing reviews to run `/sfs report` and then `/sfs retro`, even though
> `retro` already ensures `report.md` as part of the normal close flow.

### Fixed

- Changed the Gate 6 review next-action policy so PASS names `/sfs retro` as
  the normal close path.
- Clarified that `/sfs report` is optional and should be mentioned only for a
  report preview or past-report rebuild without closing the sprint.
- Updated tidy/review context so agents do not recommend `report` before
  `retro` in the normal Gate 7 path.

### Verified

- Added a guardrail test that fails if the stale "`/sfs report` then
  `/sfs retro`" wording returns.
- `bash tests/test-agent-behavior-guardrails.sh` passed.

## [0.6.16] - 2026-05-06

> **Decision report clarity hotfix.** Real Gate 3 usage showed that compact
> dashboard reports could compress unresolved scope choices into labels such as
> `Q1` without enough user-facing context. That made the final confirmation
> harder to understand even for a developer.

### Changed

- Added a report-surface guardrail that decision questions must be
  self-contained: before any `Q1`, `D1`, or option id, the report must explain
  what is being decided, why it matters, the recommended default, and what each
  option changes.
- Strengthened Gate 3 plan context so draft plans with scope questions end with
  a short decision-needed paragraph instead of an unexplained id.
- Updated the Solon Status Report SSoT from v0.6.10 to v0.6.16 to preserve the
  compact dashboard shape while requiring clear decision briefs.

### Verified

- Added guardrail test coverage across kernel, Gate 3 plan context, and all
  Claude/Gemini/Codex adapter templates.
- `bash tests/test-agent-behavior-guardrails.sh` passed.

## [0.6.15] - 2026-05-06

> **Release notes packaging hotfix.** 0.6.14 updated the dev release notes, but
> the owner release cutter did not sync `RELEASE-NOTES.md` into the stable
> product repo. Stable packages could therefore ship stale user-facing release
> notes even while README, GUIDE, CHANGELOG, Homebrew, and Scoop were current.

### Fixed

- Added `RELEASE-NOTES.md` to the `cut-release.sh` allowlist so stable tags,
  Homebrew archives, and Scoop archives carry the same user-facing notes as dev.
- Added a release tooling regression check that fails if `RELEASE-NOTES.md` is
  omitted from the allowlist again.

### Verified

- Confirmed dev, stable, and installed package docs carry current 0.6.15 release
  notes after the hotfix release.

## [0.6.14] - 2026-05-06

> **Review lens alias hotfix.** Real use showed that agents may naturally pass
> division ids such as `strategy-pm` to `sfs review --lens`, while the CLI only
> accepted the shorter public lens names. SFS now accepts those common aliases
> and records the normalized public lens name.

### Fixed

- **Strategy/PM alias** — `sfs review --lens strategy-pm` and
  `--lens strategy_pm` now normalize to the public `strategy` lens.
- **Division alias bridge** — `design/frontend` maps to `design`, `infra` maps
  to `ops`, and finance/accounting aliases map to `management-admin`.
- **Management/admin lens** — `management-admin` is now a first-class review
  lens with finance/admin evidence guidance.
- **Invalid lens hint** — unknown lens errors now show the accepted alias
  mappings so agents can recover without starting a long executor run.

### Verified

- Added `tests/test-review-lens-aliases.sh` to exercise alias normalization and
  invalid-lens hinting through the real CLI.
- `bash tests/run-all.sh` passed with PASS 39 / FAIL 0.

## [0.6.13] - 2026-05-06

> **Thin multi-agent supervision release.** Solon now keeps the useful parts of
> Claude/Codex/Gemini team workflows without making every project carry a heavy
> supervisor system. Research, implementation, and review stay separated by
> role, but the durable project surface remains compact.

### Added

- **Researcher persona** — added a read-only `researcher` persona for broad
  codebase, domain, library, and migration mapping. The persona records compact
  findings and does not edit production files, approve quality, or rewrite the
  plan.
- **Research model tier** — added `research_high` to `model-profiles.yaml`, with
  Gemini-friendly defaults for large-context research while preserving Codex for
  independent review and existing executor choices for implementation.

### Changed

- **Thin supervision context** — kernel, brainstorm, plan, implement, and review
  context now describe multi-agent work as optional thin supervision: read-only
  research first, fixed-scope worker slices when needed, and independent review
  before risky implementation.
- **Workbench memory guidance** — routed context now prefers compact workbench
  notes and `docs/solon/domain-map.md` for durable domain terms instead of
  copying full agent transcripts into the project.
- **User docs** — Korean and English guides now explain when Claude, Codex, and
  Gemini teamwork is useful, and when a single-agent flow is still the cleaner
  choice.

### Verified

- Added guardrail coverage for researcher persona, research tier, domain-map
  usage, plan review gating, thin supervision wording, fixed worker scope, and
  self-validation review risk.
- `bash tests/run-all.sh` passed before release preparation.

## [0.6.12] - 2026-05-06

> **Agent behavior guardrail release.** Solon now absorbs the useful parts of
> the Claude/Codex "Karpathy-style" coding discipline without copying long
> instruction files into every adapter. The durable rules live in SFS kernel and
> routed command context; adapters only point agents back to that thin source.

### Changed

- **Kernel guardrails** — SFS now tells agents to surface material assumptions,
  prefer the minimum useful slice, avoid speculative flexibility and adjacent
  cleanup, read actual files/errors before fixing, verify before completion,
  and report exact evidence.
- **Plan/implement/review alignment** — `plan.md`, `implement.md`, and
  `review.md` context now carry phase-specific checks for explicit non-goals,
  `verify by ...` evidence, surgical changes, dirty worktree respect, full
  error/log reading, overengineering review, and final verification evidence.
- **SFS-shaped notes policy** — checklist/context-note guidance now maps to
  current sprint workbench artifacts instead of forcing root-level
  `checklist.md` / `context-notes.md` files that would fight minimal-residue
  project surfaces.
- **Korean project ergonomics** — kernel guidance covers Korean sentence-ending
  style and Korean-first source-file role headers without making adapter files
  heavy.
- **Adapter hints refreshed** — Claude, Codex, Gemini, project-scoped skills,
  plugin commands, and legacy prompt surfaces all point implementation/review
  work back to the routed guardrails.
- **Homebrew fallback docs** — README, GUIDE, and BEGINNER-GUIDE now state that
  Mac users can run `brew upgrade MJ-0701/solon-product/sfs` before
  `sfs upgrade` when the `sfs` runtime itself is stale or self-upgrade cannot
  complete.
- **Stable test parity** — dev staging now carries the release-channel guards
  for deprecated external CLI flags and macOS bash 3.2 empty-array expansion;
  the suffixless release test now skips gracefully in packaged trees where
  owner-side release scripts are intentionally absent.
- **Homebrew audit cleanup** — packaged formula no longer emits an explicit
  `version` line when the same version is already inferable from the GitHub tag
  URL, matching `brew audit --strict --online` expectations.

### Verified

- Added `tests/test-agent-behavior-guardrails.sh` to lock the guardrails into
  kernel, plan, implement, review, and adapter surfaces.
- Added `tests/test-no-deprecated-cli-flags.sh` and
  `tests/test-nounset-empty-array-expansion.sh` to keep release tooling and
  bash 3.2 compatibility checks in dev before stable cut.

## [0.6.11] - 2026-05-06

> **Minimal residue release.** Solon now applies "남겨야 될 것만 남긴다" across
> the project lifecycle, not just as a gitignore rule. The default surface is
> private, lazy, and compact: nothing gets created before it is useful, and
> shared output goes to `docs/solon/<english-workspace>/<yyyyMMdd>/`.

### Changed

- **Private-by-default state** — installed `.gitignore` now ignores `.sfs-local/`
  as private workbench state. Teams can opt into a different sharing policy
  outside the managed marker block.
- **Lazy sprint artifacts** — `sfs start` no longer creates blank
  `brainstorm/plan/implement/log/review/retro` files. Each phase command creates
  only the document it actually needs.
- **Adopt writes shared summary only** — `sfs adopt --apply` now creates
  `docs/solon/<english-workspace>/<yyyyMMdd>/handoff.md` and keeps raw scan/cold archive evidence
  under `.sfs-local/archives/adopt/...`. It no longer leaves a fake active
  baseline sprint.
- **Same-version residue migration** — rerunning `sfs upgrade` now converts older
  visible `legacy-baseline` sprint folders into `docs/solon/<english-workspace>/<yyyyMMdd>/handoff.md`
  plus a private cold archive, and packs old pre-created step docs for sprints
  with no phase events.
- **Lean generated templates** — sprint templates were reduced to working
  fields only and localized for Korean owner-facing use.
- **Install/upgrade surface** — new installs no longer pre-create empty
  `sprints/`, `decisions/`, or `queue/` directories. Upgrade prunes empty legacy
  `.gitkeep` placeholders without touching real user data.

### Verified

- Added `tests/test-sfs-start-lazy-artifacts.sh` for init/start/brainstorm
  residue behavior and goal propagation.
- Updated `tests/test-sfs-adopt-freeform.sh` for the `docs/solon` shared summary
  contract and no active sprint pointer after adoption.
- Added `tests/test-sfs-upgrade-minimal-residue-migration.sh` for same-version
  upgrade cleanup of legacy adoption and old prefilled step-doc residue.

## [0.6.10] - 2026-05-05

> **Report surface hotfix.** 0.6.9 made the command surface usable again, but
> dogfood showed the visible Solon report UI had become too flat after bkit
> footer removal. The output was clean, but it looked like a bland bullet dump
> instead of a product console.

### Changed

- **Solon report surface rule** — Claude/Gemini/Codex adapter instructions now
  require compact console-dashboard shape: title/verdict strip, 2-4 labeled
  status panels, one action rail, and at most 1-3 questions.
- **Project templates aligned** — `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`,
  `SFS.md`, Claude plugin command, Gemini command, and Codex skill template all
  carry the same report-surface rule.
- **Internal status report spec refreshed** — the user-local
  `solon-status-report.md` spec moved from flat topic lines to a dashboard
  layout with header, panels, action rail, questions, and sources.

### Verified

- Static syntax/manifest checks only; this release changes agent-facing
  instructions and version metadata, not runtime bash behavior.

## [0.6.9] - 2026-05-05

> **Usability hotfix.** 0.6.8 은 설치는 됐지만 실제 dogfood 에서 두 가지
> "쓸 수 있냐" 문제가 남았다. `sfs context path start/sprint/intake` alias
> 와 `adopt "<brief>"` 자연어 인자 계약이 제품 문서/agent 기대와 어긋났고,
> discovery hook 진단은 user-home write 실패를 성공처럼 보일 수 있었다.
> 본 release 는 로컬 응급 패치로 끝내지 않고 Homebrew/Scoop 사용자가 같은
> 수정본을 받도록 배포 메타데이터까지 맞추는 공개 핫픽스다.

### Fixed

- **`sfs adopt "<brief>"` free-form 인자 허용** — 기존 `adopt` 는 top-level
  명령에 존재하고 가이드에도 있었지만, 위치 인자를 전부 `unknown arg` 로
  처리했다. 이제 `sfs adopt "문서 정리좀 해야될거 같은데."` 같은 기존
  프로젝트 문서 정리/현상 정리 brief 를 dry-run/apply 양쪽에서 받아 report,
  retro, events evidence 에 남긴다.
- **`adopt` routed context 추가** — `sfs context path adopt`,
  `commands/adopt`, `commands/adopt.md` 가 모두 `commands/adopt.md` 로
  해석된다. agent 는 adopt 를 bash-first로 실행한 뒤 compact baseline
  정책만 읽으면 된다.
- **context alias hotfix 정리** — `start`, `commands/start`, `sprint`,
  `intake` alias 가 packaged runtime 과 installed Homebrew runtime 모두에서
  `commands/start.md` 로 해석되도록 고정했다.
- **discovery 진단 truthfulness** — Claude/Gemini/Codex discovery hook 이
  user-home config write 실패를 `ok` 로 보이지 않고 `warn` 으로 보고한다.
- **metadata drift 정리** — `VERSION`, Claude plugin metadata,
  `gemini-extension.json`, README/GUIDE/BEGINNER-GUIDE, packaging 예시를
  0.6.9 기준으로 맞췄다.

### Verified

- Local installed Homebrew runtime patched and dogfood verified:
  `sfs context path adopt` → packaged `commands/adopt.md`,
  `sfs adopt "문서 정리좀 해야될거 같은데."` → dry-run success.
- `tests/test-sfs-adopt-freeform.sh` 추가 — Korean free-form brief dry-run/apply
  round-trip, report/retro/events persistence 검증.
- `tests/test-context-aliases.sh` 보강 — `adopt` alias 와 `commands/adopt(.md)`
  path resolution 검증.

## [0.6.8] - 2026-05-05

> **Hotfix.** 두 가지 함께 정리:
> (a) 0.6.7 의 `.gitattributes` 가 확장자 패턴만 등록하고 extensionless 텍스트
>     (`VERSION`, `bin/sfs`) 를 누락 → Windows 의 `core.autocrlf=true` 가
>     그 둘을 CRLF 로 checkout → `test-hash-parity.sh` FAIL.
> (b) 0.6.6 에서 추가했던 `.github/workflows/macos-bash-3-2-smoke.yml`
>     을 **scope-creep correction 으로 제거**. cascade hotfix 흐름 안에서
>     architectural change 를 hotfix bundle 에 넣은 게 본인의 informed 한
>     OK 가 아니라 momentum 이었고, 결과로 0.6.7/0.6.8 cycle 추가 발생.
>     해당 workflow 가 의도했던 surface (macOS 시스템 bash 3.2) 는 이미
>     사용자 dogfood 가 첫 receipt 로 cover 했고, 추가 CI surface 가 지금
>     시점의 정합 비용 대비 가치가 낮다고 판단.

### Fixed

- **`.gitattributes` extensionless 파일 명시 등록** — `VERSION` 과 `bin/sfs`
  를 `text eol=lf` 로 명시. 양쪽 다 본질적으로 텍스트 (전자는 단일 라인 semver,
  후자는 bash 스크립트) 라 LF 강제가 정합. 같은 맥락으로 `*.cmd` / `*.bat`
  Windows 셸 파일도 `eol=crlf` 로 명시 (이전엔 누락).

### Reverted

- **`.github/workflows/macos-bash-3-2-smoke.yml` 제거 (0.6.6 scope-creep
  correction)** — 본 workflow 는 0.6.6 에서 "cascade root cause 닫는 구조적
  fix" 로 추가됐으나, hotfix bundle 에 architectural CI change 를 묶은 것
  자체가 본인의 informed consent 영역 밖이었음. 결과적으로 그 workflow 가
  처음 돌면서 pre-existing CI red (hash-parity 의 `.gitattributes missing`
  외 3건) 를 surface 시켜 0.6.7 + 0.6.8 cycle 을 만든 부작용도 있었음.
  surface-diversity 원칙 자체는 유효하지만 (사용자 macOS shell 이 receipt #1
  의 catcher 였던 사실 그대로), 그 원칙을 *명시적 CI workflow* 로 강제하는
  비용은 본 시점에 적정하지 않다는 판단으로 되돌림. 필요해지면 별도 sprint
  에서 재논의.

### Process learning

이번 cycle 에서 굳히는 것 두 가지:

1. **Hotfix bundle 의 경계를 더 명확히**. "구조적 fix" 라는 framing 으로
   CI workflow 추가 같은 architectural change 를 hotfix 와 같이 ship 하는
   건 옳지 않음. cascade 가 도는 시점일수록 변경 surface 를 작게 유지해야
   다음 layer 를 만들지 않음. 본 release 의 reverted 항목이 그 evidence.
2. **`.gitattributes` 같은 cross-platform 정합 surface 는 첫 도입 시 한
   번에 완전히**. 확장자 패턴 + extensionless 명시 + Windows 셸 (`*.cmd` /
   `*.bat`) 모두 같은 commit 에 들어가는 게 정석. 0.6.7 → 0.6.8 의 두
   layer 가 그 누락의 receipt.

cross-review-principle 문서의 Receipts 섹션에 본 cycle 을 추가 layer 로
박는 건 별도 정리 (현 시점엔 doc 변경 안 함 — release 사이즈 작게).

### Verified

- `tests/run-all.sh` (Linux sandbox) → 33/33 PASS · FAIL 0
- 기존 회귀 테스트 4 개 (`test-nounset-empty-array-expansion`,
  `test-no-deprecated-cli-flags`, `test-homebrew-formula-style`,
  `test-hash-parity`) 모두 PASS
- Windows 결과는 0.6.8 push 후 `SFS 0.6 Storage Matrix` 의 `hash-parity-windows`
  가 GREEN 으로 나와야 정상 — `.gitattributes` extensionless 보강의 직접 검증.

## [0.6.7] - 2026-05-05

> **Hotfix.** 0.6.6 의 새 macOS bash 3.2 CI workflow 가 `tests/run-all.sh`
> 실행 중 4 건 fail (`test-hash-parity`, `test-release-suffixless-hard-cut`,
> `test-sfs-archive-branch-sync`, `test-sfs-migrate-quoted-paths`). 모두
> **0.6.1 cascade 와 무관한 pre-existing 실패** 였고, 0.6.4 이후 PR Check 가
> 빨개진 상태로 가려져 있다가 0.6.6 의 macOS smoke 가 처음으로 노출시킴.
> 본 release 에서 4 건 다 닫는다. 이걸로 `tests/run-all.sh` 가 33/33 PASS.

### Fixed

- **`.gitattributes` 복원** — `test-hash-parity.sh` 가 require 하는
  `.gitattributes` 파일이 stable mirror repo 에 부재. 7 ext (`yml/yaml/md/
  jsonl/json/toml/txt`) + `sh/rb/bash` 에 LF 강제, `ps1` 는 CRLF, 흔한
  바이너리는 normalize 안 함. cross-platform sha256 parity 복구.
- **`scripts/sfs-migrate-artifacts.sh::sha256_of()` backslash escape 우회** —
  GNU coreutils `sha256sum 'back\slash.md'` 는 hash 앞에 `\` 를 prefix 로
  붙이고 파일명의 `\` 를 `\\` 로 escape 한 출력 (`\<hash>  back\\slash.md`)
  을 emit. 기존 `sha256sum "${f}" | awk '{print $1}'` 가 `\<hash>` 를 그대로
  캡쳐해서 `verify_no_data_loss` 가 mismatch 로 처리. **Fix**: filename 인자
  대신 stdin form (`< "${f}"`) 으로 sha256sum 호출 — filename 이 출력
  포맷터에 닿지 않음. 같은 fix 가 `shasum -a 256 < "${f}"` 분기에도 적용.
- **`tests/test-sfs-archive-branch-sync.sh` race-lock setup 정정** — 기존
  테스트가 `.archive-sync.lock` 에 PID 만 적어두고 스크립트가 그걸 detect
  할 거라 가정. 그러나 `sfs-archive-branch-sync.sh` 는 flock(1) 가용 시
  flock 으로 lock acquire 하고 파일 내용은 안 읽는 path. Linux runner 는
  항상 flock 가 있어서 두 번째 invocation 이 lock 을 fresh 로 가져가버려
  "graceful exit" 메시지 안 나옴. **Fix**: 테스트가 자기 셸에서 `exec 8>...
  ; flock -n 8` 으로 진짜 flock 을 잡은 채로 스크립트 호출 → 스크립트의
  flock fail → "graceful exit" 메시지 emit. flock 미가용 시 (macOS without
  brew flock 등) 기존 PID-write fallback path 그대로.
- **`tests/test-release-suffixless-hard-cut.sh` stable-mirror skip** —
  본 테스트가 `${REPO_ROOT}/scripts/cut-release.sh` 와 `verify-product-release.sh`
  를 require 하는데, 이 둘은 dev staging 전용 (`<private-dev-staging>/...`)
  이라 stable mirror 에는 의도적으로 부재. 기존엔 `missing: ...` 로 즉시
  exit 1. **Fix**: 둘 다 부재 시 informative SKIP 메시지 + exit 0 로
  graceful pass. AGENTS.md 의 release-cut output mirror 정책과 정합.

### Audit notes — not in scope

`tests/run-all.sh` 의 4 fail 정찰 중 install.sh / upgrade.sh 의 model
profile prompt 가 non-TTY 환경에서 hang 가능성을 의심했으나, 실제 코드는
이미 `tty_available()` (install.sh) / `[ ! -t 0 ]` (upgrade.sh) 가드를
가지고 있고 화면 캡쳐 재해석 결과 install 자체는 완료한 것으로 확인.
receipt #5 후보 drop. 추후 같은 클래스 hang 신호가 다시 잡히면 그때
별도 sprint.

### Verified

- `tests/run-all.sh` → **33/33 PASS** (이전 31/33 + 새로 통과한 archive-
  branch-sync, migrate-quoted-paths). 0.6.6 의 macOS bash 3.2 CI workflow
  도 다음 push 부터 같은 결과를 얻어야 정상.
- 기존 회귀 테스트 3 개 (`test-nounset-empty-array-expansion`,
  `test-no-deprecated-cli-flags`, `test-homebrew-formula-style`) 모두
  PASS — 0.6.2~0.6.5 cascade fix 들 무회귀 확인.

## [0.6.6] - 2026-05-05

> **Structural fix release — cascade 종결.** 0.6.1 → 0.6.5 의 4 receipts cascade
> 가 보여준 두 root cause (CI 의 macOS 시스템 bash 3.2 surface 부재, 외부 CLI
> deprecation 을 사후가 아니라 사전 단계 안으로 끌어오지 못한 release flow)
> 를 직접 닫는다. 본 release 부터는 같은 클래스의 다음 layer 가 ship 전에
> CI 에서 잡힌다. 자세한 분석은
> [docs/ko/cross-review-principle.md](docs/ko/cross-review-principle.md)
> ([English](docs/en/cross-review-principle.md)) Receipts 섹션.

### Added

- **`.github/workflows/macos-bash-3-2-smoke.yml`** — macOS system bash 3.2
  surface 를 명시적으로 cover 하는 새 CI workflow. `runs-on: macos-latest`
  + `shell: /bin/bash {0}` 조합으로 (= brew bash 5.x 가 아니라 시스템 bash
  3.2 강제) 회귀 테스트 3 개 + `tests/run-all.sh` + `bin/sfs upgrade
  --no-self-upgrade --skip-existing --layout thin` smoke check 를 실행.
  bash 3.2 nounset/empty-array 클래스의 다음 회귀가 ship 전에 잡힘.
  - 워크플로 시작 부분에서 `/bin/bash --version` 출력으로 3.x 임을 sanity
    check. 미래에 GitHub 가 macos-latest runner 의 시스템 bash 를 4+ 로
    업그레이드하면 이 sanity check 가 fail 해서 surface 가 다시 단일화됐다는
    걸 알려줌 (workflow 재구성 신호).
- **`scripts/sfs-release-sequence.sh` `--phase post-audit` 추가** — release
  sequence 에 phase 4. 순서: `tag-push → audit → tap-update → post-audit`.
  `tap-update` 가 dev staging `cut-release.sh` 를 통해 published 된 다음,
  `brew audit --strict --online sfs` 를 *이름 기준* 으로 실행해 path-form
  `brew audit` 이 더 이상 못 돌리는 strict + online 항목 (URL 가용성, license
  체크 등) 까지 cover. brew 미설치 / tap 미설치 시 informative hint + non-
  zero exit (조작자에게 install 을 알림).

### Changed

- **`tap-update` phase 메시지 명확화** — 기존 `tap-update — invoke
  tap-update helper (release tool integration point)` 라는 cryptic 메시지를,
  "이 stub 는 release-cut output mirror 측 marker 이고 실제 tap 갱신은 dev
  staging 의 `scripts/cut-release.sh` 에서 일어난다 + post-audit 으로 이어가는
  방법" 을 명시한 안내문으로 교체. AGENTS.md 의 release flow 와 사용자
  실제 워크플로 사이의 인지 격차 해소.
- **docs/{ko,en}/index.md cross-review-principle 링크 설명 갱신** — 기존
  "0.6.1→0.6.2 hotfix case study" 표현을 "0.6.1 → 0.6.5 cascade 의 4
  receipts" 로 갱신 (실제 receipts 수 반영).

### Process learning (5th release in the cascade — but the first one closing it)

receipts 1~4 가 같은 한 source line 에서 외부 CLI 의 layer 를 한 겹씩
받아냈던 반면, 본 release 는 그 cascade 의 root cause 두 개를 닫는다:

- **CI surface 단일화 → 다양화**: macOS system bash 3.2 가 이제 명시적
  CI surface 가 됨. 같은 클래스의 다음 회귀가 사용자가 아니라 CI 에서 먼저
  울림.
- **Pre-publish 만 하던 audit → post-publish 도 함**: published formula
  name 에 대한 strict + online 검사가 release sequence 의 정식 phase 로
  들어옴. 외부 CLI deprecation 변화는 막을 수 없지만, "release 가 끝났다고
  선언하기 전에 published artifact 를 한 번 더 검증" 하는 단계가 정상화됨.

이걸로 본 cascade 의 재발 trigger 두 개가 닫혔다고 판단. 다음 receipt 가
또 발생하면 그건 새 클래스이지, 같은 cascade 의 연장이 아니다.

### Verified

- 기존 회귀 테스트 3 개 모두 PASS (test-nounset-empty-array-expansion,
  test-no-deprecated-cli-flags, test-homebrew-formula-style).
- 새 CI workflow `macos-bash-3-2-smoke.yml` 의 동작 자체는 GitHub macos-latest
  runner 에서만 검증 가능 — 본 release 의 첫 push 시 CI run 에서 확인.
- `scripts/sfs-release-sequence.sh` 의 `--phase post-audit` 호출은
  brew + 설치된 tap 둘 다 필요하므로 sandbox 에서는 dry-run 만 검증
  (`--dry-run` 출력 정확).

## [0.6.5] - 2026-05-05

> **Hotfix.** 0.6.4 의 audit phase 가 `brew style` 단계에서 9 offenses 로
> 즉시 fail. 그 중 6 개는 진짜 template style 결함 (sigils, frozen literal
> 코멘트, class 문서 코멘트, components order, livecheck regex), 3 개는
> cut-release placeholder sha256 형태 자체에서 발생한 noise. **Receipt #4 —
> 같은 release flow 의 한 source line 에서 외부 CLI 의 다음 layer 가 또
> 떨어진 cascade 의 4번째 evidence.** 자세한 정리는
> [docs/ko/cross-review-principle.md](docs/ko/cross-review-principle.md)
> ([English](docs/en/cross-review-principle.md)) 의 Receipts 섹션.

### Fixed

- **`packaging/homebrew/sfs.rb` + `sfs.rb.template` template style 보강** —
  `brew style` 가 잡은 6 개 진짜 결함 모두 수정:
  - `# typed: false` Sorbet sigil 추가 (Sorbet/StrictSigil + Sorbet/TrueSigil
    cops).
  - `# frozen_string_literal: true` Ruby magic comment 추가
    (Style/FrozenStringLiteralComment cop).
  - `class Sfs < Formula` 위에 YARD class 문서 코멘트 추가
    (Style/Documentation cop).
  - `sfs.rb`: `version` 을 `sha256` 위로 이동 (FormulaAudit/ComponentsOrder
    cop).
  - `sfs.rb`: livecheck regex `\.tar\.gz` → `\.t` 로 broaden
    (FormulaAudit/LivecheckRegexExtension cop — `.tar.gz` 와 `.tgz` 미러
    둘 다 매칭).
- **`scripts/sfs-release-sequence.sh` audit phase: placeholder sha256 감지
  + brew style skip** — formula 가 cut-release 의
  `__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__` 를 들고 있는 상태에서는
  `brew style` 의 sha256 형태 cop 3 개가 noise 로 fail. release-cut 이
  실제 sha256 을 채우기 전까지는 그 3 개를 건너뛰는 것이 정합. 감지 시
  informative 메시지 + `brew style` skip + scoop schema validate 는 그대로
  실행.

### Added

- **`tests/test-homebrew-formula-style.sh`** — formula 와 template 의
  style 결함 회귀 가드. (1) Sorbet sigil 존재, (2) frozen literal comment
  존재, (3) class 문서 comment 존재, (4) `sfs.rb` 의 components order
  (version 이 sha256 위), (5) livecheck regex 에 `\.tar\.gz` 가 박혀있지
  않음, (6) audit phase 의 placeholder skip 로직 존재. `brew` 미설치 호스트
  에서도 정적 grep 으로 검증 가능.

### Process learning (4th receipt for cross-review-principle)

같은 release flow 의 한 audit phase 가 24h 안에 외부 CLI 의 deprecation /
정책 변경 4 개를 연이어 받았다 (`--new-formula` 제거 → `brew audit [path]`
disable → `brew style` 의 cop 검사 항목들). 본 cascade 가 굳히는 결론:

- **외부 CLI 의 검사 surface 자체가 시간에 따라 enrich 된다.** 어제 통과
  하던 동일 코드 / formula 가 오늘 fail 가능. CI 의 brew 미설치 surface
  로는 영원히 못 잡음.
- **사전 dogfood gate (= maintainer macOS 셸에서 한 번 진짜 실행)** 이
  release 의 사전 단계로 박히지 않으면 cascade 는 계속됨. 본 release 들이
  본인의 cascade 인 이유.
- **Post-publish full audit step 추가가 다음 sprint 의 P0 candidate.**
  본 hotfix 는 `--phase audit` 까지만 정합화 — `--phase tap-update` 가
  실제 published formula name 에 대해 `brew audit --strict --online sfs`
  를 호출하도록 phase 4 를 추가하는 건 후속 sprint.

### Verified

- `tests/test-homebrew-formula-style.sh` 단독 PASS.
- 기존 `tests/test-no-deprecated-cli-flags.sh` 단독 PASS (regression
  unaffected).
- 기존 `tests/test-nounset-empty-array-expansion.sh` 단독 PASS.

## [0.6.4] - 2026-05-05

> **Hotfix.** 0.6.3 도 release-sequence audit phase 가 다음 wall 에 부딪힘:
> Homebrew 가 `brew audit [path ...]` 자체를 disable 한 상태 (`Calling \`brew
> audit [path ...]\` is disabled! Use \`brew audit [name ...]\` instead.`).
> 즉 0.6.1 → 0.6.2 → 0.6.3 → 0.6.4 가 **같은 한 source line** 에서 외부 CLI
> 의 서로 다른 deprecation layer 를 한 번에 하나씩 받아낸 cascade. 본 cascade
> 자체가 cross-review-principle 의 강한 evidence — 자세한 정리는
> [docs/ko/cross-review-principle.md](docs/ko/cross-review-principle.md)
> ([English](docs/en/cross-review-principle.md)) 의 Receipts 섹션.

### Fixed

- **`scripts/sfs-release-sequence.sh` audit phase: path-form `brew audit`
  교체** — Homebrew 가 path argument 형태를 disable. `brew audit` 는 이제
  formula NAME 만 받음. 기존 호출 `brew audit --strict --online "${formula}"`
  (path 변수) 는 즉시 fail.
  - **Fix**: 동일 phase 의 path-based pre-publish 체크를 `brew style
    "${formula}"` 로 교체. RuboCop 기반 style/syntax 린트 — 가장 path-friendly
    한 등가물.
  - **Loss**: URL 가용성 / 라이선스 / 라이선스 패리티 등의 strict + online
    체크는 path 기반으로 더 이상 못 돌림. 이건 tap-update 이후 publish 된
    name 에 대해 `brew audit --strict --online sfs` (이름 기준) 으로 돌려야
    함. 본 release 는 그 단계를 doc 에만 남기고 phase 로 넣진 않음 (phase
    재구성은 hotfix 범위 밖).

### Added

- **회귀 테스트 보강** — `tests/test-no-deprecated-cli-flags.sh` 에:
  - `brew audit "${...}"` 처럼 path-like quoted 변수를 인자로 받는 호출 형
    태가 다시 들어오면 fail.
  - 반대로 `brew style ...` 가 audit phase 에 살아 있는지 positive check.
  - 기존 `--new-formula` 검사도 같이 유지하되, **comment 라인은 스킵**
    하도록 룰 보강 — 설명용 주석에서 deprecated flag 이름을 자유롭게 쓸 수
    있게.

### Process learning (3rd receipt for cross-review-principle)

같은 release flow 가 24h 안에 외부 CLI 의 서로 다른 deprecation 3개를
연이어 받아냈다 (`--new-formula` 제거 → path argument 제거 → ...). 이건
"build agent 가 빌드/리뷰 다 통과시켰는데 첫 실사용자가 macOS 위에서
처음 돌릴 때만 wall 이 보인다" 는 명제의 강한 receipt. 권장 follow-up:

- **release-sequence 의 audit phase 를 사전 dogfood gate 로 격상**: CI 가
  아니라 maintainer 의 macOS 셸에서 `--dry-run` + 실제 실행 둘 다 한 번씩
  돌고 PASS 한 evidence 가 release 의 commit message 에 첨부되도록.
- **post-publish full audit step 추가 (별도 sprint candidate)**: tap-update
  이후 published formula name 에 대해 `brew audit --strict --online sfs`
  를 자동 실행. 본 release 에는 포함하지 않음 — phase 재구성이 필요해
  hotfix 범위 밖.

### Verified

- `tests/test-no-deprecated-cli-flags.sh` 단독 PASS (확장된 룰 포함).
- `tests/test-nounset-empty-array-expansion.sh` 단독 PASS (regression
  unaffected).

## [0.6.3] - 2026-05-05

> **Hotfix.** 0.6.2 푸시 직후 사용자가 `bash scripts/sfs-release-sequence.sh
> --phase audit --version 0.6.2` 를 돌리는 순간 Homebrew 가
> `Error: invalid option: --new-formula` 로 거부 → audit phase 실패. 같은
> blind-spot 클래스 (release-time external CLI 가 CI 에서 실행되지 않는
> monocultural test surface) 가 한 번 더 잡혔다. 자세한 분석은
> [docs/ko/cross-review-principle.md](docs/ko/cross-review-principle.md)
> ([English](docs/en/cross-review-principle.md)) 의 0.6.2 case study 와 같은
> 결.

### Fixed

- **`scripts/sfs-release-sequence.sh` audit phase: deprecated Homebrew flag
  교체** — Homebrew 가 release 의 `--new-formula` 옵션을 제거 (이제 `Did
  you mean? formula` 로 reject) 한 상태. 본 release-sequence 의 audit phase
  가 그 옵션에 의존하고 있어 0.6.2 push 직후 실사용자 실행에서 즉시 실패.
  - `brew audit --strict --online` 으로 교체. `--new` 는 일부러 사용하지 않음
    — `--new` 는 "Homebrew core 에 처음 제출되는 formula 자격 심사" 용 추가
    체크를 켜기 때문에 tap-only formula 가 falsely fail 한다.
  - dry-run 출력 메시지도 같이 갱신.

### Added

- **`tests/test-no-deprecated-cli-flags.sh`** — `scripts/` 하위에서 외부
  CLI 의 deprecated flag (현재 등록된 항목: `--new-formula`) 가 재유입되는
  것을 막는 회귀 가드. 예전 release notes 가 그 flag 를 언급하는 건 의도된
  history 라 CHANGELOG 는 스캔 대상에서 제외.

### Process learning (continued from 0.6.2)

- 본 release 는 0.6.2 의 cross-review-principle 문서가 주장한 명제의 두
  번째 receipt 다 — **외부 CLI (Homebrew) 의 사양 변경은 어떤 LLM review
  로도 일관되게 잡히지 않는 환경 차원**. 회피책은:
  - release-sequence 의 `--phase audit` 를 ship-blocking gate 로 두고,
    실사용자가 (CI 가 아니라) macOS 에서 진짜로 한 번 돌려본 결과를 evidence
    로 남기는 것.
  - 외부 CLI 의존도가 있는 step 은 deprecated-flag 회귀 가드 (본 release
    의 새 test) 로 정적 검증 + 런타임 dogfood 둘 다 운영.

### Verified

- `tests/test-no-deprecated-cli-flags.sh` 단독 PASS.
- 기존 `tests/test-nounset-empty-array-expansion.sh` 단독 PASS (regression
  unaffected).

## [0.6.2] - 2026-05-05

> **Hotfix.** 0.6.1 의 `sfs upgrade` (옵션 없이 실행 시) 가 macOS bash 3.2 +
> `set -u` 환경에서 `dep_args[@]: unbound variable` 로 즉시 죽던 회귀를 수정.
> 0.6.2 발견 경로 자체가 Solon cross-review 원칙의 canonical case study —
> 자세한 내용은 [docs/ko/cross-review-principle.md](docs/ko/cross-review-principle.md)
> ([English](docs/en/cross-review-principle.md)) 참조.

### Fixed

- **`sfs upgrade` empty-args crash on macOS bash 3.2** — `bin/sfs` 의
  deprecation hook 이 빈 `dep_args` 배열을 `"${dep_args[@]}"` 로 펼치면서
  bash 3.2 + `set -u` 의 nounset rule 에 걸려 죽던 문제. 0.6.1 release
  pre-verification (`tests/run-all.sh` 30/30, `sfs doctor` 7/0/0) 은 Linux
  bash 5.x 위에서만 돌아 본 클래스를 잡지 못했고, 첫 실사용자
  (`brew install` 직후 `sfs upgrade` 실행) 시점에 Codex review 가 즉시 짚어
  hotfix 로 이어짐.
  - `${arr[@]+"${arr[@]}"}` parameter-expansion default idiom 으로 교체.
    이미 `templates/.sfs-local-template/scripts/sfs-commit.sh` 가 같은 idiom
    을 쓰고 있어 repo style 일치.
- **`/sfs loop` worker spawn empty-flags crash (same class)** — 동일 패턴이
  `templates/.sfs-local-template/scripts/sfs-loop.sh:1482` 에도 있었음.
  `LOOP_DRY_RUN` / `LOOP_NO_MENTAL_COUPLING` 둘 다 미지정 시 `extra_flags`
  가 비어 macOS bash 3.2 에서 같은 unbound variable 로 죽었을 케이스. 동일
  idiom 적용.

### Added

- **`tests/test-nounset-empty-array-expansion.sh`** — 회귀 가드. (1) 두 fix
  사이트의 idiom 정적 검증, (2) `set -u` 아래 빈 배열 expansion 의 런타임
  검증, (3) `sfs upgrade` 호출 후 stderr 에 `dep_args[@]: unbound variable`
  미출현 smoke check.

### Audit notes

다음 사이트들은 같은 패턴 (`<var>=()` + 후행 `"${var[@]}"` + `set -u`) 이지만
호출 경로상 마스터 가드 (`[[ "${#arr[@]}" -eq 0 ]] && exit` 류) 가 막아서
현재 reachable bug 없음. 그러나 스타일 불일치 — 후속 hardening PR 에서
같은 idiom 으로 정리 권장:

- `templates/.sfs-local-template/scripts/sfs-commit.sh` (SELECTED_PATHS 4 사이트)
- `templates/.sfs-local-template/scripts/sfs-adopt.sh` (tar_items, count guard)
- `templates/.sfs-local-template/scripts/sfs-common.sh` (source_paths, count guard)
- `scripts/sfs-measure.sh` (REMAINING, parse_args guard)

### Process learning

- **Cross-review 의 본질은 "다른 모델" 이 아니라 "다른 evaluation surface"
  의 다양성** — 0.6.1 의 build+review 파이프라인은 Codex / Claude / Gemini
  모두 통과시켰지만 셋 다 동일한 CI runtime (Linux bash 5.x) 에서만 돌았다.
  bash 3.2 idiom 호환성은 어떤 모델 review 로도 잡히지 않는 환경 차원이라
  monocultural CI 에서 시스템적 blind spot 이었다. 첫 실사용자 (macOS
  Homebrew + bash 3.2) 가 곧 cross-review 의 마지막 axis 였고, 이를
  ‘process 의 우연’ 이 아니라 ‘design 으로 의도된 cross-review 단계’ 로 박아두는 것이 본
  hotfix 가 남기는 evidence. 자세한 정리는 위의 cross-review-principle 문서.
- **Test matrix 보강**: `tests/run-all.sh` 에 macOS bash 3.2 emulation 또는
  `BASH_COMPAT=3.2` envelope 을 가진 별도 stage 추가는 후속 sprint candidate.

### Verified

- `tests/test-nounset-empty-array-expansion.sh` 단독 PASS (bin/sfs upgrade
  smoke check 포함, stdin closed + timeout-safe).
- 기존 `tests/run-all.sh` 의 실패 4건 (`test-hash-parity`,
  `test-release-suffixless-hard-cut`, `test-sfs-archive-branch-sync`,
  `test-sfs-migrate-quoted-paths`) 은 본 hotfix 와 무관 — 변경 파일 (`bin/sfs`,
  `sfs-loop.sh`) 과 어휘적 / 호출 경로상 교집합 없음. 사용자 macOS 환경에서
  release 전 30/30 재확인 권장.

## [0.6.1] - 2026-05-05

### Changed

- **Knowledge packs filled beyond seed inventory** — official division packs for
  backend, strategy/PM, QA, design/frontend, infra/DevOps, management/admin, and
  taxonomy now provide compact operating guidance, review questions, and
  evidence patterns in both English and Korean. The router and Gate 3/4/6
  command context now describe the packs as scoped guidance, not placeholder
  inventories.
- **Management/admin pack added for solo-founder finance work** — new
  `management-admin-knowledge-pack` covers finance, bookkeeping, tax,
  accounting, invoices, cashflow, payroll/contractor payments, compliance
  evidence, AI-safe financial data boundaries, and advisor escalation.
- **User-facing docs refreshed for 0.6.1** — README, guides, product-shape docs,
  and release notes now describe knowledge packs as practical guidance loaded
  only when relevant, while keeping release notes separate from README.

### Verified

- Pre-release verification passed: placeholder scan found no seed-inventory
  leftovers, active/template context mirror check passed, `git diff --check`
  passed, `sfs doctor` reported pass 7 / warn 0 / fail 0, and
  `tests/run-all.sh` reported 30/30 PASS.
- Package-channel verification is performed after the Homebrew/Scoop cut so the
  installed runtime can be checked against the published `v0.6.1` tag.

## [0.6.0] - 2026-05-04

> **Version naming hard cut: from 0.6.0 onwards no `-product` suffix. Historical 0.5.x-product tags preserved.**
> 0.6.0 implement sprint chunk 1 — R-A scaffold (6 새 script + bin/sfs dispatch + Windows wrapper) +
> R-G version bump (0.5.96-product → 0.6.0). R-B/R-C/R-D/R-E/R-F/R-H/R-I 실 기능 + tests + CI + brew/scoop
> hash 갱신 = 후속 chunk (G6 review 전 까지 누적). 본 entry 는 chunk 1 시점 placeholder, G6 PASS 시 final wording.

### Added

- **6 new bash scripts under `solon-mvp-dist/scripts/`** (R-A AC1.1 — functional skeletons,
  body logic 다음 chunk 에서 R-B/R-C/R-F/R-H spec 따라 채움):
    - `sfs-storage-init.sh` — Layer 1 (`docs/<domain>/<sub>/<feat>/`) + Layer 2 (`.solon/sprints/<S-id>/<feat>/`) path schema 생성/검증.
    - `sfs-storage-precommit.sh` — pre-commit / pre-merge storage validator (co-location + N:M + sprint.yml schema).
    - `sfs-archive-branch-sync.sh` — closed sprint archive branch 자동 sync + flock(1) race 보호.
    - `sfs-sprint-yml-validator.sh` — sprint.yml 8-field schema validator + close mode dispatch (validate / close 통합 — F6).
    - `sfs-migrate-artifacts.sh` — interactive / `--apply` / `--auto` 3 surface + Pass 1/2 + reject + `--rollback` + `--rollback-from-snapshot` + `--print-matrix` + `--backfill-legacy` + `--snapshot-include-all` flags.
    - `sfs-migrate-artifacts-rollback.sh` — git revert + Layer 1 atomic rollback helper (`--commit-sha` / `--from-snapshot`).
- **5 new `bin/sfs` dispatch cases** (R-A AC1.2): `storage` (init / precommit subcommands), `migrate-artifacts`,
  `migrate-artifacts-rollback`, `archive-branch-sync` (alias `archive`), `sprint` (validate / close subcommands).
- Windows wrappers (`bin/sfs.ps1` + `bin/sfs.cmd`) automatically forward all 5 new subcommands to bash `bin/sfs` (R-A AC1.3 — 기존 thin forwarder 구조 정합, Smoke verify = AC4.5 다음 chunk).

### Changed

- **`solon-mvp-dist/VERSION`**: `0.5.96-product` → `0.6.0` (R-G G-1, G-2, AC7.1).
  Suffix `-product` hard-cut from this release onwards.
- **`bin/sfs version`** output remains `sfs <version>` pattern (S2-N3 = α — Round 1 CEO ruling lock).

### Migration notes for 0.5.x consumers

- 0.5.x consumer 는 6 mo grace (until 2026-11-03) 동안 deprecation warning 만 받음. 자동 migrate 없음.
- 사용자 명시 `sfs upgrade --opt-in 0.6-storage` 또는 prompt confirm 후에만 backfill 실행.
- Hard cut 이후 (2026-11-04~) `sfs upgrade` 가 0.5.x consumer 에서 자동 forced migrate (R-E E-4, AC5.4 — backup manifest default + `--commit` opt-in flag).
- 0.5.x git tags (89개 추정) 모두 historical 보존 — 삭제 0.

### In-progress (다음 chunk)

- R-B AC2.1~AC2.9: Layer 1/2 실 mkdir + co-location validator + N:M conflict detect + sprint.yml schema enforcement + flock(1) race + `--backfill-legacy` idempotence + atomic Layer 1 movements.
- R-C AC3.1~AC3.6: interactive wizard + Pass 1 deterministic CLI prompt (Q-A~Q-F) + Pass 2 file 별 confirm + reject granularity + git revert atomic.
- R-D AC4.1~AC4.6: unit + smoke + CI matrix (mac/Ubuntu/Win) + cross-instance verify (P-17 codex/gemini secrets) + sentinel masking isolated step.
- R-E AC5.1~AC5.4: deprecation warning + `--opt-in 0.6-storage` flag + forced migrate post-grace + commit idempotence guard.
- R-F AC6.1~AC6.6: sprint.yml 8-field schema enforce + status FSM + close mode prompt + archive/delete branches.
- R-G AC7.4/AC7.5/AC7.8/AC7.9: brew audit `--new-formula sfs` PASS + scoop manifest schema check PASS + release discovery 갱신 + atomic 5-file commit.
- R-H AC10.1~AC10.5: source matrix `--print-matrix` JSON Lines schema + backup manifest 9 field + `--rollback-from-snapshot` 실 restore + interrupted-midway recovery + no-data-loss anti-AC10 verify.
- R-I AC11/AC12/AC13: release sequence enforce + cross-platform hash parity + workflow permissions hardening.

### Chunk 2 (Code runtime, 2026-05-04 KST) — implementation lock

- **R-B real logic** — `sfs-storage-init.sh` slug regex enforcement + Layer 1/2 atomic mkdir + co-location pre-flight; `sfs-storage-precommit.sh` 3 validators (co-location FAIL, N:M conflict via active-sprint cross-touch detect, sprint.yml schema delegate) with `--strict|--advisory` mode; `sfs-archive-branch-sync.sh` flock(1) primary + advisory PID lock fallback + atomic snapshot pre-mv. **bash 3.2 compatible** (no `declare -A`).
- **R-C/R-H real logic** — `sfs-migrate-artifacts.sh` 7 modes (interactive / apply / auto / backfill / rollback / rollback-snapshot / print-matrix). 6 enumerated Pass 1 prompts (Q-A~Q-F deterministic). JSON Lines matrix (6 fields, action enum, null semantics for delete/skip). 9-field backup manifest + 11-extension default snapshot filter (`--snapshot-include-all` opt-in). SIGINT/SIGTERM atomic rollback trap. `sfs-migrate-artifacts-rollback.sh` git revert + snapshot fallback + working-tree dirty safety.
- **R-E real logic** — `sfs-upgrade-deprecation.sh` consumer version classify (0.6.x silent / 0.5.x pre-grace warn + `--opt-in 0.6-storage` invoke / 0.5.x post-grace forced migrate + `--commit` opt-in + dirty WT guard + idempotence). `bin/sfs upgrade_command` extended with `--opt-in` and `--commit` flags + deprecation hook.
- **R-F real logic** — `sfs-sprint-yml-validator.sh` validate (8 fields + status enum + dependencies semantics) and close (path resolution + interactive prompt or `--force-action` + gzip archive or delete) two-mode dispatch.
- **R-G audit + release discovery** — `bin/sfs latest_release_version()` accepts both legacy `v*-product` and new suffix-drop `v[0-9]*` semver. `sfs_parse_product_version()` likewise. `packaging/homebrew/sfs.rb` and `packaging/scoop/sfs.json` materialized with `__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__` (release tool sed at cut time).
- **R-I real logic** — `sfs-release-sequence.sh` 3-phase enforcement (tag-push → audit → tap-update) with state markers. `.gitattributes` LF normalization for SFS artifact extensions.
- **R-D tests + CI** — 16 `tests/test-*.sh` + `tests/run-all.sh` harness + 3 `tests/fixtures/bad-sprint-yml/*.yml` + `tests/scoop-manifest-validate.sh`. `.github/workflows/sfs-pr-check.yml` + `.github/workflows/sfs-0-6-storage.yml` shipped (AC2.6 mandatory + AC4.3 macOS+Ubuntu+Windows matrix + AC4.4 cross-instance verify + AC4.4.4/AC4.6 isolated log-masking + AC13 explicit `permissions: contents: read`). Existing `windows-scoop-smoke.yml` patched with permissions block.
- **AC9 verified** — `git diff 03f36de -- 2026-04-19-sfs-v0.4/SFS-PHILOSOPHY.md` = 0 lines (spec sprint immutability preserved).
- **`bash tests/run-all.sh`** = **17/17 PASS** locally.
- **AC4.3 / AC4.5 / AC7.4 / AC7.5 (real toolchain runs)** explicitly deferred to chunk 3 release cut (see implement.md §5).

### G6.1 fix patch (2026-05-04 KST, brave-focused-feynman D-Code session) — codex G6 PARTIAL flags HIGH 3 + MEDIUM 3

> Option β step 2 — retro.md §9 plan 따라 G6 review codex Stage 2 PARTIAL findings 6 fix.

- **HIGH F1 — `sfs-migrate-artifacts.sh` stdin contention fix** — interactive prompts now route through a `prompt_user()` helper that reads from `/dev/tty` (with timeout + default fallback). Matrix data flowing through stdin (`build_source_matrix | apply_migration`) is no longer drained by inner reads. New `--no-tty` flag forces default-only behaviour for CI / scripted contexts. AC3.2 / AC3.4 / AC3.5.
- **HIGH F3 — SIGINT/SIGTERM atomic rollback** — every file op (migrate / archive / delete / skip) appended to a JSONL transaction journal at `.sfs-local/migrate-tx/<ts>.jsonl`. Trap handler now: (1) reverse-replays journal to remove created destinations + archive `.gz` blobs, (2) cp-restores sources from the pre-migrate snapshot, (3) reports working-tree status. Signal-aware exit codes: `130` for SIGINT, `143` for SIGTERM (legacy `4` retained as fallback). AC2.9.
- **HIGH F4 — `verify_no_data_loss` real comparison** — replaces the prior count-only stub. For each manifest `files[]` entry the check resolves the current bytes via priority order (archive `.gz` blob → source path → migration dest), recomputes sha256 + size, and strict-compares against the manifest. Mismatch ≥ 1 → exit `3` (anti-AC10) + per-file mismatch report on stderr. New `--verify-snapshot <ISO>` flag runs the verifier standalone for negative tests + post-incident audits.
- **MEDIUM F2 — `sfs-pr-check.yml` strict mode** — Option A (default per CLAUDE.md §1.4 minimal cleanup): the storage validator step now invokes `sfs-storage-precommit.sh --root . --strict`, replacing the prior `--advisory` invocation. Storage violations now fail PR checks instead of being silently logged.
- **MEDIUM F6 — Windows hash parity (AC12)** — `tests/test-hash-parity.sh` extended: when running under bash on a Windows runner where `powershell.exe` (or `pwsh`) is on PATH, sample files are double-hashed via PowerShell `Get-FileHash -Algorithm SHA256` and compared strict-equal to POSIX `sha256sum` / `shasum -a 256`. New dedicated `hash-parity-windows` job in `.github/workflows/sfs-0-6-storage.yml` invokes the test on `windows-latest` runner.
- **MEDIUM AC10.5 — interrupted-midway recovery** — new `--recover [<ts>]` mode reuses the journal-replay cleanup + snapshot-restore pipeline. Defaults to the latest journal under `.sfs-local/migrate-tx/`. After recovery the script checks tracked-file diff vs HEAD (`git diff --quiet HEAD --`); residual transient artifacts (snapshot dir + journal file) are left intact for audit.
- **5 new negative tests + 1 extended test** — `tests/test-sfs-migrate-stdin-isolation.sh`, `tests/test-sfs-migrate-sigint-rollback.sh` (static contract + best-effort integration probe), `tests/test-no-data-loss-corruption-negative.sh`, `tests/test-sfs-pr-check-strict.sh`, `tests/test-sfs-migrate-recovery-clean.sh` + extended `tests/test-hash-parity.sh` Windows-PowerShell parity branch. **`bash tests/run-all.sh` = 22/22 PASS** locally post-fix.

### G6.1.1 fix iteration (Schedule A, 2026-05-04 KST, brave-focused-feynman) — gemini cross-check PARTIAL veto V1+V2 + hidden-bug HB1+HB2

> Schedule A 2nd round: G6.1 self CPO PASS 95/100 → gemini PARTIAL with 2 third-eye veto + 3 hidden-bug flags → fix all four → re-review.

- **V1 — escape-aware JSONL parsing** — replaces fragile `sed -nE 's/.*"<field>":"([^"]*)".*/\1/p'` (which truncates at the first byte after `"<field>":"`, including escaped `\"` quotes inside the value) with a new awk state-machine helper `json_get_string()` that walks the value byte-by-byte and decodes `\\`, `\"`, `\n`, `\r`, `\t` correctly, stopping only at the first UNESCAPED `"`. Three call sites converted: `journal_replay_cleanup` (op / dest / archive) and `verify_no_data_loss` (path / sha256). `size_bytes` stays on the original sed pattern (numeric, no quote ambiguity). Effect: file paths containing `"` or `\` no longer silently truncate during rollback or anti-AC10 verification.
- **V2 — rollback failure visibility** — `on_interrupt` no longer swallows `cp -a "${SNAPSHOT_FOR_INT}/files/." .` failures with `2>/dev/null || true`. cp's stderr is now inherited; on non-zero exit the trap prints a `SEVERE — snapshot restore failed; rollback INCOMPLETE — manual intervention required` message and exits with new exit code **5** (overrides the normal 130/143 signal exit). Header exit-code table updated.
- **HB1 — empty parent dir cleanup** — after `rm -f "${dest}"` in journal_replay_cleanup, an idempotent `rmdir` cascade walks up the parent chain (stopping at first non-empty dir or `.` / `/`). No more "ghost" directory structures left behind under `.solon/sprints/<sid>/<feat>/`. Recovery test extended to assert `find .solon/sprints -mindepth 1 -type d -empty` count = 0 post-recover.
- **HB2 — trap re-entrancy guard** — `on_interrupt` now sets `trap '' INT TERM` at the very first line, blocking a second SIGINT/SIGTERM from re-entering the handler mid-cleanup. Static contract enforced by extended `test-sfs-migrate-sigint-rollback.sh` (awk over `on_interrupt()` body asserts the early `trap ''` invocation).
- **1 new regression test + 2 extended** — `tests/test-sfs-migrate-quoted-paths.sh` (V1: `"`/`\` filenames survive migrate→recover round-trip + json_get_string helper presence + sed `[^"]*` regex absence in fixed functions); extended `tests/test-sfs-migrate-sigint-rollback.sh` (V2: `cp -a ... || true` absence + exit code 5 reachable + SEVERE marker; HB2: `trap '' INT TERM` early in `on_interrupt`); extended `tests/test-sfs-migrate-recovery-clean.sh` (HB1: empty subdir count assertion + pipefail-safe find guards). **`bash tests/run-all.sh` = 23/23 PASS** locally post-G6.1.1.
- New exit code: **`5`** = SEVERE rollback incomplete (snapshot restore cp failed during trap). Documented in script header. Distinguishes silent-rollback edge case from normal signal termination.

### G6.1.2 fix (V1 follow-up — Schedule A round 2 gemini veto, 2026-05-04 KST, brave-focused-feynman)

> Round 2 gemini PARTIAL: identified residual `grep -oE '\{"path":"[^"]*",...\}'` extraction in `verify_no_data_loss` (L594 + L597) — same escape-blind regex class that round 1 V1 hit. CPO round 2 PASS 96/100 missed this; gemini caught it.

- **V1 manifest entry extraction** — replaced both escape-blind `grep -oE` invocations with new awk depth-tracker `emit_manifest_files_entries(manifest)`. The walker tracks string + escape + brace-depth state and emits one top-level `{...}` object per line from the `files[]` array, regardless of whether a path contains escaped quotes (`\"`) or backslashes. Without this, `verify_no_data_loss` would silently skip any manifest entry whose path contained `"` — causing files_count to under-report and corrupted-or-missing files to slip past anti-AC10.
- **Test extension** — `tests/test-sfs-migrate-quoted-paths.sh` now also (a) parses `verify_no_data_loss: files=N` from `--auto` output and asserts `N >= src_count_pre`, and (b) re-runs `--verify-snapshot <ISO>` standalone and re-checks files=N. Together these close the round-2 gemini CTO action item.
- `bash tests/run-all.sh` = **23/23 PASS** local (test count unchanged — extending the existing quoted-paths test rather than adding a new one). Helper line count: sfs-migrate-artifacts.sh +60 (911 → 971L) for the awk function.

### Hotfix — claude code bootstrap performance (re-cut 2026-05-04)

> Sprint `0-6-0-hotfix-re-cut-claude-bootstrap`, G2 chunk-2 (D-Code, `23rd-dazzling-sharp-euler` claude-code-local-host session).
> User lock 2026-05-04T22:01+09:00 verbatim: `'γ + a 가자'` (JAR strategy γ + scripts split a) following spike-claude-code-baseline-1 PASS_WITH_DEFECT (manual claude code path 3min PASS + sfs orchestration path 16min ABORTED → 5.3x slowdown attributable to PDCA scaffold + skeleton review overhead, not LLM synthesis itself).
> AC verified at chunk-2 commit: AC-func-1 (idempotency guard), AC-func-4 (4-case graceful degradation), AC-func-5 (skeleton autodetect → review skip), AC-func-6 (override flags), AC-func-7 (PowerShell auto-forward via thin wrapper), AC-perf-4 (file-level template inventory), AC-perf-5 (alive heartbeat ≤30s default), AC-rev-1 (cosmetic-exclusion meta-rule), AC-rev-2 (skeleton review skip), AC-rev-3 (carry note).
> AC deferred to chunk-3 manual measurement: AC-func-2 (`./gradlew build`), AC-func-3 (`./gradlew test`), AC-perf-1 (≤30min wall-clock measurement), AC-spec-1/2 (philosophy + claude.md immutability via `git diff` post-chunk).
> AC deferred to a later release: AC-perf-2 (3-run σ ≤5min), AC-perf-3 (token ≤100K soft, requires R-D timer/token sub-dim instrumentation per H5b priority 6).

#### G6.1 Gemini Schedule A fix patch (2026-05-05 KST)

- **`scripts/sfs-bootstrap.sh` `--refresh` semantics fixed** — Spring Initializr HTTP 4xx now hard-fails with exit 2 instead of falling back to stale cache, while 5xx / timeout / offline still warn and fall back to the local template cache. This closes the invalid-input ambiguity flagged by Gemini round 1.
- **`scripts/sfs-measure.sh` signal cleanup hardened** — INT/TERM trap is registered before spawning the wrapped command, and the watcher now tracks/kills its foreground `sleep` via `sleep_pid` so signal cleanup cannot leave a sleeping watcher child behind.
- **γ JAR UX hint added** — the experimental Spring/Kotlin bootstrap helper now emits a stderr hint to run `gradle wrapper --gradle-version 8.10.2` before `./gradlew build` / `./gradlew test`, matching the text-only template strategy without bundling JAR or wrapper scripts.
- **R-E cosmetic boundary clarified** — public APIs, CLI flags/options, user- or automation-consumed paths, persisted data shapes, and domain ubiquitous terms are explicitly in-scope contract surfaces even when a diff appears to be "just naming".
- **Tests expanded** — `test-sfs-bootstrap-graceful-degradation.sh` covers fake HTTP 400 hard-fail + fake HTTP 500 fallback; `test-sfs-bootstrap-quick.sh` asserts no non-empty `review-g6.md` skeleton artifact and checks the Gradle wrapper hint; `test-sfs-measure-alive.sh` adds static + runtime signal-cleanup checks; new `test-review-cosmetic-boundary.sh` guards the R-E contract-surface wording. `bash tests/run-all.sh` = **29/29 PASS** locally after this patch.

#### Discovery priority hardening (2026-05-05 KST)

- **SFS promoted to priority-1 across CLI discovery** — `scripts/install-cli-discovery.sh` and `.ps1` now promote `solon@solon` to the first Claude Code enabled plugin and marketplace entry on install/update. Gemini extension enablement is similarly promoted so `solon` is first, Codex skill text declares priority-1 routing for Solon/SFS sprint/PDCA work, and later user-managed priority changes are respected unless `SFS_DISCOVERY_FORCE_PROMOTE=1` is set.
- **Doctor now verifies priority, not just installation** — `scripts/sfs-doctor.sh` checks whether Claude `enabledPlugins` starts with `solon@solon`, Gemini extension enablement starts with `solon`, and the Codex skill contains priority-1 routing text. The Claude `plugin list` probe is skipped unless `timeout(1)` exists, avoiding hangs on stale plugin/auth state.
- **Regression guard added** — `test-cli-discovery-macos.sh` now seeds a fake non-Solon-first Claude settings/registry state and asserts the install hook rewrites it to solon-first on install/update, then respects a later user-managed reorder. Windows mirror test updated with the same priority scenario.

#### Release hard-cut tooling guard (2026-05-05 KST)

- **Suffixless `0.6.0` release tooling fixed** — `scripts/cut-release.sh` now accepts `X.Y.Z` in addition to legacy `X.Y.Z-mvp` / `X.Y.Z-product`; `scripts/verify-product-release.sh` accepts suffixless product versions plus legacy `-product`; Scoop checkver now matches `v0.6.0` as well as historical `v0.5.x-product`.
- **Release regression test added** — new `tests/test-release-suffixless-hard-cut.sh` validates both owner scripts with `bash -n`, runs `cut-release.sh --version 0.6.0 --dry-run` against a temp stable repo, and checks Scoop suffixless discovery regex.
- **Release dry-run verified** — `SOLON_STABLE_REPO=/Users/mj/tmp/solon-product bash scripts/cut-release.sh --version 0.6.0 --dry-run --allow-dirty --allow-divergence` = PASS. `bash tests/run-all.sh` = **30/30 PASS** and `bash tests/scoop-manifest-validate.sh` = PASS.

#### Added

- **Conversational initial-setup `bin/sfs bootstrap` handoff + experimental helper** (R-A) — not a generic app generator contract. Non-experimental `sfs bootstrap <plain-language goal...>` exits 0 with an agent action handoff: the user should be able to simply describe what they want, then the AI asks "초기 프로젝트 구성해드릴까요?", infers the smallest useful setup, creates the app through Claude/Codex/Gemini or native framework CLIs (FastAPI, NestJS, React, Next.js, Vue, Nuxt, Spring/Kotlin, etc.) after consent, then returns with `sfs init --layout thin --yes`. Experimental usage for the hotfix measurement helper is `sfs bootstrap --experimental spring-kotlin <name> --quick` or `sfs bootstrap --experimental --stack spring-kotlin <name> --quick`. Spring/Kotlin quick mode is backed by an offline template cache; `--refresh` re-fetches from Spring Initializr API with graceful degradation (API 2xx exit 0 / API 4xx hard fail exit 2 / API 5xx → cache fallback exit 0 / network OFF → cache fallback exit 0 / cache absent → exit 2). Override flags: `--java-version`, `--spring-boot`, `--package`. Idempotency guard: existing target dir → exit 1 default; `--force` confirm prompt; `--force --yes` CI-mode overwrite (also rejects non-tty without `--yes`). Body in `scripts/sfs-bootstrap.sh` (precedent-aligned with `sfs-storage-init.sh` / `sfs-migrate-artifacts.sh` thin-dispatch + extracted-script pattern).
- **`bin/sfs measure --alive`** subcommand (R-D) — measurement wrapper for long-running steps. Spawns a watcher that emits `[alive] still in step: <name>` to stderr every `SFS_ALIVE_THRESHOLD_SECS` seconds (prod default 30, test override 2) while the wrapped command remains running. Forwards the wrapped command's exit code unchanged. Body in `scripts/sfs-measure.sh`. Timer / token sub-dimensions explicitly DEFER to a later release (H5b priority 6, requires PII review for token consumption instrumentation).
- **`scripts/sfs-bootstrap-skeleton-signature.sh`** (R-C) — autodetect skeleton (zero-feature) signature: zero endpoint annotations + zero non-boilerplate `@Test` + zero source `.kt` files outside `Application.kt` / `ApplicationTests.kt`. Returns exit 0 for skeleton (G6 review auto-skip surface), exit 1 for featured project, exit 2 for invalid arg. Used by the experimental Spring/Kotlin helper to gate review docs synthesis (AC-rev-2: review-g6.md not generated for skeleton output).
- **`templates/spring-kotlin-zero/`** offline template cache (R-B, γ scope: text-only) — 7 placeholder files: `build.gradle.kts` (Spring Boot starter-web + spring-boot-starter-test, Kotlin DSL), `settings.gradle.kts`, `gradle/wrapper/gradle-wrapper.properties` (Gradle 8.10.2 distribution URL), `src/main/kotlin/__PACKAGE_PATH__/Application.kt` (`@SpringBootApplication`), `src/main/resources/application.properties`, `src/test/kotlin/__PACKAGE_PATH__/ApplicationTests.kt` (`contextLoads()` only — skeleton signature input), `.gitignore`. Variable substitution: `<PROJECT-NAME>`, `<PACKAGE>`, `<PACKAGE_PATH>`, `<JAVA-VERSION>`, `<SPRING-BOOT-VERSION>`. **Gradle wrapper JAR + `gradlew` / `gradlew.bat` shell scripts intentionally omitted (γ)** — the experimental Spring/Kotlin helper emits the `gradle wrapper --gradle-version 8.10.2` hint, and chunk-3 manual measurement materializes wrappers post-copy or via `--refresh` Spring Initializr API tarball. AC-perf-4 file-level diff vs IntelliJ baseline accounts for the 3-file skew (gradlew + gradlew.bat + gradle-wrapper.jar) at chunk-3 measurement time.
- **Review prompt cosmetic-exclusion meta-rule (R-E)** — added to `templates/.sfs-local-template/personas/cpo-evaluator.md` and `templates/.sfs-local-template/context/commands/review.md`. In-scope: functional correctness + consistency (cross-document SSoT, AC ↔ test ↔ impl, frontmatter ↔ body). Out-of-scope (auto-skip when meaning unchanged): identifier naming, formatting, line-count drift, wording variants, comment style. Boundary clarification: public APIs, CLI flags/options, user- or automation-consumed paths, persisted data shapes, and domain ubiquitous terms are functional contract surfaces; renames there stay in-scope. Surface a finding only when behaviour, traceability, or a documented contract changes. Long-term project-philosophy-level codification reserved for a later release (`SFS-PHILOSOPHY.md` body change = 0 lines this hotfix per AC-spec-1 / anti-AC1, anti-AC5).
- **7 new tests under `tests/`** — `test-sfs-bootstrap-quick.sh` (non-experimental conversational setup trigger emits agent handoff, includes the plain-language consent question, and creates no framework files + explicit stack requirement + unsupported-stack guard + experimental Spring/Kotlin quick mode + override flags + file-level inventory + skeleton `review-g6.md` absent/0-byte assertion + Gradle wrapper hint), `test-sfs-bootstrap-skeleton-signature.sh` (skeleton dir → exit 0 + featured dir → exit 1), `test-sfs-measure-alive.sh` (`SFS_ALIVE_THRESHOLD_SECS=2` + 3s sleep → at least one `[alive] still in step:` stderr emit + signal cleanup smoke), `test-sfs-bootstrap-idempotency.sh` (existing dir → exit 1 + `--force --yes` overwrite + non-tty `--force` rejection), `test-sfs-bootstrap-graceful-degradation.sh` (cache absent → exit 2 + `--refresh` HTTP 400 hard-fail / HTTP 500 fallback / offline fallback mocks), `test-review-cosmetic-boundary.sh` (R-E public API / CLI flag / domain term contract boundary), `test-release-suffixless-hard-cut.sh` (0.6.0 owner release tooling and Scoop checkver guard). Existing `test-cli-discovery-macos.sh` now also verifies solon-first priority against a fake non-Solon-first Claude settings state. `bash tests/run-all.sh` = **30/30 PASS** locally after G6.1 + release hard-cut guard (23 baseline + 7 new).
- **`RUNTIME-ABSTRACTION.md` §6.1 Claude Adapter** expanded — bootstrap workflow surface (R-A bin/sfs bootstrap + R-C skeleton autodetect + R-D alive heartbeat) + review prompt cosmetic-exclusion (R-E) detail level brought to symmetry with §6.2 Codex / §6.3 Gemini-CLI adapter sections. Two deferred SDK questions added (`.claude-plugin/agents/` future native slot for multi-instance evaluator + multi-stack expansion beyond Kotlin Spring).

#### Changed

- **`bin/sfs` dispatch** gains two new top-level cases: `bootstrap` → forwards to `scripts/sfs-bootstrap.sh`, `measure` → forwards to `scripts/sfs-measure.sh`. The `bootstrap` script treats non-experimental generic use as a conversational setup handoff: ask the user in plain language, infer a suitable starter, create the app through native tooling, then return to Solon. PowerShell wrapper (`bin/sfs.ps1`) and CMD wrapper (`bin/sfs.cmd`) auto-forward both via the existing thin `bash bin/sfs` shim — no native dispatch case needed (AC-func-7 structural, Windows scoop smoke verify deferred to a later release).

#### Hypotheses priority reorder (spike-result.md §7.1 + plan.md §2)

- **H1** (`--quick` / full PDCA bypass) — VERIFIED — promoted from priority 2 → 1. sfs orchestration overhead is the dominant runtime-agnostic contributor (5.3x slowdown ratio).
- **H2** (review trigger guard) — PARTIAL — promoted from 3 → 2. PDCA 6-phase scaffold creates 6 empty `.md` per sprint regardless of feature presence; combined with H8/H9.
- **H4** (template cache) — REJECTED — demoted from 1 → 4. Manual claude code path synthesised 9 files in 3 minutes → LLM synthesis itself is not the bottleneck. Template cache is now positioned as a marginal file-level baseline parity surface (R-B) rather than a perf primary.
- **H5** split: H5a (alive UX, priority 3, VERIFIED via 14-min silent block in spike sfs path = 28x AC-perf-5 violation) ≠ H5b (timer/token budget instrumentation, priority 6, DEFER to a later release).
- **H8** (review/doc synthesis cost) — ACCEPTED, integrated into H1.
- **H9** (cosmetic review overhead) — ACCEPTED via G6.1 fix Round 3 cosmetic line-count drift (911→967→971 across 4 SSoT files) precedent, integrated into H2.

#### Risks flagged (carry to a later release)

- **R1** — R-D `bin/sfs measure --token` (ii) sub-dimension PII risk: token consumption instrumentation may capture LLM context windows that include user prompts. Decision deferred until R-D extension scope.
- **R2** — `§9.3` D-Code path-level isolation guidance reinforcement (CLAUDE.md §1.25 + `.bkit/` + `.sfs-local/migrate-tx/` + `.claude/settings.local.json` exclusion explicit pattern). Picked up at chunk-2 commit instructions.
- **R3** — plan.md §3 R-E target path was inaccurate (`.claude-plugin/agents/evaluator.md` does not exist on disk; actual consumer-facing prompt SSoT is `templates/.sfs-local-template/personas/cpo-evaluator.md`). Implement.md served as ground truth at chunk-2 entry. G7 retro will record the lesson — pre-G2 entry preflight should grep plan.md target paths against the working tree before chunk-1 scaffolding.

---

## [0.5.96-product] - 2026-05-03

> Pre-staged entry. VERSION bump and final wording pinned in Phase 10
> after Phase 8 (user-machine A-1/A-2 probe) finalizes the hook branch
> logic and Phase 12 (Windows verification) lands.

### Fixed

- **Slash-command zero-file discovery** — `brew install
  MJ-0701/solon-product/sfs` (macOS) and `scoop install sfs` (Windows) now
  register `/sfs` (Claude Code), `sfs <command>` (Gemini CLI), and `$sfs`
  (Codex CLI) automatically through their post-install hooks. The project
  tree no longer needs `.claude/commands/sfs.md`, `.gemini/commands/sfs.toml`,
  or `.agents/skills/sfs/SKILL.md`. Discovery surfaces live in the
  user-home plugin/extension cellar and the Codex user-global skills
  directory:
    - Claude Code:  marketplace plugin under `MJ-0701/solon-product`
    - Gemini CLI:   extension under `MJ-0701/solon-product`
    - Codex CLI:    `~/.codex/skills/sfs/SKILL.md` (auto-discovered)
  Hook is idempotent on `sfs upgrade`; failure of any single CLI surface
  emits a warning with a one-shot recovery command and does NOT abort the
  parent install.

### Added

- **`sfs doctor` subcommand** — print Solon runtime + slash-command
  discovery health (Claude Code / Gemini CLI / Codex CLI), with
  ✅/⚠️/❌ per check and concrete recovery line on warnings. Exit codes:
  0 (all pass) / 1 (warnings only) / 2 (binary itself broken).

- **GitHub Actions CI matrix for cli-discovery** — `sfs-cli-discovery.yml`
  runs the sandbox tests (`tests/test-cli-discovery-{macos,windows}.{sh,ps1}`)
  on macos-latest, ubuntu-latest, windows-latest, plus a Windows
  end-to-end Scoop install verification (Codex skill landing).

### Changed

- `install.sh` / `upgrade.sh` / `install.ps1` / `upgrade.ps1` invoke the
  cli-discovery hook after VERSION recording (skippable via
  `SFS_SKIP_CLI_DISCOVERY=1` for CI/bottle-build paths). On Windows the
  PS1 wrappers set `SFS_SKIP_CLI_DISCOVERY=1` for the bash-side run and
  call `scripts/install-cli-discovery.ps1` natively.
- `bin/sfs-scoop-post-install.ps1` runs cli-discovery unconditionally
  early; suppresses double-run when project upgrade subsequently calls
  `sfs upgrade`.
- README / GUIDE / BEGINNER-GUIDE / docs/en/guide.md updated to lead with
  the brew/scoop one-liner and `sfs doctor` 3-line verification.

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
- **consumer/developer path separation** — README/GUIDE 에 `<private-dev-staging>` (dev SSoT),
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
