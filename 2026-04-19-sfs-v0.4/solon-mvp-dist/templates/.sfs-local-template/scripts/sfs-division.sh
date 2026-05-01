#!/usr/bin/env bash
# .sfs-local/scripts/sfs-division.sh
#
# Solon SFS — `/sfs division` command implementation.
# Makes abstract core divisions executable by updating `.sfs-local/divisions.yaml`
# and recording decision/event evidence.

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

: "${SFS_EXIT_BADCLI:=7}"

DIVISIONS_FILE="${SFS_LOCAL_DIR}/divisions.yaml"

usage_division() {
  cat <<'EOF'
Usage: /sfs division <list|status|activate|deactivate> [args]

Commands:
  list
  status
      Print division activation states from .sfs-local/divisions.yaml.

  activate <division|all|--all-abstract> [--scope full|scoped|temporal] [--parent <division>] [--sunset <date>] [--reason <text>]
      Activate one division, or every currently abstract division.
      Writes .sfs-local/divisions.yaml, creates a decision file, and appends a
      division_activated event.

  deactivate <division> [--reason <text>]
      Return a division to abstract state and record a division_deactivated event.

Examples:
  /sfs division list
  /sfs division activate design
  /sfs division activate taxonomy --scope scoped --parent strategy-pm
  /sfs division activate all --reason "Need all division guardrails for this sprint"
EOF
}

ensure_divisions_file() {
  if [[ ! -f "${DIVISIONS_FILE}" ]]; then
    echo "divisions config missing: ${DIVISIONS_FILE}" >&2
    exit "${SFS_EXIT_NO_INIT}"
  fi
}

yaml_escape() {
  printf '%s' "${1:-}" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

division_exists() {
  local id="${1:-}"
  awk -v target="${id}" '
    $0 == "  " target ":" { found=1 }
    END { exit(found ? 0 : 1) }
  ' "${DIVISIONS_FILE}"
}

division_state() {
  local id="${1:-}"
  awk -v target="${id}" '
    /^  [A-Za-z0-9_-]+:[[:space:]]*$/ {
      in_target = ($0 == "  " target ":")
      next
    }
    in_target && /^    activation_state:/ {
      print $2
      found=1
      exit
    }
    END {
      if (!found) exit 1
    }
  ' "${DIVISIONS_FILE}"
}

print_divisions() {
  awk '
    function flush() {
      if (id != "") {
        printf "%s: %s", id, (state != "" ? state : "-")
        if (scope != "") printf " scope=%s", scope
        if (parent != "") printf " parent=%s", parent
        printf "\n"
      }
    }
    /^  [A-Za-z0-9_-]+:[[:space:]]*$/ {
      flush()
      id=$1
      sub(/:$/, "", id)
      state=""
      scope=""
      parent=""
      next
    }
    id != "" && /^    activation_state:/ { state=$2 }
    id != "" && /^    activation_scope:/ { scope=$2 }
    id != "" && /^    parent_division:/ { parent=$2 }
    END { flush() }
  ' "${DIVISIONS_FILE}"
}

abstract_divisions() {
  awk '
    function flush() {
      if (id != "" && state == "abstract") print id
    }
    /^  [A-Za-z0-9_-]+:[[:space:]]*$/ {
      flush()
      id=$1
      sub(/:$/, "", id)
      state=""
      next
    }
    id != "" && /^    activation_state:/ { state=$2 }
    END { flush() }
  ' "${DIVISIONS_FILE}"
}

division_summary() {
  case "${1:-}" in
    strategy-pm) echo "Owns scope, acceptance criteria, tradeoffs, and smallest shippable slice." ;;
    dev) echo "Owns implementation, tests, migration safety, and codebase regularity." ;;
    qa) echo "Owns test strategy, smoke/regression coverage, defect triage, and release confidence." ;;
    design) echo "Owns UX flow, interaction states, accessibility, responsive fit, and design-system consistency." ;;
    infra) echo "Owns secrets, deploy path, observability, rollback, cost, and production readiness." ;;
    taxonomy) echo "Owns canonical domain terms, entities, states, naming rules, and drift detection." ;;
    *) echo "Owns scoped division outputs, review evidence, and handoff notes for its domain." ;;
  esac
}

division_outputs() {
  case "${1:-}" in
    strategy-pm) echo "scope + AC checklist|risk/tradeoff notes|decision handoff" ;;
    dev) echo "implementation notes|test/smoke evidence|handoff risks" ;;
    qa) echo "test matrix|smoke/regression result|release confidence notes" ;;
    design) echo "user flow + screen/state inventory|accessibility/responsive checklist|design-system token/component notes" ;;
    infra) echo "secret/auth/data risk checklist|deploy/rollback notes|monitoring/cost notes" ;;
    taxonomy) echo "canonical terms + forbidden aliases|entity/state naming map|drift notes across code/docs/UI" ;;
    *) echo "division checklist|evidence notes|handoff risks" ;;
  esac
}

