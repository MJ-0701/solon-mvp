#!/usr/bin/env bash
# SFS recall: 토큰 0 세션 회상 — 구조화된 session/handoff/PROGRESS 로그를
# 비-LLM(grep / 날짜 인덱스)으로 검색하는 read-only 명령.
#
# `sfs recall <YYYY-MM-DD|YYYYMMDD|keyword>` — 과거 작업의 handoff/report/retro/
# 워크벤치를 LLM 토큰 없이 찾아 위치를 출력한다. 파일을 만들거나 고치지 않는다.
#
# Search roots (read-only):
#   docs/solon/<workspace>/<yyyyMMdd>/{handoff,report,retro}.md  — 공유 핸드오프/이력
#   docs/solon/**.md                                             — 프로젝트 Solon 문서
#   .sfs-local/sprints/**                                        — sprint 워크벤치
#   .sfs-local/events.jsonl                                      — 이벤트 원장
#
# Exit codes:
#   0  matches found
#   1  no matches
#   2  usage error

set -u

RECALL_OK=0
RECALL_NONE=1
RECALL_USAGE=2

SFS_LOCAL_DIR="${SFS_LOCAL_DIR:-.sfs-local}"

usage_recall() {
  cat <<'EOF'
Usage:
  sfs recall <query>

Token-zero session recall. `query` is either a date (YYYY-MM-DD or YYYYMMDD)
or a free-text keyword. Searches structured session/handoff/PROGRESS logs with
plain grep/date indexing — no LLM, no model tokens. Read-only: it never writes,
edits, stages, commits, or mutates any file.

Search roots: docs/solon/ (handoff/report/retro + project Solon docs),
.sfs-local/sprints/ (sprint workbench), and .sfs-local/events.jsonl.

Exit codes:
  0  matches found
  1  no matches
  2  usage error
EOF
}

case "${1:-}" in
  -h|--help|help) usage_recall; exit "${RECALL_OK}" ;;
  "") echo "recall: a date or keyword is required" >&2; usage_recall >&2; exit "${RECALL_USAGE}" ;;
esac

QUERY="$1"
shift || true
if [[ $# -gt 0 ]]; then
  echo "recall: unexpected extra argument: $1" >&2
  exit "${RECALL_USAGE}"
fi

# Normalize a YYYYMMDD or YYYY-MM-DD query to both forms for matching.
is_date=0
date_compact=""
date_dashed=""
if [[ "${QUERY}" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})$ ]]; then
  is_date=1
  date_dashed="${QUERY}"
  date_compact="${BASH_REMATCH[1]}${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
elif [[ "${QUERY}" =~ ^([0-9]{4})([0-9]{2})([0-9]{2})$ ]]; then
  is_date=1
  date_compact="${QUERY}"
  date_dashed="${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]}"
fi

printf 'sfs recall: %s (read-only)\n' "${QUERY}"

match_count=0

emit_match() {
  match_count=$((match_count + 1))
  printf '  %s\n' "$1"
}

if [[ "${is_date}" -eq 1 ]]; then
  # Date index: list dated session directories and their handoff/report/retro.
  if [[ -d docs/solon ]]; then
    while IFS= read -r dir; do
      [[ -n "${dir}" ]] || continue
      emit_match "session dir: ${dir}"
      for doc in handoff report retro; do
        [[ -f "${dir}/${doc}.md" ]] && emit_match "  ${doc}: ${dir}/${doc}.md"
      done
    done < <(find docs/solon -type d \( -name "${date_compact}" -o -name "${date_dashed}" \) 2>/dev/null | sort)
  fi
  # Event ledger lines stamped with the date.
  if [[ -f "${SFS_LOCAL_DIR}/events.jsonl" ]]; then
    n="$(grep -c "${date_dashed}" "${SFS_LOCAL_DIR}/events.jsonl" 2>/dev/null || printf '0')"
    case "${n}" in ''|*[!0-9]*) n=0 ;; esac
    [[ "${n}" -gt 0 ]] && emit_match "events: ${n} line(s) in ${SFS_LOCAL_DIR}/events.jsonl on ${date_dashed}"
  fi
else
  # Keyword: grep file:line across the read-only roots.
  for root in docs/solon "${SFS_LOCAL_DIR}/sprints"; do
    [[ -d "${root}" ]] || continue
    while IFS= read -r hit; do
      [[ -n "${hit}" ]] || continue
      emit_match "${hit}"
    done < <(grep -rInE -- "${QUERY}" "${root}" --include='*.md' 2>/dev/null | head -50)
  done
  if [[ -f "${SFS_LOCAL_DIR}/events.jsonl" ]]; then
    while IFS= read -r hit; do
      [[ -n "${hit}" ]] || continue
      emit_match "events.jsonl:${hit}"
    done < <(grep -nE -- "${QUERY}" "${SFS_LOCAL_DIR}/events.jsonl" 2>/dev/null | head -20)
  fi
fi

if [[ "${match_count}" -eq 0 ]]; then
  printf 'no matches for: %s\n' "${QUERY}"
  exit "${RECALL_NONE}"
fi

printf 'recall: %s match line(s). Open the files above to restore context (no tokens spent searching).\n' "${match_count}"
exit "${RECALL_OK}"
