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

usage() {
  cat <<'EOF'
Usage: sfs upgrade [--yes]

Options:
  -y, --yes   안전 기본 정책으로 non-interactive upgrade 실행
  -h, --help  도움말 출력

Environment:
  SFS_MODEL_PROFILE_PROMPT=0  agent/model fallback 질문을 이번 upgrade 에서 숨김
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes)
      ASSUME_YES=1
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

# pipe 대응
if [ ! -t 0 ] && [ -e /dev/tty ]; then
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
  local runtime="${1:-current}" policy="${2:-current_model}" status="${3:-current_model_fallback}"
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
  grep -Eq '^[[:space:]]*status:[[:space:]]*"?current_model_fallback"?' "$file" 2>/dev/null && return 0
  grep -Eq '^[[:space:]]*status:[[:space:]]*"?review_required"?' "$file" 2>/dev/null && return 0
  grep -Eq '^[[:space:]]*status:[[:space:]]*"?unset"?' "$file" 2>/dev/null && return 0
  grep -Eq '^[[:space:]]*selected_runtime:[[:space:]]*"?current"?' "$file" 2>/dev/null && return 0
  grep -Eq '^[[:space:]]*selected_policy:[[:space:]]*"?current_model"?' "$file" 2>/dev/null && return 0
  grep -Eq '^[[:space:]]*confirmed_by:[[:space:]]*"?[[:space:]]*"?$' "$file" 2>/dev/null && return 0
  return 1
}

print_model_profile_question() {
  cat <<'EOF'

Agent model profile:
  이 질문은 Solon 의 역할별 agent 가 어떤 모델을 쓸지 정하는 단계입니다.
  예: 설계/판단 agent 는 더 강한 모델, 코드 구현 agent 는 표준 모델, 단순 정리 helper 는 가벼운 모델.

  지금 꼭 정하지 않아도 됩니다.
  건너뛰면 current_model fallback 을 유지하고, 현재 Claude/Codex/Gemini 에서 사용자가
  선택한 모델을 그대로 씁니다. 나중에 다시 설정할 수 있고, 다음 upgrade 때도 다시 안내합니다.

  선택지:
    1. Claude 권장: 설계/평가 Opus 4.7, 구현 Sonnet 4.6, helper Haiku
    2. 지금 설정 안 함: current_model fallback 유지 (처음이면 이걸 골라도 안전)
    3. all_high: 모든 agent/helper 를 high-end 로 설정 (품질 우선, 비용/지연 증가 가능)
    4. custom/manual: 직접 모델 profile 작성

  Codex/Claude 가 대신 실행 중인 경우:
    위 설명과 선택지를 사용자에게 보여주고 번호를 물어보세요.
    사용자가 "지금 설정 안 함" 이라고 하면 current_model fallback 으로 두고 계속 진행하면 됩니다.
EOF
}

set_model_profile_fields() {
  local runtime="$1" policy="$2" status="$3" confirmed_by="$4" confirmed_at="$5"
  local file="$TARGET/.sfs-local/model-profiles.yaml"
  [ -f "$file" ] || create_default_model_profile current current_model current_model_fallback
  if ! sed_inplace \
    -e "s@^[[:space:]]*status:.*@  status: \"$status\"        # current_model_fallback | selected_at_install | confirmed | review_required@g" \
    -e "s@^[[:space:]]*selected_runtime:.*@  selected_runtime: \"$runtime\"   # current | claude | codex | gemini | custom@g" \
    -e "s@^[[:space:]]*selected_policy:.*@  selected_policy: \"$policy\"       # current_model | solon_recommended | all_high | custom@g" \
    -e "s@^[[:space:]]*confirmed_by:.*@  confirmed_by: \"$confirmed_by\"@g" \
    -e "s@^[[:space:]]*confirmed_at:.*@  confirmed_at: \"$confirmed_at\"@g" \
    "$file"; then
    warn "agent model profile 저장 실패: $file"
    return 1
  fi
}