write_decision_file() {
  local id="$1" action="$2" scope="$3" parent="$4" reason="$5" sunset="$6"
  local decision_id title slug path now summary outputs

  decision_id="$(next_decision_id)"
  case "${action}" in
    activate) title="Activate ${id} division" ;;
    deactivate) title="Deactivate ${id} division" ;;
    *) title="${action} ${id} division" ;;
  esac
  slug="$(printf '%s' "${action}-${id}-division" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' | sed 's/--*/-/g; s/^-//; s/-$//')"
  path="${SFS_DECISIONS_DIR}/${decision_id}-${slug}.md"
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  summary="$(division_summary "${id}")"
  outputs="$(division_outputs "${id}")"

  mkdir -p "${SFS_DECISIONS_DIR}" || return "${SFS_EXIT_PERM}"
  if [[ -f "${path}" ]]; then
    echo "decision file already exists: ${path}" >&2
    return 1
  fi

  {
    printf -- '---\n'
    printf 'decision_id: "%s"\n' "${decision_id}"
    printf 'title: "%s"\n' "$(yaml_escape "${title}")"
    printf 'created_at: "%s"\n' "${now}"
    printf 'status: accepted\n'
    printf 'division: "%s"\n' "${id}"
    printf 'action: "%s"\n' "${action}"
    printf -- '---\n\n'
    printf '# %s\n\n' "${title}"
    printf '## Context\n\n'
    printf 'The `%s` division needed a concrete runtime state instead of staying only as an abstract concept.\n\n' "${id}"
    printf '## Decision\n\n'
    printf -- '- action: `%s`\n' "${action}"
    printf -- '- division: `%s`\n' "${id}"
    printf -- '- activation_scope: `%s`\n' "${scope}"
    if [[ -n "${parent}" ]]; then
      printf -- '- parent_division: `%s`\n' "${parent}"
    fi
    if [[ -n "${sunset}" ]]; then
      printf -- '- sunset_at: `%s`\n' "${sunset}"
    fi
    printf -- '- reason: %s\n\n' "${reason}"
    printf '## Implementation Contract\n\n'
    printf '%s\n\n' "${summary}"
    printf 'Required outputs:\n'
    printf '%s\n' "${outputs}" | tr '|' '\n' | sed 's/^/- /'
    printf '\n## Consequences\n\n'
    if [[ "${action}" == "activate" ]]; then
      printf 'SFS commands may now treat `%s` as executable division scope and should record evidence in sprint workbench/report artifacts.\n' "${id}"
    else
      printf 'SFS commands should treat `%s` as abstract again unless a later decision reactivates it.\n' "${id}"
    fi
  } > "${path}" || return "${SFS_EXIT_PERM}"

  printf '%s\n' "${path}"
}

