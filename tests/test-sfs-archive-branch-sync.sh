#!/usr/bin/env bash
# tests/test-sfs-archive-branch-sync.sh — R-B B-7 AC2.7 race lock unit test.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-archive-branch-sync.sh"

[[ -x "${SCRIPT}" ]] || { echo "missing: ${SCRIPT}" >&2; exit 1; }

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

cd "${tmp}"
git init -q
git config user.email t@t
git config user.name t
mkdir -p .solon/sprints/0-5-x-old
cat > .solon/sprints/0-5-x-old/sprint.yml <<'YML'
sprint_id: 0-5-x-old
status: closed
features: []
dependencies: []
completion_criteria: []
milestones: []
created_at: 2025-01-01T00:00:00Z
closed_at: 2025-12-01T00:00:00Z
YML
git add -A && git commit -q -m init

# AC2.7: dry-run lists 1 closed sprint without git changes.
out="$(bash "${SCRIPT}" --root . --dry-run 2>&1)"
echo "${out}" | grep -q "would move 1 closed sprint" || { echo "AC2.7 dry-run FAIL"; echo "${out}"; exit 1; }

# Verify race lock — second concurrent invocation must graceful-exit (exit 0, no error).
#
# 0.6.7 hotfix: the prior version of this test wrote `$$` into
# `.archive-sync.lock` and assumed the script's PID-content advisory check
# would detect it. But the script uses flock(1) when available (= almost
# always on Linux) and never reads the lock file's contents in that path,
# so the second invocation acquired its own flock cleanly and printed the
# dry-run summary instead of "graceful exit". The fix exercises both
# branches of the script's `acquire_lock`:
#   - flock available → take a real exclusive flock in this shell (fd 8)
#                       for the duration of the second invocation
#   - flock missing   → fall back to PID-content lock (the previous behavior)
mkdir -p .sfs-local
if command -v flock >/dev/null 2>&1; then
  exec 8>.sfs-local/.archive-sync.lock
  flock -n 8 || { echo "AC2.7 setup FAIL — could not acquire test flock on .archive-sync.lock"; exit 1; }
  out2="$(bash "${SCRIPT}" --root . --dry-run 2>&1 || true)"
  flock -u 8
  exec 8>&-
  rm -f .sfs-local/.archive-sync.lock
else
  echo "$$" > .sfs-local/.archive-sync.lock
  out2="$(bash "${SCRIPT}" --root . --dry-run 2>&1 || true)"
  rm -f .sfs-local/.archive-sync.lock
fi
echo "${out2}" | grep -qE "(graceful exit|holds (flock|advisory lock))" || {
  echo "AC2.7 race-lock 경로 mismatch:"; echo "${out2}"; exit 1
}

echo "test-sfs-archive-branch-sync: OK"
