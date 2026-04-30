#!/usr/bin/env bash
# .sfs-local/scripts/sfs-auth.sh
#
# Solon SFS — `/sfs auth` command implementation.
# Checks or bootstraps local Codex/Claude/Gemini executor auth before review.

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

: "${SFS_EXIT_BADCLI:=7}"
: "${SFS_EXIT_EXECUTOR:=9}"

usage_auth() {
  cat <<'EOF'
Usage: /sfs auth <status|check|login|probe|path> [--executor <codex|claude|gemini|all>] [--all] [--timeout <seconds>]

Manage local executor auth for CPO review bridges.
  - status    Print auth readiness. Default executor: all.
  - check     Same as status, but exits 9 if any selected executor is missing auth.
  - login     Run the selected executor's interactive CLI/browser login bootstrap.
              Requires --executor <codex|claude|gemini> or --all.
  - probe     Send one tiny dummy request to the selected executor and store
              stdout/stderr under .sfs-local/tmp/auth-probes/.
              Requires --executor <codex|claude|gemini>.
              Default timeout: 45 seconds.
  - path      Print the auth.env path SFS loads.

Examples:
  /sfs auth status
  /sfs auth login --executor gemini
  /sfs auth probe --executor gemini --timeout 20
  /sfs auth check --executor codex

Exit codes:
  0  success
  1  no .sfs-local/ (Solon not installed)
  7  unknown CLI flag or missing executor for login/probe
  9  executor auth missing or bootstrap failed
  99 unknown
EOF
}

ACTION="${1:-status}"
if [[ $# -gt 0 ]]; then
  shift
fi

EXECUTOR=""
ALL=false
PROBE_TIMEOUT="${SFS_AUTH_PROBE_TIMEOUT_SECONDS:-45}"

case "$ACTION" in
  -h|--help|help)
    usage_auth
    exit "${SFS_EXIT_OK}"
    ;;
  status|check|login|probe|path)
    ;;
  *)
    echo "unknown auth command: ${ACTION}" >&2
    usage_auth >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac

while [[ $# -gt 0 ]]; do
  case "$1" in
    --executor)
      if [[ $# -lt 2 ]]; then
        echo "--executor requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      EXECUTOR="$2"
      shift 2
      ;;
    --executor=*)
      EXECUTOR="${1#--executor=}"
      shift
      ;;
    --all)
      ALL=true
      shift
      ;;
    --timeout)
      if [[ $# -lt 2 ]]; then
        echo "--timeout requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      PROBE_TIMEOUT="$2"
      shift 2
      ;;
    --timeout=*)
      PROBE_TIMEOUT="${1#--timeout=}"
      shift
      ;;
    -h|--help)
      usage_auth
      exit "${SFS_EXIT_OK}"
      ;;
    --)
      shift
      if [[ $# -gt 0 ]]; then
        echo "unexpected extra args after --: $*" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      ;;
    -*)
      echo "unknown flag: $1" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
  esac
done

if ! printf '%s\n' "$PROBE_TIMEOUT" | grep -Eq '^[0-9]+$'; then
  echo "--timeout must be a positive integer" >&2
  exit "${SFS_EXIT_BADCLI}"
fi
if [[ "$PROBE_TIMEOUT" -lt 1 ]]; then
  echo "--timeout must be >= 1" >&2
  exit "${SFS_EXIT_BADCLI}"
fi

if [[ ! -d "${SFS_LOCAL_DIR}" ]]; then
  echo "no .sfs-local found, run install.sh first" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

if ! load_sfs_auth_env; then
  echo "executor auth env load failed: $(get_sfs_auth_env_file)" >&2
  exit "${SFS_EXIT_EXECUTOR}"
fi

normalize_selected_executors() {
  local selected="${1:-}" all="${2:-false}"
  if [[ "$all" == "true" || "$selected" == "all" || ( -z "$selected" && "$ACTION" != "login" ) ]]; then
    printf '%s\n' codex claude gemini
    return 0
  fi
  case "$(normalize_executor_profile "$selected")" in
    codex|claude|gemini)
      normalize_executor_profile "$selected"
      ;;
    *)
      echo "unknown executor: ${selected}" >&2
      return "${SFS_EXIT_BADCLI}"
      ;;
  esac
}

run_probe_command_with_timeout() {
  local cmd="$1" timeout="$2" prompt_path="$3" out_path="$4" err_path="$5" marker="$6"
  local pid elapsed

  set +m 2>/dev/null || true
  (
    # Replace the subshell with the executor so Solon can interrupt the process
    # when a CLI waits forever without returning a probe response.
    eval "exec ${cmd}" < "$prompt_path" > "$out_path" 2> "$err_path"
  ) &
  pid=$!
  elapsed=0

  while kill -0 "$pid" 2>/dev/null; do
    if [[ -n "$marker" && -f "$out_path" ]] && grep -q "$marker" "$out_path" 2>/dev/null; then
      disown "$pid" 2>/dev/null || true
      kill "$pid" 2>/dev/null || true
      sleep 1
      kill -9 "$pid" 2>/dev/null || true
      return 0
    fi
    if [[ "$elapsed" -ge "$timeout" ]]; then
      {
        printf '\nSFS auth probe timed out after %ss.\n' "$timeout"
        printf 'The executor process was interrupted by Solon.\n'
      } >> "$err_path"
      disown "$pid" 2>/dev/null || true
      kill "$pid" 2>/dev/null || true
      sleep 1
      kill -9 "$pid" 2>/dev/null || true
      return 124
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done

  wait "$pid"
}

