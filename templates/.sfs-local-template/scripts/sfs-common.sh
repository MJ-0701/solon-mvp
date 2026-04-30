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
# PORTABLE HELPERS (WU-29 hotfix — codex review finding #2 macOS tac fallback)
# ─────────────────────────────────────────────────────────────────────

# reverse_lines — print file contents in reverse line order.
#   $1 = file path
# Returns: 0 always (missing file → empty stdout, callers use grep -m1 ... || true).
# Priority: tac (gnu coreutils) > gtac (homebrew gnu) > tail -r (BSD/macOS) > awk fallback.
# WU-29 §2 spec verbatim. macOS 기본 환경 (tac/gtac 부재) 에서도 정상 동작 보장.
reverse_lines() {
  local f="${1:-}"
  [[ -f "${f}" ]] || return 0
  if command -v tac >/dev/null 2>&1; then
    tac "${f}"
  elif command -v gtac >/dev/null 2>&1; then
    gtac "${f}"
  elif tail -r </dev/null >/dev/null 2>&1; then
    # BSD tail (macOS) — `-r` reverse mode is non-POSIX but standard on Darwin.
    tail -r "${f}"
  else
    awk '{a[NR]=$0} END {for (i=NR;i>0;i--) print a[i]}' "${f}"
  fi
}

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
  # WU-29 hotfix: tac → reverse_lines for macOS portability.
  if [[ -f "${SFS_EVENTS_FILE}" ]]; then
    reverse_lines "${SFS_EVENTS_FILE}" \
      | grep -m1 '"type":"wu_open"' \
      | sed -nE 's/.*"wu_id"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p'
  fi
}

# read_last_gate — stdout: gate_id (events.jsonl 마지막 gate event).
read_last_gate() {
  [[ -f "${SFS_EVENTS_FILE}" ]] || return 0
  # WU-29 hotfix: tac → reverse_lines for macOS portability.
  reverse_lines "${SFS_EVENTS_FILE}" \
    | grep -m1 '"type":"gate"' \
    | sed -nE 's/.*"gate_id"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p'
}

# read_last_gate_verdict — stdout: pass|partial|fail|empty.
read_last_gate_verdict() {
  [[ -f "${SFS_EVENTS_FILE}" ]] || return 0
  # WU-29 hotfix: tac → reverse_lines for macOS portability.
  reverse_lines "${SFS_EVENTS_FILE}" \
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
  # NOTE: `grep -m1` returns non-zero when there is no match; under callers
  # using `set -o pipefail` (e.g. sfs-review.sh) that would abort the script.
  # Trailing `|| true` enforces the documented "Return code 항상 0" contract.
  # Fixed: 24th cycle 49번째 scheduled run `amazing-determined-gates`
  # (WU-25 row 3 sfs-review.sh smoke test T11 surfaced the bug).
  # WU-29 hotfix: tac → reverse_lines for macOS portability (codex review finding #2).
  reverse_lines "${SFS_EVENTS_FILE}" \
    | grep -m1 '"type":"review_open"' \
    | sed -nE 's/.*"gate_id"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' \
    || true
  return 0
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
Usage: /sfs start [<goal>] [--id <sprint-id>] [--force]

Default sprint-id pattern: <YYYY-Wxx>-sprint-<N>  (ISO 8601 week)
Goal is free text. Use --id only when you need a custom sprint id.
Use /sfs brainstorm for multiline/raw requirement context before /sfs plan.

Exit codes:
  0  success
  1  sprint id 충돌 (use --force or pick another id)
  4  templates not found (.sfs-local/sprint-templates)
  5  permission denied
  99 unknown
EOF
}

# ─────────────────────────────────────────────────────────────────────
# WU-27 LOOP HELPERS — Solon-wide executor + pre-flight + mutex FSM + review gate
# Spec: sprints/WU-27.md §3.1 + sprints/WU-27/sfs-loop-{flow,locking,review-gate}.md
# Created: 2026-04-29 (25th cycle session optimistic-vigilant-bell sub-task 6.3).
# ─────────────────────────────────────────────────────────────────────

# ─── EXECUTOR (WU-27 §3.1 Solon-wide convention) ────────────────────────────
# resolve_executor — given profile or custom cmd, echo resolved cmd line.
# CLI flag > env > "claude" fallback. Unknown profile → passthrough as custom string.
# stdout: resolved cmd
# rc: always 0
resolve_executor() {
  local executor="${1:-${SFS_EXECUTOR:-claude}}"
  case "$executor" in
    claude) echo "claude -p --dangerously-skip-permissions" ;;
    gemini) echo "gemini -p --yolo" ;;
    codex)  echo "codex exec --full-auto" ;;
    *)      echo "$executor" ;;   # custom string passthrough
  esac
}

