#!/usr/bin/env bash
# BLOG-2026-08-14-1 — proactive intervention: response ladder, rubric, decay.
#
# The two failure modes this delta could have are (a) a ladder that quietly
# collapses back to "propose / stay silent" by losing its no-action and
# merge-into-open-unit rungs, and (b) a decay rule that reads as licence to
# stop running an enforcement gate. Both are asserted harder than the anchors:
# all four rungs must be enumerated, and the decay section must carry the
# inviolable-gate exemption in its own body.
#
# Also locks: COMBINED_SIGNAL_WINDOW declared once (the below-floor pair that
# single-source counters cannot see), no rival scorer beside HELD_OUT_SCORING,
# the plain-line operator slot, additive preservation, budgets, and a vendor
# lockout scoped to the touched files.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
LT="${POL}/loop-taxonomy.md"
SIL="${POL}/self-improvement-loop.md"
SPL="${POL}/skill-promotion-loop.md"
WD="${POL}/work-delegation-and-startup.md"
TH="${POL}/token-harness.md"
SST="${POL}/steering-surface-taxonomy.md"
OPCTX="${DIST_DIR}/templates/.sfs-local-template/operator-context.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }
fnot() { grep -Fq -- "$2" "$1" && fail "$3: forbidden '$2' present"; return 0; }

section_of() { awk -v h="^## $2" '$0 ~ h {f=1;next} f&&/^## /{exit} f' "$1"; }

# ── (a) the ladder: all four rungs, in one owner ────────────────────
fanchor "${LT}" "PROACTIVE_INTERVENTION_LADDER" "ladder anchor"
owners=0
while IFS= read -r f; do
  grep -Eq '^#{1,6}[[:space:]]+PROACTIVE_INTERVENTION_LADDER' "$f" && owners=$((owners + 1))
done < <(find "${CTX}" "${DIST_DIR}/docs" -name '*.md' -type f)
[[ "${owners}" -eq 1 ]] || fail "PROACTIVE_INTERVENTION_LADDER must be defined once (found ${owners})"

ladder="$(section_of "${LT}" "PROACTIVE_INTERVENTION_LADDER")"
[[ -n "${ladder}" ]] || fail "ladder section is empty"
# The two rungs the surface did NOT have before are the point of the delta.
grep -Fq "**No action.**" <<<"${ladder}" \
  || fail "rung 1 (no action) missing — doing nothing must be a first-class option"
grep -Fq "not a failure to decide" <<<"${ladder}" \
  || fail "no-action rung must be stated as a choice, not an omission"
grep -Fq "**Merge into an open unit.**" <<<"${ladder}" \
  || fail "rung 4 (merge into an already-open unit) missing — the ladder collapsed back to 2 settings"
grep -Fq "open queue" <<<"${ladder}" \
  || fail "rung 4 must require reading the open queue before minting a candidate"
# ...and the two it already had, so the enumeration is genuinely four.
grep -Fq "**Inline note.**" <<<"${ladder}" || fail "rung 2 (inline note) missing"
grep -Fq "**New candidate.**" <<<"${ladder}" || fail "rung 3 (new candidate) missing"
grep -Fq "never to an accepted one" <<<"${ladder}" \
  || fail "merging must stay suggest-only (appends to a proposal, not a decision)"

# ── (b) the rubric: three axes, and no rival scorer ─────────────────
for axis in "**usefulness**" "**confidence**" "**is a human better suited**"; do
  grep -Fq -- "${axis}" <<<"${ladder}" || fail "rubric axis missing: ${axis}"
done
grep -Fq "HUMAN_ATTENTION_IS_SCARCE" <<<"${ladder}" \
  || fail "the third axis must be tied to HUMAN_ATTENTION_IS_SCARCE"
fanchor "${WD}" "HUMAN_ATTENTION_IS_SCARCE" "the paired anchor still exists in its owner"
grep -Fq "HELD_OUT_SCORING" <<<"${ladder}" \
  || fail "the rubric must reuse HELD_OUT_SCORING rather than imply a new scorer"
grep -Fq "No new scorer" <<<"${ladder}" \
  || fail "the no-new-scorer commitment must be explicit"
fanchor "${SPL}" "HELD_OUT_SCORING" "the reused scorer still exists in its owner"
# a rival scoring anchor must not have been minted anywhere
for a in INTERVENTION_SCORING PROACTIVE_SCORING INTERVENTION_RUBRIC_SCORER; do
  n="$( { grep -rlF "$a" "${CTX}" || true; } | wc -l | tr -d ' ')"
  [[ "$n" -eq 0 ]] || fail "a rival scorer anchor '$a' was created"
done

# ── (c) decay, and its exemption in the SAME section ────────────────
fanchor "${LT}" "ATTENTION_DECAY_ON_BARREN_SURFACES" "decay anchor"
decay="$(section_of "${LT}" "ATTENTION_DECAY_ON_BARREN_SURFACES")"
[[ -n "${decay}" ]] || fail "decay section is empty"
grep -Fq "check frequency" <<<"${decay}" || fail "decay must demote frequency"
grep -Fq "Never removal" <<<"${decay}" || fail "decay must not read as removal"
grep -Fq "operator names it" <<<"${decay}" || fail "explicit call must restore cadence"
# The exemption is the safety half; decay without it is a gate-disabling bug.
grep -Fq "**Inviolable gates are exempt.**" <<<"${decay}" \
  || fail "decay section carries no inviolable-gate exemption — this is the gate-disabling failure mode"
