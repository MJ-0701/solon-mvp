#!/usr/bin/env bash
# upgrade.sh — Solon Product upgrader (VERSION 기반)
#
# 사용법:
#   cd ~/workspace/my-project
#   bash ~/tmp/solon-product/upgrade.sh              # 로컬 clone 기반
#   curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-product/main/upgrade.sh | bash  # 원격
#
# 동작:
#   1. consumer 쪽 .sfs-local/VERSION 읽어서 installed_version 파악
#   2. distribution 쪽 최신 VERSION 조회
#   3. 같으면 종료, 다르면 업그레이드 계획 + 대화형 파일별 처리
#
# 원칙:
#   - .sfs-local/sprints/*, .sfs-local/decisions/*, .sfs-local/events.jsonl 은 절대 덮어쓰지 않음
#   - SFS.md / runtime adapter / .gitignore / divisions.yaml 대상
#   - 사용자 수정 가능성이 큰 파일은 checksum + 추천 action 을 먼저 보여줌
#   - 업그레이드 취소는 언제든 가능 (파일 쓰기 전 전부 dry-run 프리뷰)

set -euo pipefail

readonly SOLON_REPO="MJ-0701/solon-product"
readonly SOLON_BRANCH="main"
readonly GIT_MARKER_BEGIN="### BEGIN solon-product ###"
readonly GIT_MARKER_END="### END solon-product ###"
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

ASSUME_YES=0

usage() {
  cat <<EOF
Usage: ./upgrade.sh [--yes]

Options:
  -y, --yes   dry-run 프리뷰 후 확인 프롬프트를 자동 승인합니다.
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

# pipe 대응
if [ "$ASSUME_YES" -ne 1 ] && [ ! -t 0 ]; then
  if [ -e /dev/tty ] && { : < /dev/tty; } 2>/dev/null; then
    exec < /dev/tty
  else
    die "대화형 input 불가 (stdin 파이프 + /dev/tty 없음). 자동 승인하려면 --yes 를 명시하세요."
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
  info "Fetching Solon Product latest..."
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

${C_BOLD}=== Solon Product Upgrade ===${C_RESET}

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

  if [ "$same" = "yes" ]; then
    printf "없음"
    return 0
  fi
  if [ "$exists" = "no" ]; then
    printf "install"
    return 0
  fi

  case "$dst_rel" in
    "SFS.md"|".claude/commands/sfs.md")
      printf "backup+overwrite"
      ;;
    "CLAUDE.md"|"AGENTS.md"|"GEMINI.md"|".sfs-local/divisions.yaml")
      printf "skip"
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
  - 신규 파일                   → 자동 설치
  - checksum 동일               → 변경 없음
  - SFS.md                      → backup+overwrite (공통 SFS core 최신화)
  - CLAUDE/AGENTS/GEMINI.md     → 자동 보존 (기존 프로젝트 지침 보호)
  - .sfs-local/divisions.yaml   → 자동 보존 (프로젝트별 운영값 보호)
  - .claude/commands/sfs.md     → backup+overwrite (배포판 관리 커맨드 최신화)
  - .sfs-local/scripts/         → 자동 갱신 (배포판 관리 런타임)
  - .sfs-local/sprint-templates/ → 자동 갱신 (새 sprint 생성 템플릿)
  - .sfs-local/decisions-template/ → 자동 갱신 (ADR 템플릿)

EOF

