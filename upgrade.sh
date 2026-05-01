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
#   4. 같아도 project adapter/docs refresh, 다르면 업그레이드 계획 + 대화형 파일별 처리
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
  -y, --yes   안전 기본 정책으로 non-interactive upgrade 실행.
              agent/model profile 질문은 건너뛰고 current_model fallback 을 유지
  -h, --help  도움말 출력

Environment:
  SFS_MODEL_RUNTIME   current|claude|codex|gemini|custom
  SFS_MODEL_POLICY    current_model|solon_recommended|all_high|custom
  SFS_MODEL_PROFILE_PROMPT=0  agent/model fallback 질문을 이번 upgrade 에서 숨김
  SFS_PROJECT_PROFILE_PROMPT=0  프로젝트 개요 미감지 필드 질문을 이번 upgrade 에서 숨김
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

sed_escape() {
  printf '%s' "$1" | sed 's/[&|\\]/\\&/g'
}

pkg_has() {
  local name="$1"
  [ -f "$TARGET/package.json" ] || return 1
  grep -Eq "\"${name}\"[[:space:]]*:" "$TARGET/package.json" 2>/dev/null
}

append_project_environment() {
  local part="$1"
  [ -n "$part" ] || return 0
  case " + $PROJECT_ENVIRONMENT + " in
    *" + $part + "*) return 0 ;;
  esac
  if [ -z "$PROJECT_ENVIRONMENT" ]; then
    PROJECT_ENVIRONMENT="$part"
  else
    PROJECT_ENVIRONMENT="$PROJECT_ENVIRONMENT + $part"
  fi
}

