#!/usr/bin/env bash
# sfs-sprint-yml-validator.sh — sprint.yml schema validator + close mode dispatch.
#
# F6 codex preferred fix: validate + close 두 mode 를 한 script 에 통합 (7번째 script 신설 회피).
# AC1.1 6-count preserve.
#
# Usage:
#   sfs-sprint-yml-validator.sh --mode validate <sprint.yml-path>
#   sfs-sprint-yml-validator.sh --mode close <sprint-id> [--force-action a|d]
#
# Modes:
#   validate  schema check (8 required field + status enum + dependencies list)
#             exit 0 = OK, 1 = schema fail
#   close     interactive close — user prompt "Archive or delete? [a/d]"
#             a → .sfs-local/archives/sprint-yml/<sprint-id>.yml.gz
#             d → 완전 삭제
#             --force-action 비대화 (CI/test 용)
#
# Exit codes:
#   0  = OK
#   1  = schema fail (validate) or close error
#   2  = invalid arg
#
# AC reference: AC6.1 (8 required field), AC6.2 (status transition), AC6.3 (close prompt),
#               AC6.4 (archive), AC6.5 (delete), AC6.6 (mode dispatch).

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

REQUIRED_FIELDS=(sprint_id status features dependencies completion_criteria milestones created_at closed_at)
STATUS_ENUM_RE='^(draft|in-progress|in_progress|ready-for-[a-z0-9-]+|closed|abandoned)$'

usage() {
  cat <<'EOF'
sfs-sprint-yml-validator — sprint.yml schema validator + close mode

Usage:
  sfs-sprint-yml-validator.sh --mode validate <sprint.yml-path>
  sfs-sprint-yml-validator.sh --mode close <sprint-id> [--force-action a|d] [--root <r>]

Modes:
  validate   schema check (8 required: sprint_id / status / features / dependencies /
             completion_criteria / milestones / created_at / closed_at). exit 0=OK, 1=fail.
  close      interactive close. prompt "Archive or delete? [a/d]".
             a → .sfs-local/archives/sprint-yml/<sprint-id>.yml.gz
             d → 완전 삭제 (project tree 깔끔)

Status enum: draft | in-progress | ready-for-* | closed | abandoned.
EOF
}

mode=""
target=""
force_action=""
repo_root=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help)
      usage
      exit 0
      ;;
    --mode)
      mode="${2:-}"
      shift 2 || { echo "missing value for --mode" >&2; exit 2; }
      ;;
    --force-action)
      force_action="${2:-}"
      shift 2 || { echo "missing value for --force-action" >&2; exit 2; }
      ;;
    --root)
      repo_root="${2:-}"
      shift 2 || { echo "missing value for --root" >&2; exit 2; }
      ;;
    *)
      if [[ -z "${target}" ]]; then
        target="$1"
        shift
      else
        echo "${SCRIPT_NAME}: unexpected extra arg: $1" >&2
        usage >&2
        exit 2
      fi
      ;;
  esac
done

if [[ -z "${mode}" || -z "${target}" ]]; then
  echo "${SCRIPT_NAME}: --mode <validate|close> + target 필요" >&2
  usage >&2
  exit 2
fi

