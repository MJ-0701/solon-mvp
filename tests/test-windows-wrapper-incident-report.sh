#!/usr/bin/env bash
# Windows wrapper incident report documentation guard.
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

  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

ko_report="${DIST_DIR}/docs/ko/windows-wrapper-incident-0.6.37.md"
en_report="${DIST_DIR}/docs/en/windows-wrapper-incident-0.6.37.md"
changelog="${DIST_DIR}/CHANGELOG.md"
release_notes="${DIST_DIR}/RELEASE-NOTES.md"

if [[ ! -f "${changelog}" && -f "${DIST_DIR}/../CHANGELOG.md" ]]; then
  changelog="${DIST_DIR}/../CHANGELOG.md"
fi
if [[ ! -f "${release_notes}" && -f "${DIST_DIR}/../RELEASE-NOTES.md" ]]; then
  release_notes="${DIST_DIR}/../RELEASE-NOTES.md"
fi

assert_contains "${ko_report}" "fatal error - couldn't create signal pipe, Win32 error 5" "KO report Win32 error"
assert_contains "${ko_report}" "sfs.cmd -> sfs.ps1 -> Bash runtime" "KO report fixed bridge"
assert_contains "${ko_report}" "usage-only" "KO report usage-only"
assert_contains "${ko_report}" "한국어 깨짐" "KO report mojibake"
assert_contains "${ko_report}" "sfs.cmd start \"이미지 프롬프트 고도화\"" "KO report repro command"
assert_contains "${ko_report}" "Homebrew installed layout" "KO report installed layout"
assert_contains "${ko_report}" "TIVE_READONLY_DONE" "KO report batch replacement tail"
assert_contains "${ko_report}" 'Windows self-upgrade 의 소유자는 `sfs.ps1`' "KO report ps1 self-upgrade owner"
assert_contains "${ko_report}" "sprint 디렉터리가 비어 있는 것 자체는 버그가 아닙니다" "KO report start semantics"

assert_contains "${en_report}" "fatal error - couldn't create signal pipe, Win32 error 5" "EN report Win32 error"
assert_contains "${en_report}" "sfs.cmd -> sfs.ps1 -> Bash runtime" "EN report fixed bridge"
assert_contains "${en_report}" "usage-only" "EN report usage-only"
assert_contains "${en_report}" "mojibake" "EN report mojibake"
assert_contains "${en_report}" "sfs.cmd start \"이미지 프롬프트 고도화\"" "EN report repro command"
assert_contains "${en_report}" "Homebrew installed layout" "EN report installed layout"
assert_contains "${en_report}" "TIVE_READONLY_DONE" "EN report batch replacement tail"
assert_contains "${en_report}" 'Windows self-upgrade belongs in `sfs.ps1`' "EN report ps1 self-upgrade owner"
assert_contains "${en_report}" 'An empty sprint directory after `sfs start` is not, by itself, a bug' "EN report start semantics"

assert_contains "${DIST_DIR}/docs/ko/index.md" "windows-wrapper-incident-0.6.37.md" "KO index report link"
assert_contains "${DIST_DIR}/docs/en/index.md" "windows-wrapper-incident-0.6.37.md" "EN index report link"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape.md" "Windows 래퍼 안정화" "KO product shape wrapper section"
assert_contains "${DIST_DIR}/docs/en/current-product-shape.md" "Windows Wrapper Stabilization" "EN product shape wrapper section"
assert_contains "${DIST_DIR}/GUIDE.md" "Windows SFS 래퍼 장애 요약 보고서" "GUIDE report link"
assert_contains "${DIST_DIR}/docs/en/guide.md" "Windows SFS wrapper incident report" "EN guide report link"
assert_contains "${release_notes}" "Windows SFS 래퍼 장애 요약 보고서" "release notes report link"
assert_contains "${changelog}" "Windows wrapper incident reports" "CHANGELOG report entry"

echo "test-windows-wrapper-incident-report: OK"
