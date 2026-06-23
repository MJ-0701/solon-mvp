#!/usr/bin/env bash
# Multi-agent team topology — OCP regression lock (AC2 + AC3).
#
# OCP 1원칙: role↔runtime binding 과 runtime별 CLI 호출 방법은 데이터다. 역할
# 재배치와 새 CLI 추가는 config edit only — 분기 코드 수정 0. 본 테스트는 그
# 불변을 잠근다. 어떤 .sh resolver 도 수정하지 않고, model-profiles.yaml 데이터만
# 바꿔서 resolution 결과가 바뀌는지 검증한다.
#
#   AC2 — agent_runtime_bindings.lead 한 줄 변경 → resolve-runtime 결과가 바뀜.
#   AC3 — runtime_registry 에 4번째 runtime 추가 + binding 지정 → resolve-invoke
#         가 그 invoke 템플릿을 그대로 돌려줌.
#   추가 — resolver 스크립트 자체는 본 테스트 동안 한 글자도 안 바뀜(데이터-only).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
RESOLVER_SRC="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-team.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${RESOLVER_SRC}" ]] || fail "resolver not found: ${RESOLVER_SRC}"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-team-ocp.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "team-ocp@solon.invalid"
git config user.name "Solon Team OCP Test"
printf '# team ocp\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

MP=".sfs-local/model-profiles.yaml"
[[ -f "${MP}" ]] || fail "init did not produce ${MP}"
# Resolver runs from the global runtime (thin layout does not vendor scripts);
# invoke the dist template script directly with cwd = consumer project root.
RESOLVER="${RESOLVER_SRC}"

# Snapshot resolver source to prove the "code diff 0" claim at the end.
resolver_before="$(sha256sum "${RESOLVER}" | awk '{print $1}')"

# Force a non-solo binding surface so resolution is binding-driven, then assert.
# (Default install is solo; we edit DATA only — this is exactly the config-edit
#  extension point the OCP principle promises.)

# Pure-bash rewrite of the lead binding line (no python dependency).
set_lead_binding() {
  local rt="$1"
  awk -v rt="${rt}" '
    /^agent_runtime_bindings:/ { inb=1 }
    inb && /^[[:space:]]+lead:[[:space:]]/ {
      sub(/lead:[[:space:]].*/, "lead:        " rt)
    }
    inb && /^[A-Za-z_]/ && !/^agent_runtime_bindings:/ { inb=0 }
    { print }
  ' "${MP}" > "${MP}.tmp" && mv "${MP}.tmp" "${MP}"
}

# Seed an explicit trio binding block so lead/worker/researcher are bound.
seed_trio_bindings() {
  awk '
    /^agent_runtime_bindings:/ { print "agent_runtime_bindings:"; print "  lead:        claude"; print "  worker:      codex"; print "  researcher:  antigravity"; skip=1; next }
    skip && /^[[:space:]]+[A-Za-z_]+:[[:space:]]/ { next }
    skip && /^[[:space:]]*#/ { next }
    skip && /^[[:space:]]*$/ { next }
    skip { skip=0 }
    { print }
  ' "${MP}" > "${MP}.tmp" && mv "${MP}.tmp" "${MP}"
}

grep -q '^agent_runtime_bindings:' "${MP}" || fail "schema missing: agent_runtime_bindings"
grep -q '^runtime_registry:' "${MP}" || fail "schema missing: runtime_registry"
grep -q '^team_preset:' "${MP}" || fail "schema missing: team_preset"
grep -q '^unassigned_role_policy:' "${MP}" || fail "schema missing: unassigned_role_policy"

seed_trio_bindings

# ── AC2: lead binding drives resolved runtime (data-only) ──────────────────
set_lead_binding "claude"
got="$(bash "${RESOLVER}" resolve-runtime lead)"
[[ "${got}" == "claude" ]] || fail "AC2: expected lead→claude, got '${got}'"

set_lead_binding "codex"
got="$(bash "${RESOLVER}" resolve-runtime lead)"
[[ "${got}" == "codex" ]] || fail "AC2: one-line lead edit did not re-route (expected codex, got '${got}')"

# ── AC3: add a 4th (fake) runtime to the registry, route lead to it, and
#         assert resolve-invoke returns THAT invoke template verbatim ───────
FAKE_INVOKE='mycli run {prompt} --json'
cat >> "${MP}" <<EOF

# appended by test — 4th runtime, pure data extension point
EOF
# Insert a new registry entry under runtime_registry without touching code.
awk -v inv="${FAKE_INVOKE}" '
  /^runtime_registry:/ {
    print
    print "  mnewcli:"
    print "    invoke: \"" inv "\""
    print "    capabilities: [code]"
    print "    models_ref: claude"
    next
  }
  { print }
' "${MP}" > "${MP}.tmp" && mv "${MP}.tmp" "${MP}"

set_lead_binding "mnewcli"
got="$(bash "${RESOLVER}" resolve-runtime lead)"
[[ "${got}" == "mnewcli" ]] || fail "AC3: lead not routed to 4th runtime (got '${got}')"

got_invoke="$(bash "${RESOLVER}" resolve-invoke mnewcli)"
[[ "${got_invoke}" == "${FAKE_INVOKE}" ]] || \
  fail "AC3: 4th runtime invoke template not used. expected '${FAKE_INVOKE}', got '${got_invoke}'"

# Resolve-invoke for an existing runtime returns its declared template too.
claude_invoke="$(bash "${RESOLVER}" resolve-invoke claude)"
[[ "${claude_invoke}" == *"claude -p"* ]] || \
  fail "AC3: claude invoke template not read from registry (got '${claude_invoke}')"

# Every declared default runtime resolves to a non-empty invoke — including
# entries whose header line carries an inline comment (antigravity, gemini).
for rt in claude codex antigravity gemini; do
  inv="$(bash "${RESOLVER}" resolve-invoke "${rt}")"
  [[ -n "${inv}" ]] || fail "AC3: registry runtime '${rt}' has empty invoke (comment-header parse bug?)"
done
agy_invoke="$(bash "${RESOLVER}" resolve-invoke antigravity)"
[[ "${agy_invoke}" == *"agy -p"* ]] || \
  fail "AC3: antigravity (commented header) invoke not read (got '${agy_invoke}')"

# ── code diff 0: resolver source unchanged across all of the above ─────────
resolver_after="$(sha256sum "${RESOLVER}" | awk '{print $1}')"
[[ "${resolver_before}" == "${resolver_after}" ]] || \
  fail "OCP violated: resolver source changed (only data should change)"

echo "test-team-runtime-ocp: OK"
