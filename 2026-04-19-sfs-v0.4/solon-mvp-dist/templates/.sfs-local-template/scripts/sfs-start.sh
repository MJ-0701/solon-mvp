#!/usr/bin/env bash
# .sfs-local/scripts/sfs-start.sh
#
# Solon SFS — `/sfs start` command implementation.
# WU-24 §2 spec implementation. WU22-D5 사용자 결정 적용:
#   · ISO 8601 week sprint-id pattern (`<YYYY-Wxx>-sprint-<N>`).
#
# Usage:
#   /sfs start [<goal>] [--id <sprint-id>] [--force]
#
# Default sprint-id: <YYYY-Wxx>-sprint-<N>  (ISO week, auto-incremented).
#
# Exit codes (WU-23 §1.2 정합):
#   0  success
#   1  sprint id conflict (use --force or pick another id)
#   4  templates not found (.sfs-local/sprint-templates)
#   5  permission denied
#   99 unknown (e.g. invalid CLI args, ISO week tooling missing)
#
# Path note: dev staging file lives at
#   solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-start.sh
# install.sh copies templates/.sfs-local-template/ → consumer project's .sfs-local/.
# WU-24 spec used `.sfs-local/scripts/` as a shorthand for the consumer-side path.
#
# Visibility: business-only (solon-mvp-dist staging asset).
# Created: 2026-04-26 (scheduled run relaxed-gallant-maxwell, 24th cycle row 7).

set -euo pipefail

# Source common helpers
SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

# Local constant: templates dir lives under SFS_LOCAL_DIR.
SFS_TEMPLATES_DIR="${SFS_LOCAL_DIR}/sprint-templates"

# ─────────────────────────────────────────────────────────────────────
# CLI parse
# ─────────────────────────────────────────────────────────────────────
SPRINT_ID=""
CUSTOM_ID=""
GOAL=""
FORCE=false
GOAL_PARTS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=true
      shift
      ;;
    --id)
      shift
      if [[ $# -eq 0 ]]; then
        echo "missing value for --id" >&2
        exit "${SFS_EXIT_UNKNOWN}"
      fi
      CUSTOM_ID="$1"
      shift
      ;;
    --id=*)
      CUSTOM_ID="${1#--id=}"
      shift
      ;;
    -h|--help)
      usage_start
      exit "${SFS_EXIT_OK}"
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        GOAL_PARTS+=("$1")
        shift
      done
      ;;
    -*)
      echo "unknown flag: $1" >&2
      exit "${SFS_EXIT_UNKNOWN}"
      ;;
    *)
      GOAL_PARTS+=("$1")
      shift
      ;;
  esac
done

