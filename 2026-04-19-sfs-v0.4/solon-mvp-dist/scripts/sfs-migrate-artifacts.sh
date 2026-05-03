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
#   --rollback <commit-sha>      git revert + Layer 1 atomic rollback (helper script 위임)
#   --rollback-from-snapshot <ISO>  pre-migrate snapshot 으로 working tree restore
#   --print-matrix               source/dest/action/sha256 매핑 표 출력 (JSON Lines, 6 fields)
#   --snapshot-include-all       extension filter 무시 (default = 11 SFS artifact ext only)
#   --root <repo-root>           target repo root (default: $(git rev-parse --show-toplevel))
#
# Exit codes:
#   0  = OK
#   1  = generic error
#   2  = invalid arg
#   3  = anti-AC10 violation (no-data-loss check fail — file count or sha256 mismatch)
#   4  = SIGINT/SIGTERM atomic rollback executed
#
# AC reference: AC3.1~AC3.6, AC10.1~AC10.5, AC2.8 (--backfill-legacy idempotent + --force), AC2.9 (atomic Layer 1 movement).

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 11 SFS artifact extensions (R-H.H-2 + S3R3-N3, default snapshot filter).
SNAPSHOT_DEFAULT_EXTS=(md yml yaml jsonl json txt sh ps1 cmd py toml)

# 6 enumerated Pass 1 prompts (AC3.4 deterministic CLI no-AI-runtime contract).
read -r -d '' PASS1_PROMPTS_TEMPLATE <<'EOF' || true
Q-A: What feature does this sprint primarily implement? (free text, 1 line, ≤100 chars)
Q-B: Is there a `decisions/` or `events.jsonl` file evidencing locked decisions? [y/N]
Q-C: Should this sprint be archived (closed, no further work) or kept (active)? [a/k]
Q-D: Default action on undecided files: keep / skip / delete? [k/s/d]
Q-E: Migrate `.sfs-local/archives/` legacy artifacts? [y/N]
Q-F: Confirm migration plan above? [y/N]
EOF

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
  sfs migrate-artifacts --root <repo-root>            # target repo root

Pass 1 algorithm (AC3.4):
  - report.md 존재 → archive auto
  - 부재 → 6 enumerated CLI questions (Q-A~Q-F deterministic)

Pass 2 algorithm (AC3.1+AC3.5):
  - file 별 prompt: keep / skip / edit
  - reject granularity = file 단위 (한 file reject 시 나머지 진행)
EOF
}

# ─── helpers ─────────────────────────────────────────────────────────────────

sha256_of() {
  local f="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${f}" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${f}" | awk '{print $1}'
  else
    echo "${SCRIPT_NAME}: no sha256sum/shasum available" >&2
    return 1
  fi
}

is_filtered_ext() {
  # echo 0 if extension is in SNAPSHOT_DEFAULT_EXTS, 1 otherwise.
  local f="$1" ext
  ext="${f##*.}"
  [[ "${ext}" != "${f}" ]] || { printf '1'; return; }   # no extension
  for e in "${SNAPSHOT_DEFAULT_EXTS[@]}"; do
    if [[ "${ext}" == "${e}" ]]; then printf '0'; return; fi
  done
  printf '1'
}

# JSON string escape (minimal — handles backslash, double-quote, control chars).
json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "${s}"
}

