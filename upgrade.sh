#!/usr/bin/env bash
# upgrade.sh — Solon Product upgrader (VERSION 기반)
#
# 사용법:
#   cd ~/workspace/my-project
#   git -C ~/tmp/solon-product pull --ff-only --tags
#   ~/tmp/solon-product/upgrade.sh                   # 로컬 clone 기반
#   curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-product/main/upgrade.sh | bash  # 원격
#
# 동작:
#   1. consumer 쪽 .sfs-local/VERSION 읽어서 installed_version 파악
#   2. 로컬 clone 기반이면 clone 이 GitHub main 보다 뒤처졌는지 먼저 확인
#   3. distribution 쪽 최신 VERSION 조회
#   4. 같으면 종료, 다르면 업그레이드 계획 + 대화형 파일별 처리
#
# 원칙:
#   - .sfs-local/sprints/*, .sfs-local/decisions/*, .sfs-local/events.jsonl 은 절대 덮어쓰지 않음
#   - SFS.md / runtime adapter / .gitignore / divisions.yaml 대상
#   - 사용자 수정 가능성이 큰 파일은 checksum + 추천 action 을 먼저 보여줌
#   - 업그레이드 취소는 언제든 가능 (파일 쓰기 전 전부 dry-run 프리뷰)

set -euo pipefail

ASSUME_YES=0
UPGRADE_LAYOUT="${SFS_UPGRADE_LAYOUT:-}"

usage() {
  cat <<'EOF'
Usage: sfs upgrade [--yes] [--layout thin|vendored]

Options:
  -y, --yes           안전 기본 정책으로 non-interactive upgrade 실행
  --layout thin       project-local runtime/agent adapters 를 global sfs runtime 으로 이관
  --layout vendored   project-local runtime/agent adapters 를 계속 유지
  -h, --help          도움말 출력

Environment:
  SFS_MODEL_PROFILE_PROMPT=0  agent/model fallback 질문을 이번 upgrade 에서 숨김
  SFS_UPGRADE_LAYOUT=thin|vendored
  SFS_CLI_DISCOVERY_TIMEOUT_SEC=45  cli-discovery hook 최대 실행 시간
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes)
      ASSUME_YES=1
      ;;
    --layout)
      shift
      [ $# -gt 0 ] || { echo "알 수 없는 옵션: --layout 값 필요 (thin|vendored)" >&2; exit 99; }
      UPGRADE_LAYOUT="$1"
      ;;
    --layout=*)
      UPGRADE_LAYOUT="${1#--layout=}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "알 수 없는 옵션: $1" >&2
      usage >&2
      exit 99
      ;;
  esac
  shift
done

case "$UPGRADE_LAYOUT" in
  ""|thin|vendored) ;;
  *)
    echo "알 수 없는 layout: $UPGRADE_LAYOUT (지원: thin, vendored)" >&2
    exit 99
    ;;
esac

readonly SOLON_REPO="MJ-0701/solon-product"
readonly SOLON_BRANCH="main"
readonly GIT_MARKER_BEGIN="### BEGIN solon-product ###"
readonly GIT_MARKER_END="### END solon-product ###"
# Legacy markers (0.5.0-mvp 이전 install) — upgrade 가 fallback 으로 인식해서 product marker 로 교체.
readonly LEGACY_GIT_MARKER_BEGIN="### BEGIN solon-mvp ###"
readonly LEGACY_GIT_MARKER_END="### END solon-mvp ###"

# 색상
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  C_RED=$(tput setaf 1); C_GREEN=$(tput setaf 2); C_YELLOW=$(tput setaf 3)
  C_BLUE=$(tput setaf 4); C_BOLD=$(tput bold); C_RESET=$(tput sgr0)
else
  C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_BOLD=""; C_RESET=""
fi
info()  { printf "%s%s%s\n" "$C_BLUE" "$*" "$C_RESET"; }
ok()    { printf "  %s✓%s %s\n" "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf "  %s⚠%s %s\n" "$C_YELLOW" "$C_RESET" "$*"; }
err()   { printf "  %s✗%s %s\n" "$C_RED" "$C_RESET" "$*" >&2; }
die()   { err "$*"; exit 1; }
trace_upgrade() {
  [ "${SFS_UPGRADE_TRACE:-0}" = "1" ] || return 0
  printf '[sfs-upgrade-trace] %s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >&2
}

sfs_is_ci() {
  case "${CI:-}" in 1|true|TRUE|yes|YES) return 0 ;; esac
  case "${GITHUB_ACTIONS:-}" in 1|true|TRUE|yes|YES) return 0 ;; esac
  return 1
}

normalize_positive_timeout() {
  local raw="$1" default="$2" label="$3"
  case "$raw" in
    ""|*[!0-9]*|0)
      printf "  %s⚠%s %s timeout 값이 유효하지 않아 기본값 %ss 를 사용합니다: %s\n" \
        "$C_YELLOW" "$C_RESET" "$label" "$default" "${raw:-<empty>}" >&2
      printf '%s\n' "$default"
      ;;
    *)
      printf '%s\n' "$raw"
      ;;
  esac
}

run_upgrade_command_with_timeout() {
  local label="$1" timeout="$2"
  shift 2
  timeout="$(normalize_positive_timeout "$timeout" "45" "$label")"
  trace_upgrade "$label start timeout=${timeout}s"

  if command -v timeout >/dev/null 2>&1 && timeout 1 sh -c 'exit 0' >/dev/null 2>&1; then
    local rc=0
    set +e
    timeout "$timeout" "$@"
    rc=$?
    set -e
    if [ "$rc" -eq 124 ]; then
      warn "$label timed out after ${timeout}s — continuing"
      trace_upgrade "$label timeout rc=${rc}"
      return 124
    fi
    trace_upgrade "$label exit rc=${rc}"
    return "$rc"
  fi

  if sfs_is_ci; then
    warn "$label skipped: timeout(1) unavailable in CI, avoiding unbounded background watchdog"
    trace_upgrade "$label skipped no-timeout-command-ci"
    return 124
  fi

  "$@" &
  local child=$!
  (
    sleep "$timeout"
    if kill -0 "$child" 2>/dev/null; then
      trace_upgrade "$label timeout reached pid=${child}; terminating"
      kill -TERM "$child" 2>/dev/null || true
      sleep 2
      kill -KILL "$child" 2>/dev/null || true
    fi
  ) &
  local watcher=$!

  local rc=0
  set +e
  wait "$child"
  rc=$?
  set -e

  kill "$watcher" 2>/dev/null || true
  wait "$watcher" 2>/dev/null || true

  if [ "$rc" -eq 143 ] || [ "$rc" -eq 137 ]; then
    warn "$label timed out after ${timeout}s — continuing"
    trace_upgrade "$label timeout rc=${rc}"
    return 124
  fi
  trace_upgrade "$label exit rc=${rc}"
  return "$rc"
}

# pipe 대응. CI must keep stdin non-interactive so prompts fall back to defaults.
if ! sfs_is_ci && [ ! -t 0 ] && [ -e /dev/tty ]; then
  if { : < /dev/tty; } 2>/dev/null; then
    exec < /dev/tty
  fi
fi

prompt() {
  local msg="$1" default="${2:-}" answer
  if [ "$ASSUME_YES" -eq 1 ] && [ -n "$default" ]; then
    printf "%s [%s]: %s\n" "$msg" "$default" "$default" >&2
    echo "$default"
    return 0
  fi
  if [ -n "$default" ]; then printf "%s [%s]: " "$msg" "$default" >&2
  else printf "%s: " "$msg" >&2; fi
  read -r answer || answer=""
  echo "${answer:-$default}"
}

prompt_always() {
  local msg="$1" default="${2:-}" answer
  if [ -n "$default" ]; then printf "%s [%s]: " "$msg" "$default" >&2
  else printf "%s: " "$msg" >&2; fi
  read -r answer || answer=""
  echo "${answer:-$default}"
}

sed_inplace() {
  if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

create_default_model_profile() {
  local runtime="${1:-current}" policy="${2:-solon_recommended}" status="${3:-default_applied}"
  [ -f "$SOURCE_DIR/templates/.sfs-local-template/model-profiles.yaml" ] || return 1

  local today project_name
  today=$(date +%Y-%m-%d)
  project_name="$(basename "$TARGET")"
  mkdir -p "$TARGET/.sfs-local"
  cp "$SOURCE_DIR/templates/.sfs-local-template/model-profiles.yaml" "$TARGET/.sfs-local/model-profiles.yaml"
  sed_inplace \
    -e "s|<DATE>|$today|g" \
    -e "s|<SOLON-VERSION>|$NEW_VER|g" \
    -e "s|<PROJECT-NAME>|$project_name|g" \
    -e "s|<DEFAULT-RUNTIME>|$runtime|g" \
    -e "s|<MODEL-POLICY>|$policy|g" \
    -e "s|<MODEL-PROFILE-STATUS>|$status|g" \
    "$TARGET/.sfs-local/model-profiles.yaml" 2>/dev/null || true
}

model_profile_needs_prompt() {
  local file="$TARGET/.sfs-local/model-profiles.yaml"
  [ -f "$file" ] || return 0
  grep -Eq '^[[:space:]]*status:[[:space:]]*"?review_required"?' "$file" 2>/dev/null && return 0
  grep -Eq '^[[:space:]]*status:[[:space:]]*"?unset"?' "$file" 2>/dev/null && return 0
  return 1
}

print_model_profile_question() {
  cat <<'EOF'

Agent model profile:
  이 질문은 Solon 의 역할별 agent 가 어떤 모델을 쓸지 정하는 단계입니다.
  기본값은 이미 적용됩니다. 사용자가 따로 설정하지 않아도 deterministic intake 는 가벼운 모델,
  질문 생성/facilitation 은 standard 모델, product identity/architecture/gate 판단과 review 는
  high reasoning, 코드 구현 worker 는 fixed-slice standard, 단순 helper 는 economy 로 라우팅합니다.

  current_model 은 명시적으로 opt-out 하고 현재 Claude/Codex/Gemini 에서 사용자가 선택한
  모델을 모든 역할에 그대로 쓰고 싶을 때만 고릅니다.

  선택지:
    1. Solon 기본값: 현재 runtime 에 맞춰 role routing 적용 (권장)
    2. current_model: 역할 분리 없이 현재 선택 모델을 그대로 사용
    3. all_high: 모든 agent/helper 를 high-end 로 설정 (품질 우선, 비용/지연 증가 가능)
    4. custom/manual: 직접 모델 profile 작성

  Codex/Claude 가 대신 실행 중인 경우:
    위 설명과 선택지를 사용자에게 보여주고 번호를 물어보세요.
    사용자가 고르지 않으면 1번 Solon 기본값으로 계속 진행하면 됩니다.
EOF
}

set_model_profile_fields() {
  local runtime="$1" policy="$2" status="$3" confirmed_by="$4" confirmed_at="$5"
  local file="$TARGET/.sfs-local/model-profiles.yaml"
  [ -f "$file" ] || create_default_model_profile current solon_recommended default_applied
  if ! sed_inplace \
    -e "s@^[[:space:]]*status:.*@  status: \"$status\"        # default_applied | selected_at_install | confirmed | current_model_fallback | review_required@g" \
    -e "s@^[[:space:]]*selected_runtime:.*@  selected_runtime: \"$runtime\"   # current | claude | codex | gemini | custom@g" \
    -e "s@^[[:space:]]*selected_policy:.*@  selected_policy: \"$policy\"       # current_model | solon_recommended | all_high | custom@g" \
    -e "s@^[[:space:]]*confirmed_by:.*@  confirmed_by: \"$confirmed_by\"@g" \
    -e "s@^[[:space:]]*confirmed_at:.*@  confirmed_at: \"$confirmed_at\"@g" \
    "$file"; then
    warn "agent model profile 저장 실패: $file"
    return 1
  fi
}

# model-profiles drift WARN (#4) — config-time half of the model-tier lock.
# configured_tier=current defers to the selected policy's agent_tiers; an
# explicit configured_tier that differs from the policy-recommended tier is
# surfaced (never auto-rewritten — owner decides).
warn_model_profiles_drift() {
  local mp="$1" policy="${2:-}"
  [ -f "$mp" ] || return 0
  case "$policy" in
    solon_recommended|all_high) ;;
    *) return 0 ;;
  esac
  local drift
  drift="$(awk '
    /^agent_defaults:/ {in_ad=1; next}
    in_ad && /^[A-Za-z]/ {in_ad=0}
    in_ad && /^  [A-Za-z0-9_-]+:/ {agent=$1; sub(/:$/,"",agent); rec=""; next}
    in_ad && /recommended_tier:/ {rec=$2}
    in_ad && /configured_tier:/ {
      cfg=$2
      if (cfg != "current" && rec != "" && cfg != rec)
        print agent " (configured_tier=" cfg " vs policy " rec ")"
    }
  ' "$mp" 2>/dev/null)"
  if [ -n "$drift" ]; then
    warn "model-profiles drift — selected_policy '$policy' 와 어긋나는 configured_tier (auto-rewrite 안 함; 의도와 다르면 직접 수정):"
    printf '%s\n' "$drift" | while IFS= read -r d; do warn "  - $d"; done
  fi
}

maybe_prompt_model_profile() {
  model_profile_needs_prompt || return 0

  if [ "${SFS_MODEL_PROFILE_PROMPT:-0}" != "1" ]; then
    warn "agent model profile review_required 상태 — 이번 질문은 건너뜀"
    warn "    기본 role routing 은 이미 적용됩니다. 직접 설정이 필요하면 SFS_MODEL_PROFILE_PROMPT=1 로 다시 실행하세요."
    return 0
  fi

  if [ ! -t 0 ]; then
    print_model_profile_question
    return 0
  fi

  print_model_profile_question
  local choice runtime now
  choice="$(prompt_always "agent model profile 선택? (1/2/3/4, 기본은 1)" "1")"
  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  case "$choice" in
    1)
      set_model_profile_fields "current" "solon_recommended" "default_applied" "sfs upgrade" "$now"
      ok "agent model profile 기본값 적용: solon_recommended role routing"
      ;;
    2|"")
      set_model_profile_fields "current" "current_model" "selected_at_install" "sfs upgrade" "$now"
      ok "agent model profile opt-out: current_model"
      ;;
    3)
      runtime="$(prompt_always "all_high 를 적용할 runtime? (claude/codex/gemini/custom/current)" "claude")"
      case "$runtime" in
        claude|codex|gemini|custom|current) ;;
        *) warn "알 수 없는 runtime='$runtime' — current 로 기록"; runtime="current" ;;
      esac
      set_model_profile_fields "$runtime" "all_high" "confirmed" "sfs upgrade" "$now"
      ok "agent model profile 확정: runtime=$runtime, policy=all_high"
      ;;
    4)
      set_model_profile_fields "custom" "custom" "review_required" "" ""
      warn "custom/manual 선택 — .sfs-local/model-profiles.yaml 을 직접 채우면 됩니다."
      warn "    status=review_required 로 남겨 다음 upgrade/사용자 발화 때 다시 안내됩니다."
      ;;
    *)
      warn "알 수 없는 선택 '$choice' — solon_recommended 기본값 적용"
      set_model_profile_fields "current" "solon_recommended" "default_applied" "sfs upgrade" "$now"
      ;;
  esac
}

# ============================================================================
# 1. 소스 위치 판별
# ============================================================================

SCRIPT_PATH="${BASH_SOURCE[0]:-}"
SOURCE_DIR=""
TMP_CLONE=""
cleanup() {
  if [ -n "$TMP_CLONE" ] && [ -d "$TMP_CLONE" ]; then
    rm -rf "$TMP_CLONE"
  fi
}
trap cleanup EXIT INT TERM

if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ] && [ -d "$(dirname "$SCRIPT_PATH")/templates" ]; then
  SOURCE_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
  MODE="local"
else
  command -v git >/dev/null || die "git 미설치"
  TMP_CLONE=$(mktemp -d -t solon-upgrade.XXXXXX)
  info "Fetching Solon MVP latest..."
  git clone --quiet --depth=1 --branch="$SOLON_BRANCH" \
    "https://github.com/${SOLON_REPO}.git" "$TMP_CLONE" \
    || die "git clone 실패"
  SOURCE_DIR="$TMP_CLONE"
  MODE="remote"
fi

TARGET="$(pwd)"

