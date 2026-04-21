#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Solon v0.4-r3 · scripts/snapshot.sh
# 목적: WU 진행 중 file-level auto-snapshot — compact / FUSE 장애 /
#       네트워크 유실 대비 마지막 안정 상태 복구용.
# 트리거: 15분 (cron/launchd) · WU 전환 · micro-step 완료 · PROGRESS 덮어쓰기
# SSoT: CLAUDE.md §9 + tmp/workflow-v2-design.md §10
# FUSE 대응: /tmp/solon-snapshots-<session>/ 1차 + FUSE 2차 (2-step 저장)
# Usage: ./scripts/snapshot.sh <trigger-label>
#   ex: ./scripts/snapshot.sh "event:wu-transition"
#       ./scripts/snapshot.sh "time:15min"
#       ./scripts/snapshot.sh "event:micro-step-complete"
# ────────────────────────────────────────────────────────────────
set -euo pipefail

# ── 기본 변수 ──
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

STAMP=$(date -u +"%Y-%m-%dT%H-%M-%S")
TRIGGER="${1:-unknown}"
SESSION="${CLAUDE_SESSION_NAME:-unknown-session}"

FUSE_SNAP_DIR="tmp/snapshots/${STAMP}"
LOCAL_SNAP_DIR="/tmp/solon-snapshots-${SESSION}/${STAMP}"

mkdir -p "${FUSE_SNAP_DIR}"
mkdir -p "${LOCAL_SNAP_DIR}"

# ── PROGRESS.md 복사 (필수) ──
cp PROGRESS.md "${FUSE_SNAP_DIR}/PROGRESS.md"
cp PROGRESS.md "${LOCAL_SNAP_DIR}/PROGRESS.md"

# ── current_wu 파싱 + WU 파일 복사 (있으면) ──
CURRENT_WU=$(awk -F': *' '/^current_wu:/ {print $2; exit}' PROGRESS.md | tr -d '[:space:]')
CURRENT_WU_PATH=$(awk -F': *' '/^current_wu_path:/ {print $2; exit}' PROGRESS.md | tr -d '[:space:]')

if [[ -n "${CURRENT_WU_PATH}" && -f "${CURRENT_WU_PATH}" ]]; then
  SAFE_NAME="${CURRENT_WU_PATH//\//_}"
  cp "${CURRENT_WU_PATH}" "${FUSE_SNAP_DIR}/${SAFE_NAME}"
  cp "${CURRENT_WU_PATH}" "${LOCAL_SNAP_DIR}/${SAFE_NAME}"
fi

# ── 매니페스트 작성 ──
MANIFEST="${FUSE_SNAP_DIR}/_manifest.yaml"
cat > "${MANIFEST}" <<EOF
---
timestamp: ${STAMP}
trigger: "${TRIGGER}"
session: ${SESSION}
current_wu: ${CURRENT_WU:-none}
current_wu_path: ${CURRENT_WU_PATH:-none}
files_captured:
  - PROGRESS.md
EOF
if [[ -n "${CURRENT_WU_PATH}" && -f "${CURRENT_WU_PATH}" ]]; then
  echo "  - ${CURRENT_WU_PATH}" >> "${MANIFEST}"
fi
echo "fuse_path: ${FUSE_SNAP_DIR}" >> "${MANIFEST}"
echo "local_path: ${LOCAL_SNAP_DIR}" >> "${MANIFEST}"

# 동일 매니페스트를 local mirror 에도 복사
cp "${MANIFEST}" "${LOCAL_SNAP_DIR}/_manifest.yaml"

# ── Cleanup: 24h 초과 + non-event snapshot 삭제 ──
# wu-transition 이벤트 snapshot 은 장기 보존 (squash 시점에 일괄 삭제)
find tmp/snapshots -mindepth 1 -maxdepth 1 -type d -mmin +1440 \
  ! -name "*wu-transition*" -exec rm -rf {} + 2>/dev/null || true
find /tmp/solon-snapshots-${SESSION} -mindepth 1 -maxdepth 1 -type d -mmin +1440 \
  ! -name "*wu-transition*" -exec rm -rf {} + 2>/dev/null || true

echo "[snapshot] ${STAMP} · trigger=${TRIGGER} · wu=${CURRENT_WU:-none}"
echo "  FUSE:  ${FUSE_SNAP_DIR}"
echo "  Local: ${LOCAL_SNAP_DIR}"
