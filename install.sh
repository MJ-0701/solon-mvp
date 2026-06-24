#!/usr/bin/env bash
# install.sh — Solon Product installer
#
# 사용법 (dual mode):
#   (1) 원격: curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.sh | bash
#   (2) 로컬: git clone https://github.com/MJ-0701/solon-product ~/tmp/solon-product
#             cd ~/workspace/my-project
#             ~/tmp/solon-product/install.sh
#   (3) 비대화형: ./install.sh --yes
#
# 원칙:
#   - 현 작업 디렉토리 (consumer project) 에 Solon 7-step flow 스캐폴드 주입
#   - 기존 파일 충돌 시 대화형 처리 (skip / backup / overwrite / diff)
#   - .sfs-local/ 은 merge 모드 (기존 sprints/decisions 산출물 보존)
#   - 멱등성 (idempotent) — 재실행해도 사용자 기존 자산 파괴하지 않음
#   - 오류 시 early exit, 롤백은 사용자 git 으로
#
# 참고: 본 스크립트는 Solon Product 설치 엔트리포인트 — 풀스펙 아님 (사용자 개인 방법론 docset 참조).

set -euo pipefail

ASSUME_YES=0
INSTALL_LAYOUT="${SFS_INSTALL_LAYOUT:-vendored}"
INSTALL_AGENT_ADAPTERS="${SFS_INSTALL_AGENT_ADAPTERS:-}"
INSTALL_TEAM="${SFS_AGENT_TEAM:-solo}"   # solo | pair | trio (기본 solo = 현재 동작 무변경)

usage() {
  cat <<EOF
Usage: ./install.sh [--yes] [--layout thin|vendored]

Options:
  -y, --yes           모든 확인 프롬프트를 자동 승인합니다.
                      파일 충돌 시에는 안전한 기본값(skip)을 사용합니다.
  --layout thin       프로젝트에는 state/config/custom override 만 설치합니다.
                      runtime 은 PATH 의 global `sfs` CLI 를 사용합니다.
  --layout vendored   기존 방식입니다. scripts/templates/personas 를 프로젝트에 복사합니다.
  --with-agent-adapters
                      thin layout 에서도 .claude/.gemini/.agents command/skill
                      adapter 파일을 프로젝트에 설치합니다. 기본값은 opt-in 입니다.
  --team solo|pair|trio
                      멀티에이전트 team topology preset. solo(기본)=현재 동작
                      그대로. pair/trio 는 model-profiles 의 agent_runtime_bindings
                      를 채우고 어댑터에 role-scoped dispatch rule 을 주입합니다.
  -h, --help          도움말을 출력합니다.

Environment:
  SFS_MODEL_RUNTIME   current|claude|codex|gemini|custom (default: current)
  SFS_MODEL_POLICY    current_model|solon_recommended|all_high|custom (default: solon_recommended)
  SFS_MODEL_PROFILE_PROMPT=1  agent/model profile 선택지를 이번 install 에서 표시
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
    --layout)
      shift
      [ $# -gt 0 ] || { echo "알 수 없는 옵션: --layout 값 필요 (thin|vendored)" >&2; exit 99; }
      INSTALL_LAYOUT="$1"
      ;;
    --layout=*)
      INSTALL_LAYOUT="${1#--layout=}"
      ;;
    --with-agent-adapters|--agent-adapters)
      INSTALL_AGENT_ADAPTERS=1
      ;;
    --team)
      shift
      [ $# -gt 0 ] || { echo "알 수 없는 옵션: --team 값 필요 (solo|pair|trio)" >&2; exit 99; }
      INSTALL_TEAM="$1"
      ;;
    --team=*)
      INSTALL_TEAM="${1#--team=}"
      ;;
    *)
      echo "알 수 없는 옵션: $1 (지원: --yes, --layout, --team, --help)" >&2
      exit 99
      ;;
  esac
  shift
done

case "$INSTALL_LAYOUT" in
  thin|vendored) ;;
  *)
    echo "알 수 없는 layout: $INSTALL_LAYOUT (지원: thin, vendored)" >&2
    exit 99
    ;;
esac

case "$INSTALL_TEAM" in
  solo|pair|trio) ;;
  *)
    echo "알 수 없는 team preset: $INSTALL_TEAM (지원: solo, pair, trio)" >&2
    exit 99
    ;;
esac

if [ -z "$INSTALL_AGENT_ADAPTERS" ]; then
  if [ "$INSTALL_LAYOUT" = "thin" ]; then
    INSTALL_AGENT_ADAPTERS=0
  else
    INSTALL_AGENT_ADAPTERS=1
  fi
fi
case "$INSTALL_AGENT_ADAPTERS" in
  0|1) ;;
  true|TRUE|yes|YES) INSTALL_AGENT_ADAPTERS=1 ;;
  false|FALSE|no|NO) INSTALL_AGENT_ADAPTERS=0 ;;
  *)
    echo "알 수 없는 SFS_INSTALL_AGENT_ADAPTERS='$INSTALL_AGENT_ADAPTERS' (지원: 0|1)" >&2
    exit 99
    ;;
esac

# ============================================================================
# 0. 상수 / 색상
# ============================================================================

readonly SOLON_REPO="MJ-0701/solon-product"
readonly SOLON_BRANCH="main"
readonly GIT_MARKER_BEGIN="### BEGIN solon-product ###"
readonly GIT_MARKER_END="### END solon-product ###"
# Legacy markers (0.5.0-mvp 이전 install) — uninstall / upgrade 가 fallback 으로 인식.
readonly LEGACY_GIT_MARKER_BEGIN="### BEGIN solon-mvp ###"
readonly LEGACY_GIT_MARKER_END="### END solon-mvp ###"

# TTY 이면 색상 on
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  C_RED=$(tput setaf 1)
  C_GREEN=$(tput setaf 2)
  C_YELLOW=$(tput setaf 3)
  C_BLUE=$(tput setaf 4)
  C_BOLD=$(tput bold)
  C_RESET=$(tput sgr0)
else
  C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_BOLD=""; C_RESET=""
fi

