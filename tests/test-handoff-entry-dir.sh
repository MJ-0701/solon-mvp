#!/usr/bin/env bash
# tests/test-handoff-entry-dir.sh — entry-dir guard contract (item 9).
#
# `sfs handoff verify` item 9 closes the cross-repo silent-non-pickup bug: a
# handoff authored in the docset but opened in the distribution repo (or vice-
# versa) finds no PROGRESS/sprints/CLAUDE.md and the receiver mis-reads the
# absence as "nothing to do". This pins:
#   a. entry_working_dir + entry_repo resolving a resume target → item 9 PASS, exit 0.
#   b. entry_working_dir declared but no resume target there → item 9 MISMATCH, exit 1.
#   c. entry_working_dir pointing at a nonexistent dir → item 9 MISMATCH, exit 1.
#   d. backward compat: no entry_working_dir → item 9 WARN, exit 0 (does not block).
#
# All fixtures are synthetic mktemp dirs — never a real workspace path
# (test-private-dev-path-hygiene.sh enforces that on committed files).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
HANDOFF_SH="${DIST_DIR}/scripts/sfs-handoff.sh"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-handoff-entry.XXXXXX")"

cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

# write a product + docset that satisfy items 1-8; HANDOFF is written separately
# so each case can vary its entry_working_dir frontmatter.
write_base() {
  local prod="$1" docs="$2" ver="0.7.11"
  mkdir -p "${prod}" "${docs}/sessions"
  printf '%s\n' "${ver}" > "${prod}/VERSION"
  cat > "${prod}/CHANGELOG.md" <<EOF
# Changelog

## [${ver}] - 2026-05-29
> **entry-dir guard** — item 9 closes cross-repo silent non-pickup.

- shipped.
EOF
  {
    printf -- '---\nupdated: 2026-05-29\n---\n\n# Progress\n\n'
    printf 'last_completed_release:\n  version: %s\n  source_main: main\n\n' "${ver}"
    printf 'recent_session_owner_history:\n  - session: x\n    released_at: 2026-05-29\n\n'
    printf 'resume_hint:\n  default_action: open next WU\n'
  } > "${docs}/PROGRESS.md"
  cat > "${docs}/sessions/_INDEX.md" <<'EOF'
---
updated: 2026-05-29
---

# Sessions

- x — 2026-05-29
EOF
}

# write_handoff <docset> [entry_working_dir]
write_handoff() {
  local docs="$1" ewd="${2:-}"
  {
    printf -- '---\n'
    printf 'branch: feature/handoff-entry-dir-guard\n'
    printf 'sha: deadbeef\n'
    if [ -n "${ewd}" ]; then
      printf 'entry_working_dir: %s\n' "${ewd}"
      printf 'entry_repo: "test-repo (synthetic)"\n'
    fi
    printf -- '---\n\n# Handoff\n\nWU next mode D-Code branch sha.\n'
  } > "${docs}/HANDOFF-next-session.md"
}

run_verify() { bash "${HANDOFF_SH}" verify "$@" 2>&1; }

assert_contains() {
  local hay="$1" needle="$2" label="$3"
  case "${hay}" in
    *"${needle}"*) ;;
    *) fail "${label}: missing '${needle}' in:\n${hay}" ;;
  esac
}

# ── Case a: entry_working_dir resolves a resume target → PASS, exit 0 ─
PROD="${TMP_DIR}/a/product"; DOCS="${TMP_DIR}/a/docset"
write_base "${PROD}" "${DOCS}"
write_handoff "${DOCS}" "${DOCS}"   # docset has PROGRESS.md → resolves
out="$(run_verify --product-dir "${PROD}" --docset-dir "${DOCS}")" && rc=0 || rc=$?
[ "${rc}" -eq 0 ] || fail "case a: expected exit 0, got ${rc}:\n${out}"
assert_contains "${out}" "PASS  9. entry_working_dir resolves a resume target" "case a item9 pass"
assert_contains "${out}" "repo: test-repo (synthetic)" "case a entry_repo reported"

# ── Case b: entry_working_dir exists but has no resume target → MISMATCH ─
PROD="${TMP_DIR}/b/product"; DOCS="${TMP_DIR}/b/docset"; EMPTY="${TMP_DIR}/b/empty"
write_base "${PROD}" "${DOCS}"; mkdir -p "${EMPTY}"
write_handoff "${DOCS}" "${EMPTY}"
out="$(run_verify --product-dir "${PROD}" --docset-dir "${DOCS}")" && rc=0 || rc=$?
[ "${rc}" -eq 1 ] || fail "case b: expected exit 1 (no resume target), got ${rc}:\n${out}"
assert_contains "${out}" "MISMATCH  9." "case b item9 mismatch"
assert_contains "${out}" "no resume target" "case b mismatch message"

# ── Case c: entry_working_dir points at a nonexistent dir → MISMATCH ─
PROD="${TMP_DIR}/c/product"; DOCS="${TMP_DIR}/c/docset"
write_base "${PROD}" "${DOCS}"
write_handoff "${DOCS}" "${TMP_DIR}/c/does-not-exist"
out="$(run_verify --product-dir "${PROD}" --docset-dir "${DOCS}")" && rc=0 || rc=$?
[ "${rc}" -eq 1 ] || fail "case c: expected exit 1 (dir missing), got ${rc}:\n${out}"
assert_contains "${out}" "does not resolve to a directory" "case c mismatch message"

# ── Case d: backward compat — no entry_working_dir → WARN, exit 0 ────
PROD="${TMP_DIR}/d/product"; DOCS="${TMP_DIR}/d/docset"
write_base "${PROD}" "${DOCS}"
write_handoff "${DOCS}"   # no entry_working_dir
out="$(run_verify --product-dir "${PROD}" --docset-dir "${DOCS}")" && rc=0 || rc=$?
[ "${rc}" -eq 0 ] || fail "case d: expected exit 0 (backward compat), got ${rc}:\n${out}"
assert_contains "${out}" "WARN  9." "case d item9 warn"
assert_contains "${out}" "WARN: 1" "case d warn counted"

echo "PASS: test-handoff-entry-dir.sh"