AUTH_ENV_FILE_PATH="$(get_sfs_auth_env_file)"

case "$ACTION" in
  path)
    echo "$AUTH_ENV_FILE_PATH"
    exit "${SFS_EXIT_OK}"
    ;;
  login)
    if [[ "$ALL" != "true" && -z "$EXECUTOR" ]]; then
      echo "login requires --executor <codex|claude|gemini> or --all" >&2
      exit "${SFS_EXIT_BADCLI}"
    fi
    ;;
  probe)
    if [[ "$ALL" == "true" || -z "$EXECUTOR" || "$EXECUTOR" == "all" ]]; then
      echo "probe requires --executor <codex|claude|gemini>" >&2
      exit "${SFS_EXIT_BADCLI}"
    fi
    ;;
esac

set +e
SELECTED="$(normalize_selected_executors "$EXECUTOR" "$ALL")"
_select_rc=$?
set -e
if [[ "$_select_rc" -ne 0 ]]; then
  exit "$_select_rc"
fi

case "$ACTION" in
  status|check)
    echo "auth.env: ${AUTH_ENV_FILE_PATH}"
    missing=0
    while IFS= read -r profile; do
      [[ -z "$profile" ]] && continue
      if executor_auth_ready "$profile"; then
        printf '%s: ready\n' "$profile"
      else
        printf '%s: missing\n' "$profile"
        missing=1
      fi
    done <<EOF
${SELECTED}
EOF
    if [[ "$ACTION" == "check" && "$missing" -ne 0 ]]; then
      exit "${SFS_EXIT_EXECUTOR}"
    fi
    ;;
  login)
    while IFS= read -r profile; do
      [[ -z "$profile" ]] && continue
      echo "auth login: ${profile}"
      if ! bootstrap_executor_interactive_auth "$profile"; then
        echo "auth login failed: ${profile}" >&2
        exit "${SFS_EXIT_EXECUTOR}"
      fi
      printf '%s: ready\n' "$profile"
    done <<EOF
${SELECTED}
EOF
    ;;
  probe)
    profile="$(printf '%s\n' "$SELECTED" | sed -n '1p')"
    if ! prepare_executor_auth "$profile" "auto"; then
      exit "${SFS_EXIT_EXECUTOR}"
    fi
    PROBE_DIR="${SFS_LOCAL_DIR}/tmp/auth-probes"
    PROBE_TS="$(date -u +%Y%m%dT%H%M%SZ)"
    PROMPT_PATH="${PROBE_DIR}/${profile}-${PROBE_TS}.prompt.txt"
    OUT_PATH="${PROBE_DIR}/${profile}-${PROBE_TS}.stdout.txt"
    ERR_PATH="${PROBE_DIR}/${profile}-${PROBE_TS}.stderr.txt"
    mkdir -p "$PROBE_DIR"
    cat > "$PROMPT_PATH" <<EOF
Solon SFS executor bridge probe.
Return exactly:
SFS_AUTH_PROBE_OK ${profile}
EOF
    case "$profile" in
      codex)  PROBE_CMD="${SFS_REVIEW_CODEX_CMD:-codex exec --full-auto}" ;;
      claude) PROBE_CMD="${SFS_REVIEW_CLAUDE_CMD:-claude -p --dangerously-skip-permissions}" ;;
      gemini) PROBE_CMD="${SFS_REVIEW_GEMINI_CMD:-gemini --skip-trust --output-format text -p \"Return exactly: SFS_AUTH_PROBE_OK ${profile}\"}" ;;
      *)
        echo "unknown executor: ${profile}" >&2
        exit "${SFS_EXIT_BADCLI}"
        ;;
    esac
    echo "auth probe running: ${profile}"
    echo "  stdout: ${OUT_PATH}"
    echo "  stderr: ${ERR_PATH}"
    echo "  prompt: ${PROMPT_PATH}"
    echo "  timeout: ${PROBE_TIMEOUT}s"
    set +e
    run_probe_command_with_timeout "$PROBE_CMD" "$PROBE_TIMEOUT" "$PROMPT_PATH" "$OUT_PATH" "$ERR_PATH" "SFS_AUTH_PROBE_OK"
    rc=$?
    set -e
    if [[ "$rc" -ne 0 ]]; then
      echo "auth probe failed: ${profile} (exit ${rc}); see ${ERR_PATH}" >&2
      exit "${SFS_EXIT_EXECUTOR}"
    fi
    if ! grep -q "SFS_AUTH_PROBE_OK" "$OUT_PATH"; then
      echo "auth probe failed: ${profile}; expected SFS_AUTH_PROBE_OK in ${OUT_PATH}" >&2
      exit "${SFS_EXIT_EXECUTOR}"
    fi
    echo "auth probe complete: ${profile} | output ${OUT_PATH}"
    ;;
esac

exit "${SFS_EXIT_OK}"
# End of sfs-auth.sh
