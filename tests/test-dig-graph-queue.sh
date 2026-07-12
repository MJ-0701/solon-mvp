#!/usr/bin/env bash
# sfs dig B — L1 static graph + L2 queue headline.
#
# Locks, against the two framework fixtures:
#   - import edges resolved in grep reduced mode (no external tools)
#   - route -> handler -> service -> table chain rows
#   - BFS queue from entrypoints/routes, dead-code candidates last
#   - L2 gate marking: NOT-READY without sanity pass/waiver, READY with waiver
#     (signal-only: files are always written, exit code unchanged)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DIG="${DIST_DIR}/scripts/sfs-dig.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2' in $1"; }

TMP="$(mktemp -d "${TMPDIR:-/tmp}/sfs-dig-graph.XXXXXX")"
trap 'rm -rf "${TMP}"' EXIT

# ── spring-jpa: 2-hop table mapping + dead-code ─────────────────────
cp -R "${SCRIPT_DIR}/fixtures/dig/spring-jpa" "${TMP}/spring-jpa"
cd "${TMP}/spring-jpa"
bash "${DIG}" scan --write >/dev/null 2>&1
bash "${DIG}" graph --write >/dev/null 2>&1 || fail "graph failed on spring-jpa"
EXC="docs/solon/spring-jpa/excavation"
fhas "${EXC}/graph.md" "OrderController.java	src/main/java/com/acme/service/OrderService.java" "java import edge controller->service"
fhas "${EXC}/graph.md" "OrderService.java	src/main/java/com/acme/repo/OrderRepository.java" "java import edge service->repo"
grep -E '^\| src/main/java/com/acme/controller/OrderController.java:18 .*OrderService\.java.*orders' "${EXC}/graph.md" >/dev/null \
  || fail "route chain row must map GET route -> OrderService -> orders table"
fhas "${EXC}/graph.md" "src/main/java/com/acme/util/LegacyHelper.java" "dead-code candidate listed"
fhas "${EXC}/l2-queue.md" "depth=0" "BFS depth annotations"
fhas "${EXC}/l2-queue.md" "dead-code-candidate src/main/java/com/acme/util/LegacyHelper.java" "dead-code queued last"
# BFS: dead-code candidates must come after the deepest reachable entry
last_reach="$(grep -n 'depth=' "${EXC}/l2-queue.md" | tail -1 | cut -d: -f1)"
first_dead="$(grep -n 'dead-code-candidate' "${EXC}/l2-queue.md" | head -1 | cut -d: -f1)"
[[ "${first_dead}" -gt "${last_reach}" ]] || fail "dead-code candidates must be queued after reachable files"

# ── L2 gate marking (sanity=warn on the bare fixture → NOT-READY) ───
fhas "${EXC}/l2-queue.md" "L2-GATE: NOT-READY" "gate NOT-READY without sanity pass/waiver"

# waiver path: re-scan with --waive-sanity, regenerate queue → READY
bash "${DIG}" scan --write --waive-sanity "인수 첫날 — sanity 정비 전 L2 병행 승인" >/dev/null 2>&1
bash "${DIG}" graph --write >/dev/null 2>&1
fhas "${EXC}/l2-queue.md" "L2-GATE: READY" "gate READY with recorded waiver"
fhas "${EXC}/l2-queue.md" "waiver" "waiver named in gate line"

# ── node-prisma: js edges + queue ────────────────────────────────────
cp -R "${SCRIPT_DIR}/fixtures/dig/node-prisma" "${TMP}/node-prisma"
cd "${TMP}/node-prisma"
bash "${DIG}" scan --write >/dev/null 2>&1
bash "${DIG}" graph --write >/dev/null 2>&1 || fail "graph failed on node-prisma"
EXC="docs/solon/node-prisma/excavation"
fhas "${EXC}/graph.md" "src/index.js	src/routes/posts.js" "js import edge index->routes"
fhas "${EXC}/graph.md" "src/routes/posts.js	src/services/postService.js" "js import edge routes->service"
grep -E '^\| src/routes/posts.js:6 .*postService\.js.*post' "${EXC}/graph.md" >/dev/null \
  || fail "route chain row must map GET /posts -> postService -> post model"
fhas "${EXC}/graph.md" "src/orphan.js" "orphan flagged dead-code"
fhas "${EXC}/l2-queue.md" "dead-code-candidate src/orphan.js" "orphan queued as dead-code candidate"

echo "test-dig-graph-queue: OK"
