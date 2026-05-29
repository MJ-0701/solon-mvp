#!/usr/bin/env bash
# 0.7.10: the md-line-budget routed policy must itself be a loadable, in-budget
# policy doc and must carry the scope / threshold / exception contract that the
# harness md-line-budget-violation detector enforces. If a future edit drops a
# section or pushes the doc past its own ceiling, this test fails.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
POLICY_DIR="${DIST_DIR}/templates/.sfs-local-template/context/policies"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

for file in "${POLICY_DIR}/md-line-budget.md" "${POLICY_DIR}/md-line-budget.ko.md"; do
  [[ -f "${file}" ]] || fail "missing policy doc ${file}"

  # The policy that enforces the 200-line ceiling must obey it.
  lines="$(wc -l <"${file}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "${file} exceeds its own 200-line ceiling: ${lines}"

  # Frontmatter must make the doc routable.
  first_line="$(sed -n '1p' "${file}")"
  [[ "${first_line}" == "---" ]] || fail "${file} missing opening frontmatter"
  grep -Eq '^id:' "${file}" || fail "${file} missing id frontmatter"
  grep -Eq '^summary:' "${file}" || fail "${file} missing summary frontmatter"
  grep -Eq '^load_when:' "${file}" || fail "${file} missing load_when frontmatter"

  # Threshold contract — the three numbers the detector keys on.
  assert_contains "${file}" "180" "${file} warn threshold"
  assert_contains "${file}" "200" "${file} partial threshold"
  assert_contains "${file}" "250" "${file} fail threshold"
done

# Scope / exception contract (English doc is the canonical wording).
canon="${POLICY_DIR}/md-line-budget.md"
assert_contains "${canon}" "warn" "warn severity word"
assert_contains "${canon}" "partial" "partial severity word"
assert_contains "${canon}" "fail" "fail severity word"
assert_contains "${canon}" "In scope" "scope section header"
assert_contains "${canon}" "Out of scope" "exception section header"
assert_contains "${canon}" "Operational logs" "operational-log scope"
assert_contains "${canon}" "PROGRESS.md" "PROGRESS in scope"
assert_contains "${canon}" "HANDOFF-next-session.md" "HANDOFF in scope"
assert_contains "${canon}" "sessions/_INDEX.md" "session index in scope"
assert_contains "${canon}" "CHANGELOG.md" "changelog exception"
assert_contains "${canon}" "RELEASE-NOTES.md" "release-notes exception"
assert_contains "${canon}" "archive" "archive rotation as the fix"

# The policy must point at the harness detectors it backs.
assert_contains "${canon}" "md-line-budget-violation" "names the budget detector"
assert_contains "${canon}" "operational-log-lag" "names the lag detector"

# Routed index must list the policy so an agent can find it.
index="${DIST_DIR}/templates/.sfs-local-template/context/_INDEX.md"
assert_contains "${index}" "md-line-budget" "routed index lists md-line-budget policy"

echo "test-md-line-budget-policy: OK"
