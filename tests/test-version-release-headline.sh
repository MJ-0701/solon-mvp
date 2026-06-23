#!/usr/bin/env bash
# sfs version --check must anchor summaries to the exact installed release entry.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains_text() {
  local haystack="$1" needle="$2" label="$3"
  grep -Fq -- "${needle}" <<<"${haystack}" || fail "${label}: missing '${needle}'"
}

tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/sfs-version-headline.XXXXXX")"
trap 'rm -rf "${tmpdir}"' EXIT

repo="${tmpdir}/release-repo"
git init -q "${repo}"
git -C "${repo}" config user.email "sfs-test@example.invalid"
git -C "${repo}" config user.name "SFS Test"
git -C "${repo}" commit --allow-empty -qm "seed release repo"
git -C "${repo}" tag "v$(head -1 "${DIST_DIR}/VERSION")"

output="$(
  SFS_DIST_DIR="${DIST_DIR}" \
  SFS_RELEASE_REPO_URL="${repo}" \
  SFS_VERSION_COMMAND_TIMEOUT_SEC=0 \
  "${DIST_DIR}/bin/sfs" version --check
)"

plain_output="$(
  SFS_DIST_DIR="${DIST_DIR}" \
  SFS_RELEASE_REPO_URL="${repo}" \
  SFS_VERSION_COMMAND_TIMEOUT_SEC=0 \
  "${DIST_DIR}/bin/sfs" version
)"

[[ "${plain_output}" == "sfs 0.8.41" ]] || fail "plain version output changed: ${plain_output}"
assert_contains_text "${output}" "sfs 0.8.41" "version output"
assert_contains_text "${output}" "latest 0.8.41" "latest output"
assert_contains_text "${output}" "status up-to-date" "status output"
assert_contains_text "${output}" "installed_release_headline Shipped Markdown surfaces are scrubbed of stray closing-tag litter: 14 files under templates/ and docs/ carried a leftover end-of-file closing tag (a </content>, and in two files also a </invoke>) with no matching opening tag, which shipped into consumer installs; all are removed and a regression test locks them out." "installed release headline"
assert_contains_text "$(cat "${DIST_DIR}/bin/sfs.ps1")" "installed_release_headline" "PowerShell headline output"
assert_contains_text "$(cat "${DIST_DIR}/bin/sfs.ps1")" "Get-SfsReleaseHeadline" "PowerShell headline parser"

fallback_dist="${tmpdir}/dist-without-changelog"
mkdir -p "${fallback_dist}"
cp -R "${DIST_DIR}/bin" "${fallback_dist}/bin"
mkdir -p "${fallback_dist}/templates/.sfs-local-template/scripts"
cp "${DIST_DIR}/VERSION" "${fallback_dist}/VERSION"
cp "${DIST_DIR}/RELEASE-NOTES.md" "${fallback_dist}/RELEASE-NOTES.md"

fallback_output="$(
  SFS_DIST_DIR="${fallback_dist}" \
  SFS_RELEASE_REPO_URL="${repo}" \
  SFS_VERSION_COMMAND_TIMEOUT_SEC=0 \
  "${fallback_dist}/bin/sfs" version --check
)"

assert_contains_text "${fallback_output}" "installed_release_headline Shipped Markdown surfaces are scrubbed of stray closing-tag litter: 14 files under templates/ and docs/ carried a leftover end-of-file closing tag (a </content>, and in two files also a </invoke>) with no matching opening tag, which shipped into consumer installs; all are removed and a regression test locks them out." "release notes fallback headline"

echo "test-version-release-headline: OK"
