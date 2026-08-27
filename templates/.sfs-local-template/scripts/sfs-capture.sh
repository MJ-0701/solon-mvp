#!/usr/bin/env bash
# 증거 캡처: 승인/waiver/결정/리뷰순서/예외를 sprint log 와 active ledger 에 남긴다.
#
# Solon SFS — `/sfs capture` / `/sfs note` command implementation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SCRIPT_DIR}/sfs-common.sh"

: "${SFS_EXIT_BADCLI:=7}"

usage_capture() {
  cat <<'EOF'
Usage:
  sfs capture [--kind <note|decision|scope-change|user-approval|review-order|exception|evidence|blocker|waiver>] [--gate <1..7>] [--scope <wu|sprint|until-revoked>] [--sprint <id>] <text>
  sfs capture --stdin [--kind <kind>] [--gate <1..7>] [--scope <wu|sprint|until-revoked>] [--sprint <id>]
  sfs note <text>

Records a compact evidence fact into the current sprint's log.md and
events.jsonl. Capture is an evidence primitive, not a lifecycle gate or default
next step. Use it only for approval, waiver, decision, review-order override,
blocker, scope-change, or external evidence that a later gate must remember.

Capture is intentionally compact. SFS_CAPTURE_TEXT_MAX_CHARS defaults to 2000
bytes; set SFS_CAPTURE_ALLOW_LONG=1 only for an explicit local exception.

Exit codes:
  0  captured
  1  no .sfs-local/ or no active sprint
  4  log.md template missing
  5  permission denied
  6  invalid gate
  7  invalid args
EOF
}

CAPTURE_COMMAND="${SFS_CAPTURE_COMMAND:-capture}"
CAPTURE_KIND="note"
SPRINT_ID=""
GATE_ID=""
CAPTURE_SCOPE=""
READ_STDIN=false
TEXT_PARTS=()

if [[ "${CAPTURE_COMMAND}" == "note" ]]; then
  CAPTURE_KIND="note"
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage_capture
      exit "${SFS_EXIT_OK}"
      ;;
    --kind)
      if [[ $# -lt 2 ]]; then
        echo "--kind requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      CAPTURE_KIND="$2"
      shift 2
      ;;
    --kind=*)
      CAPTURE_KIND="${1#--kind=}"
      shift
      ;;
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
    --gate)
      if [[ $# -lt 2 ]]; then
        echo "--gate requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      GATE_ID="$2"
      shift 2
      ;;
    --gate=*)
      GATE_ID="${1#--gate=}"
      shift
      ;;
    --scope)
      if [[ $# -lt 2 ]]; then
        echo "--scope requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      CAPTURE_SCOPE="$2"
      shift 2
      ;;
    --scope=*)
      CAPTURE_SCOPE="${1#--scope=}"
      shift
      ;;
    --stdin)
      READ_STDIN=true
      shift
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        TEXT_PARTS+=("$1")
        shift
      done
      ;;
    -*)
      echo "unknown flag: $1" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
    *)
      TEXT_PARTS+=("$1")
      shift
      ;;
  esac
done

case "${CAPTURE_KIND}" in
  note|decision|scope-change|user-approval|approval|review-order|exception|evidence|blocker|waiver) ;;
  *)
    echo "invalid capture kind: ${CAPTURE_KIND}" >&2
    usage_capture >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac

# `approval` remains an accepted compatibility spelling, while all persisted
# evidence uses the canonical kind flowcheck consumes.
if [[ "${CAPTURE_KIND}" == "approval" ]]; then
  CAPTURE_KIND="user-approval"
fi

# --scope marks how long a user override / decision is authoritative. Required
# shape for user-override-precedence (policies/user-override-precedence.md):
# every override capture carries one. Valid for any kind; meaningful for
# exception / decision / user-approval (override ledger that flowcheck reads).
if [[ -n "${CAPTURE_SCOPE}" ]]; then
  case "${CAPTURE_SCOPE}" in
    wu|sprint|until-revoked) ;;
    *)
      echo "invalid capture scope: ${CAPTURE_SCOPE} (expected: wu, sprint, until-revoked)" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
  esac
