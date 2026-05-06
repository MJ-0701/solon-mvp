#!/usr/bin/env bash
# .sfs-local/scripts/sfs-implement.sh
#
# Solon SFS — `/sfs implement` command implementation.
#
# The bash adapter prepares deterministic execution artifacts. AI runtimes must
# then execute the requested work slice, update evidence, and run checks.

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

: "${SFS_EXIT_PLAN_REVIEW:=8}"

usage_implement() {
  cat <<'EOF'
Usage:
  /sfs implement [--agent-mode single|parallel] [--agents codex,claude[,gemini]] [<work slice>]
  /sfs implement --stdin
  /sfs implement --allow-unreviewed-plan [<work slice>]

Open/update the active sprint's implement.md execution artifact.
  - Intended flow: /sfs plan -> /sfs review --gate 3 -> /sfs implement -> /sfs review --gate 6.
  - Requires a passing Gate 3 Plan review before implementation starts.
  - --allow-unreviewed-plan bypasses the preflight only when the user explicitly
    waives plan review; the waiver is recorded in events.jsonl.
  - Creates implement.md from sprint-templates/implement.md if missing.
  - Records the implementation request and appends an implement_open event.
  - Default agent mode is single. Use --agent-mode parallel with two or more
    named agents only when the plan already splits into clear commit units.
  - Parallel agent mode requires disjoint files_scope, a one-sentence proposed
    commit message per lane, and cross review before Gate 6 can pass.
  - Prints implement.md, plan.md, and log.md paths.
  - AI runtimes must apply the execution harness:
    Think Before Execution, Simplicity First, Surgical Changes, Goal-Driven Execution.
  - Direct bash does not change product artifacts. AI runtimes must continue
    with the actual artifact work, checks, and evidence updates.

Exit codes:
  0  success
  1  no .sfs-local/ or no active sprint (run /sfs start first)
  2  events.jsonl / current-sprint corrupt
  3  not a git repo
  4  sprint-templates/implement.md missing
  5  permission denied
  8  Gate 3 Plan review PASS missing (run /sfs review --gate 3 first)
  99 unknown (CLI args, etc.)
EOF
}

USE_STDIN=false
ALLOW_UNREVIEWED_PLAN="${SFS_IMPLEMENT_ALLOW_UNREVIEWED_PLAN:-false}"
AGENT_MODE="${SFS_IMPLEMENT_AGENT_MODE:-single}"
AGENTS_VALUE="${SFS_IMPLEMENT_AGENTS:-}"
RAW_PARTS=()

sfs_implement_bool() {
  case "${1:-}" in
    true|1|yes|YES|y|Y|on|ON) printf 'true\n' ;;
    *) printf 'false\n' ;;
  esac
}

sfs_implement_json_string_field() {
  local field="$1" line="$2"
  printf '%s\n' "${line}" | sed -nE 's/.*"'"${field}"'"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p'
}

sfs_implement_normalize_agent_mode() {
  case "${1:-single}" in
    single|Single|SINGLE) printf 'single\n' ;;
    parallel|Parallel|PARALLEL|multi|Multi|MULTI) printf 'parallel\n' ;;
    *)
      echo "unknown agent mode: ${1:-} (expected single or parallel)" >&2
      return 1
      ;;
  esac
}

sfs_implement_agent_count() {
  local raw="$1"
  printf '%s\n' "${raw}" | tr ',' '\n' | awk '
    {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
      if ($0 != "") count++
    }
    END { print count + 0 }
  '
}

sfs_implement_extract_verdict() {
  local file="$1"
  [[ -f "${file}" ]] || return 1
  awk '
    {
      low = tolower($0)
      if (low ~ /^[[:space:]>-]*verdict:[[:space:]]*(pass|partial|fail)[[:space:]]*$/) {
        line = $0
        sub(/^[[:space:]>-]*[Vv][Ee][Rr][Dd][Ii][Cc][Tt]:[[:space:]]*/, "", line)
        sub(/[[:space:]]*$/, "", line)
        print tolower(line)
        found = 1
        exit
      }
    }
    END { if (!found) exit 1 }
  ' "${file}"
}

sfs_implement_latest_gate3_plan_review_record() {
  local line out_path verdict
  [[ -f "${SFS_EVENTS_FILE}" ]] || return 1
  while IFS= read -r line; do
    [[ "${line}" == *'"type":"review_run"'* ]] || continue
    [[ "${line}" == *"\"sprint_id\":\"${SPRINT_ID}\""* ]] || continue
    [[ "${line}" == *'"gate_id":"G1"'* ]] || continue
    out_path="$(sfs_implement_json_string_field "output_path" "${line}")"
    if [[ -n "${out_path}" && -f "${out_path}" ]]; then
      verdict="$(sfs_implement_extract_verdict "${out_path}" || true)"
    else
      verdict=""
    fi
    [[ -n "${verdict}" ]] || verdict="unknown"
    printf '%s\t%s\n' "${verdict}" "${out_path}"
    return 0
  done < <(reverse_lines "${SFS_EVENTS_FILE}")
  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --stdin)
      USE_STDIN=true
      shift
      ;;
    --allow-unreviewed-plan)
      ALLOW_UNREVIEWED_PLAN=true
      shift
      ;;
    --agent-mode)
      [[ $# -ge 2 ]] || {
        echo "missing value for --agent-mode" >&2
        exit "${SFS_EXIT_UNKNOWN}"
      }
      AGENT_MODE="$2"
      shift 2
      ;;
    --agents)
      [[ $# -ge 2 ]] || {
        echo "missing value for --agents" >&2
        exit "${SFS_EXIT_UNKNOWN}"
      }
      AGENTS_VALUE="$2"
      shift 2
      ;;
    --parallel)
      AGENT_MODE="parallel"
      shift
      ;;
    --single)
      AGENT_MODE="single"
      shift
      ;;
    -h|--help)
      usage_implement
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

