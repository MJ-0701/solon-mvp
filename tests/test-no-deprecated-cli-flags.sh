#!/usr/bin/env bash
# tests/test-no-deprecated-cli-flags.sh
#
# 0.6.3 regression: 0.6.1 ship had `brew audit --new-formula` baked into
# `scripts/sfs-release-sequence.sh`, which Homebrew has since removed. The
# command exits with `Error: invalid option: --new-formula` and the audit
# phase fails for any user driving a real release.
#
# This test asserts deprecated external-CLI flags are not silently
# reintroduced into scripts/. CHANGELOG history is *intentionally* not
# scanned — historical release notes legitimately reference the old flag.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

# Forbidden patterns. Each entry: <pattern> | <human readable reason>.
forbidden=(
  '--new-formula|brew removed --new-formula; use --strict --online for tap audit, or --new only for Homebrew core submission'
)

scan_root="${DIST_DIR}/scripts"
[[ -d "${scan_root}" ]] || fail "scan root missing: ${scan_root}"

for entry in "${forbidden[@]}"; do
  pattern="${entry%%|*}"
  reason="${entry#*|}"
  hits=$(grep -rnF -- "${pattern}" "${scan_root}" 2>/dev/null || true)
  if [[ -n "${hits}" ]]; then
    fail "deprecated flag '${pattern}' reappeared in scripts/:
${hits}
  reason: ${reason}"
  fi
done

echo "test-no-deprecated-cli-flags: OK"
