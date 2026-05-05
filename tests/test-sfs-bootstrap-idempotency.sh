#!/usr/bin/env bash
# tests/test-sfs-bootstrap-idempotency.sh — R-A AC-func-1 idempotency guard test.
#
# Default: existing target dir → exit 1 with stderr error.
# --force without --yes (non-tty stdin) → exit 1.
# --force --yes → overwrites + recreates project (exit 0).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-bootstrap.sh"

[[ -x "${SCRIPT}" ]] || { echo "missing: ${SCRIPT}" >&2; exit 1; }

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

cd "${tmp}"

# 1) First create — should succeed.
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental spring-kotlin myproject --quick
[[ -f myproject/build.gradle.kts ]] || { echo "FAIL: initial create did not produce build.gradle.kts" >&2; exit 1; }

# 2) Second call without --force → exit 1.
set +e
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental spring-kotlin myproject --quick 2>"${tmp}/err.log"
rc=$?
set -e
[[ "${rc}" == "1" ]] || { echo "FAIL: existing dir without --force should exit 1, got ${rc}" >&2; cat "${tmp}/err.log" >&2; exit 1; }
grep -q "already exists" "${tmp}/err.log" || { echo "FAIL: stderr should mention 'already exists'" >&2; cat "${tmp}/err.log" >&2; exit 1; }

# 3) --force without --yes in non-tty (stdin redirected from /dev/null) → exit 1.
set +e
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental spring-kotlin myproject --quick --force </dev/null 2>"${tmp}/err2.log"
rc=$?
set -e
[[ "${rc}" == "1" ]] || { echo "FAIL: --force without --yes in non-tty should exit 1, got ${rc}" >&2; cat "${tmp}/err2.log" >&2; exit 1; }

# 4) --force --yes → overwrites and recreates.
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental spring-kotlin myproject --quick --force --yes
[[ -f myproject/build.gradle.kts ]] || { echo "FAIL: --force --yes did not recreate build.gradle.kts" >&2; exit 1; }

# 5) --force --yes also handles a non-empty pre-existing dir (not just our own previous output).
mkdir -p stranger-files
echo "do not lose me" > stranger-files/important.txt
set +e
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental spring-kotlin stranger-files --quick 2>/dev/null
rc=$?
set -e
[[ "${rc}" == "1" ]] || { echo "FAIL: pre-existing non-bootstrap dir should also exit 1 without --force, got ${rc}" >&2; exit 1; }
[[ -f stranger-files/important.txt ]] || { echo "FAIL: existing user file should not be deleted on default refusal" >&2; exit 1; }

# --force --yes deliberately overwrites the stranger dir.
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental spring-kotlin stranger-files --quick --force --yes
[[ -f stranger-files/build.gradle.kts ]] || { echo "FAIL: --force --yes overwrite of non-bootstrap dir failed" >&2; exit 1; }
[[ ! -f stranger-files/important.txt ]] || { echo "FAIL: --force --yes should have removed pre-existing files (overwrite contract)" >&2; exit 1; }

echo "test-sfs-bootstrap-idempotency: OK"
