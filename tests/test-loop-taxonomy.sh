#!/usr/bin/env bash
# BLOG-2026-07-02 getting started with loops — WU-1 headline test.
#
# Locks the loop-taxonomy decision lens promoted into routed context (vendor
# command surface held out by-reference):
#   (a) four loop types (TURN_BASED / GOAL_BASED / TIME_BASED / PROACTIVE)
#       declared once in policies/loop-taxonomy.md;
#   (b) trigger x stop decision frame (prompt/goal/interval/event x
#       judgment/criteria+turn-cap/cancel/goal-met) + minimum-complexity rule;
#   (c) each type mapped by-reference to an existing solon primitive —
#       default session / commands/loop.md AC loop / SCHEDULED_RUN_CONTRACT /
#       unattended runners + NORTH_STAR — no mechanics re-stated;
#   (d) secondary lessons route to existing anchors (HELD_OUT_SCORING,
#       CURATION_PASS, token-harness, model-workaround-sunset);
#   (e) vendor hygiene: no vendor slash-command or preview-feature name
#       promoted into the product surface.
# Additive-only: pre-existing anchors of every touched file stay. ASCII anchors.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
TAX="${CTX}/policies/loop-taxonomy.md"
LOOP="${CTX}/commands/loop.md"
DELEG="${CTX}/policies/work-delegation-and-startup.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has()  { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
absent() { grep -Fq -- "$2" "$1" && fail "$3: vendor leak '$2'" || true; }

# (a) the four loop types are declared once, in the taxonomy policy.
[[ -f "${TAX}" ]] || fail "missing policy: ${TAX}"
has "${TAX}" "TURN_BASED" "turn-based type anchor"
has "${TAX}" "GOAL_BASED" "goal-based type anchor"
has "${TAX}" "TIME_BASED" "time-based type anchor"
has "${TAX}" "PROACTIVE" "proactive type anchor"

# (b) trigger x stop decision frame + minimum-complexity selection rule.
has "${TAX}" "DECISION_FRAME" "decision-frame section anchor"
has "${TAX}" "Trigger axis" "trigger axis declared"
has "${TAX}" "Stop axis" "stop axis declared"
for term in "prompt" "goal" "interval" "event"; do
  has "${TAX}" "${term}" "trigger-axis value '${term}'"
done
for term in "human judgment" "criteria + turn-cap" "cancel" "goal-met"; do
  has "${TAX}" "${term}" "stop-axis value '${term}'"
done
has "${TAX}" "minimum-complexity" "minimum-complexity selection rule"
has "${TAX}" "Simplest loop first" "simplest-loop-first principle"

# (c) by-reference mapping to existing solon primitives (no second SSoT).
has "${TAX}" "commands/loop.md" "goal-based routes to the loop command rail"
has "${TAX}" "SCHEDULED_RUN_CONTRACT" "time-based routes to the scheduled-run contract"
has "${TAX}" "NORTH_STAR" "proactive routes to north-star proposal authority"
has "${TAX}" "acceptance_criteria" "goal-based stop = acceptance criteria"
has "${TAX}" "harness-autonomy.md" "escalation ladder owned by harness-autonomy"
has "${TAX}" "self-improvement-loop.md" "standing proactive loop cross-ref"
has "${TAX}" "by-reference" "policy declares by-reference discipline"

# (d) secondary lessons land on existing anchors, one line each.
has "${TAX}" "HELD_OUT_SCORING" "self-verify routes to held-out scoring"
has "${TAX}" "CURATION_PASS" "encode-failures routes to curation pass"
has "${TAX}" "token-harness.md" "script-offload routes to token-harness"
has "${TAX}" "MODEL_TAG_REQUIRED" "model-tier routing cites workaround sunset"

# (e) vendor hygiene: vendor command names / preview features not promoted.
# (backticked command form — the bare trigger-axis notation prompt/goal/... is
#  the taxonomy's own vocabulary, not a vendor command.)
for leak in '`/goal`' '`/schedule`' "auto mode" "research preview" "dynamic workflows"; do
  absent "${TAX}" "${leak}" "${TAX}"
  absent "${LOOP}" "${leak}" "${LOOP}"
done

# frontmatter: router fires the new policy on loop-choice questions.
has "${TAX}" "load_when" "taxonomy frontmatter load_when"
has "${TAX}" "loop taxonomy" "load_when trigger 'loop taxonomy'"

# backpointer: the loop command rail routes type selection to the taxonomy.
has "${LOOP}" "policies/loop-taxonomy.md" "loop.md backpointer to taxonomy"

# additive guarantee: pre-existing anchors of touched files preserved.
has "${LOOP}" "single-runner" "loop.md single-runner anchor preserved"
has "${LOOP}" "Ralph-grade" "loop.md Ralph-grade anchor preserved"
has "${LOOP}" "verifier != implementer" "loop.md verifier invariant preserved"
has "${DELEG}" "SCHEDULED_RUN_CONTRACT" "work-delegation scheduled-run anchor preserved"
has "${DELEG}" "NORTH_STAR" "work-delegation north-star anchor preserved"

# line budget: touched loadable md stays under the 200-line ceiling.
for f in "${TAX}" "${LOOP}"; do
  n="$(wc -l < "${f}")"
  [[ "${n}" -lt 200 ]] || fail "exceeds 200-line budget (${n}): ${f}"
done

# _INDEX routes the new policy (colocation — routes unbroken).
has "${INDEX}" "policies/loop-taxonomy.md" "_INDEX route for loop-taxonomy"
has "${INDEX}" "commands/loop.md" "_INDEX route for loop command preserved"

echo "PASS: test-loop-taxonomy.sh"
