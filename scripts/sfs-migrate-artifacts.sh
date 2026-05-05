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
#   --no-tty                     prompt 비활성화 (CI/scripted, default 결정 사용) — G6.1 F1 fix
#   --recover [<ts>]             interrupted-midway recovery (transaction journal 기반 cleanup) — G6.1 AC10.5
#   --verify-snapshot <ts>       기존 snapshot 대비 verify_no_data_loss 단독 호출 (negative test 용) — G6.1 F4
#
# Exit codes:
#   0    = OK
#   1    = generic error
#   2    = invalid arg
#   3    = anti-AC10 violation (no-data-loss check fail — file count or sha256/size mismatch)
#   5    = SEVERE rollback incomplete (G6.1.1 V2 — snapshot restore cp -a failed during trap)
#   130  = SIGINT atomic rollback executed (G6.1 F3)
#   143  = SIGTERM atomic rollback executed (G6.1 F3)
#
# AC reference: AC3.1~AC3.6, AC10.1~AC10.5, AC2.8 (--backfill-legacy idempotent + --force), AC2.9 (atomic Layer 1 movement).
# G6.1 fix patch reference: retro.md §9 — F1 (stdin contention) / F3 (atomic rollback + transaction journal) /
#                            F4 (verify_no_data_loss real comparison) / AC10.5 (--recover mode).
# G6.1.1 fix reference: review-g6-1.md §2 — V1 (escape-aware JSONL parsing via json_get_string awk helper) /
#                                            V2 (cp -a non-zero exit + new exit code 5) /
#                                            HB1 (rmdir -p empty parents in journal_replay_cleanup) /
#                                            HB2 (trap '' INT TERM at on_interrupt entry — re-entrancy guard).
# G6.1.2 fix reference: review-g6-1.md §6 — V1 follow-up (emit_manifest_files_entries awk depth-tracker
#                                            replaces escape-blind `grep -oE '\{"path":"[^"]*",...\}'` in
#                                            verify_no_data_loss; entry-level iteration now escape-aware).

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

# G6.1 F1: --no-tty flag globals.
NO_TTY="0"

# G6.1 F3: transaction journal globals.
TX_JOURNAL=""           # path: .sfs-local/migrate-tx/<ts>.jsonl
SNAPSHOT_FOR_INT=""     # path: .sfs-local/archives/pre-migrate-<ts>

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
  sfs migrate-artifacts --no-tty                      # prompt 비활성화 (CI default)
  sfs migrate-artifacts --recover [<ts>]              # interrupted-midway cleanup (latest journal default)
  sfs migrate-artifacts --verify-snapshot <ISO>       # 기존 snapshot 단독 verify (no apply)

Pass 1 algorithm (AC3.4):
  - report.md 존재 → archive auto
  - 부재 → 6 enumerated CLI questions (Q-A~Q-F deterministic)

Pass 2 algorithm (AC3.1+AC3.5):
  - file 별 prompt: keep / skip / edit
  - reject granularity = file 단위 (한 file reject 시 나머지 진행)

Stdin contention contract (G6.1 F1):
  - matrix data 는 stdin 으로 흐르고, user prompt 는 /dev/tty 에서 read.
  - --no-tty 또는 /dev/tty 없음 → default 동작 (keep / decline) 자동 적용.
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

sha256_of_stream() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
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

