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

cd "${repo_root}"

fail=0
checks_run=0

# 1. co-location validator (Layer 1 docs/ + Layer 2 .solon/sprints/ 같은 feature paired)
#    rule: 모든 Layer 2 feat 는 적어도 하나의 Layer 1 docs/<d>/<s>/<feat>/ 에 mirror 가 있어야.
#    rationale: Layer 2 = 작업본, Layer 1 = 영구본. 작업했는데 영구 path 없으면 co-location 위반.
if [[ -d ".solon/sprints" ]]; then
  checks_run=$((checks_run + 1))
  while IFS= read -r layer2_dir; do
    rel="${layer2_dir#.solon/sprints/}"
    IFS=/ read -r sid feat <<< "${rel}"
    [[ -n "${feat}" ]] || continue
    # check Layer 1 docs/<any>/<any>/<feat>/ 가 적어도 하나 존재.
    if ! find docs -mindepth 3 -maxdepth 3 -type d -name "${feat}" 2>/dev/null | grep -q .; then
      echo "${SCRIPT_NAME}: co-location FAIL — Layer 2 .solon/sprints/${sid}/${feat}/ has no Layer 1 docs/*/*/${feat}/ mirror" >&2
      fail=$((fail + 1))
    fi
  done < <(find .solon/sprints -mindepth 2 -maxdepth 2 -type d 2>/dev/null || true)
fi

# 2. N:M 매핑 conflict (같은 feature 가 여러 sprint 에서 같은 file modify)
#    static heuristic: 같은 feat 가 active (status != closed) sprint 2+ 개에서 같은 Layer 1 file 영향 → conflict.
#    bash 3.2 호환: associative array 대신 newline-delimited string + grep.
if [[ -d ".solon/sprints" ]]; then
  checks_run=$((checks_run + 1))
  # Build "feat<TAB>sid" lines for active sprints.
  feat_sprint_lines=""
  while IFS= read -r sprint_dir; do
    sid="${sprint_dir##*/}"
    yml="${sprint_dir}/sprint.yml"
    status=""
    if [[ -f "${yml}" ]]; then
      status="$(awk '/^status:/ {print $2; exit}' "${yml}" 2>/dev/null | tr -d '"' || true)"
    fi
    case "${status}" in closed|abandoned) continue ;; esac
    while IFS= read -r feat_dir; do
      f="${feat_dir##*/}"
      [[ -n "${f}" ]] || continue
      feat_sprint_lines="${feat_sprint_lines}${f}	${sid}
"
    done < <(find "${sprint_dir}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null || true)
  done < <(find .solon/sprints -mindepth 1 -maxdepth 1 -type d 2>/dev/null || true)

  # Distinct feats with 2+ active sprints.
  if [[ -n "${feat_sprint_lines}" ]]; then
    while IFS= read -r feat; do
      [[ -n "${feat}" ]] || continue
      sprint_list_csv="$(printf '%s\n' "${feat_sprint_lines}" | awk -F'\t' -v f="${feat}" '$1==f {print $2}' | sort -u | paste -sd, -)"
      n_sprints="$(printf '%s' "${sprint_list_csv}" | tr ',' '\n' | grep -c .)"
      [[ "${n_sprints}" -ge 2 ]] || continue
      # Find Layer 1 dir.
      layer1_dir="$(find docs -mindepth 3 -maxdepth 3 -type d -name "${feat}" 2>/dev/null | head -1 || true)"
      [[ -n "${layer1_dir}" ]] || continue
      # Build "layer1_path<TAB>sid" for each sprint that touches a file present in Layer 1.
      file_sprint_lines=""
      IFS=, read -ra sprint_list <<< "${sprint_list_csv}"
      for sid in "${sprint_list[@]}"; do
        [[ -n "${sid}" ]] || continue
        while IFS= read -r touched; do
          rel_in_layer2="${touched#.solon/sprints/${sid}/${feat}/}"
          layer1_candidate="${layer1_dir}/${rel_in_layer2}"
          if [[ -f "${layer1_candidate}" ]]; then
            file_sprint_lines="${file_sprint_lines}${layer1_candidate}	${sid}
"
          fi
        done < <(find ".solon/sprints/${sid}/${feat}" -type f 2>/dev/null || true)
      done
      if [[ -n "${file_sprint_lines}" ]]; then
        # For each distinct file, count distinct sprints — 2+ = conflict.
        while IFS= read -r conflicting_file; do
          [[ -n "${conflicting_file}" ]] || continue
          conflict_sprints="$(printf '%s\n' "${file_sprint_lines}" | awk -F'\t' -v f="${conflicting_file}" '$1==f {print $2}' | sort -u | paste -sd, -)"
          conflict_count="$(printf '%s' "${conflict_sprints}" | tr ',' '\n' | grep -c .)"
          if [[ "${conflict_count}" -ge 2 ]]; then
            echo "${SCRIPT_NAME}: N:M FAIL — feat '${feat}' file '${conflicting_file}' modified by ${conflict_count} active sprints: ${conflict_sprints}" >&2
            fail=$((fail + 1))
          fi
        done < <(printf '%s\n' "${file_sprint_lines}" | awk -F'\t' '{print $1}' | sort -u)
      fi
    done < <(printf '%s\n' "${feat_sprint_lines}" | awk -F'\t' '{print $1}' | sort -u)
  fi
fi

# 3. sprint.yml schema (sfs-sprint-yml-validator.sh --mode validate 위임)
validator="${SCRIPT_DIR}/sfs-sprint-yml-validator.sh"
if [[ -x "${validator}" ]]; then
  checks_run=$((checks_run + 1))
  while IFS= read -r yml; do
    if ! "${validator}" --mode validate "${yml}" >/dev/null 2>&1; then
      echo "${SCRIPT_NAME}: sprint.yml schema FAIL — ${yml}" >&2
      fail=$((fail + 1))
    fi
  done < <(find .solon/sprints sprints -name 'sprint.yml' -type f 2>/dev/null || true)
else
  printf 'sfs-storage-precommit: sprint.yml validator missing (%s) — advisory skip\n' "${validator}" >&2
fi

if [[ "${fail}" -ne 0 ]]; then
  case "${mode}" in
    strict)
      printf 'sfs-storage-precommit: STRICT FAIL — %d issues across %d checks\n' "${fail}" "${checks_run}" >&2
      exit 1
      ;;
    advisory)
      printf 'sfs-storage-precommit: advisory mode — exit 0 despite %d failures across %d checks\n' "${fail}" "${checks_run}" >&2
      exit 0
      ;;
  esac
fi

printf 'sfs-storage-precommit: OK — %d checks, 0 failures (mode=%s, root=%s)\n' "${checks_run}" "${mode}" "${repo_root}"
exit 0