info()  { printf "%s%s%s\n" "$C_BLUE" "$*" "$C_RESET"; }
ok()    { printf "  %s✓%s %s\n" "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf "  %s⚠%s %s\n" "$C_YELLOW" "$C_RESET" "$*"; }
err()   { printf "  %s✗%s %s\n" "$C_RED" "$C_RESET" "$*" >&2; }
die()   { err "$*"; exit 1; }

# ============================================================================
# 1. 대화형 read helper (curl | bash 에서도 TTY 읽기 가능)
# ============================================================================

# stdin 이 pipe (curl | bash) 면 /dev/tty 로 전환
if [ "$ASSUME_YES" -ne 1 ] && [ ! -t 0 ]; then
  if [ -r /dev/tty ] && { : < /dev/tty; } 2>/dev/null; then
    exec < /dev/tty
  else
    die "대화형 input 불가 (stdin 파이프 + /dev/tty 없음). 로컬 실행 권장: git clone ... && ./install.sh"
  fi
fi

prompt() {
  # prompt "질문" "기본값(선택)"
  local msg="$1"
  local default="${2:-}"
  local answer

  if [ "$ASSUME_YES" -eq 1 ] && [ -n "$default" ]; then
    printf "%s [%s]: %s\n" "$msg" "$default" "$default" >&2
    echo "$default"
    return 0
  fi

  if [ -n "$default" ]; then
    printf "%s [%s]: " "$msg" "$default" >&2
  else
    printf "%s: " "$msg" >&2
  fi
  read -r answer || answer=""
  echo "${answer:-$default}"
}

confirm() {
  # confirm "질문" → y/Y/yes → 0, 나머지 → 1
  local ans
  if [ "$ASSUME_YES" -eq 1 ]; then
    # ASSUME_YES 분기에서는 prompt 자체를 묵음으로 — 비대화 모드의 정의 그대로.
    # 0.6.143 이전엔 "<질문> (y/N) [N]: y" 한 줄을 stderr 로 흘려서
    # test runner stderr 가 stdout 으로 합류할 때 한국어 prompt 가 결과에
    # 누설되는 부작용이 있었다 (run-all.sh 스트림 통합). SFS_INSTALL_VERBOSE_CONFIRM=1
    # 로 명시적 opt-in 시에만 prompt 를 보여준다.
    case "${SFS_INSTALL_VERBOSE_CONFIRM:-0}" in
      1|true|TRUE|yes|YES|on|ON)
        printf "%s (y/N) [N]: y\n" "$1" >&2
        ;;
    esac
    return 0
  fi
  ans=$(prompt "$1 (y/N)" "N")
  case "$ans" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

confirm_default_yes() {
  # confirm with recommended default = YES (install). Decline only on explicit n/N.
  # Under ASSUME_YES (--yes) → install. Mirrors confirm() but flips the default
  # for "recommended-default + opt-out" surfaces (e.g. the llm-wiki vault).
  local ans
  if [ "$ASSUME_YES" -eq 1 ]; then
    case "${SFS_INSTALL_VERBOSE_CONFIRM:-0}" in
      1|true|TRUE|yes|YES|on|ON) printf "%s (Y/n) [Y]: y\n" "$1" >&2 ;;
    esac
    return 0
  fi
  ans=$(prompt "$1 (Y/n)" "Y")
  case "$ans" in
    n|N|no|NO) return 1 ;;
    *) return 0 ;;
  esac
}

tty_available() {
  [ -t 0 ] && return 0
  [ -r /dev/tty ] && { : < /dev/tty; } 2>/dev/null
}

prompt_model_always() {
  local msg="$1" default="${2:-}" answer
  if [ -t 0 ]; then
    if [ -n "$default" ]; then printf "%s [%s]: " "$msg" "$default" >&2
    else printf "%s: " "$msg" >&2; fi
    read -r answer || answer=""
  elif [ -r /dev/tty ] && { : < /dev/tty; } 2>/dev/null; then
    if [ -n "$default" ]; then printf "%s [%s]: " "$msg" "$default" > /dev/tty
    else printf "%s: " "$msg" > /dev/tty; fi
    read -r answer < /dev/tty || answer=""
  else
    answer="$default"
  fi
  echo "${answer:-$default}"
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

choose_initial_model_profile() {
  if [ -n "${SFS_MODEL_RUNTIME:-}" ] || [ -n "${SFS_MODEL_POLICY:-}" ]; then
    return 0
  fi

  if [ "${SFS_MODEL_PROFILE_PROMPT:-0}" != "1" ]; then
    ok "agent model profile 기본값 적용 — solon_recommended role routing"
    return 0
  fi

  print_model_profile_question
  if ! tty_available; then
    warn "대화형 입력 불가 — solon_recommended role routing 기본값으로 설치"
    return 0
  fi

  local choice runtime
  choice="$(prompt_model_always "agent model profile 선택? (1/2/3/4, 기본은 1)" "1")"
  case "$choice" in
    1)
      MODEL_RUNTIME="current"
      MODEL_POLICY="solon_recommended"
      MODEL_PROFILE_STATUS="default_applied"
      ;;
    2|"")
      MODEL_RUNTIME="current"
      MODEL_POLICY="current_model"
      MODEL_PROFILE_STATUS="selected_at_install"
      ;;
    3)
      runtime="$(prompt_model_always "all_high 를 적용할 runtime? (claude/codex/gemini/custom/current)" "claude")"
      case "$runtime" in
        claude|codex|gemini|custom|current) ;;
        *) warn "알 수 없는 runtime='$runtime' — current 로 기록"; runtime="current" ;;
      esac
      MODEL_RUNTIME="$runtime"
      MODEL_POLICY="all_high"
      MODEL_PROFILE_STATUS="selected_at_install"
      ;;
    4)
      MODEL_RUNTIME="custom"
      MODEL_POLICY="custom"
      MODEL_PROFILE_STATUS="review_required"
      warn "custom/manual 선택 — 설치 후 .sfs-local/model-profiles.yaml 을 직접 채우면 됩니다."
      warn "    status=review_required 로 남겨 다음 upgrade/사용자 발화 때 다시 안내됩니다."
      ;;
    *)
      warn "알 수 없는 선택 '$choice' — solon_recommended 기본값으로 설치"
      MODEL_RUNTIME="current"
      MODEL_POLICY="solon_recommended"
      MODEL_PROFILE_STATUS="default_applied"
      ;;
  esac
}

# ============================================================================
# 2. 모드 판별 (local vs remote)
# ============================================================================

SOURCE_DIR=""
TMP_CLONE=""
cleanup() {
  if [ -n "$TMP_CLONE" ] && [ -d "$TMP_CLONE" ]; then
    rm -rf "$TMP_CLONE"
  fi
}
trap cleanup EXIT INT TERM

SCRIPT_PATH="${BASH_SOURCE[0]:-}"
if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
  SOURCE_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
  if [ -d "$SOURCE_DIR/templates" ]; then
    MODE="local"
  else
    MODE="remote"   # 스크립트만 있고 templates/ 없음 → 원격 모드
  fi
else
  MODE="remote"
fi

# ============================================================================
# 3. 배너
# ============================================================================

cat <<EOF

${C_BOLD}=== Solon Product Installer ===${C_RESET}

모드:   $MODE
layout: $INSTALL_LAYOUT
타겟:   $(pwd)
Solon:  https://github.com/${SOLON_REPO} (branch: $SOLON_BRANCH)

Solon Product 는 AI-native sprint flow (브레인스토밍 → plan → 구현 → review → retro) 를
현재 프로젝트에 주입합니다. report 는 sprint close 때 함께 정리됩니다. .sfs-local/ 스캐폴드 + SFS.md 공통 지침 +
Claude/Codex/Gemini 어댑터 + .gitignore 규칙이 설치됩니다.

EOF

if [ "$INSTALL_LAYOUT" = "thin" ]; then
  info "thin layout: 프로젝트에는 state/config/custom override 만 두고, runtime 은 global 'sfs' CLI 를 사용합니다."
  if [ "$INSTALL_AGENT_ADAPTERS" = "0" ]; then
    info "thin layout: project-local .claude/.gemini/.agents command/skill adapters 는 기본 설치하지 않습니다."
  fi
  if ! command -v sfs >/dev/null 2>&1; then
    warn "PATH 에 global 'sfs' CLI 가 없습니다. 설치 후 명령 실행 전 brew/source package 로 sfs 를 노출해야 합니다."
  fi
fi

if [ "$ASSUME_YES" -eq 1 ]; then
  info "--yes 활성화: 확인 프롬프트를 자동 승인하고, 충돌 시 기본값을 사용합니다."
else
  info "입력 필요: 계속 설치하려면 'y' 를 입력하고 Enter 를 누르세요."
fi

if ! confirm "계속 진행할까요?"; then
  info "중단됨."
  exit 0
fi

# ============================================================================
# 4. 원격 모드: git clone
# ============================================================================

