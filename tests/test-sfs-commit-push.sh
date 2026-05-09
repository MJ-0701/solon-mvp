#!/usr/bin/env bash
# tests/test-sfs-commit-push.sh — sfs commit apply is commit+push for user projects.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-commit-push.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2" label="$3"
  case "${haystack}" in
    *"${needle}"*) ;;
    *) fail "${label}: missing ${needle} in: ${haystack}" ;;
  esac
}

origin="${TMP_DIR}/origin.git"
work="${TMP_DIR}/work"
git init --bare -q "${origin}"
mkdir -p "${work}"

cd "${work}"
git init -q
git branch -M main
git config user.email sfs-test@example.invalid
git config user.name "SFS Test"
git remote add origin "${origin}"
printf '# Commit Push Project\n' > README.md
git add README.md
git commit -qm 'initial'
git push -u origin HEAD >/dev/null

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
git add SFS.md CLAUDE.md AGENTS.md GEMINI.md .gitignore
git commit -qm 'install sfs'
git push >/dev/null

mkdir -p src
printf 'hello\n' > src/app.txt
out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" commit apply --group product-code -m "feat: add app")"
assert_contains "${out}" "push: pending" "commit output pending push"
assert_contains "${out}" "committed:" "commit output committed"
assert_contains "${out}" "pushed:" "commit output pushed"

local_head="$(git rev-parse HEAD)"
remote_head="$(git --git-dir="${origin}" rev-parse refs/heads/main)"
[[ "${local_head}" == "${remote_head}" ]] || fail "remote main was not pushed"

printf 'offline\n' > src/offline.txt
before_no_push_remote="$(git --git-dir="${origin}" rev-parse refs/heads/main)"
out_no_push="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" commit apply --group product-code --no-push -m "feat: add offline app")"
assert_contains "${out_no_push}" "push: disabled (--no-push)" "no-push output disabled"
assert_contains "${out_no_push}" "push: skipped (--no-push)" "no-push output skipped"
after_no_push_remote="$(git --git-dir="${origin}" rev-parse refs/heads/main)"
[[ "${before_no_push_remote}" == "${after_no_push_remote}" ]] || fail "--no-push unexpectedly updated remote"

echo "test-sfs-commit-push: OK"
