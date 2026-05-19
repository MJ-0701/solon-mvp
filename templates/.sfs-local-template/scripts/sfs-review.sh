#!/usr/bin/env bash
# .sfs-local/scripts/sfs-review.sh
#
# Solon SFS — `/sfs review` command implementation.
# CPO Evaluator review entrypoint. Review is mandatory in the sprint flow.
# By default it executes the selected evaluator through a real CLI/bridge; use
# `--prompt-only` for manual handoff.
# WU-25 §2 spec implementation. WU-23 §1.4 + V-1 conditions #1 (gate id SSoT
# = gates.md §1) + WU22-D5 (7-Gate enum) 정합:
#   · 파일 path stdout 출력만 (에디터 launch 안 함, V-1 conditions #4 정합).
#   · gate number normalization = sfs-common.sh::sfs_normalize_gate_id (WU-25 row 4 기반).
#   · `--gate <1..7>` 미지정 시 events.jsonl 마지막 review_open event 의
#     gate_id 추론 (sfs-common.sh::infer_last_gate_id, WU-25 row 4 신설).
#   · CPO Evaluator persona prompt 를 review.md 에 append.
#   · verdict 자체는 CPO agent output 으로 기록한다. 본 bash 명령은 prompt/evidence
#     scaffold + executor bridge + event 기록을 담당한다.
#
# Output:
#   review.md ready: <path> | gate <Gate N (Name)> prompt ready | executor <executor> | prompt <path>
#   review.md ready: <path> | gate <Gate N (Name)> CPO run complete | executor <executor> | output <path>
#   review result ready:
#     verdict: <pass|partial|fail|unknown>
#     output: <path>
#     display: 사용자 언어로 요약/해야 할 일 레포트 렌더링; 원문은 파일에 보관
#
# Exit codes (WU-25 §2.3 / gates.md §3 정합):
#   0  success
#   1  no .sfs-local/ 또는 활성 sprint 없음 (run /sfs start first)
#   2  events.jsonl / current-sprint 손상
#   3  not a git repo
#   4  sprint-templates/review.md 부재
#   5  permission denied
#   6  gate id invalid 또는 미지정 (--gate 누락 + 추론 실패) — gates.md §3 verbatim:
#      "unknown gate <id>, valid: 1 (Gate 1 Intake), ... 7 (Gate 7 Retro)"
#   7  unknown CLI flag
#   9  executor bridge missing or executor failed
#   99 unknown (e.g. bash trap)
#
# Path note: dev staging file lives at
#   solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-review.sh
# install.sh copies templates/.sfs-local-template/ → consumer project's .sfs-local/.
# WU-25 §2 spec used `.sfs-local/scripts/` as a shorthand for the consumer-side path.
#
# Visibility: business-only (solon-mvp-dist staging asset).
# Created: 2026-04-28 (24th cycle 49번째 scheduled run `amazing-determined-gates`,
#                      mode=user-active-deferred, WU-25 §5 row 3).

set -euo pipefail

# Source common helpers
SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

# ─────────────────────────────────────────────────────────────────────
# Local exit-code fallbacks (WU-25 §2.3 — sfs-common.sh 미정의 시 default).
# 후속 sfs-common.sh 보강에서 SFS_EXIT_GATE / SFS_EXIT_BADCLI 정식 정의 시
# `:=` 가 fallback 으로만 작동하므로 충돌 X.
# ─────────────────────────────────────────────────────────────────────
: "${SFS_EXIT_GATE:=6}"
: "${SFS_EXIT_BADCLI:=7}"
: "${SFS_EXIT_EXECUTOR:=9}"

if ! load_sfs_auth_env; then
  echo "executor auth env load failed: ${SFS_AUTH_ENV_FILE:-${SFS_LOCAL_DIR}/auth.env}" >&2
  exit "${SFS_EXIT_EXECUTOR}"
fi

# ─────────────────────────────────────────────────────────────────────
# USAGE
# ─────────────────────────────────────────────────────────────────────
usage_review() {
  cat <<'EOF'
Usage: /sfs review [--gate <1..7>] [--lens <auto|artifact|code|docs|source-docs|simplify|security|performance|api-contract|strategy|design|taxonomy|qa|ops|management-admin|release>] [--executor <profile|cmd>] [--generator <profile|cmd>] [--persona <path>] [--prompt-only|--print-prompt] [--show-last] [--allow-empty] [--auth-interactive|--no-auth-interactive]

Open the active sprint's review.md as the CPO Evaluator review document.
  - --gate <n>    gate number, 1..7. Reports display this as Gate 1..7:
                  1 Intake, 2 Brainstorm, 3 Plan, 4 Design,
                  5 Handoff, 6 Review, 7 Retro.
                  Older ids are still accepted for compatibility.
                  If omitted, inferred from the most recent `review_open`
                  event in events.jsonl. If no review history exists, SFS
                  defaults to Gate 6 when implementation/artifact evidence is
                  present, or Gate 3 when only plan evidence is present.
  - --lens <name> review lens. Default: auto.
                  auto chooses from artifact, code, docs, source-docs,
                  simplify, security, performance, api-contract, strategy,
                  design, taxonomy, qa, ops, management-admin, release using
                  plan/implement/log text and changed artifact paths. Use an
                  explicit lens only to override a wrong inference. For the
                  same sprint/gate, later auto reviews reuse the previous lens
                  so review loops converge; pass an explicit lens to change
                  lanes. `code` is one lens, not the default meaning of review.
                  Common division aliases are accepted, for example
                  strategy-pm -> strategy, design/frontend -> design,
                  infra -> ops, source-driven -> source-docs, perf ->
                  performance, api/schema -> api-contract, and
                  finance/accounting -> management-admin.
  - --executor <profile|cmd>
                  CPO review tool/profile. Default: $SFS_REVIEW_EXECUTOR or codex.
                  Typical: codex, gemini, claude, or a custom command.
  - --generator <profile|cmd>
                  CTO implementation tool/profile, for self-validation tracking.
  - --persona <path>
                  CPO persona path. Default: .sfs-local/personas/cpo-evaluator.md.
  - --print-prompt
                  Prompt-only mode: print the generated CPO review prompt to
                  stdout after updating review.md. Does not execute evaluator.
  - --prompt-only
                  Prompt-only mode: create prompt/log for manual handoff.
                  Does not execute evaluator or spend executor tokens.
  - --show-last
                  Print the latest recorded CPO review result for the active
                  sprint without invoking an executor. Alias: --show, --last.
  - default run   Execute the CPO evaluator through a real bridge.
                  For named executors, SFS first runs a tiny bridge probe
                  (default timeout: 45s) so a broken CLI wrapper/auth path
                  fails before the full CPO prompt is sent.
                  Named profiles:
                    codex        $SFS_REVIEW_CODEX_CMD, else `codex exec --full-auto --ephemeral --output-last-message <result> -`
                    codex-plugin unsupported: Claude in-process Codex wrappers are blocked by Runtime Token Firewall
                    gemini       $SFS_REVIEW_GEMINI_CMD, else `gemini --skip-trust --output-format text -p "Read stdin and perform the requested CPO review."`
                    claude       $SFS_REVIEW_CLAUDE_CMD, else `claude -p "\$(cat)"`
                    claude-plugin unsupported; Codex is not a Claude plugin host
                  Custom executor strings are passed through as shell commands and receive the prompt on stdin.
  - --allow-empty
                  Force executor invocation even when SFS finds no reviewable project/sprint evidence.
                  Prefer `/sfs auth probe --executor <tool>` for cheap bridge request/response tests.
  - --auth-interactive
                  If a named executor is missing auth, allow its CLI login/browser
                  flow before running review. Requires a real terminal.
  - --no-auth-interactive
                  Fail closed when auth is missing. Useful for CI/headless runs.
                  Default: auto (use interactive auth when a real terminal is available).
  - Creates review.md from sprint-templates/review.md if missing.
  - Updates frontmatter: phase=review, gate_number=<n>, gate_label=<Gate N>,
    gate_id=<internal compatibility id>, evaluator_role=CPO, evaluator_executor=<executor>,
    generator_executor=<generator>, last_touched_at=<ISO8601>.
  - Writes the full CPO prompt to .sfs-local/tmp/review-prompts/.
  - Appends a compact CPO Evaluator invocation log to review.md. The full
    prompt body is not embedded by default to prevent recursive token growth.
  - Stores full executor result sets under .sfs-local/tmp/review-runs/. Scratch
    directories include a timestamp and pid so nested/reentrant review invocations
    cannot clobber each other. The durable review record is review.md; scratch is
    bundled into the sprint cold archive on tidy/retro close. review.md keeps
    only compact result metadata by default. Set SFS_REVIEW_MD_EXCERPT_LINES=1..80
    to embed a bounded excerpt.
  - Appends events.jsonl `review_open` event.
  - Prints the resolved review.md path + gate id + executor to stdout (no editor launch).
  - When review runs, prints compact result metadata only. AI runtimes should
    read the output path and render a localized Solon report instead of dumping
    the raw executor markdown.

Exit codes:
  0  success
  1  no .sfs-local/ or no active sprint (run /sfs start first)
  2  events.jsonl / current-sprint corrupt
  3  not a git repo
  4  sprint-templates/review.md missing
  5  permission denied
  6  gate id invalid or required (--gate missing + inference failed)
  7  unknown CLI flag
  9  executor bridge missing or executor failed
  99 unknown (CLI args, etc.)
EOF
}

# ─────────────────────────────────────────────────────────────────────
# CLI parse (--gate <1..7> | --gate=<1..7> | -h | --help)
# ─────────────────────────────────────────────────────────────────────
GATE_ID=""
REVIEW_LENS="${SFS_REVIEW_LENS:-auto}"
EVALUATOR_EXECUTOR="${SFS_REVIEW_EXECUTOR:-codex}"
GENERATOR_EXECUTOR="${SFS_GENERATOR_EXECUTOR:-unknown}"
PERSONA_PATH="$(sfs_persona_file cpo-evaluator)"
PRINT_PROMPT=false
RUN_REVIEW=true
SHOW_LAST=false
ALLOW_EMPTY_REVIEW="${SFS_REVIEW_ALLOW_EMPTY:-false}"
AUTH_INTERACTIVE="${SFS_AUTH_INTERACTIVE:-auto}"
REVIEW_MD_EXCERPT_LINES="${SFS_REVIEW_MD_EXCERPT_LINES:-0}"
REVIEW_FILE_EXCERPT_MAX="${SFS_REVIEW_FILE_EXCERPT_MAX:-12}"
REVIEW_FILE_EXCERPT_LINES="${SFS_REVIEW_FILE_EXCERPT_LINES:-120}"
REVIEW_DIFF_LINES="${SFS_REVIEW_DIFF_LINES:-180}"
REVIEW_TARGET_EXCERPT_RADIUS="${SFS_REVIEW_TARGET_EXCERPT_RADIUS:-32}"
REVIEW_INDEXED_TARGET_MAX="${SFS_REVIEW_INDEXED_TARGET_MAX:-80}"
REVIEW_SMALL_FILE_EXCERPT_LINES="${SFS_REVIEW_SMALL_FILE_EXCERPT_LINES:-450}"
REVIEW_FIRST_CLASS_EXCERPT_MAX="${SFS_REVIEW_FIRST_CLASS_EXCERPT_MAX:-40}"
REVIEW_DIR_EXPANSION_MAX="${SFS_REVIEW_DIR_EXPANSION_MAX:-80}"
REVIEW_EXECUTOR_TIMEOUT="${SFS_REVIEW_EXECUTOR_TIMEOUT_SEC:-${SFS_REVIEW_COMMAND_TIMEOUT_SEC:-1500}}"
REVIEW_BRIDGE_PROBE="${SFS_REVIEW_BRIDGE_PROBE:-auto}"
REVIEW_BRIDGE_PROBE_TIMEOUT="${SFS_REVIEW_BRIDGE_PROBE_TIMEOUT_SEC:-45}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage_review
      exit "${SFS_EXIT_OK}"
      ;;
    --gate)
      if [[ $# -lt 2 ]]; then
        echo "--gate requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      GATE_ID="$2"
      shift 2
      ;;
    --gate=*)
      GATE_ID="${1#--gate=}"
      shift
      ;;
    --lens)
      if [[ $# -lt 2 ]]; then
        echo "--lens requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      REVIEW_LENS="$2"
      shift 2
      ;;
    --lens=*)
      REVIEW_LENS="${1#--lens=}"
      shift
      ;;
    --executor)
      if [[ $# -lt 2 ]]; then
        echo "--executor requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      EVALUATOR_EXECUTOR="$2"
      shift 2
      ;;
    --executor=*)
      EVALUATOR_EXECUTOR="${1#--executor=}"
      shift
      ;;
    --generator)
      if [[ $# -lt 2 ]]; then
        echo "--generator requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      GENERATOR_EXECUTOR="$2"
      shift 2
      ;;
    --generator=*)
      GENERATOR_EXECUTOR="${1#--generator=}"
      shift
      ;;
    --persona)
      if [[ $# -lt 2 ]]; then
        echo "--persona requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      PERSONA_PATH="$2"
      shift 2
      ;;
    --persona=*)
      PERSONA_PATH="${1#--persona=}"
      shift
      ;;
    --print-prompt)
      PRINT_PROMPT=true
      RUN_REVIEW=false
      shift
      ;;
    --prompt-only|--no-run)
      RUN_REVIEW=false
      shift
      ;;
    --show-last|--show|--last)
      SHOW_LAST=true
      RUN_REVIEW=false
      shift
      ;;
    --run)
      # Deprecated no-op. Review runs by default.
      shift
      ;;
    --allow-empty)
      ALLOW_EMPTY_REVIEW=true
      shift
      ;;
    --auth-interactive)
      AUTH_INTERACTIVE=true
      shift
      ;;
    --no-auth-interactive)
      AUTH_INTERACTIVE=false
      shift
      ;;
    --)
      shift
      if [[ $# -gt 0 ]]; then
        echo "unexpected extra args after --: $*" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      ;;
    -*)
      echo "unknown flag: $1" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
  esac
done
case "${AUTH_INTERACTIVE}" in
  true|1|yes|YES|y|Y) AUTH_INTERACTIVE=true ;;
  false|0|no|NO|n|N) AUTH_INTERACTIVE=false ;;
  auto|AUTO|"") AUTH_INTERACTIVE=auto ;;
  *)
    echo "unknown auth mode: ${AUTH_INTERACTIVE}" >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac
case "${ALLOW_EMPTY_REVIEW}" in
  true|1|yes|YES|y|Y) ALLOW_EMPTY_REVIEW=true ;;
  *) ALLOW_EMPTY_REVIEW=false ;;
