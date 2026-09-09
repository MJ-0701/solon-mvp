#!/usr/bin/env bash
# tests/test-sfs-quality-gate.sh — bounded wrapper contract for scripts/sfs-quality-gate.sh.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-quality-gate.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

[[ -f "${SCRIPT}" ]] || fail "missing scripts/sfs-quality-gate.sh"
[[ -x "${SCRIPT}" ]] || fail "scripts/sfs-quality-gate.sh must be executable"
bash -n "${SCRIPT}" || fail "quality gate script is not valid bash"

tmp="$(mktemp -d)"
cleanup() {
  rm -rf "${tmp}"
}
trap cleanup EXIT

make_fake_repo() {
  local root="$1"
  mkdir -p "${root}/scripts" "${root}/tests"
  printf '#!/usr/bin/env bash\necho syntax-ok\n' > "${root}/scripts/syntax-ok.sh"
  printf '#!/usr/bin/env bash\necho syntax-ok\n' > "${root}/tests/syntax-ok.sh"
  chmod +x "${root}/scripts/syntax-ok.sh" "${root}/tests/syntax-ok.sh"

  cat > "${root}/scripts/_fake-step.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
name="$(basename "$0")"
log="${FAKE_STEP_LOG:?}"
printf '%s %s\n' "${name}" "$*" >> "${log}"
if [[ "${FAIL_STEP:-}" == "${name}" ]]; then
  exit "${FAIL_RC:-7}"
fi
printf '%s: OK\n' "${name}"
EOF
  chmod +x "${root}/scripts/_fake-step.sh"

  local f
  for f in \
    sfs-pr-review-flow-check.sh \
    sfs-storage-precommit.sh \
    verify-product-release.sh \
    sfs-channel-publish-preflight.sh
  do
    cp "${root}/scripts/_fake-step.sh" "${root}/scripts/${f}"
    chmod +x "${root}/scripts/${f}"
  done
  for f in \
    test-bad-fixture.sh \
    test-aws-agent-toolkit-setup-policy.sh \
    test-sfs-pr-check-strict.sh \
    test-sfs-quality-gate.sh \
    test-workflow-permissions.sh \
    scoop-manifest-validate.sh \
    test-hash-parity.sh \
    run-all.sh
  do
    cp "${root}/scripts/_fake-step.sh" "${root}/tests/${f}"
    chmod +x "${root}/tests/${f}"
  done
}

write_event() {
  local path="$1" kind="$2"
  case "${kind}" in
    pr)
      printf '{ "pull_request": { "body": "Gate 6 self-CPO PASS" } }\n' > "${path}"
      ;;
    push)
      printf '{ "ref": "refs/heads/main", "head_commit": { "id": "abc123" } }\n' > "${path}"
      ;;
    *)
      fail "unknown fake event kind: ${kind}"
      ;;
  esac
}

run_quality_gate() {
  # The CI workflow exports real PR evidence. This fixture asserts each event
  # mode independently, so it must not inherit ambient PR context or event
  # payloads. Fixture event payloads use FAKE_GITHUB_EVENT_PATH instead.
  local fake_github_event_path="${FAKE_GITHUB_EVENT_PATH:-}"
  (
    unset SFS_PR_BODY SFS_PR_BASE_SHA SFS_PR_HEAD_SHA GITHUB_EVENT_PATH
    if [[ -n "${fake_github_event_path}" ]]; then
      export GITHUB_EVENT_PATH="${fake_github_event_path}"
    fi
    bash "${SCRIPT}" "$@"
  )
}

repo="${tmp}/repo"
make_fake_repo "${repo}"
step_log="${tmp}/steps.log"
: > "${step_log}"

help_out="$(bash "${SCRIPT}" --help)"
printf '%s\n' "${help_out}" | grep -q "pr|full|release" || fail "--help must document modes"
printf '%s\n' "${help_out}" | grep -q "tests/run-all.sh" || fail "--help must document full mode run-all"
printf '%s\n' "${help_out}" | grep -q "verify-product-release.sh --version X.Y.Z" || fail "--help must document release verifier"
printf '%s\n' "${help_out}" | grep -q "tests/test-sfs-quality-gate.sh" || fail "--help must document wrapper contract coverage"
printf '%s\n' "${help_out}" | grep -q "tests/test-aws-agent-toolkit-setup-policy.sh" || fail "--help must document AWS policy coverage"
printf '%s\n' "${help_out}" | grep -q "tests/test-sfs-pr-check-strict.sh" || fail "--help must document PR strict-contract regression"

