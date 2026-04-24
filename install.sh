#!/usr/bin/env bash
# install.sh — Solon MVP installer
#
# 사용법 (dual mode):
#   (1) 원격: curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-mvp/main/install.sh | bash
#   (2) 로컬: git clone https://github.com/MJ-0701/solon-mvp ~/tmp/solon-mvp
#             cd ~/workspace/my-project
#             ~/tmp/solon-mvp/install.sh
#   (3) 비대화형: ./install.sh --yes
#
# 원칙:
#   - 현 작업 디렉토리 (consumer project) 에 Solon 7-step flow 스캐폴드 주입
#   - 기존 파일 충돌 시 대화형 처리 (skip / backup / overwrite / diff)
#   - .sfs-local/ 은 merge 모드 (기존 sprints/decisions 산출물 보존)
#   - 멱등성 (idempotent) — 재실행해도 사용자 기존 자산 파괴하지 않음
#   - 오류 시 early exit, 롤백은 사용자 git 으로
#
# 참고: 본 스크립트는 Solon MVP 0.1.0 — 풀스펙 아님 (사용자 개인 방법론 docset 참조).

set -euo pipefail

ASSUME_YES=0

usage() {
  cat <<EOF
Usage: ./install.sh [--yes]

Options:
  -y, --yes   모든 확인 프롬프트를 자동 승인합니다.
              파일 충돌 시에는 안전한 기본값(skip)을 사용합니다.
  -h, --help  도움말을 출력합니다.
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
      die "알 수 없는 옵션: $1 (지원: --yes, --help)"
      ;;
  esac
  shift
done

# ============================================================================
# 0. 상수 / 색상
# ============================================================================

readonly SOLON_REPO="MJ-0701/solon-mvp"
readonly SOLON_BRANCH="main"
readonly GIT_MARKER_BEGIN="### BEGIN solon-mvp ###"
readonly GIT_MARKER_END="### END solon-mvp ###"

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
  if [ -r /dev/tty ]; then
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

${C_BOLD}=== Solon MVP Installer ===${C_RESET}

모드:   $MODE
타겟:   $(pwd)
Solon:  https://github.com/${SOLON_REPO} (branch: $SOLON_BRANCH)

Solon 은 AI-native 7-step flow (브레인스토밍 → plan → sprint → 구현 → review →
commit → 문서화) 를 현재 프로젝트에 주입합니다. .sfs-local/ 스캐폴드 + SFS.md
공통 지침 + Claude/Codex/Gemini 어댑터 + .gitignore 규칙이 설치됩니다.

EOF

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
  TMP_CLONE=$(mktemp -d -t solon-mvp-install.XXXXXX)
  info ""
  info "Fetching Solon MVP (depth=1)..."
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

# 6.3) 자동 치환 가능한 placeholder (DATE + SOLON-VERSION) 처리
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

# sprints/ + decisions/
mkdir -p "$TARGET/.sfs-local/sprints" "$TARGET/.sfs-local/decisions"
[ -f "$TARGET/.sfs-local/sprints/.gitkeep" ] || touch "$TARGET/.sfs-local/sprints/.gitkeep"
[ -f "$TARGET/.sfs-local/decisions/.gitkeep" ] || touch "$TARGET/.sfs-local/decisions/.gitkeep"
ok "  sprints/ + decisions/ 확보"

# ============================================================================
# 8. .gitignore 주입 (idempotent marker-based)
# ============================================================================

info ""
info ".gitignore 갱신..."

touch "$TARGET/.gitignore"

if grep -qF "$GIT_MARKER_BEGIN" "$TARGET/.gitignore" 2>/dev/null; then
  ok "solon-mvp 블록 이미 존재 — skip"
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
  ok "solon-mvp 블록 추가됨"
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
source_repo: https://github.com/${SOLON_REPO}
EOF
ok "VERSION 기록: $SOLON_VERSION ($MODE @ $INSTALLED_AT)"

# ============================================================================
# 10. 완료
# ============================================================================

cat <<EOF

${C_BOLD}${C_GREEN}=== Solon MVP 설치 완료 ===${C_RESET}

설치 위치:       $TARGET
Solon 버전:      $SOLON_VERSION
.sfs-local/:     스캐폴드 (${C_BOLD}기존 sprint 산출물은 보존됨${C_RESET})
공통 지침:       SFS.md
런타임 어댑터:   CLAUDE.md / AGENTS.md / GEMINI.md
Claude /sfs:     .claude/commands/sfs.md

다음 단계:

  ${C_BOLD}1.${C_RESET} SFS.md 내용 확인 + 프로젝트 특성 반영 (Stack / 도메인 등).

  ${C_BOLD}2.${C_RESET} 선호 런타임에서 시작:
     ${C_BLUE}cd $TARGET && claude${C_RESET}
     ${C_BLUE}/sfs status${C_RESET} 또는 ${C_BLUE}/sfs start${C_RESET} 로 시작.
     Codex/Gemini CLI 에서는 "SFS.md 읽고 sfs status처럼 현재 상태 요약해줘" 로 시작.

  ${C_BOLD}3.${C_RESET} git commit + push (Solon 주입 자체를 기록):
     ${C_BLUE}git add SFS.md CLAUDE.md AGENTS.md GEMINI.md .gitignore .claude/commands/sfs.md .sfs-local/${C_RESET}
     ${C_BLUE}git commit -m "chore: install solon-mvp $SOLON_VERSION"${C_RESET}
     ${C_BLUE}git push${C_RESET}

  ${C_BOLD}4.${C_RESET} 버전 갱신 필요 시: ${C_BLUE}solon-mvp/upgrade.sh${C_RESET} 실행.

문제 발생 시: https://github.com/${SOLON_REPO}/issues

EOF
