#!/usr/bin/env bash
# 0.7.10: sfs harness doctor must flag operational-log lag — the gap between a
# project's VERSION and its PROGRESS.md last_completed_release.version. The
# 0.6.141 → 0.7.9 (16-release) drift went unseen because no detector existed.
# This test drives synthetic fixtures through the real harness and asserts the
# warn / partial severities, plus the md-line-budget-violation sibling.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

fail() { echo "FAIL: $*" >&2; exit 1; }

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/sfs-oplog-lag.XXXXXX")"
trap 'rm -rf "${tmp_root}"' EXIT

# Initialize a real SFS project so the doctor reaches the new section.
make_project() {
  local dir="$1"
  mkdir -p "${dir}"
  cd "${dir}"
  git init -q
  git config user.email "oplog@solon.invalid"
  git config user.name "Solon Oplog Test"
  printf '# t\n' > README.md
  mkdir -p tests
  git add . && git commit -qm "init"
  SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
}

write_progress() {
  cat > PROGRESS.md <<EOF
---
doc_id: progress
---
last_completed_release:
  version: $1
  source_main: deadbeef
EOF
}

run_doctor() {
  SFS_DIST_DIR="${DIST_DIR}" bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor 2>&1 || true
}

# ── 1) in-sync → ok, no lag warning ────────────────────────────────
make_project "${tmp_root}/sync"
printf '0.7.10\n' > VERSION
write_progress "0.7.10"
out="$(run_doctor)"
grep -qF 'Operational Logs And Size' <<<"${out}" \
  || fail "doctor must add an 'Operational Logs And Size' section"
grep -qE 'operational-log-lag:.*in sync' <<<"${out}" \
  || fail "in-sync project must report operational-log-lag in sync, got:\n${out}"

# ── 2) small patch lag → warn ──────────────────────────────────────
make_project "${tmp_root}/warn"
printf '0.7.10\n' > VERSION
write_progress "0.7.8"
out="$(run_doctor)"
grep -qE '⚠️.*operational-log-lag:.*0\.7\.8.*behind VERSION 0\.7\.10.*lag 2' <<<"${out}" \
  || fail "patch lag must warn with lag count, got:\n${out}"
grep -qE 'partial:.*operational-log-lag' <<<"${out}" \
  && fail "small patch lag must not escalate to partial"

# ── 3) minor-level lag (16 releases, 0.6.141 → 0.7.10) → partial ───
make_project "${tmp_root}/partial"
printf '0.7.10\n' > VERSION
write_progress "0.6.141"
out="$(run_doctor)"
grep -qE 'partial:.*operational-log-lag:.*0\.6\.141.*behind VERSION 0\.7\.10' <<<"${out}" \
  || fail "minor-level lag must escalate to partial, got:\n${out}"

# ── 4) md-line-budget sibling: a 260-line in-scope log → fail ──────
make_project "${tmp_root}/budget"
printf '0.7.10\n' > VERSION
write_progress "0.7.10"
{ printf -- '---\ndoc_id: x\n---\n'; for i in $(seq 1 300); do echo "line ${i}"; done; } > HANDOFF-next-session.md
out="$(run_doctor)"
grep -qE '❌.*md-line-budget-violation:.*HANDOFF-next-session.md.*fail' <<<"${out}" \
  || fail "260+ line operational log must hit md-line-budget fail, got:\n${out}"

# ── 5) doctor returns non-zero when the budget detector fails ──────
rc=0
SFS_DIST_DIR="${DIST_DIR}" bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor >/dev/null 2>&1 || rc=$?
[[ "${rc}" -ne 0 ]] || fail "doctor must exit non-zero when a md-line-budget fail is present"

echo "test-operational-log-lag-detector: OK"
