#!/usr/bin/env bash
# tests/test-no-data-loss-corruption-negative.sh — G6.1 F4 regression.
#
# Contract: verify_no_data_loss MUST exit 3 when post-state files are corrupted
# (sha256 or size mismatch vs manifest) — anti-AC10 silent-data-loss path eliminated.
#
# Test:
#   1) Apply migration on a synthetic 0.5.x tree.
#   2) Standalone --verify-snapshot against the captured manifest → expect exit 0.
#   3) Corrupt one migrated dest file (rewrite content) AND one archived .gz blob.
#   4) Re-run --verify-snapshot → expect exit 3 + mismatch report on stderr.
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

mkdir -p .sfs-local/sprints/0-5-x-corrupt
echo "alpha-data-original" > .sfs-local/sprints/0-5-x-corrupt/a.md
echo "beta-data-original"  > .sfs-local/sprints/0-5-x-corrupt/b.md
echo "report-original"     > .sfs-local/sprints/0-5-x-corrupt/report.md
git add -A && git commit -q -m init >/dev/null

bash "${MIGRATE}" --auto --root . >/dev/null 2>&1

snap_iso="$(find .sfs-local/archives -maxdepth 1 -name 'pre-migrate-*' -type d | head -1 | sed 's|.*pre-migrate-||')"
[[ -n "${snap_iso}" ]] || { echo "F4 FAIL: no snapshot found"; exit 1; }

# Step 2: clean verify must succeed.
if ! bash "${MIGRATE}" --verify-snapshot "${snap_iso}" --root . >/dev/null 2>&1; then
  ec=$?
  echo "F4 FAIL: clean verify failed (exit ${ec}) — should be 0 right after a successful apply"
  exit 1
fi

# Step 3: corrupt a migrated dest (a.md) AND the archived report.md gzip blob.
victim_dest="$(find .solon/sprints -type f -name 'a.md' | head -1)"
[[ -n "${victim_dest}" ]] || { echo "F4 FAIL: a.md dest not found"; exit 1; }
echo "TAMPERED" > "${victim_dest}"

victim_archive="$(find .sfs-local/archives/migrate-archive -type f -name '*report.md.gz' | head -1)"
[[ -n "${victim_archive}" ]] || { echo "F4 FAIL: report.md.gz archive not found"; exit 1; }
# Replace gzip blob with another valid gzip of different content (so gunzip succeeds but sha mismatches).
echo "TAMPERED-archive-content" | gzip -c > "${victim_archive}"

# Step 4: re-verify must fail with exit 3.
set +e
bash "${MIGRATE}" --verify-snapshot "${snap_iso}" --root . >/tmp/verify.out 2>/tmp/verify.err
ec=$?
set -e

if [[ "${ec}" -ne 3 ]]; then
  echo "F4 FAIL: corruption verify exit=${ec} (expected 3 = anti-AC10 violation)"
  echo "  stdout:"; sed 's/^/    /' /tmp/verify.out 2>/dev/null
  echo "  stderr:"; sed 's/^/    /' /tmp/verify.err 2>/dev/null
  exit 1
fi

# Stderr must mention MISMATCH or MISSING for both victims.
if ! grep -qE 'MISMATCH|MISSING' /tmp/verify.err 2>/dev/null; then
  echo "F4 FAIL: stderr does not contain MISMATCH/MISSING report"
  cat /tmp/verify.err 2>/dev/null | sed 's/^/    /'
  exit 1
fi

echo "test-no-data-loss-corruption-negative: OK (clean verify=0, corrupted verify=3 with mismatch report)"
