#!/bin/bash
# /commit 스킬 실행 시 migration 파일이 staged되어 있으면 ERD 자동 생성
# profile: standard, strict
PROFILE=$(cat "$CLAUDE_PROJECT_DIR/.claude/.hook-profile" 2>/dev/null || echo "minimal")
case "$PROFILE" in standard|strict) ;; *) exit 0 ;; esac
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# git commit 명령일 때만 동작
if ! echo "$COMMAND" | grep -qE '^git commit'; then
  exit 0
fi

# staged 파일 중 migration 파일이 있는지 확인
MIGRATION_FILES=$(git diff --cached --name-only -- 'greenribbon-service/src/migration/')
if [ -z "$MIGRATION_FILES" ]; then
  exit 0
fi

# ERD 생성 스크립트 실행
if python3 scripts/generate_erd.py 2>/dev/null; then
  # ERD 파일이 변경되었으면 staging에 추가
  if ! git diff --quiet docs/erd/erd-guide.md 2>/dev/null; then
    git add docs/erd/erd-guide.md
    cat <<EOF
{
  "additionalContext": "migration 파일 변경 감지 → ERD 자동 생성 완료. docs/erd/erd-guide.md가 커밋에 포함됩니다."
}
EOF
  fi
fi
exit 0
