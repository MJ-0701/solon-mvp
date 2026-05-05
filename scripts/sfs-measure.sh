#!/usr/bin/env bash
# sfs-measure.sh — measurement wrapper. chunk-2 scope: alive heartbeat sub-dim only (R-D / H5a).
#
# Wraps a target command and emits `[alive] still in step: <name>` to stderr every
# SFS_ALIVE_THRESHOLD_SECS seconds the command remains running, breaking 14-min
# silent hangs that previously violated AC-perf-5 by 28x in spike-claude-code-baseline-1.
#
# Out-of-scope for chunk-2 (DEFER per H5b priority 6):
#   --timer (i)  wall-clock + per-step trace  → 0.6.1+
#   --token (ii) claude-code token instrumentation → 0.6.1+
#
# Usage:
#   sfs-measure.sh --alive [--step <name>] [--threshold <secs>] -- <command> [args...]
#   sfs-measure.sh --help
#
# Env overrides:
#   SFS_ALIVE_THRESHOLD_SECS  default 30 (prod). Test harness uses 2.
#   SFS_MEASURE_STEP_NAME     fallback step-name if --step omitted.
#
# Exit codes: forward the wrapped command's exit code unchanged.

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

ALIVE_MODE=0
STEP_NAME=""
THRESHOLD=""

usage() {
  cat <<'EOF'
sfs-measure — measurement wrapper (chunk-2 scope: alive heartbeat sub-dim only)

Usage:
  sfs-measure.sh --alive [--step <name>] [--threshold <secs>] -- <command> [args...]

Modes:
  --alive            emit [alive] still in step: <name> to stderr every threshold seconds
  --help             print this help

Env:
  SFS_ALIVE_THRESHOLD_SECS  default 30 prod; tests use 2
  SFS_MEASURE_STEP_NAME     fallback step-name if --step not supplied

Out-of-scope (DEFER 0.6.1+ per H5b):
  --timer  wall-clock + per-step trace
  --token  claude-code token instrumentation

Exit code: forwards wrapped command's exit code.
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --alive) ALIVE_MODE=1; shift ;;
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

  if (( ALIVE_MODE != 1 )); then
    echo "${SCRIPT_NAME}: --alive required (chunk-2 scope: alive heartbeat sub-dim only)" >&2
    usage >&2
    return 2
  fi

  run_alive
}

main "$@"