grep -Fq "RULE_VS_GUARDRAIL" <<<"${decay}" \
  || fail "the exemption must route classification to RULE_VS_GUARDRAIL"
fanchor "${SST}" "RULE_VS_GUARDRAIL" "the classification rule still exists in its owner"
# the job-grain twin is named, so this is not a second SSoT for the same idea
grep -Fq "SCHEDULED_RUN_CONTRACT item 5" <<<"${decay}" \
  || fail "decay must name its job-grain twin (SCHEDULED_RUN_CONTRACT) and the grain difference"
grep -Fq "surface-grain" <<<"${decay}" || fail "the grain difference must be stated"
fhas "${TH}" "ATTENTION_DECAY_ON_BARREN_SURFACES" "token-harness points at the decay owner"

# ── (d) combined signal window: one owner, real claim ───────────────
definers=0
while IFS= read -r f; do
  grep -Fq -- '**COMBINED_SIGNAL_WINDOW**' "$f" && definers=$((definers + 1))
done < <(find "${CTX}" "${DIST_DIR}/docs" -name '*.md' -type f)
[[ "${definers}" -eq 1 ]] \
  || fail "COMBINED_SIGNAL_WINDOW must be defined once (found ${definers} defining copies)"
fhas "${SIL}" "different kinds" "the pair is cross-source, not two of the same signal"
fhas "${SIL}" "inside one source" "why single-source floors cannot see the pair"
fhas "${SIL}" "never as an adoption" "the pair stays suggest-only"
# the floors it defers to still exist where they live
fhas "${SPL}" "3+" "completed-work signature floor preserved"
fhas "${SPL}" "lower floor (2)" "repeated-correction floor preserved"

# ── (e) plain-line operator slot ────────────────────────────────────
fhas "${OPCTX}" "<OPERATOR-PROACTIVITY>" "operator proactivity placeholder"
fhas "${OPCTX}" "PROACTIVE_INTERVENTION_LADDER" "the slot points at the ladder"
fhas "${OPCTX}" "in your own words" "the slot is plain language, not a config grammar"

# ── (f) additive: pre-existing anchors in the touched files ─────────
for a in DECISION_FRAME LOOP_TYPES CHECK_PLACEMENT_LADDER HABIT_TO_CONTRACT_CHAINING \
         VERIFICATION_AND_SYSTEM_ENCODING; do
  fanchor "${LT}" "${a}" "loop-taxonomy anchor preserved"
done
for a in BE_THE_AGENT_FIRST REFLECTION_TO_EVAL_PIPELINE REJECTION_REASON_CAPTURE; do
  fanchor "${SIL}" "${a}" "self-improvement-loop anchor preserved"
done
fhas "${TH}" "KNOB_DIAGNOSTIC_LADDER" "token-harness anchor preserved"
fhas "${OPCTX}" "<OPERATOR-NORTH-STAR>" "operator-context slot preserved"

# ── (g) negative control on the doc surface ────────────────────────
# The ladder must not be describable as two-valued anywhere in its own body.
if grep -Eq 'propose or stay silent|two options: propose' <<<"${ladder}"; then
  fail "the ladder body still frames the response as a binary"
fi
# The decay body must not authorize skipping a gate.
if grep -Eiq 'gates? (may|can) (also )?(be )?(decay|skipp?ed)|including inviolable' <<<"${decay}"; then
  fail "the decay body appears to authorize decaying an enforcement gate"
fi

# ── (h) vendor lockout, scoped to the touched files ────────────────
for f in "${LT}" "${SIL}" "${TH}" "${OPCTX}"; do
  for s in "Slack" "Claude Tag" "@Claude" "Teams channel" "@mention" "Discord" \
           "Max plan" "Pro plan" "Enterprise plan" "reads the room"; do
    fnot "$f" "$s" "vendor/platform lockout in $(basename "$f")"
  done
  if grep -Eq '\b(30|40|50)% (more|fewer|faster)|[0-9]+% of (messages|threads)' "$f"; then
    fail "$(basename "$f"): a source performance figure leaked"
  fi
done

# ── (i) routed index ───────────────────────────────────────────────
for a in PROACTIVE_INTERVENTION_LADDER ATTENTION_DECAY_ON_BARREN_SURFACES \
         COMBINED_SIGNAL_WINDOW; do
  fanchor "${INDEX}" "${a}" "index route"
done

# ── (j) line budgets ───────────────────────────────────────────────
for f in "${LT}" "${SIL}" "${SPL}" "${WD}" "${TH}" "${SST}" "${OPCTX}" "${INDEX}"; do
  n="$(wc -l < "$f" | tr -d '[:space:]')"
  [[ "${n}" -le 200 ]] || fail "$(basename "$f") exceeds the 200-line budget: ${n}"
done

echo "PASS: proactive intervention ladder + rubric + bounded attention decay locked"