# G6.1.2 V1 follow-up — escape-aware iteration of manifest "files":[...] entries.
# Walks the JSON char-by-char tracking string + escape + brace-depth state, emitting
# each top-level {...} object inside the files[] array on its own line. Replaces
# the prior `grep -oE '\{"path":"[^"]*",...\}'` extraction which was escape-blind:
# any path containing an escaped quote (`\"`) caused the regex to NOT match the
# enclosing object, silently skipping that entry from verify_no_data_loss iteration.
# Input: manifest file path. Output: one JSON object per line (files[] only).
emit_manifest_files_entries() {
  awk '
  BEGIN { in_files=0; depth=0; in_string=0; escape=0; entry="" }
  {
    L = $0
    if (!in_files) {
      pos = index(L, "\"files\":")
      if (pos == 0) next
      L = substr(L, pos + 8)
      pos = index(L, "[")
      if (pos == 0) next
      in_files = 1
      L = substr(L, pos + 1)
    }
    n = length(L)
    for (i = 1; i <= n; i++) {
      c = substr(L, i, 1)
      if (escape) { entry = entry c; escape = 0; continue }
      if (in_string) {
        if (c == "\\") { entry = entry c; escape = 1; continue }
        if (c == "\"") { entry = entry c; in_string = 0; continue }
        entry = entry c
        continue
      }
      if (c == "\"") { entry = entry c; in_string = 1; continue }
      if (c == "{") {
        if (depth == 0) entry = "{"
        else            entry = entry c
        depth += 1
        continue
      }
      if (c == "}") {
        depth -= 1
        entry = entry c
        if (depth == 0) {
          print entry
          entry = ""
        }
        continue
      }
      if (c == "]" && depth == 0) {
        in_files = 0
        exit
      }
      if (depth > 0) entry = entry c
    }
  }
  ' "$1"
}

# G6.1.1 V1 — escape-aware JSON string field extractor.
# Replaces fragile `sed -nE 's/.*"<field>":"([^"]*)".*/\1/p'` parsing which
# truncates values at the first byte after `"<field>":"`, including escaped
# quotes (`\"`) inside the value. awk state-machine walks the string byte-by-byte,
# decoding `\\`, `\"`, `\n`, `\r`, `\t` and stopping only at the first UNESCAPED `"`.
#
# Args: $1 = field name (e.g., "path", "op", "dest"), $2 = single-line JSON-ish blob.
# Output: decoded raw value (empty if field absent or value is JSON null).
json_get_string() {
  local field="$1" blob="$2"
  printf '%s' "${blob}" | awk -v field="${field}" '
  {
    needle = "\"" field "\":\""
    pos = index($0, needle)
    if (pos == 0) { exit 0 }
    rest = substr($0, pos + length(needle))
    out = ""
    i = 1
    n = length(rest)
    while (i <= n) {
      c = substr(rest, i, 1)
      if (c == "\\") {
        nc = substr(rest, i+1, 1)
        if      (nc == "n") out = out "\n"
        else if (nc == "r") out = out "\r"
        else if (nc == "t") out = out "\t"
        else                out = out nc
        i += 2
      } else if (c == "\"") {
        break
      } else {
        out = out c
        i += 1
      }
    }
    printf "%s", out
  }'
}

# G6.1 F1: prompt user via /dev/tty (stdin 경합 회피).
# Usage: answer=$(prompt_user "<prompt-text>" "<default>" [<timeout-sec>])
# Behavior:
#   --no-tty 또는 /dev/tty 미존재 → default 즉시 반환.
#   /dev/tty 정상 → prompt 표시 후 read, timeout 초과 시 default 반환.
prompt_user() {
  local prompt="$1" default="$2" timeout="${3:-60}" answer=""
  if [[ "${NO_TTY}" == "1" ]] || ! [[ -e /dev/tty ]] || ! [[ -r /dev/tty ]]; then
    printf '%s' "${default}"
    return 0
  fi
  printf '%s' "${prompt}" >/dev/tty 2>/dev/null || {
    printf '%s' "${default}"
    return 0
  }
  if read -r -t "${timeout}" answer </dev/tty 2>/dev/null; then
    if [[ -z "${answer}" ]]; then
      printf '%s' "${default}"
    else
      printf '%s' "${answer}"
    fi
  else
    printf '%s' "${default}"
  fi
}

# G6.1 F3: transaction journal helpers.
# Journal format (.sfs-local/migrate-tx/<ts>.jsonl, JSONL):
#   {"op":"<migrate|archive|delete|skip>","src":"<path>","dest":"<path|null>","archive":"<path|null>","ts":"<UTC>"}
init_journal() {
  local ts="$1"
  TX_JOURNAL=".sfs-local/migrate-tx/${ts}.jsonl"
  mkdir -p "$(dirname "${TX_JOURNAL}")"
  : > "${TX_JOURNAL}"
}

