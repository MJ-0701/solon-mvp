#!/usr/bin/env bash
# .sfs-local/scripts/sfs-review.sh
#
# Solon SFS — `/sfs review` command implementation.
# CPO Evaluator review entrypoint. Review is mandatory in the sprint flow;
# the executor/tool is configurable to avoid CTO self-validation. `--run`
# requires a real CLI/plugin bridge; metadata alone is not treated as review.
# WU-25 §2 spec implementation. WU-23 §1.4 + V-1 conditions #1 (gate id SSoT
# = gates.md §1) + WU22-D5 (7-Gate enum) 정합:
#   · 파일 path stdout 출력만 (에디터 launch 안 함, V-1 conditions #4 정합).
#   · gate id 검증 = sfs-common.sh::validate_gate_id (WU-25 row 4 신설).
#   · `--gate <id>` 미지정 시 events.jsonl 마지막 review_open event 의
#     gate_id 추론 (sfs-common.sh::infer_last_gate_id, WU-25 row 4 신설).
#   · CPO Evaluator persona prompt 를 review.md 에 append.
#   · verdict 자체는 CPO agent output 으로 기록한다. 본 bash 명령은 prompt/evidence
#     scaffold + event 기록까지만 담당한다.
#
# Output (one line):
#   review.md ready: <path> | gate <gate-id> awaiting CPO verdict | executor <executor>
#   review.md ready: <path> | gate <gate-id> CPO run complete | executor <executor> | output <path>
#
# Exit codes (WU-25 §2.3 / gates.md §3 정합):
#   0  success
#   1  no .sfs-local/ 또는 활성 sprint 없음 (run /sfs start first)
#   2  events.jsonl / current-sprint 손상
#   3  not a git repo
#   4  sprint-templates/review.md 부재
#   5  permission denied
#   6  gate id invalid 또는 미지정 (--gate 누락 + 추론 실패) — gates.md §3 verbatim:
#      "unknown gate <id>, valid: G-1, G0, G1, G2, G3, G4, G5"
#   7  unknown CLI flag
#   9  executor bridge missing or executor failed
#   99 unknown (e.g. bash trap)
#
# Path note: dev staging file lives at
#   solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-review.sh
# install.sh copies templates/.sfs-local-template/ → consumer project's .sfs-local/.
# WU-25 §2 spec used `.sfs-local/scripts/` as a shorthand for the consumer-side path.
#
# Visibility: business-only (solon-mvp-dist staging asset).
# Created: 2026-04-28 (24th cycle 49번째 scheduled run `amazing-determined-gates`,
#                      mode=user-active-deferred, WU-25 §5 row 3).

set -euo pipefail

# Source common helpers
SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

# ─────────────────────────────────────────────────────────────────────
# Local exit-code fallbacks (WU-25 §2.3 — sfs-common.sh 미정의 시 default).
# 후속 sfs-common.sh 보강에서 SFS_EXIT_GATE / SFS_EXIT_BADCLI 정식 정의 시
# `:=` 가 fallback 으로만 작동하므로 충돌 X.
# ─────────────────────────────────────────────────────────────────────
: "${SFS_EXIT_GATE:=6}"
: "${SFS_EXIT_BADCLI:=7}"
: "${SFS_EXIT_EXECUTOR:=9}"

if ! load_sfs_auth_env; then
  echo "executor auth env load failed: ${SFS_AUTH_ENV_FILE:-${SFS_LOCAL_DIR}/auth.env}" >&2
  exit "${SFS_EXIT_EXECUTOR}"
fi

