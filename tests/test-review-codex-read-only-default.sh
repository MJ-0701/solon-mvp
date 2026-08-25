#!/usr/bin/env bash
# Codex review 기본 실행 권한을 read-only/never로 잠그고 구현 worker 권한과 분리한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

review_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"
auth_example="${DIST_DIR}/templates/.sfs-local-template/auth.env.example"
auth_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-auth.sh"
common_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-common.sh"
model_profiles="${DIST_DIR}/templates/.sfs-local-template/model-profiles.yaml"
review_surfaces=("${review_script}" "${auth_example}" "${auth_script}")

for file in "${review_surfaces[@]}"; do
  codex_lines="$(grep -F -- 'codex exec' "${file}" || true)"
  [[ -n "${codex_lines}" ]] || fail "review surface has no Codex command: ${file}"
  if grep -Fvq -- '--sandbox read-only' <<<"${codex_lines}"; then
    fail "review Codex command is not read-only: ${file}"
  fi
  normalized_codex_lines="$(sed 's/\\"/"/g' <<<"${codex_lines}")"
  if grep -Fvq -- 'approval_policy="never"' <<<"${normalized_codex_lines}"; then
    fail "review Codex command does not set approval_policy=never: ${file}"
  fi
  if grep -Fq -- '--full-auto' <<<"${codex_lines}"; then
    fail "review surface retains --full-auto: ${file}"
  fi
  if grep -Fq -- 'workspace-write' <<<"${codex_lines}"; then
    fail "review surface retains workspace-write: ${file}"
  fi
done

assert_contains "${review_script}" 'codex exec --sandbox read-only -c approval_policy=\"never\" --ephemeral --output-last-message' "review runtime default"
assert_contains "${auth_example}" 'SFS_REVIEW_CODEX_CMD='"'"'codex exec --sandbox read-only -c approval_policy="never"'"'"'' "review auth example"
assert_contains "${auth_script}" 'codex exec --sandbox read-only -c approval_policy=\"never\"' "review auth probe default"

# Issue #12 changes evaluator permissions only. Implementation workers retain write access.
assert_contains "${common_script}" 'codex)  echo "codex exec --full-auto"' "implementation worker full-auto default"
assert_contains "${model_profiles}" 'invoke: "codex exec {prompt} --sandbox workspace-write"' "implementation worker workspace-write profile"

echo "test-review-codex-read-only-default: OK"
