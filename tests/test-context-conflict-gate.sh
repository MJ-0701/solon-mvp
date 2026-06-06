#!/usr/bin/env bash
# WU-1: context conflict gate.
#
# Locks the opt-in conflict-key marker policy and the harness detector that
# flags a slug declared with both `allow` and `deny` stances across a consumer's
# project-local context overrides. Drives synthetic fixtures through the real
# `sfs harness doctor`, mirroring test-operational-log-lag-detector.sh.
# Distribution policies carry no markers, so run-all stays unaffected.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
POLICY="${DIST_DIR}/templates/.sfs-local-template/context/policies/context-conflict-gate.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── Policy doc + index route ───────────────────────────────────────
[[ -f "${POLICY}" ]] || fail "missing context-conflict-gate.md"
has "${POLICY}" "id: sfs-context-conflict-gate" "frontmatter id"
has "${POLICY}" "CONFLICT_KEY_MARKER" "marker section anchor"
has "${POLICY}" "conflict-key:" "marker syntax"
has "${POLICY}" "stance: allow|deny" "stance syntax"
has "${POLICY}" "DETECTION" "detection section anchor"
grep -q '^load_when:' "${POLICY}" || fail "policy missing load_when"
has "${DIST_DIR}/templates/.sfs-local-template/context/_INDEX.md" \
  "policies/context-conflict-gate.md" "index route"

# No private absolute path may leak into the product file.
if grep -Eq '/Users/|/home/[a-z]' "${POLICY}"; then
  fail "context-conflict-gate policy leaks an absolute private path"
fi

# ── Fixtures through the real doctor ───────────────────────────────
tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/sfs-ctx-conflict.XXXXXX")"
trap 'rm -rf "${tmp_root}"' EXIT

make_project() {
  local dir="$1"
  mkdir -p "${dir}"
  cd "${dir}"
  git init -q
  git config user.email "ctx@solon.invalid"
  git config user.name "Solon Ctx Test"
  printf '# t\n' > README.md
  git add . && git commit -qm "init"
  SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
  mkdir -p .sfs-local/context/policies
}

run_doctor() {
  SFS_DIST_DIR="${DIST_DIR}" bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor 2>&1 || true
}

# 1) conflicting pair (allow + deny on same slug) → warn
make_project "${tmp_root}/conflict"
cat > .sfs-local/context/policies/a.md <<'EOF'
# Policy A
Force-push to main is permitted for release automation.
<!-- conflict-key: force-push-main stance: allow -->
EOF
cat > .sfs-local/context/policies/b.md <<'EOF'
# Policy B
Never force-push to main.
<!-- conflict-key: force-push-main stance: deny -->
EOF
out="$(run_doctor)"
grep -qF 'Context Conflict Gate' <<<"${out}" \
  || fail "doctor must add a 'Context Conflict Gate' section"
grep -qE "context-conflict-gate:.*force-push-main.*both allow and deny" <<<"${out}" \
  || fail "conflicting marker pair must warn, got:\n${out}"

# 2) consistent markers (no contradiction) → ok, no conflict warning
make_project "${tmp_root}/clean"
cat > .sfs-local/context/policies/a.md <<'EOF'
# Policy A
Never force-push to main.
<!-- conflict-key: force-push-main stance: deny -->
EOF
cat > .sfs-local/context/policies/b.md <<'EOF'
# Policy B
Never delete without a backup.
<!-- conflict-key: delete-without-backup stance: deny -->
EOF
out="$(run_doctor)"
grep -qE 'context-conflict-gate: no conflicting directives' <<<"${out}" \
  || fail "consistent markers must report ok, got:\n${out}"
grep -qE 'context-conflict-gate:.*both allow and deny' <<<"${out}" \
  && fail "consistent markers must not warn of a conflict"

# 3) no markers at all → skipped (info), never warns
make_project "${tmp_root}/none"
cat > .sfs-local/context/policies/a.md <<'EOF'
# Policy A
Ordinary prose with no stance markers.
EOF
out="$(run_doctor)"
grep -qE 'context-conflict-gate: no conflict-key markers' <<<"${out}" \
  || fail "no markers must skip with info, got:\n${out}"

echo "test-context-conflict-gate: OK"
