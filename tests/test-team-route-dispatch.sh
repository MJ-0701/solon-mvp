#!/usr/bin/env bash
# Multi-agent team topology P3 — `sfs route` dispatch helper headline lock.
#
# AC (design §7 + P3 표면):
#   - route 가 registry.invoke 템플릿으로 호출 명령을 만든다(실호출은 dry-run mock):
#     role→runtime→invoke→{prompt}/{tools} 채움.
#   - transport_kind 를 바꾸면(argv→stdin) 전달 전략이 바뀌고 route.sh 코드는 불변
#     (SHA 동일) — transport 는 데이터.
#   - hop 상한 + role 순환은 거부(exit 8)한다.
#   - dispatch off(solo) 또는 registry 부재 시 crash 없이 "직접 수행"(exit 3)으로
#     degrade 한다 — standalone guarantee.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ROUTE="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-route.sh"
TEAM="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-team.sh"
MP_TEMPLATE="${DIST_DIR}/templates/.sfs-local-template/model-profiles.yaml"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${ROUTE}" ]] || fail "route helper not found: ${ROUTE}"
[[ -f "${TEAM}" ]] || fail "team resolver not found: ${TEAM}"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-route.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

MP="${TMP_DIR}/model-profiles.yaml"
cp "${MP_TEMPLATE}" "${MP}"
# A consumer model-profiles needs configuration.selected_runtime; the dist
# template ships a <DEFAULT-RUNTIME> placeholder — make it concrete.
if grep -q '<DEFAULT-RUNTIME>' "${MP}"; then
  if [[ "$(uname)" == "Darwin" ]]; then sed -i '' -e 's|<DEFAULT-RUNTIME>|current|g' "${MP}"
  else sed -i -e 's|<DEFAULT-RUNTIME>|current|g' "${MP}"; fi
fi

set_preset() {
  local p="$1"
  if [[ "$(uname)" == "Darwin" ]]; then sed -i '' -e "s|^team_preset:.*|team_preset: ${p}|" "${MP}"
  else sed -i -e "s|^team_preset:.*|team_preset: ${p}|" "${MP}"; fi
}
seed_trio_bindings() {
  awk '/^agent_runtime_bindings: \{\}/{print "agent_runtime_bindings:"; print "  lead: claude"; print "  worker: codex"; print "  researcher: antigravity"; next}{print}' "${MP}" > "${MP}.t" && mv "${MP}.t" "${MP}"
}

CAP="${TMP_DIR}/capsule.yaml"
cat > "${CAP}" <<'EOF'
goal: Add retry to the upload client
acceptance_criteria: unit test covers 3 retries with backoff
files_scope: src/upload/**
tools_allowed: read,edit,bash
output_paths: .sfs-local/handoff/result.md
token_budget: 50000
EOF

route() { SFS_MODEL_PROFILES="${MP}" SFS_ROUTE_DRY_RUN=1 bash "${ROUTE}" "$@"; }

set_preset trio
seed_trio_bindings

# ── 1) invoke-template call: lead→claude, worker→codex ──────────────────────
out_lead="$(route lead "${CAP}" 2>/dev/null)" || fail "route lead exited non-zero"
grep -Fq 'runtime=claude' <<<"${out_lead}"  || fail "lead not resolved to claude runtime"
grep -Fq 'transport=argv' <<<"${out_lead}"  || fail "lead transport not argv"
grep -Fq 'claude -p' <<<"${out_lead}"        || fail "lead command not built from claude invoke template"
grep -Fq 'Add retry to the upload client' <<<"${out_lead}" || fail "lead command missing capsule goal in {prompt}"
grep -Fq 'allowedTools read,edit,bash' <<<"${out_lead}"    || fail "lead command missing {tools} from capsule tools_allowed"

out_worker="$(route worker "${CAP}" 2>/dev/null)" || fail "route worker exited non-zero"
grep -Fq 'runtime=codex' <<<"${out_worker}" || fail "worker not resolved to codex"
grep -Fq 'codex exec' <<<"${out_worker}"    || fail "worker command not built from codex invoke template"

# ── 2) transport_kind is data: flip argv→stdin, delivery changes, code diff 0 ─
route_before="$(shasum "${ROUTE}" | awk '{print $1}')"
team_before="$(shasum "${TEAM}" | awk '{print $1}')"
# Flip ONLY the claude entry's transport_kind to stdin (data edit).
awk '
  /^  claude:/ { inc=1 }
  inc && /^  [a-z]/ && !/^  claude:/ { inc=0 }
  inc && /transport_kind:/ { sub(/transport_kind:.*/, "transport_kind: stdin") }
  { print }
