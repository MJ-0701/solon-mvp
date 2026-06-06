#!/usr/bin/env bash
# WU-4: user-context separation (soul / user / procedure 3-split).
#
# Locks the new operator-context placeholder file (placeholders only, no fixed
# operator values) and the policy that documents the three-layer split, plus the
# index route. ASCII anchors.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TPL="${DIST_DIR}/templates/.sfs-local-template"
CTX="${TPL}/context"
OPERATOR="${TPL}/operator-context.md"
POLICY="${CTX}/policies/user-context-separation.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── Operator-context placeholder file ──────────────────────────────
[[ -f "${OPERATOR}" ]] || fail "missing operator-context.md"
has "${OPERATOR}" "doc_id: sfs-operator-context" "operator frontmatter id"
sed -n '1p' "${OPERATOR}" | grep -qx -- '---' || fail "operator-context missing opening frontmatter"

# Every operator field must be a placeholder, not a baked value.
grep -Eq '<OPERATOR-[A-Z-]+>' "${OPERATOR}" || fail "operator-context has no placeholders"
# Catch the obvious fixed-value leak: a 'Role / hat' or 'Working language' line
# whose value is filled rather than a placeholder.
if grep -E '^\- \*\*(Role|Working language|Reporting channel)' "${OPERATOR}" \
     | grep -qvE '<OPERATOR-[A-Z-]+>'; then
  fail "operator-context ships a fixed value where a placeholder is required"
fi
if grep -Eq '/Users/|/home/[a-z]' "${OPERATOR}"; then
  fail "operator-context leaks an absolute private path"
fi

# ── Policy: three-layer split ──────────────────────────────────────
[[ -f "${POLICY}" ]] || fail "missing user-context-separation.md"
has "${POLICY}" "id: sfs-user-context-separation" "policy frontmatter id"
grep -q '^load_when:' "${POLICY}" || fail "policy missing load_when"
has "${POLICY}" "THREE_LAYERS" "three-layers section anchor"
has "${POLICY}" "Soul" "soul layer"
has "${POLICY}" "User" "user layer"
has "${POLICY}" "Procedure" "procedure layer"
has "${POLICY}" "operator-context.md" "points at operator file"
has "${POLICY}" "personas/" "points at soul home"
has "${POLICY}" "TEMPLATE_DISCIPLINE" "placeholder-discipline anchor"

has "${CTX}/_INDEX.md" "policies/user-context-separation.md" "index route"

echo "test-user-context-separation: OK"