# ─────────────────────────────────────────────────────────────────────
# USAGE
# ─────────────────────────────────────────────────────────────────────
usage_review() {
  cat <<'EOF'
Usage: /sfs review [--gate <id>] [--executor <profile|cmd>] [--generator <profile|cmd>] [--persona <path>] [--print-prompt] [--run] [--auth-interactive]

Open the active sprint's review.md as the CPO Evaluator review document.
  - --gate <id>   gate id (one of: G-1, G0, G1, G2, G3, G4, G5).
                  If omitted, inferred from the most recent `review_open`
                  event in events.jsonl. If inference fails, exit 6.
  - --executor <profile|cmd>
                  CPO review tool/profile. Default: $SFS_REVIEW_EXECUTOR or codex.
                  Typical: codex, gemini, claude, or a custom command.
  - --generator <profile|cmd>
                  CTO implementation tool/profile, for self-validation tracking.
  - --persona <path>
                  CPO persona path. Default: .sfs-local/personas/cpo-evaluator.md.
  - --print-prompt
                  Print the generated CPO review prompt to stdout after updating review.md.
  - --run
                  Execute the CPO evaluator through a real bridge.
                  Named profiles:
                    codex        $SFS_REVIEW_CODEX_CMD, else `codex exec --full-auto`
                    codex-plugin $SFS_REVIEW_CODEX_PLUGIN_CMD only (Claude in-process plugins are not shell-callable)
                    gemini       $SFS_REVIEW_GEMINI_CMD, else `gemini --skip-trust --output-format text -p "Read stdin and perform the requested CPO review."`
                    claude       $SFS_REVIEW_CLAUDE_CMD, else `claude -p --dangerously-skip-permissions`
                    claude-plugin unsupported; Codex is not a Claude plugin host
                  Custom executor strings are passed through as shell commands and receive the prompt on stdin.
  - --auth-interactive
                  If a named executor is missing headless auth, allow its CLI login/browser
                  flow before running review. Requires a real terminal. Default is fail-closed.
  - Creates review.md from sprint-templates/review.md if missing.
  - Updates frontmatter: phase=review, gate_id=<id>, evaluator_role=CPO,
    evaluator_executor=<executor>, generator_executor=<generator>, last_touched_at=<ISO8601>.
  - Appends a CPO Evaluator invocation prompt to review.md.
  - Appends events.jsonl `review_open` event.
  - Prints the resolved review.md path + gate id + executor to stdout (no editor launch).

Exit codes:
  0  success
  1  no .sfs-local/ or no active sprint (run /sfs start first)
  2  events.jsonl / current-sprint corrupt
  3  not a git repo
  4  sprint-templates/review.md missing
  5  permission denied
  6  gate id invalid or required (--gate missing + inference failed)
  7  unknown CLI flag
  9  executor bridge missing or executor failed
  99 unknown (CLI args, etc.)
EOF
}

# ─────────────────────────────────────────────────────────────────────
# CLI parse (--gate <id> | --gate=<id> | -h | --help)
# ─────────────────────────────────────────────────────────────────────
GATE_ID=""
EVALUATOR_EXECUTOR="${SFS_REVIEW_EXECUTOR:-codex}"
GENERATOR_EXECUTOR="${SFS_GENERATOR_EXECUTOR:-unknown}"
PERSONA_PATH="${SFS_LOCAL_DIR}/personas/cpo-evaluator.md"
PRINT_PROMPT=false
RUN_REVIEW=false
AUTH_INTERACTIVE="${SFS_AUTH_INTERACTIVE:-false}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage_review
      exit "${SFS_EXIT_OK}"
      ;;
    --gate)
      if [[ $# -lt 2 ]]; then
        echo "--gate requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      GATE_ID="$2"
      shift 2
      ;;
    --gate=*)
      GATE_ID="${1#--gate=}"
      shift
      ;;
    --executor)
      if [[ $# -lt 2 ]]; then
        echo "--executor requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      EVALUATOR_EXECUTOR="$2"
      shift 2
      ;;
    --executor=*)
      EVALUATOR_EXECUTOR="${1#--executor=}"
      shift
      ;;
    --generator)
      if [[ $# -lt 2 ]]; then
        echo "--generator requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      GENERATOR_EXECUTOR="$2"
      shift 2
      ;;
    --generator=*)
      GENERATOR_EXECUTOR="${1#--generator=}"
      shift
      ;;
    --persona)
      if [[ $# -lt 2 ]]; then
        echo "--persona requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      PERSONA_PATH="$2"
      shift 2
      ;;
    --persona=*)
      PERSONA_PATH="${1#--persona=}"
      shift
      ;;
    --print-prompt)
      PRINT_PROMPT=true
      shift
      ;;
    --run)
      RUN_REVIEW=true
      shift
      ;;
    --auth-interactive)
      AUTH_INTERACTIVE=true
      shift
      ;;
    --)
      shift
      if [[ $# -gt 0 ]]; then
        echo "unexpected extra args after --: $*" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      ;;
    -*)
      echo "unknown flag: $1" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
  esac
done
case "${AUTH_INTERACTIVE}" in
  true|1|yes|YES|y|Y) AUTH_INTERACTIVE=true ;;
  *) AUTH_INTERACTIVE=false ;;