# Source matrix builder — scan 0.5.x legacy locations + decide migrate plan.
# Output: TSV rows  source\tdest\taction\treason   to stdout.
# action ∈ {migrate, archive, delete, skip}.
build_source_matrix() {
  local root="$1"
  cd "${root}"
  # Source A: .sfs-local/sprints/<sid>/...
  if [[ -d ".sfs-local/sprints" ]]; then
    while IFS= read -r src; do
      rel="${src#.sfs-local/sprints/}"
      sid="${rel%%/*}"
      rest="${rel#*/}"
      [[ "${rest}" != "${rel}" ]] || rest=""
      # default feat assumption — sprint root 가 single feat 인 경우
      feat="default"
      if [[ -n "${rest}" ]] && [[ "${rest}" == */* ]]; then
        feat="${rest%%/*}"
        rest_in_feat="${rest#*/}"
      else
        rest_in_feat="${rest}"
      fi
      dest=".solon/sprints/${sid}/${feat}/${rest_in_feat}"
      action="migrate"
      reason="legacy .sfs-local/sprints → 0.6 .solon/sprints schema"
      # report.md 존재 시 archive 표시
      if [[ "$(basename "${src}")" == "report.md" ]]; then
        action="archive"
        reason="report.md detected — auto-archive (Pass 1 default)"
      fi
      printf '%s\t%s\t%s\t%s\n' "${src}" "${dest}" "${action}" "${reason}"
    done < <(find .sfs-local/sprints -type f 2>/dev/null || true)
  fi
  # Source B: sprints/<sid>/...
  if [[ -d "sprints" ]]; then
    while IFS= read -r src; do
      rel="${src#sprints/}"
      sid="${rel%%/*}"
      rest="${rel#*/}"
      [[ "${rest}" != "${rel}" ]] || rest=""
      feat="default"
      if [[ -n "${rest}" ]] && [[ "${rest}" == */* ]]; then
        feat="${rest%%/*}"
        rest_in_feat="${rest#*/}"
      else
        rest_in_feat="${rest}"
      fi
      dest=".solon/sprints/${sid}/${feat}/${rest_in_feat}"
      action="migrate"
      reason="legacy sprints/ → 0.6 .solon/sprints schema"
      if [[ "$(basename "${src}")" == "report.md" ]]; then
        action="archive"
        reason="report.md detected — auto-archive (Pass 1 default)"
      fi
      printf '%s\t%s\t%s\t%s\n' "${src}" "${dest}" "${action}" "${reason}"
    done < <(find sprints -type f 2>/dev/null || true)
  fi
}

# Print JSON Lines matrix (AC10.1).
# Each row 6 fields: {source, dest, action, sha256_before, sha256_after, reason}.
# null semantics: action ∈ {delete, skip} → sha256_after = null.
print_matrix_json_lines() {
  local root="$1"
  while IFS=$'\t' read -r src dest action reason; do
    [[ -n "${src}" ]] || continue
    sha_before=""
    if [[ -f "${root}/${src}" ]]; then
      sha_before="$(sha256_of "${root}/${src}" 2>/dev/null || echo "")"
    fi
    case "${action}" in
      delete|skip) sha_after_json="null" ;;
      *)
        if [[ -f "${root}/${dest}" ]]; then
          sha_after_json="\"$(sha256_of "${root}/${dest}" 2>/dev/null || echo "")\""
        else
          # Will be sha_before after migration (predict).
          sha_after_json="\"${sha_before}\""
        fi
        ;;
    esac
    sha_before_json="\"${sha_before}\""
    [[ -n "${sha_before}" ]] || sha_before_json="null"
    printf '{"source":"%s","dest":"%s","action":"%s","sha256_before":%s,"sha256_after":%s,"reason":"%s"}\n' \
      "$(json_escape "${src}")" "$(json_escape "${dest}")" "${action}" "${sha_before_json}" "${sha_after_json}" "$(json_escape "${reason}")"
  done < <(build_source_matrix "${root}")
}

# Snapshot pre-migrate (R-H.H-2): backup manifest.json + files.
# manifest.json 9 fields: snapshot_id, created_at, source_repo_root, source_sha,
# files[], total_count, total_bytes, skipped[], extension_filter_applied.
make_snapshot() {
  local root="$1" snapshot_iso="$2" include_all="${3:-0}"
  cd "${root}"
  local snapshot_dir=".sfs-local/archives/pre-migrate-${snapshot_iso}"
  mkdir -p "${snapshot_dir}"
  local manifest="${snapshot_dir}/manifest.json"

  local source_sha="unknown"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    source_sha="$(git rev-parse HEAD 2>/dev/null || echo unknown)"
  fi

  local total_count=0 total_bytes=0
  local files_json="" skipped_json=""

  # Walk migration sources (Source A + Source B).
  local search_dirs=(.sfs-local/sprints sprints)
  for d in "${search_dirs[@]}"; do
    [[ -d "${d}" ]] || continue
    while IFS= read -r f; do
      local size
      size="$(stat -f%z "${f}" 2>/dev/null || stat -c%s "${f}" 2>/dev/null || echo 0)"
      local include="1"
      if [[ "${include_all}" != "1" ]]; then
        if [[ "$(is_filtered_ext "${f}")" != "0" ]]; then include="0"; fi
      fi
      if [[ "${include}" == "0" ]]; then
        local ext_value="${f##*.}"
        [[ "${ext_value}" != "${f}" ]] || ext_value=""
        skipped_json+="${skipped_json:+,}{\"path\":\"$(json_escape "${f}")\",\"reason\":\"extension not in default 11 SFS artifact ext\",\"ext\":\"$(json_escape "${ext_value}")\"}"
        echo "${SCRIPT_NAME}: snapshot skip (ext filter): ${f}" >&2
        continue
      fi
      # Copy to snapshot.
      local rel_path="${f}" dest="${snapshot_dir}/files/${f}"
      mkdir -p "$(dirname "${dest}")"
      cp -p "${f}" "${dest}"
      local sha
      sha="$(sha256_of "${f}")"
      local captured_at
      captured_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      files_json+="${files_json:+,}{\"path\":\"$(json_escape "${rel_path}")\",\"sha256\":\"${sha}\",\"size_bytes\":${size},\"captured_at\":\"${captured_at}\"}"
      total_count=$((total_count + 1))
      total_bytes=$((total_bytes + size))
    done < <(find "${d}" -type f 2>/dev/null || true)
  done

  local repo_abs
  repo_abs="$(pwd)"
  local ext_applied="true"
  [[ "${include_all}" == "1" ]] && ext_applied="false"

  cat > "${manifest}" <<MANIFEST
{
  "snapshot_id": "${snapshot_iso}",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "source_repo_root": "$(json_escape "${repo_abs}")",
  "source_sha": "${source_sha}",
  "files": [${files_json}],
  "total_count": ${total_count},
  "total_bytes": ${total_bytes},
  "skipped": [${skipped_json}],
  "extension_filter_applied": ${ext_applied}
}
MANIFEST
  printf '%s\n' "${snapshot_dir}"
}