detect_project_profile() {
  PROJECT_TYPE="<PROJECT-TYPE>"
  PROJECT_STAGE="Solon 운영 도입 초기"
  PROJECT_ENVIRONMENT=""
  PROJECT_DATA=""
  PROJECT_OUTPUT="<PROJECT-OUTPUT>"
  PROJECT_DELIVERY=""

  if [ -f "$TARGET/package.json" ]; then
    PROJECT_TYPE="소프트웨어/웹 제품"
    append_project_environment "Node.js"
    if [ -f "$TARGET/tsconfig.json" ] || pkg_has typescript; then
      append_project_environment "TypeScript"
    fi
    if pkg_has next || [ -f "$TARGET/next.config.js" ] || [ -f "$TARGET/next.config.mjs" ] || [ -f "$TARGET/next.config.ts" ]; then
      append_project_environment "Next.js"
      PROJECT_OUTPUT="웹 앱"
    elif pkg_has vite || [ -f "$TARGET/vite.config.js" ] || [ -f "$TARGET/vite.config.ts" ]; then
      append_project_environment "Vite"
      PROJECT_OUTPUT="웹 앱"
    elif pkg_has react; then
      append_project_environment "React"
      PROJECT_OUTPUT="웹 앱"
    elif pkg_has vue; then
      append_project_environment "Vue"
      PROJECT_OUTPUT="웹 앱"
    elif pkg_has svelte; then
      append_project_environment "Svelte"
      PROJECT_OUTPUT="웹 앱"
    else
      PROJECT_OUTPUT="Node.js 앱"
    fi
    if pkg_has tailwindcss || [ -f "$TARGET/tailwind.config.js" ] || [ -f "$TARGET/tailwind.config.ts" ]; then
      append_project_environment "Tailwind CSS"
    fi
    if pkg_has prisma || [ -f "$TARGET/prisma/schema.prisma" ]; then
      append_project_environment "Prisma"
      PROJECT_DATA="Prisma"
    elif pkg_has drizzle-orm || [ -f "$TARGET/drizzle.config.ts" ] || [ -f "$TARGET/drizzle.config.js" ]; then
      append_project_environment "Drizzle"
      PROJECT_DATA="Drizzle"
    fi
  fi

  if [ -f "$TARGET/prisma/schema.prisma" ]; then
    if grep -Eq 'provider[[:space:]]*=[[:space:]]*"postgresql"' "$TARGET/prisma/schema.prisma" 2>/dev/null; then
      append_project_environment "Postgres"; PROJECT_DATA="${PROJECT_DATA:+$PROJECT_DATA + }Postgres"
    elif grep -Eq 'provider[[:space:]]*=[[:space:]]*"mysql"' "$TARGET/prisma/schema.prisma" 2>/dev/null; then
      append_project_environment "MySQL"; PROJECT_DATA="${PROJECT_DATA:+$PROJECT_DATA + }MySQL"
    elif grep -Eq 'provider[[:space:]]*=[[:space:]]*"sqlite"' "$TARGET/prisma/schema.prisma" 2>/dev/null; then
      append_project_environment "SQLite"; PROJECT_DATA="${PROJECT_DATA:+$PROJECT_DATA + }SQLite"
    elif grep -Eq 'provider[[:space:]]*=[[:space:]]*"mongodb"' "$TARGET/prisma/schema.prisma" 2>/dev/null; then
      append_project_environment "MongoDB"; PROJECT_DATA="${PROJECT_DATA:+$PROJECT_DATA + }MongoDB"
    fi
  fi

  if [ -f "$TARGET/pyproject.toml" ] || [ -f "$TARGET/requirements.txt" ]; then
    [ "$PROJECT_TYPE" = "<PROJECT-TYPE>" ] && PROJECT_TYPE="소프트웨어/Python 프로젝트"
    append_project_environment "Python"
    PROJECT_OUTPUT="${PROJECT_OUTPUT#<PROJECT-OUTPUT>}"
    [ -z "$PROJECT_OUTPUT" ] && PROJECT_OUTPUT="Python 앱"
    if grep -Eiq 'fastapi' "$TARGET/pyproject.toml" "$TARGET/requirements.txt" 2>/dev/null; then
      append_project_environment "FastAPI"
      PROJECT_OUTPUT="API 서비스"
    elif grep -Eiq 'django' "$TARGET/pyproject.toml" "$TARGET/requirements.txt" 2>/dev/null; then
      append_project_environment "Django"
      PROJECT_OUTPUT="웹 앱"
    elif grep -Eiq 'flask' "$TARGET/pyproject.toml" "$TARGET/requirements.txt" 2>/dev/null; then
      append_project_environment "Flask"
      PROJECT_OUTPUT="웹/API 앱"
    elif grep -Eiq 'streamlit' "$TARGET/pyproject.toml" "$TARGET/requirements.txt" 2>/dev/null; then
      append_project_environment "Streamlit"
      PROJECT_OUTPUT="데이터 앱"
    fi
  fi

  if [ -f "$TARGET/Cargo.toml" ]; then
    [ "$PROJECT_TYPE" = "<PROJECT-TYPE>" ] && PROJECT_TYPE="소프트웨어/Rust 프로젝트"
    append_project_environment "Rust"
    [ "$PROJECT_OUTPUT" = "<PROJECT-OUTPUT>" ] && PROJECT_OUTPUT="Rust 앱"
  fi
  if [ -f "$TARGET/go.mod" ]; then
    [ "$PROJECT_TYPE" = "<PROJECT-TYPE>" ] && PROJECT_TYPE="소프트웨어/Go 프로젝트"
    append_project_environment "Go"
    [ "$PROJECT_OUTPUT" = "<PROJECT-OUTPUT>" ] && PROJECT_OUTPUT="Go 앱"
  fi
  if [ -f "$TARGET/Gemfile" ]; then
    [ "$PROJECT_TYPE" = "<PROJECT-TYPE>" ] && PROJECT_TYPE="소프트웨어/Ruby 프로젝트"
    append_project_environment "Ruby"
    [ "$PROJECT_OUTPUT" = "<PROJECT-OUTPUT>" ] && PROJECT_OUTPUT="Ruby 앱"
  fi
  if [ -f "$TARGET/pom.xml" ] || [ -f "$TARGET/build.gradle" ] || [ -f "$TARGET/build.gradle.kts" ]; then
    [ "$PROJECT_TYPE" = "<PROJECT-TYPE>" ] && PROJECT_TYPE="소프트웨어/JVM 프로젝트"
    append_project_environment "JVM"
    [ "$PROJECT_OUTPUT" = "<PROJECT-OUTPUT>" ] && PROJECT_OUTPUT="JVM 앱"
  fi

  if [ -f "$TARGET/vercel.json" ]; then
    PROJECT_DELIVERY="Vercel"
  elif [ -f "$TARGET/netlify.toml" ]; then
    PROJECT_DELIVERY="Netlify"
  elif [ -f "$TARGET/wrangler.toml" ]; then
    PROJECT_DELIVERY="Cloudflare"
  elif [ -f "$TARGET/firebase.json" ]; then
    PROJECT_DELIVERY="Firebase"
  elif [ -f "$TARGET/Dockerfile" ] || [ -f "$TARGET/docker-compose.yml" ] || [ -f "$TARGET/compose.yml" ]; then
    PROJECT_DELIVERY="Docker"
  fi

  if [ -d "$TARGET/docs" ] || ls "$TARGET"/*.md >/dev/null 2>&1; then
    if [ "$PROJECT_TYPE" = "<PROJECT-TYPE>" ]; then
      PROJECT_TYPE="문서/지식 작업공간"
      append_project_environment "Markdown/Git 작업공간"
      PROJECT_OUTPUT="문서/운영 기록"
      PROJECT_DELIVERY="${PROJECT_DELIVERY:-Git 또는 문서 공유}"
    fi
  fi

  [ -n "$PROJECT_ENVIRONMENT" ] || PROJECT_ENVIRONMENT="<PROJECT-ENVIRONMENT>"
  [ -n "$PROJECT_DATA" ] || PROJECT_DATA="<PROJECT-DATA>"
  [ -n "$PROJECT_DELIVERY" ] || PROJECT_DELIVERY="<PROJECT-DELIVERY>"
}

profile_placeholder() {
  case "${1:-}" in
    ""|"<"*) return 0 ;;
    *) return 1 ;;
  esac
}

fill_missing_project_profile_interactive() {
  [ "$ASSUME_YES" -eq 0 ] || return 0
  [ "${SFS_PROJECT_PROFILE_PROMPT:-1}" != "0" ] || return 0

  if profile_placeholder "$PROJECT_TYPE" \
    || profile_placeholder "$PROJECT_ENVIRONMENT" \
    || profile_placeholder "$PROJECT_OUTPUT" \
    || profile_placeholder "$PROJECT_DELIVERY"; then
    info ""
    info "Project profile setup..."
    cat <<'EOF'
Solon 이 SFS.md 프로젝트 개요를 감지값으로 채웁니다.
비워두면 placeholder 를 유지합니다. 나중에 AI runtime 에서 `sfs profile` 로 이 작업만 다시 맡길 수 있습니다.
EOF
  fi

  local answer
  if profile_placeholder "$PROJECT_TYPE"; then
    answer=$(prompt_always "프로젝트 유형? (예: 웹 제품 / 문서 운영 / 내부 자동화)" "")
    [ -n "$answer" ] && PROJECT_TYPE="$answer"
  fi
  if profile_placeholder "$PROJECT_ENVIRONMENT"; then
    answer=$(prompt_always "환경? (기술 stack, 문서 도구, 협업 환경 등)" "")
    [ -n "$answer" ] && PROJECT_ENVIRONMENT="$answer"
  fi
  if profile_placeholder "$PROJECT_OUTPUT"; then
    answer=$(prompt_always "핵심 산출물? (예: 웹 앱 / API / 문서 / playbook)" "")
    [ -n "$answer" ] && PROJECT_OUTPUT="$answer"
  fi
  if profile_placeholder "$PROJECT_DELIVERY"; then
    answer=$(prompt_always "공유/운영 방식? (예: Vercel / GitHub / 로컬 문서)" "")
    [ -n "$answer" ] && PROJECT_DELIVERY="$answer"
  fi
}

prepare_project_profile_replacements() {
  PROJECT_NAME_REPL=$(sed_escape "$PROJECT_NAME")
  PROJECT_TYPE_REPL=$(sed_escape "$PROJECT_TYPE")
  PROJECT_STAGE_REPL=$(sed_escape "$PROJECT_STAGE")
  PROJECT_ENVIRONMENT_REPL=$(sed_escape "$PROJECT_ENVIRONMENT")
  PROJECT_DATA_REPL=$(sed_escape "$PROJECT_DATA")
  PROJECT_OUTPUT_REPL=$(sed_escape "$PROJECT_OUTPUT")
  PROJECT_DELIVERY_REPL=$(sed_escape "$PROJECT_DELIVERY")
}

create_default_model_profile() {
  local runtime="${1:-current}" policy="${2:-current_model}" status="${3:-current_model_fallback}"
  [ -f "$SOURCE_DIR/templates/.sfs-local-template/model-profiles.yaml" ] || return 1

  local today project_name project_name_repl
  today=$(date +%Y-%m-%d)
  project_name="$(basename "$TARGET")"
  project_name_repl="$(sed_escape "$project_name")"
  mkdir -p "$TARGET/.sfs-local"
  cp "$SOURCE_DIR/templates/.sfs-local-template/model-profiles.yaml" "$TARGET/.sfs-local/model-profiles.yaml"
  sed_inplace \
    -e "s|<DATE>|$today|g" \
    -e "s|<SOLON-VERSION>|$NEW_VER|g" \
    -e "s|<PROJECT-NAME>|$project_name_repl|g" \
    -e "s|<DEFAULT-RUNTIME>|$runtime|g" \
    -e "s|<MODEL-POLICY>|$policy|g" \
    -e "s|<MODEL-PROFILE-STATUS>|$status|g" \
    -e "s|<MODEL-CONFIRMED-BY>||g" \
    -e "s|<MODEL-CONFIRMED-AT>||g" \
    "$TARGET/.sfs-local/model-profiles.yaml" 2>/dev/null || true
}

model_profile_needs_prompt() {
  local file="$TARGET/.sfs-local/model-profiles.yaml"
  [ -f "$file" ] || return 0

  local status runtime policy
  status=$(sed -nE 's/^[[:space:]]*status:[[:space:]]*"?([^"#[:space:]]+)"?.*/\1/p' "$file" 2>/dev/null | head -1)
  runtime=$(sed -nE 's/^[[:space:]]*selected_runtime:[[:space:]]*"?([^"#[:space:]]+)"?.*/\1/p' "$file" 2>/dev/null | head -1)
  policy=$(sed -nE 's/^[[:space:]]*selected_policy:[[:space:]]*"?([^"#[:space:]]+)"?.*/\1/p' "$file" 2>/dev/null | head -1)

  grep -Eq '^[[:space:]]*status:[[:space:]]*"?current_model_fallback"?' "$file" 2>/dev/null && return 0
  grep -Eq '^[[:space:]]*status:[[:space:]]*"?review_required"?' "$file" 2>/dev/null && return 0
  grep -Eq '^[[:space:]]*status:[[:space:]]*"?unset"?' "$file" 2>/dev/null && return 0
  [ "${runtime:-unset}" = "unset" ] && return 0
  [ "${policy:-current_model}" = "current_model" ] && return 0
  if [ "$runtime" = "current" ] && [ "$policy" = "current_model" ]; then
    return 0
  fi
  case "$status" in
    selected_at_install|confirmed)
      return 1
      ;;
  esac
  grep -Eq '^[[:space:]]*confirmed_by:[[:space:]]*"?[[:space:]]*"?$' "$file" 2>/dev/null && return 0
  return 1
}

