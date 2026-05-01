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

usage() {
  cat <<EOF
Usage: ./install.sh [--yes] [--layout thin|vendored]

Options:
  -y, --yes           모든 확인 프롬프트를 자동 승인합니다.
                      파일 충돌 시에는 안전한 기본값(skip)을 사용합니다.
  --layout thin       프로젝트에는 state/config/custom override 만 설치합니다.
                      runtime 은 PATH 의 global `sfs` CLI 를 사용합니다.
  --layout vendored   기존 방식입니다. scripts/templates/personas 를 프로젝트에 복사합니다.
  -h, --help          도움말을 출력합니다.

Environment:
  SFS_MODEL_RUNTIME   current|claude|codex|gemini|custom (default: current)
  SFS_MODEL_POLICY    current_model|solon_recommended|all_high|custom (default: current_model)
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
    *)
      echo "알 수 없는 옵션: $1 (지원: --yes, --layout, --help)" >&2
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
    printf "%s (y/N) [N]: y\n" "$1" >&2
    return 0
  fi
  ans=$(prompt "$1 (y/N)" "N")
  case "$ans" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
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

Solon Product 는 AI-native 7-step flow (브레인스토밍 → plan → sprint → 구현 → review →
commit → 문서화) 를 현재 프로젝트에 주입합니다. 이 7-step 은 full artifact chain 의
lightweight projection 입니다. .sfs-local/ 스캐폴드 + SFS.md 공통 지침 +
Claude/Codex/Gemini 어댑터 + .gitignore 규칙이 설치됩니다.

EOF

if [ "$INSTALL_LAYOUT" = "thin" ]; then
  info "thin layout: 프로젝트에는 state/config/custom override 만 두고, runtime 은 global 'sfs' CLI 를 사용합니다."
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
MODEL_POLICY="${SFS_MODEL_POLICY:-current_model}"

info ""
info "Agent model profile setup..."
cat <<EOF
Solon 은 agent 별 모델 설정을 프로젝트 로컬 파일에 남깁니다:
  .sfs-local/model-profiles.yaml

권장값은 C-Level/review 는 high reasoning, 구현 worker 는 standard, helper 는 economy 입니다.
단, 프로젝트가 비용/지연을 감수한다면 worker/helper 까지 전부 high-end 모델로 두는 것도 허용합니다.
설정을 건너뛰거나 나중에 하기로 하면 Solon 은 현재 런타임에서 사용자가 선택한 모델을 그대로 씁니다.
EOF

if [ "$ASSUME_YES" -ne 1 ]; then
  MODEL_RUNTIME="$(prompt "기본 LLM runtime? (current/claude/codex/gemini/custom)" "$MODEL_RUNTIME")"
  MODEL_POLICY="$(prompt "agent model policy? (current_model/solon_recommended/all_high/custom)" "$MODEL_POLICY")"
fi

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
    MODEL_POLICY="current_model"
    ;;
  *)
    warn "알 수 없는 SFS_MODEL_POLICY='$MODEL_POLICY' — current_model 로 기록"
    MODEL_POLICY="current_model"
    ;;
esac

MODEL_PROFILE_STATUS="current_model_fallback"
if [ "$MODEL_RUNTIME" != "current" ] || [ "$MODEL_POLICY" != "current_model" ]; then
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

# 6.2) Claude Code slash command adapter
mkdir -p "$TARGET/.claude/commands"
install_file "templates/.claude/commands/sfs.md" ".claude/commands/sfs.md" "Claude Code /sfs 커맨드"

# 6.2a) Claude Code Skill adapter (current primary command surface)
mkdir -p "$TARGET/.claude/skills/sfs"
install_file "templates/.claude/commands/sfs.md" ".claude/skills/sfs/SKILL.md" "Claude Code /sfs Skill"

# 6.2b) Gemini CLI custom command (project-scoped slash 1급, TOML)
# 위치: <project>/.gemini/commands/sfs.toml — Gemini CLI 가 자동 발견 + native /sfs 슬래시.
mkdir -p "$TARGET/.gemini/commands"
install_file "templates/.gemini/commands/sfs.toml" ".gemini/commands/sfs.toml" "Gemini CLI /sfs 슬래시"