esac
normalize_review_lens_value() {
  local lens="$1"
  lens="$(printf '%s\n' "$lens" | tr '[:upper:]' '[:lower:]')"
  lens="${lens//_/-}"
  case "$lens" in
    auto|"") printf 'auto\n' ;;
    artifact|outcome|acceptance|general) printf 'artifact\n' ;;
    code|source|implementation) printf 'code\n' ;;
    doc|docs|documentation) printf 'docs\n' ;;
    source-docs|source-driven|source-driven-development|official-docs|official-documentation|docs-source|source-verification|framework-docs) printf 'source-docs\n' ;;
    simplify|simplification|code-simplify|cleanup|dead-code|deadcode|reduce-complexity) printf 'simplify\n' ;;
    security|hardening|auth|authorization|authentication|pii|secrets|secret) printf 'security\n' ;;
    performance|perf|latency|benchmark|benchmarks|lighthouse|memory|bundle) printf 'performance\n' ;;
    api-contract|api|interface|contract|schema|schemas|openapi|public-api|compatibility) printf 'api-contract\n' ;;
    strategy|strategy-pm|product|product-strategy|product-management|pm|planning) printf 'strategy\n' ;;
    design|design/frontend|frontend-design|ux|ui) printf 'design\n' ;;
    taxonomy|domain|glossary|naming) printf 'taxonomy\n' ;;
    qa|test|tests|verification) printf 'qa\n' ;;
    ops|infra|infra/devops|devops|runbook|operations) printf 'ops\n' ;;
    management-admin|management/admin|management|admin-finance|finance|financial|bookkeeping|accounting|tax|cashflow|payroll) printf 'management-admin\n' ;;
    release|deploy|deployment) printf 'release\n' ;;
    *)
      return 1
      ;;
  esac
}
_normalized_lens="$(normalize_review_lens_value "${REVIEW_LENS}" || true)"
if [[ -z "${_normalized_lens}" ]]; then
  echo "unknown review lens ${REVIEW_LENS}, valid: auto, artifact, code, docs, source-docs, simplify, security, performance, api-contract, strategy, design, taxonomy, qa, ops, management-admin, release" >&2
  echo "aliases: strategy-pm -> strategy, design/frontend -> design, infra -> ops, source-driven -> source-docs, perf -> performance, api/schema -> api-contract, finance/accounting -> management-admin" >&2
  exit "${SFS_EXIT_BADCLI}"
fi
REVIEW_LENS="${_normalized_lens}"
case "${REVIEW_MD_EXCERPT_LINES}" in
  ''|*[!0-9]*)
    echo "invalid SFS_REVIEW_MD_EXCERPT_LINES: ${REVIEW_MD_EXCERPT_LINES} (expected 0..80)" >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac
if (( REVIEW_MD_EXCERPT_LINES > 80 )); then
  REVIEW_MD_EXCERPT_LINES=80
fi
case "${REVIEW_FILE_EXCERPT_MAX}" in
  ''|*[!0-9]*) REVIEW_FILE_EXCERPT_MAX=12 ;;
esac
case "${REVIEW_FILE_EXCERPT_LINES}" in
  ''|*[!0-9]*) REVIEW_FILE_EXCERPT_LINES=120 ;;
esac
case "${REVIEW_DIFF_LINES}" in
  ''|*[!0-9]*) REVIEW_DIFF_LINES=180 ;;
esac
case "${REVIEW_EXECUTOR_TIMEOUT}" in
  ''|*[!0-9]*)
    echo "invalid SFS_REVIEW_EXECUTOR_TIMEOUT_SEC: ${REVIEW_EXECUTOR_TIMEOUT} (expected integer seconds, 0 disables)" >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac
case "${REVIEW_BRIDGE_PROBE_TIMEOUT}" in
  ''|*[!0-9]*)
    echo "invalid SFS_REVIEW_BRIDGE_PROBE_TIMEOUT_SEC: ${REVIEW_BRIDGE_PROBE_TIMEOUT} (expected integer seconds)" >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac
case "${REVIEW_TARGET_EXCERPT_RADIUS}" in
  ''|*[!0-9]*) REVIEW_TARGET_EXCERPT_RADIUS=32 ;;
esac
case "${REVIEW_INDEXED_TARGET_MAX}" in
  ''|*[!0-9]*) REVIEW_INDEXED_TARGET_MAX=80 ;;
esac
case "${REVIEW_SMALL_FILE_EXCERPT_LINES}" in
  ''|*[!0-9]*) REVIEW_SMALL_FILE_EXCERPT_LINES=450 ;;
esac
case "${REVIEW_FIRST_CLASS_EXCERPT_MAX}" in
  ''|*[!0-9]*) REVIEW_FIRST_CLASS_EXCERPT_MAX=40 ;;
esac
case "${REVIEW_DIR_EXPANSION_MAX}" in
  ''|*[!0-9]*) REVIEW_DIR_EXPANSION_MAX=80 ;;
esac
if (( REVIEW_FILE_EXCERPT_MAX > 40 )); then
  REVIEW_FILE_EXCERPT_MAX=40
fi
if (( REVIEW_FILE_EXCERPT_LINES > 240 )); then
  REVIEW_FILE_EXCERPT_LINES=240
fi
if (( REVIEW_DIFF_LINES > 360 )); then
  REVIEW_DIFF_LINES=360
fi
if (( REVIEW_TARGET_EXCERPT_RADIUS > 80 )); then
  REVIEW_TARGET_EXCERPT_RADIUS=80
fi
if (( REVIEW_INDEXED_TARGET_MAX > 200 )); then
  REVIEW_INDEXED_TARGET_MAX=200
fi
if (( REVIEW_SMALL_FILE_EXCERPT_LINES > 800 )); then
  REVIEW_SMALL_FILE_EXCERPT_LINES=800
fi
if (( REVIEW_FIRST_CLASS_EXCERPT_MAX > 80 )); then
  REVIEW_FIRST_CLASS_EXCERPT_MAX=80
fi
if (( REVIEW_DIR_EXPANSION_MAX > 200 )); then
  REVIEW_DIR_EXPANSION_MAX=200
fi

# ─────────────────────────────────────────────────────────────────────
# Validate .sfs-local + git
# ─────────────────────────────────────────────────────────────────────
set +e
validate_sfs_local
_validate_rc=$?
set -e
if [[ "${_validate_rc}" -ne 0 ]]; then
  # validate_sfs_local emits its own stderr.
  exit "${_validate_rc}"
fi

# ─────────────────────────────────────────────────────────────────────
# Resolve active sprint
# ─────────────────────────────────────────────────────────────────────
SPRINT_ID="$(read_current_sprint)"
if [[ -z "${SPRINT_ID}" ]]; then
  echo "no active sprint, run /sfs start first" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

SPRINT_DIR="${SFS_SPRINTS_DIR}/${SPRINT_ID}"
REVIEW_PATH="${SPRINT_DIR}/review.md"
TEMPLATE="$(sfs_sprint_template_file review)"
IMPLEMENT_PATH="${SPRINT_DIR}/implement.md"
PLAN_PATH="${SPRINT_DIR}/plan.md"
LOG_PATH="${SPRINT_DIR}/log.md"
BRAINSTORM_PATH="${SPRINT_DIR}/brainstorm.md"
SPRINT_GOAL="$(sfs_goal_for_sprint "${SPRINT_ID}" || true)"
SPRINT_WORKSPACE="$(sfs_workspace_for_sprint "${SPRINT_ID}" || true)"

review_signal_text() {
  for file in "${IMPLEMENT_PATH}" "${PLAN_PATH}" "${LOG_PATH}" "${BRAINSTORM_PATH}"; do
    [[ -f "$file" ]] && sed -n '1,260p' "$file"
  done 2>/dev/null || true
}

review_changed_paths_for_lens() {
  git status --porcelain=v1 2>/dev/null | while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    local path
    path="${line#???}"
    case "$line" in
      R*|C*) path="${path##* -> }" ;;
    esac
    path="${path#./}"
    case "$path" in
      .sfs-local|.sfs-local/*|.claude/commands/sfs.md|.claude/skills/sfs|.claude/skills/sfs/*|.gemini/commands/sfs.toml|.agents/skills/sfs/SKILL.md|.codex/prompts/sfs.md|SFS.md|CLAUDE.md|AGENTS.md|GEMINI.md)
        continue
        ;;
    esac
    [[ -n "$path" ]] && printf '%s\n' "$path"
  done
}

review_path_lens_signal() {
  local paths="$1"
  case "$paths" in
    *VERSION*|*CHANGELOG.md*|*packaging/*|*.github/*|*install.sh*|*upgrade.sh*|*uninstall.sh*|*bin/sfs*|*bin/sfs.ps1*|*bin/sfs.cmd*)
      printf 'release\n'
      return 0
      ;;
  esac
  case "$paths" in
    *Dockerfile*|*docker-compose*|*.github/workflows/*|*runbook*|*infra*|*deploy*|*.env.example*|*k8s*|*terraform*|*.tf)
      printf 'ops\n'
      return 0
      ;;
  esac
  case "$paths" in
    *auth*|*oauth*|*token*|*secret*|*security*|*permission*|*permissions*|*pii*|*privacy*|*upload*|*webhook*|*.pem|*.key)
      printf 'security\n'
      return 0
      ;;
  esac
  case "$paths" in
    *perf*|*performance*|*benchmark*|*benchmarks*|*lighthouse*|*latency*|*memory*|*bundle*|*load-test*)
      printf 'performance\n'
      return 0
      ;;
  esac
  case "$paths" in
    *openapi*|*api*|*controller*|*controllers*|*route*|*routes*|*schema*|*schemas*|*dto*|*interface*|*contract*)
      printf 'api-contract\n'
      return 0
      ;;
  esac
  case "$paths" in
    *cleanup*|*simplif*|*dead-code*|*deadcode*|*deprecat*|*migration*)
      printf 'simplify\n'
      return 0
      ;;
  esac
  case "$paths" in
    *figma*|*design*|*wireframe*|*ux*|*ui*|*component*|*.css|*.scss|*.html)
      printf 'design\n'
      return 0
      ;;
  esac
  case "$paths" in
    *glossary*|*taxonomy*|*schema*|*domain*|*enum*|*naming*)
      printf 'taxonomy\n'
      return 0
      ;;
  esac
  case "$paths" in
    *roadmap*|*pricing*|*strategy*|*prd*|*plan.md|*decision*)
      printf 'strategy\n'
      return 0
      ;;
  esac
  case "$paths" in
    *management-admin*|*finance*|*financial*|*accounting*|*bookkeeping*|*invoice*|*receipt*|*tax*|*cashflow*|*payroll*|*ledger*)
      printf 'management-admin\n'
      return 0
      ;;
  esac
  case "$paths" in
    *test*|*spec*|*playwright*|*cypress*|*vitest*|*jest*|*smoke*)
      printf 'qa\n'
      return 0
      ;;
  esac
  case "$paths" in
    *.ts|*.tsx|*.js|*.jsx|*.py|*.java|*.kt|*.go|*.rs|*.rb|*.php|*.cs|*.swift|*.sql|*src/*|*app/*|*lib/*)
      printf 'code\n'
      return 0
      ;;
  esac
  case "$paths" in
    *.md|*.mdx|*.rst|*.adoc|*docs/*|*README*)
      printf 'docs\n'
      return 0
      ;;
  esac
  return 1
}

infer_review_lens() {
  local text paths lowered path_signal
  text="$(review_signal_text)"
  lowered="$(printf '%s\n' "$text" | tr '[:upper:]' '[:lower:]')"
  paths="$(review_changed_paths_for_lens | tr '\n' ' ' || true)"
  path_signal="$(review_path_lens_signal "$paths" || true)"

  if [[ -n "$path_signal" ]]; then
    printf '%s\n' "$path_signal"
    return 0
  fi
  case "$lowered" in
    *"source-driven"*|*"official docs"*|*"official documentation"*|*"framework docs"*|*"primary source"*|*"upstream docs"*)
      printf 'source-docs\n'
      return 0
      ;;
    *"security"*|*"hardening"*|*"auth"*|*"authorization"*|*"authentication"*|*"pii"*|*"secret"*|*"token"*|*"untrusted input"*)
      printf 'security\n'
      return 0
      ;;
    *"performance"*|*"perf"*|*"latency"*|*"benchmark"*|*"lighthouse"*|*"memory"*|*"bundle size"*)
      printf 'performance\n'
      return 0
      ;;
    *"api contract"*|*"public api"*|*"openapi"*|*"schema"*|*"interface compatibility"*|*"backward compatibility"*)
      printf 'api-contract\n'
      return 0
      ;;
    *"simplify"*|*"simplification"*|*"dead code"*|*"deprecation"*|*"migration"*)
      printf 'simplify\n'
      return 0
      ;;
    *"artifact types touched"*release*|*"release readiness"*|*"homebrew"*|*"scoop"*)
      printf 'release\n'
      return 0
      ;;
    *"artifact types touched"*infra*|*"runbook"*|*"rollback"*|*"observability"*|*"secret"*|*"ops"*)
      printf 'ops\n'
      return 0
      ;;
    *"artifact types touched"*design*|*"ux"*|*"ui"*|*"figma"*|*"wireframe"*)
      printf 'design\n'
      return 0
      ;;
    *"artifact types touched"*taxonomy*|*"glossary"*|*"domain terms touched"*|*"ubiquitous language"*|*"용어"*)
      printf 'taxonomy\n'
      return 0
      ;;
    *"artifact types touched"*strategy*|*"roadmap"*|*"pricing"*|*"positioning"*|*"prd"*|*"전략"*)
      printf 'strategy\n'
      return 0
      ;;
    *"artifact types touched"*management-admin*|*"management/admin evidence"*|*"finance"*|*"financial"*|*"bookkeeping"*|*"accounting"*|*"invoice"*|*"receipt"*|*"tax"*|*"cashflow"*|*"payroll"*)
      printf 'management-admin\n'
      return 0
      ;;
    *"artifact types touched"*qa*|*"qa / verification evidence"*|*"test plan"*|*"테스트"*)
      printf 'qa\n'
      return 0
      ;;
    *"artifact types touched"*docs*|*"docs / decisions"*|*"documentation"*|*"문서"*)
      printf 'docs\n'
      return 0
      ;;
  esac
  if [[ "$lowered" == *"code"* || "$lowered" == *"source"* ]]; then
    printf 'code\n'
    return 0
  fi
  printf 'artifact\n'
}

review_lens_label() {
  case "$1" in
    code) printf 'code review lens' ;;
    docs) printf 'documentation acceptance lens' ;;
    source-docs) printf 'source-driven documentation evidence lens' ;;
    simplify) printf 'behavior-preserving simplification lens' ;;
    security) printf 'security/threat-model acceptance lens' ;;
    performance) printf 'performance evidence lens' ;;
    api-contract) printf 'API/contract compatibility lens' ;;
    strategy) printf 'strategy/product acceptance lens' ;;
    design) printf 'design/UX acceptance lens' ;;
    taxonomy) printf 'taxonomy/domain-language acceptance lens' ;;
    qa) printf 'QA/verification acceptance lens' ;;
    ops) printf 'ops/infra readiness lens' ;;
    management-admin) printf 'management/admin finance evidence lens' ;;
    release) printf 'release readiness lens' ;;
    *) printf 'artifact acceptance lens' ;;
  esac
}

infer_default_review_gate_id() {
  local inferred event_hit
  inferred="$(infer_last_gate_id || true)"
  if [[ -n "$inferred" ]]; then
    printf '%s\n' "$inferred"
    return 0
  fi
  if [[ -f "${SFS_EVENTS_FILE}" ]]; then
    event_hit="$(grep -E '"type":"implement_open"' "${SFS_EVENTS_FILE}" 2>/dev/null \
      | grep -F "\"sprint_id\":\"${SPRINT_ID}\"" \
      | sed -n '1p' || true)"
    if [[ -n "$event_hit" ]]; then
      printf 'G4\n'
      return 0
    fi
    event_hit="$(grep -E '"type":"plan_open|brainstorm_open|decision_created"' "${SFS_EVENTS_FILE}" 2>/dev/null \
      | grep -F "\"sprint_id\":\"${SPRINT_ID}\"" \
      | sed -n '1p' || true)"
    if [[ -n "$event_hit" ]]; then
      printf 'G1\n'
      return 0
    fi
  fi
  if [[ -s "${IMPLEMENT_PATH}" ]] && grep -Eiq 'ready-for-review|Ready for review\?\*\*[[:space:]]*yes|Build output|Smoke output|Verification|Non-code artifact review evidence|Artifact Changes Made|검증|산출물' "${IMPLEMENT_PATH}"; then
    printf 'G4\n'
    return 0
  fi
  if [[ -s "${PLAN_PATH}" ]]; then
    printf 'G1\n'
    return 0
  fi
  return 1
}

existing_result_excerpt() {
  local file="$1" limit="${2:-80}"
  if [[ ! -s "$file" ]]; then
    printf '(empty)\n'
    return 0
  fi
  awk -v limit="$limit" '
    BEGIN { found=0; count=0 }
    /^[[:space:]>-]*Verdict:[[:space:]]*(pass|partial|fail)[[:space:]]*$/ { found=1 }
    found && count < limit { print; count++ }
    END { exit(found ? 0 : 1) }
  ' "$file" && return 0
  sed -n "1,${limit}p" "$file"
}

latest_review_output_path() {
  local gate_filter="${1:-}" line
  [[ -f "${SFS_EVENTS_FILE}" ]] || return 1
  if [[ -n "${gate_filter}" ]]; then
    line="$(grep -F '"type":"review_run"' "${SFS_EVENTS_FILE}" 2>/dev/null \
      | grep -F "\"sprint_id\":\"${SPRINT_ID}\"" \
      | grep -F "\"gate_id\":\"${gate_filter}\"" \
      | tail -n 1 || true)"
  else
    line="$(grep -F '"type":"review_run"' "${SFS_EVENTS_FILE}" 2>/dev/null \
      | grep -F "\"sprint_id\":\"${SPRINT_ID}\"" \
      | tail -n 1 || true)"
  fi
  [[ -n "$line" ]] || return 1
  printf '%s\n' "$line" | sed -nE 's/.*"output_path":"([^"]*)".*/\1/p'
}

