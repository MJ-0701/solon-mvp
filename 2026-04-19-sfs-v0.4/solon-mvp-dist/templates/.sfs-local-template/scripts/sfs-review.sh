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
#   · gate id 검증 = sfs-common.sh::validate_gate_id (WU-25 row 4 신설).
#   · `--gate <id>` 미지정 시 events.jsonl 마지막 review_open event 의
#     gate_id 추론 (sfs-common.sh::infer_last_gate_id, WU-25 row 4 신설).
#   · CPO Evaluator persona prompt 를 review.md 에 append.
#   · verdict 자체는 CPO agent output 으로 기록한다. 본 bash 명령은 prompt/evidence
#     scaffold + executor bridge + event 기록을 담당한다.
#
# Output:
#   review.md ready: <path> | gate <gate-id> prompt ready | executor <executor> | prompt <path>
#   review.md ready: <path> | gate <gate-id> CPO run complete | executor <executor> | output <path>
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
#      "unknown gate <id>, valid: G-1, G0, G1, G2, G3, G4, G5"
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
Usage: /sfs review [--gate <id>] [--executor <profile|cmd>] [--generator <profile|cmd>] [--persona <path>] [--prompt-only|--print-prompt] [--show-last] [--allow-empty] [--auth-interactive|--no-auth-interactive]

Open the active sprint's review.md as the CPO Evaluator review document.
  - --gate <id>   gate id (one of: G-1, G0, G1, G2, G3, G4, G5).
                  If omitted, inferred from the most recent `review_open`
                  event in events.jsonl. If inference fails, exit 6.
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
                  Named profiles:
                    codex        $SFS_REVIEW_CODEX_CMD, else `codex exec --full-auto --ephemeral --output-last-message <result> -`
                    codex-plugin $SFS_REVIEW_CODEX_PLUGIN_CMD only (Claude in-process plugins are not shell-callable)
                    gemini       $SFS_REVIEW_GEMINI_CMD, else `gemini --skip-trust --output-format text -p "Read stdin and perform the requested CPO review."`
                    claude       $SFS_REVIEW_CLAUDE_CMD, else `claude -p --dangerously-skip-permissions`
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
  - Updates frontmatter: phase=review, gate_id=<id>, evaluator_role=CPO,
    evaluator_executor=<executor>, generator_executor=<generator>, last_touched_at=<ISO8601>.
  - Writes the full CPO prompt to .sfs-local/tmp/review-prompts/.
  - Appends a compact CPO Evaluator invocation log to review.md. The full
    prompt body is not embedded by default to prevent recursive token growth.
  - Stores only the latest full executor result set for the same sprint/gate
    under .sfs-local/tmp/review-runs/. Older same sprint/gate prompt/run files
    are archived under .sfs-local/archives/review-runs/ before the new run.
    review.md keeps only compact result metadata by default. Set
    SFS_REVIEW_MD_EXCERPT_LINES=1..80 to embed a bounded excerpt.
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
# CLI parse (--gate <id> | --gate=<id> | -h | --help)
# ─────────────────────────────────────────────────────────────────────
GATE_ID=""
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
if (( REVIEW_FILE_EXCERPT_MAX > 40 )); then
  REVIEW_FILE_EXCERPT_MAX=40
fi
if (( REVIEW_FILE_EXCERPT_LINES > 240 )); then
  REVIEW_FILE_EXCERPT_LINES=240
fi
if (( REVIEW_DIFF_LINES > 360 )); then
  REVIEW_DIFF_LINES=360
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

emit_result_metadata_stdout() {
  local file="$1" state="${2:-ready}" verdict
  verdict="$(extract_result_verdict "${file}" || true)"
  [[ -n "${verdict}" ]] || verdict="unknown"
  echo "review result ${state}:"
  echo "  verdict: ${verdict}"
  echo "  output: ${file}"
  echo "  display: 사용자 언어로 요약/해야 할 일 레포트 렌더링; 원문은 파일에 보관"
}