journal_append() {
  local op="$1" src="${2:-}" dest="${3:-}" archive="${4:-}"
  [[ -n "${TX_JOURNAL}" ]] || return 0
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local dest_json="null" archive_json="null"
  [[ -n "${dest}" ]]    && dest_json="\"$(json_escape "${dest}")\""
  [[ -n "${archive}" ]] && archive_json="\"$(json_escape "${archive}")\""
  printf '{"op":"%s","src":"%s","dest":%s,"archive":%s,"ts":"%s"}\n' \
    "${op}" "$(json_escape "${src}")" "${dest_json}" "${archive_json}" "${ts}" \
    >> "${TX_JOURNAL}"
}

# Reverse-replay journal: remove created destinations + archive files.
# Source restoration is handled separately by snapshot restore.
journal_replay_cleanup() {
  local journal="$1"
  [[ -f "${journal}" ]] || return 0
  # Reverse iterate (later ops cleaned first). awk for portability (no tac on macOS).
  local reversed
  reversed=$(awk '{a[NR]=$0} END {for(i=NR;i>0;i--) print a[i]}' "${journal}")
  while IFS= read -r line; do
    [[ -n "${line}" ]] || continue
    local op dest archive parent
    op=$(json_get_string "op" "${line}")
    dest=$(json_get_string "dest" "${line}")
    archive=$(json_get_string "archive" "${line}")
    case "${op}" in
      migrate)
        if [[ -n "${dest}" ]]; then
          rm -f "${dest}" 2>/dev/null || true
          # G6.1.1 HB1 — rmdir empty parent dirs left behind after rm.
          parent="$(dirname "${dest}")"
          while [[ -n "${parent}" ]] && [[ "${parent}" != "." ]] && [[ "${parent}" != "/" ]]; do
            rmdir "${parent}" 2>/dev/null || break
            parent="$(dirname "${parent}")"
          done
        fi
        ;;
      archive)
        if [[ -n "${dest}" ]]; then
          rm -f "${dest}" 2>/dev/null || true
          parent="$(dirname "${dest}")"
          while [[ -n "${parent}" ]] && [[ "${parent}" != "." ]] && [[ "${parent}" != "/" ]]; do
            rmdir "${parent}" 2>/dev/null || break
            parent="$(dirname "${parent}")"
          done
        fi
        if [[ -n "${archive}" ]]; then
          rm -f "${archive}" 2>/dev/null || true
        fi
        ;;
      delete|skip)
        : # snapshot restore handles src — no created destination to remove.
        ;;
    esac
  done <<< "${reversed}"
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

