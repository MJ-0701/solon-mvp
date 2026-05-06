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

echo "test-review-auto-lens-lock: OK"
