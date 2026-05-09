#!/usr/bin/env bash
# README is a product introduction page; detailed release/operating specs belong in guides/10x docs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
README="${DIST_DIR}/README.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local needle="$1"
  grep -Fq -- "${needle}" "${README}" || fail "README missing '${needle}'"
}

assert_not_contains() {
  local needle="$1"
  if grep -Fq -- "${needle}" "${README}"; then
    fail "README should not contain release/spec detail '${needle}'"
  fi
}

[[ -f "${README}" ]] || fail "README missing"

assert_contains "## 왜 Solon인가"
assert_contains "AI 의 속도를 제품 운영으로 바꿔 주는 얇은 레일"
assert_contains "더 깊은 설명은 [Solon 10x 가치]"
assert_contains "## 기본 흐름"
assert_contains "## 설치"
assert_contains "## 문서 지도"

assert_not_contains "0.6."
assert_not_contains "gpt-"
assert_not_contains "gemini-"
assert_not_contains "divisions.yaml"
assert_not_contains "management-admin"
assert_not_contains "reviewable 산출물"
assert_not_contains "operational assumptions"
assert_not_contains "source-docs"
assert_not_contains "api-contract"
assert_not_contains "SFS_REVIEW_"
assert_not_contains "--agent-mode parallel"

line_count="$(wc -l < "${README}" | tr -d ' ')"
[[ "${line_count}" -le 220 ]] || fail "README too long for intro page: ${line_count} lines"

echo "test-readme-intro-hygiene: OK"
