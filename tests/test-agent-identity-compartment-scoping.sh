#!/usr/bin/env bash
# BLOG-2026-06-26-2 agent identity / new access model — WU-2 headline test.
#
# Locks the generalized principles promoted into routed context (vendor
# specifics — product/channel UI, Enterprise RBAC, JIT roadmap — held out
# by-reference):
#   (a) agent-as-itself (service account) + revoke-by-identity, framed as
#       external validation of credential boundary attachment / single-point
#       rotation, same principle as runtime-token-firewall per-consumer isolation
#       (credential-hygiene);
#   (b) per-compartment scoping — permissions belong to the work boundary
#       (compartment) not the user; baseline inherited + per-boundary override;
#       cross-boundary access and memory do not leak (user-context-separation);
#   (c) audit-driven grant lifecycle — start broad, read the audit trail, pare
#       to one justified grant at a time; solon events.jsonl/tool_call telemetry
#       is the audit source (credential-hygiene).
# Additive-only: pre-existing anchors of every touched policy stay. ASCII anchors.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
CRED="${CTX}/policies/credential-hygiene.md"
UCS="${CTX}/policies/user-context-separation.md"
ORCH="${CTX}/policies/external-orchestrator-entry.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has()  { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
absent() { grep -Fq -- "$2" "$1" && fail "$3: vendor leak '$2'" || true; }

# (a) agent-as-itself + revoke-by-identity in credential-hygiene.
[[ -f "${CRED}" ]] || fail "missing policy: ${CRED}"
has "${CRED}" "AGENT_IDENTITY" "agent-identity section anchor"
has "${CRED}" "acts as itself" "agent-as-itself (service account) framing"
has "${CRED}" "service account" "service-account term"
has "${CRED}" "revoke" "revoke-by-identity ends all access"
has "${CRED}" "runtime-token-firewall.md" "same-principle cross-link to token firewall"
# (c) audit-driven grant lifecycle in credential-hygiene.
has "${CRED}" "GRANT_LIFECYCLE" "grant-lifecycle section anchor"
has "${CRED}" "audit" "audit-driven paring"
has "${CRED}" "events.jsonl" "solon audit source named"
# pre-existing anchors preserved (additive guarantee).
has "${CRED}" "BOUNDARY_ATTACHMENT" "pre-existing boundary-attachment anchor preserved"
has "${CRED}" "ROTATION_SINGLE_POINT" "pre-existing rotation anchor preserved"
has "${CRED}" "PLACEHOLDER_ONLY_SURFACES" "pre-existing placeholder anchor preserved"

# (b) per-compartment scoping + cross-boundary memory non-leak in user-context.
[[ -f "${UCS}" ]] || fail "missing policy: ${UCS}"
has "${UCS}" "COMPARTMENT_SCOPING" "compartment-scoping section anchor"
has "${UCS}" "compartment" "compartment (work boundary) term"
has "${UCS}" "baseline" "baseline inherited + per-boundary override"
has "${UCS}" "does not leak" "cross-boundary memory non-leak rule"
# pre-existing anchors preserved.
has "${UCS}" "THREE_LAYERS" "pre-existing three-layers anchor preserved"
has "${UCS}" "TEMPLATE_DISCIPLINE" "pre-existing template-discipline anchor preserved"

# external-orchestrator-entry carries a compartment cross-ref (kept thin).
has "${ORCH}" "compartment" "orchestrator cross-ref to compartment scoping"
has "${ORCH}" "First-permission read-only" "pre-existing first-permission anchor preserved"

# by-reference discipline + vendor hygiene on every touched policy.
has "${CRED}" "by-reference" "credential policy cites source by-reference"
has "${UCS}" "by-reference" "user-context policy cites source by-reference"
for f in "${CRED}" "${UCS}" "${ORCH}"; do
  absent "${f}" "Slack" "${f}"
  absent "${f}" "Claude Tag" "${f}"
  absent "${f}" "GitHub App" "${f}"
  absent "${f}" "Enterprise RBAC" "${f}"
done

# load_when triggers added so the router fires the new content.
has "${CRED}" "agent identity" "credential load_when trigger for agent identity"
has "${UCS}" "compartment" "user-context load_when trigger for compartment"

# line budget: every touched loadable md stays under the 200-line ceiling.
for f in "${CRED}" "${UCS}" "${ORCH}"; do
  n="$(wc -l < "${f}")"
  [[ "${n}" -lt 200 ]] || fail "exceeds 200-line budget (${n}): ${f}"
done

# _INDEX routes the touched policies (colocation — routes unbroken).
has "${INDEX}" "policies/credential-hygiene.md" "_INDEX route for credential-hygiene"
has "${INDEX}" "policies/user-context-separation.md" "_INDEX route for user-context-separation"
has "${INDEX}" "policies/external-orchestrator-entry.md" "_INDEX route for external-orchestrator-entry"

echo "PASS: test-agent-identity-compartment-scoping.sh"