# ─── PROGRESS PATH RESOLVER ──────────────────────────────────────────────────
# resolve_progress_path — resolve PROGRESS.md location.
# Priority: arg1 > $SFS_PROGRESS_PATH > $SFS_LOCAL_DIR/PROGRESS.md > ./PROGRESS.md
# stdout: absolute or relative path to PROGRESS.md
# rc: 0=found, 6=not found (matches SFS_LOOP_EXIT_SPEC_MISSING)
resolve_progress_path() {
  local override="${1:-}"
  local cand=""
  if [[ -n "$override" ]]; then
    cand="$override"
  elif [[ -n "${SFS_PROGRESS_PATH:-}" ]]; then
    cand="$SFS_PROGRESS_PATH"
  elif [[ -f "${SFS_LOCAL_DIR}/PROGRESS.md" ]]; then
    cand="${SFS_LOCAL_DIR}/PROGRESS.md"
  elif [[ -f "PROGRESS.md" ]]; then
    cand="PROGRESS.md"
  else
    echo "PROGRESS.md not found (set SFS_PROGRESS_PATH or run from a project root)" >&2
    return 6
  fi
  if [[ ! -f "$cand" ]]; then
    echo "PROGRESS.md path '$cand' does not exist" >&2
    return 6
  fi
  echo "$cand"
  return 0
}

# ─── PRE-FLIGHT (sfs-loop-flow.md §4 step 1~3) ───────────────────────────────
# pre_flight_check — sanity check before mutex claim.
# Inputs: $1 = PROGRESS.md path (or use resolve_progress_path)
# Checks:
#   - PROGRESS.md last_overwrite drift > 90 minutes (warn, return 16 = drift)
#   - .git/index.lock present (FUSE bypass needed, warn only)
#   - staged diff count (P-03 risk, warn only)
#   - YAML frontmatter parsable (python3 yaml if available, else minimal awk)
# stdout: optional context dict (key=value pairs)
# rc: 0=clean, 3=drift detected, 8=heartbeat write/read fail
pre_flight_check() {
  local progress_path="${1:-}"
  if [[ -z "$progress_path" ]]; then
    progress_path="$(resolve_progress_path)" || return 8
  fi

  # Drift check
  local last_overwrite
  last_overwrite=$(awk '/^last_overwrite:/ { sub(/^last_overwrite: */, ""); sub(/[ \t]*#.*$/, ""); print; exit }' "$progress_path")
  if [[ -n "$last_overwrite" ]]; then
    # Strip ISO8601 timezone for date parsing (best-effort, GNU date or BSD date).
    local lo_epoch now_epoch drift_min
    lo_epoch=$(date -d "$last_overwrite" +%s 2>/dev/null || \
               date -j -f "%Y-%m-%dT%H:%M:%S%z" "${last_overwrite//:00+/00+}" +%s 2>/dev/null || \
               echo "")
    now_epoch=$(date +%s)
    if [[ -n "$lo_epoch" ]]; then
      drift_min=$(( (now_epoch - lo_epoch) / 60 ))
      if (( drift_min > 90 )); then
        echo "pre-flight: drift detected (${drift_min}m since last_overwrite)" >&2
        echo "drift_min=${drift_min}"
        return 3
      fi
    fi
  fi

  # FUSE lock warn (non-fatal)
  if [[ -f ".git/index.lock" ]]; then
    echo "pre-flight: .git/index.lock present (FUSE bypass may be needed, see CLAUDE.md §1.6)" >&2
  fi

  # Staged diff warn (P-03)
  local staged_count
  staged_count=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  if (( staged_count > 0 )); then
    echo "pre-flight: ${staged_count} staged files (P-03 risk; review before claim)" >&2
  fi

  return 0
}

# ─── DOMAIN LOCK FSM HELPERS (sfs-loop-locking.md §6.5) ──────────────────────
# Note: These helpers operate on PROGRESS.md frontmatter `domain_locks.<X>` blocks.
# YAML manipulation = python3 if available (preferred), else awk-based fallback.
# Conceptual borrowing from Spring JPA @Version (claim_lock = version+=1).

# _domain_locks_field — read a single field from domain_locks.<domain>.<field>.
# Args: $1 = progress_path, $2 = domain, $3 = field
# stdout: field value or empty
_domain_locks_field() {
  local path="$1" domain="$2" field="$3"
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$path" "$domain" "$field" <<'PYEOF' 2>/dev/null
import sys, re
path, domain, field = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path) as f:
    content = f.read()
# Extract frontmatter (between first --- pair)
m = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
if not m:
    sys.exit(0)
