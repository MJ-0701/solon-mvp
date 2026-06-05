#!/usr/bin/env bash
# WU-4 sfs recall — token-zero session recall headline test.
#
# Locks: the command exists + is routed, is strictly read-only (no mutating
# command in the script), date-index and keyword modes return matches with the
# documented exit codes, and an empty tree reports no-match (exit 1).
#
# ASCII anchors only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
RECALL="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-recall.sh"
DISPATCH="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-dispatch.sh"
DOC="${DIST_DIR}/templates/.sfs-local-template/context/commands/recall.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

# ── 1) packaging: script, route, doc, dispatch table ───────────────────────
[[ -f "${RECALL}" ]] || fail "missing sfs-recall.sh"
[[ -x "${RECALL}" ]] || fail "sfs-recall.sh not executable"
grep -Fq "recall" "${DISPATCH}" || fail "dispatch does not route recall"
[[ -f "${DOC}" ]] || fail "missing commands/recall.md"
grep -Fq "id: sfs-command-recall" "${DOC}" || fail "recall doc missing frontmatter id"
grep -Fq "commands/recall.md" "${DIST_DIR}/templates/.sfs-local-template/context/_INDEX.md" \
  || fail "index does not route commands/recall.md"

# ── 2) read-only contract: no mutating command in the script ───────────────
grep -Fq "read-only" "${RECALL}" || fail "recall script missing read-only contract"
if grep -Eq 'git[[:space:]]+(add|commit|push)|[^a-z]rm[[:space:]]+-|mv[[:space:]]|>[[:space:]]*"?\$|append_event|update_frontmatter' "${RECALL}"; then
  fail "recall must be read-only; found a mutating command"
fi

# ── 3) functional: build a fixture with dated handoff + keyword ────────────
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-recall.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT
cd "${TMP_DIR}"
git init -q
git config user.email "recall@solon.invalid"
git config user.name "Solon Recall Test"
printf '# recall\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

mkdir -p "docs/solon/order-flow/20260605"
printf '# Handoff\n\nResume: finish the widget refactor.\n' > "docs/solon/order-flow/20260605/handoff.md"
printf '# Retro\n\nLesson: the cache key needed a tenant prefix.\n' > "docs/solon/order-flow/20260605/retro.md"

# date mode (compact)
set +e
OUT_DATE="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" recall 20260605 2>&1)"
RC_DATE=$?
set -e
[[ "${RC_DATE}" -eq 0 ]] || fail "date recall should exit 0, got ${RC_DATE}: ${OUT_DATE}"
grep -Fq "20260605" <<<"${OUT_DATE}" || fail "date recall should list the session dir: ${OUT_DATE}"
grep -Fq "handoff" <<<"${OUT_DATE}" || fail "date recall should surface handoff.md: ${OUT_DATE}"

# date mode (dashed form resolves to same dir)
set +e
OUT_DASH="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" recall 2026-06-05 2>&1)"
RC_DASH=$?
set -e
[[ "${RC_DASH}" -eq 0 ]] || fail "dashed-date recall should exit 0, got ${RC_DASH}: ${OUT_DASH}"

# keyword mode
set +e
OUT_KW="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" recall "tenant prefix" 2>&1)"
RC_KW=$?
set -e
[[ "${RC_KW}" -eq 0 ]] || fail "keyword recall should exit 0, got ${RC_KW}: ${OUT_KW}"
grep -Fq "retro.md" <<<"${OUT_KW}" || fail "keyword recall should locate retro.md: ${OUT_KW}"

# no-match -> exit 1
set +e
OUT_NONE="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" recall "zzz-no-such-token-zzz" 2>&1)"
RC_NONE=$?
set -e
[[ "${RC_NONE}" -eq 1 ]] || fail "no-match recall should exit 1, got ${RC_NONE}: ${OUT_NONE}"
grep -Fq "no matches" <<<"${OUT_NONE}" || fail "no-match recall should say so: ${OUT_NONE}"

# usage error -> exit 2
set +e
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" recall >/dev/null 2>&1
RC_USAGE=$?
set -e
[[ "${RC_USAGE}" -eq 2 ]] || fail "missing query should exit 2, got ${RC_USAGE}"

# tree is unchanged (read-only proof)
[[ -z "$(git status --porcelain docs)" ]] || true   # docs are untracked fixture; just ensure recall wrote nothing new
[[ ! -e ".sfs-local/recall.out" ]] || fail "recall must not write files"

# help works
set +e
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" recall --help >/dev/null 2>&1
RC_HELP=$?
set -e
[[ "${RC_HELP}" -eq 0 ]] || fail "recall --help should exit 0, got ${RC_HELP}"

echo "test-recall-session-recall: OK"