review_json_string_field() {
  local field="$1" line="$2"
  printf '%s\n' "$line" | sed -nE 's/.*"'"${field}"'"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p'
}

latest_review_lens_for_gate() {
  local gate_filter="${1:-}" line lens normalized
  [[ -f "${SFS_EVENTS_FILE}" && -n "${gate_filter}" ]] || return 1
  while IFS= read -r line; do
    case "$line" in
      *'"type":"review_open"'*|*'"type":"review_run"'*) ;;
      *) continue ;;
    esac
    [[ "$line" == *"\"sprint_id\":\"${SPRINT_ID}\""* ]] || continue
    [[ "$line" == *"\"gate_id\":\"${gate_filter}\""* ]] || continue
    lens="$(review_json_string_field "review_lens" "$line")"
    [[ -n "$lens" ]] || continue
    normalized="$(normalize_review_lens_value "$lens" || true)"
    case "$normalized" in
      ""|auto) continue ;;
      *)
        printf '%s\n' "$normalized"
        return 0
        ;;
    esac
  done < <(reverse_lines "${SFS_EVENTS_FILE}")
  return 1
}

latest_review_md_result_path() {
  [[ -f "${REVIEW_PATH}" ]] || return 1
  awk -F'`' '/^- result_path: `/ { path=$2 } END { if (path != "") print path; else exit 1 }' "${REVIEW_PATH}"
}

latest_review_md_excerpt() {
  [[ -f "${REVIEW_PATH}" ]] || return 1
  awk '
    /^#### result excerpt[[:space:]]*$/ { capture=1; in_block=0; buf=""; next }
    capture && /^```/ {
      if (in_block) { last=buf; capture=0; in_block=0; next }
      in_block=1; next
    }
    capture && in_block { buf = buf $0 ORS }
    END { if (last != "") printf "%s", last; else exit 1 }
  ' "${REVIEW_PATH}"
}

extract_result_verdict() {
  local file="$1"
  [[ -f "${file}" ]] || return 1
  awk '
    {
      low = tolower($0)
      if (low ~ /^[[:space:]>-]*verdict:[[:space:]]*(pass|partial|fail)[[:space:]]*$/) {
        line = $0
        sub(/^[[:space:]>-]*[Vv][Ee][Rr][Dd][Ii][Cc][Tt]:[[:space:]]*/, "", line)
        sub(/[[:space:]]*$/, "", line)
        print tolower(line)
        found = 1
        exit
      }
    }
    END { if (!found) exit 1 }
  ' "${file}"
}

review_next_action_line() {
  local gate="${1:-}" verdict="${2:-unknown}" gate_display
  gate_display="$(sfs_gate_display_label "${gate}" 2>/dev/null || printf '%s' "${gate:-Gate -}")"
  case "${verdict}" in
    pass)
      case "${gate}" in
        G1)
          printf 'sfs implement (Gate 3 Plan PASS; carry required review items into the first implementation slice)\n'
          ;;
        G4|G5)
          printf 'sfs retro (review PASS; close with report/retro evidence)\n'
          ;;
        *)
          printf 'continue to the next SFS gate after recording this %s PASS\n' "${gate_display}"
          ;;
      esac
      ;;
    partial)
      printf 'rework the smallest failing slice, then rerun sfs review --gate %s\n' "${gate#G}"
      ;;
    fail)
      printf 'stop and return to the prior gate; do not hand off implementation from a FAIL review\n'
      ;;
    *)
      printf 'inspect the review output path and record a clear pass/partial/fail before moving gates\n'
      ;;
  esac
}

emit_result_metadata_stdout() {
  local file="$1" state="${2:-ready}" gate="${3:-}" verdict next_action
  verdict="$(extract_result_verdict "${file}" || true)"
  [[ -n "${verdict}" ]] || verdict="unknown"
  next_action="$(review_next_action_line "${gate}" "${verdict}")"
  echo "review result ${state}:"
  echo "  verdict: ${verdict}"
  echo "  output: ${file}"
  echo "  display: 사용자 언어로 요약/해야 할 일 레포트 렌더링; 원문은 파일에 보관"
  echo "  next: ${next_action}"
}

show_latest_review_result() {
  local gate_filter="${1:-}" result_path gate_label
  if [[ ! -f "${REVIEW_PATH}" ]]; then
    echo "review.md not found: ${REVIEW_PATH} | no recorded CPO review yet"
    return 0
  fi

  gate_label=""
  if [[ -n "${gate_filter}" ]]; then
    gate_label=" | gate $(sfs_gate_display_label "${gate_filter}")"
  fi

  result_path="$(latest_review_output_path "${gate_filter}" || true)"
  if [[ -z "${result_path}" && -n "${gate_filter}" ]]; then
    echo "review.md ready: ${REVIEW_PATH}${gate_label} | latest CPO result | output not-found"
    echo "review result none:"
    echo "  verdict: unknown"
    echo "  output: not-found"
    echo "  display: $(sfs_gate_display_label "${gate_filter}") 에 기록된 CPO 결과 없음"
    return 0
  fi
  if [[ -z "${result_path}" ]]; then
    result_path="$(latest_review_md_result_path || true)"
  fi

  if [[ -n "${result_path}" && -f "${result_path}" ]]; then
    echo "review.md ready: ${REVIEW_PATH}${gate_label} | latest CPO result | output ${result_path}"
    emit_result_metadata_stdout "${result_path}" "ready" "${gate_filter}"
    return 0
  fi

  echo "review.md ready: ${REVIEW_PATH}${gate_label} | latest CPO result | output ${result_path:-not-found}"
  if latest_review_md_excerpt >/dev/null 2>&1; then
    emit_result_metadata_stdout "${REVIEW_PATH}" "embedded" "${gate_filter}"
  else
    echo "review result none:"
    echo "  verdict: unknown"
    echo "  output: not-found"
    echo "  display: 기록된 CPO 결과 없음"
  fi
}

if [[ "${SHOW_LAST}" == "true" ]]; then
  if [[ -n "${GATE_ID}" ]]; then
    _normalized_gate_id="$(sfs_normalize_gate_id "${GATE_ID}" || true)"
    if [[ -z "${_normalized_gate_id}" ]] || ! validate_gate_id "${_normalized_gate_id}"; then
      echo "unknown gate ${GATE_ID}, valid: $(sfs_gate_valid_display_list)" >&2
      exit "${SFS_EXIT_GATE}"
    fi
    GATE_ID="${_normalized_gate_id}"
  fi
  show_latest_review_result "${GATE_ID}"
  exit "${SFS_EXIT_OK}"
fi

# ─────────────────────────────────────────────────────────────────────
# Resolve gate id (either --gate <1..7> or infer from events.jsonl)
# ─────────────────────────────────────────────────────────────────────
if [[ -z "${GATE_ID}" ]]; then
  GATE_ID="$(infer_default_review_gate_id || true)"
fi
if [[ -z "${GATE_ID}" ]]; then
  echo "gate number required: --gate <1..7>, valid: $(sfs_gate_valid_display_list). SFS can infer it after /sfs plan or /sfs implement evidence exists." >&2
  exit "${SFS_EXIT_GATE}"
fi
_normalized_gate_id="$(sfs_normalize_gate_id "${GATE_ID}" || true)"
if [[ -z "${_normalized_gate_id}" ]] || ! validate_gate_id "${_normalized_gate_id}"; then
  echo "unknown gate ${GATE_ID}, valid: $(sfs_gate_valid_display_list)" >&2
  exit "${SFS_EXIT_GATE}"
fi
GATE_ID="${_normalized_gate_id}"
GATE_DISPLAY="$(sfs_gate_display_label "${GATE_ID}")"
GATE_NUMBER="$(sfs_gate_number "${GATE_ID}")"
GATE_ARTIFACT_ID="gate${GATE_NUMBER}"
REVIEW_LENS_SOURCE="explicit"
if [[ "${REVIEW_LENS}" == "auto" ]]; then
  _previous_review_lens="$(latest_review_lens_for_gate "${GATE_ID}" || true)"
  if [[ -n "${_previous_review_lens}" ]]; then
    REVIEW_LENS="${_previous_review_lens}"
    REVIEW_LENS_SOURCE="auto-locked"
  else
    REVIEW_LENS="$(infer_review_lens)"
    REVIEW_LENS_SOURCE="auto"
  fi
fi
REVIEW_LENS_LABEL="$(review_lens_label "${REVIEW_LENS}")"

normalize_inferred_executor_value() {
  local value="$1" token low_value session_hint
  value="$(printf '%s' "$value" \
    | sed -E 's/[`"*]//g; s/#.*$//; s/^[[:space:]-]+//; s/[[:space:]]+$//')"
  [[ -n "$value" ]] || return 1
  low_value="$(printf '%s\n' "$value" | tr '[:upper:]' '[:lower:]')"
  case "$low_value" in
    *unknown*|*"current runtime model"*|*"current-runtime-model"*)
      return 1
      ;;
  esac
  case "$low_value" in
    *codex*)
      session_hint="$(printf '%s\n' "$value" \
        | sed -nE 's/.*[Ii]n[[:space:]]+this[[:space:]]+([^[:space:],.;]+)[[:space:]]+session.*/\1/p; s/.*same[[:space:]]+([^[:space:],.;]+)[[:space:]]+session.*/\1/p' \
        | sed -n '1p')"
      if [[ -n "$session_hint" ]]; then
        printf 'codex, same %s session\n' "$session_hint"
      else
        printf 'codex\n'
      fi
      return 0
      ;;
    *gemini*) printf 'gemini\n'; return 0 ;;
    *claude*) printf 'claude\n'; return 0 ;;
    *human*) printf 'human\n'; return 0 ;;
  esac
  token="$(printf '%s\n' "$value" | awk '{print $1}')"
  token="${token%,}"
  token="${token%;}"
  token="${token%.}"
  [[ -n "$token" ]] || return 1
  printf '%s\n' "$token"
}

infer_generator_executor_from_file() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  awk '
    /^#{1,6}[[:space:]]+/ {
      low = tolower($0)
      in_self_validation = (low ~ /self-validation|self validation|cto 구현 메모/)
      next
    }
    {
      low = tolower($0)
    }
    low ~ /generator_executor[[:space:]]*:/ ||
    low ~ /generator executor[[:space:]]*:/ ||
    low ~ /generator executor\/tool[[:space:]*]*:/ ||
    low ~ /implementation executor[[:space:]]*:/ ||
    low ~ /implementation tool[[:space:]]*:/ ||
    low ~ /구현 executor\/tool[[:space:]*]*:/ ||
    low ~ /구현 executor[[:space:]]*:/ ||
    (in_self_validation && low ~ /(generator|implementation|executor|tool|구현|codex|gemini|claude|human)/) {
      line = $0
      sub(/^.*:[[:space:]]*/, "", line)
      print line
      exit
    }
  ' "$file" | while IFS= read -r candidate; do
    normalize_inferred_executor_value "$candidate" && exit 0
  done
}

if [[ -z "${GENERATOR_EXECUTOR}" || "${GENERATOR_EXECUTOR}" == "unknown" ]]; then
  _inferred_generator="$(infer_generator_executor_from_file "${IMPLEMENT_PATH}" || true)"
  if [[ -z "${_inferred_generator}" ]]; then
    _inferred_generator="$(infer_generator_executor_from_file "${LOG_PATH}" || true)"
  fi
  if [[ -n "${_inferred_generator}" ]]; then
    GENERATOR_EXECUTOR="${_inferred_generator}"
  fi
fi

preflight_review_executor_auth() {
  local profile upper override_var override_value
  [[ "${RUN_REVIEW}" == "true" ]] || return 0
  profile="$(normalize_executor_profile "${EVALUATOR_EXECUTOR}")"
  case "${profile}" in
    claude|codex|gemini) ;;
    *) return 0 ;;
  esac

  upper="$(printf '%s' "${profile}" | tr '[:lower:]' '[:upper:]')"
  override_var="SFS_REVIEW_${upper}_CMD"
  override_value="${!override_var:-}"
  if [[ -n "${override_value}" ]]; then
    return 0
  fi
  if ! command -v "${profile}" >/dev/null 2>&1; then
    executor_cli_missing_hint "${profile}"
    echo "review auth preflight stopped before CPO prompt generation." >&2
    return "${SFS_EXIT_EXECUTOR}"
  fi
  if executor_auth_ready "${profile}"; then
    return 0
  fi
  case "${AUTH_INTERACTIVE}" in
    true)
      if bootstrap_executor_interactive_auth "${profile}"; then
        return 0
      fi
      ;;
    auto)
      if executor_interactive_tty_available && bootstrap_executor_interactive_auth "${profile}"; then
        return 0
      fi
      ;;
  esac

  cat >&2 <<EOF
