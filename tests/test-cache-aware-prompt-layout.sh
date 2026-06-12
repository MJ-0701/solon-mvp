#!/usr/bin/env bash
# BLOG-2026-06-12-2 "Harnessing Claude's intelligence" absorption — headline.
#
# Locks the three promoted principles:
#   (a) token-harness gains CACHE_AWARE_PROMPT_LAYOUT (static-first/dynamic-
#       last, update-by-append, stable tool surface, one model per segment);
#   (b) model-workaround-sunset gains STOP_DOING_REVIEW (model upgrade asks
#       "what can the harness stop doing", handover verified not assumed);
#   (c) critical-rule-hook-promotion gains DECLARATIVE_BOUNDARY_SURFACE
#       (boundary actions get typed surfaces, not prose).
# Additive-only: pre-existing anchors in touched policies stay.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
TOKEN="${CTX}/policies/token-harness.md"
SUNSET="${CTX}/policies/model-workaround-sunset.md"
HOOK="${CTX}/policies/critical-rule-hook-promotion.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# (a) cache-aware prompt layout.
has "${TOKEN}" "CACHE_AWARE_PROMPT_LAYOUT" "cache-layout section anchor"
has "${TOKEN}" "Static first, dynamic last" "static-first principle"
has "${TOKEN}" "Update by append, not in-place edit" "append-not-edit principle"
has "${TOKEN}" "stable, not just narrow" "stable tool surface principle"
has "${TOKEN}" "One model per run segment" "no mid-run model swap principle"
has "${TOKEN}" "by-reference" "vendor source cited by-reference"
# pre-existing token-harness content preserved (additive guarantee).
has "${TOKEN}" "Runtime Token Firewall" "pre-existing firewall bullet preserved"
has "${TOKEN}" "Session Continuation Guard" "pre-existing continuation bullet preserved"

# (b) stop-doing review complement in sunset policy.
has "${SUNSET}" "STOP_DOING_REVIEW" "stop-doing section anchor"
has "${SUNSET}" "what can the harness stop doing" "stop-doing question"
has "${SUNSET}" "tested, not assumed" "handover verification clause"
# pre-existing sunset anchors preserved.
has "${SUNSET}" "MODEL_TAG_REQUIRED" "pre-existing tag anchor preserved"
has "${SUNSET}" "SUNSET_REVIEW_ON_MODEL_CHANGE" "pre-existing review anchor preserved"

# (c) declarative boundary surface in hook promotion.
has "${HOOK}" "DECLARATIVE_BOUNDARY_SURFACE" "boundary-surface section anchor"
has "${HOOK}" "typed declarative surface" "typed surface rule"
has "${HOOK}" "sub-agent-capsule-contract.md" "typed-contract vein cross-link"
# pre-existing hook-promotion anchors preserved.
has "${HOOK}" "PROMOTION_CRITERIA" "pre-existing criteria anchor preserved"
has "${HOOK}" "WIRING_HOME" "pre-existing wiring anchor preserved"

# line budgets: all three touched policies stay under the 200-line ceiling.
for f in "${TOKEN}" "${SUNSET}" "${HOOK}"; do
  lines="$(wc -l < "${f}")"
  [[ "${lines}" -lt 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS"
