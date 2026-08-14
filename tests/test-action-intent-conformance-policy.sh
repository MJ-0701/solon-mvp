#!/usr/bin/env bash
# BLOG-2026-08-14-2 — the action-side layer: original-intent conformance.
#
# The gate is only worth anything if the checker is NOT the executor, so that
# requirement is asserted first and hardest: the body must demand a separate
# checker and must not leave a self-report path open.
#
# The second risk is a duplicate SSoT with MID_RUN_INTENT_RECHECK, which lives
# in this same file and is easy to conflate. The owner decision taken here is a
# NEW anchor (different timing AND different actor); the test therefore locks
# both that the old anchor survives untouched and that the new section states
# the distinction in its own body.
#
# Also locks: the original request/AC exempted from RIGHTSIZE trimming, the
# no-new-invariant guarantee (registry row count unchanged, verdict/exit
# invariant), budgets, and a vendor lockout on the source's browser surface.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
FCP="${POL}/flow-conformance-postflight.md"
CCG="${POL}/context-conflict-gate.md"
CH="${POL}/credential-hygiene.md"
HA="${POL}/harness-autonomy.md"
SCD="${POL}/skill-catalog-discipline.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
khas() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }
fnot() { grep -Fq -- "$2" "$1" && fail "$3: forbidden '$2' present"; return 0; }

# ── (a) anchor + single owner ───────────────────────────────────────
fanchor "${FCP}" "IRREVERSIBLE_ACTION_INTENT_GATE" "action-intent gate anchor"
owners=0
while IFS= read -r f; do
  grep -Eq '^#{1,6}[[:space:]]+IRREVERSIBLE_ACTION_INTENT_GATE' "$f" && owners=$((owners + 1))
done < <(find "${CTX}" "${DIST_DIR}/docs" -name '*.md' -type f)
[[ "${owners}" -eq 1 ]] \
  || fail "IRREVERSIBLE_ACTION_INTENT_GATE must be defined once (found ${owners})"

sect="$(awk '/^## IRREVERSIBLE_ACTION_INTENT_GATE/{f=1;next} f&&/^## /{exit} f' "${FCP}")"
[[ -n "${sect}" ]] || fail "IRREVERSIBLE_ACTION_INTENT_GATE section is empty"

# ── (b) the separate-checker requirement — the point of the gate ────
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '검사자 분리 필수' \
  || fail "the separate-checker requirement is missing"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '자기신고는 게이트가 아니다' \
  || fail "self-reporting must be explicitly ruled out as a gate"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq 'verifier != implementer' \
  || fail "the gate must reuse verifier != implementer rather than mint a checker"
fhas "${HA}" "Verifier != implementer" "the reused invariant still exists in its owner"
# no escape hatch: a run that cannot stand up a separate checker does not act
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '자동으로 하지 않는다' \
  || fail "missing the fallback rule for a run with no separate checker"

# ── (c) distinguished from MID_RUN_INTENT_RECHECK, both preserved ───
fanchor "${FCP}" "MID_RUN_INTENT_RECHECK" "the pre-existing in-flight anchor is preserved"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq 'MID_RUN_INTENT_RECHECK' \
  || fail "the new section must name the anchor it sits beside"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '스텝 경계마다 스스로' \
  || fail "the timing/actor of MID_RUN_INTENT_RECHECK must be restated for contrast"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '개별 비가역 행동 직전 1회' \
  || fail "the new section's own timing must be stated"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '두 앵커는 병존한다' \
  || fail "the coexistence decision must be recorded in the body"
# the three layers it is NOT
for a in INGRESS_TRUST_CHECKPOINT NEVER_APPROVE_CLASS APPROVAL_FATIGUE_DECAY; do
  LC_ALL=C printf '%s\n' "${sect}" | grep -Fq "$a" \
    || fail "the gap argument must name the pre-existing layer ${a}"
done
fanchor "${CH}" "NEVER_APPROVE_CLASS" "class layer preserved in its owner"
fanchor "${CH}" "INGRESS_TRUST_CHECKPOINT" "ingress layer preserved in its owner"
fhas "${CH}" "IRREVERSIBLE_ACTION_INTENT_GATE" "credential-hygiene points at the residual layer"

# ── (d) no new invariant: registry unchanged, verdict/exit invariant ─
rows="$(awk '/^\| id \| 기대 \| class \|/{f=1;next} f&&/^\|/{n++} f&&!/^\|/{exit} END{print n+0}' "${FCP}")"
[[ "${rows}" -eq 9 ]] \
  || fail "the FCP invariant registry changed size (expected 9 rows incl. separator, found ${rows})"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq 'invariant registry 에 행을 추가하지 않으며' \
  || fail "the no-new-invariant guarantee must be stated"
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq 'verdict/exit 는 양방향 불변' \
  || fail "exit-code invariance must be stated in both directions"
for id in fcp-model-tier fcp-conflict-surfaced fcp-gate-order fcp-stop-the-line \
          fcp-pr-reviewed fcp-verifier-implementer fcp-self-cpo fcp-worker-lane; do
  fhas "${FCP}" "${id}" "pre-existing invariant id preserved"
done

# ── (e) the original request/AC is an enforcement surface ───────────
fhas "${CCG}" "enforcement surface, not standing guidance" "request/AC classed as enforcement"
fhas "${CCG}" "IRREVERSIBLE_ACTION_INTENT_GATE" "the trim exemption names the gate it feeds"
fhas "${CCG}" "disables that gate" "why trimming the request is not a saving"
fanchor "${CCG}" "RIGHTSIZE_CONTEXT_PASS" "the trimming pass is still the owner"

# ── (f) deferred items were NOT re-drafted ─────────────────────────
LC_ALL=C printf '%s\n' "${sect}" | grep -Fq '재기안하지 않는다' \
  || fail "already-covered items must be explicitly deferred, not restated"
for a in SHADOW_MODE_TRUST_LADDER DONE_IS_ARTIFACT_ON_DISK EVENT_LOG_RECONSTRUCTION_SSOT; do
  LC_ALL=C printf '%s\n' "${sect}" | grep -Fq "$a" || fail "missing cross-ref to ${a}"
done
fanchor "${SCD}" "SHADOW_MODE_TRUST_LADDER" "trust ladder preserved in its owner"
# and no rival anchor was minted for the browser/tool-access theme held out
for a in BROWSER_ACCESS_LAYER LEGACY_PORTAL_ACCESS TOOL_ACCESS_TIER; do
  n="$( { grep -rlF "$a" "${CTX}" || true; } | wc -l | tr -d ' ')"
  [[ "$n" -eq 0 ]] || fail "deferred item '$a' was drafted as a new anchor"
done

# ── (g) vendor lockout, scoped to the touched files ────────────────
for f in "${FCP}" "${CCG}" "${CH}"; do
  for s in "Chrome" "side panel" "사이드패널" "browser extension" "Claude in Chrome" \
           "Cowork" "Max plan" "Pro plan"; do
    fnot "$f" "$s" "vendor lockout in $(basename "$f")"
  done
done

# ── (h) routed index + budgets ─────────────────────────────────────
fanchor "${INDEX}" "IRREVERSIBLE_ACTION_INTENT_GATE" "index route"
for f in "${FCP}" "${CCG}" "${CH}" "${HA}" "${INDEX}"; do
  n="$(wc -l < "$f" | tr -d '[:space:]')"
  [[ "${n}" -le 200 ]] || fail "$(basename "$f") exceeds the 200-line budget: ${n}"
done

echo "PASS: irreversible-action intent conformance gate locked"
