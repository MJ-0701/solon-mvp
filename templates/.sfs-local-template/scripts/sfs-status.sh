#!/usr/bin/env bash
# .sfs-local/scripts/sfs-status.sh
#
# Solon SFS — `/sfs status` command implementation.
# WU-24 §1 spec implementation. WU22-D4 사용자 결정 적용:
#   · 구분자 / --color flag (auto|always|never) / ISO8601 last_event.
#
# Output (one line):
#   sprint <id> · WU <wu_id> · gate <last_gate>:<verdict> · ahead <N> · last_event <ISO8601_ts>
#
# Exit codes (WU-23 §1.1 정합):
#   0  success
#   1  .sfs-local/ 부재
#   2  events.jsonl 손상
#   3  not a git repo
#   99 unknown (e.g. invalid CLI args)
#
# Path note: dev staging file lives at
#   solon-product/templates/.sfs-local-template/scripts/sfs-status.sh
# install.sh copies templates/.sfs-local-template/ → consumer project's .sfs-local/.
#
# Visibility: business-only (solon-product staging asset).
# Created: 2026-04-26 (scheduled run brave-gifted-thompson, 24th cycle row 6).

set -euo pipefail

# Source common helpers
SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

# ─────────────────────────────────────────────────────────────────────
# CLI parse
# ─────────────────────────────────────────────────────────────────────
COLOR_MODE="auto"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --color=*)
      COLOR_MODE="${1#*=}"
      shift
      ;;
    --color)
      if [[ $# -lt 2 ]]; then
        echo "missing value for --color (expected auto|always|never)" >&2
        exit "${SFS_EXIT_UNKNOWN}"
      fi
      COLOR_MODE="$2"
      shift 2
      ;;
    -h|--help)
      usage_status
      exit "${SFS_EXIT_OK}"
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "unknown flag: $1" >&2
      exit "${SFS_EXIT_UNKNOWN}"
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit "${SFS_EXIT_UNKNOWN}"
      ;;
  esac
done

# Validate --color value
case "${COLOR_MODE}" in
  auto|always|never) ;;
  *)
    echo "invalid --color value: ${COLOR_MODE} (expected auto|always|never)" >&2
    exit "${SFS_EXIT_UNKNOWN}"
    ;;
esac

# ─────────────────────────────────────────────────────────────────────
# Validate .sfs-local + git
# ─────────────────────────────────────────────────────────────────────
# validate_sfs_local returns:
#   0=ok, 1=no init, 2=corrupt events.jsonl, 3=no git
# We propagate the exact code (set -e is enabled, so explicit `|| exit $?`).
set +e
validate_sfs_local
_rc=$?
set -e
if [[ "${_rc}" -ne 0 ]]; then
  exit "${_rc}"
fi

# ─────────────────────────────────────────────────────────────────────
# Gather state (best-effort; all readers tolerate missing files)
# ─────────────────────────────────────────────────────────────────────
SPRINT_ID="$(read_current_sprint || true)"
WU_ID="$(read_current_wu || true)"
LAST_GATE="$(read_last_gate || true)"
VERDICT="$(read_last_gate_verdict || true)"
LAST_EVENT_TS="$(read_last_event_ts || true)"

# git_ahead_count returns SFS_EXIT_NO_GIT (3) when not a git repo.
# validate_sfs_local already ensured git presence; treat any non-zero as "0".
set +e
AHEAD="$(git_ahead_count)"
_ahead_rc=$?
set -e
if [[ "${_ahead_rc}" -ne 0 ]] || [[ -z "${AHEAD}" ]]; then
  AHEAD=0
fi
# Sanity: ensure AHEAD is a non-negative integer.
if ! [[ "${AHEAD}" =~ ^[0-9]+$ ]]; then
  AHEAD=0
fi

# ─────────────────────────────────────────────────────────────────────
# Render
# ─────────────────────────────────────────────────────────────────────
render_status_line \
  "${COLOR_MODE}" \
  "${SPRINT_ID}" \
  "${WU_ID}" \
  "${LAST_GATE}" \
  "${VERDICT}" \
  "${AHEAD}" \
  "${LAST_EVENT_TS}"

exit "${SFS_EXIT_OK}"
# End of sfs-status.sh
