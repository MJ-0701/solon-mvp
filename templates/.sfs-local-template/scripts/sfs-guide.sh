#!/usr/bin/env bash
# .sfs-local/scripts/sfs-guide.sh
#
# Solon SFS — `/sfs guide` command implementation.
#
# Output (default, one line):
#   guide.md ready: <path>
#
# Flags:
#   --path   print only the guide path
#   --print  print guide contents to stdout
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
  - Default: prints the guide path.
  - --path: prints only the guide path.
  - --print: prints the guide contents.

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
    echo "guide.md ready: ${GUIDE_PATH}"
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
