#!/usr/bin/env bash
# .sfs-local/scripts/sfs-retro.sh
#
# Solon SFS — `/sfs retro` command implementation.
# WU-26 §2 spec implementation. WU-23 §1.6 정합:
#   · 파일 path stdout 출력만 (에디터 launch 안 함).
#   · 기본 `retro` 는 docs/solon/<english-workspace>/<yyyyMMdd> handoff report.md ensure + Gate 6 review evidence + retro를 daily handoff 에 최종 반영 (manager HTML, sfs-publish-daily-handoff.sh) + workbench archive + sprint close + auto commit + stdout 4줄.
#   · `--close` 는 backward-compatible alias.
#   · `--draft` / `--no-close` 지정 시 retro.md 진입만 (daily handoff 미발행), stdout 1줄.
#   · auto commit (sfs-common.sh::auto_commit_close) 은 사용자 명시 retro 호출 시에만 동작 (§1.5' 정합).
#
# Output (1~4 lines):
#   retro.md ready: <path>
#   report.md ready: <path>      # default close 시 추가
#   sprint closed: <sprint-id>     # default close 시 추가
#   daily handoff ready: <path>    # default close 시 추가 (manager HTML)
#
# Exit codes (WU-26 §2.3 / WU-23 §1.6 정합):
#   0  success
#   1  no .sfs-local/ or no active sprint
#   4  sprint-templates/retro.md 부재
#   7  unknown CLI flag
#   8  close 인데 review.md 미작성
#   99 unknown (e.g. bash trap)
#
# Path note: dev staging file lives at
#   templates/.sfs-local-template/scripts/sfs-retro.sh
# install.sh copies templates/.sfs-local-template/ → consumer project's .sfs-local/.
# WU-26 §2 spec used `.sfs-local/scripts/` as a shorthand for the consumer-side path.
#
# Visibility: distribution template.
# Created: 2026-04-29 (25th-4 user-active conversation, WU-26 §5 row 3 by exciting-festive-cori).

set -euo pipefail

# Local exit-code fallback (sfs-common.sh has SFS_EXIT_*; we add row-3-local pattern
# matching WU-25 row 3 sfs-review.sh / WU-26 row 2 sfs-decision.sh style for forward compat).
: "${SFS_EXIT_BADCLI:=7}"
: "${SFS_EXIT_REVIEW_REQUIRED:=8}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SCRIPT_DIR}/sfs-common.sh"

# ─────────────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────────────
CLOSE=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --close)
      CLOSE=1
      shift
      ;;
    --draft|--no-close)
      CLOSE=0
      shift
      ;;
    -h|--help)
      cat <<EOF
Usage: /sfs retro [--draft|--no-close|--close]

Close the current sprint: open/create docs/solon/<english-workspace>/<yyyyMMdd>/retro.md,
ensure the matching report.md exists, publish the manager-facing daily handoff
(daily-handoff.md + daily-handoff.html via scripts/sfs-publish-daily-handoff.sh),
archive workbench evidence, mark the sprint closed, and commit the result.
Daily handoff publication failure aborts the close (it is never silently
skipped); the publisher's nonzero exit code propagates.
The AI runtime owns branch push/main merge/main push after this local close commit.

Options:
  --draft,
  --no-close    Open/create retro.md only. Does not ensure report.md, publish
                the daily handoff, archive, close the sprint, or auto-commit.
  --close       Backward-compatible alias for the default close behavior
                (includes the automatic daily handoff publication).
  -h, --help    Show this help.

Exit codes:
  0  ok
  1  no .sfs-local/ or no active sprint
  4  sprint-templates/retro.md missing
  7  unknown CLI flag
  8  close requested but review.md missing (run /sfs review first)
  99 unknown (bash trap)
  (daily handoff publish failure exits with the publisher's nonzero code)
EOF
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "unknown arg: $1" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
    *)
      echo "unknown arg: $1 (retro takes no positional args; did you mean /sfs decision?)" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
  esac
done

# ─────────────────────────────────────────────────────────────────────
# Pre-flight
# ─────────────────────────────────────────────────────────────────────
# validate_sfs_local emits stderr + returns 1/2/3; we collapse 2/3 into 1
# (no init / corrupt events / no git all imply "no active sprint").
set +e
validate_sfs_local
RC=$?
set -e
if [[ "${RC}" -ne 0 ]]; then
  exit "${SFS_EXIT_NO_INIT}"
fi

SPRINT_ID="$(read_current_sprint)"
if [[ -z "${SPRINT_ID}" ]]; then
  echo "no active sprint, run /sfs start first" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

SPRINT_DIR="${SFS_SPRINTS_DIR}/${SPRINT_ID}"

# ─────────────────────────────────────────────────────────────────────
# (a) shared retro.md ensure + frontmatter 갱신 + retro_open event
# ─────────────────────────────────────────────────────────────────────
NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"
set +e
RETRO_PATH="$(sfs_prepare_sprint_retro "${SPRINT_ID}" "${NOW}")"
_retro_prepare_rc=$?
set -e
if [[ "${_retro_prepare_rc}" -ne 0 ]]; then
  exit "${_retro_prepare_rc}"
fi

# WU-26 §2: append_event TYPE PAYLOAD 2-arg signature (sfs-decision.sh / sfs-plan.sh 패턴 정합).
append_event "retro_open" "{\"sprint_id\":\"${SPRINT_ID}\",\"path\":\"${RETRO_PATH}\"}"

echo "retro.md ready: ${RETRO_PATH}"

