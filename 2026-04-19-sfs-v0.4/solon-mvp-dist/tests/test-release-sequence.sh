#!/usr/bin/env bash
# tests/test-release-sequence.sh — AC11 release sequence enforcement.
#
# Sequence rule (AC11):
#   1. git tag v0.6.0 → push to remote
#   2. brew audit (AC7.4) + scoop schema check (AC7.5)
#   3. tap repo formula/manifest update + push
#
# Out-of-order invocation must exit non-zero.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-release-sequence.sh"

[[ -x "${SCRIPT}" ]] || { echo "missing: ${SCRIPT}" >&2; exit 1; }

# Use a per-test mktemp state-dir so prior test runs don't pollute the order check.
tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
STATE="${tmp}/release-state"

# Phase out-of-order — running phase 3 before phase 1 must fail.
if bash "${SCRIPT}" --phase tap-update --version 0.6.0 --dry-run --state-dir "${STATE}" 2>/dev/null; then
  echo "AC11 FAIL: tap-update without preceding tag-push should fail"
  exit 1
fi

# Phase 1 dry-run OK.
bash "${SCRIPT}" --phase tag-push --version 0.6.0 --dry-run --state-dir "${STATE}" >/dev/null

# After phase 1 marker in place, phase 2 dry-run OK.
bash "${SCRIPT}" --phase audit --version 0.6.0 --dry-run --state-dir "${STATE}" >/dev/null

# After phase 2, phase 3 dry-run OK (uses same state-dir).
bash "${SCRIPT}" --phase tap-update --version 0.6.0 --dry-run --state-dir "${STATE}" >/dev/null

echo "test-release-sequence: OK"
