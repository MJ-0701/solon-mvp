#!/usr/bin/env bash
# .sfs-local/scripts/sfs-guide.sh
#
# Solon SFS — `/sfs guide` command implementation.
#
# Output (default):
#   short context briefing + next commands + guide path
#
# Flags:
#   --path   print only the guide path
#   --print  print full guide contents to stdout
#
# Exit codes:
#   0  success
#   1  no .sfs-local/ (Solon not installed)
#   4  guide document missing
#   99 unknown (CLI args, etc.)

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

usage_guide() {
  cat <<'EOF'
Usage: /sfs guide [--path|--print]

Show the Solon Product onboarding guide installed with this project.
  - Default: prints a short context briefing for first use.
  - --path: prints only the guide path.
  - --print: prints the full guide contents.

Exit codes:
  0  success
  1  no .sfs-local/ (Solon not installed)
  4  guide document missing
  99 unknown (CLI args, etc.)
EOF
}

MODE="ready"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path)
      MODE="path"
      shift
      ;;
    --print)
      MODE="print"
      shift
      ;;
    -h|--help)
      usage_guide
      exit "${SFS_EXIT_OK}"
      ;;
    --)
      shift
      if [[ $# -gt 0 ]]; then
        echo "unexpected extra args after --: $*" >&2
        exit "${SFS_EXIT_UNKNOWN}"
      fi
      ;;
    -*)
      echo "unknown flag: $1" >&2
      exit "${SFS_EXIT_UNKNOWN}"
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit "${SFS_EXIT_UNKNOWN}"
      ;;
  esac
done

if [[ ! -d "${SFS_LOCAL_DIR}" ]]; then
  echo "no .sfs-local found, run install.sh first" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

GUIDE_PATH="${SFS_LOCAL_DIR}/GUIDE.md"
if [[ ! -f "${GUIDE_PATH}" && -f "GUIDE.md" ]]; then
  GUIDE_PATH="GUIDE.md"
fi

if [[ ! -f "${GUIDE_PATH}" ]]; then
  echo "guide missing: ${SFS_LOCAL_DIR}/GUIDE.md" >&2
  exit "${SFS_EXIT_NO_TEMPLATES}"
fi

case "${MODE}" in
  ready)
    cat <<EOF
Solon guide context

이게 뭐야:
  Solon 은 이 repo 안에 sprint, decision, review, retro, handoff 상태를 남겨서
  AI 와 제품 작업할 때 맥락이 사라지지 않게 해 주는 가벼운 운영 레이어야.

처음 볼 파일:
  SFS.md        프로젝트 이름, 도메인, stack, DB, 배포 환경
  CLAUDE.md     Claude Code 에게 알려줄 프로젝트별 맥락
  AGENTS.md     Codex 에게 알려줄 프로젝트별 맥락
  GEMINI.md     Gemini CLI 에게 알려줄 프로젝트별 맥락

첫 흐름:
  /sfs status
  /sfs start "<이번 sprint 목표>"
  /sfs plan

작업 중:
  /sfs decision "<결정 제목>"   결정이 흐려지기 전에 기록
  /sfs review --gate G2        구현/기획 검토 evidence 남기기
  /sfs retro --close           sprint close + local auto-commit

전체 가이드:
  /sfs guide --print
  path: ${GUIDE_PATH}
EOF
    ;;
  path)
    echo "${GUIDE_PATH}"
    ;;
  print)
    cat "${GUIDE_PATH}"
    ;;
esac

exit "${SFS_EXIT_OK}"
# End of sfs-guide.sh
