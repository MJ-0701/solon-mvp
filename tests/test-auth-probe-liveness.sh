#!/usr/bin/env bash
# 인증 probe 는 실제 worker 호출 가능성과 민감정보 비저장을 함께 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-auth-probe-liveness.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_file_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

cd "${TMP_DIR}"
git init -q
printf '# Auth Probe Liveness Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

run_sfs init --layout thin --yes >/dev/null

fake_bin="${TMP_DIR}/fake-bin"
mkdir -p "${fake_bin}"
cat > "${fake_bin}/claude" <<'FAKE_CLAUDE'
#!/usr/bin/env bash
printf '%s\n' "$*" > "${SFS_FAKE_CLAUDE_ARGS_LOG}"
if [[ "$*" == *"--dangerously-skip-permissions"* ]]; then
  echo "dangerous bridge used" >&2
  exit 44
fi
if [[ "${SFS_FAKE_CLAUDE_FAIL:-0}" == "1" ]]; then
  echo "Failed to authenticate. API Error: 401 Invalid authentication credentials" >&2
  exit 1
fi
case "$*" in
  *SFS_AUTH_PROBE_OK*claude* ) ;;
  *) echo "missing probe marker in prompt argument: $*" >&2; exit 45 ;;
esac
echo "Authorization: Bearer ${SFS_FAKE_AUTH_HEADER_SECRET}"
echo "stdout secret ${SFS_FAKE_SECRET_TOKEN}"
echo "SFS_AUTH_PROBE_OK claude"
echo "stderr token ${SFS_FAKE_SECRET_TOKEN}" >&2
FAKE_CLAUDE
chmod +x "${fake_bin}/claude"

export PATH="${fake_bin}:$PATH"
export SFS_CLAUDE_AUTH_READY=1
export SFS_FAKE_CLAUDE_ARGS_LOG="${TMP_DIR}/claude-args.log"
export SFS_FAKE_SECRET_TOKEN="sfs-secret-token-123456789"
export SFS_FAKE_AUTH_HEADER_SECRET="sfs-auth-header-123456789"

probe_out="$(
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" \
    bash "${SFS_BIN}" auth probe --executor claude --timeout 5
)"
case "${probe_out}" in
  *"auth probe complete: claude"* ) ;;
  *) fail "successful probe did not complete: ${probe_out}" ;;
esac

stdout_path="$(printf '%s\n' "${probe_out}" | awk '/stdout:/ {print $2; exit}')"
stderr_path="$(printf '%s\n' "${probe_out}" | awk '/stderr:/ {print $2; exit}')"
prompt_path="$(printf '%s\n' "${probe_out}" | awk '/prompt:/ {print $2; exit}')"

assert_file_contains "${SFS_FAKE_CLAUDE_ARGS_LOG}" "SFS_AUTH_PROBE_OK claude" "claude received tiny probe marker"
assert_file_not_contains "${SFS_FAKE_CLAUDE_ARGS_LOG}" "--dangerously-skip-permissions" "claude probe args no dangerous mode"
assert_file_contains "${stdout_path}" "SFS_AUTH_PROBE_OK claude" "probe stdout marker"
assert_file_not_contains "${stdout_path}" "${SFS_FAKE_SECRET_TOKEN}" "probe stdout redacts env token"
assert_file_not_contains "${stderr_path}" "${SFS_FAKE_SECRET_TOKEN}" "probe stderr redacts env token"
assert_file_not_contains "${stdout_path}" "${SFS_FAKE_AUTH_HEADER_SECRET}" "probe stdout redacts auth header secret"
assert_file_not_contains "${prompt_path}" "${SFS_FAKE_SECRET_TOKEN}" "probe prompt excludes env token"
assert_file_not_contains "${prompt_path}" "CPO evaluator" "probe prompt excludes review payload"

set +e
fail_out="$(
  SFS_FAKE_CLAUDE_FAIL=1 SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" \
    bash "${SFS_BIN}" auth probe --executor claude --timeout 5 2>"${TMP_DIR}/fail.err"
)"
fail_rc=$?
set -e
[[ "${fail_rc}" == "9" ]] || {
  echo "stdout:" >&2
  printf '%s\n' "${fail_out}" >&2
  echo "stderr:" >&2
  cat "${TMP_DIR}/fail.err" >&2
  fail "failing Claude model call should exit 9, got ${fail_rc}"
}
grep -Fq "auth probe failed: claude" "${TMP_DIR}/fail.err" \
  || fail "failing probe should report auth probe failed"

echo "test-auth-probe-liveness: OK"
