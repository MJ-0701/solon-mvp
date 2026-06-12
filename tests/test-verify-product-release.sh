#!/usr/bin/env bash
# scripts/verify-product-release.sh — in-repo post-publish verifier contract.
#
# Replaces tests/test-release-verifier-quiet-smokes.sh, which targeted an
# owner-side release script outside this tree and therefore permanently
# SKIP-passed (dead test). The verifier is now shipped in-repo; this test
# locks its contract: local-evidence-only checks, env-overridable channel
# clone paths, and a failing exit on a version that was never cut.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERIFY="${DIST_DIR}/scripts/verify-product-release.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

[[ -f "${VERIFY}" ]] || fail "missing scripts/verify-product-release.sh"
[[ -x "${VERIFY}" ]] || fail "verify-product-release.sh must be executable"
bash -n "${VERIFY}" || fail "not valid bash"

# contract anchors: local evidence only, env-overridable clones, marker loop.
has "${VERIFY}" "no network calls" "local-evidence-only contract"
has "${VERIFY}" "SFS_HOMEBREW_CLONE" "homebrew clone env override"
has "${VERIFY}" "SFS_SCOOP_CLONE" "scoop clone env override"
has "${VERIFY}" "release-state/" "release-state markers checked"
for marker in tag-push audit tap-update post-audit; do
  has "${VERIFY}" "${marker}" "phase marker ${marker} covered"
done

# usage: --help exits 0; missing --version exits 2.
"${VERIFY}" --help >/dev/null || fail "--help must exit 0"
rc=0; "${VERIFY}" >/dev/null 2>&1 || rc=$?
[[ "${rc}" -eq 2 ]] || fail "missing --version must exit 2 (got ${rc})"

# a version that was never cut must FAIL with nonzero exit.
rc=0
out="$("${VERIFY}" --version 9.9.9 2>&1)" || rc=$?
[[ "${rc}" -eq 1 ]] || fail "uncut version must exit 1 (got ${rc})"
printf '%s\n' "${out}" | grep -q "^FAIL" || fail "uncut version must print FAIL lines"
printf '%s\n' "${out}" | grep -q "verify-product-release: FAIL" || fail "summary FAIL line missing"

echo "test-verify-product-release: OK"
