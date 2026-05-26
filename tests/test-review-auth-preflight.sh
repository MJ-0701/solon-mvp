#!/usr/bin/env bash
# tests/test-review-auth-preflight.sh — named review executors ask for auth before full prompt generation.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-auth-preflight.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_with_timeout() {
  local seconds="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "${seconds}s" "$@"
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout "${seconds}s" "$@"
  else
    perl -e 'alarm shift @ARGV; exec @ARGV' "${seconds}" "$@"
  fi
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

cd "${TMP_DIR}"
git init -q
printf '# Review Auth Preflight Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

run_sfs init --layout thin --yes >/dev/null
run_sfs start "review auth preflight" >/dev/null

sprint_id="$(cat .sfs-local/current-sprint)"
sprint_dir=".sfs-local/sprints/${sprint_id}"
mkdir -p "${sprint_dir}"
cat > "${sprint_dir}/plan.md" <<'PLAN'
---
phase: plan
status: ready-for-review
---

# Plan

Artifact types touched: docs
Acceptance criteria:
- Review auth must be checked before full CPO prompt generation.
PLAN

fake_bin="${TMP_DIR}/fake-bin"
mkdir -p "${fake_bin}"
cat > "${fake_bin}/gemini" <<'FAKE_GEMINI'
#!/usr/bin/env bash
args="$*"
if [[ "${args}" == *"SFS_REVIEW_BRIDGE_PROBE_OK"* ]]; then
  printf 'SFS_REVIEW_BRIDGE_PROBE_OK\n'
  exit 0
fi
while IFS= read -r _line; do :; done
cat <<'RESULT'
Verdict: pass
Review lens: docs
Review independence risk: none
Artifact quality verdict:
- Auth preflight passed before full review.
Evidence bundle verdict:
- Prompt evidence was readable.
Evidence checked:
- plan.md
Evidence gaps:
- none
Findings:
- none
Required CTO actions:
- none
Next action:
- continue
Final recommendation:
- pass
RESULT
FAKE_GEMINI
chmod +x "${fake_bin}/gemini"

set +e
env -u GEMINI_API_KEY -u GOOGLE_API_KEY -u GOOGLE_APPLICATION_CREDENTIALS -u SFS_GEMINI_AUTH_READY \
  PATH="${fake_bin}:$PATH" SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" \
  bash "${SFS_BIN}" review --gate 3 --executor gemini --no-auth-interactive >"${TMP_DIR}/missing.out" 2>"${TMP_DIR}/missing.err"
missing_rc=$?
set -e
[[ "${missing_rc}" == "9" ]] || {
  echo "stdout:" >&2
  cat "${TMP_DIR}/missing.out" >&2
  echo "stderr:" >&2
  cat "${TMP_DIR}/missing.err" >&2
  fail "missing Gemini auth should exit 9, got ${missing_rc}"
}
grep -Fq "review auth preflight required: gemini" "${TMP_DIR}/missing.err" \
  || fail "missing auth stderr should name review auth preflight"
grep -Fq "Review was not started, and no CPO prompt was generated." "${TMP_DIR}/missing.err" \
  || fail "missing auth stderr should say no prompt was generated"
grep -Fq 'sfs auth login --executor gemini' "${TMP_DIR}/missing.err" \
  || fail "missing auth stderr should point to auth login"
[[ ! -f "${sprint_dir}/review.md" ]] \
  || fail "review.md should not be created when auth preflight blocks"
if [[ -d .sfs-local/tmp/review-prompts ]] && find .sfs-local/tmp/review-prompts -type f | grep -q .; then
  fail "review prompt files should not be created when auth preflight blocks"
fi
if [[ -f .sfs-local/events.jsonl ]] && grep -Fq '"type":"review_open"' .sfs-local/events.jsonl; then
  fail "review_open event should not be recorded when auth preflight blocks"
fi

review_out="$(
  PATH="${fake_bin}:$PATH" SFS_GEMINI_AUTH_READY=1 SFS_REVIEW_BRIDGE_PROBE=0 SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" \
    bash "${SFS_BIN}" review --gate 3 --executor gemini
)"
case "${review_out}" in
  *"CPO run complete"*"executor gemini"* ) ;;
  *) fail "authenticated Gemini review should run: ${review_out}" ;;
esac
case "${review_out}" in
  *"verdict: pass"* ) ;;
  *) fail "authenticated Gemini review should surface pass verdict: ${review_out}" ;;
esac
[[ -f "${sprint_dir}/review.md" ]] \
  || fail "review.md should be created after auth preflight passes"
grep -Fq "CPO evaluator invocation" "${sprint_dir}/review.md" \
  || fail "review.md should record invocation after auth preflight passes"
grep -Fq "CPO evaluator result" "${sprint_dir}/review.md" \
  || fail "review.md should record result after auth preflight passes"
grep -Fq '"type":"review_open"' .sfs-local/events.jsonl \
  || fail "review_open event should be recorded after auth preflight passes"

cat > "${fake_bin}/hanging-gemini" <<'HANGING_GEMINI'
#!/usr/bin/env bash
while IFS= read -r _line; do :; done
sleep 60
HANGING_GEMINI
chmod +x "${fake_bin}/hanging-gemini"

set +e
run_with_timeout 8 env \
  PATH="${fake_bin}:$PATH" \
  SFS_FORCE_NONINTERACTIVE=1 \
  SFS_GEMINI_AUTH_READY=1 \
  SFS_REVIEW_BRIDGE_PROBE=0 \
  SFS_REVIEW_GEMINI_CMD="${fake_bin}/hanging-gemini" \
  SFS_REVIEW_EXECUTOR_TIMEOUT_SEC=0 \
  SFS_NONINTERACTIVE_REVIEW_EXECUTOR_TIMEOUT_SEC=2 \
  SFS_COMMAND_TIMEOUT_SEC=0 \
  SFS_DIST_DIR="${DIST_DIR}" \
  bash "${SFS_BIN}" review --gate 3 --executor gemini \
    >"${TMP_DIR}/hang.out" 2>"${TMP_DIR}/hang.err"
hang_rc=$?
set -e
[[ "${hang_rc}" == "9" ]] || {
  echo "stdout:" >&2
  cat "${TMP_DIR}/hang.out" >&2
  echo "stderr:" >&2
  cat "${TMP_DIR}/hang.err" >&2
  fail "non-interactive unbounded Gemini review should fail via SFS guard before outer timeout, got ${hang_rc}"
}
grep -Fq 'timeout_guard: `non-interactive review cannot use unbounded executor timeout; using 2s`' "${sprint_dir}/review.md" \
  || fail "review.md should record non-interactive timeout guard"
grep -Fq 'exit_code: `124`' "${sprint_dir}/review.md" \
  || fail "review.md should record bounded timeout exit code"

echo "test-review-auth-preflight: OK"
