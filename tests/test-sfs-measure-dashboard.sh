#!/usr/bin/env bash
# tests/test-sfs-measure-dashboard.sh — B4 local measure dashboard contract.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-measure.sh"
BIN="${DIST_DIR}/bin/sfs"
WIN_BIN="${DIST_DIR}/bin/sfs.ps1"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  grep -Fq -- "${needle}" "${file}" || {
    echo "FAIL: missing ${label}: ${needle}" >&2
    echo "--- ${file} ---" >&2
    cat "${file}" >&2
    exit 1
  }
}

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

fixture="${tmp}/fixture"
mkdir -p \
  "${fixture}/.sfs-local/sprints/sprint-alpha" \
  "${fixture}/.sfs-local/sprints/sprint-beta" \
  "${fixture}/.sfs-local/archives/events/sprints" \
  "${fixture}/.sfs-local/decisions"
fixture_real="$(cd -P "${fixture}" && pwd)"

cat > "${fixture}/.sfs-local/sprints/sprint-alpha/report.md" <<'EOF'
# sprint alpha

sfs_measure: saved_minutes=45 decision_count=2 token_count=1200 token_cost_usd=0.15 onboarding_ramp_minutes=12
EOF

cat > "${fixture}/.sfs-local/sprints/sprint-beta/retro.md" <<'EOF'
# sprint beta

sfs_measure: saved_minutes=30 decision_count=1 token_count=unknown token_cost_usd=unknown
EOF

cat > "${fixture}/.sfs-local/archives/events/sprints/sprint-alpha.jsonl" <<'EOF'
{"ts":"2026-06-01T09:00:00+09:00","type":"sprint_start","sprint_id":"sprint-alpha"}
{"ts":"2026-06-01T10:00:00+09:00","type":"sprint_close","sprint_id":"sprint-alpha"}
EOF

cat > "${fixture}/.sfs-local/events.jsonl" <<'EOF'
{"ts":"2026-06-02T10:00:00+09:00","type":"sprint_start","sprint_id":"sprint-beta"}
{"ts":"2026-06-02T12:00:00+09:00","type":"sprint_close","sprint_id":"sprint-beta"}
EOF

touch \
  "${fixture}/.sfs-local/decisions/0001-alpha.md" \
  "${fixture}/.sfs-local/decisions/0002-beta.md"

human_root="${tmp}/human-root.txt"
(
  cd "${fixture}"
  SFS_COMMAND_TIMEOUT_SEC=0 bash "${BIN}" measure > "${human_root}"
)
assert_contains "${human_root}" "SFS measure dashboard" "dashboard heading"
assert_contains "${human_root}" "sprints: 2" "sprint count"
assert_contains "${human_root}" "saved_minutes: 75" "saved minutes total"
assert_contains "${human_root}" "sprint_decisions: 3" "sprint decision total"
assert_contains "${human_root}" "project_decisions: 2" "project ADR fallback"
assert_contains "${human_root}" "token_count: unknown" "unknown token total"
assert_contains "${human_root}" "token_cost_usd: unknown" "unknown cost total"
assert_contains "${human_root}" "onboarding_ramp_minutes: 12" "onboarding ramp total"
assert_contains "${human_root}" "wu_cycle_count: 2" "wu cycle count from active+archived events"
assert_contains "${human_root}" "wu_cycle_avg_minutes: 90" "wu cycle average from active+archived events"
assert_contains "${human_root}" "agent_assisted_commits: unknown" "non-git commit ratio graceful"
assert_contains "${human_root}" "- sprint-alpha saved_minutes=45 decision_count=2 token_count=1200 token_cost_usd=0.15" "alpha row"
assert_contains "${human_root}" "- sprint-beta saved_minutes=30 decision_count=1 token_count=unknown token_cost_usd=unknown" "beta row"

human_override="${tmp}/human-override.txt"
bash "${SCRIPT}" --root "${fixture}" > "${human_override}"
assert_contains "${human_override}" "root: ${fixture_real}" "--root output"
assert_contains "${human_override}" "saved_minutes: 75" "--root saved minutes"

