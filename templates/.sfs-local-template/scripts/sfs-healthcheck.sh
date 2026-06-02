#!/usr/bin/env bash
# SFS healthcheck: read-only runtime/project 상태를 점검한다.

set -u

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
SFS_RUNTIME_DIR="${SFS_RUNTIME_DIR:-$(cd "${SFS_SCRIPT_DIR}/.." 2>/dev/null && pwd)}"
SFS_DIST_DIR="${SFS_DIST_DIR:-$(cd "${SFS_RUNTIME_DIR}/../.." 2>/dev/null && pwd)}"

HC_OK=0
HC_ISSUES=1
HC_USAGE=2

ISSUE_COUNT=0
PROJECT_COUNT=0
ISSUE_TEXT=""

usage_healthcheck() {
  cat <<'EOF'
Usage:
  sfs healthcheck
  sfs healthcheck --project <dir> [<dir>...]
  sfs healthcheck --all

Read-only SFS product/runtime healthcheck. It inspects runtime dispatch,
routed context, project status/divisions/version state, llm-wiki frontmatter,
.git/index.lock, and a small packaged runtime regression subset.

Exit codes:
  0  ok
  1  one or more health issues found
  2  usage error or unrecoverable runtime error
EOF
}

say_ok() {
  printf 'OK   %s\n' "$1"
}

add_issue() {
  local project="$1" check="$2" message="$3" line
  ISSUE_COUNT=$((ISSUE_COUNT + 1))
  line="$(printf 'FAIL %-22s %s: %s' "[${check}]" "${project}" "${message}")"
  printf '%s\n' "${line}"
  ISSUE_TEXT="${ISSUE_TEXT}${line}
"
}

file_contains() {
  local file="$1" needle="$2"
  [[ -f "${file}" ]] || return 1
  awk -v needle="${needle}" 'index($0, needle) { found=1; exit } END { exit(found ? 0 : 1) }' "${file}" 2>/dev/null
}

string_contains() {
  local haystack="$1" needle="$2"
  case "${haystack}" in
    *"${needle}"*) return 0 ;;
    *) return 1 ;;
  esac
}

first_line() {
  local file="$1"
  sed -n '1p' "${file}" 2>/dev/null
}

trim_version_value() {
  awk -F: '
    $1 == "solon_mvp_version" {
      v=$2
      sub(/^[ \t]+/, "", v)
      gsub(/["<>]/, "", v)
      print v
      exit
    }
  ' "$1" 2>/dev/null
}

runtime_version() {
  if [[ -f "${SFS_DIST_DIR}/VERSION" ]]; then
    first_line "${SFS_DIST_DIR}/VERSION"
  else
    printf ''
  fi
}

abs_dir_or_empty() {
  local dir="$1"
  (cd "${dir}" 2>/dev/null && pwd) || printf ''
}

add_project_unique() {
  local candidate="$1" existing
  [[ -n "${candidate}" ]] || return 0
  for existing in "${PROJECTS[@]+"${PROJECTS[@]}"}"; do
    [[ "${existing}" == "${candidate}" ]] && return 0
  done
  PROJECTS+=("${candidate}")
}

project_name() {
  basename "$1" 2>/dev/null || printf '%s' "$1"
}

rel_to_project() {
  local project="$1" file="$2"
  case "${file}" in
    "${project}/"*) printf '%s' "${file#"${project}/"}" ;;
    *) printf '%s' "${file}" ;;
  esac
}

