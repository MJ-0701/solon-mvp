#!/usr/bin/env bash
# tests/test-sfs-migrate-recovery-clean.sh — G6.1 AC10.5 regression.
#
# Contract: --recover MUST exercise the journal-replay cleanup + snapshot restore
# path, leaving:
#   - zero residual destination files under .solon/sprints/
#   - zero residual archive .gz files under .sfs-local/archives/migrate-archive/
#   - source files restored at their original .sfs-local/sprints/ + sprints/ paths
#   - tracked working tree matching HEAD (`git diff --quiet HEAD --` exit 0)
#
# Approach: run --auto to completion (so journal+snapshot exist), then exercise
# --recover. The post-state should match the pre-migration committed state for
# tracked files. (Untracked .sfs-local/migrate-tx + archives/pre-migrate-* dirs
# may remain — only tracked-diff-clean is asserted.)
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

mkdir -p .sfs-local/sprints/0-5-x-recover sprints/0-5-x-other
echo "alpha-data" > .sfs-local/sprints/0-5-x-recover/a.md
echo "beta-data"  > .sfs-local/sprints/0-5-x-recover/b.md
echo "report"     > .sfs-local/sprints/0-5-x-recover/report.md   # archive action
echo "other-data" > sprints/0-5-x-other/x.md
git add -A && git commit -q -m init >/dev/null

src_count_pre="$(find .sfs-local/sprints sprints -type f | wc -l | tr -d ' ')"
[[ "${src_count_pre}" -eq 4 ]] || { echo "AC10.5 setup FAIL: src=${src_count_pre} (expected 4)"; exit 1; }

# Phase 1 — apply migration.
bash "${MIGRATE}" --auto --root . >/dev/null 2>&1
[[ -f .solon/sprints/0-5-x-recover/default/a.md ]] || { echo "AC10.5 FAIL: a.md not migrated"; exit 1; }
[[ -f .solon/sprints/0-5-x-other/default/x.md ]]   || { echo "AC10.5 FAIL: x.md not migrated"; exit 1; }
[[ ! -f .sfs-local/sprints/0-5-x-recover/a.md ]]   || { echo "AC10.5 FAIL: src a.md still present after migrate"; exit 1; }
archive_count="$(find .sfs-local/archives/migrate-archive -type f -name '*.gz' 2>/dev/null | wc -l | tr -d ' ')"
[[ "${archive_count}" -eq 1 ]] || { echo "AC10.5 FAIL: archive count=${archive_count} (expected 1 = report.md)"; exit 1; }

# Phase 2 — exercise --recover (default = latest journal).
bash "${MIGRATE}" --recover --root . >/dev/null 2>&1

# Assertion 1 — no residual destinations. (find pattern guarded — .solon/sprints
# may not exist after G6.1.1 HB1 rmdir cascade; pipefail-safe via subshell.)
dest_residual=0
if [[ -d .solon/sprints ]]; then
  dest_residual="$( { find .solon/sprints -type f 2>/dev/null || true; } | wc -l | tr -d ' ')"
fi
if [[ "${dest_residual}" -ne 0 ]]; then
  echo "AC10.5 FAIL: ${dest_residual} dest files left after --recover"
  find .solon/sprints -type f 2>/dev/null | sed 's/^/    /'
  exit 1
fi

# Assertion 1.1 — G6.1.1 HB1: empty parent dirs under .solon/sprints/ must be rmdir'd.
# Allow .solon/sprints/ itself (with one entry) OR full removal — but no empty subdirs.
if [[ -d .solon/sprints ]]; then
  empty_subdirs="$( { find .solon/sprints -mindepth 1 -type d -empty 2>/dev/null || true; } | wc -l | tr -d ' ')"
  if [[ "${empty_subdirs}" -gt 0 ]]; then
    echo "AC10.5/HB1 FAIL: ${empty_subdirs} empty parent dir(s) left under .solon/sprints/ after --recover"
    find .solon/sprints -mindepth 1 -type d -empty 2>/dev/null | sed 's/^/    /'
    exit 1
  fi
fi

# Assertion 2 — no residual archive blobs.
archive_residual=0
if [[ -d .sfs-local/archives/migrate-archive ]]; then
  archive_residual="$( { find .sfs-local/archives/migrate-archive -type f 2>/dev/null || true; } | wc -l | tr -d ' ')"
fi
if [[ "${archive_residual}" -ne 0 ]]; then
  echo "AC10.5 FAIL: ${archive_residual} archive files left after --recover"
  exit 1
fi

# Assertion 3 — sources restored.
[[ -f .sfs-local/sprints/0-5-x-recover/a.md ]]      || { echo "AC10.5 FAIL: a.md not restored"; exit 1; }
[[ -f .sfs-local/sprints/0-5-x-recover/b.md ]]      || { echo "AC10.5 FAIL: b.md not restored"; exit 1; }
[[ -f .sfs-local/sprints/0-5-x-recover/report.md ]] || { echo "AC10.5 FAIL: report.md not restored"; exit 1; }
[[ -f sprints/0-5-x-other/x.md ]]                   || { echo "AC10.5 FAIL: x.md not restored"; exit 1; }

src_count_post="$(find .sfs-local/sprints sprints -type f | wc -l | tr -d ' ')"
if [[ "${src_count_post}" -ne "${src_count_pre}" ]]; then
  echo "AC10.5 FAIL: src count post=${src_count_post} pre=${src_count_pre}"
  exit 1
fi

# Assertion 4 — tracked working tree matches HEAD (git diff --quiet HEAD --).
# Untracked .sfs-local/migrate-tx + archives/pre-migrate-* allowed (transient artifacts).
if ! git diff --quiet HEAD --; then
  echo "AC10.5 FAIL: tracked working tree differs from HEAD after --recover"
  git diff --stat HEAD --
  exit 1
fi

echo "test-sfs-migrate-recovery-clean: OK (dest=0, archive=0, src ${src_count_post}/${src_count_pre} restored, tracked diff clean)"
