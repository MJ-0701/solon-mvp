#!/usr/bin/env bash
# tests/test-backup-manifest-schema.sh — AC10.2 + AC10.3 backup manifest 9 fields + extension filter.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-migrate-artifacts.sh"

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
cd "${tmp}"
git init -q
git config user.email t@t
git config user.name t
mkdir -p .sfs-local/sprints/0-5-x-mfs
echo "data" > .sfs-local/sprints/0-5-x-mfs/notes.md
# Non-default extension to trigger skipped[] entry (AC10.3).
echo "binary" > .sfs-local/sprints/0-5-x-mfs/dummy.bin
git add -A && git commit -q -m init

bash "${SCRIPT}" --auto --root . >/dev/null 2>&1

manifest="$(find .sfs-local/archives -name manifest.json -type f 2>/dev/null | head -1 || true)"
[[ -n "${manifest}" ]] || { echo "AC10.2 FAIL: manifest.json not produced"; exit 1; }

# 9 required field grep.
required=(snapshot_id created_at source_repo_root source_sha files total_count total_bytes skipped extension_filter_applied)
fail=0
for f in "${required[@]}"; do
  if ! grep -q "\"${f}\"" "${manifest}"; then
    echo "AC10.2 FAIL: manifest missing field ${f}"; fail=$((fail + 1))
  fi
done

# AC10.3: skipped[] should contain dummy.bin.
if ! grep -q "dummy.bin" "${manifest}"; then
  echo "AC10.3 FAIL: dummy.bin not in skipped[]"; fail=$((fail + 1))
fi
# extension_filter_applied default true.
if ! grep -q '"extension_filter_applied": true' "${manifest}"; then
  echo "AC10.3 FAIL: extension_filter_applied should default true"; fail=$((fail + 1))
fi

if [[ "${fail}" -gt 0 ]]; then exit 1; fi
echo "test-backup-manifest-schema: OK"
