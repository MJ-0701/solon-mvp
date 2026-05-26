#!/usr/bin/env bash
# Product markdown harness: active user/agent docs stay frontmatter-loadable and split below 200 lines.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DIST_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

is_append_only_release_log() {
  case "$1" in
    "${DIST_DIR}/CHANGELOG.md"|"${DIST_DIR}/RELEASE-NOTES.md") return 0 ;;
    *) return 1 ;;
  esac
}

is_test_fixture() {
  case "$1" in
    "${DIST_DIR}/tests/"*) return 0 ;;
    *) return 1 ;;
  esac
}

while IFS= read -r file; do
  is_test_fixture "${file}" && continue

  lines="$(wc -l <"${file}" | tr -d '[:space:]')"
  if is_append_only_release_log "${file}"; then
    [[ "${lines}" -gt 200 ]] || fail "${file} should remain the explicit append-only release-log exception"
    continue
  fi

  [[ "${lines}" -le 200 ]] || fail "${file} exceeds 200 lines: ${lines}"

  first_line="$(sed -n '1p' "${file}")"
  [[ "${first_line}" == "---" ]] || fail "${file} missing opening frontmatter"
  sed -n '2,40p' "${file}" | grep -Fxq -- "---" || fail "${file} missing closing frontmatter"
done < <(find "${DIST_DIR}" -name '*.md' -type f | sort)

while IFS= read -r file; do
  lines="$(wc -l <"${file}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "${file} exceeds 200 lines: ${lines}"
done < <(find "${DIST_DIR}/templates" -name '*.md.template' -type f | sort)

cut_release="${REPO_ROOT}/scripts/cut-release.sh"
if [[ -f "${cut_release}" ]]; then
  while IFS= read -r file; do
    stem="${file%.md}"
    [[ -d "${stem}" ]] || continue
    item="${stem#"${DIST_DIR}/"}"
    grep -Fxq "  \"${item}\"" "${cut_release}" || \
      fail "split doc payload missing from cut-release allowlist: ${item}"
  done < <(find "${DIST_DIR}" -maxdepth 1 -name '*.md' -type f | sort)
fi

echo "test-product-md-frontmatter-line-budget: OK"
