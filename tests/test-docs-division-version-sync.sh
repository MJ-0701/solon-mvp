#!/usr/bin/env bash
# README/current product docs must keep version and division/lens terminology in sync.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected stale '${needle}'"
  fi
}

docs=(
  "${DIST_DIR}/README.md"
  "${DIST_DIR}/GUIDE.md"
  "${DIST_DIR}/docs/ko/index.md"
  "${DIST_DIR}/docs/ko/current-product-shape.md"
  "${DIST_DIR}/docs/en/index.md"
  "${DIST_DIR}/docs/en/current-product-shape.md"
  "${DIST_DIR}/docs/en/guide.md"
)

for file in "${docs[@]}"; do
  assert_not_contains "${file}" "0.6.26" "docs no stale 0.6.26 ${file}"
  assert_not_contains "${file}" "0.6.27" "docs no stale 0.6.27 ${file}"
  assert_not_contains "${file}" "As of 0.6.26" "docs no stale As of 0.6.26 ${file}"
  assert_not_contains "${file}" "0.6.27 기준" "docs no stale 0.6.27 기준 ${file}"
done

assert_contains "${DIST_DIR}/VERSION" "0.6.79" "version bumped"
assert_contains "${DIST_DIR}/README.md" "0.6.79 기준으로는 본부, 지식팩, review lens 를 같은 말처럼 섞지 않습니다" "README division/lens split"
assert_contains "${DIST_DIR}/README.md" "6개 core activation slot" "README core activation slots"
assert_contains "${DIST_DIR}/README.md" 'backend 는 `dev` 의 기술' "README backend specialization"
assert_contains "${DIST_DIR}/README.md" "management-admin 은 재무/경리/세무/회계" "README management admin"
assert_contains "${DIST_DIR}/README.md" "언어/분류 lens" "README taxonomy lens"

assert_contains "${DIST_DIR}/docs/ko/current-product-shape.md" "## 본부 / 지식팩 / Review Lens" "KO product shape split section"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape.md" "전체 지식팩/review lens registry 가 아닙니다" "KO product shape registry boundary"
assert_contains "${DIST_DIR}/docs/en/current-product-shape.md" "## Divisions / Knowledge Packs / Review Lenses" "EN product shape split section"
assert_contains "${DIST_DIR}/docs/en/current-product-shape.md" "not the full" "EN product shape registry boundary"

assert_contains "${DIST_DIR}/templates/.sfs-local-template/divisions.yaml" "compatibility surface" "divisions yaml compatibility surface"
assert_contains "${DIST_DIR}/templates/.sfs-local-template/divisions.yaml" "전체 지식팩/review lens registry 가 아니다" "divisions yaml registry boundary"
assert_contains "${DIST_DIR}/templates/.sfs-local-template/divisions.yaml" "taxonomy: cross-cutting language/classification lens, not an org division" "divisions yaml taxonomy boundary"

assert_contains "${DIST_DIR}/templates/.sfs-local-template/context/policies/knowledge-pack-router.md" "not the same surface as" "router divisions boundary"
assert_contains "${DIST_DIR}/templates/.sfs-local-template/context/policies/knowledge-pack-router.ko.md" "같은 표면이 아니다" "router ko divisions boundary"

echo "test-docs-division-version-sync: OK"