# Compute the migration dest for a given source path, using same rules as build_source_matrix.
# Empty output if path not under .sfs-local/sprints/ or sprints/.
compute_migrate_dest() {
  local path="$1"
  local rel="" sid="" rest="" feat="default" rest_in_feat=""
  if [[ "${path}" == .sfs-local/sprints/* ]]; then
    rel="${path#.sfs-local/sprints/}"
  elif [[ "${path}" == sprints/* ]]; then
    rel="${path#sprints/}"
  else
    return 0
  fi
  sid="${rel%%/*}"
  rest="${rel#*/}"
  [[ "${rest}" != "${rel}" ]] || rest=""
  rest_in_feat="${rest}"
  if [[ -n "${rest}" ]] && [[ "${rest}" == */* ]]; then
    feat="${rest%%/*}"
    rest_in_feat="${rest#*/}"
  fi
  printf '%s' ".solon/sprints/${sid}/${feat}/${rest_in_feat}"
}

# Apply migration plan (read TSV from stdin or via build_source_matrix).
# Options: $1=root, $2=mode (auto|interactive|apply)
# G6.1 F1: per-file prompts use prompt_user (/dev/tty), no stdin contention.
# G6.1 F3: every file op appended to TX_JOURNAL.
apply_migration() {
  local root="$1" ui_mode="$2"
  cd "${root}"
  local applied=0 skipped=0
  while IFS=$'\t' read -r src dest action reason; do
    [[ -n "${src}" ]] || continue
    case "${action}" in
      delete)
        rm -f "${src}"
        journal_append "delete" "${src}" "" ""
        ;;
      skip)
        journal_append "skip" "${src}" "" ""
        skipped=$((skipped + 1))
        continue
        ;;
      archive|migrate)
        local user_choice="k"
        if [[ "${ui_mode}" == "interactive" || "${ui_mode}" == "apply" ]]; then
          user_choice="$(prompt_user \
            "  [${action}] ${src} → ${dest} (${reason}) — keep/skip/edit? [k/s/e]: " \
            "k" 60)"
        fi
        case "${user_choice}" in
          s|skip|n)
            journal_append "skip" "${src}" "" ""
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
          journal_append "migrate" "${src}" "${dest}" ""
          rm -f "${src}"
        else
          # archive — gzip src to migrate-archive/, write stub at dest, rm src.
          mkdir -p ".sfs-local/archives/migrate-archive"
          local archive_path=".sfs-local/archives/migrate-archive/${src//\//__}.gz"
          gzip -c "${src}" > "${archive_path}"
          mkdir -p "$(dirname "${dest}")"
          printf 'archived: see %s\n' "${archive_path}" > "${dest}"
          journal_append "archive" "${src}" "${dest}" "${archive_path}"
          rm -f "${src}"
        fi
        applied=$((applied + 1))
        ;;
    esac
  done
  printf 'sfs-migrate-artifacts: applied=%d skipped=%d\n' "${applied}" "${skipped}"
}

# G6.1 F4: verify_no_data_loss real comparison (anti-AC10).
# Strict checks per manifest files[] entry:
#   1. Locate current path: src (intact) → migration dest → archive_path (gunzip stream).
#   2. Recompute sha256 + size, strict compare vs manifest expected values.
#   3. count: source_files (post-extension-filter) - skipped[] = post-state count.
#   4. mismatch ≥ 1 → exit 3 + stderr report.
verify_no_data_loss() {
  local root="$1" snapshot_dir="$2"
  cd "${root}"
  local manifest="${snapshot_dir}/manifest.json"
  [[ -f "${manifest}" ]] || { echo "verify_no_data_loss: no manifest at ${manifest}" >&2; return 3; }

  local mismatch_count=0 verified_count=0 missing_count=0
  local mismatches=""

  while IFS= read -r entry; do
    [[ -n "${entry}" ]] || continue
    local path expected_sha expected_size
    # G6.1.1 V1 — escape-aware extraction for path + sha256 (sha is hex but route
    # through json_get_string for symmetry); size_bytes is a JSON number, sed-safe.
    path=$(json_get_string "path" "${entry}")
    expected_sha=$(json_get_string "sha256" "${entry}")
    expected_size=$(printf '%s' "${entry}" | sed -nE 's/.*"size_bytes":([0-9]+).*/\1/p')
    [[ -n "${path}" ]] || continue
    [[ -n "${expected_sha}" ]] || continue

    # Locate current bytes — priority: archive_path (gunzip stream) → src (intact) → dest (migrated copy).
    # Archive checked first because archive action writes a *stub* to dest (97-byte stub != original content);
    # the real bytes only survive inside the gzip blob.
    local current="" actual_sha="" actual_size=""
    local archive_path=".sfs-local/archives/migrate-archive/${path//\//__}.gz"
    if [[ -f "${archive_path}" ]]; then
      actual_sha="$(gunzip -c "${archive_path}" 2>/dev/null | sha256_of_stream || echo "")"
      actual_size="$(gunzip -c "${archive_path}" 2>/dev/null | wc -c | tr -d ' ')"
      if [[ "${actual_sha}" == "${expected_sha}" ]] && [[ "${actual_size}" == "${expected_size}" ]]; then
        verified_count=$((verified_count + 1))
        continue
      else
        mismatches="${mismatches}MISMATCH ${path} (archived to ${archive_path}): sha expected=${expected_sha} actual=${actual_sha}, size expected=${expected_size} actual=${actual_size}"$'\n'
        mismatch_count=$((mismatch_count + 1))
        continue
      fi
    fi
    if [[ -f "${path}" ]]; then
      current="${path}"
    else
      local dest
      dest="$(compute_migrate_dest "${path}")"
      if [[ -n "${dest}" ]] && [[ -f "${dest}" ]]; then
        current="${dest}"
      else
        mismatches="${mismatches}MISSING: ${path} (not at src, dest=${dest:-<n/a>}, no archive)"$'\n'
        missing_count=$((missing_count + 1))
        mismatch_count=$((mismatch_count + 1))
        continue
      fi
    fi

    actual_sha="$(sha256_of "${current}" 2>/dev/null || echo "")"
    actual_size="$(stat -f%z "${current}" 2>/dev/null || stat -c%s "${current}" 2>/dev/null || echo 0)"

    if [[ "${actual_sha}" != "${expected_sha}" ]] || [[ "${actual_size}" != "${expected_size}" ]]; then
      mismatches="${mismatches}MISMATCH ${path} (now at ${current}): sha expected=${expected_sha} actual=${actual_sha}, size expected=${expected_size} actual=${actual_size}"$'\n'
      mismatch_count=$((mismatch_count + 1))
    else
      verified_count=$((verified_count + 1))
    fi
  done < <(emit_manifest_files_entries "${manifest}")

  local files_count
  files_count=$(emit_manifest_files_entries "${manifest}" | wc -l | tr -d ' ')

  printf 'verify_no_data_loss: files=%d verified=%d mismatch=%d missing=%d\n' \
    "${files_count}" "${verified_count}" "${mismatch_count}" "${missing_count}"

  if [[ "${mismatch_count}" -gt 0 ]]; then
    printf '%s' "${mismatches}" >&2
    return 3
  fi
  return 0
}

