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

[[ "${plain_output}" == "sfs 0.8.49" ]] || fail "plain version output changed: ${plain_output}"
assert_contains_text "${output}" "sfs 0.8.49" "version output"
assert_contains_text "${output}" "latest 0.8.49" "latest output"
assert_contains_text "${output}" "installed_release_headline Minor release: completes hands-off multi-agent team activation on top of 0.8.48's upgrade-path repair. (R1) activation is now its own write command — \`sfs team use <solo|pair|trio>\` materializes a preset any time, independent of \`sfs upgrade\`, and both paths share one extracted core (\`sfs-team-apply.sh\`: scaffold → \`team_preset\` → bindings → adapter dispatch), so the upgrade and use paths can't drift. (R3) a capability preflight probes each binding's runtime (CLI present + authenticated) before applying — only runnable bindings are written, the rest are held with \`install/auth X then sfs team use <preset>\` guidance, and an absent \`agy\` researcher falls back to deprecated \`gemini\` or is held rather than left guessing; the gate never crashes. (R5) the user no longer needs to know any command — a solo \`sfs upgrade\` in a team-capable environment surfaces a one-line \`[Y/n]\` offer, applies only the capable bindings on consent, and records the decision so it never nags again, re-offering once only if the environment goes incapable→capable. Non-interactive, declined, and incapable paths stay solo: byte-for-byte on \`model-profiles.yaml\`, no \`team_dispatch\`, standalone lock intact." "installed release headline"
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

assert_contains_text "${fallback_output}" "installed_release_headline 0.8.48 의 업그레이드 경로 수리 위에, 사용자가 명령어를 몰라도 멀티에이전트 팀을 켤 수 있게 자동화를 완성한 마이너 릴리스입니다. 이제 \`sfs team use trio\` 로 업그레이드와 무관하게 언제든 팀을 활성화할 수 있고, 켤 수 있는 환경이면 \`sfs upgrade\` 가 한 줄로 적용 여부를 물어봅니다. 거절·비대화·미충족 환경은 solo 무변경입니다." "release notes fallback headline"

echo "test-version-release-headline: OK"
