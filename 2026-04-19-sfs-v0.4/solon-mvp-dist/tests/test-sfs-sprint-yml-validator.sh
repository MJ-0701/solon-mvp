#!/usr/bin/env bash
# tests/test-sfs-sprint-yml-validator.sh — R-F AC6.1/AC6.2/AC6.6 unit test.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-sprint-yml-validator.sh"

[[ -x "${SCRIPT}" ]] || { echo "missing: ${SCRIPT}" >&2; exit 1; }

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
cd "${tmp}"

# good.yml: 8 fields + valid status enum.
cat > good.yml <<'YML'
sprint_id: 0-6-0-test
status: in-progress
features:
  - foo
dependencies: []
completion_criteria:
  - x
milestones: []
created_at: 2026-05-04T00:00:00Z
closed_at: null
YML

bash "${SCRIPT}" --mode validate good.yml >/dev/null

# Bad enum.
cat > bad-enum.yml <<'YML'
sprint_id: x
status: BOGUS
features: []
dependencies: []
completion_criteria: []
milestones: []
created_at: 2026-05-04
closed_at: null
YML
if bash "${SCRIPT}" --mode validate bad-enum.yml 2>/dev/null; then
  echo "AC6.2 FAIL: BOGUS status should reject"; exit 1
fi

# Missing field.
cat > missing.yml <<'YML'
sprint_id: x
status: closed
YML
if bash "${SCRIPT}" --mode validate missing.yml 2>/dev/null; then
  echo "AC6.1 FAIL: missing fields should reject"; exit 1
fi

# AC6.4 close → archive.
mkdir -p .solon/sprints/0-5-x-close
cat > .solon/sprints/0-5-x-close/sprint.yml <<'YML'
sprint_id: 0-5-x-close
status: closed
features: []
dependencies: []
completion_criteria: []
milestones: []
created_at: 2025-01-01
closed_at: 2025-12-01
YML
git init -q
git config user.email t@t
git config user.name t
bash "${SCRIPT}" --mode close 0-5-x-close --force-action a --root . >/dev/null
[[ -f ".sfs-local/archives/sprint-yml/0-5-x-close.yml.gz" ]] || { echo "AC6.4 archive missing"; exit 1; }
[[ ! -f ".solon/sprints/0-5-x-close/sprint.yml" ]] || { echo "AC6.4 original sprint.yml should be removed"; exit 1; }

# AC6.5 close → delete.
mkdir -p .solon/sprints/0-5-x-del
cat > .solon/sprints/0-5-x-del/sprint.yml <<'YML'
sprint_id: 0-5-x-del
status: closed
features: []
dependencies: []
completion_criteria: []
milestones: []
created_at: 2025-01-01
closed_at: 2025-12-01
YML
bash "${SCRIPT}" --mode close 0-5-x-del --force-action d --root . >/dev/null
[[ ! -f ".solon/sprints/0-5-x-del/sprint.yml" ]] || { echo "AC6.5 delete failed"; exit 1; }
[[ ! -f ".sfs-local/archives/sprint-yml/0-5-x-del.yml.gz" ]] || { echo "AC6.5 should not archive on delete"; exit 1; }

echo "test-sfs-sprint-yml-validator: OK"
