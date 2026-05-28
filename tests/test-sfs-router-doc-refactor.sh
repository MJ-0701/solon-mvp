#!/usr/bin/env bash
# SFS.md 는 정책 보관소가 아니라 thin router 로 유지되어야 한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-router-doc-refactor.XXXXXX")"
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

write_bloated_sfs() {
  cat > SFS.md <<'EOF'
---
doc_id: sfs-project-router
title: "SFS.md — `study-note` Solon SFS router"
doc_type: solon-router
managed_by: sfs
---

# SFS.md — `study-note` Solon SFS router

## 프로젝트 개요

- **이름**: `study-note`
- **유형**: `학습 노트 서비스`
- **단계**: `production`
- **환경**: `Azure SWA + Container Apps`
- **핵심 산출물**: `사용자 학습 노트`
- **공유/운영 방식**: `운영 서비스`

Read order:
1. `sfs context cat kernel`
2. `sfs context cat index`

Project overview refresh:
- `sfs profile` updates only this file's `## 프로젝트 개요` section.

Executable Action Ownership is part of the router contract.
Monitor checkpoint classification is mandatory for long-running monitor work.
Handoff-only scope is a stop contract.
Session Continuation Guard is also a router contract.
Division sub-agent council is always-on from brainstorm through Gate 6.
DDD/TDD is a product-level engineering floor, not backend-only.
Never ask the user to confirm a compact option bundle such as `A/A/A/C/C`.
EOF
}

run_sfs() {
  PATH="${DIST_DIR}/bin:$PATH" SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

cd "${TMP_DIR}"
mkdir doctor-case
cd doctor-case
git init --quiet
run_sfs init --layout thin --yes >/dev/null
write_bloated_sfs

run_sfs doctor > doctor.out 2>&1 || true
assert_contains doctor.out "SFS.md needs thin-router refactor" "doctor detects SFS router bloat"

run_sfs doctor --fix > fix.out 2>&1 || true
assert_contains fix.out "SFS.md thin-router refactor applied" "doctor fixes SFS router bloat"
assert_contains SFS.md "sfs context cat kernel" "fixed SFS routes kernel"
assert_contains SFS.md "sfs doctor --fix" "fixed SFS exposes maintenance command"
assert_contains SFS.md '**이름**: `study-note`' "fixed SFS preserves project name"
assert_contains SFS.md "Azure SWA + Container Apps" "fixed SFS preserves environment"
assert_not_contains SFS.md "Executable Action Ownership is part of the router contract" "fixed SFS removes executable policy body"
assert_not_contains SFS.md "Session Continuation Guard is also a router contract" "fixed SFS removes session policy body"

line_count="$(wc -l < SFS.md | tr -d '[:space:]')"
[[ "${line_count}" -le 75 ]] || fail "SFS.md should stay thin, got ${line_count} lines"

archive_count="$(find .sfs-local/archives/sfs-router-doc-refactor -name SFS.md.tar.gz -type f | wc -l | tr -d '[:space:]')"
[[ "${archive_count}" == "1" ]] || fail "expected one SFS.md archive, got ${archive_count}"
assert_contains .sfs-local/archives/sfs-router-doc-refactor/*/manifest.txt "SFS.md" "backup manifest tracks SFS.md"

cd "${TMP_DIR}"
mkdir upgrade-case
cd upgrade-case
git init --quiet
run_sfs init --layout thin --yes >/dev/null
write_bloated_sfs

SFS_UPDATE_SELF=0 run_sfs upgrade --no-self-upgrade --yes > upgrade.out 2>&1
assert_contains upgrade.out "SFS.md router refactor:" "upgrade runs SFS router doctor"
assert_contains upgrade.out "refactored: SFS.md" "upgrade refactors bloated SFS router"
assert_contains SFS.md '**이름**: `study-note`' "upgrade preserves project overview"
assert_not_contains SFS.md "Division sub-agent council is always-on" "upgrade removes division policy body"

echo "test-sfs-router-doc-refactor: OK"
