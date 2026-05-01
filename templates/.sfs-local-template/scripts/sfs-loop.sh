#!/usr/bin/env bash
# .sfs-local/scripts/sfs-loop.sh
#
# Solon SFS — `/sfs loop` command implementation (Ralph Loop + Solon mutex
# + Solon-wide executor convention). 7번째 명령 (WU-23 §1 6 명령 contract
# + WU-27 추가).
#
# Spec source:
#   sprints/WU-27.md (main: §0 + §1.1~1.3 + §3.1 + 분할 plan)
#   sprints/WU-27/sfs-loop-flow.md (§2 비교 + §3 인자 + §4 12-step pseudo-flow + §5 exit codes)
#   sprints/WU-27/sfs-loop-locking.md (§6.5 Optimistic Lock + 4-state FSM)
#   sprints/WU-27/sfs-loop-review-gate.md (§6.6 PLANNER+EVALUATOR persona)
#   sprints/WU-27/sfs-loop-multi-worker.md (§6.0 Worker Independence + §6.4 spawn)
#
# Path note: dev staging file lives at
#   solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh
# install.sh copies templates/.sfs-local-template/ → consumer project's .sfs-local/.
#
# Visibility: business-only (solon-mvp-dist staging asset).
# Created: 2026-04-29 (25th cycle session optimistic-vigilant-bell sub-task 6.1).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$SCRIPT_DIR/sfs-common.sh"

# ─────────────────────────────────────────────────────────────────────
# EXIT CODES (sfs-loop-flow.md §5 verbatim)
# ─────────────────────────────────────────────────────────────────────
SFS_LOOP_EXIT_OK=0                       # 정상 종료
SFS_LOOP_EXIT_BADCLI=1                   # invalid usage
SFS_LOOP_EXIT_PROGRESS_PARSE=2           # PROGRESS.md frontmatter 파싱 실패
SFS_LOOP_EXIT_DRIFT=3                    # resume-session-check exit 16
SFS_LOOP_EXIT_MUTEX=4                    # mutex claim 실패
SFS_LOOP_EXIT_SAFETY_LOCK=5              # safety_lock trip
SFS_LOOP_EXIT_SPEC_MISSING=6             # WU spec 누락 / 손상
SFS_LOOP_EXIT_VERIFY_FAIL=7              # 산출물 verify 실패
SFS_LOOP_EXIT_HEARTBEAT_FAIL=8           # PROGRESS heartbeat 쓰기 실패 (FUSE lock 등)
SFS_LOOP_EXIT_EXECUTOR_FAIL=9            # executor resolve 실패
SFS_LOOP_EXIT_UNKNOWN=99                 # bug

if ! load_sfs_auth_env; then
  echo "loop: executor auth env load failed: ${SFS_AUTH_ENV_FILE:-${SFS_LOCAL_DIR}/auth.env}" >&2
  exit "$SFS_LOOP_EXIT_EXECUTOR_FAIL"
fi

# ─────────────────────────────────────────────────────────────────────
# DEFAULTS (sfs-loop-flow.md §3.2 inflation table)
# ─────────────────────────────────────────────────────────────────────
LOOP_MODE="${LOOP_MODE:-user-active-deferred}"
LOOP_EXECUTOR="${SFS_EXECUTOR:-claude}"
LOOP_DOMAIN_FILTER=""
LOOP_PRIORITY_MIN=1
LOOP_PRIORITY_MAX=10
LOOP_MAX_ITERS=5
LOOP_MAX_WALL_MIN=30
LOOP_TTL_MIN=30
LOOP_MICRO_STEPS_PER_ITER=1
LOOP_RELEASE_BETWEEN=true
LOOP_EXCLUSIVE=false
LOOP_DRY_RUN=false
LOOP_ESCALATE_ON=""
LOOP_OWNER=""
LOOP_REPORT_FORMAT="text"

# Multi-worker (sub-task 5 spec)
LOOP_PARALLEL=1
LOOP_WORKER_ID=""
LOOP_AUTO_CODENAME=true
LOOP_COORD_ONLY=false
LOOP_WORKER_PREFER_MODE=""
LOOP_WORKER_DOMAIN_PIN=""
LOOP_ISOLATION="process"
LOOP_NO_MENTAL_COUPLING=true

# Review gate (sub-task 6.6)
LOOP_REVIEW_GATE=true
LOOP_PLAN_DOC=""
LOOP_PERSONA_DIR="agents"
LOOP_QUEUE_TITLE=""
LOOP_QUEUE_CLAIMED_PATH=""
LOOP_QUEUE_TARGET=""
LOOP_QUEUE_SIZE="medium"
LOOP_QUEUE_TARGET_MINUTES=45

# Internal (sub-cmd dispatch)
LOOP_SUBCMD=""

# ─────────────────────────────────────────────────────────────────────
# USAGE
# ─────────────────────────────────────────────────────────────────────
usage_loop() {
  cat <<'EOF'
Usage:
  /sfs loop [OPTIONS]                  Run loop iterations (default sub-cmd).
  /sfs loop queue                      Show queue counts.
  /sfs loop enqueue <title> [OPTIONS]  Add a pending queue task.
  /sfs loop claim [OPTIONS]            Claim the next pending queue task.
  /sfs loop complete <task-id-or-path>  Move a claimed queue task to done/.
  /sfs loop fail <task-id-or-path>      Move a claimed queue task to failed/.
  /sfs loop retry <task-id-or-path>     Move a failed/claimed task back to pending/.
  /sfs loop abandon <task-id-or-path>   Move a queue task to abandoned/.
  /sfs loop verify <task-id-or-path>    Run task Verify commands, then done/failed.
  /sfs loop status                     Show status of currently running loop.
  /sfs loop stop                       Stop the running loop, release mutex.
  /sfs loop replay <task-log-id>       Replay a past scheduled_task_log entry.

Core OPTIONS:
  --mode <user-active|scheduled|user-active-deferred>
                                       resume_hint default_action mode (default: user-active-deferred)
  --executor <profile|cmd>             LLM executor (claude|gemini|codex|<custom>) (default: claude / $SFS_EXECUTOR)
  --domain-filter <D-X,D-Y,...>        Comma-separated domain whitelist
  --priority-min <N>                   Lowest priority (default 1)
  --priority-max <N>                   Highest priority (default 10)
  --max-iters <N>                      Max iterations (default 5; Ralph Loop infinite cap)
  --max-wall-min <N>                   Max wall-clock minutes (default 30)
  --ttl-min <N>                        Per-iter mutex TTL (default 30)
  --micro-steps-per-iter <N>           Micro-steps per iteration (default 1)
  --release-between                    Release owner between iters (default true)
  --exclusive                          Hold owner across iters (overrides --release-between)
  --dry-run                            Print plan only, claim nothing
  --escalate-on <safety-lock-id,...>   Specific safety_locks to escalate on
  --owner <codename>                   Mutex owner override (default: basename of /sessions/<x>/)
  --report-format <text|json|status-line>
                                       Per-iter report format (default text)

Queue OPTIONS:
  --size <small|medium|large>          Queue task size (default medium)
  --target-minutes <N>                 Expected work minutes (default 45)

Multi-worker OPTIONS (sub-task 5):
  --parallel <N>                       Spawn N workers (default 1)
  --worker-id <X>                      Override worker mutex owner
  --auto-codename                      Auto-generate adjective-adjective-surname (default when parallel>1)
  --coord-only                         Coordinator only (spawn N workers + wait + aggregate)
  --worker-prefer-mode <X>             Per-worker prefer_mode override
  --worker-domain-pin <D-X>            Pin worker to specific domain (⚠️ mental coupling, escalates)
  --isolation <process|claude-instance|sub-session>
                                       Worker isolation mode (default process)
  --no-mental-coupling                 Enforce Worker Independence Invariant (default true)

Exit codes:
  0  success (max-iters / all-domains-closed / max-wall reached)
  1  invalid usage
  2  PROGRESS.md frontmatter parse error
  3  drift detected (resume-session-check exit 16)
  4  mutex claim failed
  5  safety_lock tripped
  6  WU spec file missing / corrupt
  7  artifact verify failed
  8  heartbeat write failed (FUSE lock?)
  9  executor resolve failed
  99 unknown internal error

Spec: sprints/WU-27.md + sprints/WU-27/sfs-loop-{flow,locking,review-gate,multi-worker}.md
EOF
}

