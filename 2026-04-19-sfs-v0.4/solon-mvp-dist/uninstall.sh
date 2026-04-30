#!/usr/bin/env bash
# uninstall.sh — Solon Product uninstaller
#
# 사용법:
#   cd ~/workspace/my-project
#   sfs uninstall
#   sfs uninstall --keep-artifacts --remove-docs
#   ~/tmp/solon-product/uninstall.sh
#
# 동작:
#   1. .gitignore 에서 solon-product 블록 제거 (legacy `solon-mvp` marker 도 동일 처리)
#   2. .sfs-local/ 처리 — 대화형:
#      (a) 전부 제거 (sprints/decisions 산출물 포함)
#      (b) scaffold 만 제거, 산출물 (sprints/decisions/events.jsonl) 보존
#      (c) 취소
#   3. 설치 취소 기록은 git commit 권장 (스크립트가 자동 commit 하지 않음)

set -euo pipefail

ARTIFACT_MODE=""
DOC_MODE=""

usage() {
  cat <<'EOF'
Usage: sfs uninstall [--keep-artifacts|--remove-all] [--remove-docs|--keep-docs]

Options:
  --keep-artifacts   scaffold 만 제거하고 sprints/decisions/events.jsonl 보존
  --remove-all       .sfs-local 전체 제거
  --remove-docs      SFS.md/CLAUDE.md/AGENTS.md/GEMINI.md 및 agent entry point 제거
  --keep-docs        SFS.md/CLAUDE.md/AGENTS.md/GEMINI.md 및 agent entry point 보존
  -h, --help         도움말 출력
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --keep-artifacts)
      ARTIFACT_MODE="keep"
      ;;
    --remove-all)
      ARTIFACT_MODE="all"
      ;;
    --remove-docs|--remove-adapters)
      DOC_MODE="remove"
      ;;
    --keep-docs|--keep-adapters)
      DOC_MODE="keep"
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

case "$ARTIFACT_MODE" in
  ""|keep|all) ;;
  *) echo "알 수 없는 artifact mode: $ARTIFACT_MODE" >&2; exit 99 ;;
esac

case "$DOC_MODE" in
  ""|remove|keep) ;;
  *) echo "알 수 없는 doc mode: $DOC_MODE" >&2; exit 99 ;;
esac

readonly GIT_MARKER_BEGIN="### BEGIN solon-product ###"
readonly GIT_MARKER_END="### END solon-product ###"
# Legacy markers (0.5.0-mvp 이전 install) — uninstall 시 동일 처리.
readonly LEGACY_GIT_MARKER_BEGIN="### BEGIN solon-mvp ###"
readonly LEGACY_GIT_MARKER_END="### END solon-mvp ###"

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

if [ ! -t 0 ] && [ -r /dev/tty ] && { : < /dev/tty; } 2>/dev/null; then
  exec < /dev/tty
fi

prompt() {
  local msg="$1" default="${2:-}" answer
  if [ -n "$default" ]; then printf "%s [%s]: " "$msg" "$default" >&2
  else printf "%s: " "$msg" >&2; fi
  read -r answer || answer=""
  echo "${answer:-$default}"
}

TARGET="$(pwd)"

cat <<EOF

${C_BOLD}=== Solon Product Uninstaller ===${C_RESET}

타겟:   $TARGET

EOF

if [ ! -d "$TARGET/.sfs-local" ] && ! grep -qF "$GIT_MARKER_BEGIN" "$TARGET/.gitignore" 2>/dev/null; then
  warn "Solon 설치 흔적 없음 (.sfs-local/ 도 .gitignore 마커도 없음)"
  exit 0
fi

# ============================================================================
# 1. .sfs-local/ 처리 방법 선택
# ============================================================================

