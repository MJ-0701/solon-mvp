#!/usr/bin/env bash
# BLOG-2026-06-19-1 "Steering Claude Code" absorption — headline.
#
# Locks the steering-surface decision frame (generalized; vendor surface names
# + the host managed-settings mechanism held by-reference):
#   (a) new policy steering-surface-taxonomy.md — four axes (load-timing /
#       compaction / context-cost / authority) mapped to solon surfaces
#       (entry stub always-load / routed load_when trigger-scoped / Gate·hook
#       deterministic / capsule final-message-only), routed + <200 lines;
#   (b) critical-rule-hook-promotion gains the managed-settings authority
#       ceiling note — by-reference, solon operator overrides all;
#   (c) sub-agent-capsule-contract (en+ko) names final-message-only isolation.
# Additive-only: pre-existing anchors in every touched file stay.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
TAX="${CTX}/policies/steering-surface-taxonomy.md"
HOOK="${CTX}/policies/critical-rule-hook-promotion.md"
CAP="${CTX}/policies/sub-agent-capsule-contract.md"
CAP_KO="${CTX}/policies/sub-agent-capsule-contract.ko.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── (a) new taxonomy policy ────────────────────────────────────────
[[ -f "${TAX}" ]] || fail "missing steering-surface-taxonomy.md"
has "${TAX}" "id: sfs-steering-surface-taxonomy" "taxonomy frontmatter id"
has "${TAX}" "load_when:" "taxonomy load_when"
# section anchors
has "${TAX}" "FOUR_AXES" "four-axes section anchor"
has "${TAX}" "PLACEMENT_RULES" "placement-rules section anchor"
has "${TAX}" "DECISION_TABLE" "decision-table section anchor"
# the four axes are all named
has "${TAX}" "Load timing" "axis 1 load-timing"
has "${TAX}" "Compaction behavior" "axis 2 compaction"
has "${TAX}" "Context cost" "axis 3 context-cost"
has "${TAX}" "Authority" "axis 4 authority"
# solon surface mapping for each axis target
has "${TAX}" "entry stub" "solon mapping: entry stub (always-load)"
has "${TAX}" "load_when" "solon mapping: routed load_when (trigger-scoped)"
has "${TAX}" "code-enforced" "solon mapping: Gate/hook (deterministic)"
has "${TAX}" "final-message-only" "solon mapping: capsule isolation"
# the core claim: prose cannot guarantee Every-time/Never rules
has "${TAX}" "Every time X" "prose-cannot-guarantee claim"
has "${TAX}" "Never do Y" "never-do claim"
has "${TAX}" "deterministic enforcement" "promote-to-enforcement"
# managed-settings is by-reference, NOT a solon feature
has "${TAX}" "by-reference" "vendor cited by-reference"
has "${TAX}" "user-override-precedence.md" "operator-overrides-all cross-ref"
# trigger vs path-scoped distinction
has "${TAX}" "path-scoped" "path-scoped vs trigger distinction"

# ── (b) managed-settings authority ceiling in hook-promotion ───────
has "${HOOK}" "managed settings" "hook-promotion managed-settings note"
has "${HOOK}" "by-reference" "hook-promotion by-reference"
has "${HOOK}" "user-override-precedence.md" "hook-promotion operator-overrides-all"
has "${HOOK}" "steering-surface-taxonomy.md" "hook-promotion cross-ref to taxonomy"
# pre-existing hook-promotion anchors preserved (additive guarantee)
has "${HOOK}" "ENFORCEMENT_TIERS" "pre-existing hook tiers anchor preserved"
has "${HOOK}" "PROMOTION_CRITERIA" "pre-existing hook criteria anchor preserved"
has "${HOOK}" "DECLARATIVE_BOUNDARY_SURFACE" "pre-existing boundary anchor preserved"

# ── (c) final-message-only isolation in capsule contract (en + ko) ─
has "${CAP}" "Final-message-only return" "capsule en final-message-only"
has "${CAP}" "bidirectional" "capsule en bidirectional isolation"
has "${CAP_KO}" "Final-message-only return" "capsule ko final-message-only"
has "${CAP_KO}" "양방향" "capsule ko bidirectional isolation"
# pre-existing capsule anchors preserved
has "${CAP}" "Capsule-only" "pre-existing capsule-only rule preserved"
has "${CAP}" "the same instance as the authoring agent" "pre-existing verifier≠author preserved"
has "${CAP_KO}" "저작 agent 와 동일" "pre-existing ko verifier≠author preserved"

# ── index registration (literal route, doc-colocation reverse lock) ──
has "${INDEX}" "policies/steering-surface-taxonomy.md" "index route"

# ── vendor hygiene: no model version leaked into absorbed bodies ────
for f in "${TAX}" "${HOOK}" "${CAP}"; do
  for v in "Opus 4.8" "Opus 4.7" "Claude Code"; do
    if grep -Fq -- "${v}" "${f}"; then
      fail "$(basename "${f}"): vendor token '${v}' leaked into policy body"
    fi
  done
done

# ── line budget: new policy under the 200-line ceiling ─────────────
lines="$(wc -l < "${TAX}")"
[[ "${lines}" -lt 200 ]] || fail "steering-surface-taxonomy.md exceeds 200-line budget (${lines})"

echo "PASS"