# ─────────────────────────────────────────────────────────────────────
# (b) close 분기 (default). --draft / --no-close keeps retro open-only.
# ─────────────────────────────────────────────────────────────────────
if [[ "${CLOSE}" -eq 1 ]]; then
  # WU-26 §2.3 + smoke fix: events.jsonl 의 review_open event 가 sprint_id 매치로 있어야 close 가능.
  # file 기반 검사 (review.md 존재) 는 sfs-start.sh 가 4 templates 모두 미리 cp 하므로 의미 없음 →
  # events 기반 검사로 변경 ("review 를 한번이라도 open 해야 close 가능" 의도 정합).
  if [[ ! -f "${SFS_EVENTS_FILE}" ]] \
     || ! grep -F '"type":"review_open"' "${SFS_EVENTS_FILE}" 2>/dev/null \
        | grep -F "\"sprint_id\":\"${SPRINT_ID}\"" >/dev/null 2>&1; then
    echo "review.md required before close (run /sfs review first)" >&2
    exit "${SFS_EXIT_REVIEW_REQUIRED}"
  fi

  # Completed sprint artifact lifecycle:
  # report.md becomes the final work artifact; workbench docs move to archive.
  REPORT_PATH="$(sfs_prepare_sprint_report "${SPRINT_ID}" "${NOW}" "final")"
  # WU-36: surface cycle-end division activation recommendations inside report/retro.
  sfs_write_cycle_end_division_recommendations "${SPRINT_ID}" "${NOW}" "${REPORT_PATH}" "${RETRO_PATH}" || true
  # Active Obsidian/wiki projects close with a deterministic compile checklist:
  # report/retro keep sprint evidence, llm-wiki receives only durable meaning.
  sfs_write_wiki_compile_checklist "${SPRINT_ID}" "${NOW}" "${REPORT_PATH}" "${RETRO_PATH}" || true

  # Gate 7 publication finalizes the same handoff refreshed at Gate 6. It runs
  # after report, review, and retro records contain available evidence, and before any
  # workbench/event compaction can remove the source material. A failed
  # publisher leaves the sprint active and propagates its nonzero exit code.
  HANDOFF_DIR="$(dirname "${REPORT_PATH}")"
  HANDOFF_MD="${HANDOFF_DIR}/daily-handoff.md"
  HANDOFF_HTML="${HANDOFF_DIR}/daily-handoff.html"
  REVIEW_PATH="${SPRINT_DIR}/review.md"
  PUBLISHER="${SCRIPT_DIR}/sfs-publish-daily-handoff.sh"
  if [[ ! -x "${PUBLISHER}" ]]; then
    echo "daily handoff publisher missing or not executable: ${PUBLISHER}" >&2
    exit "${SFS_EXIT_NO_TEMPLATES}"
  fi
  PUBLISH_ARGS=(--report "${REPORT_PATH}")
  # Legacy sprints may have valid report + retro evidence without a persisted
  # review.md. Do not invent a source path; Gate 6 passes review evidence when
  # it actually exists.
  if [[ -f "${REVIEW_PATH}" ]]; then
    PUBLISH_ARGS+=(--review "${REVIEW_PATH}")
  fi
  PUBLISH_ARGS+=(--retro "${RETRO_PATH}" --sprint "${SPRINT_ID}" --out-dir "${HANDOFF_DIR}")
  set +e
  PUBLISH_OUTPUT="$("${PUBLISHER}" "${PUBLISH_ARGS[@]+"${PUBLISH_ARGS[@]}"}")"
  _handoff_publish_rc=$?
  set -e
  if [[ "${_handoff_publish_rc}" -ne 0 ]]; then
    [[ -z "${PUBLISH_OUTPUT}" ]] || printf '%s\n' "${PUBLISH_OUTPUT}" >&2
    echo "daily handoff publication failed; sprint remains open" >&2
    exit "${_handoff_publish_rc}"
  fi
  if [[ ! -f "${HANDOFF_MD}" || ! -f "${HANDOFF_HTML}" ]]; then
    echo "daily handoff publication failed; expected both ${HANDOFF_MD} and ${HANDOFF_HTML}" >&2
    exit "${SFS_EXIT_UNKNOWN}"
  fi

  # Only publication success allows close metadata and source compaction.
  update_frontmatter "${RETRO_PATH}" "closed_at" "${NOW}"
  sprint_close "${SPRINT_DIR}" "${NOW}"

  # report_ready + sprint_close events (2-arg signature)
  append_event "report_ready" "{\"sprint_id\":\"${SPRINT_ID}\",\"path\":\"${REPORT_PATH}\"}"
  append_event "sprint_close" "{\"sprint_id\":\"${SPRINT_ID}\"}"
  sfs_preserve_event_excerpt_from_file "${SPRINT_ID}" "${SFS_EVENTS_FILE}" "retro close before active-ledger prune" \
    || exit "${SFS_EXIT_PERM}"
  sfs_compact_sprint_workbench "${SPRINT_ID}" "${NOW}"

  # current-sprint 클리어 + active ledger prune after durable event preservation.
  rm -f "${SFS_CURRENT_SPRINT_FILE}" || exit "${SFS_EXIT_PERM}"
  sfs_prune_sprint_event_lines "${SPRINT_ID}" || exit "${SFS_EXIT_PERM}"

  # auto commit. Branch push/main merge/main push belong to the AI runtime Git Flow lifecycle.
  auto_commit_close "${SPRINT_ID}"

  echo "report.md ready: ${REPORT_PATH}"
  echo "sprint closed: ${SPRINT_ID}"
  echo "daily handoff ready: ${HANDOFF_HTML}"
fi

exit 0
