#!/usr/bin/env bash
# Owner release tooling must default to the current product stable clone path.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DIST_DIR}/.." && pwd)"

cut_release="${REPO_ROOT}/scripts/cut-release.sh"
check_drift="${REPO_ROOT}/scripts/check-drift.sh"
sync_stable="${REPO_ROOT}/scripts/sync-stable-to-dev.sh"
readme="${REPO_ROOT}/scripts/_README.md"

if [[ ! -f "${cut_release}" ]]; then
  echo "test-release-tooling-stable-repo-default: SKIP (owner release scripts are not packaged in this tree)"
  exit 0
fi

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

for script in "${cut_release}" "${check_drift}" "${sync_stable}"; do
  bash -n "${script}"
  assert_contains "${script}" '${HOME}/tmp/solon-product' "stable repo default ${script}"
done

assert_contains "${readme}" 'stable product repo' "README stable repo wording"
assert_contains "${readme}" '~/tmp/solon-product' "README current stable path"
assert_contains "${readme}" '--no-clean-handoff-check' "README clean handoff exception"
assert_contains "${readme}" '[verify-product-release]' "README failure evidence prefix"

echo "test-release-tooling-stable-repo-default: OK"
