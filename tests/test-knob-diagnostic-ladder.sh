#!/usr/bin/env bash
# INSIGHT-2026-07-12 (choosing model and effort level) — headline.
#
# Locks the knob diagnostic ladder, additive by-reference:
#   - two knobs, two failure modes: model tier = capability range,
#     effort = thoroughness; discriminating question "didn't know (model)
#     vs didn't look (effort)"
#   - escalation order on failure: context/skills -> effort up -> model
#     tier up (inverting the order buys cost without fixing the cause)
#   - downshift discipline: routine judgment-free stretches route to a
#     smaller tier; sustained success is the downshift signal, consumed by
#     existing capsule routing (no new mechanism)
# Vendor hygiene: model names / effort-UI specifics locked out of the
# policy file. Additive: pre-existing token-harness anchors preserved.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/token-harness.md"
METHOD="${DIST_DIR}/docs/maintenance/methodology-7-step.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── Ladder anchors ───────────────────────────────────────────────────
fhas "${POLICY}" "KNOB_DIAGNOSTIC_LADDER" "ladder anchor"
fhas "${POLICY}" "capability range" "model-knob meaning"
fhas "${POLICY}" "how thoroughly it works" "effort-knob meaning"
fhas "${POLICY}" "Escalation order on failure" "escalation order anchor"
fhas "${POLICY}" "check context/skills first" "context-first rung"
fhas "${POLICY}" "only" "effort-before-model ordering"
fhas "${POLICY}" "Inverting the order buys cost" "inversion warning"
fhas "${POLICY}" "Downshift discipline" "downshift anchor"
fhas "${POLICY}" "sustained success" "downshift signal"
fhas "${POLICY}" "unknowns-and-deviations.md" "map-vs-territory cross-ref"
fhas "${POLICY}" "runtime-token-firewall.md" "capsule-routing cross-ref"

# ── Pointers ─────────────────────────────────────────────────────────
fhas "${METHOD}" "KNOB_DIAGNOSTIC_LADDER" "methodology pointer anchor"
LC_ALL=C grep -q "몰라서 틀렸나" "${METHOD}" || fail "methodology: missing discriminating question ko"
fhas "${CTX}/_INDEX.md" "KNOB_DIAGNOSTIC_LADDER" "index route mentions ladder"

# ── By-reference + vendor hygiene ────────────────────────────────────
fhas "${POLICY}" "by-reference" "insight cited by-reference"
if grep -Eiq 'fable|opus|sonnet|haiku' "${POLICY}"; then
  fail "vendor model name leaked into token-harness.md"
fi

# ── Budgets ──────────────────────────────────────────────────────────
for f in "${POLICY}" "${METHOD}"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

# ── Additive guarantee ───────────────────────────────────────────────
fhas "${POLICY}" "CACHE_AWARE_PROMPT_LAYOUT" "cache layout preserved"
fhas "${POLICY}" "Cache-prefix discipline" "cache-prefix section preserved"
fhas "${POLICY}" "Runtime Token Firewall" "firewall rule preserved"
fhas "${METHOD}" "Model-tier quick reference" "methodology model-tier section preserved"
fhas "${METHOD}" "UNKNOWNS_QUADRANT" "methodology unknowns pointer preserved"

echo "PASS: knob diagnostic ladder locked (context -> effort -> model, downshift mirror)"
