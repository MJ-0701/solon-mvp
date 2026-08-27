#!/usr/bin/env bash
# Release docs must keep the five-division/six-role taxonomy contract in sync.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected stale '${needle}'"
  fi
}

expected_version="0.15.4"
actual_version="$(tr -d '[:space:]' < "${DIST_DIR}/VERSION")"
[[ "${actual_version}" == "${expected_version}" ]] \
  || fail "VERSION is ${actual_version}, expected ${expected_version}"

assert_contains "${DIST_DIR}/CHANGELOG.md" "## [${expected_version}] - 2026-08-27" "changelog current version"
assert_contains "${DIST_DIR}/RELEASE-NOTES.md" "## ${expected_version}" "release notes current version"

assert_contains "${DIST_DIR}/README.md" "5개 조직 본부 + cross-cutting taxonomy lens의 6개 필수 council role" "README council model"
assert_contains "${DIST_DIR}/docs/en/index.md" "five organization divisions plus the cross-cutting taxonomy lens as six required council roles" "EN index council model"
assert_contains "${DIST_DIR}/docs/ko/index.md" 'taxonomy` slot은 조직 division이' "KO index taxonomy boundary"
assert_contains "${DIST_DIR}/docs/ko/index.md" "이 여섯 role은 모두 필수 conceptual council participation role" "KO index six-role requirement"

policy="${DIST_DIR}/docs/maintenance/policies/six-division-council.md"
assert_contains "${policy}" "organization division은 strategy-pm / dev / QA / design / infra 다섯" "maintenance five-division boundary"
assert_contains "${policy}" "taxonomy는 조직 division이 아닌 foundational cross-cutting product" "maintenance taxonomy boundary"
assert_contains "${policy}" "이 여섯 required" "maintenance six-role requirement"
assert_contains "${policy}" "기존 Division Sub-agent Ledger heading" "legacy ledger heading compatibility"
assert_contains "${policy}" "say_warn" "healthcheck warn-only contract"
assert_contains "${policy}" "issue count/exit code를 바꾸지 않으며" "healthcheck exit behavior"

for template in \
  "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/plan.md" \
  "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/review.md"; do
  assert_contains "${template}" "Council Participation Ledger" "new template council heading"
  assert_contains "${template}" '| council role |' "new template council-role column"
  assert_contains "${template}" '| taxonomy |' "taxonomy required row"
  assert_not_contains "${template}" "Division Sub-agent Ledger" "new template avoids stale division heading"
done

echo "test-docs-division-version-sync: OK"
