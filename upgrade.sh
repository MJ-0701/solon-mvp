#!/usr/bin/env bash
# upgrade.sh — Solon MVP upgrader (VERSION 기반)
#
# 사용법:
#   cd ~/workspace/my-project
#   ~/tmp/solon-mvp/upgrade.sh                   # 로컬 clone 기반
#   curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-mvp/main/upgrade.sh | bash  # 원격
#
# 동작:
#   1. consumer 쪽 .sfs-local/VERSION 읽어서 installed_version 파악
#   2. distribution 쪽 최신 VERSION 조회
#   3. 같으면 종료, 다르면 업그레이드 계획 + 대화형 파일별 처리
#
# 원칙:
#   - .sfs-local/sprints/*, .sfs-local/decisions/*, .sfs-local/events.jsonl 은 절대 덮어쓰지 않음
#   - CLAUDE.md / .gitignore / divisions.yaml 만 대상 (사용자 수정분 우선 diff 보여줌)
#   - 업그레이드 취소는 언제든 가능 (파일 쓰기 전 전부 dry-run 프리뷰)

set -euo pipefail

readonly SOLON_REPO="MJ-0701/solon-mvp"
readonly SOLON_BRANCH="main"
readonly GIT_MARKER_BEGIN="### BEGIN solon-mvp ###"
readonly GIT_MARKER_END="### END solon-mvp ###"

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
if [ ! -t 0 ] && [ -r /dev/tty ]; then exec < /dev/tty; fi

prompt() {
  local msg="$1" default="${2:-}" answer
  if [ -n "$default" ]; then printf "%s [%s]: " "$msg" "$default"
  else printf "%s: " "$msg"; fi
  read -r answer || answer=""
  echo "${answer:-$default}"
}

# ============================================================================
# 1. 소스 위치 판별
# ============================================================================

SCRIPT_PATH="${BASH_SOURCE[0]:-}"
SOURCE_DIR=""
TMP_CLONE=""
cleanup() { [ -n "$TMP_CLONE" ] && [ -d "$TMP_CLONE" ] && rm -rf "$TMP_CLONE"; }
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

# ============================================================================
# 2. 버전 비교
# ============================================================================

NEW_VER=$(cat "$SOURCE_DIR/VERSION" 2>/dev/null | head -1 || echo "unknown")

if [ ! -f "$TARGET/.sfs-local/VERSION" ]; then
  die ".sfs-local/VERSION 없음 — Solon 이 설치되지 않은 상태. 먼저 install.sh 실행."
fi

CUR_VER=$(grep '^solon_mvp_version:' "$TARGET/.sfs-local/VERSION" | awk '{print $2}')
INSTALLED_AT=$(grep '^installed_at:' "$TARGET/.sfs-local/VERSION" | awk '{print $2}')

cat <<EOF

${C_BOLD}=== Solon MVP Upgrade ===${C_RESET}

현재 설치:   $CUR_VER  (installed: $INSTALLED_AT)
최신 배포:   $NEW_VER
소스 모드:   $MODE

EOF

if [ "$CUR_VER" = "$NEW_VER" ]; then
  ok "이미 최신 버전. 업그레이드 불필요."
  exit 0
fi

# ============================================================================
# 3. Dry-run 프리뷰 — 어떤 파일이 바뀌나
# ============================================================================

info ""
info "변경 예정 파일 프리뷰..."

# diff 보여줄 파일 3종
declare -a CHECK_FILES=(
  "CLAUDE.md|templates/CLAUDE.md.template"
  ".sfs-local/divisions.yaml|templates/.sfs-local-template/divisions.yaml"
)

for pair in "${CHECK_FILES[@]}"; do
  dst_rel="${pair%%|*}"
  src_rel="${pair##*|}"
  src="$SOURCE_DIR/$src_rel"
  dst="$TARGET/$dst_rel"

  printf "\n  ${C_BOLD}%s${C_RESET}\n" "$dst_rel"
  if [ ! -f "$dst" ]; then
    printf "    (기존 없음 — 신규 설치 예정)\n"
  elif diff -q "$dst" "$src" >/dev/null 2>&1; then
    printf "    (동일 — 변경 없음)\n"
  else
    lines_diff=$(diff "$dst" "$src" | grep -c '^[<>]' || true)
    printf "    (~%s 줄 차이 — 대화형 처리 대상)\n" "$lines_diff"
  fi
done

# .gitignore snippet 은 marker 기반 블록 교체
printf "\n  ${C_BOLD}.gitignore${C_RESET}\n"
if grep -qF "$GIT_MARKER_BEGIN" "$TARGET/.gitignore" 2>/dev/null; then
  printf "    (solon-mvp 블록 존재 — 내용만 갱신 예정)\n"
else
  printf "    (solon-mvp 블록 없음 — 신규 추가 예정)\n"
fi

echo ""
if [ "$(prompt "업그레이드 진행?" "y")" != "y" ]; then
  info "취소됨."
  exit 0
fi

# ============================================================================
# 4. 파일별 갱신 (대화형)
# ============================================================================

update_file() {
  local dst_rel="$1" src_rel="$2" label="$3"
  local dst="$TARGET/$dst_rel" src="$SOURCE_DIR/$src_rel"

  [ -f "$src" ] || { err "source 없음: $src_rel"; return 1; }

  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    ok "신규 설치: $dst_rel"
    return 0
  fi

  if diff -q "$dst" "$src" >/dev/null 2>&1; then
    ok "변경 없음: $dst_rel"
    return 0
  fi

  warn "$dst_rel 차이 있음 ($label)"
  while true; do
    local ans
    ans=$(prompt "    [s]kip / [b]ackup+overwrite / [o]verwrite / [d]iff" "s")
    case "$ans" in
      s|S|"") ok "skip: $dst_rel"; return 0 ;;
      b|B)
        local ts=$(date +%Y%m%d-%H%M%S)
        mv "$dst" "$dst.bak-$ts"
        cp "$src" "$dst"
        ok "백업 + 갱신: $dst_rel → $dst_rel.bak-$ts"
        return 0 ;;
      o|O) cp "$src" "$dst"; ok "덮어쓰기: $dst_rel"; return 0 ;;
      d|D)
        printf "\n--- diff: %s ---\n" "$dst_rel"
        diff -u "$dst" "$src" || true
        printf "--- end ---\n\n" ;;
      *) warn "s/b/o/d 중 선택" ;;
    esac
  done
}

info ""
info "파일별 갱신..."

update_file "CLAUDE.md" "templates/CLAUDE.md.template" "세션 지침"
update_file ".sfs-local/divisions.yaml" "templates/.sfs-local-template/divisions.yaml" "본부 활성화"

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
ok ".gitignore solon-mvp 블록 교체 완료"

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
source_repo: https://github.com/${SOLON_REPO}
EOF
ok "VERSION 갱신: $CUR_VER → $NEW_VER"

# ============================================================================
# 7. 완료
# ============================================================================

cat <<EOF

${C_BOLD}${C_GREEN}=== 업그레이드 완료 ===${C_RESET}

  $CUR_VER → $NEW_VER

변경사항 git commit 권장:
  ${C_BLUE}git add CLAUDE.md .gitignore .sfs-local/divisions.yaml .sfs-local/VERSION${C_RESET}
  ${C_BLUE}git commit -m "chore: upgrade solon-mvp $CUR_VER → $NEW_VER"${C_RESET}

CHANGELOG: https://github.com/${SOLON_REPO}/blob/main/CHANGELOG.md

EOF
