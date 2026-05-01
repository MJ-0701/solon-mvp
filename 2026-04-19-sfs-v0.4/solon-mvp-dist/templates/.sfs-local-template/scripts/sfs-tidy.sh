#!/usr/bin/env bash
# .sfs-local/scripts/sfs-tidy.sh
#
# Solon SFS — `/sfs tidy [--sprint <id>|--all] [--apply]`.
# Moves existing workbench docs into archive so the sprint directory keeps only
# report/retro/durable artifacts. Dry-run is the default; --apply is required
# for file changes.

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

: "${SFS_EXIT_BADCLI:=7}"

usage_tidy() {
  cat <<'EOF'
Usage:
  /sfs tidy [--sprint <id>] [--apply]
  /sfs tidy --all [--apply]

Clean up completed sprint workbench docs without deleting them.
  - Default is dry-run; it prints what would be archived.
  - --apply creates report.md when missing, then moves
    brainstorm/plan/implement/log/review into .sfs-local/archives/.
  - Matching .sfs-local/tmp review prompt/run files for the sprint are moved
    into the same archive tree.
  - The visible sprint folder keeps report.md, retro.md, decisions, and other
    durable artifacts; workbench dust leaves the main reading path.
  - When report.md was created from legacy workbench docs, AI runtimes should
    refine it into the final report immediately after the adapter returns.
  - report.md, retro.md, decision files, and events.jsonl are preserved.

Recommended close flow:
  1. /sfs tidy --sprint <id>          # inspect legacy state
  2. /sfs tidy --sprint <id> --apply  # create report if missing + archive workbench
  3. refine report.md into the final work report if it was newly created

Exit codes:
  0  ok
  1  no .sfs-local/ or no sprint
  5  permission denied
  7  usage
  99 unknown
EOF
}

validate_sprint_id_arg() {
  local sid="${1:-}"
  case "${sid}" in
    ""|*..*|*/*|*\\*|*$'\n'*|*$'\t'*|*' '*|.*)
      echo "invalid sprint-id: '${sid}'" >&2
      return "${SFS_EXIT_BADCLI}"
      ;;
  esac
  return "${SFS_EXIT_OK}"
}

tidy_candidate_count() {
  local sid="${1:?sprint id required}"
  local sdir="${SFS_SPRINTS_DIR}/${sid}"
  local doc path count=0
  for doc in brainstorm plan implement log review; do
    path="${sdir}/${doc}.md"
    [[ -f "${path}" ]] || continue
    count=$((count + 1))
  done
  printf '%s\n' "${count}"
}

tidy_tmp_candidate_count() {
  local sid="${1:?sprint id required}"
  local tmp_root="${SFS_LOCAL_DIR}/tmp"
  [[ -d "${tmp_root}" ]] || { printf '0\n'; return 0; }
  find "${tmp_root}" -type f -name "${sid}*" 2>/dev/null | wc -l | tr -d '[:space:]'
}

SPRINT_ID=""
ALL=0
APPLY=0

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
    --all)
      ALL=1
      shift
      ;;
    --apply)
      APPLY=1
      shift
      ;;
    -h|--help)
      usage_tidy
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

if [[ "${ALL}" -eq 1 && -n "${SPRINT_ID}" ]]; then
  echo "--all cannot be combined with --sprint" >&2
  exit "${SFS_EXIT_BADCLI}"
fi

set +e
validate_sfs_local
_validate_rc=$?
set -e
if [[ "${_validate_rc}" -ne 0 ]]; then
  exit "${_validate_rc}"
fi

TARGETS=""
if [[ "${ALL}" -eq 1 ]]; then
  for d in "${SFS_SPRINTS_DIR}"/*; do
    [[ -d "${d}" ]] || continue
    TARGETS="${TARGETS}${d##*/}"$'\n'
  done
