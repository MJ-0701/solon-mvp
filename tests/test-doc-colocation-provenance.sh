#!/usr/bin/env bash
# WU-7: doc-colocation-provenance policy headline test.
#
# Locks: the policy exists and is routed; the reference-doc skeleton fields and
# five provenance fields are present (SSoT lives in this one policy); the 7-step
# doc cross-links provenance instead of restating fields; and the REVERSE
# colocation invariant -- every literal _INDEX route resolves to an existing
# file (glob `*` lines skipped). The FORWARD direction is review-time process,
# deliberately NOT a static assert. ASCII anchors.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/doc-colocation-provenance.md"
SEVEN="${DIST_DIR}/docs/maintenance/methodology-7-step.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

[[ -f "${POLICY}" ]] || fail "missing doc-colocation-provenance.md"
has "${POLICY}" "id: sfs-doc-colocation-provenance" "frontmatter id"

# Section anchors.
has "${POLICY}" "COLOCATION_RULE" "colocation anchor"
has "${POLICY}" "REFERENCE_DOC_SKELETON" "skeleton anchor"
has "${POLICY}" "PROVENANCE_LINE" "provenance anchor"

# Reference-doc skeleton fields.
for field in Grain Scope Usage Gotchas Cross-Ref; do
  has "${POLICY}" "${field}" "skeleton field ${field}"
done

# Five provenance fields, defined here as SSoT.
for field in Source-grade Confidence Reviewed Freshness Owner; do
  has "${POLICY}" "${field}" "provenance field ${field}"
done

# Index route present.
has "${CTX}/_INDEX.md" "policies/doc-colocation-provenance.md" "index route"

# 7-step doc cross-links the provenance policy and must NOT restate the field
# list (SSoT is the policy; restatement is the overclaim-by-duplication we avoid).
has "${SEVEN}" "doc-colocation-provenance" "7-step cross-link"
if grep -Fq "Source-grade" "${SEVEN}"; then
  fail "7-step doc restates provenance fields; cross-link only"
fi

# REVERSE colocation lock: every literal _INDEX route resolves to a real file.
# Glob (`*`) lines are families, skipped.
broken=0
while IFS= read -r route; do
  [[ -f "${CTX}/${route}" ]] || { echo "BROKEN ROUTE: ${route}" >&2; broken=1; }
done < <(grep -oE '(policies|commands)/[A-Za-z0-9._-]+\.md' "${CTX}/_INDEX.md" | sort -u)
[[ "${broken}" -eq 0 ]] || fail "one or more literal _INDEX routes do not resolve"

echo "test-doc-colocation-provenance: OK"