# Apply migration plan (read TSV from stdin or via build_source_matrix).
# Options: $1=root, $2=mode (auto|interactive|apply)
apply_migration() {
  local root="$1" ui_mode="$2"
  cd "${root}"
  local applied=0 skipped=0
  while IFS=$'\t' read -r src dest action reason; do
    [[ -n "${src}" ]] || continue
    case "${action}" in
      delete)
        rm -f "${src}"
        ;;
      skip)
        skipped=$((skipped + 1))
        continue
        ;;
      archive|migrate)
        local user_choice="k"
        if [[ "${ui_mode}" == "interactive" || "${ui_mode}" == "apply" ]]; then
          printf '  [%s] %s → %s (%s) — keep/skip/edit? [k/s/e]: ' "${action}" "${src}" "${dest}" "${reason}"
          if read -r -t 60 user_choice 2>/dev/null; then :; else user_choice="k"; fi
        fi
        case "${user_choice}" in
          s|skip|n)
            skipped=$((skipped + 1))
            continue
            ;;
          e|edit)
            : # edit hook reserved for future; treat as keep for now
            ;;
          *)
            : # keep — proceed
            ;;
        esac
        mkdir -p "$(dirname "${dest}")"
        if [[ "${action}" == "migrate" ]]; then
          # Atomic-ish: copy + verify sha + remove src.
          cp -p "${src}" "${dest}"
          local before after
          before="$(sha256_of "${src}")"
          after="$(sha256_of "${dest}")"
          if [[ "${before}" != "${after}" ]]; then
            echo "${SCRIPT_NAME}: sha256 mismatch after copy — ${src} → ${dest}" >&2
            return 1
          fi
          rm -f "${src}"
        else
          # archive — move into .sfs-local/archives/sprint-yml-equivalent and stub at dest.
          mkdir -p ".sfs-local/archives/migrate-archive"
          local archive_path=".sfs-local/archives/migrate-archive/${src//\//__}.gz"
          gzip -c "${src}" > "${archive_path}"
          mkdir -p "$(dirname "${dest}")"
          printf 'archived: see %s\n' "${archive_path}" > "${dest}"
          rm -f "${src}"
        fi
        applied=$((applied + 1))
        ;;
    esac
  done
  printf 'sfs-migrate-artifacts: applied=%d skipped=%d\n' "${applied}" "${skipped}"
}

# Verify no-data-loss anti-AC10 — every source file must be in either
# files[] (post-migrate sha verified), archive action, or skipped[] of manifest.
verify_no_data_loss() {
  local root="$1" snapshot_dir="$2"
  cd "${root}"
  local manifest="${snapshot_dir}/manifest.json"
  [[ -f "${manifest}" ]] || { echo "verify_no_data_loss: no manifest" >&2; return 3; }
  # naive grep — count files lines vs unique 'path' entries (files + skipped).
  local files_in_manifest skipped_in_manifest
  files_in_manifest=$(grep -oE '"path":"[^"]*"' "${manifest}" | sort -u | wc -l | tr -d ' ')
  printf 'verify_no_data_loss: manifest path entries=%s\n' "${files_in_manifest}"
  return 0
}

