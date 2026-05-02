#!/usr/bin/env bash
# .sfs-local/scripts/sfs-brainstorm.sh
#
# Solon SFS — `/sfs brainstorm` command implementation.
#
# Usage:
#   /sfs brainstorm [--simple|--easy|--quick|--hard] [<raw brief>]
#   /sfs brainstorm --stdin
#
# Output:
#   brainstorm.md ready: <path> | depth <simple|normal|hard> (<source>)
#   brainstorm.md ready: <path> | depth <...> | raw captured | AI runtime should refine §0-§7 as Solon CEO
#
# Exit codes:
#   0  success
#   1  no .sfs-local/ or no active sprint (run /sfs start first)
#   2  events.jsonl / current-sprint corrupt
#   3  not a git repo
#   4  sprint-templates/brainstorm.md missing
#   5  permission denied
#   99 unknown (CLI args, etc.)

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

usage_brainstorm() {
  cat <<'EOF'
Usage: /sfs brainstorm [--simple|--easy|--quick|--hard] [<raw brief>]
       /sfs brainstorm --stdin
       /sfs brainstorm --depth <simple|normal|hard>

Open/update the active sprint's brainstorm.md (Gate 2 Brainstorm document).
  - Creates brainstorm.md from sprint-templates/brainstorm.md if missing.
  - Accepts multiline raw context via --stdin or a quoted argument.
  - Appends raw input to brainstorm.md.
  - Records brainstorm depth:
      --simple / --easy / --quick  quick requirement cleanup + light questions
      default brainstorm            normal owner-thinking scaffold
      --hard                        product-owner hard training; no plan escape
  - In Claude/Codex/Gemini runtimes, the /sfs adapter should then refine
    §0~§7 as Solon CEO from the append log and ask follow-up questions.
  - Direct bash remains capture-only and prints the file path plus refinement hint.
  - Updates frontmatter: phase=brainstorm, last_touched_at=<ISO8601>.
  - Appends events.jsonl `brainstorm_open` event.
  - Prints the resolved brainstorm.md path to stdout.

Flow:
  /sfs start "<short sprint seed>"
  /sfs brainstorm --stdin
  /sfs plan

Exit codes:
  0  success
  1  no .sfs-local/ or no active sprint (run /sfs start first)
  2  events.jsonl / current-sprint corrupt
  3  not a git repo
  4  sprint-templates/brainstorm.md missing
  5  permission denied
  99 unknown (CLI args, etc.)
EOF
}

USE_STDIN=false
RAW_PARTS=()
BRAINSTORM_DEPTH="normal"
BRAINSTORM_DEPTH_SOURCE="default"

set_brainstorm_depth() {
  local raw="$1" source="$2"
  case "${raw}" in
    simple|easy|quick)
      BRAINSTORM_DEPTH="simple"
      ;;
    normal|default)
      BRAINSTORM_DEPTH="normal"
      ;;
    hard)
      BRAINSTORM_DEPTH="hard"
      ;;
    *)
      echo "invalid brainstorm depth: ${raw} (valid: simple, normal, hard)" >&2
      exit "${SFS_EXIT_UNKNOWN}"
      ;;
  esac
  BRAINSTORM_DEPTH_SOURCE="${source}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --simple|--easy|--quick)
      set_brainstorm_depth "${1#--}" "explicit"
      shift
      ;;
    --normal)
      set_brainstorm_depth "normal" "explicit"
      shift
      ;;
    --hard)
      set_brainstorm_depth "hard" "explicit"
      shift
      ;;
    --depth)
      shift
      if [[ $# -eq 0 ]]; then
        echo "missing value for --depth" >&2
        exit "${SFS_EXIT_UNKNOWN}"
      fi
      set_brainstorm_depth "$1" "explicit"
      shift
      ;;
    --depth=*)
      set_brainstorm_depth "${1#--depth=}" "explicit"
      shift
      ;;
    --stdin)
      USE_STDIN=true
      shift
      ;;
    -h|--help)
      usage_brainstorm
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
BRAINSTORM_PATH="${SPRINT_DIR}/brainstorm.md"
TEMPLATE="$(sfs_sprint_template_file brainstorm)"

if [[ ! -f "${BRAINSTORM_PATH}" ]]; then
  if [[ ! -f "${TEMPLATE}" ]]; then
    echo "template missing: ${TEMPLATE}" >&2
    exit "${SFS_EXIT_NO_TEMPLATES}"
  fi
  if ! mkdir -p "${SPRINT_DIR}" 2>/dev/null; then
    echo "permission denied creating ${SPRINT_DIR}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
  if ! cp -f "${TEMPLATE}" "${BRAINSTORM_PATH}" 2>/dev/null; then
    echo "permission denied copying template to ${BRAINSTORM_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
fi

NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"

if ! update_frontmatter "${BRAINSTORM_PATH}" "phase" "brainstorm" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${BRAINSTORM_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${BRAINSTORM_PATH}" "last_touched_at" "${NOW}" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${BRAINSTORM_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${BRAINSTORM_PATH}" "brainstorm_depth" "${BRAINSTORM_DEPTH}" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${BRAINSTORM_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${BRAINSTORM_PATH}" "brainstorm_depth_source" "${BRAINSTORM_DEPTH_SOURCE}" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${BRAINSTORM_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi

if [[ -n "${RAW_TEXT}" ]]; then
  {
    printf '\n### %s — raw input (depth: %s)\n\n' "${NOW}" "${BRAINSTORM_DEPTH}"
    printf '```text\n'
    printf '%s\n' "${RAW_TEXT}"
    printf '```\n'
  } >> "${BRAINSTORM_PATH}" || {
    echo "permission denied appending raw input to ${BRAINSTORM_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  }
fi

_esc_sprint="${SPRINT_ID//\\/\\\\}"
_esc_sprint="${_esc_sprint//\"/\\\"}"
_esc_path="${BRAINSTORM_PATH//\\/\\\\}"
_esc_path="${_esc_path//\"/\\\"}"
_esc_depth="${BRAINSTORM_DEPTH//\\/\\\\}"
_esc_depth="${_esc_depth//\"/\\\"}"
_esc_depth_source="${BRAINSTORM_DEPTH_SOURCE//\\/\\\\}"
_esc_depth_source="${_esc_depth_source//\"/\\\"}"

if ! append_event "brainstorm_open" "{\"sprint_id\":\"${_esc_sprint}\",\"path\":\"${_esc_path}\",\"depth\":\"${_esc_depth}\",\"depth_source\":\"${_esc_depth_source}\"}" 2>/dev/null; then
  echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
  exit "${SFS_EXIT_PERM}"
fi

if [[ -n "${RAW_TEXT}" ]]; then
  echo "brainstorm.md ready: ${BRAINSTORM_PATH} | depth ${BRAINSTORM_DEPTH} (${BRAINSTORM_DEPTH_SOURCE}) | raw captured | AI runtime should refine §0-§7 as Solon CEO"
else
  echo "brainstorm.md ready: ${BRAINSTORM_PATH} | depth ${BRAINSTORM_DEPTH} (${BRAINSTORM_DEPTH_SOURCE}) | no new raw input | AI runtime may refine existing §8 append log"
fi

exit "${SFS_EXIT_OK}"
# End of sfs-brainstorm.sh
