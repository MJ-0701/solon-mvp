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

[[ "${plain_output}" == "sfs 0.8.48" ]] || fail "plain version output changed: ${plain_output}"
assert_contains_text "${output}" "sfs 0.8.48" "version output"
assert_contains_text "${output}" "latest 0.8.48" "latest output"
assert_contains_text "${output}" "installed_release_headline Patch release: repairs the multi-agent team-topology upgrade path for legacy (pre-0.8.42) consumers — three bugs and one discoverability gap left by the 0.8.42..0.8.47 cut. (B1) \`sfs upgrade --team <preset>\` was swallowed by bin/sfs's front-door arg parser as an \"unknown arg\" even though \`upgrade.sh\` parsed it, so only the \`SFS_AGENT_TEAM\` env var worked; the front door now validates \`solo|pair|trio\` and forwards the flag, matching install's contract. (B2) \`upgrade\` assumed the team schema already existed, so a legacy profile with zero team keys was skipped forever — the adapter got \`team_dispatch\` injected while \`agent_runtime_bindings\` stayed empty, a half-applied routing no-op (real consumer breakage); upgrade now scaffolds the packaged team block (default \`team_preset: solo\` = zero behavior change) into the profile right after the \`configuration:\` block, then materializes the requested preset. (B3) the skip warning misdiagnosed an absent key as a user customization; the bindings-fill guard is now 3-way (absent vs literal \`{}\` vs custom) with corrected messages. (UX) the team preset had no interactive surface — install and upgrade now offer it (default solo). Solo/standalone invariants are locked: a no-flag \`--yes\` upgrade is byte-for-byte on \`model-profiles.yaml\` and never injects \`team_dispatch\`." "installed release headline"
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

assert_contains_text "${fallback_output}" "installed_release_headline team topology 출하본(0.8.42..0.8.47)의 업그레이드 경로 버그 3개 + 발견가능성 결함 1개를 고친 패치 릴리스입니다. 기존(pre-0.8.42) 프로젝트도 이제 \`sfs upgrade --team trio\` 로 멀티에이전트를 켤 수 있습니다. solo 기본 무변경·standalone 불변식은 그대로입니다." "release notes fallback headline"

echo "test-version-release-headline: OK"
