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

[[ "${plain_output}" == "sfs 0.8.44" ]] || fail "plain version output changed: ${plain_output}"
assert_contains_text "${output}" "sfs 0.8.44" "version output"
assert_contains_text "${output}" "latest 0.8.44" "latest output"
assert_contains_text "${output}" "status up-to-date" "status output"
assert_contains_text "${output}" "installed_release_headline Multi-agent team topology P3 lands the dispatch helper: \`sfs route <role> <capsule>\` turns the P1/P2 data surface into an actual headless hand-off. It resolves role→runtime→invoke-template→transport purely from \`model-profiles.yaml\`, fills the capsule's typed fields into \`{prompt}\`/\`{tools}\`, and calls the target CLI — with hop-limit + role-cycle guards that refuse runaway dispatch (exit 8) and a clean \"act directly\" degrade (exit 3, never a crash) when dispatch is off (solo) or the registry is absent. How each CLI is fed is data: a new \`transport_kind\` scalar (\`argv|stdin|file\`) selects the delivery strategy, so flipping a runtime's transport is a one-scalar edit with zero \`sfs-route.sh\` diff. Real CLI execution is mocked in-repo via \`SFS_ROUTE_DRY_RUN=1\` (no auth reached); the deliverable is adjustability-by-data, not a live call. The helper is named \`route\` because \`dispatch\` is the router engine itself and \`handoff\` is a pre-existing command (design D5). This completes the opt-in team topology — solo remains byte-for-byte unchanged throughout." "installed release headline"
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

assert_contains_text "${fallback_output}" "installed_release_headline 멀티에이전트 team topology 의 마지막 단계(P3)입니다. P1/P2 의 데이터 표면 위에 실제 디스패치 헬퍼 \`sfs route <role> <capsule>\` 가 얹혔습니다. solo 는 끝까지 그대로입니다." "release notes fallback headline"

echo "test-version-release-headline: OK"
