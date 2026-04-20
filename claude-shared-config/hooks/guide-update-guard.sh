#!/bin/bash
# git commit 완료 후 PDCA 문서(plan/design/check/act) 변경 감지 시
# 해당 도메인의 guide.md 갱신을 Claude에게 지시하는 hook
# profile: standard, strict
PROFILE=$(cat "$CLAUDE_PROJECT_DIR/.claude/.hook-profile" 2>/dev/null || echo "minimal")
case "$PROFILE" in standard|strict) ;; *) exit 0 ;; esac
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
RESPONSE=$(echo "$INPUT" | jq -r '.tool_response // empty')

# git commit 명령일 때만 동작
if ! echo "$COMMAND" | grep -qE '^git commit'; then
  exit 0
fi

# 커밋 실패 시 무시
if echo "$RESPONSE" | grep -qE 'nothing to commit|no changes added|aborting commit'; then
  exit 0
fi

# 직전 커밋에서 변경된 PDCA 파일 확인
PDCA_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD -- 'docs/' | grep -E '/(plan|design|check|act)\.md$')
if [ -z "$PDCA_FILES" ]; then
  exit 0
fi

# 변경된 도메인과 guide 파일 매핑
DOMAINS=""
GUIDE_FILES=""
for f in $PDCA_FILES; do
  # docs/{domain}/{date}/{pdca}.md → domain 추출
  DOMAIN=$(echo "$f" | awk -F'/' '{print $2}')
  GUIDE="docs/${DOMAIN}/${DOMAIN}-guide.md"

  if [ -f "$GUIDE" ] && ! echo "$GUIDE_FILES" | grep -q "$GUIDE"; then
    DOMAINS="${DOMAINS}${DOMAIN}, "
    GUIDE_FILES="${GUIDE_FILES}${GUIDE} "
  fi
done

if [ -z "$GUIDE_FILES" ]; then
  exit 0
fi

# 도메인 목록 정리 (trailing comma 제거)
DOMAINS=$(echo "$DOMAINS" | sed 's/, $//')

cat <<EOF
{
  "additionalContext": "PDCA 문서 변경 감지 (${DOMAINS}). 다음 절차를 수행하세요:\n1. 변경된 PDCA 문서를 읽으세요: ${PDCA_FILES}\n2. 해당 도메인의 가이드 문서를 읽으세요: ${GUIDE_FILES}\n3. PDCA 문서 내용을 반영하여 가이드 문서를 갱신하세요 (수정 이력 추가 + 본문 업데이트). 가이드 문서는 비개발자(영업, 기획, 운영) 대상이므로 기술 용어를 피하고 정책/절차 관점으로 작성하세요.\n4. 갱신된 가이드 문서를 사용자에게 보여주고 확인을 받으세요.\n5. 승인 시 가이드 문서만 별도 커밋하세요 (메시지: docs: {domain} 가이드 문서 갱신).\n6. 커밋 후 git push하세요. PR body 갱신은 불필요합니다."
}
EOF
exit 0
