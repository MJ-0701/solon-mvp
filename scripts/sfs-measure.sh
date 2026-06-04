#!/usr/bin/env bash
# sfs-measure.sh — local measurement dashboard + alive heartbeat wrapper.
#
# Default dashboard mode reads local `.sfs-local` evidence only. It never calls
# provider billing/pricing APIs and never estimates cost from live model prices.
# Alive mode remains the long-running command heartbeat wrapper.

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

ALIVE_MODE=0
JSON_MODE=0
ROOT_DIR=""
STEP_NAME=""
THRESHOLD=""

usage() {
  cat <<'EOF'
sfs-measure — local measurement dashboard

Usage:
  sfs-measure.sh [--json] [--root <dir>]
  sfs-measure.sh --alive [--step <name>] [--threshold <secs>] -- <command> [args...]

Modes:
  default            print local saved-time / decision / token-cost dashboard
  --json             print deterministic JSON for the same local dashboard data
  --root <dir>       read <dir>/.sfs-local instead of the current project
  --alive            emit [alive] still in step: <name> to stderr every threshold seconds
  --help             print this help

Metric marker contract:
  Scan .sfs-local/sprints/<sprint-id>/{report.md,retro.md,log.md} for lines:
    sfs_measure: saved_minutes=<int> decision_count=<int> token_count=<int|unknown> token_cost_usd=<decimal|unknown>
  saved_minutes and decision_count are additive. token_count and token_cost_usd
  are reported as unknown unless every observed value for that field is numeric.

Env:
  SFS_ALIVE_THRESHOLD_SECS  default 30 prod; tests use 2
  SFS_MEASURE_STEP_NAME     fallback step-name if --step not supplied
  SFS_LOCAL_DIR             dashboard state dir when --root is not supplied

Out-of-scope (DEFER 0.6.1+ per H5b):
  --timer  wall-clock + per-step trace
  --token  claude-code token instrumentation

Exit code: dashboard returns 0 on successful local scan; --alive forwards the
wrapped command's exit code.
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --alive) ALIVE_MODE=1; shift ;;
      --json) JSON_MODE=1; shift ;;
      --root)
        ROOT_DIR="${2:-}"
        if [[ -z "${ROOT_DIR}" ]]; then
          echo "${SCRIPT_NAME}: --root requires a directory" >&2
          return 2
        fi
        shift 2
        ;;
      --step) STEP_NAME="${2:-}"; shift 2 ;;
      --threshold) THRESHOLD="${2:-}"; shift 2 ;;
      --timer|--token)
        echo "${SCRIPT_NAME}: ${1} is DEFER 0.6.1+ (chunk-2 scope: --alive only)" >&2
        return 2
        ;;
      -h|--help|help) usage; exit 0 ;;
      --) shift; break ;;
      -*)
        echo "${SCRIPT_NAME}: unknown flag '${1}'" >&2
        usage >&2
        return 2
        ;;
      *) break ;;
    esac
  done
  REMAINING=("$@")
}

is_nonnegative_int() {
  case "${1:-}" in
    ''|*[!0-9]*) return 1 ;;
    *) return 0 ;;
  esac
}

is_decimal() {
  [[ "${1:-}" =~ ^[0-9]+([.][0-9]+)?$ ]]
}

sum_decimal() {
  awk -v a="${1}" -v b="${2}" 'BEGIN { printf "%.6f\n", a + b }'
}

format_decimal() {
  awk -v n="${1}" 'BEGIN {
    s = sprintf("%.6f", n)
    sub(/0+$/, "", s)
    sub(/[.]$/, "", s)
    if (s == "") s = "0"
    print s
  }'
}

json_escape() {
  local value="${1}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '%s' "${value}"
}

resolve_root_dir() {
  if [[ -n "${ROOT_DIR}" ]]; then
    (cd -P "${ROOT_DIR}" 2>/dev/null && pwd) || {
      echo "${SCRIPT_NAME}: --root directory not found: ${ROOT_DIR}" >&2
      return 2
    }
    return 0
  fi
  pwd -P
}

resolve_local_dir() {
  local root="$1"
  if [[ -n "${ROOT_DIR}" ]]; then
    printf '%s/.sfs-local\n' "${root}"
    return 0
  fi
  printf '%s\n' "${SFS_LOCAL_DIR:-${root}/.sfs-local}"
}

count_project_decisions() {
  local local_dir="$1"
  if [[ ! -d "${local_dir}/decisions" ]]; then
    printf '0\n'
    return 0
  fi
  find "${local_dir}/decisions" -maxdepth 1 -type f -name '[0-9][0-9][0-9][0-9]-*.md' 2>/dev/null | wc -l | tr -d ' '
}

