#!/usr/bin/env bash
# Contract test for the user-override-precedence policy (#3 guard, 0.8.0).
# Locks explicit-command supremacy, mandatory scope, and always-surface
# transitions (no silent auto-revert in either direction).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

fail() { echo "FAIL: $*" >&2; exit 1; }

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-override.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "override@solon.invalid"
git config user.name "Solon Override Test"
printf '# override\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context cat policies/user-override-precedence.md 2>&1)" \
  || fail "context cat policies/user-override-precedence.md failed: ${out}"

grep -q "explicit user command > SFS product default" <<<"${out}" || fail "missing precedence rule"
grep -q "inherited stored policy" <<<"${out}" || fail "missing inherited-stored advisory distinction"
grep -q "wu\` | \`sprint\` | \`until-revoked\`" <<<"${out}" || fail "missing scope enum"
grep -q "silent auto-revert 금지" <<<"${out}" || fail "missing no-silent-auto-revert rule"
grep -q "fcp-model-tier" <<<"${out}" || fail "missing FCP integration"

# the --scope flag is live on capture
cap_help="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" capture --help 2>&1 || true)"
grep -q -- "--scope" <<<"${cap_help}" || fail "capture --help missing --scope flag"

echo "PASS: test-context-user-override-precedence-policy.sh"
