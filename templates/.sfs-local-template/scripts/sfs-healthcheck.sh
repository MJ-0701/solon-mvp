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

# say_warn — advisory line that does NOT count as a health issue and does NOT
# change the exit code. open-sprint + passed-review + uncommitted is the normal
# mid-sprint state; bumping the issue count here would cry wolf every sprint.
say_warn() {
  local check="$1" project="$2" message="$3"
  printf 'WARN %-22s %s: %s\n' "[${check}]" "${project}" "${message}"
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

check_evidence_at_risk() {
  local project="$1" local_dir="$2" out label
  label="$(project_name "${project}")"
  out="$(cd "${project}" 2>/dev/null && SFS_LOCAL_DIR="${local_dir}" SFS_RUNTIME_DIR="${SFS_RUNTIME_DIR}" SFS_DIST_DIR="${SFS_DIST_DIR}" bash "${SFS_SCRIPT_DIR}/sfs-status.sh" --compact 2>/dev/null)"
  if string_contains "${out}" "evidence_at_risk="; then
    local n="${out##*evidence_at_risk=}"
    n="${n%% *}"
    say_warn "evidence-at-risk" "${label}" "open sprint + passed review + ${n} uncommitted change(s) — commit or run \`sfs retro --close\` before handoff (read-only warning, not a failure)"
  else
    say_ok "${label} handoff evidence committed"
  fi
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
  done < <(find "${wiki}" -type d -name 'graphify_out' -prune -o -type f -name '*.md' -print 2>/dev/null)
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

# excavation(dig) 정합 — advisory only: 무효 카드 수와 게이트-추월을 알리되
# 이슈로 세지 않고 exit 코드도 바꾸지 않는다 (signal-only).
check_excavation_conformance() {
  local project="$1" label="$2" exc dig invalid queue cards_dir
  dig="${SFS_DIST_DIR:-}/scripts/sfs-dig.sh"
  [[ -n "${SFS_DIST_DIR:-}" && -f "${dig}" ]] || return 0
  for exc in "${project}"/docs/solon/*/excavation; do
    [[ -d "${exc}" ]] || continue
    cards_dir="${exc}/cards"
    if [[ -d "${cards_dir}" ]]; then
      invalid="$( (cd "${project}" && bash "${dig}" card validate "${cards_dir#"${project}"/}" --root . 2>/dev/null) | grep -c '^REJECT' || true)"
      if [[ "${invalid:-0}" -gt 0 ]]; then
        say_warn "excavation-cards" "${label}" "${invalid} card(s) fail validation under ${exc#"${project}"/} (advisory)"
      fi
    fi
    queue="${exc}/l2-queue.md"
    if [[ -f "${queue}" ]] && file_contains "${queue}" "L2-GATE: NOT-READY" && [[ -d "${cards_dir}" ]] \
      && ls "${cards_dir}"/*.md >/dev/null 2>&1; then
      say_warn "excavation-gate" "${label}" "L2 cards exist while l2-queue gate is NOT-READY — record a sanity waiver or re-run scan (advisory)"
    fi
  done
  return 0
}

# unknowns 루프 정합 — advisory only (policies/unknowns-and-deviations.md).
# (a) deviation-ledger: review/report 가 존재(완료 주장)하는데 implement.md 의
#     `## Deviations` 가 없거나 비어 있으면 (entries 도 `none observed` 도 없음)
#     advisory. (b) plan-readiness: 구현이 시작됐는데 plan.md 의 unknowns-loop
#     readiness 체크 항목이 unchecked 로 남아 있으면 advisory. 둘 다 say_warn
#     only — 이슈로 세지 않고 exit 코드도 바꾸지 않는다 (signal-only).
# ledger 가 "명시" 되었는가 — `## Deviations` 섹션 안에 (a) 독립 `none observed`
# 라인 (guidance 문장 속 인용은 제외 — 라인 전체가 sentinel 일 때만) 또는
# (b) 비어 있지 않은 테이블 데이터 행이 있으면 stated.
deviation_ledger_stated() {
  local file="$1"
  awk '
    /^## Deviations/ { in_sec=1; next }
    in_sec && /^## /  { in_sec=0 }
    in_sec {
      line=$0
      tmp=line
      gsub(/[-*`[:space:]]/, "", tmp)
      if (tmp == "noneobserved") { found=1 }
      if (line ~ /^\|/) {
        if (line ~ /^\|[[:space:]]*-/) next          # separator row
        else if (index(line, "계획") > 0) next        # header row
        else {
          gsub(/[|[:space:]]/, "", line)
          if (length(line) > 0) { found=1 }
        }
      }
    }
    END { exit(found ? 0 : 1) }
  ' "${file}" 2>/dev/null
}

check_unknowns_conformance() {
  local project="$1" label="$2" local_dir="$3" sid sdir impl plan n=0
  sid="$(head -n1 "${local_dir}/current-sprint" 2>/dev/null | tr -d '[:space:]')"
  [[ -n "${sid}" ]] || return 0
  sdir="${local_dir}/sprints/${sid}"
  impl="${sdir}/implement.md"
  plan="${sdir}/plan.md"

  if [[ -f "${impl}" ]] && { [[ -f "${sdir}/review.md" ]] || [[ -f "${sdir}/report.md" ]]; }; then
    if ! file_contains "${impl}" "## Deviations"; then
      say_warn "deviation-ledger" "${label}" "review/report exists but implement.md has no '## Deviations' ledger — state entries or 'none observed' (policies/unknowns-and-deviations.md, advisory)"
    elif ! deviation_ledger_stated "${impl}"; then
      say_warn "deviation-ledger" "${label}" "completion claimed but the '## Deviations' ledger is unstated — add entries or 'none observed' (policies/unknowns-and-deviations.md, advisory)"
    fi
  fi

  if [[ -f "${impl}" && -f "${plan}" ]]; then
    file_contains "${plan}" "- [ ] 인터뷰 열린 질문" && n=$((n + 1))
    file_contains "${plan}" "- [ ] blind_spots 항목" && n=$((n + 1))
    file_contains "${plan}" "- [ ] references 가 있으면" && n=$((n + 1))
    if [[ "${n}" -gt 0 ]]; then
      say_warn "plan-readiness" "${label}" "${n} unknowns-loop readiness item(s) unchecked in plan.md while implementation already started (interview/blind_spots/references, advisory)"
    fi
  fi
  return 0
}

# Six-division ledger completeness — Tier-B mechanical detection, advisory only.
# The semantic Gate 3/Gate 6 verdict remains with the council/review policy.
# A plan ledger is relevant once implement.md exists; a review ledger is
# relevant only after a real verdict is persisted. This avoids treating fresh
# scaffolds as missing work. The check then finds named division rows whose
# cells after the division name are all blank. Any explicit finding, evidence,
# asset, waiver, or N/A reason is accepted without judging relevance or PASS.
division_ledger_blank_rows() {
  local file="$1" section="$2"
  awk -v section="${section}" '
    function trim(value) {
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      return value
    }
    function markdown_heading_level(line, text, level) {
      text=line
      sub(/^[[:space:]]*/, "", text)
      level=0
      while (substr(text, level + 1, 1) == "#") level++
      return level
    }
    function markdown_heading_text(line, text) {
      text=line
      sub(/^[[:space:]]*#+[[:space:]]*/, "", text)
      text=trim(text)
      sub(/[[:space:]]+#+[[:space:]]*$/, "", text)
      return trim(text)
    }
    function is_ledger_heading(line, target, text) {
      if (markdown_heading_level(line) == 0) return 0
      text=tolower(markdown_heading_text(line))
      gsub(/[-_[:space:]]+/, " ", text)
      text=trim(text)
      if (index(text, "§") == 1) text=substr(text, length("§") + 1)
      return text ~ ("^" target "[.):]*[[:space:]]+division sub agent ledger$")
    }
    function canonical_division(value) {
      value=trim(value)
      if (value ~ /^`[^`]+`$/) {
        sub(/^`/, "", value)
        sub(/`$/, "", value)
      } else if (value ~ /^\*\*[^*]+\*\*$/ || value ~ /^__[^_]+__$/) {
        sub(/^[*_][*_]/, "", value)
        sub(/[*_][*_]$/, "", value)
      } else if (value ~ /^\*[^*]+\*$/ || value ~ /^_[^_]+_$/) {
        sub(/^[*_]/, "", value)
        sub(/[*_]$/, "", value)
      }
      value=tolower(trim(value))
      if (value == "strategy-pm" || value == "strategy pm") return "strategy-pm"
      if (value == "dev") return "dev"
      if (value == "qa") return "QA"
      if (value == "design") return "design"
      if (value == "infra") return "infra"
      if (value == "taxonomy") return "taxonomy"
      return ""
    }
    !in_section && is_ledger_heading($0, section) {
      in_section=1
      section_level=markdown_heading_level($0)
      next
    }
    in_section && markdown_heading_level($0) > 0 && markdown_heading_level($0) <= section_level { exit }
    in_section && /^\|/ {
      row=$0
      sub(/^[[:space:]]*\|/, "", row)
      count=split(row, cells, "|")
      division=canonical_division(cells[1])
      if (division == "") next
      substantive=0
      for (column=2; column<=count; column++) {
        if (trim(cells[column]) != "") {
          substantive=1
          break
        }
      }
      if (substantive) next
      if (found) printf ", "
      printf "%s", division
      found=1
    }
    END { if (found) printf "\n" }
  ' "${file}" 2>/dev/null
}

review_verdict_recorded() {
  local file="$1"
  awk '
    {
      line=tolower($0)
      if (line ~ /^[[:space:]>-]*verdict:[[:space:]]*(pass|partial|fail)[[:space:]]*$/ ||
          line ~ /^[[:space:]>-]*result_verdict:[[:space:]]*`?(pass|partial|fail)`?[[:space:]]*$/) {
        found=1
        exit
      }
    }
    END { exit(found ? 0 : 1) }
  ' "${file}" 2>/dev/null
}

check_division_ledger_completeness() {
  local project="$1" label="$2" local_dir="$3" sid sdir plan impl review blank
  sid="$(head -n1 "${local_dir}/current-sprint" 2>/dev/null | tr -d '[:space:]')"
  [[ -n "${sid}" ]] || return 0
  sdir="${local_dir}/sprints/${sid}"
  plan="${sdir}/plan.md"
  impl="${sdir}/implement.md"
  review="${sdir}/review.md"

  if [[ -f "${plan}" && -f "${impl}" ]]; then
    blank="$(division_ledger_blank_rows "${plan}" "7")"
    if [[ -n "${blank}" ]]; then
      say_warn "division-ledger" "${label}" "plan.md §7 has blank substantive row(s): ${blank} — add a finding/evidence/asset, or explicit N/A/waiver (Tier-B advisory)"
    fi
  fi

  if [[ -f "${review}" ]] && review_verdict_recorded "${review}"; then
    blank="$(division_ledger_blank_rows "${review}" "5")"
    if [[ -n "${blank}" ]]; then
      say_warn "division-ledger" "${label}" "review.md §5 has blank substantive row(s): ${blank} — add a finding/evidence/asset, or explicit N/A/waiver (Tier-B advisory)"
    fi
  fi
  return 0
}

# security audit 정합 — advisory only: open critical finding 수를 알리되 이슈로
# 세지 않고 exit 코드도 바꾸지 않는다 (signal-only).
check_audit_conformance() {
  local project="$1" label="$2" tsv crit total
  total=0
  for tsv in "${project}"/docs/solon/*/audit/findings.tsv; do
    [[ -f "${tsv}" ]] || continue
    crit="$(awk -F'\t' '$1=="critical"' "${tsv}" 2>/dev/null | grep -c '' || true)"
    total=$(( total + crit ))
  done
  if [[ "${total:-0}" -gt 0 ]]; then
    say_warn "audit-critical" "${label}" "${total} open critical security finding(s) — see docs/solon/*/audit/00-audit.md and commands/audit.md threat-model step (advisory)"
  fi
  return 0
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
  check_excavation_conformance "${project}" "${label}"
  check_audit_conformance "${project}" "${label}"

  local_dir="${project}/.sfs-local"
  if [[ ! -d "${local_dir}" ]]; then
    add_issue "${label}" "project-init" ".sfs-local missing"
    return 0
  fi
  check_version_drift "${project}" "${local_dir}"
  check_status_parse "${project}" "${local_dir}"
  check_evidence_at_risk "${project}" "${local_dir}"
  check_unknowns_conformance "${project}" "${label}" "${local_dir}"
  check_division_ledger_completeness "${project}" "${label}" "${local_dir}"
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