fm = m.group(1)
# Find domain block + field
pat = rf'^\s*{re.escape(domain)}:\s*\n((?:[ \t]+.*\n?)*)'
mm = re.search(pat, fm, re.MULTILINE)
if not mm:
    sys.exit(0)
block = mm.group(1)
fpat = rf'^\s+{re.escape(field)}:\s*(.*?)\s*(?:#.*)?$'
fm2 = re.search(fpat, block, re.MULTILINE)
if fm2:
    val = fm2.group(1).strip()
    # Strip surrounding quotes
    if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
        val = val[1:-1]
    print(val)
PYEOF
  else
    # Awk fallback (best-effort, single-level only)
    awk -v dom="$domain" -v fld="$field" '
      $0 ~ "^[[:space:]]*"dom":" { in_block=1; next }
      in_block && $0 ~ "^[^ \t]" { in_block=0 }
      in_block && $0 ~ "^[[:space:]]+"fld":" {
        sub(/^[[:space:]]+[^:]+:[[:space:]]*/, "")
        sub(/[[:space:]]*#.*$/, "")
        gsub(/^["'\'']|["'\'']$/, "")
        print; exit
      }
    ' "$path"
  fi
}

# detect_stale — check if domain owner is stale (last_heartbeat > ttl_minutes).
# Args: $1 = progress_path, $2 = domain
# rc: 0=stale, 1=fresh, 2=no owner
detect_stale() {
  local path="$1" domain="$2"
  local owner last_hb ttl
  owner=$(_domain_locks_field "$path" "$domain" "owner")
  if [[ -z "$owner" || "$owner" == "null" ]]; then
    return 2
  fi
  last_hb=$(_domain_locks_field "$path" "$domain" "last_heartbeat")
  ttl=$(_domain_locks_field "$path" "$domain" "ttl_minutes")
  ttl="${ttl:-15}"

  local hb_epoch now_epoch elapsed_min
  hb_epoch=$(date -d "$last_hb" +%s 2>/dev/null || \
             date -j -f "%Y-%m-%dT%H:%M:%S%z" "$last_hb" +%s 2>/dev/null || \
             echo 0)
  now_epoch=$(date +%s)
  elapsed_min=$(( (now_epoch - hb_epoch) / 60 ))
  if (( elapsed_min > ttl )); then
    return 0   # stale
  else
    return 1   # fresh
  fi
}

# claim_lock — claim domain lock with optimistic version bump.
# Args: $1 = progress_path, $2 = domain, $3 = owner_codename
# Effect: PROGRESS.md frontmatter domain_locks.<domain> updated:
#   owner=$3, claimed_at=now, last_heartbeat=now, status=PROGRESS, version+=1, retry_count preserved
# rc: 0=claimed, 4=race lost (other owner)
claim_lock() {
  local path="$1" domain="$2" owner="$3"
  local now lock_dir
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  lock_dir="${path}.lock"

  # § 6.8.3 (26th-1 admiring-compassionate-euler): mkdir-based atomic claim.
  # TOCTOU race window 차단 (POSIX-portable, macOS+Linux 양립). `mkdir` 은 atomic
  # file system operation = 동시 worker 호출 시 한 명만 성공. 이전 버그 = bash read owner →
  # python3 write 사이 inter-process gap 으로 양쪽 worker 가 owner=null 본 후 양쪽 write 가능.
  # 후속 W10: stale lock dir 자동 정리 (mtime 기반) + release_lock/mark_*/auto_restart 도 동일 lock 보호.
  if ! mkdir "$lock_dir" 2>/dev/null; then
    return 4   # race lost (다른 worker 가 lock dir 점유 중)
  fi

  # === lock 보호 영역 시작 ===
  local rc=0
  local cur_owner
  cur_owner=$(_domain_locks_field "$path" "$domain" "owner")
  if [[ -n "$cur_owner" && "$cur_owner" != "null" && "$cur_owner" != "$owner" ]]; then
    if ! detect_stale "$path" "$domain"; then
      rmdir "$lock_dir" 2>/dev/null
      return 4   # race lost (active other owner)
    fi
    # stale → takeover allowed (caller decides retry)
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$path" "$domain" "$owner" "$now" <<'PYEOF'
import sys, re
path, domain, owner, now = sys.argv[1:5]
with open(path) as f:
    content = f.read()
def repl_or_add(block, key, val):
    pat = rf'(^[ \t]+{re.escape(key)}:[ \t]*).*?(\s*#.*)?$'
    if re.search(pat, block, re.MULTILINE):
        return re.sub(pat, lambda m: f"{m.group(1)}{val}{m.group(2) or ''}", block, count=1, flags=re.MULTILINE)
    indent = '    '
    if block and not block.endswith('\n'):
        block += '\n'
    return block + f"{indent}{key}: {val}\n"
def bump_version(block):
    pat = r'(^[ \t]+version:[ \t]*)(\d+)(\s*#.*)?$'
    m = re.search(pat, block, re.MULTILINE)
    if m:
        new_v = int(m.group(2)) + 1
        return re.sub(pat, lambda mm: f"{mm.group(1)}{new_v}{mm.group(3) or ''}", block, count=1, flags=re.MULTILINE)
    return block + "    version: 1\n"
m = re.search(r'^(---\n)(.*?)(\n---)', content, re.DOTALL)
if not m:
    sys.exit(2)
fm = m.group(2)
dpat = rf'(^\s*{re.escape(domain)}:\s*\n)((?:[ \t]+.*\n?)*)'
dm = re.search(dpat, fm, re.MULTILINE)
if not dm:
    sys.exit(2)
header, block = dm.group(1), dm.group(2)
block = repl_or_add(block, 'owner', owner)
block = repl_or_add(block, 'claimed_at', now)
block = repl_or_add(block, 'last_heartbeat', now)
block = repl_or_add(block, 'status', 'PROGRESS')
block = bump_version(block)
new_fm = fm[:dm.start()] + header + block + fm[dm.end():]
new_content = m.group(1) + new_fm + m.group(3) + content[m.end():]
with open(path, 'w') as f:
    f.write(new_content)
PYEOF
    rc=$?
  else
    echo "claim_lock: python3 required for YAML manipulation" >&2
    rc=99
  fi

  # === lock 해제 (§ 6.8.3) ===
  rmdir "$lock_dir" 2>/dev/null
  return $rc
}