if [ "$MODE" = "remote" ]; then
  command -v git >/dev/null || die "git 미설치 (Solon 은 consumer repo 가 git 이어야 함)"
  TMP_CLONE=$(mktemp -d -t solon-product-install.XXXXXX)
  info ""
  info "Fetching Solon Product (depth=1)..."
  if ! git clone --quiet --depth=1 --branch="$SOLON_BRANCH" \
       "https://github.com/${SOLON_REPO}.git" "$TMP_CLONE" 2>&1; then
    die "git clone 실패 — 네트워크 또는 repo 권한 확인"
  fi
  SOURCE_DIR="$TMP_CLONE"
  ok "clone 완료: $TMP_CLONE"
fi

# 필수 template 확인
[ -d "$SOURCE_DIR/templates" ] || die "templates/ 디렉토리 없음 — 배포 손상 가능성"

# ============================================================================
# 5. 타겟 pre-flight
# ============================================================================

TARGET="$(pwd)"
PROJECT_NAME="$(basename "$TARGET")"

info ""
info "Pre-flight check..."

if [ ! -d .git ]; then
  warn "현 디렉토리에 .git 없음 (Solon 은 git repo 를 권장)"
  if confirm "  → 지금 'git init' 실행할까요?"; then
    git init --quiet
    ok "git init 완료"
  else
    warn "git 없이 진행 — version control 없이 운용하는 건 비권장"
  fi
fi

MODEL_RUNTIME="${SFS_MODEL_RUNTIME:-current}"
MODEL_POLICY="${SFS_MODEL_POLICY:-solon_recommended}"
MODEL_PROFILE_STATUS="default_applied"

info ""
info "Agent model profile setup..."
cat <<EOF
Solon 은 agent 별 모델 설정을 프로젝트 로컬 파일에 남깁니다:
  .sfs-local/model-profiles.yaml

기본값은 Solon recommended role routing 입니다. deterministic intake 는 가벼운 모델,
질문 생성/facilitation 은 standard 모델, product identity/architecture/gate 판단과 review 는
high reasoning, 구현 worker 는 fixed-slice standard, helper 는 economy 로 나눕니다.
단, 프로젝트가 비용/지연을 감수한다면 worker/helper 까지 전부 high-end 모델로 두는 것도 허용합니다.
사용자가 따로 설정하지 않아도 이 기본 라우팅이 적용됩니다. current_model 은 명시적 opt-out 입니다.
EOF

choose_initial_model_profile

# F4: team preset 발견가능성 surface. model-profile 선택과 동일 게이트(인터랙티브 +
# SFS_MODEL_PROFILE_PROMPT=1)에서 함께 묻는다. 기본 solo = 무변경, --team/SFS_AGENT_TEAM
# 로 이미 비-solo 가 지정됐으면 그 값을 존중하고 묻지 않는다. 비대화/--yes = solo 유지.
choose_initial_team_preset() {
  [ "$INSTALL_TEAM" = "solo" ] || return 0
  [ "${SFS_MODEL_PROFILE_PROMPT:-0}" = "1" ] || return 0
  tty_available || return 0
  info "멀티에이전트 team preset 선택:"
  info "    solo  단독 실행(기본, 현재 동작) / pair  lead+worker / trio  lead+worker+researcher"
  local choice
  choice="$(prompt_model_always "team preset? (solo/pair/trio, 기본 solo)" "solo")"
  case "$choice" in
    pair|trio) INSTALL_TEAM="$choice" ;;
    solo|"") INSTALL_TEAM="solo" ;;
    *) warn "알 수 없는 team preset '$choice' — solo 로 설치"; INSTALL_TEAM="solo" ;;
  esac
}
choose_initial_team_preset

case "$MODEL_RUNTIME" in
  current|claude|codex|gemini|custom) ;;
  unset|"")
    MODEL_RUNTIME="current"
    ;;
  *)
    warn "알 수 없는 SFS_MODEL_RUNTIME='$MODEL_RUNTIME' — current 로 기록"
    MODEL_RUNTIME="current"
    ;;
esac

case "$MODEL_POLICY" in
  current_model|solon_recommended|all_high|custom) ;;
  recommended)
    MODEL_POLICY="solon_recommended"
    ;;
  all-high)
    MODEL_POLICY="all_high"
    ;;
  skip|none|"")
    MODEL_POLICY="solon_recommended"
    ;;
  *)
    warn "알 수 없는 SFS_MODEL_POLICY='$MODEL_POLICY' — solon_recommended 기본값으로 기록"
    MODEL_POLICY="solon_recommended"
    ;;
esac

if [ "$MODEL_PROFILE_STATUS" != "review_required" ] \
   && { [ "$MODEL_RUNTIME" != "current" ] || [ "$MODEL_POLICY" != "solon_recommended" ]; }; then
  MODEL_PROFILE_STATUS="selected_at_install"
fi
ok "model profile 선택: runtime=$MODEL_RUNTIME, policy=$MODEL_POLICY, status=$MODEL_PROFILE_STATUS"

# ============================================================================
# 6. 파일별 설치 (대화형 충돌 처리)
# ============================================================================

# install_file <source_rel> <dest_rel> <설명>
install_file() {
  local src="$SOURCE_DIR/$1"
  local dst="$TARGET/$2"
  local label="$3"

  [ -f "$src" ] || { err "source 없음: $src"; return 1; }

  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    ok "설치: $2 ($label)"
    return 0
  fi

  # 충돌
  warn "$2 이미 존재 ($label)"
  local size_old size_new
  size_old=$(wc -l < "$dst" 2>/dev/null || echo "?")
  size_new=$(wc -l < "$src" 2>/dev/null || echo "?")
  printf "    기존: %s 줄 / 신규: %s 줄\n" "$size_old" "$size_new"
  printf "    선택: [s] 건너뛰기 / [b] 백업 후 덮어쓰기 / [o] 바로 덮어쓰기 / [d] diff\n"

  while true; do
    local ans
    ans=$(prompt "    선택?" "s")
    case "$ans" in
      s|S|"")
        ok "skip: $2 (기존 유지)"
        return 0
        ;;
      b|B)
        local ts=$(date +%Y%m%d-%H%M%S)
        mv "$dst" "$dst.bak-$ts"
        cp "$src" "$dst"
        ok "백업 후 설치: $2 → $2.bak-$ts"
        return 0
        ;;
      o|O)
        cp "$src" "$dst"
        ok "덮어쓰기: $2"
        return 0
        ;;
      d|D)
        printf "\n--- diff (기존 vs 신규) ---\n"
        diff -u "$dst" "$src" || true
        printf "--- end diff ---\n\n"
        # 루프 재진입
        ;;
      *)
        warn "    '$ans' 인식 불가 — s/b/o/d 중 선택"
        ;;
    esac
  done
}

info ""
info "파일 설치 (대화형)..."

# 6.1) Runtime-neutral SFS core + adapter files
install_file "templates/SFS.md.template" "SFS.md" "공통 SFS 지침"
install_file "templates/CLAUDE.md.template" "CLAUDE.md" "Claude Code 어댑터"
install_file "templates/AGENTS.md.template" "AGENTS.md" "Codex 어댑터"
install_file "templates/GEMINI.md.template" "GEMINI.md" "Gemini CLI 어댑터"

