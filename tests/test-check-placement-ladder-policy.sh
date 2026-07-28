#!/usr/bin/env bash
# BLOG-2026-07-24-1 — verification checks as a placement decision.
#
# Locks CHECK_PLACEMENT_LADDER (standalone → embedded → chained → every-change,
# with repeated invocation as the promotion signal) and
# HABIT_TO_CONTRACT_CHAINING (an "always Y after X" habit becomes a call, with
# the flexibility/token trade stated and a do-not-chain clause). Both live in
# loop-taxonomy, which is by-reference-only by charter — so this test also
# checks that no mechanic was restated and that `tidy` routes to it. The
# vendor's command and feature names are locked out.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
LT="${POL}/loop-taxonomy.md"
TIDY="${CTX}/commands/tidy.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }

# ── (a) the two delta anchors ───────────────────────────────────────
fanchor "${LT}" "CHECK_PLACEMENT_LADDER" "placement ladder anchor"
fanchor "${LT}" "HABIT_TO_CONTRACT_CHAINING" "habit-to-contract anchor"

# ── (b) all four placements, in order ───────────────────────────────
for rung in Standalone Embedded Chained Every-change; do
  fhas "${LT}" "**${rung}**" "placement rung: ${rung}"
done
awk '/## CHECK_PLACEMENT_LADDER/,/## HABIT_TO_CONTRACT_CHAINING/' "${LT}" \
  | grep -q 'Standalone' || fail "placement rungs are not inside the ladder section"

# ── (c) promotion signal + its floor ────────────────────────────────
fhas "${LT}" "repeated invocation" "promotion signal named"
fhas "${LT}" "has already graduated" "graduation wording"
fhas "${LT}" "DETECTION, floor 2" "shares the repeated-correction floor"

# ── (d) the trade-off caveats — the part a naive port would drop ────
fhas "${LT}" "do not chain" "do-not-chain clause"
fhas "${LT}" "costs flexibility" "flexibility trade stated"
fhas "${LT}" "spends tokens" "token cost stated"
fhas "${LT}" "wrapper" "unmodifiable-rail wrapper path"

# ── (e) project-specific deterministic rules are in capture scope ───
fhas "${LT}" "project-specific deterministic rules count" "domain-rule capture scope"
fhas "${LT}" "generic linter cannot know" "beyond-generic-linter clause"

# ── (f) by-reference only — no restated mechanism ───────────────────
fhas "${LT}" "CURATION_PASS" "ref: lessons curation owner"
fhas "${LT}" "FIX_THE_LOOP_NOT_THE_CODE" "ref: upstream-fix owner"
fhas "${LT}" "SHADOW_MODE_TRUST_LADDER" "ref: trust ladder owner"
fhas "${LT}" "critical-rule-hook-promotion.md" "ref: enforcement-tier owner"
fhas "${LT}" "by-reference only" "charter line preserved"

# ── (g) the command surface routes to it ────────────────────────────
fhas "${TIDY}" "CHECK_PLACEMENT_LADDER" "tidy routes to the ladder"
fhas "${TIDY}" "HABIT_TO_CONTRACT_CHAINING" "tidy routes to the chaining rule"
fanchor "${INDEX}" "CHECK_PLACEMENT_LADDER" "index route: placement ladder"
fanchor "${INDEX}" "HABIT_TO_CONTRACT_CHAINING" "index route: chaining"

# ── (h) additive guarantee — existing anchors preserved ─────────────
for anchor in DECISION_FRAME LOOP_TYPES TURN_BASED GOAL_BASED TIME_BASED \
              PROACTIVE VERIFICATION_AND_SYSTEM_ENCODING; do
  fanchor "${LT}" "${anchor}" "loop-taxonomy preserved anchor"
done

# ── (i) vendor lockout — feature/command names never enter policy ───
# The slash-command pattern is anchored on a path-segment boundary on purpose:
# a bare `/verify` is the vendor command, while `scripts/verify-…` and
# `PR/code-review` are pre-existing legitimate prose that must not red-fail.
for f in "${POL}"/*.md "${CTX}"/commands/*.md "${CTX}"/kernel.md "${INDEX}"; do
  if grep -Eq '(^|[[:space:]("`])/(verify|simplify|code-review)([[:space:]).,`]|$)' "${f}"; then
    fail "$(basename "${f}"): vendor slash-command name leaked"
  fi
  # "Managed Agents" and "GitHub Actions" are pre-existing legitimate
  # by-reference source/CI names elsewhere in the routed context and are NOT
  # banned; only this source's preview-feature framing is.
  if grep -Eiq 'research preview' "${f}"; then
    fail "$(basename "${f}"): vendor preview-feature name leaked"
  fi
done

# ── (j) line budget ─────────────────────────────────────────────────
for f in "${LT}" "${TIDY}" "${INDEX}"; do
  lines="$(wc -l < "${f}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS: check placement ladder + habit-to-contract chaining locked"
