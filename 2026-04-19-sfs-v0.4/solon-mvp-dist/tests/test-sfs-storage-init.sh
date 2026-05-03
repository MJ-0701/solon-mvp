#!/usr/bin/env bash
# tests/test-sfs-storage-init.sh — R-B B-1/B-2 AC2.1 + AC2.2 unit test.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-storage-init.sh"

[[ -x "${SCRIPT}" ]] || { echo "missing: ${SCRIPT}" >&2; exit 1; }

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

cd "${tmp}"

# AC2.1 + AC2.2: create Layer 1 + Layer 2.
bash "${SCRIPT}" --domain biz --sub apps --feat checkout --sprint-id 0-6-0-test >/dev/null
[[ -d "docs/biz/apps/checkout" ]] || { echo "AC2.1 FAIL: docs/biz/apps/checkout/ missing"; exit 1; }
[[ -d ".solon/sprints/0-6-0-test/checkout" ]] || { echo "AC2.2 FAIL: .solon/sprints/0-6-0-test/checkout/ missing"; exit 1; }

# Bad slug → exit 2
if bash "${SCRIPT}" --domain "BAD_UPPER" --sub a --feat b --sprint-id c 2>/dev/null; then
  echo "FAIL: bad slug should exit non-zero"; exit 1
fi

# Validate mode OK on freshly-created tree.
bash "${SCRIPT}" --validate . >/dev/null

# Idempotent re-run.
bash "${SCRIPT}" --domain biz --sub apps --feat checkout --sprint-id 0-6-0-test >/dev/null

echo "test-sfs-storage-init: OK"
