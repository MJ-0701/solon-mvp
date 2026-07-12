#!/usr/bin/env bash
# INSIGHT-2026-07-12 (long-horizon autonomy trust patterns) — headline.
#
# Locks three generalized principles, all additive by-reference:
#   1. PRE_WORK_INVARIANT_DECLARATION — before a migration-grade risky WU,
#      the agent declares the invariants it will preserve as a workbench
#      artifact; the declaration is a verification target (self-generated
#      counterpart of AC) — harness-autonomy
#   2. HONEST_UNKNOWNS — diagnostic artifacts state confidence + unverified
#      items; "stopped at the first plausible conclusion" is a drift
#      finding; docs-level, FCP verdict/exit untouched in both directions
#   3. dogfooding-beats-bench ("trust no eval") — external validation of
#      measured-but-not-sufficient (self-improvement-loop invariant) and
#      HELD_OUT_SCORING (skill-promotion-loop)
# Vendor hygiene: lab/product/model names locked out of touched policies.
# Additive: pre-existing anchors preserved.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

HA="${CTX}/policies/harness-autonomy.md"
FCP="${CTX}/policies/flow-conformance-postflight.md"
FC="${CTX}/commands/flowcheck.md"
SIL="${CTX}/policies/self-improvement-loop.md"
SPL="${CTX}/policies/skill-promotion-loop.md"

# ── Principle 1: pre-work invariant declaration ──────────────────────
fhas "${HA}" "PRE_WORK_INVARIANT_DECLARATION" "invariant declaration anchor"
fhas "${HA}" "migration-grade" "risky-WU scope"
fhas "${HA}" "verification target" "declaration-as-verification-target"
fhas "${HA}" "counterpart of acceptance criteria" "self-generated AC twin"
fhas "${HA}" "even when every AC passes" "breach-is-finding rule"

# ── Principle 2: honest unknowns ─────────────────────────────────────
fhas "${FCP}" "HONEST_UNKNOWNS" "FCP honest-unknowns anchor"
LC_ALL=C grep -q "확신도와 미확인 항목을 명시" "${FCP}" || fail "FCP: missing confidence+unverified obligation"
LC_ALL=C grep -q "첫" "${FCP}" || fail "FCP: missing first-plausible-stop wording"
fhas "${FCP}" "drift finding" "first-plausible-stop classified as drift"
fhas "${FCP}" "known-unknowns" "unknowns preflight cross-ref"
fhas "${FCP}" "documentation-level" "docs-level standing (non-invariant)"
fhas "${FC}" "HONEST_UNKNOWNS" "flowcheck command pointer"
fhas "${FC}" "verdict/exit 불변" "flowcheck non-breaking note"

# ── Principle 3: dogfooding beats bench ──────────────────────────────
fhas "${SIL}" "trust no eval" "self-improvement trust-no-eval anchor"
fhas "${SIL}" "dogfooding on real work" "dogfooding wording"
fhas "${SIL}" "field twin" "invariant field-twin standing"
fhas "${SPL}" "Dogfooding-beats-bench" "HELD_OUT_SCORING dogfooding registration"
fhas "${SPL}" "trust no eval" "HELD_OUT_SCORING trust-no-eval wording"

# ── By-reference + vendor hygiene ────────────────────────────────────
fhas "${HA}" "by-reference" "principle 1 by-reference"
fhas "${FCP}" "by-reference" "principle 2 by-reference"
fhas "${SIL}" "by-reference" "principle 3 by-reference"
for f in "${HA}" "${FCP}" "${FC}" "${SIL}" "${SPL}"; do
  if grep -Eiq 'cognition|devin|fable|cowork' "$f"; then
    fail "vendor lab/product/model name leaked into $(basename "$f")"
  fi
done

# ── Budgets ──────────────────────────────────────────────────────────
for f in "${HA}" "${FCP}" "${FC}" "${SIL}" "${SPL}"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

# ── Additive guarantee: pre-existing anchors survive ─────────────────
fhas "${HA}" "fresh-context audit agent" "audit-agent anchor preserved"
fhas "${HA}" "verification capability is the precondition" "autonomy precondition preserved"
fhas "${FCP}" "Verifier context split pattern" "verifier split section preserved"
fhas "${FCP}" "EVENT_LOG_RECONSTRUCTION_SSOT" "event-log SSoT preserved"
fhas "${FCP}" "fcp-verifier-implementer" "invariant registry preserved"
fhas "${FC}" "eval-first" "plan-gate eval-first preserved"
fhas "${FC}" "usage-value" "usage-value signal preserved"
fhas "${SIL}" "measured-but-not-sufficient" "invariant name preserved"
fhas "${SPL}" "HELD_OUT_SCORING" "held-out scoring preserved"
fhas "${SPL}" "repeated-correction trigger" "correction trigger preserved"

echo "PASS: invariant declaration + honest unknowns + dogfooding-beats-bench locked"
