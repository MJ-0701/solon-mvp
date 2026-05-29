#!/usr/bin/env bash
# Contract test for the bug-report-lifecycle policy (0.8.0).
# Locks that `sfs context cat policies/bug-report-lifecycle.md` resolves and
# carries the lifecycle states, report template, confirm gate, and routing.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

fail() { echo "FAIL: $*" >&2; exit 1; }

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-bug-lifecycle.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "bug-lifecycle@solon.invalid"
git config user.name "Solon Bug Lifecycle Test"
printf '# bug lifecycle\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context cat policies/bug-report-lifecycle.md 2>&1)" \
  || fail "context cat policies/bug-report-lifecycle.md failed: ${out}"

grep -q "detected → filed" <<<"${out}" || fail "missing lifecycle states"
grep -q "confirmed(user gate)" <<<"${out}" || fail "missing confirm gate state"
grep -q "증상" <<<"${out}" || fail "missing report template (증상)"
grep -q "근본 원인" <<<"${out}" || fail "missing report template (근본 원인)"
grep -q "dev-first" <<<"${out}" || fail "missing dev-first routing"
grep -q "hotfix" <<<"${out}" || fail "missing hotfix exception"
grep -q "MJ-0701/solon-product" <<<"${out}" || fail "missing official channel"

echo "PASS: test-bug-report-lifecycle-policy.sh"
