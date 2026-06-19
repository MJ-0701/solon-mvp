#!/usr/bin/env bash
# BLOG-2026-06-19-2 "Opus 4.8 Build Day hackathon" absorption — headline.
#
# Locks the generalized verify/map methodology (vendor/name/model specifics
# held by-reference):
#   (a) verifier capsule patterns — isolated verifier + self-correction loop,
#       and adversarial verifier capsule (cardnews-redteam generalized) — named
#       as by-reference options in sub-agent-capsule-contract (en+ko) and on the
#       advisor<->Code file bus (external-orchestrator-entry);
#   (b) plan map-first — methodology-7-step plan gains "map the whole project
#       before building -> parallel workflows" external validation;
#   (c) evidence chain in source-pointer-citation, cost-as-sunset-trigger in
#       model-workaround-sunset STOP_DOING_REVIEW.
# Additive-only: pre-existing anchors in every touched file stay.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
CAP="${CTX}/policies/sub-agent-capsule-contract.md"
CAP_KO="${CTX}/policies/sub-agent-capsule-contract.ko.md"
ORCH="${CTX}/policies/external-orchestrator-entry.md"
SPC="${CTX}/policies/source-pointer-citation.md"
SUNSET="${CTX}/policies/model-workaround-sunset.md"
METHOD="${DIST_DIR}/docs/maintenance/methodology-7-step.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
has_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── (a) verifier capsule patterns ──────────────────────────────────
has "${CAP}" "Verifier capsule patterns" "capsule en verifier-patterns anchor"
has "${CAP}" "isolated verifier capsule" "capsule en isolated verifier"
has "${CAP}" "self-correction loop" "capsule en self-correction loop"
has "${CAP}" "adversarial verifier capsule" "capsule en adversarial verifier"
has "${CAP}" "cardnews-redteam" "capsule en red-team generalization"
has "${CAP}" "by-reference" "capsule en by-reference"
has "${CAP_KO}" "Verifier capsule patterns" "capsule ko verifier-patterns anchor"
has "${CAP_KO}" "self-correction" "capsule ko self-correction loop"
has "${CAP_KO}" "adversarial verifier capsule" "capsule ko adversarial verifier"
# advisor<->Code file bus carries the adversarial-verifier role
has "${ORCH}" "adversarial verifier capsule" "orchestrator bus adversarial role"
has "${ORCH}" "advisor↔Code file bus" "orchestrator advisor bus anchor preserved"
# pre-existing capsule anchors preserved (additive guarantee)
has "${CAP}" "Verifier ≠ author" "pre-existing verifier≠author preserved"
has "${CAP}" "Final-message-only return" "pre-existing WU-1 final-message-only preserved"

# ── (b) plan map-first ─────────────────────────────────────────────
has_ko "${METHOD}" "map-first" "methodology map-first anchor"
has "${METHOD}" "by-reference" "methodology by-reference"
# pre-existing methodology anchors preserved
has_ko "${METHOD}" "eval-first" "pre-existing WU-0 eval-first preserved"

# ── (c) evidence chain + cost-as-sunset-trigger ────────────────────
has "${SPC}" "Evidence chain" "source-pointer evidence-chain anchor"
has "${SPC}" "traces back to a documented source" "source-pointer traceability rule"
has "${SPC}" "by-reference" "source-pointer by-reference"
# pre-existing source-pointer anchors preserved
has "${SPC}" "No content copy" "pre-existing no-content-copy preserved"
has "${SUNSET}" "Don't settle for the first method that works" "sunset cost-refactor lesson"
has "${SUNSET}" "sunset trigger" "sunset cost-as-trigger framing"
# pre-existing sunset anchors preserved
has "${SUNSET}" "STOP_DOING_REVIEW" "pre-existing STOP_DOING_REVIEW preserved"
has "${SUNSET}" "MODEL_TAG_REQUIRED" "pre-existing MODEL_TAG_REQUIRED preserved"

# ── vendor hygiene: no model version / product names leaked ────────
for f in "${CAP}" "${ORCH}" "${SPC}" "${SUNSET}"; do
  for v in "Opus 4.8" "Opus 4.7" "Tekton" "Sim Francisco"; do
    if grep -Fq -- "${v}" "${f}"; then
      fail "$(basename "${f}"): vendor token '${v}' leaked into policy body"
    fi
  done
done

# ── line budgets: every touched policy under the 200-line ceiling ──
for f in "${CAP}" "${CAP_KO}" "${ORCH}" "${SPC}" "${SUNSET}"; do
  lines="$(wc -l < "${f}")"
  [[ "${lines}" -lt 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS"
