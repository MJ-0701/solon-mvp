#!/usr/bin/env bash
# BLOG-2026-07-18-1 — large-scale migration loop discipline (4 anchors).
#
# Locks: FIX_THE_LOOP_NOT_THE_CODE / JUDGE_NEGATIVE_CONTROL /
# DONE_IS_ARTIFACT_ON_DISK / SERIALIZE_EXPENSIVE_OPS, plus a negative control
# of this test's own judge: the anchor assert must FAIL on a deliberately
# stripped copy (JUDGE_NEGATIVE_CONTROL applied to itself).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
HA="${CTX}/policies/harness-autonomy.md"
TH="${CTX}/policies/token-harness.md"
CAP="${CTX}/policies/sub-agent-capsule-contract.md"
LES="${CTX}/policies/lessons-accumulation.md"
METHOD="${DIST_DIR}/docs/maintenance/methodology-7-step.md"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/mig-loop.XXXXXX")"
trap 'rm -rf "${TMP}"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── (a) fix the loop, not the code ───────────────────────────────────
fhas "${HA}" "FIX_THE_LOOP_NOT_THE_CODE" "harness loop-fix anchor"
fhas "${HA}" "regenerate the affected batch" "batch regeneration rule"
fhas "${HA}" "never hand-patched against" "hand-patch ban"
fhas "${LES}" "FIX_THE_LOOP_NOT_THE_CODE" "lessons flywheel upstream pointer"

# ── (b) judge negative control ───────────────────────────────────────
fhas "${HA}" "JUDGE_NEGATIVE_CONTROL" "judge negative-control anchor"
fhas "${HA}" "deliberately-broken fixture" "broken-fixture rule"
fhas "${HA}" "cannot catch breakage is not a judge" "rubber-stamp rule"

# ── (c) done is artifact on disk ─────────────────────────────────────
fhas "${CAP}" "DONE_IS_ARTIFACT_ON_DISK" "capsule disk-done anchor"
fhas "${CAP}" "re-derived from disk state" "queue re-derivation rule"
fhas "${CAP}" "resume are correct by construction" "resume-by-construction rule"

# ── (d) serialize expensive ops ──────────────────────────────────────
fhas "${TH}" "SERIALIZE_EXPENSIVE_OPS" "token-harness serialization anchor"
fhas "${TH}" "single serialization point" "single-runner rule"
fhas "${TH}" "Workers write patches" "patch-only workers rule"

# ── methodology pointer ──────────────────────────────────────────────
fhas_ko "${METHOD}" "FIX_THE_LOOP_NOT_THE_CODE" "methodology loop pointer"
fhas_ko "${METHOD}" "SERIALIZE_EXPENSIVE_OPS" "methodology serialize pointer"

# ── negative control of this test's own judge ────────────────────────
# A stripped copy must make the anchor grep FAIL — a judge that passes on
# broken input is a rubber stamp (JUDGE_NEGATIVE_CONTROL, self-applied).
sed 's/FIX_THE_LOOP_NOT_THE_CODE//g' "${HA}" > "${TMP}/broken-harness.md"
if grep -Fq -- "FIX_THE_LOOP_NOT_THE_CODE" "${TMP}/broken-harness.md"; then
  fail "negative control: anchor grep passed on a stripped fixture — judge is a rubber stamp"
fi

# ── additive guarantee ───────────────────────────────────────────────
fhas "${HA}" "PRE_WORK_INVARIANT_DECLARATION" "harness invariant anchor preserved"
fhas "${HA}" "Verifier != implementer" "verifier invariant preserved"
fhas "${TH}" "KNOB_DIAGNOSTIC_LADDER" "knob ladder preserved"
fhas "${TH}" "CACHE_AWARE_PROMPT_LAYOUT" "cache layout preserved"
fhas "${CAP}" "warn-before-block" "capsule warn-before-block preserved"
fhas "${CAP}" "DEVIATIONS_LOG" "capsule deviation convention preserved"
fhas "${LES}" "CURATION_PASS" "lessons curation preserved"
fhas "${LES}" "PRE_BUILD_AUDIT" "lessons pre-build audit preserved"

# ── vendor lockout ───────────────────────────────────────────────────
for f in "${HA}" "${TH}" "${CAP}" "${LES}" "${METHOD}"; do
  if grep -Eiq '\bbun\b|\bzig\b' "${f}"; then
    fail "$(basename "${f}"): vendor language/product name leaked"
  fi
done

# ── budgets ──────────────────────────────────────────────────────────
for f in "${HA}" "${TH}" "${CAP}" "${LES}"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

echo "PASS: migration loop discipline locked (incl. negative control)"
