#!/usr/bin/env bash
# .sfs-local/scripts/sfs-plan.sh
#
# Solon SFS — `/sfs plan` command implementation.
# WU-25 §1 spec implementation. WU-23 §1.3 #4 (V-1 conditions) 정합:
#   · 파일 path stdout 출력만 (에디터 launch 안 함).
#
# Output (one line):
#   plan.md ready: <path>
#
# Exit codes (WU-25 §1.3 / WU-23 §1.3 정합):
#   0  success
#   1  no .sfs-local/ 또는 활성 sprint 없음 (run /sfs start first)
#   2  events.jsonl 손상 또는 current-sprint 손상
#   3  not a git repo
#   4  sprint-templates/plan.md 부재
#   5  permission denied
#   99 unknown (e.g. invalid CLI args)
#
# Path note: dev staging file lives at
#   solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-plan.sh
# install.sh copies templates/.sfs-local-template/ → consumer project's .sfs-local/.
# WU-25 §1 spec used `.sfs-local/scripts/` as a shorthand for the consumer-side path.
#
# Visibility: business-only (solon-mvp-dist staging asset).
# Created: 2026-04-28 (24th cycle user-active conversation `brave-gracious-mayer`,
#                      WU-25 §5 row 2).

set -euo pipefail

# Source common helpers
SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

# ─────────────────────────────────────────────────────────────────────
# USAGE (local — row 4 (sfs-common.sh 보강) 시 common 으로 이관 검토)
# ─────────────────────────────────────────────────────────────────────
usage_plan() {
  cat <<'EOF'
Usage: /sfs plan

Open the active sprint's plan.md (G1 Plan Gate document).
  - Creates plan.md from sprint-templates/plan.md if missing.
  - Updates frontmatter: phase=plan, last_touched_at=<ISO8601>.
  - Appends events.jsonl `plan_open` event.
  - Prints the resolved plan.md path to stdout (no editor launch).

Exit codes:
  0  success
  1  no .sfs-local/ or no active sprint (run /sfs start first)
  2  events.jsonl / current-sprint corrupt
  3  not a git repo
  4  sprint-templates/plan.md missing
  5  permission denied
  99 unknown (CLI args, etc.)
EOF
}

# ─────────────────────────────────────────────────────────────────────
# LOCAL HELPER — update_frontmatter (TODO: WU-25 row 4 시 sfs-common.sh 이관)
# ─────────────────────────────────────────────────────────────────────
# update_frontmatter <path> <key> <value>
# Replace `<key>: ...` line inside the YAML frontmatter (--- ... ---) at the
# top of the file. Appends `<key>: <value>` to the frontmatter block if the
# key is missing. Does nothing (returns 0) if the file has no frontmatter
# block — caller is responsible for creating one before invoking.
#
# Implementation note: pure-awk, no sed -i (BSD/GNU diff). Atomic via tmp+mv.
update_frontmatter() {
  local path="$1" key="$2" value="$3"
  [[ -f "${path}" ]] || return 1
  local tmp="${path}.tmp.$$"
  awk -v k="${key}" -v v="${value}" '
    BEGIN { in_fm=0; fm_seen=0; updated=0 }
    NR==1 && /^---[[:space:]]*$/ {
      in_fm=1; fm_seen=1; print; next
    }
    in_fm && /^---[[:space:]]*$/ {
      if (!updated) { print k ": " v }
      in_fm=0; print; next
    }
    in_fm {
      # Match `<key>:` (allow leading whitespace = 0; YAML root keys here).
      if ($0 ~ "^"k"[[:space:]]*:") {
        print k ": " v
        updated=1
        next
      }
      print; next
    }
    { print }
  ' "${path}" > "${tmp}" && mv -f "${tmp}" "${path}"
}

# ─────────────────────────────────────────────────────────────────────
# CLI parse (no positional args, only --help)
# ─────────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage_plan
      exit "${SFS_EXIT_OK}"
      ;;
    --)
      shift
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
      echo "unknown arg: $1" >&2
      exit "${SFS_EXIT_UNKNOWN}"
      ;;
  esac
done

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
PLAN_PATH="${SPRINT_DIR}/plan.md"
TEMPLATE="${SFS_LOCAL_DIR}/sprint-templates/plan.md"

# ─────────────────────────────────────────────────────────────────────
# Ensure plan.md exists (copy from template if missing)
# ─────────────────────────────────────────────────────────────────────
if [[ ! -f "${PLAN_PATH}" ]]; then
  if [[ ! -f "${TEMPLATE}" ]]; then
    echo "template missing: ${TEMPLATE}" >&2
    exit "${SFS_EXIT_NO_TEMPLATES}"
  fi
  if ! mkdir -p "${SPRINT_DIR}" 2>/dev/null; then
    echo "permission denied creating ${SPRINT_DIR}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
  if ! cp -f "${TEMPLATE}" "${PLAN_PATH}" 2>/dev/null; then
    echo "permission denied copying template to ${PLAN_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# Update frontmatter (phase + last_touched_at)
# ─────────────────────────────────────────────────────────────────────
NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"

if ! update_frontmatter "${PLAN_PATH}" "phase" "plan" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${PLAN_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${PLAN_PATH}" "last_touched_at" "${NOW}" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${PLAN_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi

# ─────────────────────────────────────────────────────────────────────
# Append plan_open event (ts auto-injected by append_event)
# ─────────────────────────────────────────────────────────────────────
# JSON-escape sprint-id and path (defensive — sprint-id shape was already
# validated by /sfs start, but path may include characters that escape).
_esc_sprint="${SPRINT_ID//\\/\\\\}"
_esc_sprint="${_esc_sprint//\"/\\\"}"
_esc_path="${PLAN_PATH//\\/\\\\}"
_esc_path="${_esc_path//\"/\\\"}"

if ! append_event "plan_open" "{\"sprint_id\":\"${_esc_sprint}\",\"path\":\"${_esc_path}\"}" 2>/dev/null; then
  echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
  exit "${SFS_EXIT_PERM}"
fi

# ─────────────────────────────────────────────────────────────────────
# Stdout (V-1 conditions #4 / WU-23 §1.3 #4 — path only, no editor launch)
# ─────────────────────────────────────────────────────────────────────
echo "plan.md ready: ${PLAN_PATH}"

exit "${SFS_EXIT_OK}"
# End of sfs-plan.sh
