#!/usr/bin/env bash
# verify-w0.sh — Phase 1 MVP W0 exit 검증 (사용자 Mac 실행, 현 디렉토리 = admin panel repo 루트)
# 출처: Solon docset WU-19 (2026-04-24)
# 대응: PHASE1-MVP-QUICK-START.md §6
# 실행: cd <repo>/ && ./verify-w0.sh  (또는 절대경로)
#
# 적용 대상: setup-w0.sh 산출물 전용 (3 commit + .sfs-local/ 구조 + CLAUDE.md/README.md placeholder).
#            install.sh 산출물은 본 검증기로 검증하지 말 것 — 별도 verify-install.sh 사용 (WU-30 §2 결정).
#            근거: WU-21 §F-04(a) — install.sh banner 의 'Solon' 키워드가 check #7 에 over-strict
#                  match 되어 false-positive 발생. WU22-D9 (b) 결정 = 두 검증기 분리.

set -euo pipefail

# === pass/fail counter ===
PASS=0
FAIL=0
WARN=0

ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL+1)); }
warn() { echo "  ⚠  $1"; WARN=$((WARN+1)); }

echo "=== W0 exit 검증 ==="
echo ""

# 0) git repo 확인
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "❌ 현 디렉토리는 git repo 아님"
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
echo "repo: $REPO_ROOT"
echo ""

# === 1) 3 commit 이상 존재 ===
echo "1) git commit 수"
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo 0)
if [ "$COMMIT_COUNT" -ge 3 ]; then
  ok "$COMMIT_COUNT commits (≥3)"
else
  fail "$COMMIT_COUNT commits (<3) — setup-w0.sh 가 3 commit 을 만들었어야 함"
fi

# === 2) IP 경계 — Solon 파일 zero ===
echo ""
echo "2) IP 경계 (git ls-files | grep -i solon)"
if git ls-files | grep -i solon >/dev/null; then
  fail "Solon 파일 유입!"
  git ls-files | grep -i solon | sed 's/^/     /'
else
  ok "Solon 파일 0건"
fi

# === 3) .gitmodules 없음 / Solon 항목 없음 ===
echo ""
echo "3) .gitmodules"
if [ -f .gitmodules ]; then
  if grep -iq solon .gitmodules; then
    fail ".gitmodules 에 Solon submodule 존재"
  else
    warn ".gitmodules 파일 존재 (Solon 항목은 없음) — 의도적이면 OK"
  fi
else
  ok ".gitmodules 없음"
fi

# === 4) .sfs-local 구조 ===
echo ""
echo "4) .sfs-local/ 구조"
[ -d .sfs-local ] && ok ".sfs-local/ 디렉토리 존재" || fail ".sfs-local/ 디렉토리 없음"
[ -f .sfs-local/divisions.yaml ] && ok ".sfs-local/divisions.yaml 존재" || fail ".sfs-local/divisions.yaml 없음"
[ -f .sfs-local/events.jsonl ] && ok ".sfs-local/events.jsonl 존재" || fail ".sfs-local/events.jsonl 없음"
[ -d .sfs-local/sprints ] && ok ".sfs-local/sprints/ 존재" || fail ".sfs-local/sprints/ 없음"
[ -d .sfs-local/decisions ] && ok ".sfs-local/decisions/ 존재" || fail ".sfs-local/decisions/ 없음"

# === 5) CLAUDE.md + README.md ===
echo ""
echo "5) root 문서"
[ -f CLAUDE.md ] && ok "CLAUDE.md 존재" || fail "CLAUDE.md 없음"
[ -f README.md ] && ok "README.md 존재" || fail "README.md 없음"

# === 6) placeholder 잔여 ===
echo ""
echo "6) placeholder 잔여 (Stack 결정 전이면 WARN, 결정 후이면 FAIL)"
PLACEHOLDER_FILES=(CLAUDE.md README.md .sfs-local/divisions.yaml)
PLACEHOLDER_HITS=0
for f in "${PLACEHOLDER_FILES[@]}"; do
  [ -f "$f" ] || continue
  if grep -nE '<[A-Z]{2,}[A-Z0-9_-]*>' "$f" >/dev/null; then
    PLACEHOLDER_HITS=$((PLACEHOLDER_HITS+1))
    warn "$f 에 placeholder 잔여:"
    grep -nE '<[A-Z]{2,}[A-Z0-9_-]*>' "$f" | sed 's/^/     /'
  fi
done
[ $PLACEHOLDER_HITS -eq 0 ] && ok "placeholder 전부 치환됨"

# === 7) CLAUDE.md 가 Solon 경로 미언급 (IP 경계) ===
# 적용 대상 = setup-w0.sh 산출물 only. install.sh output 의 'Solon' 제품명 키워드는
# 정상 banner 이므로 본 검증기에서 검사하면 false-positive (WU-21 §F-04(a)).
# install.sh output 검증은 verify-install.sh (별도 신설 예정) 에서 수행 (WU-30 §2 / WU22-D9 (b)).
echo ""
echo "7) CLAUDE.md IP 경계 — Solon 경로 하드코딩 검사 (setup-w0.sh 산출물 한정)"
if [ -f CLAUDE.md ] && grep -iE "solon|agent_architect|sfs-v0\.4" CLAUDE.md >/dev/null; then
  fail "CLAUDE.md 에 Solon 관련 경로/키워드 포함 — 제거 필요"
  grep -inE "solon|agent_architect|sfs-v0\.4" CLAUDE.md | sed 's/^/     /'
else
  ok "CLAUDE.md 에 Solon 언급 없음"
fi

# === 요약 ===
echo ""
echo "=== 결과 ==="
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
echo "  WARN: $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
  if [ $WARN -eq 0 ]; then
    echo "✅ W0 exit — 완전 통과. W1 진입 가능 (PHASE1-KICKOFF-CHECKLIST §3)."
    exit 0
  else
    echo "⚠  W0 exit — 조건부 통과 ($WARN WARN). Stack 결정 + placeholder 치환 후 재검증 권장."
    exit 0
  fi
else
  echo "❌ W0 exit 실패 ($FAIL FAIL). 문제 해결 후 재실행."
  exit 1
fi
