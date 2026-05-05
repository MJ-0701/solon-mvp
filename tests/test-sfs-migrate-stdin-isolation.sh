#!/usr/bin/env bash
# tests/test-sfs-migrate-stdin-isolation.sh — G6.1 F1 regression.
#
# Contract: prompts in apply_migration MUST read from /dev/tty, not stdin.
# When matrix flows through stdin (`build_source_matrix | apply_migration interactive`)
# any inner `read` against stdin would drain matrix rows, dropping files.
#
# Test runs interactive default mode with `--no-tty` (so prompt_user falls back to
# default 'k'), and verifies every source file in the matrix lands at its dest.
# Pre-fix bug would manifest as dest_count < src_count (some matrix lines drained).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MIGRATE="${DIST_DIR}/scripts/sfs-migrate-artifacts.sh"

[[ -x "${MIGRATE}" ]] || { echo "missing: ${MIGRATE}" >&2; exit 1; }

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
cd "${tmp}"
git init -q
git config user.email t@t
git config user.name t

# 8 source files spread across 3 sprints (mix of migrate + archive actions).
mkdir -p .sfs-local/sprints/0-5-x-a .sfs-local/sprints/0-5-x-b sprints/0-5-x-c
echo "alpha-1" > .sfs-local/sprints/0-5-x-a/note-1.md
echo "alpha-2" > .sfs-local/sprints/0-5-x-a/note-2.md
echo "alpha-3" > .sfs-local/sprints/0-5-x-a/note-3.md
echo "alpha-r" > .sfs-local/sprints/0-5-x-a/report.md      # archive action
echo "beta-1"  > .sfs-local/sprints/0-5-x-b/note-1.md
echo "beta-2"  > .sfs-local/sprints/0-5-x-b/note-2.md
echo "gamma-1" > sprints/0-5-x-c/note-1.md
echo "gamma-2" > sprints/0-5-x-c/note-2.md
git add -A && git commit -q -m init >/dev/null

src_count_pre="$(find .sfs-local/sprints sprints -type f | wc -l | tr -d ' ')"
[[ "${src_count_pre}" -eq 8 ]] || { echo "stdin-iso FAIL: setup src count=${src_count_pre} (expected 8)"; exit 1; }

# Run interactive mode (default — no flag) with --no-tty so prompts default to 'k'.
# stdin is the matrix pipe (internal). If prompts drained the pipe, dest_count < 8.
bash "${MIGRATE}" --no-tty --root . >/dev/null 2>&1

# Account for migrated files (.solon/sprints/) + archived (1 = report.md).
dest_count="$(find .solon/sprints -type f 2>/dev/null | wc -l | tr -d ' ')"
archive_count="$(find .sfs-local/archives/migrate-archive -type f 2>/dev/null | wc -l | tr -d ' ')"
total_accounted=$((dest_count))   # archive writes both stub at dest AND .gz; both forms count once via stub.

# Strict: all 8 source files must reach a dest path (7 migrate + 1 archive stub).
if [[ "${total_accounted}" -ne 8 ]]; then
  echo "stdin-iso FAIL: total dest=${total_accounted} (expected 8) — possible stdin drain regression"
  echo "  dest files:"
  find .solon/sprints -type f 2>/dev/null | sed 's/^/    /'
  exit 1
fi

# Sanity: archive .gz must exist for report.md.
if [[ "${archive_count}" -ne 1 ]]; then
  echo "stdin-iso FAIL: archive count=${archive_count} (expected 1)"; exit 1
fi

# Sanity: no source remnant.
src_remaining="$(find .sfs-local/sprints sprints -type f 2>/dev/null | wc -l | tr -d ' ')"
if [[ "${src_remaining}" -ne 0 ]]; then
  echo "stdin-iso FAIL: ${src_remaining} src files remain"; exit 1
fi

echo "test-sfs-migrate-stdin-isolation: OK (8/8 reached dest, 1 archived, 0 src remain)"
