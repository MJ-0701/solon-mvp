#!/usr/bin/env bash
# sfs-sprint-yml-validator.sh — sprint.yml schema validator + close mode dispatch.
#
# F6 codex preferred fix: validate + close 두 mode 를 한 script 에 통합 (7번째 script 신설 회피).
# AC1.1 6-count preserve.
#
# Usage:
#   sfs-sprint-yml-validator.sh --mode validate <sprint.yml-path>
#   sfs-sprint-yml-validator.sh --mode close <sprint-id>
#
# Modes:
#   validate  schema check (8 required field + status enum + dependencies list)
#             exit 0 = OK, 1 = schema fail
#   close     interactive close — user prompt "Archive or delete? [a/d]"
#             a → .sfs-local/archives/sprint-yml/<sprint-id>.yml.gz
#             d → 완전 삭제
#
# Exit codes:
#   0  = OK
#   1  = schema fail (validate) or close error
#   2  = invalid arg
#
# AC reference: AC6.1 (8 required field), AC6.3 (close prompt), AC6.4 (archive), AC6.5 (delete), AC6.6 (mode dispatch).
# Implementation: chunk 1 = skeleton + arg parse + mode dispatch. 실 yaml schema check + archive/delete logic = 다음 chunk (R-F F-1~F-5).

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<'EOF'
sfs-sprint-yml-validator — sprint.yml schema validator + close mode

Usage:
  sfs-sprint-yml-validator.sh --mode validate <sprint.yml-path>
  sfs-sprint-yml-validator.sh --mode close <sprint-id>

Modes:
  validate   schema check (8 required: sprint_id / status / features / dependencies /
             completion_criteria / milestones / created_at / closed_at). exit 0=OK, 1=fail.
  close      interactive close. prompt "Archive or delete? [a/d]".
             a → .sfs-local/archives/sprint-yml/<sprint-id>.yml.gz
             d → 완전 삭제 (project tree 깔끔)
EOF
}

mode=""
target=""

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
    # TODO chunk N (R-F F-1):
    #   - 8 required field grep (sprint_id / status / features / dependencies /
    #     completion_criteria / milestones / created_at / closed_at)
    #   - status enum check (draft / in-progress / ready-for-* / closed)
    #   - status transition validity (R-F F-2)
    # placeholder: 단순 file 존재만 OK.
    required=(sprint_id status features dependencies completion_criteria milestones created_at closed_at)
    fail=0
    for f in "${required[@]}"; do
      if ! grep -qE "^${f}:" "${target}"; then
        echo "${SCRIPT_NAME}: validate FAIL — missing required field: ${f}" >&2
        fail=$((fail + 1))
      fi
    done
    if [[ "${fail}" -gt 0 ]]; then
      exit 1
    fi
    printf 'sfs-sprint-yml-validator: validate OK — %s (8 required field 모두 존재)\n' "${target}"
    exit 0
    ;;
  close)
    sprint_id="${target}"
    # TODO chunk N (R-F F-3~F-5):
    #   - sprint.yml file path 결정 (.solon/sprints/${sprint_id}/sprint.yml or sprints/${sprint_id}/sprint.yml)
    #   - sprint.yml status=closed 확인
    #   - prompt "Archive or delete? [a/d]" (default reject — F-3)
    #   - a: gzip + mv to .sfs-local/archives/sprint-yml/${sprint_id}.yml.gz + 원본 rm
    #   - d: rm 원본 + archive 미생성
    printf 'sfs-sprint-yml-validator: close mode placeholder — sprint_id=%s\n' "${sprint_id}"
    printf 'Archive or delete this sprint.yml? [a/d] (placeholder, default: a)\n'
    # placeholder: stdin read 미수행 (chunk N 실 prompt).
    exit 0
    ;;
  *)
    echo "${SCRIPT_NAME}: unknown mode: ${mode} (expected: validate | close)" >&2
    usage >&2
    exit 2
    ;;
esac
