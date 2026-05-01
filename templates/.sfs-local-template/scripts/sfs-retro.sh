#!/usr/bin/env bash
# .sfs-local/scripts/sfs-retro.sh
#
# Solon SFS — `/sfs retro [--close]` command implementation.
# WU-26 §2 spec implementation. WU-23 §1.6 정합:
#   · 파일 path stdout 출력만 (에디터 launch 안 함).
#   · `--close` 미지정 시 retro.md 진입만, stdout 1줄.
#   · `--close` 지정 시 report.md ensure + workbench archive + sprint close + auto commit + stdout 3줄.
#   · auto commit (sfs-common.sh::auto_commit_close) 은 사용자 명시 호출 시에만 동작 (§1.5' 정합).
#
# Output (1~3 lines):
#   retro.md ready: <path>
#   report.md ready: <path>      # --close 시에만 추가
#   sprint closed: <sprint-id>     # --close 시에만 추가
#
# Exit codes (WU-26 §2.3 / WU-23 §1.6 정합):
#   0  success
#   1  no .sfs-local/ or no active sprint
#   4  sprint-templates/retro.md 부재
#   7  unknown CLI flag
#   8  --close 인데 review.md 미작성
#   99 unknown (e.g. bash trap)
#
# Path note: dev staging file lives at
#   solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-retro.sh
# install.sh copies templates/.sfs-local-template/ → consumer project's .sfs-local/.
# WU-26 §2 spec used `.sfs-local/scripts/` as a shorthand for the consumer-side path.
#
# Visibility: business-only (solon-mvp-dist staging asset).
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
CLOSE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --close)
      CLOSE=1
      shift
      ;;
    -h|--help)
      cat <<EOF
Usage: /sfs retro [--close]

Open the current sprint's retro.md (creates if missing). With --close, also
ensures report.md exists, marks the sprint closed, and commits the result.
The AI runtime owns branch push/main merge/main push after this local close commit.

Options:
  --close       Ensure report.md exists, mark sprint closed (writes
                status/closed_at into plan.md, removes .sfs-local/current-sprint,
                appends report_ready + sprint_close events, runs
                sfs-common.sh::auto_commit_close which performs git add+commit).
  -h, --help    Show this help.

Exit codes:
  0  ok
  1  no .sfs-local/ or no active sprint
  4  sprint-templates/retro.md missing
  7  unknown CLI flag
  8  --close requested but review.md missing (run /sfs review first)
  99 unknown (bash trap)
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
RETRO_PATH="${SPRINT_DIR}/retro.md"
REPORT_PATH="${SPRINT_DIR}/report.md"
TEMPLATE="$(sfs_sprint_template_file retro)"

# ─────────────────────────────────────────────────────────────────────
# (a) retro.md 미존재 시 template cp + placeholder 치환
# ─────────────────────────────────────────────────────────────────────
if [[ ! -f "${RETRO_PATH}" ]]; then
  if [[ ! -f "${TEMPLATE}" ]]; then
    echo "template missing: ${TEMPLATE}" >&2
    exit "${SFS_EXIT_TEMPLATE:-4}"
  fi
  mkdir -p "${SPRINT_DIR}"
  cp "${TEMPLATE}" "${RETRO_PATH}"
  # sprint_id placeholder 치환 (template 안의 `<sprint title>` / `{{SPRINT_ID}}` 양쪽 호환)
  if grep -q '{{SPRINT_ID}}' "${RETRO_PATH}"; then
    # awk-based atomic tmp+mv (BSD/GNU portable, sfs-decision.sh 패턴)
    local_tmp=$(mktemp "${RETRO_PATH}.XXXXXX")
    awk -v sid="${SPRINT_ID}" '{ gsub(/\{\{SPRINT_ID\}\}/, sid); print }' "${RETRO_PATH}" > "${local_tmp}"
    mv "${local_tmp}" "${RETRO_PATH}"
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# (b) frontmatter 갱신 + retro_open event
# ─────────────────────────────────────────────────────────────────────
NOW="$(date -u +%Y-%m-%dT%H:%M:%S+00:00)"
update_frontmatter "${RETRO_PATH}" "phase" "retro"
update_frontmatter "${RETRO_PATH}" "sprint_id" "${SPRINT_ID}"
update_frontmatter "${RETRO_PATH}" "last_touched_at" "${NOW}"

# WU-26 §2: append_event TYPE PAYLOAD 2-arg signature (sfs-decision.sh / sfs-plan.sh 패턴 정합).
append_event "retro_open" "{\"sprint_id\":\"${SPRINT_ID}\",\"path\":\"${RETRO_PATH}\"}"

echo "retro.md ready: ${RETRO_PATH}"

# ─────────────────────────────────────────────────────────────────────
# (c) --close 분기
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

  # sprint frontmatter status=closed + closed_at + closed_at on retro.md too
  update_frontmatter "${RETRO_PATH}" "closed_at" "${NOW}"

  # Completed sprint artifact lifecycle:
  # report.md becomes the final work artifact; workbench docs move to archive.
  REPORT_PATH="$(sfs_prepare_sprint_report "${SPRINT_ID}" "${NOW}" "final")"
  sprint_close "${SPRINT_DIR}" "${NOW}"
  sfs_compact_sprint_workbench "${SPRINT_ID}" "${NOW}"

  # current-sprint 클리어
  rm -f "${SFS_CURRENT_SPRINT_FILE}"

  # report_ready + sprint_close events (2-arg signature)
  append_event "report_ready" "{\"sprint_id\":\"${SPRINT_ID}\",\"path\":\"${REPORT_PATH}\"}"
  append_event "sprint_close" "{\"sprint_id\":\"${SPRINT_ID}\"}"

  # auto commit. Branch push/main merge/main push belong to the AI runtime Git Flow lifecycle.
  auto_commit_close "${SPRINT_ID}"

  echo "report.md ready: ${REPORT_PATH}"
  echo "sprint closed: ${SPRINT_ID}"
fi

exit 0
