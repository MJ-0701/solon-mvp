#!/usr/bin/env bash
# tests/test-hash-parity.sh — AC12 cross-platform SHA256 parity + LF normalization.
#
# Two layers:
#   (1) .gitattributes declares text eol=lf for SFS artifact extensions, and
#       representative spec/yml files are LF-only (no CRLF).
#   (2) G6.1 F6 — when running on Windows (powershell.exe available), recompute
#       sha256 via PowerShell `Get-FileHash` and assert strict equality with
#       POSIX `sha256sum`/`shasum`. Skipped (no-op) on non-Windows runners.
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

# G6.1 F6 — Windows PowerShell vs POSIX sha256sum parity.
# Triggered only when powershell.exe (or pwsh) is on PATH (Windows runners under bash).
posix_hash() {
  local f="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${f}" | awk '{print tolower($1)}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${f}" | awk '{print tolower($1)}'
  else
    return 1
  fi
}

ps_cmd=""
if command -v powershell.exe >/dev/null 2>&1; then
  ps_cmd="powershell.exe"
elif command -v pwsh >/dev/null 2>&1; then
  ps_cmd="pwsh"
fi

parity_checked=0
if [[ -n "${ps_cmd}" ]]; then
  for f in "${sample_files[@]}"; do
    [[ -f "${f}" ]] || continue
    posix=""
    posix="$(posix_hash "${f}" 2>/dev/null || echo "")"
    if [[ -z "${posix}" ]]; then
      echo "AC12 FAIL: posix sha256 unavailable for ${f}"
      fail=$((fail + 1))
      continue
    fi
    win="$("${ps_cmd}" -NoProfile -Command "(Get-FileHash -Algorithm SHA256 -LiteralPath '${f}').Hash.ToLower()" 2>/dev/null | tr -d '\r\n[:space:]')"
    if [[ -z "${win}" ]]; then
      echo "AC12 FAIL: PowerShell Get-FileHash returned empty for ${f}"
      fail=$((fail + 1))
      continue
    fi
    if [[ "${posix}" != "${win}" ]]; then
      echo "AC12 FAIL: hash parity mismatch for ${f}: posix=${posix} powershell=${win}"
      fail=$((fail + 1))
    else
      parity_checked=$((parity_checked + 1))
    fi
  done
  printf 'test-hash-parity: PowerShell parity checked %d sample(s)\n' "${parity_checked}"
else
  printf 'test-hash-parity: PowerShell not available — skipping cross-platform parity (POSIX-only environment)\n'
fi

if [[ "${fail}" -gt 0 ]]; then exit 1; fi
echo "test-hash-parity: OK (.gitattributes covers ${#required_exts[@]} ext, no CRLF in samples, ps_parity=${parity_checked})"
