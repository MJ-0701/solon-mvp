#!/usr/bin/env bash
# tests/test-rollback-from-snapshot.sh — AC10.4 snapshot restore.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MIGRATE="${DIST_DIR}/scripts/sfs-migrate-artifacts.sh"
ROLLBACK="${DIST_DIR}/scripts/sfs-migrate-artifacts-rollback.sh"

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
cd "${tmp}"
git init -q
git config user.email t@t
git config user.name t
mkdir -p .sfs-local/sprints/0-5-x-rb
echo "before-migration" > .sfs-local/sprints/0-5-x-rb/notes.md
git add -A && git commit -q -m init

bash "${MIGRATE}" --auto --root . >/dev/null 2>&1
git add -A && git commit -q -m migrate

snap="$(find .sfs-local/archives -name 'pre-migrate-*' -type d 2>/dev/null | head -1)"
[[ -n "${snap}" ]] || { echo "AC10.4 FAIL: snapshot dir missing"; exit 1; }
snapshot_iso="${snap##*/pre-migrate-}"

# Damage: delete migrated file + commit.
rm -f .solon/sprints/0-5-x-rb/default/notes.md
git add -A && git commit -q -m damage 2>/dev/null || true

# Restore.
bash "${ROLLBACK}" --from-snapshot "${snapshot_iso}" --root . >/dev/null 2>&1

# Original location should be restored.
[[ -f ".sfs-local/sprints/0-5-x-rb/notes.md" ]] || { echo "AC10.4 FAIL: snapshot restore did not recover original file"; exit 1; }

content="$(cat .sfs-local/sprints/0-5-x-rb/notes.md)"
[[ "${content}" == "before-migration" ]] || { echo "AC10.4 FAIL: content mismatch: ${content}"; exit 1; }

echo "test-rollback-from-snapshot: OK"
