#!/usr/bin/env bash
# 사용자 문서가 최신 모델 라우팅과 Spark 경계를 설명하는지 검증한다.
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
  "${DIST_DIR}/BEGINNER-GUIDE.md"
  "${DIST_DIR}/docs/ko/index.md"
  "${DIST_DIR}/docs/ko/current-product-shape.md"
  "${DIST_DIR}/docs/en/index.md"
  "${DIST_DIR}/docs/en/current-product-shape.md"
  "${DIST_DIR}/docs/en/guide.md"
)

if [[ ! -f "${docs[0]}" && -f "${DIST_DIR}/../README.md" ]]; then
  docs[0]="${DIST_DIR}/../README.md"
fi

for file in "${docs[@]}"; do
  assert_contains "${file}" "gpt-5.3-codex" "docs codex worker ${file}"
  assert_contains "${file}" "gpt-5.3-codex-spark" "docs codex spark ${file}"
  assert_not_contains "${file}" "0.6.17" "docs no stale 0.6.17 ${file}"
done

assert_contains "${docs[0]}" "Codex worker" "README model routing heading"
assert_contains "${docs[0]}" "--agent-mode parallel --agents codex,claude[,gemini]" "README parallel implement option"
assert_contains "${DIST_DIR}/GUIDE.md" "일반 구현 worker 가 아니라" "GUIDE spark helper boundary"
assert_contains "${DIST_DIR}/GUIDE.md" "Single Agent 모드도 구현 직후 review 는 필수" "GUIDE post implement review"
assert_contains "${DIST_DIR}/BEGINNER-GUIDE.md" "AI 모델 이름을 전부 외울 필요도 없습니다" "BEGINNER friendly model explanation"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape.md" "모델 라우팅과 책임 경계" "KO product shape model routing"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape.md" "병렬 agent 구현은 agent 간 cross review evidence" "KO product shape parallel cross review"
assert_contains "${DIST_DIR}/docs/en/current-product-shape.md" "Model Routing And Responsibility Boundaries" "EN product shape model routing"
assert_contains "${DIST_DIR}/docs/en/current-product-shape.md" "record cross review evidence" "EN product shape parallel cross review"
assert_contains "${DIST_DIR}/docs/en/guide.md" '`gpt-5.3-codex-spark` is helper-only' "EN guide spark helper boundary"
assert_contains "${DIST_DIR}/docs/en/guide.md" "Implementation starts in Single Agent mode" "EN guide single default"

echo "test-docs-model-routing: OK"
