#!/usr/bin/env bash
# BLOG-2026-08-08-3 — cost visibility and control: judge by cost per outcome.
#
# The delta here is deliberately NOT a new anchor. `token-harness.md`
# KNOB_DIAGNOSTIC_LADDER already single-owns the completion-ratio x cost-per-task
# routing evidence, so the two entry questions ("what would this have cost with
# no agent, counting work that would not have happened?" and "is this hard work
# or merely a lot of work?") extend that ladder IN PLACE. This test therefore
# locks the absence of a rival owner as hard as it locks the presence of the
# questions — a COST_PER_OUTCOME_FRAME anchor appearing anywhere is a failure,
# because it would split an SSoT that already exists.
#
# Also locks: the advisor binding naming pre-ship verification as its
# representative call point (asserted on the NEW wording — "Gate 6" alone was
# already present before this WU and would rubber-stamp), per-stage effort
# allocation at capsule issue time, the ko/en GUIDE carrying "take stock for a
# month, then restrict" in both languages, budgets, and a price-figure lockout.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
TH="${POL}/token-harness.md"
EOE="${POL}/external-orchestrator-entry.md"
CAP="${POL}/sub-agent-capsule-contract.md"
GKO="${DIST_DIR}/GUIDE/03-2-5.md"
GEN="${DIST_DIR}/docs/en/guide/03-2-start-a-sprint.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhasu() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }
fnot() { grep -Fq -- "$2" "$1" && fail "$3: forbidden '$2' present"; return 0; }

# ── (a) in-place extension of the existing single owner ─────────────
fanchor "${TH}" "KNOB_DIAGNOSTIC_LADDER" "the ladder still owns the routing evidence"
fhas "${TH}" "cost per outcome" "the reframing unit"
fhas "${TH}" "never cost per token" "the unit it replaces"
fhas "${TH}" "without an agent" "entry question 1: the counterfactual"
fhas "${TH}" "would simply not have been done" "entry question 1 counts the undone work"
fhas "${TH}" "hard work, or merely a lot of work" "entry question 2: the routing question"
fhas "${TH}" "retries and human correction" "why a small tier can cost more"
fhas "${TH}" "capability that goes unused" "why the strongest tier can cost more"
fhas "${TH}" "mixed pipeline" "a mixed pipeline is normal, not a compromise"

# The questions must sit inside the ladder's own section, not float elsewhere.
sect="$(awk '/^## KNOB_DIAGNOSTIC_LADDER/{f=1;next} f&&/^## /{exit} f' "${TH}")"
[[ -n "${sect}" ]] || fail "KNOB_DIAGNOSTIC_LADDER section not found"
printf '%s\n' "${sect}" | grep -Fq 'hard work, or merely a lot of work' \
  || fail "entry questions are outside the ladder they claim to extend"
# ...and the pre-existing ladder content survives the extension
for s in "did it fail because it didn't know" "Downshift discipline" \
         "Route from a record, not a feel" "task completion ratio"; do
  printf '%s\n' "${sect}" | grep -Fq -- "$s" || fail "ladder lost pre-existing content: '$s'"
done

# ── (b) NO rival SSoT was minted ────────────────────────────────────
rivals="$( { grep -rlF 'COST_PER_OUTCOME_FRAME' "${CTX}" "${DIST_DIR}/docs" "${DIST_DIR}/GUIDE" \
             || true; } | wc -l | tr -d ' ')"
[[ "${rivals}" -eq 0 ]] \
  || fail "cost framing must extend KNOB_DIAGNOSTIC_LADDER in place, not mint a new anchor"
# exactly one file defines the ladder
owners=0
while IFS= read -r f; do
  grep -Eq '^#{1,6}[[:space:]]+KNOB_DIAGNOSTIC_LADDER' "$f" && owners=$((owners + 1))
done < <(find "${CTX}" "${DIST_DIR}/docs" -name '*.md' -type f)
[[ "${owners}" -eq 1 ]] || fail "KNOB_DIAGNOSTIC_LADDER must be defined once (found ${owners})"

# ── (c) advisor binding: the NEW pre-ship wording, not "Gate 6" ─────
# "Gate 6" predates this WU; asserting it alone would pass before the edit.
fanchor "${EOE}" "ADVISOR_STRATEGY_BINDING" "advisor binding preserved"
fhas "${EOE}" "ship-eve evaluation" "pre-ship call point named (new wording)"
fhas "${EOE}" "last moment a wrong result is still cheap" "why that point is the representative one"
cond="$(awk '/^## ADVISOR_STRATEGY_BINDING/{f=1;next} f&&/^## /{exit} f' "${EOE}")"
printf '%s\n' "${cond}" | grep -Fq 'ship-eve evaluation' \
  || fail "pre-ship call point must live in the binding's call-condition list"
for s in "stuck" "low-confidence" "call conditions are a data surface"; do
  printf '%s\n' "${cond}" | grep -Fq -- "$s" || fail "binding lost pre-existing condition: '$s'"
done

# ── (d) per-stage effort allocation at issue time ───────────────────
fanchor "${CAP}" "SUBAGENT_TIER_DEFAULT" "capsule tier default preserved"
fhas "${CAP}" "at issue time, per pipeline stage" "effort is pre-allocated, not only escalated"
fhas "${CAP}" "issue at low" "low-effort stages named"
fhas "${CAP}" "review stages issue high" "high-effort stages named"
fhas "${CAP}" "opening bid, not a ceiling" "composes with the failure-driven ladder"
fhas "${CAP}" "KNOB_DIAGNOSTIC_LADDER" "points at the ladder rather than restating it"

# ── (e) GUIDE ko + en carry the ordering rule ───────────────────────
fhasu "${GKO}" "먼저 한 달 재고, 그 다음 제한" "ko: observe first, then restrict"
fhasu "${GKO}" "결과 하나당 비용" "ko: cost per outcome"
fhasu "${GKO}" "그냥 양이 많은 일인가" "ko: hard vs merely large"
fhasu "${GKO}" "KNOB_DIAGNOSTIC_LADDER" "ko: routes to the SSoT instead of copying it"
fhas "${GEN}" "take stock for a month before you restrict" "en: observe first, then restrict"
fhas "${GEN}" "cost per outcome" "en: cost per outcome"
fhas "${GEN}" "merely a lot of work" "en: hard vs merely large"
fhas "${GEN}" "KNOB_DIAGNOSTIC_LADDER is the SSoT" "en: routes to the SSoT"

# ── (f) price/figure lockout, scoped to the touched files ───────────
for f in "${TH}" "${EOE}" "${CAP}" "${GKO}" "${GEN}"; do
  for s in "10% of list" "50% off" "batch is half" "prompt cache hit" "cache hits cost" \
           "정가의" "반값"; do
    fnot "$f" "$s" "vendor price lockout in $(basename "$f")"
  done
done

# ── (g) budgets ─────────────────────────────────────────────────────
for f in "${TH}" "${EOE}" "${CAP}"; do
  n="$(wc -l < "$f" | tr -d ' ')"
  [[ "$n" -le 200 ]] || fail "$(basename "$f") exceeds the 200-line budget: ${n}"
done

echo "PASS: cost-per-outcome frame (in-place) + pre-ship advisor point + staged effort"
