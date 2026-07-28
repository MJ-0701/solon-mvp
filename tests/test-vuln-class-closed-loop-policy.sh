#!/usr/bin/env bash
# BLOG-2026-07-23-2 — AI-native SDLC security: closed loop, risk tiering,
# shadow mode, proof-carrying findings, agent-to-agent as blast radius.
#
# Locks five delta anchors and — just as importantly — locks that each one has
# exactly ONE owning file, because three of them sit next to existing loops
# (lessons flywheel, skill promotion, citation validation) that already own the
# mechanism. Vendor figures and security-tool taxonomies are locked out.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POL="${CTX}/policies"
AUDIT="${CTX}/commands/audit.md"
LESSONS="${POL}/lessons-accumulation.md"
WDS="${POL}/work-delegation-and-startup.md"
SKC="${POL}/skill-catalog-discipline.md"
SPC="${POL}/source-pointer-citation.md"
CRED="${POL}/credential-hygiene.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }

# ── (a) delta anchors, each in its owning file ───────────────────────
fanchor "${AUDIT}" "VULNERABILITY_CLASS_CLOSED_LOOP" "closed-loop anchor"
fanchor "${WDS}" "DELEGATION_UNIT_LADDER" "delegation-unit ladder anchor"
fanchor "${SKC}" "SHADOW_MODE_TRUST_LADDER" "shadow-mode ladder anchor"
fanchor "${SPC}" "PROOF_CARRYING_FINDING" "proof-carrying finding anchor"

# ── (b) the substance of each anchor, not just its name ──────────────
LC_ALL=C grep -Fq -- "waiver 만 쌓이는" "${AUDIT}" \
  || fail "audit.md: waiver-without-promotion-is-itself-a-finding rule missing"
fhas "${WDS}" "chunk" "ladder unit: chunk"
fhas "${WDS}" "decision" "ladder unit: decision"
fhas "${WDS}" "risk tier" "ladder input: risk tier"
fhas "${WDS}" "the tier caps the ladder" "tier caps rather than averages"
fhas "${SKC}" "Shadow" "shadow step"
fhas "${SKC}" "sampling audit" "post-promotion sampling audit"
fhas "${SPC}" "hypothesis" "unproven finding reported as hypothesis"
fhas "${CRED}" "Other agents count" "agent-to-agent inside blast radius"
fhas "${CRED}" "never at trusting a peer" "boundary on access/action, not trust"

# ── (c) by-reference to the existing owner, never a second mechanism ─
fhas "${AUDIT}" "FIX_THE_LOOP_NOT_THE_CODE" "audit refs the upstream-fix owner"
fhas "${AUDIT}" "lessons-accumulation.md" "audit refs the promotion ledger"
fhas "${LESSONS}" "VULNERABILITY_CLASS_CLOSED_LOOP" "lessons back-refs audit (bidirectional)"
fhas "${LESSONS}" "sfs audit" "lessons names audit as a signal source"
fhas "${WDS}" "verifier != implementer" "ladder refs the verification precondition"
fhas "${SKC}" "HELD_OUT_SCORING" "shadow ladder refs the scoring owner"
fhas "${SKC}" "MODEL_UPGRADE_SETUP_AUDIT" "shadow ladder refs the model counterpart"
fhas "${SPC}" "commands/dig.md" "proof rule refs the dig card validator"
fhas "${SPC}" "HONEST_UNKNOWNS" "proof rule refs the unknowns contract"
fhas "${SPC}" "SHADOW_MODE_TRUST_LADDER" "proof rule feeds the shadow ladder"

# ── (d) single SSoT — each anchor is defined in exactly one policy ───
for anchor in DELEGATION_UNIT_LADDER SHADOW_MODE_TRUST_LADDER \
              VULNERABILITY_CLASS_CLOSED_LOOP; do
  owners="$(grep -rlEw -- "^## ${anchor}" "${POL}" "${CTX}/commands" 2>/dev/null | wc -l | tr -d '[:space:]')"
  [[ "${owners}" -eq 1 ]] || fail "${anchor}: expected exactly 1 owning section, found ${owners}"
done

# ── (e) routed index carries the new routes ─────────────────────────
for anchor in VULNERABILITY_CLASS_CLOSED_LOOP DELEGATION_UNIT_LADDER \
              SHADOW_MODE_TRUST_LADDER PROOF_CARRYING_FINDING; do
  fanchor "${INDEX}" "${anchor}" "index route"
done

# ── (f) additive guarantee — existing anchors preserved ─────────────
fanchor "${AUDIT}" "SCHEDULED_RUN_CONTRACT" "audit preserved pointer"
fanchor "${WDS}" "DELEGATE_FIVE_FACTORS" "work-delegation preserved anchor"
fanchor "${WDS}" "NORTH_STAR" "work-delegation preserved anchor"
fanchor "${WDS}" "HUMAN_ATTENTION_IS_SCARCE" "work-delegation preserved anchor"
fanchor "${SKC}" "NINE_CATEGORY_LENS" "skill-catalog preserved anchor"
fanchor "${SKC}" "CURATION_SAFETY" "skill-catalog preserved anchor"
fanchor "${SPC}" "CITE_THEN_VALIDATE" "source-pointer preserved anchor"
fanchor "${CRED}" "FOUR_QUESTION_RISK_PREFLIGHT" "credential preserved anchor"
fanchor "${CRED}" "AGENT_IDENTITY" "credential preserved anchor"
fhas "${CRED}" "move fast" "zero-untrusted-ingest fast path preserved"

# ── (g) vendor / figure lockout ─────────────────────────────────────
# Security-tool taxonomies and the source's org figures stay out of policy prose.
for f in "${POL}"/*.md "${CTX}"/commands/*.md "${CTX}"/kernel.md "${INDEX}"; do
  if grep -Eq '\bMITRE\b|\bSIEM\b|\bDAST\b|\bSAST\b' "${f}"; then
    fail "$(basename "${f}"): security-vendor taxonomy leaked"
  fi
done
for f in "${AUDIT}" "${LESSONS}" "${WDS}" "${SKC}" "${SPC}" "${CRED}"; do
  if grep -Eq '80%|8x|16 ?→ ?54|500 OSS' "${f}"; then
    fail "$(basename "${f}"): source figure leaked into the promoted principle"
  fi
done

# ── (h) line budget ─────────────────────────────────────────────────
for f in "${AUDIT}" "${LESSONS}" "${WDS}" "${SKC}" "${SPC}" "${CRED}" "${INDEX}"; do
  lines="$(wc -l < "${f}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS: vulnerability-class closed loop + risk tiering + shadow ladder locked"
