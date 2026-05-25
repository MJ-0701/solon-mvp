#!/usr/bin/env bash
# review lens 별칭을 실제 CLI 입력에서 공개 lens 이름으로 정규화한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-lens.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_REVIEW_BRIDGE_PROBE_TIMEOUT_SEC=1 \
    SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

cd "${TMP_DIR}"
git init -q
printf '# Review Lens Alias Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

run_sfs init --layout thin --yes >/dev/null
run_sfs start "review lens aliases" >/dev/null

assert_auto_lens() {
  local expected="$1" out review_path
  out="$(run_sfs review --gate 6 --lens auto --prompt-only --allow-empty)"
  case "${out}" in
    *"lens ${expected} (auto) prompt ready"*) ;;
    *) fail "--lens auto did not infer ${expected}: ${out}" ;;
  esac
  review_path="$(printf '%s\n' "${out}" | sed -nE 's/^review\.md ready: ([^|]+) \|.*/\1/p')"
  [[ -f "${review_path}" ]] || fail "review path missing for auto ${expected}: ${review_path}"
  grep -Fq "review_lens: \"${expected}\"" "${review_path}" \
    || fail "review.md frontmatter missing inferred lens ${expected}"
}

assert_alias() {
  local alias="$1" expected="$2" out review_path
  out="$(run_sfs review --gate 6 --lens "${alias}" --prompt-only --allow-empty)"
  case "${out}" in
    *"lens ${expected} (explicit) prompt ready"*) ;;
    *) fail "--lens ${alias} did not normalize to ${expected}: ${out}" ;;
  esac
  review_path="$(printf '%s\n' "${out}" | sed -nE 's/^review\.md ready: ([^|]+) \|.*/\1/p')"
  [[ -f "${review_path}" ]] || fail "review path missing for ${alias}: ${review_path}"
  grep -Fq "review_lens: \"${expected}\"" "${review_path}" \
    || fail "review.md frontmatter missing normalized lens ${expected} for ${alias}"
}

sprint_id="$(cat .sfs-local/current-sprint)"
plan_path=".sfs-local/sprints/${sprint_id}/plan.md"
{
  printf '\nAlgorithm verification trigger:\n'
  printf 'Gate 6 must inspect algorithm complexity, hot path query behavior, payload size, and concurrency behavior.\n'
} >> "${plan_path}"
assert_auto_lens performance

assert_alias strategy-pm strategy
assert_alias strategy_pm strategy
assert_alias design/frontend design
assert_alias infra ops
assert_alias source-driven source-docs
assert_alias official-docs source-docs
assert_alias perf performance
assert_alias performance-algorithm performance
assert_alias algorithm performance
assert_alias benchmark performance
assert_alias security security
assert_alias auth security
assert_alias simplify simplify
assert_alias dead-code simplify
assert_alias process process-lean
assert_alias ceremony process-lean
assert_alias bottleneck process-lean
assert_alias api api-contract
assert_alias schema api-contract
assert_alias ddd ddd-tdd
assert_alias tdd ddd-tdd
assert_alias domain-model ddd-tdd
assert_alias test-first ddd-tdd
assert_alias management-admin management-admin
assert_alias finance management-admin
assert_alias accounting management-admin

if run_sfs review --gate 6 --lens not-a-lens --prompt-only >"${TMP_DIR}/invalid.out" 2>"${TMP_DIR}/invalid.err"; then
  fail "invalid lens unexpectedly passed"
fi
grep -Fq "strategy-pm -> strategy" "${TMP_DIR}/invalid.err" \
  || fail "invalid lens error should show strategy-pm alias hint"
grep -Fq "source-driven -> source-docs" "${TMP_DIR}/invalid.err" \
  || fail "invalid lens error should show source-docs alias hint"
grep -Fq "api/schema -> api-contract" "${TMP_DIR}/invalid.err" \
  || fail "invalid lens error should show api-contract alias hint"
grep -Fq "performance-algorithm -> performance" "${TMP_DIR}/invalid.err" \
  || fail "invalid lens error should show performance-algorithm alias hint"
grep -Fq "process/ceremony -> process-lean" "${TMP_DIR}/invalid.err" \
  || fail "invalid lens error should show process-lean alias hint"
grep -Fq "DDD/TDD -> ddd-tdd" "${TMP_DIR}/invalid.err" \
  || fail "invalid lens error should show DDD/TDD alias hint"

echo "test-review-lens-aliases: OK"