# ─────────────────────────────────────────────────────────────────────
# ARG PARSING
# ─────────────────────────────────────────────────────────────────────
parse_args() {
  # Sub-command detection (first non-option positional).
  while [[ $# -gt 0 ]]; do
    case "$1" in
      # Sub-commands
      status|stop|replay|queue|claim)
        LOOP_SUBCMD="$1"
        shift
        # `replay` consumes one positional (task-log-id)
        if [[ "$LOOP_SUBCMD" == "replay" ]]; then
          if [[ $# -lt 1 ]]; then
            echo "loop replay: missing <task-log-id>" >&2
            exit "$SFS_LOOP_EXIT_BADCLI"
          fi
          LOOP_REPLAY_ID="$1"
          shift
        fi
        ;;
      enqueue)
        LOOP_SUBCMD="$1"
        shift
        if [[ $# -lt 1 ]]; then
          echo "loop enqueue: missing <title>" >&2
          exit "$SFS_LOOP_EXIT_BADCLI"
        fi
        LOOP_QUEUE_TITLE="$1"
        shift
        ;;
      complete|fail|retry|abandon|verify)
        LOOP_SUBCMD="$1"
        shift
        if [[ $# -lt 1 ]]; then
          echo "loop $LOOP_SUBCMD: missing <task-id-or-path>" >&2
          exit "$SFS_LOOP_EXIT_BADCLI"
        fi
        LOOP_QUEUE_TARGET="$1"
        shift
        ;;

      # Core options
      --mode)              LOOP_MODE="$2"; shift 2 ;;
      --mode=*)            LOOP_MODE="${1#*=}"; shift ;;
      --executor)          LOOP_EXECUTOR="$2"; shift 2 ;;
      --executor=*)        LOOP_EXECUTOR="${1#*=}"; shift ;;
      --domain-filter)     LOOP_DOMAIN_FILTER="$2"; shift 2 ;;
      --domain-filter=*)   LOOP_DOMAIN_FILTER="${1#*=}"; shift ;;
      --priority-min)      LOOP_PRIORITY_MIN="$2"; shift 2 ;;
      --priority-min=*)    LOOP_PRIORITY_MIN="${1#*=}"; shift ;;
      --priority-max)      LOOP_PRIORITY_MAX="$2"; shift 2 ;;
      --priority-max=*)    LOOP_PRIORITY_MAX="${1#*=}"; shift ;;
      --max-iters)         LOOP_MAX_ITERS="$2"; shift 2 ;;
      --max-iters=*)       LOOP_MAX_ITERS="${1#*=}"; shift ;;
      --max-wall-min)      LOOP_MAX_WALL_MIN="$2"; shift 2 ;;
      --max-wall-min=*)    LOOP_MAX_WALL_MIN="${1#*=}"; shift ;;
      --ttl-min)           LOOP_TTL_MIN="$2"; shift 2 ;;
      --ttl-min=*)         LOOP_TTL_MIN="${1#*=}"; shift ;;
      --micro-steps-per-iter)   LOOP_MICRO_STEPS_PER_ITER="$2"; shift 2 ;;
      --micro-steps-per-iter=*) LOOP_MICRO_STEPS_PER_ITER="${1#*=}"; shift ;;
      --release-between)   LOOP_RELEASE_BETWEEN=true;  shift ;;
      --no-release-between) LOOP_RELEASE_BETWEEN=false; shift ;;
      --exclusive)         LOOP_EXCLUSIVE=true; LOOP_RELEASE_BETWEEN=false; shift ;;
      --dry-run)           LOOP_DRY_RUN=true; shift ;;
      --escalate-on)       LOOP_ESCALATE_ON="$2"; shift 2 ;;
      --escalate-on=*)     LOOP_ESCALATE_ON="${1#*=}"; shift ;;
      --owner)             LOOP_OWNER="$2"; shift 2 ;;
      --owner=*)           LOOP_OWNER="${1#*=}"; shift ;;
      --report-format)     LOOP_REPORT_FORMAT="$2"; shift 2 ;;
      --report-format=*)   LOOP_REPORT_FORMAT="${1#*=}"; shift ;;
      --size)              LOOP_QUEUE_SIZE="$2"; shift 2 ;;
      --size=*)            LOOP_QUEUE_SIZE="${1#*=}"; shift ;;
      --target-minutes)    LOOP_QUEUE_TARGET_MINUTES="$2"; shift 2 ;;
      --target-minutes=*)  LOOP_QUEUE_TARGET_MINUTES="${1#*=}"; shift ;;

      # Multi-worker options
      --parallel)          LOOP_PARALLEL="$2"; shift 2 ;;
      --parallel=*)        LOOP_PARALLEL="${1#*=}"; shift ;;
      --worker-id)         LOOP_WORKER_ID="$2"; shift 2 ;;
      --worker-id=*)       LOOP_WORKER_ID="${1#*=}"; shift ;;
      --auto-codename)     LOOP_AUTO_CODENAME=true; shift ;;
      --no-auto-codename)  LOOP_AUTO_CODENAME=false; shift ;;
      --coord-only)        LOOP_COORD_ONLY=true; shift ;;
      --worker-prefer-mode)   LOOP_WORKER_PREFER_MODE="$2"; shift 2 ;;
      --worker-prefer-mode=*) LOOP_WORKER_PREFER_MODE="${1#*=}"; shift ;;
      --worker-domain-pin)    LOOP_WORKER_DOMAIN_PIN="$2"; shift 2 ;;
      --worker-domain-pin=*)  LOOP_WORKER_DOMAIN_PIN="${1#*=}"; shift ;;
      --isolation)         LOOP_ISOLATION="$2"; shift 2 ;;
      --isolation=*)       LOOP_ISOLATION="${1#*=}"; shift ;;
      --no-mental-coupling)    LOOP_NO_MENTAL_COUPLING=true;  shift ;;
      --allow-mental-coupling) LOOP_NO_MENTAL_COUPLING=false; shift ;;

      # Review gate options (sub-task 6.6)
      --no-review-gate)    LOOP_REVIEW_GATE=false; shift ;;
      --review-gate)       LOOP_REVIEW_GATE=true;  shift ;;
      --plan-doc)          LOOP_PLAN_DOC="$2"; shift 2 ;;
      --plan-doc=*)        LOOP_PLAN_DOC="${1#*=}"; shift ;;
      --persona-dir)       LOOP_PERSONA_DIR="$2"; shift 2 ;;
      --persona-dir=*)     LOOP_PERSONA_DIR="${1#*=}"; shift ;;

      # Help
      -h|--help)
        usage_loop
        exit "$SFS_LOOP_EXIT_OK"
        ;;

      # Unknown
      --*)
        echo "loop: unknown option: $1" >&2
        usage_loop >&2
        exit "$SFS_LOOP_EXIT_BADCLI"
        ;;

      *)
        echo "loop: unexpected positional argument: $1" >&2
        usage_loop >&2
        exit "$SFS_LOOP_EXIT_BADCLI"
        ;;
    esac
  done
}

# ─────────────────────────────────────────────────────────────────────
# ARG VALIDATION (post-parse)
# ─────────────────────────────────────────────────────────────────────
validate_args() {
  # Mode enum
  case "$LOOP_MODE" in
    user-active|scheduled|user-active-deferred) ;;
    *)
      echo "loop: invalid --mode '$LOOP_MODE' (expected user-active|scheduled|user-active-deferred)" >&2
      exit "$SFS_LOOP_EXIT_BADCLI"
      ;;
  esac

  # Numeric ranges
  if ! [[ "$LOOP_MAX_ITERS" =~ ^[1-9][0-9]*$ ]]; then
    echo "loop: --max-iters must be positive integer (got '$LOOP_MAX_ITERS')" >&2
    exit "$SFS_LOOP_EXIT_BADCLI"
  fi
  if ! [[ "$LOOP_MAX_WALL_MIN" =~ ^[1-9][0-9]*$ ]]; then
    echo "loop: --max-wall-min must be positive integer (got '$LOOP_MAX_WALL_MIN')" >&2
    exit "$SFS_LOOP_EXIT_BADCLI"
  fi
  if ! [[ "$LOOP_TTL_MIN" =~ ^[1-9][0-9]*$ ]]; then
    echo "loop: --ttl-min must be positive integer (got '$LOOP_TTL_MIN')" >&2
    exit "$SFS_LOOP_EXIT_BADCLI"
  fi
  if ! [[ "$LOOP_MICRO_STEPS_PER_ITER" =~ ^[1-9][0-9]*$ ]]; then
    echo "loop: --micro-steps-per-iter must be positive integer" >&2
    exit "$SFS_LOOP_EXIT_BADCLI"
  fi
  if ! [[ "$LOOP_PARALLEL" =~ ^[1-9][0-9]*$ ]]; then
    echo "loop: --parallel must be positive integer" >&2
    exit "$SFS_LOOP_EXIT_BADCLI"
  fi
  if ! [[ "$LOOP_PRIORITY_MIN" =~ ^[1-9]|10$ ]]; then
    : # 1 자리 또는 10 만 허용 (1-10 범위)
  fi

  # Mutual exclusion: --exclusive overrides --release-between (already handled in parser)
  # Coord-only requires --parallel >= 2
  if [[ "$LOOP_COORD_ONLY" == "true" ]] && (( LOOP_PARALLEL < 2 )); then
    echo "loop: --coord-only requires --parallel >= 2 (got $LOOP_PARALLEL)" >&2
    exit "$SFS_LOOP_EXIT_BADCLI"
  fi

  # Auto-codename default = true when parallel > 1
  if (( LOOP_PARALLEL > 1 )) && [[ -z "$LOOP_WORKER_ID" ]]; then
    LOOP_AUTO_CODENAME=true
  fi

  # Isolation enum
  case "$LOOP_ISOLATION" in
    process|claude-instance|sub-session) ;;
    *)
      echo "loop: invalid --isolation '$LOOP_ISOLATION'" >&2
      exit "$SFS_LOOP_EXIT_BADCLI"
      ;;
  esac

  # Report format enum
  case "$LOOP_REPORT_FORMAT" in
    text|json|status-line) ;;
    *)
      echo "loop: invalid --report-format '$LOOP_REPORT_FORMAT'" >&2
      exit "$SFS_LOOP_EXIT_BADCLI"
      ;;
  esac

  case "$LOOP_QUEUE_SIZE" in
    small|medium|large) ;;
    *)
      echo "loop: invalid --size '$LOOP_QUEUE_SIZE' (expected small|medium|large)" >&2
      exit "$SFS_LOOP_EXIT_BADCLI"
      ;;
  esac
  if ! [[ "$LOOP_QUEUE_TARGET_MINUTES" =~ ^[1-9][0-9]*$ ]]; then
    echo "loop: --target-minutes must be positive integer (got '$LOOP_QUEUE_TARGET_MINUTES')" >&2
    exit "$SFS_LOOP_EXIT_BADCLI"
  fi

  # Owner default = self codename (basename of /sessions/<x>/, fallback hostname)
  if [[ -z "$LOOP_OWNER" ]]; then
    if [[ -d /sessions ]]; then
      LOOP_OWNER="$(ls /sessions 2>/dev/null | head -1 || echo "unknown-session")"
    else
      LOOP_OWNER="$(hostname -s 2>/dev/null || echo "unknown")"
    fi
  fi
}