check_runtime_dispatch() {
  local dispatch="${SFS_SCRIPT_DIR}/sfs-dispatch.sh"
  local cmd script
  [[ -f "${dispatch}" ]] || { add_issue "runtime" "dispatch" "missing sfs-dispatch.sh"; return 0; }
  for cmd in adopt ingest flowcheck report-bug retro healthcheck; do
    script="${SFS_SCRIPT_DIR}/sfs-${cmd}.sh"
    [[ -f "${script}" ]] || { add_issue "runtime" "dispatch" "missing adapter sfs-${cmd}.sh"; continue; }
    [[ -x "${script}" ]] || add_issue "runtime" "dispatch" "adapter not executable: sfs-${cmd}.sh"
    file_contains "${dispatch}" "${cmd}" || add_issue "runtime" "dispatch" "dispatch table does not mention ${cmd}"
  done
  say_ok "runtime dispatch table checked"

  local retro_help retro_rc
  retro_help="$(bash "${SFS_SCRIPT_DIR}/sfs-retro.sh" --help 2>&1)"
  retro_rc=$?
  if [[ "${retro_rc}" -ne 0 ]] || ! string_contains "${retro_help}" "Usage:"; then
    add_issue "runtime" "retro-help" "retro --help did not return a usage banner"
  else
    say_ok "retro --help returns without sprint mutation"
  fi
}

check_context_resolve() {
  local ctx="${SFS_RUNTIME_DIR}/context"
  local rel
  for rel in \
    commands/healthcheck.md \
    commands/report-bug.md \
    commands/flowcheck.md \
    policies/review-lens-routing.md \
    policies/obsidian-llm-wiki.md \
    policies/bug-report-lifecycle.md; do
    [[ -f "${ctx}/${rel}" ]] || add_issue "runtime" "context-resolve" "missing ${rel}"
  done
  if [[ -f "${ctx}/_INDEX.md" ]]; then
    file_contains "${ctx}/_INDEX.md" "commands/healthcheck.md" \
      || add_issue "runtime" "context-resolve" "index does not route commands/healthcheck.md"
  else
    add_issue "runtime" "context-resolve" "missing context _INDEX.md"
  fi
  say_ok "runtime context routes checked"
}

run_runtime_subset() {
  case "${SFS_HEALTHCHECK_SKIP_RUNTIME_TESTS:-0}" in
    1|true|yes|on)
      say_ok "runtime regression subset skipped by env"
      return 0
      ;;
  esac

  local tests_dir="${SFS_DIST_DIR}/tests"
  local test_name test_path out rc
  if [[ ! -d "${tests_dir}" ]]; then
    add_issue "runtime" "runtime-regression" "packaged tests directory not found"
    return 0
  fi
  for test_name in \
    test-context-report-bug-command.sh \
    test-bug-report-lifecycle-policy.sh \
    test-context-list-command.sh; do
    test_path="${tests_dir}/${test_name}"
    [[ -f "${test_path}" ]] || { add_issue "runtime" "runtime-regression" "missing ${test_name}"; continue; }
    out="$(SFS_DIST_DIR="${SFS_DIST_DIR}" SFS_COMMAND_TIMEOUT_SEC=0 bash "${test_path}" 2>&1)"
    rc=$?
    if [[ "${rc}" -ne 0 ]]; then
      add_issue "runtime" "runtime-regression" "${test_name} failed rc=${rc}"
    else
      say_ok "runtime regression ${test_name}"
    fi
  done
}

check_version_drift() {
  local project="$1" local_dir="$2" rv pv
  rv="$(runtime_version)"
  pv="$(trim_version_value "${local_dir}/VERSION")"
  [[ -n "${rv}" ]] || { add_issue "$(project_name "${project}")" "version-drift" "runtime VERSION missing"; return 0; }
  [[ -n "${pv}" ]] || { add_issue "$(project_name "${project}")" "version-drift" "project solon_mvp_version missing"; return 0; }
  if [[ "${pv}" != "${rv}" ]]; then
    add_issue "$(project_name "${project}")" "version-drift" "project=${pv} runtime=${rv}"
  else
    say_ok "$(project_name "${project}") version ${pv}"
  fi
}

check_status_parse() {
  local project="$1" local_dir="$2" out rc
  out="$(cd "${project}" 2>/dev/null && SFS_LOCAL_DIR="${local_dir}" SFS_RUNTIME_DIR="${SFS_RUNTIME_DIR}" SFS_DIST_DIR="${SFS_DIST_DIR}" bash "${SFS_SCRIPT_DIR}/sfs-status.sh" --compact 2>&1)"
  rc=$?
  if [[ "${rc}" -ne 0 ]]; then
    add_issue "$(project_name "${project}")" "status-parse" "sfs-status failed rc=${rc}"
    return 0
  fi
  for needle in "sprint=" "wu=" "gate=" "verdict=" "ahead=" "last_event="; do
    string_contains "${out}" "${needle}" || add_issue "$(project_name "${project}")" "status-parse" "missing field ${needle}"
  done
  say_ok "$(project_name "${project}") status parse"
}

