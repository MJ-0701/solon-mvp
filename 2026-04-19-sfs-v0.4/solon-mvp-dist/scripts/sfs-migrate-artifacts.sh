#!/usr/bin/env bash
# sfs-migrate-artifacts.sh — R3 migrate-artifacts CLI.
#
# 0.5.x consumer (.sfs-local/sprints, sprints/) → 0.6 schema (.solon/sprints/<S-id>/<feat>/) 마이그레이션.
# 3 surface: interactive (no-flag wizard) / --apply (양 단계 confirm) / --auto (fully unattended).
# Pass 1 = report.md 존재 → archive auto / 부재 → 6 enumerated CLI questions (Q-A~Q-F) deterministic.
# Pass 2 = file 별 keep/skip/edit prompt.
#
# 추가 flag:
#   --backfill-legacy            옛 sprints/0-5-x-* 전부 0.6 schema 변환 (idempotent default + --force)
#   --rollback <commit-sha>      git revert + Layer 1 atomic rollback
#   --rollback-from-snapshot <ISO>  pre-migrate snapshot 으로 working tree restore
#   --print-matrix               source/dest/action/sha256 매핑 표 출력 (JSON Lines, 6 fields)
#   --snapshot-include-all       extension filter 무시 (default = 11 SFS artifact ext only)
#
# Exit codes:
#   0  = OK
#   1  = generic error
#   2  = invalid arg
#   3  = anti-AC10 violation (no-data-loss check fail — file count or sha256 mismatch)
#   4  = SIGINT/SIGTERM atomic rollback executed
#
# AC reference: AC3.1~AC3.6 (3 surface + Pass 1/2 + reject + rollback), AC10.1~AC10.5 (matrix + manifest + rollback + interrupted recovery + no-data-loss), AC2.8 (--backfill-legacy idempotent + --force), AC2.9 (atomic Layer 1 movement).
# Implementation: chunk 1 = skeleton + arg parse + flag dispatch. 실 wizard / Pass 1 prompt / matrix / rollback logic = 다음 chunk (R-C C-1~C-6 + R-H H-1~H-5).

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
sfs-migrate-artifacts — R3 migrate-artifacts CLI

Usage:
  sfs migrate-artifacts                          # interactive wizard (default)
  sfs migrate-artifacts --apply                  # batch with 양 단계 confirm
  sfs migrate-artifacts --auto                   # fully unattended (CI 용)

  sfs migrate-artifacts --backfill-legacy [--force]   # 옛 sprints 전부 0.6 schema (idempotent default)
  sfs migrate-artifacts --rollback <commit-sha>       # git revert + atomic Layer 1 rollback
  sfs migrate-artifacts --rollback-from-snapshot <ISO>  # pre-migrate snapshot 복원
  sfs migrate-artifacts --print-matrix                # JSON Lines 6-field 매핑 표
  sfs migrate-artifacts --snapshot-include-all        # extension filter 무시 (advanced)

Pass 1 algorithm:
  - report.md 존재 → archive auto
  - 부재 → 6 enumerated CLI questions (Q-A~Q-F deterministic, AC3.4)

Pass 2 algorithm:
  - file 별 prompt: keep / skip / edit (AC3.1)
  - reject granularity = file 단위 (한 file reject 시 나머지 진행)
  - sprint 전체 영향 발견 시 sprint 단위 escalate
EOF
}

# arg parse — 본 chunk 는 mode dispatch + flag 인식만.
mode="interactive"   # interactive | apply | auto | backfill | rollback | rollback-snapshot | print-matrix
rollback_arg=""
backfill_force=0
snapshot_include_all=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help)
      usage
      exit 0
      ;;
    --apply)
      mode="apply"
      shift
      ;;
    --auto)
      mode="auto"
      shift
      ;;
    --backfill-legacy)
      mode="backfill"
      shift
      ;;
    --force)
      backfill_force=1
      shift
      ;;
    --rollback)
      mode="rollback"
      rollback_arg="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --rollback requires <commit-sha>" >&2; exit 2; }
      ;;
    --rollback-from-snapshot)
      mode="rollback-snapshot"
      rollback_arg="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --rollback-from-snapshot requires <ISO>" >&2; exit 2; }
      ;;
    --print-matrix)
      mode="print-matrix"
      shift
      ;;
    --snapshot-include-all)
      snapshot_include_all=1
      shift
      ;;
    *)
      echo "${SCRIPT_NAME}: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

# SIGINT/SIGTERM trap for atomic rollback (AC2.9 + AC10.5).
on_interrupt() {
  echo "${SCRIPT_NAME}: SIGINT/SIGTERM received — atomic rollback (placeholder, chunk N R-H H-5)" >&2
  # TODO chunk N: pre-migrate snapshot 으로 working tree restore.
  exit 4
}
trap 'on_interrupt' INT TERM

case "${mode}" in
  interactive)
    # TODO chunk N (R-C C-1): file 별 prompt loop.
    printf 'sfs-migrate-artifacts: interactive wizard placeholder (chunk N R-C C-1)\n'
    ;;
  apply)
    # TODO chunk N (R-C C-2): Pass 1 propose list confirm + Pass 2 file 별 confirm.
    printf 'sfs-migrate-artifacts: --apply placeholder (chunk N R-C C-2)\n'
    ;;
  auto)
    # TODO chunk N (R-C C-3): unattended Pass 1 + Pass 2 default 선택.
    printf 'sfs-migrate-artifacts: --auto placeholder (chunk N R-C C-3)\n'
    ;;
  backfill)
    # TODO chunk N (R-B B-8 + AC2.8): 옛 sprints/0-5-x-* iter + 0.6 schema 변환 + idempotent.
    if [[ "${backfill_force}" == "1" ]]; then
      printf 'sfs-migrate-artifacts: --backfill-legacy --force placeholder (overwrite mode)\n'
    else
      printf 'sfs-migrate-artifacts: --backfill-legacy placeholder (idempotent default — re-run = no-op)\n'
    fi
    ;;
  rollback)
    # TODO chunk N (R-C C-6 + AC3.6): git revert + Layer 1 atomic rollback.
    rollback_helper="${SCRIPT_DIR}/sfs-migrate-artifacts-rollback.sh"
    if [[ -x "${rollback_helper}" ]]; then
      exec "${rollback_helper}" --commit-sha "${rollback_arg}"
    fi
    printf 'sfs-migrate-artifacts: --rollback placeholder (commit-sha=%s)\n' "${rollback_arg}"
    ;;
  rollback-snapshot)
    # TODO chunk N (R-H H-3): pre-migrate snapshot 으로 working tree restore.
    printf 'sfs-migrate-artifacts: --rollback-from-snapshot placeholder (ISO=%s)\n' "${rollback_arg}"
    ;;
  print-matrix)
    # TODO chunk N (R-H H-1 + AC10.1):
    #   각 row JSON Line: {source, dest, action, sha256_before, sha256_after, reason}
    #   action ∈ [migrate, archive, delete, skip]
    #   sha256_after = null (delete/skip) | archive snapshot sha256 | post-migrate dest sha256
    printf 'sfs-migrate-artifacts: --print-matrix placeholder — JSON Lines schema 다음 chunk\n'
    # placeholder JSON Line for schema testing:
    # printf '{"source":".sfs-local/sprints/0-5-x-foo/report.md","dest":".solon/sprints/0-5-x-foo/foo/report.md","action":"migrate","sha256_before":"deadbeef...","sha256_after":"cafef00d...","reason":"report.md exists, auto-archive"}\n'
    ;;
esac
exit 0
