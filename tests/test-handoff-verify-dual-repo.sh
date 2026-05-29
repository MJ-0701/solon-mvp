#!/usr/bin/env bash
# tests/test-handoff-verify-dual-repo.sh — 0.7.11 contract.
#
# `sfs handoff verify` must read items 1-2 (VERSION / CHANGELOG) from the
# product repo and items 3-8 (PROGRESS / HANDOFF / sessions / line budget) from
# the docset, even when the two live in different directories (R-D1 dual-repo
# layout). 0.7.10 assumed a single --dir and false-MISMATCHed items 1-2 against
# the docset. This test pins:
#   1. --product-dir / --docset-dir split → 8 PASS, exit 0.
#   2. PROGRESS.md frontmatter `product_repo_path:` resolves the product when
#      only the docset is given.
#   3. backward compat: a single --dir over a combined dir → 8 PASS.
#   4. the original bug shape: --dir at the docset alone → items 1-2 MISMATCH.
#
# All fixtures are synthetic mktemp dirs — never a real workspace path
# (test-private-dev-path-hygiene.sh enforces that on committed files).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
HANDOFF_SH="${DIST_DIR}/scripts/sfs-handoff.sh"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-handoff-dual.XXXXXX")"

cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

# write_product <dir> <version> — VERSION + CHANGELOG headline section.
write_product() {
  local dir="$1" ver="$2"
  mkdir -p "${dir}"
  printf '%s\n' "${ver}" > "${dir}/VERSION"
  cat > "${dir}/CHANGELOG.md" <<EOF
# Changelog

## [${ver}] - 2026-05-29
> **dual-repo handoff verify** — items 1-2 from product, 3-8 from docset.

- something shipped.
EOF
}

# write_docset <dir> <version> [product_repo_path] — PROGRESS / HANDOFF /
# sessions ledger. If a 3rd arg is given it is injected as the frontmatter
# product pointer.
write_docset() {
  local dir="$1" ver="$2" pointer="${3:-}"
  mkdir -p "${dir}/sessions"
  {
    printf -- '---\n'
    printf 'updated: 2026-05-29\n'
    [ -n "${pointer}" ] && printf 'product_repo_path: %s\n' "${pointer}"
    printf -- '---\n\n'
    printf '# Progress\n\n'
    printf 'last_completed_release:\n'
    printf '  version: %s\n' "${ver}"
    printf '  source_main: main\n\n'
    printf 'recent_session_owner_history:\n'
    printf '  - session: quirky-elegant-ritchie\n'
    printf '    released_at: 2026-05-29\n\n'
    printf 'resume_hint:\n'
    printf '  default_action: open WU-0.7.11 D-Code\n'
  } > "${dir}/PROGRESS.md"

  cat > "${dir}/HANDOFF-next-session.md" <<'EOF'
# Handoff

branch: feature/0.7.11-handoff-verify-dual-repo
sha: deadbeef
WU: WU-0.7.11
mode: D-Code
next: cut release
EOF

  cat > "${dir}/sessions/_INDEX.md" <<'EOF'
---
updated: 2026-05-29
---

# Sessions

- quirky-elegant-ritchie — 2026-05-29
EOF
}

run_verify() {
  # echoes combined output; returns the command's exit code.
  bash "${HANDOFF_SH}" verify "$@" 2>&1
}

assert_contains() {
  local hay="$1" needle="$2" label="$3"
  case "${hay}" in
    *"${needle}"*) ;;
    *) fail "${label}: missing '${needle}' in:\n${hay}" ;;
  esac
}

# ── Case 1: explicit dual-repo split ────────────────────────────────
PROD1="${TMP_DIR}/case1/product"
DOCS1="${TMP_DIR}/case1/docset"
write_product "${PROD1}" "0.7.11"
write_docset  "${DOCS1}" "0.7.11"
out="$(run_verify --product-dir "${PROD1}" --docset-dir "${DOCS1}")" && rc=0 || rc=$?
[ "${rc}" -eq 0 ] || fail "case1: expected exit 0, got ${rc}:\n${out}"
assert_contains "${out}" "PASS: 8" "case1 all pass"
assert_contains "${out}" "MISMATCH: 0" "case1 no mismatch"
assert_contains "${out}" "PASS  1. product VERSION present: 0.7.11" "case1 item1 from product"
assert_contains "${out}" "PASS  2. CHANGELOG headline section [0.7.11]" "case1 item2 from product"

# ── Case 2: frontmatter product_repo_path pointer ───────────────────
PROD2="${TMP_DIR}/case2/product"
DOCS2="${TMP_DIR}/case2/docset"
write_product "${PROD2}" "0.7.11"
# absolute pointer; only the docset is supplied on the command line.
write_docset  "${DOCS2}" "0.7.11" "${PROD2}"
out="$(run_verify --docset-dir "${DOCS2}")" && rc=0 || rc=$?
[ "${rc}" -eq 0 ] || fail "case2: expected exit 0, got ${rc}:\n${out}"
assert_contains "${out}" "PASS: 8" "case2 all pass via frontmatter pointer"
assert_contains "${out}" "product source: PROGRESS.md product_repo_path" "case2 pointer reported"

# ── Case 2b: relative product_repo_path resolves against docset ─────
PROD2B="${TMP_DIR}/case2b/repo/product"
DOCS2B="${TMP_DIR}/case2b/repo/docset"
write_product "${PROD2B}" "0.7.11"
write_docset  "${DOCS2B}" "0.7.11" "../product"
out="$(run_verify --dir "${DOCS2B}")" && rc=0 || rc=$?
[ "${rc}" -eq 0 ] || fail "case2b: relative pointer expected exit 0, got ${rc}:\n${out}"
assert_contains "${out}" "PASS: 8" "case2b relative pointer all pass"

# ── Case 3: backward compat — single --dir over a combined dir ──────
COMBO="${TMP_DIR}/case3/combo"
write_product "${COMBO}" "0.7.11"
write_docset  "${COMBO}" "0.7.11"
out="$(run_verify --dir "${COMBO}")" && rc=0 || rc=$?
[ "${rc}" -eq 0 ] || fail "case3: combined --dir expected exit 0, got ${rc}:\n${out}"
assert_contains "${out}" "PASS: 8" "case3 backward-compat all pass"

# ── Case 4: original bug shape — --dir at docset only ───────────────
DOCS4="${TMP_DIR}/case4/docset"
write_docset "${DOCS4}" "0.7.11"   # no VERSION/CHANGELOG, no pointer
out="$(run_verify --dir "${DOCS4}")" && rc=0 || rc=$?
[ "${rc}" -eq 1 ] || fail "case4: expected exit 1 (items 1-2 mismatch), got ${rc}:\n${out}"
assert_contains "${out}" "MISMATCH  1." "case4 item1 mismatch"
assert_contains "${out}" "MISMATCH  2." "case4 item2 mismatch"

echo "PASS: test-handoff-verify-dual-repo.sh"