check_divisions_parse() {
  local project="$1" local_dir="$2" file="${local_dir}/divisions.yaml"
  if [[ ! -f "${file}" ]]; then
    add_issue "$(project_name "${project}")" "divisions-parse" "missing .sfs-local/divisions.yaml"
    return 0
  fi
  if [[ ! -s "${file}" ]]; then
    add_issue "$(project_name "${project}")" "divisions-parse" "empty .sfs-local/divisions.yaml"
    return 0
  fi
  file_contains "${file}" "divisions:" || add_issue "$(project_name "${project}")" "divisions-parse" "missing divisions root"
  file_contains "${file}" "activation_state:" || add_issue "$(project_name "${project}")" "divisions-parse" "missing activation_state"
  file_contains "${file}" "  dev:" || add_issue "$(project_name "${project}")" "divisions-parse" "missing dev division"
  file_contains "${file}" "  strategy-pm:" || add_issue "$(project_name "${project}")" "divisions-parse" "missing strategy-pm division"
  say_ok "$(project_name "${project}") divisions parse"
}

frontmatter_has_key() {
  local file="$1" key="$2"
  awk -v key="${key}" '
    NR == 1 && $0 != "---" { exit 2 }
    NR == 1 { in_fm=1; next }
    in_fm && $0 == "---" { exit(found ? 0 : 1) }
    in_fm && index($0, key ":") == 1 { found=1 }
    END { if (NR == 0) exit 2; if (in_fm) exit(found ? 0 : 1) }
  ' "${file}" 2>/dev/null
}

check_wiki_frontmatter() {
  local project="$1" wiki="${project}/llm-wiki" file found=0 label
  label="$(project_name "${project}")"
  if [[ ! -d "${wiki}" ]]; then
    if [[ -d "${project}/.obsidian" ]]; then
      add_issue "${label}" "vault-frontmatter" ".obsidian exists but llm-wiki/ is missing"
    else
      say_ok "${label} llm-wiki not present"
    fi
    return 0
  fi
  for file in "${wiki}/README.md" "${wiki}/ddd/README.md"; do
    [[ -f "${file}" ]] || add_issue "${label}" "vault-frontmatter" "missing $(rel_to_project "${project}" "${file}")"
  done
  while IFS= read -r file; do
    [[ -n "${file}" ]] || continue
    found=1
    if [[ "$(first_line "${file}")" != "---" ]]; then
      add_issue "${label}" "vault-frontmatter" "$(rel_to_project "${project}" "${file}") missing opening frontmatter"
      continue
    fi
    for key in doc_id title tags; do
      frontmatter_has_key "${file}" "${key}" \
        || add_issue "${label}" "vault-frontmatter" "$(rel_to_project "${project}" "${file}") missing ${key}"
    done
  done < <(find "${wiki}" -type f -name '*.md' 2>/dev/null)
  [[ "${found}" -eq 1 ]] || add_issue "${label}" "vault-frontmatter" "llm-wiki has no markdown notes"
  say_ok "${label} llm-wiki frontmatter"
}

check_git_index_lock() {
  local project="$1"
  if [[ -f "${project}/.git/index.lock" ]]; then
    add_issue "$(project_name "${project}")" "git-index-lock" ".git/index.lock exists"
  else
    say_ok "$(project_name "${project}") no git index lock"
  fi
}