if [ "$INSTALL_AGENT_ADAPTERS" = "1" ]; then
  # 6.2) Claude Code slash command adapter
  mkdir -p "$TARGET/.claude/commands"
  install_file "templates/.claude/commands/sfs.md" ".claude/commands/sfs.md" "Claude Code /sfs 커맨드"

  # 6.2a0) Claude Code Stop hook template: suggest-only self-improve hints.
  mkdir -p "$TARGET/.claude/hooks"
  install_file "templates/.claude/hooks/solon-stop-suggest.sh" ".claude/hooks/solon-stop-suggest.sh" "Claude Code Stop hook (suggest-only)"

  # 6.2a1) Register the Stop hook in .claude/settings.json. Claude Code only
  # runs hooks declared in settings — copying the script alone is a no-op (the
  # WU-0 root cause for the silent evidence-at-risk gap). Non-destructive:
  # create settings.json if absent; if it exists, never edit it — just print the
  # block to add so the consumer keeps ownership of their settings.
  _SETTINGS="$TARGET/.claude/settings.json"
  if [ ! -f "$_SETTINGS" ]; then
    cat > "$_SETTINGS" <<'EOF'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/solon-stop-suggest.sh" }
        ]
      }
    ]
  }
}
EOF
    ok "Claude Code Stop hook registered (.claude/settings.json)"
  elif grep -q "solon-stop-suggest.sh" "$_SETTINGS" 2>/dev/null; then
    ok "Claude Code Stop hook already registered (.claude/settings.json)"
  else
    warn "existing .claude/settings.json not modified — add the Stop hook manually to enable session-end handoff suggestions:"
    printf '%s\n' '    "hooks": { "Stop": [ { "hooks": [ { "type": "command", "command": "bash .claude/hooks/solon-stop-suggest.sh" } ] } ] }'
  fi

  # 6.2a) Claude Code Skill adapter (current primary command surface)
  mkdir -p "$TARGET/.claude/skills/sfs"
  install_file "templates/.claude/commands/sfs.md" ".claude/skills/sfs/SKILL.md" "Claude Code /sfs Skill"

  # 6.2b) Gemini CLI custom command (project-scoped `sfs ...`, TOML)
  # 위치: <project>/.gemini/commands/sfs.toml — Gemini CLI 가 자동 발견 + `sfs ...` command.
  mkdir -p "$TARGET/.gemini/commands"
  install_file "templates/.gemini/commands/sfs.toml" ".gemini/commands/sfs.toml" "Gemini CLI sfs command"

  # 6.2c) Codex Skill (project-scoped, .agents/skills/, Anthropic Skills 호환)
  # 위치: <project>/.agents/skills/sfs/SKILL.md — Codex Skill.
  # Codex CLI 의 공식 Skill 호출은 `$sfs`; bare `/sfs` 는 모델 전에 차단될 수 있다.
  # implicit invocation (사용자 의도 매칭) + explicit invocation ($sfs) 양쪽 작동.
  mkdir -p "$TARGET/.agents/skills/sfs"
  install_file "templates/.agents/skills/sfs/SKILL.md" ".agents/skills/sfs/SKILL.md" "Codex Skill (project-scoped)"

  # 6.2e) Solon HTML output-artifact skills (spec / review / handoff).
  # Source of truth = templates/.agents/skills/<name>/; installed to both the
  # Claude Code and Codex skill surfaces so either runtime can render the
  # shared HTML artifacts. The handoff skill carries the copy-as-prompt export.
  for _doc_skill in solon-doc-spec solon-doc-review solon-doc-handoff; do
    mkdir -p "$TARGET/.claude/skills/$_doc_skill" "$TARGET/.agents/skills/$_doc_skill"
    install_file "templates/.agents/skills/$_doc_skill/SKILL.md" ".claude/skills/$_doc_skill/SKILL.md" "Claude Code Skill ($_doc_skill)"
    install_file "templates/.agents/skills/$_doc_skill/template.html" ".claude/skills/$_doc_skill/template.html" "Claude Code Skill asset ($_doc_skill)"
    install_file "templates/.agents/skills/$_doc_skill/SKILL.md" ".agents/skills/$_doc_skill/SKILL.md" "Codex Skill ($_doc_skill)"
    install_file "templates/.agents/skills/$_doc_skill/template.html" ".agents/skills/$_doc_skill/template.html" "Codex Skill asset ($_doc_skill)"
  done
else
  ok "project-local agent command/skill adapters skip (opt-in: sfs agent install all)"
fi

# 6.2d) Codex CLI user-scoped prompt (legacy/optional fallback, NOT auto-installed to ~/)
# 위치 (template 만): templates/.codex/prompts/sfs.md
# `/sfs` 는 Solon public command surface. project-scoped Skill 은 Codex adaptor entry 이고,
# 본 file 은 user 가 ~/.codex/prompts/sfs.md 로 직접 cp 할 때 쓰는 legacy prompt fallback.
# Codex build 에 따라 `/prompts:sfs` 지원 여부가 다르므로 primary 로 안내하지 않는다.
# install.sh 는 user $HOME 에 쓰지 않음 (사용자 영역 보호).
# 안내만 출력:
ok "Codex custom prompt fallback (optional/legacy): templates/.codex/prompts/sfs.md → ~/.codex/prompts/sfs.md (manual cp, if supported)"

# 6.3) 자동 치환 가능한 placeholder 처리
# <PROJECT-NAME> / <STACK> / <DB> / <DEPLOY> / <DOMAIN> 등은 consumer 수동 치환 대상.
SOLON_VERSION_VAL=$(cat "$SOURCE_DIR/VERSION" 2>/dev/null | head -1 || echo "unknown")
TODAY=$(date +%Y-%m-%d)
if [ "$(uname)" = "Darwin" ]; then
  SED_INPLACE=(sed -i '')
else
  SED_INPLACE=(sed -i)
fi
for auto_file in "$TARGET/SFS.md" "$TARGET/CLAUDE.md" "$TARGET/AGENTS.md" "$TARGET/GEMINI.md"; do
  if [ -f "$auto_file" ]; then
    "${SED_INPLACE[@]}" \
      -e "s|<DATE>|$TODAY|g" \
      -e "s|<SOLON-VERSION>|$SOLON_VERSION_VAL|g" \
      "$auto_file" 2>/dev/null || true
  fi
done
ok "문서 자동 치환: <DATE>=$TODAY, <SOLON-VERSION>=$SOLON_VERSION_VAL"

sed_replacement_escape() {
  printf '%s' "$1" | sed -e 's/[\/&|]/\\&/g'
}

fill_llm_wiki_project_context() {
  local file="$1"
  [ "$ASSUME_YES" -eq 1 ] && return 0
  [ -f "$file" ] || return 0
  grep -Fq '<PROJECT-PURPOSE>' "$file" 2>/dev/null || return 0

  info ""
  info "llm-wiki 초기 프로젝트 맥락 인터뷰 (Enter = TBD)"
  local purpose user output question boundary
  purpose="$(prompt "  프로젝트 목적 1줄" "TBD")"
  user="$(prompt "  주요 사용자/운영자" "TBD")"
  output="$(prompt "  핵심 산출물" "TBD")"
  question="$(prompt "  이 프로젝트에서 먼저 답하고 싶은 질문" "TBD")"
  boundary="$(prompt "  헷갈리면 안 되는 경계/비범위" "TBD")"

  "${SED_INPLACE[@]}" \
    -e "s|<PROJECT-PURPOSE>|$(sed_replacement_escape "$purpose")|g" \
    -e "s|<PROJECT-USER>|$(sed_replacement_escape "$user")|g" \
    -e "s|<PROJECT-OUTPUT>|$(sed_replacement_escape "$output")|g" \
    -e "s|<PROJECT-QUESTION>|$(sed_replacement_escape "$question")|g" \
    -e "s|<PROJECT-BOUNDARY>|$(sed_replacement_escape "$boundary")|g" \
    "$file" 2>/dev/null || true
  ok "  llm-wiki/project-context.md 초기 인터뷰 반영"
}

# ============================================================================
# 7. .sfs-local/ 스캐폴드 (merge 모드)
# ============================================================================

info ""
info ".sfs-local/ 스캐폴드..."

