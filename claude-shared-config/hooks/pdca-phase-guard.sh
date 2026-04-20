#!/bin/bash
# PDCA 단계 산출물 작성 후 사용자 확인을 강제하는 hook
# profile: strict only
PROFILE=$(cat "$CLAUDE_PROJECT_DIR/.claude/.hook-profile" 2>/dev/null || echo "minimal")
case "$PROFILE" in strict) ;; *) exit 0 ;; esac
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if echo "$FILE_PATH" | grep -qE 'docs/.+/[0-9]{8}/(plan|design|check|act)\.md$'; then
  PHASE=$(basename "$FILE_PATH" .md | tr '[:lower:]' '[:upper:]')
  cat <<EOF
{
  "additionalContext": "PDCA ${PHASE} 단계 산출물 작성 완료. 반드시 사용자에게 확인을 받은 후 다음 단계로 진행하세요. 사용자 확인 없이 다음 단계를 절대 시작하지 마세요."
}
EOF
fi
exit 0
