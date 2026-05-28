#!/usr/bin/env bash
# Token Diet 품질 전수조사: compact I/O 가 routine 표면에만 적용되고
# evidence/risk/raw-source traceability 가 사라지지 않는지 계약으로 고정한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DIST_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

scripts_dir="${DIST_DIR}/templates/.sfs-local-template/scripts"
bin_dir="${DIST_DIR}/bin"
common="${scripts_dir}/sfs-common.sh"
status="${scripts_dir}/sfs-status.sh"
start="${scripts_dir}/sfs-start.sh"
report="${scripts_dir}/sfs-report.sh"
windows_native="${bin_dir}/sfs.ps1"
verify_release="${REPO_ROOT}/scripts/verify-product-release.sh"
token_policy="${DIST_DIR}/templates/.sfs-local-template/context/policies/token-harness.md"
kernel="${DIST_DIR}/templates/.sfs-local-template/context/kernel.md"
fixture_test="${SCRIPT_DIR}/test-token-diet-compact-output.sh"

# Output-style implementation must stay on routine, low-risk surfaces.
output_style_hits="$(
  grep -RIl -E 'SFS_OUTPUT_STYLE|--output-style' "${bin_dir}" "${scripts_dir}" 2>/dev/null || true
)"
while IFS= read -r file; do
  [[ -n "${file}" ]] || continue
  rel="${file#${DIST_DIR}/}"
  case "${rel}" in
    bin/sfs.ps1|\
    templates/.sfs-local-template/scripts/sfs-common.sh|\
    templates/.sfs-local-template/scripts/sfs-status.sh|\
    templates/.sfs-local-template/scripts/sfs-start.sh|\
    templates/.sfs-local-template/scripts/sfs-report.sh)
      ;;
    *)
      fail "Token Diet output-style leaked into non-routine runtime surface: ${rel}"
      ;;
  esac
done <<EOF
${output_style_hits}
EOF

for guarded in \
  sfs-adopt.sh \
  sfs-brainstorm.sh \
  sfs-commit.sh \
  sfs-decision.sh \
  sfs-division.sh \
  sfs-implement.sh \
  sfs-loop.sh \
  sfs-plan.sh \
  sfs-retro.sh \
  sfs-review.sh \
  sfs-tidy.sh
do
  assert_not_contains "${scripts_dir}/${guarded}" "SFS_OUTPUT_STYLE" "${guarded} no env compact"
  assert_not_contains "${scripts_dir}/${guarded}" "--output-style" "${guarded} no output-style compact"
done

# Compact runtime output keeps trace-critical fields, just removes decoration.
assert_contains "${common}" "Keeps every status field explicit while removing decorative separators." "status compact quality comment"
assert_contains "${common}" "sprint=%s wu=%s gate=%s verdict=%s ahead=%s last_event=%s" "status compact fields"
assert_contains "${status}" "render_status_compact_line" "status compact helper"
assert_contains "${windows_native}" 'sprint=$sprint wu=$wu gate=$gateLabel verdict=$verdict ahead=$ahead last_event=$lastEvent' "windows compact fields"

assert_contains "${start}" "created=%s/ current_sprint=%s shared_docs=%s/<yyyyMMdd>/ step_docs=lazy" "start compact path fields"
assert_contains "${start}" "next=%s alt_simple=%s alt_hard=%s recommended=normal" "start compact next/alternatives"
assert_contains "${report}" "SFS_OUTPUT_STYLE=compact or --output-style compact prints one line while" "report output-style boundary"
assert_contains "${report}" "With --compact, marks report.md final and moves verbose workbench docs" "report compact archive semantics"
assert_contains "${report}" "report=%s compact=1 archive=%s workbench_archived=%s" "report final compact fields"
assert_contains "${report}" "report=%s compact=0" "report draft compact fields"

# Release verifier may hide successful smoke chatter, but must replay failure stdout/stderr.
if [[ -f "${verify_release}" ]]; then
  assert_contains "${verify_release}" "run_quiet()" "release verifier quiet helper"
  assert_contains "${verify_release}" 'out="${TMP_DIR}/${slug}.log"' "release verifier captured log"
  assert_contains "${verify_release}" "command failed; replaying captured stdout/stderr" "release verifier failure replay notice"
  assert_contains "${verify_release}" "sed 's/^/[verify-product-release]     /' \"\${out}\" >&2" "release verifier prefixed replay"
fi

# Agent/document policy keeps Token Diet subordinate to evidence and raw-source traceability.
assert_contains "${kernel}" "Compactness is never a pass condition" "kernel compact quality floor"
assert_contains "${kernel}" "verification results stay intact" "kernel verification retention"
assert_contains "${token_policy}" "Token savings is secondary to quality" "token policy quality priority"
assert_contains "${token_policy}" "raw source first" "token policy raw-source fallback"
assert_contains "${token_policy}" "do not compress; return to full clarity" "token policy full clarity fallback"
assert_contains "${token_policy}" "Do not force SFS-wide one-file-one-function/type rules" "token policy no filefunc transplant"

for adapter in \
  "${DIST_DIR}/templates/SFS.md.template" \
  "${DIST_DIR}/templates/codex-skill/SKILL.md" \
  "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md" \
  "${DIST_DIR}/templates/.claude/commands/sfs.md" \
  "${DIST_DIR}/templates/.gemini/commands/sfs.toml" \
  "${DIST_DIR}/templates/.codex/prompts/sfs.md" \
  "${DIST_DIR}/commands/sfs.toml" \
  "${DIST_DIR}/plugins/solon/commands/sfs.md"
do
  assert_contains "${adapter}" "Compact output is quality-preserving only" "adapter compact quality contract ${adapter}"
  assert_contains "${adapter}" "raw-source traceability" "adapter raw trace ${adapter}"
  assert_contains "${adapter}" "use full clarity" "adapter full clarity fallback ${adapter}"
done

# Negative fixtures prove the harness would reject compact text that dropped key evidence.
assert_contains "${fixture_test}" "bad-review-missing-evidence.compact.md" "negative review fixture enforced"
assert_contains "${fixture_test}" "bad-safety-missing-warning.compact.md" "negative safety fixture enforced"
assert_contains "${fixture_test}" "bad-decision-missing-alternatives.compact.md" "negative decision fixture enforced"

echo "test-token-diet-quality-audit: OK"
