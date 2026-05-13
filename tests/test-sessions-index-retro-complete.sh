#!/usr/bin/env bash
# Owner sessions index should not keep the April 19th/20th retro gap open.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DIST_DIR}/.." && pwd)"
SESSIONS_DIR="${REPO_ROOT}/sessions"
INDEX="${SESSIONS_DIR}/_INDEX.md"

if [[ ! -f "${INDEX}" ]]; then
  echo "test-sessions-index-retro-complete: SKIP (owner sessions index is not packaged in this tree)"
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

assert_not_contains_line() {
  local file="$1"
  local pattern="$2"
  local label="$3"

  if grep -F -- "${pattern}" "${file}" | grep -Fq -- "retrospective 미작성"; then
    fail "${label}: still marked retrospective missing"
  fi
}

eager="${SESSIONS_DIR}/2026-04-25-eager-elegant-bell.md"
epic="${SESSIONS_DIR}/2026-04-25-epic-brave-galileo.md"

assert_contains "${INDEX}" "2026-04-25-eager-elegant-bell.md" "index eager link"
assert_contains "${INDEX}" "2026-04-25-epic-brave-galileo.md" "index epic link"
assert_contains "${INDEX}" "D-E-meta-retro lifecycle closed" "index D-E closure"
assert_contains "${INDEX}" "0 sessions 남음" "index no remaining sessions"
assert_not_contains_line "${INDEX}" 'eager-elegant-bell' "eager index row"
assert_not_contains_line "${INDEX}" 'epic-brave-galileo' "epic index row"

assert_contains "${eager}" "session_codename: eager-elegant-bell" "eager frontmatter"
assert_contains "${eager}" "P-04-session-hang-takeover" "eager P-04 cross ref"
assert_contains "${eager}" "3471c12" "eager commit trace"
assert_contains "${epic}" "session_codename: epic-brave-galileo" "epic frontmatter"
assert_contains "${epic}" "a66cf2e" "epic close commit trace"
assert_contains "${epic}" "stale mutex takeover" "epic takeover trace"

echo "test-sessions-index-retro-complete: OK"
