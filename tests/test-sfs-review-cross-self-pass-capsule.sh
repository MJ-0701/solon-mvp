#!/usr/bin/env bash
# Gate 6 cross review requires a same-gate self-CPO PASS, but its frozen prompt
# bundle must not leak the legacy self-review capsule.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-cross-self-pass.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2" label="$3"
  case "${haystack}" in
    *"${needle}"*) ;;
    *) fail "${label}: missing '${needle}' in: ${haystack}" ;;
  esac
}

assert_not_contains() {
  local haystack="$1" needle="$2" label="$3"
  case "${haystack}" in
    *"${needle}"*) fail "${label}: unexpected '${needle}' in: ${haystack}" ;;
    *) ;;
  esac
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_REVIEW_EXECUTOR_TIMEOUT_SEC=0 \
    SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

cd "${TMP_DIR}"
git init -q
git config user.email sfs-test@example.invalid
git config user.name "SFS Test"
printf '# Review Capsule Project\n' > README.md
git add README.md
git commit -qm 'initial'

run_sfs init --layout thin --yes >/dev/null
run_sfs start "Gate 6 cross self pass capsule" >/dev/null
sprint_id="$(cat .sfs-local/current-sprint)"
sprint_dir=".sfs-local/sprints/${sprint_id}"
mkdir -p src tools
printf 'implemented\n' > src/app.txt
cat > "${sprint_dir}/implement.md" <<'IMPLEMENT'
---
phase: implement
status: ready-for-review
---

# 실행

## 4. 검증

- Commands run: deterministic test passed
- Result: passed
IMPLEMENT

cat > tools/fake-partial-review.sh <<'PARTIAL'
#!/usr/bin/env bash
cat >/dev/null
cat <<'RESULT'
Verdict: partial
Blocking findings: 1
Advisories: 0
Review lens: qa
Review independence risk: none
Artifact quality verdict:
- Deliberate partial for next-action formatting test.
Evidence bundle verdict:
- Prompt was readable.
Evidence checked:
- implement.md
Evidence gaps:
- none
Implementation acceptance ledger:
- implementation acceptance | missing | synthetic fixture | required follow-up
Findings:
- [Required] [Gate PASS: G6-1] deliberate partial for next-action formatting test.
Advisory details:
- none
Required CTO actions:
- Resolve the required fixture finding.
RESULT
PARTIAL
chmod +x tools/fake-partial-review.sh

partial_out="$(run_sfs review --gate 6 --stage self --executor ./tools/fake-partial-review.sh --generator codex)"
assert_contains "${partial_out}" "verdict: partial" "partial review verdict"
assert_contains "${partial_out}" "sfs review --gate 6" "partial next action gate number"
assert_not_contains "${partial_out}" "-Gate -" "partial next action naked gate placeholder"
assert_not_contains "${partial_out}" "sfs review --gate 4" "partial next action legacy internal gate id"

cat > tools/fake-capsule-review.sh <<'FAKE'
#!/usr/bin/env bash
cat > tools/latest-cross-prompt.txt

cat <<'RESULT'
Verdict: pass
Blocking findings: 0
Advisories: 0
Review lens: qa
Review independence risk: none
Artifact quality verdict:
- Self-CPO capsule is available.
Evidence bundle verdict:
- Prompt was accepted.
Evidence checked:
- SELF_REVIEW_SENTINEL
Evidence gaps:
- none
Implementation acceptance ledger:
- implementation acceptance | implemented | synthetic fixture | SELF_REVIEW_SENTINEL
Findings:
- none
Advisory details:
- none
Required CTO actions:
- none
RESULT
FAKE
chmod +x tools/fake-capsule-review.sh

set +e
cross_before_self_out="$(run_sfs review --gate 6 --stage cross --executor ./tools/fake-capsule-review.sh --generator codex 2>&1)"
cross_before_self_rc=$?
set -e
[[ "${cross_before_self_rc}" == "6" ]] || fail "cross review without same-gate self PASS must exit 6, got ${cross_before_self_rc}"
assert_contains "${cross_before_self_out}" "cross review requires a same-gate self-CPO PASS" "cross self prerequisite"

self_out="$(run_sfs review --gate 6 --stage self --executor ./tools/fake-capsule-review.sh --generator codex)"
assert_contains "${self_out}" "verdict: pass" "self review pass"
assert_not_contains "${self_out}" "-Gate -" "self pass next action naked gate placeholder"

cross_out="$(run_sfs review --gate 6 --stage cross --executor ./tools/fake-capsule-review.sh --generator codex)"
assert_contains "${cross_out}" "verdict: pass" "cross review should pass with embedded self PASS evidence"

latest_cross_prompt="$(find .sfs-local/tmp/review-prompts -name prompt.txt -type f | sort | tail -n 1)"
[[ -f "${latest_cross_prompt}" ]] || fail "missing latest cross prompt"
grep -Fq "Review stage: cross" tools/latest-cross-prompt.txt \
  || fail "cross executor did not receive a cross-stage prompt"
if grep -Fq "same-gate self-CPO PASS evidence for cross review" "${latest_cross_prompt}" \
  || grep -Fq "SELF_REVIEW_SENTINEL" "${latest_cross_prompt}"; then
  fail "contract-only cross prompt must not embed the legacy self-review capsule"
fi

echo "test-sfs-review-cross-self-pass-capsule: OK"
