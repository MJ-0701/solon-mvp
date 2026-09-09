#!/usr/bin/env bash
# 제품 PR 검증기가 GitHub-only review 증거를 SFS Gate 6 flow 대체물로 받지 않는지 확인한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHECK="${DIST_DIR}/scripts/sfs-pr-review-flow-check.sh"
WORKFLOW="${DIST_DIR}/.github/workflows/sfs-pr-check.yml"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2" label="$3"
  case "${haystack}" in
    *"${needle}"*) ;;
    *) fail "${label}: missing '${needle}' in: ${haystack}" ;;
  esac
}

assert_file_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

run_check() {
  SFS_PR_CHANGED_FILES="${1}" SFS_PR_BODY="${2}" bash "${CHECK}" --root "${DIST_DIR}"
}

[[ -x "${CHECK}" ]] || fail "${CHECK} is not executable"

docs_only_out="$(run_check $'notes/internal.txt' '')"
assert_contains "${docs_only_out}" "no product-bearing paths changed" "docs-only skip"

set +e
empty_out="$(run_check $'scripts/sfs-review.sh' '' 2>&1)"
empty_rc=$?
set -e
[[ "${empty_rc}" -eq 1 ]] || fail "empty product PR should fail, got ${empty_rc}: ${empty_out}"
assert_contains "${empty_out}" "formal SFS Gate 6 self/cross review evidence is missing" "empty body failure"

set +e
github_only_out="$(run_check $'scripts/sfs-review.sh' $'GitHub @codex PASS\nPR approval PASS' 2>&1)"
github_only_rc=$?
set -e
[[ "${github_only_rc}" -eq 1 ]] || fail "GitHub-only product PR should fail, got ${github_only_rc}: ${github_only_out}"
assert_contains "${github_only_out}" "external evidence only and does not satisfy SFS self/cross review" "GitHub-only boundary"

set +e
self_only_out="$(run_check $'templates/.sfs-local-template/context/commands/review.md' $'sfs review --gate 6 --stage self\nGitHub @codex PASS' 2>&1)"
self_only_rc=$?
set -e
[[ "${self_only_rc}" -eq 1 ]] || fail "self-only product PR should fail, got ${self_only_rc}: ${self_only_out}"
assert_contains "${self_only_out}" "cross CPO" "self-only cross guidance"

set +e
fail_verdict_out="$(run_check $'scripts/sfs-review.sh' $'sfs review --gate 6 --stage self: FAIL\nsfs review --gate 6 --stage cross: PASS' 2>&1)"
fail_verdict_rc=$?
set -e
[[ "${fail_verdict_rc}" -eq 1 ]] || fail "self FAIL evidence should fail, got ${fail_verdict_rc}: ${fail_verdict_out}"
assert_contains "${fail_verdict_out}" "self-CPO PASS" "self fail guidance"

set +e
generic_fallback_out="$(run_check $'scripts/sfs-review.sh' $'sfs review --gate 6 --stage self: PASS\nSelf-CPO fallback: true\nFallback reason: TODO' 2>&1)"
generic_fallback_rc=$?
set -e
[[ "${generic_fallback_rc}" -eq 1 ]] || fail "generic fallback should fail, got ${generic_fallback_rc}: ${generic_fallback_out}"
assert_contains "${generic_fallback_out}" "concrete fallback reason" "generic fallback guidance"

full_body=$'SFS evidence:\n- sfs review --gate 6 --stage self: PASS\n- sfs review --gate 6 --stage cross: PASS\n- GitHub @codex: external evidence last'
full_out="$(run_check $'scripts/sfs-review.sh\ntests/test-review-implementation-sequence.sh' "${full_body}")"
assert_contains "${full_out}" "formal SFS Gate 6 self/cross evidence" "full evidence pass"

fallback_body=$'SFS evidence:\nGate 6 self-CPO PASS\nSelf-CPO fallback: true\nFallback reason: no other agent subscription'
fallback_out="$(run_check $'bin/sfs' "${fallback_body}")"
assert_contains "${fallback_out}" "formal SFS Gate 6 self/cross evidence" "fallback evidence pass"

assert_file_contains "${WORKFLOW}" "sfs-quality-gate.sh --root . --mode pr" "workflow invokes canonical quality gate"
assert_file_contains "${WORKFLOW}" "SFS_PR_BODY:" "workflow passes PR body into canonical quality gate"
assert_file_contains "${WORKFLOW}" "SFS_PR_BASE_SHA:" "workflow passes PR diff base into canonical quality gate"
assert_file_contains "${WORKFLOW}" "SFS_PR_HEAD_SHA:" "workflow passes PR diff head into canonical quality gate"
if grep -Fq 'sfs-pr-review-flow-check.sh --root .' "${WORKFLOW}"; then
  fail "workflow must not bypass the canonical quality gate with a direct review-flow step"
fi
assert_file_contains "${WORKFLOW}" "templates/**" "workflow covers templates"
assert_file_contains "${WORKFLOW}" "docs/**" "workflow covers docs"
assert_file_contains "${WORKFLOW}" "install.sh" "workflow covers root installer"
assert_file_contains "${WORKFLOW}" "AGENTS.md" "workflow covers root agent docs"
assert_file_contains "${WORKFLOW}" "fetch-depth: 0" "workflow fetches diff history"

echo "test-pr-review-flow-check: OK"
