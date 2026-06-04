#!/usr/bin/env bash
# 리뷰 예산 guardrail 이 executor 호출 전 차단하고 privacy-safe telemetry 를 남기는지 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-budget.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_sfs() {
  SFS_TEST_MARKER="${SFS_TEST_MARKER-}" \
    SFS_REVIEW_BUDGET_USD="${SFS_REVIEW_BUDGET_USD-}" \
    SFS_REVIEW_ESTIMATED_COST_USD="${SFS_REVIEW_ESTIMATED_COST_USD-}" \
    SFS_ADVISOR_BUDGET_USD="${SFS_ADVISOR_BUDGET_USD-}" \
    SFS_ADVISOR_ESTIMATED_COST_USD="${SFS_ADVISOR_ESTIMATED_COST_USD-}" \
    SFS_COMMAND_TIMEOUT_SEC=0 SFS_REVIEW_BRIDGE_PROBE=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

assert_jsonl_contains() {
  local needle="$1" file="$2" label="$3"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing ${needle}"
}

assert_file_contains() {
  local file="$1" needle="$2" label="$3"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing ${needle} in ${file}"
}

cd "${TMP_DIR}"
git init -q
printf '# Review Budget Guardrail Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

run_sfs init --layout thin --yes >/dev/null
run_sfs start "review budget guardrails" >/dev/null
sprint_id="$(cat .sfs-local/current-sprint)"
sprint_dir=".sfs-local/sprints/${sprint_id}"
cat > "${sprint_dir}/plan.md" <<'PLAN'
---
phase: plan
status: ready-for-review
---

# Plan

Acceptance criteria:
- Review budget guardrails must block over-budget executor calls.
PLAN

fake_reviewer="${TMP_DIR}/fake-reviewer.sh"
marker="${TMP_DIR}/executor-invoked"
cat > "${fake_reviewer}" <<'FAKE_REVIEWER'
#!/usr/bin/env bash
touch "${SFS_TEST_MARKER:?}"
while IFS= read -r _line; do :; done
cat <<'RESULT'
Verdict: pass
Review lens: qa
Review independence risk: none
Artifact quality verdict:
- Fake review executed.
Evidence bundle verdict:
- Prompt was accepted.
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
FAKE_REVIEWER
chmod +x "${fake_reviewer}"

telemetry=".sfs-local/telemetry/advisor-budget.jsonl"

set +e
SFS_TEST_MARKER="${marker}" \
SFS_REVIEW_BUDGET_USD=0.01 \
SFS_REVIEW_ESTIMATED_COST_USD=0.02 \
run_sfs review --gate 3 --executor "${fake_reviewer}" --generator codex --allow-empty \
  >"${TMP_DIR}/blocked.out" 2>"${TMP_DIR}/blocked.err"
blocked_rc=$?
set -e
[[ "${blocked_rc}" == "9" ]] || {
  cat "${TMP_DIR}/blocked.out" >&2
  cat "${TMP_DIR}/blocked.err" >&2
  fail "over-budget review should exit 9, got ${blocked_rc}"
}
[[ ! -e "${marker}" ]] || fail "over-budget review invoked executor"
assert_jsonl_contains '"decision":"blocked"' "${telemetry}" "blocked telemetry"
assert_jsonl_contains '"reason":"over_budget"' "${telemetry}" "blocked reason"
assert_jsonl_contains '"budget_usd":"0.01"' "${telemetry}" "blocked budget"
assert_jsonl_contains '"estimated_cost_usd":"0.02"' "${telemetry}" "blocked estimate"

rm -f "${marker}"
allowed_out="$(
  SFS_TEST_MARKER="${marker}" \
  SFS_REVIEW_BUDGET_USD=0.02 \
  SFS_REVIEW_ESTIMATED_COST_USD=0.01 \
  run_sfs review --gate 3 --executor "${fake_reviewer}" --generator codex --allow-empty
)"
[[ -e "${marker}" ]] || fail "under-budget review did not invoke executor: ${allowed_out}"
assert_jsonl_contains '"decision":"allowed"' "${telemetry}" "allowed telemetry"
assert_jsonl_contains '"reason":"within_budget"' "${telemetry}" "allowed reason"

rm -f "${marker}"
missing_out="$(
  SFS_TEST_MARKER="${marker}" \
  SFS_REVIEW_ESTIMATED_COST_USD=0.01 \
  run_sfs review --gate 3 --executor "${fake_reviewer}" --generator codex --allow-empty
)"
[[ -e "${marker}" ]] || fail "missing-budget review did not preserve executor flow: ${missing_out}"
assert_jsonl_contains '"decision":"not_configured"' "${telemetry}" "missing budget telemetry"
assert_jsonl_contains '"reason":"missing_budget"' "${telemetry}" "missing budget reason"

rm -f "${marker}"
unknown_out="$(
  SFS_TEST_MARKER="${marker}" \
  SFS_REVIEW_BUDGET_USD=0.02 \
  run_sfs review --gate 3 --executor "${fake_reviewer}" --generator codex --allow-empty
)"
[[ -e "${marker}" ]] || fail "unknown-estimate review did not preserve executor flow: ${unknown_out}"
assert_jsonl_contains '"decision":"unknown_estimate"' "${telemetry}" "unknown estimate telemetry"
assert_jsonl_contains '"reason":"missing_estimate"' "${telemetry}" "unknown estimate reason"

assert_jsonl_contains '"ts":"' "${telemetry}" "timestamp"
assert_jsonl_contains '"surface":"review"' "${telemetry}" "surface"
assert_jsonl_contains '"executor":"' "${telemetry}" "executor"
assert_jsonl_contains '"generator":"codex"' "${telemetry}" "generator"

if grep -Eq 'SFS_REVIEW_BUDGET|SFS_TEST_MARKER|SECRET|TOKEN|prompt|model output|Return exactly' "${telemetry}"; then
  cat "${telemetry}" >&2
  fail "telemetry contains forbidden prompt/env/secret-shaped content"
fi

assert_file_contains "${DIST_DIR}/templates/.sfs-local-template/context/commands/review.md" "Declared advisor/review cost controls are enforced before the full executor" "review context budget enforcement"
assert_file_contains "${DIST_DIR}/templates/.sfs-local-template/context/commands/review.md" "Provider billing APIs, live token accounting, and pricing tables are separate" "review context pricing deferral"
docset_gate_framework="${DIST_DIR}/../05-gate-framework.md"
# docset-only SSoT sync check: product archives intentionally omit parent docset files.
if [[ -f "${docset_gate_framework}" ]]; then
  assert_file_contains "${docset_gate_framework}" "실행 전 강제 차단" "gate framework budget enforcement"
  if grep -Fq "Phase 1은 warn only" "${docset_gate_framework}"; then
    fail "gate framework still describes budget_usd as warn-only"
  fi
fi

echo "test-review-budget-guardrails: OK"
