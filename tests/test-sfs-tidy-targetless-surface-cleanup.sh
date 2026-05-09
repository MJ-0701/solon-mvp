#!/usr/bin/env bash
# tests/test-sfs-tidy-targetless-surface-cleanup.sh — tidy can clean post-adopt residue without visible sprints.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-tidy-targetless.XXXXXX")"

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

cd "${TMP_DIR}"
git init -q
printf '# Targetless Surface Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null

rm -rf .sfs-local/sprints
mkdir -p .sfs-local/cache .sfs-local/archives/runtime-migrations/legacy .sfs-local/archives/runtime-upgrades/old .sfs-local/archives/sprints/done
printf 'last_checked_epoch=0\nlatest=0.0.0\n' > .sfs-local/cache/version-notice.env
printf 'last_checked_epoch=0\n' > .sfs-local/cache/hygiene-notice.env
printf '# placeholder only\n' > .sfs-local/auth.env
printf '{"ts":"2026-05-09T14:40:00+09:00","type":"legacy_probe"}\n' > .sfs-local/events.jsonl
printf 'migration evidence\n' > .sfs-local/archives/runtime-migrations/legacy/evidence.txt
printf 'upgrade evidence\n' > .sfs-local/archives/runtime-upgrades/old/evidence.txt
printf 'sprint evidence\n' > .sfs-local/archives/sprints/done/evidence.txt

dry_run="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all)"
assert_contains "${dry_run}" "sprints: none (surface cleanup only)" "dry-run targetless mode"
assert_contains "${dry_run}" "events: 1 line(s) would prune" "dry-run orphan events"
assert_contains "${dry_run}" "archives: 3 non-adopt archive bucket(s) would collapse" "dry-run archive collapse"

apply_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all --apply)"
assert_contains "${apply_out}" "events: 1 historical line(s) pruned" "apply orphan events"
assert_contains "${apply_out}" "archives: 3 non-adopt bucket(s) collapsed" "apply archive collapse"

[[ ! -e .sfs-local/events.jsonl ]] || fail "orphan events.jsonl should be removed"
[[ ! -d .sfs-local/cache ]] || fail "cache notice files should be removed"
[[ ! -e .sfs-local/auth.env ]] || fail "placeholder auth.env should be removed"
[[ ! -d .sfs-local/archives/runtime-migrations ]] || fail "runtime-migrations should be collapsed"
[[ ! -d .sfs-local/archives/runtime-upgrades ]] || fail "runtime-upgrades should be collapsed"
[[ ! -d .sfs-local/archives/sprints ]] || fail "sprints archive bucket should be collapsed"

archive_file="$(find .sfs-local/archives/adopt/surface-cleanup -name preexisting-archives.tar.gz -type f | head -1)"
[[ -n "${archive_file}" ]] || fail "missing collapsed preexisting archive bundle"
tar -tzf "${archive_file}" | grep -Fq 'runtime-migrations/legacy/evidence.txt' \
  || fail "collapsed archive missing runtime migration evidence"
tar -tzf "${archive_file}" | grep -Fq 'runtime-upgrades/old/evidence.txt' \
  || fail "collapsed archive missing runtime upgrade evidence"
tar -tzf "${archive_file}" | grep -Fq 'sprints/done/evidence.txt' \
  || fail "collapsed archive missing sprint archive evidence"

echo "test-sfs-tidy-targetless-surface-cleanup: OK"