review auth preflight required: ${profile}
Review was not started, and no CPO prompt was generated.
Next:
  1. Run \`sfs auth login --executor ${profile}\` from a real terminal.
  2. Run \`sfs auth probe --executor ${profile} --timeout ${REVIEW_BRIDGE_PROBE_TIMEOUT}\`.
  3. Rerun the same \`sfs review ... --executor ${profile}\` command.
Manual handoff: rerun with \`--prompt-only\` and paste the prompt into ${profile} yourself.
EOF
  return "${SFS_EXIT_EXECUTOR}"
}

if ! preflight_review_executor_auth; then
  exit "${SFS_EXIT_EXECUTOR}"
fi
# ─────────────────────────────────────────────────────────────────────
# Ensure review.md exists (copy from template if missing)
# ─────────────────────────────────────────────────────────────────────
if [[ ! -f "${REVIEW_PATH}" ]]; then
  if [[ ! -f "${TEMPLATE}" ]]; then
    echo "template missing: ${TEMPLATE}" >&2
    exit "${SFS_EXIT_NO_TEMPLATES}"
  fi
  if ! mkdir -p "${SPRINT_DIR}" 2>/dev/null; then
    echo "permission denied creating ${SPRINT_DIR}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
  if ! cp -f "${TEMPLATE}" "${REVIEW_PATH}" 2>/dev/null; then
    echo "permission denied copying template to ${REVIEW_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# Update frontmatter (phase + gate_number/gate_label + compatibility gate_id + last_touched_at)
# ─────────────────────────────────────────────────────────────────────
NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"

if ! sfs_update_sprint_doc_identity "${REVIEW_PATH}" "${SPRINT_ID}" "${NOW}" 2>/dev/null; then
  echo "permission denied updating sprint metadata in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "phase" "review" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if [[ -n "${SPRINT_GOAL}" ]]; then
  if ! update_frontmatter "${REVIEW_PATH}" "goal" "$(sfs_yaml_quote "${SPRINT_GOAL}")" 2>/dev/null; then
    echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
fi
if [[ -n "${SPRINT_WORKSPACE}" ]]; then
  if ! update_frontmatter "${REVIEW_PATH}" "workspace" "$(sfs_yaml_quote "${SPRINT_WORKSPACE}")" 2>/dev/null; then
    echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
fi
if ! update_frontmatter "${REVIEW_PATH}" "gate_id" "${GATE_ID}" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "gate_number" "${GATE_NUMBER}" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "gate_label" "\"${GATE_DISPLAY//\"/\\\"}\"" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "evaluator_role" "CPO" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "evaluator_persona" "\"${PERSONA_PATH//\"/\\\"}\"" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "review_lens" "\"${REVIEW_LENS//\"/\\\"}\"" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "review_lens_source" "\"${REVIEW_LENS_SOURCE//\"/\\\"}\"" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "evaluator_executor" "\"${EVALUATOR_EXECUTOR//\"/\\\"}\"" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "generator_executor" "\"${GENERATOR_EXECUTOR//\"/\\\"}\"" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "last_touched_at" "${NOW}" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi

render_evidence_file() {
  local file="$1" limit="${2:-220}"
  printf '\n### file: %s\n\n' "$file"
  if [[ -f "$file" ]]; then
    sed -n "1,${limit}p" "$file"
  else
    printf '(missing)\n'
  fi
}

render_priority_evidence_sections() {
  local file="$1" limit="${2:-80}"
  printf '\n### priority evidence sections: %s\n\n' "$file"
  if [[ ! -f "$file" ]]; then
    printf '(missing)\n'
    return 0
  fi
  awk -v limit="$limit" '
    BEGIN { capture=0; count=0; matched=0 }
    /^#{1,6}[[:space:]]+/ {
      low = tolower($0)
      if (low ~ /build output|smoke output|raw command output|command output|file excerpt index|self-validation|risk ledger|untracked implementation surface|verification evidence|commands run|artifact changes|review handoff|verification|검증|변경|핸드오프/) {
        capture=1
        count=0
        matched=1
        print ""
        print $0
        next
      }
      if (capture) {
        capture=0
      }
    }
    capture && count < limit {
      print
      count++
    }
    END {
      if (!matched) {
        print "(no priority evidence sections matched)"
      }
    }
  ' "$file"
}

auto_review_evidence_paths() {
  {
    git diff --name-only --diff-filter=ACMRT 2>/dev/null || true
    git diff --cached --name-only --diff-filter=ACMRT 2>/dev/null || true
    git ls-files --others --exclude-standard 2>/dev/null || true
  } | while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    path="$(normalize_review_candidate_path "$path" || true)"
    [[ -n "$path" ]] || continue
    if is_reviewable_project_path "$path" && is_auto_review_candidate_path "$path"; then
      printf '%s\n' "$path"
    fi
  done
}

latest_commit_review_evidence_paths() {
  git rev-parse --verify HEAD >/dev/null 2>&1 || return 0
  git diff-tree --no-commit-id --name-only -r --diff-filter=ACMRT HEAD 2>/dev/null \
    | while IFS= read -r path; do
      [[ -n "$path" ]] || continue
      path="$(normalize_review_candidate_path "$path" || true)"
      [[ -n "$path" ]] || continue
      if is_reviewable_project_path "$path" && is_auto_review_candidate_path "$path" && review_evidence_file_exists "$path"; then
        printf '%s\n' "$path"
      fi
    done
}

current_sprint_handoff_evidence_paths() {
  local handoff_dir path
  handoff_dir="$(sfs_shared_handoff_dir "${SPRINT_ID}" "${NOW}" 2>/dev/null || true)"
  [[ -n "$handoff_dir" ]] || return 0
  for path in \
    "${handoff_dir}/report.md" \
    "${handoff_dir}/retro.md"; do
    path="$(normalize_review_candidate_path "$path" || true)"
    [[ -n "$path" ]] || continue
    if is_reviewable_project_path "$path" && is_auto_review_candidate_path "$path" && review_evidence_file_exists "$path"; then
      printf '%s\n' "$path"
    fi
  done
}

indexed_review_evidence_paths_uncached() {
  {
    extract_path_tokens_from_file "${IMPLEMENT_PATH}"
    extract_path_tokens_from_file "${PLAN_PATH}"
    extract_path_tokens_from_file "${LOG_PATH}"
  } | while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    path="$(normalize_review_candidate_path "$path" || true)"
    [[ -n "$path" ]] || continue
    expand_review_candidate_path "$path" | while IFS= read -r expanded; do
      expanded="$(normalize_review_candidate_path "$expanded" || true)"
      [[ -n "$expanded" ]] || continue
      if is_reviewable_project_path "$expanded" && is_auto_review_candidate_path "$expanded" && review_evidence_file_exists "$expanded"; then
        printf '%s\n' "$expanded"
      fi
    done
  done | awk '!seen[$0]++'
}

INDEXED_REVIEW_EVIDENCE_PATHS_CACHE_READY=false
INDEXED_REVIEW_EVIDENCE_PATHS_CACHE=""
indexed_review_evidence_paths() {
  if [[ "${INDEXED_REVIEW_EVIDENCE_PATHS_CACHE_READY}" != "true" ]]; then
    INDEXED_REVIEW_EVIDENCE_PATHS_CACHE="$(indexed_review_evidence_paths_uncached || true)"
    INDEXED_REVIEW_EVIDENCE_PATHS_CACHE_READY=true
  fi
  if [[ -n "${INDEXED_REVIEW_EVIDENCE_PATHS_CACHE}" ]]; then
    printf '%s\n' "${INDEXED_REVIEW_EVIDENCE_PATHS_CACHE}"
  fi
}

review_evidence_path_rank() {
  local path="$1"
  case "$path" in
    docs/solon/*/*/report.md|docs/solon/*/*/retro.md)
      printf '08\n'
      ;;
    docs/solon/decisions/*.md)
      printf '09\n'
      ;;
    .env.example|*/.env.example)
      printf '10\n'
      ;;
    */src/auth/*|*/src/materials/*|*/src/storage/*|*/src/*controller*|*/src/*service*|*/src/*module*|*/src/*route*|*/src/*resolver*)
      printf '20\n'
      ;;
    backend/src/*|api/src/*|server/src/*|apps/*/src/*|packages/*/src/*)
      printf '25\n'
      ;;
    package.json|package-lock.json|pnpm-lock.yaml|yarn.lock|bun.lockb|tsconfig.json|tsconfig.*.json|vite.config.*|next.config.*|nest-cli.json|.gitignore|*/package.json|*/package-lock.json|*/tsconfig.json|*/nest-cli.json)
      printf '30\n'
      ;;
    README.md|*/README.md)
      printf '40\n'
      ;;
    examples/*|*/examples/*|fixtures/*|*/fixtures/*|test/fixtures/*|tests/fixtures/*|src/data/*|*/src/data/*|src/domain/*|*/src/domain/*|*sample*|*example.json)
      printf '85\n'
      ;;
    src/*|*/src/*)
      printf '50\n'
      ;;
    *sample*|*example*)
      printf '85\n'
      ;;
    *)
      printf '65\n'
      ;;
  esac
}

is_full_small_review_evidence_path() {
  local path="$1"
  case "$path" in
    docs/solon/*/*/report.md|docs/solon/*/*/retro.md|docs/solon/decisions/*.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

sort_review_evidence_paths() {
  local path rank seq=0
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    seq=$((seq + 1))
    rank="$(review_evidence_path_rank "$path")"
    printf '%03d\t%06d\t%s\n' "$rank" "$seq" "$path"
  done | sort -k1,1n -k2,2n | cut -f3-
}

all_reviewable_evidence_paths() {
  {
    current_sprint_handoff_evidence_paths || true
    indexed_review_evidence_paths || true
    latest_commit_review_evidence_paths || true
    auto_review_evidence_paths || true
  } | awk '!seen[$0]++'
}

review_excerpt_priority_paths() {
  {
    current_sprint_handoff_evidence_paths | sort_review_evidence_paths
    indexed_review_evidence_paths | sort_review_evidence_paths
    latest_commit_review_evidence_paths | sort_review_evidence_paths
    auto_review_evidence_paths | sort_review_evidence_paths
  } | awk '!seen[$0]++'
}

first_class_review_evidence_paths() {
  local path rank
  {
    current_sprint_handoff_evidence_paths
    indexed_review_evidence_paths
    latest_commit_review_evidence_paths
  } | sort_review_evidence_paths | while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    rank="$(review_evidence_path_rank "$path")"
    if (( rank < 85 )); then
      printf '%s\n' "$path"
    fi
  done | awk '!seen[$0]++'
}

review_evidence_paths() {
  all_reviewable_evidence_paths
}

review_evidence_file_exists() {
  local path="$1"
  [[ -f "$path" ]]
}

review_evidence_file_is_text() {
  local path="$1"
  [[ -f "$path" ]] || return 1
  [[ -s "$path" ]] || return 0
  LC_ALL=C grep -Iq . "$path" 2>/dev/null
}

normalize_review_candidate_path() {
  local path="$1"
  path="${path#./}"
  path="${path#\"}"
  path="${path%\"}"
  path="${path#\'}"
  path="${path%\'}"
  path="${path#\`}"
  path="${path%\`}"
  path="$(printf '%s\n' "$path" | sed -E 's/[),.;]+$//; s/:[0-9]+(:[0-9]+)?$//')"
  case "$path" in
    ""|http://*|https://*|*"://"*|/*)
      return 1
      ;;
  esac
  printf '%s\n' "$path"
}

expand_review_candidate_path() {
  local path="$1" prefix
  path="${path#./}"
  case "$path" in
    */\*\*)
      prefix="${path%/\*\*}"
      ;;
    *\**)
      prefix="${path%%\**}"
      prefix="${prefix%/}"
      ;;
    *)
      if [[ -d "$path" ]]; then
        prefix="$path"
      else
        printf '%s\n' "$path"
        return 0
      fi
      ;;
  esac

  if [[ -n "${prefix:-}" && -d "$prefix" ]]; then
    find "$prefix" -type f 2>/dev/null | sed 's#^\./##' | sed -n "1,${REVIEW_DIR_EXPANSION_MAX}p"
  else
    printf '%s\n' "$path"
  fi
}

extract_path_tokens_from_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  awk '
    BEGIN { capture=0 }
    /^#{1,6}[[:space:]]+/ {
      low = tolower($0)
      capture = (low ~ /file excerpt index|source excerpt|implementation surface|changed files|changed artifacts|artifact changes made|acceptance criteria|cto generator|sprint ac|output paths|target paths|변경 파일|변경 파일\/모듈|산출물|cpo 에게 넘길 검증 포인트/)
      next
    }
    capture || /(^|[[:space:]`])([.]\/)?[A-Za-z0-9_.@%+=*-]+(\/[A-Za-z0-9_.@%+=*-]+)+(:[0-9]+(:[0-9]+)?)?([[:space:]`),.;]|$)/ || /(^|[[:space:]`])([.]gitignore|[A-Za-z0-9_.@%+=-]+[.][A-Za-z0-9_.@%+=-]+)(:[0-9]+(:[0-9]+)?)?([[:space:]`),.;]|$)/ {
      line = $0
      gsub(/[`"'\''()<>{}\[\],]/, " ", line)
      split(line, parts, /[[:space:]]+/)
      for (i in parts) {
        token = parts[i]
        sub(/[),.;]+$/, "", token)
        sub(/:[0-9]+(:[0-9]+)?$/, "", token)
        if (token ~ /^([.]\/)?[A-Za-z0-9_.@%+=*-]+(\/[A-Za-z0-9_.@%+=*-]+)+$/ ||
            token ~ /^([.]\/)?[.]gitignore$/ ||
            token ~ /^([.]\/)?[A-Za-z0-9_.@%+=-]+[.][A-Za-z0-9_.@%+=-]+$/) {
          print token
        }
      }
    }
  ' "$file"
}

extract_indexed_evidence_paths() {
  indexed_review_evidence_paths
}

is_review_path_token() {
  local token="$1"
  case "$token" in
    ./*)
      token="${token#./}"
      ;;
  esac
  case "$token" in
    ""|*/)
      return 1
      ;;
  esac
  case "$token" in
    .gitignore|*/*|*.*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

extract_indexed_evidence_targets_from_file() {
  local file="$1" raw path lines line_no root
  [[ -f "$file" ]] || return 0
  while IFS= read -r raw || [[ -n "$raw" ]]; do
    lines="$(printf '%s\n' "$raw" | grep -Eo 'line[[:space:]]+[0-9]+' | sed -E 's/line[[:space:]]+//' || true)"
    [[ -n "$lines" ]] || continue
    {
      printf '%s\n' "$raw" | grep -Eo '([.]\/)?[A-Za-z0-9_.@%+=-]+(/[A-Za-z0-9_.@%+=-]+)+' || true
      for root in .gitignore package.json package-lock.json pnpm-lock.yaml yarn.lock bun.lockb vite.config.ts vite.config.js vite.config.mjs tsconfig.json playwright.config.ts playwright.config.js; do
        case "$raw" in
          *"$root"*) printf '%s\n' "$root" ;;
        esac
      done
    } | awk '!seen[$0]++' | while IFS= read -r path; do
      [[ -n "$path" ]] || continue
      path="${path#./}"
      is_review_path_token "$path" || continue
      while IFS= read -r line_no; do
        [[ -n "$line_no" ]] || continue
        printf '%s:%s\n' "$path" "$line_no"
      done <<< "$lines"
    done
  done < "$file"
}

extract_indexed_evidence_targets() {
  {
    extract_indexed_evidence_targets_from_file "${IMPLEMENT_PATH}"
    extract_indexed_evidence_targets_from_file "${LOG_PATH}"
  } | while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    local path line_no
    path="${target%:*}"
    line_no="${target##*:}"
    case "$line_no" in
      ''|*[!0-9]*)
        continue
        ;;
    esac
    path="$(normalize_review_candidate_path "$path" || true)"
    [[ -n "$path" ]] || continue
    if is_reviewable_project_path "$path" && is_auto_review_candidate_path "$path"; then
      printf '%s:%s\n' "$path" "$line_no"
    fi
  done | awk '!seen[$0]++'
}

is_indexed_review_evidence_path() {
  local needle="$1" path
  while IFS= read -r path; do
    [[ "$path" == "$needle" ]] && return 0
  done < <(indexed_review_evidence_paths || true)
  return 1
}

is_ignored_review_path() {
  local path="$1"
  case "$path" in
    .idea|.idea/*|.vscode|.vscode/*|.fleet|.fleet/*|.zed|.zed/*|.settings|.settings/*|.project|.classpath|*.iml)
      return 0
      ;;
    .git|.git/*|*.git|*.git/*|.hg|.hg/*|.svn|.svn/*)
      return 0
      ;;
    node_modules|node_modules/*|vendor|vendor/*|Pods|Pods/*)
      return 0
      ;;
    dist|dist/*|*/dist|*/dist/*|build|build/*|*/build|*/build/*|out|out/*|*/out|*/out/*|target|target/*|*/target|*/target/*|coverage|coverage/*|*/coverage|*/coverage/*|*.tsbuildinfo)
      return 0
      ;;
    .next|.next/*|*/.next|*/.next/*|.nuxt|.nuxt/*|*/.nuxt|*/.nuxt/*|.svelte-kit|.svelte-kit/*|*/.svelte-kit|*/.svelte-kit/*|.vite|.vite/*|*/.vite|*/.vite/*|.turbo|.turbo/*|*/.turbo|*/.turbo/*|.cache|.cache/*|*/.cache|*/.cache/*|.parcel-cache|.parcel-cache/*|*/.parcel-cache|*/.parcel-cache/*)
      return 0
      ;;
    __pycache__|__pycache__/*|*/__pycache__|*/__pycache__/*|.pytest_cache|.pytest_cache/*|*/.pytest_cache|*/.pytest_cache/*|.mypy_cache|.mypy_cache/*|*/.mypy_cache|*/.mypy_cache/*|.ruff_cache|.ruff_cache/*|*/.ruff_cache|*/.ruff_cache/*|.gradle|.gradle/*|*/.gradle|*/.gradle/*)
      return 0
      ;;
    tmp|tmp/*|temp|temp/*|logs|logs/*)
      return 0
      ;;
    .DS_Store|Thumbs.db|Desktop.ini|*.log|*.tmp|*.temp|*.bak|*.swp|*.swo|*~)
      return 0
      ;;
    .env.example|*/.env.example)
      return 1
      ;;
    .env|.env.*|*/.env|*/.env.*|*.pem|*.key|*.p12|*.pfx|*.crt|*.cer)
      return 0
      ;;
    *.png|*.jpg|*.jpeg|*.gif|*.webp|*.ico|*.svg|*.pdf|*.zip|*.tar|*.gz|*.tgz|*.7z|*.mp4|*.mov|*.avi|*.db|*.sqlite|*.sqlite3)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_auto_review_candidate_path() {
  local path="$1"
  case "$path" in
    ""|*/)
      return 1
      ;;
  esac
  review_evidence_file_is_text "$path"
}

