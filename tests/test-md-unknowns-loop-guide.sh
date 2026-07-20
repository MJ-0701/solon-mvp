#!/usr/bin/env bash
# 0.12.1 headline — unknowns-loop user guide (ko/en) + feature-overview refresh.
#
# Locks: docs/{ko,en}/current-product-shape/30-unknowns-loop.md exist with the
# timeline table, runtime-signal table, and signal-only framing; both
# aggregates wire the new child (split-sync test covers the mechanics, this
# locks intent); 29-feature-overview carries the 0.11.x/0.12.0 rows
# (unknowns loop, runtime signals, evals scaffold, model-swap discipline,
# batch loop discipline) in both languages.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
KO="${DIST_DIR}/docs/ko/current-product-shape/30-unknowns-loop.md"
EN="${DIST_DIR}/docs/en/current-product-shape/30-unknowns-loop.md"
KO29="${DIST_DIR}/docs/ko/current-product-shape/29-feature-overview.md"
EN29="${DIST_DIR}/docs/en/current-product-shape/29-feature-overview.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── guide pages exist with the loop's spine ──────────────────────────
for f in "${KO}" "${EN}"; do
  [[ -f "${f}" ]] || fail "missing guide page: ${f}"
  for anchor in PROTOTYPE_FORK RECON_RUN_BEFORE_COMMIT SPEC_INTERVIEW_GATE \
                REFERENCES_FIELD DEVIATIONS_LOG SOLVED_ELSEWHERE_FIRST \
                EVAL_SURFACE_BLIND_SPOT COMPREHENSION_GATE \
                JUDGE_NEGATIVE_CONTROL; do
    fhas "${f}" "${anchor}" "$(basename "${f}") loop anchor ${anchor}"
  done
  fhas "${f}" "deviation-ledger" "$(basename "${f}") healthcheck signal row"
  fhas "${f}" "plan-readiness" "$(basename "${f}") readiness signal row"
  fhas "${f}" "Held-Out Evals" "$(basename "${f}") doctor section row"
  fhas "${f}" "policies/unknowns-and-deviations.md" "$(basename "${f}") SSoT pointer"
  fhas "${f}" "signal-only" "$(basename "${f}") signal-only framing"
done
fhas_ko "${KO}" "지도" "ko map-vs-territory frame"
fhas "${EN}" "territory" "en map-vs-territory frame"

# ── aggregates wire the child (both surfaces, both languages) ────────
for lang in ko en; do
  agg="${DIST_DIR}/docs/${lang}/current-product-shape.md"
  fhas "${agg}" "docs/${lang}/current-product-shape/30-unknowns-loop.md" "${lang} split_children entry"
  fhas "${agg}" "./current-product-shape/30-unknowns-loop.md" "${lang} document-map link"
done

# ── feature overview carries the new rows ────────────────────────────
for f in "${KO29}" "${EN29}"; do
  fhas "${f}" "30-unknowns-loop.md" "$(basename "$(dirname "${f}")") overview links guide"
  fhas "${f}" "MODEL_UPGRADE_SETUP_AUDIT" "overview model-swap row"
  fhas "${f}" "SERIALIZE_EXPENSIVE_OPS" "overview batch-loop row"
  fhas "${f}" "evals/README.md" "overview evals scaffold row"
  fhas "${f}" "BOUNDS_OUTLIVE_MODEL_LIMITS" "overview safety bullet"
done
fhas_ko "${KO29}" "4질문 리스크 프리플라이트" "ko overview preflight bullet"
fhas "${EN29}" "four-question risk
  preflight" "en overview preflight bullet"

# ── vendor hygiene on the new pages ──────────────────────────────────
for f in "${KO}" "${EN}"; do
  if grep -Eiq 'hebbia|base44|\bcursor\b|ponemon' "${f}"; then
    fail "$(basename "${f}"): vendor name leaked into user guide"
  fi
done

echo "PASS: unknowns-loop user guide + feature-overview refresh locked"