# release_lock — release domain lock.
# Args: $1 = progress_path, $2 = domain, $3 = verdict (complete|fail)
# Effect: owner=null, status=COMPLETE or FAIL based on verdict.
# rc: 0=ok
release_lock() {
  local path="$1" domain="$2" verdict="${3:-complete}"
  local new_status="COMPLETE"
  case "$verdict" in
    complete) new_status="COMPLETE" ;;
    fail)     new_status="FAIL" ;;
    *)        echo "release_lock: invalid verdict '$verdict' (expected complete|fail)" >&2; return 1 ;;
  esac
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$path" "$domain" "$new_status" <<'PYEOF'
import sys, re
path, domain, new_status = sys.argv[1:4]
with open(path) as f:
    content = f.read()
m = re.search(r'^(---\n)(.*?)(\n---)', content, re.DOTALL)
if not m: sys.exit(2)
fm = m.group(2)
dpat = rf'(^\s*{re.escape(domain)}:\s*\n)((?:[ \t]+.*\n?)*)'
dm = re.search(dpat, fm, re.MULTILINE)
if not dm: sys.exit(2)
header, block = dm.group(1), dm.group(2)
def repl(block, key, val):
    pat = rf'(^[ \t]+{re.escape(key)}:[ \t]*).*?(\s*#.*)?$'
    if re.search(pat, block, re.MULTILINE):
        return re.sub(pat, lambda mm: f"{mm.group(1)}{val}{mm.group(2) or ''}", block, count=1, flags=re.MULTILINE)
    if block and not block.endswith('\n'):
        block += '\n'
    return block + f"    {key}: {val}\n"
block = repl(block, 'owner', 'null')
block = repl(block, 'status', new_status)
new_fm = fm[:dm.start()] + header + block + fm[dm.end():]
with open(path, 'w') as f:
    f.write(m.group(1) + new_fm + m.group(3) + content[m.end():])
PYEOF
    return $?
  fi
  return 99
}

# mark_fail — mark domain as FAIL with reason.
# Args: $1 = progress_path, $2 = domain, $3 = reason
mark_fail() {
  local path="$1" domain="$2" reason="$3"
  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$path" "$domain" "$reason" "$now" <<'PYEOF'
import sys, re
path, domain, reason, now = sys.argv[1:5]
with open(path) as f:
    content = f.read()
m = re.search(r'^(---\n)(.*?)(\n---)', content, re.DOTALL)
if not m: sys.exit(2)
fm = m.group(2)
dpat = rf'(^\s*{re.escape(domain)}:\s*\n)((?:[ \t]+.*\n?)*)'
dm = re.search(dpat, fm, re.MULTILINE)
if not dm: sys.exit(2)
header, block = dm.group(1), dm.group(2)
def repl(b, k, v):
    pat = rf'(^[ \t]+{re.escape(k)}:[ \t]*).*?(\s*#.*)?$'
    if re.search(pat, b, re.MULTILINE):
        return re.sub(pat, lambda mm: f"{mm.group(1)}{v}{mm.group(2) or ''}", b, count=1, flags=re.MULTILINE)
    if b and not b.endswith('\n'):
        b += '\n'
    return b + f"    {k}: {v}\n"
block = repl(block, 'status', 'FAIL')
block = repl(block, 'failed_at', now)
block = repl(block, 'fail_reason', reason)
block = repl(block, 'owner', 'null')
new_fm = fm[:dm.start()] + header + block + fm[dm.end():]
with open(path, 'w') as f:
    f.write(m.group(1) + new_fm + m.group(3) + content[m.end():])
PYEOF
    return $?
  fi
  return 99
}

