#!/usr/bin/env bash
# BWU-9: Ralph-grade autonomy loop and verifier/implementer flowcheck lock.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"

fail() { echo "FAIL: $*" >&2; exit 1; }

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

loop="${CONTEXT_DIR}/commands/loop.md"
harness="${CONTEXT_DIR}/policies/harness-autonomy.md"
division="${CONTEXT_DIR}/policies/division-subagent-council.md"
flow="${CONTEXT_DIR}/policies/flow-conformance-postflight.md"
event="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-event.sh"
engine="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-flowcheck.sh"

assert_contains "${loop}" "Ralph-grade loop" "loop Ralph mode"
assert_contains "${loop}" "every story AC is PASS" "loop AC stop condition"
assert_contains "${loop}" "verifier != implementer" "loop verifier invariant"
assert_contains "${harness}" "Ralph-grade ends only when every story AC is PASS" "harness Ralph stop condition"
assert_contains "${division}" "verifier != implementer" "division verifier invariant"
assert_contains "${flow}" "fcp-verifier-implementer" "flowcheck verifier invariant"
assert_contains "${event}" "verification_pair" "event contract"
assert_contains "${engine}" "fcp-verifier-implementer" "engine invariant"

# WU-2: quantitative within-loop discard escalation ladder, distinct from the
# Ralph-grade AC-based loop-end condition. Policy + loop doc + command exposure.
loop_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-loop.sh"
assert_contains "${harness}" "refine" "harness discard ladder refine"
assert_contains "${harness}" "pivot" "harness discard ladder pivot"
assert_contains "${harness}" "halt" "harness discard ladder halt"
assert_contains "${harness}" "consecutive discarded" "harness discard counter"
assert_contains "${loop}" "resets the counter to 0" "loop keep-resets-counter"
assert_contains "${loop}" "refine@3 / pivot@5 / halt@8" "loop doc discard ladder"
assert_contains "${loop_script}" "refine@3 / pivot@5 / halt@8" "loop command exposes ladder"

# The ladder must surface through the reachable command help (노출 != 문서화).
help_out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${loop_script}" --help 2>&1 || true)"
grep -Fq -- "refine@3 / pivot@5 / halt@8" <<<"${help_out}" \
  || fail "loop --help must surface the discard ladder: ${help_out}"

echo "test-ralph-loop-flowcheck: OK"
