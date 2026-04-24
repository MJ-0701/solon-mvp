#!/usr/bin/env bash
# setup-w0.sh — Phase 1 MVP W0 환경 준비 자동화 (사용자 Mac 실행)
# 출처: Solon docset WU-19 (2026-04-24)
# 대응: PHASE1-MVP-QUICK-START.md §2
# 실행: ./setup-w0.sh  (환경변수 3개 필요)

set -euo pipefail

# === 1) 환경변수 검증 ===
: "${PROJECT_NAME:?env PROJECT_NAME required (예: admin-panel-mvp)}"
: "${SOLON_DOCSET:?env SOLON_DOCSET required (예: \$HOME/workspace/solon-docset/2026-04-19-sfs-v0.4)}"
: "${WORKSPACE:?env WORKSPACE required (admin panel repo 를 둘 부모 디렉토리)}"

# GITHUB_USER 는 optional — 없으면 whoami 사용
GITHUB_USER="${GITHUB_USER:-$(whoami)}"
GIT_PROTOCOL="${GIT_PROTOCOL:-ssh}"   # ssh 또는 https

TEMPLATES_DIR="$SOLON_DOCSET/phase1-mvp-templates"
REPO_DIR="$WORKSPACE/$PROJECT_NAME"

# === 2) 사전 체크 ===
echo "==> Pre-flight check"
if [ ! -d "$TEMPLATES_DIR" ]; then
  echo "❌ TEMPLATES_DIR 없음: $TEMPLATES_DIR"
  exit 1
fi
if [ -d "$REPO_DIR" ]; then
  echo "❌ REPO_DIR 이미 존재: $REPO_DIR — 중단 (수동 처리 필요)"
  exit 1
fi
if ! command -v git >/dev/null; then
  echo "❌ git 미설치"
  exit 1
fi

# === 3) Repo clone ===
echo "==> Cloning repo"
cd "$WORKSPACE"
if [ "$GIT_PROTOCOL" = "ssh" ]; then
  REPO_URL="git@github.com:$GITHUB_USER/$PROJECT_NAME.git"
else
  REPO_URL="https://github.com/$GITHUB_USER/$PROJECT_NAME.git"
fi
echo "   → $REPO_URL"
git clone "$REPO_URL" "$PROJECT_NAME"
cd "$PROJECT_NAME"

# === 4) 템플릿 복사 ===
echo "==> Copying templates"
cp "$TEMPLATES_DIR/CLAUDE.md.template" ./CLAUDE.md
cp "$TEMPLATES_DIR/README.md.template" ./README.md
touch ./.gitignore
cat "$TEMPLATES_DIR/.gitignore.snippet" >> ./.gitignore

mkdir -p .sfs-local/sprints .sfs-local/decisions
cp "$TEMPLATES_DIR/.sfs-local-template/divisions.yaml.template" ./.sfs-local/divisions.yaml
touch .sfs-local/events.jsonl .sfs-local/sprints/.gitkeep .sfs-local/decisions/.gitkeep

# === 5) Placeholder 치환 (OS 호환) ===
echo "==> Replacing placeholders"
TODAY=$(date +%Y-%m-%d)
# macOS sed -i '' vs Linux sed -i 호환
if [ "$(uname)" = "Darwin" ]; then
  SED_INPLACE=(sed -i '')
else
  SED_INPLACE=(sed -i)
fi
"${SED_INPLACE[@]}" \
  -e "s|<PROJECT-NAME>|$PROJECT_NAME|g" \
  -e "s|<DATE>|$TODAY|g" \
  ./CLAUDE.md ./README.md ./.sfs-local/divisions.yaml

# === 6) 남은 placeholder 리포트 (정상, 사용자가 에디터에서 채움) ===
echo "==> Remaining placeholders (에디터에서 수동 치환 — stack 결정 후):"
grep -rn '<[A-Z][A-Z0-9_-]*>' ./CLAUDE.md ./README.md ./.sfs-local/divisions.yaml || echo "   (없음)"

# === 7) IP 경계 pre-check ===
echo "==> IP boundary pre-check"
if git ls-files 2>/dev/null | grep -i solon >/dev/null; then
  echo "❌ Solon 파일이 이미 tracked 상태 — 중단"
  exit 1
fi
if [ -f .gitmodules ] && grep -iq solon .gitmodules; then
  echo "❌ .gitmodules 에 Solon 항목 존재 — 중단"
  exit 1
fi
echo "   ✅ clean"

# === 8) Initial commits ===
echo "==> Creating 3 commits"

git add .gitignore
git commit -m "chore: initial .gitignore (Node + .sfs-local rules)"

git add CLAUDE.md README.md
git commit -m "docs: CLAUDE.md + README (7-step flow, stack TBD)"

git add .sfs-local/
git commit -m "chore: .sfs-local/ scaffold (divisions.yaml + events.jsonl + sprints/ + decisions/)"

# === 9) Push ===
echo "==> Pushing to origin/main"
if git push -u origin main; then
  echo "   ✅ push 완료"
else
  echo "   ⚠ push 실패 — 수동 재시도 필요: cd $REPO_DIR && git push -u origin main"
fi

# === 10) 완료 ===
echo ""
echo "=== setup-w0.sh 완료 ==="
echo ""
echo "Repo: $REPO_DIR"
echo "Next steps:"
echo "  1. 에디터에서 나머지 placeholder 치환 (Stack / DB / DEPLOY / RECEIPT-API / EMAIL 등)"
echo "     → 치환 후 추가 commit + push"
echo "  2. ./verify-w0.sh 로 W0 exit 검증"
echo "  3. 검증 통과 시 'cd $REPO_DIR && claude' 로 첫 세션 시작"
echo "     (첫 프롬프트: $TEMPLATES_DIR/PROMPT-FOR-FIRST-SESSION.md 복붙)"