ALLOW_UNREVIEWED_PLAN="$(sfs_implement_bool "${ALLOW_UNREVIEWED_PLAN}")"
AGENT_MODE="$(sfs_implement_normalize_agent_mode "${AGENT_MODE}")" || exit "${SFS_EXIT_UNKNOWN}"
if [[ "${AGENT_MODE}" == "parallel" ]]; then
  [[ -n "${AGENTS_VALUE}" ]] || AGENTS_VALUE="codex,claude,gemini"
  if (( $(sfs_implement_agent_count "${AGENTS_VALUE}") < 2 )); then
    echo "parallel agent mode requires at least two agents; use --agents codex,claude or keep --agent-mode single" >&2
    exit "${SFS_EXIT_UNKNOWN}"
  fi
else
  [[ -n "${AGENTS_VALUE}" ]] || AGENTS_VALUE="worker/generator-default"
fi

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
IMPLEMENT_PATH="${SPRINT_DIR}/implement.md"
PLAN_PATH="${SPRINT_DIR}/plan.md"
LOG_PATH="${SPRINT_DIR}/log.md"
TEMPLATE="$(sfs_sprint_template_file implement)"

PLAN_REVIEW_RECORD="$(sfs_implement_latest_gate3_plan_review_record || true)"
PLAN_REVIEW_VERDICT=""
PLAN_REVIEW_EVIDENCE=""
if [[ -n "${PLAN_REVIEW_RECORD}" ]]; then
  PLAN_REVIEW_VERDICT="$(printf '%s\n' "${PLAN_REVIEW_RECORD}" | awk -F '	' '{print $1; exit}')"
  PLAN_REVIEW_EVIDENCE="$(printf '%s\n' "${PLAN_REVIEW_RECORD}" | awk -F '	' '{print $2; exit}')"
fi

if [[ "${PLAN_REVIEW_VERDICT}" != "pass" ]]; then
  if [[ "${ALLOW_UNREVIEWED_PLAN}" != "true" ]]; then
    echo "Gate 3 Plan review required before implement: run /sfs review --gate 3 and continue only after verdict: pass" >&2
    if [[ -n "${PLAN_REVIEW_VERDICT}" ]]; then
      echo "latest Gate 3 review verdict: ${PLAN_REVIEW_VERDICT} (${PLAN_REVIEW_EVIDENCE:-output not found})" >&2
    else
      echo "latest Gate 3 review verdict: none" >&2
    fi
    echo "If the user explicitly waives this gate, rerun with --allow-unreviewed-plan; SFS will record the waiver." >&2
    exit "${SFS_EXIT_PLAN_REVIEW}"
  fi

  _esc_sprint_for_waiver="${SPRINT_ID//\\/\\\\}"
  _esc_sprint_for_waiver="${_esc_sprint_for_waiver//\"/\\\"}"
  if ! append_event "implement_unreviewed_plan_waiver" \
    "{\"sprint_id\":\"${_esc_sprint_for_waiver}\",\"reason\":\"explicit_user_waiver_required\",\"required_gate\":\"Gate 3 (Plan)\",\"required_command\":\"sfs review --gate 3\"}" \
    2>/dev/null; then
    echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
fi

if [[ ! -f "${IMPLEMENT_PATH}" ]]; then
  if [[ ! -f "${TEMPLATE}" ]]; then
    echo "template missing: ${TEMPLATE}" >&2
    exit "${SFS_EXIT_NO_TEMPLATES}"
  fi
  if ! mkdir -p "${SPRINT_DIR}" 2>/dev/null; then
    echo "permission denied creating ${SPRINT_DIR}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
  if ! cp -f "${TEMPLATE}" "${IMPLEMENT_PATH}" 2>/dev/null; then
    echo "permission denied copying template to ${IMPLEMENT_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
fi

NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"

