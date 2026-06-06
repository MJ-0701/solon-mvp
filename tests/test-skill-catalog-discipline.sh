#!/usr/bin/env bash
# WU-6: skill-catalog-discipline policy headline test.
#
# Locks the nine-category audit lens, the trigger-centric load_when invariant
# (every routed command carries a non-empty load_when), the on-demand guardrail
# candidates, the setup-via-placeholder cross-link, and the index route.
# Mechanical asserts only -- trigger PROSE quality is a review concern, not
# machine-graded here. ASCII anchors.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/skill-catalog-discipline.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

[[ -f "${POLICY}" ]] || fail "missing skill-catalog-discipline.md"
has "${POLICY}" "id: sfs-skill-catalog-discipline" "frontmatter id"

# Section A -- nine-category lens with the named gap findings.
has "${POLICY}" "NINE_CATEGORY_LENS" "section A anchor"
for bucket in library-reference product-verification data-analysis \
  work-automation scaffolding code-quality-review ci-cd runbook infra-ops; do
  has "${POLICY}" "${bucket}" "category bucket ${bucket}"
done
has "${POLICY}" "GAP CANDIDATE" "named gap (runbook)"
has "${POLICY}" "N/A-by-design" "deliberate absence (data-analysis)"

# Section B -- trigger-centric load_when rule + the lint invariant it claims.
has "${POLICY}" "TRIGGER_CENTRIC_LOAD_WHEN" "section B anchor"

# Section C -- on-demand guardrail candidates.
has "${POLICY}" "ON_DEMAND_GUARDRAIL_CANDIDATES" "section C anchor"
has "${POLICY}" "/careful" "careful guardrail"
has "${POLICY}" "/freeze" "freeze guardrail"

# Section D -- setup-via-placeholder cross-link.
has "${POLICY}" "SETUP_VIA_PLACEHOLDER" "section D anchor"
has "${POLICY}" "AskUserQuestion" "prompt-when-unset"

has "${CTX}/_INDEX.md" "policies/skill-catalog-discipline.md" "index route"

# Lint invariant the policy claims: every routed command AND policy carries a
# non-empty load_when. This is the mechanical part of the trigger-centric rule.
shopt -s nullglob
for f in "${CTX}"/commands/*.md "${CTX}"/policies/*.md; do
  rel="$(basename "$(dirname "${f}")")/$(basename "${f}")"
  line="$(grep -m1 '^load_when:' "${f}" || true)"
  [[ -n "${line}" ]] || fail "routed ${rel} missing load_when"
  case "${line}" in
    *'[]'*) fail "routed ${rel} has empty load_when" ;;
  esac
done

# No private absolute path may leak into the product file.
if grep -Eq '/Users/|/home/[a-z]' "${POLICY}"; then
  fail "skill-catalog-discipline policy leaks an absolute private path"
fi

echo "test-skill-catalog-discipline: OK"
