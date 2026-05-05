#!/usr/bin/env bash
# tests/scoop-manifest-validate.sh — AC7.5 Scoop manifest schema check.
#
# Validates required JSON fields without requiring a real `scoop` CLI:
#   version, url, hash, bin, autoupdate (or checkver+autoupdate combo).
# This is the locally runnable surrogate for `scoop bucket validate`/`scoop checkver`.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST="${DIST_DIR}/packaging/scoop/sfs.json"
TEMPLATE="${DIST_DIR}/packaging/scoop/sfs.json.template"

target=""
if [[ -f "${MANIFEST}" ]]; then
  target="${MANIFEST}"
elif [[ -f "${TEMPLATE}" ]]; then
  target="${TEMPLATE}"
fi
[[ -n "${target}" ]] || { echo "AC7.5 FAIL: no scoop manifest or template found"; exit 1; }

required=(version url hash bin)
fail=0
for k in "${required[@]}"; do
  if ! grep -qE "\"${k}\"[[:space:]]*:" "${target}"; then
    echo "AC7.5 FAIL: ${target} missing field: ${k}"
    fail=$((fail + 1))
  fi
done

# Either checkver or autoupdate (release discovery support) should exist.
if ! grep -qE "\"(checkver|autoupdate)\"[[:space:]]*:" "${target}"; then
  echo "AC7.5 FAIL: ${target} missing checkver/autoupdate (release discovery)" >&2
  fail=$((fail + 1))
fi

if [[ "${fail}" -gt 0 ]]; then exit 1; fi
echo "scoop-manifest-validate: OK (${target}, $(echo "${required[@]}" | wc -w | tr -d ' ') required fields + release-discovery present)"
