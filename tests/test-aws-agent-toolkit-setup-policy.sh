#!/usr/bin/env bash
# Distributed AWS Agent Toolkit setup-policy static regression coverage.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
POLICY="${DIST_DIR}/templates/.sfs-local-template/context/policies/aws-agent-toolkit-setup.md"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local needle="$1" label="$2"
  grep -Fq -- "${needle}" "${POLICY}" || fail "${label}: missing '${needle}'"
}

[[ -f "${POLICY}" ]] || fail "missing AWS Agent Toolkit setup policy"

assert_contains "AWS CLI v2.35.0 or newer" "minimum AWS CLI v2 prerequisite"
assert_contains "A named AWS CLI profile (\`<profile_name>\`)" "named AWS CLI profile declaration"
assert_contains "never an assumed \`default\` profile" "named profile requirement"
assert_contains "browser sign-in belongs to the human; stop until it completes or is cancelled" "browser human-interaction pause"
assert_contains "aws configure agent-toolkit --yes --region us-east-1 --profile" "toolkit service region"
assert_contains "aws agent-toolkit list-available-skills" "catalog verification command"
assert_contains "--region us-east-1 --profile <profile_name>" "catalog service region"
assert_contains "Do not put credentials, access keys, secret keys, tokens, or identity output in docs, prompts, logs, or MCP configuration." "credential and identity non-persistence"
assert_contains "never persist returned account or identity values" "identity result non-persistence"

echo "test-aws-agent-toolkit-setup-policy: OK"