esac

# ─────────────────────────────────────────────────────────────────────
# Validate .sfs-local + git
# ─────────────────────────────────────────────────────────────────────
set +e
validate_sfs_local
_validate_rc=$?
set -e
if [[ "${_validate_rc}" -ne 0 ]]; then
  # validate_sfs_local emits its own stderr.
  exit "${_validate_rc}"
fi

# ─────────────────────────────────────────────────────────────────────
# Resolve active sprint
# ─────────────────────────────────────────────────────────────────────
SPRINT_ID="$(read_current_sprint)"
if [[ -z "${SPRINT_ID}" ]]; then
  echo "no active sprint, run /sfs start first" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

# ─────────────────────────────────────────────────────────────────────
# Resolve gate id (either --gate <id> or infer from events.jsonl)
# ─────────────────────────────────────────────────────────────────────
if [[ -z "${GATE_ID}" ]]; then
  GATE_ID="$(infer_last_gate_id)"
fi
if [[ -z "${GATE_ID}" ]]; then
  echo "gate id required: --gate <id>, valid: G-1, G0, G1, G2, G3, G4, G5" >&2
  exit "${SFS_EXIT_GATE}"
fi
if ! validate_gate_id "${GATE_ID}"; then
  echo "unknown gate ${GATE_ID}, valid: G-1, G0, G1, G2, G3, G4, G5" >&2
  exit "${SFS_EXIT_GATE}"
fi

SPRINT_DIR="${SFS_SPRINTS_DIR}/${SPRINT_ID}"
REVIEW_PATH="${SPRINT_DIR}/review.md"
TEMPLATE="${SFS_LOCAL_DIR}/sprint-templates/review.md"

# ─────────────────────────────────────────────────────────────────────
# Ensure review.md exists (copy from template if missing)
# ─────────────────────────────────────────────────────────────────────
if [[ ! -f "${REVIEW_PATH}" ]]; then
  if [[ ! -f "${TEMPLATE}" ]]; then
    echo "template missing: ${TEMPLATE}" >&2
    exit "${SFS_EXIT_NO_TEMPLATES}"
  fi
  if ! mkdir -p "${SPRINT_DIR}" 2>/dev/null; then
    echo "permission denied creating ${SPRINT_DIR}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
  if ! cp -f "${TEMPLATE}" "${REVIEW_PATH}" 2>/dev/null; then
    echo "permission denied copying template to ${REVIEW_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# Update frontmatter (phase + gate_id + last_touched_at)
# ─────────────────────────────────────────────────────────────────────
NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"

if ! update_frontmatter "${REVIEW_PATH}" "phase" "review" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "gate_id" "${GATE_ID}" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "evaluator_role" "CPO" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "evaluator_persona" "\"${PERSONA_PATH//\"/\\\"}\"" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "evaluator_executor" "\"${EVALUATOR_EXECUTOR//\"/\\\"}\"" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "generator_executor" "\"${GENERATOR_EXECUTOR//\"/\\\"}\"" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! update_frontmatter "${REVIEW_PATH}" "last_touched_at" "${NOW}" 2>/dev/null; then
  echo "permission denied updating frontmatter in ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi

