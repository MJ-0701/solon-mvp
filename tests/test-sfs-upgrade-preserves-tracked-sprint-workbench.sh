#!/usr/bin/env bash
# tests/test-sfs-upgrade-preserves-tracked-sprint-workbench.sh — upgrade must not silently delete tracked sprint workbench docs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-upgrade-tracked-sprint.XXXXXX")"

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
git config user.email "tracked-sprint@solon.invalid"
git config user.name "Solon Tracked Sprint Test"
printf '# Tracked Sprint Fixture\n' > README.md
git add README.md
git commit -qm "initial"

SFS_DIST_DIR="${DIST_DIR}" \
SFS_INSTALL_LLM_WIKI=0 \
SFS_MODEL_PROFILE_PROMPT=0 \
SFS_SKIP_CLI_DISCOVERY=1 \
SFS_COMMAND_TIMEOUT_SEC=0 \
bash "${SFS_BIN}" init --layout vendored --yes >/dev/null

sprint_id="solon-loop-queue-mvp"
mkdir -p ".sfs-local/sprints/${sprint_id}"
printf '%s\n' "${sprint_id}" > .sfs-local/current-sprint
for doc in brainstorm implement log plan retro review; do
  cat > ".sfs-local/sprints/${sprint_id}/${doc}.md" <<EOF
---
phase: ${doc}
sprint_id: "${sprint_id}"
---

# ${doc}

Tracked sprint workbench evidence.
EOF
done
git add -f ".sfs-local/sprints/${sprint_id}"

archive_sprint_id="closed-tracked-sprint"
archive_run_id="2026-06-04T23-00-00-09-00"
archive_dir=".sfs-local/archives/sprints/${archive_sprint_id}/${archive_run_id}"
mkdir -p "${archive_dir}"
printf 'tracked loose sprint archive evidence\n' > "${archive_dir}/evidence.txt"

git add -f ".sfs-local/sprints/${sprint_id}" ".sfs-local/archives/sprints/${archive_sprint_id}"
git commit -qm "track sprint workbench and archive"

set +e
upgrade_out="$(
  SFS_INSTALL_LLM_WIKI=0 \
  SFS_MODEL_PROFILE_PROMPT=0 \
  SFS_SKIP_CLI_DISCOVERY=1 \
  SFS_COMMAND_TIMEOUT_SEC=0 \
  bash "${DIST_DIR}/upgrade.sh" --yes --layout vendored 2>&1
)"
upgrade_rc=$?
set -e

[[ "${upgrade_rc}" -eq 0 ]] \
  || fail "upgrade should succeed while preserving tracked sprint workbench, rc=${upgrade_rc}: ${upgrade_out}"

grep -Fq "git-tracked sprint workbench 보존" <<<"${upgrade_out}" \
  || fail "upgrade should explicitly notify when tracked sprint workbench compaction is skipped: ${upgrade_out}"
grep -Fq "git-tracked sprint archive 보존" <<<"${upgrade_out}" \
  || fail "upgrade should explicitly notify when tracked sprint archive compaction is skipped: ${upgrade_out}"
grep -Fq "git-tracked archive bucket 보존" <<<"${upgrade_out}" \
  || fail "upgrade should explicitly notify when tracked archive bucket collapse is skipped: ${upgrade_out}"

for doc in brainstorm implement log plan retro review; do
  path=".sfs-local/sprints/${sprint_id}/${doc}.md"
  [[ -f "${path}" ]] || fail "tracked ${doc}.md should remain in the workbench"
  grep -Fq "Tracked sprint workbench evidence." "${path}" \
    || fail "tracked ${doc}.md body should be preserved"
done

deleted_status="$(git status --short -- ".sfs-local/sprints/${sprint_id}")"
[[ -z "${deleted_status}" ]] \
  || fail "upgrade should not leave tracked sprint workbench deletions: ${deleted_status}"

[[ -f "${archive_dir}/evidence.txt" ]] || fail "tracked sprint archive evidence should remain"
grep -Fq 'tracked loose sprint archive evidence' "${archive_dir}/evidence.txt" \
  || fail "tracked sprint archive evidence body should be preserved"
archive_status="$(git status --short -- ".sfs-local/archives/sprints/${archive_sprint_id}")"
[[ -z "${archive_status}" ]] \
  || fail "upgrade should not leave tracked sprint archive deletions: ${archive_status}"

echo "test-sfs-upgrade-preserves-tracked-sprint-workbench: OK"