SPRINT_IDS=()
SPRINT_SAVED=()
SPRINT_DECISIONS=()
SPRINT_TOKEN_KNOWN=()
SPRINT_TOKENS=()
SPRINT_COST_KNOWN=()
SPRINT_COSTS=()

TOTAL_SAVED=0
TOTAL_SPRINT_DECISIONS=0
TOTAL_TOKEN_KNOWN=1
TOTAL_TOKENS=0
TOTAL_COST_KNOWN=1
TOTAL_COST="0"
PROJECT_DECISIONS=0

ROW_MARKERS=0
ROW_SAVED=0
ROW_DECISIONS=0
ROW_TOKEN_KNOWN=1
ROW_TOKENS=0
ROW_COST_KNOWN=1
ROW_COST="0"

parse_measure_marker() {
  local line="$1" rest field key value
  local saved="0" decisions="0" tokens="unknown" cost="unknown"

  rest="${line#*sfs_measure:}"
  for field in ${rest}; do
    key="${field%%=*}"
    value="${field#*=}"
    case "${key}" in
      saved_minutes) saved="${value}" ;;
      decision_count) decisions="${value}" ;;
      token_count) tokens="${value}" ;;
      token_cost_usd) cost="${value}" ;;
    esac
  done

  ROW_MARKERS=$((ROW_MARKERS + 1))

  if is_nonnegative_int "${saved}"; then
    ROW_SAVED=$((ROW_SAVED + saved))
  fi
  if is_nonnegative_int "${decisions}"; then
    ROW_DECISIONS=$((ROW_DECISIONS + decisions))
  fi
  if is_nonnegative_int "${tokens}"; then
    ROW_TOKENS=$((ROW_TOKENS + tokens))
  else
    ROW_TOKEN_KNOWN=0
  fi
  if is_decimal "${cost}"; then
    ROW_COST="$(sum_decimal "${ROW_COST}" "${cost}")"
  else
    ROW_COST_KNOWN=0
  fi
}

scan_metric_file() {
  local file="$1" line
  [[ -f "${file}" ]] || return 0
  while IFS= read -r line || [[ -n "${line}" ]]; do
    case "${line}" in
      *sfs_measure:*) parse_measure_marker "${line}" ;;
    esac
  done < "${file}"
}

append_sprint_row() {
  local sid="$1"

  if (( ROW_MARKERS == 0 )); then
    ROW_TOKEN_KNOWN=0
    ROW_COST_KNOWN=0
  fi

  SPRINT_IDS+=("${sid}")
  SPRINT_SAVED+=("${ROW_SAVED}")
  SPRINT_DECISIONS+=("${ROW_DECISIONS}")
  SPRINT_TOKEN_KNOWN+=("${ROW_TOKEN_KNOWN}")
  SPRINT_TOKENS+=("${ROW_TOKENS}")
  SPRINT_COST_KNOWN+=("${ROW_COST_KNOWN}")
  SPRINT_COSTS+=("$(format_decimal "${ROW_COST}")")

  TOTAL_SAVED=$((TOTAL_SAVED + ROW_SAVED))
  TOTAL_SPRINT_DECISIONS=$((TOTAL_SPRINT_DECISIONS + ROW_DECISIONS))
  if (( ROW_TOKEN_KNOWN == 1 )); then
    TOTAL_TOKENS=$((TOTAL_TOKENS + ROW_TOKENS))
  else
    TOTAL_TOKEN_KNOWN=0
  fi
  if (( ROW_COST_KNOWN == 1 )); then
    TOTAL_COST="$(sum_decimal "${TOTAL_COST}" "${ROW_COST}")"
  else
    TOTAL_COST_KNOWN=0
  fi
}

