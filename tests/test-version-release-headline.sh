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

[[ "${plain_output}" == "sfs 0.8.42" ]] || fail "plain version output changed: ${plain_output}"
assert_contains_text "${output}" "sfs 0.8.42" "version output"
assert_contains_text "${output}" "latest 0.8.42" "latest output"
assert_contains_text "${output}" "status up-to-date" "status output"
assert_contains_text "${output}" "installed_release_headline Multi-agent team topology P1 lands as a data-only surface: \`model-profiles.yaml\` gains an opt-in \`runtime_registry\` + \`agent_runtime_bindings\` + \`team_preset\` + \`unassigned_role_policy\` schema, and a new read-only \`sfs team\` resolver answers role→runtime→invoke-template purely from that data. The default is \`solo\` with empty bindings, so every role still falls back to \`selected_runtime\` and behavior is unchanged; removing the team sections entirely degrades cleanly back to standalone solo. Two headline regression locks pin the OCP principle (a one-line binding edit re-routes a role, and a 4th registry runtime is honored, both with zero resolver-code diff) and the standalone guarantee. No dispatch is wired yet — that is P3." "installed release headline"
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

assert_contains_text "${fallback_output}" "installed_release_headline 멀티에이전트 team topology 의 첫 단계(P1)가 데이터 표면 + 회귀잠금으로 들어왔습니다. model-profiles.yaml 에 opt-in team 스키마(runtime_registry / agent_runtime_bindings / team_preset)와 그것을 읽는 읽기전용 sfs team resolver 가 추가되고, 기본 solo 는 동작이 0 변경이며 team 섹션을 통째로 지워도 solo 로 안전하게 degrade 됩니다. 실제 자동 호출(dispatch)은 P3 입니다." "release notes fallback headline"

echo "test-version-release-headline: OK"
