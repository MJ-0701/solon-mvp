#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_HOME="$HOME/.claude"
CHECKSUMS_FILE=".claude/.checksums"

# 색상
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}[OK]${NC}   $1"; }
skip() { echo -e "  ${YELLOW}[SKIP]${NC} $1"; }
conflict() { echo -e "  ${RED}[WARN]${NC} $1"; }

# 충돌 파일 수집
CONFLICT_FILES=()

# ─────────────────────────────────────────────
# checksum 유틸
# ─────────────────────────────────────────────
file_checksum() {
  md5 -q "$1" 2>/dev/null || md5sum "$1" | cut -d' ' -f1
}

get_saved_checksum() {
  local target="$1" rel_path="$2"
  local checksums_path="$target/$CHECKSUMS_FILE"
  if [ -f "$checksums_path" ]; then
    grep "^$rel_path " "$checksums_path" 2>/dev/null | cut -d' ' -f2 || echo ""
  else
    echo ""
  fi
}

save_checksum() {
  local target="$1" rel_path="$2" checksum="$3"
  local checksums_path="$target/$CHECKSUMS_FILE"
  mkdir -p "$(dirname "$checksums_path")"
  # 기존 항목 제거 후 추가
  if [ -f "$checksums_path" ]; then
    grep -v "^$rel_path " "$checksums_path" > "$checksums_path.tmp" 2>/dev/null || true
    mv "$checksums_path.tmp" "$checksums_path"
  fi
  echo "$rel_path $checksum" >> "$checksums_path"
}

# ─────────────────────────────────────────────
# 파일 단위 스마트 설치
# ─────────────────────────────────────────────
install_file() {
  local src="$1" target_dir="$2" target_root="$3" rel_path="$4"
  local dest="$target_dir/$(basename "$src")"

  local src_checksum
  src_checksum=$(file_checksum "$src")
  local saved_checksum
  saved_checksum=$(get_saved_checksum "$target_root" "$rel_path")

  if [ ! -f "$dest" ]; then
    # 신규 설치
    cp "$src" "$dest"
    save_checksum "$target_root" "$rel_path" "$src_checksum"
    log "$rel_path (신규 설치)"
    return
  fi

  local dest_checksum
  dest_checksum=$(file_checksum "$dest")

  if [ "$src_checksum" = "$saved_checksum" ]; then
    # 공유 레포 변경 없음 → 프로젝트 수정 보존
    skip "$rel_path (프로젝트 수정 보존)"
    return
  fi

  if [ "$src_checksum" = "$dest_checksum" ]; then
    # 이미 최신
    save_checksum "$target_root" "$rel_path" "$src_checksum"
    skip "$rel_path (이미 최신)"
    return
  fi

  if [ "$dest_checksum" = "$saved_checksum" ]; then
    # 프로젝트 수정 없음, 공유 레포만 변경 → 갱신
    cp "$src" "$dest"
    save_checksum "$target_root" "$rel_path" "$src_checksum"
    log "$rel_path (갱신)"
    return
  fi

  # 양쪽 변경 → 백업 후 갱신
  cp "$dest" "$dest.bak"
  cp "$src" "$dest"
  save_checksum "$target_root" "$rel_path" "$src_checksum"
  conflict "$rel_path (양쪽 변경 → 갱신, 기존 .bak 백업)"
  CONFLICT_FILES+=("$rel_path")
}