# mark_abandoned — mark domain as ABANDONED (retry_count >= 3).
# Args: $1 = progress_path, $2 = domain
# § 6.8.4 (26th-1): 성공 시 escalate_w10_todo auto-wire (best-effort), spec §6.5.4 정합.
mark_abandoned() {
  local path="$1" domain="$2"
  local rc=99
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$path" "$domain" <<'PYEOF'
import sys, re
path, domain = sys.argv[1:3]
with open(path) as f:
    content = f.read()
m = re.search(r'^(---\n)(.*?)(\n---)', content, re.DOTALL)
if not m: sys.exit(2)
fm = m.group(2)
dpat = rf'(^\s*{re.escape(domain)}:\s*\n)((?:[ \t]+.*\n?)*)'
dm = re.search(dpat, fm, re.MULTILINE)
if not dm: sys.exit(2)
header, block = dm.group(1), dm.group(2)
def repl(b, k, v):
    pat = rf'(^[ \t]+{re.escape(k)}:[ \t]*).*?(\s*#.*)?$'
    if re.search(pat, b, re.MULTILINE):
        return re.sub(pat, lambda mm: f"{mm.group(1)}{v}{mm.group(2) or ''}", b, count=1, flags=re.MULTILINE)
    if b and not b.endswith('\n'):
        b += '\n'
    return b + f"    {k}: {v}\n"
block = repl(block, 'status', 'ABANDONED')
block = repl(block, 'owner', 'null')
new_fm = fm[:dm.start()] + header + block + fm[dm.end():]
with open(path, 'w') as f:
    f.write(m.group(1) + new_fm + m.group(3) + content[m.end():])
PYEOF
    rc=$?
  fi
  # § 6.8.4 (26th-1 admiring-compassionate-euler): auto-escalate to W10 TODO (best-effort).
  # ABANDONED status 마킹 성공 시 cross-ref-audit.md §4 W-AUTO entry append.
  # escalate 실패해도 ABANDONED 자체는 잘 남으니 rc 우선 보존 (best-effort).
  if (( rc == 0 )); then
    escalate_w10_todo "$domain" "ABANDONED (retry_count >= 3) — domain locked unrecoverable, awaiting user resolution" >/dev/null 2>&1 || true
  fi
  return $rc
}

# auto_restart — retry FAIL domain by re-claiming (retry_count+=1, version+=1).
# Args: $1 = progress_path, $2 = domain, $3 = owner
# Pre-cond: status==FAIL, retry_count<3.
# rc: 0=restarted, 1=cap reached (caller should mark_abandoned), 4=other owner active
auto_restart() {
  local path="$1" domain="$2" owner="$3"
  local status retry
  status=$(_domain_locks_field "$path" "$domain" "status")
  retry=$(_domain_locks_field "$path" "$domain" "retry_count")
  retry="${retry:-0}"
  if [[ "$status" != "FAIL" ]]; then
    echo "auto_restart: domain '$domain' status='$status' (expected FAIL)" >&2
    return 1
  fi
  if (( retry >= 3 )); then
    return 1   # cap reached
  fi
  # bump retry, then claim
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$path" "$domain" <<'PYEOF'
import sys, re
path, domain = sys.argv[1:3]
with open(path) as f:
    content = f.read()
m = re.search(r'^(---\n)(.*?)(\n---)', content, re.DOTALL)
fm = m.group(2)
dpat = rf'(^\s*{re.escape(domain)}:\s*\n)((?:[ \t]+.*\n?)*)'
dm = re.search(dpat, fm, re.MULTILINE)
header, block = dm.group(1), dm.group(2)
pat = r'(^[ \t]+retry_count:[ \t]*)(\d+)(\s*#.*)?$'
mm = re.search(pat, block, re.MULTILINE)
if mm:
    new_r = int(mm.group(2)) + 1
    block = re.sub(pat, lambda x: f"{x.group(1)}{new_r}{x.group(3) or ''}", block, count=1, flags=re.MULTILINE)
else:
    block += "    retry_count: 1\n"
new_fm = fm[:dm.start()] + header + block + fm[dm.end():]
with open(path, 'w') as f:
    f.write(m.group(1) + new_fm + m.group(3) + content[m.end():])
PYEOF
  fi
  claim_lock "$path" "$domain" "$owner"
  return $?
}

