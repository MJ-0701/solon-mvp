#!/usr/bin/env bash
# tests/test-sfs-migrate-artifacts-smoke.sh — AC4.2 end-to-end smoke harness.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MIGRATE="${DIST_DIR}/scripts/sfs-migrate-artifacts.sh"

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

cd "${tmp}"
git init -q
git config user.email t@t
git config user.name t

# Fake consumer 0.5.x project tree.
mkdir -p .sfs-local/sprints/0-5-x-alpha .sfs-local/sprints/0-5-x-beta sprints/0-5-x-gamma
echo "alpha-notes" > .sfs-local/sprints/0-5-x-alpha/notes.md
echo "alpha-report" > .sfs-local/sprints/0-5-x-alpha/report.md
echo "beta-feat" > .sfs-local/sprints/0-5-x-beta/feature.md
echo "gamma-old" > sprints/0-5-x-gamma/legacy.md
git add -A && git commit -q -m fake-consumer-init

# 1) Print matrix sanity.
matrix="$(bash "${MIGRATE}" --print-matrix --root . 2>/dev/null)"
[[ -n "${matrix}" ]] || { echo "smoke FAIL: empty matrix"; exit 1; }

# 2) Auto migrate.
bash "${MIGRATE}" --auto --root . >/dev/null 2>&1

# Check destination tree.
[[ -d .solon/sprints/0-5-x-alpha ]] || { echo "smoke FAIL: alpha missing"; exit 1; }
[[ -d .solon/sprints/0-5-x-beta ]]  || { echo "smoke FAIL: beta missing"; exit 1; }
[[ -d .solon/sprints/0-5-x-gamma ]] || { echo "smoke FAIL: gamma missing"; exit 1; }

# Snapshot present.
snap="$(find .sfs-local/archives -name 'pre-migrate-*' -type d 2>/dev/null | head -1)"
[[ -n "${snap}" ]] || { echo "smoke FAIL: snapshot missing"; exit 1; }

# Idempotent re-run via backfill.
bash "${MIGRATE}" --backfill-legacy --root . >/dev/null 2>&1

echo "test-sfs-migrate-artifacts-smoke: OK"
