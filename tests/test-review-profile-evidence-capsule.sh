#!/usr/bin/env bash
# Review bridge profile evidence must come from SFS-collected probe metadata,
# not from LLM self-attestation in the review body.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-profile-evidence.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_REVIEW_BRIDGE_PROBE_TIMEOUT_SEC=5 \
    SFS_REVIEW_EXECUTOR_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

cd "${TMP_DIR}"
git init -q
printf '# Review Profile Evidence Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

run_sfs init --layout thin --yes >/dev/null
run_sfs start "review profile evidence capsule" >/dev/null
sprint_id="$(cat .sfs-local/current-sprint)"
sprint_dir=".sfs-local/sprints/${sprint_id}"
cat > "${sprint_dir}/plan.md" <<'PLAN'
---
phase: plan
status: ready-for-review
---

# Plan

Acceptance criteria:
- Codex review profile evidence must be supplied by SFS bridge metadata.
PLAN

fake_bin="${TMP_DIR}/fake-bin"
mkdir -p "${fake_bin}"
cat > "${fake_bin}/codex" <<'FAKE_CODEX'
#!/usr/bin/env bash
result_path=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-last-message)
      result_path="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

prompt="$(cat)"
printf 'model: gpt-5.5\n' >&2
printf 'reasoning effort: xhigh\n' >&2

if [[ "${prompt}" == Solon\ SFS\ review\ bridge\ probe* ]]; then
  printf 'SFS_REVIEW_BRIDGE_PROBE_OK\n'
  [[ -n "${result_path}" ]] && printf 'SFS_REVIEW_BRIDGE_PROBE_OK\n' > "${result_path}"
  exit 0
fi

for expected in \
  'SFS Executor Profile Bridge Evidence' \
  'Detected model: gpt-5.5' \
  'Detected reasoning effort: xhigh' \
  'Match status: matched' \
  'do not require the reviewer LLM to self-attest'; do
  if ! grep -Fq "${expected}" <<<"${prompt}"; then
    printf 'missing expected profile evidence: %s\n' "${expected}" >&2
    exit 42
  fi
done

review_result="$(cat <<'RESULT'
Verdict: pass
Review lens: qa
Review independence risk: none
Artifact quality verdict:
- Profile bridge evidence was supplied by SFS.
Evidence bundle verdict:
- The prompt contained matched Codex profile evidence.
Evidence checked:
- SFS Executor Profile Bridge Evidence
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
)"

if [[ -n "${result_path}" ]]; then
  printf '%s\n' "${review_result}" > "${result_path}"
else
  printf '%s\n' "${review_result}"
fi
FAKE_CODEX
chmod +x "${fake_bin}/codex"

review_out="$(
  PATH="${fake_bin}:$PATH" SFS_CODEX_AUTH_READY=1 SFS_COMMAND_TIMEOUT_SEC=0 \
    SFS_REVIEW_BRIDGE_PROBE_TIMEOUT_SEC=5 SFS_REVIEW_EXECUTOR_TIMEOUT_SEC=0 \
    SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" review --gate 3 --stage self --lens qa --executor codex --no-auth-interactive
)"

case "${review_out}" in
  *"verdict: pass"* ) ;;
  *)
    latest_result="$(find .sfs-local/tmp/review-runs -name result.md -type f | head -n 1 || true)"
    [[ -z "${latest_result}" ]] || sed -n '1,80p' "${latest_result}" >&2
    fail "Codex review should pass with profile evidence: ${review_out}"
    ;;
esac

profile_evidence="$(find .sfs-local/tmp/review-runs -name executor-profile-evidence.txt -type f | head -n 1)"
[[ -n "${profile_evidence}" ]] || fail "missing executor profile evidence file"
grep -Fq "Detected model: gpt-5.5" "${profile_evidence}" \
  || fail "profile evidence missing model"
grep -Fq "Detected reasoning effort: xhigh" "${profile_evidence}" \
  || fail "profile evidence missing reasoning"
grep -Fq "Match status: matched" "${profile_evidence}" \
  || fail "profile evidence should be matched"
grep -Fq "profile_evidence_status: \`matched\`" "${sprint_dir}/review.md" \
  || fail "review.md should record matched profile evidence status"

cat > "${fake_bin}/claude" <<'FAKE_CLAUDE'
#!/usr/bin/env bash
args="$*"
prompt=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p)
      prompt="${2:-}"
      shift 2
      ;;
    --)
      shift
      ;;
    *)
      shift
      ;;
  esac
done
if [[ "${prompt}" == "Solon SFS review bridge probe for claude."* ]]; then
  printf 'SFS_REVIEW_BRIDGE_PROBE_OK\n'
  exit 0
fi

for expected in \
  'SFS Executor Profile Bridge Evidence' \
  'Detected model: opus' \
  'Detected reasoning effort: xhigh' \
  'Match status: matched' \
  'do not require the reviewer LLM to self-attest'; do
  if ! grep -Fq "${expected}" <<<"${prompt}"; then
    printf 'missing expected Claude profile evidence: %s\n' "${expected}" >&2
    exit 42
  fi
done

cat <<'RESULT'
Verdict: pass
Review lens: qa
Review independence risk: none
Artifact quality verdict:
- Claude profile bridge evidence was supplied by SFS invocation flags.
Evidence bundle verdict:
- The prompt contained matched Claude profile evidence.
Evidence checked:
- SFS Executor Profile Bridge Evidence
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
FAKE_CLAUDE
chmod +x "${fake_bin}/claude"

claude_out="$(
  PATH="${fake_bin}:$PATH" SFS_CLAUDE_AUTH_READY=1 \
    SFS_REVIEW_CLAUDE_CMD='claude --model opus --effort xhigh -p "$(cat)"' \
    SFS_COMMAND_TIMEOUT_SEC=0 SFS_REVIEW_BRIDGE_PROBE_TIMEOUT_SEC=5 \
    SFS_REVIEW_EXECUTOR_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" \
    bash "${SFS_BIN}" review --gate 3 --stage cross --lens qa --executor claude --generator codex --allow-empty --no-auth-interactive
)"

case "${claude_out}" in
  *"verdict: pass"* ) ;;
  *)
    latest_result="$(find .sfs-local/tmp/review-runs -name stdout.md -type f | tail -n 1 || true)"
    [[ -z "${latest_result}" ]] || sed -n '1,80p' "${latest_result}" >&2
    fail "Claude review should pass with invocation-flag profile evidence: ${claude_out}"
    ;;
esac

claude_profile_evidence="$(find .sfs-local/tmp/review-runs -name executor-profile-evidence.txt -type f -exec grep -l 'Evaluator executor/profile: claude' {} \; | tail -n 1)"
[[ -n "${claude_profile_evidence}" ]] || fail "missing Claude executor profile evidence file"
grep -Fq "Detected model: opus" "${claude_profile_evidence}" \
  || fail "Claude profile evidence missing model"
grep -Fq "Detected reasoning effort: xhigh" "${claude_profile_evidence}" \
  || fail "Claude profile evidence missing effort"
grep -Fq "Match status: matched" "${claude_profile_evidence}" \
  || fail "Claude profile evidence should be matched"

echo "test-review-profile-evidence-capsule: OK"
