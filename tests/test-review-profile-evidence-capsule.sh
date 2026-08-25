#!/usr/bin/env bash
# Review bridge profile evidence follows Codex CPO precedence and source metadata.
#
# Contract:
# - explicit env vars > model-profiles > defaults
# - model and reasoning_effort resolve independently
# - source metadata is surfaced in prompt/evidence
# - fallback is gpt-5.5/xhigh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-review-profile-evidence.XXXXXX")"
FAKE_BIN="${TMP_DIR}/fake-bin"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

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

extract_review_field() {
  local file="$1" field="$2" line
  line="$(awk -v field="${field}" '$0 ~ ("- " field ":") {line=$0} END {print line}' "${file}")"
  awk -F'`' 'NF>=2 {print $2}' <<<"${line}"
}

run_codex_review_case() {
  local label="$1"
  local expected_model="$2"
  local expected_reasoning="$3"
  local expected_model_source="$4"
  local expected_reasoning_source="$5"
  local detected_model="$6"
  local detected_reasoning="$7"
  local env_model="$8"
  local env_reasoning="$9"
  local custom_cmd="${10:-}"
  local emit_profile_banner="${11:-1}"

  REVIEW_OUTPUT="$({
    PATH="${FAKE_BIN}:$PATH" \
      SFS_DIST_DIR="${DIST_DIR}" \
      SFS_CODEX_AUTH_READY=1 \
      SFS_COMMAND_TIMEOUT_SEC=0 \
      SFS_REVIEW_BRIDGE_PROBE_TIMEOUT_SEC=5 \
      SFS_REVIEW_EXECUTOR_TIMEOUT_SEC=0 \
      SFS_REVIEW_CODEX_MODEL="${env_model}" \
      SFS_REVIEW_CODEX_REASONING_EFFORT="${env_reasoning}" \
      SFS_REVIEW_CODEX_CMD="${custom_cmd}" \
      FAKE_CODEX_EXPECT_PROFILE_MODEL="${expected_model}" \
      FAKE_CODEX_EXPECT_PROFILE_REASONING="${expected_reasoning}" \
      FAKE_CODEX_EXPECT_PROFILE_MODEL_SOURCE="${expected_model_source}" \
      FAKE_CODEX_EXPECT_PROFILE_REASONING_SOURCE="${expected_reasoning_source}" \
      FAKE_CODEX_DETECTED_MODEL="${detected_model}" \
      FAKE_CODEX_DETECTED_REASONING="${detected_reasoning}" \
      FAKE_CODEX_EMIT_PROFILE_BANNER="${emit_profile_banner}" \
      bash "${SFS_BIN}" review --gate 3 --stage self --lens qa --executor codex --no-auth-interactive
  } 2>&1)"

  REVIEW_MD_PATH="${SPRINT_DIR}/review.md"
  PROMPT_PATH="$(extract_review_field "${REVIEW_MD_PATH}" "prompt_path")"
  PROFILE_EVIDENCE_PATH="$(extract_review_field "${REVIEW_MD_PATH}" "profile_evidence_path")"
  [[ -f "${PROMPT_PATH}" ]] || fail "${label}: missing prompt path ${PROMPT_PATH}"
  [[ -f "${PROFILE_EVIDENCE_PATH}" ]] || fail "${label}: missing profile evidence path ${PROFILE_EVIDENCE_PATH}"

  case "${REVIEW_OUTPUT}" in
    *"verdict: pass"*) ;;
    *)
      echo "${REVIEW_OUTPUT}" >&2
      fail "${label}: expected review pass output"
      ;;
  esac

  assert_contains "${PROMPT_PATH}" "- For Codex CPO/cross review, the requested review_high profile is ${expected_model} with ${expected_reasoning} reasoning." "${label}: prompt should include resolved Codex profile"
  assert_contains "${PROMPT_PATH}" "Codex review profile source: model=${expected_model_source}, effort=${expected_reasoning_source}" "${label}: prompt should include source metadata"
  assert_contains "${PROFILE_EVIDENCE_PATH}" "Evaluator executor/profile: codex" "${label}: profile evidence should identify Codex executor"
  assert_contains "${PROFILE_EVIDENCE_PATH}" "Expected model: ${expected_model}" "${label}: profile evidence should include expected model"
  assert_contains "${PROFILE_EVIDENCE_PATH}" "Expected reasoning effort: ${expected_reasoning}" "${label}: profile evidence should include expected reasoning"
  assert_contains "${PROFILE_EVIDENCE_PATH}" "Expected model source: ${expected_model_source}" "${label}: profile evidence should include model source"
  assert_contains "${PROFILE_EVIDENCE_PATH}" "Expected reasoning source: ${expected_reasoning_source}" "${label}: profile evidence should include reasoning source"
  assert_contains "${PROFILE_EVIDENCE_PATH}" "Detected model: ${detected_model}" "${label}: profile evidence should include detected model"
  assert_contains "${PROFILE_EVIDENCE_PATH}" "Detected reasoning effort: ${detected_reasoning}" "${label}: profile evidence should include detected reasoning"
  assert_contains "${PROFILE_EVIDENCE_PATH}" "Match status: matched" "${label}: profile evidence should be matched"
  assert_contains "${REVIEW_MD_PATH}" "profile_evidence_status: \`matched\`" "${label}: review.md should capture matched status"

  LAST_PROMPT_PATH="${PROMPT_PATH}"
  LAST_PROFILE_EVIDENCE_PATH="${PROFILE_EVIDENCE_PATH}"
}

