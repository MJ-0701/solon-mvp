#!/usr/bin/env bash
# tests/test-bad-fixture.sh — AC2.6 + S2R2-N5 misformed fixtures must all FAIL validator.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-sprint-yml-validator.sh"
FIXTURE_DIR="${SCRIPT_DIR}/fixtures/bad-sprint-yml"

[[ -d "${FIXTURE_DIR}" ]] || { echo "fixtures missing: ${FIXTURE_DIR}" >&2; exit 1; }

failures=0
for f in "${FIXTURE_DIR}"/*.yml; do
  [[ -f "${f}" ]] || continue
  name="$(basename "${f}")"
  if bash "${SCRIPT}" --mode validate "${f}" >/dev/null 2>&1; then
    echo "BAD FIXTURE PASS UNEXPECTED: ${name} (validator should reject)" >&2
    failures=$((failures + 1))
  fi
done

if [[ "${failures}" -gt 0 ]]; then
  echo "test-bad-fixture: ${failures} fixtures incorrectly passed validator" >&2
  exit 1
fi
echo "test-bad-fixture: OK (all fixtures rejected as expected)"