if ! sfs_update_sprint_doc_identity "${IMPLEMENT_PATH}" "${SPRINT_ID}" "${NOW}" 2>/dev/null; then
  echo "permission denied updating sprint metadata in ${IMPLEMENT_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${IMPLEMENT_PATH}" "phase" "implement" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${IMPLEMENT_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${IMPLEMENT_PATH}" "status" "in-progress" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${IMPLEMENT_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${IMPLEMENT_PATH}" "last_touched_at" "${NOW}" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${IMPLEMENT_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi

if [[ -n "${RAW_TEXT}" ]]; then
  {
    printf '\n## %s — Implementation Request\n\n' "${NOW}"
    printf '```text\n'
    printf '%s\n' "${RAW_TEXT}"
    printf '```\n'
  } >> "${IMPLEMENT_PATH}" || {
    echo "permission denied appending request to ${IMPLEMENT_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  }
fi

{
  printf '\n## %s — Execution Mode\n\n' "${NOW}"
  printf -- '- agent_mode: %s\n' "${AGENT_MODE}"
  printf -- '- agents: %s\n' "${AGENTS_VALUE}"
  if [[ "${AGENT_MODE}" == "parallel" ]]; then
    cat <<'EOF'
- split rule: use multiple agents only when each lane has disjoint files_scope and a clear one-sentence proposed commit message.
- commit-unit guard: if a lane cannot explain its commit message before coding, do not split it; merge it into the nearest coherent lane or return to single-agent mode.
- lane contract: each agent records owner, files_scope, non-goals, verification command, result, and proposed commit message before handoff.
- review rule: cross review between agents is required before Gate 6 review can pass, then run `sfs review --gate 6` for artifact acceptance.
EOF
  else
    cat <<'EOF'
- default lane: one worker/generator owns the fixed implementation slice.
- optional parallel lane: rerun `sfs implement --agent-mode parallel --agents codex,claude[,gemini] ...` before coding only if the plan splits into clear commit units.
- review rule: implementation is not complete until evidence is recorded and `sfs review --gate 6` runs; the generator cannot approve its own output.
EOF
  fi
} >> "${IMPLEMENT_PATH}" || {
  echo "permission denied appending execution mode to ${IMPLEMENT_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
}

_esc_sprint="${SPRINT_ID//\\/\\\\}"
_esc_sprint="${_esc_sprint//\"/\\\"}"
_esc_path="${IMPLEMENT_PATH//\\/\\\\}"
_esc_path="${_esc_path//\"/\\\"}"
_event_task="$(printf '%s' "${RAW_TEXT}" | tr '\n\r' '  ')"
_esc_task="${_event_task//\\/\\\\}"
_esc_task="${_esc_task//\"/\\\"}"

if [[ -n "${RAW_TEXT}" ]]; then
  _esc_agents="${AGENTS_VALUE//\\/\\\\}"
  _esc_agents="${_esc_agents//\"/\\\"}"
  _payload="{\"sprint_id\":\"${_esc_sprint}\",\"path\":\"${_esc_path}\",\"task\":\"${_esc_task}\",\"agent_mode\":\"${AGENT_MODE}\",\"agents\":\"${_esc_agents}\"}"
else
  _esc_agents="${AGENTS_VALUE//\\/\\\\}"
  _esc_agents="${_esc_agents//\"/\\\"}"
  _payload="{\"sprint_id\":\"${_esc_sprint}\",\"path\":\"${_esc_path}\",\"agent_mode\":\"${AGENT_MODE}\",\"agents\":\"${_esc_agents}\"}"
fi

if ! append_event "implement_open" "${_payload}" 2>/dev/null; then
  echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
  exit "${SFS_EXIT_PERM}"
fi

if [[ "${PLAN_REVIEW_VERDICT}" == "pass" ]]; then
  if [[ "${AGENT_MODE}" == "parallel" ]]; then
    echo "implement.md ready: ${IMPLEMENT_PATH} | plan.md: ${PLAN_PATH} | log.md: ${LOG_PATH} | plan review: pass (${PLAN_REVIEW_EVIDENCE}) | agent mode: parallel (${AGENTS_VALUE}) | cross review required before Gate 6 PASS | after implementation run: sfs review --gate 6"
  else
    echo "implement.md ready: ${IMPLEMENT_PATH} | plan.md: ${PLAN_PATH} | log.md: ${LOG_PATH} | plan review: pass (${PLAN_REVIEW_EVIDENCE}) | agent mode: single (default) | optional parallel: sfs implement --agent-mode parallel --agents codex,claude[,gemini] | after implementation run: sfs review --gate 6"
  fi
else
  if [[ "${AGENT_MODE}" == "parallel" ]]; then
    echo "implement.md ready: ${IMPLEMENT_PATH} | plan.md: ${PLAN_PATH} | log.md: ${LOG_PATH} | plan review: waived | agent mode: parallel (${AGENTS_VALUE}) | cross review required before Gate 6 PASS | after implementation run: sfs review --gate 6"
  else
    echo "implement.md ready: ${IMPLEMENT_PATH} | plan.md: ${PLAN_PATH} | log.md: ${LOG_PATH} | plan review: waived | agent mode: single (default) | optional parallel: sfs implement --agent-mode parallel --agents codex,claude[,gemini] | after implementation run: sfs review --gate 6"
  fi
fi

exit "${SFS_EXIT_OK}"
# End of sfs-implement.sh
