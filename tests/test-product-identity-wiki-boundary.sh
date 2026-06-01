#!/usr/bin/env bash
# Solon 제품 정체성이 wiki 기능 확장으로 기울지 않는지 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DIST_DIR}/../.." && pwd)"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

readme="${DIST_DIR}/README.md"
readme_solon="${DIST_DIR}/README/01-solon.md"
product_ko="${DIST_DIR}/docs/ko/current-product-shape/01-section.md"
obsidian_en="${DIST_DIR}/docs/en/current-product-shape/19-obsidian-llm-wiki-continuity.md"
obsidian_ko="${DIST_DIR}/docs/ko/current-product-shape/19-obsidian-llm-wiki-continuity.md"
policy_en="${CONTEXT_DIR}/policies/obsidian-llm-wiki.md"
policy_ko="${CONTEXT_DIR}/policies/obsidian-llm-wiki.ko.md"
wiki_home="${REPO_ROOT}/llm-wiki/README.md"

assert_contains "${readme}" "AI 의 속도를 제품 운영으로 바꿔 주는 얇은 레일" "README Solon product rail"
assert_contains "${readme_solon}" "Solon 은 이 문제를 앱 generator 로 풀지 않습니다" "README no generator drift"
assert_contains "${readme_solon}" "Solon 은 그 다음부터의 제품 운영을 맡습니다" "README product operations"
assert_contains "${readme_solon}" "기억 장치는 이 흐름을 더 정확하고 빠르게 만들기 위한 보조 도구" "README wiki support boundary"
assert_contains "${product_ko}" "모호한 의도를 검증 가능한 작업 계약" "product core contract"
assert_contains "${product_ko}" "사람의 판단" "product human judgment"

assert_contains "${obsidian_en}" "Product identity boundary" "EN product identity boundary"
assert_contains "${obsidian_en}" "wiki growth serves SFS flow" "EN wiki serves SFS"
assert_contains "${obsidian_en}" "not a product direction" "EN wiki not direction"
assert_contains "${obsidian_en}" "start -> brainstorm -> plan ->" "EN SFS loop"
assert_contains "${obsidian_ko}" "제품 정체성 경계" "KO product identity boundary"
assert_contains "${obsidian_ko}" "제품 방향이 아닙니다" "KO wiki not direction"
assert_contains "${obsidian_ko}" "SFS 흐름" "KO wiki serves SFS"

assert_contains "${policy_en}" "Product identity boundary" "EN policy identity boundary"
assert_contains "${policy_en}" "instead of Solon product scope" "EN policy defer tooling"
assert_contains "${policy_ko}" "제품 방향이 아니며" "KO policy identity boundary"

if [[ -f "${wiki_home}" ]]; then
  assert_contains "${wiki_home}" "wiki 자체가 제품 방향" "wiki home anti-drift"
  assert_contains "${wiki_home}" "SFS flow" "wiki home SFS flow"
fi

for file in "${readme}" "${readme_solon}" "${obsidian_en}" "${obsidian_ko}" "${policy_en}" "${policy_ko}"; do
  assert_not_contains "${file}" "wiki-first product" "no wiki-first product ${file}"
  assert_not_contains "${file}" "Obsidian is required" "no required Obsidian ${file}"
  assert_not_contains "${file}" "must use Obsidian" "no must-use Obsidian ${file}"
done

if [[ -f "${wiki_home}" ]]; then
  assert_not_contains "${wiki_home}" "wiki-first product" "no wiki-first product ${wiki_home}"
  assert_not_contains "${wiki_home}" "Obsidian is required" "no required Obsidian ${wiki_home}"
  assert_not_contains "${wiki_home}" "must use Obsidian" "no must-use Obsidian ${wiki_home}"
fi

echo "test-product-identity-wiki-boundary: OK"
