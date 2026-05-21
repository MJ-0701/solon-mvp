#!/usr/bin/env bash
# tests/test-review-auto-lens-lock.sh — same sprint/gate auto review reuses the first lens.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-auto-lens-lock.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

cd "${TMP_DIR}"
git init -q
printf '# Review Auto Lens Lock Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

run_sfs init --layout thin --yes >/dev/null
run_sfs start "review auto lens lock" >/dev/null

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
PLAN

first_out="$(run_sfs review --gate 3 --prompt-only)"
case "${first_out}" in
  *"lens docs (auto) prompt ready"* ) ;;
  *) fail "first auto review should infer docs: ${first_out}" ;;
esac

cat > "${sprint_dir}/plan.md" <<'PLAN'
---
phase: plan
status: ready-for-review
---

# Plan

Artifact types touched: design
UX and UI review signals are now prominent.
PLAN

second_out="$(run_sfs review --gate 3 --prompt-only)"
case "${second_out}" in
  *"lens docs (auto-locked) prompt ready"* ) ;;
  *) fail "second auto review should reuse docs lens: ${second_out}" ;;
esac

review_path="$(printf '%s\n' "${second_out}" | sed -nE 's/^review\.md ready: ([^|]+) \|.*/\1/p')"
[[ -f "${review_path}" ]] || fail "review path missing: ${review_path}"
grep -Fq 'review_lens: "docs"' "${review_path}" \
  || fail "review.md should keep docs lens"
grep -Fq 'review_lens_source: "auto-locked"' "${review_path}" \
  || fail "review.md should record auto-locked source"
grep -Fq '"review_lens_source":"auto-locked"' .sfs-local/events.jsonl \
  || fail "events should record auto-locked lens source"

explicit_out="$(run_sfs review --gate 3 --lens design --prompt-only)"
case "${explicit_out}" in
  *"lens design (explicit) prompt ready"* ) ;;
  *) fail "explicit lens should still override lock: ${explicit_out}" ;;
esac

mkdir -p .sfs-local/tmp/review-runs
result_path=".sfs-local/tmp/review-runs/${sprint_id}-gate3-pass.md"
cat > "${result_path}" <<'RESULT'
Verdict: pass

Required items:
- Carry reviewed requirements into the first implementation slice.
RESULT
cat >> "${review_path}" <<EOF

### synthetic CPO evaluator result

- result_path: \`${result_path}\`
- result_verdict: \`pass\`
EOF
printf '{"ts":"2026-05-09T02:00:00+09:00","type":"review_run","sprint_id":"%s","gate_id":"G1","output_path":"%s","review_lens":"design","evaluator_executor":"codex","generator_executor":"claude","exit_code":0}\n' \
  "${sprint_id}" "${result_path}" >> .sfs-local/events.jsonl

last_out="$(run_sfs review --last --gate 3)"
case "${last_out}" in
  *"next: sfs implement (Gate 3 Plan PASS;"* ) ;;
  *) fail "Gate 3 PASS review should surface implementation next action: ${last_out}" ;;
esac

cat >> "${sprint_dir}/plan.md" <<'PLAN'

user_approval_required: true
user_approval_status: "pending"
PLAN
approval_needed_out="$(run_sfs review --last --gate 3)"
case "${approval_needed_out}" in
  *"next: ask user to approve the Gate 3 plan, then record: sfs capture --kind user-approval --gate 3"* ) ;;
  *) fail "Gate 3 PASS with pending user approval should not route to implement: ${approval_needed_out}" ;;
esac

run_sfs capture --kind user-approval --gate 3 "User approved this Gate 3 plan for implementation." >/dev/null
approval_recorded_out="$(run_sfs review --last --gate 3)"
case "${approval_recorded_out}" in
  *"next: sfs implement (Gate 3 Plan PASS;"* ) ;;
  *) fail "Gate 3 PASS with captured user approval should route to implement: ${approval_recorded_out}" ;;
esac

echo "test-review-auto-lens-lock: OK"