# 6.2c) Codex Skill (project-scoped, .agents/skills/, Anthropic Skills 호환)
# 위치: <project>/.agents/skills/sfs/SKILL.md — Codex Skill.
# Codex app/CLI 는 leading `/sfs` 를 모델 전에 차단할 수 있으므로 `$sfs` / 자연어를 우선 쓴다.
# implicit invocation (사용자 의도 매칭) + explicit invocation ($sfs) 양쪽 작동.
mkdir -p "$TARGET/.agents/skills/sfs"
install_file "templates/.agents/skills/sfs/SKILL.md" ".agents/skills/sfs/SKILL.md" "Codex Skill (project-scoped)"

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
  sprint_templates: ".sfs-local/sprint-templates"
  decisions_template: ".sfs-local/decisions-template"
  personas: ".sfs-local/personas"
  model_profiles: ".sfs-local/model-profiles.yaml"
EOF
  ok "  config.yaml 생성 (runtime layout: $INSTALL_LAYOUT)"
else
  ok "  config.yaml 기존 유지"
fi

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

# divisions.yaml — 기존 있으면 skip (사용자 수정분 보호)
if [ ! -f "$TARGET/.sfs-local/divisions.yaml" ]; then
  cp "$SOURCE_DIR/templates/.sfs-local-template/divisions.yaml" "$TARGET/.sfs-local/divisions.yaml"
  # 자동 치환
  "${SED_INPLACE[@]}" \
    -e "s|<DATE>|$TODAY|g" \
    -e "s|<SOLON-VERSION>|$SOLON_VERSION_VAL|g" \
    "$TARGET/.sfs-local/divisions.yaml" 2>/dev/null || true
  ok "  divisions.yaml 생성 (auto-sub: <DATE>, <SOLON-VERSION>)"
else
  ok "  divisions.yaml 기존 유지"
fi

# events.jsonl — 없으면 빈 파일
if [ ! -f "$TARGET/.sfs-local/events.jsonl" ]; then
  touch "$TARGET/.sfs-local/events.jsonl"
  ok "  events.jsonl 생성 (빈 파일)"
else
  ok "  events.jsonl 기존 유지"
fi

# auth.env.example — local executor credentials template (actual auth.env is gitignored)
if [ -f "$SOURCE_DIR/templates/.sfs-local-template/auth.env.example" ] \
   && [ ! -f "$TARGET/.sfs-local/auth.env.example" ]; then
  cp "$SOURCE_DIR/templates/.sfs-local-template/auth.env.example" "$TARGET/.sfs-local/auth.env.example"
  ok "  auth.env.example 생성 (Gemini/Codex/Claude bridge auth 안내)"
fi

# sprints/ + decisions/
mkdir -p "$TARGET/.sfs-local/sprints" "$TARGET/.sfs-local/decisions"
[ -f "$TARGET/.sfs-local/sprints/.gitkeep" ] || touch "$TARGET/.sfs-local/sprints/.gitkeep"
[ -f "$TARGET/.sfs-local/decisions/.gitkeep" ] || touch "$TARGET/.sfs-local/decisions/.gitkeep"
ok "  sprints/ + decisions/ 확보"

# queue/ — file-backed loop queue state (preserve existing tasks).
for qstate in pending claimed done failed abandoned runs; do
  mkdir -p "$TARGET/.sfs-local/queue/$qstate"
  [ -f "$TARGET/.sfs-local/queue/$qstate/.gitkeep" ] || touch "$TARGET/.sfs-local/queue/$qstate/.gitkeep"
done
ok "  queue/ 상태 디렉토리 확보 (pending/claimed/done/failed/abandoned/runs)"

if [ "$INSTALL_LAYOUT" = "vendored" ]; then
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
    ok "  sprint-templates/ 복사 (brainstorm + plan + implement + log + review + retro + decision-light)"
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
  ok "  thin layout: GUIDE/scripts/sprint-templates/personas/decisions-template 는 global runtime 사용"
  ok "  project-local override 가 필요하면 .sfs-local/{sprint-templates,personas,decisions-template}/ 에 파일을 추가"
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
# 10. 완료
# ============================================================================

cat <<EOF

${C_BOLD}${C_GREEN}=== Solon Product 설치 완료 ===${C_RESET}

설치 위치:       $TARGET
Solon 버전:      $SOLON_VERSION
layout:          $INSTALL_LAYOUT
.sfs-local/:     state/config 스캐폴드 (${C_BOLD}기존 sprint 산출물은 보존됨${C_RESET})
공통 지침:       SFS.md
런타임 어댑터:   CLAUDE.md / AGENTS.md / GEMINI.md
Entry 1급:       .claude/skills/sfs/SKILL.md (Claude Code Skill)
                 .claude/commands/sfs.md (Claude Code legacy slash)
                 .gemini/commands/sfs.toml (Gemini CLI, TOML slash)
                 .agents/skills/sfs/SKILL.md (Codex, Skills 체계)
