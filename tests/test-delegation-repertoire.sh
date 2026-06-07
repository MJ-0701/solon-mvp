#!/usr/bin/env bash
# WU-2 delegation repertoire + runtime-table augmentation — headline test.
#
# Locks: the work-delegation policy gains the long-running/scheduled axis and the
# official three-way reconciliation (by-reference, additive); the bilingual
# repertoire doc exists, cross-links the bookend loop, and is linked from the
# parent doc map. Additive-only: the pre-existing RUNTIME_SELECTION table stays.
# ASCII anchors only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/work-delegation-and-startup.md"
KO="${DIST_DIR}/docs/ko/current-product-shape/26-delegation-repertoire.md"
EN="${DIST_DIR}/docs/en/current-product-shape/26-delegation-repertoire.md"
KO_PARENT="${DIST_DIR}/docs/ko/current-product-shape.md"
EN_PARENT="${DIST_DIR}/docs/en/current-product-shape.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# 1) policy augmentation (additive — old table anchor still present).
has "${POLICY}" "RUNTIME_SELECTION" "pre-existing runtime anchor preserved"
has "${POLICY}" "LONG_RUNNING_AND_SCHEDULED" "scheduled-axis anchor"
has "${POLICY}" "cross-app knowledge work" "three-way reconciliation"
has "${POLICY}" "Cowork product guide" "by-reference source"
has "${POLICY}" "commands/daily.md" "policy cross-links bookend loop"

# 2) bilingual repertoire doc exists + frontmatter + cross-links.
for f in "${KO}" "${EN}"; do
  [[ -f "${f}" ]] || fail "missing repertoire doc: ${f}"
  has "${f}" "doc_type: product-reference" "frontmatter doc_type in ${f}"
  has "${f}" "commands/daily.md" "repertoire cross-links daily loop in ${f}"
  has "${f}" "work-delegation-and-startup.md" "repertoire cross-links policy in ${f}"
  has "${f}" "by-reference" "repertoire cites source by-reference in ${f}"
done
has "${KO}" "doc_id: sfs-current-product-shape-ko-26" "ko doc_id"
has "${EN}" "doc_id: sfs-current-product-shape-en-26" "en doc_id"

# 3) parent doc map links it (matches the 24/25 precedent).
has "${KO_PARENT}" "26-delegation-repertoire.md" "ko parent links repertoire"
has "${EN_PARENT}" "26-delegation-repertoire.md" "en parent links repertoire"

echo "test-delegation-repertoire: OK"
