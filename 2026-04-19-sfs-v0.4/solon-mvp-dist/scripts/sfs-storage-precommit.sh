#!/usr/bin/env bash
# sfs-storage-precommit.sh — pre-commit / pre-merge storage validator.
#
# Layer 1 + Layer 2 co-location + N:M 매핑 정합 + sprint.yml schema enforcement.
# CI workflow (.github/workflows/sfs-pr-check.yml) 가 본 script 를 호출 (AC2.6 mandatory).
# Local .git/hooks/pre-merge-commit 등록은 advisory (optional).
#
# Usage:
#   sfs storage precommit [--root <repo-root>] [--strict|--advisory]
#
# Exit codes:
#   0  = OK (모든 validator PASS)
#   1  = validator FAIL (PR/merge block)
#   2  = invalid arg
#
# AC reference: AC2.3 (co-location), AC2.4 (N:M conflict), AC2.5 (sprint.yml schema), AC2.6 (CI mandatory).
# Implementation: chunk 1 = skeleton + arg parse + script invoke pattern. 실 validator logic = 다음 chunk.

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
sfs-storage-precommit — pre-commit / pre-merge storage validator

Usage:
  sfs storage precommit [--root <repo-root>] [--strict|--advisory]

Modes:
  --strict    (default for CI) validator fail → exit 1
  --advisory  validator fail → warn but exit 0 (local pre-merge hook 용)

Validators called:
  1. co-location validator   (Layer 1 + Layer 2 같은 feature 가 한 sprint 에 묶임)
  2. N:M 매핑 conflict        (같은 feature × 다른 sprint 가 같은 file 동시 modify)
  3. sprint.yml schema        (8 required field — sfs-sprint-yml-validator.sh --mode validate 호출)
EOF
}

repo_root=""
mode="strict"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help)
      usage
      exit 0
      ;;
    --root)
      repo_root="${2:-}"
      shift 2 || { echo "missing value for --root" >&2; exit 2; }
      ;;
    --strict)
      mode="strict"
      shift
      ;;
    --advisory)
      mode="advisory"
      shift
      ;;
    *)
      echo "${SCRIPT_NAME}: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${repo_root}" ]]; then
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi

if [[ ! -d "${repo_root}" ]]; then
  echo "${SCRIPT_NAME}: repo_root not a directory: ${repo_root}" >&2
  exit 1
fi

fail=0

# 1. co-location validator (Layer 1 docs/ + Layer 2 .solon/sprints/ 같은 feature paired)
# TODO chunk N (R-B B-3): 실 co-location detect logic.
printf 'sfs-storage-precommit: co-location validator placeholder (%s)\n' "${repo_root}"

# 2. N:M 매핑 conflict (같은 feature 가 여러 sprint 에서 같은 file modify)
# TODO chunk N (R-B B-4): 실 conflict detect logic.
printf 'sfs-storage-precommit: N:M validator placeholder\n'

# 3. sprint.yml schema (sfs-sprint-yml-validator.sh --mode validate 위임)
validator="${SCRIPT_DIR}/sfs-sprint-yml-validator.sh"
if [[ -x "${validator}" ]]; then
  # TODO chunk N (R-F F-1 / R-B B-5): 실 sprint.yml file iterate + validator 호출.
  printf 'sfs-storage-precommit: sprint.yml validator placeholder (%s)\n' "${validator}"
else
  printf 'sfs-storage-precommit: sprint.yml validator missing (%s) — advisory skip\n' "${validator}" >&2
fi

if [[ "${fail}" -ne 0 ]]; then
  case "${mode}" in
    strict) exit 1 ;;
    advisory)
      printf 'sfs-storage-precommit: advisory mode — exit 0 despite %d failures\n' "${fail}" >&2
      exit 0
      ;;
  esac
fi

exit 0