fi

if [[ -n "${GATE_ID}" ]]; then
  _normalized_gate_id="$(sfs_normalize_gate_id "${GATE_ID}" || true)"
  if [[ -z "${_normalized_gate_id}" ]] || ! validate_gate_id "${_normalized_gate_id}"; then
    echo "unknown gate ${GATE_ID}, valid: $(sfs_gate_valid_display_list)" >&2
    exit "${SFS_EXIT_GATE:-6}"
  fi
  GATE_ID="${_normalized_gate_id}"
fi

CAPTURE_TEXT=""
if [[ ${#TEXT_PARTS[@]} -gt 0 ]]; then
  CAPTURE_TEXT="${TEXT_PARTS[*]}"
fi
if [[ "${READ_STDIN}" == "true" ]]; then
  STDIN_TEXT="$(cat)"
  if [[ -n "${CAPTURE_TEXT}" && -n "${STDIN_TEXT}" ]]; then
    CAPTURE_TEXT="${CAPTURE_TEXT}
${STDIN_TEXT}"
  elif [[ -n "${STDIN_TEXT}" ]]; then
    CAPTURE_TEXT="${STDIN_TEXT}"
  fi
fi

if [[ -z "${CAPTURE_TEXT}" ]]; then
  echo "capture text required" >&2
  usage_capture >&2
  exit "${SFS_EXIT_BADCLI}"
fi

CAPTURE_TEXT_MAX_CHARS="${SFS_CAPTURE_TEXT_MAX_CHARS:-2000}"
case "${CAPTURE_TEXT_MAX_CHARS}" in
  ''|*[!0-9]*)
    echo "SFS_CAPTURE_TEXT_MAX_CHARS must be a non-negative integer" >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac

CAPTURE_TEXT_BYTES="$(printf '%s' "${CAPTURE_TEXT}" | LC_ALL=C wc -c | tr -d '[:space:]')"
if [[ "${CAPTURE_TEXT_MAX_CHARS}" -gt 0 && "${CAPTURE_TEXT_BYTES}" -gt "${CAPTURE_TEXT_MAX_CHARS}" ]]; then
  case "${SFS_CAPTURE_ALLOW_LONG:-0}" in
    1|true|TRUE|yes|YES|on|ON) ;;
    *)
      echo "capture text too long (${CAPTURE_TEXT_BYTES} bytes > ${CAPTURE_TEXT_MAX_CHARS}); summarize the checkpoint or store bulky prompt/output as an artifact path" >&2
      echo "override only for an explicit local exception: SFS_CAPTURE_ALLOW_LONG=1" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
  esac
fi

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
  echo "no active sprint; run sfs start first or pass --sprint <id>" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

