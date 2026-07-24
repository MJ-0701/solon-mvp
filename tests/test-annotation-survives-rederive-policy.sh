#!/usr/bin/env bash
# BLOG-2026-07-24 (ad-hoc) — derived-doc annotation survives regeneration.
#
# Locks: DERIVED_DOC_ANNOTATION (a doc derived from a source-of-truth artifact
# is regenerated on change, but human why/correction/constraint notes anchored
# to the item survive re-derivation instead of being clobbered). By-reference to
# existing owners (obsidian-llm-wiki Memory Formation, source-pointer-citation,
# unknowns-and-deviations DEVIATIONS_LOG, lessons-accumulation) — no restated
# mechanism. External-exemplar tool identity locked out.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
POL="${DIST_DIR}/templates/.sfs-local-template/context/policies"
DCP="${POL}/doc-colocation-provenance.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── (a) the delta anchor ─────────────────────────────────────────────
fhas "${DCP}" "DERIVED_DOC_ANNOTATION" "delta anchor present"
fhas "${DCP}" "preserves" "regen-preserves rule"
fhas "${DCP}" "why" "note kind: why"
fhas "${DCP}" "correction" "note kind: correction"
fhas "${DCP}" "constraint" "note kind: constraint"
fhas "${DCP}" "not to a line number" "anchor-to-item not line rule"

# ── (b) by-reference, not restated mechanism ─────────────────────────
fhas "${DCP}" "obsidian-llm-wiki.md" "ref: derived-doc formation owner"
fhas "${DCP}" "source-pointer-citation.md" "ref: no-copy origin pointer"
fhas "${DCP}" "unknowns-and-deviations.md" "ref: conflict-as-gap owner"
fhas "${DCP}" "lessons-accumulation.md" "ref: correction-promotion owner"

# ── (c) additive guarantee — existing anchors preserved ──────────────
fhas "${DCP}" "COLOCATION_RULE" "colocation anchor preserved"
fhas "${DCP}" "REFERENCE_DOC_SKELETON" "skeleton anchor preserved"
fhas "${DCP}" "PROVENANCE_LINE" "provenance anchor preserved"

# ── (d) vendor lockout — exemplar tool identity never leaks ───────────
for f in "${POL}"/*.md; do
  if grep -Eiq 'platty|paradigmshift' "${f}"; then
    fail "$(basename "${f}"): external-exemplar tool identity leaked"
  fi
done

# ── (e) line budget ──────────────────────────────────────────────────
lines="$(wc -l < "${DCP}")"
[[ "${lines}" -le 200 ]] || fail "doc-colocation-provenance.md exceeds 200-line budget (${lines})"

echo "PASS: derived-doc annotation survives regeneration locked"
