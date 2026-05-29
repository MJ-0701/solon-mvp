#!/usr/bin/env bash
# tests/run-all.sh per-category summary contract (0.7.7).
#
# 0.7.7 added a per-category breakdown to the run-all output without
# changing the existing flat summary. This test validates the
# categorize() classifier on a representative sample (one filename
# from each declared category) and confirms the run-all script is
# syntactically valid + executable.
#
# We deliberately do NOT spawn `bash run-all.sh` here — that would
# transitively re-run the entire suite and double the cost. The
# classifier is the unit of regression risk; running it standalone is
# sufficient.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
RUN_ALL="${SCRIPT_DIR}/run-all.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${RUN_ALL}" ]] || fail "missing tests/run-all.sh"
bash -n "${RUN_ALL}" || fail "run-all.sh is not syntactically valid bash"
[[ -x "${RUN_ALL}" ]] || fail "tests/run-all.sh must be executable"

# Extract the categorize function from run-all.sh and source it into
# the current shell so we can probe it directly.
classifier="$(mktemp "${TMPDIR:-/tmp}/categorize.XXXXXX.sh")"
trap 'rm -f "${classifier}"' EXIT
sed -n '/^categorize()/,/^}/p' "${RUN_ALL}" > "${classifier}"
# shellcheck source=/dev/null
source "${classifier}"

assert_category() {
  local filename="$1" expected="$2" actual
  actual="$(categorize "${filename}")"
  [[ "${actual}" == "${expected}" ]] \
    || fail "categorize ${filename}: expected '${expected}', got '${actual}'"
}

# ── 1) host-channel — the 0.7.0+ surface family ─────────────────────
assert_category test-host-channel-docs-coverage.sh         host-channel
assert_category test-mcp-server-contract.sh                host-channel
assert_category test-solon-safe-permissions-preset.sh      host-channel
assert_category test-agent-build-review-lens.sh            host-channel
assert_category test-claude-agent-sdk-zero-template.sh     host-channel
assert_category test-bootstrap-template-flag.sh            host-channel
assert_category test-install-completion-hints.sh           host-channel
assert_category test-harness-host-channel-surface.sh       host-channel
assert_category test-polluted-adapter-hygiene-notice.sh    host-channel

# ── 2) harness ──────────────────────────────────────────────────────
assert_category test-harness-engineering-guardrails.sh     harness
assert_category test-sfs-harness-command.sh                harness
assert_category test-obsidian-applied-project-harness.sh   harness

# ── 3) release ──────────────────────────────────────────────────────
assert_category test-version-release-headline.sh           release
assert_category test-docs-division-version-sync.sh         release
assert_category test-release-sequence.sh                   release
assert_category test-upgrade-freshness-summary.sh          release

# ── 4) packaging ────────────────────────────────────────────────────
assert_category test-packaging-channel-map.sh              packaging
assert_category test-homebrew-formula-style.sh             packaging
assert_category test-windows-wrapper-incident-report.sh    packaging

# ── 5) review ───────────────────────────────────────────────────────
assert_category test-review-auth-preflight.sh              review
assert_category test-sfs-review-closed-sprint-restore.sh   review
assert_category test-runtime-token-firewall.sh             review

# ── 6) doc-and-context ──────────────────────────────────────────────
assert_category test-agent-doc-refactor.sh                 doc-and-context
assert_category test-thin-agent-adapter-docs.sh            doc-and-context
assert_category test-context-aliases.sh                    doc-and-context
assert_category test-friendly-ux-contract.sh               doc-and-context

# ── 7) hygiene-and-policy ───────────────────────────────────────────
assert_category test-private-dev-path-hygiene.sh           hygiene-and-policy
assert_category test-no-data-loss.sh                       hygiene-and-policy
assert_category test-nounset-empty-array-expansion.sh      hygiene-and-policy
assert_category test-domain-knowledge-assets.sh            hygiene-and-policy

# ── 8) sfs-core — covers the bulk of test-sfs-*.sh and stragglers. ─
assert_category test-sfs-bootstrap-quick.sh                sfs-core
assert_category test-sfs-router-doc-refactor.sh            sfs-core
assert_category test-bad-fixture.sh                        sfs-core
assert_category test-cli-discovery-macos.sh                sfs-core

# ── 9) other — anything that falls through. ─────────────────────────
assert_category test-something-completely-unknown.sh       other

# ── 10) run-all script body contains the per-category summary header
#       so a future refactor that drops it gets caught. ──────────────
grep -qF 'by category:' "${RUN_ALL}" \
  || fail "run-all.sh must keep the 'by category:' header line"
grep -qF 'cat_keys' "${RUN_ALL}" \
  || fail "run-all.sh must keep the cat_keys parallel-array bookkeeping"

echo "test-run-all-categorization: OK"