check_project() {
  local project="$1" local_dir label
  PROJECT_COUNT=$((PROJECT_COUNT + 1))
  label="$(project_name "${project}")"
  printf '\nProject: %s\n' "${project}"
  if [[ ! -d "${project}" ]]; then
    add_issue "${label}" "project" "directory does not exist"
    return 0
  fi
  check_git_index_lock "${project}"
  check_wiki_frontmatter "${project}"

  local_dir="${project}/.sfs-local"
  if [[ ! -d "${local_dir}" ]]; then
    add_issue "${label}" "project-init" ".sfs-local missing"
    return 0
  fi
  check_version_drift "${project}" "${local_dir}"
  check_status_parse "${project}" "${local_dir}"
  check_divisions_parse "${project}" "${local_dir}"
}

discover_all_projects() {
  local max_depth="${SFS_HEALTHCHECK_FIND_MAX_DEPTH:-4}" local_dir parent abs
  case "${max_depth}" in ''|*[!0-9]*) max_depth=4 ;; esac
  while IFS= read -r local_dir; do
    parent="$(dirname "${local_dir}")"
    abs="$(abs_dir_or_empty "${parent}")"
    add_project_unique "${abs}"
  done < <(find . -maxdepth "${max_depth}" -type d -name .sfs-local -print 2>/dev/null)
}

emit_report_bug_draft() {
  local rv
  rv="$(runtime_version)"
  cat <<EOF

--- report-bug DRAFT (not submitted) ---
This is a draft for the sfs report-bug confirm gate. No GitHub issue was
created and no gh command was invoked.

Title: [healthcheck] read-only healthcheck found SFS runtime/project drift

**증상** — \`sfs healthcheck\` found ${ISSUE_COUNT} issue(s) across ${PROJECT_COUNT} project(s).
**실제 사례** — See the FAIL lines above. Keep private paths out of the final issue body.
**근본 원인** — Runtime dispatch/context, project version/state, divisions, llm-wiki frontmatter, git lock, or runtime regression drift.
**제안** — Confirm whether this is an SFS product defect, then run \`sfs report-bug\` and submit through its confirm gate only after user approval.
**환경** — sfs version ${rv:-unknown}; runtime healthcheck; consumer repo name(s) only.
EOF
}

PROJECTS=()
MODE="current"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help)
      usage_healthcheck
      exit "${HC_OK}"
      ;;
    --all)
      [[ "${MODE}" == "current" ]] || { echo "healthcheck: --all cannot be combined with --project" >&2; exit "${HC_USAGE}"; }
      MODE="all"
      shift
      ;;
    --project)
      [[ "${MODE}" != "all" ]] || { echo "healthcheck: --project cannot be combined with --all" >&2; exit "${HC_USAGE}"; }
      MODE="project"
      shift
      [[ $# -gt 0 ]] || { echo "healthcheck: --project requires at least one directory" >&2; exit "${HC_USAGE}"; }
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --*) break ;;
          *)
            _hc_project_abs="$(abs_dir_or_empty "$1")"
            if [[ -n "${_hc_project_abs}" ]]; then
              add_project_unique "${_hc_project_abs}"
            else
              add_project_unique "$1"
            fi
            shift
            ;;
        esac
      done
      ;;
    *)
      echo "healthcheck: unknown arg $1" >&2
      usage_healthcheck >&2
      exit "${HC_USAGE}"
      ;;
  esac
done

case "${MODE}" in
  current)
    add_project_unique "$(pwd)"
    ;;
  all)
    discover_all_projects
    if [[ "${#PROJECTS[@]}" -eq 0 ]]; then
      add_issue "workspace" "project-discovery" "no .sfs-local directories found below current directory"
    fi
    ;;
esac

printf 'sfs healthcheck\n'
printf 'runtime: %s\n' "${SFS_DIST_DIR}"

check_runtime_dispatch
check_context_resolve
run_runtime_subset

for project in "${PROJECTS[@]+"${PROJECTS[@]}"}"; do
  check_project "${project}"
done

printf '\nSummary: projects=%s issues=%s\n' "${PROJECT_COUNT}" "${ISSUE_COUNT}"
if [[ "${ISSUE_COUNT}" -gt 0 ]]; then
  emit_report_bug_draft
  exit "${HC_ISSUES}"
fi

exit "${HC_OK}"
