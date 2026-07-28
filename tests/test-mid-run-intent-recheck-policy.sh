#!/usr/bin/env bash
# BLOG-2026-07-22-1 — in-flight intent recheck for long / unattended runs.
#
# Locks MID_RUN_INTENT_RECHECK: at each step boundary a long or unattended WU
# leaves an artifact trace of (a) assumption-change detection and (b) an
# original-AC/intent comparison; silent forward progress is itself a drift
# finding. The point of the anchor is that it is a THIRD moment, distinct from
# the pre-work declaration and the postflight registry, so the test asserts all
# three are named and that the anchor stays advisory. The delegation-ladder and
# cost-routing halves of this insight merged into single owners elsewhere and
# are asserted here as references, not copies.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
FCP="${POL}/flow-conformance-postflight.md"
HA="${POL}/harness-autonomy.md"
WDS="${POL}/work-delegation-and-startup.md"
TH="${POL}/token-harness.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
kfhas() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }

# ── (a) the anchor ──────────────────────────────────────────────────
fanchor "${FCP}" "MID_RUN_INTENT_RECHECK" "mid-run recheck anchor"

# ── (b) both checks are named, and the trace is an artifact ─────────
kfhas "${FCP}" "가정 변화 감지" "check (a): assumption-change detection"
kfhas "${FCP}" "원 intent 대조" "check (b): original-intent comparison"
kfhas "${FCP}" "스텝 경계마다" "cadence: at each step boundary"
kfhas "${FCP}" "산출물 흔적" "the recheck leaves an artifact trace"
kfhas "${FCP}" "drift finding" "silence is itself a finding"

# ── (c) three distinct moments — the whole point of the delta ───────
# Pre-work declaration, in-flight recheck, postflight registry must all be
# named in the same section, or the anchor collapses into what already existed.
section="$(awk '/## MID_RUN_INTENT_RECHECK/,/## HONEST_UNKNOWNS/' "${FCP}")"
for needle in "PRE_WORK_INVARIANT_DECLARATION" "harness-autonomy.md" \
              "SCHEDULED_RUN_CONTRACT" "work-delegation-and-startup.md" \
              "unknowns-and-deviations.md"; do
  printf '%s' "${section}" | grep -Fq -- "${needle}" \
    || fail "MID_RUN_INTENT_RECHECK section missing reference: ${needle}"
done
printf '%s' "${section}" | LC_ALL=C grep -Fq -- "advisory" \
  || fail "MID_RUN_INTENT_RECHECK must stay advisory (non-blocking)"
fanchor "${HA}" "PRE_WORK_INVARIANT_DECLARATION" "pre-work anchor still exists"

# ── (d) the other two halves merged, not duplicated ─────────────────
fanchor "${WDS}" "DELEGATION_UNIT_LADDER" "delegation ladder owner"
fhas "${WDS}" "chunk" "ladder covers the task -> decision progression"
fhas "${TH}" "task completion ratio" "cost-routing metric owner"
ladder_owners="$(grep -rlEw -- '^## DELEGATION_UNIT_LADDER' "${POL}" "${CTX}/commands" | wc -l | tr -d '[:space:]')"
[[ "${ladder_owners}" -eq 1 ]] || fail "DELEGATION_UNIT_LADDER duplicated (${ladder_owners} owners)"

# ── (e) session-memory of mistakes is NOT re-drafted here ───────────
# The insight's "cross-session mistake memory" is already the lessons ledger;
# re-introducing it would be a second SSoT.
printf '%s' "${section}" | grep -Fq "lessons.md" \
  && fail "MID_RUN_INTENT_RECHECK re-drafts the lessons ledger (already owned)"

# ── (f) routed index ────────────────────────────────────────────────
fanchor "${INDEX}" "MID_RUN_INTENT_RECHECK" "index route: mid-run recheck"

# ── (g) additive guarantee ──────────────────────────────────────────
fanchor "${FCP}" "EVENT_LOG_RECONSTRUCTION_SSOT" "FCP anchor preserved"
fanchor "${FCP}" "HONEST_UNKNOWNS" "FCP anchor preserved"
fhas "${FCP}" "fcp-verifier-implementer" "invariant registry preserved"
fhas "${FCP}" "fcp-stop-the-line" "invariant registry preserved"

# ── (h) vendor / figure lockout ─────────────────────────────────────
for f in "${POL}"/*.md "${CTX}"/commands/*.md "${CTX}"/kernel.md "${INDEX}"; do
  if grep -Eiq 'rakuten|kaji|ai-nization' "${f}"; then
    fail "$(basename "${f}"): vendor identity leaked"
  fi
done
for f in "${FCP}" "${WDS}" "${TH}"; do
  if grep -Eiq '\b10x\b|\bfable\b' "${f}"; then
    fail "$(basename "${f}"): source figure or model class leaked"
  fi
done

# ── (i) line budget ─────────────────────────────────────────────────
for f in "${FCP}" "${HA}" "${WDS}" "${TH}" "${INDEX}"; do
  lines="$(wc -l < "${f}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS: mid-run intent recheck locked (in-flight distinct from pre/post)"
