#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────
# Solon v0.4-r3 · scripts/squash-wu.sh
# 목적: WU 완료 시 해당 WU 의 wip 커밋들을 interactive rebase 로 squash.
# 규칙: CLAUDE.md §8 (커밋 규율) · tmp/workflow-v2-design.md §4
#   - wip: `wip(WU-<id>/step-<n>/<tag>): <요약>`
#   - final: `WU-<id>: <제목>` (squash 결과 1개)
#   - refresh (WU-<id>.1): squash 대상 **아님** — 독립 유지
# FUSE bypass: .git/index.lock 경합 시 자동으로 /tmp/solon-git-<ts>/
#              에 .git 복사 → rebase → rsync back.
# Usage: ./scripts/squash-wu.sh <WU-id> [--dry-run]
#   ex: ./scripts/squash-wu.sh WU-15
#       ./scripts/squash-wu.sh WU-15 --dry-run
# ────────────────────────────────────────────────────────────────
set -euo pipefail

WU_ID="${1:-}"
DRY_RUN=false
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=true

if [[ -z "${WU_ID}" ]]; then
  echo "ERROR: WU id required. usage: $0 <WU-id> [--dry-run]" >&2
  exit 2
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

# ── wip 커밋 탐색 ──
WIP_PATTERN="^wip(${WU_ID}/"
# `git log` 로 해당 WU 의 wip 커밋 범위 찾기 (가장 오래된 wip 커밋의 부모부터)
WIP_SHAS=$(git log --format='%H %s' main | awk -v p="wip(${WU_ID}/" '$0 ~ p {print $1}')

if [[ -z "${WIP_SHAS}" ]]; then
  echo "[squash-wu] ${WU_ID} 에 해당하는 wip 커밋 없음. 스킵."
  exit 0
fi

WIP_COUNT=$(echo "${WIP_SHAS}" | wc -l | tr -d '[:space:]')
OLDEST_WIP=$(echo "${WIP_SHAS}" | tail -1)
OLDEST_WIP_PARENT=$(git rev-parse "${OLDEST_WIP}^")

echo "[squash-wu] ${WU_ID}: wip 커밋 ${WIP_COUNT} 개 감지"
echo "  범위: ${OLDEST_WIP_PARENT}..HEAD"
git log --oneline "${OLDEST_WIP_PARENT}..HEAD"

if [[ "${DRY_RUN}" == "true" ]]; then
  echo "[squash-wu] --dry-run — 실제 rebase 생략. 위 범위를 squash 할 예정."
  exit 0
fi

# ── FUSE bypass 자동 적용 ──
# .git/index.lock 경합 시 /tmp/solon-git-<ts>/ 에 .git 복사 → 작업 → rsync back
if [[ -e .git/index.lock ]]; then
  echo "[squash-wu] .git/index.lock 감지 → FUSE bypass 모드 진입"
  TS=$(date -u +"%Y%m%dT%H%M%S")
  TMP_GIT="/tmp/solon-git-${TS}"
  cp -a .git "${TMP_GIT}"
  ORIGINAL_GIT_DIR=".git"
  export GIT_DIR="${TMP_GIT}"
  FUSE_BYPASS=true
else
  FUSE_BYPASS=false
fi

# ── 사용자 확인 ──
echo ""
echo "⚠️  Interactive rebase 진행 예정. 에디터가 열리면 ${WU_ID} 의 wip 커밋들을"
echo "   모두 'squash' (또는 'fixup') 로 변경한 뒤 저장/종료하세요."
echo "   최종 커밋 메시지는 'WU-${WU_ID}: <제목>' 패턴 권장 (CLAUDE.md §8)."
echo ""
read -rp "진행? [y/N] " CONFIRM
if [[ ! "${CONFIRM}" =~ ^[Yy]$ ]]; then
  echo "[squash-wu] 중단."
  [[ "${FUSE_BYPASS}" == "true" ]] && unset GIT_DIR && rm -rf "${TMP_GIT}"
  exit 1
fi

git rebase -i "${OLDEST_WIP_PARENT}"

# ── FUSE bypass 복귀: rsync back ──
if [[ "${FUSE_BYPASS}" == "true" ]]; then
  echo "[squash-wu] rebase 완료 → rsync back → .git 복귀"
  unset GIT_DIR
  rsync -a --delete "${TMP_GIT}/" "${ORIGINAL_GIT_DIR}/"
  rm -rf "${TMP_GIT}"
fi

echo "[squash-wu] ${WU_ID} squash 완료. git log 확인:"
git log --oneline -5
echo ""
echo "다음 단계:"
echo "  1. WU 파일 (sprints/${WU_ID}.md) frontmatter 에 final_sha 반영"
echo "  2. PROGRESS.md ① Just-Finished 에 squash 완료 기록"
echo "  3. 필요 시 WU-<id>.1 refresh 커밋으로 sha backfill"
echo "  4. git push 는 **사용자 터미널에서만** (CLAUDE.md §1.5)"