print_model_profile_question() {
  cat <<'EOF'

Agent model profile:
  이 질문은 Solon 의 역할별 agent 가 어떤 모델을 쓸지 정하는 단계입니다.
  예: 설계/판단 agent 는 더 강한 모델, 코드 구현 agent 는 표준 모델, 단순 정리 helper 는 가벼운 모델.

  지금 꼭 정하지 않아도 됩니다.
  건너뛰면 current_model fallback 을 유지하고, 현재 실행 환경에서 사용자가 선택한 모델을
  그대로 씁니다. 순수 터미널에서 실행 중이면 2번이 가장 안전합니다. 나중에 Claude/Codex/Gemini
  중 실제로 쓸 runtime 기준으로 다시 설정할 수 있고, 다음 upgrade 때도 다시 안내합니다.

  선택지:
    1. Claude 권장: 설계/평가 Opus 4.7, 구현 Sonnet 4.6, helper Haiku (가장 흔한 기본값)
    2. 지금 설정 안 함: current_model fallback 유지 (처음이면 이걸 골라도 안전)
    3. Codex 권장: 설계/평가 GPT-5.5 high reasoning, 구현 GPT-5.5 medium, helper mini/low
    4. Gemini 권장: 설계/평가 high reasoning, 구현 balanced, helper flash/economy
    5. all_high: 모든 agent/helper 를 high-end 로 설정 (품질 우선, 비용/지연 증가 가능)
    6. custom/manual: 직접 모델 profile 작성

  순수 터미널이면 번호만 직접 입력하면 됩니다.
  Claude/Codex/Gemini 같은 AI runtime 이 대신 실행 중이면 이 설명과 선택지를 사용자에게 보여주고
  번호를 받아 적용하세요. 사용자가 "지금 설정 안 함" 이라고 하면 current_model fallback 으로 두고
  계속 진행하면 됩니다.
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
  if [ -n "${SFS_MODEL_RUNTIME:-}" ] || [ -n "${SFS_MODEL_POLICY:-}" ]; then
    local env_runtime="${SFS_MODEL_RUNTIME:-current}"
    local env_policy="${SFS_MODEL_POLICY:-}"
    local env_status="confirmed"
    local now

    if [ -z "$env_policy" ]; then
      if [ "$env_runtime" = "current" ]; then
        env_policy="current_model"
      else
        env_policy="solon_recommended"
      fi
    fi

    case "$env_runtime" in
      current|claude|codex|gemini|custom) ;;
      *) warn "알 수 없는 SFS_MODEL_RUNTIME='$env_runtime' — current 로 기록"; env_runtime="current" ;;
    esac
    case "$env_policy" in
      current_model|solon_recommended|all_high|custom) ;;
      recommended) env_policy="solon_recommended" ;;
      all-high) env_policy="all_high" ;;
      skip|none|"") env_policy="current_model" ;;
      *) warn "알 수 없는 SFS_MODEL_POLICY='$env_policy' — current_model 로 기록"; env_policy="current_model" ;;
    esac

    now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    if [ "$env_policy" = "current_model" ]; then
      env_status="current_model_fallback"
      set_model_profile_fields "$env_runtime" "$env_policy" "$env_status" "" ""
    else
      set_model_profile_fields "$env_runtime" "$env_policy" "$env_status" "sfs upgrade env" "$now"
    fi
    ok "agent model profile env 적용: runtime=$env_runtime, policy=$env_policy, status=$env_status"
    return 0
  fi

  model_profile_needs_prompt || return 0

  if [ "${SFS_MODEL_PROFILE_PROMPT:-1}" = "0" ]; then
    warn "agent model profile fallback 상태 — SFS_MODEL_PROFILE_PROMPT=0 이라 이번 질문은 건너뜀"
    warn "    current_model fallback 유지. 다음 upgrade 에서 다시 질문됩니다."
    return 0
  fi

  if [ "$ASSUME_YES" -eq 1 ]; then
    warn "--yes 활성화 — agent model profile 질문은 건너뛰고 current_model fallback 을 유지"
    warn "    나중에 sfs upgrade 또는 .sfs-local/model-profiles.yaml 편집으로 Claude/Codex/Gemini profile 을 확정할 수 있습니다."
    return 0
  fi

  if [ ! -t 0 ]; then
    print_model_profile_question
    return 0
  fi

  print_model_profile_question
  local choice runtime now
  choice="$(prompt_always "agent model profile 선택? (1/2/3/4/5/6, 처음이면 2 권장)" "2")"
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
      set_model_profile_fields "codex" "solon_recommended" "confirmed" "sfs upgrade" "$now"
      ok "agent model profile 확정: Codex 권장 (GPT-5.5 high/medium + mini/low)"
      ;;
    4)
      set_model_profile_fields "gemini" "solon_recommended" "confirmed" "sfs upgrade" "$now"
      ok "agent model profile 확정: Gemini 권장 (high/balanced/flash tiers)"
      ;;
    5)
      runtime="$(prompt_always "all_high 를 적용할 runtime? (current/claude/codex/gemini/custom)" "current")"
      case "$runtime" in
        current|claude|codex|gemini|custom) ;;
        *) warn "알 수 없는 runtime='$runtime' — current 로 기록"; runtime="current" ;;
      esac
      set_model_profile_fields "$runtime" "all_high" "confirmed" "sfs upgrade" "$now"
      ok "agent model profile 확정: runtime=$runtime, policy=all_high"
      ;;
    6)
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
PROJECT_NAME="$(basename "$TARGET")"
detect_project_profile
fill_missing_project_profile_interactive
prepare_project_profile_replacements

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
  sfs init --yes                          injects SFS.md, .sfs-local/, and agent adapters into this project.
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

