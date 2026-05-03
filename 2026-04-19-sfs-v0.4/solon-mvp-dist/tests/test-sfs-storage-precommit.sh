#!/usr/bin/env bash
# tests/test-sfs-storage-precommit.sh — R-B B-3/B-4/B-5 AC2.3 + AC2.4 + AC2.5 unit test.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-storage-precommit.sh"
INIT="${DIST_DIR}/scripts/sfs-storage-init.sh"

[[ -x "${SCRIPT}" ]] || { echo "missing: ${SCRIPT}" >&2; exit 1; }

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

cd "${tmp}"
git init -q
git config user.email t@t
git config user.name t

# 1. Build a paired Layer 1 + Layer 2 with valid sprint.yml — should PASS strict mode.
bash "${INIT}" --domain biz --sub apps --feat foo --sprint-id 0-6-0-good >/dev/null
mkdir -p .solon/sprints/0-6-0-good
cat > .solon/sprints/0-6-0-good/sprint.yml <<'YML'
sprint_id: 0-6-0-good
status: in-progress
features:
  - foo
dependencies: []
completion_criteria:
  - all green
milestones: []
created_at: 2026-05-04T00:00:00Z
closed_at: null
YML
bash "${SCRIPT}" --root . --strict >/dev/null

# 2. AC2.3 co-location FAIL: Layer 2 feat with no Layer 1 docs/*/*/feat/.
mkdir -p .solon/sprints/0-6-0-orphan/orphan
cat > .solon/sprints/0-6-0-orphan/sprint.yml <<'YML'
sprint_id: 0-6-0-orphan
status: in-progress
features:
  - orphan
dependencies: []
completion_criteria:
  - x
milestones: []
created_at: 2026-05-04T00:00:00Z
closed_at: null
YML
if bash "${SCRIPT}" --root . --strict 2>/dev/null; then
  echo "AC2.3 FAIL: orphan feat should fail strict mode"; exit 1
fi

# 3. Same orphan in advisory mode → exit 0.
bash "${SCRIPT}" --root . --advisory >/dev/null

echo "test-sfs-storage-precommit: OK"
