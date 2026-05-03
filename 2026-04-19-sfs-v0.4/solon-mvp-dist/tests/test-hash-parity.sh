#!/usr/bin/env bash
# tests/test-hash-parity.sh — AC12 cross-platform SHA256 parity + LF normalization.
#
# Verify .gitattributes declares text eol=lf for SFS artifact extensions,
# and that representative spec/yml files are LF-only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
GA="${DIST_DIR}/.gitattributes"

[[ -f "${GA}" ]] || { echo "AC12 FAIL: .gitattributes missing"; exit 1; }

required_exts=(yml yaml md jsonl json toml txt)
fail=0
for ext in "${required_exts[@]}"; do
  if ! grep -qE "^\*\.${ext}[[:space:]]+text[[:space:]]+eol=lf" "${GA}"; then
    echo "AC12 FAIL: .gitattributes missing 'text eol=lf' for *.${ext}"
    fail=$((fail + 1))
  fi
done

# Sample a few existing tracked files for CRLF presence.
sample_files=("${DIST_DIR}/CHANGELOG.md" "${DIST_DIR}/VERSION")
for f in "${sample_files[@]}"; do
  [[ -f "${f}" ]] || continue
  if grep -q $'\r' "${f}" 2>/dev/null; then
    echo "AC12 FAIL: CRLF detected in ${f}"
    fail=$((fail + 1))
  fi
done

if [[ "${fail}" -gt 0 ]]; then exit 1; fi
echo "test-hash-parity: OK (.gitattributes covers ${#required_exts[@]} ext, no CRLF in samples)"