activate_one() {
  local id="$1" scope="$2" parent="$3" reason="$4" sunset="$5"
  local state now tmp summary outputs decision_path esc_reason esc_summary

  if ! division_exists "${id}"; then
    echo "unknown division: ${id}" >&2
    return "${SFS_EXIT_BADCLI}"
  fi
  state="$(division_state "${id}" || true)"
  if [[ "${state}" == "active" ]]; then
    echo "division already active: ${id}"
    return 0
  fi
  if [[ "${scope}" == "scoped" && -z "${parent}" ]]; then
    echo "activation scope 'scoped' requires --parent <division>" >&2
    return "${SFS_EXIT_BADCLI}"
  fi
  if [[ -n "${parent}" ]]; then
    if ! division_exists "${parent}"; then
      echo "unknown parent division: ${parent}" >&2
      return "${SFS_EXIT_BADCLI}"
    fi
    if [[ "$(division_state "${parent}" || true)" != "active" ]]; then
      echo "parent division is not active: ${parent}" >&2
      return "${SFS_EXIT_BADCLI}"
    fi
  fi

  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  summary="$(division_summary "${id}")"
  outputs="$(division_outputs "${id}")"
  esc_reason="$(yaml_escape "${reason}")"
  esc_summary="$(yaml_escape "${summary}")"
  tmp="${DIVISIONS_FILE}.tmp.$$"

  awk \
    -v target="${id}" \
    -v scope="${scope}" \
    -v parent="${parent}" \
    -v sunset="${sunset}" \
    -v now="${now}" \
    -v reason="${esc_reason}" \
    -v summary="${esc_summary}" \
    -v outputs="${outputs}" '
    function is_header(line) {
      return line ~ /^  [A-Za-z0-9_-]+:[[:space:]]*$/
    }
    function emit_activation(    n, parts, i) {
      print "    activation_state: active"
      print "    activation_scope: " scope
      if (parent != "") print "    parent_division: " parent
      if (sunset != "") print "    sunset_at: \"" sunset "\""
      print "    activated_at: \"" now "\""
      print "    activation_reason: \"" reason "\""
      print "    implementation_contract:"
      print "      summary: \"" summary "\""
      print "      outputs:"
      n = split(outputs, parts, /\|/)
      for (i = 1; i <= n; i++) {
        if (parts[i] != "") print "        - \"" parts[i] "\""
      }
      print "      evidence:"
      print "        - \"decision file under .sfs-local/decisions/\""
      print "        - \"events.jsonl division_activated event\""
      emitted=1
    }
    {
      if (in_target && skip_contract) {
        if ($0 ~ /^      / || $0 ~ /^        /) next
        skip_contract=0
      }
      if (in_target && !emitted && $0 ~ /^[[:space:]]*$/) {
        emit_activation()
        print
        next
      }
      if (in_target && !is_header($0) && $0 !~ /^    / && $0 !~ /^[[:space:]]*$/) {
        if (!emitted) emit_activation()
        in_target=0
        print
        next
      }
      if (is_header($0)) {
        if (in_target && !emitted) emit_activation()
        in_target = ($0 == "  " target ":")
        emitted=0
        print
        next
      }
      if (in_target) {
        if ($0 ~ /^    implementation_contract:/) { skip_contract=1; next }
        if ($0 ~ /^    (activation_state|activation_scope|parent_division|sunset_at|activated_at|deactivated_at|activation_reason|deactivation_reason|reason):/) next
      }
      print
    }
    END {
      if (in_target && !emitted) emit_activation()
    }
  ' "${DIVISIONS_FILE}" > "${tmp}" && mv -f "${tmp}" "${DIVISIONS_FILE}" || return "${SFS_EXIT_PERM}"

  decision_path="$(write_decision_file "${id}" "activate" "${scope}" "${parent}" "${reason}" "${sunset}")" || return $?

  local _esc_id _esc_scope _esc_parent _esc_decision
  _esc_id="$(yaml_escape "${id}")"
  _esc_scope="$(yaml_escape "${scope}")"
  _esc_parent="$(yaml_escape "${parent}")"
  _esc_decision="$(yaml_escape "${decision_path}")"
  append_event "division_activated" "{\"division\":\"${_esc_id}\",\"activation_scope\":\"${_esc_scope}\",\"parent_division\":\"${_esc_parent}\",\"decision_path\":\"${_esc_decision}\"}"
  echo "division activated: ${id} | scope ${scope} | decision ${decision_path}"
}

deactivate_one() {
  local id="$1" reason="$2" now tmp decision_path esc_reason

  if ! division_exists "${id}"; then
    echo "unknown division: ${id}" >&2
    return "${SFS_EXIT_BADCLI}"
  fi

  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  tmp="${DIVISIONS_FILE}.tmp.$$"
  esc_reason="$(yaml_escape "${reason}")"
  awk -v target="${id}" -v now="${now}" -v reason="${esc_reason}" '
    function is_header(line) {
      return line ~ /^  [A-Za-z0-9_-]+:[[:space:]]*$/
    }
    function emit_deactivation() {
      print "    activation_state: abstract"
      print "    deactivated_at: \"" now "\""
      print "    deactivation_reason: \"" reason "\""
      emitted=1
    }
    {
      if (in_target && skip_contract) {
        if ($0 ~ /^      / || $0 ~ /^        /) next
        skip_contract=0
      }
      if (in_target && !emitted && $0 ~ /^[[:space:]]*$/) {
        emit_deactivation()
        print
        next
      }
      if (in_target && !is_header($0) && $0 !~ /^    / && $0 !~ /^[[:space:]]*$/) {
        if (!emitted) emit_deactivation()
        in_target=0
        print
        next
      }
      if (is_header($0)) {
        if (in_target && !emitted) emit_deactivation()
        in_target = ($0 == "  " target ":")
        emitted=0
        print
        next
      }
      if (in_target) {
        if ($0 ~ /^    implementation_contract:/) { skip_contract=1; next }
        if ($0 ~ /^    (activation_state|activation_scope|parent_division|sunset_at|activated_at|deactivated_at|activation_reason|deactivation_reason|reason):/) next
      }
      print
    }
    END {
      if (in_target && !emitted) emit_deactivation()
    }
  ' "${DIVISIONS_FILE}" > "${tmp}" && mv -f "${tmp}" "${DIVISIONS_FILE}" || return "${SFS_EXIT_PERM}"

  decision_path="$(write_decision_file "${id}" "deactivate" "abstract" "" "${reason}" "")" || return $?
  local _esc_id _esc_decision
  _esc_id="$(yaml_escape "${id}")"
  _esc_decision="$(yaml_escape "${decision_path}")"
  append_event "division_deactivated" "{\"division\":\"${_esc_id}\",\"decision_path\":\"${_esc_decision}\"}"
  echo "division deactivated: ${id} | decision ${decision_path}"
}