json_out="${tmp}/measure.json"
bash "${SCRIPT}" --json --root "${fixture}" > "${json_out}"
assert_contains "${json_out}" '"generated_from": {' "json generated_from"
assert_contains "${json_out}" '"totals": {' "json totals"
assert_contains "${json_out}" '"saved_minutes": 75' "json saved minutes"
assert_contains "${json_out}" '"sprint_decisions": 3' "json sprint decisions"
assert_contains "${json_out}" '"project_decisions": 2' "json project decisions"
assert_contains "${json_out}" '"token_count": null' "json unknown token"
assert_contains "${json_out}" '"token_count_known": false' "json token known false"
assert_contains "${json_out}" '"token_cost_usd": null' "json unknown cost"
assert_contains "${json_out}" '"token_cost_known": false' "json cost known false"
assert_contains "${json_out}" '"onboarding_ramp_minutes": 12' "json onboarding ramp"
assert_contains "${json_out}" '"onboarding_ramp_known": true' "json onboarding known"
assert_contains "${json_out}" '"wu_cycle_count": 2' "json wu cycle count"
assert_contains "${json_out}" '"wu_cycle_total_minutes": 180' "json wu cycle total"
assert_contains "${json_out}" '"wu_cycle_avg_minutes": 90' "json wu cycle average"
assert_contains "${json_out}" '"agent_commits_total": 0' "json non-git commit total"
assert_contains "${json_out}" '"agent_assisted_commits": 0' "json non-git assisted commits"
assert_contains "${json_out}" '"agent_assisted_commit_ratio": null' "json non-git commit ratio"
assert_contains "${json_out}" '{"id":"sprint-alpha","saved_minutes":45,"decision_count":2,"token_count":1200,"token_count_known":true,"token_cost_usd":0.15,"token_cost_known":true}' "json alpha row"
assert_contains "${json_out}" '{"id":"sprint-beta","saved_minutes":30,"decision_count":1,"token_count":null,"token_count_known":false,"token_cost_usd":null,"token_cost_known":false}' "json beta row"

known="${tmp}/known"
mkdir -p "${known}/.sfs-local/sprints/sprint-known"
cat > "${known}/.sfs-local/sprints/sprint-known/log.md" <<'EOF'
# sprint known

sfs_measure: saved_minutes=5 decision_count=1 token_count=100 token_cost_usd=0.10
sfs_measure: saved_minutes=6 decision_count=2 token_count=200 token_cost_usd=0.25
EOF
known_human="${tmp}/known-human.txt"
bash "${SCRIPT}" --root "${known}" > "${known_human}"
assert_contains "${known_human}" "saved_minutes: 11" "known additive saved"
assert_contains "${known_human}" "sprint_decisions: 3" "known additive decisions"
assert_contains "${known_human}" "token_count: 300" "known additive tokens"
assert_contains "${known_human}" "token_cost_usd: 0.35" "known additive cost"
assert_contains "${known_human}" "- sprint-known saved_minutes=11 decision_count=3 token_count=300 token_cost_usd=0.35" "known additive row"

known_json="${tmp}/known.json"
bash "${SCRIPT}" --json --root "${known}" > "${known_json}"
assert_contains "${known_json}" '"token_count": 300' "known json tokens"
assert_contains "${known_json}" '"token_count_known": true' "known json token known"
assert_contains "${known_json}" '"token_cost_usd": 0.35' "known json cost"
assert_contains "${known_json}" '"token_cost_known": true' "known json cost known"

missing_fields="${tmp}/missing-fields"
mkdir -p "${missing_fields}/.sfs-local/sprints/sprint-missing"
cat > "${missing_fields}/.sfs-local/sprints/sprint-missing/report.md" <<'EOF'
# sprint missing fields

sfs_measure: saved_minutes=7 decision_count=1
EOF
missing_human="${tmp}/missing-human.txt"
bash "${SCRIPT}" --root "${missing_fields}" > "${missing_human}"
assert_contains "${missing_human}" "saved_minutes: 7" "missing field saved"
assert_contains "${missing_human}" "sprint_decisions: 1" "missing field decisions"
assert_contains "${missing_human}" "token_count: unknown" "missing token unknown"
assert_contains "${missing_human}" "token_cost_usd: unknown" "missing cost unknown"

