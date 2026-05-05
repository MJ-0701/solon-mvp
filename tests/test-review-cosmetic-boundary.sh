#!/usr/bin/env bash
# tests/test-review-cosmetic-boundary.sh — R-E cosmetic exclusion must not hide contract-surface renames.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CPO="${DIST_DIR}/templates/.sfs-local-template/personas/cpo-evaluator.md"
REVIEW="${DIST_DIR}/templates/.sfs-local-template/context/commands/review.md"

[[ -f "${CPO}" ]] || { echo "missing: ${CPO}" >&2; exit 1; }
[[ -f "${REVIEW}" ]] || { echo "missing: ${REVIEW}" >&2; exit 1; }

assert_contains() {
  local file="$1" pattern="$2" label="$3"
  if ! grep -qiE "${pattern}" "${file}"; then
    echo "FAIL: ${label} missing from ${file}" >&2
    exit 1
  fi
}

for file in "${CPO}" "${REVIEW}"; do
  assert_contains "${file}" 'public APIs?' "public API boundary"
  assert_contains "${file}" 'CLI[[:space:]]+flags' "CLI flag boundary"
  assert_contains "${file}" 'domain ubiquitous terms' "domain ubiquitous term boundary"
  assert_contains "${file}" 'in-scope' "contract renames in-scope wording"
done

echo "test-review-cosmetic-boundary: OK"