maybe_prompt_model_profile() {
  model_profile_needs_prompt || return 0

  if [ "${SFS_MODEL_PROFILE_PROMPT:-1}" = "0" ]; then
    warn "agent model profile fallback 상태 — SFS_MODEL_PROFILE_PROMPT=0 이라 이번 질문은 건너뜀"
    warn "    current_model fallback 유지. 다음 upgrade 에서 다시 질문됩니다."
    return 0
  fi

  if [ ! -t 0 ]; then
    print_model_profile_question
    return 0
  fi

  print_model_profile_question
  local choice runtime now
  choice="$(prompt_always "agent model profile 선택? (1/2/3/4, 처음이면 2 권장)" "2")"
  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  case "$choice" in
    1)
      set_model_profile_fields "claude" "solon_recommended" "confirmed" "sfs upgrade" "$now"
      ok "agent model profile 확정: Claude 권장 (Opus 4.7 / Sonnet 4.6 / Haiku)"
      ;;
    2|"")
      set_model_profile_fields "current" "current_model" "current_model_fallback" "" ""
      ok "agent model profile 미확정 유지: current_model fallback (다음 upgrade 때 다시 질문)"
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
      warn "알 수 없는 선택 '$choice' — current_model fallback 유지"
      set_model_profile_fields "current" "current_model" "current_model_fallback" "" ""
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

repair_missing_context_router_targets() {
  local source_index="$SOURCE_DIR/templates/.sfs-local-template/context/_INDEX.md"
  local target_context="$TARGET/.sfs-local/context"
  local rel src dst repaired=0

  [ -f "$source_index" ] || return 0
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
  done < <(
    {
      printf '%s\n' "_INDEX.md" "kernel.md"
      grep -Eo 'commands/[a-z-]+\.md|policies/[a-z-]+\.md' "$source_index" || true
    } | sort -u
  )

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
  done < <(grep -Eo 'commands/[a-z-]+\.md|policies/[a-z-]+\.md' "$target_index" | sort -u)

  [ "$missing" -eq 0 ] || return 1
  ok "context router targets complete"
}