Model profiles: .sfs-local/model-profiles.yaml (runtime=$MODEL_RUNTIME, policy=$MODEL_POLICY)
Agent 갱신:      sfs agent install claude|gemini|codex|all
Project update:  sfs update
Runtime:         $([ "$INSTALL_LAYOUT" = "thin" ] && echo "global sfs CLI" || echo ".sfs-local/scripts/sfs-dispatch.sh")
Windows wrapper: $([ "$INSTALL_LAYOUT" = "thin" ] && echo "global sfs CLI via Git Bash/WSL" || echo ".sfs-local/scripts/sfs.ps1 (PowerShell → Git Bash)")

다음 단계:

  ${C_BOLD}1.${C_RESET} SFS.md 내용 확인 + 프로젝트 특성 반영 (Stack / 도메인 등).

  ${C_BOLD}2.${C_RESET} agent 모델 설정 확인:
     ${C_BLUE}.sfs-local/model-profiles.yaml${C_RESET}
     - Codex: model + reasoning_effort 조합 (예: gpt-5.5 + xhigh/very_high)
     - Claude: opus-4.7 / opus-4.6 / sonnet / haiku 등 runtime 지원 모델명
     - Gemini/custom: 프로젝트가 쓰는 모델/profile 이름
     - 설정을 안 하거나 거부하면: 현재 런타임에서 사용자가 선택한 모델 그대로 사용
     Solon 권장은 C-Level high, worker standard, helper economy 이지만,
     원하면 worker/helper 도 high-end 로 바꿔도 됩니다.

  ${C_BOLD}3.${C_RESET} 선호 런타임에서 시작:
     ${C_BLUE}claude${C_RESET}     → ${C_BLUE}/sfs status${C_RESET} → ${C_BLUE}/sfs start${C_RESET} → ${C_BLUE}/sfs brainstorm${C_RESET} → ${C_BLUE}/sfs plan${C_RESET} → ${C_BLUE}/sfs implement${C_RESET}
     ${C_BLUE}gemini${C_RESET}     → ${C_BLUE}/sfs status${C_RESET} → ${C_BLUE}/sfs start${C_RESET} → ${C_BLUE}/sfs brainstorm${C_RESET} → ${C_BLUE}/sfs plan${C_RESET} → ${C_BLUE}/sfs implement${C_RESET}
     ${C_BLUE}codex${C_RESET}      → ${C_BLUE}\$sfs status${C_RESET} → ${C_BLUE}\$sfs start${C_RESET} → ${C_BLUE}\$sfs brainstorm${C_RESET} → ${C_BLUE}\$sfs plan${C_RESET} → ${C_BLUE}\$sfs implement${C_RESET}
                   (bare ${C_BLUE}/sfs${C_RESET} 가 '커맨드 없음' 으로 막히면 host slash parser gap)
     셋 모두 동일한 ${C_BOLD}sfs${C_RESET} runtime command 로 내려간 뒤 deterministic bash adapter 호출.
     설치 직후 가이드는 ${C_BLUE}/sfs guide${C_RESET}, ${C_BLUE}\$sfs guide${C_RESET}, 또는 shell 의 ${C_BLUE}sfs guide${C_RESET}.

  ${C_BOLD}4.${C_RESET} git commit + push (Solon 주입 자체를 기록):
     ${C_BLUE}git add SFS.md CLAUDE.md AGENTS.md GEMINI.md .gitignore \\${C_RESET}
     ${C_BLUE}        .claude/skills/sfs/SKILL.md .claude/commands/sfs.md \\${C_RESET}
     ${C_BLUE}        .gemini/commands/sfs.toml \\${C_RESET}
     ${C_BLUE}        .agents/skills/sfs/SKILL.md .sfs-local/${C_RESET}
     ${C_BLUE}git commit -m "chore: install solon-product $SOLON_VERSION"${C_RESET}
     ${C_BLUE}git push${C_RESET}

  ${C_BOLD}5.${C_RESET} 현재 설치된 Solon runtime 으로 project adapter/docs 를 갱신할 때:
     ${C_BLUE}sfs update${C_RESET}

  ${C_BOLD}6.${C_RESET} Claude/Gemini/Codex entry point 만 갱신할 때:
     ${C_BLUE}sfs agent install all${C_RESET}

  ${C_BOLD}7.${C_RESET} interactive preview 가 필요하면: ${C_BLUE}sfs upgrade${C_RESET}

문제 발생 시: https://github.com/${SOLON_REPO}/issues

EOF