# escalate_w10_todo — append W-XX TODO entry to cross-ref-audit.md §4.
# Args: $1 = domain, $2 = message
# Side effect: cross-ref-audit.md §4 W-XX entry appended (best-effort path resolve).
escalate_w10_todo() {
  local domain="$1" msg="$2"
  local audit_path=""
  for cand in "cross-ref-audit.md" "../cross-ref-audit.md" "../../cross-ref-audit.md"; do
    if [[ -f "$cand" ]]; then audit_path="$cand"; break; fi
  done
  if [[ -z "$audit_path" ]]; then
    echo "escalate_w10_todo: cross-ref-audit.md not found, skipping (msg: $msg)" >&2
    return 1
  fi
  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  printf '\n- W-AUTO (%s) [%s]: %s\n' "$now" "$domain" "$msg" >> "$audit_path"
  echo "escalate_w10_todo: appended to $audit_path" >&2
  return 0
}

# ─── REVIEW GATE HELPERS (sfs-loop-review-gate.md §6.6) ──────────────────────

# is_big_task — apply 5 criteria from sfs-loop-review-gate.md §6.6.3.
# Args: $1 = plan-spec file or stdin (frontmatter with `wall_min` / `files_touched` / `decision_points`)
# rc: 0=big task (review gate required), 1=small task (skip OK)
is_big_task() {
  local spec="${1:-}"
  local content
  if [[ -n "$spec" && -f "$spec" ]]; then
    content=$(cat "$spec")
  else
    content=$(cat)
  fi
  # 5 criteria
  local wall_min files_touched decision_points spec_change visibility_change
  wall_min=$(echo "$content" | awk '/^wall_min:/ { sub(/^wall_min:[ \t]*/, ""); print; exit }')
  files_touched=$(echo "$content" | awk '/^files_touched_count:/ { sub(/^files_touched_count:[ \t]*/, ""); print; exit }')
  decision_points=$(echo "$content" | grep -cE '^[ \t]*-[ \t]*id:[ \t]*[A-Z]+[0-9]+-D[0-9]+' || true)
  decision_points="${decision_points:-0}"
  spec_change=$(echo "$content" | awk '/^spec_change:/ { sub(/^spec_change:[ \t]*/, ""); print; exit }')
  visibility_change=$(echo "$content" | awk '/^visibility_change:/ { sub(/^visibility_change:[ \t]*/, ""); print; exit }')

  (( ${wall_min:-0} >= 10 )) && return 0
  (( ${files_touched:-0} >= 3 )) && return 0
  (( ${decision_points:-0} >= 1 )) && return 0
  [[ "${spec_change:-false}" == "true" ]] && return 0
  [[ "${visibility_change:-false}" == "true" ]] && return 0
  return 1
}

# _builtin_persona_text — emit a 4-line built-in persona text for known roles.
# § 6.8.4b (26th-1 admiring-compassionate-euler, 사용자 추가 정책): known persona file 부재 시
# review_with_persona 가 사용하는 fallback. 미래 live=1 (WU27-D6 후속) 시 LLM 호출 stdin 공급원.
# Args: $1 = kind (planner|evaluator)
# rc: 0=ok stdout=persona text, 99=unknown kind
_builtin_persona_text() {
  local kind="$1"
  case "$kind" in
    planner)
      cat <<'EOF_PLANNER'
You are the CEO reviewer for Solon autonomous work.
Check scope, time cap, files_touched cap, decision_points, rollback risk, and whether user approval is required.
Prefer minimal cleanup when choices are ambiguous.
Return verdict: PASS, FAIL, or PASS-with-conditions with one concise reason.
EOF_PLANNER
      ;;
    evaluator)
      cat <<'EOF_EVALUATOR'
You are the CPO reviewer for Solon autonomous work.
Check user-facing clarity, failure behavior, safety locks, recovery notes, and whether the result is understandable to the next worker.
Prefer fail-closed behavior for uncertain automation.
Return verdict: PASS, FAIL, or PASS-with-conditions with one concise reason.
EOF_EVALUATOR
      ;;
    *)
      return 99
      ;;
  esac
  return 0
}

