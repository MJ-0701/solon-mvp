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

echo "test-ralph-loop-flowcheck: OK"
