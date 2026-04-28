#!/usr/bin/env bash
# .sfs-local/scripts/sfs-common.sh
#
# Solon SFS — common helper functions sourced by sfs-status.sh / sfs-start.sh / etc.
# WU-24 §3 spec implementation. bash 4+ required.
#
# Path note: dev staging file lives at
#   solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-common.sh
# install.sh copies templates/.sfs-local-template/ → consumer project's .sfs-local/.
# WU-24 spec used `.sfs-local/scripts/` as a shorthand for the consumer-side path.
#
# Visibility: business-only (solon-mvp-dist staging asset; OSS fork inclusion 결정은 후속).
# Created: 2026-04-26 (scheduled run friendly-magical-galileo, 24th cycle).

set -uo pipefail
# NOTE: callers `set -euo pipefail`; this file is sourced and uses non-fatal returns.

# ─────────────────────────────────────────────────────────────────────
# CONSTANTS
# ─────────────────────────────────────────────────────────────────────
SFS_LOCAL_DIR="${SFS_LOCAL_DIR:-.sfs-local}"
SFS_EVENTS_FILE="${SFS_LOCAL_DIR}/events.jsonl"
SFS_CURRENT_SPRINT_FILE="${SFS_LOCAL_DIR}/current-sprint"
SFS_CURRENT_WU_FILE="${SFS_LOCAL_DIR}/current-wu"
SFS_VERSION_FILE="${SFS_LOCAL_DIR}/VERSION"
SFS_SPRINTS_DIR="${SFS_LOCAL_DIR}/sprints"
SFS_DECISIONS_DIR="${SFS_LOCAL_DIR}/decisions"

# Exit codes (WU-23 §1.1 / §1.2 정합)
SFS_EXIT_OK=0
SFS_EXIT_NO_INIT=1
SFS_EXIT_CORRUPT=2
SFS_EXIT_NO_GIT=3
SFS_EXIT_NO_TEMPLATES=4
SFS_EXIT_PERM=5
SFS_EXIT_UNKNOWN=99

# ─────────────────────────────────────────────────────────────────────
# VALIDATION
# ─────────────────────────────────────────────────────────────────────

# validate_sfs_local — ensure .sfs-local/ + events.jsonl + git presence.
# Returns: 0=ok, 1=no init, 2=events.jsonl 손상, 3=no git.
validate_sfs_local() {
  if [[ ! -d "${SFS_LOCAL_DIR}" ]]; then
    echo "no .sfs-local found, run /sfs start first" >&2
    return ${SFS_EXIT_NO_INIT}
  fi
  if [[ -f "${SFS_EVENTS_FILE}" ]]; then
    # Each non-empty line must start with `{` and end with `}` (strict JSONL).
    local lineno=0
    while IFS= read -r line || [[ -n "${line}" ]]; do
      lineno=$((lineno + 1))
      [[ -z "${line}" ]] && continue
      if [[ "${line}" != \{*\} ]]; then
        echo "events.jsonl parse error at line ${lineno}" >&2
        return ${SFS_EXIT_CORRUPT}
      fi
    done < "${SFS_EVENTS_FILE}"
  fi
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "not a git repo (sfs requires git for ahead count)" >&2
    return ${SFS_EXIT_NO_GIT}
  fi
  return ${SFS_EXIT_OK}
}

# ─────────────────────────────────────────────────────────────────────
# READERS
# ─────────────────────────────────────────────────────────────────────

# read_current_sprint — stdout: sprint-id 또는 empty.
read_current_sprint() {
  if [[ -f "${SFS_CURRENT_SPRINT_FILE}" ]]; then
    head -n1 "${SFS_CURRENT_SPRINT_FILE}" | tr -d '[:space:]'
  fi
}

# read_current_wu — stdout: wu_id 또는 empty.
# Source priority: .sfs-local/current-wu → events.jsonl 마지막 wu_open event.
read_current_wu() {
  if [[ -f "${SFS_CURRENT_WU_FILE}" ]]; then
    head -n1 "${SFS_CURRENT_WU_FILE}" | tr -d '[:space:]'
    return 0
  fi
  # Fallback: scan events.jsonl backwards for last wu_open / wu_close.
  if [[ -f "${SFS_EVENTS_FILE}" ]]; then
    tac "${SFS_EVENTS_FILE}" 2>/dev/null \
      | grep -m1 '"type":"wu_open"' \
      | sed -nE 's/.*"wu_id"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p'
  fi
}

# read_last_gate — stdout: gate_id (events.jsonl 마지막 gate event).
read_last_gate() {
  [[ -f "${SFS_EVENTS_FILE}" ]] || return 0
  tac "${SFS_EVENTS_FILE}" 2>/dev/null \
    | grep -m1 '"type":"gate"' \
    | sed -nE 's/.*"gate_id"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p'
}

