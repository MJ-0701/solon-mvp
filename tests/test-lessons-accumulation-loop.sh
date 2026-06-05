#!/usr/bin/env bash
# WU-1 LESSONS accumulation loop headline test.
#
# Locks the self-improving record loop: a durable .sfs-local/lessons.md ledger,
# the policy + schema, the plan/flowcheck consult obligation, the contributing
# append checklist, and — the part that makes it a loop — flowcheck surfacing the
# ledger as an advisory line without touching its verdict or exit code.
#
# ASCII anchors only (locale-safe; no Korean grep).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"

fail() { echo "FAIL: $*" >&2; exit 1; }

assert_file_has() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}' in ${file}"
}

# ── 1) policy doc: frontmatter + schema fields ─────────────────────────────
POLICY="${CTX}/policies/lessons-accumulation.md"
assert_file_has "${POLICY}" "id: sfs-policy-lessons-accumulation" "policy id"
assert_file_has "${POLICY}" "## L-NNN" "policy schema entry header"
assert_file_has "${POLICY}" "promoted:" "policy promoted field (WU-3 flywheel hook)"
assert_file_has "${POLICY}" "## Gotchas slot" "policy Gotchas slot (WU-7 reuse)"
assert_file_has "${POLICY}" "md-line-budget" "policy rotation cross-link"

# WU-3 feedback flywheel: record (lesson) -> reflect (verification tool).
assert_file_has "${POLICY}" "## Feedback flywheel" "policy flywheel reflect half"
assert_file_has "${POLICY}" "more than once" "policy repeated-finding threshold"
assert_file_has "${POLICY}" "agent training material" "policy agent-friendly error principle"
assert_file_has "${DIST_DIR}/docs/maintenance/methodology-7-step.md" "record" "methodology flywheel"

# ── 2) index routes the policy ─────────────────────────────────────────────
assert_file_has "${CTX}/_INDEX.md" "policies/lessons-accumulation.md" "index route"

# ── 3) seed template ledger ships with schema ──────────────────────────────
SEED="${DIST_DIR}/templates/.sfs-local-template/lessons.md"
assert_file_has "${SEED}" "## L-NNN" "seed schema"
assert_file_has "${SEED}" "## Lessons" "seed lessons section"
assert_file_has "${DIST_DIR}/install.sh" "lessons.md" "install seeds lessons.md"

# ── 4) consult/append obligation wired into entry docs ─────────────────────
assert_file_has "${CTX}/commands/plan.md" "lessons.md" "plan consult obligation"
assert_file_has "${CTX}/commands/flowcheck.md" "lessons-accumulation" "flowcheck doc reference"
assert_file_has "${CTX}/policies/token-harness.md" "lessons.md" "token-harness cross-link"
assert_file_has "${DIST_DIR}/docs/maintenance/contributing.md" "lessons" "contributing append checklist"

# ── 5) flowcheck command SURFACES the ledger (Red->Green), exit unchanged ───
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-lessons.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "lessons@solon.invalid"
git config user.name "Solon Lessons Test"
printf '# lessons\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

SPRINT="2026-W23-sprint-9"
mkdir -p ".sfs-local/sprints/${SPRINT}"
printf '%s\n' "${SPRINT}" > ".sfs-local/current-sprint"
EVENTS=".sfs-local/events.jsonl"
: > "${EVENTS}"
# A conformant slice so flowcheck reaches PASS/exit 0.
emit() {
  local t="$1"; shift
  local body=""
  for kv in "$@"; do body+=",\"${kv%%=*}\":\"${kv#*=}\""; done
  printf '{"ts":"2026-06-05T10:00:00+09:00","type":"%s","sprint_id":"%s"%s}\n' \
    "${t}" "${SPRINT}" "${body}" >> "${EVENTS}"
}
emit model_resolved agent_role=implementation-worker resolved_tier=execution_standard resolved_model=sonnet-4.6 source=policy
emit gate_passed gate=G3 order_index=1 self_cpo=pass
emit verification_pair implementer=implementation-worker verifier=cpo-evaluator implementer_context=w1 verifier_context=r1 gate=G3

# seed lessons ledger should exist from init; add one L-entry to exercise count.
LEDGER=".sfs-local/lessons.md"
[[ -f "${LEDGER}" ]] || fail "init did not seed .sfs-local/lessons.md"
printf '\n## L-001 example\n- date: 2026-06-05\n- category: process\n- rule: do the thing\n- promoted: none\n' >> "${LEDGER}"

set +e
FC_OUT="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" flowcheck 2>&1)"
FC_RC=$?
set -e

[[ "${FC_RC}" -eq 0 ]] || fail "flowcheck lessons line must not change exit code, got rc=${FC_RC}: ${FC_OUT}"
grep -q "lessons:" <<<"${FC_OUT}" || fail "flowcheck must surface a lessons advisory line: ${FC_OUT}"
grep -q "(1 recorded)" <<<"${FC_OUT}" || fail "flowcheck lessons line must report the ledger count: ${FC_OUT}"

echo "test-lessons-accumulation-loop: OK"