# ─────────────────────────────────────────────
# 디렉토리 단위 설치
# ─────────────────────────────────────────────
install_dir() {
  local src_dir="$1" dest_dir="$2" target_root="$3" prefix="$4"
  mkdir -p "$dest_dir"
  for src_file in "$src_dir"/*; do
    [ ! -e "$src_file" ] && continue
    local name
    name=$(basename "$src_file")
    local rel="$prefix/$name"
    if [ -d "$src_file" ]; then
      install_dir "$src_file" "$dest_dir/$name" "$target_root" "$rel"
    else
      install_file "$src_file" "$dest_dir" "$target_root" "$rel"
    fi
  done
}

# ─────────────────────────────────────────────
# 1. ~/.claude/CLAUDE.md 설치 (전역 공통 규칙)
# ─────────────────────────────────────────────
install_global() {
  cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
  log "~/.claude/CLAUDE.md 설치 완료"
}

# ─────────────────────────────────────────────
# 2. 프로젝트별 설치
# ─────────────────────────────────────────────
install_project() {
  local target="$1"
  CONFLICT_FILES=()

  if [ ! -d "$target" ]; then
    echo "ERROR: $target 디렉토리가 존재하지 않습니다."
    exit 1
  fi

  echo ""
  echo ">>> $target 설치 시작"

  mkdir -p "$target/.claude"

  # agents
  echo ""
  echo "  [agents]"
  install_dir "$SCRIPT_DIR/agents" "$target/.claude/agents" "$target" ".claude/agents"

  # skills
  echo ""
  echo "  [skills]"
  install_dir "$SCRIPT_DIR/skills" "$target/.claude/skills" "$target" ".claude/skills"

  # hooks
  echo ""
  echo "  [hooks]"
  install_dir "$SCRIPT_DIR/hooks" "$target/.claude/hooks" "$target" ".claude/hooks"
  chmod +x "$target/.claude/hooks/"*.sh 2>/dev/null || true

  # settings.json
  echo ""
  echo "  [settings]"
  install_file "$SCRIPT_DIR/settings.json" "$target/.claude" "$target" ".claude/settings.json"
  if [ -f "$target/.claude/settings.local.json" ]; then
    skip "settings.local.json 유지 (프로젝트 고유)"
  fi

  # standards
  echo ""
  echo "  [standards]"
  install_dir "$SCRIPT_DIR/standards" "$target/docs/standards" "$target" "docs/standards"

  # README.md → docs/claudeguide.md
  echo ""
  echo "  [docs]"
  mkdir -p "$target/docs"
  install_file "$SCRIPT_DIR/README.md" "$target/docs" "$target" "docs/claudeguide.md"

  # CLAUDE.md (프로젝트 루트)는 건드리지 않음
  if [ -f "$target/CLAUDE.md" ]; then
    skip "CLAUDE.md 유지 (프로젝트 고유)"
  else
    echo -e "  ${YELLOW}[WARN]${NC} CLAUDE.md 없음 — 프로젝트 고유 정보를 직접 작성해주세요"
  fi

  echo ""
  echo ">>> $target 설치 완료"

  # 충돌 요약
  if [ ${#CONFLICT_FILES[@]} -gt 0 ]; then
    echo ""
    echo -e "  ${RED}⚠ 양쪽 변경 파일 ${#CONFLICT_FILES[@]}건:${NC}"
    for f in "${CONFLICT_FILES[@]}"; do
      echo "    - $f (.bak 백업됨)"
    done
    echo ""
    echo "  차이점 확인:"
    for f in "${CONFLICT_FILES[@]}"; do
      echo "    diff $target/$f $target/$f.bak"
    done
  fi
}

# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────
echo "=== claude-shared-config installer ==="
echo ""

if [ $# -eq 0 ]; then
  echo "사용법: ./install.sh <프로젝트 경로> [프로젝트 경로2] ..."
  echo ""
  echo "예시:"
  echo "  ./install.sh /Users/gr/IdeaProjects/greenribbon-api"
  echo "  ./install.sh /Users/gr/IdeaProjects/greenribbon-api /Users/gr/IdeaProjects/agent-work-manage-api"
  echo ""
  echo "옵션:"
  echo "  --global-only   ~/.claude/CLAUDE.md만 설치"
  exit 1
fi

# 전역 설치
install_global

# AgentShield 글로벌 설치
if command -v ecc-agentshield >/dev/null 2>&1; then
  log "ecc-agentshield 이미 설치됨"
else
  echo ""
  echo "  [AgentShield]"
  npm install -g ecc-agentshield 2>/dev/null && log "ecc-agentshield 글로벌 설치 완료" || echo -e "  ${YELLOW}[SKIP]${NC} ecc-agentshield 설치 실패 (npm 확인 필요)"
fi

# --global-only 옵션
if [ "$1" = "--global-only" ]; then
  echo ""
  echo "=== 전역 설치만 완료 ==="
  exit 0
fi

# 프로젝트별 설치
for project in "$@"; do
  install_project "$project"
done

echo ""
echo "=== 전체 설치 완료 ==="