# read_last_gate_verdict — stdout: pass|partial|fail|empty.
read_last_gate_verdict() {
  [[ -f "${SFS_EVENTS_FILE}" ]] || return 0
  tac "${SFS_EVENTS_FILE}" 2>/dev/null \
    | grep -m1 '"type":"gate"' \
    | sed -nE 's/.*"verdict"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p'
}

# git_ahead_count — stdout: int (commits ahead of upstream).
# Returns: SFS_EXIT_NO_GIT (3) if not a git repo, 0 otherwise.
# When no upstream is configured, prints 0 and returns 0 (best-effort).
git_ahead_count() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    return ${SFS_EXIT_NO_GIT}
  fi
  local upstream
  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  if [[ -z "${upstream}" ]]; then
    echo 0
    return 0
  fi
  git rev-list --count "${upstream}..HEAD" 2>/dev/null || echo 0
}

# read_last_event_ts — stdout: ISO8601 ts (events.jsonl 마지막 entry, ts field).
read_last_event_ts() {
  [[ -f "${SFS_EVENTS_FILE}" ]] || return 0
  tail -n1 "${SFS_EVENTS_FILE}" 2>/dev/null \
    | sed -nE 's/.*"ts"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p'
}

# ─────────────────────────────────────────────────────────────────────
# GENERATION
# ─────────────────────────────────────────────────────────────────────

# generate_sprint_id_iso_week — stdout: <YYYY-Wxx>-sprint-<N>
# WU22-D5: ISO 8601 week numbering. <N> = 해당 week 안의 sprint 번호 (1+, 충돌 시 increment).
generate_sprint_id_iso_week() {
  local week_prefix
  # GNU date supports %G-W%V (ISO week-numbering year + ISO week number).
  # macOS `date` (BSD) does not support %V → fall back via gdate or python.
  if week_prefix="$(date +%G-W%V 2>/dev/null)" && [[ "${week_prefix}" =~ ^[0-9]{4}-W[0-9]{2}$ ]]; then
    :
  elif command -v gdate >/dev/null 2>&1; then
    week_prefix="$(gdate +%G-W%V)"
  elif command -v python3 >/dev/null 2>&1; then
    week_prefix="$(python3 -c 'import datetime; iso = datetime.date.today().isocalendar(); print(f"{iso.year}-W{iso.week:02d}")')"
  else
    echo "cannot determine ISO week (no GNU date/gdate/python3)" >&2
    return ${SFS_EXIT_UNKNOWN}
  fi

  local n=1
  while [[ -d "${SFS_SPRINTS_DIR}/${week_prefix}-sprint-${n}" ]]; do
    n=$((n + 1))
  done
  echo "${week_prefix}-sprint-${n}"
}

# ─────────────────────────────────────────────────────────────────────
# RENDER (color-aware)
# ─────────────────────────────────────────────────────────────────────

# _sfs_color_enabled MODE  — stdout 0/1 to indicate whether to emit colors.
# MODE: auto|always|never (default: auto).
_sfs_color_enabled() {
  local mode="${1:-auto}"
  case "${mode}" in
    always) return 0 ;;
    never)  return 1 ;;
    auto|*)
      if [[ -t 1 ]]; then return 0; else return 1; fi
      ;;
  esac
}

# render_status_line MODE SPRINT WU GATE VERDICT AHEAD TS — color-aware status line.
# Format (WU-24 §1.1):
#   sprint <id> · WU <wu_id> · gate <last_gate>:<verdict> · ahead <N> · last_event <ISO8601_ts>
# Empty fields render as `-` to keep separator alignment.
render_status_line() {
  local mode="${1:-auto}"
  local sprint="${2:-}"
  local wu="${3:-}"
  local gate="${4:-}"
  local verdict="${5:-}"
  local ahead="${6:-0}"
  local ts="${7:-}"

  local C_RESET="" C_GREEN="" C_YELLOW="" C_RED="" C_CYAN=""
  if _sfs_color_enabled "${mode}"; then
    C_RESET=$'\033[0m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_RED=$'\033[31m'
    C_CYAN=$'\033[36m'
  fi

  local v_color=""
  case "${verdict}" in
    pass)    v_color="${C_GREEN}" ;;
    partial) v_color="${C_YELLOW}" ;;
    fail)    v_color="${C_RED}" ;;
  esac

  local ahead_color=""
  if [[ "${ahead}" =~ ^[0-9]+$ ]] && (( ahead > 0 )); then
    ahead_color="${C_CYAN}"
  fi

  local s_disp="${sprint:--}"
  local w_disp="${wu:--}"
  local g_disp="${gate:--}"
  local v_disp="${verdict:--}"
  local t_disp="${ts:--}"

  printf 'sprint %s · WU %s · gate %s:%s%s%s · ahead %s%s%s · last_event %s\n' \
    "${s_disp}" \
    "${w_disp}" \
    "${g_disp}" \
    "${v_color}" "${v_disp}" "${C_RESET}" \
    "${ahead_color}" "${ahead}" "${C_RESET}" \
    "${t_disp}"
}

