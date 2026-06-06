#!/usr/bin/env bash
# WU-2: critical-rule hook-promotion criteria policy headline test.
#
# Locks the three enforcement tiers, the promotion criteria (severity +
# detectability + pre-action interception, recurrence escalator), the example
# classification, and the wiring-home cross-link to the on-demand guardrail
# candidates. Mechanical ASCII asserts only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/critical-rule-hook-promotion.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

[[ -f "${POLICY}" ]] || fail "missing critical-rule-hook-promotion.md"
has "${POLICY}" "id: sfs-critical-rule-hook-promotion" "frontmatter id"
grep -q '^load_when:' "${POLICY}" || fail "policy missing load_when"

# Three tiers.
has "${POLICY}" "ENFORCEMENT_TIERS" "tiers section anchor"
has "${POLICY}" "Tier A" "tier A"
has "${POLICY}" "Tier B" "tier B"
has "${POLICY}" "Tier C" "tier C"
has "${POLICY}" "100%" "hooks 100-percent enforcement claim"

# Promotion criteria.
has "${POLICY}" "PROMOTION_CRITERIA" "criteria section anchor"
has "${POLICY}" "Severity" "criterion severity"
has "${POLICY}" "Mechanical detectability" "criterion detectability"
has "${POLICY}" "Recurrence" "recurrence escalator"

# Classification examples include the canonical critical cases.
has "${POLICY}" "CLASSIFICATION_EXAMPLES" "examples section anchor"
has "${POLICY}" ".env" "secret leak example"
has "${POLICY}" "rm -rf" "destructive command example"

# Wiring home cross-links the existing candidates, does not re-document them.
has "${POLICY}" "WIRING_HOME" "wiring section anchor"
has "${POLICY}" "skill-catalog-discipline.md" "cross-link to guardrail candidates"
has "${POLICY}" "settings.json" "hook surface"

has "${CTX}/_INDEX.md" "policies/critical-rule-hook-promotion.md" "index route"

# No private absolute path may leak into the product file.
if grep -Eq '/Users/|/home/[a-z]' "${POLICY}"; then
  fail "critical-rule-hook-promotion policy leaks an absolute private path"
fi

echo "test-critical-rule-hook-promotion: OK"