SAME_VERSION=0
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
  SAME_VERSION=1
  warn "버전은 같지만 project adapter/docs refresh 를 계속합니다. stale 템플릿과 빈 프로젝트 개요를 보정합니다."
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
      ".sfs-local/GUIDE.md"|.sfs-local/scripts/*|.sfs-local/sprint-templates/*|.sfs-local/personas/*|.sfs-local/decisions-template/*)
        printf "skip (thin runtime)"
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
    ".sfs-local/auth.env.example")
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
  - .claude/skills/sfs/SKILL.md        → backup+overwrite (Claude Code Skill 최신화)
  - .claude/commands/sfs.md            → backup+overwrite (legacy 커맨드 fallback 최신화)
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
  ".sfs-local/GUIDE.md|GUIDE.md"
  # scripts/ — Solon-versioned bash adapters (executable, user 수정 영역 아님)
  ".sfs-local/scripts/sfs-dispatch.sh|templates/.sfs-local-template/scripts/sfs-dispatch.sh"
  ".sfs-local/scripts/sfs.ps1|templates/.sfs-local-template/scripts/sfs.ps1"
  ".sfs-local/scripts/sfs-common.sh|templates/.sfs-local-template/scripts/sfs-common.sh"
  ".sfs-local/scripts/sfs-status.sh|templates/.sfs-local-template/scripts/sfs-status.sh"
  ".sfs-local/scripts/sfs-start.sh|templates/.sfs-local-template/scripts/sfs-start.sh"
  ".sfs-local/scripts/sfs-guide.sh|templates/.sfs-local-template/scripts/sfs-guide.sh"
  ".sfs-local/scripts/sfs-auth.sh|templates/.sfs-local-template/scripts/sfs-auth.sh"
  ".sfs-local/scripts/sfs-profile.sh|templates/.sfs-local-template/scripts/sfs-profile.sh"
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
  # 0.5.0-mvp 신규: multi-adaptor parity (Gemini CLI native slash + Codex Skill)
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
  - backup+overwrite 대상은 기존 파일을 .sfs-local/tmp/upgrade-backups/ 아래에 보관한 뒤 갱신합니다.

EOF

echo ""
if [ "$(prompt "업그레이드 진행?" "y")" != "y" ]; then
  info "취소됨."
  exit 0
fi

# ============================================================================
# 4. 파일별 갱신 (checksum 기반 자동 처리)
# ============================================================================

update_file() {
  local dst_rel="$1" src_rel="$2" label="$3" recommended="${4:-s}"
  local dst="$TARGET/$dst_rel" src="$SOURCE_DIR/$src_rel"

  if [ "${INSTALL_LAYOUT:-vendored}" = "thin" ]; then
    case "$dst_rel" in
      ".sfs-local/GUIDE.md"|.sfs-local/scripts/*|.sfs-local/sprint-templates/*|.sfs-local/personas/*|.sfs-local/decisions-template/*)
        ok "thin runtime 사용 — project-local managed asset skip: $dst_rel"
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
      local ts backup_dir safe_rel backup_path backup_rel
      ts=$(date +%Y%m%d-%H%M%S)
      backup_dir="$TARGET/.sfs-local/tmp/upgrade-backups/$ts"
      mkdir -p "$backup_dir"
      safe_rel="${dst_rel//\//__}"
      backup_path="$backup_dir/$safe_rel"
      backup_rel="${backup_path#$TARGET/}"
      mv "$dst" "$backup_path"
      cp "$src" "$dst"
      ok "백업 + 갱신: $dst_rel → $backup_rel"
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

update_file "CLAUDE.md" "templates/CLAUDE.md.template" "Claude Code 어댑터" "s"
update_file "SFS.md" "templates/SFS.md.template" "공통 SFS 지침" "b"
update_file "AGENTS.md" "templates/AGENTS.md.template" "Codex 어댑터" "s"
update_file "GEMINI.md" "templates/GEMINI.md.template" "Gemini CLI 어댑터" "s"
mkdir -p "$TARGET/.claude/commands"
mkdir -p "$TARGET/.claude/skills/sfs"
update_file ".claude/skills/sfs/SKILL.md" "templates/.claude/commands/sfs.md" "Claude Code /sfs Skill" "b"
update_file ".claude/commands/sfs.md" "templates/.claude/commands/sfs.md" "Claude Code /sfs 커맨드" "b"
update_file ".sfs-local/divisions.yaml" "templates/.sfs-local-template/divisions.yaml" "본부 활성화" "s"
update_file ".sfs-local/model-profiles.yaml" "templates/.sfs-local-template/model-profiles.yaml" "runtime model profiles" "s"
update_file ".sfs-local/auth.env.example" "templates/.sfs-local-template/auth.env.example" "executor auth env example" "b"
update_file ".sfs-local/GUIDE.md" "GUIDE.md" "Solon onboarding guide (/sfs guide)" "b"

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
update_file ".sfs-local/scripts/sfs-profile.sh"  "templates/.sfs-local-template/scripts/sfs-profile.sh"  "sfs profile"  "b"
update_file ".sfs-local/scripts/sfs-brainstorm.sh" "templates/.sfs-local-template/scripts/sfs-brainstorm.sh" "sfs brainstorm" "b"
update_file ".sfs-local/scripts/sfs-plan.sh"     "templates/.sfs-local-template/scripts/sfs-plan.sh"     "sfs plan"     "b"
update_file ".sfs-local/scripts/sfs-implement.sh" "templates/.sfs-local-template/scripts/sfs-implement.sh" "sfs implement" "b"
update_file ".sfs-local/scripts/sfs-review.sh"   "templates/.sfs-local-template/scripts/sfs-review.sh"   "sfs review"   "b"
update_file ".sfs-local/scripts/sfs-decision.sh" "templates/.sfs-local-template/scripts/sfs-decision.sh" "sfs decision (WU-26)" "b"
update_file ".sfs-local/scripts/sfs-report.sh"   "templates/.sfs-local-template/scripts/sfs-report.sh"   "sfs report (final report + compaction)" "b"
update_file ".sfs-local/scripts/sfs-retro.sh"    "templates/.sfs-local-template/scripts/sfs-retro.sh"    "sfs retro --close (WU-26)" "b"
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

# multi-adaptor parity (0.5.0-mvp 신규): Gemini CLI native slash + Codex Skill
# 신규: .gemini/commands/sfs.toml + .agents/skills/sfs/SKILL.md
# Claude Code 1급 (.claude/commands/sfs.md) 와 동등 entry point.
mkdir -p "$TARGET/.gemini/commands"
mkdir -p "$TARGET/.agents/skills/sfs"
update_file ".gemini/commands/sfs.toml"   "templates/.gemini/commands/sfs.toml"   "Gemini CLI /sfs 슬래시 (TOML)"  "b"
update_file ".agents/skills/sfs/SKILL.md" "templates/.agents/skills/sfs/SKILL.md" "Codex Skill (project-scoped)"  "b"

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
      -e "s|<PROJECT-NAME>|$PROJECT_NAME_REPL|g" \
      -e "s|<PROJECT-TYPE>|$PROJECT_TYPE_REPL|g" \
      -e "s|<PROJECT-STAGE>|$PROJECT_STAGE_REPL|g" \
      -e "s|<PROJECT-ENVIRONMENT>|$PROJECT_ENVIRONMENT_REPL|g" \
      -e "s|<PROJECT-DATA>|$PROJECT_DATA_REPL|g" \
      -e "s|<PROJECT-OUTPUT>|$PROJECT_OUTPUT_REPL|g" \
      -e "s|<PROJECT-DELIVERY>|$PROJECT_DELIVERY_REPL|g" \
      -e "s|<DOMAIN>|$PROJECT_TYPE_REPL|g" \
      -e "s|<STACK>|$PROJECT_ENVIRONMENT_REPL|g" \
      -e "s|<DB>|$PROJECT_DATA_REPL|g" \
      -e "s|<DEPLOY>|$PROJECT_DELIVERY_REPL|g" \
      -e "s|<DEFAULT-RUNTIME>|$MODEL_RUNTIME|g" \
      -e "s|<MODEL-POLICY>|$MODEL_POLICY|g" \
      -e "s|<MODEL-PROFILE-STATUS>|$MODEL_PROFILE_STATUS|g" \
      "$auto_file" 2>/dev/null || true
  fi
done
ok "문서 자동 치환: <DATE>=$TODAY, <SOLON-VERSION>=$NEW_VER, project profile"

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

VERSION_SUMMARY="$CUR_VER → $NEW_VER"
COMMIT_MESSAGE="chore: upgrade solon-product $CUR_VER → $NEW_VER"
if [ "${SAME_VERSION:-0}" -eq 1 ]; then
  VERSION_SUMMARY="$NEW_VER (same-version refresh)"
  COMMIT_MESSAGE="chore: refresh solon-product $NEW_VER"
fi

cat <<EOF

${C_BOLD}${C_GREEN}=== 업그레이드 완료 ===${C_RESET}

  $VERSION_SUMMARY

Agent model profile:
  ${MODEL_PROFILE_NOTICE:-설정 파일 유지됨: .sfs-local/model-profiles.yaml}

Project profile:
  SFS.md 프로젝트 개요를 감지값으로 치환했습니다. 미감지 placeholder 만 남아 있으면 sfs profile 로 좁게 보정하세요.

  Solon 권장은 C-Level/review high, worker standard, helper economy 입니다.
  프로젝트가 비용/지연을 감수한다면 worker/helper 도 high-end 모델로 설정해도 됩니다.
  설정을 안 하거나 거부하면 현재 런타임에서 사용자가 선택한 모델을 그대로 씁니다.
  Codex 는 model + reasoning_effort 조합(예: gpt-5.5 + xhigh/very_high), Claude 는 opus/sonnet/haiku 계열,
  Gemini/custom 은 프로젝트 runtime 이 지원하는 profile 이름으로 agent별 override 가능합니다.

변경사항 git commit 권장:
  ${C_BLUE}git add SFS.md CLAUDE.md AGENTS.md GEMINI.md .gitignore \\${C_RESET}
  ${C_BLUE}        .claude/skills/sfs/SKILL.md .claude/commands/sfs.md \\${C_RESET}
  ${C_BLUE}        .gemini/commands/sfs.toml \\${C_RESET}
  ${C_BLUE}        .agents/skills/sfs/SKILL.md .sfs-local/${C_RESET}
  ${C_BLUE}git commit -m "$COMMIT_MESSAGE"${C_RESET}

CHANGELOG: https://github.com/${SOLON_REPO}/blob/main/CHANGELOG.md

EOF