if [ -d "$TARGET/.sfs-local" ]; then
  SPRINT_COUNT=$(find "$TARGET/.sfs-local/sprints" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  DECISION_COUNT=$(find "$TARGET/.sfs-local/decisions" -mindepth 1 -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  EVENTS_LINES=$(wc -l < "$TARGET/.sfs-local/events.jsonl" 2>/dev/null || echo 0)
  EVENTS_LINES=$(echo "$EVENTS_LINES" | tr -d ' ')

  info "현재 .sfs-local/ 상태:"
  printf "  sprints/:    %s 개 디렉토리\n" "$SPRINT_COUNT"
  printf "  decisions/:  %s 개 파일\n" "$DECISION_COUNT"
  printf "  events.jsonl: %s 줄\n" "$EVENTS_LINES"
  echo ""

  cat <<EOF
선택:
  [a] 전부 제거 (sprints/decisions 산출물 포함 — ${C_RED}복구 불가${C_RESET})
  [b] scaffold 만 제거, 산출물 보존 (.sfs-local/sprints /decisions/events.jsonl 유지)
  [c] 취소

EOF
  case "$ARTIFACT_MODE" in
    keep) CHOICE="b" ;;
    all) CHOICE="a" ;;
    *) CHOICE=$(prompt "선택?" "c") ;;
  esac

  case "$CHOICE" in
    a|A)
      rm -rf "$TARGET/.sfs-local"
      ok ".sfs-local/ 전부 제거"
      ;;
    b|B)
      # scaffold 파일만 제거
      rm -f "$TARGET/.sfs-local/divisions.yaml"
      rm -f "$TARGET/.sfs-local/VERSION"
      rm -f "$TARGET/.sfs-local/GUIDE.md"
      rm -f "$TARGET/.sfs-local/auth.env.example"
      rm -f "$TARGET/.sfs-local/sprints/.gitkeep"
      rm -f "$TARGET/.sfs-local/decisions/.gitkeep"
      rm -rf "$TARGET/.sfs-local/scripts"
      rm -rf "$TARGET/.sfs-local/sprint-templates"
      rm -rf "$TARGET/.sfs-local/personas"
      rm -rf "$TARGET/.sfs-local/decisions-template"
      ok "scaffold 제거 (runtime scripts / templates / personas / divisions.yaml / VERSION / GUIDE.md / auth.env.example)"
      warn "산출물 보존: sprints/ / decisions/ / events.jsonl / current-sprint / current-wu"
      warn "로컬 인증값 보존: .sfs-local/auth.env"
      ;;
    *)
      info "취소됨."
      exit 0
      ;;
  esac
fi

# ============================================================================
# 2. .gitignore 블록 제거
# ============================================================================

# solon-product marker + legacy solon-mvp marker 양쪽 모두 동일 awk 로 제거 (idempotent).
remove_block() {
  local b="$1" e="$2"
  if [ -f "$TARGET/.gitignore" ] && grep -qF "$b" "$TARGET/.gitignore"; then
    awk -v b="$b" -v e="$e" '
      $0 == b { skip=1; next }
      $0 == e { skip=0; next }
      !skip { print }
    ' "$TARGET/.gitignore" > "$TARGET/.gitignore.tmp.$$"
    mv "$TARGET/.gitignore.tmp.$$" "$TARGET/.gitignore"
    ok ".gitignore '${b}' 블록 제거"
  fi
}
remove_block "$GIT_MARKER_BEGIN" "$GIT_MARKER_END"
remove_block "$LEGACY_GIT_MARKER_BEGIN" "$LEGACY_GIT_MARKER_END"

# ============================================================================
# 3. Runtime adapter docs — 대화형 (사용자가 수정했을 가능성)
# ============================================================================

for doc in \
  SFS.md \
  CLAUDE.md \
  AGENTS.md \
  GEMINI.md \
  .claude/commands/sfs.md \
  .gemini/commands/sfs.toml \
  .agents/skills/sfs/SKILL.md
do
  [ -f "$TARGET/$doc" ] || continue
  echo ""
  warn "$doc 가 존재합니다 (사용자가 편집했을 수 있음)"
  case "$DOC_MODE" in
    remove) ans="y" ;;
    keep) ans="N" ;;
    *) ans=$(prompt "$doc 삭제할까요?" "N") ;;
  esac
  case "$ans" in
    y|Y|yes|YES)
      rm -f "$TARGET/$doc"
      ok "$doc 제거"
      ;;
    *)
      ok "$doc 보존"
      ;;
  esac
done

rmdir "$TARGET/.claude/commands" "$TARGET/.claude" 2>/dev/null || true
rmdir "$TARGET/.gemini/commands" "$TARGET/.gemini" 2>/dev/null || true
rmdir "$TARGET/.agents/skills/sfs" "$TARGET/.agents/skills" "$TARGET/.agents" 2>/dev/null || true

# ============================================================================
# 4. 완료
# ============================================================================

cat <<EOF

${C_BOLD}${C_GREEN}=== Uninstall 완료 ===${C_RESET}

변경사항 git commit 권장:
  ${C_BLUE}git add -A${C_RESET}
  ${C_BLUE}git commit -m "chore: uninstall solon-product"${C_RESET}

EOF