else
  if [[ -z "${SPRINT_ID}" ]]; then
    SPRINT_ID="$(read_current_sprint)"
  fi
  if [[ -z "${SPRINT_ID}" ]]; then
    echo "no sprint selected (use --sprint <id>, --all, or run /sfs start first)" >&2
    exit "${SFS_EXIT_NO_INIT}"
  fi
  validate_sprint_id_arg "${SPRINT_ID}"
  TARGETS="${SPRINT_ID}"$'\n'
fi

if [[ -z "${TARGETS}" ]]; then
  echo "no sprint workspaces found" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"
CURRENT_SPRINT="$(read_current_sprint || true)"

# Apply preflight first so --all never half-applies before discovering a
# missing or invalid target.
if [[ "${APPLY}" -eq 1 ]]; then
  while IFS= read -r sid; do
    [[ -n "${sid}" ]] || continue
    validate_sprint_id_arg "${sid}"
    if [[ ! -d "${SFS_SPRINTS_DIR}/${sid}" ]]; then
      echo "sprint not found: ${sid}" >&2
      exit "${SFS_EXIT_NO_INIT}"
    fi
  done <<< "${TARGETS}"
fi

while IFS= read -r sid; do
  [[ -n "${sid}" ]] || continue
  validate_sprint_id_arg "${sid}"
  SPRINT_DIR="${SFS_SPRINTS_DIR}/${sid}"
  if [[ ! -d "${SPRINT_DIR}" ]]; then
    echo "sprint not found: ${sid}" >&2
    exit "${SFS_EXIT_NO_INIT}"
  fi

  REPORT_PATH="${SPRINT_DIR}/report.md"
  ARCHIVE_PATH="$(sfs_workbench_archive_dir "${sid}" "${NOW}")"
  COUNT="$(tidy_candidate_count "${sid}")"
  TMP_COUNT="$(tidy_tmp_candidate_count "${sid}")"
  ACTIVE="no"
  [[ "${sid}" == "${CURRENT_SPRINT}" ]] && ACTIVE="yes"

  if [[ "${APPLY}" -eq 0 ]]; then
    echo "tidy dry-run: ${sid}"
    echo "  active: ${ACTIVE}"
    if [[ -f "${REPORT_PATH}" ]]; then
      echo "  report: ${REPORT_PATH}"
    else
      echo "  report: missing (will create on --apply)"
    fi
    echo "  workbench: ${COUNT} file(s) would move to archive"
    echo "  tmp: ${TMP_COUNT} file(s) would move to archive"
    echo "  archive: ${ARCHIVE_PATH}"
    continue
  fi

  REPORT_CREATED=0
  REPORT_STATUS="final"
  if [[ ! -f "${REPORT_PATH}" ]]; then
    REPORT_CREATED=1
    REPORT_STATUS="migration-draft"
  fi
  REPORT_PATH="$(sfs_prepare_sprint_report "${sid}" "${NOW}" "${REPORT_STATUS}")"
  sfs_compact_sprint_workbench "${sid}" "${NOW}"

  _esc_sprint="${sid//\\/\\\\}"
  _esc_sprint="${_esc_sprint//\"/\\\"}"
  _esc_report="${REPORT_PATH//\\/\\\\}"
  _esc_report="${_esc_report//\"/\\\"}"
  _esc_archive="${ARCHIVE_PATH//\\/\\\\}"
  _esc_archive="${_esc_archive//\"/\\\"}"
  append_event "tidy_apply" "{\"sprint_id\":\"${_esc_sprint}\",\"report\":\"${_esc_report}\",\"archive\":\"${_esc_archive}\",\"workbench_files\":${COUNT},\"tmp_files\":${TMP_COUNT},\"report_created\":${REPORT_CREATED}}"

  echo "tidied: ${sid}"
  if [[ "${REPORT_CREATED}" -eq 1 ]]; then
    echo "  report: ${REPORT_PATH} (created; refine from archive)"
  else
    echo "  report: ${REPORT_PATH}"
  fi
  echo "  archive: ${ARCHIVE_PATH}"
  echo "  workbench: ${COUNT} file(s) moved"
  echo "  tmp: ${TMP_COUNT} file(s) moved"
done <<< "${TARGETS}"

exit "${SFS_EXIT_OK}"
