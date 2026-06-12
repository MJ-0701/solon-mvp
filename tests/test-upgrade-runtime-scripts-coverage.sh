#!/usr/bin/env bash
# AUDIT-2026-06-12 hardening — headline test.
#
# Locks the audit-pass fixes:
#   (a) upgrade.sh enumerates runtime adapter scripts DYNAMICALLY
#       (list_managed_script_rels) in both the preview CHECK_FILES list and
#       the apply loop — the hard-coded 19-of-27 list silently skipped 8
#       adapters (capture/event/flowcheck/ingest/profile/recall/report-bug/
#       tidy) on every vendored upgrade;
#   (b) release-path guidance is post-R-D1: AGENTS.md and release-policy.md
#       describe the in-repo cut, release-sequence points at the manual
#       channel publish + shipped verify-product-release.sh;
#   (c) routed-context coherence: adapter-refactor routes workaround removal
#       through model-workaround-sunset; orchestrator gates cite
#       DECLARATIVE_BOUNDARY_SURFACE; continuation-guard cites the event-log
#       SSoT; agent-build review lens is routed from _INDEX.
# Korean greps are pinned LC_ALL=C per-grep.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
UPGRADE="${DIST_DIR}/upgrade.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# (a) dynamic runtime-script enumeration, no hard-coded adapter list left.
has "${UPGRADE}" "list_managed_script_rels()" "dynamic enumerator defined"
n="$(grep -c "list_managed_script_rels" "${UPGRADE}")"
[[ "${n}" -ge 3 ]] || fail "enumerator must be consumed by preview + apply (refs=${n})"
if grep -q 'update_file "\.sfs-local/scripts/sfs-' "${UPGRADE}"; then
  fail "hard-coded per-script update_file lines crept back into upgrade.sh"
fi
if grep -q '"\.sfs-local/scripts/sfs-.*|templates/' "${UPGRADE}"; then
  fail "hard-coded CHECK_FILES script entries crept back into upgrade.sh"
fi

# parity: the enumerator must see every template runtime adapter.
enum="$(mktemp "${TMPDIR:-/tmp}/enum.XXXXXX.sh")"
trap 'rm -f "${enum}"' EXIT
sed -n '/^list_managed_script_rels()/,/^}/p' "${UPGRADE}" > "${enum}"
listed="$(SOURCE_DIR="${DIST_DIR}" bash -c "source '${enum}'; SOURCE_DIR='${DIST_DIR}' list_managed_script_rels" | sort)"
actual="$(cd "${DIST_DIR}/templates/.sfs-local-template/scripts" && find . -type f \( -name '*.sh' -o -name '*.ps1' \) | sed 's#^\./##' | sort)"
[[ "${listed}" == "${actual}" ]] || fail "enumerator parity mismatch with templates scripts dir"
for adapter in sfs-capture.sh sfs-event.sh sfs-flowcheck.sh sfs-ingest.sh \
               sfs-profile.sh sfs-recall.sh sfs-report-bug.sh sfs-tidy.sh; do
  printf '%s\n' "${listed}" | grep -qx "${adapter}" \
    || fail "previously-skipped adapter not enumerated: ${adapter}"
done

# (b) post-R-D1 release guidance.
LC_ALL=C grep -q "본 repo 에는 cut tooling 없음" "${DIST_DIR}/AGENTS.md" \
  && fail "AGENTS.md still claims this repo has no cut tooling"
has "${DIST_DIR}/AGENTS.md" "sfs-release-sequence.sh" "AGENTS.md names in-repo cut sequence"
LC_ALL=C grep -q "R-D1 dev-first 는 2026-06-06 폐기" "${DIST_DIR}/docs/maintenance/release-policy.md" \
  || fail "release-policy must mark R-D1 deprecated with date"
has "${DIST_DIR}/docs/maintenance/release-policy.md" "verify-product-release.sh" "release-policy names the verifier"
has "${DIST_DIR}/scripts/sfs-release-sequence.sh" "verify-product-release.sh" "release-sequence points at verifier"
if grep -q "performed by scripts/cut-release.sh" "${DIST_DIR}/scripts/sfs-release-sequence.sh"; then
  fail "release-sequence still delegates tap-update to deprecated cut-release.sh"
fi
[[ -x "${DIST_DIR}/scripts/verify-product-release.sh" ]] || fail "verifier missing or not executable"

# (c) routed-context coherence fixes.
has "${CTX}/policies/agent-adapter-doc-refactor.md" "model-workaround-sunset.md" \
  "adapter-refactor routes workaround removal through sunset review"
has "${CTX}/policies/external-orchestrator-entry.md" "DECLARATIVE_BOUNDARY_SURFACE" \
  "orchestrator gates cite typed-surface enforcement"
has "${CTX}/policies/session-continuation-guard.md" "EVENT_LOG_RECONSTRUCTION_SSOT" \
  "continuation-guard cites event-ledger precedence"
has "${CTX}/_INDEX.md" "policies/agent-build-review-lens.md" "agent-build lens routed"
has "${CTX}/policies/review-lens-routing.md" "agent-build" "agent-build lens alias listed"
if head -5 "${CTX}/policies/context-pollution-guard.md" | grep -q '"token"'; then
  fail "context-pollution-guard load_when regressed to bare generic trigger"
fi

echo "test-upgrade-runtime-scripts-coverage: OK"
