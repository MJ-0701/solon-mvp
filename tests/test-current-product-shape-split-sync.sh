#!/usr/bin/env bash
# Drift-lock: current-product-shape aggregate must stay in sync with its split dir.
#
# Found during the 0.8.57 self-audit: the aggregate's `split_children:`
# frontmatter had drifted (stopped at 23) while the body "Document Map" link
# list had a different gap (missing 23, carrying 24-26) — neither listed every
# numbered child, and no test caught it. This locks all three surfaces together,
# per language, so adding a numbered child without wiring both lists fails CI.
#
# Per language (ko, en): every NN-*.md in docs/<lang>/current-product-shape/
# must appear (a) in the aggregate `split_children:` path form and (b) in the
# body link list; and every entry on either list must point to a file that
# exists (no dangling). ASCII-only assertions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

checked=0
for lang in ko en; do
  agg="${DIST_DIR}/docs/${lang}/current-product-shape.md"
  dir="${DIST_DIR}/docs/${lang}/current-product-shape"
  [[ -f "${agg}" ]] || fail "missing aggregate: ${agg}"
  [[ -d "${dir}" ]] || fail "missing split dir: ${dir}"

  # Forward: every numbered child file is listed in BOTH surfaces.
  for path in "${dir}"/[0-9]*.md; do
    base="$(basename "${path}")"
    grep -Fq "docs/${lang}/current-product-shape/${base}" "${agg}" \
      || fail "${lang}: ${base} missing from split_children frontmatter"
    grep -Fq "./current-product-shape/${base}" "${agg}" \
      || fail "${lang}: ${base} missing from body Document Map link list"
    checked=$((checked + 1))
  done

  # Reverse: every split_children entry points to a file that exists.
  while IFS= read -r child; do
    [[ -n "${child}" ]] || continue
    [[ -f "${DIST_DIR}/${child}" ]] \
      || fail "${lang}: split_children entry has no file: ${child}"
  done < <(grep -oE "docs/${lang}/current-product-shape/[0-9][^ ]*\.md" "${agg}" | sort -u)

  # Reverse: every body link points to a file that exists.
  while IFS= read -r rel; do
    [[ -n "${rel}" ]] || continue
    [[ -f "${dir}/${rel}" ]] \
      || fail "${lang}: body link has no file: current-product-shape/${rel}"
  done < <(grep -oE "\./current-product-shape/[0-9][^)]*\.md" "${agg}" | sed 's#\./current-product-shape/##' | sort -u)
done

[[ "${checked}" -ge 56 ]] || fail "expected >=56 child checks across ko+en, got ${checked}"
echo "test-current-product-shape-split-sync: OK (${checked} child entries synced across ko+en)"
