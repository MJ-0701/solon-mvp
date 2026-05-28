#!/usr/bin/env bash
# SFS 루트 agent 문서 비대화 감지와 frontmatter-only 자동 정리를 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-agent-doc-refactor.XXXXXX")"
trap 'rm -rf "${TMP_DIR}"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

assert_frontmatter_only() {
  local file="$1" label="$2"
  [[ "$(sed -n '1p' "${file}")" == "---" ]] || fail "${label}: missing opening frontmatter"
  sed -n '2,120p' "${file}" | grep -Fxq -- "---" || fail "${label}: missing closing frontmatter"
  if awk '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { in_fm = 0; seen_close = 1; next }
    seen_close && $0 ~ /[^[:space:]]/ { found = 1 }
    END { exit found ? 0 : 1 }
  ' "${file}"; then
    fail "${label}: body text remains"
  fi
}

cd "${TMP_DIR}"
git init --quiet
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null

cat >> CLAUDE.md <<'EOF'

# Accidental SFS Policy Copy

This project uses Solon Product SFS.

SFS commands — bash adapter SSoT

Session Continuation Guard
EOF

SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" agent doctor > doctor.out
assert_contains doctor.out "needs-refactor: CLAUDE.md" "doctor detects bloated Claude adapter"
assert_contains doctor.out "ok frontmatter-only: AGENTS.md" "doctor accepts thin Codex adapter"
assert_contains doctor.out "ok frontmatter-only: GEMINI.md" "doctor accepts thin Gemini adapter"

SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" agent doctor --fix > fix.out
assert_contains fix.out "refactored: CLAUDE.md" "doctor fixes bloated Claude adapter"
assert_contains fix.out "agent doc refactor backup:" "doctor writes backup archive"

assert_frontmatter_only CLAUDE.md "fixed Claude adapter"
assert_contains CLAUDE.md "frontmatter_only: true" "fixed Claude frontmatter marker"
assert_contains CLAUDE.md "sfs agent doctor --fix" "fixed Claude maintenance pointer"
assert_not_contains CLAUDE.md "Accidental SFS Policy Copy" "fixed Claude removed body"
assert_not_contains CLAUDE.md "Session Continuation Guard" "fixed Claude removed policy body"

archive_count="$(find .sfs-local/archives/agent-doc-refactor -name root-agent-docs.tar.gz -type f | wc -l | tr -d '[:space:]')"
[[ "${archive_count}" == "1" ]] || fail "expected one root-agent-docs archive, got ${archive_count}"
assert_contains .sfs-local/archives/agent-doc-refactor/*/manifest.txt "CLAUDE.md" "backup manifest tracks Claude adapter"

cat > AGENTS.md <<'EOF'
# Local Codex Notes

This is a project-specific non-SFS note.
EOF

SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" agent doctor --fix > non-sfs.out
assert_contains non-sfs.out "skip non-sfs: AGENTS.md" "doctor skips non-SFS agent docs"
assert_contains AGENTS.md "project-specific non-SFS note" "doctor preserves non-SFS body"

echo "test-agent-doc-refactor: OK"
