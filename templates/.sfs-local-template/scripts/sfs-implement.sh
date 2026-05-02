#!/usr/bin/env bash
# .sfs-local/scripts/sfs-implement.sh
#
# Solon SFS — `/sfs implement` command implementation.
#
# The bash adapter prepares deterministic execution artifacts. AI runtimes must
# then execute the requested work slice, update evidence, and run checks.

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

usage_implement() {
  cat <<'EOF'
Usage:
  /sfs implement [<work slice>]
  /sfs implement --stdin

Open/update the active sprint's implement.md execution artifact.
  - Intended flow: /sfs plan -> /sfs implement -> /sfs review --gate 6.
  - Creates implement.md from sprint-templates/implement.md if missing.
  - Records the implementation request and appends an implement_open event.
  - Prints implement.md, plan.md, and log.md paths.
  - AI runtimes must apply the execution harness:
    Think Before Execution, Simplicity First, Surgical Changes, Goal-Driven Execution.
  - Direct bash does not change product artifacts. AI runtimes must continue
    with the actual artifact work, checks, and evidence updates.

Exit codes:
  0  success
  1  no .sfs-local/ or no active sprint (run /sfs start first)
  2  events.jsonl / current-sprint corrupt
  3  not a git repo
  4  sprint-templates/implement.md missing
  5  permission denied
  99 unknown (CLI args, etc.)
EOF
}

USE_STDIN=false
RAW_PARTS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --stdin)
      USE_STDIN=true
      shift
      ;;
    -h|--help)
      usage_implement
      exit "${SFS_EXIT_OK}"
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        RAW_PARTS+=("$1")
        shift
      done
      ;;
    -*)
      echo "unknown flag: $1" >&2
      exit "${SFS_EXIT_UNKNOWN}"
      ;;
    *)
      RAW_PARTS+=("$1")
      shift
      ;;
  esac
done

RAW_TEXT=""
if [[ "${USE_STDIN}" == "true" ]]; then
  RAW_TEXT="$(cat)"
elif [[ ${#RAW_PARTS[@]} -gt 0 ]]; then
  RAW_TEXT="${RAW_PARTS[*]}"
fi

set +e
validate_sfs_local
_validate_rc=$?
set -e
if [[ "${_validate_rc}" -ne 0 ]]; then
  exit "${_validate_rc}"
fi

SPRINT_ID="$(read_current_sprint)"
if [[ -z "${SPRINT_ID}" ]]; then
  echo "no active sprint, run /sfs start first" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

SPRINT_DIR="${SFS_SPRINTS_DIR}/${SPRINT_ID}"
IMPLEMENT_PATH="${SPRINT_DIR}/implement.md"
PLAN_PATH="${SPRINT_DIR}/plan.md"
LOG_PATH="${SPRINT_DIR}/log.md"
TEMPLATE="$(sfs_sprint_template_file implement)"

if [[ ! -f "${IMPLEMENT_PATH}" ]]; then
  if [[ ! -f "${TEMPLATE}" ]]; then
    echo "template missing: ${TEMPLATE}" >&2
    exit "${SFS_EXIT_NO_TEMPLATES}"
  fi
  if ! mkdir -p "${SPRINT_DIR}" 2>/dev/null; then
    echo "permission denied creating ${SPRINT_DIR}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
  if ! cp -f "${TEMPLATE}" "${IMPLEMENT_PATH}" 2>/dev/null; then
    echo "permission denied copying template to ${IMPLEMENT_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
fi

NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"

if ! update_frontmatter "${IMPLEMENT_PATH}" "phase" "implement" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${IMPLEMENT_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${IMPLEMENT_PATH}" "status" "in-progress" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${IMPLEMENT_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${IMPLEMENT_PATH}" "last_touched_at" "${NOW}" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${IMPLEMENT_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi

if [[ -n "${RAW_TEXT}" ]]; then
  {
    printf '\n## %s — Implementation Request\n\n' "${NOW}"
    printf '```text\n'
    printf '%s\n' "${RAW_TEXT}"
    printf '```\n'
  } >> "${IMPLEMENT_PATH}" || {
    echo "permission denied appending request to ${IMPLEMENT_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  }
fi

_esc_sprint="${SPRINT_ID//\\/\\\\}"
_esc_sprint="${_esc_sprint//\"/\\\"}"
_esc_path="${IMPLEMENT_PATH//\\/\\\\}"
_esc_path="${_esc_path//\"/\\\"}"
_event_task="$(printf '%s' "${RAW_TEXT}" | tr '\n\r' '  ')"
_esc_task="${_event_task//\\/\\\\}"
_esc_task="${_esc_task//\"/\\\"}"

if [[ -n "${RAW_TEXT}" ]]; then
  _payload="{\"sprint_id\":\"${_esc_sprint}\",\"path\":\"${_esc_path}\",\"task\":\"${_esc_task}\"}"
else
  _payload="{\"sprint_id\":\"${_esc_sprint}\",\"path\":\"${_esc_path}\"}"
fi

if ! append_event "implement_open" "${_payload}" 2>/dev/null; then
  echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
  exit "${SFS_EXIT_PERM}"
fi

echo "implement.md ready: ${IMPLEMENT_PATH} | plan.md: ${PLAN_PATH} | log.md: ${LOG_PATH} | AI runtime must execute the work slice and record evidence now"

exit "${SFS_EXIT_OK}"
# End of sfs-implement.sh
