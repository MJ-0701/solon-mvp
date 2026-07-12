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

[[ "${plain_output}" == "sfs 0.8.67" ]] || fail "plain version output changed: ${plain_output}"
assert_contains_text "${output}" "sfs 0.8.67" "version output"
assert_contains_text "${output}" "latest 0.8.67" "latest output"
# Headline drift-lock: the printed headline must (a) reproduce, byte-for-byte, the
# `> **...**` blockquote the awk extracts from CHANGELOG for the installed version
# (so the machinery and the source file stay in sync), and (b) carry the version's
# distinctive opening clause (so a stale CHANGELOG can't silently pass). Deriving
# (a) from source avoids a brittle hand-escaped megastring while staying a real lock.
expected_changelog_headline="$(
  awk -v version="$(head -1 "${DIST_DIR}/VERSION")" '
    $0 ~ "^## \\[" version "\\]" { in_entry=1; next }
    in_entry && /^## / { exit }
    in_entry && /^> / { line=$0; sub(/^> /,"",line); gsub(/\*\*/,"",line); h=h (h?" ":"") line; next }
    in_entry && h != "" { exit }
    END { if (h!=""){ gsub(/[[:space:]]+/," ",h); sub(/^[[:space:]]+/,"",h); sub(/[[:space:]]+$/,"",h); print h } }
  ' "${DIST_DIR}/CHANGELOG.md"
)"
[[ -n "${expected_changelog_headline}" ]] || fail "no CHANGELOG headline for installed version"
assert_contains_text "${output}" "installed_release_headline ${expected_changelog_headline}" "installed release headline"
assert_contains_text "${output}" "dispatch layer routes only" "0.8.67 headline opening clause"
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

# Fallback headline (no CHANGELOG): first non-empty line of the RELEASE-NOTES
# `## <version>` section. Same derive-from-source drift-lock + a distinctive substring.
expected_notes_headline="$(
  awk -v version="$(head -1 "${fallback_dist}/VERSION")" '
    $0 == "## " version { in_entry=1; next }
    in_entry && /^## / { exit }
    in_entry && $0 != "" { line=$0; gsub(/[[:space:]]+/," ",line); sub(/^[[:space:]]+/,"",line); sub(/[[:space:]]+$/,"",line); print line; exit }
  ' "${fallback_dist}/RELEASE-NOTES.md"
)"
[[ -n "${expected_notes_headline}" ]] || fail "no RELEASE-NOTES headline for installed version"
assert_contains_text "${fallback_output}" "installed_release_headline ${expected_notes_headline}" "release notes fallback headline"
assert_contains_text "${fallback_output}" "dispatcher 는 라우팅만" "0.8.67 release-notes distinctive clause"

echo "test-version-release-headline: OK"