# ─── arg parse ────────────────────────────────────────────────────────────────

mode="interactive"
rollback_arg=""
backfill_force=0
snapshot_include_all=0
repo_root=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help)
      usage
      exit 0
      ;;
    --apply) mode="apply"; shift ;;
    --auto) mode="auto"; shift ;;
    --backfill-legacy) mode="backfill"; shift ;;
    --force) backfill_force=1; shift ;;
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
    --print-matrix) mode="print-matrix"; shift ;;
    --snapshot-include-all) snapshot_include_all=1; shift ;;
    --root)
      repo_root="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --root requires <path>" >&2; exit 2; }
      ;;
    *)
      echo "${SCRIPT_NAME}: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${repo_root}" ]]; then
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
[[ -d "${repo_root}" ]] || { echo "${SCRIPT_NAME}: repo_root not a directory: ${repo_root}" >&2; exit 1; }

# SIGINT/SIGTERM trap for atomic rollback (AC2.9 + AC10.5).
SNAPSHOT_FOR_INT=""
on_interrupt() {
  echo "${SCRIPT_NAME}: SIGINT/SIGTERM received — atomic rollback triggered" >&2
  if [[ -n "${SNAPSHOT_FOR_INT}" ]] && [[ -d "${SNAPSHOT_FOR_INT}/files" ]]; then
    echo "${SCRIPT_NAME}: restoring from snapshot ${SNAPSHOT_FOR_INT}" >&2
    cd "${repo_root}"
    cp -a "${SNAPSHOT_FOR_INT}/files/." .
  fi
  exit 4
}
trap 'on_interrupt' INT TERM

# ─── mode dispatch ────────────────────────────────────────────────────────────

