#!/usr/bin/env bash
# 0.7.3 — consumer-side pollution warning surface.
#
# Verifies that when a consumer's CLAUDE.md / AGENTS.md / GEMINI.md
# declares frontmatter_only:true but carries body content (the 0.7.2-class
# pollution: project state / architecture / infra / methodology bleed),
# the next interactive sfs invocation prints a one-line WARN + the
# `sfs agent doctor --fix` AS hint.
#
# The detection lives in `sfs_maybe_emit_hygiene_notice`
# (templates/.sfs-local-template/scripts/sfs-common.sh). The hint surfaces
# the existing AS path (shipped in 0.6.139) to consumers who do not know
# to run the doctor themselves.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

fail() { echo "FAIL: $*" >&2; exit 1; }

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-polluted-adapter.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "polluted@solon.invalid"
git config user.name "Solon Polluted Test"
printf '# polluted\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

# ── 1) Pollute CLAUDE.md — frontmatter_only:true marker + bleed body. ─
cat > CLAUDE.md <<'EOF'
---
doc_id: sfs-project-agent-adapter-claude
title: "CLAUDE.md — polluted test"
doc_type: agent-adapter-bootstrap
agent: claude-code
frontmatter_only: true
updated: 2026-05-28
---

# Polluted CLAUDE.md

## 프로젝트 개요

- 이름: my-project
- 도메인: 테스트용
- 아키텍처: monolith + Postgres

## 배포 원칙

1. install.sh 는 bash 호환
2. CHANGELOG.md 는 모든 릴리스 기록

## 수정 시 체크리스트

- [ ] foo
- [ ] bar
EOF

# ── 2) Force hygiene notice (bypass TTL + interactive-tty gate). ─────
out="$(
  SFS_DIST_DIR="${DIST_DIR}" \
  SFS_HYGIENE_NOTICE_FORCE=1 \
  SFS_HYGIENE_NOTICE=1 \
  bash "${SFS_BIN}" status 2>&1 || true
)"

# ── 3) The WARN must surface the polluted file name + AS hint. ──────
echo "${out}" | grep -qF 'sfs hygiene notice' \
  || fail "polluted CLAUDE.md should trigger 'sfs hygiene notice' header
got:
${out}"

echo "${out}" | grep -qF 'polluted agent adapter doc detected' \
  || fail "hygiene notice must call out polluted agent adapter doc
got:
${out}"

echo "${out}" | grep -qF 'CLAUDE.md' \
  || fail "hygiene notice must name the polluted file (CLAUDE.md)
got:
${out}"

echo "${out}" | grep -qF 'sfs agent doctor --fix' \
  || fail "hygiene notice must surface the AS path \`sfs agent doctor --fix\`
got:
${out}"

# ── 4) A clean (frontmatter-only) CLAUDE.md should NOT trigger. ─────
cat > CLAUDE.md <<'EOF'
---
doc_id: sfs-project-agent-adapter-claude
title: "CLAUDE.md — clean test"
doc_type: agent-adapter-bootstrap
agent: claude-code
frontmatter_only: true
updated: 2026-05-28
---
EOF

# Hygiene state is cached; force a fresh check.
rm -f .sfs-local/cache/hygiene-notice.env 2>/dev/null || true

clean_out="$(
  SFS_DIST_DIR="${DIST_DIR}" \
  SFS_HYGIENE_NOTICE_FORCE=1 \
  SFS_HYGIENE_NOTICE=1 \
  bash "${SFS_BIN}" status 2>&1 || true
)"

if echo "${clean_out}" | grep -qF 'polluted agent adapter doc detected'; then
  fail "frontmatter-only CLAUDE.md must NOT trigger the polluted-adapter notice
got:
${clean_out}"
fi

echo "test-polluted-adapter-hygiene-notice: OK"
