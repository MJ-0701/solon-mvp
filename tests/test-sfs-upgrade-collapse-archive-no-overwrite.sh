#!/usr/bin/env bash
# tests/test-sfs-upgrade-collapse-archive-no-overwrite.sh — repeated upgrade collapses must not overwrite cold evidence.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-upgrade-collapse.XXXXXX")"

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
printf '# Collapse Archive Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout vendored --with-agent-adapters --yes >/dev/null

sed -i.bak 's/^solon_mvp_version:.*/solon_mvp_version: 0.0.0-product/' .sfs-local/VERSION
rm -f .sfs-local/VERSION.bak

SFS_MODEL_PROFILE_PROMPT=0 \
SFS_SKIP_CLI_DISCOVERY=1 \
SFS_COMMAND_TIMEOUT_SEC=0 \
SFS_UPGRADE_LAYOUT=thin \
bash "${DIST_DIR}/upgrade.sh" --yes >/tmp/sfs-upgrade-collapse.out

archive_index="${TMP_DIR}/collapsed-index.txt"
: > "${archive_index}"
while IFS= read -r archive; do
  tar -tzf "${archive}" >> "${archive_index}"
done < <(find .sfs-local/archives/adopt/surface-cleanup -name preexisting-archives.tar.gz -type f | sort)

grep -Fq 'project-runtime-assets.tar.gz' "${archive_index}" \
  || fail "collapsed archives lost project-runtime-assets.tar.gz"
grep -Fq 'project-agent-adapters.tar.gz' "${archive_index}" \
  || fail "collapsed archives lost project-agent-adapters.tar.gz"
grep -Fq 'project-local-context.tar.gz' "${archive_index}" \
  || fail "collapsed archives lost thin-context archive"

[[ ! -d .sfs-local/archives/runtime-migrations ]] || fail "runtime-migrations should be collapsed"
[[ ! -d .sfs-local/scripts ]] || fail "thin upgrade should remove project-local scripts"
[[ ! -e .claude/commands/sfs.md ]] || fail "thin upgrade should remove project-local Claude adapter"

echo "test-sfs-upgrade-collapse-archive-no-overwrite: OK"
