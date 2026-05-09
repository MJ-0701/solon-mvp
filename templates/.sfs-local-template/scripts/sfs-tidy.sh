#!/usr/bin/env bash
# .sfs-local/scripts/sfs-tidy.sh
#
# Solon SFS — `/sfs tidy [--sprint <id>|--all] [--apply]`.
# Moves existing workbench docs into archive so .sfs-local keeps only artifacts
# that have a one-line keep reason. Dry-run is the default; --apply is required
# for file changes.

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

: "${SFS_EXIT_BADCLI:=7}"

usage_tidy() {
  cat <<'EOF'
Usage:
  /sfs tidy [--sprint <id-or-ref>] [--apply]
  /sfs tidy --all [--apply]

Clean up completed sprint workbench docs without leaving loose hidden files.
  - Default is dry-run; it prints what would be archived.
  - --sprint accepts an exact sprint id or a unique suffix ref.
    Example: W18-sprint-1 can resolve to 2026-W18-sprint-1.
  - --apply creates report.md when missing, then packs
    brainstorm/plan/implement/log/review plus matching .sfs-local/tmp review
    prompt/run scratch into one cold .tar.gz bundle with a short manifest.
  - Durable handoff docs live under docs/solon/<english-workspace>/<yyyyMMdd>/:
    report.md and retro.md use the `sfs start "<goal>"` text as workspace.
  - The visible sprint folder keeps only artifacts with a one-line keep reason.
  - Closed-sprint event ledger lines, broken current-sprint pointers, empty
    placeholder dirs, and stale workbench dust are removed when they no longer
    explain why they must stay visible.
  - `--all --apply` also cleans targetless post-adopt surface residue such as
    cache notice files, empty archive buckets, stale logs, and placeholder auth.
  - When report.md was created from legacy workbench docs, AI runtimes should
    refine it into the final report immediately after the adapter returns.
  - report.md, retro.md, and decision files are preserved in their durable
    locations. events.jsonl is kept only while it backs an active sprint/current
    state; historical closed-sprint events are pruned after report/archive
    evidence exists.

Recommended close flow:
  1. /sfs tidy --sprint <id-or-ref>          # inspect legacy state
  2. /sfs tidy --sprint <id-or-ref> --apply  # create report if missing + archive workbench
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

resolve_sprint_ref() {
  local ref="${1:-}"
  local d base count=0 last="" matches=""
  validate_sprint_id_arg "${ref}" || return "$?"

  if [[ -d "${SFS_SPRINTS_DIR}/${ref}" ]]; then
    printf '%s\n' "${ref}"
    return "${SFS_EXIT_OK}"
  fi
  if [[ ! -d "${SFS_SPRINTS_DIR}" ]]; then
    echo "no sprint workspaces found" >&2
    return "${SFS_EXIT_NO_INIT}"
  fi

  for d in "${SFS_SPRINTS_DIR}"/*; do
    [[ -d "${d}" ]] || continue
    base="${d##*/}"
    if [[ "${base}" == *"${ref}" ]]; then
      count=$((count + 1))
      last="${base}"
      matches="${matches}${base}"$'\n'
    fi
  done

  if [[ "${count}" -eq 1 ]]; then
    printf '%s\n' "${last}"
    return "${SFS_EXIT_OK}"
  fi
  if [[ "${count}" -gt 1 ]]; then
    echo "ambiguous sprint ref: ${ref}" >&2
    echo "matches:" >&2
    while IFS= read -r base; do
      [[ -n "${base}" ]] || continue
      echo "  - ${base}" >&2
    done <<< "${matches}"
    echo "use the full sprint id or a longer unique suffix" >&2
    return "${SFS_EXIT_BADCLI}"
  fi

  echo "sprint not found: ${ref}" >&2
  echo "hint: use exact id, a unique suffix like W18-sprint-1, or --all" >&2
  return "${SFS_EXIT_NO_INIT}"
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

tidy_target_contains_sprint() {
  local targets="${1:-}" sid="${2:-}"
  [[ -n "${sid}" ]] || return 1
  case $'\n'"${targets}" in
    *$'\n'"${sid}"$'\n'*) return 0 ;;
    *) return 1 ;;
  esac
}

