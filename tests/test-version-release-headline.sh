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

[[ "${plain_output}" == "sfs 0.8.52" ]] || fail "plain version output changed: ${plain_output}"
assert_contains_text "${output}" "sfs 0.8.52" "version output"
assert_contains_text "${output}" "latest 0.8.52" "latest output"
assert_contains_text "${output}" "installed_release_headline Patch release: deprecated-fallback -> canonical auto-promotion (SFS level). A project whose trio researcher fell back to the deprecated \`gemini\` runtime (because \`antigravity\`/\`agy\` was absent at activation time) had no product-level path back to canonical after \`agy\` was later installed+authed: re-running \`sfs team use trio\` hit the 3-way bindings guard's \"custom bindings 보존\" skip, so the only way forward was a manual \`model-profiles.yaml\` edit — the \"must know the command/YAML\" anti-pattern 0.8.49/0.8.50 removed. 0.8.52 makes the guard 4-way. Fallback bindings are now MARKED at materialize time (\`# sfs-fallback: <canonical>\`), and when the canonical runtime becomes capable SFS detects -> offers (one consent) -> promotes only that one line and strips the marker. (R1) the provenance marker distinguishes a deprecated fallback from a user-chosen \`gemini\`; (R2) \`sfs team use <preset>\` re-run, the new \`sfs team refresh [--yes]\`, and \`sfs upgrade\` all re-evaluate capability and surface the promotion; (R3) unmarked user-custom bindings are never auto-changed (4-way = absent / \`{}\` / fallback(promote) / user-custom(preserve)); (R4) non-interactive / \`--yes\` without consent = byte-for-byte no change; (R5) the antigravity capability gate is now auth-aware (presence + Google-cred env / \`SFS_ANTIGRAVITY_AUTH_READY\`), so an installed-but-unauthed \`agy\` no longer promotes into a \"promoted but unauthed\" runtime error. solo/standalone behavior unchanged; the marker is comment-only so \`resolve-runtime\` is unaffected. Locked by \`tests/test-team-fallback-promotion.sh\`." "installed release headline"
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

assert_contains_text "${fallback_output}" "installed_release_headline trio researcher 가 활성화 시점에 antigravity(\`agy\`) 부재로 deprecated \`gemini\` fallback 으로 굳은 프로젝트가, \`agy\` 설치·인증 후에도 제품 차원에서 canonical 로 돌아올 길이 없던 문제를 고친 패치 릴리스입니다. 이제 fallback binding 에 출처 표식(\`# sfs-fallback: <canonical>\`)을 남겨, canonical 런타임이 capable 해지면 SFS 가 스스로 감지 -> 제안(동의 1회) -> 그 한 줄만 승격하고 표식을 제거합니다. 사용자가 직접 고른 binding 은 건드리지 않고(R3), 비대화/\`--yes\` 미동의는 byte-for-byte 무변경(R4)이며, antigravity 게이트는 auth-aware(R5)라 설치만 되고 미인증인 \`agy\` 는 승격하지 않습니다. solo/standalone 동작은 불변입니다." "release notes fallback headline"

echo "test-version-release-headline: OK"
