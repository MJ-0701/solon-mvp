#!/usr/bin/env bash
# cut-release dry-run preview must count content changes, not metadata drift.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DIST_DIR}/.." && pwd)"
CUT_RELEASE="${REPO_ROOT}/scripts/cut-release.sh"
VERSION="$(head -1 "${DIST_DIR}/VERSION")"

if [[ ! -f "${CUT_RELEASE}" ]]; then
  echo "test-cut-release-preview-content-diff: SKIP (owner release scripts are not packaged in this tree)"
  exit 0
fi

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_output_contains() {
  local output="$1"
  local needle="$2"
  local label="$3"

  if ! grep -Fq -- "${needle}" <<< "${output}"; then
    echo "${output}" >&2
    fail "${label}: missing '${needle}'"
  fi
}

bash -n "${CUT_RELEASE}"
command -v rsync >/dev/null 2>&1 || {
  echo "test-cut-release-preview-content-diff: SKIP (rsync unavailable)"
  exit 0
}

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/sfs-cut-preview-content.XXXXXX")"
cleanup() {
  rm -rf "${TMP_ROOT}"
}
trap cleanup EXIT INT TERM

prepare_stable() {
  local stable="$1"

  mkdir -p "${stable}"
  rsync -a --delete --exclude='.git' "${DIST_DIR}/" "${stable}/"
  git -C "${stable}" init -q
  git -C "${stable}" config user.email "sfs-test@example.invalid"
  git -C "${stable}" config user.name "SFS Test"
  git -C "${stable}" add -A
  git -C "${stable}" commit -q -m "baseline"
}

run_preview() {
  local stable="$1"

  SOLON_STABLE_REPO="${stable}" bash "${CUT_RELEASE}" \
    --version "${VERSION}" --dry-run --allow-dirty 2>&1
}

metadata_stable="${TMP_ROOT}/stable-metadata"
prepare_stable "${metadata_stable}"
touch -t 200001010101 "${metadata_stable}/README.md"
touch -t 200001010101 "${metadata_stable}/install.sh"
metadata_output="$(run_preview "${metadata_stable}")"
assert_output_contains "${metadata_output}" \
  "summary: changed=0 new=0 deleted=0" \
  "metadata-only drift should not count as changed"

if ! grep -Fq -- '--checksum' "${CUT_RELEASE}"; then
  fail "cut-release dry-run preview does not use checksum/content-aware comparison"
fi

changed_stable="${TMP_ROOT}/stable-changed"
prepare_stable "${changed_stable}"
printf '# Stale stable README\n' > "${changed_stable}/README.md"
changed_output="$(run_preview "${changed_stable}")"
assert_output_contains "${changed_output}" \
  "summary: changed=1 new=0 deleted=0" \
  "true content change should count as changed"

deleted_stable="${TMP_ROOT}/stable-deleted"
prepare_stable "${deleted_stable}"
printf 'obsolete\n' > "${deleted_stable}/tests/obsolete-preview-file.txt"
deleted_output="$(run_preview "${deleted_stable}")"
assert_output_contains "${deleted_output}" \
  "summary: changed=0 new=0 deleted=1" \
  "extra stable file under allowlist directory should count as deleted"

echo "test-cut-release-preview-content-diff: OK"