scan_sprints() {
  local local_dir="$1" sprints_dir sprint_dir sid
  sprints_dir="${local_dir}/sprints"
  if [[ ! -d "${sprints_dir}" ]]; then
    TOTAL_TOKEN_KNOWN=0
    TOTAL_COST_KNOWN=0
    return 0
  fi

  for sprint_dir in "${sprints_dir}"/*; do
    [[ -d "${sprint_dir}" ]] || continue
    sid="$(basename "${sprint_dir}")"
    ROW_MARKERS=0
    ROW_SAVED=0
    ROW_DECISIONS=0
    ROW_TOKEN_KNOWN=1
    ROW_TOKENS=0
    ROW_COST_KNOWN=1
    ROW_COST="0"

    scan_metric_file "${sprint_dir}/report.md"
    scan_metric_file "${sprint_dir}/retro.md"
    scan_metric_file "${sprint_dir}/log.md"
    append_sprint_row "${sid}"
  done

  if (( ${#SPRINT_IDS[@]} == 0 )); then
    TOTAL_TOKEN_KNOWN=0
    TOTAL_COST_KNOWN=0
  fi
}

render_human_dashboard() {
  local root="$1" local_dir="$2" i token_display cost_display
  token_display="unknown"
  cost_display="unknown"
  if (( TOTAL_TOKEN_KNOWN == 1 )); then
    token_display="${TOTAL_TOKENS}"
  fi
  if (( TOTAL_COST_KNOWN == 1 )); then
    cost_display="$(format_decimal "${TOTAL_COST}")"
  fi

  printf 'SFS measure dashboard\n'
  printf 'root: %s\n' "${root}"
  printf 'local_dir: %s\n' "${local_dir}"
  printf 'sprints: %d\n' "${#SPRINT_IDS[@]}"
  printf 'saved_minutes: %d\n' "${TOTAL_SAVED}"
  printf 'sprint_decisions: %d\n' "${TOTAL_SPRINT_DECISIONS}"
  printf 'project_decisions: %d\n' "${PROJECT_DECISIONS}"
  printf 'token_count: %s\n' "${token_display}"
  printf 'token_cost_usd: %s\n' "${cost_display}"

  if (( ${#SPRINT_IDS[@]} > 0 )); then
    printf '\nSprint rows:\n'
    for ((i=0; i<${#SPRINT_IDS[@]}; i++)); do
      token_display="unknown"
      cost_display="unknown"
      if (( SPRINT_TOKEN_KNOWN[$i] == 1 )); then
        token_display="${SPRINT_TOKENS[$i]}"
      fi
      if (( SPRINT_COST_KNOWN[$i] == 1 )); then
        cost_display="${SPRINT_COSTS[$i]}"
      fi
      printf -- '- %s saved_minutes=%s decision_count=%s token_count=%s token_cost_usd=%s\n' \
        "${SPRINT_IDS[$i]}" "${SPRINT_SAVED[$i]}" "${SPRINT_DECISIONS[$i]}" \
        "${token_display}" "${cost_display}"
    done
  fi
}

render_json_dashboard() {
  local root="$1" local_dir="$2" i comma token_value cost_value
  local total_cost
  total_cost="$(format_decimal "${TOTAL_COST}")"

  printf '{\n'
  printf '  "generated_from": {\n'
  printf '    "root": "%s",\n' "$(json_escape "${root}")"
  printf '    "local_dir": "%s"\n' "$(json_escape "${local_dir}")"
  printf '  },\n'
  printf '  "totals": {\n'
  printf '    "saved_minutes": %d,\n' "${TOTAL_SAVED}"
  printf '    "sprint_decisions": %d,\n' "${TOTAL_SPRINT_DECISIONS}"
  printf '    "project_decisions": %d,\n' "${PROJECT_DECISIONS}"
  if (( TOTAL_TOKEN_KNOWN == 1 )); then
    token_value="${TOTAL_TOKENS}"
  else
    token_value="null"
  fi
  if (( TOTAL_COST_KNOWN == 1 )); then
    cost_value="${total_cost}"
  else
    cost_value="null"
  fi
  printf '    "token_count": %s,\n' "${token_value}"
  printf '    "token_count_known": %s,\n' "$([[ "${token_value}" != "null" ]] && printf true || printf false)"
  printf '    "token_cost_usd": %s,\n' "${cost_value}"
  printf '    "token_cost_known": %s\n' "$([[ "${cost_value}" != "null" ]] && printf true || printf false)"
  printf '  },\n'
  printf '  "sprints": [\n'
  for ((i=0; i<${#SPRINT_IDS[@]}; i++)); do
    comma=","
    if (( i == ${#SPRINT_IDS[@]} - 1 )); then
      comma=""
    fi
    if (( SPRINT_TOKEN_KNOWN[$i] == 1 )); then
      token_value="${SPRINT_TOKENS[$i]}"
    else
      token_value="null"
    fi
    if (( SPRINT_COST_KNOWN[$i] == 1 )); then
      cost_value="${SPRINT_COSTS[$i]}"
    else
      cost_value="null"
    fi
    printf '    {"id":"%s","saved_minutes":%s,"decision_count":%s,"token_count":%s,"token_count_known":%s,"token_cost_usd":%s,"token_cost_known":%s}%s\n' \
      "$(json_escape "${SPRINT_IDS[$i]}")" \
      "${SPRINT_SAVED[$i]}" \
      "${SPRINT_DECISIONS[$i]}" \
      "${token_value}" \
      "$([[ "${token_value}" != "null" ]] && printf true || printf false)" \
      "${cost_value}" \
      "$([[ "${cost_value}" != "null" ]] && printf true || printf false)" \
      "${comma}"
  done
  printf '  ]\n'
  printf '}\n'
}

run_dashboard() {
  local root local_dir
  if (( ${#REMAINING[@]} > 0 )); then
    echo "${SCRIPT_NAME}: dashboard mode does not accept a wrapped command; use --alive -- <command>" >&2
    return 2
  fi
  if [[ -n "${STEP_NAME}" || -n "${THRESHOLD}" ]]; then
    echo "${SCRIPT_NAME}: --step/--threshold require --alive" >&2
    return 2
  fi
  if (( ALIVE_MODE == 1 )); then
    echo "${SCRIPT_NAME}: --alive cannot be combined with dashboard mode flags" >&2
    return 2
  fi

  root="$(resolve_root_dir)" || return $?
  local_dir="$(resolve_local_dir "${root}")"
  PROJECT_DECISIONS="$(count_project_decisions "${local_dir}")"
  scan_sprints "${local_dir}"

  if (( JSON_MODE == 1 )); then
    render_json_dashboard "${root}" "${local_dir}"
  else
    render_human_dashboard "${root}" "${local_dir}"
  fi
}

resolve_threshold() {
  if [[ -n "${THRESHOLD}" ]]; then
    printf '%s\n' "${THRESHOLD}"
    return 0
  fi
  printf '%s\n' "${SFS_ALIVE_THRESHOLD_SECS:-30}"
}

resolve_step_name() {
  if [[ -n "${STEP_NAME}" ]]; then
    printf '%s\n' "${STEP_NAME}"
    return 0
  fi
  printf '%s\n' "${SFS_MEASURE_STEP_NAME:-unknown-step}"
}

run_alive() {
  local threshold step
  threshold="$(resolve_threshold)"
  step="$(resolve_step_name)"

  case "${threshold}" in
    ''|*[!0-9]*)
      echo "${SCRIPT_NAME}: --threshold/SFS_ALIVE_THRESHOLD_SECS must be integer (got '${threshold}')" >&2
      return 2
      ;;
  esac

  if (( ${#REMAINING[@]} == 0 )); then
    echo "${SCRIPT_NAME}: --alive requires a wrapped command after '--'" >&2
    return 2
  fi

  local child="" watcher=""

  # Register cleanup before spawning any subprocess so INT/TERM cannot land in
  # the gap between child start and trap installation.
  trap '[[ -n "${child:-}" ]] && kill "${child}" 2>/dev/null || true; [[ -n "${watcher:-}" ]] && kill "${watcher}" 2>/dev/null || true; [[ -n "${child:-}" ]] && wait "${child}" 2>/dev/null || true; [[ -n "${watcher:-}" ]] && wait "${watcher}" 2>/dev/null || true; exit 130' INT TERM

  # Run wrapped command in background.
  "${REMAINING[@]}" &
  child=$!

  # Spawn watcher that emits alive stderr every threshold seconds while child alive.
  (
    # disable inherited trap on EXIT
    trap '' EXIT
    local sleep_pid=""
    trap '[[ -n "${sleep_pid:-}" ]] && kill "${sleep_pid}" 2>/dev/null || true; [[ -n "${sleep_pid:-}" ]] && wait "${sleep_pid}" 2>/dev/null || true; exit 0' INT TERM
    while kill -0 "${child}" 2>/dev/null; do
      sleep "${threshold}" &
      sleep_pid=$!
      wait "${sleep_pid}" 2>/dev/null || true
      sleep_pid=""
      if kill -0 "${child}" 2>/dev/null; then
        printf '[alive] still in step: %s\n' "${step}" >&2
      fi
    done
  ) &
  watcher=$!

  local rc=0
  wait "${child}" || rc=$?
  kill "${watcher}" 2>/dev/null || true
  wait "${watcher}" 2>/dev/null || true
  trap - INT TERM

  return "${rc}"
}

main() {
  REMAINING=()
  parse_args "$@" || return $?

  if (( ALIVE_MODE == 1 )); then
    if (( JSON_MODE == 1 )) || [[ -n "${ROOT_DIR}" ]]; then
      echo "${SCRIPT_NAME}: --alive cannot be combined with --json or --root" >&2
      return 2
    fi
    run_alive
    return $?
  fi

  run_dashboard
}

main "$@"
