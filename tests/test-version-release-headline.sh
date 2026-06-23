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

[[ "${plain_output}" == "sfs 0.8.43" ]] || fail "plain version output changed: ${plain_output}"
assert_contains_text "${output}" "sfs 0.8.43" "version output"
assert_contains_text "${output}" "latest 0.8.43" "latest output"
assert_contains_text "${output}" "status up-to-date" "status output"
assert_contains_text "${output}" "installed_release_headline Multi-agent team topology P2: \`--team solo|pair|trio\` becomes a real install/upgrade option that materializes the P1 data surface and wires role-scoped auto-dispatch into the adapters — while \`solo\` (the default) stays byte-for-byte unchanged. \`install.sh --team trio\` (or \`SFS_AGENT_TEAM=trio\`) fills \`agent_runtime_bindings\` from a new data-driven \`team_preset_catalog\` and injects a \`team_dispatch:\` rule block into the consumer's \`CLAUDE.md\`/\`AGENTS.md\`/\`GEMINI.md\` frontmatter; \`upgrade.sh --team <preset>\` re-applies the same, idempotently, even on the already-latest path. Presets are data: adding a 4th preset is one catalog bundle, zero install/resolver code diff (OCP). The dist \`*.md.template\` files are never touched, so the thin-adapter ≤50-line/frontmatter-only gate stays green and solo behavior is preserved. The dispatch helper is named \`sfs route\` (P3) — \`dispatch\` is the router engine itself and \`handoff\` is taken." "installed release headline"
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

assert_contains_text "${fallback_output}" "installed_release_headline 멀티에이전트 team topology 의 두 번째 단계(P2)입니다. P1 의 데이터 표면을 \`--team\` 설치/업그레이드 옵션으로 실제 배선하면서, 기본 \`solo\` 는 바이트 단위로 그대로 둡니다." "release notes fallback headline"

echo "test-version-release-headline: OK"
