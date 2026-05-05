#!/usr/bin/env bash
# tests/test-workflow-permissions.sh — AC13 workflow permissions hardening.
#
# Each .github/workflows/*.yml must declare an explicit permissions block
# with at minimum `contents: read`.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WF_DIR="${DIST_DIR}/.github/workflows"

[[ -d "${WF_DIR}" ]] || { echo "AC13 FAIL: workflows dir missing: ${WF_DIR}"; exit 1; }

fail=0
for wf in "${WF_DIR}"/*.yml; do
  [[ -f "${wf}" ]] || continue
  if ! grep -qE "^permissions:" "${wf}"; then
    echo "AC13 FAIL: ${wf} missing top-level 'permissions:' block"
    fail=$((fail + 1))
    continue
  fi
  # contents: read 가 어디에든 등장해야 (top-level 또는 job-level minimum).
  if ! grep -qE "^[[:space:]]*contents:[[:space:]]*read" "${wf}"; then
    echo "AC13 FAIL: ${wf} 'permissions:' block missing 'contents: read'"
    fail=$((fail + 1))
  fi
done

if [[ "${fail}" -gt 0 ]]; then exit 1; fi
echo "test-workflow-permissions: OK ($(ls "${WF_DIR}"/*.yml 2>/dev/null | wc -l | tr -d ' ') workflows checked)"
