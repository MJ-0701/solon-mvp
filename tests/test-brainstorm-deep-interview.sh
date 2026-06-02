#!/usr/bin/env bash
# BWU-8: ambiguous app/product asks use deep-interview before plan readiness.
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

brainstorm="${CONTEXT_DIR}/commands/brainstorm.md"
policy="${CONTEXT_DIR}/policies/ai-work-intake-routing.md"

for file in "${brainstorm}" "${policy}"; do
  assert_contains "${file}" "Deep" "deep-interview section ${file}"
  assert_contains "${file}" "ambiguity <= 20%" "ambiguity target ${file}"
  assert_contains "${file}" "ㄱㄱ" "bare-go guard ${file}"
  assert_contains "${file}" "purpose" "purpose question ${file}"
  assert_contains "${file}" "must-have" "must-have question ${file}"
  assert_contains "${file}" "done" "completion bar ${file}"
done

echo "test-brainstorm-deep-interview: OK"
