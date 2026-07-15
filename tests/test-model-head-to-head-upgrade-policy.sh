#!/usr/bin/env bash
# BLOG-2026-07-15-1 (frontier finance-diligence field case) — headline.
#
# Locks the two promoted generalized principles (vendor specifics held
# by-reference; company/product names and performance figures locked out):
#   (a) MODEL_HEAD_TO_HEAD_ON_UPGRADE — a model swap decision runs the same
#       domain eval head-to-head vs the incumbent, and the benchmark surface
#       expands release-over-release (field twins registered in
#       self-improvement-loop MEASURE + skill-promotion-loop HELD_OUT_SCORING);
#   (b) decomposition invariance — small, repeatable, checked steps with
#       controlled inputs stay no matter how capable the model
#       (sub-agent-capsule-contract + methodology-7-step, one line each).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
SUNSET="${CTX}/policies/model-workaround-sunset.md"
LOOP="${CTX}/policies/self-improvement-loop.md"
PROMOTE="${CTX}/policies/skill-promotion-loop.md"
CAPSULE="${CTX}/policies/sub-agent-capsule-contract.md"
METHOD="${DIST_DIR}/docs/maintenance/methodology-7-step.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── (a) head-to-head upgrade bench + expanding surface ───────────────
fhas "${SUNSET}" "MODEL_HEAD_TO_HEAD_ON_UPGRADE" "sunset head-to-head anchor"
fhas "${SUNSET}" "head-to-head" "head-to-head rule"
fhas "${SUNSET}" "expands release-over-release" "expanding bench surface rule"
fhas "${SUNSET}" "by-reference" "sunset external source cited by-reference"
fhas "${LOOP}" "MODEL_HEAD_TO_HEAD_ON_UPGRADE" "MEASURE stage field twin"
fhas "${LOOP}" "expands release-over-release" "MEASURE expanding surface twin"
fhas "${PROMOTE}" "MODEL_HEAD_TO_HEAD_ON_UPGRADE" "HELD_OUT_SCORING field twin"
fhas "${PROMOTE}" "grows release-over-release" "HELD_OUT expanding surface twin"

# ── (b) decomposition invariance ─────────────────────────────────────
fhas "${CAPSULE}" "model-invariant discipline" "capsule decomposition invariance"
fhas "${CAPSULE}" "checked steps with controlled" "capsule checked-steps clause"
fhas_ko "${METHOD}" "모델 성능과 무관한" "methodology invariance line"
fhas_ko "${METHOD}" "MODEL_HEAD_TO_HEAD_ON_UPGRADE" "methodology head-to-head pointer"

# ── vendor lockout: company/product names + performance figures ─────
for f in "${SUNSET}" "${LOOP}" "${PROMOTE}" "${CAPSULE}" "${METHOD}"; do
  if grep -Eiq 'hebbia|financial diligence' "${f}"; then
    fail "$(basename "${f}"): vendor company/product name leaked"
  fi
done

# ── additive guarantee: pre-existing anchors survive ─────────────────
fhas "${SUNSET}" "MODEL_TAG_REQUIRED" "sunset tag anchor preserved"
fhas "${SUNSET}" "SUNSET_REVIEW_ON_MODEL_CHANGE" "sunset review anchor preserved"
fhas "${SUNSET}" "STOP_DOING_REVIEW" "sunset stop-doing anchor preserved"
fhas "${SUNSET}" "DEBT_FRAMING" "sunset debt anchor preserved"
fhas "${LOOP}" "usage-value signal" "loop usage signal preserved"
fhas "${LOOP}" "measured-but-not-sufficient" "loop invariant preserved"
fhas "${PROMOTE}" "HELD_OUT_SCORING" "promote held-out anchor preserved"
fhas "${PROMOTE}" "EVOLUTION_ADOPTION_GATE" "promote adoption-gate anchor preserved"
fhas "${CAPSULE}" "warn-before-block" "capsule warn-before-block preserved"
fhas "${CAPSULE}" "exemplar" "capsule exemplar preserved"

# ── budgets (promote policy has its own stricter <200 lock elsewhere) ─
for f in "${SUNSET}" "${LOOP}" "${PROMOTE}" "${CAPSULE}"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

echo "PASS: model head-to-head upgrade + decomposition invariance locked"
