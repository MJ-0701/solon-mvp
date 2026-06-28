#!/usr/bin/env bash
# BLOG-2026-06-26-1 building effective human-agent teams — WU-1 headline test.
#
# Locks the four generalized lessons promoted into routed context (vendor
# specifics held out by-reference):
#   (a) roster-as-artifact — each agent's owns/scope/tools is an explicit
#       declared surface (harness-autonomy);
#   (b) north star — operator-documented ambitious goal + which agents hold
#       proactive-proposal authority, gated behind trust (work-delegation +
#       operator-context placeholders);
#   (c) verifiability is the precondition for expanding autonomy (doer-verifier
#       extended in harness-autonomy; weekly "lessons and missteps" report
#       mapped to the curation pass by-reference);
#   (d) human attention is a scarce resource — question batching, key-context
#       repetition, one-time-exposure limit, workload guardrail (work-delegation).
# Additive-only: pre-existing anchors of every touched policy stay. ASCII anchors.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
HARNESS="${CTX}/policies/harness-autonomy.md"
DELEG="${CTX}/policies/work-delegation-and-startup.md"
LESSONS="${CTX}/policies/lessons-accumulation.md"
OPCTX="${DIST_DIR}/templates/.sfs-local-template/operator-context.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has()  { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
absent() { grep -Fq -- "$2" "$1" && fail "$3: vendor leak '$2'" || true; }

# (a) roster-as-artifact in harness-autonomy.
[[ -f "${HARNESS}" ]] || fail "missing policy: ${HARNESS}"
has "${HARNESS}" "Team roster is an explicit artifact" "roster-as-artifact anchor"
has "${HARNESS}" "owns/scope/tools" "roster declares owns/scope/tools"
has "${HARNESS}" "side personal AI" "role-unspecified fragmentation motive (by-reference)"
# (c) verification-precedes-autonomy extends the verifier!=implementer invariant.
has "${HARNESS}" "verification capability is the precondition" "verification-precedes-autonomy anchor"
has "${HARNESS}" "Verifier != implementer" "pre-existing verifier invariant preserved"
has "${HARNESS}" "advisor-Code file bus" "pre-existing advisor-Code bus anchor preserved"

# (b) north star + (d) human attention in work-delegation.
[[ -f "${DELEG}" ]] || fail "missing policy: ${DELEG}"
has "${DELEG}" "NORTH_STAR" "north-star section anchor"
has "${DELEG}" "proactive" "proactive-proposal authority named"
has "${DELEG}" "harness-autonomy.md" "north-star proactivity gated on verification trust (cross-ref)"
has "${DELEG}" "HUMAN_ATTENTION_IS_SCARCE" "human-attention section anchor"
has "${DELEG}" "batch" "question-batching discipline"
# pre-existing anchors preserved (additive guarantee).
has "${DELEG}" "DELEGATE_FIVE_FACTORS" "pre-existing five-factor anchor preserved"
has "${DELEG}" "RESTATE_AND_CLARIFY" "pre-existing restate anchor preserved"
has "${DELEG}" "SCHEDULED_RUN_CONTRACT" "pre-existing scheduled-run anchor preserved"

# (b) operator-context placeholders for north star + proactive agents.
[[ -f "${OPCTX}" ]] || fail "missing operator-context: ${OPCTX}"
has "${OPCTX}" "<OPERATOR-NORTH-STAR>" "north-star placeholder"
has "${OPCTX}" "<OPERATOR-PROACTIVE-AGENTS>" "proactive-proposal opt-in placeholder"

# (c) weekly lessons & missteps report mapped to curation pass (by-reference).
has "${LESSONS}" "lessons and missteps" "weekly lessons-and-missteps report anchor"
has "${LESSONS}" "CURATION_PASS" "pre-existing curation-pass anchor preserved"

# by-reference discipline + vendor hygiene on every touched policy.
has "${HARNESS}" "by-reference" "harness cites source by-reference"
for f in "${HARNESS}" "${DELEG}" "${LESSONS}"; do
  absent "${f}" "Slack" "${f}"
  absent "${f}" "Claude Tag" "${f}"
  absent "${f}" "Enterprise RBAC" "${f}"
done

# load_when triggers added on modified policies so the router fires new content.
has "${HARNESS}" "team roster" "harness load_when trigger for roster"
has "${DELEG}" "north star" "delegation load_when trigger for north star"

# line budget: every touched loadable md stays under the 200-line ceiling.
for f in "${HARNESS}" "${DELEG}" "${LESSONS}"; do
  n="$(wc -l < "${f}")"
  [[ "${n}" -lt 200 ]] || fail "exceeds 200-line budget (${n}): ${f}"
done

# _INDEX already routes the touched policies (colocation — routes unbroken).
has "${INDEX}" "policies/harness-autonomy.md" "_INDEX route for harness-autonomy"
has "${INDEX}" "policies/work-delegation-and-startup.md" "_INDEX route for work-delegation"
has "${INDEX}" "policies/lessons-accumulation.md" "_INDEX route for lessons-accumulation"

echo "PASS: test-human-agent-team-roster.sh"
