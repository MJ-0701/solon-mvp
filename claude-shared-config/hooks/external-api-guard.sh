#!/bin/bash
# 외부 API/인프라 연동 코드 감지 시 리뷰 리마인드
# profile: standard, strict
PROFILE=$(cat "$CLAUDE_PROJECT_DIR/.claude/.hook-profile" 2>/dev/null || echo "minimal")
case "$PROFILE" in standard|strict) ;; *) exit 0 ;; esac
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Java 파일만 대상
if ! echo "$FILE_PATH" | grep -qE '\.java$'; then
  exit 0
fi

# 파일 내용에서 외부 연동 패턴 감지
if [ -f "$FILE_PATH" ]; then
  PATTERNS='WebClient|RestTemplate|FeignClient|HttpClient|WebSocketClient|RedisTemplate|StringRedisTemplate|RedissonClient'
  if grep -qE "$PATTERNS" "$FILE_PATH"; then
    MATCHED=$(grep -oE "$PATTERNS" "$FILE_PATH" | sort -u | tr '\n' ', ' | sed 's/,$//')
    cat <<EOF
{
  "additionalContext": "외부 연동 코드 감지 (${MATCHED}). 이 코드에 대해 timeout/retry/fallback/circuit breaker/observability 검토가 필요합니다. /external-api-integration 스킬 기준으로 리뷰하세요."
}
EOF
  fi
fi
exit 0