check_local_source_freshness() {
  # Local clone mode means the user's product distribution source is the clone
  # itself (for example ~/tmp/solon-product). If that clone is stale, VERSION
  # comparison below can falsely report "already latest" while GitHub has newer
  # adapters/scripts. Fetch refs only; do not mutate the worktree.
  [ "$MODE" = "local" ] || return 0
  [ -d "$SOURCE_DIR/.git" ] || return 0
  command -v git >/dev/null 2>&1 || return 0

  local remote_url local_head remote_head
  remote_url=$(git -C "$SOURCE_DIR" remote get-url origin 2>/dev/null || true)
  case "$remote_url" in
    *github.com*MJ-0701/solon-product*|*github.com:MJ-0701/solon-product*) ;;
    *) return 0 ;;
  esac

  git -C "$SOURCE_DIR" fetch --quiet origin "$SOLON_BRANCH" --tags 2>/dev/null || {
    warn "로컬 product clone 최신 여부를 확인하지 못함: $SOURCE_DIR"
    warn "    네트워크가 가능하면 먼저 실행 권장: git -C \"$SOURCE_DIR\" pull --ff-only --tags"
    return 0
  }

  local_head=$(git -C "$SOURCE_DIR" rev-parse HEAD 2>/dev/null || true)
  remote_head=$(git -C "$SOURCE_DIR" rev-parse "refs/remotes/origin/${SOLON_BRANCH}" 2>/dev/null || true)
  [ -n "$local_head" ] && [ -n "$remote_head" ] || return 0
  [ "$local_head" != "$remote_head" ] || return 0

  if git -C "$SOURCE_DIR" merge-base --is-ancestor "$local_head" "$remote_head" 2>/dev/null; then
    cat >&2 <<EOF
  ✗ 로컬 product clone 이 GitHub 보다 뒤처져 있습니다.

    source clone: $SOURCE_DIR
    local HEAD : ${local_head:0:7}
    origin/$SOLON_BRANCH: ${remote_head:0:7}

    먼저 product clone 을 최신화한 뒤 upgrade 를 다시 실행하세요:

      git -C "$SOURCE_DIR" pull --ff-only --tags
      cd "$TARGET"
      bash "$SOURCE_DIR/upgrade.sh"

EOF
    exit 10
  fi

  warn "로컬 product clone 이 origin/${SOLON_BRANCH} 과 diverge 되어 있습니다: $SOURCE_DIR"
  warn "    local=${local_head:0:7} remote=${remote_head:0:7}"
  warn "    개발자/owner 의 unreleased clone 이 아니라면 새로 clone 후 upgrade 권장."
}

check_local_source_freshness

list_managed_context_rels() {
  local context_root="$SOURCE_DIR/templates/.sfs-local-template/context"
  [ -d "$context_root" ] || return 0
  (
    cd "$context_root" || exit 0
    find . -type f -name '*.md' -print 2>/dev/null | sed 's#^\./##' | sort
  )
}

repair_missing_context_router_targets() {
  local target_context="$TARGET/.sfs-local/context"
  local rel src dst repaired=0

  mkdir -p "$target_context/commands" "$target_context/policies"

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    src="$SOURCE_DIR/templates/.sfs-local-template/context/$rel"
    dst="$target_context/$rel"
    [ -f "$src" ] || continue
    if [ ! -f "$dst" ]; then
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
      ok "context router 누락 target 수리: $rel"
      repaired=1
    fi
  done < <(list_managed_context_rels)

  [ "$repaired" -eq 0 ] || warn "새 context 파일을 추가했으니 프로젝트 repo 에서 commit 여부를 확인하세요: .sfs-local/context/"
}

verify_context_router_targets() {
  local target_index="$TARGET/.sfs-local/context/_INDEX.md"
  local target_kernel="$TARGET/.sfs-local/context/kernel.md"
  local rel missing=0

  if [ ! -f "$target_index" ]; then
    err "context router index missing: .sfs-local/context/_INDEX.md"
    missing=1
  fi
  if [ ! -f "$target_kernel" ]; then
    err "context kernel missing: .sfs-local/context/kernel.md"
    missing=1
  fi
  [ "$missing" -eq 0 ] || return 1

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    if [ ! -f "$TARGET/.sfs-local/context/$rel" ]; then
      err "context router target missing: $rel"
      missing=1
    fi
  done < <(list_managed_context_rels)

  [ "$missing" -eq 0 ] || return 1
  ok "context router targets complete"
}

thin_context_runtime_migration() {
  [ "${INSTALL_LAYOUT:-vendored}" = "thin" ] || return 0
  local target_context="$TARGET/.sfs-local/context"
  local rel src dst archive_dir archive_file manifest staging count remaining

  if [ ! -d "$target_context" ]; then
    ok "thin runtime context: project-local context 없음 (packaged runtime 사용)"
    return 0
  fi

  archive_dir="$TARGET/.sfs-local/archives/runtime-migrations/$(date +%Y%m%d-%H%M%S)-thin-context"
  archive_file="$archive_dir/project-local-context.tar.gz"
  manifest="$archive_dir/manifest.txt"
  mkdir -p "$archive_dir" || return 5
  staging=$(mktemp -d "$archive_dir/.stage.XXXXXX") || return 5
  count=0

  list_managed_context_rels | while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    dst="$target_context/$rel"
    [ -f "$dst" ] || continue
    mkdir -p "$staging/context/$(dirname "$rel")" || exit 5
    cp "$dst" "$staging/context/$rel" || exit 5
    rm -f "$dst" || exit 5
    printf '%s\n' "$rel" >> "$archive_dir/.migrated-list"
  done

  if [ -f "$archive_dir/.migrated-list" ]; then
    count=$(wc -l < "$archive_dir/.migrated-list" | tr -d '[:space:]')
  else
    count=0
  fi
  if [ "$count" -eq 0 ]; then
    rm -rf "$staging" "$archive_dir/.migrated-list" 2>/dev/null || true
    rmdir "$archive_dir" 2>/dev/null || true
    remaining=$(find "$target_context" -type f 2>/dev/null | wc -l | tr -d '[:space:]')
    if [ "${remaining:-0}" -gt 0 ]; then
      warn "thin runtime context: project-local custom context override 유지 ($remaining files)"
    else
      find "$target_context" -depth -type d -empty -exec rmdir {} \; 2>/dev/null || true
      ok "thin runtime context: 정리할 managed context 없음"
    fi
    return 0
  fi

  {
    echo "SFS thin runtime context migration"
    echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "reason: project-local context docs moved to packaged global sfs runtime"
    echo "archive: $archive_file"
    echo "count: $count"
    echo
    echo "meaning:"
    echo "- files were not conceptually removed from SFS"
    echo "- managed command/policy guidance now lives in the Homebrew/Scoop sfs runtime"
    echo "- the consumer project keeps only state, reports, decisions, and optional local overrides"
    echo
    echo "migrated_files:"
    sed 's/^/- .sfs-local\/context\//' "$archive_dir/.migrated-list"
  } > "$manifest" || return 5

  tar -czf "$archive_file" -C "$staging" . || return 5
  rm -rf "$staging" "$archive_dir/.migrated-list" || return 5
  find "$target_context" -depth -type d -empty -exec rmdir {} \; 2>/dev/null || true

  remaining=$(find "$target_context" -type f 2>/dev/null | wc -l | tr -d '[:space:]' || printf '0')
  ok "thin runtime context 이관: managed context $count files → packaged global sfs runtime"
  ok "  압축 백업: ${archive_file#$TARGET/}"
  if [ "${remaining:-0}" -gt 0 ]; then
    warn "  project-local custom context override 는 유지됨: .sfs-local/context/ ($remaining files)"
  else
    ok "  프로젝트 표면 정리: .sfs-local/context managed md 제거 완료"
  fi
  return 0
}

compact_legacy_sprint_archive_dirs() {
  local root="$TARGET/.sfs-local/archives/sprints"
  local dir archive_file manifest staging count total=0 file rel
  [ -d "$root" ] || return 0

  while IFS= read -r dir; do
    [ -d "$dir" ] || continue
    archive_file="$dir/sprint-evidence.tar.gz"
    manifest="$dir/manifest.txt"

    count=0
    staging="$(mktemp -d "$dir/.stage.XXXXXX")" || return 5
    if [ -f "$archive_file" ]; then
      tar -xzf "$archive_file" -C "$staging" || return 5
    fi
    while IFS= read -r file; do
      [ -f "$file" ] || continue
      rel="${file#$dir/}"
      mkdir -p "$staging/$(dirname "$rel")" || return 5
      cp "$file" "$staging/$rel" || return 5
      count=$((count + 1))
    done < <(find "$dir" -type f ! -name 'manifest.txt' ! -name '*.tar.gz' ! -path '*/.stage/*' ! -path '*/.stage.*/*' | sort)

    if [ "$count" -eq 0 ]; then
      rm -rf "$staging" 2>/dev/null || true
      continue
    fi

    {
      echo "SFS legacy sprint archive compaction"
      echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      echo "reason: loose legacy sprint archive files packed into one cold archive bundle"
      echo "archive: $archive_file"
      echo "loose_files_compacted: $count"
      echo
      echo "items:"
      find "$staging" -type f 2>/dev/null | sort | while IFS= read -r staged; do
        printf -- "- %s\n" "${staged#$staging/}"
      done
    } > "$manifest" || return 5

    tar -czf "$archive_file" -C "$staging" . || return 5
    rm -rf "$staging" || return 5
    while IFS= read -r file; do
      [ -f "$file" ] || continue
      rm -f "$file" || return 5
    done < <(find "$dir" -type f ! -name 'manifest.txt' ! -name '*.tar.gz' ! -path '*/.stage/*' ! -path '*/.stage.*/*' | sort)
    find "$dir" -depth -type d -empty -exec rmdir {} \; 2>/dev/null || true
    total=$((total + 1))
  done < <(find "$root" -mindepth 2 -maxdepth 2 -type d | sort)

  if [ "$total" -gt 0 ]; then
    ok "legacy sprint archives 압축 정리: $total bundle(s)"
  fi
  return 0
}

compact_legacy_review_run_archives() {
  local root="$TARGET/.sfs-local/archives/review-runs"
  local archive_dir archive_file manifest staging count
  [ -d "$root" ] || return 0

  count=$(find "$root" -type f 2>/dev/null | wc -l | tr -d '[:space:]')
  if [ "${count:-0}" -eq 0 ]; then
    rm -rf "$root" 2>/dev/null || true
    ok "legacy review-run archive 비움: loose file 없음"
    return 0
  fi

  archive_dir="$TARGET/.sfs-local/archives/runtime-migrations/$(date +%Y%m%d-%H%M%S)-legacy-review-runs"
  archive_file="$archive_dir/review-runs.tar.gz"
  manifest="$archive_dir/manifest.txt"
  mkdir -p "$archive_dir" || return 5
  staging="$(mktemp -d "$archive_dir/.stage.XXXXXX")" || return 5
  mkdir -p "$staging/review-runs" || return 5
  cp -R "$root"/. "$staging/review-runs/" || return 5

  {
    echo "SFS legacy review-run archive migration"
    echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "reason: old per-run review scratch archives are no longer kept as loose project files"
    echo "archive: $archive_file"
    echo "count: $count"
    echo
    echo "meaning:"
    echo "- future superseded review scratch is discarded during implementation"
    echo "- latest sprint review scratch is packed into the sprint cold archive bundle at tidy/retro"
    echo "- this compressed file is retained only for legacy history"
    echo
    echo "items:"
    find "$staging/review-runs" -type f 2>/dev/null | sort | while IFS= read -r staged; do
      printf -- "- %s\n" "${staged#$staging/}"
    done
  } > "$manifest" || return 5

  tar -czf "$archive_file" -C "$staging" . || return 5
  rm -rf "$staging" "$root" || return 5
  ok "legacy review-run archives 이관: $count files → ${archive_file#$TARGET/}"
  return 0
}

compact_legacy_runtime_upgrade_archives() {
  local root="$TARGET/.sfs-local/archives/runtime-upgrades"
  local dir archive_file manifest staging count total=0 file rel
  [ -d "$root" ] || return 0

  while IFS= read -r dir; do
    [ -d "$dir" ] || continue
    archive_file="$dir/runtime-upgrade-backup.tar.gz"
    manifest="$dir/manifest.txt"
    count=0
    staging="$(mktemp -d "$dir/.stage.XXXXXX")" || return 5
    if [ -f "$archive_file" ]; then
      tar -xzf "$archive_file" -C "$staging" || return 5
    fi
    while IFS= read -r file; do
      [ -f "$file" ] || continue
      rel="${file#$dir/}"
      mkdir -p "$staging/legacy-flat" || return 5
      cp "$file" "$staging/legacy-flat/$(basename "$file")" || return 5
      count=$((count + 1))
    done < <(find "$dir" -type f ! -name 'manifest.txt' ! -name '*.tar.gz' ! -path '*/.stage/*' ! -path '*/.stage.*/*' | sort)

    if [ "$count" -eq 0 ]; then
      rm -rf "$staging" 2>/dev/null || true
      continue
    fi

    {
      echo "SFS runtime upgrade backup compaction"
      echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      echo "reason: runtime upgrade backups are cold rollback evidence, not visible project docs"
      echo "archive: $archive_file"
      echo "loose_files_compacted: $count"
      echo
      echo "items:"
      find "$staging" -type f 2>/dev/null | sort | while IFS= read -r staged; do
        printf -- "- %s\n" "${staged#$staging/}"
      done
    } > "$manifest" || return 5

    tar -czf "$archive_file" -C "$staging" . || return 5
    rm -rf "$staging" || return 5
    while IFS= read -r file; do
      [ -f "$file" ] || continue
      rm -f "$file" || return 5
    done < <(find "$dir" -type f ! -name 'manifest.txt' ! -name '*.tar.gz' ! -path '*/.stage/*' ! -path '*/.stage.*/*' | sort)
    find "$dir" -depth -type d -empty -exec rmdir {} \; 2>/dev/null || true
    total=$((total + 1))
  done < <(find "$root" -mindepth 1 -maxdepth 1 -type d | sort)

  if [ "$total" -gt 0 ]; then
    ok "legacy runtime-upgrades 압축 정리: $total bundle(s)"
  fi
  return 0
}

compact_legacy_agent_install_archives() {
  local root="$TARGET/.sfs-local/archives/agent-install-backups"
  local dir archive_file manifest staging count total=0 file
  [ -d "$root" ] || return 0

  while IFS= read -r dir; do
    [ -d "$dir" ] || continue
    archive_file="$dir/agent-adapter-backup.tar.gz"
    manifest="$dir/manifest.txt"
    [ ! -f "$archive_file" ] || continue
    count=0
    staging="$(mktemp -d "$dir/.stage.XXXXXX")" || return 5
    while IFS= read -r file; do
      [ -f "$file" ] || continue
      mkdir -p "$staging/legacy-flat" || return 5
      cp "$file" "$staging/legacy-flat/$(basename "$file")" || return 5
      count=$((count + 1))
    done < <(find "$dir" -type f ! -name 'manifest.txt' ! -name '*.tar.gz' ! -path '*/.stage/*' ! -path '*/.stage.*/*' | sort)

    if [ "$count" -eq 0 ]; then
      rm -rf "$staging" 2>/dev/null || true
      continue
    fi

    {
      echo "SFS agent adapter backup compaction"
      echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      echo "reason: agent install backups are rollback evidence, not visible project docs"
      echo "archive: $archive_file"
      echo "loose_files_compacted: $count"
      echo
      echo "items:"
      find "$staging" -type f 2>/dev/null | sort | while IFS= read -r staged; do
        printf -- "- %s\n" "${staged#$staging/}"
      done
    } > "$manifest" || return 5

    tar -czf "$archive_file" -C "$staging" . || return 5
    rm -rf "$staging" || return 5
    while IFS= read -r file; do
      [ -f "$file" ] || continue
      rm -f "$file" || return 5
    done < <(find "$dir" -type f ! -name 'manifest.txt' ! -name '*.tar.gz' ! -path '*/.stage/*' ! -path '*/.stage.*/*' | sort)
    find "$dir" -depth -type d -empty -exec rmdir {} \; 2>/dev/null || true
    total=$((total + 1))
  done < <(find "$root" -mindepth 1 -maxdepth 1 -type d | sort)

  if [ "$total" -gt 0 ]; then
    ok "legacy agent-install backups 압축 정리: $total bundle(s)"
  fi
  return 0
}