render_cpo_prompt() {
  local persona_note
  if [[ -f "${PERSONA_PATH}" ]]; then
    persona_note="Use persona file: ${PERSONA_PATH}"
  else
    persona_note="Persona file missing: ${PERSONA_PATH}. Use built-in CPO Evaluator policy from review.md."
  fi
  cat <<EOF
You are the Solon CPO Evaluator.

${persona_note}

Review gate: ${GATE_ID}
Sprint: ${SPRINT_ID}
Generator executor/tool: ${GENERATOR_EXECUTOR}
Evaluator executor/tool: ${EVALUATOR_EXECUTOR}

Self-validation policy:
- Do not rubber-stamp CTO Generator output.
- If this review is running in the same tool/session that generated the implementation, explicitly call that out as a risk.
- Prefer independent review evidence from Codex/Gemini/another agent instance when implementation was produced by Claude.

Read these files before verdict:
- .sfs-local/sprints/${SPRINT_ID}/brainstorm.md
- .sfs-local/sprints/${SPRINT_ID}/plan.md
- .sfs-local/sprints/${SPRINT_ID}/log.md
- .sfs-local/sprints/${SPRINT_ID}/review.md
- git status / git diff / relevant tests

Return exactly this shape:
Verdict: pass | partial | fail
Evidence checked:
- ...
Findings:
- ...
Required CTO actions:
- ...
Final recommendation:
- ...
EOF
}

resolve_review_executor_cmd() {
  case "${EVALUATOR_EXECUTOR}" in
    codex|codex-cli)
      if [[ -n "${SFS_REVIEW_CODEX_CMD:-}" ]]; then
        printf '%s\n' "${SFS_REVIEW_CODEX_CMD}"
      elif command -v codex >/dev/null 2>&1; then
        prepare_executor_auth "codex" "${AUTH_INTERACTIVE}" || return "${SFS_EXIT_EXECUTOR}"
        printf '%s\n' "codex exec --full-auto"
      else
        echo "executor bridge missing: codex CLI not found and SFS_REVIEW_CODEX_CMD unset" >&2
        return "${SFS_EXIT_EXECUTOR}"
      fi
      ;;
    codex-plugin)
      if [[ -n "${SFS_REVIEW_CODEX_PLUGIN_CMD:-}" ]]; then
        printf '%s\n' "${SFS_REVIEW_CODEX_PLUGIN_CMD}"
      else
        echo "executor bridge missing: codex-plugin is a Claude runtime plugin, not shell-callable; set SFS_REVIEW_CODEX_PLUGIN_CMD or run --print-prompt and invoke the plugin from Claude" >&2
        return "${SFS_EXIT_EXECUTOR}"
      fi
      ;;
    gemini)
      if [[ -n "${SFS_REVIEW_GEMINI_CMD:-}" ]]; then
        printf '%s\n' "${SFS_REVIEW_GEMINI_CMD}"
      elif command -v gemini >/dev/null 2>&1; then
        prepare_executor_auth "gemini" "${AUTH_INTERACTIVE}" || return "${SFS_EXIT_EXECUTOR}"
        printf '%s\n' 'gemini --skip-trust --output-format text -p "Read stdin and perform the requested CPO review."'
      else
        echo "executor bridge missing: gemini CLI not found and SFS_REVIEW_GEMINI_CMD unset" >&2
        return "${SFS_EXIT_EXECUTOR}"
      fi
      ;;
    claude)
      if [[ -n "${SFS_REVIEW_CLAUDE_CMD:-}" ]]; then
        printf '%s\n' "${SFS_REVIEW_CLAUDE_CMD}"
      elif command -v claude >/dev/null 2>&1; then
        prepare_executor_auth "claude" "${AUTH_INTERACTIVE}" || return "${SFS_EXIT_EXECUTOR}"
        printf '%s\n' "claude -p --dangerously-skip-permissions"
      else
        echo "executor bridge missing: claude CLI not found and SFS_REVIEW_CLAUDE_CMD unset" >&2
        return "${SFS_EXIT_EXECUTOR}"
      fi
      ;;
    claude-plugin)
      echo "executor bridge unsupported: Codex is not a Claude plugin host; use --executor claude with Claude CLI, set SFS_REVIEW_CLAUDE_CMD, or run --print-prompt and paste into Claude" >&2
      return "${SFS_EXIT_EXECUTOR}"
      ;;
    *)
      printf '%s\n' "${EVALUATOR_EXECUTOR}"
      ;;
  esac
}

if [[ -n "${EVALUATOR_EXECUTOR}" && -n "${GENERATOR_EXECUTOR}" && "${EVALUATOR_EXECUTOR}" == "${GENERATOR_EXECUTOR}" ]]; then
  echo "warning: evaluator executor equals generator executor (${EVALUATOR_EXECUTOR}); self-validation risk" >&2
fi