cmd="${1:-list}"
shift || true

case "${cmd}" in
  -h|--help|help)
    usage_division
    exit "${SFS_EXIT_OK}"
    ;;
esac

set +e
validate_sfs_local
rc=$?
set -e
if [[ "${rc}" -ne 0 ]]; then
  exit "${rc}"
fi
ensure_divisions_file

case "${cmd}" in
  list|status)
    print_divisions
    ;;
  activate)
    target=""
    scope="full"
    parent=""
    sunset=""
    reason="Manual division activation"
    all_abstract=0
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --all-abstract)
          all_abstract=1
          shift
          ;;
        --scope)
          [[ $# -ge 2 ]] || { echo "--scope requires a value" >&2; exit "${SFS_EXIT_BADCLI}"; }
          scope="$2"
          shift 2
          ;;
        --scope=*)
          scope="${1#--scope=}"
          shift
          ;;
        --parent)
          [[ $# -ge 2 ]] || { echo "--parent requires a value" >&2; exit "${SFS_EXIT_BADCLI}"; }
          parent="$2"
          shift 2
          ;;
        --parent=*)
          parent="${1#--parent=}"
          shift
          ;;
        --sunset)
          [[ $# -ge 2 ]] || { echo "--sunset requires a value" >&2; exit "${SFS_EXIT_BADCLI}"; }
          sunset="$2"
          shift 2
          ;;
        --sunset=*)
          sunset="${1#--sunset=}"
          shift
          ;;
        --reason)
          [[ $# -ge 2 ]] || { echo "--reason requires a value" >&2; exit "${SFS_EXIT_BADCLI}"; }
          reason="$2"
          shift 2
          ;;
        --reason=*)
          reason="${1#--reason=}"
          shift
          ;;
        -*)
          echo "unknown flag: $1" >&2
          exit "${SFS_EXIT_BADCLI}"
          ;;
        *)
          if [[ -n "${target}" ]]; then
            echo "unexpected extra arg: $1" >&2
            exit "${SFS_EXIT_BADCLI}"
          fi
          target="$1"
          shift
          ;;
      esac
    done
    case "${scope}" in
      full|scoped|temporal) ;;
      *) echo "invalid --scope: ${scope} (expected full|scoped|temporal)" >&2; exit "${SFS_EXIT_BADCLI}" ;;
    esac
    if [[ "${target}" == "all" ]]; then
      all_abstract=1
    fi
    if [[ "${all_abstract}" == "1" ]]; then
      targets="$(abstract_divisions)"
      if [[ -z "${targets}" ]]; then
        echo "no abstract divisions to activate"
        exit "${SFS_EXIT_OK}"
      fi
      while IFS= read -r id; do
        [[ -z "${id}" ]] && continue
        activate_one "${id}" "${scope}" "${parent}" "${reason}" "${sunset}"
      done <<EOF
${targets}
EOF
    else
      [[ -n "${target}" ]] || { echo "usage: /sfs division activate <division|all>" >&2; exit "${SFS_EXIT_BADCLI}"; }
      activate_one "${target}" "${scope}" "${parent}" "${reason}" "${sunset}"
    fi
    ;;
  deactivate)
    target=""
    reason="Manual division deactivation"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --reason)
          [[ $# -ge 2 ]] || { echo "--reason requires a value" >&2; exit "${SFS_EXIT_BADCLI}"; }
          reason="$2"
          shift 2
          ;;
        --reason=*)
          reason="${1#--reason=}"
          shift
          ;;
        -*)
          echo "unknown flag: $1" >&2
          exit "${SFS_EXIT_BADCLI}"
          ;;
        *)
          if [[ -n "${target}" ]]; then
            echo "unexpected extra arg: $1" >&2
            exit "${SFS_EXIT_BADCLI}"
          fi
          target="$1"
          shift
          ;;
      esac
    done
    [[ -n "${target}" ]] || { echo "usage: /sfs division deactivate <division>" >&2; exit "${SFS_EXIT_BADCLI}"; }
    deactivate_one "${target}" "${reason}"
    ;;
  *)
    echo "unknown division command: ${cmd}" >&2
    usage_division >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac

exit "${SFS_EXIT_OK}"
