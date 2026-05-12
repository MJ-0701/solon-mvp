#!/usr/bin/env bash
# 릴리스 verifier 내부 smoke 로그를 성공 시 숨기고 실패 시 증거로 복원하는지 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DIST_DIR}/.." && pwd)"
VERIFY_RELEASE="${REPO_ROOT}/scripts/verify-product-release.sh"

if [[ ! -f "${VERIFY_RELEASE}" ]]; then
  echo "test-release-verifier-quiet-smokes: SKIP (owner release script is not packaged in this tree)"
  exit 0
fi

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local needle="$1" label="$2"
  grep -Fq -- "${needle}" "${VERIFY_RELEASE}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local needle="$1" label="$2"
  if grep -Fq -- "${needle}" "${VERIFY_RELEASE}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

bash -n "${VERIFY_RELEASE}"

assert_contains "run_quiet()" "quiet helper"
assert_contains 'out="${TMP_DIR}/${slug}.log"' "captured log path"
assert_contains "sed 's/^/[verify-product-release]     /' \"\${out}\" >&2" "failure evidence replay"
assert_contains 'run_quiet "${label} thin install smoke"' "thin install quieted"
assert_contains 'run_quiet "${label} thin upgrade adapter migration smoke"' "thin upgrade quieted"
assert_contains 'run_quiet "${label} vendored install smoke"' "vendored install quieted"
assert_contains 'run_quiet "${label} vendored-to-thin upgrade smoke"' "vendored upgrade quieted"

assert_not_contains 'bash "${root}/install.sh" --yes --layout thin >/dev/null' "direct thin install stdout-only suppression"
assert_not_contains 'bash "${root}/upgrade.sh" --yes >/dev/null' "direct thin upgrade stdout-only suppression"
assert_not_contains 'bash "${root}/install.sh" --yes --layout vendored --with-agent-adapters >/dev/null' "direct vendored install stdout-only suppression"
assert_not_contains 'SFS_UPGRADE_LAYOUT=thin bash "${root}/upgrade.sh" --yes >/dev/null' "direct vendored upgrade stdout-only suppression"

echo "test-release-verifier-quiet-smokes: OK"