pr_out="$(FAKE_STEP_LOG="${step_log}" run_quality_gate --root "${repo}" --mode pr)"
printf '%s\n' "${pr_out}" | grep -q 'SKIP pr-review-flow-evidence' || fail "pr mode should skip review-flow without explicit PR context"
printf '%s\n' "${pr_out}" | grep -q 'PASS storage-precommit' || fail "pr mode should run storage-precommit"
printf '%s\n' "${pr_out}" | grep -q 'PASS quality-gate-contract' || fail "pr mode should run wrapper contract coverage"
printf '%s\n' "${pr_out}" | grep -q 'PASS aws-agent-toolkit-policy' || fail "pr mode should run AWS policy coverage"
printf '%s\n' "${pr_out}" | grep -q 'PASS pr-check-strict-contract' || fail "pr mode should run strict-contract regression"
if printf '%s\n' "${pr_out}" | grep -q 'run-all'; then
  fail "pr mode must not run run-all"
fi
if grep -q 'run-all.sh' "${step_log}"; then
  fail "pr mode must not execute tests/run-all.sh"
fi
grep -q 'test-sfs-quality-gate.sh' "${step_log}" || fail "pr mode should execute its wrapper contract against the fake repo"
grep -q 'test-aws-agent-toolkit-setup-policy.sh' "${step_log}" || fail "pr mode should execute AWS policy coverage"
grep -q 'test-sfs-pr-check-strict.sh' "${step_log}" || fail "pr mode should execute tests/test-sfs-pr-check-strict.sh"

full_out="$(FAKE_STEP_LOG="${step_log}" run_quality_gate --root "${repo}" --mode full)"
printf '%s\n' "${full_out}" | grep -q 'PASS run-all' || fail "full mode should run run-all"
grep -q 'run-all.sh' "${step_log}" || fail "full mode should execute tests/run-all.sh"

push_event="${tmp}/push-event.json"
write_event "${push_event}" push
push_out="$(FAKE_GITHUB_EVENT_PATH="${push_event}" FAKE_STEP_LOG="${step_log}" run_quality_gate --root "${repo}" --mode pr)"
printf '%s\n' "${push_out}" | grep -q 'SKIP pr-review-flow-evidence' || fail "push event payload must not trigger PR review-flow step"

pr_event="${tmp}/pr-event.json"
write_event "${pr_event}" pr
pr_event_out="$(FAKE_GITHUB_EVENT_PATH="${pr_event}" FAKE_STEP_LOG="${step_log}" run_quality_gate --root "${repo}" --mode pr)"
printf '%s\n' "${pr_event_out}" | grep -q 'PASS pr-review-flow-evidence' || fail "pull_request event payload should trigger PR review-flow step"
grep -q 'sfs-pr-review-flow-check.sh --root .* --strict' "${step_log}" || fail "PR event payload should execute review-flow step"

rc=0
run_quality_gate --root "${repo}" --mode release >/dev/null 2>&1 || rc=$?
[[ "${rc}" -eq 2 ]] || fail "release mode without --version must exit 2 (got ${rc})"

release_out="$(PATH="/usr/bin:/bin" FAKE_STEP_LOG="${step_log}" run_quality_gate --root "${repo}" --mode release --version 1.2.3)"
printf '%s\n' "${release_out}" | grep -q 'PASS verify-product-release' || fail "release mode should run release verifier"
printf '%s\n' "${release_out}" | grep -q 'SKIP channel-publish-preflight' || fail "release mode should skip gh preflight when gh is unavailable"

rc=0
set +e
FAIL_STEP="sfs-storage-precommit.sh" FAIL_RC=9 FAKE_STEP_LOG="${step_log}" \
  run_quality_gate --root "${repo}" --mode pr >"${tmp}/fail.out" 2>&1
rc=$?
set -e
[[ "${rc}" -eq 9 ]] || fail "failing child step must preserve exit code 9 (got ${rc})"
grep -q 'FAIL storage-precommit' "${tmp}/fail.out" || fail "failure summary must mark storage-precommit as FAIL"
grep -q 'mode=pr' "${tmp}/fail.out" || fail "failure summary must include mode"

echo "test-sfs-quality-gate: OK"
