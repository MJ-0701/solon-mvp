#!/usr/bin/env bash
# Contract test for the `report-bug` routed command (0.8.0).
# Locks that `sfs context cat commands/report-bug` resolves and carries the
# official-channel + confirm-gate + dev-first|hotfix routing contract.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

fail() { echo "FAIL: $*" >&2; exit 1; }

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-report-bug.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "report-bug@solon.invalid"
git config user.name "Solon Report Bug Test"
printf '# report-bug\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context cat commands/report-bug 2>&1)" \
  || fail "context cat commands/report-bug failed: ${out}"
# bare key resolves too
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context cat report-bug >/dev/null 2>&1 \
  || fail "bare 'report-bug' context key did not resolve"

grep -q "MJ-0701/solon-product" <<<"${out}" || fail "missing official channel repo"
grep -q "label \`bug\`" <<<"${out}" || fail "missing bug label"
grep -q "confirm gate" <<<"${out}" || fail "missing confirm gate"
grep -q "dev-first" <<<"${out}" || fail "missing dev-first routing"
grep -q "hotfix" <<<"${out}" || fail "missing hotfix exception"
grep -q "consumer" <<<"${out}" || fail "missing consumer vs product distinction"

echo "PASS: test-context-report-bug-command.sh"
