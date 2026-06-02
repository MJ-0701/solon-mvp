#!/usr/bin/env bash
# legacy SFS workbench 에서 VERSION 마커만 누락된 upgrade 복구를 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-upgrade-legacy-marker.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

cd "${TMP_DIR}"
git init -q
git config user.email "legacy-marker@solon.invalid"
git config user.name "Solon Legacy Marker Test"

printf '# Legacy SFS Project\n' > SFS.md
printf '# Agent Entry\n\nUse SFS and .sfs-local state.\n' > AGENTS.md
mkdir -p .sfs-local/sprints/legacy-sprint
printf 'legacy-sprint\n' > .sfs-local/current-sprint
printf '{"ts":"2026-06-02T00:00:00Z","type":"sprint_start","sprint_id":"legacy-sprint"}\n' > .sfs-local/events.jsonl
printf 'division: legacy\n' > .sfs-local/divisions.yaml
printf '# report\n\nlegacy report body\n' > .sfs-local/sprints/legacy-sprint/report.md
git add SFS.md AGENTS.md
git commit -qm "legacy sfs project"

[[ ! -f .sfs-local/VERSION ]] || fail "fixture should start without VERSION"

set +e
upgrade_out="$(
  SFS_SKIP_CLI_DISCOVERY=1 \
  SFS_INSTALL_LLM_WIKI=0 \
  SFS_UPDATE_SELF=0 \
  SFS_COMMAND_TIMEOUT_SEC=0 \
  SFS_DIST_DIR="${DIST_DIR}" \
  bash "${SFS_BIN}" upgrade --no-self-upgrade --skip-existing --layout thin 2>&1
)"
upgrade_rc=$?
set -e

[[ "${upgrade_rc}" -eq 0 ]] || fail "legacy marker repair upgrade should pass, rc=${upgrade_rc}: ${upgrade_out}"
[[ -f .sfs-local/VERSION ]] || fail "upgrade should recreate .sfs-local/VERSION"
[[ -f .sfs-local/config.yaml ]] || fail "upgrade should recreate .sfs-local/config.yaml"
grep -Fq 'install_layout: thin' .sfs-local/VERSION \
  || fail "VERSION should record thin layout"
grep -Fq 'installed_from: legacy-marker-repair' .sfs-local/VERSION \
  || fail "VERSION should record marker repair origin on same-version upgrade"
grep -Fq 'layout: "thin"' .sfs-local/config.yaml \
  || fail "config should record thin layout"
grep -Fq 'legacy-sprint' .sfs-local/current-sprint \
  || fail "upgrade should preserve current-sprint pointer"
grep -Fq 'legacy report body' .sfs-local/sprints/legacy-sprint/report.md \
  || fail "upgrade should preserve legacy sprint artifacts"
grep -Fq 'legacy SFS state detected without .sfs-local/VERSION' <<<"${upgrade_out}" \
  || fail "upgrade should surface marker repair: ${upgrade_out}"
if grep -Fq 'this project is not initialized yet' <<<"${upgrade_out}"; then
  fail "upgrade should not fall back to first-time setup after marker repair: ${upgrade_out}"
fi

status_out="$(
  SFS_COMMAND_TIMEOUT_SEC=0 \
  SFS_DIST_DIR="${DIST_DIR}" \
  bash "${SFS_BIN}" status --compact --color never 2>&1
)"
grep -Fq 'sprint=legacy-sprint' <<<"${status_out}" \
  || fail "status should recognize repaired project, got: ${status_out}"

echo "test-sfs-upgrade-legacy-marker-repair: OK"