tidy_event_line_sprint_id() {
  local line="${1:-}"
  printf '%s\n' "${line}" | sed -nE 's/.*"sprint_id"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p'
}

tidy_should_prune_event_line() {
  local line="${1:-}" targets="${2:-}" current_sprint="${3:-}" all="${4:-0}"
  local sid
  sid="$(tidy_event_line_sprint_id "${line}")"

  # `tidy --all` with no valid active sprint means events.jsonl is purely
  # historical scratch. report.md/retro.md/cold archives are the durable record.
  if [[ "${all}" -eq 1 && -z "${current_sprint}" ]]; then
    return 0
  fi

  if [[ -n "${sid}" ]] && tidy_target_contains_sprint "${targets}" "${sid}" \
     && [[ "${sid}" != "${current_sprint}" ]]; then
    return 0
  fi
  return 1
}

tidy_event_prune_stats() {
  local targets="${1:-}" current_sprint="${2:-}" all="${3:-0}"
  local line prune=0 keep=0
  [[ -f "${SFS_EVENTS_FILE}" ]] || { printf '0 0 absent\n'; return 0; }
  while IFS= read -r line || [[ -n "${line}" ]]; do
    [[ -n "${line}" ]] || continue
    if tidy_should_prune_event_line "${line}" "${targets}" "${current_sprint}" "${all}"; then
      prune=$((prune + 1))
    else
      keep=$((keep + 1))
    fi
  done < "${SFS_EVENTS_FILE}"
  printf '%s %s present\n' "${prune}" "${keep}"
}

tidy_prune_events() {
  local targets="${1:-}" current_sprint="${2:-}" all="${3:-0}"
  local line tmp pruned=0 kept=0
  [[ -f "${SFS_EVENTS_FILE}" ]] || { printf '0\n'; return 0; }
  tmp="$(mktemp "${SFS_EVENTS_FILE}.XXXXXX")" || return "${SFS_EXIT_PERM}"
  while IFS= read -r line || [[ -n "${line}" ]]; do
    [[ -n "${line}" ]] || continue
    if tidy_should_prune_event_line "${line}" "${targets}" "${current_sprint}" "${all}"; then
      pruned=$((pruned + 1))
      continue
    fi
    printf '%s\n' "${line}" >> "${tmp}" || return "${SFS_EXIT_PERM}"
    kept=$((kept + 1))
  done < "${SFS_EVENTS_FILE}"

  if [[ "${kept}" -eq 0 ]]; then
    rm -f "${tmp}" "${SFS_EVENTS_FILE}" || return "${SFS_EXIT_PERM}"
  else
    mv -f "${tmp}" "${SFS_EVENTS_FILE}" || return "${SFS_EXIT_PERM}"
  fi
  printf '%s\n' "${pruned}"
}

