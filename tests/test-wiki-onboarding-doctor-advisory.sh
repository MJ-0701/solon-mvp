#!/usr/bin/env bash
# Wiki strong-recommendation doctor advisory (OWNER-2026-06-06-wiki-strong-reco).
#
# `sfs harness doctor` must surface a one-line advisory when a project has no
# llm-wiki/ AND no recorded waiver, and must fall silent (neutral line, no
# advisory) once a waiver is recorded. The advisory is info-only: it must never
# change the doctor exit code or the pass/warn/fail counts (the standalone /
# never-hard-block guarantee). ASCII anchors only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-wiki-doctor-advisory.XXXXXX")"
trap 'rm -rf "${TMP_DIR}"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

run_sfs() {
  PATH="${DIST_DIR}/bin:$PATH" SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

cd "${TMP_DIR}"
mkdir project
cd project
git init --quiet
run_sfs init --layout thin --yes >/dev/null
mkdir -p tests

# Normalize to the "no wiki, no waiver" state regardless of init defaults.
rm -rf llm-wiki
rm -f .sfs-local/llm-wiki.waiver

# ── State A: no wiki, no waiver → advisory present ──────────────────
run_sfs harness doctor > doctor-no-waiver.out || true
grep -Fq -- "llm-wiki advisory: wiki strongly recommended but absent" doctor-no-waiver.out \
  || fail "no-waiver: expected advisory line is missing"
grep -Fq -- "never blocks" doctor-no-waiver.out \
  || fail "no-waiver: advisory must mark itself non-blocking"

# ── State B: waiver recorded → advisory silent ──────────────────────
mkdir -p .sfs-local
printf 'declined_at=test\nreason=fixture-opt-out\n' > .sfs-local/llm-wiki.waiver
run_sfs harness doctor > doctor-with-waiver.out || true
if grep -Fq -- "llm-wiki advisory: wiki strongly recommended but absent" doctor-with-waiver.out; then
  fail "with-waiver: advisory must fall silent once a waiver is recorded"
fi
grep -Fq -- "waiver recorded (.sfs-local/llm-wiki.waiver)" doctor-with-waiver.out \
  || fail "with-waiver: expected neutral waiver-acknowledged line is missing"

# ── Exit code + summary must be identical across both states ────────
# (advisory is info-only — it cannot change doctor's verdict.)
sumline() { grep -E 'pass: [0-9]+ +warn: [0-9]+ +fail: [0-9]+' "$1" | tail -1; }
a="$(sumline doctor-no-waiver.out)"
b="$(sumline doctor-with-waiver.out)"
[[ -n "${a}" ]] || fail "no-waiver: summary line not found"
[[ "${a}" == "${b}" ]] \
  || fail "advisory changed doctor counts: '${a}' vs '${b}'"

echo "test-wiki-onboarding-doctor-advisory: OK"
