#!/usr/bin/env bash
# INSIGHT-2026-07-12 (finding your unknowns) — headline.
#
# Locks the map-vs-territory unknowns loop, all additive by-reference:
#   1. UNKNOWNS_QUADRANT + BLIND_SPOT_PASS as a plan preflight (policy +
#      plan.md pointer + methodology-7-step pointer)
#   2. DEVIATIONS_LOG — conservative choice + record + continue during
#      implementation; capsule workers write deviations to output_paths;
#      recurring classes feed lessons (SIGNAL input registered in
#      lessons-accumulation + self-improvement-loop)
#   3. COMPREHENSION_GATE — post-implementation explainer/quiz as the
#      operator understanding check for HTML-encouraged user-facing docs;
#      signal-only, Gate 6 treats it as evidence not a block
# Vendor hygiene: model/product names appear nowhere in the new policy.
# Additive: pre-existing plan/review/capsule/lessons anchors preserved.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/unknowns-and-deviations.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

[[ -f "${POLICY}" ]] || fail "missing unknowns-and-deviations.md"
fhas "${POLICY}" "id: sfs-policy-unknowns-and-deviations" "frontmatter id"

# ── Touchpoint 1: unknowns quadrant + blind-spot pass at plan ────────
fhas "${POLICY}" "UNKNOWNS_QUADRANT" "quadrant anchor"
for q in known-knowns known-unknowns unknown-knowns unknown-unknowns; do
  fhas "${POLICY}" "${q}" "quadrant cell ${q}"
done
fhas "${POLICY}" "BLIND_SPOT_PASS" "blind-spot anchor"
fhas "${POLICY}" "territory" "map-vs-territory frame"
fhas "${POLICY}" "non-technical operators" "operator blind-spot emphasis"
fhas "${CTX}/commands/plan.md" "policies/unknowns-and-deviations.md" "plan.md preflight pointer"
fhas "${CTX}/commands/plan.md" "UNKNOWNS_QUADRANT" "plan.md quadrant anchor"
fhas "${CTX}/commands/plan.md" "BLIND_SPOT_PASS" "plan.md blind-spot anchor"
fhas "${DIST_DIR}/docs/maintenance/methodology-7-step.md" "unknowns-and-deviations.md" "methodology pointer"
fhas "${DIST_DIR}/docs/maintenance/methodology-7-step.md" "UNKNOWNS_QUADRANT" "methodology quadrant anchor"

# ── Touchpoint 2: deviations log ─────────────────────────────────────
fhas "${POLICY}" "DEVIATIONS_LOG" "deviations anchor"
fhas "${POLICY}" "conservative" "conservative-choice rule"
fhas "${POLICY}" "## Deviations" "workbench heading convention"
fhas "${CTX}/policies/sub-agent-capsule-contract.md" "DEVIATIONS_LOG" "capsule deviation convention"
fhas "${CTX}/policies/sub-agent-capsule-contract.md" "no silent improvisation" "capsule conservative rule"
fhas "${CTX}/policies/lessons-accumulation.md" "DEVIATIONS_LOG" "lessons signal source"
fhas "${CTX}/policies/self-improvement-loop.md" "plan-deviation log entries" "SIGNAL stage registration"

# ── Touchpoint 3: comprehension gate ─────────────────────────────────
fhas "${POLICY}" "COMPREHENSION_GATE" "comprehension anchor"
fhas "${POLICY}" "explainer" "explainer artifact"
fhas "${POLICY}" "quiz" "quiz artifact"
fhas "${POLICY}" "HTML-encouraged" "docs-strategy tie-in"
fhas "${POLICY}" "signal-only" "never-hard-block standing"
fhas "${CTX}/commands/review.md" "COMPREHENSION_GATE" "review.md gate-6 pointer"
fhas "${CTX}/commands/review.md" "## Deviations" "review.md deviation check"

# ── By-reference + vendor hygiene ────────────────────────────────────
fhas "${POLICY}" "by-reference" "insight cited by-reference"
if grep -Eiq 'fable|opus|sonnet|haiku|claude code|cowork' "${POLICY}"; then
  fail "vendor/model name leaked into unknowns-and-deviations.md"
fi

# ── Route + budgets ──────────────────────────────────────────────────
fhas "${CTX}/_INDEX.md" "policies/unknowns-and-deviations.md" "index route"
for f in "${POLICY}" "${CTX}/commands/plan.md" "${CTX}/commands/review.md" \
         "${CTX}/policies/lessons-accumulation.md" \
         "${CTX}/policies/sub-agent-capsule-contract.md" \
         "${CTX}/policies/self-improvement-loop.md"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

# ── Additive guarantee: pre-existing anchors survive ─────────────────
fhas "${CTX}/commands/plan.md" "policies/lessons-accumulation.md" "plan lessons consult preserved"
fhas "${CTX}/commands/review.md" "division_subagent_ledger" "review ledger anchor preserved"
fhas "${CTX}/policies/sub-agent-capsule-contract.md" "warn-before-block" "capsule warn-before-block preserved"
fhas "${CTX}/policies/sub-agent-capsule-contract.md" "exemplar" "capsule exemplar preserved"
fhas "${CTX}/policies/lessons-accumulation.md" "PRE_BUILD_AUDIT" "lessons pre-build audit preserved"
fhas "${CTX}/policies/lessons-accumulation.md" "CURATION_PASS" "lessons curation preserved"
fhas "${CTX}/policies/self-improvement-loop.md" "usage-value signal" "self-improvement usage signal preserved"

echo "PASS: unknowns-deviation loop locked (quadrant preflight / deviations log / comprehension gate)"