# ─────────────────────────────────────────────────────────────────────
# EVENT APPEND
# ─────────────────────────────────────────────────────────────────────

# append_event TYPE JSON_PAYLOAD — append one JSONL line to events.jsonl.
# JSON_PAYLOAD must already be a valid JSON object (e.g. '{"k":"v"}').
# Auto-injects `ts` (ISO8601 +TZ) and `type` if not present in payload.
append_event() {
  local etype="${1:?type required}"
  local payload="${2:-{\}}"
  local ts
  ts="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"

  # Strip outer braces from payload, reconstruct with ts/type prepended.
  # Caller-supplied payload precedence is preserved (type/ts in payload override defaults).
  local body="${payload#\{}"
  body="${body%\}}"
  body="$(echo "${body}" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"

  local prefix='"ts":"'"${ts}"'","type":"'"${etype}"'"'
  local line
  if [[ -z "${body}" ]]; then
    line="{${prefix}}"
  else
    line="{${prefix},${body}}"
  fi

  mkdir -p "${SFS_LOCAL_DIR}"
  printf '%s\n' "${line}" >> "${SFS_EVENTS_FILE}"
}

# ─────────────────────────────────────────────────────────────────────
# GATE ID HELPERS (WU-25 §3 추가, gates.md §1 7-enum SSoT 정합)
# ─────────────────────────────────────────────────────────────────────

# validate_gate_id <id> — gates.md §1 7-enum exact match (case-sensitive, hyphen 포함).
# 7-enum SSoT = gates.md §1 (cross-reference; 변경 시 양쪽 동시 갱신).
# Returns: 0 valid / 1 invalid.
# Caller usage:
#   if ! validate_gate_id "${GATE_ID}"; then
#     echo "unknown gate ${GATE_ID}, valid: G-1, G0, G1, G2, G3, G4, G5" >&2
#     exit 6
#   fi
validate_gate_id() {
  local id="${1:-}"
  case "${id}" in
    G-1|G0|G1|G2|G3|G4|G5) return 0 ;;
    *) return 1 ;;
  esac
}

# infer_last_gate_id — events.jsonl 마지막 review_open event 의 gate_id 추출.
# stdout: gate_id (없으면 빈 문자열). Return code 항상 0.
# WU-25 §2.1 default — `--gate <id>` 미지정 시 추론 fallback 으로 사용.
# read_last_gate (gate event) 와 분리: review 진입 시점 추적 = review_open scan.
infer_last_gate_id() {
  [[ -f "${SFS_EVENTS_FILE}" ]] || return 0
  tac "${SFS_EVENTS_FILE}" 2>/dev/null \
    | grep -m1 '"type":"review_open"' \
    | sed -nE 's/.*"gate_id"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p'
}

# ─────────────────────────────────────────────────────────────────────
# YAML FRONTMATTER UPDATER (WU-25 §3 추가, sfs-plan.sh local helper 이관)
# ─────────────────────────────────────────────────────────────────────

# update_frontmatter <path> <key> <value>
# Replace `<key>: ...` line inside the YAML frontmatter (--- ... ---) at the
# top of the file. Appends `<key>: <value>` to the frontmatter block if the
# key is missing. Does nothing (returns 0) if the file has no frontmatter
# block — caller is responsible for creating one before invoking.
#
# Implementation note: pure-awk, no sed -i (BSD/GNU portable). Atomic via
# tmp+mv (no partial writes if process dies mid-update).
#
# Returns: 0 on success, 1 if path missing or file unwritable.
update_frontmatter() {
  local path="${1:?path required}" key="${2:?key required}" value="${3-}"
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
# USAGE STUBS (consumer scripts override / call locally)
# ─────────────────────────────────────────────────────────────────────

usage_status() {
  cat <<'EOF'
Usage: /sfs status [--color=auto|always|never]

Print one line:
  sprint <id> · WU <wu_id> · gate <last_gate>:<verdict> · ahead <N> · last_event <ISO8601_ts>

Exit codes:
  0  success
  1  .sfs-local/ 부재 (run /sfs start first)
  2  events.jsonl 손상
  3  not a git repo
  99 unknown
EOF
}

usage_start() {
  cat <<'EOF'
Usage: /sfs start [<sprint-id>] [--force]

Default sprint-id pattern: <YYYY-Wxx>-sprint-<N>  (ISO 8601 week)

Exit codes:
  0  success
  1  sprint id 충돌 (use --force or pick another id)
  4  templates not found (.sfs-local/sprint-templates)
  5  permission denied
  99 unknown
EOF
}

# End of sfs-common.sh
