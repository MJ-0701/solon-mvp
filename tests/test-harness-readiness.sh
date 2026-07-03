#!/usr/bin/env bash
# DESIGN-2026-07-03 P3 (cost-signal-readiness-adapter §3) — headline.
#
# Locks the AI-readiness (Sanity) audit, decisions confirmed 2026-07-03:
#   D1-carryover: entry point = doctor section (no new subcommand)
#   D3: file-level heuristics only (no language-tool dependency)
#   D4: waiver = .sfs-local/readiness-waiver (one line: reason + date)
# Rubric: 4 axes x 0-2, deterministic bash, evidence line per axis. Axis
# tokens must match between the routed policy RUBRIC and doctor output.
# Order discipline: `harness map --write` prints a readiness advisory when no
# waiver is recorded — signal-only, the map is always written (ALT-INV-3).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
POLICY="${DIST_DIR}/templates/.sfs-local-template/context/policies/harness-readiness.md"
AUTONOMY="${DIST_DIR}/templates/.sfs-local-template/context/policies/harness-autonomy.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
has() { grep -Fq -- "$2" <<<"$1" || fail "$3: missing '$2'"; }

AXES="self-verification dead-code convention-consistency entry-doc-freshness"

# ── Policy doc + routes ─────────────────────────────────────────────
[[ -f "${POLICY}" ]] || fail "missing policies/harness-readiness.md"
fhas "${POLICY}" "RUBRIC" "rubric section anchor"
fhas "${POLICY}" "ORDER_DISCIPLINE" "order-discipline section anchor"
fhas "${POLICY}" "WAIVER" "waiver section anchor"
fhas "${POLICY}" "KNOWLEDGE_GRAPH_POINTER" "graph opt-in pointer anchor"
fhas "${POLICY}" ".sfs-local/readiness-waiver" "waiver path (D4)"
fhas "${POLICY}" "signal-only" "ALT-INV-3 wording"
for axis in ${AXES}; do
  fhas "${POLICY}" "${axis}" "rubric axis '${axis}'"
done
grep -q '^load_when:' "${POLICY}" || fail "policy missing load_when"
fhas "${DIST_DIR}/templates/.sfs-local-template/context/_INDEX.md" \
  "policies/harness-readiness.md" "index route"
fhas "${AUTONOMY}" "harness-readiness.md" "harness-autonomy cross-ref"
if grep -Eq '/Users/|/home/[a-z]' "${POLICY}"; then
  fail "harness-readiness policy leaks an absolute private path"
fi
lines="$(wc -l < "${POLICY}")"
[[ "${lines}" -lt 200 ]] || fail "policy exceeds 200-line budget (${lines})"

# doc colocation: product-shape wiki names the readiness audit, both languages.
fhas "${DIST_DIR}/docs/en/current-product-shape/17-token-harness-hygiene.md" \
  "readiness" "wiki readiness bullet (en)"
fhas "${DIST_DIR}/docs/ko/current-product-shape/17-token-harness-hygiene.md" \
  "readiness" "wiki readiness bullet (ko)"

# ── Fixtures through the real doctor ────────────────────────────────
tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/sfs-readiness.XXXXXX")"
trap 'rm -rf "${tmp_root}"' EXIT
# Cost section must stay quiet in these fixtures.
export SFS_COST_FORCE_PARSER=none

run_doctor() { # echoes output + final "rc=<n>" line
  local rc=0 out
  out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor 2>&1)" || rc=$?
  printf '%s\nrc=%d\n' "${out}" "${rc}"
}

# 1) rich project: every axis scores 2/2.
rich="${tmp_root}/rich"
mkdir -p "${rich}"
cd "${rich}"
git init -q && git config user.email "r@solon.invalid" && git config user.name "R"
mkdir -p tests scripts
printf '#!/usr/bin/env bash\necho ok\n' > tests/run-all.sh
printf '#!/usr/bin/env bash\necho build\n' > scripts/build.sh
printf '# rich\nBuild via scripts/build.sh; test via tests/run-all.sh\n' > README.md
git add -A && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
cat > SFS.md <<'EOF'
# rich router
See [README](README.md).
EOF
git add -A && git commit -qm "sfs"
out_rich="$(run_doctor)"
has "${out_rich}" "AI Readiness (Sanity)" "doctor readiness section"
has "${out_rich}" "readiness: self-verification 2/2" "rich self-verification 2/2"
has "${out_rich}" "readiness: dead-code 2/2" "rich dead-code 2/2"
has "${out_rich}" "readiness: convention-consistency 2/2" "rich convention 2/2"
has "${out_rich}" "readiness: entry-doc-freshness 2/2" "rich entry-doc 2/2"
has "${out_rich}" "readiness: total 8/8" "rich total"

