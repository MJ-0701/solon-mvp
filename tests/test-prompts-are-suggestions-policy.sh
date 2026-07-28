#!/usr/bin/env bash
# BLOG-2026-07-24-2 — long-horizon autonomy: invariants live in the harness.
#
# Locks five delta anchors: PROMPTS_ARE_SUGGESTIONS / INVARIANT_LIVES_IN_HARNESS
# (an always-rule in prose has a decay curve; move it to an enforcement
# surface), BE_THE_AGENT_FIRST (fix the standard by hand before automating),
# REFLECTION_TO_EVAL_PIPELINE (structured manual review -> eval case, judge
# agent scores transcripts, tool-gap self-report as SIGNAL),
# CONSTRAIN_ORCHESTRATION_FREE_JUDGMENT (constrain the orchestration layer, not
# the judgment interval), and INGRESS_TRUST_CHECKPOINT (per-touch injection
# check with the hijack assumed and bounded). Vendor identities and business
# figures are locked out.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
HA="${POL}/harness-autonomy.md"
SIL="${POL}/self-improvement-loop.md"
CAP="${POL}/sub-agent-capsule-contract.md"
CRED="${POL}/credential-hygiene.md"
EVALS="${DIST_DIR}/templates/.sfs-local-template/evals/README.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }

# ── (a) anchors in their owning files ───────────────────────────────
fanchor "${HA}" "PROMPTS_ARE_SUGGESTIONS" "prompts-are-suggestions anchor"
fanchor "${HA}" "INVARIANT_LIVES_IN_HARNESS" "invariant-in-harness anchor"
fanchor "${SIL}" "BE_THE_AGENT_FIRST" "be-the-agent-first anchor"
fanchor "${SIL}" "REFLECTION_TO_EVAL_PIPELINE" "reflection-to-eval anchor"
fanchor "${CAP}" "CONSTRAIN_ORCHESTRATION_FREE_JUDGMENT" "orchestration/judgment anchor"
fanchor "${CRED}" "INGRESS_TRUST_CHECKPOINT" "ingress checkpoint anchor"

# ── (b) the substance, not just the names ───────────────────────────
fhas "${HA}" "decay curve" "prompt-instruction decay named"
fhas "${HA}" "must hold **every time**" "the every-time criterion"
fhas "${HA}" "reclaims the context budget" "context-budget reclamation"
fhas "${SIL}" "by hand" "manual run precedes automation"
fhas "${SIL}" "definition of \"good\"" "manual run fixes the standard"
fhas "${SIL}" "judge agent" "transcript scoring delegated to a judge"
fhas "${SIL}" "tool-gap self-report" "tool-gap self-report as SIGNAL"
fhas "${SIL}" "speed instrument before it is a" "eval-as-speed-instrument framing"
fhas "${CAP}" "how it is solved is free" "placement rule, not a strength dial"
fhas "${CAP}" "pin the method rather than the outcome" "the over-constraint failure mode"
fhas "${CRED}" "per-touch, not per-session" "checkpoint cadence"
fhas "${CRED}" "Assume a successful hijack" "hijack assumed and bounded"

# ── (c) SIGNAL stage actually consumes the self-report ──────────────
awk '/1\. \*\*SIGNAL\*\*/,/2\. \*\*RECORD\*\*/' "${SIL}" \
  | grep -q 'tool-gap self-report' || fail "SIGNAL stage does not list the tool-gap self-report"

# ── (d) evals scaffold carries the upstream step by-reference ───────
fanchor "${EVALS}" "BE_THE_AGENT_FIRST" "evals README points at the upstream step"
fhas "${EVALS}" "self-improvement-loop.md" "evals README names the SSoT"
LC_ALL=C grep -Fq -- "여기서 재나열하지 않습니다" "${EVALS}" \
  || fail "evals README: pointer-only convention line missing"

# ── (e) by-reference to existing owners ─────────────────────────────
fhas "${HA}" "steering-surface-taxonomy.md" "ref: placement scorer"
fhas "${HA}" "BOUNDS_OUTLIVE_MODEL_LIMITS" "ref: permission-not-prompting anchor"
fhas "${SIL}" "HELD_OUT_SCORING" "ref: held-out scoring owner"
fhas "${SIL}" "JUDGE_NEGATIVE_CONTROL" "ref: judge validation owner"
fhas "${CAP}" "LEAST_AGENCY_VERB_SCOPING" "ref: the constraint it must not overreach"
fhas "${CAP}" "PROMPTS_ARE_SUGGESTIONS" "ref: the harness half of the split"
fhas "${CRED}" "FOUR_QUESTION_RISK_PREFLIGHT" "ref: the preflight it complements"
fhas "${CRED}" "source-pointer-citation.md" "ref: fetched-content-is-data owner"

# ── (f) routed index carries the new routes ─────────────────────────
for anchor in BE_THE_AGENT_FIRST REFLECTION_TO_EVAL_PIPELINE \
              CONSTRAIN_ORCHESTRATION_FREE_JUDGMENT INGRESS_TRUST_CHECKPOINT; do
  fanchor "${INDEX}" "${anchor}" "index route"
done

# ── (g) additive guarantee — existing anchors preserved ─────────────
fanchor "${SIL}" "SIGNAL" "self-improvement stage preserved"
fhas "${SIL}" "measured-but-not-sufficient" "invariant preserved"
fhas "${SIL}" "by-reference only" "charter line preserved"
fanchor "${CAP}" "DONE_IS_ARTIFACT_ON_DISK" "capsule anchor preserved"
fanchor "${CAP}" "SHARED_SURFACE_CONFLICT_SCAN" "capsule anchor preserved"
fanchor "${CRED}" "GRANT_LIFECYCLE" "credential anchor preserved"
fanchor "${CRED}" "ROTATION_SINGLE_POINT" "credential anchor preserved"

# ── (h) vendor / figure lockout ─────────────────────────────────────
for f in "${POL}"/*.md "${CTX}"/commands/*.md "${CTX}"/kernel.md "${INDEX}" "${EVALS}"; do
  if grep -Eiq 'outtake|recon agent|palantir|blastbox' "${f}"; then
    fail "$(basename "${f}"): vendor identity leaked"
  fi
done
for f in "${HA}" "${SIL}" "${CAP}" "${CRED}"; do
  if grep -Eq '\bARR\b|[0-9]+x ARR|\b20M\b|\b6x\b|\b10x\b' "${f}"; then
    fail "$(basename "${f}"): business figure leaked into the promoted principle"
  fi
done

# ── (i) line budget ─────────────────────────────────────────────────
for f in "${HA}" "${SIL}" "${CAP}" "${CRED}" "${EVALS}" "${INDEX}"; do
  lines="$(wc -l < "${f}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS: prompts-are-suggestions + be-the-agent-first + ingress checkpoint locked"