if [[ ${#GOAL_PARTS[@]} -gt 0 ]]; then
  GOAL="${GOAL_PARTS[*]}"
fi

# Backward compatibility: a single old-style sprint id may still be passed
# positionally. Free-text goals should use the default auto-generated id, and
# custom ids should use `--id`.
if [[ -z "${CUSTOM_ID}" && ${#GOAL_PARTS[@]} -eq 1 && "${GOAL_PARTS[0]}" == *sprint-* ]]; then
  CUSTOM_ID="${GOAL_PARTS[0]}"
  GOAL=""
fi

if [[ -n "${CUSTOM_ID}" ]]; then
  SPRINT_ID="${CUSTOM_ID}"
fi

# ─────────────────────────────────────────────────────────────────────
# Auto-generate sprint-id if not provided
# ─────────────────────────────────────────────────────────────────────
if [[ -z "${SPRINT_ID}" ]]; then
  set +e
  SPRINT_ID="$(generate_sprint_id_iso_week)"
  _gen_rc=$?
  set -e
  if [[ "${_gen_rc}" -ne 0 ]] || [[ -z "${SPRINT_ID}" ]]; then
    # generate_sprint_id_iso_week emits its own stderr on failure.
    exit "${SFS_EXIT_UNKNOWN}"
  fi
fi

# Goal is free text but must stay single-line for frontmatter/events.jsonl.
case "${GOAL}" in
  *$'\n'*|*$'\r'*)
    echo "invalid goal: newline not allowed" >&2
    exit "${SFS_EXIT_UNKNOWN}"
    ;;
esac

# Validate sprint-id shape (no path traversal, no whitespace, no leading dot).
case "${SPRINT_ID}" in
  *..*|*/*|*\\*|*$'\n'*|*$'\t'*|*' '*|.*)
    echo "invalid sprint-id: '${SPRINT_ID}' (no slashes / whitespace / leading dot)" >&2
    exit "${SFS_EXIT_UNKNOWN}"
    ;;
esac

# ─────────────────────────────────────────────────────────────────────
# Templates check (must exist before we touch sprints/)
# ─────────────────────────────────────────────────────────────────────
if [[ ! -d "${SFS_TEMPLATES_DIR}" ]]; then
  echo "templates not found: ${SFS_TEMPLATES_DIR}" >&2
  exit "${SFS_EXIT_NO_TEMPLATES}"
fi

# Ensure all 5 expected sprint template files exist.
for tpl in brainstorm plan log review retro; do
  if [[ ! -f "${SFS_TEMPLATES_DIR}/${tpl}.md" ]]; then
    echo "templates not found: ${SFS_TEMPLATES_DIR}/${tpl}.md" >&2
    exit "${SFS_EXIT_NO_TEMPLATES}"
  fi
done

# ─────────────────────────────────────────────────────────────────────
# Conflict check
# ─────────────────────────────────────────────────────────────────────
SPRINT_DIR="${SFS_SPRINTS_DIR}/${SPRINT_ID}"
if [[ -d "${SPRINT_DIR}" ]]; then
  if [[ "${FORCE}" != "true" ]]; then
    echo "sprint ${SPRINT_ID} already exists, use --force or pick another id" >&2
    exit 1
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# Scaffold sprint dir + copy templates
# ─────────────────────────────────────────────────────────────────────
if ! mkdir -p "${SPRINT_DIR}" 2>/dev/null; then
  echo "permission denied creating ${SPRINT_DIR}" >&2
  exit "${SFS_EXIT_PERM}"
fi

for tpl in brainstorm plan log review retro; do
  if ! cp -f "${SFS_TEMPLATES_DIR}/${tpl}.md" "${SPRINT_DIR}/${tpl}.md" 2>/dev/null; then
    echo "permission denied copying ${tpl}.md to ${SPRINT_DIR}/" >&2
    exit "${SFS_EXIT_PERM}"
  fi
done

NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"
_yaml_sprint="${SPRINT_ID//\\/\\\\}"
_yaml_sprint="${_yaml_sprint//\"/\\\"}"
_yaml_goal="${GOAL//\\/\\\\}"
_yaml_goal="${_yaml_goal//\"/\\\"}"

for doc in brainstorm plan log review retro; do
  update_frontmatter "${SPRINT_DIR}/${doc}.md" "sprint_id" "\"${_yaml_sprint}\"" || true
  update_frontmatter "${SPRINT_DIR}/${doc}.md" "created_at" "\"${NOW}\"" || true
  if [[ -n "${GOAL}" ]]; then
    update_frontmatter "${SPRINT_DIR}/${doc}.md" "goal" "\"${_yaml_goal}\"" || true
  fi
done

# ─────────────────────────────────────────────────────────────────────
# Update current-sprint pointer + emit sprint_start event
# ─────────────────────────────────────────────────────────────────────
if ! mkdir -p "${SFS_LOCAL_DIR}" 2>/dev/null; then
  echo "permission denied creating ${SFS_LOCAL_DIR}" >&2
  exit "${SFS_EXIT_PERM}"
fi

# JSON-escape sprint-id (only need to handle quotes/backslashes; we already
# rejected whitespace and slashes above, so this is mostly defensive).
_esc_sprint="${SPRINT_ID//\\/\\\\}"
_esc_sprint="${_esc_sprint//\"/\\\"}"
_esc_goal="${GOAL//\\/\\\\}"
_esc_goal="${_esc_goal//\"/\\\"}"

if [[ -n "${GOAL}" ]]; then
  _event_payload="{\"sprint_id\":\"${_esc_sprint}\",\"goal\":\"${_esc_goal}\",\"by\":\"sfs-start\"}"
else
  _event_payload="{\"sprint_id\":\"${_esc_sprint}\",\"by\":\"sfs-start\"}"
fi

if ! append_event "sprint_start" "${_event_payload}" 2>/dev/null; then
  echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
  exit "${SFS_EXIT_PERM}"
fi

if ! printf '%s\n' "${SPRINT_ID}" > "${SFS_CURRENT_SPRINT_FILE}" 2>/dev/null; then
  echo "permission denied writing ${SFS_CURRENT_SPRINT_FILE}" >&2
  exit "${SFS_EXIT_PERM}"
fi

# ─────────────────────────────────────────────────────────────────────
# Report
# ─────────────────────────────────────────────────────────────────────
echo "created: ${SPRINT_DIR}/"
echo "  - brainstorm.md"
echo "  - plan.md"
echo "  - log.md"
echo "  - review.md"
echo "  - retro.md"

exit "${SFS_EXIT_OK}"
# End of sfs-start.sh