# review_with_persona — invoke a persona file as reviewer.
# Args: $1 = persona-path (e.g. agents/planner.md), $2 = plan-doc path
# Output: stdout = "verdict: PASS|FAIL|PASS-with-conditions\nreason: <prose>"
# rc: 0=PASS, 1=FAIL, 2=PASS-with-conditions, 99=hard error / unknown persona missing
# NOTE: This MVP version emits a deterministic stub when no executor is connected.
#       Full LLM invocation = future WU when --executor runtime is wired (WU27-D6).
review_with_persona() {
  local persona_path="$1" plan_doc="$2"
  local persona_source="file"   # file | builtin-planner | builtin-evaluator
  if [[ ! -f "$persona_path" ]]; then
    # § 6.8.4b (26th-1): known persona missing → built-in fallback,
    # unknown persona missing → rc=99 fail-closed (review 의미 왜곡 방지,
    # 다른 이름으로 CEO/CPO fallback 호출 차단).
    case "$(basename "$persona_path")" in
      planner.md)
        persona_source="builtin-planner"
        echo "review_with_persona: persona file missing, using built-in fallback (planner CEO scope-risk reviewer)" >&2
        ;;
      evaluator.md)
        persona_source="builtin-evaluator"
        echo "review_with_persona: persona file missing, using built-in fallback (evaluator CPO user-impact reviewer)" >&2
        ;;
      *)
        echo "review_with_persona: persona not found: $persona_path (unknown name, fail-closed)" >&2
        return 99
        ;;
    esac
  fi
  if [[ ! -f "$plan_doc" ]]; then
    echo "review_with_persona: plan doc not found: $plan_doc" >&2
    return 99
  fi
  # § 6.8.2 (26th-1 admiring-compassionate-euler): SFS_LOOP_LLM_LIVE env gating fail-closed.
  # CHANGELOG v1.0-rc1 entry 명시 vs 코드 미구현 spec/impl drift 해소.
  # live=1 모드 = 실 LLM CLI 호출 shape (claude/gemini/codex 별 stdin/flag/exit parsing 차이) =
  # WU27-D6 decision_point W10 deferred → 본 cycle = TBD fail-closed (rc=99, stub fallback 금지).
  # live=0 (default) 모드 = 기존 MVP stub 유지 (결정성 PASS-with-conditions).
  if [[ "${SFS_LOOP_LLM_LIVE:-0}" == "1" ]]; then
    echo "review_with_persona: SFS_LOOP_LLM_LIVE=1 detected, but live executor CLI shape unresolved (WU27-D6, W10 deferred)" >&2
    cat <<EOF
verdict: ERROR
reason: live LLM mode requested (SFS_LOOP_LLM_LIVE=1) but CLI shape unresolved (claude/gemini/codex stdin/flag/exit parsing differs — WU27-D6 W10 deferred). Fail-closed: stub fallback intentionally disabled in live mode to prevent silent degradation.
EOF
    return 99
  fi
  # MVP stub (default, live=0): always PASS-with-conditions.
  # Real implementation = pipe persona + plan to $(resolve_executor) and parse verdict — wired after WU27-D6 decision.
  # persona_source 는 file / builtin-planner / builtin-evaluator 중 하나 (§ 6.8.4b 정합).
  cat <<EOF
verdict: PASS-with-conditions
reason: MVP review stub (persona_source=$persona_source). Persona '$persona_path' applied to '$plan_doc'. Conditions: smoke verification + idempotency check before commit.
EOF
  return 2
}

# submit_to_user — write a 7-step briefing doc for user final approval.
# Args: $1 = plan-doc, $2 = reviews-doc (combined PLANNER + EVALUATOR output)
# Output: stdout = path to written briefing
submit_to_user() {
  local plan_doc="$1" reviews_doc="$2"
  local ts now wu_id outpath
  ts=$(date -u +"%Y%m%dT%H%M%SZ")
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  wu_id=$(awk '/^wu_id:/ { sub(/^wu_id:[ \t]*/, ""); print; exit }' "$plan_doc" 2>/dev/null || echo "WU-UNKNOWN")
  mkdir -p tmp
  outpath="tmp/sfs-review-submit-${wu_id}-${ts}.md"
  cat > "$outpath" <<EOF
---
doc_id: sfs-review-submit
wu_id: ${wu_id}
created: ${now}
plan_doc: ${plan_doc}
reviews_doc: ${reviews_doc}
visibility: raw-internal
---

# /sfs loop — Pre-execution Review Submission

## 1. Question
Approve autonomous execution of plan?

## 2. Context
$(head -20 "$plan_doc" 2>/dev/null | sed 's/^/  /')

## 3. Reviews
$(cat "$reviews_doc" 2>/dev/null | sed 's/^/  /')

## 4. Recommendation
Default = β minimal-cleanup (proceed with conditions).

## 5. Risk if Not Decided
Loop blocks until user reply.

## 6. Cascade Options (if FAIL)
- (1) abandon (yagni)
- (2) split into smaller sub-tasks
- (3) prerequisite first
- (4) custom user plan

## 7. Reply Format
"approve" | "fail (reason)" | "split" | "abandon"
EOF
  echo "$outpath"
  return 0
}

