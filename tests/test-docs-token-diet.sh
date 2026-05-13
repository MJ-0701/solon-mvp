#!/usr/bin/env bash
# Token Diet 사용자 문서가 품질 보존형 compact I/O 로 설명되는지 검증한다.
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
    fail "${label}: unexpected '${needle}'"
  fi
}

assert_not_contains "${DIST_DIR}/README.md" "Token Diet" "README stays introductory"
assert_not_contains "${DIST_DIR}/README.md" "SFS_OUTPUT_STYLE" "README no output-style detail"

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
  assert_contains "${file}" "Token Diet" "docs name Token Diet ${file}"
  assert_contains "${file}" "Caveman/persona" "docs persona opt-in boundary ${file}"
done

command_docs=(
  "${DIST_DIR}/GUIDE.md"
  "${DIST_DIR}/docs/ko/index.md"
  "${DIST_DIR}/docs/ko/current-product-shape.md"
  "${DIST_DIR}/docs/en/index.md"
  "${DIST_DIR}/docs/en/current-product-shape.md"
  "${DIST_DIR}/docs/en/guide.md"
)

for file in "${command_docs[@]}"; do
  assert_contains "${file}" "SFS_OUTPUT_STYLE=compact" "docs compact env ${file}"
  assert_contains "${file}" "sfs status --compact" "docs status compact ${file}"
  assert_contains "${file}" "--output-style compact" "docs output style flag ${file}"
done

assert_contains "${DIST_DIR}/GUIDE.md" "path, next action, alternative mode, archive path" "GUIDE trace fields"
assert_contains "${DIST_DIR}/GUIDE.md" "full clarity" "GUIDE full clarity fallback"
assert_contains "${DIST_DIR}/docs/en/current-product-shape.md" "evidence, risk, and raw traceability" "EN quality floor"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape.md" "evidence/risk/raw traceability" "KO quality floor"
assert_contains "${DIST_DIR}/docs/en/10x-value.md" "Raw-text fallback" "EN raw text fallback"
assert_contains "${DIST_DIR}/docs/ko/10x-value.md" "Raw-text fallback" "KO raw text fallback"
assert_contains "${DIST_DIR}/docs/en/current-product-shape.md" "not a broad one-file-one-function rule" "EN no filefunc transplant"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape.md" "one-file-one-function 규칙이 아니라" "KO no filefunc transplant"
assert_contains "${DIST_DIR}/GUIDE.md" "0.6.85부터 release verifier" "GUIDE release verifier quiet evidence"
assert_contains "${DIST_DIR}/docs/ko/index.md" "0.6.85에서는 release verifier" "KO index release verifier quiet evidence"
assert_contains "${DIST_DIR}/docs/en/index.md" "As of 0.6.85, the release verifier" "EN index release verifier quiet evidence"
assert_contains "${DIST_DIR}/docs/en/guide.md" "release verifier follows the same evidence floor" "EN guide release verifier evidence floor"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape.md" "[verify-product-release]" "KO current product release verifier prefix"
assert_contains "${DIST_DIR}/docs/en/current-product-shape.md" "release evidence remains traceable" "EN current product release verifier traceability"
assert_contains "${DIST_DIR}/docs/ko/10x-value.md" "Quiet release verifier" "KO 10x release verifier loop"
assert_contains "${DIST_DIR}/docs/en/10x-value.md" "Quiet release verifier" "EN 10x release verifier loop"

assert_contains "${DIST_DIR}/CHANGELOG.md" "## [0.6.84]" "CHANGELOG 0.6.84"
assert_contains "${DIST_DIR}/CHANGELOG.md" "compactness is never a pass condition" "CHANGELOG quality floor"
assert_contains "${DIST_DIR}/CHANGELOG.md" 'Windows native `sfs.cmd status` parity' "CHANGELOG Windows parity"
assert_contains "${DIST_DIR}/CHANGELOG.md" "one-file-one-function/type rule" "CHANGELOG no filefunc transplant"
assert_contains "${DIST_DIR}/CHANGELOG.md" "## [0.6.85]" "CHANGELOG 0.6.85"
assert_contains "${DIST_DIR}/CHANGELOG.md" "failure evidence" "CHANGELOG release verifier evidence"
assert_contains "${DIST_DIR}/CHANGELOG.md" "## [0.6.86]" "CHANGELOG 0.6.86"
assert_contains "${DIST_DIR}/CHANGELOG.md" "test-token-diet-quality-audit.sh" "CHANGELOG 0.6.86 quality audit"
assert_contains "${DIST_DIR}/RELEASE-NOTES.md" "## 0.6.84" "release notes 0.6.84"
assert_contains "${DIST_DIR}/RELEASE-NOTES.md" "짧아져도 evidence, warning, decision, source trace, verification" "release notes trace preservation"
assert_contains "${DIST_DIR}/RELEASE-NOTES.md" "Caveman/persona 말투는 기본값이 아닙니다" "release notes persona not default"
assert_contains "${DIST_DIR}/RELEASE-NOTES.md" "one-file-one-function/type 규칙" "release notes no filefunc transplant"
assert_contains "${DIST_DIR}/RELEASE-NOTES.md" "## 0.6.85" "release notes 0.6.85"
assert_contains "${DIST_DIR}/RELEASE-NOTES.md" "[verify-product-release]" "release notes verifier prefix"
assert_contains "${DIST_DIR}/RELEASE-NOTES.md" "## 0.6.86" "release notes 0.6.86"
assert_contains "${DIST_DIR}/RELEASE-NOTES.md" "Token Diet 를 더 짧게 만드는 릴리스가 아니라" "release notes 0.6.86 quality floor"

echo "test-docs-token-diet: OK"