tidy_count_local_residue() {
  local count=0 path dir
  if [[ -d "${SFS_LOCAL_DIR}/cache" ]]; then
    count=$((count + 1))
  fi
  if [[ -f "${SFS_LOCAL_DIR}/auth.env" ]] && ! tidy_auth_env_has_assignments "${SFS_LOCAL_DIR}/auth.env"; then
    count=$((count + 1))
  fi
  for path in \
    "${SFS_SPRINTS_DIR}/.gitkeep" \
    "${SFS_LOCAL_DIR}/decisions/.gitkeep" \
    "${SFS_LOCAL_DIR}/queue/pending/.gitkeep" \
    "${SFS_LOCAL_DIR}/queue/claimed/.gitkeep" \
    "${SFS_LOCAL_DIR}/queue/done/.gitkeep" \
    "${SFS_LOCAL_DIR}/queue/failed/.gitkeep" \
    "${SFS_LOCAL_DIR}/queue/abandoned/.gitkeep" \
    "${SFS_LOCAL_DIR}/queue/runs/.gitkeep"; do
    [[ -e "${path}" ]] || continue
    count=$((count + 1))
  done

  for dir in \
    "${SFS_LOCAL_DIR}/queue/pending" \
    "${SFS_LOCAL_DIR}/queue/claimed" \
    "${SFS_LOCAL_DIR}/queue/done" \
    "${SFS_LOCAL_DIR}/queue/failed" \
    "${SFS_LOCAL_DIR}/queue/abandoned" \
    "${SFS_LOCAL_DIR}/queue/runs" \
    "${SFS_LOCAL_DIR}/queue" \
    "${SFS_LOCAL_DIR}/tmp" \
    "${SFS_LOCAL_DIR}/cache" \
    "${SFS_SPRINTS_DIR}" \
    "${SFS_LOCAL_DIR}/decisions" \
    "${SFS_ARCHIVES_DIR}/sprints" \
    "${SFS_ARCHIVES_DIR}/runtime-migrations" \
    "${SFS_ARCHIVES_DIR}/runtime-upgrades" \
    "${SFS_ARCHIVES_DIR}"; do
    [[ -d "${dir}" ]] || continue
    if [[ -z "$(find "${dir}" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
      count=$((count + 1))
    fi
  done

  if [[ -f "${SFS_CURRENT_SPRINT_FILE}" ]]; then
    local current
    current="$(read_current_sprint || true)"
    if [[ -z "${current}" || ! -d "${SFS_SPRINTS_DIR}/${current}" ]]; then
      count=$((count + 1))
    fi
  fi
  printf '%s\n' "${count}"
}

tidy_auth_env_has_assignments() {
  local file="${1:?file required}"
  awk '
    /^[[:space:]]*($|#)/ { next }
    /^[[:space:]]*export[[:space:]]+[A-Za-z_][A-Za-z0-9_]*=/ { found=1; next }
    /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*=/ { found=1; next }
    END { exit(found ? 0 : 1) }
  ' "${file}" 2>/dev/null
}

tidy_non_adopt_archive_ids() {
  [[ -d "${SFS_ARCHIVES_DIR}" ]] || return "${SFS_EXIT_OK}"
  find "${SFS_ARCHIVES_DIR}" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null \
    | while IFS= read -r dir; do
        [[ "$(basename "${dir}")" == "adopt" ]] && continue
        basename "${dir}"
      done \
    | sort
}

tidy_non_adopt_archive_count() {
  tidy_non_adopt_archive_ids | sed '/^[[:space:]]*$/d' | wc -l | tr -d '[:space:]'
}

tidy_collapse_non_adopt_archives() {
  local now="${1:?timestamp required}" ids count safe_ts archive_dir archive_file manifest item
  local tar_items=()
  ids="$(tidy_non_adopt_archive_ids)"
  count="$(printf '%s\n' "${ids}" | sed '/^[[:space:]]*$/d' | wc -l | tr -d '[:space:]')"
  [[ "${count}" -gt 0 ]] || { printf '0\n'; return "${SFS_EXIT_OK}"; }

  safe_ts="${now//:/-}"
  safe_ts="${safe_ts//+/-}"
  archive_dir="${SFS_ARCHIVES_DIR}/adopt/surface-cleanup/${safe_ts}"
  archive_file="${archive_dir}/preexisting-archives.tar.gz"
  manifest="${archive_dir}/preexisting-archives.manifest.txt"
  mkdir -p "${archive_dir}" || return "${SFS_EXIT_PERM}"

  {
    echo "SFS surface archive collapse"
    echo "generated_at: ${now}"
    echo "reason: non-adopt archive buckets are cold recovery evidence, not visible project surface"
    echo "archive: ${archive_file}"
    echo "count: ${count}"
    echo
    echo "items:"
    printf '%s\n' "${ids}" | while IFS= read -r item; do
      [[ -n "${item}" ]] || continue
      echo "- ${SFS_ARCHIVES_DIR}/${item}"
    done
  } > "${manifest}" || return "${SFS_EXIT_PERM}"

  while IFS= read -r item; do
    [[ -n "${item}" ]] || continue
    tar_items+=("${item}")
  done <<< "${ids}"
  tar -czf "${archive_file}" -C "${SFS_ARCHIVES_DIR}" "${tar_items[@]}" || return "${SFS_EXIT_PERM}"

  while IFS= read -r item; do
    [[ -n "${item}" ]] || continue
    rm -rf "${SFS_ARCHIVES_DIR}/${item}" || return "${SFS_EXIT_PERM}"
  done <<< "${ids}"
  printf '%s\n' "${count}"
}

tidy_cleanup_local_residue() {
  local count=0 path dir current
  if [[ -d "${SFS_LOCAL_DIR}/cache" ]]; then
    rm -rf "${SFS_LOCAL_DIR}/cache" || return "${SFS_EXIT_PERM}"
    count=$((count + 1))
  fi
  if [[ -f "${SFS_LOCAL_DIR}/auth.env" ]] && ! tidy_auth_env_has_assignments "${SFS_LOCAL_DIR}/auth.env"; then
    rm -f "${SFS_LOCAL_DIR}/auth.env" || return "${SFS_EXIT_PERM}"
    count=$((count + 1))
  fi
  for path in \
    "${SFS_SPRINTS_DIR}/.gitkeep" \
    "${SFS_LOCAL_DIR}/decisions/.gitkeep" \
    "${SFS_LOCAL_DIR}/queue/pending/.gitkeep" \
    "${SFS_LOCAL_DIR}/queue/claimed/.gitkeep" \
    "${SFS_LOCAL_DIR}/queue/done/.gitkeep" \
    "${SFS_LOCAL_DIR}/queue/failed/.gitkeep" \
    "${SFS_LOCAL_DIR}/queue/abandoned/.gitkeep" \
    "${SFS_LOCAL_DIR}/queue/runs/.gitkeep"; do
    [[ -e "${path}" ]] || continue
    rm -f "${path}" || return "${SFS_EXIT_PERM}"
    count=$((count + 1))
  done

  if [[ -f "${SFS_CURRENT_SPRINT_FILE}" ]]; then
    current="$(read_current_sprint || true)"
    if [[ -z "${current}" || ! -d "${SFS_SPRINTS_DIR}/${current}" ]]; then
      rm -f "${SFS_CURRENT_SPRINT_FILE}" || return "${SFS_EXIT_PERM}"
      count=$((count + 1))
    fi
  fi

  for dir in \
    "${SFS_LOCAL_DIR}/queue/pending" \
    "${SFS_LOCAL_DIR}/queue/claimed" \
    "${SFS_LOCAL_DIR}/queue/done" \
    "${SFS_LOCAL_DIR}/queue/failed" \
    "${SFS_LOCAL_DIR}/queue/abandoned" \
    "${SFS_LOCAL_DIR}/queue/runs" \
    "${SFS_LOCAL_DIR}/queue" \
    "${SFS_LOCAL_DIR}/tmp" \
    "${SFS_LOCAL_DIR}/cache" \
    "${SFS_SPRINTS_DIR}" \
    "${SFS_LOCAL_DIR}/decisions" \
    "${SFS_ARCHIVES_DIR}/sprints" \
    "${SFS_ARCHIVES_DIR}/runtime-migrations" \
    "${SFS_ARCHIVES_DIR}/runtime-upgrades" \
    "${SFS_ARCHIVES_DIR}"; do
    [[ -d "${dir}" ]] || continue
    if [[ -n "${current:-}" && "${dir}" == "${SFS_SPRINTS_DIR}/${current}" ]]; then
      continue
    fi
    if [[ -z "$(find "${dir}" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
      rmdir "${dir}" 2>/dev/null || true
      [[ -d "${dir}" ]] || count=$((count + 1))
    fi
  done
  printf '%s\n' "${count}"
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
  if [[ -d "${SFS_SPRINTS_DIR}" ]]; then
    for d in "${SFS_SPRINTS_DIR}"/*; do
      [[ -d "${d}" ]] || continue
      TARGETS="${TARGETS}${d##*/}"$'\n'
    done
  fi
else
  if [[ -z "${SPRINT_ID}" ]]; then
    SPRINT_ID="$(read_current_sprint)"
  fi
  if [[ -z "${SPRINT_ID}" ]]; then
    echo "no sprint selected (use --sprint <id>, --all, or run /sfs start first)" >&2
    exit "${SFS_EXIT_NO_INIT}"
  fi
  SPRINT_ID="$(resolve_sprint_ref "${SPRINT_ID}")"
  TARGETS="${SPRINT_ID}"$'\n'
fi

TARGETLESS_SURFACE_CLEANUP=0
if [[ -z "${TARGETS}" && "${ALL}" -eq 1 ]]; then
  TARGETLESS_SURFACE_CLEANUP=1
elif [[ -z "${TARGETS}" ]]; then
  echo "no sprint workspaces found" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"
RAW_CURRENT_SPRINT="$(read_current_sprint || true)"
CURRENT_SPRINT="${RAW_CURRENT_SPRINT}"
if [[ -n "${CURRENT_SPRINT}" && ! -d "${SFS_SPRINTS_DIR}/${CURRENT_SPRINT}" ]]; then
  CURRENT_SPRINT=""
fi

read -r EVENT_PRUNE_COUNT EVENT_KEEP_COUNT EVENT_STATE \
  <<< "$(tidy_event_prune_stats "${TARGETS}" "${CURRENT_SPRINT}" "${ALL}")"
RESIDUE_COUNT="$(tidy_count_local_residue)"
ARCHIVE_COLLAPSE_COUNT="$(tidy_non_adopt_archive_count)"

if [[ "${APPLY}" -eq 0 ]]; then
  echo "tidy retention dry-run:"
  echo "  rule: keep only files with a one-line keep reason"
  if [[ "${TARGETLESS_SURFACE_CLEANUP}" -eq 1 ]]; then
    echo "  sprints: none (surface cleanup only)"
  fi
  if [[ "${EVENT_STATE}" == "present" ]]; then
    echo "  events: ${EVENT_PRUNE_COUNT} line(s) would prune; ${EVENT_KEEP_COUNT} active/state line(s) would remain"
  else
    echo "  events: absent"
  fi
  echo "  residue: ${RESIDUE_COUNT} placeholder/broken/empty item(s) would remove"
  echo "  archives: ${ARCHIVE_COLLAPSE_COUNT} non-adopt archive bucket(s) would collapse"
fi

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

  REPORT_PATH="$(sfs_shared_sprint_doc_path "${sid}" "${NOW}" report)"
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
    echo "  workbench: ${COUNT} file(s) would pack into cold archive"
    echo "  tmp: ${TMP_COUNT} file(s) would pack into cold archive"
    echo "  archive: ${ARCHIVE_PATH}/sprint-evidence.tar.gz"
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
  echo "  archive: ${ARCHIVE_PATH}/sprint-evidence.tar.gz"
  echo "  manifest: ${ARCHIVE_PATH}/manifest.txt"
  echo "  workbench: ${COUNT} file(s) packed"
  echo "  tmp: ${TMP_COUNT} file(s) packed"
done <<< "${TARGETS}"

if [[ "${APPLY}" -eq 1 ]]; then
  EVENT_PRUNED="$(tidy_prune_events "${TARGETS}" "${CURRENT_SPRINT}" "${ALL}")"
  RESIDUE_REMOVED="$(tidy_cleanup_local_residue)"
  ARCHIVES_COLLAPSED="$(tidy_collapse_non_adopt_archives "${NOW}")"
  echo "retention:"
  echo "  rule: kept files must have a one-line reason"
  echo "  events: ${EVENT_PRUNED} historical line(s) pruned"
  echo "  residue: ${RESIDUE_REMOVED} placeholder/broken/empty item(s) removed"
  echo "  archives: ${ARCHIVES_COLLAPSED} non-adopt bucket(s) collapsed"
fi

exit "${SFS_EXIT_OK}"