run_scenario_setup() {
  mkdir -p "${FAKE_BIN}"
  cat > "${FAKE_BIN}/codex" <<'FAKE_CODEX'
#!/usr/bin/env bash
args=" $* "

case "${args}" in
  *" --sandbox read-only "*) ;;
  *)
    echo "missing read-only review sandbox: $*" >&2
    exit 40
    ;;
esac
case "${args}" in
  *" -c approval_policy=never "*) ;;
  *)
    echo "missing never approval policy: $*" >&2
    exit 41
    ;;
esac
case "${args}" in
  *" --full-auto "*|*" workspace-write "*)
    echo "write-enabled review bridge used: $*" >&2
    exit 42
    ;;
esac

result_path=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-last-message)
      result_path="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

prompt="$(cat)"
if [[ "${FAKE_CODEX_EMIT_PROFILE_BANNER:-1}" != "0" ]]; then
  printf 'model: %s\n' "${FAKE_CODEX_DETECTED_MODEL:-gpt-5.5}" >&2
  printf 'reasoning effort: %s\n' "${FAKE_CODEX_DETECTED_REASONING:-xhigh}" >&2
fi

if [[ "${prompt}" == "Solon SFS review bridge probe"* ]]; then
  printf 'SFS_REVIEW_BRIDGE_PROBE_OK\n'
  if [[ -n "${result_path}" ]]; then
    printf 'SFS_REVIEW_BRIDGE_PROBE_OK\n' > "${result_path}"
  fi
  exit 0
fi

for expected in \
  "For Codex CPO/cross review, the requested review_high profile is ${FAKE_CODEX_EXPECT_PROFILE_MODEL} with ${FAKE_CODEX_EXPECT_PROFILE_REASONING} reasoning." \
  "Codex review profile source: model=${FAKE_CODEX_EXPECT_PROFILE_MODEL_SOURCE}, effort=${FAKE_CODEX_EXPECT_PROFILE_REASONING_SOURCE}"; do
  if ! grep -Fq "${expected}" <<<"${prompt}"; then
    echo "missing expected prompt metadata: ${expected}" >&2
    exit 42
  fi
done

review_result="$(cat <<'RESULT'
Verdict: pass
Review lens: qa
Review independence risk: none
Artifact quality verdict:
- Profile bridge evidence was validated by SFS.
Evidence bundle verdict:
- ok
Evidence checked:
- SFS Executor Profile Bridge Evidence
Evidence gaps:
- none
Findings:
- none
Required CTO actions:
- none
Next action:
- continue
Final recommendation:
- pass
RESULT
)"
if [[ -n "${result_path}" ]]; then
  printf '%s\n' "${review_result}" > "${result_path}"
else
  printf '%s\n' "${review_result}"
fi
FAKE_CODEX
  chmod +x "${FAKE_BIN}/codex"
}

cd "${TMP_DIR}"
git init -q
printf '# Review Profile Evidence Project\n' > README.md
git add README.md

run_scenario_setup

git -c user.email='review-profile-evidence@solon.invalid' -c user.name='SFS Review Profile Evidence Test' commit -qm 'initial'

SFS_BIN="${DIST_DIR}/bin/sfs"
bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
bash "${SFS_BIN}" start "review profile evidence capsule" >/dev/null 2>&1
sprint_id="$(cat .sfs-local/current-sprint)"
SPRINT_DIR=".sfs-local/sprints/${sprint_id}"
MODEL_PROFILES=".sfs-local/model-profiles.yaml"
PROMPT_PATH=""
PROFILE_EVIDENCE_PATH=""

cat > "${SPRINT_DIR}/plan.md" <<'PLAN'
---
phase: plan
status: ready-for-review
---

# Plan

Acceptance criteria:
- Profile resolution and evidence metadata must follow env > local profile > defaults.
PLAN

# 1) Env vars should win for both fields.
cat > "${MODEL_PROFILES}" <<'YAML'
runtime_model_settings:
  codex:
    review_high:
      model: codex-profile-model
      reasoning_effort: profile-reasoning