case "${SPRINT_ID}" in
  *..*|*/*|*\\*|*$'\n'*|*$'\t'*|*' '*|.*)
    echo "invalid sprint-id: '${SPRINT_ID}' (no slashes / whitespace / leading dot)" >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac

SPRINT_DIR="${SFS_SPRINTS_DIR}/${SPRINT_ID}"
if [[ ! -d "${SPRINT_DIR}" ]]; then
  echo "sprint not found: ${SPRINT_ID}" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

LOG_PATH="${SPRINT_DIR}/log.md"
TEMPLATE="$(sfs_sprint_template_file log)"
NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"
CAPTURE_ID="$(date -u +%Y%m%dT%H%M%SZ 2>/dev/null || date +%s)-$$"

if [[ ! -f "${LOG_PATH}" ]]; then
  if [[ ! -f "${TEMPLATE}" ]]; then
    echo "template missing: ${TEMPLATE}" >&2
    exit "${SFS_EXIT_NO_TEMPLATES}"
  fi
  cp -f "${TEMPLATE}" "${LOG_PATH}" 2>/dev/null || {
    echo "permission denied copying template to ${LOG_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  }
  update_frontmatter "${LOG_PATH}" "phase" "do" || true
  update_frontmatter "${LOG_PATH}" "sprint_id" "$(sfs_yaml_quote "${SPRINT_ID}")" || true
  update_frontmatter "${LOG_PATH}" "created_at" "$(sfs_yaml_quote "${NOW}")" || true
  _goal="$(sfs_goal_for_sprint "${SPRINT_ID}" || true)"
  if [[ -n "${_goal}" ]]; then
    update_frontmatter "${LOG_PATH}" "goal" "$(sfs_yaml_quote "${_goal}")" || true
  fi
fi
update_frontmatter "${LOG_PATH}" "last_touched_at" "$(sfs_yaml_quote "${NOW}")" || true

if ! grep -Fq "## Evidence Capture" "${LOG_PATH}" 2>/dev/null; then
  {
    printf '\n## Evidence Capture\n\n'
    printf '승인/waiver/결정/외부 evidence 처럼 gate 가 잃으면 안 되는 최소 사실만 남긴다. Capture 는 lifecycle 단계가 아니다.\n'
  } >> "${LOG_PATH}" || {
    echo "permission denied appending capture section to ${LOG_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  }
fi

{
  printf '\n### %s — %s (%s)\n\n' "${NOW}" "${CAPTURE_KIND}" "${CAPTURE_ID}"
  printf -- '- kind: `%s`\n' "${CAPTURE_KIND}"
  if [[ -n "${GATE_ID}" ]]; then
    printf -- '- gate: `%s`\n' "$(sfs_gate_display_label "${GATE_ID}")"
  fi
  if [[ -n "${CAPTURE_SCOPE}" ]]; then
    printf -- '- scope: `%s`\n' "${CAPTURE_SCOPE}"
  fi
  printf -- '- source: evidence-primitive\n'
  printf -- '- text:\n'
  while IFS= read -r line || [[ -n "${line}" ]]; do
    printf '  > %s\n' "${line}"
  done <<< "${CAPTURE_TEXT}"
} >> "${LOG_PATH}" || {
  echo "permission denied appending capture entry to ${LOG_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
}

PREVIEW="$(printf '%s' "${CAPTURE_TEXT}" | tr '\r\n\t' '   ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')"
PREVIEW="$(printf '%s' "${PREVIEW}" | LC_ALL=C cut -c 1-180)"

_esc_sprint="$(sfs_json_escape "${SPRINT_ID}")"
_esc_kind="$(sfs_json_escape "${CAPTURE_KIND}")"
_esc_capture="$(sfs_json_escape "${CAPTURE_ID}")"
_esc_path="$(sfs_json_escape "${LOG_PATH}")"
_esc_preview="$(sfs_json_escape "${PREVIEW}")"
_payload="\"sprint_id\":\"${_esc_sprint}\",\"kind\":\"${_esc_kind}\",\"capture_id\":\"${_esc_capture}\",\"path\":\"${_esc_path}\",\"text_preview\":\"${_esc_preview}\""
if [[ -n "${GATE_ID}" ]]; then
  _esc_gate="$(sfs_json_escape "${GATE_ID}")"
  _payload="${_payload},\"gate_id\":\"${_esc_gate}\""
fi
if [[ -n "${CAPTURE_SCOPE}" ]]; then
  _payload="${_payload},\"scope\":\"$(sfs_json_escape "${CAPTURE_SCOPE}")\""
fi
if ! append_event "evidence_capture" "{${_payload}}" 2>/dev/null; then
  echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
  exit "${SFS_EXIT_PERM}"
fi

echo "capture recorded: ${LOG_PATH} | sprint ${SPRINT_ID} | kind ${CAPTURE_KIND} | capture ${CAPTURE_ID}"
