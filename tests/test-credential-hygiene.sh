#!/usr/bin/env bash
# BLOG-2026-06-11-1 credential hygiene + scheduled-run contract — headline test.
#
# Locks: the credential-hygiene policy exists (placeholder-only surfaces /
# boundary attachment with per-consumer scope / single-point rotation /
# unattended-runner env-at-spawn), is routed from _INDEX, and the
# work-delegation policy gains the SCHEDULED_RUN_CONTRACT (fresh session per
# fire, file-borne state, four operational controls, credential indirection).
# Additive-only: pre-existing work-delegation anchors stay. ASCII anchors only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/credential-hygiene.md"
DELEG="${CTX}/policies/work-delegation-and-startup.md"
INDEX="${CTX}/_INDEX.md"
KO="${DIST_DIR}/docs/ko/current-product-shape/26-delegation-repertoire.md"
EN="${DIST_DIR}/docs/en/current-product-shape/26-delegation-repertoire.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# 1) credential-hygiene policy exists with the four section anchors.
[[ -f "${POLICY}" ]] || fail "missing policy: ${POLICY}"
has "${POLICY}" "id: sfs-policy-credential-hygiene" "policy frontmatter id"
has "${POLICY}" "PLACEHOLDER_ONLY_SURFACES" "placeholder-only section anchor"
has "${POLICY}" "BOUNDARY_ATTACHMENT" "boundary-attachment section anchor"
has "${POLICY}" "ROTATION_SINGLE_POINT" "rotation section anchor"
has "${POLICY}" "UNATTENDED_AND_SCHEDULED_RUNS" "unattended-runs section anchor"
has "${POLICY}" "by-reference" "vendor source cited by-reference"
has "${POLICY}" "agentic-security-logging-pack.md" "cross-link to security pack"

# 2) line budget: policy stays under the 200-line loadable ceiling.
lines="$(wc -l < "${POLICY}")"
[[ "${lines}" -lt 200 ]] || fail "policy exceeds 200-line budget (${lines})"

# 3) _INDEX routes the new policy.
has "${INDEX}" "policies/credential-hygiene.md" "_INDEX route for credential-hygiene"

# 4) work-delegation gains the scheduled-run contract (additive).
has "${DELEG}" "SCHEDULED_RUN_CONTRACT" "scheduled-run contract anchor"
has "${DELEG}" "fresh session" "fresh-session-per-fire rule"
has "${DELEG}" "on-demand trigger" "four operational controls"
has "${DELEG}" "credential-hygiene.md" "delegation cross-links credential policy"
# pre-existing anchors preserved (additive guarantee).
has "${DELEG}" "RUNTIME_SELECTION" "pre-existing runtime anchor preserved"
has "${DELEG}" "LONG_RUNNING_AND_SCHEDULED" "pre-existing scheduled-axis anchor preserved"
has "${DELEG}" "DELEGATE_FIVE_FACTORS" "pre-existing five-factor anchor preserved"

# 5) bilingual repertoire docs carry the externally-validated example pointer.
for f in "${KO}" "${EN}"; do
  [[ -f "${f}" ]] || fail "missing repertoire doc: ${f}"
  has "${f}" "SCHEDULED_RUN_CONTRACT" "repertoire links scheduled contract in ${f}"
  has "${f}" "New in Claude Managed Agents" "repertoire by-reference source in ${f}"
done

echo "PASS"
