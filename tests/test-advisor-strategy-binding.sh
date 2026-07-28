#!/usr/bin/env bash
# BLOG-2026-07-24-4 — advisor strategy as a first-class, configured binding.
#
# Locks ADVISOR_STRATEGY_BINDING (selective advisor coaching over a fast
# worker; call conditions are a data surface, cost compared per task) and its
# capsule-side consumer SUBAGENT_TIER_DEFAULT. The routing-evidence pair (task
# completion ratio x cost per task) is shared with the overnight-run insight,
# so this test also asserts it has exactly ONE owner and is referenced, not
# duplicated. Model class names, benchmark names, and figures are locked out of
# every file this insight touched.
#
# Host note: the team-topology design doc is the semantic home for this
# principle but sits at the 200-line ceiling with zero headroom, so the binding
# lives on the advisor-bus SSoT and cites the design doc's OCP rule instead.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
EOE="${POL}/external-orchestrator-entry.md"
CAP="${POL}/sub-agent-capsule-contract.md"
TH="${POL}/token-harness.md"
DESIGN="${DIST_DIR}/docs/maintenance/2026-06-23-multi-agent-team-topology.design.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }

# ── (a) anchors ─────────────────────────────────────────────────────
fanchor "${EOE}" "ADVISOR_STRATEGY_BINDING" "advisor-strategy anchor"
fanchor "${CAP}" "SUBAGENT_TIER_DEFAULT" "subagent tier default anchor"

# ── (b) the call conditions are a DATA surface, and all three exist ─
fhas "${EOE}" "call conditions are a data surface" "call conditions declared as data"
fhas "${EOE}" "agent_runtime_bindings" "conditions live beside the bindings surface"
fhas "${EOE}" "stuck" "condition: worker stuck"
fhas "${EOE}" "verification gate" "condition: verification gate"
fhas "${EOE}" "low-confidence" "condition: low-confidence slice"
fhas "${EOE}" "runs worker-only" "default outside the conditions"

# ── (c) the cost/quality binding, stated as measured not slogan ─────
fhas "${EOE}" "selectively" "selective coaching, not every step"
fhas "${EOE}" "much lower cost per" "cost/quality binding"
fhas "${EOE}" "per task**, not per token" "cost compared per task"
fhas "${EOE}" "a binding is data, not code" "cites the OCP rule"
fhas "${EOE}" "2026-06-23-multi-agent-team-topology.design.md" "cites the design doc by path"
[[ -f "${DESIGN}" ]] || fail "design doc referenced by the binding does not exist"

# ── (d) routing-evidence pair: exactly one owner, referenced elsewhere
fhas "${TH}" "task completion ratio" "routing metric 1 owned by token-harness"
fhas "${TH}" "cost per task" "routing metric 2 owned by token-harness"
fhas "${TH}" "Route from a record, not a feel" "routing-from-record rule"
owners=0
for f in "${POL}"/*.md "${CTX}"/commands/*.md; do
  grep -Fq "task completion ratio" "${f}" && owners=$((owners+1))
done
[[ "${owners}" -eq 1 ]] || fail "routing metric pair duplicated across ${owners} files (expected 1 owner)"
fhas "${EOE}" "KNOB_DIAGNOSTIC_LADDER" "advisor binding refs the ladder owner"
fhas "${EOE}" "SUBAGENT_TIER_DEFAULT" "advisor binding names its capsule consumer"
fhas "${CAP}" "ADVISOR_STRATEGY_BINDING" "capsule side refs the binding owner"
fhas "${CAP}" "a routing input, not" "tier is a routing input, not a capsule field"

# ── (e) start-smart-then-downshift stays a cross-ref, not a re-draft ─
fhas "${TH}" "Downshift discipline" "existing downshift mirror preserved"
fhas "${TH}" "MODEL_HEAD_TO_HEAD_ON_UPGRADE" "swap decision owner referenced"

# ── (f) routed index ────────────────────────────────────────────────
fanchor "${INDEX}" "ADVISOR_STRATEGY_BINDING" "index route: advisor strategy"
fanchor "${INDEX}" "SUBAGENT_TIER_DEFAULT" "index route: subagent tier"

# ── (g) additive guarantee ──────────────────────────────────────────
fhas "${EOE}" "Standalone guarantee" "standalone framing preserved"
fhas "${EOE}" "Inviolable gates" "gate section preserved"
fanchor "${CAP}" "LEAST_AGENCY_VERB_SCOPING" "capsule anchor preserved"
fanchor "${TH}" "KNOB_DIAGNOSTIC_LADDER" "token-harness anchor preserved"
fanchor "${TH}" "CACHE_AWARE_PROMPT_LAYOUT" "token-harness anchor preserved"

# ── (h) model-class / benchmark / figure lockout ────────────────────
# Scoped to the files this insight touched: class names appear legitimately in
# kernel.md and the plan/implement/review command rails as concrete routing
# guidance, and must not red-fail here.
for f in "${EOE}" "${CAP}" "${TH}" "${DESIGN}"; do
  if grep -Eiq '\b(mythos|fable|opus|sonnet|haiku)\b' "${f}"; then
    fail "$(basename "${f}"): model class name leaked into the promoted binding"
  fi
  if grep -Eiq 'swe-bench' "${f}"; then
    fail "$(basename "${f}"): benchmark name leaked"
  fi
  if grep -Eq '63%|within 10%' "${f}"; then
    fail "$(basename "${f}"): performance figure leaked"
  fi
done

# ── (i) line budget ─────────────────────────────────────────────────
for f in "${EOE}" "${CAP}" "${TH}" "${DESIGN}" "${INDEX}"; do
  lines="$(wc -l < "${f}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS: advisor strategy binding + subagent tier default locked"
