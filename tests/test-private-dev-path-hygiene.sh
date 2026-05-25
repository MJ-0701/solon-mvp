#!/usr/bin/env bash
# Active product surfaces must not leak the maintainer's private dev checkout.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

private_name="agent""_architect"
absolute_path="/Users/mj/${private_name}"
home_path="~/${private_name}"

tmp="$(mktemp -d "${TMPDIR:-/tmp}/sfs-private-path-hygiene.XXXXXX")"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

patterns="${tmp}/patterns.txt"
printf '%s\n%s\n%s\n' "${private_name}" "${absolute_path}" "${home_path}" > "${patterns}"

scan_file="${tmp}/files.txt"
find "${DIST_DIR}" \
  \( -path "${DIST_DIR}/.git" -o -path "${DIST_DIR}/.sfs-local" \) -prune -o \
  -type f \
  ! -name 'CHANGELOG.md' \
  ! -name 'RELEASE-NOTES.md' \
  ! -name 'test-private-dev-path-hygiene.sh' \
  -print > "${scan_file}"

while IFS= read -r file; do
  grep -FIn -f "${patterns}" "${file}" >> "${tmp}/hits.txt" || true
done < "${scan_file}"

if [[ -s "${tmp}/hits.txt" ]]; then
  cat "${tmp}/hits.txt" >&2
  fail "private dev staging path leaked into active product files"
fi

echo "test-private-dev-path-hygiene: OK"