is_reviewable_project_path() {
  local path="$1"
  if is_sfs_managed_review_path "$path" || is_ignored_review_path "$path"; then
    return 1
  fi
  return 0
}

render_untracked_manifest() {
  local paths
  printf '\n### untracked file manifest\n\n'
  paths="$(git ls-files --others --exclude-standard 2>/dev/null \
    | while IFS= read -r path; do
      [[ -n "$path" ]] || continue
      path="$(normalize_review_candidate_path "$path" || true)"
      [[ -n "$path" ]] || continue
      if is_reviewable_project_path "$path" && is_auto_review_candidate_path "$path"; then
        printf '%s\n' "$path"
      fi
    done | awk '!seen[$0]++' || true)"
  if [[ -n "$paths" ]]; then
    printf '%s\n' "$paths" | sed -n '1,200p'
  else
    printf '(no untracked project artifact/source files detected)\n'
  fi
}

render_latest_commit_manifest() {
  local paths sha subject
  printf '\n### latest commit reviewable file manifest\n\n'
  if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    printf '(no git HEAD commit detected)\n'
    return 0
  fi
  sha="$(git rev-parse --short HEAD 2>/dev/null || echo "-")"
  subject="$(git log -1 --pretty=%s 2>/dev/null || true)"
  printf 'commit: %s %s\n\n' "$sha" "$subject"
  paths="$(latest_commit_review_evidence_paths | awk '!seen[$0]++' || true)"
  if [[ -n "$paths" ]]; then
    printf '%s\n' "$paths" | sed -n '1,200p'
  else
    printf '(latest commit has no reviewable project artifact/source files)\n'
  fi
}

render_current_sprint_handoff_manifest() {
  local paths handoff_dir
  printf '\n### current sprint shared handoff evidence manifest\n\n'
  handoff_dir="$(sfs_shared_handoff_dir "${SPRINT_ID}" "${NOW}" 2>/dev/null || true)"
  if [[ -n "$handoff_dir" ]]; then
    printf 'handoff_dir: %s\n\n' "$handoff_dir"
  fi
  paths="$(current_sprint_handoff_evidence_paths | awk '!seen[$0]++' || true)"
  if [[ -n "$paths" ]]; then
    printf '%s\n' "$paths" | sed -n '1,200p'
  else
    printf '(no current sprint shared report/retro evidence detected)\n'
  fi
}

render_reviewable_file_manifest() {
  local paths
  printf '\n### reviewable artifact/source file manifest\n\n'
  paths="$(all_reviewable_evidence_paths || true)"
  if [[ -n "$paths" ]]; then
    printf '%s\n' "$paths" | sed -n '1,200p'
  else
    printf '(no project artifact/source files detected)\n'
  fi
}

render_excerpt_priority_manifest() {
  local paths
  printf '\n### excerpt priority file list\n\n'
  printf 'Bounded source diffs/excerpts use this prioritized list. Declared implement.md/plan.md/log.md targets come before auto-discovered files; source slices and safe config evidence come before examples, fixtures, and sample data.\n\n'
  paths="$(review_excerpt_priority_paths || true)"
  if [[ -n "$paths" ]]; then
    printf '%s\n' "$paths" | sed -n '1,200p'
  else
    printf '(no project artifact/source files detected)\n'
  fi
}

render_review_git_status() {
  local output line path
  output="$(git status --porcelain=v1 2>/dev/null | while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    path="${line#???}"
    if [[ "$line" == R* || "$line" == C* ]]; then
      path="${path##* -> }"
    fi
    path="$(normalize_review_candidate_path "$path" || true)"
    [[ -n "$path" ]] || continue
    if is_reviewable_project_path "$path" && is_auto_review_candidate_path "$path"; then
      printf '%s\n' "$line"
    fi
  done || true)"
  if [[ -n "$output" ]]; then
    printf '%s\n' "$output"
  else
    printf '(no reviewable project git status entries; SFS/IDE/build metadata filtered)\n'
  fi
}