YAML
run_codex_review_case \
  "env precedence" \
  "env-model" "env-reasoning" \
  "env" "env" \
  "env-model" "env-reasoning" \
  "env-model" "env-reasoning"

# 2) Profile should be used when env vars are not set.
cat > "${MODEL_PROFILES}" <<'YAML'
runtime_model_settings:
  codex:
    review_high:
      model: profile-model-7
      reasoning_effort: profile-reasoning-7
YAML
run_codex_review_case \
  "profile precedence" \
  "profile-model-7" "profile-reasoning-7" \
  "profile" "profile" \
  "profile-model-7" "profile-reasoning-7" \
  "" ""

# 3) Missing file should fallback to gpt-5.5/xhigh.
rm -f "${MODEL_PROFILES}"
run_codex_review_case \
  "missing profile file fallback" \
  "gpt-5.5" "xhigh" \
  "default" "default" \
  "gpt-5.5" "xhigh" \
  "" ""

# 4) Missing profile block should also fallback per-field (review_high only absent).
cat > "${MODEL_PROFILES}" <<'YAML'
runtime_model_settings:
  codex:
    review_low:
      model: wrong-route-model
      reasoning_effort: wrong-route-reason
YAML
run_codex_review_case \
  "missing profile block fallback" \
  "gpt-5.5" "xhigh" \
  "default" "default" \
  "gpt-5.5" "xhigh" \
  "" ""

# 5) Resolve fields independently: model from profile, reasoning from default.
cat > "${MODEL_PROFILES}" <<'YAML'
runtime_model_settings:
  codex:
    review_high:
      model: profile-only-model
YAML
run_codex_review_case \
  "partial profile fallback" \
  "profile-only-model" "xhigh" \
  "profile" "default" \
  "profile-only-model" "xhigh" \
  "" ""

# 6) Probe banner values remain authoritative when they conflict with custom
# command --model/--effort flags.
custom_codex_cmd='codex exec --sandbox read-only -c approval_policy="never" --model cmd-flag-model --effort cmd-flag-reasoning --ephemeral --output-last-message "${RUN_RESULT}" -'
run_codex_review_case \
  "custom command banner authority" \
  "banner-model" "banner-reasoning" \
  "env" "env" \
  "banner-model" "banner-reasoning" \
  "banner-model" "banner-reasoning" \
  "${custom_codex_cmd}" "1"

# 7) Custom Codex command should backfill detected model/effort from flags when
# the bridge probe banner omits both fields.
custom_codex_cmd='codex exec --sandbox read-only -c approval_policy="never" --model cmd-flag-model --effort cmd-flag-reasoning --ephemeral --output-last-message "${RUN_RESULT}" -'
run_codex_review_case \
  "custom command flag fallback" \
  "cmd-flag-model" "cmd-flag-reasoning" \
  "env" "env" \
  "cmd-flag-model" "cmd-flag-reasoning" \
  "cmd-flag-model" "cmd-flag-reasoning" \
  "${custom_codex_cmd}" "0"

# 8) When the banner is missing and a custom command includes both
# --reasoning-effort and --effort, --reasoning-effort should win.
custom_codex_cmd='codex exec --sandbox read-only -c approval_policy="never" --model cmd-dual-flag-model --reasoning-effort preferred-reasoning --effort fallback-reasoning --ephemeral --output-last-message "${RUN_RESULT}" -'
run_codex_review_case \
  "custom command reasoning-effort precedence" \
  "cmd-dual-flag-model" "preferred-reasoning" \
  "env" "env" \
  "cmd-dual-flag-model" "preferred-reasoning" \
  "cmd-dual-flag-model" "preferred-reasoning" \
  "${custom_codex_cmd}" "0"

# 9) No cross-provider bleed-through (Codex should not read Claude settings).
cat > "${MODEL_PROFILES}" <<'YAML'
runtime_model_settings:
  claude:
    review_high:
      model: claude-profile-model
      reasoning_effort: claude-profile-reasoning
YAML
SFS_REVIEW_CLAUDE_EXPECTED_MODEL='opus-noise' SFS_REVIEW_CLAUDE_EXPECTED_EFFORT='high' \
  run_codex_review_case \
    "cross-provider leak guard" \
    "gpt-5.5" "xhigh" \
    "default" "default" \
    "gpt-5.5" "xhigh" \
    "" ""

unset SFS_REVIEW_CLAUDE_EXPECTED_MODEL
unset SFS_REVIEW_CLAUDE_EXPECTED_EFFORT

# Guard against accidental profile bleed in captured prompt/evidence metadata.
assert_not_contains "${PROMPT_PATH}" "opus-noise" "cross-provider leak guard: prompt should not include claude expected model"
assert_not_contains "${PROFILE_EVIDENCE_PATH}" "Expected model: opus-noise" "cross-provider leak guard: evidence should not include claude expected model"

echo "test-review-profile-evidence-capsule: OK"
