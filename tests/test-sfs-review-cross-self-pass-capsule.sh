#!/usr/bin/env bash
# Gate 6 cross review must receive the latest same-gate self-CPO PASS evidence
# explicitly, not only the first 80 lines of review.md.
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
printf 'Verdict: partial\n'
printf 'Summary: deliberate partial for next-action formatting test.\n'
PARTIAL
chmod +x tools/fake-partial-review.sh

partial_out="$(run_sfs review --gate 6 --stage self --executor ./tools/fake-partial-review.sh --generator codex)"
assert_contains "${partial_out}" "verdict: partial" "partial review verdict"
assert_contains "${partial_out}" "sfs review --gate 6" "partial next action gate number"
assert_not_contains "${partial_out}" "-Gate -" "partial next action naked gate placeholder"
assert_not_contains "${partial_out}" "sfs review --gate 4" "partial next action legacy internal gate id"

cat > tools/fake-capsule-review.sh <<'FAKE'
#!/usr/bin/env bash
prompt="$(cat)"
if grep -Fq "Review stage: cross" <<<"${prompt}"; then
  for expected in \
    "same-gate self-CPO PASS evidence for cross review" \
    'result_verdict: `pass`' \
    "SELF_REVIEW_SENTINEL"; do
    if ! grep -Fq "${expected}" <<<"${prompt}"; then
      printf 'Verdict: partial\n'
      printf 'Summary: missing expected cross capsule evidence: %s\n' "${expected}"
      exit 0
    fi
  done
fi

printf 'Verdict: pass\n'
printf 'Review lens: qa\n'
printf 'Evidence checked:\n- SELF_REVIEW_SENTINEL\n'
FAKE
chmod +x tools/fake-capsule-review.sh

self_out="$(run_sfs review --gate 6 --stage self --executor ./tools/fake-capsule-review.sh --generator codex)"
assert_contains "${self_out}" "verdict: pass" "self review pass"
assert_not_contains "${self_out}" "-Gate -" "self pass next action naked gate placeholder"

cross_out="$(run_sfs review --gate 6 --stage cross --executor ./tools/fake-capsule-review.sh --generator codex)"
assert_contains "${cross_out}" "verdict: pass" "cross review should pass with embedded self PASS evidence"

latest_cross_prompt="$(find .sfs-local/tmp/review-prompts -name prompt.txt -type f | sort | tail -n 1)"
[[ -f "${latest_cross_prompt}" ]] || fail "missing latest cross prompt"
grep -Fq "same-gate self-CPO PASS evidence for cross review" "${latest_cross_prompt}" \
  || fail "cross prompt missing explicit same-gate self-CPO section"
grep -Fq "SELF_REVIEW_SENTINEL" "${latest_cross_prompt}" \
  || fail "cross prompt missing self review result excerpt"

echo "test-sfs-review-cross-self-pass-capsule: OK"
