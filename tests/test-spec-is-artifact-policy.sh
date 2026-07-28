#!/usr/bin/env bash
# BLOG-2026-07-23-1 — spec is the artifact / control logic as data.
#
# Locks four delta anchors promoted from an external deterministic-kernel
# writeup: SPEC_IS_THE_ARTIFACT (verified artifact == executed artifact, no
# translation layer), CONTROL_LOGIC_AS_DATA (routines/transitions/gates on an
# inspectable data surface), the verification-gap investment line on the
# verifier!=implementer invariant, and ARTIFACT_FITS_IN_HEAD (shared design
# rationale behind the 200-line budget, thin entry, and capsule decomposition).
# Existing owners are referenced, never restated; the vendor's internal product
# identities are locked out of the whole routed-context + maintenance surface.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
HA="${POL}/harness-autonomy.md"
MLB="${POL}/md-line-budget.md"
MLB_KO="${POL}/md-line-budget.ko.md"
M7="${DIST_DIR}/docs/maintenance/methodology-7-step.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
# Anchor names must match as whole words: a plain -F assert would still pass
# against a mutated `ANCHORX`, which would make this a rubber stamp
# (harness-autonomy.md JUDGE_NEGATIVE_CONTROL).
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }

# ── (a) delta anchors ────────────────────────────────────────────────
fanchor "${HA}" "SPEC_IS_THE_ARTIFACT" "spec-is-artifact anchor"
fhas "${HA}" "translation layer between" "no-translation-layer rule"
fhas "${HA}" "drift source by construction" "translation layer = drift source"
fanchor "${HA}" "CONTROL_LOGIC_AS_DATA" "control-logic-as-data anchor"
fhas "${HA}" "implicit state machine" "implicit control flow named"
fhas "${HA}" "design finding" "implicit control flow is a finding"
fhas "${HA}" "verification gap" "verification-bottleneck line"
fhas "${HA}" "before raising throughput" "verify-before-throughput ordering"
fanchor "${MLB}" "ARTIFACT_FITS_IN_HEAD" "fits-in-head anchor (en)"
fanchor "${MLB_KO}" "ARTIFACT_FITS_IN_HEAD" "fits-in-head anchor (ko mirror)"

# ── (b) by-reference to existing owners, not restated mechanism ──────
fhas "${HA}" "sub-agent-capsule-contract.md" "ref: capsule AC instance"
fhas "${HA}" "_INDEX.md" "ref: routed-index instance"
fhas "${HA}" "model-profiles.yaml" "ref: binding-as-data instance"
fhas "${MLB}" "sub-agent-capsule-contract.md" "ref: capsule decomposition"
fhas "${MLB}" "thin agent entry" "ref: thin-entry surface"
fanchor "${M7}" "ARTIFACT_FITS_IN_HEAD" "methodology pointer to the anchor"
fhas "${M7}" "md-line-budget.md" "methodology names the SSoT file"
LC_ALL=C grep -Fq -- "여기서 재나열하지 않는다" "${M7}" \
  || fail "methodology-7-step: pointer-only convention line missing"

# ── (c) routed index carries the new routes ─────────────────────────
fanchor "${INDEX}" "SPEC_IS_THE_ARTIFACT" "index route: spec-is-artifact"
fanchor "${INDEX}" "CONTROL_LOGIC_AS_DATA" "index route: control-logic-as-data"
fanchor "${INDEX}" "ARTIFACT_FITS_IN_HEAD" "index route: fits-in-head"

# ── (d) additive guarantee — existing anchors preserved ─────────────
for anchor in PRE_WORK_INVARIANT_DECLARATION FIX_THE_LOOP_NOT_THE_CODE \
              JUDGE_NEGATIVE_CONTROL BOUNDS_OUTLIVE_MODEL_LIMITS; do
  fanchor "${HA}" "${anchor}" "harness-autonomy preserved anchor"
done
fhas "${HA}" "Verifier != implementer" "verifier invariant preserved"
for needle in "In scope" "Out of scope" "md-line-budget-violation" \
              "operational-log-lag"; do
  fhas "${MLB}" "${needle}" "md-line-budget preserved section"
done

# ── (e) vendor lockout — internal product identities never leak ─────
# NOTE: "Datadog" itself is a legitimate observability vendor across the
# security/logging pack, so it is not blanket-banned; it is banned only from
# the files this insight touched. The vendor's internal product names are
# banned everywhere.
for f in "${POL}"/*.md "${CTX}"/commands/*.md "${CTX}"/kernel.md "${CTX}"/_INDEX.md \
         "${DIST_DIR}"/docs/maintenance/*.md; do
  if grep -Eiq 'temper|courier|bitsevolve|helix' "${f}"; then
    fail "$(basename "${f}"): external-exemplar product identity leaked"
  fi
done
for f in "${HA}" "${MLB}" "${MLB_KO}"; do
  grep -Fq "Datadog" "${f}" && fail "$(basename "${f}"): vendor name leaked into the promoted principle"
done

# ── (f) line budget on every touched file ───────────────────────────
for f in "${HA}" "${MLB}" "${MLB_KO}" "${M7}" "${INDEX}"; do
  lines="$(wc -l < "${f}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS: spec-is-the-artifact / control-logic-as-data locked"
