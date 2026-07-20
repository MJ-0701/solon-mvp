#!/usr/bin/env bash
# BLOG-2026-07-17-1 — model-swap setup audit + reference pairs + schedule audit.
#
# Locks the three promoted deltas (vendor names locked out):
#   (a) MODEL_UPGRADE_SETUP_AUDIT — on model swap, the NEW model runs a
#       read-only audit of untagged standing instructions (skills/lessons/
#       operator-context); retire/generalize/keep candidates at the tidy rail.
#   (b) REFERENCE_PAIR_STANDARD_INFERENCE — standards may be given as
#       before/after artifact-pair pointers (operator-context slot).
#   (c) SCHEDULED_RUN_CONTRACT gains a periodic schedule audit (4th item).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
SUNSET="${CTX}/policies/model-workaround-sunset.md"
WDS="${CTX}/policies/work-delegation-and-startup.md"
PROMOTE="${CTX}/policies/skill-promotion-loop.md"
TIDY="${CTX}/commands/tidy.md"
OPCTX="${DIST_DIR}/templates/.sfs-local-template/operator-context.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── (a) setup audit ──────────────────────────────────────────────────
fhas "${SUNSET}" "MODEL_UPGRADE_SETUP_AUDIT" "sunset setup-audit anchor"
fhas "${SUNSET}" "the new model itself" "new-model-audits-itself rule"
fhas "${SUNSET}" "retire / generalize / keep" "candidate outcomes"
fhas "${SUNSET}" "suggest-only" "suggest-only standing"
fhas "${TIDY}" "MODEL_UPGRADE_SETUP_AUDIT" "tidy rail consumes candidates"

# ── (b) reference pairs ──────────────────────────────────────────────
fhas "${PROMOTE}" "REFERENCE_PAIR_STANDARD_INFERENCE" "promote reference-pair anchor"
fhas "${PROMOTE}" "pointers, never pasted payloads" "pointer-not-payload tie"
fhas "${OPCTX}" "<OPERATOR-REFERENCE-PAIRS>" "operator-context placeholder slot"
fhas "${OPCTX}" "REFERENCE_PAIR_STANDARD_INFERENCE" "operator-context cross-ref"
# placeholder discipline: the slot line carries a placeholder, no fixed value
grep -F -- "Reference pairs (standards by example)" "${OPCTX}" | grep -Fq -- "<OPERATOR-REFERENCE-PAIRS>" \
  || fail "operator-context reference-pair line must stay a placeholder"

# ── (c) schedule audit ───────────────────────────────────────────────
fhas "${WDS}" "Periodic schedule audit" "scheduled-run 4th contract item"
fhas "${WDS}" "retirement candidate" "no-value fires surface retirement"

# ── additive guarantee ───────────────────────────────────────────────
fhas "${SUNSET}" "MODEL_TAG_REQUIRED" "sunset tag anchor preserved"
fhas "${SUNSET}" "SUNSET_REVIEW_ON_MODEL_CHANGE" "sunset review anchor preserved"
fhas "${SUNSET}" "MODEL_HEAD_TO_HEAD_ON_UPGRADE" "head-to-head anchor preserved"
fhas "${SUNSET}" "STOP_DOING_REVIEW" "stop-doing anchor preserved"
fhas "${WDS}" "Every fire is a fresh session" "contract item 1 preserved"
fhas "${WDS}" "Four operational controls exist" "contract item 2 preserved"
fhas "${WDS}" "Credentials by indirection only" "contract item 3 preserved"
fhas "${PROMOTE}" "HELD_OUT_SCORING" "promote held-out anchor preserved"
fhas "${OPCTX}" "<OPERATOR-NORTH-STAR>" "operator-context north-star preserved"

# ── vendor lockout (new-delta files; WDS carries pre-existing by-ref citations) ──
for f in "${SUNSET}" "${OPCTX}" "${TIDY}"; do
  if grep -Eiq 'fable|cowork' "${f}"; then
    fail "$(basename "${f}"): vendor product name leaked"
  fi
done

# ── budgets ──────────────────────────────────────────────────────────
for f in "${SUNSET}" "${WDS}" "${PROMOTE}" "${TIDY}"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

echo "PASS: model-upgrade setup audit + reference pairs + schedule audit locked"
