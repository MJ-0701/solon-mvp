#!/usr/bin/env bash
# Solon 고도화 후보가 wiki tooling 으로 제품 방향을 흐리지 않게 점검한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

brainstorm="${CONTEXT_DIR}/commands/brainstorm.md"
plan="${CONTEXT_DIR}/commands/plan.md"
review="${CONTEXT_DIR}/commands/review.md"
policy="${CONTEXT_DIR}/policies/obsidian-llm-wiki.md"
identity_test="${SCRIPT_DIR}/test-product-identity-wiki-boundary.sh"

assert_contains "${brainstorm}" "Advancement Scorecard" "brainstorm scorecard"
assert_contains "${brainstorm}" "product-core" "brainstorm product-core class"
assert_contains "${brainstorm}" "wiki-tooling-deferred" "brainstorm wiki tooling class"
assert_contains "${brainstorm}" "intent capture, plan contracts" "brainstorm SFS-loop signals"
assert_contains "${brainstorm}" "product judgment or source truth" "brainstorm no replacement"

assert_contains "${plan}" "carry the Solon Advancement Scorecard" "plan carries scorecard"
assert_contains "${plan}" "requirements/non-goals" "plan requirements and non-goals"
assert_contains "${plan}" "names the SFS-loop improvement" "plan product scope threshold"
assert_contains "${plan}" "defer it as wiki tooling" "plan defer tooling"

assert_contains "${review}" "Solon Advancement Scorecard proves" "review scorecard proof"
assert_contains "${review}" "not wiki volume" "review no volume-only pass"
assert_contains "${policy}" "pass the Solon Advancement Scorecard" "policy review question"
assert_contains "${policy}" "outside Solon product scope" "policy product scope boundary"

assert_contains "${identity_test}" "wiki 자체가 제품 방향" "identity test remains active"

echo "test-solon-advancement-scorecard: OK"
