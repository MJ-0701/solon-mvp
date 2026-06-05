#!/usr/bin/env bash
# Solon Stop hook: suggestion-only self-improve hints. 파일 수정/commit/push 금지.
set -euo pipefail

changed="$(git status --short 2>/dev/null || true)"

if [ -z "${changed}" ]; then
  exit 0
fi

printf '%s\n' "[solon-stop-suggest] suggest-only: review changed files before ending."

# WU-0 evidence-at-risk: open sprint + passed review + uncommitted tree is the
# handoff-loss scenario. Surface it on session end. Read-only and best-effort —
# a missing/older runtime must never break the Stop hook.
if command -v sfs >/dev/null 2>&1; then
  ear_status="$(sfs status --compact 2>/dev/null || true)"
  case "${ear_status}" in
    *"evidence_at_risk="*)
      printf '%s\n' "- evidence-at-risk: open sprint passed review with an uncommitted tree — commit or run 'sfs retro --close' so the handoff is not lost."
      ;;
  esac
fi

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
