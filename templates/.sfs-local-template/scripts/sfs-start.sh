#!/usr/bin/env bash
# .sfs-local/scripts/sfs-start.sh
#
# Solon SFS — `/sfs start` command implementation.
# WU-24 §2 spec implementation. WU22-D5 사용자 결정 적용:
#   · ISO 8601 week sprint-id pattern (`<YYYY-Wxx>-sprint-<N>`).
#
# Usage:
#   /sfs start [<sprint-id>] [--force]
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
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=true
      shift
      ;;
    -h|--help)
      usage_start
      exit "${SFS_EXIT_OK}"
      ;;
    --)
      shift
      # Treat remaining as positional sprint-id (only one allowed).
      if [[ $# -gt 0 ]]; then
        if [[ -n "${SPRINT_ID}" ]]; then
          echo "multiple sprint-id args: '${SPRINT_ID}' and '$1'" >&2
          exit "${SFS_EXIT_UNKNOWN}"
        fi
        SPRINT_ID="$1"
        shift
      fi
      if [[ $# -gt 0 ]]; then
        echo "unexpected extra args after --: $*" >&2
        exit "${SFS_EXIT_UNKNOWN}"
      fi
      ;;
    -*)
      echo "unknown flag: $1" >&2
      exit "${SFS_EXIT_UNKNOWN}"
      ;;
    *)
      if [[ -n "${SPRINT_ID}" ]]; then
        echo "multiple sprint-id args: '${SPRINT_ID}' and '$1'" >&2
        exit "${SFS_EXIT_UNKNOWN}"
      fi
      SPRINT_ID="$1"
      shift
      ;;
  esac
done

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

# Ensure all 4 expected template files exist (WU-24 §2.3).
for tpl in plan log review retro; do
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

for tpl in plan log review retro; do
  if ! cp -f "${SFS_TEMPLATES_DIR}/${tpl}.md" "${SPRINT_DIR}/${tpl}.md" 2>/dev/null; then
    echo "permission denied copying ${tpl}.md to ${SPRINT_DIR}/" >&2
    exit "${SFS_EXIT_PERM}"
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

if ! append_event "sprint_start" "{\"sprint_id\":\"${_esc_sprint}\",\"by\":\"sfs-start\"}" 2>/dev/null; then
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
echo "  - plan.md"
echo "  - log.md"
echo "  - review.md"
echo "  - retro.md"

exit "${SFS_EXIT_OK}"
# End of sfs-start.sh