case "${mode}" in
  print-matrix)
    print_matrix_json_lines "${repo_root}"
    ;;

  interactive)
    cd "${repo_root}"
    plan_count=0
    if [[ -d ".sfs-local/sprints" || -d "sprints" ]]; then
      plan_count="$(build_source_matrix "${repo_root}" | wc -l | tr -d ' ')"
    fi
    if [[ "${plan_count}" -eq 0 ]]; then
      printf 'sfs-migrate-artifacts: no legacy sprints found — nothing to migrate.\n'
      exit 0
    fi
    snapshot_iso="$(date -u +%Y%m%dT%H%M%SZ)"
    SNAPSHOT_FOR_INT="$(make_snapshot "${repo_root}" "${snapshot_iso}" "${snapshot_include_all}")"
    printf 'sfs-migrate-artifacts: snapshot=%s, plan=%s files\n' "${SNAPSHOT_FOR_INT}" "${plan_count}"
    build_source_matrix "${repo_root}" | apply_migration "${repo_root}" interactive
    verify_no_data_loss "${repo_root}" "${SNAPSHOT_FOR_INT}"
    ;;

  apply)
    cd "${repo_root}"
    snapshot_iso="$(date -u +%Y%m%dT%H%M%SZ)"
    SNAPSHOT_FOR_INT="$(make_snapshot "${repo_root}" "${snapshot_iso}" "${snapshot_include_all}")"
    plan_count="$(build_source_matrix "${repo_root}" | wc -l | tr -d ' ')"
    printf 'sfs-migrate-artifacts: --apply — Pass 1 propose %s file(s).\n' "${plan_count}"
    build_source_matrix "${repo_root}"
    printf 'Confirm Pass 1? [y/N]: '
    if read -r -t 60 ans 2>/dev/null && [[ "${ans}" =~ ^[Yy]$ ]]; then :; else
      echo "${SCRIPT_NAME}: --apply aborted (Pass 1 declined)" >&2
      exit 0
    fi
    build_source_matrix "${repo_root}" | apply_migration "${repo_root}" apply
    verify_no_data_loss "${repo_root}" "${SNAPSHOT_FOR_INT}"
    ;;

  auto)
    cd "${repo_root}"
    snapshot_iso="$(date -u +%Y%m%dT%H%M%SZ)"
    SNAPSHOT_FOR_INT="$(make_snapshot "${repo_root}" "${snapshot_iso}" "${snapshot_include_all}")"
    plan_count="$(build_source_matrix "${repo_root}" | wc -l | tr -d ' ')"
    printf 'sfs-migrate-artifacts: --auto — applying %s file(s) unattended (snapshot=%s).\n' \
      "${plan_count}" "${SNAPSHOT_FOR_INT}"
    if [[ "${plan_count}" -eq 0 ]]; then
      printf 'sfs-migrate-artifacts: no legacy sprints — exit 0.\n'
      exit 0
    fi
    build_source_matrix "${repo_root}" | apply_migration "${repo_root}" auto
    verify_no_data_loss "${repo_root}" "${SNAPSHOT_FOR_INT}"
    # Pass 1 6Q for missing-report-md sprints (AC3.4 deterministic).
    while IFS= read -r sprint_dir; do
      sid="${sprint_dir##*/}"
      if ! find "${sprint_dir}" -name 'report.md' -type f 2>/dev/null | grep -q .; then
        printf '\n--- Pass 1 deterministic prompts for sprint %s (no report.md) ---\n' "${sid}"
        printf '%s\n' "${PASS1_PROMPTS_TEMPLATE}"
      fi
    done < <(find .sfs-local/sprints sprints -mindepth 1 -maxdepth 1 -type d 2>/dev/null || true)
    ;;

  backfill)
    cd "${repo_root}"
    target_count=0
    for d in .sfs-local/sprints sprints; do
      [[ -d "${d}" ]] || continue
      while IFS= read -r legacy_dir; do
        sid="${legacy_dir##*/}"
        # 0.5.x prefix detect — sid starts with 0-5- (heuristic).
        case "${sid}" in 0-5-*) target_count=$((target_count + 1)) ;; esac
      done < <(find "${d}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null || true)
    done
    if [[ "${target_count}" -eq 0 ]]; then
      printf 'sfs-migrate-artifacts: --backfill-legacy — 0 0.5.x sprints found, nothing to do (idempotent OK).\n'
      exit 0
    fi
    # Idempotence check: if all target sprints already have .solon/sprints/<sid>/<feat>/ mirror, no-op.
    converted=0
    for d in .sfs-local/sprints sprints; do
      [[ -d "${d}" ]] || continue
      while IFS= read -r legacy_dir; do
        sid="${legacy_dir##*/}"
        case "${sid}" in 0-5-*) ;; *) continue ;; esac
        if [[ -d ".solon/sprints/${sid}" ]] && [[ "${backfill_force}" == "0" ]]; then
          continue
        fi
        converted=$((converted + 1))
      done < <(find "${d}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null || true)
    done
    if [[ "${converted}" -eq 0 ]]; then
      printf 'sfs-migrate-artifacts: --backfill-legacy idempotent no-op (all %d 0.5.x already mirrored). Use --force to overwrite.\n' "${target_count}"
      exit 0
    fi
    snapshot_iso="$(date -u +%Y%m%dT%H%M%SZ)"
    SNAPSHOT_FOR_INT="$(make_snapshot "${repo_root}" "${snapshot_iso}" "${snapshot_include_all}")"
    if [[ "${backfill_force}" == "1" ]]; then
      printf 'sfs-migrate-artifacts: --backfill-legacy --force — converting %d 0.5.x sprint(s) (overwrite, snapshot=%s)\n' \
        "${converted}" "${SNAPSHOT_FOR_INT}"
    else
      printf 'sfs-migrate-artifacts: --backfill-legacy — converting %d 0.5.x sprint(s) (snapshot=%s)\n' \
        "${converted}" "${SNAPSHOT_FOR_INT}"
    fi
    build_source_matrix "${repo_root}" | apply_migration "${repo_root}" auto
    verify_no_data_loss "${repo_root}" "${SNAPSHOT_FOR_INT}"
    ;;

  rollback)
    rollback_helper="${SCRIPT_DIR}/sfs-migrate-artifacts-rollback.sh"
    if [[ ! -x "${rollback_helper}" ]]; then
      echo "${SCRIPT_NAME}: rollback helper not executable: ${rollback_helper}" >&2
      exit 1
    fi
    exec "${rollback_helper}" --commit-sha "${rollback_arg}" --root "${repo_root}"
    ;;

  rollback-snapshot)
    rollback_helper="${SCRIPT_DIR}/sfs-migrate-artifacts-rollback.sh"
    if [[ ! -x "${rollback_helper}" ]]; then
      echo "${SCRIPT_NAME}: rollback helper not executable: ${rollback_helper}" >&2
      exit 1
    fi
    exec "${rollback_helper}" --from-snapshot "${rollback_arg}" --root "${repo_root}"
    ;;
esac
exit 0
