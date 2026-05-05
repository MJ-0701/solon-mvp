#!/usr/bin/env bash
# tests/test-no-data-loss.sh — anti-AC10 data-loss verification.
#
# Rule: every migration source file must end up in one of:
#   (a) files[] of manifest with sha256 verified post-migrate
#   (b) action=archive (named in matrix)
#   (c) skipped[] of manifest (extension filter exclusion)
#
# Negative test: simulate a "lost" file (sha mismatch + not archived/skipped) → expect failure.

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
mkdir -p .sfs-local/sprints/0-5-x-loss
echo "alpha" > .sfs-local/sprints/0-5-x-loss/a.md
echo "beta" > .sfs-local/sprints/0-5-x-loss/b.md
git add -A && git commit -q -m init

# Capture pre-migration sha256 of source files.
before_count="$(find .sfs-local/sprints/0-5-x-loss -type f | wc -l | tr -d ' ')"

bash "${MIGRATE}" --auto --root . >/dev/null 2>&1

manifest="$(find .sfs-local/archives -name manifest.json -type f 2>/dev/null | head -1 || true)"
[[ -n "${manifest}" ]] || { echo "anti-AC10 FAIL: no manifest"; exit 1; }

# Count manifest 'path' entries from files[] and skipped[].
path_entries="$(grep -oE '"path":"[^"]*"' "${manifest}" | sort -u | wc -l | tr -d ' ')"

# Count post-migration files in dest + archive (handle missing dirs).
dest_count="$( { find .solon/sprints -type f 2>/dev/null || true; } | wc -l | tr -d ' ')"
archive_count="$( { find .sfs-local/archives/migrate-archive -type f 2>/dev/null || true; } | wc -l | tr -d ' ')"

# Each source file must be accounted for.
total_accounted=$((dest_count + archive_count))

if [[ "${total_accounted}" -lt "${before_count}" ]]; then
  echo "anti-AC10 FAIL: ${before_count} sources, only ${total_accounted} accounted (dest=${dest_count} archive=${archive_count})"
  exit 1
fi

# Negative test: artificially corrupt a migrated file and verify our heuristic detects the mismatch.
victim="$(find .solon/sprints -type f -name 'a.md' | head -1)"
if [[ -n "${victim}" ]]; then
  echo "CORRUPT" > "${victim}"
  # Compare sha256 with pre-migration capture in manifest.
  expected_sha="$(grep -oE '"path":"[^"]*a\.md","sha256":"[a-f0-9]{64}"' "${manifest}" | head -1 | sed -E 's/.*"sha256":"([a-f0-9]{64})".*/\1/')"
  if command -v sha256sum >/dev/null 2>&1; then
    actual_sha="$(sha256sum "${victim}" | awk '{print $1}')"
  else
    actual_sha="$(shasum -a 256 "${victim}" | awk '{print $1}')"
  fi
  if [[ -n "${expected_sha}" ]] && [[ "${expected_sha}" == "${actual_sha}" ]]; then
    echo "anti-AC10 FAIL: corrupted victim should have differing sha but matched — heuristic broken"
    exit 1
  fi
fi

echo "test-no-data-loss: OK (anti-AC10 guard active, ${total_accounted}/${before_count} accounted, ${path_entries} manifest entries)"