# diff 보여줄 파일
declare -a CHECK_FILES=(
  "SFS.md|templates/SFS.md.template"
  "CLAUDE.md|templates/CLAUDE.md.template"
  "AGENTS.md|templates/AGENTS.md.template"
  "GEMINI.md|templates/GEMINI.md.template"
  ".claude/commands/sfs.md|templates/.claude/commands/sfs.md"
  ".sfs-local/divisions.yaml|templates/.sfs-local-template/divisions.yaml"
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
elif grep -qF "$LEGACY_GIT_MARKER_BEGIN" "$TARGET/.gitignore" 2>/dev/null; then
  printf "    상태: legacy solon-mvp 블록 존재 — solon-product marker 로 교체 예정\n"
  printf "    checksum: managed-snippet=%s\n" "$snippet_sum"
  printf "    추천: 자동 갱신\n"
else
  printf "    상태: solon-product 블록 없음 — 신규 추가 예정\n"
  printf "    checksum: managed-snippet=%s\n" "$snippet_sum"
  printf "    추천: 자동 추가\n"
fi

printf "\n  ${C_BOLD}.sfs-local/scripts/${C_RESET}\n"
script_count=$(find "$SOURCE_DIR/templates/.sfs-local-template/scripts" -maxdepth 1 -type f -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')
printf "    상태: managed runtime scripts %s개 — 자동 갱신 예정\n" "$script_count"
printf "    추천: overwrite + chmod +x\n"

printf "\n  ${C_BOLD}.sfs-local/sprint-templates/${C_RESET}\n"
sprint_tpl_count=$(find "$SOURCE_DIR/templates/.sfs-local-template/sprint-templates" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
printf "    상태: sprint templates %s개 — 자동 갱신 예정\n" "$sprint_tpl_count"
printf "    추천: overwrite\n"

printf "\n  ${C_BOLD}.sfs-local/decisions-template/${C_RESET}\n"
decision_tpl_count=$(find "$SOURCE_DIR/templates/.sfs-local-template/decisions-template" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
printf "    상태: decision templates %s개 — 자동 갱신 예정\n" "$decision_tpl_count"
printf "    추천: overwrite\n"

cat <<EOF

지금 무엇을 하면 되나:
  - 계속하려면 아래 "업그레이드 진행? [y]:" 에서 Enter 를 누르세요.
  - 멈추려면 n 을 입력하세요.

적용 결과:
  - 신규 파일과 .gitignore/VERSION 은 자동 처리됩니다.
  - 기존 프로젝트 지침 파일은 자동 보존됩니다.
  - backup+overwrite 대상은 기존 파일을 .bak-YYYYMMDD-HHMMSS 로 보관한 뒤 갱신합니다.

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
      local ts=$(date +%Y%m%d-%H%M%S)
      mv "$dst" "$dst.bak-$ts"
      cp "$src" "$dst"
      ok "백업 + 갱신: $dst_rel → $dst_rel.bak-$ts"
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

update_file "CLAUDE.md" "templates/CLAUDE.md.template" "Claude Code 어댑터" "s"
update_file "SFS.md" "templates/SFS.md.template" "공통 SFS 지침" "b"
update_file "AGENTS.md" "templates/AGENTS.md.template" "Codex 어댑터" "s"
update_file "GEMINI.md" "templates/GEMINI.md.template" "Gemini CLI 어댑터" "s"
mkdir -p "$TARGET/.claude/commands"
update_file ".claude/commands/sfs.md" "templates/.claude/commands/sfs.md" "Claude Code /sfs 커맨드" "b"
update_file ".sfs-local/divisions.yaml" "templates/.sfs-local-template/divisions.yaml" "본부 활성화" "s"

copy_managed_files() {
  local src_dir="$1" dst_dir="$2" kind="$3" label="$4"

  [ -d "$src_dir" ] || { warn "source 없음: $src_dir"; return 0; }
  mkdir -p "$dst_dir"

  case "$kind" in
    sh)
      cp "$src_dir"/*.sh "$dst_dir/" 2>/dev/null || true
      chmod +x "$dst_dir"/*.sh 2>/dev/null || true
      ;;
    md)
      cp "$src_dir"/*.md "$dst_dir/" 2>/dev/null || true
      ;;
    *)
      warn "알 수 없는 managed file kind: $kind"
      return 0
      ;;
  esac

  ok "managed 갱신: $label"
}

copy_managed_files \
  "$SOURCE_DIR/templates/.sfs-local-template/scripts" \
  "$TARGET/.sfs-local/scripts" \
  "sh" \
  ".sfs-local/scripts/ (executable)"

copy_managed_files \
  "$SOURCE_DIR/templates/.sfs-local-template/sprint-templates" \
  "$TARGET/.sfs-local/sprint-templates" \
  "md" \
  ".sfs-local/sprint-templates/"

copy_managed_files \
  "$SOURCE_DIR/templates/.sfs-local-template/decisions-template" \
  "$TARGET/.sfs-local/decisions-template" \
  "md" \
  ".sfs-local/decisions-template/"

TODAY=$(date +%Y-%m-%d)
if [ "$(uname)" = "Darwin" ]; then
  SED_INPLACE=(sed -i '')
else
  SED_INPLACE=(sed -i)
fi
for auto_file in "$TARGET/SFS.md" "$TARGET/CLAUDE.md" "$TARGET/AGENTS.md" "$TARGET/GEMINI.md" "$TARGET/.sfs-local/divisions.yaml"; do
  if [ -f "$auto_file" ]; then
    "${SED_INPLACE[@]}" \
      -e "s|<DATE>|$TODAY|g" \
      -e "s|<SOLON-VERSION>|$NEW_VER|g" \
      "$auto_file" 2>/dev/null || true
  fi
done
ok "문서 자동 치환: <DATE>=$TODAY, <SOLON-VERSION>=$NEW_VER"

# ============================================================================
# 5. .gitignore 블록 교체 (marker 기반)
# ============================================================================

info ""
info ".gitignore 블록 갱신..."

remove_gitignore_block() {
  local begin="$1" end="$2"
  if grep -qF "$begin" "$TARGET/.gitignore" 2>/dev/null; then
    awk -v b="$begin" -v e="$end" '
    $0 == b { skip=1; next }
    $0 == e { skip=0; next }
    !skip { print }
    ' "$TARGET/.gitignore" > "$TARGET/.gitignore.tmp"
    mv "$TARGET/.gitignore.tmp" "$TARGET/.gitignore"
  fi
}

remove_gitignore_block "$GIT_MARKER_BEGIN" "$GIT_MARKER_END"
remove_gitignore_block "$LEGACY_GIT_MARKER_BEGIN" "$LEGACY_GIT_MARKER_END"

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
  ${C_BLUE}git add SFS.md CLAUDE.md AGENTS.md GEMINI.md .claude/commands/sfs.md .gitignore .sfs-local/divisions.yaml .sfs-local/VERSION .sfs-local/scripts .sfs-local/sprint-templates .sfs-local/decisions-template${C_RESET}
  ${C_BLUE}git commit -m "chore: upgrade solon-product $CUR_VER → $NEW_VER"${C_RESET}

CHANGELOG: https://github.com/${SOLON_REPO}/blob/main/CHANGELOG.md

EOF