' "${MP}" > "${MP}.t" && mv "${MP}.t" "${MP}"
[[ "$(SFS_MODEL_PROFILES="${MP}" bash "${TEAM}" resolve-transport claude)" == "stdin" ]] \
  || fail "transport flip not read back as stdin"
out_stdin="$(route lead "${CAP}" 2>/dev/null)" || fail "route lead (stdin) exited non-zero"
grep -Fq 'transport=stdin' <<<"${out_stdin}"     || fail "delivery did not switch to stdin after data flip"
grep -Fq 'delivery=stdin' <<<"${out_stdin}"      || fail "stdin delivery line missing"
grep -Fq 'route_dry_run stdin: GOAL: Add retry' <<<"${out_stdin}" || fail "prompt not delivered via stdin"
# claude -p {prompt} → {prompt} removed for stdin, so no inline goal in the command line.
cmd_line="$(grep -F 'route_dry_run command:' <<<"${out_stdin}")"
grep -Fq 'Add retry to the upload client' <<<"${cmd_line}" && fail "stdin command must not inline the prompt in argv"
[[ "$(shasum "${ROUTE}" | awk '{print $1}')" == "${route_before}" ]] || fail "OCP: route.sh changed to switch transport (should be data-only)"
[[ "$(shasum "${TEAM}" | awk '{print $1}')" == "${team_before}" ]]   || fail "OCP: resolver changed to switch transport (should be data-only)"
# restore claude transport for the remaining cases
awk '
  /^  claude:/ { inc=1 }
  inc && /^  [a-z]/ && !/^  claude:/ { inc=0 }
  inc && /transport_kind:/ { sub(/transport_kind:.*/, "transport_kind: argv") }
  { print }
' "${MP}" > "${MP}.t" && mv "${MP}.t" "${MP}"

# ── 3) guards: hop limit + role cycle → refuse (exit 8) ─────────────────────
if SFS_MODEL_PROFILES="${MP}" SFS_ROUTE_DRY_RUN=1 SFS_ROUTE_HOP=3 SFS_ROUTE_MAX_HOPS=3 \
     bash "${ROUTE}" lead "${CAP}" >/dev/null 2>&1; then
  fail "hop limit not enforced (expected non-zero exit)"
else
  rc=$?; [[ "${rc}" -eq 8 ]] || fail "hop limit wrong exit code: ${rc} (expected 8)"
fi
if SFS_MODEL_PROFILES="${MP}" SFS_ROUTE_DRY_RUN=1 SFS_ROUTE_CHAIN="lead" \
     bash "${ROUTE}" lead "${CAP}" >/dev/null 2>&1; then
  fail "role cycle not detected (expected non-zero exit)"
else
  rc=$?; [[ "${rc}" -eq 8 ]] || fail "cycle wrong exit code: ${rc} (expected 8)"
fi

# ── 4) standalone: solo → act-directly (exit 3), no crash ───────────────────
set_preset solo
if SFS_MODEL_PROFILES="${MP}" SFS_ROUTE_DRY_RUN=1 bash "${ROUTE}" lead "${CAP}" >/dev/null 2>&1; then
  fail "solo route should refuse with non-zero (dispatch off)"
else
  rc=$?; [[ "${rc}" -eq 3 ]] || fail "solo route wrong exit code: ${rc} (expected 3 = act directly)"
fi

# registry stripped entirely → still degrades to exit 3, never crashes.
set_preset trio   # non-solo, but registry removed below
awk '
  /^runtime_registry:/ { drop=1; next }
  drop && /^[[:space:]]/ { next }
  drop && /^[[:space:]]*#/ { next }
  drop && /^[[:space:]]*$/ { next }
  drop { drop=0 }
  { print }
' "${MP}" > "${MP}.t" && mv "${MP}.t" "${MP}"
if SFS_MODEL_PROFILES="${MP}" SFS_ROUTE_DRY_RUN=1 bash "${ROUTE}" lead "${CAP}" >/dev/null 2>&1; then
  fail "route with registry absent should refuse (act directly), not succeed"
else
  rc=$?; [[ "${rc}" -eq 3 ]] || fail "route with registry absent wrong exit: ${rc} (expected 3, never a crash)"
fi

echo "test-team-route-dispatch: OK"