if [ -d "$TARGET/.sfs-local" ]; then
  warn ".sfs-local/ 이미 존재 — merge 모드 (기존 산출물 보존)"
else
  mkdir -p "$TARGET/.sfs-local"
  ok ".sfs-local/ 생성"
fi

# config.yaml — project-local runtime contract.
# scripts do not require this file yet; it is the human/tooling-visible lock that
# explains whether runtime assets are global(thin) or vendored(project-local).
if [ ! -f "$TARGET/.sfs-local/config.yaml" ]; then
  runtime_command="bash .sfs-local/scripts/sfs-dispatch.sh"
  if [ "$INSTALL_LAYOUT" = "thin" ]; then
    runtime_command="sfs"
  fi
  cat > "$TARGET/.sfs-local/config.yaml" <<EOF
runtime:
  layout: "$INSTALL_LAYOUT"
  command: "$runtime_command"
  version: "$SOLON_VERSION_VAL"
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
  ok "  config.yaml 생성 (runtime layout: $INSTALL_LAYOUT)"
else
  ok "  config.yaml 기존 유지"
fi

# model-profiles drift WARN (#4) — config-time half of the model-tier lock.
# Under named-policy precedence, configured_tier=current defers to the policy
# agent_tiers; an explicit configured_tier that differs from the policy-
# recommended tier is surfaced (never auto-rewritten — owner decides).
sfs_warn_model_profiles_drift() {
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

# model-profiles.yaml — reasoning tier registry, 기존 있으면 skip (사용자 설정 보호)
if [ ! -f "$TARGET/.sfs-local/model-profiles.yaml" ]; then
  cp "$SOURCE_DIR/templates/.sfs-local-template/model-profiles.yaml" "$TARGET/.sfs-local/model-profiles.yaml"
  "${SED_INPLACE[@]}" \
    -e "s|<DATE>|$TODAY|g" \
    -e "s|<SOLON-VERSION>|$SOLON_VERSION_VAL|g" \
    -e "s|<PROJECT-NAME>|$PROJECT_NAME|g" \
    -e "s|<DEFAULT-RUNTIME>|$MODEL_RUNTIME|g" \
    -e "s|<MODEL-POLICY>|$MODEL_POLICY|g" \
    -e "s|<MODEL-PROFILE-STATUS>|$MODEL_PROFILE_STATUS|g" \
    "$TARGET/.sfs-local/model-profiles.yaml" 2>/dev/null || true
  ok "  model-profiles.yaml 생성 (agent별 Claude/Codex/Gemini model settings)"
else
  ok "  model-profiles.yaml 기존 유지"
fi
sfs_warn_model_profiles_drift "$TARGET/.sfs-local/model-profiles.yaml" "$MODEL_POLICY"

# --team preset 머티리얼라이즈 (solo = no-op = 현재 동작 무변경).
# OCP: preset→bindings 는 model-profiles 의 team_preset_catalog(데이터)에서 읽고,
# install 코드는 enum 을 모른다. 새 preset = 카탈로그 편집만.
sfs_apply_team_preset() {
  local team="$1" mp="$TARGET/.sfs-local/model-profiles.yaml"
  [ "$team" = "solo" ] && return 0
  [ -f "$mp" ] || { warn "team preset 적용 불가: model-profiles.yaml 없음"; return 0; }

  # 1) team_preset 라인 갱신.
  "${SED_INPLACE[@]}" -e "s|^team_preset:.*|team_preset: $team|" "$mp" 2>/dev/null || true

  # 2) agent_runtime_bindings 머티리얼라이즈 — 기본 `{}` 일 때만 (사용자 커스텀 보호).
  local resolver="$SOURCE_DIR/templates/.sfs-local-template/scripts/sfs-team.sh"
  if grep -Eq '^agent_runtime_bindings:[[:space:]]*\{\}[[:space:]]*$' "$mp" && [ -f "$resolver" ]; then
    # resolver 출력(`key: value`)을 2칸 들여쓰기로 임시파일에 적재. awk -v 에
    # 여러 줄을 넘기면 BSD awk 가 'newline in string' 으로 죽으므로 getline 사용.
    local binds_file="$mp.binds.tmp"
    SFS_MODEL_PROFILES="$mp" bash "$resolver" preset-bindings "$team" 2>/dev/null | sed 's/^/  /' > "$binds_file" || true
    if [ -s "$binds_file" ]; then
      awk -v bf="$binds_file" '
        $1 == "agent_runtime_bindings:" && index($0, "{}") {
          print "agent_runtime_bindings:"
          while ((getline l < bf) > 0) print l
          close(bf)
          next
        }
        { print }
      ' "$mp" > "$mp.tmp" && mv "$mp.tmp" "$mp"
      ok "  team preset '$team' → agent_runtime_bindings 채움"
    fi
    rm -f "$binds_file"
  else
    warn "  agent_runtime_bindings 가 기본 {} 가 아님 — team preset 자동 적용 skip (직접 편집)"
  fi

  # 3) 어댑터 dispatch rule 주입 (설치본 frontmatter 의 닫는 --- 앞). entry-agnostic.
  local adapter
  for adapter in "$TARGET/CLAUDE.md" "$TARGET/AGENTS.md" "$TARGET/GEMINI.md"; do
    [ -f "$adapter" ] || continue
    grep -q '^team_dispatch:' "$adapter" && continue   # idempotent
    awk -v preset="$team" '
      BEGIN { fm=0; done=0 }
      NR==1 && $0=="---" { fm=1; print; next }
      fm==1 && done==0 && $0=="---" {
        print "team_dispatch:                          # injected by --team " preset " (P2); solo 면 부재"
        print "  preset: " preset
        print "  rule: \"task role 분류(plan/review/docs=lead, 구현=worker, 조사=researcher) → `sfs team resolve-runtime <role>` 로 runtime 해석 → 내 runtime 과 다르면 typed capsule 발행 후 `sfs route <role> <capsule>` 로 위임 → 회수·통합. solo/standalone 은 항상 직접 수행.\""
        print "  ssot: \"docs/maintenance/2026-06-23-multi-agent-team-topology.design.md §4.4\""
        done=1; print; next
      }
      { print }
    ' "$adapter" > "$adapter.tmp" && mv "$adapter.tmp" "$adapter"
  done
  ok "  team dispatch rule 주입: CLAUDE.md / AGENTS.md / GEMINI.md (preset=$team)"
}
sfs_apply_team_preset "$INSTALL_TEAM"

# divisions.yaml — 기존 있으면 skip (사용자 수정분 보호)
if [ ! -f "$TARGET/.sfs-local/divisions.yaml" ]; then
  cp "$SOURCE_DIR/templates/.sfs-local-template/divisions.yaml" "$TARGET/.sfs-local/divisions.yaml"
  # 자동 치환 — model-profiles.yaml 와 일치시켜 <PROJECT-NAME> 도 함께 치환한다.
  # <DEPLOY> 는 consumer 수동 치환 대상 (안내문 안의 도메인 힌트라 자동 치환 위험).
  "${SED_INPLACE[@]}" \
    -e "s|<DATE>|$TODAY|g" \
    -e "s|<SOLON-VERSION>|$SOLON_VERSION_VAL|g" \
    -e "s|<PROJECT-NAME>|$PROJECT_NAME|g" \
    "$TARGET/.sfs-local/divisions.yaml" 2>/dev/null || true
  ok "  divisions.yaml 생성 (auto-sub: <DATE>, <SOLON-VERSION>, <PROJECT-NAME>)"
else
  ok "  divisions.yaml 기존 유지"
fi

# events.jsonl — event가 처음 발생할 때만 생성. 빈 workbench 로그는 남기지 않는다.
if [ -f "$TARGET/.sfs-local/events.jsonl" ]; then
  ok "  events.jsonl 기존 유지"
else
  ok "  events.jsonl lazy mode: 첫 이벤트 발생 시 생성"
fi

# lessons.md — 누적 회피 규칙 ledger seed (기존 있으면 사용자 누적분 보호).
if [ ! -f "$TARGET/.sfs-local/lessons.md" ]; then
  cp "$SOURCE_DIR/templates/.sfs-local-template/lessons.md" "$TARGET/.sfs-local/lessons.md"
  ok "  lessons.md seed 생성 (실패→회피 규칙 누적)"
else
  ok "  lessons.md 기존 유지"
fi

# auth.env.example — keep the sample in the packaged runtime, not in project state.
ok "  auth.env.example project copy skip (샘플은 packaged runtime 에만 유지; 필요 시 /sfs auth path)"

ok "  work dirs lazy mode: sprints/decisions/queue 는 필요할 때만 생성"

# llm-wiki/ — long-horizon knowledge vault (WMU-2). Project-root, BOTH layouts
# (it is project-committed knowledge like SFS.md, not a vendored-only runtime
# module). recommended-default + opt-out + waiver — never hard-block.
#   - skip-if-exists: an existing vault is preserved.
#   - SFS_INSTALL_LLM_WIKI=0 → scriptable opt-out (records a waiver, no copy).
#   - SFS_INSTALL_LLM_WIKI=1 / --yes → install.
#   - interactive (unset) → confirm_default_yes (default Y).
LLM_WIKI_SRC="$SOURCE_DIR/templates/.sfs-local-template/llm-wiki"
if [ -d "$TARGET/llm-wiki" ]; then
  ok "  llm-wiki/ 기존 유지 (사용자 vault 보호)"
elif [ -d "$LLM_WIKI_SRC" ]; then
  _wiki_decision=""
  case "${SFS_INSTALL_LLM_WIKI:-}" in
    0|false|FALSE|no|NO|off|OFF) _wiki_decision="decline" ;;
    1|true|TRUE|yes|YES|on|ON)  _wiki_decision="install" ;;
  esac
  if [ -z "$_wiki_decision" ]; then
    if confirm_default_yes "  llm-wiki/ 장기 지식 vault skeleton 을 설치할까요? (수동 유지, generator 미동반)"; then
      _wiki_decision="install"
    else
      _wiki_decision="decline"
    fi
  fi
  if [ "$_wiki_decision" = "install" ]; then
    mkdir -p "$TARGET/llm-wiki"
    cp -R "$LLM_WIKI_SRC"/. "$TARGET/llm-wiki/" 2>/dev/null || true
    ok "  llm-wiki/ 설치 (README + 00-llm-retrieval-guide + project-context + _FRONTMATTER + ddd/ + bug-reports/; 수동 유지)"
    fill_llm_wiki_project_context "$TARGET/llm-wiki/project-context.md"
  else
    mkdir -p "$TARGET/.sfs-local"
    printf 'declined_at=%s\nreason=user-opt-out-at-install\nnote=re-run `sfs init` or copy templates/.sfs-local-template/llm-wiki/ to add the vault later.\n' \
      "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$TARGET/.sfs-local/llm-wiki.waiver"
    ok "  llm-wiki/ 설치 생략 — waiver 기록 (.sfs-local/llm-wiki.waiver)"
  fi
  unset _wiki_decision