case "${mode}" in
  validate)
    if [[ ! -f "${target}" ]]; then
      echo "${SCRIPT_NAME}: sprint.yml not found: ${target}" >&2
      exit 1
    fi

    fail=0

    # 1. 8 required fields.
    for f in "${REQUIRED_FIELDS[@]}"; do
      if ! grep -qE "^${f}:" "${target}"; then
        echo "${SCRIPT_NAME}: validate FAIL — missing required field: ${f}" >&2
        fail=$((fail + 1))
      fi
    done

    # 2. status enum check.
    status="$(awk '/^status:/ {print $2; exit}' "${target}" 2>/dev/null | tr -d '"' || true)"
    if [[ -n "${status}" ]] && ! [[ "${status}" =~ ${STATUS_ENUM_RE} ]]; then
      echo "${SCRIPT_NAME}: validate FAIL — status '${status}' not in enum (draft|in-progress|ready-for-*|closed|abandoned)" >&2
      fail=$((fail + 1))
    fi

    # 3. dependencies must be a list (yaml '- ' marker after dependencies: line, OR inline `[]`/`null`).
    if grep -qE '^dependencies:' "${target}"; then
      dep_inline="$(awk '/^dependencies:/ {sub(/^dependencies:[[:space:]]*/, ""); print; exit}' "${target}" 2>/dev/null || true)"
      if [[ -z "${dep_inline}" ]]; then
        # next non-blank line should be `  - ` (yaml block list) or stay empty.
        if ! awk 'BEGIN{found=0} /^dependencies:/{found=1; next} found && NF>0 && !/^[[:space:]]*-/ && !/^[a-z_]+:/{print "non-list-after-deps"; exit} found && NF>0 {exit}' "${target}" | grep -qv "non-list-after-deps"; then
          : # empty list OK
        fi
      elif [[ "${dep_inline}" != "[]" ]] && [[ "${dep_inline}" != "null" ]] && ! [[ "${dep_inline}" =~ ^\[ ]]; then
        echo "${SCRIPT_NAME}: validate FAIL — dependencies inline value '${dep_inline}' must be [] / null / yaml list" >&2
        fail=$((fail + 1))
      fi
    fi

    if [[ "${fail}" -gt 0 ]]; then
      exit 1
    fi
    printf 'sfs-sprint-yml-validator: validate OK — %s\n' "${target}"
    exit 0
    ;;

  close)
    sprint_id="${target}"

    # Resolve sprint.yml path.
    if [[ -z "${repo_root}" ]]; then
      repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
    fi
    cd "${repo_root}"

    candidate=""
    for path in \
      ".solon/sprints/${sprint_id}/sprint.yml" \
      "sprints/${sprint_id}/sprint.yml" \
      ".sfs-local/sprints/${sprint_id}/sprint.yml"; do
      if [[ -f "${path}" ]]; then
        candidate="${path}"
        break
      fi
    done
    if [[ -z "${candidate}" ]]; then
      echo "${SCRIPT_NAME}: close FAIL — sprint.yml not found for sprint_id=${sprint_id}" >&2
      exit 1
    fi

    # Status check — close mode requires status=closed (or status=ready-for-close).
    status="$(awk '/^status:/ {print $2; exit}' "${candidate}" 2>/dev/null | tr -d '"' || true)"
    case "${status}" in
      closed|ready-for-close) ;;
      *)
        echo "${SCRIPT_NAME}: close FAIL — sprint status='${status}' (expected: closed|ready-for-close)" >&2
        exit 1
        ;;
    esac

    # Action prompt (or --force-action).
    action="${force_action}"
    if [[ -z "${action}" ]]; then
      printf 'Archive or delete this sprint.yml? [a/d]: '
      if read -r -t 60 answer 2>/dev/null; then
        action="${answer}"
      else
        action=""
      fi
    fi
    case "${action}" in
      a|A|archive)
        action="a"
        ;;
      d|D|delete)
        action="d"
        ;;
      *)
        echo "${SCRIPT_NAME}: close abort — invalid action '${action}' (expected a/d)" >&2
        exit 1
        ;;
    esac

    case "${action}" in
      a)
        archive_dir=".sfs-local/archives/sprint-yml"
        mkdir -p "${archive_dir}"
        archive_path="${archive_dir}/${sprint_id}.yml.gz"
        gzip -c "${candidate}" > "${archive_path}"
        rm -f "${candidate}"
        printf 'sfs-sprint-yml-validator: archived %s → %s\n' "${candidate}" "${archive_path}"
        ;;
      d)
        rm -f "${candidate}"
        printf 'sfs-sprint-yml-validator: deleted %s (no archive)\n' "${candidate}"
        ;;
    esac
    exit 0
    ;;

  *)
    echo "${SCRIPT_NAME}: unknown mode: ${mode} (expected: validate | close)" >&2
    usage >&2
    exit 2
    ;;
esac