PROMPT_DIR="${SFS_LOCAL_DIR}/tmp/review-prompts"
RUN_DIR="${SFS_LOCAL_DIR}/tmp/review-runs"
PROMPT_TS="$(date -u +%Y%m%dT%H%M%SZ)"
PROMPT_PATH="${PROMPT_DIR}/${SPRINT_ID}-${GATE_ID}-${PROMPT_TS}.txt"

if ! mkdir -p "${PROMPT_DIR}" "${RUN_DIR}" 2>/dev/null; then
  echo "permission denied creating ${PROMPT_DIR} / ${RUN_DIR}" >&2
  exit "${SFS_EXIT_PERM}"
fi
if ! render_cpo_prompt > "${PROMPT_PATH}" 2>/dev/null; then
  echo "permission denied writing CPO prompt to ${PROMPT_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
fi

{
  printf '\n### %s — CPO evaluator invocation (%s)\n\n' "${NOW}" "${GATE_ID}"
  printf -- '- evaluator_role: CPO\n'
  printf -- '- evaluator_persona: `%s`\n' "${PERSONA_PATH}"
  printf -- '- evaluator_executor: `%s`\n' "${EVALUATOR_EXECUTOR}"
  printf -- '- generator_executor: `%s`\n' "${GENERATOR_EXECUTOR}"
  printf -- '- prompt_path: `%s`\n' "${PROMPT_PATH}"
  if [[ "${RUN_REVIEW}" == "true" ]]; then
    printf -- '- run_requested: true\n'
  else
    printf -- '- run_requested: false\n'
  fi
  if [[ "${AUTH_INTERACTIVE}" == "true" || "${AUTH_INTERACTIVE}" == "1" || "${AUTH_INTERACTIVE}" == "yes" ]]; then
    printf -- '- auth_interactive: true\n'
  else
    printf -- '- auth_interactive: false\n'
  fi
  printf -- '- self_validation_policy: CTO Generator output must be checked by CPO Evaluator; independent tool/instance recommended.\n\n'
  printf '```text\n'
  cat "${PROMPT_PATH}"
  printf '\n```\n'
} >> "${REVIEW_PATH}" || {
  echo "permission denied appending CPO prompt to ${REVIEW_PATH}" >&2
  exit "${SFS_EXIT_PERM}"
}

RUN_OUT=""
RUN_ERR=""
RUN_RC=""
if [[ "${RUN_REVIEW}" == "true" ]]; then
  set +e
  EXECUTOR_CMD="$(resolve_review_executor_cmd)"
  _resolve_rc=$?
  set -e
  if [[ "${_resolve_rc}" -ne 0 ]] || [[ -z "${EXECUTOR_CMD:-}" ]]; then
    {
      printf '\n### %s — CPO evaluator run failed before start\n\n' "${NOW}"
      printf -- '- executor: `%s`\n' "${EVALUATOR_EXECUTOR}"
      printf -- '- prompt_path: `%s`\n' "${PROMPT_PATH}"
      printf -- '- reason: executor bridge missing\n'
    } >> "${REVIEW_PATH}" || true
    exit "${SFS_EXIT_EXECUTOR}"
  fi

  RUN_OUT="${RUN_DIR}/${SPRINT_ID}-${GATE_ID}-${PROMPT_TS}.stdout.md"
  RUN_ERR="${RUN_DIR}/${SPRINT_ID}-${GATE_ID}-${PROMPT_TS}.stderr.txt"
  set +e
  eval "${EXECUTOR_CMD}" < "${PROMPT_PATH}" > "${RUN_OUT}" 2> "${RUN_ERR}"
  RUN_RC=$?
  set -e

  {
    printf '\n### %s — CPO evaluator result (%s)\n\n' "${NOW}" "${GATE_ID}"
    printf -- '- executor: `%s`\n' "${EVALUATOR_EXECUTOR}"
    printf -- '- executor_cmd: `%s`\n' "${EXECUTOR_CMD}"
    printf -- '- exit_code: `%s`\n' "${RUN_RC}"
    printf -- '- stdout_path: `%s`\n' "${RUN_OUT}"
    printf -- '- stderr_path: `%s`\n\n' "${RUN_ERR}"
    printf '```text\n'
    cat "${RUN_OUT}" 2>/dev/null || true
    printf '\n```\n'
    if [[ -s "${RUN_ERR}" ]]; then
      printf '\n#### stderr\n\n```text\n'
      cat "${RUN_ERR}" 2>/dev/null || true
      printf '\n```\n'
    fi
  } >> "${REVIEW_PATH}" || {
    echo "permission denied appending CPO result to ${REVIEW_PATH}" >&2
    exit "${SFS_EXIT_PERM}"
  }

  if [[ "${RUN_RC}" -ne 0 ]]; then
    echo "executor failed: ${EVALUATOR_EXECUTOR} (exit ${RUN_RC}); see ${RUN_ERR}" >&2
    exit "${SFS_EXIT_EXECUTOR}"
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# Append review_open event (ts auto-injected by append_event)
# ─────────────────────────────────────────────────────────────────────
# JSON-escape sprint-id, gate_id, path (defensive — sprint-id and gate_id were
# already validated, but path may include characters that escape).
_esc_sprint="${SPRINT_ID//\\/\\\\}"
_esc_sprint="${_esc_sprint//\"/\\\"}"
_esc_gate="${GATE_ID//\\/\\\\}"
_esc_gate="${_esc_gate//\"/\\\"}"
_esc_path="${REVIEW_PATH//\\/\\\\}"
_esc_path="${_esc_path//\"/\\\"}"
_esc_prompt="${PROMPT_PATH//\\/\\\\}"
_esc_prompt="${_esc_prompt//\"/\\\"}"
_esc_eval="${EVALUATOR_EXECUTOR//\\/\\\\}"
_esc_eval="${_esc_eval//\"/\\\"}"
_esc_gen="${GENERATOR_EXECUTOR//\\/\\\\}"
_esc_gen="${_esc_gen//\"/\\\"}"
_esc_persona="${PERSONA_PATH//\\/\\\\}"
_esc_persona="${_esc_persona//\"/\\\"}"

