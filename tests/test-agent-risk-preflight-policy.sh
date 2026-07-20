#!/usr/bin/env bash
# BLOG-2026-07-19-1 — agentic-risk frame (3 anchors, vendor/figures locked out).
#
# Locks: FOUR_QUESTION_RISK_PREFLIGHT (credential-hygiene decision lens +
# audit.md pointer), LEAST_AGENCY_VERB_SCOPING (capsule verb-grain
# tools_allowed), BOUNDS_OUTLIVE_MODEL_LIMITS (harness-autonomy, cross-ref to
# MODEL_UPGRADE_SETUP_AUDIT).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
CRED="${CTX}/policies/credential-hygiene.md"
CAP="${CTX}/policies/sub-agent-capsule-contract.md"
HA="${CTX}/policies/harness-autonomy.md"
AUDIT="${CTX}/commands/audit.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── (a) four-question preflight ──────────────────────────────────────
fhas "${CRED}" "FOUR_QUESTION_RISK_PREFLIGHT" "preflight anchor"
fhas "${CRED}" "untrusted content" "ingest question"
fhas "${CRED}" "under whose identity" "actions+identity question"
fhas "${CRED}" "Blast radius" "blast-radius question"
fhas "${CRED}" "Observability" "observability question"
fhas "${CRED}" "move fast" "zero-untrusted-ingest speed rule"
fhas "${CRED}" "suggest-only decision lens" "no hard block"
fhas_ko "${AUDIT}" "FOUR_QUESTION_RISK_PREFLIGHT" "audit.md preflight pointer"

# ── (b) least-agency verb scoping ────────────────────────────────────
fhas "${CAP}" "LEAST_AGENCY_VERB_SCOPING" "capsule verb-scoping anchor"
fhas "${CAP}" "verb/action" "verb-grain rule"
fhas "${CAP}" "by-construction block" "removal-beats-prompting rule"
fhas "${CAP}" "DECLARATIVE_BOUNDARY_SURFACE" "typed-boundary cross-ref"

# ── (c) bounds outlive model limits ──────────────────────────────────
fhas "${HA}" "BOUNDS_OUTLIVE_MODEL_LIMITS" "harness bounds anchor"
fhas "${HA}" "what the operator
  permits" "operator-permission basis"
fhas "${HA}" "MODEL_UPGRADE_SETUP_AUDIT" "setup-audit cross-ref"
fhas "${HA}" "it is not a breach" "emergent-in-bounds rule"

# ── additive guarantee ───────────────────────────────────────────────
fhas "${CRED}" "PLACEHOLDER_ONLY_SURFACES" "cred placeholder anchor preserved"
fhas "${CRED}" "AGENT_IDENTITY" "cred identity anchor preserved"
fhas "${CRED}" "GRANT_LIFECYCLE" "cred grant anchor preserved"
fhas "${CRED}" "ROTATION_SINGLE_POINT" "cred rotation anchor preserved"
fhas "${CAP}" "tools_allowed" "capsule tools field preserved"
fhas "${CAP}" "exemplar" "capsule exemplar preserved"
fhas_ko "${AUDIT}" "안전 경계" "audit safety boundary preserved"

# ── vendor lockout ───────────────────────────────────────────────────
for f in "${CRED}" "${CAP}" "${HA}" "${AUDIT}"; do
  if grep -Eiq 'ponemon|deputy ciso|\bcowork\b|claude tag' "${f}"; then
    fail "$(basename "${f}"): vendor/report name leaked"
  fi
done

# ── budgets ──────────────────────────────────────────────────────────
for f in "${CRED}" "${CAP}" "${HA}" "${AUDIT}"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

echo "PASS: agent risk preflight + verb scoping + durable bounds locked"
