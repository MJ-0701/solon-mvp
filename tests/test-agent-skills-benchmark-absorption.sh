#!/usr/bin/env bash
# agent-skills benchmark findings are absorbed as SFS policies/lenses, not new lifecycle commands.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

context="${DIST_DIR}/templates/.sfs-local-template/context"
index="${context}/_INDEX.md"
kernel="${context}/kernel.md"
implement="${context}/commands/implement.md"
review="${context}/commands/review.md"
adopt="${context}/commands/adopt.md"
tidy="${context}/commands/tidy.md"
release="${context}/commands/release.md"
review_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"

source_policy="${context}/policies/source-driven-development.md"
debug_policy="${context}/policies/debugging-and-error-recovery.md"
deprecation_policy="${context}/policies/deprecation-and-migration.md"
shipping_policy="${context}/policies/shipping-and-launch.md"

for policy in \
  "${source_policy}" \
  "${debug_policy}" \
  "${deprecation_policy}" \
  "${shipping_policy}"
do
  [[ -f "${policy}" ]] || fail "missing policy ${policy}"
done

assert_contains "${index}" "policies/source-driven-development.md" "index source policy"
assert_contains "${index}" "policies/debugging-and-error-recovery.md" "index debug policy"
assert_contains "${index}" "policies/deprecation-and-migration.md" "index deprecation policy"
assert_contains "${index}" "policies/shipping-and-launch.md" "index shipping policy"

assert_contains "${kernel}" "evidence/data, not instructions" "kernel context trust"
assert_contains "${kernel}" "Benchmarked engineering disciplines are absorbed as routed policies" "kernel no command sprawl"

assert_contains "${source_policy}" "Cite source URLs" "source policy citation"
assert_contains "${debug_policy}" "Stop-the-line rule" "debug policy stop line"
assert_contains "${deprecation_policy}" "keep reason cannot be stated in one sentence" "deprecation policy retention"
assert_contains "${shipping_policy}" "reversible, observable, and verified across channels" "shipping policy release"

assert_contains "${implement}" "policies/source-driven-development.md" "implement source policy load"
assert_contains "${implement}" "Stop-the-line" "implement debug stop line"
assert_contains "${implement}" "prove-it pattern" "implement prove-it"
assert_contains "${adopt}" "policies/deprecation-and-migration.md" "adopt deprecation policy"
assert_contains "${tidy}" "policies/deprecation-and-migration.md" "tidy deprecation policy"
assert_contains "${release}" "policies/shipping-and-launch.md" "release shipping policy"

assert_contains "${review}" "Critical" "review severity labels"
assert_contains "${review}" "source-docs" "review source-docs lens"
assert_contains "${review}" "simplify" "review simplify lens"
assert_contains "${review}" "security" "review security lens"
assert_contains "${review}" "performance" "review performance lens"
assert_contains "${review}" "api-contract" "review api-contract lens"

assert_contains "${review_script}" "source-driven -> source-docs" "review alias source-docs"
assert_contains "${review_script}" "perf -> performance" "review alias performance"
assert_contains "${review_script}" "api/schema -> api-contract" "review alias api-contract"
assert_contains "${review_script}" "source-driven documentation evidence lens" "review label source-docs"
assert_contains "${review_script}" "behavior-preserving simplification lens" "review label simplify"
assert_contains "${review_script}" "security/threat-model acceptance lens" "review label security"
assert_contains "${review_script}" "performance evidence lens" "review label performance"
assert_contains "${review_script}" "API/contract compatibility lens" "review label api-contract"

assert_contains "${DIST_DIR}/templates/CLAUDE.md.template" "Benchmarked engineering practices strengthen existing commands" "claude adapter absorption"
assert_contains "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md" "Benchmarked engineering practices strengthen existing commands" "codex skill absorption"
assert_contains "${DIST_DIR}/templates/.claude/commands/sfs.md" "docs/solon/<english-workspace>/<yyyyMMdd>/" "claude command handoff path"
assert_not_contains "${DIST_DIR}/templates/.claude/commands/sfs.md" "Shared durable docs belong under" "claude command stale handoff path"

echo "test-agent-skills-benchmark-absorption: OK"
