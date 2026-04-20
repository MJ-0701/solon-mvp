#!/bin/bash
# 세션 종료 시 AgentShield 보안 스캔 자동 실행
if command -v ecc-agentshield >/dev/null 2>&1; then
  ecc-agentshield scan 2>/dev/null
fi
exit 0