# ─── arg parse ────────────────────────────────────────────────────────────────

mode="interactive"
rollback_arg=""
backfill_force=0
snapshot_include_all=0
repo_root=""
recover_journal_arg=""
verify_snapshot_arg=""

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
    --recover)
      mode="recover"
      # Optional <ts> arg — peek next token; if it looks like a flag, no arg.
      if [[ $# -ge 2 ]] && [[ "${2:0:2}" != "--" ]] && [[ -n "${2:-}" ]]; then
        recover_journal_arg="$2"
        shift 2
      else
        shift
      fi
      ;;
    --verify-snapshot)
      mode="verify-snapshot"
      verify_snapshot_arg="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --verify-snapshot requires <ISO>" >&2; exit 2; }
      ;;
    --print-matrix) mode="print-matrix"; shift ;;
    --snapshot-include-all) snapshot_include_all=1; shift ;;
    --no-tty) NO_TTY="1"; shift ;;
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

# G6.1 F3: SIGINT/SIGTERM trap — atomic rollback (journal cleanup → snapshot restore → git status verify).
# G6.1.1 HB2 — disable trap re-entrancy at entry: a second SIGINT during cleanup
#              must not re-enter on_interrupt mid-flight.
# G6.1.1 V2 — `cp -a` snapshot restore failure is now a hard, visible error:
#              non-zero exit code 5 (SEVERE rollback incomplete) overrides the
#              normal signal exit (130/143). stderr inherits cp's error message.
on_interrupt() {
  local sig="${1:-INT}"
  trap '' INT TERM   # G6.1.1 HB2 — block re-entrant SIGINT/SIGTERM during cleanup.
  echo "${SCRIPT_NAME}: SIG${sig} received — atomic rollback triggered" >&2

  # Step 1: journal-based reverse cleanup (remove created destinations + archive files).
  if [[ -n "${TX_JOURNAL}" ]] && [[ -f "${TX_JOURNAL}" ]]; then
    echo "${SCRIPT_NAME}: journal cleanup — ${TX_JOURNAL}" >&2
    journal_replay_cleanup "${TX_JOURNAL}" || true
  fi

  # Step 2: snapshot restore (G6.1.1 V2 — non-zero exit on cp failure, no swallow).
  local restore_failed=0
  if [[ -n "${SNAPSHOT_FOR_INT}" ]] && [[ -d "${SNAPSHOT_FOR_INT}/files" ]]; then
    echo "${SCRIPT_NAME}: restoring from snapshot ${SNAPSHOT_FOR_INT}" >&2
    cd "${repo_root}"
    if ! cp -a "${SNAPSHOT_FOR_INT}/files/." . ; then
      echo "${SCRIPT_NAME}: SEVERE — snapshot restore failed; rollback INCOMPLETE — manual intervention required (snapshot kept at ${SNAPSHOT_FOR_INT})" >&2
      restore_failed=1
    fi
  fi

  # Step 3: working tree status verify (informational warning only).
  if git -C "${repo_root}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [[ -n "$(git -C "${repo_root}" status --porcelain 2>/dev/null)" ]]; then
      echo "${SCRIPT_NAME}: warning — working tree not clean after rollback (residual files may exist)" >&2
    fi
  fi

  # G6.1.1 V2 — SEVERE rollback failure (cp -a failed) overrides signal exit code.
  if [[ "${restore_failed}" == "1" ]]; then
    exit 5
  fi
  case "${sig}" in
    INT)  exit 130 ;;
    TERM) exit 143 ;;
    *)    exit 4 ;;
  esac
}
trap 'on_interrupt INT'  INT
trap 'on_interrupt TERM' TERM

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
    init_journal "${snapshot_iso}"
    SNAPSHOT_FOR_INT="$(make_snapshot "${repo_root}" "${snapshot_iso}" "${snapshot_include_all}")"
    printf 'sfs-migrate-artifacts: snapshot=%s, journal=%s, plan=%s files\n' \
      "${SNAPSHOT_FOR_INT}" "${TX_JOURNAL}" "${plan_count}"
    build_source_matrix "${repo_root}" | apply_migration "${repo_root}" interactive
    verify_no_data_loss "${repo_root}" "${SNAPSHOT_FOR_INT}"
    ;;

  apply)
    cd "${repo_root}"
    snapshot_iso="$(date -u +%Y%m%dT%H%M%SZ)"
    init_journal "${snapshot_iso}"
    SNAPSHOT_FOR_INT="$(make_snapshot "${repo_root}" "${snapshot_iso}" "${snapshot_include_all}")"
    plan_count="$(build_source_matrix "${repo_root}" | wc -l | tr -d ' ')"
    printf 'sfs-migrate-artifacts: --apply — Pass 1 propose %s file(s).\n' "${plan_count}"
    build_source_matrix "${repo_root}"
    confirm="$(prompt_user 'Confirm Pass 1? [y/N]: ' 'N' 60)"
    if [[ "${confirm}" =~ ^[Yy]$ ]]; then :; else
      echo "${SCRIPT_NAME}: --apply aborted (Pass 1 declined)" >&2
      exit 0
    fi
    build_source_matrix "${repo_root}" | apply_migration "${repo_root}" apply
    verify_no_data_loss "${repo_root}" "${SNAPSHOT_FOR_INT}"
    ;;

  auto)
    cd "${repo_root}"
    snapshot_iso="$(date -u +%Y%m%dT%H%M%SZ)"
    init_journal "${snapshot_iso}"
    SNAPSHOT_FOR_INT="$(make_snapshot "${repo_root}" "${snapshot_iso}" "${snapshot_include_all}")"
    plan_count="$(build_source_matrix "${repo_root}" | wc -l | tr -d ' ')"
    printf 'sfs-migrate-artifacts: --auto — applying %s file(s) unattended (snapshot=%s, journal=%s).\n' \
      "${plan_count}" "${SNAPSHOT_FOR_INT}" "${TX_JOURNAL}"
    if [[ "${plan_count}" -eq 0 ]]; then
      printf 'sfs-migrate-artifacts: no legacy sprints — exit 0.\n'
      exit 0
    fi
    build_source_matrix "${repo_root}" | apply_migration "${repo_root}" auto
    verify_no_data_loss "${repo_root}" "${SNAPSHOT_FOR_INT}"
    # Pass 1 6Q for missing-report-md sprints (AC3.4 deterministic informational).
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
    init_journal "${snapshot_iso}"
    SNAPSHOT_FOR_INT="$(make_snapshot "${repo_root}" "${snapshot_iso}" "${snapshot_include_all}")"
    if [[ "${backfill_force}" == "1" ]]; then
      printf 'sfs-migrate-artifacts: --backfill-legacy --force — converting %d 0.5.x sprint(s) (overwrite, snapshot=%s, journal=%s)\n' \
        "${converted}" "${SNAPSHOT_FOR_INT}" "${TX_JOURNAL}"
    else
      printf 'sfs-migrate-artifacts: --backfill-legacy — converting %d 0.5.x sprint(s) (snapshot=%s, journal=%s)\n' \
        "${converted}" "${SNAPSHOT_FOR_INT}" "${TX_JOURNAL}"
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

  recover)
    # G6.1 AC10.5: interrupted-midway recovery via transaction journal.
    cd "${repo_root}"
    target_journal=""
    if [[ -n "${recover_journal_arg}" ]]; then
      # Accept either bare ts or full path.
      if [[ -f "${recover_journal_arg}" ]]; then
        target_journal="${recover_journal_arg}"
      elif [[ -f ".sfs-local/migrate-tx/${recover_journal_arg}.jsonl" ]]; then
        target_journal=".sfs-local/migrate-tx/${recover_journal_arg}.jsonl"
      else
        echo "${SCRIPT_NAME}: --recover ${recover_journal_arg} not found (tried as path and as ts)" >&2
        exit 1
      fi
    else
      # Default: latest journal.
      target_journal="$(find .sfs-local/migrate-tx -maxdepth 1 -name '*.jsonl' -type f 2>/dev/null | sort -r | head -1)"
    fi
    if [[ -z "${target_journal}" ]] || [[ ! -f "${target_journal}" ]]; then
      echo "${SCRIPT_NAME}: --recover: no transaction journal found under .sfs-local/migrate-tx/" >&2
      exit 1
    fi
    journal_ts="$(basename "${target_journal}" .jsonl)"
    snapshot_dir=".sfs-local/archives/pre-migrate-${journal_ts}"
    printf '%s: --recover using journal=%s, snapshot=%s\n' "${SCRIPT_NAME}" "${target_journal}" "${snapshot_dir}"
    journal_replay_cleanup "${target_journal}"
    if [[ -d "${snapshot_dir}/files" ]]; then
      cp -a "${snapshot_dir}/files/." .
    else
      echo "${SCRIPT_NAME}: --recover: snapshot dir not found ${snapshot_dir}/files (journal-only cleanup)" >&2
    fi
    # Cleanliness check — tracked working tree must match HEAD (untracked migrate-tx /
    # archives/pre-migrate-* dirs are transient artifacts and OK to leave behind).
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      if ! git diff --quiet HEAD -- 2>/dev/null; then
        echo "${SCRIPT_NAME}: --recover: warning — tracked working tree differs from HEAD after recover" >&2
        git diff --stat HEAD -- >&2 || true
        exit 3
      fi
    fi
    printf '%s: --recover complete (tracked working tree matches HEAD)\n' "${SCRIPT_NAME}"
    ;;

  verify-snapshot)
    # G6.1 F4: standalone verify (negative test 용).
    snapshot_dir=".sfs-local/archives/pre-migrate-${verify_snapshot_arg}"
    if [[ ! -d "${snapshot_dir}" ]]; then
      # Allow user to pass full path too.
      if [[ -d "${verify_snapshot_arg}" ]]; then
        snapshot_dir="${verify_snapshot_arg}"
      else
        echo "${SCRIPT_NAME}: --verify-snapshot: snapshot dir not found ${snapshot_dir} (or as path ${verify_snapshot_arg})" >&2
        exit 1
      fi
    fi
    verify_no_data_loss "${repo_root}" "${snapshot_dir}"
    ;;
esac
exit 0