show_latest_review_result() {
  local gate_filter="${1:-}" result_path gate_label
  if [[ ! -f "${REVIEW_PATH}" ]]; then
    echo "review.md not found: ${REVIEW_PATH} | no recorded CPO review yet"
    return 0
  fi

  gate_label=""
  if [[ -n "${gate_filter}" ]]; then
    gate_label=" | gate ${gate_filter}"
  fi

  result_path="$(latest_review_output_path "${gate_filter}" || true)"
  if [[ -z "${result_path}" && -n "${gate_filter}" ]]; then
    echo "review.md ready: ${REVIEW_PATH}${gate_label} | latest CPO result | output not-found"
    echo "review result none:"
    echo "  verdict: unknown"
    echo "  output: not-found"
    echo "  display: gate ${gate_filter} 에 기록된 CPO 결과 없음"
    return 0
  fi
  if [[ -z "${result_path}" ]]; then
    result_path="$(latest_review_md_result_path || true)"
  fi

  if [[ -n "${result_path}" && -f "${result_path}" ]]; then
    echo "review.md ready: ${REVIEW_PATH}${gate_label} | latest CPO result | output ${result_path}"
    emit_result_metadata_stdout "${result_path}" "ready"
    return 0
  fi

  echo "review.md ready: ${REVIEW_PATH}${gate_label} | latest CPO result | output ${result_path:-not-found}"
  if latest_review_md_excerpt >/dev/null 2>&1; then
    emit_result_metadata_stdout "${REVIEW_PATH}" "embedded"
  else
    echo "review result none:"
    echo "  verdict: unknown"
    echo "  output: not-found"
    echo "  display: 기록된 CPO 결과 없음"
  fi
}

if [[ "${SHOW_LAST}" == "true" ]]; then
  if [[ -n "${GATE_ID}" ]] && ! validate_gate_id "${GATE_ID}"; then
    echo "unknown gate ${GATE_ID}, valid: G-1, G0, G1, G2, G3, G4, G5" >&2
    exit "${SFS_EXIT_GATE}"
  fi
  show_latest_review_result "${GATE_ID}"
  exit "${SFS_EXIT_OK}"
fi

# ─────────────────────────────────────────────────────────────────────
# Resolve gate id (either --gate <id> or infer from events.jsonl)
# ─────────────────────────────────────────────────────────────────────
if [[ -z "${GATE_ID}" ]]; then
  GATE_ID="$(infer_last_gate_id)"
fi
if [[ -z "${GATE_ID}" ]]; then
  echo "gate id required: --gate <id>, valid: G-1, G0, G1, G2, G3, G4, G5" >&2
  exit "${SFS_EXIT_GATE}"
fi
if ! validate_gate_id "${GATE_ID}"; then
  echo "unknown gate ${GATE_ID}, valid: G-1, G0, G1, G2, G3, G4, G5" >&2
  exit "${SFS_EXIT_GATE}"
fi

normalize_inferred_executor_value() {
  local value="$1" token low_value
  value="$(printf '%s' "$value" \
    | sed -E 's/[`"*]//g; s/#.*$//; s/^[[:space:]-]+//; s/[[:space:]]+$//')"
  [[ -n "$value" ]] || return 1
  low_value="$(printf '%s\n' "$value" | tr '[:upper:]' '[:lower:]')"
  case "$value" in
    *" / "*)
      return 1
      ;;
  esac
  case "$low_value" in
    *unknown*|*"current runtime model"*|*"current-runtime-model"*)
      return 1
      ;;
  esac
  case "$low_value" in
    *codex*) printf 'codex\n'; return 0 ;;
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
    }
    {
      low = tolower($0)
    }
    low ~ /generator_executor[[:space:]]*:/ ||
    low ~ /generator executor[[:space:]]*:/ ||
    low ~ /implementation executor[[:space:]]*:/ ||
    low ~ /implementation tool[[:space:]]*:/ ||
    low ~ /구현 executor\/tool[[:space:]]*:/ ||
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
# Update frontmatter (phase + gate_id + last_touched_at)
# ─────────────────────────────────────────────────────────────────────
NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"