if ! append_event "review_open" \
  "{\"sprint_id\":\"${_esc_sprint}\",\"gate_id\":\"${_esc_gate}\",\"path\":\"${_esc_path}\",\"prompt_path\":\"${_esc_prompt}\",\"evaluator_role\":\"CPO\",\"evaluator_executor\":\"${_esc_eval}\",\"generator_executor\":\"${_esc_gen}\",\"persona\":\"${_esc_persona}\",\"run_requested\":${RUN_REVIEW},\"auth_interactive\":${AUTH_INTERACTIVE}}" \
  2>/dev/null; then
  echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
  exit "${SFS_EXIT_PERM}"
fi

if [[ "${RUN_REVIEW}" == "true" ]]; then
  _esc_out="${RUN_OUT//\\/\\\\}"
  _esc_out="${_esc_out//\"/\\\"}"
  _esc_rc="${RUN_RC:-0}"
  if ! append_event "review_run" \
    "{\"sprint_id\":\"${_esc_sprint}\",\"gate_id\":\"${_esc_gate}\",\"path\":\"${_esc_path}\",\"output_path\":\"${_esc_out}\",\"evaluator_role\":\"CPO\",\"evaluator_executor\":\"${_esc_eval}\",\"generator_executor\":\"${_esc_gen}\",\"exit_code\":${_esc_rc}}" \
    2>/dev/null; then
    echo "permission denied appending event to ${SFS_EVENTS_FILE}" >&2
    exit "${SFS_EXIT_PERM}"
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# Stdout (V-1 conditions #4 / WU-25 §2.1 — path + gate id, no editor launch)
# ─────────────────────────────────────────────────────────────────────
if [[ "${PRINT_PROMPT}" == "true" ]]; then
  cat "${PROMPT_PATH}"
elif [[ "${RUN_REVIEW}" == "true" ]]; then
  echo "review.md ready: ${REVIEW_PATH} | gate ${GATE_ID} CPO run complete | executor ${EVALUATOR_EXECUTOR} | output ${RUN_OUT}"
else
  echo "review.md ready: ${REVIEW_PATH} | gate ${GATE_ID} awaiting CPO verdict | executor ${EVALUATOR_EXECUTOR}"
fi

exit "${SFS_EXIT_OK}"
# End of sfs-review.sh
