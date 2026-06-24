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

[[ "${plain_output}" == "sfs 0.8.50" ]] || fail "plain version output changed: ${plain_output}"
assert_contains_text "${output}" "sfs 0.8.50" "version output"
assert_contains_text "${output}" "latest 0.8.50" "latest output"
assert_contains_text "${output}" "installed_release_headline Patch release: Windows (PowerShell/Scoop) reaches multi-agent team-activation parity with bash 0.8.49 by thin delegation — zero native port, single SSoT. \`install.ps1\` and \`upgrade.ps1\` now accept and forward \`-Team <solo|pair|trio>\` to the bash core (\`install.sh\` / \`upgrade.sh\`), so Windows users get the same \`--team\` materialize, capability preflight (R3), and zero-knowledge \`[Y/n]\` auto-offer (R5) that bash shipped — the offer and gate run in Git Bash and are byte-for-byte the bash behavior. \`sfs.cmd team use <preset>\` and \`sfs.cmd upgrade --team\` already reached the bash core (mutating commands delegate via \`bin/sfs.ps1\`); that delegation is now locked against a future native-handler regression. Omitting \`-Team\` forwards zero \`--team\` flags, preserving the solo no-op and keeping the R5 auto-offer reachable. The Git-Bash-required fallback in all three wrappers now points at \`sfs team use\`. No bash behavior changed; bash 0.8.49 remains the spec." "installed release headline"
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

assert_contains_text "${fallback_output}" "installed_release_headline Windows(PowerShell/Scoop) 사용자도 bash 0.8.49 와 동일하게 멀티에이전트 팀을 켤 수 있게 한 패치 릴리스입니다. \`install.ps1\`·\`upgrade.ps1\` 이 \`-Team <solo|pair|trio>\` 를 받아 bash 코어로 그대로 넘기므로, capability 게이트(R3)와 \`[Y/n]\` 자동 제안(R5)이 Windows 에서도 동일하게 동작합니다. \`-Team\` 을 생략하면 아무 플래그도 넘기지 않아 solo 무변경입니다." "release notes fallback headline"

echo "test-version-release-headline: OK"