compact_legacy_tmp_artifacts() {
  local tmp_root="$TARGET/.sfs-local/tmp"
  local current_sprint_file="$TARGET/.sfs-local/current-sprint"
  local current_sprint="" archive_dir archive_file manifest staging file rel count=0 kept_review=0
  [ -d "$tmp_root" ] || return 0
  [ -f "$current_sprint_file" ] && current_sprint="$(head -1 "$current_sprint_file" | tr -d '[:space:]')"

  archive_dir="$TARGET/.sfs-local/archives/runtime-migrations/$(date +%Y%m%d-%H%M%S)-legacy-tmp-artifacts"
  archive_file="$archive_dir/tmp-artifacts.tar.gz"
  manifest="$archive_dir/manifest.txt"
  mkdir -p "$archive_dir" || return 5
  staging="$(mktemp -d "$archive_dir/.stage.XXXXXX")" || return 5

  while IFS= read -r file; do
    [ -f "$file" ] || continue
    case "$file" in
      "$tmp_root/review-prompts/"*|"$tmp_root/review-runs/"*)
        if [ -n "$current_sprint" ] && basename "$file" | grep -Fq "${current_sprint}"; then
          kept_review=$((kept_review + 1))
          continue
        fi
        ;;
      "$tmp_root/upgrade-backups/"*|"$tmp_root/agent-install-backups/"*|"$tmp_root/profile-backups/"*|"$tmp_root/auth-probes/"*)
        ;;
      *)
        continue
        ;;
    esac
    rel="${file#$TARGET/.sfs-local/}"
    mkdir -p "$staging/$(dirname "$rel")" || return 5
    cp "$file" "$staging/$rel" || return 5
    count=$((count + 1))
  done < <(find "$tmp_root" -type f | sort)

  if [ "$count" -eq 0 ]; then
    rm -rf "$staging" 2>/dev/null || true
    rmdir "$archive_dir" 2>/dev/null || true
    [ "$kept_review" -eq 0 ] || ok "legacy tmp review scratch 유지: current sprint match $kept_review file(s)"
    return 0
  fi

  {
    echo "SFS legacy tmp artifact migration"
    echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "reason: stale tmp/backups are not active project surface"
    echo "archive: $archive_file"
    echo "count: $count"
    echo "kept_current_review_scratch: $kept_review"
    echo
    echo "policy:"
    echo "- current sprint review scratch stays in tmp so retro/tidy can pack it with the sprint"
    echo "- stale review scratch and old backup/probe dirs move to compressed cold history"
    echo
    echo "items:"
    find "$staging" -type f 2>/dev/null | sort | while IFS= read -r staged; do
      printf -- "- %s\n" "${staged#$staging/}"
    done
  } > "$manifest" || return 5

  tar -czf "$archive_file" -C "$staging" . || return 5
  rm -rf "$staging" || return 5
  while IFS= read -r file; do
    [ -f "$file" ] || continue
    case "$file" in
      "$tmp_root/review-prompts/"*|"$tmp_root/review-runs/"*)
        if [ -n "$current_sprint" ] && basename "$file" | grep -Fq "${current_sprint}"; then
          continue
        fi
        ;;
      "$tmp_root/upgrade-backups/"*|"$tmp_root/agent-install-backups/"*|"$tmp_root/profile-backups/"*|"$tmp_root/auth-probes/"*)
        ;;
      *)
        continue
        ;;
    esac
    rm -f "$file" || return 5
  done < <(find "$tmp_root" -type f | sort)
  find "$tmp_root" -depth -type d -empty -exec rmdir {} \; 2>/dev/null || true
  ok "legacy tmp artifacts 이관: $count files → ${archive_file#$TARGET/}"
  [ "$kept_review" -eq 0 ] || ok "  current sprint review scratch 유지: $kept_review file(s)"
  return 0
}

archive_stale_auth_env_example() {
  local file="$TARGET/.sfs-local/auth.env.example"
  local archive_dir archive_file manifest
  [ -f "$file" ] || return 0

  archive_dir="$TARGET/.sfs-local/archives/runtime-migrations/$(date +%Y%m%d-%H%M%S)-auth-env-example"
  archive_file="$archive_dir/auth-env-example.tar.gz"
  manifest="$archive_dir/manifest.txt"
  mkdir -p "$archive_dir" || return 5

  {
    echo "SFS stale auth.env.example migration"
    echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "reason: auth.env.example is a packaged sample, not active project state"
    echo "archive: ${archive_file#$TARGET/}"
    echo
    echo "policy:"
    echo "- project .sfs-local keeps only files with a one-line runtime reason"
    echo "- actual local credentials, if any, belong in .sfs-local/auth.env or SFS_AUTH_ENV_FILE"
    echo "- the sample template remains available in the packaged SFS runtime"
    echo
    echo "items:"
    echo "- .sfs-local/auth.env.example"
  } > "$manifest" || return 5

  tar -czf "$archive_file" -C "$TARGET" ".sfs-local/auth.env.example" || return 5
  rm -f "$file" || return 5
  ok "stale auth.env.example 이관: ${archive_file#$TARGET/}"
  return 0
}

auth_env_has_assignments() {
  local file="${1:?file required}"
  awk '
    /^[[:space:]]*($|#)/ { next }
    /^[[:space:]]*export[[:space:]]+[A-Za-z_][A-Za-z0-9_]*=/ { found=1; next }
    /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*=/ { found=1; next }
    END { exit(found ? 0 : 1) }
  ' "$file" 2>/dev/null
}

cleanup_transient_cache_and_placeholder_auth() {
  local count=0 auth_file="$TARGET/.sfs-local/auth.env"
  if [ -d "$TARGET/.sfs-local/cache" ]; then
    rm -rf "$TARGET/.sfs-local/cache" || return 5
    count=$((count + 1))
  fi
  if [ -f "$auth_file" ] && ! auth_env_has_assignments "$auth_file"; then
    rm -f "$auth_file" || return 5
    count=$((count + 1))
  fi
  if [ "$count" -gt 0 ]; then
    ok "transient cache/placeholder auth 정리: $count item(s)"
  fi
  return 0
}

cleanup_orphan_event_ledger() {
  local events_file="$TARGET/.sfs-local/events.jsonl"
  local current_sprint="" visible_sprint_count archive_dir backup_file manifest line_count
  [ -f "$events_file" ] || return 0

  if [ -f "$TARGET/.sfs-local/current-sprint" ]; then
    current_sprint="$(sed -n '1p' "$TARGET/.sfs-local/current-sprint" 2>/dev/null | tr -d '[:space:]' || true)"
  fi
  if [ -n "$current_sprint" ] && [ -d "$TARGET/.sfs-local/sprints/$current_sprint" ]; then
    return 0
  fi

  visible_sprint_count=0
  if [ -d "$TARGET/.sfs-local/sprints" ]; then
    visible_sprint_count="$(find "$TARGET/.sfs-local/sprints" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d '[:space:]')"
  fi
  [ "${visible_sprint_count:-0}" -eq 0 ] || return 0

  line_count="$(wc -l < "$events_file" 2>/dev/null | tr -d '[:space:]' || printf '0')"
  if [ "${line_count:-0}" -eq 0 ]; then
    rm -f "$events_file" || return 5
    ok "empty event ledger 제거: .sfs-local/events.jsonl"
    return 0
  fi

  archive_dir="$TARGET/.sfs-local/archives/adopt/surface-cleanup/$(date +%Y%m%d-%H%M%S)-orphan-events"
  backup_file="$archive_dir/events.jsonl"
  manifest="$archive_dir/manifest.txt"
  mkdir -p "$archive_dir" || return 5
  cp "$events_file" "$backup_file" || return 5
  {
    echo "SFS orphan event ledger cleanup"
    echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "reason: events.jsonl has no valid active sprint and is not durable handoff history"
    echo "archive: ${backup_file#$TARGET/}"
    echo "lines: $line_count"
  } > "$manifest" || return 5
  rm -f "$events_file" || return 5
  ok "orphan event ledger 이관: $line_count line(s) → ${backup_file#$TARGET/}"
  return 0
}

cleanup_empty_workbench_surface_dirs() {
  local root dir count=0 removed current_sprint=""
  if [ -f "$TARGET/.sfs-local/current-sprint" ]; then
    current_sprint="$(sed -n '1p' "$TARGET/.sfs-local/current-sprint" 2>/dev/null | tr -d '[:space:]' || true)"
  fi
  while :; do
    removed=0
    for root in \
      "$TARGET/.sfs-local/cache" \
      "$TARGET/.sfs-local/tmp" \
      "$TARGET/.sfs-local/queue" \
      "$TARGET/.sfs-local/sprints" \
      "$TARGET/.sfs-local/decisions"; do
      [ -d "$root" ] || continue
      while IFS= read -r dir; do
        [ -n "$dir" ] && [ -d "$dir" ] || continue
        if [ -n "$current_sprint" ] && [ "$dir" = "$TARGET/.sfs-local/sprints/$current_sprint" ]; then
          continue
        fi
        rmdir "$dir" 2>/dev/null || true
        if [ ! -d "$dir" ]; then
          count=$((count + 1))
          removed=$((removed + 1))
        fi
      done < <(find "$root" -depth -type d -empty -print 2>/dev/null)
    done
    [ "$removed" -gt 0 ] || break
  done
  if [ "$count" -gt 0 ]; then
    ok "empty workbench surface dirs 정리: $count dir(s)"
  fi
  return 0
}

non_adopt_archive_ids() {
  local root="$TARGET/.sfs-local/archives" dir
  [ -d "$root" ] || return 0
  find "$root" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null \
    | while IFS= read -r dir; do
        [ "$(basename "$dir")" = "adopt" ] && continue
        basename "$dir"
      done \
    | sort
}

collapse_non_adopt_archive_dirs() {
  local root="$TARGET/.sfs-local/archives"
  local ids count safe_ts archive_dir archive_file manifest item
  local -a tar_items=()
  [ -d "$root" ] || return 0
  ids="$(non_adopt_archive_ids)"
  count="$(printf '%s\n' "$ids" | sed '/^[[:space:]]*$/d' | wc -l | tr -d '[:space:]')"
  [ "${count:-0}" -gt 0 ] || return 0

  safe_ts="$(date +%Y%m%d-%H%M%S)"
  archive_dir="$root/adopt/surface-cleanup/${safe_ts}-archive-buckets"
  if [ -e "$archive_dir" ]; then
    local i=2
    while [ -e "${archive_dir}-${i}" ]; do
      i=$((i + 1))
    done
    archive_dir="${archive_dir}-${i}"
  fi
  archive_file="$archive_dir/preexisting-archives.tar.gz"
  manifest="$archive_dir/preexisting-archives.manifest.txt"
  mkdir -p "$archive_dir" || return 5

  {
    echo "SFS non-adopt archive bucket collapse"
    echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "reason: runtime migration/upgrade/sprint buckets are cold recovery evidence, not visible project surface"
    echo "archive: ${archive_file#$TARGET/}"
    echo "count: $count"
    echo
    echo "items:"
    printf '%s\n' "$ids" | while IFS= read -r item; do
      [ -n "$item" ] || continue
      echo "- .sfs-local/archives/$item"
    done
  } > "$manifest" || return 5

  while IFS= read -r item; do
    [ -n "$item" ] || continue
    tar_items+=("$item")
  done <<< "$ids"
  tar -czf "$archive_file" -C "$root" "${tar_items[@]}" || return 5

  while IFS= read -r item; do
    [ -n "$item" ] || continue
    rm -rf "$root/$item" || return 5
  done <<< "$ids"
  ok "non-adopt archive buckets 접기: $count bucket(s) → ${archive_file#$TARGET/}"
  return 0
}

surface_cleanup_date_key_upgrade() {
  local name="${1:-}"
  case "$name" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*)
      printf '%s\n' "$(printf '%s' "$name" | sed -E 's/^([0-9]{4})-([0-9]{2})-([0-9]{2}).*/\1\2\3/')"
      return 0
      ;;
    [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*)
      printf '%s\n' "$(printf '%s' "$name" | sed -E 's/^([0-9]{8}).*/\1/')"
      return 0
      ;;
  esac
  return 1
}