if ! update_frontmatter "${REVIEW_PATH}" "phase" "review" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "gate_id" "${GATE_ID}" 2>/dev/null; then
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
      if (low ~ /build output|smoke output|file excerpt index|self-validation|risk ledger|untracked implementation surface|verification evidence|commands run/) {
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

review_evidence_paths() {
  {
    git diff --name-only --diff-filter=ACMRT 2>/dev/null || true
    git diff --cached --name-only --diff-filter=ACMRT 2>/dev/null || true
    git ls-files --others --exclude-standard 2>/dev/null || true
    extract_indexed_evidence_paths
  } | while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    path="$(normalize_review_candidate_path "$path" || true)"
    [[ -n "$path" ]] || continue
    if is_reviewable_project_path "$path"; then
      printf '%s\n' "$path"
    fi
  done | awk '!seen[$0]++'
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

extract_path_tokens_from_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  awk '
    BEGIN { capture=0 }
    /^#{1,6}[[:space:]]+/ {
      low = tolower($0)
      capture = (low ~ /file excerpt index|source excerpt|implementation surface|changed files|changed artifacts|변경 파일|변경 파일\/모듈|cpo 에게 넘길 검증 포인트/)
      next
    }
    capture || /(^|[[:space:]`])(([.]\/)?src\/|src\/|scripts\/|package[.]json|vite[.]config|tsconfig|playwright[.]config|[A-Za-z0-9_.\/-]+[.](ts|tsx|js|jsx|mjs|cjs|css|scss|html|json|yml|yaml|sh|md))([[:space:]`),.;]|$)/ {
      line = $0
      gsub(/[`"'\''()<>{}\[\],]/, " ", line)
      split(line, parts, /[[:space:]]+/)
      for (i in parts) {
        token = parts[i]
        if (token ~ /^([.]\/)?(src|app|pages|components|scripts|test|tests|__tests__|public|styles|lib|server|client|config)\// ||
            token ~ /(^|\/)(package[.]json|vite[.]config[.](ts|js|mjs)|tsconfig[^\/]*[.]json|playwright[.]config[.](ts|js)|[^\/]+[.](ts|tsx|js|jsx|mjs|cjs|css|scss|html|json|yml|yaml|sh|md))$/) {
          print token
        }
      }
    }
  ' "$file"
}

extract_indexed_evidence_paths() {
  {
    extract_path_tokens_from_file "${IMPLEMENT_PATH}"
    extract_path_tokens_from_file "${LOG_PATH}"
  } | while IFS= read -r path; do
    normalize_review_candidate_path "$path" || true
  done
}

is_ignored_review_path() {
  local path="$1"
  case "$path" in
    .idea|.idea/*|.vscode|.vscode/*|node_modules|node_modules/*|dist|dist/*|build|build/*|coverage|coverage/*|.DS_Store|*.iml)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
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
        if is_reviewable_project_path "$path"; then
          printf '%s\n' "$path"
        fi
      done || true)"
  if [[ -n "$paths" ]]; then
    printf '%s\n' "$paths" | sed -n '1,200p'
  else
    printf '(no untracked project implementation files detected)\n'
  fi
}

render_reviewable_file_manifest() {
  local paths
  printf '\n### reviewable implementation file manifest\n\n'
  paths="$(review_evidence_paths || true)"
  if [[ -n "$paths" ]]; then
    printf '%s\n' "$paths" | sed -n '1,200p'
  else
    printf '(no project implementation files detected)\n'
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
    if is_reviewable_project_path "$path"; then
      printf '%s\n' "$line"
    fi
  done || true)"
  if [[ -n "$output" ]]; then
    printf '%s\n' "$output"
  else
    printf '(no reviewable project git status entries; SFS/IDE/build metadata filtered)\n'
  fi
}

render_review_file_excerpt() {
  local file="$1" limit="${2:-120}" bytes
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
  if (( bytes > 131072 )); then
    printf '(large file: %s bytes; showing first %s lines)\n\n' "$bytes" "$limit"
  fi
  sed -n "1,${limit}p" "$file"
}

render_review_file_diff() {
  local file="$1" limit="${2:-180}" staged unstaged
  printf '\n### source diff: %s\n\n' "$file"
  if [[ ! -e "$file" ]]; then
    printf '(missing; no diff available)\n'
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
  printf '\n### bounded source diffs for reviewable files\n\n'
  paths="$(review_evidence_paths || true)"
  if [[ -z "$paths" ]]; then
    printf '(no project implementation files detected)\n'
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
  printf '\n### bounded source excerpts for reviewable files\n\n'
  paths="$(review_evidence_paths || true)"
  if [[ -z "$paths" ]]; then
    printf '(no project implementation files detected)\n'
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

render_evidence_bundle() {
  printf '## Embedded Evidence Bundle\n\n'
  printf 'The following evidence was collected by SFS before invoking the executor. Review this embedded evidence first; do not assume your CLI has project file/tool access. If evidence is insufficient, return partial/fail and list the missing evidence instead of calling unsupported tools.\n\n'

  printf '### git status --short (review-filtered)\n\n'
  render_review_git_status

  printf '\n### git diff --stat\n\n'
  git diff --stat 2>/dev/null || printf '(git diff unavailable)\n'

  render_untracked_manifest
  render_reviewable_file_manifest
  render_priority_evidence_sections "${IMPLEMENT_PATH}" 120
  render_evidence_file "${BRAINSTORM_PATH}" 220
  render_evidence_file "${PLAN_PATH}" 260
  render_evidence_file "${IMPLEMENT_PATH}" 420
  render_evidence_file "${LOG_PATH}" 260
  render_review_file_diffs
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
    .sfs-local/*|.claude/commands/sfs.md|.gemini/commands/sfs.toml|.agents/skills/sfs/SKILL.md|.codex/prompts/sfs.md)
      return 0
      ;;
    SFS.md|CLAUDE.md|AGENTS.md|GEMINI.md|.gitignore)
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

Review gate: ${GATE_ID}
Sprint: ${SPRINT_ID}
Generator executor/tool: ${GENERATOR_EXECUTOR}
Evaluator executor/tool: ${EVALUATOR_EXECUTOR}

Self-validation policy:
- Do not rubber-stamp CTO Generator output.
- If this review is running in the same tool/session that generated the implementation, explicitly call that out as a risk.
- Prefer independent review evidence from Codex/Gemini/another agent instance when implementation was produced by Claude.
- Separate implementation quality findings from evidence-bundle gaps. If the embedded bundle lacks required implementation files, build/smoke output, or untracked source excerpts, say that explicitly as an evidence packaging gap.
- Treat File excerpt index paths as first-class review targets. The bundle should include bounded source diffs and excerpts for those paths when files are available.

Review the embedded evidence below. Do not rely on executor-specific tools being available.

EOF
  render_evidence_bundle
  cat <<'EOF'

Return exactly this shape:
Verdict: pass | partial | fail
Evidence checked:
- ...
Evidence gaps:
- ...
Findings:
- ...
Required CTO actions:
- ...
Final recommendation:
- ...
EOF
}

resolve_review_executor_cmd() {
  case "${EVALUATOR_EXECUTOR}" in
    codex|codex-cli)
      if [[ -n "${SFS_REVIEW_CODEX_CMD:-}" ]]; then
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
      if [[ -n "${SFS_REVIEW_CODEX_PLUGIN_CMD:-}" ]]; then
        printf '%s\n' "${SFS_REVIEW_CODEX_PLUGIN_CMD}"
      else
        echo "executor bridge missing: codex-plugin is a Claude runtime plugin, not shell-callable; set SFS_REVIEW_CODEX_PLUGIN_CMD or run --print-prompt and invoke the plugin from Claude" >&2
        return "${SFS_EXIT_EXECUTOR}"
      fi
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
        printf '%s\n' "claude -p --dangerously-skip-permissions"
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

if [[ -n "${EVALUATOR_EXECUTOR}" && -n "${GENERATOR_EXECUTOR}" && "${EVALUATOR_EXECUTOR}" == "${GENERATOR_EXECUTOR}" ]]; then
  echo "warning: evaluator executor equals generator executor (${EVALUATOR_EXECUTOR}); self-validation risk" >&2
fi

PROMPT_DIR="${SFS_LOCAL_DIR}/tmp/review-prompts"
RUN_DIR="${SFS_LOCAL_DIR}/tmp/review-runs"
PROMPT_TS="$(date -u +%Y%m%dT%H%M%SZ)"
PROMPT_PATH="${PROMPT_DIR}/${SPRINT_ID}-${GATE_ID}-${PROMPT_TS}.txt"

archive_prior_review_artifacts() {
  local prefix="${SPRINT_ID}-${GATE_ID}-"
  local archive_dir="${SFS_ARCHIVES_DIR}/review-runs/${SPRINT_ID}/${GATE_ID}/${PROMPT_TS}"
  local path base moved=0

  for path in "${PROMPT_DIR}/${prefix}"* "${RUN_DIR}/${prefix}"*; do
    [[ -f "${path}" ]] || continue
    if [[ "${moved}" -eq 0 ]]; then
      mkdir -p "${archive_dir}" || return "${SFS_EXIT_PERM}"
      moved=1
    fi
    base="${path##*/}"
    mv "${path}" "${archive_dir}/${base}" || return "${SFS_EXIT_PERM}"
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
    printf '\n### %s — CPO evaluator skipped (%s)\n\n' "${NOW}" "${GATE_ID}"
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
  append_event "review_skip" \
    "{\"sprint_id\":\"${_esc_sprint}\",\"gate_id\":\"${_esc_gate}\",\"path\":\"${_esc_path}\",\"evaluator_role\":\"CPO\",\"evaluator_executor\":\"${_esc_eval}\",\"generator_executor\":\"${_esc_gen}\",\"reason\":\"no_review_items\"}" \
    2>/dev/null || {
      echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
      exit "${SFS_EXIT_PERM}"
    }

  _probe_executor="$(normalize_executor_profile "${EVALUATOR_EXECUTOR}")"
  if [[ "${_probe_executor}" == "custom" ]]; then
    echo "리뷰할 항목이 없습니다: gate ${GATE_ID} | executor ${EVALUATOR_EXECUTOR} | use --allow-empty to force a custom executor"
  else
    echo "리뷰할 항목이 없습니다: gate ${GATE_ID} | executor ${EVALUATOR_EXECUTOR} | bridge test: /sfs auth probe --executor ${_probe_executor}"
  fi
  exit "${SFS_EXIT_OK}"
fi

if ! mkdir -p "${PROMPT_DIR}" "${RUN_DIR}" 2>/dev/null; then
  echo "permission denied creating ${PROMPT_DIR} / ${RUN_DIR}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! archive_prior_review_artifacts; then
  echo "permission denied archiving prior review artifacts" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! render_cpo_prompt > "${PROMPT_PATH}" 2>/dev/null; then
  echo "permission denied writing CPO prompt to ${PROMPT_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
PROMPT_LINES="$(count_file_lines "${PROMPT_PATH}")"
PROMPT_BYTES="$(count_file_bytes "${PROMPT_PATH}")"

{
  printf '\n### %s — CPO evaluator invocation (%s)\n\n' "${NOW}" "${GATE_ID}"
  printf -- '- evaluator_role: CPO\n'
  printf -- '- evaluator_persona: `%s`\n' "${PERSONA_PATH}"
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
  RUN_OUT="${RUN_DIR}/${SPRINT_ID}-${GATE_ID}-${PROMPT_TS}.stdout.md"
  RUN_ERR="${RUN_DIR}/${SPRINT_ID}-${GATE_ID}-${PROMPT_TS}.stderr.txt"
  RUN_RESULT="${RUN_DIR}/${SPRINT_ID}-${GATE_ID}-${PROMPT_TS}.result.md"

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

  {
    echo "executor running: ${EVALUATOR_EXECUTOR}"
    echo "  stdout: ${RUN_OUT}"
    echo "  stderr: ${RUN_ERR}"
    echo "  result: ${RUN_RESULT}"
    echo "  prompt: ${PROMPT_PATH}"
    echo "  If it looks stuck, inspect another terminal with: tail -f ${RUN_ERR}"
  } >&2
  set +e
  eval "${EXECUTOR_CMD}" < "${PROMPT_PATH}" > "${RUN_OUT}" 2> "${RUN_ERR}"
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
    printf '\n### %s — CPO evaluator result (%s)\n\n' "${NOW}" "${GATE_ID}"
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

if ! append_event "review_open" \
  "{\"sprint_id\":\"${_esc_sprint}\",\"gate_id\":\"${_esc_gate}\",\"path\":\"${_esc_path}\",\"prompt_path\":\"${_esc_prompt}\",\"evaluator_role\":\"CPO\",\"evaluator_executor\":\"${_esc_eval}\",\"generator_executor\":\"${_esc_gen}\",\"persona\":\"${_esc_persona}\",\"run_requested\":${RUN_REVIEW},\"auth_mode\":\"${_esc_auth_mode}\"}" \
  2>/dev/null; then
  echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
  exit "${SFS_EXIT_PERM}"
fi

if [[ "${RUN_REVIEW}" == "true" ]]; then
  _esc_out="${RESULT_PATH//\\/\\\\}"
  _esc_out="${_esc_out//\"/\\\"}"
  _esc_rc="${RUN_RC:-0}"
  if ! append_event "review_run" \
    "{\"sprint_id\":\"${_esc_sprint}\",\"gate_id\":\"${_esc_gate}\",\"path\":\"${_esc_path}\",\"output_path\":\"${_esc_out}\",\"evaluator_role\":\"CPO\",\"evaluator_executor\":\"${_esc_eval}\",\"generator_executor\":\"${_esc_gen}\",\"exit_code\":${_esc_rc}}" \
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
    echo "review.md ready: ${REVIEW_PATH} | gate ${GATE_ID} CPO run complete with executor warning | executor ${EVALUATOR_EXECUTOR} | output ${RESULT_PATH}"
  else
    echo "review.md ready: ${REVIEW_PATH} | gate ${GATE_ID} CPO run complete | executor ${EVALUATOR_EXECUTOR} | output ${RESULT_PATH}"
  fi
  emit_result_excerpt_stdout "${RESULT_PATH}" 80
else
  echo "review.md ready: ${REVIEW_PATH} | gate ${GATE_ID} prompt ready | executor ${EVALUATOR_EXECUTOR} | prompt ${PROMPT_PATH}"
fi

exit "${SFS_EXIT_OK}"
# End of sfs-review.sh
