#!/usr/bin/env bash
# .sfs-local/scripts/sfs-report.sh
#
# Solon SFS — `/sfs report [--sprint <id>] [--compact]`.
# Creates the compact final sprint report. With --compact, moves verbose
# workbench artifacts into .sfs-local/archives/ after user/AI approval.

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

: "${SFS_EXIT_BADCLI:=7}"

usage_report() {
  cat <<'EOF'
Usage:
  /sfs report [--sprint <id>] [--compact]

Create or update the compact sprint report.
  - Without --compact, prepares .sfs-local/sprints/<id>/report.md for AI/user refinement.
  - With --compact, marks report.md final and moves verbose workbench docs
    (brainstorm/plan/implement/log/review) into .sfs-local/archives/.
  - retro.md and decision files are preserved as history/learning.

Exit codes:
  0  ok
  1  no .sfs-local/ or no sprint
  4  report template missing
  5  permission denied
  7  usage
  99 unknown
EOF
}

SPRINT_ID=""
COMPACT=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sprint)
      if [[ $# -lt 2 ]]; then
        echo "--sprint requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      SPRINT_ID="$2"
      shift 2
      ;;
    --sprint=*)
      SPRINT_ID="${1#--sprint=}"
      shift
      ;;
    --current)
      SPRINT_ID=""
      shift
      ;;
    --compact)
      COMPACT=1
      shift
      ;;
    -h|--help)
      usage_report
      exit "${SFS_EXIT_OK}"
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

set +e
validate_sfs_local
_validate_rc=$?
set -e
if [[ "${_validate_rc}" -ne 0 ]]; then
  exit "${_validate_rc}"
fi

if [[ -z "${SPRINT_ID}" ]]; then
  SPRINT_ID="$(read_current_sprint)"
fi
if [[ -z "${SPRINT_ID}" ]]; then
  echo "no sprint selected (use --sprint <id> or run /sfs start first)" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

case "${SPRINT_ID}" in
  *..*|*/*|*\\*|*$'\n'*|*$'\t'*|*' '*|.*)
    echo "invalid sprint-id: '${SPRINT_ID}'" >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac

NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"
STATUS="draft"
if [[ "${COMPACT}" -eq 1 ]]; then
  STATUS="final"
fi

REPORT_PATH="$(sfs_prepare_sprint_report "${SPRINT_ID}" "${NOW}" "${STATUS}")"

_esc_sprint="${SPRINT_ID//\\/\\\\}"
_esc_sprint="${_esc_sprint//\"/\\\"}"
_esc_path="${REPORT_PATH//\\/\\\\}"
_esc_path="${_esc_path//\"/\\\"}"
append_event "report_ready" "{\"sprint_id\":\"${_esc_sprint}\",\"path\":\"${_esc_path}\",\"compact\":${COMPACT}}"

echo "report.md ready: ${REPORT_PATH}"

if [[ "${COMPACT}" -eq 1 ]]; then
  ARCHIVE_PATH="$(sfs_workbench_archive_dir "${SPRINT_ID}" "${NOW}")"
  sfs_compact_sprint_workbench "${SPRINT_ID}" "${NOW}"
  echo "archive: ${ARCHIVE_PATH}"
  echo "workbench archived: ${SPRINT_ID}"
fi

exit "${SFS_EXIT_OK}"
# End of sfs-report.sh