consolidate_surface_cleanup_archives() {
  local root="$TARGET/.sfs-local/archives/adopt/surface-cleanup"
  local dates date dir name key staging bundle_dir bundle_file manifest moved total=0
  [ -d "$root" ] || return 0

  dates="$(
    find "$root" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null \
      | while IFS= read -r dir; do
          name="$(basename "$dir")"
          printf '%s\n' "$name" | grep -Eq '^[0-9]{8}$' && continue
          key="$(surface_cleanup_date_key_upgrade "$name" || true)"
          [ -n "$key" ] && printf '%s\n' "$key"
        done \
      | sort -u
  )"
  [ -n "$dates" ] || return 0

  while IFS= read -r date; do
    [ -n "$date" ] || continue
    staging="$(mktemp -d "$root/.consolidate-${date}.XXXXXX")" || return 5
    bundle_dir="$root/$date"
    bundle_file="$bundle_dir/surface-cleanup.tar.gz"
    manifest="$bundle_dir/manifest.txt"
    moved=0

    if [ -f "$bundle_file" ]; then
      tar -xzf "$bundle_file" -C "$staging" || {
        rm -rf "$staging"
        return 5
      }
    fi

    for dir in "$root"/*; do
      [ -d "$dir" ] || continue
      name="$(basename "$dir")"
      [ "$name" = "$date" ] && continue
      key="$(surface_cleanup_date_key_upgrade "$name" || true)"
      [ "$key" = "$date" ] || continue
      mv "$dir" "$staging/$name" || {
        rm -rf "$staging"
        return 5
      }
      moved=$((moved + 1))
    done

    if [ "$moved" -gt 0 ]; then
      mkdir -p "$bundle_dir" || {
        rm -rf "$staging"
        return 5
      }
      tar -czf "$bundle_file" -C "$staging" . || {
        rm -rf "$staging"
        return 5
      }
      {
        echo "SFS daily surface cleanup bundle"
        echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "date: $date"
        echo "reason: small same-day surface-cleanup evidence is consolidated to avoid visible archive clutter"
        echo "archive: ${bundle_file#$TARGET/}"
        echo "new_run_dirs_consolidated: $moved"
        echo "contents: run directories inside surface-cleanup.tar.gz"
      } > "$manifest" || {
        rm -rf "$staging"
        return 5
      }
      total=$((total + moved))
    fi
    rm -rf "$staging" || return 5
  done <<< "$dates"

  if [ "$total" -gt 0 ]; then
    ok "surface-cleanup daily bundle 정리: $total run dir(s) → .sfs-local/archives/adopt/surface-cleanup/<yyyyMMdd>/surface-cleanup.tar.gz"
  fi
  return 0
}

json_escape_upgrade() {
  printf '%s' "${1:-}" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

upgrade_event_json_string_field() {
  local field="${1:?field required}" line="${2:-}"
  printf '%s\n' "$line" | sed -nE 's/.*"'"$field"'"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p'
}

upgrade_event_same_compaction_key() {
  local existing="${1:-}" event_type="${2:?event type required}" sid="${3:-}" gate="${4:-}" division="${5:-}" decision="${6:-}" wu="${7:-}"
  case "$existing" in
    *"\"type\":\"$event_type\""*) ;;
    *) return 1 ;;
  esac
  if [ -n "$sid" ]; then
    case "$existing" in *"\"sprint_id\":\"$sid\""*) ;; *) return 1 ;; esac
  fi
  if [ -n "$gate" ]; then
    case "$existing" in *"\"gate_id\":\"$gate\""*) ;; *) return 1 ;; esac
  fi
  if [ -n "$division" ]; then
    case "$existing" in *"\"division\":\"$division\""*) ;; *) return 1 ;; esac
  fi
  if [ -n "$decision" ]; then
    case "$existing" in *"\"decision_id\":\"$decision\""*) ;; *) return 1 ;; esac
  fi
  if [ -n "$wu" ]; then
    case "$existing" in *"\"wu_id\":\"$wu\""*) ;; *) return 1 ;; esac
  fi
  return 0
}

upgrade_active_event_ledger_sprint() {
  local current_sprint=""
  if [ -f "$TARGET/.sfs-local/current-sprint" ]; then
    current_sprint="$(sed -n '1p' "$TARGET/.sfs-local/current-sprint" 2>/dev/null | tr -d '[:space:]' || true)"
  fi
  if [ -n "$current_sprint" ] && [ -d "$TARGET/.sfs-local/sprints/$current_sprint" ]; then
    printf '%s\n' "$current_sprint"
  fi
}

upgrade_event_line_belongs_to_active_sprint() {
  local line="${1:-}" active_sid="${2:-}" sid
  [ -n "$active_sid" ] || return 1
  sid="$(upgrade_event_json_string_field "sprint_id" "$line")"
  [ -n "$sid" ] && [ "$sid" = "$active_sid" ]
}

write_compact_upgrade_event_line() {
  local events_file="${1:?events file required}" line="${2:?line required}"
  local event_type sid gate division decision wu active_sid tmp existing
  event_type="$(upgrade_event_json_string_field "type" "$line")"
  sid="$(upgrade_event_json_string_field "sprint_id" "$line")"
  gate="$(upgrade_event_json_string_field "gate_id" "$line")"
  division="$(upgrade_event_json_string_field "division" "$line")"
  decision="$(upgrade_event_json_string_field "decision_id" "$line")"
  wu="$(upgrade_event_json_string_field "wu_id" "$line")"
  active_sid="$(upgrade_active_event_ledger_sprint)"
  if ! upgrade_event_line_belongs_to_active_sprint "$line" "$active_sid"; then
    return 0
  fi
  tmp="${events_file}.tmp.$$"
  : > "$tmp" || return 5
  if [ -f "$events_file" ]; then
    while IFS= read -r existing || [ -n "$existing" ]; do
      [ -n "$existing" ] || continue
      if ! upgrade_event_line_belongs_to_active_sprint "$existing" "$active_sid"; then
        continue
      fi
      if [ -n "$event_type" ] && upgrade_event_same_compaction_key "$existing" "$event_type" "$sid" "$gate" "$division" "$decision" "$wu"; then
        continue
      fi
      printf '%s\n' "$existing" >> "$tmp" || return 5
    done < "$events_file"
  fi
  printf '%s\n' "$line" >> "$tmp" || return 5
  mv -f "$tmp" "$events_file" || return 5
}

compact_upgrade_event_ledger() {
  local events_file="$TARGET/.sfs-local/events.jsonl" tmp line before after removed
  [ -f "$events_file" ] || return 0
  before="$(wc -l < "$events_file" 2>/dev/null | tr -d '[:space:]' || printf '0')"
  tmp="${events_file}.compact.$$"
  : > "$tmp" || return 5
  while IFS= read -r line || [ -n "$line" ]; do
    [ -n "$line" ] || continue
    write_compact_upgrade_event_line "$tmp" "$line" || return 5
  done < "$events_file"
  after="$(wc -l < "$tmp" 2>/dev/null | tr -d '[:space:]' || printf '0')"
  if [ "${after:-0}" -eq 0 ]; then
    rm -f "$tmp" "$events_file" || return 5
  else
    mv -f "$tmp" "$events_file" || return 5
  fi
  removed=$((before - after))
  if [ "$removed" -gt 0 ]; then
    ok "active event ledger 정리: $removed stale/duplicate line(s) 제거"
  fi
  return 0
}

append_upgrade_event() {
  local event_type="${1:?event type required}" fields="${2:-}"
  local events_file="$TARGET/.sfs-local/events.jsonl"
  local now line
  [ -f "$events_file" ] || return 0
  now="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"
  if [ -n "$fields" ]; then
    fields=",${fields#,}"
  fi
  line="$(printf '{"ts":"%s","type":"%s"%s}' "$now" "$(json_escape_upgrade "$event_type")" "$fields")"
  write_compact_upgrade_event_line "$events_file" "$line" || return 5
  return 0
}

strip_frontmatter_body() {
  awk '
    NR == 1 && $0 == "---" { in_fm=1; next }
    in_fm && $0 == "---" { in_fm=0; next }
    !in_fm { print }
  ' "$1"
}

migrate_legacy_adopt_visible_sprints() {
  local sprints_dir="$TARGET/.sfs-local/sprints"
  local report sprint_dir sid now safe_ts shared_dir shared_doc archive_dir archive_file manifest staging
  local current_sprint count=0 esc_sid esc_shared esc_archive
  [ -d "$sprints_dir" ] || return 0

  now="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"
  safe_ts="${now//:/-}"
  safe_ts="${safe_ts//+/-}"
  current_sprint=""
  if [ -f "$TARGET/.sfs-local/current-sprint" ]; then
    current_sprint="$(sed -n '1p' "$TARGET/.sfs-local/current-sprint" 2>/dev/null | tr -d '[:space:]' || true)"
  fi

  for report in "$sprints_dir"/*/report.md; do
    [ -f "$report" ] || continue
    sprint_dir="$(dirname "$report")"
    sid="$(basename "$sprint_dir")"
    if [ "$sid" != "legacy-baseline" ] \
      && ! grep -Eq 'status:[[:space:]]*"?legacy-baseline"?|Legacy Baseline Intake|Solon Adoption Summary' "$report" 2>/dev/null; then
      continue
    fi

    date_dir="$(printf '%s\n' "$now" | sed -nE 's/^([0-9]{4})-([0-9]{2})-([0-9]{2}).*/\1\2\3/p')"
    [ -n "$date_dir" ] || date_dir="$(date +%Y%m%d 2>/dev/null || date -u +%Y%m%d)"
    shared_dir="$TARGET/docs/solon/$sid/$date_dir"
    shared_doc="$shared_dir/handoff.md"
    archive_dir="$TARGET/.sfs-local/archives/adopt/$sid/${safe_ts}-visible-sprint-migration"
    archive_file="$archive_dir/visible-sprint-workspace.tar.gz"
    manifest="$archive_dir/manifest.txt"

    mkdir -p "$shared_dir" "$archive_dir" || return 5
    if [ ! -f "$shared_doc" ]; then
      {
        echo "---"
        echo "title: \"Solon Adoption Summary\""
        echo "status: legacy-baseline"
        echo "adopt_id: \"$(json_escape_upgrade "$sid")\""
        echo "created_at: \"$now\""
        echo "last_touched_at: \"$now\""
        echo "source: \"legacy .sfs-local adoption report migration\""
        echo "confidence: \"mixed\""
        echo "---"
        echo
        echo "# Solon Adoption Summary - $sid"
        echo
        echo "> Migrated from \`.sfs-local/sprints/$sid/report.md\` during \`sfs upgrade\`."
        echo "> Raw legacy sprint files are preserved in the private cold archive listed below."
        echo
        echo "- **Archive**: \`${archive_file#$TARGET/}\`"
        echo "- **Manifest**: \`${manifest#$TARGET/}\`"
        echo
        echo "## Original Legacy Report"
        echo
        strip_frontmatter_body "$report"
      } > "$shared_doc" || return 5
    fi

    staging="$(mktemp -d "$archive_dir/.stage.XXXXXX")" || return 5
    mkdir -p "$staging/.sfs-local/sprints" || return 5
    cp -R "$sprint_dir" "$staging/.sfs-local/sprints/$sid" || return 5
    {
      echo "SFS legacy adopt visible sprint migration"
      echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      echo "sprint_id: $sid"
      echo "shared_doc: ${shared_doc#$TARGET/}"
      echo "archive: ${archive_file#$TARGET/}"
      echo
      echo "policy:"
      echo "- shared adoption handoff lives in docs/solon/<english-workspace>/<yyyyMMdd>"
      echo "- old visible legacy-baseline workbench is private cold history"
      echo
      echo "items:"
      find "$staging" -type f 2>/dev/null | sort | while IFS= read -r staged; do
        printf -- "- %s\n" "${staged#$staging/}"
      done
    } > "$manifest" || return 5
    tar -czf "$archive_file" -C "$staging" . || return 5
    rm -rf "$staging" || return 5
    rm -rf "$sprint_dir" || return 5
    if [ "$current_sprint" = "$sid" ]; then
      rm -f "$TARGET/.sfs-local/current-sprint" || return 5
    fi

    esc_sid="$(json_escape_upgrade "$sid")"
    esc_shared="$(json_escape_upgrade "${shared_doc#$TARGET/}")"
    esc_archive="$(json_escape_upgrade "${archive_file#$TARGET/}")"
    append_upgrade_event "legacy_adopt_surface_migrated" "\"sprint_id\":\"$esc_sid\",\"shared_doc\":\"$esc_shared\",\"archive\":\"$esc_archive\"" || return 5
    count=$((count + 1))
  done

  if [ "$count" -gt 0 ]; then
    ok "legacy adopt visible sprint 이관: $count sprint(s) → docs/solon/<english-workspace>/<yyyyMMdd>"
  fi
  return 0
}

sprint_has_phase_event() {
  local sid="${1:?sprint id required}" events_file="$TARGET/.sfs-local/events.jsonl"
  local esc
  [ -f "$events_file" ] || return 1
  esc="$(json_escape_upgrade "$sid")"
  grep -E '"type":"(brainstorm_open|plan_open|implement_open|review_open|retro_open|report_ready|tidy_apply|sprint_close)"' "$events_file" 2>/dev/null \
    | grep -F "\"sprint_id\":\"$esc\"" >/dev/null 2>&1
}

compact_prefilled_step_doc_residue() {
  local sprints_dir="$TARGET/.sfs-local/sprints"
  local now safe_ts archive_root sprint_dir sid report path doc staging archive_file manifest
  local current_sprint count total=0 esc_sid esc_archive
  local source_paths=()
  [ -d "$sprints_dir" ] || return 0

  now="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"
  safe_ts="${now//:/-}"
  safe_ts="${safe_ts//+/-}"
  archive_root="$TARGET/.sfs-local/archives/runtime-migrations/${safe_ts}-prefilled-step-docs"
  current_sprint=""
  if [ -f "$TARGET/.sfs-local/current-sprint" ]; then
    current_sprint="$(sed -n '1p' "$TARGET/.sfs-local/current-sprint" 2>/dev/null | tr -d '[:space:]' || true)"
  fi

  for sprint_dir in "$sprints_dir"/*; do
    [ -d "$sprint_dir" ] || continue
    sid="$(basename "$sprint_dir")"
    [ "$sid" = "legacy-baseline" ] && continue
    report="$sprint_dir/report.md"
    [ ! -f "$report" ] || continue
    if sprint_has_phase_event "$sid"; then
      continue
    fi

    source_paths=()
    for doc in brainstorm plan implement log review retro; do
      path="$sprint_dir/$doc.md"
      [ -f "$path" ] || continue
      source_paths+=("$path")
    done
    count="${#source_paths[@]}"
    [ "$count" -gt 0 ] || continue

    mkdir -p "$archive_root" || return 5
    staging="$(mktemp -d "$archive_root/.stage.${sid}.XXXXXX")" || return 5
    mkdir -p "$staging/.sfs-local/sprints/$sid" || return 5
    for path in "${source_paths[@]}"; do
      cp "$path" "$staging/.sfs-local/sprints/$sid/$(basename "$path")" || return 5
    done

    archive_file="$archive_root/${sid}-step-docs.tar.gz"
    manifest="$archive_root/${sid}-manifest.txt"
    {
      echo "SFS prefilled step-doc residue migration"
      echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      echo "sprint_id: $sid"
      echo "archive: ${archive_file#$TARGET/}"
      echo "step_docs: $count"
      echo
      echo "reason:"
      echo "- this sprint has no phase events and no report.md"
      echo "- old runtimes pre-created step docs at start; new runtimes create them lazily"
      echo "- archived files are recoverable cold history, not active reading surface"
      echo
      echo "items:"
      find "$staging" -type f 2>/dev/null | sort | while IFS= read -r staged; do
        printf -- "- %s\n" "${staged#$staging/}"
      done
    } > "$manifest" || return 5
    tar -czf "$archive_file" -C "$staging" . || return 5
    rm -rf "$staging" || return 5

    for path in "${source_paths[@]}"; do
      rm -f "$path" || return 5
    done
    if [ "$sid" != "$current_sprint" ]; then
      rmdir "$sprint_dir" 2>/dev/null || true
    fi

    esc_sid="$(json_escape_upgrade "$sid")"
    esc_archive="$(json_escape_upgrade "${archive_file#$TARGET/}")"
    append_upgrade_event "prefilled_step_docs_compacted" "\"sprint_id\":\"$esc_sid\",\"archive\":\"$esc_archive\",\"step_docs\":$count" || return 5
    total=$((total + count))
  done

  if [ "$total" -gt 0 ]; then
    ok "prefilled step docs 정리: $total file(s) → ${archive_root#$TARGET/}"
  else
    rmdir "$archive_root" 2>/dev/null || true
  fi
  return 0
}

prune_legacy_gitkeep_placeholders() {
  local dir count=0
  for dir in \
    "$TARGET/.sfs-local/sprints" \
    "$TARGET/.sfs-local/decisions" \
    "$TARGET/.sfs-local/queue/pending" \
    "$TARGET/.sfs-local/queue/claimed" \
    "$TARGET/.sfs-local/queue/done" \
    "$TARGET/.sfs-local/queue/failed" \
    "$TARGET/.sfs-local/queue/abandoned" \
    "$TARGET/.sfs-local/queue/runs"; do
    [ -f "$dir/.gitkeep" ] || continue
    rm -f "$dir/.gitkeep" 2>/dev/null || return 5
    count=$((count + 1))
  done
  find "$TARGET/.sfs-local/queue" -depth -type d -empty -exec rmdir {} \; 2>/dev/null || true
  rmdir "$TARGET/.sfs-local/sprints" "$TARGET/.sfs-local/decisions" 2>/dev/null || true
  if [ "$count" -gt 0 ]; then
    ok "legacy .gitkeep placeholder 정리: $count file(s)"
  fi
  return 0
}

thin_project_agent_adapter_migration() {
  [ "${INSTALL_LAYOUT:-vendored}" = "thin" ] || return 0
  case "${SFS_KEEP_PROJECT_AGENT_ADAPTERS:-0}" in
    1|true|TRUE|yes|YES)
      ok "thin project-local agent adapters 유지: SFS_KEEP_PROJECT_AGENT_ADAPTERS=${SFS_KEEP_PROJECT_AGENT_ADAPTERS}"
      return 0
      ;;
  esac

  local archive_dir archive_file manifest staging rel file count=0
  local -a adapter_files=(
    ".claude/commands/sfs.md"
    ".claude/skills/sfs/SKILL.md"
    ".gemini/commands/sfs.toml"
    ".agents/skills/sfs/SKILL.md"
  )

  for rel in "${adapter_files[@]}"; do
    [ -f "$TARGET/$rel" ] && count=$((count + 1))
  done
  [ "$count" -gt 0 ] || return 0

  archive_dir="$TARGET/.sfs-local/archives/runtime-migrations/$(date +%Y%m%d-%H%M%S)-project-agent-adapters"
  archive_file="$archive_dir/project-agent-adapters.tar.gz"
  manifest="$archive_dir/manifest.txt"
  mkdir -p "$archive_dir" || return 5
  staging="$(mktemp -d "$archive_dir/.stage.XXXXXX")" || return 5

  for rel in "${adapter_files[@]}"; do
    file="$TARGET/$rel"
    [ -f "$file" ] || continue
    mkdir -p "$staging/$(dirname "$rel")" || return 5
    cp "$file" "$staging/$rel" || return 5
  done

  {
    echo "SFS thin project agent adapter migration"
    echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "reason: thin layout keeps managed agent command/skill adapters in the packaged runtime by default"
    echo "archive: $archive_file"
    echo "count: $count"
    echo
    echo "policy:"
    echo "- root CLAUDE.md / AGENTS.md / GEMINI.md remain as project-facing agent instructions"
    echo "- project-scoped slash/skill files are optional and can be reinstalled with: sfs agent install all"
    echo "- set SFS_KEEP_PROJECT_AGENT_ADAPTERS=1 before upgrade to keep existing project-scoped adapter files"
    echo
    echo "items:"
    find "$staging" -type f 2>/dev/null | sort | while IFS= read -r staged; do
      printf -- "- %s\n" "${staged#$staging/}"
    done
  } > "$manifest" || return 5

  tar -czf "$archive_file" -C "$staging" . || return 5
  rm -rf "$staging" || return 5

  for rel in "${adapter_files[@]}"; do
    rm -f "$TARGET/$rel" 2>/dev/null || return 5
  done
  rmdir "$TARGET/.claude/commands" "$TARGET/.claude/skills/sfs" "$TARGET/.claude/skills" "$TARGET/.claude" 2>/dev/null || true
  rmdir "$TARGET/.gemini/commands" "$TARGET/.gemini" 2>/dev/null || true
  rmdir "$TARGET/.agents/skills/sfs" "$TARGET/.agents/skills" "$TARGET/.agents" 2>/dev/null || true

  ok "thin project agent adapters 이관: $count files → ${archive_file#$TARGET/}"
  ok "  필요 시 opt-in 재설치: sfs agent install all"
  return 0
}

thin_project_runtime_asset_migration() {
  [ "${INSTALL_LAYOUT:-vendored}" = "thin" ] || return 0
  case "${SFS_KEEP_PROJECT_RUNTIME_ASSETS:-0}" in
    1|true|TRUE|yes|YES)
      ok "thin project-local runtime assets 유지: SFS_KEEP_PROJECT_RUNTIME_ASSETS=${SFS_KEEP_PROJECT_RUNTIME_ASSETS}"
      return 0
      ;;
  esac

  local archive_dir archive_file manifest staging rel path count=0
  local -a asset_paths=(
    ".sfs-local/GUIDE.md"
    ".sfs-local/scripts"
    ".sfs-local/sprint-templates"
    ".sfs-local/personas"
    ".sfs-local/decisions-template"
  )

  for rel in "${asset_paths[@]}"; do
    path="$TARGET/$rel"
    if [ -f "$path" ]; then
      count=$((count + 1))
    elif [ -d "$path" ]; then
      count=$((count + $(find "$path" -type f 2>/dev/null | wc -l | tr -d '[:space:]')))
    fi
  done
  [ "${count:-0}" -gt 0 ] || return 0

  archive_dir="$TARGET/.sfs-local/archives/runtime-migrations/$(date +%Y%m%d-%H%M%S)-project-runtime-assets"
  archive_file="$archive_dir/project-runtime-assets.tar.gz"
  manifest="$archive_dir/manifest.txt"
  mkdir -p "$archive_dir" || return 5
  staging="$(mktemp -d "$archive_dir/.stage.XXXXXX")" || return 5

  for rel in "${asset_paths[@]}"; do
    path="$TARGET/$rel"
    [ -e "$path" ] || continue
    mkdir -p "$staging/$(dirname "$rel")" || return 5
    cp -R "$path" "$staging/$rel" || return 5
  done

  {
    echo "SFS thin project runtime asset migration"
    echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "reason: global sfs upgrade converts managed runtime assets out of the project surface"
    echo "archive: $archive_file"
    echo "count: $count"
    echo
    echo "policy:"
    echo "- sprint/decision/event state stays project-local"
    echo "- managed scripts/templates/personas/GUIDE move to packaged runtime"
    echo "- set SFS_KEEP_PROJECT_RUNTIME_ASSETS=1 before upgrade to keep project-local runtime assets"
    echo
    echo "items:"
    find "$staging" -type f 2>/dev/null | sort | while IFS= read -r staged; do
      printf -- "- %s\n" "${staged#$staging/}"
    done
  } > "$manifest" || return 5

  tar -czf "$archive_file" -C "$staging" . || return 5
  rm -rf "$staging" || return 5

  rm -f "$TARGET/.sfs-local/GUIDE.md" 2>/dev/null || return 5
  rm -rf "$TARGET/.sfs-local/scripts" \
         "$TARGET/.sfs-local/sprint-templates" \
         "$TARGET/.sfs-local/personas" \
         "$TARGET/.sfs-local/decisions-template" 2>/dev/null || return 5

  ok "thin project runtime assets 이관: $count files → ${archive_file#$TARGET/}"
  return 0
}

project_surface_archive_migrations() {
  migrate_legacy_adopt_visible_sprints || return 5
  compact_prefilled_step_doc_residue || return 5
  prune_legacy_gitkeep_placeholders || return 5
  compact_legacy_runtime_upgrade_archives || return 5
  compact_legacy_agent_install_archives || return 5
  compact_legacy_sprint_archive_dirs || return 5
  compact_legacy_review_run_archives || return 5
  compact_legacy_tmp_artifacts || return 5
  archive_stale_auth_env_example || return 5
  cleanup_transient_cache_and_placeholder_auth || return 5
  cleanup_orphan_event_ledger || return 5
  compact_upgrade_event_ledger || return 5
  cleanup_empty_workbench_surface_dirs || return 5
  thin_project_runtime_asset_migration || return 5
  thin_project_agent_adapter_migration || return 5
  collapse_non_adopt_archive_dirs || return 5
  consolidate_surface_cleanup_archives || return 5
  return 0
}

# ============================================================================
# 2. 버전 비교
# ============================================================================

NEW_VER=$(cat "$SOURCE_DIR/VERSION" 2>/dev/null | head -1 || echo "unknown")

if [ ! -f "$TARGET/.sfs-local/VERSION" ]; then
  cat >&2 <<EOF
Solon CLI is installed, but this project is not initialized yet.

Current directory:
  $TARGET

First-time project setup:
  sfs init --yes
  sfs status
  sfs guide

What this means:
  brew install MJ-0701/solon-product/sfs  installs the global sfs CLI on this Mac.
  sfs init --yes                          injects SFS.md, root agent docs, and .sfs-local/ state into this project.
  sfs upgrade                             upgrades the global CLI first, then refreshes this project.

Tip:
  If this folder is not a git repo yet, sfs init --yes will run git init for you.
EOF
  exit 1
fi

CUR_VER=$(grep '^solon_mvp_version:' "$TARGET/.sfs-local/VERSION" | awk '{print $2}')
INSTALLED_AT=$(grep '^installed_at:' "$TARGET/.sfs-local/VERSION" | awk '{print $2}')
RECORDED_INSTALL_LAYOUT=$(grep '^install_layout:' "$TARGET/.sfs-local/VERSION" 2>/dev/null | awk '{print $2}')
CONFIG_INSTALL_LAYOUT=""
if [ -f "$TARGET/.sfs-local/config.yaml" ]; then
  CONFIG_INSTALL_LAYOUT=$(awk '
    /^runtime:/ {in_runtime=1; next}
    /^[^[:space:]]/ {in_runtime=0}
    in_runtime && /^[[:space:]]*layout:/ {
      gsub(/["'\'']/, "", $2)
      print $2
      exit
    }
  ' "$TARGET/.sfs-local/config.yaml" 2>/dev/null || true)
fi
case "${UPGRADE_LAYOUT:-}" in
  thin|vendored)
    INSTALL_LAYOUT="$UPGRADE_LAYOUT"
    ;;
  *)
    INSTALL_LAYOUT="${RECORDED_INSTALL_LAYOUT:-${CONFIG_INSTALL_LAYOUT:-vendored}}"
    ;;
esac
case "$INSTALL_LAYOUT" in
  thin|vendored) ;;
  *)
    warn "알 수 없는 기존 install_layout='$INSTALL_LAYOUT' — vendored 로 처리"
    INSTALL_LAYOUT="vendored"
    ;;
esac

print_agent_implementation_mode_contract() {
  cat <<EOF
Agent implementation mode:
  기본 구현 모드는 single-agent 입니다.
  병렬 agent 구현은 명시적으로 선택할 때만 사용합니다:
  ${C_BLUE}sfs implement --agent-mode parallel --agents codex,claude[,gemini] "<work slice>"${C_RESET}
  parallel lane 은 disjoint files_scope, AC/ADR subset ownership, expected tests/evidence,
  output report path, merge/conflict policy, lane-level verification,
  native/workspace-language one-sentence commit message, 그리고 Gate 6 PASS 전 agent cross review 가 필요합니다.
EOF
}

cat <<EOF

${C_BOLD}=== Solon Product Upgrade ===${C_RESET}

현재 설치:   $CUR_VER  (installed: $INSTALLED_AT)
최신 배포:   $NEW_VER
소스 모드:   $MODE
layout:      $INSTALL_LAYOUT
layout from: $([ -n "${UPGRADE_LAYOUT:-}" ] && echo "upgrade request" || echo "project metadata")

EOF

# llm-wiki/ scaffold (WMU-2) — existing consumers materialize the vault on upgrade
# too (not init-only). Runs before the version branch so it covers both the
# already-latest path and a version-bump apply. Idempotent + opt-out aware:
#   - skip-if-exists: existing vault preserved.
#   - .sfs-local/llm-wiki.waiver present → respect prior opt-out, do not reinstall.
#   - SFS_INSTALL_LLM_WIKI=0 → record waiver, no copy.
#   - otherwise (recommended-default) → install.
LLM_WIKI_SRC="$SOURCE_DIR/templates/.sfs-local-template/llm-wiki"
if [ -d "$LLM_WIKI_SRC" ]; then
  if [ -d "$TARGET/llm-wiki" ]; then
    :
  elif [ -f "$TARGET/.sfs-local/llm-wiki.waiver" ]; then
    :
  else
    case "${SFS_INSTALL_LLM_WIKI:-}" in
      0|false|FALSE|no|NO|off|OFF)
        mkdir -p "$TARGET/.sfs-local"
        printf 'declined_at=%s\nreason=user-opt-out-at-upgrade\n' \
          "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$TARGET/.sfs-local/llm-wiki.waiver"
        ;;
      *)
        mkdir -p "$TARGET/llm-wiki"
        cp -R "$LLM_WIKI_SRC"/. "$TARGET/llm-wiki/" 2>/dev/null || true
        ok "llm-wiki/ 지식 vault skeleton 설치 (upgrade; 수동 유지, generator 미동반)"
        ;;
    esac
  fi
fi

if [ "$CUR_VER" = "$NEW_VER" ]; then
  MODEL_PROFILE_REPAIRED=0
  if [ ! -f "$TARGET/.sfs-local/model-profiles.yaml" ] \
     && [ -f "$SOURCE_DIR/templates/.sfs-local-template/model-profiles.yaml" ]; then
    create_default_model_profile current solon_recommended default_applied
    ok "model-profiles.yaml 누락 감지 — solon_recommended 기본 role routing 으로 생성"
    MODEL_PROFILE_REPAIRED=1
  elif grep -q 'status: "current_model_fallback"' "$TARGET/.sfs-local/model-profiles.yaml" 2>/dev/null \
    || grep -q 'selected_runtime: "unset"' "$TARGET/.sfs-local/model-profiles.yaml" 2>/dev/null; then
    set_model_profile_fields "current" "solon_recommended" "default_applied" "sfs upgrade" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    ok "agent model profile fallback 감지 — solon_recommended 기본 role routing 으로 전환"
  elif grep -q 'status: "review_required"' "$TARGET/.sfs-local/model-profiles.yaml" 2>/dev/null; then
    warn "agent model profile 이 review_required 상태입니다."
  fi
  warn_model_profiles_drift "$TARGET/.sfs-local/model-profiles.yaml" "solon_recommended"
  if [ "${INSTALL_LAYOUT:-vendored}" = "thin" ]; then
    thin_context_runtime_migration || die "thin runtime context migration failed"
  else
    repair_missing_context_router_targets
    verify_context_router_targets || die "context router index references missing files"
  fi
  project_surface_archive_migrations || die "legacy archive surface migration failed"
  maybe_prompt_model_profile
  print_agent_implementation_mode_contract
  ok "이미 최신 버전. 업그레이드 불필요."
  if [ "$MODEL_PROFILE_REPAIRED" -eq 1 ]; then
    warn "새 파일을 추가했으니 프로젝트 repo 에서 commit 여부를 확인하세요: .sfs-local/model-profiles.yaml"
  fi
  exit 0
fi

# ============================================================================
# 3. Dry-run 프리뷰 — 어떤 파일이 바뀌나
# ============================================================================

info ""
info "변경 예정 파일 프리뷰..."

checksum_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print substr($1, 1, 12)}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print substr($1, 1, 12)}'
  else
    cksum "$file" | awk '{print $1}'
  fi
}

recommend_action() {
  local dst_rel="$1" exists="$2" same="$3"

  if [ "${INSTALL_LAYOUT:-vendored}" = "thin" ]; then
    case "$dst_rel" in
      .sfs-local/context/*|.sfs-local/context/commands/*|.sfs-local/context/policies/*)
        if [ "$exists" = "yes" ]; then
          printf "migrate to packaged runtime"
        else
          printf "skip (packaged runtime)"
        fi
        return 0
        ;;
      ".sfs-local/GUIDE.md"|.sfs-local/scripts/*|.sfs-local/sprint-templates/*|.sfs-local/personas/*|.sfs-local/decisions-template/*)
        printf "skip (thin runtime)"
        return 0
        ;;
      ".claude/skills/sfs/SKILL.md"|".claude/commands/sfs.md"|".gemini/commands/sfs.toml"|".agents/skills/sfs/SKILL.md")
        if [ "$exists" = "yes" ]; then
          printf "migrate to packaged runtime"
        else
          printf "skip (opt-in agent adapter)"
        fi
        return 0
        ;;
    esac
  fi

  if [ "$same" = "yes" ]; then
    printf "없음"
    return 0
  fi
  if [ "$exists" = "no" ]; then
    printf "install"
    return 0
  fi

  case "$dst_rel" in
    ".claude/skills/sfs/SKILL.md"|".claude/commands/sfs.md"|".gemini/commands/sfs.toml"|".agents/skills/sfs/SKILL.md"|".sfs-local/GUIDE.md")
      printf "backup+overwrite"
      ;;
    "SFS.md")
      printf "thin-router refactor"
      ;;
    "CLAUDE.md"|"AGENTS.md"|"GEMINI.md"|".sfs-local/divisions.yaml"|".sfs-local/model-profiles.yaml")
      printf "skip"
      ;;
    .sfs-local/context/*.md|.sfs-local/context/commands/*.md|.sfs-local/context/policies/*.md)
      printf "backup+overwrite"
      ;;
    .sfs-local/scripts/*.sh|.sfs-local/scripts/*.ps1)
      # Solon-versioned runtime code, user 수정 영역 아님
      printf "backup+overwrite"
      ;;
    .sfs-local/sprint-templates/*.md|.sfs-local/decisions-template/*.md|.sfs-local/personas/*.md)
      # 배포판 관리 템플릿, user 수정 영역 아님 (install.sh 정책 정합)
      printf "backup+overwrite"
      ;;
    *)
      printf "skip"
      ;;
  esac
}

cat <<EOF

읽는 법:
  - checksum 동일       → 변경 없음
  - 기존 없음          → 자동 신규 설치
  - checksum 다름      → 자동 정책에 따라 갱신 또는 보존

자동 처리 정책:
  - 신규 파일                          → 자동 설치
  - checksum 동일                      → 변경 없음
  - SFS.md                             → 비대화 감지 시 archive+thin-router refactor (프로젝트 개요 보존)
  - CLAUDE/AGENTS/GEMINI.md            → 자동 보존 (기존 프로젝트 지침 보호)
  - .sfs-local/divisions.yaml          → 자동 보존 (프로젝트별 운영값 보호)
  - .sfs-local/model-profiles.yaml     → 없으면 설치 + 설정 안내, 있으면 자동 보존 (agent별 모델 설정 보호)
  - .sfs-local/auth.env.example        → project copy removed (샘플은 packaged runtime 에만 유지)
  - .sfs-local/context/**/*.md         → thin: packaged runtime 으로 이관, vendored: backup+overwrite
  - .claude/.gemini/.agents command/skill → thin: 압축 이관 후 제거, vendored/opt-in: backup+overwrite
  - .sfs-local/scripts/sfs-*.sh        → backup+overwrite (Solon-versioned bash)
  - .sfs-local/scripts/sfs.ps1         → backup+overwrite (Windows PowerShell → Git Bash wrapper)
  - .sfs-local/sprint-templates/*.md   → backup+overwrite (배포판 관리 템플릿)
  - .sfs-local/personas/*.md           → backup+overwrite (CEO/CTO/worker/CPO 기본 persona)
  - .sfs-local/decisions-template/*.md → backup+overwrite (ADR-TEMPLATE 신규, WU-26)

EOF

# diff 보여줄 파일 (codex finding #4 후속, 25th-6 zen-magical-feynman 보강)
# 0.4.0-mvp 이상 = sfs-loop / sfs-decision / sfs-retro / decision-light template +
#                  ADR-TEMPLATE 신규 슬롯 cover.
declare -a CHECK_FILES=(
  "SFS.md|templates/SFS.md.template"
  "CLAUDE.md|templates/CLAUDE.md.template"
  "AGENTS.md|templates/AGENTS.md.template"
  "GEMINI.md|templates/GEMINI.md.template"
  ".claude/skills/sfs/SKILL.md|templates/.claude/commands/sfs.md"
  ".claude/commands/sfs.md|templates/.claude/commands/sfs.md"
  ".sfs-local/divisions.yaml|templates/.sfs-local-template/divisions.yaml"
  ".sfs-local/model-profiles.yaml|templates/.sfs-local-template/model-profiles.yaml"
  # context/ modules are appended dynamically from templates/.sfs-local-template/context
  # below so new routed policies cannot be missed by a hard-coded upgrade list.
  ".sfs-local/GUIDE.md|GUIDE.md"
  # scripts/ — Solon-versioned bash adapters (executable, user 수정 영역 아님)
  ".sfs-local/scripts/sfs-dispatch.sh|templates/.sfs-local-template/scripts/sfs-dispatch.sh"
  ".sfs-local/scripts/sfs.ps1|templates/.sfs-local-template/scripts/sfs.ps1"
  ".sfs-local/scripts/sfs-common.sh|templates/.sfs-local-template/scripts/sfs-common.sh"
  ".sfs-local/scripts/sfs-status.sh|templates/.sfs-local-template/scripts/sfs-status.sh"
  ".sfs-local/scripts/sfs-start.sh|templates/.sfs-local-template/scripts/sfs-start.sh"
  ".sfs-local/scripts/sfs-guide.sh|templates/.sfs-local-template/scripts/sfs-guide.sh"
  ".sfs-local/scripts/sfs-auth.sh|templates/.sfs-local-template/scripts/sfs-auth.sh"
  ".sfs-local/scripts/sfs-adopt.sh|templates/.sfs-local-template/scripts/sfs-adopt.sh"
  ".sfs-local/scripts/sfs-brainstorm.sh|templates/.sfs-local-template/scripts/sfs-brainstorm.sh"
  ".sfs-local/scripts/sfs-plan.sh|templates/.sfs-local-template/scripts/sfs-plan.sh"
  ".sfs-local/scripts/sfs-implement.sh|templates/.sfs-local-template/scripts/sfs-implement.sh"
  ".sfs-local/scripts/sfs-review.sh|templates/.sfs-local-template/scripts/sfs-review.sh"
  ".sfs-local/scripts/sfs-decision.sh|templates/.sfs-local-template/scripts/sfs-decision.sh"
  ".sfs-local/scripts/sfs-report.sh|templates/.sfs-local-template/scripts/sfs-report.sh"
  ".sfs-local/scripts/sfs-healthcheck.sh|templates/.sfs-local-template/scripts/sfs-healthcheck.sh"
  ".sfs-local/scripts/sfs-retro.sh|templates/.sfs-local-template/scripts/sfs-retro.sh"
  ".sfs-local/scripts/sfs-commit.sh|templates/.sfs-local-template/scripts/sfs-commit.sh"
  ".sfs-local/scripts/sfs-loop.sh|templates/.sfs-local-template/scripts/sfs-loop.sh"
  # sprint-templates/ — sfs-start.sh 가 sprint dir 초기화 시 사용
  ".sfs-local/sprint-templates/brainstorm.md|templates/.sfs-local-template/sprint-templates/brainstorm.md"
  ".sfs-local/sprint-templates/plan.md|templates/.sfs-local-template/sprint-templates/plan.md"
  ".sfs-local/sprint-templates/implement.md|templates/.sfs-local-template/sprint-templates/implement.md"
  ".sfs-local/sprint-templates/log.md|templates/.sfs-local-template/sprint-templates/log.md"
  ".sfs-local/sprint-templates/review.md|templates/.sfs-local-template/sprint-templates/review.md"
  ".sfs-local/sprint-templates/retro.md|templates/.sfs-local-template/sprint-templates/retro.md"
  ".sfs-local/sprint-templates/report.md|templates/.sfs-local-template/sprint-templates/report.md"
  ".sfs-local/sprint-templates/decision-light.md|templates/.sfs-local-template/sprint-templates/decision-light.md"
  # personas/ — CEO / CTO Generator / CPO Evaluator 기본 persona
  ".sfs-local/personas/ceo.md|templates/.sfs-local-template/personas/ceo.md"
  ".sfs-local/personas/cto-generator.md|templates/.sfs-local-template/personas/cto-generator.md"
  ".sfs-local/personas/implementation-worker.md|templates/.sfs-local-template/personas/implementation-worker.md"
  ".sfs-local/personas/cpo-evaluator.md|templates/.sfs-local-template/personas/cpo-evaluator.md"
  # decisions-template/ — sfs-decision.sh 가 ADR 신설 시 사용 (WU-26)
  ".sfs-local/decisions-template/ADR-TEMPLATE.md|templates/.sfs-local-template/decisions-template/ADR-TEMPLATE.md"
  ".sfs-local/decisions-template/_INDEX.md|templates/.sfs-local-template/decisions-template/_INDEX.md"
  # 0.5.0-mvp 신규: multi-adaptor parity (Gemini CLI command + Codex Skill)
  ".gemini/commands/sfs.toml|templates/.gemini/commands/sfs.toml"
  ".agents/skills/sfs/SKILL.md|templates/.agents/skills/sfs/SKILL.md"
)

while IFS= read -r rel; do
  [ -n "$rel" ] || continue
  CHECK_FILES+=(".sfs-local/context/${rel}|templates/.sfs-local-template/context/${rel}")
done < <(list_managed_context_rels)

for pair in "${CHECK_FILES[@]}"; do
  dst_rel="${pair%%|*}"
  src_rel="${pair##*|}"
  src="$SOURCE_DIR/$src_rel"
  dst="$TARGET/$dst_rel"

  printf "\n  ${C_BOLD}%s${C_RESET}\n" "$dst_rel"
  if [ ! -f "$dst" ]; then
    new_sum=$(checksum_file "$src")
    rec=$(recommend_action "$dst_rel" "no" "no")
    printf "    상태: 신규 설치\n"
    printf "    checksum: existing=none  new=%s\n" "$new_sum"
    printf "    추천: %s\n" "$rec"
  else
    old_sum=$(checksum_file "$dst")
    new_sum=$(checksum_file "$src")
    if [ "$old_sum" = "$new_sum" ]; then
      rec=$(recommend_action "$dst_rel" "yes" "yes")
      printf "    상태: 동일 — 변경 없음\n"
      printf "    checksum: existing=%s  new=%s\n" "$old_sum" "$new_sum"
      printf "    추천: %s\n" "$rec"
    else
      rec=$(recommend_action "$dst_rel" "yes" "no")
      printf "    상태: checksum 다름 — 자동 정책 적용 대상\n"
      printf "    checksum: existing=%s  new=%s\n" "$old_sum" "$new_sum"
      printf "    추천: %s\n" "$rec"
    fi
  fi
done

# .gitignore snippet 은 marker 기반 블록 교체
printf "\n  ${C_BOLD}.gitignore${C_RESET}\n"
snippet_sum=$(checksum_file "$SOURCE_DIR/templates/.gitignore.snippet")
if grep -qF "$GIT_MARKER_BEGIN" "$TARGET/.gitignore" 2>/dev/null; then
  printf "    상태: solon-product 블록 존재 — marker 블록 교체 예정\n"
  printf "    checksum: managed-snippet=%s\n" "$snippet_sum"
  printf "    추천: 자동 갱신\n"
else
  printf "    상태: solon-product 블록 없음 — 신규 추가 예정\n"
  printf "    checksum: managed-snippet=%s\n" "$snippet_sum"
  printf "    추천: 자동 추가\n"
fi

cat <<EOF

지금 무엇을 하면 되나:
  - 계속하려면 아래 "업그레이드 진행? [y]:" 에서 Enter 를 누르세요.
  - 멈추려면 n 을 입력하세요.

적용 결과:
  - 신규 파일과 .gitignore/VERSION 은 자동 처리됩니다.
  - 기존 프로젝트 지침 파일은 자동 보존됩니다.
  - backup+overwrite 대상은 기존 파일을 .sfs-local/archives/runtime-upgrades/ 아래 압축 bundle 로 보관한 뒤 갱신합니다.

EOF

echo ""
trace_upgrade "confirm prompt before"
UPGRADE_CONFIRM="$(prompt "업그레이드 진행?" "y")"
trace_upgrade "confirm prompt after answer=${UPGRADE_CONFIRM}"
if [ "$UPGRADE_CONFIRM" != "y" ]; then
  info "취소됨."
  exit 0
fi

# ============================================================================
# 4. 파일별 갱신 (checksum 기반 자동 처리)
# ============================================================================

RUNTIME_UPGRADE_BACKUP_TS=""
RUNTIME_UPGRADE_BACKUP_DIR=""
RUNTIME_UPGRADE_BACKUP_STAGE=""
RUNTIME_UPGRADE_BACKUP_LIST=""
RUNTIME_UPGRADE_BACKUP_REL=""

runtime_upgrade_backup_file() {
  local dst="$1" dst_rel="$2"
  local rel_dir backup_rel

  if [ -z "$RUNTIME_UPGRADE_BACKUP_DIR" ]; then
    RUNTIME_UPGRADE_BACKUP_TS="$(date +%Y%m%d-%H%M%S)"
    RUNTIME_UPGRADE_BACKUP_DIR="$TARGET/.sfs-local/archives/runtime-upgrades/$RUNTIME_UPGRADE_BACKUP_TS"
    RUNTIME_UPGRADE_BACKUP_STAGE="$RUNTIME_UPGRADE_BACKUP_DIR/.stage"
    RUNTIME_UPGRADE_BACKUP_LIST="$RUNTIME_UPGRADE_BACKUP_DIR/.items"
    mkdir -p "$RUNTIME_UPGRADE_BACKUP_STAGE" || return 5
  fi

  rel_dir="$(dirname "$dst_rel")"
  mkdir -p "$RUNTIME_UPGRADE_BACKUP_STAGE/$rel_dir" || return 5
  cp "$dst" "$RUNTIME_UPGRADE_BACKUP_STAGE/$dst_rel" || return 5
  printf '%s\n' "$dst_rel" >> "$RUNTIME_UPGRADE_BACKUP_LIST" || return 5
  RUNTIME_UPGRADE_BACKUP_REL="${RUNTIME_UPGRADE_BACKUP_DIR#$TARGET/}/runtime-upgrade-backup.tar.gz"
  return 0
}

finalize_runtime_upgrade_backup() {
  local archive_file manifest count
  [ -n "$RUNTIME_UPGRADE_BACKUP_DIR" ] || return 0
  [ -d "$RUNTIME_UPGRADE_BACKUP_STAGE" ] || return 0

  archive_file="$RUNTIME_UPGRADE_BACKUP_DIR/runtime-upgrade-backup.tar.gz"
  manifest="$RUNTIME_UPGRADE_BACKUP_DIR/manifest.txt"
  count=$(find "$RUNTIME_UPGRADE_BACKUP_STAGE" -type f 2>/dev/null | wc -l | tr -d '[:space:]')
  if [ "${count:-0}" -eq 0 ]; then
    rm -rf "$RUNTIME_UPGRADE_BACKUP_STAGE" "$RUNTIME_UPGRADE_BACKUP_LIST" 2>/dev/null || true
    rmdir "$RUNTIME_UPGRADE_BACKUP_DIR" 2>/dev/null || true
    return 0
  fi

  {
    echo "SFS runtime upgrade backup"
    echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "reason: pre-upgrade rollback copies for managed runtime/adaptor files"
    echo "archive: $archive_file"
    echo "count: $count"
    echo
    echo "policy:"
    echo "- rollback evidence is compressed cold history"
    echo "- managed files are updated in-place after their previous versions enter this bundle"
    echo
    echo "items:"
    if [ -f "$RUNTIME_UPGRADE_BACKUP_LIST" ]; then
      sort -u "$RUNTIME_UPGRADE_BACKUP_LIST" | sed 's/^/- /'
    else
      find "$RUNTIME_UPGRADE_BACKUP_STAGE" -type f 2>/dev/null | sort | while IFS= read -r staged; do
        printf -- "- %s\n" "${staged#$RUNTIME_UPGRADE_BACKUP_STAGE/}"
      done
    fi
  } > "$manifest" || return 5

  tar -czf "$archive_file" -C "$RUNTIME_UPGRADE_BACKUP_STAGE" . || return 5
  rm -rf "$RUNTIME_UPGRADE_BACKUP_STAGE" "$RUNTIME_UPGRADE_BACKUP_LIST" || return 5
  ok "runtime upgrade backup 압축 생성: ${archive_file#$TARGET/} ($count files)"
  return 0
}

update_file() {
  local dst_rel="$1" src_rel="$2" label="$3" recommended="${4:-s}"
  local dst="$TARGET/$dst_rel" src="$SOURCE_DIR/$src_rel"

  if [ "${INSTALL_LAYOUT:-vendored}" = "thin" ]; then
    case "$dst_rel" in
      .sfs-local/context/*|.sfs-local/context/commands/*|.sfs-local/context/policies/*)
        ok "thin runtime 사용 — project-local context skip: $dst_rel"
        return 0
        ;;
      ".sfs-local/GUIDE.md"|.sfs-local/scripts/*|.sfs-local/sprint-templates/*|.sfs-local/personas/*|.sfs-local/decisions-template/*)
        ok "thin runtime 사용 — project-local managed asset skip: $dst_rel"
        return 0
        ;;
      ".claude/skills/sfs/SKILL.md"|".claude/commands/sfs.md"|".gemini/commands/sfs.toml"|".agents/skills/sfs/SKILL.md")
        ok "thin runtime 사용 — project-local agent adapter skip: $dst_rel"
        return 0
        ;;
    esac
  fi

  [ -f "$src" ] || { err "source 없음: $src_rel"; return 1; }

  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    ok "신규 설치: $dst_rel"
    return 0
  fi

  old_sum=$(checksum_file "$dst")
  new_sum=$(checksum_file "$src")
  if [ "$old_sum" = "$new_sum" ]; then
    ok "변경 없음: $dst_rel (checksum=$old_sum)"
    return 0
  fi

  warn "$dst_rel checksum 다름 ($label)"
  printf "    existing=%s  new=%s\n" "$old_sum" "$new_sum"
  printf "    자동 정책: %s\n" "$recommended"
  case "$recommended" in
    b|B|"backup"|"backup+overwrite")
      local backup_rel
      runtime_upgrade_backup_file "$dst" "$dst_rel" || return 5
      backup_rel="$RUNTIME_UPGRADE_BACKUP_REL"
      cp "$src" "$dst"
      ok "아카이브 + 갱신: $dst_rel → $backup_rel"
      ;;
    o|O|"overwrite")
      cp "$src" "$dst"
      ok "덮어쓰기: $dst_rel"
      ;;
    *)
      ok "보존: $dst_rel"
      ;;
  esac
}

sfs_router_doc_is_sfs() {
  local file="$1"
  [ -f "$file" ] || return 1
  grep -Fq "doc_type: solon-router" "$file" && return 0
  grep -Fq "Solon SFS has two meanings" "$file" && return 0
  grep -Fq "sfs context cat kernel" "$file" && return 0
  grep -Fq "Project overview refresh" "$file" && return 0
  return 1
}

sfs_router_doc_needs_refactor() {
  local file="$1" marker lines
  sfs_router_doc_is_sfs "$file" || return 1
  for marker in \
    "SFS commands —" \
    "Executable Action Ownership" \
    "Monitor checkpoint classification" \
    "Handoff-only scope is a stop contract" \
    "Session Continuation Guard" \
    "Division sub-agent council is always-on" \
    "User-escalation premise guard" \
    "DDD/TDD is a product-level engineering floor" \
    "compact option bundle"; do
    grep -Fq "$marker" "$file" && return 0
  done
  lines="$(wc -l < "$file" 2>/dev/null | tr -d '[:space:]')"
  case "${lines:-0}" in ''|*[!0-9]*) return 1 ;; esac
  [ "$lines" -gt 90 ]
}

sfs_router_extract_overview() {
  local src="$1" out="$2"
  awk '
    $0 == "## 프로젝트 개요" {
      in_section = 1
      found = 1
      seen_bullet = 0
      print
      next
    }
    in_section && /^## / {
      exit
    }
    in_section && /^-/ {
      seen_bullet = 1
      print
      next
    }
    in_section && seen_bullet && /^[[:space:]]/ {
      print
      next
    }
    in_section && seen_bullet {
      exit
    }
    in_section {
      print
    }
    END {
      exit found ? 0 : 1
    }
  ' "$src" > "$out"
}

write_sfs_router_template() {
  local dst="$1" overview="$2" template="$SOURCE_DIR/templates/SFS.md.template"
  local tmp today project_name
  [ -f "$template" ] || { err "source 없음: templates/SFS.md.template"; return 1; }
  tmp="$dst.tmp.$$"
  today="$(date +%F)"
  project_name="${PROJECT_NAME:-$(basename "$TARGET")}"
  awk -v block_file="$overview" '
    BEGIN {
      while ((getline line < block_file) > 0) {
        block = block line "\n"
      }
      close(block_file)
      in_profile = 0
      replaced = 0
    }
    $0 == "## 프로젝트 개요" && block != "" {
      printf "%s", block
      in_profile = 1
      replaced = 1
      next
    }
    in_profile && /^## / {
      in_profile = 0
      print
      next
    }
    !in_profile {
      print
    }
    END {
      if (!replaced && block != "") {
        print ""
        printf "%s", block
      }
    }
  ' "$template" | sed \
    -e "s|<PROJECT-NAME>|$project_name|g" \
    -e "s|<DATE>|$today|g" > "$tmp" || return 5
  mv "$tmp" "$dst" || return 5
}

auto_refactor_sfs_router_doc() {
  local dst="$TARGET/SFS.md" src="$SOURCE_DIR/templates/SFS.md.template"
  local archive_dir archive_file manifest staging overview
  [ -f "$src" ] || { err "source 없음: templates/SFS.md.template"; return 1; }

  if [ ! -f "$dst" ]; then
    cp "$src" "$dst" || return 5
    ok "신규 설치: SFS.md"
    return 0
  fi

  if ! sfs_router_doc_is_sfs "$dst"; then
    ok "SFS.md skip non-SFS router"
    return 0
  fi

  if ! sfs_router_doc_needs_refactor "$dst"; then
    ok "SFS.md thin router: preserved"
    return 0
  fi

  case "${SFS_ROUTER_DOC_REFACTOR:-1}" in
    0|false|FALSE|no|NO)
      warn "SFS.md thin-router refactor needed but skipped: SFS_ROUTER_DOC_REFACTOR=${SFS_ROUTER_DOC_REFACTOR}"
      return 0
      ;;
  esac

  archive_dir="$TARGET/.sfs-local/archives/sfs-router-doc-refactor/$(date +%Y%m%d-%H%M%S)"
  archive_file="$archive_dir/SFS.md.tar.gz"
  manifest="$archive_dir/manifest.txt"
  mkdir -p "$archive_dir" || return 5
  staging="$(mktemp -d "$archive_dir/.stage.XXXXXX")" || return 5
  overview="$(mktemp "${TMPDIR:-/tmp}/sfs-router-overview.XXXXXX")" || return 5
  cp "$dst" "$staging/SFS.md" || return 5
  if ! sfs_router_extract_overview "$dst" "$overview"; then
    sfs_router_extract_overview "$src" "$overview" || return 5
  fi
  write_sfs_router_template "$dst" "$overview" || return $?
  rm -f "$overview"
  {
    echo "SFS router doc refactor backup"
    echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "reason: recognized SFS.md contained routed policy body; SFS.md must stay a thin router"
    echo "archive: $archive_file"
    echo "items:"
    echo "- SFS.md"
  } > "$manifest" || return 5
  tar -czf "$archive_file" -C "$staging" . || return 5
  rm -rf "$staging" || return 5
  ok "SFS.md thin-router refactor: ${archive_file#$TARGET/}"
}

root_agent_doc_template() {
  case "$1" in
    CLAUDE.md) printf '%s\n' "$SOURCE_DIR/templates/CLAUDE.md.template" ;;
    AGENTS.md) printf '%s\n' "$SOURCE_DIR/templates/AGENTS.md.template" ;;
    GEMINI.md) printf '%s\n' "$SOURCE_DIR/templates/GEMINI.md.template" ;;
    *) return 1 ;;
  esac
}

root_agent_doc_is_sfs_adapter() {
  local file="$1"
  [ -f "$file" ] || return 1
  grep -Fq "doc_type: agent-adapter-bootstrap" "$file" && return 0
  grep -Fq "sfs_detail_sources:" "$file" && return 0
  grep -Fq "frontmatter_only: true" "$file" && return 0
  grep -Fq "SFS commands —" "$file" && return 0
  if grep -Fq "Solon SFS" "$file" && grep -Fq "sfs context cat" "$file"; then
    return 0
  fi
  if grep -Fq "This project uses Solon Product SFS" "$file"; then
    return 0
  fi
  return 1
}

root_agent_doc_has_frontmatter() {
  local file="$1"
  [ -f "$file" ] || return 1
  [ "$(sed -n '1p' "$file")" = "---" ] || return 1
  sed -n '2,120p' "$file" | grep -Fxq -- "---"
}

root_agent_doc_body_has_content() {
  local file="$1"
  awk '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { in_fm = 0; seen_close = 1; next }
    seen_close && $0 ~ /[^[:space:]]/ { found = 1 }
    END { exit found ? 0 : 1 }
  ' "$file"
}

root_agent_doc_is_frontmatter_only() {
  local file="$1"
  root_agent_doc_has_frontmatter "$file" || return 1
  if root_agent_doc_body_has_content "$file"; then
    return 1
  fi
  return 0
}

write_root_agent_doc_template() {
  local src="$1" dst="$2" today tmp
  [ -f "$src" ] || { err "source 없음: $src"; return 1; }
  today="$(date +%F)"
  tmp="$dst.tmp.$$"
  sed "s|<DATE>|$today|g" "$src" > "$tmp" || return 5
  mv "$tmp" "$dst" || return 5
}

auto_refactor_root_agent_docs() {
  case "${SFS_AGENT_DOC_REFACTOR:-1}" in
    0|false|FALSE|no|NO)
      ok "root agent docs refactor skip: SFS_AGENT_DOC_REFACTOR=${SFS_AGENT_DOC_REFACTOR}"
      return 0
      ;;
  esac

  local rel dst src archive_dir archive_file manifest staging count=0
  for rel in CLAUDE.md AGENTS.md GEMINI.md; do
    dst="$TARGET/$rel"
    [ -f "$dst" ] || continue
    if ! root_agent_doc_is_sfs_adapter "$dst"; then
      ok "root agent doc skip non-SFS: $rel"
      continue
    fi
    if root_agent_doc_is_frontmatter_only "$dst"; then
      ok "root agent doc frontmatter-only: $rel"
      continue
    fi

    if [ -z "${archive_dir:-}" ]; then
      archive_dir="$TARGET/.sfs-local/archives/agent-doc-refactor/$(date +%Y%m%d-%H%M%S)"
      archive_file="$archive_dir/root-agent-docs.tar.gz"
      manifest="$archive_dir/manifest.txt"
      mkdir -p "$archive_dir" || return 5
      staging="$(mktemp -d "$archive_dir/.stage.XXXXXX")" || return 5
    fi

    mkdir -p "$staging/$(dirname "$rel")" || return 5
    cp "$dst" "$staging/$rel" || return 5
    src="$(root_agent_doc_template "$rel")" || return 1
    write_root_agent_doc_template "$src" "$dst" || return $?
    ok "root agent doc frontmatter-only refactor: $rel"
    count=$((count + 1))
  done

  [ "${count:-0}" -gt 0 ] || return 0
  {
    echo "SFS root agent doc refactor backup"
    echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "reason: recognized SFS adapter doc had body text; frontmatter-only root docs keep policy in SFS.md/context"
    echo "archive: $archive_file"
    echo "count: $count"
    echo
    echo "items:"
    find "$staging" -type f 2>/dev/null | sort | while IFS= read -r staged; do
      printf -- "- %s\n" "${staged#$staging/}"
    done
  } > "$manifest" || return 5
  tar -czf "$archive_file" -C "$staging" . || return 5
  rm -rf "$staging" || return 5
  ok "root agent docs refactor archive: ${archive_file#$TARGET/}"
  return 0
}

info ""
info "파일별 갱신..."
trace_upgrade "file update phase start"

PROJECT_NAME="$(basename "$TARGET")"
MODEL_RUNTIME="current"
MODEL_POLICY="solon_recommended"
MODEL_PROFILE_STATUS="default_applied"
MODEL_PROFILES_WAS_MISSING=0
if [ ! -f "$TARGET/.sfs-local/model-profiles.yaml" ]; then
  MODEL_PROFILES_WAS_MISSING=1
fi

trace_upgrade "project_surface_archive_migrations before"
project_surface_archive_migrations || die "legacy archive surface migration failed"
trace_upgrade "project_surface_archive_migrations after"

update_file "CLAUDE.md" "templates/CLAUDE.md.template" "Claude Code 어댑터" "s"
auto_refactor_sfs_router_doc || die "SFS.md thin-router refactor failed"
update_file "AGENTS.md" "templates/AGENTS.md.template" "Codex 어댑터" "s"
update_file "GEMINI.md" "templates/GEMINI.md.template" "Gemini CLI 어댑터" "s"
auto_refactor_root_agent_docs || die "root agent doc refactor failed"
if [ "${INSTALL_LAYOUT:-vendored}" = "thin" ] && [ "${SFS_INSTALL_AGENT_ADAPTERS:-0}" != "1" ]; then
  ok "thin runtime 사용 — project-local agent adapters skip (.claude/.gemini/.agents). opt-in: sfs agent install all"
else
  mkdir -p "$TARGET/.claude/commands"
  mkdir -p "$TARGET/.claude/skills/sfs"
  update_file ".claude/skills/sfs/SKILL.md" "templates/.claude/commands/sfs.md" "Claude Code /sfs Skill" "b"
  update_file ".claude/commands/sfs.md" "templates/.claude/commands/sfs.md" "Claude Code /sfs 커맨드" "b"
fi
update_file ".sfs-local/divisions.yaml" "templates/.sfs-local-template/divisions.yaml" "본부 활성화" "s"
update_file ".sfs-local/model-profiles.yaml" "templates/.sfs-local-template/model-profiles.yaml" "runtime model profiles" "s"
warn_model_profiles_drift "$TARGET/.sfs-local/model-profiles.yaml" "$MODEL_POLICY"
update_file ".sfs-local/GUIDE.md" "GUIDE.md" "Solon onboarding guide (/sfs guide)" "b"

if [ "${INSTALL_LAYOUT:-vendored}" = "thin" ]; then
  trace_upgrade "thin_context_runtime_migration before"
  thin_context_runtime_migration || die "thin runtime context migration failed"
  trace_upgrade "thin_context_runtime_migration after"
else
  # context/ — short, routed agent context modules for vendored installs.
  mkdir -p "$TARGET/.sfs-local/context/commands" "$TARGET/.sfs-local/context/policies"
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    update_file ".sfs-local/context/${rel}" "templates/.sfs-local-template/context/${rel}" "context routed module" "b"
  done < <(list_managed_context_rels)
  verify_context_router_targets || die "context router index references missing files"
fi

# scripts/ — Solon-versioned bash adapters (codex finding #4 후속, 25th-6 보강)
# 신규: sfs-loop / sfs-decision / sfs-retro (0.4.0-mvp 추가 슬롯) + sfs-guide (0.5.2-product)
mkdir -p "$TARGET/.sfs-local/scripts"
update_file ".sfs-local/scripts/sfs-dispatch.sh" "templates/.sfs-local-template/scripts/sfs-dispatch.sh" "sfs dispatch compatibility layer" "b"
update_file ".sfs-local/scripts/sfs.ps1"        "templates/.sfs-local-template/scripts/sfs.ps1"        "Windows PowerShell wrapper" "b"
update_file ".sfs-local/scripts/sfs-common.sh"   "templates/.sfs-local-template/scripts/sfs-common.sh"   "sfs-common (shared helpers)" "b"
update_file ".sfs-local/scripts/sfs-status.sh"   "templates/.sfs-local-template/scripts/sfs-status.sh"   "sfs status"   "b"
update_file ".sfs-local/scripts/sfs-start.sh"    "templates/.sfs-local-template/scripts/sfs-start.sh"    "sfs start"    "b"
update_file ".sfs-local/scripts/sfs-guide.sh"    "templates/.sfs-local-template/scripts/sfs-guide.sh"    "sfs guide"    "b"
update_file ".sfs-local/scripts/sfs-auth.sh"     "templates/.sfs-local-template/scripts/sfs-auth.sh"     "sfs auth"     "b"
update_file ".sfs-local/scripts/sfs-division.sh" "templates/.sfs-local-template/scripts/sfs-division.sh" "sfs division activation" "b"
update_file ".sfs-local/scripts/sfs-adopt.sh"    "templates/.sfs-local-template/scripts/sfs-adopt.sh"    "sfs adopt (legacy baseline intake)" "b"
update_file ".sfs-local/scripts/sfs-brainstorm.sh" "templates/.sfs-local-template/scripts/sfs-brainstorm.sh" "sfs brainstorm" "b"
update_file ".sfs-local/scripts/sfs-plan.sh"     "templates/.sfs-local-template/scripts/sfs-plan.sh"     "sfs plan"     "b"
update_file ".sfs-local/scripts/sfs-implement.sh" "templates/.sfs-local-template/scripts/sfs-implement.sh" "sfs implement" "b"
update_file ".sfs-local/scripts/sfs-review.sh"   "templates/.sfs-local-template/scripts/sfs-review.sh"   "sfs review"   "b"
update_file ".sfs-local/scripts/sfs-decision.sh" "templates/.sfs-local-template/scripts/sfs-decision.sh" "sfs decision (WU-26)" "b"
update_file ".sfs-local/scripts/sfs-report.sh"   "templates/.sfs-local-template/scripts/sfs-report.sh"   "sfs report (final report + compaction)" "b"
update_file ".sfs-local/scripts/sfs-healthcheck.sh" "templates/.sfs-local-template/scripts/sfs-healthcheck.sh" "sfs healthcheck" "b"
update_file ".sfs-local/scripts/sfs-retro.sh"    "templates/.sfs-local-template/scripts/sfs-retro.sh"    "sfs retro close flow" "b"
update_file ".sfs-local/scripts/sfs-commit.sh"   "templates/.sfs-local-template/scripts/sfs-commit.sh"   "sfs commit" "b"
update_file ".sfs-local/scripts/sfs-loop.sh"     "templates/.sfs-local-template/scripts/sfs-loop.sh"     "sfs loop (WU-27 spec)" "b"
chmod +x "$TARGET/.sfs-local/scripts"/*.sh 2>/dev/null || true

# sprint-templates/ — sfs-start.sh 가 sprint dir 초기화 시 사용
mkdir -p "$TARGET/.sfs-local/sprint-templates"
update_file ".sfs-local/sprint-templates/brainstorm.md"      "templates/.sfs-local-template/sprint-templates/brainstorm.md"      "sprint brainstorm template" "b"
update_file ".sfs-local/sprint-templates/plan.md"            "templates/.sfs-local-template/sprint-templates/plan.md"            "sprint plan template"   "b"
update_file ".sfs-local/sprint-templates/implement.md"       "templates/.sfs-local-template/sprint-templates/implement.md"       "sprint implement template" "b"
update_file ".sfs-local/sprint-templates/log.md"             "templates/.sfs-local-template/sprint-templates/log.md"             "sprint log template"    "b"
update_file ".sfs-local/sprint-templates/review.md"          "templates/.sfs-local-template/sprint-templates/review.md"          "sprint review template" "b"
update_file ".sfs-local/sprint-templates/retro.md"           "templates/.sfs-local-template/sprint-templates/retro.md"           "sprint retro template"  "b"
update_file ".sfs-local/sprint-templates/report.md"          "templates/.sfs-local-template/sprint-templates/report.md"          "sprint final report template" "b"
update_file ".sfs-local/sprint-templates/decision-light.md"  "templates/.sfs-local-template/sprint-templates/decision-light.md"  "decision-light template (WU-26)" "b"

# personas/ — CEO / CTO Generator / Implementation Worker / CPO Evaluator 기본 persona
mkdir -p "$TARGET/.sfs-local/personas"
update_file ".sfs-local/personas/ceo.md"           "templates/.sfs-local-template/personas/ceo.md"           "CEO persona" "b"
update_file ".sfs-local/personas/cto-generator.md" "templates/.sfs-local-template/personas/cto-generator.md" "CTO Generator persona" "b"
update_file ".sfs-local/personas/implementation-worker.md" "templates/.sfs-local-template/personas/implementation-worker.md" "Implementation Worker persona" "b"
update_file ".sfs-local/personas/cpo-evaluator.md" "templates/.sfs-local-template/personas/cpo-evaluator.md" "CPO Evaluator persona" "b"

# decisions-template/ — sfs-decision.sh 가 ADR 신설 시 사용 (WU-26 §1)
# 신규: ADR-TEMPLATE.md + _INDEX.md (0.4.0-mvp 추가)
mkdir -p "$TARGET/.sfs-local/decisions-template"
update_file ".sfs-local/decisions-template/ADR-TEMPLATE.md"  "templates/.sfs-local-template/decisions-template/ADR-TEMPLATE.md"  "ADR template (WU-26 full)"  "b"
update_file ".sfs-local/decisions-template/_INDEX.md"        "templates/.sfs-local-template/decisions-template/_INDEX.md"        "decisions _INDEX (WU-26)"   "b"

if [ "${INSTALL_LAYOUT:-vendored}" != "thin" ] || [ "${SFS_INSTALL_AGENT_ADAPTERS:-0}" = "1" ]; then
  # multi-adaptor parity (0.5.0-mvp 신규): Gemini CLI command + Codex Skill
  # 신규: .gemini/commands/sfs.toml + .agents/skills/sfs/SKILL.md
  # Claude Code 1급 (.claude/commands/sfs.md) 와 동등 entry point.
  mkdir -p "$TARGET/.gemini/commands"
  mkdir -p "$TARGET/.agents/skills/sfs"
  update_file ".gemini/commands/sfs.toml"   "templates/.gemini/commands/sfs.toml"   "Gemini CLI sfs command (TOML)"  "b"
  update_file ".agents/skills/sfs/SKILL.md" "templates/.agents/skills/sfs/SKILL.md" "Codex Skill (project-scoped)"  "b"
fi
if [ "${INSTALL_LAYOUT:-vendored}" = "thin" ] && [ "${SFS_KEEP_PROJECT_RUNTIME_ASSETS:-0}" != "1" ]; then
  rmdir "$TARGET/.sfs-local/scripts" \
        "$TARGET/.sfs-local/sprint-templates" \
        "$TARGET/.sfs-local/personas" \
        "$TARGET/.sfs-local/decisions-template" 2>/dev/null || true
fi
trace_upgrade "finalize_runtime_upgrade_backup before"
finalize_runtime_upgrade_backup || die "runtime upgrade backup bundle failed"
trace_upgrade "finalize_runtime_upgrade_backup after"
trace_upgrade "post-update archive surface collapse before"
cleanup_transient_cache_and_placeholder_auth || die "transient cache cleanup failed"
collapse_non_adopt_archive_dirs || die "archive surface collapse failed"
consolidate_surface_cleanup_archives || die "surface-cleanup consolidation failed"
cleanup_empty_workbench_surface_dirs || die "empty workbench surface cleanup failed"
trace_upgrade "post-update archive surface collapse after"

TODAY=$(date +%Y-%m-%d)
if [ "$(uname)" = "Darwin" ]; then
  SED_INPLACE=(sed -i '')
else
  SED_INPLACE=(sed -i)
fi
for auto_file in "$TARGET/SFS.md" "$TARGET/CLAUDE.md" "$TARGET/AGENTS.md" "$TARGET/GEMINI.md" "$TARGET/.sfs-local/divisions.yaml" "$TARGET/.sfs-local/model-profiles.yaml"; do
  if [ -f "$auto_file" ]; then
    "${SED_INPLACE[@]}" \
      -e "s|<DATE>|$TODAY|g" \
      -e "s|<SOLON-VERSION>|$NEW_VER|g" \
      -e "s|<PROJECT-NAME>|$PROJECT_NAME|g" \
      -e "s|<DEFAULT-RUNTIME>|$MODEL_RUNTIME|g" \
      -e "s|<MODEL-POLICY>|$MODEL_POLICY|g" \
      -e "s|<MODEL-PROFILE-STATUS>|$MODEL_PROFILE_STATUS|g" \
      "$auto_file" 2>/dev/null || true
  fi
done
ok "문서 자동 치환: <DATE>=$TODAY, <SOLON-VERSION>=$NEW_VER"

# config.yaml — create when upgrading older installs; preserve user edits outside runtime fields.
runtime_command="bash .sfs-local/scripts/sfs-dispatch.sh"
if [ "$INSTALL_LAYOUT" = "thin" ]; then
  runtime_command="sfs"
fi
if [ ! -f "$TARGET/.sfs-local/config.yaml" ]; then
  cat > "$TARGET/.sfs-local/config.yaml" <<EOF
runtime:
  layout: "$INSTALL_LAYOUT"
  command: "$runtime_command"
  version: "$NEW_VER"
state:
  dir: ".sfs-local"
overrides:
  # Optional local override. Thin layout keeps managed context in the packaged runtime.
  context: ".sfs-local/context"
  sprint_templates: ".sfs-local/sprint-templates"
  decisions_template: ".sfs-local/decisions-template"
  personas: ".sfs-local/personas"
  model_profiles: ".sfs-local/model-profiles.yaml"
EOF
  ok "config.yaml 생성 (runtime layout: $INSTALL_LAYOUT)"
else
  tmp_config="$TARGET/.sfs-local/config.yaml.tmp.$$"
  awk -v layout="$INSTALL_LAYOUT" -v command="$runtime_command" -v version="$NEW_VER" '
    function emit_missing() {
      if (!seen_layout) { print "  layout: \"" layout "\"" }
      if (!seen_command) { print "  command: \"" command "\"" }
      if (!seen_version) { print "  version: \"" version "\"" }
    }
    /^runtime:[[:space:]]*$/ {
      print
      in_runtime=1
      seen_layout=0
      seen_command=0
      seen_version=0
      next
    }
    in_runtime && /^[^[:space:]]/ {
      emit_missing()
      in_runtime=0
    }
    in_runtime && /^[[:space:]]*layout:/ {
      print "  layout: \"" layout "\""
      seen_layout=1
      next
    }
    in_runtime && /^[[:space:]]*command:/ {
      print "  command: \"" command "\""
      seen_command=1
      next
    }
    in_runtime && /^[[:space:]]*version:/ {
      print "  version: \"" version "\""
      seen_version=1
      next
    }
    { print }
    END {
      if (in_runtime) {
        emit_missing()
      }
    }
  ' "$TARGET/.sfs-local/config.yaml" > "$tmp_config" && mv "$tmp_config" "$TARGET/.sfs-local/config.yaml"
  ok "config.yaml runtime 갱신 (layout: $INSTALL_LAYOUT)"
fi

# ============================================================================
# 5. .gitignore 블록 교체 (marker 기반)
# ============================================================================

info ""
info ".gitignore 블록 갱신..."

if grep -qF "$GIT_MARKER_BEGIN" "$TARGET/.gitignore" 2>/dev/null; then
  # 블록 제거
  awk -v b="$GIT_MARKER_BEGIN" -v e="$GIT_MARKER_END" '
    $0 == b { skip=1; next }
    $0 == e { skip=0; next }
    !skip { print }
  ' "$TARGET/.gitignore" > "$TARGET/.gitignore.tmp"
  mv "$TARGET/.gitignore.tmp" "$TARGET/.gitignore"
fi

# 새 블록 append
{
  if [ -s "$TARGET/.gitignore" ] && [ "$(tail -c1 "$TARGET/.gitignore" | wc -l)" = "0" ]; then
    echo ""
  fi
  echo ""
  echo "$GIT_MARKER_BEGIN"
  cat "$SOURCE_DIR/templates/.gitignore.snippet"
  echo "$GIT_MARKER_END"
} >> "$TARGET/.gitignore"
ok ".gitignore solon-product 블록 교체 완료"

prune_empty_sfs_workbench_dirs() {
  local dir entries
  for dir in \
    "$TARGET/.sfs-local/sprints" \
    "$TARGET/.sfs-local/decisions" \
    "$TARGET/.sfs-local/queue/pending" \
    "$TARGET/.sfs-local/queue/claimed" \
    "$TARGET/.sfs-local/queue/done" \
    "$TARGET/.sfs-local/queue/failed" \
    "$TARGET/.sfs-local/queue/abandoned" \
    "$TARGET/.sfs-local/queue/runs"; do
    [ -d "$dir" ] || continue
    entries="$(find "$dir" -mindepth 1 ! -name .gitkeep -print -quit 2>/dev/null || true)"
    if [ -z "$entries" ]; then
      rm -f "$dir/.gitkeep" 2>/dev/null || true
    fi
  done
  find "$TARGET/.sfs-local/queue" -depth -type d -empty -exec rmdir {} \; 2>/dev/null || true
  rmdir "$TARGET/.sfs-local/sprints" "$TARGET/.sfs-local/decisions" 2>/dev/null || true
  ok "빈 Solon workbench placeholder 정리 완료"
}

prune_empty_sfs_workbench_dirs

# ============================================================================
# 6. VERSION 갱신
# ============================================================================

UPGRADED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
cat > "$TARGET/.sfs-local/VERSION" <<EOF
solon_mvp_version: $NEW_VER
installed_at: $INSTALLED_AT
upgraded_at: $UPGRADED_AT
upgraded_from: $CUR_VER
installed_from: $MODE
install_layout: $INSTALL_LAYOUT
source_repo: https://github.com/${SOLON_REPO}
EOF
ok "VERSION 갱신: $CUR_VER → $NEW_VER"

trace_upgrade "maybe_prompt_model_profile before"
maybe_prompt_model_profile
trace_upgrade "maybe_prompt_model_profile after"

trace_upgrade "model profile notice before"
MODEL_PROFILE_NOTICE=""
if [ -f "$TARGET/.sfs-local/model-profiles.yaml" ]; then
  if model_profile_needs_prompt; then
    MODEL_PROFILE_NOTICE="agent model profile 이 미확정 fallback 상태입니다. 지금 설정하지 않으면 현재 런타임 모델을 쓰며, 다음 upgrade 또는 사용자 발화 때 다시 안내됩니다."
  elif [ "$MODEL_PROFILES_WAS_MISSING" -eq 1 ]; then
    MODEL_PROFILE_NOTICE="새 agent model profile 이 생성되고 설정되었습니다."
  elif ! grep -q '^agent_defaults:' "$TARGET/.sfs-local/model-profiles.yaml" 2>/dev/null; then
    MODEL_PROFILE_NOTICE="기존 model-profiles.yaml 을 보존했습니다. 새 agent_defaults/agent_model_overrides 형식이 필요하면 배포 템플릿과 비교해 병합하세요."
  fi
fi
trace_upgrade "model profile notice after"

# ============================================================================
# 6.5. CLI discovery hook (0.5.96-product) — slash-command zero-file
# ============================================================================
# Re-runs the same hook used by install.sh so existing 0.5.89-95 installations
# pick up the new global discovery surface on `sfs upgrade`. Idempotent.

if [ "${SFS_SKIP_CLI_DISCOVERY:-0}" != "1" ]; then
  CLI_DISCOVERY_HOOK="$SOURCE_DIR/scripts/install-cli-discovery.sh"
  CLI_DISCOVERY_TIMEOUT="$(normalize_positive_timeout "${SFS_CLI_DISCOVERY_TIMEOUT_SEC:-45}" "45" "cli-discovery hook")"
  trace_upgrade "cli-discovery hook before timeout=${CLI_DISCOVERY_TIMEOUT}s"
  if [ -x "$CLI_DISCOVERY_HOOK" ] || [ -f "$CLI_DISCOVERY_HOOK" ]; then
    OLD_SFS_DISCOVERY_SOURCE_DIR="${SFS_DISCOVERY_SOURCE_DIR-}"
    OLD_SFS_DISCOVERY_SOURCE_DIR_SET=0
    if [ "${SFS_DISCOVERY_SOURCE_DIR+x}" = "x" ]; then OLD_SFS_DISCOVERY_SOURCE_DIR_SET=1; fi
    export SFS_DISCOVERY_SOURCE_DIR="$SOURCE_DIR"
    run_upgrade_command_with_timeout "cli-discovery hook" "$CLI_DISCOVERY_TIMEOUT" \
      bash "$CLI_DISCOVERY_HOOK" || warn "cli-discovery hook returned non-zero or timed out (graceful — continuing)"
    if [ "$OLD_SFS_DISCOVERY_SOURCE_DIR_SET" -eq 1 ]; then
      export SFS_DISCOVERY_SOURCE_DIR="$OLD_SFS_DISCOVERY_SOURCE_DIR"
    else
      unset SFS_DISCOVERY_SOURCE_DIR
    fi
  else
    warn "cli-discovery hook not found at $CLI_DISCOVERY_HOOK — skip"
  fi
  trace_upgrade "cli-discovery hook after"
else
  trace_upgrade "cli-discovery hook skipped before"
  ok "cli-discovery hook skipped (SFS_SKIP_CLI_DISCOVERY=1)"
  trace_upgrade "cli-discovery hook skipped after"
fi

# ============================================================================
# 7. 완료
# ============================================================================

trace_upgrade "completion hint render before"
if [ "${INSTALL_LAYOUT:-vendored}" = "thin" ]; then
  AGENT_HINT="project-local command/skill adapters 는 기본 제거되었습니다. 필요할 때만: sfs agent install all"
else
  AGENT_HINT="vendored layout 은 project-local command/skill adapters 를 계속 동기화합니다."
fi
COMMIT_HINT="${C_BLUE}sfs commit plan${C_RESET}
  ${C_BLUE}sfs commit apply --group runtime-upgrade -m \"업그레이드: solon-mvp $CUR_VER → $NEW_VER\"${C_RESET}"
trace_upgrade "completion hint render after"

trace_upgrade "completion output before"
cat <<EOF

${C_BOLD}${C_GREEN}=== 업그레이드 완료 ===${C_RESET}

  $CUR_VER → $NEW_VER

Agent model profile:
  ${MODEL_PROFILE_NOTICE:-설정 파일 유지됨: .sfs-local/model-profiles.yaml}

  Solon recommended role routing 이 기본 적용됩니다. current_model 은 명시적 opt-out 입니다.
  Codex 권장은 helper-grade intake/non-coding helper gpt-5.4-mini, 질문 생성/facilitator/일반 worker gpt-5.4,
  advisor/review gpt-5.5 xhigh, bounded coding helper gpt-5.3-codex,
  무판단 mechanical implementation helper gpt-5.3-codex-spark 입니다.
  Gemini 는 strategy/research/review 를 gemini-3.1-pro-preview, agentic coding/bounded 구현 helper 를 gemini-3-flash-preview, relay/probe/economy helper 를 gemini-3.1-flash-lite 로 라우팅합니다. 3.x 미만 fallback 은 쓰지 않습니다.
  모델명은 SFS role/profile contract 입니다. CLI --model flag 지원을 전제로 하지 않고,
  기본 bridge 는 prompt 와 host/runtime 설정으로 해당 역할을 요청합니다.
  하위모델이 질문/선택지/답변 해석/gate 를 흔들면 최상위 advisor 검토가 필수입니다.
  helper-grade 단순 I/O 는 advisor 검토를 생략할 수 있습니다.
  advisor 호출은 self-CPO PASS 가 아닙니다. external/cross review 전에는 요구사항-AC-slice-ADR 추적,
  AC-file/artifact/evidence 매핑, SEED/placeholder/mock/fallback non-acceptance 를 self-CPO mini-check 로 남깁니다.
  프로젝트가 비용/지연을 감수한다면 worker/helper 도 high-end 모델로 설정해도 됩니다.
  Spark 는 일반 구현 worker 가 아니라 scope/files_scope/AC/정확한 수정 의도가 잠긴 무판단 기계적 구현 용도입니다.
  Claude: advisor 는 Opus 4.7, worker/facilitator/code helper 는 Sonnet 4.6,
  Haiku 는 코딩 금지 helper-grade relay/요약/read-only 보조 전용입니다.
  Gemini/custom 은 프로젝트 runtime 이 지원하는 profile 이름으로 agent별 override 가능합니다.

$(print_agent_implementation_mode_contract)

변경사항 sfs commit + push 권장:
  ${COMMIT_HINT}
  ${C_YELLOW}sfs commit apply 는 기본적으로 현재 branch 를 push 합니다. 로컬 sandbox 에서만 --no-push 를 쓰세요.${C_RESET}
  ${C_YELLOW}커밋 메시지는 사용자 native/workspace 언어가 기본입니다. 영어는 repo 규칙이 요구할 때만 쓰세요.${C_RESET}

Agent adapter surface:
  ${AGENT_HINT}

CHANGELOG: https://github.com/${SOLON_REPO}/blob/main/CHANGELOG.md

EOF
trace_upgrade "completion output after"
