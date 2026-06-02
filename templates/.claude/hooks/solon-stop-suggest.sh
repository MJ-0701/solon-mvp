#!/usr/bin/env bash
# Solon Stop hook: suggestion-only self-improve hints. 파일 수정/commit/push 금지.
set -euo pipefail

changed="$(git status --short 2>/dev/null || true)"

if [ -z "${changed}" ]; then
  exit 0
fi

printf '%s\n' "[solon-stop-suggest] suggest-only: review changed files before ending."

case "${changed}" in
  *"SFS.md"*|*".sfs-local/context"*|*"docs/solon/"*|*"llm-wiki/"*)
    printf '%s\n' "- Consider running: sfs context cat kernel && sfs review --gate 6"
    ;;
esac

case "${changed}" in
  *".claude/"*|*".agents/skills/"*|*".gemini/"*)
    printf '%s\n' "- Adapter/skill surface changed: consider sfs agent doctor --fix or a focused adapter test."
    ;;
esac

printf '%s\n' "- This hook is suggest-only; it does not edit files, stage, commit, push, or run destructive commands."
