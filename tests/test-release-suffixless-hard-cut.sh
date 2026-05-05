#!/usr/bin/env bash
# tests/test-release-suffixless-hard-cut.sh — 0.6.0+ release tooling must accept suffixless versions.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DIST_DIR}/.." && pwd)"
CUT_RELEASE="${REPO_ROOT}/scripts/cut-release.sh"
VERIFY_RELEASE="${REPO_ROOT}/scripts/verify-product-release.sh"
SCOOP_TEMPLATE="${DIST_DIR}/packaging/scoop/sfs.json.template"

[[ -f "${CUT_RELEASE}" ]] || { echo "missing: ${CUT_RELEASE}" >&2; exit 1; }
[[ -f "${VERIFY_RELEASE}" ]] || { echo "missing: ${VERIFY_RELEASE}" >&2; exit 1; }
[[ -f "${SCOOP_TEMPLATE}" ]] || { echo "missing: ${SCOOP_TEMPLATE}" >&2; exit 1; }

bash -n "${CUT_RELEASE}"
bash -n "${VERIFY_RELEASE}"

TMP_STABLE="$(mktemp -d "${TMPDIR:-/tmp}/sfs-release-suffixless.XXXXXX")"
cleanup() {
  rm -rf "${TMP_STABLE}"
}
trap cleanup EXIT INT TERM

git -C "${TMP_STABLE}" init -q
git -C "${TMP_STABLE}" config user.email "sfs-test@example.invalid"
git -C "${TMP_STABLE}" config user.name "SFS Test"
printf '0.5.96-product\n' > "${TMP_STABLE}/VERSION"
printf '# Solon Product\n' > "${TMP_STABLE}/README.md"
: > "${TMP_STABLE}/CHANGELOG.md"
printf 'readonly SOLON_REPO="MJ-0701/solon-product"\n' > "${TMP_STABLE}/install.sh"

if ! SOLON_STABLE_REPO="${TMP_STABLE}" bash "${CUT_RELEASE}" --version 0.6.0 --dry-run --allow-dirty >/dev/null; then
  echo "FAIL: cut-release.sh rejected suffixless version 0.6.0 in dry-run mode" >&2
  exit 1
fi

if grep -qE '\^[0-9]+\\\.\[0-9\]\+\\\.\[0-9\]\+-(mvp|product)' "${CUT_RELEASE}"; then
  echo "FAIL: cut-release.sh still appears to require a release suffix" >&2
  exit 1
fi

if ! grep -q 'X.Y.Z' "${CUT_RELEASE}"; then
  echo "FAIL: cut-release.sh help/error text does not document suffixless versions" >&2
  exit 1
fi

if ! grep -Fq '(-product)?' "${VERIFY_RELEASE}"; then
  echo "FAIL: verify-product-release.sh does not accept suffixless product versions" >&2
  exit 1
fi

if ! grep -Fq '(?:-product)?' "${SCOOP_TEMPLATE}"; then
  echo "FAIL: Scoop checkver regex does not match suffixless tags" >&2
  exit 1
fi

echo "test-release-suffixless-hard-cut: OK"
