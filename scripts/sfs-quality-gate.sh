#!/usr/bin/env bash
# sfs-quality-gate.sh — bounded quality-gate entry point for the distribution repo.
#
# This wrapper intentionally composes only checks that already exist in-tree.
# It does not invent new linters or mutate release state. Modes are cumulative:
#   pr      cheap structural + safe checks already used by current PR CI
#   full    pr + full local regression suite
#   release full + release verification, with optional external-tool preflight
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
repo_root=""
mode="pr"
version=""

step_names=()
step_statuses=()
step_commands=()
step_notes=()

usage() {
  cat <<'EOF'
sfs-quality-gate.sh — executable quality-gate wrapper for this shell/distribution repo

Usage:
  sfs-quality-gate.sh [--root <repo-root>] [--mode pr|full|release] [--version X.Y.Z]

Modes:
  pr
    - bash -n over scripts/*.sh and tests/*.sh
    - tests/test-sfs-quality-gate.sh
    - tests/test-aws-agent-toolkit-setup-policy.sh
    - scripts/sfs-pr-review-flow-check.sh --root <repo-root> --strict
      runs only when explicit PR context env is present; otherwise documented SKIP
    - scripts/sfs-storage-precommit.sh --root <repo-root> --strict
    - tests/test-sfs-pr-check-strict.sh
    - tests/test-bad-fixture.sh
    - tests/test-workflow-permissions.sh
    - tests/scoop-manifest-validate.sh
    - tests/test-hash-parity.sh

  full
    - every pr step
    - tests/run-all.sh

  release
    - every full step
    - scripts/verify-product-release.sh --version X.Y.Z
    - scripts/sfs-channel-publish-preflight.sh --version X.Y.Z --mode push
      only when `gh` is available; otherwise documented SKIP

Notes:
  - release mode requires --version
  - commands fail fast on real non-zero exits
  - a summary is printed for every PASS / SKIP / FAIL step
EOF
}

append_step() {
  step_names+=("$1")
  step_statuses+=("$2")
  step_commands+=("$3")
  step_notes+=("$4")
}

print_summary() {
  local rc="$1"
  local i pass=0 skip=0 fail=0 final="OK"
  if [[ "${rc}" -ne 0 ]]; then
    final="FAIL"
  fi

  printf '\nSummary (%s, mode=%s)\n' "${final}" "${mode}"
  for ((i=0; i<${#step_names[@]}; i++)); do
    case "${step_statuses[$i]}" in
      PASS) pass=$((pass + 1)) ;;
      SKIP) skip=$((skip + 1)) ;;
      FAIL) fail=$((fail + 1)) ;;
    esac
    printf '  %-4s %-28s %s\n' "${step_statuses[$i]}" "${step_names[$i]}" "${step_commands[$i]}"
    if [[ -n "${step_notes[$i]}" ]]; then
      printf '       %s\n' "${step_notes[$i]}"
    fi
  done
  printf '%s: mode=%s pass=%d skip=%d fail=%d\n' "${SCRIPT_NAME}" "${mode}" "${pass}" "${skip}" "${fail}"
}

run_step() {
  local name="$1" note="$2"
  shift 2
  local cmd_text
  cmd_text="$(printf '%s ' "$@")"
  cmd_text="${cmd_text% }"

  printf '\n[%d] %s\n' "$(( ${#step_names[@]} + 1 ))" "${name}"
  printf 'cmd  %s\n' "${cmd_text}"
  "$@"
  append_step "${name}" PASS "${cmd_text}" "${note}"
}

fail_step() {
  local name="$1" note="$2" rc="$3" cmd_text="$4"
  append_step "${name}" FAIL "${cmd_text}" "${note} (exit=${rc})"
  print_summary "${rc}"
  exit "${rc}"
}

run_guarded_step() {
  local name="$1" note="$2"
  shift 2
  local cmd_text rc
  cmd_text="$(printf '%s ' "$@")"
  cmd_text="${cmd_text% }"

  printf '\n[%d] %s\n' "$(( ${#step_names[@]} + 1 ))" "${name}"
  printf 'cmd  %s\n' "${cmd_text}"
  set +e
  "$@"
  rc=$?
  set -e
  if [[ "${rc}" -ne 0 ]]; then
    fail_step "${name}" "${note}" "${rc}" "${cmd_text}"
  fi
  append_step "${name}" PASS "${cmd_text}" "${note}"
}

skip_step() {
  local name="$1" cmd_text="$2" note="$3"
  printf '\n[%d] %s\n' "$(( ${#step_names[@]} + 1 ))" "${name}"
  printf 'skip %s\n' "${note}"
  append_step "${name}" SKIP "${cmd_text}" "${note}"
}

run_bash_syntax_step() {
  local files=() file found=0 rc=0
  for file in "${repo_root}"/scripts/*.sh "${repo_root}"/tests/*.sh; do
    [[ -e "${file}" ]] || continue
    files+=("${file}")
    found=1
  done

  if [[ "${found}" -eq 0 ]]; then
    fail_step "bash-syntax" "expected scripts/*.sh and tests/*.sh under repo root" 1 "bash -n scripts/*.sh tests/*.sh"
  fi

  printf '\n[%d] bash-syntax\n' "$(( ${#step_names[@]} + 1 ))"
  printf 'cmd  bash -n scripts/*.sh tests/*.sh\n'
  set +e
  for file in "${files[@]+"${files[@]}"}"; do
    bash -n "${file}" || rc=$?
    if [[ "${rc}" -ne 0 ]]; then
      break
    fi
  done
  set -e

  if [[ "${rc}" -ne 0 ]]; then
    fail_step "bash-syntax" "shell syntax check failed" "${rc}" "bash -n scripts/*.sh tests/*.sh"
  fi
  append_step "bash-syntax" PASS "bash -n scripts/*.sh tests/*.sh" "current PR CI syntax baseline"
}

has_explicit_pr_context() {
  [[ -n "${SFS_PR_CHANGED_FILES:-}" ]] && return 0
  [[ -n "${SFS_PR_BODY:-}" ]] && return 0
  [[ -n "${SFS_PR_BASE_SHA:-}" && -n "${SFS_PR_HEAD_SHA:-}" ]] && return 0
  if [[ -n "${GITHUB_EVENT_PATH:-}" && -f "${GITHUB_EVENT_PATH:-}" ]]; then
    if command -v jq >/dev/null 2>&1; then
      jq -e '.pull_request? != null' "${GITHUB_EVENT_PATH}" >/dev/null 2>&1 && return 0
    elif command -v ruby >/dev/null 2>&1; then
      ruby -rjson -e 'exit(JSON.parse(File.read(ARGV.fetch(0))).key?("pull_request") ? 0 : 1)' \
        "${GITHUB_EVENT_PATH}" >/dev/null 2>&1 && return 0
    elif command -v python3 >/dev/null 2>&1; then
      python3 -c 'import json,sys; raise SystemExit(0 if "pull_request" in json.load(open(sys.argv[1])) else 1)' \
        "${GITHUB_EVENT_PATH}" >/dev/null 2>&1 && return 0
    fi
  fi
  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help)
      usage
      exit 0
      ;;
    --root)
      repo_root="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: missing value for --root" >&2; exit 2; }
      ;;
    --mode)
      mode="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: missing value for --mode" >&2; exit 2; }
      ;;
    --version)
      version="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: missing value for --version" >&2; exit 2; }
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
  echo "${SCRIPT_NAME}: repo root not found: ${repo_root}" >&2
  exit 2
fi
case "${mode}" in
  pr|full|release) ;;
  *)
    echo "${SCRIPT_NAME}: --mode must be pr, full, or release" >&2
    exit 2
    ;;
esac
if [[ "${mode}" == "release" && -z "${version}" ]]; then
  echo "${SCRIPT_NAME}: --version is required in release mode" >&2
  exit 2
fi

printf 'sfs-quality-gate: mode=%s root=%s\n' "${mode}" "${repo_root}"

run_bash_syntax_step

if has_explicit_pr_context; then
  run_guarded_step \
    "pr-review-flow-evidence" \
    "existing PR review-flow gate from current workflow" \
    bash "${repo_root}/scripts/sfs-pr-review-flow-check.sh" --root "${repo_root}" --strict
else
  skip_step \
    "pr-review-flow-evidence" \
    "bash ${repo_root}/scripts/sfs-pr-review-flow-check.sh --root ${repo_root} --strict" \
    "explicit PR context env not present"
fi

run_guarded_step \
  "storage-precommit" \
  "existing strict storage validator from current workflow" \
  bash "${repo_root}/scripts/sfs-storage-precommit.sh" --root "${repo_root}" --strict
run_guarded_step \
  "quality-gate-contract" \
  "isolated fake-repository contract coverage for this wrapper" \
  bash "${repo_root}/tests/test-sfs-quality-gate.sh"
run_guarded_step \
  "aws-agent-toolkit-policy" \
  "distributed AWS Agent Toolkit setup-policy regression" \
  bash "${repo_root}/tests/test-aws-agent-toolkit-setup-policy.sh"
run_guarded_step \
  "pr-check-strict-contract" \
  "regression lock for canonical PR wrapper plus strict storage enforcement" \
  bash "${repo_root}/tests/test-sfs-pr-check-strict.sh"
run_guarded_step \
  "bad-fixture" \
  "existing malformed sprint fixture rejection test" \
  bash "${repo_root}/tests/test-bad-fixture.sh"
run_guarded_step \
  "workflow-permissions" \
  "existing workflow permissions hardening test" \
  bash "${repo_root}/tests/test-workflow-permissions.sh"
run_guarded_step \
  "scoop-manifest" \
  "existing scoop manifest surrogate validation" \
  bash "${repo_root}/tests/scoop-manifest-validate.sh"
run_guarded_step \
  "hash-parity" \
  "existing LF/hash parity regression test" \
  bash "${repo_root}/tests/test-hash-parity.sh"

if [[ "${mode}" == "full" || "${mode}" == "release" ]]; then
  run_guarded_step \
    "run-all" \
    "full in-repo regression suite" \
    bash "${repo_root}/tests/run-all.sh"
fi

if [[ "${mode}" == "release" ]]; then
  run_guarded_step \
    "verify-product-release" \
    "existing local-evidence release verifier" \
    bash "${repo_root}/scripts/verify-product-release.sh" --version "${version}"

  if command -v gh >/dev/null 2>&1; then
    run_guarded_step \
      "channel-publish-preflight" \
      "optional workflow credential classifier when gh is available" \
      bash "${repo_root}/scripts/sfs-channel-publish-preflight.sh" --version "${version}" --mode push
  else
    skip_step \
      "channel-publish-preflight" \
      "bash ${repo_root}/scripts/sfs-channel-publish-preflight.sh --version ${version} --mode push" \
      "optional external check skipped because gh is unavailable"
  fi
fi

print_summary 0