thin_context_runtime_migration() {
  [ "${INSTALL_LAYOUT:-vendored}" = "thin" ] || return 0
  local target_context="$TARGET/.sfs-local/context"
  local source_index="$SOURCE_DIR/templates/.sfs-local-template/context/_INDEX.md"
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

  {
    printf '%s\n' "_INDEX.md" "kernel.md"
    if [ -f "$source_index" ]; then
      grep -Eo 'commands/[a-z-]+\.md|policies/[a-z-]+\.md' "$source_index" || true
    fi
  } | sort -u | while IFS= read -r rel; do
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

project_surface_archive_migrations() {
  compact_legacy_runtime_upgrade_archives || return 5
  compact_legacy_agent_install_archives || return 5
  compact_legacy_sprint_archive_dirs || return 5
  compact_legacy_review_run_archives || return 5
  compact_legacy_tmp_artifacts || return 5
  thin_project_agent_adapter_migration || return 5
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
INSTALL_LAYOUT=$(grep '^install_layout:' "$TARGET/.sfs-local/VERSION" 2>/dev/null | awk '{print $2}')
INSTALL_LAYOUT="${INSTALL_LAYOUT:-vendored}"

cat <<EOF

${C_BOLD}=== Solon Product Upgrade ===${C_RESET}

현재 설치:   $CUR_VER  (installed: $INSTALLED_AT)
최신 배포:   $NEW_VER
소스 모드:   $MODE
layout:      $INSTALL_LAYOUT

EOF

if [ "$CUR_VER" = "$NEW_VER" ]; then
  MODEL_PROFILE_REPAIRED=0
  if [ ! -f "$TARGET/.sfs-local/model-profiles.yaml" ] \
     && [ -f "$SOURCE_DIR/templates/.sfs-local-template/model-profiles.yaml" ]; then
    create_default_model_profile current current_model current_model_fallback
    ok "model-profiles.yaml 누락 감지 — current_model fallback 설정으로 생성"
    MODEL_PROFILE_REPAIRED=1
  elif grep -q 'status: "current_model_fallback"' "$TARGET/.sfs-local/model-profiles.yaml" 2>/dev/null \
    || grep -q 'selected_runtime: "current"' "$TARGET/.sfs-local/model-profiles.yaml" 2>/dev/null \
    || grep -q 'status: "review_required"' "$TARGET/.sfs-local/model-profiles.yaml" 2>/dev/null \
    || grep -q 'selected_runtime: "unset"' "$TARGET/.sfs-local/model-profiles.yaml" 2>/dev/null; then
    warn "agent model profile 이 current_model fallback 상태입니다."
  fi
  if [ "${INSTALL_LAYOUT:-vendored}" = "thin" ]; then
    thin_context_runtime_migration || die "thin runtime context migration failed"
  else
    repair_missing_context_router_targets
    verify_context_router_targets || die "context router index references missing files"
  fi
  project_surface_archive_migrations || die "legacy archive surface migration failed"
  maybe_prompt_model_profile
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
    "SFS.md"|".claude/skills/sfs/SKILL.md"|".claude/commands/sfs.md"|".gemini/commands/sfs.toml"|".agents/skills/sfs/SKILL.md"|".sfs-local/GUIDE.md")
      printf "backup+overwrite"
      ;;
    "CLAUDE.md"|"AGENTS.md"|"GEMINI.md"|".sfs-local/divisions.yaml"|".sfs-local/model-profiles.yaml")
      printf "skip"
      ;;
    ".sfs-local/auth.env.example"|.sfs-local/context/*.md|.sfs-local/context/commands/*.md|.sfs-local/context/policies/*.md)
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
  - SFS.md                             → backup+overwrite (공통 SFS core 최신화)
  - CLAUDE/AGENTS/GEMINI.md            → 자동 보존 (기존 프로젝트 지침 보호)
  - .sfs-local/divisions.yaml          → 자동 보존 (프로젝트별 운영값 보호)
  - .sfs-local/model-profiles.yaml     → 없으면 설치 + 설정 안내, 있으면 자동 보존 (agent별 모델 설정 보호)
  - .sfs-local/auth.env.example        → backup+overwrite (로컬 auth 템플릿, 실제 auth.env 는 ignore)
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
  ".sfs-local/auth.env.example|templates/.sfs-local-template/auth.env.example"
  ".sfs-local/context/_INDEX.md|templates/.sfs-local-template/context/_INDEX.md"
  ".sfs-local/context/kernel.md|templates/.sfs-local-template/context/kernel.md"
  ".sfs-local/context/commands/start.md|templates/.sfs-local-template/context/commands/start.md"
  ".sfs-local/context/commands/profile.md|templates/.sfs-local-template/context/commands/profile.md"
  ".sfs-local/context/commands/brainstorm.md|templates/.sfs-local-template/context/commands/brainstorm.md"
  ".sfs-local/context/commands/plan.md|templates/.sfs-local-template/context/commands/plan.md"
  ".sfs-local/context/commands/implement.md|templates/.sfs-local-template/context/commands/implement.md"
  ".sfs-local/context/commands/review.md|templates/.sfs-local-template/context/commands/review.md"
  ".sfs-local/context/commands/release.md|templates/.sfs-local-template/context/commands/release.md"
  ".sfs-local/context/commands/upgrade.md|templates/.sfs-local-template/context/commands/upgrade.md"
  ".sfs-local/context/commands/tidy.md|templates/.sfs-local-template/context/commands/tidy.md"
  ".sfs-local/context/commands/loop.md|templates/.sfs-local-template/context/commands/loop.md"
  ".sfs-local/context/policies/mutex.md|templates/.sfs-local-template/context/policies/mutex.md"
  ".sfs-local/context/policies/token-harness.md|templates/.sfs-local-template/context/policies/token-harness.md"
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
if [ "$(prompt "업그레이드 진행?" "y")" != "y" ]; then
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

info ""
info "파일별 갱신..."

PROJECT_NAME="$(basename "$TARGET")"
MODEL_RUNTIME="current"
MODEL_POLICY="current_model"
MODEL_PROFILE_STATUS="current_model_fallback"
MODEL_PROFILES_WAS_MISSING=0
if [ ! -f "$TARGET/.sfs-local/model-profiles.yaml" ]; then
  MODEL_PROFILES_WAS_MISSING=1
fi

project_surface_archive_migrations || die "legacy archive surface migration failed"

update_file "CLAUDE.md" "templates/CLAUDE.md.template" "Claude Code 어댑터" "s"
update_file "SFS.md" "templates/SFS.md.template" "공통 SFS 지침" "b"
update_file "AGENTS.md" "templates/AGENTS.md.template" "Codex 어댑터" "s"
update_file "GEMINI.md" "templates/GEMINI.md.template" "Gemini CLI 어댑터" "s"
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
update_file ".sfs-local/auth.env.example" "templates/.sfs-local-template/auth.env.example" "executor auth env example" "b"
update_file ".sfs-local/GUIDE.md" "GUIDE.md" "Solon onboarding guide (/sfs guide)" "b"

if [ "${INSTALL_LAYOUT:-vendored}" = "thin" ]; then
  thin_context_runtime_migration || die "thin runtime context migration failed"
else
  # context/ — short, routed agent context modules for vendored installs.
  mkdir -p "$TARGET/.sfs-local/context/commands" "$TARGET/.sfs-local/context/policies"
  update_file ".sfs-local/context/_INDEX.md" "templates/.sfs-local-template/context/_INDEX.md" "context router index" "b"
  update_file ".sfs-local/context/kernel.md" "templates/.sfs-local-template/context/kernel.md" "context kernel" "b"
  update_file ".sfs-local/context/commands/start.md" "templates/.sfs-local-template/context/commands/start.md" "context start module" "b"
  update_file ".sfs-local/context/commands/profile.md" "templates/.sfs-local-template/context/commands/profile.md" "context profile module" "b"
  update_file ".sfs-local/context/commands/brainstorm.md" "templates/.sfs-local-template/context/commands/brainstorm.md" "context brainstorm module" "b"
  update_file ".sfs-local/context/commands/plan.md" "templates/.sfs-local-template/context/commands/plan.md" "context plan module" "b"
  update_file ".sfs-local/context/commands/implement.md" "templates/.sfs-local-template/context/commands/implement.md" "context implement module" "b"
  update_file ".sfs-local/context/commands/review.md" "templates/.sfs-local-template/context/commands/review.md" "context review module" "b"
  update_file ".sfs-local/context/commands/release.md" "templates/.sfs-local-template/context/commands/release.md" "context release module" "b"
  update_file ".sfs-local/context/commands/upgrade.md" "templates/.sfs-local-template/context/commands/upgrade.md" "context upgrade module" "b"
  update_file ".sfs-local/context/commands/tidy.md" "templates/.sfs-local-template/context/commands/tidy.md" "context tidy module" "b"
  update_file ".sfs-local/context/commands/loop.md" "templates/.sfs-local-template/context/commands/loop.md" "context loop module" "b"
  update_file ".sfs-local/context/policies/mutex.md" "templates/.sfs-local-template/context/policies/mutex.md" "context mutex policy" "b"
  update_file ".sfs-local/context/policies/token-harness.md" "templates/.sfs-local-template/context/policies/token-harness.md" "context token/harness policy" "b"
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
finalize_runtime_upgrade_backup || die "runtime upgrade backup bundle failed"

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

# config.yaml — create when upgrading older installs; preserve user edits.
if [ ! -f "$TARGET/.sfs-local/config.yaml" ]; then
  runtime_command="bash .sfs-local/scripts/sfs-dispatch.sh"
  if [ "$INSTALL_LAYOUT" = "thin" ]; then
    runtime_command="sfs"
  fi
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
  ok "config.yaml 기존 유지"
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

maybe_prompt_model_profile

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

# ============================================================================
# 7. 완료
# ============================================================================

if [ "${INSTALL_LAYOUT:-vendored}" = "thin" ]; then
  COMMIT_HINT="${C_BLUE}git add SFS.md CLAUDE.md AGENTS.md GEMINI.md .gitignore .sfs-local .claude .gemini .agents${C_RESET}"
  AGENT_HINT="project-local command/skill adapters 는 기본 제거되었습니다. 필요할 때만: sfs agent install all"
else
  COMMIT_HINT="${C_BLUE}git add SFS.md CLAUDE.md AGENTS.md GEMINI.md .gitignore .sfs-local .claude .gemini .agents${C_RESET}"
  AGENT_HINT="vendored layout 은 project-local command/skill adapters 를 계속 동기화합니다."
fi

cat <<EOF

${C_BOLD}${C_GREEN}=== 업그레이드 완료 ===${C_RESET}

  $CUR_VER → $NEW_VER

Agent model profile:
  ${MODEL_PROFILE_NOTICE:-설정 파일 유지됨: .sfs-local/model-profiles.yaml}

  Solon 권장은 C-Level/review high, worker standard, helper economy 입니다.
  프로젝트가 비용/지연을 감수한다면 worker/helper 도 high-end 모델로 설정해도 됩니다.
  설정을 안 하거나 거부하면 현재 런타임에서 사용자가 선택한 모델을 그대로 씁니다.
  Codex 는 model + reasoning_effort 조합(예: gpt-5.5 + xhigh/very_high), Claude 는 opus/sonnet/haiku 계열,
  Gemini/custom 은 프로젝트 runtime 이 지원하는 profile 이름으로 agent별 override 가능합니다.

변경사항 git commit 권장:
  ${COMMIT_HINT}
  ${C_BLUE}git commit -m "chore: upgrade solon-mvp $CUR_VER → $NEW_VER"${C_RESET}

Agent adapter surface:
  ${AGENT_HINT}

CHANGELOG: https://github.com/${SOLON_REPO}/blob/main/CHANGELOG.md

EOF
