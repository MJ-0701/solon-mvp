#!/usr/bin/env bash
# tests/test-sfs-version-notice-cache-global.sh — version notice state must not recreate .sfs-local/cache.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-version-cache.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

PROJECT_DIR="${TMP_DIR}/project"
RELEASE_REPO="${TMP_DIR}/release-repo"
mkdir -p "${PROJECT_DIR}" "${RELEASE_REPO}"

git -C "${RELEASE_REPO}" init -q
printf '# releases\n' > "${RELEASE_REPO}/README.md"
git -C "${RELEASE_REPO}" add README.md
git -C "${RELEASE_REPO}" -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'
git -C "${RELEASE_REPO}" tag v0.6.75

cd "${PROJECT_DIR}"
git init -q
printf '# Version Notice Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null

SFS_VERSION_NOTICE_FORCE=1 \
SFS_VERSION_NOTICE_TTL_SEC=0 \
SFS_VERSION_NOTICE_THRESHOLD=1 \
SFS_RELEASE_REPO_URL="${RELEASE_REPO}" \
SFS_CACHE_DIR="${TMP_DIR}/user-cache" \
SFS_COMMAND_TIMEOUT_SEC=0 \
SFS_DIST_DIR="${DIST_DIR}" \
bash "${SFS_BIN}" status >/tmp/sfs-version-notice.out 2>/tmp/sfs-version-notice.err

[[ ! -d .sfs-local/cache ]] || fail "version notice must not create project-local .sfs-local/cache"
find "${TMP_DIR}/user-cache/version-notices" -name '*.env' -type f | grep -q . \
  || fail "version notice should write state to user SFS cache"
grep -Fq 'latest is 0.6.75' /tmp/sfs-version-notice.err \
  || fail "expected stale version notice on stderr"

echo "test-sfs-version-notice-cache-global: OK"
