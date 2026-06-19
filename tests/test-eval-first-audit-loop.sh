#!/usr/bin/env bash
# BLOG-2026-06-17-1 "Built with Opus 4.7 Claude Code hackathon winners" absorption — headline.
#
# Locks the two promoted generalized principles (vendor specifics held by-reference):
#   (a) eval-first gate — the flowcheck Plan-gate self-check fixes ground-truth
#       eval cases + scoring dimensions BEFORE code ("eval = first commit"),
#       mirrored on the success side in skill-promotion-loop HELD_OUT_SCORING;
#   (b) pre-build audit ("let Claude audit") — lessons-accumulation gains a
#       read-only, suggest-only PRE_BUILD_AUDIT pass over already-shipped
#       artifacts before the next build.
# Additive-only: pre-existing anchors in every touched file stay.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
FLOW="${CTX}/commands/flowcheck.md"
PROMOTE="${CTX}/policies/skill-promotion-loop.md"
LESSONS="${CTX}/policies/lessons-accumulation.md"
METHOD="${DIST_DIR}/docs/maintenance/methodology-7-step.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
# Korean grep pinned to this call only (no global LC_ALL — breaks ruby UTF-8 output).
has_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── (a) eval-first gate ────────────────────────────────────────────
# flowcheck Plan-gate self-check gains a 5th check.
has "${FLOW}" "eval-first" "flowcheck eval-first anchor"
has "${FLOW}" "eval = first commit" "flowcheck eval=first-commit principle"
has "${FLOW}" "HELD_OUT_SCORING" "flowcheck cross-link to held-out scoring"
has "${FLOW}" "by-reference" "flowcheck vendor source cited by-reference"
# pre-existing Plan-gate checks preserved (additive guarantee).
has "${FLOW}" "intended-output" "pre-existing plan-gate check 1 preserved"
has "${FLOW}" "implicit-assumptions" "pre-existing plan-gate check 2 preserved"
has "${FLOW}" "intent-alignment" "pre-existing plan-gate check 4 preserved"

# skill-promotion-loop HELD_OUT_SCORING gains the eval-first / fixed-before-edit clause.
has "${PROMOTE}" "Eval-first" "promote eval-first clause"
has "${PROMOTE}" "eval = first commit" "promote eval=first-commit principle"
has "${PROMOTE}" "by-reference" "promote vendor source cited by-reference"
# pre-existing skill-promotion anchors preserved.
has "${PROMOTE}" "HELD_OUT_SCORING" "pre-existing held-out anchor preserved"
has "${PROMOTE}" "EVOLUTION_ADOPTION_GATE" "pre-existing adoption-gate anchor preserved"

# ── (b) pre-build audit ("let Claude audit") ───────────────────────
has "${LESSONS}" "PRE_BUILD_AUDIT" "lessons pre-build-audit section anchor"
has "${LESSONS}" "read-only audit of the artifacts" "lessons read-only audit rule"
has "${LESSONS}" "suggest-only" "lessons audit suggest-only rule"
has "${LESSONS}" "by-reference" "lessons vendor source cited by-reference"
# pre-existing lessons anchors preserved.
has "${LESSONS}" "CURATION_PASS" "pre-existing curation-pass anchor preserved"
has "${LESSONS}" "Feedback flywheel" "pre-existing flywheel section preserved"

# methodology quick-ref carries the eval-first pointer.
has_ko "${METHOD}" "eval-first" "methodology eval-first pointer"
has "${METHOD}" "eval = first commit" "methodology eval=first-commit principle"

# ── vendor hygiene: no model-version anecdote bled into the policy bodies ──
# The generalized principle is promoted; the model version stays out of the
# absorbed prose (by-reference citations name the source neutrally).
for f in "${FLOW}" "${PROMOTE}" "${LESSONS}"; do
  if grep -Fq -- "Opus 4.7" "${f}"; then
    fail "$(basename "${f}"): vendor model version 'Opus 4.7' leaked into policy body"
  fi
done

# ── line budgets: routed-context policies stay under the 200-line ceiling ──
for f in "${FLOW}" "${PROMOTE}" "${LESSONS}"; do
  lines="$(wc -l < "${f}")"
  [[ "${lines}" -lt 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS"