render_review_git_diff_stat() {
  local paths=() path cached unstaged
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if git ls-files --error-unmatch "$path" >/dev/null 2>&1; then
      paths+=("$path")
    fi
  done < <(review_evidence_paths || true)

  if (( ${#paths[@]} == 0 )); then
    printf '(no reviewable tracked project diff; untracked artifacts/sources are represented by manifest/excerpts below)\n'
    return 0
  fi

  cached="$(git diff --cached --stat -- "${paths[@]}" 2>/dev/null || true)"
  unstaged="$(git diff --stat -- "${paths[@]}" 2>/dev/null || true)"
  if [[ -n "$cached" ]]; then
    printf '#### staged reviewable diff stat\n\n%s\n' "$cached"
  fi
  if [[ -n "$unstaged" ]]; then
    printf '#### working-tree reviewable diff stat\n\n%s\n' "$unstaged"
  fi
  if [[ -z "$cached" && -z "$unstaged" ]]; then
    printf '(no tracked reviewable project diff; untracked artifacts/sources are represented by manifest/excerpts below)\n'
  fi
}

is_sfs_sprint_artifact_path() {
  local path="$1"
  case "$path" in
    .sfs-local/sprints/*|.sfs-local/decisions/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

render_sfs_scope_classification() {
  local system_paths mixed_paths sprint_paths line path
  printf '\n### SFS/system scope classification\n\n'
  system_paths="$({
    git status --porcelain=v1 2>/dev/null | while IFS= read -r line; do
      [[ -n "$line" ]] || continue
      path="${line#???}"
      if [[ "$line" == R* || "$line" == C* ]]; then
        path="${path##* -> }"
      fi
      printf '%s\n' "$path"
    done
    git ls-files --others --exclude-standard 2>/dev/null || true
  } | while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    path="$(normalize_review_candidate_path "$path" || true)"
    [[ -n "$path" ]] || continue
    if is_sfs_managed_review_path "$path" && ! is_sfs_sprint_artifact_path "$path"; then
      printf '%s\n' "$path"
    fi
  done | awk '!seen[$0]++' | sed -n '1,120p' || true)"
  mixed_paths="$(git status --porcelain=v1 2>/dev/null | while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    path="${line#???}"
    if [[ "$line" == R* || "$line" == C* ]]; then
      path="${path##* -> }"
    fi
    path="$(normalize_review_candidate_path "$path" || true)"
    [[ "$path" == ".gitignore" ]] || continue
    printf '%s\n' "$path"
  done | awk '!seen[$0]++' | sed -n '1,20p' || true)"
  sprint_paths="$(git status --porcelain=v1 2>/dev/null | while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    path="${line#???}"
    if [[ "$line" == R* || "$line" == C* ]]; then
      path="${path##* -> }"
    fi
    path="$(normalize_review_candidate_path "$path" || true)"
    [[ -n "$path" ]] || continue
    if is_sfs_sprint_artifact_path "$path"; then
      printf '%s\n' "$path"
    fi
  done | awk '!seen[$0]++' | sed -n '1,120p' || true)"

  printf 'SFS/runtime/adapter files are filtered out of product artifact/source diffs and should be treated as Solon system state, not as the sprint product slice, unless this sprint explicitly targets SFS itself.\n\n'
  printf '#### SFS-managed system/runtime changes filtered from product scope\n\n'
  if [[ -n "$system_paths" ]]; then
    printf '%s\n' "$system_paths"
  else
    printf '(none detected)\n'
  fi
  printf '\n#### Mixed product/system files included with product-owned evidence\n\n'
  if [[ -n "$mixed_paths" ]]; then
    printf '%s — only content outside the solon-product managed block is product-owned evidence; the managed block remains SFS system scope.\n' "$mixed_paths"
  else
    printf '(none detected)\n'
  fi
  printf '\n#### Sprint evidence artifacts embedded separately\n\n'
  if [[ -n "$sprint_paths" ]]; then
    printf '%s\n' "$sprint_paths"
  else
    printf '(none detected in git status; current sprint files are still embedded by path below when present)\n'
  fi
}

render_review_file_excerpt() {
  local file="$1" limit="${2:-120}" bytes line_count
  printf '\n### source excerpt: %s\n\n' "$file"
  if [[ ! -f "$file" ]]; then
    printf '(missing or not a regular file)\n'
    return 0
  fi
  bytes="$(wc -c < "$file" 2>/dev/null | tr -d '[:space:]' || printf '0')"
  if [[ "$bytes" == "0" ]]; then
    printf '(empty file)\n'
    return 0
  fi
  if ! LC_ALL=C grep -Iq . "$file" 2>/dev/null; then
    printf '(binary or non-text file skipped; %s bytes)\n' "$bytes"
    return 0
  fi
  line_count="$(count_file_lines "$file")"
  if is_full_small_review_evidence_path "$file" && (( line_count > 0 && line_count <= REVIEW_SMALL_FILE_EXCERPT_LINES )); then
    limit="$line_count"
    printf '(first-class review target; full file included: %s lines)\n\n' "$line_count"
  fi
  if (( bytes > 131072 )); then
    printf '(large file: %s bytes; showing first %s lines)\n\n' "$bytes" "$limit"
  fi
  if [[ "$file" == ".gitignore" ]]; then
    printf '(mixed product/system file; showing product-owned lines outside ### BEGIN/END solon-product blocks)\n\n'
    awk '
      /^### BEGIN solon-product ###$/ { in_managed=1; next }
      /^### END solon-product ###$/ { in_managed=0; next }
      !in_managed { print }
    ' "$file" | sed -n "1,${limit}p"
    return 0
  fi
  sed -n "1,${limit}p" "$file"
}

render_review_file_line_excerpt() {
  local file="$1" line_no="$2" radius="${3:-32}" line_count start end bytes
  printf '\n### indexed source excerpt: %s around line %s\n\n' "$file" "$line_no"
  if [[ ! -f "$file" ]]; then
    printf '(missing or not a regular file)\n'
    return 0
  fi
  bytes="$(wc -c < "$file" 2>/dev/null | tr -d '[:space:]' || printf '0')"
  if [[ "$bytes" == "0" ]]; then
    printf '(empty file)\n'
    return 0
  fi
  if ! LC_ALL=C grep -Iq . "$file" 2>/dev/null; then
    printf '(binary or non-text file skipped; %s bytes)\n' "$bytes"
    return 0
  fi
  line_count="$(count_file_lines "$file")"
  if (( line_no < 1 )); then
    line_no=1
  fi
  if (( line_count > 0 && line_no > line_count )); then
    printf '(line %s is outside file length %s; showing tail)\n\n' "$line_no" "$line_count"
    line_no="$line_count"
  fi
  start=$(( line_no - radius ))
  end=$(( line_no + radius ))
  if (( start < 1 )); then
    start=1
  fi
  if (( line_count > 0 && end > line_count )); then
    end="$line_count"
  fi
  printf '```text\n'
  nl -ba "$file" | sed -n "${start},${end}p"
  printf '```\n'
}

filter_gitignore_product_diff() {
  awk '
    BEGIN {
      in_managed=0
      emitted_meta=0
      emitted=0
      meta=""
      hunk=""
    }
    /^diff --git / || /^index / || /^--- / || /^\+\+\+ / {
      meta = meta $0 ORS
      next
    }
    /^@@/ {
      hunk = $0
      next
    }
    /^[-+]### BEGIN solon-product ###$/ {
      in_managed=1
      next
    }
    /^[-+]### END solon-product ###$/ {
      in_managed=0
      next
    }
    {
      if (in_managed) {
        next
      }
      if ($0 ~ /^[-+][[:space:]]*$/) {
        next
      }
      if ($0 ~ /^[-+]/) {
        if (!emitted_meta && meta != "") {
          printf "%s", meta
          emitted_meta=1
        }
        if (hunk != "") {
          print hunk
          hunk=""
        }
        print
        emitted=1
      }
    }
    END {
      if (!emitted) {
        exit 1
      }
    }
  '
}

render_review_file_diff() {
  local file="$1" limit="${2:-180}" staged unstaged
  printf '\n### source diff: %s\n\n' "$file"
  if [[ ! -e "$file" ]]; then
    printf '(missing; no diff available)\n'
    return 0
  fi
  if [[ "$file" == ".gitignore" ]]; then
    printf '(mixed product/system file; showing product-owned changed lines only. Solon managed block internals and blank-only churn are omitted.)\n\n'
    staged="$(git diff --cached --no-ext-diff -U0 -- "$file" 2>/dev/null | filter_gitignore_product_diff | sed -n "1,${limit}p" || true)"
    unstaged="$(git diff --no-ext-diff -U0 -- "$file" 2>/dev/null | filter_gitignore_product_diff | sed -n "1,${limit}p" || true)"
    if [[ -n "$staged" ]]; then
      printf '#### staged product-owned diff\n\n```diff\n%s\n```\n' "$staged"
    fi
    if [[ -n "$unstaged" ]]; then
      printf '#### working tree product-owned diff\n\n```diff\n%s\n```\n' "$unstaged"
    fi
    if [[ -z "$staged" && -z "$unstaged" ]]; then
      printf '(no product-owned .gitignore diff outside the solon-product managed block)\n'
    fi
    return 0
  fi
  staged="$(git diff --cached --no-ext-diff -- "$file" 2>/dev/null | sed -n "1,${limit}p" || true)"
  unstaged="$(git diff --no-ext-diff -- "$file" 2>/dev/null | sed -n "1,${limit}p" || true)"
  if [[ -n "$staged" ]]; then
    printf '#### staged diff\n\n```diff\n%s\n```\n' "$staged"
  fi
  if [[ -n "$unstaged" ]]; then
    printf '#### working tree diff\n\n```diff\n%s\n```\n' "$unstaged"
  fi
  if [[ -z "$staged" && -z "$unstaged" ]]; then
    if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
      printf '(tracked file has no working-tree diff; source excerpt included because sprint evidence referenced it)\n'
    else
      printf '(untracked file; no git diff available; source excerpt below is the review evidence)\n'
    fi
  fi
}

render_review_file_diffs() {
  local max="${REVIEW_FILE_EXCERPT_MAX}" lines="${REVIEW_DIFF_LINES}" count=0 path paths
  printf '\n### bounded artifact/source diffs for reviewable files\n\n'
  paths="$(review_excerpt_priority_paths || true)"
  if [[ -z "$paths" ]]; then
    printf '(no project artifact/source files detected)\n'
    return 0
  fi
  printf '%s\n' "$paths" | while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    count=$((count + 1))
    if (( count > max )); then
      if (( count == max + 1 )); then
        printf '\n(diff limit reached: showing first %s files; see manifest above for the rest)\n' "$max"
      fi
      continue
    fi
    render_review_file_diff "$path" "$lines"
  done
}

render_review_file_excerpts() {
  local max="${REVIEW_FILE_EXCERPT_MAX}" lines="${REVIEW_FILE_EXCERPT_LINES}" count=0 path paths
  printf '\n### bounded artifact/source excerpts for reviewable files\n\n'
  paths="$(review_excerpt_priority_paths || true)"
  if [[ -z "$paths" ]]; then
    printf '(no project artifact/source files detected)\n'
    return 0
  fi
  printf '%s\n' "$paths" | while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    count=$((count + 1))
    if (( count > max )); then
      if (( count == max + 1 )); then
        printf '\n(excerpt limit reached: showing first %s files; see manifest above for the rest)\n' "$max"
      fi
      continue
    fi
    render_review_file_excerpt "$path" "$lines"
  done
}

render_first_class_review_file_excerpts() {
  local max="${REVIEW_FIRST_CLASS_EXCERPT_MAX}" lines="${REVIEW_FILE_EXCERPT_LINES}" count=0 path paths
  printf '\n### declared first-class source/config excerpts\n\n'
  printf 'Declared implement.md/plan.md/log.md artifact/source/config targets are included here before the generic first-N excerpt cap is applied. Build outputs, generated dist/build folders, SFS runtime files, examples, fixtures, and sample data are not first-class review excerpts.\n\n'
  paths="$(first_class_review_evidence_paths || true)"
  if [[ -z "$paths" ]]; then
    printf '(no first-class source/config targets detected)\n'
    return 0
  fi
  printf '%s\n' "$paths" | while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    count=$((count + 1))
    if (( count > max )); then
      if (( count == max + 1 )); then
        printf '\n(first-class excerpt limit reached: showing first %s declared source/config files)\n' "$max"
      fi
      continue
    fi
    render_review_file_excerpt "$path" "$lines"
  done
}

render_indexed_target_source_excerpts() {
  local radius="${REVIEW_TARGET_EXCERPT_RADIUS}" max="${REVIEW_INDEXED_TARGET_MAX}" count=0 target path line_no targets
  printf '\n### indexed target source excerpts\n\n'
  targets="$(extract_indexed_evidence_targets || true)"
  if [[ -z "$targets" ]]; then
    printf '(no line-targeted source excerpts found in implement.md/log.md index)\n'
    return 0
  fi
  printf '%s\n' "$targets" | while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    count=$((count + 1))
    if (( count > max )); then
      if (( count == max + 1 )); then
        printf '\n(indexed target excerpt limit reached: showing first %s targets)\n' "$max"
      fi
      continue
    fi
    path="${target%:*}"
    line_no="${target##*:}"
    render_review_file_line_excerpt "$path" "$line_no" "$radius"
  done
}

render_evidence_bundle() {
  printf '## Embedded Evidence Bundle\n\n'
  printf 'The following evidence was collected by SFS before invoking the executor. Review this embedded evidence first; do not assume your CLI has project file/tool access. If evidence is insufficient, return partial/fail and list the missing evidence instead of calling unsupported tools.\n\n'

  printf '### git status --short (review-filtered)\n\n'
  render_review_git_status

  printf '\n### git diff --stat (review-filtered)\n\n'
  render_review_git_diff_stat

  render_sfs_scope_classification

  render_untracked_manifest
  render_latest_commit_manifest
  render_current_sprint_handoff_manifest
  render_reviewable_file_manifest
  render_excerpt_priority_manifest
  render_priority_evidence_sections "${IMPLEMENT_PATH}" 120
  render_evidence_file "${BRAINSTORM_PATH}" 220
  render_evidence_file "${PLAN_PATH}" 260
  render_evidence_file "${IMPLEMENT_PATH}" 420
  render_evidence_file "${LOG_PATH}" 260
  render_review_file_diffs
  render_indexed_target_source_excerpts
  render_first_class_review_file_excerpts
  render_review_file_excerpts
  printf '\n### review.md note\n\n'
  printf 'Only the first 80 lines of review.md are embedded to prevent recursive prompt growth. Full CPO prompts live under .sfs-local/tmp/review-prompts/.\n'
  render_evidence_file "${REVIEW_PATH}" 80
}

is_sfs_managed_review_path() {
  local path="$1"
  path="${path#\"}"
  path="${path%\"}"
  case "$path" in
    .sfs-local/*|.claude/commands/sfs.md|.claude/skills/sfs|.claude/skills/sfs/*|.gemini/commands/sfs.toml|.agents/skills/sfs/SKILL.md|.codex/prompts/sfs.md)
      return 0
      ;;
    SFS.md|CLAUDE.md|AGENTS.md|GEMINI.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

reviewable_git_paths() {
  git status --porcelain=v1 2>/dev/null | while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local path
    path="${line#???}"
    case "$line" in
      R*|C*) path="${path##* -> }" ;;
    esac
    path="$(normalize_review_candidate_path "$path" || true)"
    [[ -n "$path" ]] || continue
    if is_reviewable_project_path "$path"; then
      printf '%s\n' "$path"
    fi
  done
}

sprint_artifact_events_exist() {
  [[ -f "${SFS_EVENTS_FILE}" ]] || return 1
  grep -E '"type":"(brainstorm_open|plan_open|decision_created)"' "${SFS_EVENTS_FILE}" \
    | grep -q "\"sprint_id\":\"${SPRINT_ID}\""
}

implementation_evidence_exists() {
  local event_line
  event_line=""
  if [[ -f "${SFS_EVENTS_FILE}" ]]; then
    event_line="$(grep -F '"type":"implement_open"' "${SFS_EVENTS_FILE}" 2>/dev/null \
      | grep -F "\"sprint_id\":\"${SPRINT_ID}\"" \
      | sed -n '1p' || true)"
  fi
  if [[ -n "$event_line" ]]; then
    return 0
  fi
  if [[ -f "${IMPLEMENT_PATH}" ]] && grep -Eiq 'ready-for-review|Ready for review\?\*\*[[:space:]]*yes|Build output|Smoke output|File excerpt index|Commands run|npm run|passed' "${IMPLEMENT_PATH}"; then
    return 0
  fi
  if [[ -f "${LOG_PATH}" ]] && grep -Eiq '실행한 테스트|smoke|build|passed|구현 executor/tool' "${LOG_PATH}"; then
    return 0
  fi
  return 1
}

has_review_items() {
  local first_project_path=""
  first_project_path="$(reviewable_git_paths | sed -n '1p' || true)"
  if [[ -n "$first_project_path" ]]; then
    return 0
  fi

  # Planning gates may review sprint artifacts. Implementation/release gates
  # should not spend executor tokens when there is no project change.
  case "${GATE_ID}" in
    G-1|G0|G1|G2|G3)
      sprint_artifact_events_exist && return 0
      ;;
    G4)
      implementation_evidence_exists && return 0
      ;;
  esac

  return 1
}

render_lens_guidance() {
  cat <<EOF
Review lens: ${REVIEW_LENS} (${REVIEW_LENS_LABEL}; source=${REVIEW_LENS_SOURCE})

Lens policy:
- sfs review is an artifact acceptance review. Code review is only the
  code lens, not the default meaning of review.
- GitHub @codex PR/code review is external code-review evidence only. A PR
  approval, GitHub check PASS, or @codex comment does not satisfy self-CPO,
  SFS cross review, sfs review, Gate 3, or Gate 6 PASS by itself.
- Judge the produced artifact against the CEO plan, Gate 2/3 contract, evidence,
  user value, scope, risk, and next action.
- Do not force source-code findings when the selected lens is docs, source-docs,
  simplify, security, performance, api-contract, strategy, design, taxonomy,
  QA, ops, management-admin, release, or generic artifact acceptance.

Lens-specific checklist:
EOF
  case "${REVIEW_LENS}" in
    code)
      cat <<'EOF'
- Check correctness, regressions, failure paths, interfaces, tests, and maintainability.
- Use source diffs/excerpts as first-class evidence.
EOF
      ;;
    docs)
      cat <<'EOF'
- Check whether the document is accurate, complete enough, navigable, and consistent with project terminology.
- Treat unclear audience, stale instructions, missing examples, or misleading next steps as findings.
EOF
      ;;
    source-docs)
      cat <<'EOF'
- Check whether implementation or guidance claims are grounded in official/current upstream docs, release notes, schemas, or source-of-truth files.
- Treat unsourced framework/library assumptions, stale copied recipes, and missing version/date evidence as findings.
- Prefer the smallest cited primary source that proves the behavior; do not ask for broad research when one official source would settle it.
EOF
      ;;
    simplify)
      cat <<'EOF'
- Check whether the change removes accidental complexity without changing behavior, public contracts, or needed observability.
- Treat needless abstractions, duplicate branches, dead code left behind, and migration paths without a rollback/compatibility note as findings.
- Require evidence that the simplification is behavior-preserving, such as focused tests, unchanged outputs, or explicit non-goals.
EOF
      ;;
    security)
      cat <<'EOF'
- Check auth boundaries, secret handling, untrusted input, PII exposure, permission scope, and failure modes.
- Treat missing threat assumptions, overly broad privileges, logging of sensitive values, or absent negative tests as findings.
- Keep findings concrete: identify the attacker/input, affected surface, and required mitigation or evidence.
EOF
      ;;
    performance)
      cat <<'EOF'
- Check baseline evidence, target metric, hot path realism, resource use, and regression risk.
- Treat unmeasured optimization claims, synthetic-only proof, bundle/runtime growth, or missing rollback thresholds as findings.
- Prefer measurement-backed recommendations over speculative micro-optimizations.
EOF
      ;;
    api-contract)
      cat <<'EOF'
- Check public interfaces, request/response schemas, error semantics, backward compatibility, versioning, and migration notes.
- Treat breaking changes without explicit version/migration handling, ambiguous nullability, or undocumented error behavior as findings.
- Verify generated docs, examples, and tests agree with the actual contract.
EOF
      ;;
    strategy)
      cat <<'EOF'
- Check product intent, trade-offs, priority, non-goals, stakeholder/user impact, and decision clarity.
- Treat unsupported assumptions or vague success metrics as findings.
EOF
      ;;
    design)
      cat <<'EOF'
- Check interaction clarity, UX states, accessibility, design-system fit, and handoff completeness.
- Treat visual or flow ambiguity as acceptance risk, even without code defects.
- Check design.md/token adherence when a design contract exists. Treat token drift, mixed icon styles, arbitrary spacing/radius, and generic AI-slop visual language as review evidence.
EOF
      ;;
    taxonomy)
      cat <<'EOF'
- Check naming, glossary consistency, state/enum boundaries, aliases, schema implications, and migration notes.
- Treat term drift as a product risk, not a cosmetic issue.
EOF
      ;;
    qa)
      cat <<'EOF'
- Check AC-linked verification, regression coverage, boundary cases, evidence quality, and release confidence.
- Treat missing reproducible checks as an evidence gap.
EOF
      ;;
    ops)
      cat <<'EOF'
- Check deployability, secrets hygiene, rollback, observability, runbook clarity, and operational blast radius.
- Treat missing recovery or environment evidence as an acceptance risk.
EOF
      ;;
    management-admin)
      cat <<'EOF'
- Check finance/admin evidence, bookkeeping traceability, tax/accounting questions, cash impact, and advisor escalation boundaries.
- Treat missing source documents, owner decisions, or compliance-sensitive assumptions as acceptance risk.
EOF
      ;;
    release)
      cat <<'EOF'
- Check versioning, changelog clarity, packaged files, install/upgrade paths, Homebrew/Scoop or channel readiness, and rollback notes.
- Treat channel drift or unverifiable install freshness as blocking release evidence.
EOF
      ;;
    *)
      cat <<'EOF'
- Check the artifact's fitness for purpose, evidence, scope control, terminology, boundaries, and handoff clarity.
- If the artifact type is unclear, return partial and request the smallest missing evidence.
EOF
      ;;
  esac
  cat <<'EOF'

Next-action policy:
- `pass`: name `/sfs retro` as the normal close path. `retro` ensures
  `report.md`, opens/refines `retro.md`, archives noisy workbench state, and
  closes the sprint. Mention `/sfs report` only when the user explicitly wants
  a report preview or wants to rebuild a past report without closing.
- `partial`: name the smallest rework slice and whether to rerun `/sfs review`.
- `fail`: name whether to return to `/sfs plan`, redo implementation, or escalate to the user.

EOF
}

render_cpo_prompt() {
  local persona_note
  if [[ -f "${PERSONA_PATH}" ]]; then
    persona_note="Use persona file: ${PERSONA_PATH}"
  else
    persona_note="Persona file missing: ${PERSONA_PATH}. Use built-in CPO Evaluator policy from review.md."
  fi
  cat <<EOF
You are the Solon CPO Evaluator.

${persona_note}

Model routing contract:
- SFS model tiers are role/profile targets, not a requirement that the executor CLI supports a --model flag.
- Act under the requested evaluator role using the highest configured host/runtime profile available for this review.
- If the host/runtime cannot provide the required advisor/CPO profile, report that as an executor/auth/profile bridge issue instead of silently downgrading the gate verdict.
- For Codex CPO/cross review, the requested review_high profile is gpt-5.5 with xhigh reasoning.
- Codex gpt-5.4 worker, gpt-5.3-codex coding-helper, and gpt-5.3-codex-spark mechanical-helper profiles are not acceptable as the CPO/cross-review profile.
- The default Codex shell bridge does not force model selection with CLI flags; configure the host/runtime profile, or set SFS_REVIEW_CODEX_CMD explicitly only if your Codex CLI supports those flags.
- Runtime Token Firewall applies to this review: the executor receives this
  capsule prompt and embedded evidence only. Do not use a Claude in-process
  Codex/Gemini plugin, rescue subagent, forked context, or wrapper that forwards
  the lead agent's full conversation history. If this capsule is insufficient,
  return partial/fail and list the missing artifact instead of asking for the
  whole chat.

Review gate: ${GATE_DISPLAY}
Review lens: ${REVIEW_LENS} (${REVIEW_LENS_LABEL}; source=${REVIEW_LENS_SOURCE})
Sprint: ${SPRINT_ID}
Generator executor/tool: ${GENERATOR_EXECUTOR}
Evaluator executor/tool: ${EVALUATOR_EXECUTOR}

Self-validation policy:
- Do not rubber-stamp CTO Generator output.
- If this review is running in the same tool/session that generated the implementation, explicitly call that out as a risk.
- Prefer independent review evidence from Codex/Gemini/another agent instance when implementation was produced by Claude.
- Advisor calls are not a self-CPO PASS. For Gate 3 cross review, require local self-CPO evidence first: pass/partial/fail, requirements-to-AC-to-slice-to-ADR traceability, AC-to-file/artifact/evidence mapping, and SEED/placeholder/mock/fallback material treated as fail/partial/non-acceptance until replaced. If absent, return partial and request the self-CPO pass before external cross review.
- GitHub PR/@codex code review is not an SFS gate verdict. Treat GitHub review comments, PR approvals, and GitHub check PASS as external evidence only; they do not satisfy self-CPO, SFS cross review, `sfs review`, Gate 3, or Gate 6 PASS unless SFS review explicitly records that verdict or the user waives the gate.
- Treat same-tool review risk as review_independence_risk: warning unless the evidence proves a concrete product or evidence-bundle defect. Do not make same-tool risk the sole blocker for artifact quality.
- Separate artifact quality findings from evidence-bundle gaps. If the embedded bundle lacks required artifact files, acceptance evidence, build/smoke output, or source excerpts needed for this lens, say that explicitly as an evidence packaging gap.
- Treat File excerpt index paths as first-class review targets. The bundle should include bounded source diffs and excerpts for those paths when files are available.
- Treat the "declared first-class source/config excerpts" section as the primary artifact/source/config evidence; the generic first-N excerpt cap should not hide declared source/config targets.
- Treat SFS/runtime/adapter files listed under SFS/system scope classification as Solon system state, not product implementation scope, unless this sprint explicitly targets SFS itself.
- Code review is only the code lens. For every other lens, review the artifact/outcome without inventing code-level findings.

Review the lens guidance and embedded evidence below. Do not rely on executor-specific tools being available.

EOF
  render_lens_guidance
  render_evidence_bundle
  cat <<'EOF'

Return exactly this shape:
Verdict: pass | partial | fail
Review lens: <lens>
Review independence risk: none | warning | blocking
Artifact quality verdict:
- ...
Evidence bundle verdict:
- ...
Evidence checked:
- ...
Evidence gaps:
- ...
Findings:
- ...
Required CTO actions:
- ...
Next action:
- ...
Final recommendation:
- ...
EOF
}

history_forwarding_executor_cmd() {
  local cmd="${1:-}"
  case "${cmd}" in
    *codex-rescue*|*codex:codex*|*claude*plugin*codex*|*claude*codex*plugin*|*fork_context=true*|*fork_context[=:]true*|*full-history*|*full_history*|*conversation-history*|*conversation_history*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

reject_history_forwarding_executor() {
  local source="${1:-executor command}"
  cat >&2 <<EOF
history-forwarding review bridge rejected: ${source}
Runtime Token Firewall requires capsule-only executor handoff.

Do not route SFS review through Claude in-process Codex/Gemini plugin wrappers,
rescue subagents, forked contexts, or commands that forward the lead
conversation history. Use one of:
  - sfs review --gate <1..7> --executor codex
  - SFS_REVIEW_CODEX_CMD='codex exec --full-auto --ephemeral --output-last-message "\${RUN_RESULT}" -'
  - sfs review --gate <1..7> --executor codex --prompt-only
EOF
}

resolve_review_executor_cmd() {
  case "${EVALUATOR_EXECUTOR}" in
    codex|codex-cli)
      if [[ -n "${SFS_REVIEW_CODEX_CMD:-}" ]]; then
        if history_forwarding_executor_cmd "${SFS_REVIEW_CODEX_CMD}"; then
          reject_history_forwarding_executor "SFS_REVIEW_CODEX_CMD"
          return "${SFS_EXIT_EXECUTOR}"
        fi
        case "${SFS_REVIEW_CODEX_CMD}" in
          *WindowsApps*OpenAI.Codex*app*resources*codex.exe*)
            cat >&2 <<'EOF'
executor bridge unsupported: SFS_REVIEW_CODEX_CMD points at the Windows Store package-private codex.exe.
Windows commonly denies direct execution from:
  C:\Program Files\WindowsApps\OpenAI.Codex_...\app\resources\codex.exe

Use the App Execution Alias or another accessible shim instead, for example:
  SFS_REVIEW_CODEX_CMD='codex exec --full-auto --ephemeral --output-last-message "${RUN_RESULT}" -'

If the alias is not visible from Git Bash, use the per-user alias path:
  /c/Users/<you>/AppData/Local/Microsoft/WindowsApps/codex.exe
EOF
            return "${SFS_EXIT_EXECUTOR}"
            ;;
        esac
        printf '%s\n' "${SFS_REVIEW_CODEX_CMD}"
      elif command -v codex >/dev/null 2>&1; then
        prepare_executor_auth "codex" "${AUTH_INTERACTIVE}" || return "${SFS_EXIT_EXECUTOR}"
        printf '%s\n' "codex exec --full-auto --ephemeral --output-last-message \"${RUN_RESULT}\" -"
      else
        executor_cli_missing_hint "codex"
        return "${SFS_EXIT_EXECUTOR}"
      fi
      ;;
    codex-plugin)
      cat >&2 <<'EOF'
executor bridge unsupported: codex-plugin/Claude in-process Codex wrappers are blocked by Runtime Token Firewall.
They can forward main-thread conversation history and make review cost scale
with the lead Claude session instead of the SFS evidence capsule.

Use `--executor codex` with the Codex CLI, set SFS_REVIEW_CODEX_CMD to a
capsule-only stdin/file bridge, or run `--prompt-only` and paste the generated
prompt into Codex manually.
EOF
      return "${SFS_EXIT_EXECUTOR}"
      ;;
    gemini)
      if [[ -n "${SFS_REVIEW_GEMINI_CMD:-}" ]]; then
        printf '%s\n' "${SFS_REVIEW_GEMINI_CMD}"
      elif command -v gemini >/dev/null 2>&1; then
        prepare_executor_auth "gemini" "${AUTH_INTERACTIVE}" || return "${SFS_EXIT_EXECUTOR}"
        printf '%s\n' 'gemini --skip-trust --output-format text -p "Read stdin and perform the requested CPO review."'
      else
        executor_cli_missing_hint "gemini"
        return "${SFS_EXIT_EXECUTOR}"
      fi
      ;;
    claude)
      if [[ -n "${SFS_REVIEW_CLAUDE_CMD:-}" ]]; then
        printf '%s\n' "${SFS_REVIEW_CLAUDE_CMD}"
      elif command -v claude >/dev/null 2>&1; then
        prepare_executor_auth "claude" "${AUTH_INTERACTIVE}" || return "${SFS_EXIT_EXECUTOR}"
        printf '%s\n' 'claude -p "$(cat)"'
      else
        executor_cli_missing_hint "claude"
        return "${SFS_EXIT_EXECUTOR}"
      fi
      ;;
    claude-plugin)
      echo "executor bridge unsupported: Codex is not a Claude plugin host; use --executor claude with Claude CLI, set SFS_REVIEW_CLAUDE_CMD, or run --print-prompt and paste into Claude" >&2
      return "${SFS_EXIT_EXECUTOR}"
      ;;
    *)
      printf '%s\n' "${EVALUATOR_EXECUTOR}"
      ;;
  esac
}

review_bridge_probe_enabled() {
  local profile
  case "${REVIEW_BRIDGE_PROBE}" in
    0|false|FALSE|no|NO|off|OFF) return 1 ;;
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
  esac
  profile="$(normalize_executor_profile "${EVALUATOR_EXECUTOR}")"
  case "${profile}" in
    claude|codex|gemini) return 0 ;;
    *) return 1 ;;
  esac
}

resolve_review_bridge_probe_cmd() {
  local profile="$1" result_path="$2"
  case "${profile}" in
    codex)
      if [[ -n "${SFS_REVIEW_CODEX_CMD:-}" ]]; then
        printf '%s\n' "${SFS_REVIEW_CODEX_CMD}"
      else
        printf 'codex exec --full-auto --ephemeral --output-last-message "%s" -\n' "${result_path}"
      fi
      ;;
    gemini)
      if [[ -n "${SFS_REVIEW_GEMINI_CMD:-}" ]]; then
        printf '%s\n' "${SFS_REVIEW_GEMINI_CMD}"
      else
        printf '%s\n' 'gemini --skip-trust --output-format text -p "Return exactly: SFS_REVIEW_BRIDGE_PROBE_OK"'
      fi
      ;;
    claude)
      if [[ -n "${SFS_REVIEW_CLAUDE_CMD:-}" ]]; then
        printf '%s\n' "${SFS_REVIEW_CLAUDE_CMD}"
      else
        printf '%s\n' 'claude -p "$(cat)"'
      fi
      ;;
    *)
      return 1
      ;;
  esac
}

if [[ -n "${EVALUATOR_EXECUTOR}" && -n "${GENERATOR_EXECUTOR}" && "${EVALUATOR_EXECUTOR}" == "${GENERATOR_EXECUTOR}" ]]; then
  echo "warning: evaluator executor equals generator executor (${EVALUATOR_EXECUTOR}); self-validation risk" >&2
fi

PROMPT_DIR="${SFS_LOCAL_DIR}/tmp/review-prompts"
RUN_DIR="${SFS_LOCAL_DIR}/tmp/review-runs"
PROMPT_TS="$(date -u +%Y%m%dT%H%M%SZ)"
PROMPT_ID="${PROMPT_TS}-$$"
PROMPT_INVOCATION_DIR="${PROMPT_DIR}/${SPRINT_ID}-${GATE_ARTIFACT_ID}-${PROMPT_ID}"
RUN_INVOCATION_DIR="${RUN_DIR}/${SPRINT_ID}-${GATE_ARTIFACT_ID}-${PROMPT_ID}"
PROMPT_PATH="${PROMPT_INVOCATION_DIR}/prompt.txt"

discard_prior_review_scratch() {
  local prefix="${SPRINT_ID}-${GATE_ARTIFACT_ID}-"
  local path

  [[ "${SFS_REVIEW_CLEAN_SCRATCH:-false}" == "true" ]] || return "${SFS_EXIT_OK}"
  for path in "${PROMPT_DIR}/${prefix}"* "${RUN_DIR}/${prefix}"*; do
    [[ -e "${path}" ]] || continue
    [[ "${path}" == "${PROMPT_INVOCATION_DIR}" || "${path}" == "${RUN_INVOCATION_DIR}" ]] && continue
    if [[ -d "${path}" ]]; then
      rm -rf "${path}" || return "${SFS_EXIT_PERM}"
    else
      rm -f "${path}" || return "${SFS_EXIT_PERM}"
    fi
  done
  return "${SFS_EXIT_OK}"
}

count_file_lines() {
  local file="$1"
  if [[ -f "$file" ]]; then
    wc -l < "$file" | tr -d '[:space:]'
  else
    printf '0'
  fi
}

count_file_bytes() {
  local file="$1"
  if [[ -f "$file" ]]; then
    wc -c < "$file" | tr -d '[:space:]'
  else
    printf '0'
  fi
}

has_strict_verdict() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  grep -Eiq '^[[:space:]>-]*Verdict:[[:space:]]*(pass|partial|fail)[[:space:]]*$' "$file"
}

append_result_excerpt() {
  local file="$1" limit="${2:-180}"
  if [[ ! -s "$file" ]]; then
    printf '(empty)\n'
    return 0
  fi
  awk -v limit="$limit" '
    BEGIN { found=0; count=0 }
    /^[[:space:]>-]*Verdict:[[:space:]]*(pass|partial|fail)[[:space:]]*$/ { found=1 }
    found && count < limit { print; count++ }
    END { exit(found ? 0 : 1) }
  ' "$file" && return 0
  sed -n "1,${limit}p" "$file"
}

emit_result_excerpt_stdout() {
  local file="$1"
  emit_result_metadata_stdout "${file}" "ready"
}

if [[ "${RUN_REVIEW}" == "true" && "${ALLOW_EMPTY_REVIEW}" != "true" ]] && ! has_review_items; then
  {
    printf '\n### %s — CPO evaluator skipped (%s)\n\n' "${NOW}" "${GATE_DISPLAY}"
    printf -- '- executor: `%s`\n' "${EVALUATOR_EXECUTOR}"
    printf -- '- reason: no reviewable project/sprint evidence found\n'
    printf -- '- next: make an implementation/planning change first, or run `/sfs auth probe --executor <tool>` for a cheap bridge request/response test.\n'
  } >> "${REVIEW_PATH}" || {
    echo "permission denied appending CPO skip result to ${REVIEW_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  }

  _esc_sprint="${SPRINT_ID//\\/\\\\}"
  _esc_sprint="${_esc_sprint//\"/\\\"}"
  _esc_gate="${GATE_ID//\\/\\\\}"
  _esc_gate="${_esc_gate//\"/\\\"}"
  _esc_path="${REVIEW_PATH//\\/\\\\}"
  _esc_path="${_esc_path//\"/\\\"}"
  _esc_eval="${EVALUATOR_EXECUTOR//\\/\\\\}"
  _esc_eval="${_esc_eval//\"/\\\"}"
  _esc_gen="${GENERATOR_EXECUTOR//\\/\\\\}"
  _esc_gen="${_esc_gen//\"/\\\"}"
  _esc_lens="${REVIEW_LENS//\\/\\\\}"
  _esc_lens="${_esc_lens//\"/\\\"}"
  append_event "review_skip" \
    "{\"sprint_id\":\"${_esc_sprint}\",\"gate_id\":\"${_esc_gate}\",\"path\":\"${_esc_path}\",\"review_lens\":\"${_esc_lens}\",\"evaluator_role\":\"CPO\",\"evaluator_executor\":\"${_esc_eval}\",\"generator_executor\":\"${_esc_gen}\",\"reason\":\"no_review_items\"}" \
    2>/dev/null || {
      echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
      exit "${SFS_EXIT_PERM}"
    }

  _probe_executor="$(normalize_executor_profile "${EVALUATOR_EXECUTOR}")"
  if [[ "${_probe_executor}" == "custom" ]]; then
    echo "리뷰할 항목이 없습니다: gate ${GATE_DISPLAY} | lens ${REVIEW_LENS} (${REVIEW_LENS_SOURCE}) | executor ${EVALUATOR_EXECUTOR} | use --allow-empty to force a custom executor"
  else
    echo "리뷰할 항목이 없습니다: gate ${GATE_DISPLAY} | lens ${REVIEW_LENS} (${REVIEW_LENS_SOURCE}) | executor ${EVALUATOR_EXECUTOR} | bridge test: /sfs auth probe --executor ${_probe_executor}"
  fi
  exit "${SFS_EXIT_OK}"
fi

if ! mkdir -p "${PROMPT_INVOCATION_DIR}" "${RUN_INVOCATION_DIR}" 2>/dev/null; then
  echo "permission denied creating ${PROMPT_INVOCATION_DIR} / ${RUN_INVOCATION_DIR}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! discard_prior_review_scratch; then
  echo "permission denied cleaning prior review scratch" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! render_cpo_prompt > "${PROMPT_PATH}" 2>/dev/null; then
  echo "permission denied writing CPO prompt to ${PROMPT_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
PROMPT_LINES="$(count_file_lines "${PROMPT_PATH}")"
PROMPT_BYTES="$(count_file_bytes "${PROMPT_PATH}")"

{
  printf '\n### %s — CPO evaluator invocation (%s)\n\n' "${NOW}" "${GATE_DISPLAY}"
  printf -- '- evaluator_role: CPO\n'
  printf -- '- evaluator_persona: `%s`\n' "${PERSONA_PATH}"
  printf -- '- review_lens: `%s` (%s, %s)\n' "${REVIEW_LENS}" "${REVIEW_LENS_LABEL}" "${REVIEW_LENS_SOURCE}"
  printf -- '- evaluator_executor: `%s`\n' "${EVALUATOR_EXECUTOR}"
  printf -- '- generator_executor: `%s`\n' "${GENERATOR_EXECUTOR}"
  printf -- '- prompt_path: `%s`\n' "${PROMPT_PATH}"
  if [[ "${RUN_REVIEW}" == "true" ]]; then
    printf -- '- run_requested: true\n'
  else
    printf -- '- run_requested: false\n'
  fi
  printf -- '- auth_mode: `%s`\n' "${AUTH_INTERACTIVE}"
  printf -- '- prompt_size: `%s bytes / %s lines`\n' "${PROMPT_BYTES}" "${PROMPT_LINES}"
  printf -- '- prompt_body: stored in `prompt_path` only; not embedded in review.md to avoid recursive token growth.\n'
  printf -- '- self_validation_policy: CTO Generator output must be checked by CPO Evaluator; independent tool/instance recommended.\n'
} >> "${REVIEW_PATH}" || {
  echo "permission denied appending CPO prompt to ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
}

RUN_OUT=""
RUN_ERR=""
RUN_RESULT=""
RESULT_PATH=""
RUN_RC=""
RUN_WARNING=""
if [[ "${RUN_REVIEW}" == "true" ]]; then
  RUN_OUT="${RUN_INVOCATION_DIR}/stdout.md"
  RUN_ERR="${RUN_INVOCATION_DIR}/stderr.txt"
  RUN_RESULT="${RUN_INVOCATION_DIR}/result.md"

  set +e
  EXECUTOR_CMD="$(resolve_review_executor_cmd)"
  _resolve_rc=$?
  set -e
  if [[ "${_resolve_rc}" -ne 0 ]] || [[ -z "${EXECUTOR_CMD:-}" ]]; then
    {
      printf '\n### %s — CPO evaluator run failed before start\n\n' "${NOW}"
      printf -- '- executor: `%s`\n' "${EVALUATOR_EXECUTOR}"
      printf -- '- prompt_path: `%s`\n' "${PROMPT_PATH}"
      printf -- '- reason: executor bridge missing\n'
    } >> "${REVIEW_PATH}" || true
    exit "${SFS_EXIT_EXECUTOR}"
  fi

  if review_bridge_probe_enabled; then
    PROBE_PROFILE="$(normalize_executor_profile "${EVALUATOR_EXECUTOR}")"
    PROBE_PROMPT="${RUN_INVOCATION_DIR}/bridge-probe.prompt.txt"
    PROBE_OUT="${RUN_INVOCATION_DIR}/bridge-probe.stdout.txt"
    PROBE_ERR="${RUN_INVOCATION_DIR}/bridge-probe.stderr.txt"
    PROBE_RESULT="${RUN_INVOCATION_DIR}/bridge-probe.result.txt"
    cat > "${PROBE_PROMPT}" <<EOF
Solon SFS review bridge probe for ${PROBE_PROFILE}.
Return exactly:
SFS_REVIEW_BRIDGE_PROBE_OK
EOF
    PROBE_CMD="$(resolve_review_bridge_probe_cmd "${PROBE_PROFILE}" "${PROBE_RESULT}")"
    {
      echo "executor bridge probe: ${EVALUATOR_EXECUTOR}"
      echo "  timeout: ${REVIEW_BRIDGE_PROBE_TIMEOUT}s"
      echo "  stdout: ${PROBE_OUT}"
      echo "  stderr: ${PROBE_ERR}"
    } >&2
    set +e
    sfs_run_eval_with_timeout "${PROBE_CMD}" "${REVIEW_BRIDGE_PROBE_TIMEOUT}" "${PROBE_PROMPT}" "${PROBE_OUT}" "${PROBE_ERR}" "review executor bridge probe (${EVALUATOR_EXECUTOR})"
    PROBE_RC=$?
    set -e
    if [[ -s "${PROBE_RESULT}" ]]; then
      cat "${PROBE_RESULT}" >> "${PROBE_OUT}" 2>/dev/null || true
    fi
    if [[ "${PROBE_RC}" -ne 0 ]] || ! grep -q "SFS_REVIEW_BRIDGE_PROBE_OK" "${PROBE_OUT}" 2>/dev/null; then
      {
        printf '\n### %s — CPO evaluator bridge probe failed before full review\n\n' "${NOW}"
        printf -- '- executor: `%s`\n' "${EVALUATOR_EXECUTOR}"
        printf -- '- timeout: `%ss`\n' "${REVIEW_BRIDGE_PROBE_TIMEOUT}"
        printf -- '- stdout_path: `%s`\n' "${PROBE_OUT}"
        printf -- '- stderr_path: `%s`\n' "${PROBE_ERR}"
        printf -- '- reason: named executor did not return SFS_REVIEW_BRIDGE_PROBE_OK before full CPO prompt\n'
        printf -- '- next: run `/sfs auth probe --executor %s --timeout %s`, set SFS_REVIEW_%s_CMD to a known-good CLI path, or use --prompt-only for manual handoff.\n' "${PROBE_PROFILE}" "${REVIEW_BRIDGE_PROBE_TIMEOUT}" "$(printf '%s' "${PROBE_PROFILE}" | tr '[:lower:]' '[:upper:]')"
      } >> "${REVIEW_PATH}" || true
      echo "executor bridge probe failed: ${EVALUATOR_EXECUTOR} (exit ${PROBE_RC}); full CPO review not started; see ${PROBE_ERR}" >&2
      exit "${SFS_EXIT_EXECUTOR}"
    fi
  fi

  {
    echo "executor running: ${EVALUATOR_EXECUTOR}"
    echo "  stdout: ${RUN_OUT}"
    echo "  stderr: ${RUN_ERR}"
    echo "  result: ${RUN_RESULT}"
    echo "  prompt: ${PROMPT_PATH}"
    echo "  If it looks stuck, inspect another terminal with: tail -f ${RUN_ERR}"
  } >&2
  set +e
  sfs_run_eval_with_timeout "${EXECUTOR_CMD}" "${REVIEW_EXECUTOR_TIMEOUT}" "${PROMPT_PATH}" "${RUN_OUT}" "${RUN_ERR}" "review executor (${EVALUATOR_EXECUTOR})"
  RUN_RC=$?
  set -e

  if [[ -s "${RUN_RESULT}" ]]; then
    RESULT_PATH="${RUN_RESULT}"
  elif [[ -s "${RUN_OUT}" ]]; then
    RESULT_PATH="${RUN_OUT}"
  elif [[ -s "${RUN_ERR}" ]]; then
    RESULT_PATH="${RUN_ERR}"
  else
    RESULT_PATH="${RUN_OUT}"
  fi

  if [[ "${RUN_RC}" -ne 0 ]] && has_strict_verdict "${RESULT_PATH}"; then
    RUN_WARNING="executor returned ${RUN_RC}, but verdict-shaped output was captured"
    echo "warning: ${RUN_WARNING}; recording review result" >&2
  fi

  RUN_OUT_LINES="$(count_file_lines "${RUN_OUT}")"
  RUN_OUT_BYTES="$(count_file_bytes "${RUN_OUT}")"
  RUN_ERR_LINES="$(count_file_lines "${RUN_ERR}")"
  RUN_ERR_BYTES="$(count_file_bytes "${RUN_ERR}")"
  RUN_RESULT_LINES="$(count_file_lines "${RESULT_PATH}")"
  RUN_RESULT_BYTES="$(count_file_bytes "${RESULT_PATH}")"
  RUN_VERDICT="$(extract_result_verdict "${RESULT_PATH}" || true)"
  [[ -n "${RUN_VERDICT}" ]] || RUN_VERDICT="unknown"

  {
    printf '\n### %s — CPO evaluator result (%s)\n\n' "${NOW}" "${GATE_DISPLAY}"
    printf -- '- review_lens: `%s` (%s, %s)\n' "${REVIEW_LENS}" "${REVIEW_LENS_LABEL}" "${REVIEW_LENS_SOURCE}"
    printf -- '- executor: `%s`\n' "${EVALUATOR_EXECUTOR}"
    printf -- '- executor_cmd: `%s`\n' "${EXECUTOR_CMD}"
    printf -- '- exit_code: `%s`\n' "${RUN_RC}"
    if [[ -n "${RUN_WARNING}" ]]; then
      printf -- '- warning: `%s`\n' "${RUN_WARNING}"
    fi
    printf -- '- stdout_path: `%s`\n' "${RUN_OUT}"
    printf -- '- stdout_size: `%s bytes / %s lines`\n' "${RUN_OUT_BYTES}" "${RUN_OUT_LINES}"
    printf -- '- stderr_path: `%s`\n' "${RUN_ERR}"
    printf -- '- stderr_size: `%s bytes / %s lines`\n' "${RUN_ERR_BYTES}" "${RUN_ERR_LINES}"
    printf -- '- result_path: `%s`\n' "${RESULT_PATH}"
    printf -- '- result_size: `%s bytes / %s lines`\n' "${RUN_RESULT_BYTES}" "${RUN_RESULT_LINES}"
    printf -- '- result_verdict: `%s`\n' "${RUN_VERDICT}"
    if (( REVIEW_MD_EXCERPT_LINES > 0 )); then
      printf -- '- result_excerpt: `%s lines max; full result stored in result_path`\n\n' "${REVIEW_MD_EXCERPT_LINES}"
      printf '#### result excerpt\n\n'
      printf '```text\n'
      append_result_excerpt "${RESULT_PATH}" "${REVIEW_MD_EXCERPT_LINES}"
      printf '\n```\n'
    else
      printf -- '- result_excerpt: `disabled; full result stored in result_path`\n'
    fi
  } >> "${REVIEW_PATH}" || {
    echo "permission denied appending CPO result to ${REVIEW_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  }

  if [[ "${RUN_RC}" -ne 0 && -z "${RUN_WARNING}" ]]; then
    echo "executor failed: ${EVALUATOR_EXECUTOR} (exit ${RUN_RC}); see ${RUN_ERR}" >&2
    exit "${SFS_EXIT_EXECUTOR}"
  fi
fi

# Prompt rendering may inspect review evidence while another installed runtime is
# present on the host. Reassert the current invocation metadata after all prompt
# and executor side effects so review.md frontmatter matches the command that
# produced the reported prompt/result.
if ! update_frontmatter "${REVIEW_PATH}" "review_lens" "\"${REVIEW_LENS//\"/\\\"}\"" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "review_lens_source" "\"${REVIEW_LENS_SOURCE//\"/\\\"}\"" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "evaluator_persona" "\"${PERSONA_PATH//\"/\\\"}\"" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi

# ─────────────────────────────────────────────────────────────────────
# Append review_open event (ts auto-injected by append_event)
# ─────────────────────────────────────────────────────────────────────
# JSON-escape sprint-id, gate_id, path (defensive — sprint-id and gate_id were
# already validated, but path may include characters that escape).
_esc_sprint="${SPRINT_ID//\\/\\\\}"
_esc_sprint="${_esc_sprint//\"/\\\"}"
_esc_gate="${GATE_ID//\\/\\\\}"
_esc_gate="${_esc_gate//\"/\\\"}"
_esc_path="${REVIEW_PATH//\\/\\\\}"
_esc_path="${_esc_path//\"/\\\"}"
_esc_prompt="${PROMPT_PATH//\\/\\\\}"
_esc_prompt="${_esc_prompt//\"/\\\"}"
_esc_eval="${EVALUATOR_EXECUTOR//\\/\\\\}"
_esc_eval="${_esc_eval//\"/\\\"}"
_esc_gen="${GENERATOR_EXECUTOR//\\/\\\\}"
_esc_gen="${_esc_gen//\"/\\\"}"
_esc_persona="${PERSONA_PATH//\\/\\\\}"
_esc_persona="${_esc_persona//\"/\\\"}"
_esc_auth_mode="${AUTH_INTERACTIVE//\\/\\\\}"
_esc_auth_mode="${_esc_auth_mode//\"/\\\"}"
_esc_lens="${REVIEW_LENS//\\/\\\\}"
_esc_lens="${_esc_lens//\"/\\\"}"
_esc_lens_source="${REVIEW_LENS_SOURCE//\\/\\\\}"
_esc_lens_source="${_esc_lens_source//\"/\\\"}"

if ! append_event "review_open" \
  "{\"sprint_id\":\"${_esc_sprint}\",\"gate_id\":\"${_esc_gate}\",\"path\":\"${_esc_path}\",\"prompt_path\":\"${_esc_prompt}\",\"review_lens\":\"${_esc_lens}\",\"review_lens_source\":\"${_esc_lens_source}\",\"evaluator_role\":\"CPO\",\"evaluator_executor\":\"${_esc_eval}\",\"generator_executor\":\"${_esc_gen}\",\"persona\":\"${_esc_persona}\",\"run_requested\":${RUN_REVIEW},\"auth_mode\":\"${_esc_auth_mode}\"}" \
  2>/dev/null; then
  echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
  exit "${SFS_EXIT_PERM}"
fi

if [[ "${RUN_REVIEW}" == "true" ]]; then
  _esc_out="${RESULT_PATH//\\/\\\\}"
  _esc_out="${_esc_out//\"/\\\"}"
  _esc_rc="${RUN_RC:-0}"
  if ! append_event "review_run" \
    "{\"sprint_id\":\"${_esc_sprint}\",\"gate_id\":\"${_esc_gate}\",\"path\":\"${_esc_path}\",\"output_path\":\"${_esc_out}\",\"review_lens\":\"${_esc_lens}\",\"evaluator_role\":\"CPO\",\"evaluator_executor\":\"${_esc_eval}\",\"generator_executor\":\"${_esc_gen}\",\"exit_code\":${_esc_rc}}" \
    2>/dev/null; then
    echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# Stdout (V-1 conditions #4 / WU-25 §2.1 — path + gate id, no editor launch)
# ─────────────────────────────────────────────────────────────────────
if [[ "${PRINT_PROMPT}" == "true" ]]; then
  cat "${PROMPT_PATH}"
elif [[ "${RUN_REVIEW}" == "true" ]]; then
  if [[ -n "${RUN_WARNING}" ]]; then
    echo "review.md ready: ${REVIEW_PATH} | gate ${GATE_DISPLAY} | lens ${REVIEW_LENS} (${REVIEW_LENS_SOURCE}) CPO run complete with executor warning | executor ${EVALUATOR_EXECUTOR} | output ${RESULT_PATH}"
  else
    echo "review.md ready: ${REVIEW_PATH} | gate ${GATE_DISPLAY} | lens ${REVIEW_LENS} (${REVIEW_LENS_SOURCE}) CPO run complete | executor ${EVALUATOR_EXECUTOR} | output ${RESULT_PATH}"
  fi
  emit_result_excerpt_stdout "${RESULT_PATH}" 80
  printf 'next: %s\n' "$(review_next_action_line "${GATE_ID}" "${RUN_VERDICT}")"
else
  echo "review.md ready: ${REVIEW_PATH} | gate ${GATE_DISPLAY} | lens ${REVIEW_LENS} (${REVIEW_LENS_SOURCE}) prompt ready | executor ${EVALUATOR_EXECUTOR} | prompt ${PROMPT_PATH}"
fi

exit "${SFS_EXIT_OK}"
# End of sfs-review.sh
