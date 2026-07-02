#!/usr/bin/env bash
# Drift-lock: split aggregates must stay in sync with their split dirs.
#
# Found during the 0.8.57 self-audit: the current-product-shape aggregate's
# `split_children:` frontmatter had drifted (stopped at 23) while the body
# "Document Map" link list had a different gap (missing 23, carrying 24-26) —
# neither listed every numbered child, and no test caught it. The 0.8.58
# self-audit then found the SAME drift on the 10x-value aggregates (en
# frontmatter missing 13, ko frontmatter missing 12), so this lock now covers
# every split aggregate, per language: adding a numbered child without wiring
# both lists fails CI.
#
# Per aggregate x language: every NN-*.md in docs/<lang>/<agg>/ must appear
# (a) in the aggregate `split_children:` path form and (b) in the body link
# list; and every entry on either list must point to a file that exists (no
# dangling). ASCII-only assertions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

# aggregate-name:minimum-child-count-across-ko+en (bash-3.2: no assoc arrays)
AGGREGATES="current-product-shape:56 10x-value:25"

total=0
for spec in ${AGGREGATES}; do
  name="${spec%%:*}"
  min="${spec##*:}"
  checked=0
  for lang in ko en; do
    agg="${DIST_DIR}/docs/${lang}/${name}.md"
    dir="${DIST_DIR}/docs/${lang}/${name}"
    [[ -f "${agg}" ]] || fail "missing aggregate: ${agg}"
    [[ -d "${dir}" ]] || fail "missing split dir: ${dir}"

    # Forward: every numbered child file is listed in BOTH surfaces.
    for path in "${dir}"/[0-9]*.md; do
      base="$(basename "${path}")"
      grep -Fq "docs/${lang}/${name}/${base}" "${agg}" \
        || fail "${lang}/${name}: ${base} missing from split_children frontmatter"
      grep -Fq "./${name}/${base}" "${agg}" \
        || fail "${lang}/${name}: ${base} missing from body Document Map link list"
      checked=$((checked + 1))
    done

    # Reverse: every split_children entry points to a file that exists.
    while IFS= read -r child; do
      [[ -n "${child}" ]] || continue
      [[ -f "${DIST_DIR}/${child}" ]] \
        || fail "${lang}/${name}: split_children entry has no file: ${child}"
    done < <(grep -oE "docs/${lang}/${name}/[0-9][^ ]*\.md" "${agg}" | sort -u)

    # Reverse: every body link points to a file that exists.
    while IFS= read -r rel; do
      [[ -n "${rel}" ]] || continue
      [[ -f "${dir}/${rel}" ]] \
        || fail "${lang}/${name}: body link has no file: ${name}/${rel}"
    done < <(grep -oE "\./${name}/[0-9][^)]*\.md" "${agg}" | sed "s#\./${name}/##" | sort -u)
  done
  [[ "${checked}" -ge "${min}" ]] \
    || fail "${name}: expected >=${min} child checks across ko+en, got ${checked}"
  total=$((total + checked))
done

echo "test-current-product-shape-split-sync: OK (${total} child entries synced across aggregates x ko+en)"
