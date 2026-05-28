#!/usr/bin/env bash
# Owner-side MD split queue audit helper contract.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DIST_DIR}/.." && pwd)"
SCRIPT="${REPO_ROOT}/scripts/md-split-audit.sh"

if [[ ! -f "${SCRIPT}" ]]; then
  echo "test-md-split-audit: SKIP (owner md split audit helper is not packaged in this tree)"
  exit 0
fi

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains_text() {
  local text="$1"
  local needle="$2"
  local label="$3"

  case "${text}" in
    *"${needle}"*) ;;
    *) fail "${label}: missing '${needle}' in output" ;;
  esac
}

assert_contains_file() {
  local file="$1"
  local needle="$2"
  local label="$3"

  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

bash -n "${SCRIPT}"
assert_contains_file "${SCRIPT}" "This helper is read-only" "read-only contract"
assert_contains_file "${SCRIPT}" "does not split, rewrite, move, or delete files" "no mutation contract"

out="$(bash "${SCRIPT}" --root "${REPO_ROOT}" --threshold 400 --limit 5)"
assert_contains_text "${out}" "# MD split audit" "audit header"
assert_contains_text "${out}" "threshold=400" "audit threshold"
assert_contains_text "${out}" 'CHANGELOG.md' "top oversized doc"

set +e
bad="$(bash "${SCRIPT}" --threshold nope 2>&1)"
bad_rc=$?
set -e
[[ "${bad_rc}" -eq 1 ]] || fail "invalid threshold should exit 1, got ${bad_rc}"
assert_contains_text "${bad}" "invalid --threshold" "invalid threshold error"

echo "test-md-split-audit: OK"