# ─────────────────────────────────────────────────────────────────────
# MAIN DISPATCH (sub-task 6.2~6.6 가 채움)
# ─────────────────────────────────────────────────────────────────────
main() {
  parse_args "$@"
  validate_args

  # Sub-cmd dispatch
  case "$LOOP_SUBCMD" in
    status)
      cmd_loop_status   # 후속 sub-task 6.4 (iter loop core)
      ;;
    queue)
      cmd_loop_queue
      ;;
    enqueue)
      cmd_loop_enqueue "$LOOP_QUEUE_TITLE"
      ;;
    claim)
      cmd_loop_claim
      ;;
    complete)
      cmd_loop_complete "$LOOP_QUEUE_TARGET"
      ;;
    fail)
      cmd_loop_fail "$LOOP_QUEUE_TARGET"
      ;;
    retry)
      cmd_loop_retry "$LOOP_QUEUE_TARGET"
      ;;
    abandon)
      cmd_loop_abandon "$LOOP_QUEUE_TARGET"
      ;;
    verify)
      cmd_loop_verify "$LOOP_QUEUE_TARGET"
      ;;
    stop)
      cmd_loop_stop     # 후속 sub-task 6.4
      ;;
    replay)
      cmd_loop_replay "$LOOP_REPLAY_ID"   # 후속 sub-task 6.4
      ;;
    "")
      # Default = main loop. parallel >1 or coord-only → coordinator path (sub-task 6.5).
      if (( LOOP_PARALLEL > 1 )) || [[ "$LOOP_COORD_ONLY" == "true" ]]; then
        cmd_loop_coord
      else
        cmd_loop_run
      fi
      ;;
    *)
      echo "loop: unknown subcommand: $LOOP_SUBCMD" >&2
      exit "$SFS_LOOP_EXIT_BADCLI"
      ;;
  esac
}

# ─────────────────────────────────────────────────────────────────────
# INTERNAL HELPERS (sub-task 6.4)
# ─────────────────────────────────────────────────────────────────────

# _pick_domain — sweep PROGRESS.md domain_locks, pick highest-priority unowned domain.
# Args: $1 = progress_path
# Filters: --domain-filter (LOOP_DOMAIN_FILTER), --priority-min/max, --mode (prefer_mode match)
# stdout: domain id or empty
# rc: 0=picked, 1=none eligible
_pick_domain() {
  local progress_path="$1"
  local filter="$LOOP_DOMAIN_FILTER"
  local pmin="$LOOP_PRIORITY_MIN" pmax="$LOOP_PRIORITY_MAX"
  local mode="$LOOP_MODE"
  if ! command -v python3 >/dev/null 2>&1; then
    echo "_pick_domain: python3 required" >&2
    return 99
  fi
  python3 - "$progress_path" "$filter" "$pmin" "$pmax" "$mode" <<'PYEOF'
import sys, re
path, flt, pmin, pmax, mode = sys.argv[1:6]
pmin = int(pmin); pmax = int(pmax)
flt_set = set(x.strip() for x in flt.split(',') if x.strip()) if flt else None
with open(path) as f:
    content = f.read()
m = re.search(r'^---\n(.*?)\n---', content, re.DOTALL)
if not m:
    sys.exit(1)
fm = m.group(1)
# Find domain_locks block
dl = re.search(r'^domain_locks:\s*\n((?:[ \t]+.*\n?)+)', fm, re.MULTILINE)
if not dl:
    sys.exit(1)
body = dl.group(1)
# Domain entries: indented N spaces, key: \n followed by deeper indent fields
candidates = []
cur_dom = None; cur_fields = {}
def flush():
    if cur_dom:
        candidates.append((cur_dom, dict(cur_fields)))
for line in body.splitlines():
    if not line.strip():
        continue
    m1 = re.match(r'^(\s+)([\w-]+):\s*(.*)$', line)
    if not m1:
        continue
    indent, key, val = m1.group(1), m1.group(2), m1.group(3).strip()
    # Strip comment
    val = re.sub(r'\s*#.*$', '', val).strip()
    # Domain entry = 2-space indent (top-level under domain_locks)
    if len(indent) == 2:
        flush()
        cur_dom = key
        cur_fields = {}
    elif cur_dom:
        cur_fields[key] = val
flush()
# Filter + sort
def eligible(d, f):
    name = d
    if flt_set and name not in flt_set:
        return False
    owner = f.get('owner', '')
    if owner and owner not in ('null', '~', ''):
        return False
    status = f.get('status', '')
    if status in ('COMPLETE', 'ABANDONED'):
        # check priority — closed lifecycle low pri (8), but skip
        return False
    pr = f.get('priority', '0')
    try:
        pr_i = int(pr)
    except:
        pr_i = 0
    if pr_i < pmin or pr_i > pmax:
        return False
    pmode = f.get('prefer_mode', '')
    # mode filter: scheduled mode skips user-active-only domains
    if mode == 'scheduled' and pmode == 'user-active-only':
        return False
    return True
elig = [(d, f) for d, f in candidates if eligible(d, f)]
if not elig:
    sys.exit(1)
# Sort by priority asc (1 = highest), then by name asc for determinism
elig.sort(key=lambda x: (int(x[1].get('priority', '99')), x[0]))
print(elig[0][0])
PYEOF
}

# _queue_root — stdout: .sfs-local/queue root.
_queue_root() {
  echo "${SFS_LOCAL_DIR}/queue"
}

# _ensure_queue_dirs — create file-backed queue state directories.
_ensure_queue_dirs() {
  local root
  root="$(_queue_root)"
  mkdir -p "$root/pending" "$root/claimed" "$root/done" "$root/failed" "$root/abandoned" "$root/runs"
}

# _slugify — portable, conservative filename slug.
_slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' \
    | cut -c1-48
}

