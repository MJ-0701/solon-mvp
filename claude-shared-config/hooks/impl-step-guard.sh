#!/bin/bash
# 구현 Step 완료 후 사용자 확인을 강제하는 hook
# gradle test 성공 시 다음 Step으로 넘어가기 전 확인 요청
# profile: strict only
PROFILE=$(cat "$CLAUDE_PROJECT_DIR/.claude/.hook-profile" 2>/dev/null || echo "minimal")
case "$PROFILE" in strict) ;; *) exit 0 ;; esac
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
RESPONSE=$(echo "$INPUT" | jq -r '.tool_response // empty')

# gradle test 명령인지 확인
if echo "$COMMAND" | grep -qE 'gradlew.*test'; then
  # 테스트 성공인지 확인
  if echo "$RESPONSE" | grep -q 'BUILD SUCCESSFUL'; then
    cat <<EOF
{
  "additionalContext": "테스트 통과(GREEN). 현재 구현 Step이 완료되었다면 반드시 사용자에게 확인을 받은 후 다음 Step으로 진행하세요. 사용자 확인 없이 다음 Step을 시작하지 마세요."
}
EOF
  fi
fi
exit 0
