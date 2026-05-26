#!/usr/bin/env bash
# Packaging fixtures must explain the boundary between source templates and live channel repos.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

packaging_readme="${DIST_DIR}/packaging/README.md"
homebrew_fixture="${DIST_DIR}/packaging/homebrew/sfs.rb"
scoop_fixture="${DIST_DIR}/packaging/scoop/sfs.json"

assert_contains "${packaging_readme}" 'Homebrew tap: `MJ-0701/homebrew-solon-product`' "packaging readme homebrew authority"
assert_contains "${packaging_readme}" 'Scoop bucket: `MJ-0701/scoop-solon-product`' "packaging readme scoop authority"
assert_contains "${packaging_readme}" "최신 배포 채널의 SoT 가 아닙니다" "packaging readme fixture boundary"
assert_contains "${packaging_readme}" '`sfs version --check`' "packaging readme installed verification"
assert_contains "${packaging_readme}" "scripts/verify-product-release.sh --version <version>" "packaging readme release verifier"

if grep -Fq "__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__" "${homebrew_fixture}" ||
   grep -Fq "__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__" "${scoop_fixture}"; then
  assert_contains "${packaging_readme}" "__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__" "packaging readme placeholder explanation"
fi

echo "test-packaging-channel-map: OK"
