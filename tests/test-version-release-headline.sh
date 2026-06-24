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

[[ "${plain_output}" == "sfs 0.8.51" ]] || fail "plain version output changed: ${plain_output}"
assert_contains_text "${output}" "sfs 0.8.51" "version output"
assert_contains_text "${output}" "latest 0.8.51" "latest output"
assert_contains_text "${output}" "installed_release_headline Patch release: Windows (PowerShell/Scoop) typed-command argv fix — after an in-session \`sfs upgrade\`, a later \`sfs init\` (or any typed command) was silently rewritten to a stale \`update\`. Root cause: the Scoop self-upgrade reload set \`\$env:SFS_NATIVE_*\` on the in-process PowerShell session and never cleared it, and \`bin/sfs.ps1\` selected that env channel before the typed args, so the stale \`update\` shadowed every later command in the same window (the 0.6.45-0.6.56 / 0.8.50 regression class). Belt-and-suspenders fix: (F1) current typed/automatic args are now authoritative and beat the inherited env channel, which is consulted only when no typed args are present — the cmd-shim path forwards zero positional args, so that bridge stays byte-for-byte; (F2) the self-upgrade reload snapshots and restores \`\$env:SFS_NATIVE_*\` and \`SFS_SKIP_SELF_UPGRADE\`, so the interactive session is never polluted. Also: the not-initialized onboarding hint now branches by OS (Windows -> Scoop/PC, not brew/Mac) and reflects the real typed command, and Windows JSON writes use BOM-less UTF-8 to stop \`Unrecognized token\` failures. No bash behavior changed; bash 0.8.50 stays green (207/207). Locked by \`tests/test-windows-argv-stale-env.sh\`." "installed release headline"
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

assert_contains_text "${fallback_output}" "installed_release_headline 같은 PowerShell 창에서 \`sfs upgrade\` 를 한 번 실행한 뒤 \`sfs init\` 등 친 명령이 stale \`update\` 로 둔갑하던 Windows 인자전달 버그를 고친 패치 릴리스입니다. Scoop self-upgrade reload 가 \`\$env:SFS_NATIVE_*\` 를 세션에 남기고 \`bin/sfs.ps1\` 이 그 env 를 친 인자보다 먼저 골라, 이후 모든 명령이 stale \`update\` 로 바뀌었습니다 (0.6.45-0.6.56 / 0.8.50 회귀 계열). 이제 친 인자가 항상 inherited env 를 이기고(F1), self-upgrade reload 가 끝나면 세션 env 를 복원합니다(F2). bash 동작은 불변, 207/207 green." "release notes fallback headline"

echo "test-version-release-headline: OK"