_queue_now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# _queue_counts — stdout: "queue · pending N · claimed N · done N · failed N · abandoned N".
_queue_counts() {
  _ensure_queue_dirs
  local root
  root="$(_queue_root)"
  local pending claimed done failed abandoned
  pending=$(find "$root/pending" -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  claimed=$(find "$root/claimed" -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  done=$(find "$root/done" -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  failed=$(find "$root/failed" -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  abandoned=$(find "$root/abandoned" -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  printf 'queue · pending %s · claimed %s · done %s · failed %s · abandoned %s\n' \
    "$pending" "$claimed" "$done" "$failed" "$abandoned"
}

_queue_stale_claims() {
  _ensure_queue_dirs
  local root ttl
  root="$(_queue_root)"
  ttl="$LOOP_TTL_MIN"
  if ! command -v python3 >/dev/null 2>&1; then
    return 0
  fi
  python3 - "$root/claimed" "$ttl" <<'PYEOF'
import datetime as dt
import os
import re
import sys

claimed_root, ttl_s = sys.argv[1:3]
try:
    ttl = int(ttl_s)
except Exception:
    ttl = 30
now = dt.datetime.now(dt.timezone.utc)

def parse_iso(value):
    value = (value or "").strip().strip('"')
    if not value:
        return None
    if value.endswith("Z"):
        value = value[:-1] + "+00:00"
    try:
        parsed = dt.datetime.fromisoformat(value)
    except Exception:
        return None
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=dt.timezone.utc)
    return parsed.astimezone(dt.timezone.utc)

def frontmatter(path):
    try:
        data = open(path, encoding="utf-8").read()
    except Exception:
        return {}
    m = re.match(r"^---\n(.*?)\n---", data, re.S)
    if not m:
        return {}
    out = {}
    for line in m.group(1).splitlines():
        mm = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if mm:
            out[mm.group(1)] = mm.group(2).strip().strip('"')
    return out

stale = []
if os.path.isdir(claimed_root):
    for dirpath, _, names in os.walk(claimed_root):
        for name in names:
            if not name.endswith(".md"):
                continue
            path = os.path.join(dirpath, name)
            fm = frontmatter(path)
            claimed_at = parse_iso(fm.get("claimed_at", ""))
            if not claimed_at:
                continue
            age = int((now - claimed_at).total_seconds() // 60)
            if age > ttl:
                stale.append((age, fm.get("owner", ""), fm.get("task_id", name[:-3]), path))
for age, owner, task_id, path in sorted(stale, reverse=True):
    print(f"stale · age {age}m · owner {owner or '-'} · task {task_id} · {path}")
PYEOF
}

_queue_blocked_tasks() {
  _ensure_queue_dirs
  local root owner
  root="$(_queue_root)"
  owner="$LOOP_OWNER"
  if ! command -v python3 >/dev/null 2>&1; then
    return 0
  fi
  python3 - "$root" "$owner" <<'PYEOF'
import os
import re
import sys

root, current_owner = sys.argv[1:3]

def read(path):
    try:
        return open(path, encoding="utf-8").read()
    except Exception:
        return ""

def fm_and_body(path):
    data = read(path)
    m = re.match(r"^---\n(.*?)\n---\n?", data, re.S)
    fm = {}
    deps = []
    if m:
        lines = m.group(1).splitlines()
        in_deps = False
        for line in lines:
            mm = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
            if mm:
                key, val = mm.group(1), mm.group(2).strip().strip('"')
                fm[key] = val
                in_deps = key == "depends_on"
                if key == "depends_on" and val and val not in ("[]", '""'):
                    deps.extend(x.strip().strip('"') for x in val.strip("[]").split(",") if x.strip())
                continue
            if in_deps:
                mm2 = re.match(r"^\s*-\s*(.*?)\s*$", line)
                if mm2:
                    deps.append(mm2.group(1).strip().strip('"'))
                elif line and not line.startswith(" "):
                    in_deps = False
        body = data[m.end():]
    else:
        body = data
    return fm, deps, body

def files_scope(body):
    out = []
    in_scope = False
    for raw in body.splitlines():
        if re.match(r"^## Files Scope\s*$", raw):
            in_scope = True
            continue
        if in_scope and raw.startswith("## "):
            break
        if not in_scope:
            continue
        line = raw.strip()
        if not line.startswith("- "):
            continue
        val = line[2:].strip().strip("`").strip()
        if not val or val == "TBD":
            continue
        out.append(val.rstrip("/"))
    return out

def task_id(path):
    fm, _, _ = fm_and_body(path)
    return fm.get("task_id") or os.path.basename(path)[:-3]

done_ids = set()
done_dir = os.path.join(root, "done")
if os.path.isdir(done_dir):
    for name in os.listdir(done_dir):
        if name.endswith(".md"):
            done_ids.add(task_id(os.path.join(done_dir, name)))

claimed_scopes = []
claimed_dir = os.path.join(root, "claimed")
if os.path.isdir(claimed_dir):
    for dirpath, _, names in os.walk(claimed_dir):
        for name in names:
            if not name.endswith(".md"):
                continue
            path = os.path.join(dirpath, name)
            fm, _, body = fm_and_body(path)
            owner = fm.get("owner") or os.path.basename(os.path.dirname(path))
            for scope in files_scope(body):
                claimed_scopes.append((owner, task_id(path), scope))

def overlaps(a, b):
    return a == b or a.startswith(b + "/") or b.startswith(a + "/")

pending_dir = os.path.join(root, "pending")
if os.path.isdir(pending_dir):
    for name in sorted(os.listdir(pending_dir)):
        if not name.endswith(".md"):
            continue
        path = os.path.join(pending_dir, name)
        fm, deps, body = fm_and_body(path)
        tid = fm.get("task_id") or name[:-3]
        missing = [dep for dep in deps if dep and dep not in done_ids]
        if missing:
            print(f"blocked · deps {','.join(missing)} · task {tid} · {path}")
            continue
        scopes = files_scope(body)
        for owner, claimed_tid, claimed_scope in claimed_scopes:
            hit = next((scope for scope in scopes if overlaps(scope, claimed_scope)), None)
            if hit:
                print(f"blocked · files_scope {hit} overlaps {claimed_tid}@{owner} · task {tid} · {path}")
                break
PYEOF
}

# _pick_queue_task — stdout: pending task path, priority asc then path.
# Filter: scheduled mode skips task mode=user-active-only.
_pick_queue_task() {
  _ensure_queue_dirs
  local root mode owner
  root="$(_queue_root)"
  mode="$LOOP_MODE"
  owner="$LOOP_OWNER"
  if ! command -v python3 >/dev/null 2>&1; then
    find "$root/pending" -type f -name '*.md' | sort | head -1
    return 0
  fi
  python3 - "$root" "$mode" "$owner" <<'PYEOF'
import os, re, sys
root, mode, current_owner = sys.argv[1:4]
pending = os.path.join(root, "pending")

def parse(path):
    try:
        data = open(path, encoding="utf-8").read()
    except Exception:
        return {}, [], ""
    fm = {}
    deps = []
    m = re.match(r"^---\n(.*?)\n---\n?", data, re.S)
    if m:
        lines = m.group(1).splitlines()
        in_deps = False
        for line in lines:
            mm = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
            if mm:
                key, val = mm.group(1), mm.group(2).strip().strip('"')
                fm[key] = val
                in_deps = key == "depends_on"
                if key == "depends_on" and val and val not in ("[]", '""'):
                    deps.extend(x.strip().strip('"') for x in val.strip("[]").split(",") if x.strip())
                continue
            if in_deps:
                mm2 = re.match(r"^\s*-\s*(.*?)\s*$", line)
                if mm2:
                    deps.append(mm2.group(1).strip().strip('"'))
                elif line and not line.startswith(" "):
                    in_deps = False
        body = data[m.end():]
    else:
        body = data
    return fm, deps, body

def task_id(path):
    fm, _, _ = parse(path)
    return fm.get("task_id") or os.path.basename(path)[:-3]

def files_scope(body):
    out = []
    in_scope = False
    for raw in body.splitlines():
        if re.match(r"^## Files Scope\s*$", raw):
            in_scope = True
            continue
        if in_scope and raw.startswith("## "):
            break
        if not in_scope:
            continue
        line = raw.strip()
        if not line.startswith("- "):
            continue
        val = line[2:].strip().strip("`").strip()
        if val and val != "TBD":
            out.append(val.rstrip("/"))
    return out

done_ids = set()
done_dir = os.path.join(root, "done")
if os.path.isdir(done_dir):
    for name in os.listdir(done_dir):
        if name.endswith(".md"):
            done_ids.add(task_id(os.path.join(done_dir, name)))

claimed_scopes = []
claimed_dir = os.path.join(root, "claimed")
if os.path.isdir(claimed_dir):
    for dirpath, _, names in os.walk(claimed_dir):
        for name in names:
            if not name.endswith(".md"):
                continue
            path = os.path.join(dirpath, name)
            fm, _, body = parse(path)
            owner = fm.get("owner") or os.path.basename(os.path.dirname(path))
            for scope in files_scope(body):
                claimed_scopes.append(scope)

def overlaps(a, b):
    return a == b or a.startswith(b + "/") or b.startswith(a + "/")

tasks = []
if os.path.isdir(pending):
    for name in os.listdir(pending):
        if not name.endswith(".md"):
            continue
        path = os.path.join(pending, name)
        fm, deps, body = parse(path)
        if fm.get("status", "pending") != "pending":
            continue
        if mode == "scheduled" and fm.get("mode") == "user-active-only":
            continue
        if any(dep and dep not in done_ids for dep in deps):
            continue
        scopes = files_scope(body)
        if any(overlaps(scope, claimed_scope) for scope in scopes for claimed_scope in claimed_scopes):
            continue
        try:
            pr = int(fm.get("priority", "5"))
        except Exception:
            pr = 5
        tasks.append((pr, path))
tasks.sort(key=lambda x: (x[0], x[1]))
if tasks:
    print(tasks[0][1])
PYEOF
}

# _queue_rewrite_status — update simple scalar frontmatter keys.
_queue_rewrite_status() {
  local path="$1" status="$2" owner="$3"
  local now tmp
  now="$(_queue_now_utc)"
  tmp=$(mktemp) || return 1
  awk -v status="$status" -v owner="$owner" -v now="$now" '
    BEGIN { in_fm=0; seen_status=0; seen_owner=0; seen_claimed=0 }
    NR == 1 && $0 == "---" { in_fm=1; print; next }
    in_fm && $0 == "---" {
      if (!seen_status) print "status: " status
      if (owner != "" && !seen_owner) print "owner: " owner
      if (owner != "" && !seen_claimed) print "claimed_at: " now
      in_fm=0; print; next
    }
    in_fm && /^status:/ { print "status: " status; seen_status=1; next }
    in_fm && /^owner:/ {
      if (owner != "") { print "owner: " owner; seen_owner=1; next }
    }
    in_fm && /^claimed_at:/ {
      if (owner != "") { print "claimed_at: " now; seen_claimed=1; next }
    }
    { print }
  ' "$path" > "$tmp" && mv -f "$tmp" "$path"
}

# _claim_queue_task — claim the next pending task with atomic mv.
# stdout: claimed task path.
_claim_queue_task() {
  local owner="$1"
  local task claimed_dir base dest
  task="$(_pick_queue_task)"
  [[ -n "$task" && -f "$task" ]] || return 1
  _ensure_queue_dirs
  claimed_dir="$(_queue_root)/claimed/${owner}"
  mkdir -p "$claimed_dir"
  base="$(basename "$task")"
  dest="${claimed_dir}/${base}"
  if mv "$task" "$dest" 2>/dev/null; then
    _queue_rewrite_status "$dest" "claimed" "$owner" || true
    echo "$dest"
    return 0
  fi
  return 1
}

# _queue_read_scalar — read a simple scalar frontmatter key.
_queue_read_scalar() {
  local path="$1" key="$2"
  awk -v key="$key" '
    BEGIN { in_fm=0 }
    NR == 1 && $0 == "---" { in_fm=1; next }
    in_fm && $0 == "---" { exit }
    in_fm && index($0, key ":") == 1 {
      sub(/^[^:]*:[ \t]*/, "")
      gsub(/^"/, "")
      gsub(/"$/, "")
      print
      exit
    }
  ' "$path"
}

_queue_read_int() {
  local path="$1" key="$2" default_value="$3" value
  value="$(_queue_read_scalar "$path" "$key")"
  case "$value" in
    ''|*[!0-9]*) echo "$default_value" ;;
    *) echo "$value" ;;
  esac
}

# _queue_path_in_allowed_state — true when a task path sits under one allowed state.
_queue_path_in_allowed_state() {
  local path="$1"
  shift
  local root state
  root="$(_queue_root)"
  for state in "$@"; do
    case "$path" in
      "$root/$state"/*|*/"$root/$state"/*)
        return 0
        ;;
    esac
  done
  return 1
}

# _queue_resolve_task — resolve task-id, basename, or path in allowed states.
_queue_resolve_task() {
  local target="$1"
  shift
  local root tmp state candidate base task_id
  _ensure_queue_dirs
  root="$(_queue_root)"

  if [[ -f "$target" ]] && _queue_path_in_allowed_state "$target" "$@"; then
    echo "$target"
    return 0
  fi
  if [[ -f "$root/$target" ]] && _queue_path_in_allowed_state "$root/$target" "$@"; then
    echo "$root/$target"
    return 0
  fi

  tmp=$(mktemp) || return 1
  : > "$tmp"
  for state in "$@"; do
    if [[ -d "$root/$state" ]]; then
      find "$root/$state" -type f -name '*.md' 2>/dev/null
    fi
  done | sort > "$tmp"

  while IFS= read -r candidate; do
    base="$(basename "$candidate")"
    task_id="$(_queue_read_scalar "$candidate" task_id)"
    if [[ "$target" == "$task_id" || "$target" == "$base" || "$target.md" == "$base" || "$base" == "$target"-* ]]; then
      echo "$candidate"
      rm -f "$tmp"
      return 0
    fi
  done < "$tmp"

  rm -f "$tmp"
  return 1
}

# _queue_move_task — move task into a queue state directory without overwrite.
_queue_move_task() {
  local path="$1" state="$2"
  local root dest
  _ensure_queue_dirs
  root="$(_queue_root)"
  mkdir -p "$root/$state"
  dest="$root/$state/$(basename "$path")"
  if [[ "$path" == "$dest" ]]; then
    echo "$dest"
    return 0
  fi
  if [[ -e "$dest" ]]; then
    echo "queue: destination exists: $dest" >&2
    return 1
  fi
  mv "$path" "$dest" || return 1
  echo "$dest"
}

_queue_run_stamp() {
  date -u +"%Y%m%dT%H%M%SZ"
}

_queue_env_quote() {
  printf "%s" "$1" | sed "s/'/'\\\\''/g; s/^/'/; s/$/'/"
}

# _queue_prepare_run_artifacts — create deterministic task execution handoff files.
# stdout: run artifact directory.
_queue_prepare_run_artifacts() {
  local task="$1" owner="$2" executor="$3" executor_cmd="$4"
  local task_id title root run_dir now guard
  task_id="$(_queue_read_scalar "$task" task_id)"
  [[ -n "$task_id" ]] || task_id="$(basename "$task" .md)"
  title="$(_queue_read_scalar "$task" title)"
  root="$(_queue_root)/runs/${task_id}"
  run_dir="${root}/$(_queue_run_stamp)-$$"
  now="$(_queue_now_utc)"
  mkdir -p "$run_dir" || return 1

  guard="- Do not run git add, git commit, or git push unless this task explicitly grants that permission."
  if grep -Eiq 'git (add|commit|push).*(allowed|ok|okay|permitted)|auto-commit|commit까지는' "$task"; then
    guard="- Follow the task-specific git instructions exactly; if they are ambiguous, do not run git add, git commit, or git push."
  fi

  {
    printf 'TASK_ID=%s\n' "$(_queue_env_quote "$task_id")"
    printf 'TITLE=%s\n' "$(_queue_env_quote "$title")"
    printf 'CLAIMED_PATH=%s\n' "$(_queue_env_quote "$task")"
    printf 'OWNER=%s\n' "$(_queue_env_quote "$owner")"
    printf 'EXECUTOR=%s\n' "$(_queue_env_quote "$executor")"
    printf 'EXECUTOR_CMD=%s\n' "$(_queue_env_quote "$executor_cmd")"
    printf 'CREATED_AT=%s\n' "$(_queue_env_quote "$now")"
    printf 'PROMPT_PATH=%s\n' "$(_queue_env_quote "$run_dir/PROMPT.md")"
  } > "$run_dir/metadata.env" || return 1

  {
    printf '# Solon Queue Execution Prompt\n\n'
    printf '## Metadata\n\n'
    printf -- '- Task ID: `%s`\n' "$task_id"
    printf -- '- Title: `%s`\n' "${title:-unknown}"
    printf -- '- Claimed task path: `%s`\n' "$task"
    printf -- '- Owner: `%s`\n' "$owner"
    printf -- '- Executor: `%s`\n' "$executor"
    printf -- '- Created at: `%s`\n\n' "$now"
    printf '## Safety Guard\n\n'
    printf '%s\n' "$guard"
    printf -- '- Stay within the task Files Scope unless the task itself explicitly expands it.\n'
    printf -- '- Preserve existing queue behavior unless the task explicitly changes queue behavior.\n'
    printf -- '- Record meaningful verification evidence in the sprint log or task artifacts.\n\n'
    printf '## Claimed Task\n\n'
    cat "$task"
  } > "$run_dir/PROMPT.md" || return 1

  echo "$run_dir"
}

_queue_extract_verify_commands() {
  local task="$1"
  awk '
    /^## Verify[ \t]*$/ { in_verify=1; next }
    in_verify && /^## / { exit }
    in_verify {
      line=$0
      sub(/^[ \t]*/, "", line)
      if (line !~ /^- /) next
      sub(/^- /, "", line)
      if (line == "" || line == "TBD") next
      if (line ~ /^`[^`]+`/) {
        sub(/^`/, "", line)
        sub(/`.*/, "", line)
        print line
        next
      }
      if (line ~ /^(bash|cmp|git diff --check|test|grep|find|printf|mkdir|rm|cp|mv|sed|awk|SFS_|\.\/|\.sfs-local\/)/) {
        print line
      }
    }
  ' "$task"
}

_queue_run_verify() {
  local task="$1" run_dir="$2"
  local commands_file out_file err_file exit_file cmd idx rc
  mkdir -p "$run_dir" || return 1
  commands_file="$run_dir/verify.commands"
  out_file="$run_dir/verify.out"
  err_file="$run_dir/verify.err"
  exit_file="$run_dir/verify.exit"
  _queue_extract_verify_commands "$task" > "$commands_file"
  if [[ ! -s "$commands_file" ]]; then
    printf '%s\n' "no runnable verify commands found" > "$err_file"
    printf '%s\n' "6" > "$exit_file"
    return "$SFS_LOOP_EXIT_SPEC_MISSING"
  fi

  : > "$out_file"
  : > "$err_file"
  idx=0
  while IFS= read -r cmd || [[ -n "$cmd" ]]; do
    idx=$(( idx + 1 ))
    printf '[%s] %s\n' "$idx" "$cmd" >> "$out_file"
    if bash -lc "$cmd" >> "$out_file" 2>> "$err_file"; then
      rc=0
    else
      rc=$?
    fi
    printf '[%s] exit %s\n' "$idx" "$rc" >> "$out_file"
    if (( rc != 0 )); then
      printf '%s\n' "$rc" > "$exit_file"
      return "$SFS_LOOP_EXIT_VERIFY_FAIL"
    fi
  done < "$commands_file"

  printf '%s\n' "0" > "$exit_file"
  return "$SFS_LOOP_EXIT_OK"
}

# _queue_rewrite_lifecycle — update lifecycle scalar frontmatter fields.
_queue_rewrite_lifecycle() {
  local path="$1" status="$2" owner="$3" claimed_at="$4" attempts="$5" ts_key="$6"
  local now tmp
  now="$(_queue_now_utc)"
  tmp=$(mktemp) || return 1
  awk \
    -v status="$status" \
    -v owner="$owner" \
    -v claimed_at="$claimed_at" \
    -v attempts="$attempts" \
    -v ts_key="$ts_key" \
    -v now="$now" '
    BEGIN {
      in_fm=0
      seen_status=0
      seen_owner=0
      seen_claimed=0
      seen_attempts=0
      seen_ts=0
    }
    NR == 1 && $0 == "---" { in_fm=1; print; next }
    in_fm && $0 == "---" {
      if (!seen_status) print "status: " status
      if (owner != "__KEEP__" && !seen_owner) print "owner: " owner
      if (claimed_at != "__KEEP__" && !seen_claimed) print "claimed_at: " claimed_at
      if (attempts != "__KEEP__" && !seen_attempts) print "attempts: " attempts
      if (ts_key != "" && !seen_ts) print ts_key ": " now
      in_fm=0
      print
      next
    }
    in_fm && /^status:/ { print "status: " status; seen_status=1; next }
    in_fm && /^owner:/ {
      if (owner != "__KEEP__") { print "owner: " owner; seen_owner=1; next }
    }
    in_fm && /^claimed_at:/ {
      if (claimed_at != "__KEEP__") { print "claimed_at: " claimed_at; seen_claimed=1; next }
    }
    in_fm && /^attempts:/ {
      if (attempts != "__KEEP__") { print "attempts: " attempts; seen_attempts=1; next }
    }
    in_fm && ts_key != "" && index($0, ts_key ":") == 1 {
      print ts_key ": " now
      seen_ts=1
      next
    }
    { print }
  ' "$path" > "$tmp" && mv -f "$tmp" "$path"
}

# _bump_heartbeat — sed PROGRESS.md frontmatter `last_overwrite` to now (UTC ISO).
# Args: $1 = progress_path
# rc: 0=ok, 8=write fail
_bump_heartbeat() {
  local path="$1"
  local now
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  # awk-replace the last_overwrite line, preserving comments after the value
  local tmp
  tmp=$(mktemp) || return 8
  awk -v now="$now" '
    /^last_overwrite:/ && !done {
      # preserve trailing comment if any
      cmt = ""
      if (match($0, /[ \t]*#.*$/)) cmt = substr($0, RSTART)
      print "last_overwrite: " now cmt
      done = 1; next
    }
    { print }
  ' "$path" > "$tmp" && mv -f "$tmp" "$path" || return 8
  return 0
}

# _generate_codename — generate adjective-adjective-surname (multi-worker auto-codename).
# rc: 0
_generate_codename() {
  local adj1=(adoring brave bright calm clever dazzling eager gallant happy jolly
              keen loving merry nifty quirky serene sweet trusty witty zealous)
  local adj2=(angry busy clever cool fast funny gentle gracious lucid magic noisy
              proud quiet rapid steady tender vivid wise yearning zesty)
  local sur=(archimedes babbage bohr curie dijkstra einstein feynman galileo
             hopper kepler lovelace mendel newton ohm pascal ritchie shannon
             tesla turing wright)
  local i1=$(( RANDOM % ${#adj1[@]} ))
  local i2=$(( RANDOM % ${#adj2[@]} ))
  local i3=$(( RANDOM % ${#sur[@]} ))
  echo "${adj1[$i1]}-${adj2[$i2]}-${sur[$i3]}"
}

# ─────────────────────────────────────────────────────────────────────
# SUB-CMD IMPLEMENTATIONS (sub-task 6.4)
# ─────────────────────────────────────────────────────────────────────

# cmd_loop_run — main loop entry (12-step pseudo-flow integration)
# spec: sfs-loop-flow.md §4
cmd_loop_run() {
  local progress_path
  progress_path=$(resolve_progress_path) || exit "$SFS_LOOP_EXIT_SPEC_MISSING"

  # Step 1~3: pre-flight (CLAUDE.md / PROGRESS / drift)
  echo "loop: pre-flight check (progress=$progress_path)" >&2
  set +e
  pre_flight_check "$progress_path"
  local pf_rc=$?
  set -e
  if (( pf_rc == 3 )); then
    echo "loop: drift detected, aborting (exit 3)" >&2
    exit "$SFS_LOOP_EXIT_DRIFT"
  fi
  if (( pf_rc != 0 )); then
    echo "loop: pre-flight failed (rc=$pf_rc)" >&2
    exit "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
  fi

  # Step 1.5: Pre-execution review gate (sub-task 6.6)
  # spec: sfs-loop-review-gate.md §6.6 + CLAUDE.md §1.15
  if [[ "$LOOP_REVIEW_GATE" == "true" ]]; then
    local planner="${LOOP_PERSONA_DIR}/planner.md"
    local evaluator="${LOOP_PERSONA_DIR}/evaluator.md"
    local plan_doc="$LOOP_PLAN_DOC"
    if [[ -z "$plan_doc" ]]; then
      # Auto-resolve: first sprints/WU-*.md or skip.
      plan_doc=$(ls sprints/WU-*.md 2>/dev/null | head -1 || echo "")
    fi
    if [[ -f "$planner" && -f "$evaluator" && -f "$plan_doc" ]]; then
      echo "loop: review gate (PLANNER + EVALUATOR on $plan_doc)" >&2
      local r1 r2
      set +e
      r1=$(review_with_persona "$planner" "$plan_doc" 2>&1)
      r2=$(review_with_persona "$evaluator" "$plan_doc" 2>&1)
      set -e
      echo "loop:   PLANNER:" >&2
      echo "$r1" | sed 's/^/loop:     /' >&2
      echo "loop:   EVALUATOR:" >&2
      echo "$r2" | sed 's/^/loop:     /' >&2
      echo "loop:   verdicts: PASS-with-conditions (MVP stub) → proceed" >&2
    else
      echo "loop: review gate skipped (planner/evaluator/plan_doc missing — MVP stub)" >&2
    fi
  fi

  # Wall-clock cap
  local start_epoch end_epoch
  start_epoch=$(date +%s)
  end_epoch=$(( start_epoch + LOOP_MAX_WALL_MIN * 60 ))

  # Iter loop
  local iter=0
  local completed=0
  local last_domain=""
  while (( iter < LOOP_MAX_ITERS )); do
    iter=$(( iter + 1 ))
    local now_epoch
    now_epoch=$(date +%s)
    if (( now_epoch >= end_epoch )); then
      echo "loop: max-wall-min reached ($LOOP_MAX_WALL_MIN min)" >&2
      break
    fi

    echo "loop: ── iter $iter/$LOOP_MAX_ITERS (mode=$LOOP_MODE, executor=$LOOP_EXECUTOR, owner=$LOOP_OWNER)" >&2

    # Step 4~5a: queue-first task pick + claim. Queue is an execution backlog;
    # sprint scope remains in brainstorm/plan/decision artifacts.
    local queue_task
    queue_task="$(_pick_queue_task)"
    if [[ -n "$queue_task" && -f "$queue_task" ]]; then
      echo "loop:   picked queue task: $queue_task" >&2
      if [[ "$LOOP_DRY_RUN" == "true" ]]; then
        echo "loop:   [DRY-RUN] would claim_queue_task for $LOOP_OWNER" >&2
      else
        local claimed
        set +e
        claimed="$(_claim_queue_task "$LOOP_OWNER")"
        local qclaim_rc=$?
        set -e
        if (( qclaim_rc != 0 )) || [[ -z "$claimed" ]]; then
          echo "loop:   queue claim failed, trying next iter" >&2
          continue
        fi
        echo "loop:   claimed queue task: $claimed" >&2
        local executor_cmd run_dir live_rc
        executor_cmd=$(resolve_executor "$LOOP_EXECUTOR")
        run_dir="$(_queue_prepare_run_artifacts "$claimed" "$LOOP_OWNER" "$LOOP_EXECUTOR" "$executor_cmd")" || {
          echo "loop:   queue run artifact creation failed" >&2
          exit "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
        }
        echo "loop:   queue run artifacts: $run_dir" >&2
        echo "loop:   queue prompt: $run_dir/PROMPT.md" >&2
        if [[ "${SFS_LOOP_LLM_LIVE:-0}" == "1" ]]; then
          ensure_executor_headless_auth "$LOOP_EXECUTOR" || exit "$SFS_LOOP_EXIT_EXECUTOR_FAIL"
          echo "loop:   [LIVE] invoking queue executor" >&2
          set +e
          # shellcheck disable=SC2086
          cat "$run_dir/PROMPT.md" | eval $executor_cmd > "$run_dir/executor.out" 2> "$run_dir/executor.err"
          live_rc=$?
          set -e
          printf '%s\n' "$live_rc" > "$run_dir/executor.exit"
          if (( live_rc != 0 )); then
            echo "loop:   queue executor returned non-zero (rc=$live_rc)" >&2
          fi
        else
          echo "loop:   [STUB] queue prompt generated; set SFS_LOOP_LLM_LIVE=1 to invoke executor" >&2
        fi
        if [[ "${SFS_LOOP_VERIFY:-0}" == "1" ]]; then
          local verify_rc
          echo "loop:   queue verify: $claimed" >&2
          set +e
          _queue_run_verify "$claimed" "$run_dir"
          verify_rc=$?
          set -e
          if (( verify_rc == 0 )); then
            cmd_loop_complete "$claimed" >&2
            echo "loop:   queue verify passed" >&2
          elif (( verify_rc == SFS_LOOP_EXIT_VERIFY_FAIL )); then
            cmd_loop_fail "$claimed" >&2 || true
            echo "loop:   queue verify failed" >&2
          else
            echo "loop:   queue verify skipped (no runnable commands, rc=$verify_rc)" >&2
          fi
        fi
      fi
      completed=$(( completed + 1 ))
      last_domain="queue"
      continue
    fi

    # Step 4~5b: domain sweep + claim fallback
    local picked
    set +e
    picked=$(_pick_domain "$progress_path")
    local pick_rc=$?
    set -e
    if [[ -z "$picked" ]] || (( pick_rc != 0 )); then
      echo "loop: no eligible domain (all-domains-closed-or-locked), exiting" >&2
      break
    fi
    echo "loop:   picked domain: $picked" >&2

    if [[ "$LOOP_DRY_RUN" == "true" ]]; then
      echo "loop:   [DRY-RUN] would claim_lock $picked for $LOOP_OWNER" >&2
    else
      set +e
      claim_lock "$progress_path" "$picked" "$LOOP_OWNER"
      local claim_rc=$?
      set -e
      if (( claim_rc != 0 )); then
        echo "loop:   claim_lock failed (rc=$claim_rc), trying next iter" >&2
        continue
      fi
    fi

    # Step 6: LLM invocation site (MVP stub — real call gated on env SFS_LOOP_LLM_LIVE=1)
    local executor_cmd
    executor_cmd=$(resolve_executor "$LOOP_EXECUTOR")
    echo "loop:   executor: $executor_cmd" >&2
    if [[ "${SFS_LOOP_LLM_LIVE:-0}" == "1" && "$LOOP_DRY_RUN" != "true" ]]; then
      ensure_executor_headless_auth "$LOOP_EXECUTOR" || exit "$SFS_LOOP_EXIT_EXECUTOR_FAIL"
      echo "loop:   [LIVE] invoking executor (real LLM call)" >&2
      # Real call: cat PROMPT.md | $executor_cmd  (Ralph Loop pattern)
      # MVP: PROMPT.md must exist; otherwise skip
      if [[ -f PROMPT.md ]]; then
        # shellcheck disable=SC2086
        cat PROMPT.md | eval $executor_cmd || echo "loop:   executor returned non-zero" >&2
      else
        echo "loop:   no PROMPT.md, skipping live invocation" >&2
      fi
    else
      echo "loop:   [STUB] would invoke executor (set SFS_LOOP_LLM_LIVE=1 to enable)" >&2
    fi

    # Step 7: heartbeat
    if [[ "$LOOP_DRY_RUN" != "true" ]]; then
      _bump_heartbeat "$progress_path" || {
        echo "loop:   heartbeat failed, aborting" >&2
        exit "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
      }
    fi

    # Step 11: release_between
    if [[ "$LOOP_RELEASE_BETWEEN" == "true" && "$LOOP_DRY_RUN" != "true" ]]; then
      release_lock "$progress_path" "$picked" complete || true
    fi

    completed=$(( completed + 1 ))
    last_domain="$picked"
  done

  # Final report
  echo "loop: ── done. iterations=$completed last_domain=${last_domain:-none}" >&2
  return "$SFS_LOOP_EXIT_OK"
}

# cmd_loop_coord — coordinator spawning N independent workers (sub-task 6.5).
# spec: sfs-loop-multi-worker.md §6.4
cmd_loop_coord() {
  local N="$LOOP_PARALLEL"
  if (( N < 1 )); then N=1; fi
  echo "loop: coordinator spawning $N workers (isolation=$LOOP_ISOLATION, mode=$LOOP_MODE)" >&2

  # Pre-flight at coordinator level (workers do their own pre-flight too)
  local progress_path
  progress_path=$(resolve_progress_path) || exit "$SFS_LOOP_EXIT_SPEC_MISSING"

  if [[ "$LOOP_ISOLATION" != "process" ]]; then
    echo "loop: --isolation '$LOOP_ISOLATION' not yet implemented (only 'process'), falling back to process" >&2
  fi

  local pids=()
  local worker_ids=()
  local logdir="${SFS_LOOP_LOGDIR:-/tmp}"
  for i in $(seq 1 "$N"); do
    local wid
    if [[ -n "$LOOP_WORKER_ID" ]] && (( N == 1 )); then
      wid="$LOOP_WORKER_ID"
    else
      wid="$(_generate_codename)"
    fi
    worker_ids+=("$wid")
    local logfile="${logdir}/sfs-loop-worker-${wid}.log"

    local extra_flags=()
    if [[ "$LOOP_DRY_RUN" == "true" ]]; then extra_flags+=("--dry-run"); fi
    if [[ "$LOOP_NO_MENTAL_COUPLING" == "true" ]]; then extra_flags+=("--no-mental-coupling"); fi

    # COORD_ONLY mode means coordinator does no work itself; otherwise coordinator + workers
    "$SCRIPT_DIR/sfs-loop.sh" \
      --mode "$LOOP_MODE" \
      --executor "$LOOP_EXECUTOR" \
      --worker-id "$wid" \
      --owner "$wid" \
      --max-iters "$LOOP_MAX_ITERS" \
      --max-wall-min "$LOOP_MAX_WALL_MIN" \
      --ttl-min "$LOOP_TTL_MIN" \
      --micro-steps-per-iter "$LOOP_MICRO_STEPS_PER_ITER" \
      --parallel 1 \
      "${extra_flags[@]}" \
      > "$logfile" 2>&1 &
    local pid=$!
    pids+=("$pid")
    echo "loop:   spawned worker $i: $wid (pid=$pid, log=$logfile)" >&2
  done

  echo "loop: waiting for ${#pids[@]} workers..." >&2
  local agg_rc=0
  local exit_codes=()
  for idx in "${!pids[@]}"; do
    local pid="${pids[$idx]}"
    local wid="${worker_ids[$idx]}"
    set +e
    wait "$pid"
    local rc=$?
    set -e
    exit_codes+=("$rc")
    if (( rc != 0 )); then
      echo "loop:   worker $wid (pid=$pid) exited rc=$rc" >&2
      # Propagate first non-zero (spec: 5/7 priority)
      if (( agg_rc == 0 )); then agg_rc="$rc"; fi
    fi
  done

  echo "loop: ── coordinator done. workers=${#pids[@]} exits=[${exit_codes[*]}] agg_rc=$agg_rc" >&2
  return "$agg_rc"
}

# cmd_loop_status — print 1-line status of current loop state.
# spec: sfs-loop-flow.md §3.3 sub-cmd
cmd_loop_queue() {
  _queue_counts
  _queue_stale_claims
  _queue_blocked_tasks
  return "$SFS_LOOP_EXIT_OK"
}

cmd_loop_enqueue() {
  local title="$1"
  _ensure_queue_dirs
  local now id slug sprint path safe_title
  now="$(_queue_now_utc)"
  id="loopq-$(date -u +"%Y%m%dT%H%M%SZ")-$$"
  slug="$(_slugify "$title")"
  [[ -n "$slug" ]] || slug="task"
  sprint="$(read_current_sprint 2>/dev/null || true)"
  path="$(_queue_root)/pending/${id}-${slug}.md"
  safe_title="$(printf '%s' "$title" | sed 's/"/\\"/g')"
  cat > "$path" <<EOF
---
task_id: ${id}
title: "${safe_title}"
status: pending
priority: 5
mode: ${LOOP_MODE}
sprint_id: "${sprint:-}"
owner: ""
attempts: 0
max_attempts: 3
created_at: ${now}
claimed_at: ""
size: ${LOOP_QUEUE_SIZE}
target_minutes: ${LOOP_QUEUE_TARGET_MINUTES}
---

# ${title}

## Goal

Describe the concrete loop task here.

## Files Scope

- TBD

## Verify

- TBD
EOF
  echo "queued: $path"
  return "$SFS_LOOP_EXIT_OK"
}

cmd_loop_claim() {
  local claimed
  set +e
  claimed="$(_claim_queue_task "$LOOP_OWNER")"
  local rc=$?
  set -e
  if (( rc != 0 )) || [[ -z "$claimed" ]]; then
    echo "queue: no pending task" >&2
    return "$SFS_LOOP_EXIT_SPEC_MISSING"
  fi
  echo "claimed: $claimed"
  return "$SFS_LOOP_EXIT_OK"
}

cmd_loop_complete() {
  local target="$1" task moved
  set +e
  task="$(_queue_resolve_task "$target" claimed)"
  local resolve_rc=$?
  set -e
  if (( resolve_rc != 0 )) || [[ -z "$task" ]]; then
    echo "queue: claimed task not found: $target" >&2
    return "$SFS_LOOP_EXIT_SPEC_MISSING"
  fi
  moved="$(_queue_move_task "$task" done)" || return "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
  _queue_rewrite_lifecycle "$moved" "done" "__KEEP__" "__KEEP__" "__KEEP__" "completed_at" \
    || return "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
  echo "completed: $moved"
  return "$SFS_LOOP_EXIT_OK"
}

cmd_loop_fail() {
  local target="$1" task moved
  set +e
  task="$(_queue_resolve_task "$target" claimed)"
  local resolve_rc=$?
  set -e
  if (( resolve_rc != 0 )) || [[ -z "$task" ]]; then
    echo "queue: claimed task not found: $target" >&2
    return "$SFS_LOOP_EXIT_SPEC_MISSING"
  fi
  moved="$(_queue_move_task "$task" failed)" || return "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
  _queue_rewrite_lifecycle "$moved" "failed" "__KEEP__" "__KEEP__" "__KEEP__" "failed_at" \
    || return "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
  echo "failed: $moved"
  return "$SFS_LOOP_EXIT_OK"
}

cmd_loop_retry() {
  local target="$1" task moved attempts max_attempts
  set +e
  task="$(_queue_resolve_task "$target" failed abandoned claimed)"
  local resolve_rc=$?
  set -e
  if (( resolve_rc != 0 )) || [[ -z "$task" ]]; then
    echo "queue: retryable task not found: $target" >&2
    return "$SFS_LOOP_EXIT_SPEC_MISSING"
  fi
  attempts="$(_queue_read_int "$task" attempts 0)"
  max_attempts="$(_queue_read_int "$task" max_attempts 3)"
  attempts=$(( attempts + 1 ))
  if (( attempts > max_attempts )); then
    moved="$(_queue_move_task "$task" abandoned)" || return "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
    _queue_rewrite_lifecycle "$moved" "abandoned" "__KEEP__" "__KEEP__" "$attempts" "abandoned_at" \
      || return "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
    echo "abandoned: $moved (attempts=$attempts max_attempts=$max_attempts)"
    return "$SFS_LOOP_EXIT_OK"
  fi
  moved="$(_queue_move_task "$task" pending)" || return "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
  _queue_rewrite_lifecycle "$moved" "pending" "\"\"" "\"\"" "$attempts" "retried_at" \
    || return "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
  echo "retried: $moved (attempts=$attempts)"
  return "$SFS_LOOP_EXIT_OK"
}

cmd_loop_abandon() {
  local target="$1" task moved attempts
  set +e
  task="$(_queue_resolve_task "$target" pending claimed failed abandoned)"
  local resolve_rc=$?
  set -e
  if (( resolve_rc != 0 )) || [[ -z "$task" ]]; then
    echo "queue: task not found: $target" >&2
    return "$SFS_LOOP_EXIT_SPEC_MISSING"
  fi
  attempts="$(_queue_read_int "$task" attempts 0)"
  moved="$(_queue_move_task "$task" abandoned)" || return "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
  _queue_rewrite_lifecycle "$moved" "abandoned" "__KEEP__" "__KEEP__" "$attempts" "abandoned_at" \
    || return "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
  echo "abandoned: $moved (attempts=$attempts)"
  return "$SFS_LOOP_EXIT_OK"
}

cmd_loop_verify() {
  local target="$1" task owner executor_cmd run_dir verify_rc
  set +e
  task="$(_queue_resolve_task "$target" claimed)"
  local resolve_rc=$?
  set -e
  if (( resolve_rc != 0 )) || [[ -z "$task" ]]; then
    echo "queue: claimed task not found: $target" >&2
    return "$SFS_LOOP_EXIT_SPEC_MISSING"
  fi

  owner="$(_queue_read_scalar "$task" owner)"
  [[ -n "$owner" ]] || owner="$LOOP_OWNER"
  executor_cmd=$(resolve_executor "$LOOP_EXECUTOR")
  run_dir="$(_queue_prepare_run_artifacts "$task" "$owner" "$LOOP_EXECUTOR" "$executor_cmd")" \
    || return "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"

  set +e
  _queue_run_verify "$task" "$run_dir"
  verify_rc=$?
  set -e
  if (( verify_rc == 0 )); then
    cmd_loop_complete "$task" >&2
    echo "verified: $run_dir"
    return "$SFS_LOOP_EXIT_OK"
  fi
  if (( verify_rc == SFS_LOOP_EXIT_VERIFY_FAIL )); then
    cmd_loop_fail "$task" >&2 || true
    echo "verify failed: $run_dir" >&2
    return "$SFS_LOOP_EXIT_VERIFY_FAIL"
  fi
  echo "verify skipped: $run_dir (no runnable commands)" >&2
  return "$verify_rc"
}

cmd_loop_status() {
  local progress_path
  progress_path=$(resolve_progress_path) || exit "$SFS_LOOP_EXIT_SPEC_MISSING"
  local owner
  owner=$(awk '/^current_wu_owner:/ { sub(/^current_wu_owner: */, ""); sub(/[ \t]*#.*$/, ""); print; exit }' "$progress_path")
  owner="${owner:-null}"
  local last
  last=$(awk '/^last_overwrite:/ { sub(/^last_overwrite: */, ""); sub(/[ \t]*#.*$/, ""); print; exit }' "$progress_path")
  printf 'loop · owner %s · last_overwrite %s · max_iters %d · max_wall %dmin\n' \
    "$owner" "${last:-unknown}" "$LOOP_MAX_ITERS" "$LOOP_MAX_WALL_MIN"
  return "$SFS_LOOP_EXIT_OK"
}

# cmd_loop_stop — release current_wu_owner (best-effort) + exit.
cmd_loop_stop() {
  local progress_path
  progress_path=$(resolve_progress_path) || exit "$SFS_LOOP_EXIT_SPEC_MISSING"
  # Reset current_wu_owner via sed (atomic single-line replace).
  local tmp
  tmp=$(mktemp) || exit "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
  awk '
    /^current_wu_owner:/ && !done {
      cmt = ""
      if (match($0, /[ \t]*#.*$/)) cmt = substr($0, RSTART)
      print "current_wu_owner: null" cmt
      done = 1; next
    }
    { print }
  ' "$progress_path" > "$tmp" && mv -f "$tmp" "$progress_path" || exit "$SFS_LOOP_EXIT_HEARTBEAT_FAIL"
  echo "loop: stopped, current_wu_owner=null" >&2
  return "$SFS_LOOP_EXIT_OK"
}

# cmd_loop_replay — replay past scheduled_task_log entry (debug).
cmd_loop_replay() {
  local task_log_id="$1"
  local progress_path
  progress_path=$(resolve_progress_path) || exit "$SFS_LOOP_EXIT_SPEC_MISSING"
  echo "loop: replay '$task_log_id' (MVP stub)" >&2
  if grep -q "$task_log_id" "$progress_path" 2>/dev/null; then
    echo "loop: found '$task_log_id' in $progress_path" >&2
    return "$SFS_LOOP_EXIT_OK"
  fi
  echo "loop: '$task_log_id' not found in $progress_path" >&2
  return "$SFS_LOOP_EXIT_SPEC_MISSING"
}

main "$@"
