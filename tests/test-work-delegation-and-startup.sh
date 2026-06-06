#!/usr/bin/env bash
# WU-5: work delegation + startup policy headline test.
#
# Locks the five-factor delegation test, the restate-and-clarify startup habit,
# the runtime-selection table, the index route, and the methodology step-1
# cross-link. ASCII anchors.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/work-delegation-and-startup.md"
METH="${DIST_DIR}/docs/maintenance/methodology-7-step.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

[[ -f "${POLICY}" ]] || fail "missing work-delegation-and-startup.md"
has "${POLICY}" "id: sfs-work-delegation-and-startup" "frontmatter id"
grep -q '^load_when:' "${POLICY}" || fail "policy missing load_when"

# Five-factor delegation test.
has "${POLICY}" "DELEGATE_FIVE_FACTORS" "five-factor section anchor"
has "${POLICY}" "Multiple inputs" "factor multiple inputs"
has "${POLICY}" "Produces an artifact" "factor artifact"
has "${POLICY}" "Repeatable" "factor repeatable"
has "${POLICY}" "define \"good\"" "factor define good"
has "${POLICY}" "tedious" "factor tedious middle"

# Restate-and-clarify startup habit.
has "${POLICY}" "RESTATE_AND_CLARIFY" "restate section anchor"
has "${POLICY}" "restates the ask" "restate habit"

# Runtime selection table with the three tiers.
has "${POLICY}" "RUNTIME_SELECTION" "runtime section anchor"
has "${POLICY}" "Quick chat" "tier quick chat"
has "${POLICY}" "Assisted work session" "tier assisted session"
has "${POLICY}" "Autonomous code runtime" "tier autonomous code"

has "${CTX}/_INDEX.md" "policies/work-delegation-and-startup.md" "index route"
has "${METH}" "work-delegation-and-startup.md" "methodology step-1 cross-link"

if grep -Eq '/Users/|/home/[a-z]' "${POLICY}"; then
  fail "work-delegation policy leaks an absolute private path"
fi

echo "test-work-delegation-and-startup: OK"
