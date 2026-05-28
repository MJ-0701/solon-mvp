#!/usr/bin/env bash
# Active product surfaces must not leak the maintainer's private dev checkout.
#
# The forbidden patterns include both the canonical private working-tree name
# (`agent_architect`) and the dated docset directories / docset-internal
# fixtures that live inside it. 0.6.141's `sfs-harness.sh` shipped two
# hardcoded `2026-04-19-sfs-v0.4/...` paths that the old test could not see
# because it only matched the canonical name; 0.6.142 expands the patterns to
# fail loudly on any private docset fingerprint.
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

# Fixed-string patterns: canonical workdir name + the two common host paths.
fixed_patterns="${tmp}/patterns.txt"
printf '%s\n%s\n%s\n' "${private_name}" "${absolute_path}" "${home_path}" \
  > "${fixed_patterns}"

# Regex patterns: dated docset directories (e.g. 2026-04-19-sfs-v0.4) and
# the docset-internal phase template directory. The unqualified
# `solon-mvp-dist` label is grandfathered for now — it appears in script
# header banners and test fixtures as legacy dev-provenance metadata and is
# tracked as a separate cleanup. New leaks of dated docset directories,
# absolute /Users/mj/ paths, or `phase1-mvp-templates` references will fail
# this hygiene test immediately.
regex_patterns="${tmp}/regex.txt"
{
  printf '%s\n' '[0-9]{4}-[0-9]{2}-[0-9]{2}-sfs-v[0-9]'
  printf '%s\n' 'phase1-mvp-templates'
} > "${regex_patterns}"

scan_file="${tmp}/files.txt"
# Historical-evidence files are allowed to cite forbidden paths as evidence
# of past incidents; they are not active product surfaces. The QA-REPORT-*.md
# family is the same shape — a one-shot incident report, not running code.
find "${DIST_DIR}" \
  \( -path "${DIST_DIR}/.git" -o -path "${DIST_DIR}/.sfs-local" \) -prune -o \
  -type f \
  ! -name 'CHANGELOG.md' \
  ! -name 'RELEASE-NOTES.md' \
  ! -name 'QA-REPORT-*.md' \
  ! -name 'test-private-dev-path-hygiene.sh' \
  -print > "${scan_file}"

while IFS= read -r file; do
  grep -FIn -f "${fixed_patterns}" "${file}" >> "${tmp}/hits.txt" || true
  grep -EIn -f "${regex_patterns}" "${file}" >> "${tmp}/hits.txt" || true
done < "${scan_file}"

if [[ -s "${tmp}/hits.txt" ]]; then
  cat "${tmp}/hits.txt" >&2
  fail "private dev staging path leaked into active product files"
fi

echo "test-private-dev-path-hygiene: OK"
