#!/usr/bin/env bash
# tests/run-all.sh — R-D AC4.1 entry point. Runs every tests/test-*.sh and reports.
#
# Each test script:
#   - exit 0 = PASS
#   - non-zero = FAIL (record reason from stderr)
# This harness aggregates exit codes, prints summary, exits non-zero on any FAIL.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

pass=0
fail=0
failed_tests=()

for t in test-*.sh; do
  [[ -f "${t}" ]] || continue
  printf '\n=== %s ===\n' "${t}"
  if bash "${t}"; then
    pass=$((pass + 1))
    printf '  PASS\n'
  else
    fail=$((fail + 1))
    failed_tests+=("${t}")
    printf '  FAIL\n'
  fi
done

printf '\n--- run-all summary ---\n'
printf '  PASS: %d\n' "${pass}"
printf '  FAIL: %d\n' "${fail}"
if [[ "${#failed_tests[@]}" -gt 0 ]]; then
  printf '  Failed scripts:\n'
  for t in "${failed_tests[@]}"; do
    printf '    - %s\n' "${t}"
  done
  exit 1
fi
exit 0
