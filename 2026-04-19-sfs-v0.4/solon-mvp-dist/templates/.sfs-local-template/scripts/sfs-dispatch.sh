#!/usr/bin/env bash
# .sfs-local/scripts/sfs-dispatch.sh
#
# Solon SFS — runtime adaptor compatibility layer.
# Normalizes public/runtime command surfaces (`/sfs`, `$sfs`, `sfs`) and
# dispatches to the deterministic bash adapter SSoT (`sfs-<command>.sh`).

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SFS_EXIT_NO_TEMPLATES=4
SFS_EXIT_USAGE=7
SFS_EXIT_UNKNOWN=99

usage() {
  cat <<'EOF'
Usage: /sfs <command> [args]
Commands: status, start, guide, auth, division, adopt, brainstorm, plan, implement, review, decision, report, tidy, retro, commit, loop
Help: bash .sfs-local/scripts/sfs-<command>.sh --help
EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

case "${1:-}" in
  /sfs|sfs|\$sfs)
    shift
    ;;
esac

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

cmd="$1"
shift

case "${cmd}" in
  help|-h|--help)
    usage
    exit 0
    ;;
  status|start|guide|auth|division|adopt|brainstorm|plan|implement|review|decision|report|tidy|retro|commit|loop)
    target="${SFS_SCRIPT_DIR}/sfs-${cmd}.sh"
    ;;
  *)
    echo "unknown command: ${cmd}" >&2
    usage >&2
    exit "${SFS_EXIT_USAGE}"
    ;;
esac

if [[ ! -f "${target}" ]]; then
  echo "missing adapter: ${target}" >&2
  exit "${SFS_EXIT_NO_TEMPLATES}"
fi

if [[ ! -x "${target}" ]]; then
  echo "adapter not executable: ${target}" >&2
  exit "${SFS_EXIT_NO_TEMPLATES}"
fi

for arg in "$@"; do
  if [[ "${cmd}" != "brainstorm" && "${arg}" == *$'\n'* ]]; then
    echo "unknown arg: newline not allowed" >&2
    exit "${SFS_EXIT_UNKNOWN}"
  fi
done

exec bash "${target}" "$@"
