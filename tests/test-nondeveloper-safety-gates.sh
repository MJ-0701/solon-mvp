#!/usr/bin/env bash
# BWU-10: nondeveloper published-output safety gates are visible in Gate 6.
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

review="${CONTEXT_DIR}/commands/review.md"
flowcheck="${CONTEXT_DIR}/commands/flowcheck.md"
security="${CONTEXT_DIR}/policies/agentic-security-logging-pack.md"
security_ko="${CONTEXT_DIR}/policies/agentic-security-logging-pack.ko.md"
data="${CONTEXT_DIR}/policies/gate6-data-validation-pack.md"
data_ko="${CONTEXT_DIR}/policies/gate6-data-validation-pack.ko.md"

for file in "${review}" "${flowcheck}" "${data}" "${data_ko}"; do
  assert_contains "${file}" "structure" "structure gate ${file}"
  assert_contains "${file}" "security" "security gate ${file}"
  assert_contains "${file}" "UX" "UX gate ${file}"
  assert_contains "${file}" "refactor" "refactor gate ${file}"
done

assert_contains "${security}" "SEC-AIERA-007" "EN security lens"
assert_contains "${security}" "critical-blocking" "EN security critical block"
assert_contains "${security_ko}" "SEC-AIERA-007" "KO security lens"
assert_contains "${security_ko}" "critical-blocking" "KO security critical block"

echo "test-nondeveloper-safety-gates: OK"
