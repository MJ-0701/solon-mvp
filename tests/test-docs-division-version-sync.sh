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
  "${DIST_DIR}/GUIDE.md"
  "${DIST_DIR}/docs/ko/index.md"
  "${DIST_DIR}/docs/ko/current-product-shape.md"
  "${DIST_DIR}/docs/ko/10x-value.md"
  "${DIST_DIR}/docs/en/index.md"
  "${DIST_DIR}/docs/en/current-product-shape.md"
  "${DIST_DIR}/docs/en/10x-value.md"
  "${DIST_DIR}/docs/en/guide.md"
)

for file in "${docs[@]}"; do
  assert_not_contains "${file}" "0.6.26" "docs no stale 0.6.26 ${file}"
  assert_not_contains "${file}" "0.6.27" "docs no stale 0.6.27 ${file}"
  assert_not_contains "${file}" "As of 0.6.26" "docs no stale As of 0.6.26 ${file}"
  assert_not_contains "${file}" "0.6.27 기준" "docs no stale 0.6.27 기준 ${file}"
done

assert_contains "${DIST_DIR}/VERSION" "0.6.87" "version bumped"
assert_not_contains "${DIST_DIR}/README.md" "0.6." "README no release-version prose"
assert_not_contains "${DIST_DIR}/README.md" "divisions.yaml" "README no division registry detail"
assert_not_contains "${DIST_DIR}/README.md" "management-admin" "README no lens registry detail"
assert_contains "${DIST_DIR}/docs/ko/10x-value.md" "## 모델 라우팅 10x 루프" "KO 10x model routing detail"
assert_contains "${DIST_DIR}/docs/en/10x-value.md" "## Model Routing 10x Loop" "EN 10x model routing detail"

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
