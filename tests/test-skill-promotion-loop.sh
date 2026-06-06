#!/usr/bin/env bash
# WU-3: skill promotion loop (suggest-only).
#
# Locks the policy doc + the harness detector that SUGGESTS skill/command
# candidates from repeated completed-work patterns. Read-only: it must emit
# info/ok only (never warn/fail) so doctor's exit code is unchanged, and it must
# never write a skill. Drives synthetic PROGRESS fixtures through the real
# `sfs harness doctor`. Distribution has no such logs, so run-all is unaffected.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/skill-promotion-loop.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── Policy doc + routes ────────────────────────────────────────────
[[ -f "${POLICY}" ]] || fail "missing skill-promotion-loop.md"
has "${POLICY}" "id: sfs-skill-promotion-loop" "frontmatter id"
grep -q '^load_when:' "${POLICY}" || fail "policy missing load_when"
has "${POLICY}" "SUGGEST_ONLY" "suggest-only section anchor"
has "${POLICY}" "read-only" "read-only claim"
has "${POLICY}" "lessons-accumulation.md" "failure-twin cross-link"
has "${CTX}/_INDEX.md" "policies/skill-promotion-loop.md" "index route"
has "${CTX}/commands/tidy.md" "skill-promotion-loop.md" "tidy rail guidance"
if grep -Eq '/Users/|/home/[a-z]' "${POLICY}"; then
  fail "skill-promotion-loop policy leaks an absolute private path"
fi

# ── Fixtures through the real doctor ───────────────────────────────
tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/sfs-skill-promote.XXXXXX")"
trap 'rm -rf "${tmp_root}"' EXIT

make_project() {
  local dir="$1"
  mkdir -p "${dir}"
  cd "${dir}"
  git init -q
  git config user.email "skill@solon.invalid"
  git config user.name "Solon Skill Test"
  printf '# t\n' > README.md
  git add . && git commit -qm "init"
  SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
}

run_doctor() {
  SFS_DIST_DIR="${DIST_DIR}" bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor 2>&1 || true
}

# 1) repeated pattern (3 version-stamped repeats) → candidate suggested
make_project "${tmp_root}/repeat"
cat > PROGRESS.md <<'EOF'
# progress
- [x] release cut 0.8.23
- [x] release cut 0.8.24
- [x] release cut 0.8.25
- [x] one-off domain glossary fix
EOF
out="$(run_doctor)"
grep -qF 'Skill Promotion Candidates' <<<"${out}" \
  || fail "doctor must add a 'Skill Promotion Candidates' section"
grep -qE "skill-promote-candidate: 'release cut' completed 3 times" <<<"${out}" \
  || fail "repeated pattern must surface a candidate, got:\n${out}"
grep -qF 'suggest-only' <<<"${out}" || fail "candidate must be marked suggest-only"
# Read-only: no skill file may have been created.
[[ ! -e .claude/skills/release-cut ]] || fail "loop must not auto-create a skill"

# 2) distinct tasks (no repeat at threshold) → no candidate
make_project "${tmp_root}/distinct"
cat > PROGRESS.md <<'EOF'
# progress
- [x] add login endpoint
- [x] write migration for orders
- [x] fix flaky payment test
EOF
out="$(run_doctor)"
grep -qE 'skill-promote-candidate: no repeated work pattern' <<<"${out}" \
  || fail "distinct tasks must report no candidate, got:\n${out}"
grep -qE 'skill-promote-candidate:.*completed [0-9]+ times' <<<"${out}" \
  && fail "distinct tasks must not surface a candidate"

# 2b) non-ASCII (Korean) repeated pattern must still surface — punctuation is
#     stripped via [[:punct:]], not a whitelist, so Korean text is not erased.
#     Assert via the ASCII count to avoid a Korean grep entirely.
make_project "${tmp_root}/korean"
printf '# progress\n- [x] 주간 리포트 생성\n- [x] 주간 리포트 생성\n- [x] 주간 리포트 생성\n' > PROGRESS.md
out="$(run_doctor)"
grep -qE 'skill-promote-candidate:.*completed 3 times' <<<"${out}" \
  || fail "Korean repeated pattern must still surface a candidate, got:\n${out}"

# 2c) uppercase [X] checkboxes are counted too.
make_project "${tmp_root}/upper"
printf '# progress\n- [X] backup database\n- [X] backup database\n- [X] backup database\n' > PROGRESS.md
out="$(run_doctor)"
grep -qE "skill-promote-candidate: 'backup database' completed 3 times" <<<"${out}" \
  || fail "uppercase [X] entries must be counted, got:\n${out}"

# 3) read-only proof: detector must not raise doctor's exit on a clean project.
make_project "${tmp_root}/exit"
cat > PROGRESS.md <<'EOF'
# progress
- [x] generate weekly recap
- [x] generate weekly recap
- [x] generate weekly recap
EOF
rc=0
SFS_DIST_DIR="${DIST_DIR}" bash "${DIST_DIR}/scripts/sfs-harness.sh" doctor >/tmp/sp-exit.out 2>&1 || rc=$?
grep -qE "skill-promote-candidate: 'generate weekly recap' completed 3 times" /tmp/sp-exit.out \
  || fail "candidate must surface in exit-code project"
# A candidate is info-level; it must not by itself push doctor to a fail (rc 2).
[[ "${rc}" -ne 2 ]] || fail "skill-promote candidate must not cause a doctor fail exit"

echo "test-skill-promotion-loop: OK"