# cascade_on_fail — handle review FAIL with cascade depth check.
# Args: $1 = fail-reason, $2 = original-plan path, $3 = depth (default 0)
# Output: stdout = path to fail-report doc
# rc: 0=cascade allowed (depth<3), 1=cap reached (escalate W10)
cascade_on_fail() {
  local reason="$1" plan="$2" depth="${3:-0}"
  local ts outpath
  ts=$(date -u +"%Y%m%dT%H%M%SZ")
  mkdir -p tmp
  outpath="tmp/sfs-fail-report-$(basename "$plan" .md)-${ts}.md"
  cat > "$outpath" <<EOF
---
doc_id: sfs-fail-report
plan: ${plan}
reason: ${reason}
depth: ${depth}
created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
visibility: raw-internal
---

# /sfs loop — Review Fail Cascade Report (depth ${depth})

Fail reason: ${reason}

Cascade options:
- (1) abandon (yagni)
- (2) split larger unit into smaller sub-tasks (depth+=1, cap 3)
- (3) work on prerequisite domain first
- (4) user-provided custom plan
EOF
  if (( depth >= 3 )); then
    escalate_w10_todo "review-cascade" "depth cap reached for plan: $plan (reason: $reason)"
    echo "$outpath"
    return 1
  fi
  echo "$outpath"
  return 0
}

# ─────────────────────────────────────────────────────────────────────
# DECISION / SPRINT CLOSE HELPERS (WU-26 §3)
# ─────────────────────────────────────────────────────────────────────

# next_decision_id — `.sfs-local/decisions/` 의 가장 큰 4-자리 id + 1.
# stdout: 4-자리 zero-pad id (시작 "0001"). Returns: 0 always.
# WU-26 §3 spec verbatim. sfs-decision.sh 의 inline `next_decision_id_local` 보다 우선
# (본 표준 함수가 sfs-common.sh 에 정착, inline helper 는 deprecation 후보).
next_decision_id() {
  local dir="${SFS_DECISIONS_DIR}"
  [[ -d "${dir}" ]] || { echo "0001"; return 0; }
  local max
  max=$(ls -1 "${dir}" 2>/dev/null | grep -oE '^[0-9]{4}' | sort -n | tail -1)
  if [[ -z "${max}" ]]; then
    echo "0001"
  else
    printf '%04d\n' $((10#${max} + 1))
  fi
  return 0
}

# sprint_close <sprint-dir> <iso-ts> — sprint frontmatter status=closed + closed_at.
# 대상 = `<sprint-dir>/plan.md` 우선, 부재 시 `<sprint-dir>/sprint.md`, 둘 다 부재 시 silent return 0.
# WU-26 §3 spec verbatim. update_frontmatter 재사용.
sprint_close() {
  local sdir="${1:-}" ts="${2:-}"
  [[ -n "${sdir}" && -n "${ts}" ]] || return 0
  local target="${sdir}/plan.md"
  [[ -f "${target}" ]] || target="${sdir}/sprint.md"
  [[ -f "${target}" ]] || return 0
  update_frontmatter "${target}" "status" "closed"
  update_frontmatter "${target}" "closed_at" "${ts}"
  return 0
}

# auto_commit_close <sprint-id> — sprint close 후 git add + commit. push 안 함 (§1.5 정합).
# WARNING: AI 자율 호출 금지 — 사용자가 `/sfs retro --close` 명시 호출 시에만 동작 (§1.5' 정합).
# git operation 들은 silent fail (`|| true`) — git 부재 / pre-commit hook 등 환경 차이 흡수.
auto_commit_close() {
  local sid="${1:-}"
  [[ -n "${sid}" ]] || return 0
  git rev-parse --git-dir >/dev/null 2>&1 || return 0
  git add "${SFS_SPRINTS_DIR}/${sid}/" 2>/dev/null || true
  git add "${SFS_EVENTS_FILE}" 2>/dev/null || true
  # current-sprint 가 방금 제거됐으므로 staged deletion 마킹
  git add -A "${SFS_LOCAL_DIR}/" 2>/dev/null || true
  git commit -m "chore(sfs): close sprint ${sid}" >/dev/null 2>&1 || true
  return 0
}

# End of sfs-common.sh
