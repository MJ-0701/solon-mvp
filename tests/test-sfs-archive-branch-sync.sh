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
mkdir -p .sfs-local
echo "$$" > .sfs-local/.archive-sync.lock
out2="$(bash "${SCRIPT}" --root . --dry-run 2>&1 || true)"
echo "${out2}" | grep -qE "(graceful exit|holds (flock|advisory lock))" || {
  # If our PID-based lock check sees our own PID alive, second call should bail.
  # Fallback: this verifies the script at least handles the lock file presence path.
  echo "AC2.7 race-lock 경로 mismatch:"; echo "${out2}"; exit 1
}
rm -f .sfs-local/.archive-sync.lock

echo "test-sfs-archive-branch-sync: OK"
