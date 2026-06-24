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

[[ "${plain_output}" == "sfs 0.8.47" ]] || fail "plain version output changed: ${plain_output}"
assert_contains_text "${output}" "sfs 0.8.47" "version output"
assert_contains_text "${output}" "latest 0.8.47" "latest output"
assert_contains_text "${output}" "status up-to-date" "status output"
assert_contains_text "${output}" "installed_release_headline Hermes self-evolution seam P3 wires Seam B and closes the dispatch injection seam. Two new write verbs on \`sfs orchestrator\`: \`export --from <candidates>\` emits a pointer-only typed proposal to the \`review_outbox\` (file-drop transport — id + evidence_pointer + metadata, a candidate's raw body structurally cannot leave), and \`import-review --file <review>\` validates and sanitizes a typed human review (\`candidate_id\` / \`decision\` ∈ approve|defer|reject / \`comment\` / \`reviewer\` / \`ts\`) into an advisory review log. The review log changes nothing about the loop's authority — an \`approve\` writes only that log; APPLY stays the \`tidy\` rail under a human gate, untriggerable from here. Security precondition first: team topology P3's \`sfs-route.sh\` real-exec path no longer \`eval\`s an interpolated command string — it builds an argv array and executes it directly, so a capsule goal carrying \`\$(...)\` / backticks is inert data, not shell. Credentials stay indirection-only (\`credential_ref\` placeholder, never a value). This completes the opt-in Hermes seam (P1 schema → P2 SIGNAL ingest → P3 export/import); standalone holds throughout — disable the seam and the loop runs on doctor+curation+tidy alone." "installed release headline"
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

assert_contains_text "${fallback_output}" "installed_release_headline Hermes 자체진화 seam 의 마지막 단계(P3)입니다. Seam B — 큐레이션/승격 후보를 외부 검토 표면으로 내보내고(포인터만), 사람이 내린 검토 결과를 다시 받아 advisory 로그에 적재합니다. 실제 적용(APPLY)은 끝까지 \`tidy\` 레일 + 사람 게이트입니다." "release notes fallback headline"

echo "test-version-release-headline: OK"