fi

if [ "$INSTALL_LAYOUT" = "vendored" ]; then
  # context/ — short, routed agent context modules. Thin layout keeps these in
  # the global runtime so the consumer project only shows product state and
  # user-owned overrides.
  CONTEXT_SRC="$SOURCE_DIR/templates/.sfs-local-template/context"
  if [ -d "$CONTEXT_SRC" ]; then
    mkdir -p "$TARGET/.sfs-local/context"
    cp -R "$CONTEXT_SRC"/. "$TARGET/.sfs-local/context/" 2>/dev/null || true
    ok "  context/ 복사 (vendored runtime router modules)"
  fi

  # GUIDE.md — `/sfs guide` 가 참조하는 managed onboarding guide
  if [ -f "$SOURCE_DIR/GUIDE.md" ]; then
    cp "$SOURCE_DIR/GUIDE.md" "$TARGET/.sfs-local/GUIDE.md"
    ok "  GUIDE.md 복사 (.sfs-local/GUIDE.md, /sfs guide)"
  fi

  # scripts/ — Solon-versioned bash adapters
  # 정책: vendored layout 에서만 프로젝트에 복사. thin layout 은 global sfs runtime 을 사용.
  SCRIPTS_SRC="$SOURCE_DIR/templates/.sfs-local-template/scripts"
  if [ -d "$SCRIPTS_SRC" ]; then
    mkdir -p "$TARGET/.sfs-local/scripts"
    cp "$SCRIPTS_SRC"/*.sh "$TARGET/.sfs-local/scripts/" 2>/dev/null || true
    cp "$SCRIPTS_SRC"/*.ps1 "$TARGET/.sfs-local/scripts/" 2>/dev/null || true
    chmod +x "$TARGET/.sfs-local/scripts"/*.sh 2>/dev/null || true
    ok "  scripts/ 복사 (sfs-*.sh executable + Windows sfs.ps1 wrapper)"
  fi

  # sprint-templates/ — sfs-start.sh 가 sprint dir 초기화 시 사용하는 템플릿
  TEMPLATES_SRC="$SOURCE_DIR/templates/.sfs-local-template/sprint-templates"
  if [ -d "$TEMPLATES_SRC" ]; then
    mkdir -p "$TARGET/.sfs-local/sprint-templates"
    cp "$TEMPLATES_SRC"/*.md "$TARGET/.sfs-local/sprint-templates/" 2>/dev/null || true
    ok "  sprint-templates/ 복사 (brainstorm + plan + implement + log + review + retro + report + decision-light)"
  fi

  # personas/ — CEO / CTO Generator / Implementation Worker / CPO Evaluator 기본 persona
  PERSONAS_SRC="$SOURCE_DIR/templates/.sfs-local-template/personas"
  if [ -d "$PERSONAS_SRC" ]; then
    mkdir -p "$TARGET/.sfs-local/personas"
    cp "$PERSONAS_SRC"/*.md "$TARGET/.sfs-local/personas/" 2>/dev/null || true
    ok "  personas/ 복사 (CEO + CTO Generator + Implementation Worker + CPO Evaluator)"
  fi

  # decisions-template/ — sfs-decision.sh 가 ADR 신설 시 사용하는 ADR-full 템플릿 (WU-26 §1)
  DECISIONS_TPL_SRC="$SOURCE_DIR/templates/.sfs-local-template/decisions-template"
  if [ -d "$DECISIONS_TPL_SRC" ]; then
    mkdir -p "$TARGET/.sfs-local/decisions-template"
    cp "$DECISIONS_TPL_SRC"/*.md "$TARGET/.sfs-local/decisions-template/" 2>/dev/null || true
    ok "  decisions-template/ 복사 (ADR-TEMPLATE.md + _INDEX.md)"
  fi
else
  ok "  thin layout: GUIDE/context/scripts/templates/personas/decisions-template 는 global runtime 사용"
  ok "  project-local override 가 필요할 때만 .sfs-local/{context,sprint-templates,personas,decisions-template}/ 에 파일 추가"
fi

# ============================================================================
# 8. .gitignore 주입 (idempotent marker-based)
# ============================================================================

info ""
info ".gitignore 갱신..."

touch "$TARGET/.gitignore"

# Legacy `### BEGIN solon-mvp ###` 블록이 있으면 product marker 로 교체 (idempotent rename).
if grep -qF "$LEGACY_GIT_MARKER_BEGIN" "$TARGET/.gitignore" 2>/dev/null \
   && ! grep -qF "$GIT_MARKER_BEGIN" "$TARGET/.gitignore" 2>/dev/null; then
  warn "legacy 'solon-mvp' .gitignore 블록 감지 — 'solon-product' marker 로 교체"
  awk -v old_b="$LEGACY_GIT_MARKER_BEGIN" -v old_e="$LEGACY_GIT_MARKER_END" \
      -v new_b="$GIT_MARKER_BEGIN"        -v new_e="$GIT_MARKER_END" \
    '{ if ($0==old_b) print new_b; else if ($0==old_e) print new_e; else print }' \
    "$TARGET/.gitignore" > "$TARGET/.gitignore.tmp.$$" \
    && mv "$TARGET/.gitignore.tmp.$$" "$TARGET/.gitignore"
  ok "legacy marker → solon-product marker 교체 완료"
fi

if grep -qF "$GIT_MARKER_BEGIN" "$TARGET/.gitignore" 2>/dev/null; then
  ok "solon-product 블록 이미 존재 — skip"
else
  {
    # 기존 파일 끝에 개행 보장
    if [ -s "$TARGET/.gitignore" ] && [ "$(tail -c1 "$TARGET/.gitignore" | wc -l)" = "0" ]; then
      echo ""
    fi
    echo ""
    echo "$GIT_MARKER_BEGIN"
    cat "$SOURCE_DIR/templates/.gitignore.snippet"
    echo "$GIT_MARKER_END"
  } >> "$TARGET/.gitignore"
  ok "solon-product 블록 추가됨"
fi

# ============================================================================
# 9. VERSION 기록
# ============================================================================

SOLON_VERSION=$(cat "$SOURCE_DIR/VERSION" 2>/dev/null | head -1 || echo "unknown")
INSTALLED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)

cat > "$TARGET/.sfs-local/VERSION" <<EOF
solon_mvp_version: $SOLON_VERSION
installed_at: $INSTALLED_AT
installed_from: $MODE
install_layout: $INSTALL_LAYOUT
source_repo: https://github.com/${SOLON_REPO}
EOF
ok "VERSION 기록: $SOLON_VERSION ($MODE @ $INSTALLED_AT)"

# ============================================================================
# 9.5. CLI discovery hook (0.5.96-product) — slash-command zero-file
# ============================================================================
# Register /sfs slash command in Claude Code, sfs command in Gemini CLI,
# and ~/.codex/skills/sfs/SKILL.md for Codex — all three under one umbrella.
# Idempotent + graceful (failure does not abort install).
#
# Skipped automatically when running in a context where SFS_SKIP_CLI_DISCOVERY=1
# (CI / brew-bottle build / smoke tests).

if [ "${SFS_SKIP_CLI_DISCOVERY:-0}" != "1" ]; then
  CLI_DISCOVERY_HOOK="$SOURCE_DIR/scripts/install-cli-discovery.sh"
  if [ -x "$CLI_DISCOVERY_HOOK" ] || [ -f "$CLI_DISCOVERY_HOOK" ]; then
    SFS_DISCOVERY_SOURCE_DIR="$SOURCE_DIR" \
      bash "$CLI_DISCOVERY_HOOK" || warn "cli-discovery hook returned non-zero (graceful — continuing)"
  else
    warn "cli-discovery hook not found at $CLI_DISCOVERY_HOOK — skip"
  fi
else
  ok "cli-discovery hook skipped (SFS_SKIP_CLI_DISCOVERY=1)"
fi

# ============================================================================
# 10. 완료
# ============================================================================

if [ "$INSTALL_AGENT_ADAPTERS" = "1" ]; then
  ENTRY_HINT=".claude/skills/sfs/SKILL.md (Claude Code Skill)
                 .claude/commands/sfs.md (Claude Code legacy slash)
                 .gemini/commands/sfs.toml (Gemini CLI, TOML command)
                 .agents/skills/sfs/SKILL.md (Codex, Skills 체계)"
else
  ENTRY_HINT="global sfs runtime + root CLAUDE.md / AGENTS.md / GEMINI.md
                 project-local command/skill adapters are opt-in"
fi
COMMIT_HINT="${C_BLUE}sfs commit plan${C_RESET}
     ${C_BLUE}sfs commit apply --group runtime-upgrade -m \"설치: solon-product $SOLON_VERSION\"${C_RESET}"

cat <<EOF

${C_BOLD}${C_GREEN}=== Solon Product 설치 완료 ===${C_RESET}

설치 위치:       $TARGET
Solon 버전:      $SOLON_VERSION
layout:          $INSTALL_LAYOUT
.sfs-local/:     private local state (${C_BOLD}gitignored by default; 기존 산출물은 보존됨${C_RESET})
공통 지침:       SFS.md
런타임 어댑터:   CLAUDE.md / AGENTS.md / GEMINI.md$([ "$INSTALL_TEAM" != "solo" ] && echo " (team_dispatch 주입)" || echo "")
Team topology:   $INSTALL_TEAM$([ "$INSTALL_TEAM" = "solo" ] && echo " (단일 runtime, dispatch off — 현재 동작 그대로)" || echo " (agent_runtime_bindings + 어댑터 dispatch rule)")
지식 vault:      $([ -d "$TARGET/llm-wiki" ] && echo "llm-wiki/ (장기 지식 — 수동 유지, generator 미동반)" || echo "llm-wiki/ 생략 (SFS_INSTALL_LLM_WIKI=0 / waiver)")
Entry 1급:       $ENTRY_HINT
Model profiles: .sfs-local/model-profiles.yaml (runtime=$MODEL_RUNTIME, policy=$MODEL_POLICY)
Agent opt-in:    sfs agent install claude|gemini|codex|all
Project upgrade: sfs upgrade
Runtime:         $([ "$INSTALL_LAYOUT" = "thin" ] && echo "global sfs CLI" || echo ".sfs-local/scripts/sfs-dispatch.sh")
Windows wrapper: $([ "$INSTALL_LAYOUT" = "thin" ] && echo "global sfs CLI via Git Bash/WSL" || echo ".sfs-local/scripts/sfs.ps1 (PowerShell → Git Bash)")

${C_BOLD}${C_YELLOW}■ 위키 온보딩 (강력 권고)${C_RESET}
  Obsidian + llm-wiki 구축을 ${C_BOLD}강력 권고${C_RESET}합니다 — 에이전트 셀프서비스
  컨텍스트 / 세션 간 기억 / 반복 설명 제거. 강제는 아닙니다 (standalone guarantee 유지).
  시작 가이드: ${C_BLUE}docs/ko/current-product-shape/25-wiki-onboarding-guide.md${C_RESET}
            ${C_BLUE}docs/en/current-product-shape/25-wiki-onboarding-guide.md${C_RESET}
  지금 건너뛰면 나중에 ${C_BLUE}sfs adopt${C_RESET} / ${C_BLUE}sfs harness doctor${C_RESET} 가 다시 안내합니다
  (거절 시 ${C_BLUE}.sfs-local/llm-wiki.waiver${C_RESET} 기록 후 침묵). 개인 외부 지식 위키(강의·
  인사이트용 private git repo)도 함께 권고 — 가이드 4단계 참고.

다음 단계:

  ${C_BOLD}1.${C_RESET} SFS.md 내용 확인 + 프로젝트 특성 반영 (Stack / 도메인 등).

  ${C_BOLD}2.${C_RESET} agent 모델 설정 확인:
     ${C_BLUE}.sfs-local/model-profiles.yaml${C_RESET}
     - 기본값: solon_recommended role routing 이 자동 적용됩니다. current_model 은 명시적 opt-out 입니다.
     - Codex: helper-grade intake/non-coding helper 는 gpt-5.4-mini,
       질문 생성/facilitator/일반 worker 는 gpt-5.4,
       advisor/review 는 gpt-5.5 xhigh, bounded coding helper 는 gpt-5.3-codex,
       무판단 mechanical implementation helper 는 gpt-5.3-codex-spark
     - Gemini: strategy/research/review 는 gemini-3.1-pro-preview, agentic coding/bounded 구현 helper 는 gemini-3-flash-preview, relay/probe/economy helper 는 gemini-3.1-flash-lite 입니다. 3.x 미만 fallback 은 쓰지 않습니다.
     - 모델명은 SFS role/profile contract 입니다. CLI --model flag 지원을 전제로 하지 않고,
       기본 bridge 는 prompt 와 host/runtime 설정으로 해당 역할을 요청합니다.
     - 하위모델이 질문/선택지/답변 해석/gate 를 흔들면 최상위 advisor 검토가 필수입니다.
       helper-grade 단순 I/O 는 advisor 검토를 생략할 수 있습니다.
     - advisor 호출은 self-CPO PASS 가 아닙니다. external/cross review 전에는
       요구사항-AC-slice-ADR 추적, AC-file/artifact/evidence 매핑, SEED/placeholder/mock/fallback
       non-acceptance 를 self-CPO mini-check 로 남깁니다.
     - Claude: advisor 는 Opus 4.7, worker/facilitator/code helper 는 Sonnet 4.6,
       Haiku 는 코딩 금지 helper-grade relay/요약/read-only 보조 전용입니다.
     - Gemini/custom: 프로젝트가 쓰는 모델/profile 이름
     원하면 worker/helper 도 high-end 로 바꿔도 됩니다.

     Agent implementation mode:
     - 기본 구현 모드는 single-agent 입니다.
     - 병렬 agent 구현은 명시적으로 선택할 때만 사용합니다:
       ${C_BLUE}sfs implement --agent-mode parallel --agents codex,claude[,gemini] "<work slice>"${C_RESET}
     - parallel lane 은 disjoint files_scope, AC/ADR subset ownership, expected tests/evidence,
       output report path, merge/conflict policy, lane-level verification,
       native/workspace-language one-sentence commit message, 그리고 Gate 6 PASS 전 agent cross review 가 필요합니다.

  ${C_BOLD}3.${C_RESET} 선호 런타임에서 시작:
     ${C_BLUE}legacy repo${C_RESET} → ${C_BLUE}/sfs status${C_RESET} → ${C_BLUE}/sfs adopt --apply${C_RESET} → ${C_BLUE}/sfs start${C_RESET}
     ${C_BLUE}claude${C_RESET}     → ${C_BLUE}/sfs status${C_RESET} → ${C_BLUE}/sfs start${C_RESET} → ${C_BLUE}/sfs brainstorm${C_RESET} → ${C_BLUE}/sfs plan${C_RESET} → ${C_BLUE}/sfs implement${C_RESET} → ${C_BLUE}/sfs review${C_RESET} → ${C_BLUE}/sfs retro${C_RESET}
     ${C_BLUE}gemini${C_RESET}     → ${C_BLUE}sfs status${C_RESET} → ${C_BLUE}sfs start${C_RESET} → ${C_BLUE}sfs brainstorm${C_RESET} → ${C_BLUE}sfs plan${C_RESET} → ${C_BLUE}sfs implement${C_RESET} → ${C_BLUE}sfs review${C_RESET} → ${C_BLUE}sfs retro${C_RESET}
     ${C_BLUE}codex${C_RESET}      → ${C_BLUE}\$sfs status${C_RESET} → ${C_BLUE}\$sfs start${C_RESET} → ${C_BLUE}\$sfs brainstorm${C_RESET} → ${C_BLUE}\$sfs plan${C_RESET} → ${C_BLUE}\$sfs implement${C_RESET} → ${C_BLUE}\$sfs review${C_RESET} → ${C_BLUE}\$sfs retro${C_RESET}
                   (Codex CLI 공식 Skill 호출은 ${C_BLUE}\$sfs${C_RESET}; bare ${C_BLUE}/sfs${C_RESET} 는 지원하지 않음)
     ${C_BLUE}powershell${C_RESET} → ${C_BLUE}sfs.cmd status${C_RESET} → ${C_BLUE}sfs.cmd start${C_RESET} → ${C_BLUE}sfs.cmd guide${C_RESET}
     모두 동일한 ${C_BOLD}sfs${C_RESET} runtime command 로 내려간 뒤 deterministic bash adapter 호출.
     설치 직후 가이드는 ${C_BLUE}/sfs guide${C_RESET}, ${C_BLUE}\$sfs guide${C_RESET}, 또는 shell 의 ${C_BLUE}sfs.cmd guide${C_RESET}/${C_BLUE}sfs guide${C_RESET}.

  ${C_BOLD}4.${C_RESET} sfs commit + push (공유 entry 문서만 기록; .sfs-local 은 기본 비공개):
     ${COMMIT_HINT}
     ${C_YELLOW}sfs commit apply 는 기본적으로 현재 branch 를 push 합니다. 로컬 sandbox 에서만 --no-push 를 쓰세요.${C_RESET}
     ${C_YELLOW}커밋 메시지는 사용자 native/workspace 언어가 기본입니다. 영어는 repo 규칙이 요구할 때만 쓰세요.${C_RESET}

  ${C_BOLD}5.${C_RESET} 새 Solon 배포 확인 + project adapter/docs 갱신:
     ${C_BLUE}sfs version --check${C_RESET}
     ${C_BLUE}sfs upgrade${C_RESET}

  ${C_BOLD}6.${C_RESET} Claude/Gemini/Codex entry point 만 갱신할 때:
     ${C_BLUE}sfs agent install all${C_RESET}

  ${C_BOLD}7.${C_RESET} interactive preview 가 필요하면: ${C_BLUE}sfs upgrade --interactive${C_RESET}

  ${C_BOLD}8.${C_RESET} 0.7.0+ host-agnostic 진입 (선택):
     - ${C_BOLD}MCP host${C_RESET} (Claude Desktop / Claude in Chrome / Cursor / Agent SDK):
       ${C_BLUE}solon-mcp${C_RESET} stdio server 가 ${C_BLUE}sfs_*${C_RESET} tool 12개를 노출합니다.
       설치 + 등록 스니펫: ${C_BLUE}${SOURCE_DIR}/mcp-server/README.md${C_RESET}
       (0.7.x 동안 source clone 만 지원. PyPI publish 일정은 ${C_BLUE}mcp-server/PUBLISHING.md${C_RESET}.)
     - ${C_BOLD}solon-safe 권한 baseline${C_RESET}:
       ${C_BLUE}.sfs-local/presets/solon-safe-permissions.yaml${C_RESET}
       각 runtime 의 permission config 에 import 해서 auto-push / destructive bash 를 차단합니다.
     - ${C_BOLD}Claude Agent SDK 프로젝트 스캐폴드${C_RESET}:
       ${C_BLUE}sfs bootstrap --experimental --template claude-agent-sdk-zero <project-name>${C_RESET}
     - ${C_BOLD}agent-build review lens${C_RESET}:
       agent / MCP / sub-agent 작업은 Gate 6 review 에서 ${C_BLUE}--lens agent-build${C_RESET} 가 자동 라우팅됩니다 (explicit 호출도 가능).

문제 발생 시: https://github.com/${SOLON_REPO}/issues

EOF