# 2) poor project: every axis scores 0/2.
poor="${tmp_root}/poor"
mkdir -p "${poor}"
cd "${poor}"
git init -q && git config user.email "p@solon.invalid" && git config user.name "P"
mkdir -p scripts
printf '#!/usr/bin/env bash\n' > scripts/a_one.sh
printf '#!/usr/bin/env bash\n' > scripts/b-two.sh
printf '#!/usr/bin/env bash\n' > scripts/cThree.sh
printf '#!/usr/bin/env bash\n' > scripts/d_four.sh
printf '#!/usr/bin/env bash\n' > scripts/e-five.sh
printf '# poor\n' > README.md
git add -A && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
cat > SFS.md <<'EOF'
# poor router
See [a](missing-a.md), [b](missing-b.md), [c](missing-c.md).
EOF
git add -A && git commit -qm "sfs"
out_poor="$(run_doctor)"
has "${out_poor}" "readiness: self-verification 0/2" "poor self-verification 0/2"
has "${out_poor}" "readiness: dead-code 0/2" "poor dead-code 0/2"
has "${out_poor}" "readiness: convention-consistency 0/2" "poor convention 0/2"
has "${out_poor}" "readiness: entry-doc-freshness 0/2" "poor entry-doc 0/2"
has "${out_poor}" "readiness: total 0/8" "poor total"
has "${out_poor}" "unreferenced scripts" "dead-code evidence names the finding"
has "${out_poor}" "broken relative links" "entry-doc evidence names the finding"

# readiness lines are info/ok only — never warn/fail.
if grep -E '(⚠️|❌)' <<<"${out_poor}" | grep -q 'readiness:'; then
  fail "readiness lines must be info/ok only"
fi

# rubric <-> output lock: every policy axis token appears in doctor output.
for axis in ${AXES}; do
  has "${out_poor}" "readiness: ${axis} " "doctor output axis token '${axis}'"
done

# ── Waiver (D4) + signal-only rc lock ───────────────────────────────
rc_no_waiver="$(sed -n 's/^rc=//p' <<<"${out_poor}")"
printf 'pilot repo, sanity known-poor — 2026-07-03\n' > .sfs-local/readiness-waiver
out_waived="$(run_doctor)"
has "${out_waived}" "readiness waiver recorded" "doctor shows the waiver"
has "${out_waived}" "pilot repo, sanity known-poor" "doctor echoes the waiver reason"
rc_waiver="$(sed -n 's/^rc=//p' <<<"${out_waived}")"
[[ "${rc_no_waiver}" == "${rc_waiver}" ]] \
  || fail "signal-only violated: doctor rc changed with waiver (${rc_no_waiver} -> ${rc_waiver})"

# ── Order discipline: map --write advisory, never a block ───────────
rm -f .sfs-local/readiness-waiver
map_out="$(SFS_DIST_DIR="${DIST_DIR}" bash "${DIST_DIR}/scripts/sfs-harness.sh" map --write 2>&1)" \
  || fail "map --write must succeed without a waiver (signal-only), got rc=$?"
has "${map_out}" "readiness advisory" "map advisory when no waiver"
has "${map_out}" "sfs harness doctor" "advisory routes to doctor"
has "${map_out}" "harness map written" "map still written (never blocked)"
printf 'pilot repo — 2026-07-03\n' > .sfs-local/readiness-waiver
map_out2="$(SFS_DIST_DIR="${DIST_DIR}" bash "${DIST_DIR}/scripts/sfs-harness.sh" map --write 2>&1)" \
  || fail "map --write must succeed with a waiver, got rc=$?"
has "${map_out2}" "readiness waiver recorded" "map acknowledges the waiver"

echo "test-harness-readiness: OK"