empty="${tmp}/empty"
mkdir -p "${empty}/.sfs-local"
empty_human="${tmp}/empty-human.txt"
bash "${SCRIPT}" --root "${empty}" > "${empty_human}"
assert_contains "${empty_human}" "sprints: 0" "empty sprint count"
assert_contains "${empty_human}" "saved_minutes: 0" "empty saved minutes"
assert_contains "${empty_human}" "project_decisions: 0" "empty project decisions"
assert_contains "${empty_human}" "token_count: unknown" "empty token unknown"
assert_contains "${empty_human}" "onboarding_ramp_minutes: unknown" "empty onboarding unknown"
assert_contains "${empty_human}" "wu_cycle_count: 0" "empty wu cycle count"
assert_contains "${empty_human}" "wu_cycle_avg_minutes: unknown" "empty wu cycle average"
assert_contains "${empty_human}" "agent_assisted_commits: unknown" "empty non-git commit ratio unknown"

empty_json="${tmp}/empty.json"
bash "${SCRIPT}" --json --root "${empty}" > "${empty_json}"
assert_contains "${empty_json}" '"saved_minutes": 0' "empty json saved"
assert_contains "${empty_json}" '"project_decisions": 0' "empty json decisions"
assert_contains "${empty_json}" '"onboarding_ramp_minutes": null' "empty json onboarding unknown"
assert_contains "${empty_json}" '"wu_cycle_count": 0' "empty json wu cycle count"
assert_contains "${empty_json}" '"wu_cycle_avg_minutes": null' "empty json wu cycle average"
assert_contains "${empty_json}" '"agent_assisted_commit_ratio": null' "empty json agent ratio unknown"
assert_contains "${empty_json}" '"sprints": [' "empty json sprints field"
assert_contains "${empty_json}" '  ]' "empty json empty list"

git_fixture="${tmp}/git-fixture"
mkdir -p "${git_fixture}/.sfs-local"
(
  cd "${git_fixture}"
  git init -q
  git config user.name "Human Owner"
  git config user.email "owner@example.invalid"
  printf 'one\n' > one.txt
  git add one.txt
  git commit -q -m "manual baseline"
  printf 'two\n' > two.txt
  git add two.txt
  GIT_AUTHOR_NAME="Codex Worker" GIT_AUTHOR_EMAIL="codex@example.invalid" \
    git commit -q -m "feat: assisted slice"
  printf 'three\n' > three.txt
  git add three.txt
  git commit -q -m "SFS release 상태 기록"
)

git_human="${tmp}/git-human.txt"
bash "${SCRIPT}" --root "${git_fixture}" > "${git_human}"
assert_contains "${git_human}" "agent_assisted_commits: 1/3 (0.3333)" "git agent-assisted commit ratio"

git_json="${tmp}/git.json"
bash "${SCRIPT}" --json --root "${git_fixture}" > "${git_json}"
assert_contains "${git_json}" '"agent_commits_total": 3' "json git commit total"
assert_contains "${git_json}" '"agent_assisted_commits": 1' "json git assisted commits"
assert_contains "${git_json}" '"agent_assisted_commit_ratio": 0.3333' "json git assisted ratio"

help_out="${tmp}/help.txt"
bash "${SCRIPT}" --help > "${help_out}"
assert_contains "${help_out}" 'sfs-measure.sh [--json] [--root <dir>]' "script help dashboard"
assert_contains "${help_out}" 'sfs-measure.sh --alive [--step <name>] [--threshold <secs>] -- <command> [args...]' "script help alive"

assert_contains "${BIN}" 'measure [--json] [--root <dir>]' "shell wrapper dashboard usage"
assert_contains "${BIN}" 'measure --alive -- <command>' "shell wrapper alive usage"
assert_contains "${WIN_BIN}" 'measure [--json] [--root <dir>]' "windows wrapper dashboard usage"
assert_contains "${WIN_BIN}" 'measure --alive -- <command>' "windows wrapper alive usage"

if grep -Eq '\b(curl|wget|gh|brew|scoop)\b|git[[:space:]]+(push|tag)' "${SCRIPT}"; then
  fail "measure dashboard must not call network/billing/release mutation tools"
fi

echo "test-sfs-measure-dashboard: OK"
