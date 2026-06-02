#!/usr/bin/env bash
# solon-product#7 — reviewer-tier enforcement regression lock.
#
# The CPO/cross-review reviewer model is ENFORCED, not a soft target. Codex
# quota exhaustion must not silently fall back to a sub-tier Gemini (2.5-pro);
# the qualifying signal is the invocation --model flag / route pin, NOT the
# reviewer's self-named model in the body (preview models can self-name a
# sibling version). This test locks:
#   A) default Gemini bridge whose CLI cannot apply --model  → review STOPS
#   B) explicit Gemini cmd NOT pinning the route model        → review STOPS
#   C) explicit Gemini cmd pinning the route model            → review PROCEEDS,
#      passes despite a body that self-names "gemini-2.5-pro" (text ignored),
#      and emits a reviewer model_resolved event flowcheck accepts
#   D) flowcheck: reviewer event resolved_model != route       → CRIT (exit 8)
#   E) flowcheck: reviewer event source=current (host default) → CRIT (exit 8)
#   F) flowcheck: reviewer event missing route_model           → CRIT (exit 8)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
ROUTE="gemini-3.1-pro-preview"

fail() { echo "FAIL: $*" >&2; exit 1; }

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-reviewer-tier.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "reviewer-tier@solon.invalid"
git config user.name "Solon Reviewer Tier Test"
printf '# reviewer tier\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "reviewer tier enforcement" >/dev/null 2>&1
sprint_id="$(cat .sfs-local/current-sprint)"
sprint_dir=".sfs-local/sprints/${sprint_id}"
cat > "${sprint_dir}/plan.md" <<'PLAN'
---
phase: plan
status: ready-for-review
---

# Plan

Acceptance criteria:
- Reviewer model must be the enforced review_high route, not a sub-tier fallback.
PLAN

fake_bin="${TMP_DIR}/fake-bin"
mkdir -p "${fake_bin}"

# A Gemini CLI whose --help does NOT advertise --model (cannot pin the route).
cat > "${fake_bin}/gemini" <<'FAKE_NOMODEL'
#!/usr/bin/env bash
if [[ "${1:-}" == "--help" ]]; then
  echo "Usage: gemini [--skip-trust] [--output-format text] -p <prompt>"
  exit 0
fi
# If ever invoked for a real review it would silently serve a default model.
echo "Verdict: pass"
FAKE_NOMODEL
chmod +x "${fake_bin}/gemini"

run_review() {
  set +e
  REVIEW_OUT="$(
    PATH="${fake_bin}:${PATH}" SFS_GEMINI_AUTH_READY=1 \
      SFS_COMMAND_TIMEOUT_SEC=0 SFS_REVIEW_BRIDGE_PROBE_TIMEOUT_SEC=5 \
      SFS_REVIEW_EXECUTOR_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" \
      bash "${SFS_BIN}" review --gate 6 --stage self --lens qa --executor gemini --no-auth-interactive "$@" 2>&1
  )"
  REVIEW_RC=$?
  set -e
}

# ── A) default bridge, CLI lacks --model → STOP, not a silent pass ──────────
run_review
[[ "${REVIEW_RC}" -ne 0 ]] || fail "A: unpinnable Gemini route should stop the review, got rc=0: ${REVIEW_OUT}"
grep -q "reviewer-tier enforcement (solon-product#7)" <<<"${REVIEW_OUT}" \
  || fail "A: should surface reviewer-tier enforcement stop: ${REVIEW_OUT}"
grep -qi "verdict: pass" <<<"${REVIEW_OUT}" \
  && fail "A: a sub-tier-capable review must not produce a pass verdict: ${REVIEW_OUT}"

# ── B) explicit cmd that does NOT pin the route model → STOP ────────────────
SFS_REVIEW_GEMINI_CMD_UNPINNED='cat'
run_review_env() {
  set +e
  REVIEW_OUT="$(
    PATH="${fake_bin}:${PATH}" SFS_GEMINI_AUTH_READY=1 \
      SFS_REVIEW_GEMINI_CMD="$1" \
      SFS_COMMAND_TIMEOUT_SEC=0 SFS_REVIEW_BRIDGE_PROBE_TIMEOUT_SEC=5 \
      SFS_REVIEW_EXECUTOR_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" \
      bash "${SFS_BIN}" review --gate 6 --stage self --lens qa --executor gemini --no-auth-interactive 2>&1
  )"
  REVIEW_RC=$?
  set -e
}
run_review_env "gemini --skip-trust --output-format text -p \"\$(cat)\""
[[ "${REVIEW_RC}" -ne 0 ]] || fail "B: explicit cmd not pinning the route should stop, got rc=0: ${REVIEW_OUT}"
grep -q "reviewer-tier enforcement (solon-product#7)" <<<"${REVIEW_OUT}" \
  || fail "B: should surface reviewer-tier enforcement stop for unpinned override: ${REVIEW_OUT}"

# ── B2) comment-bypass: route name only in a comment, real --model is sub-tier ─
# The route token appears (in a comment) but the actual --model value is 2.5-pro.
# A naive substring check would pass this; --model value extraction must stop it.
run_review_env "gemini --skip-trust --model gemini-2.5-pro -p \"\$(cat)\" # ${ROUTE}"
[[ "${REVIEW_RC}" -ne 0 ]] || fail "B2: comment-bypass (real --model sub-tier) should stop, got rc=0: ${REVIEW_OUT}"
grep -q "reviewer-tier enforcement (solon-product#7)" <<<"${REVIEW_OUT}" \
  || fail "B2: should surface stop when the real --model value is a sub-tier model: ${REVIEW_OUT}"

# ── C) explicit cmd pinning the route → PROCEEDS; body self-name ignored ────
# Fake reviewer that self-names a SUB-TIER model in the body. Enforcement must
# ignore the body text and accept the run because the cmd pins the route model.
cat > "${fake_bin}/fakegemini" <<'FAKE_REVIEWER'
#!/usr/bin/env bash
prompt="$(cat)"
case "${prompt}" in
  "Solon SFS review bridge probe"*) printf 'SFS_REVIEW_BRIDGE_PROBE_OK\n'; exit 0 ;;
esac
cat <<'R'
Model: I am actually gemini-2.5-pro (self-reported, must be ignored by SFS).
Verdict: pass
Review lens: qa
Review independence risk: none
Artifact quality verdict:
- Reviewer ran on the enforced route per SFS, regardless of self-naming.
Evidence bundle verdict:
- ok
Evidence checked:
- plan.md
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
R
FAKE_REVIEWER
chmod +x "${fake_bin}/fakegemini"

# A quoted --model value (=form and quoted) must be accepted, not false-stopped.
run_review_env "${fake_bin}/fakegemini --model=\"${ROUTE}\""
[[ "${REVIEW_RC}" -eq 0 ]] || fail "C0: quoted --model=\"route\" should be accepted, got rc=${REVIEW_RC}: ${REVIEW_OUT}"

run_review_env "${fake_bin}/fakegemini --model ${ROUTE}"
[[ "${REVIEW_RC}" -eq 0 ]] || fail "C: route-pinned review should pass, got rc=${REVIEW_RC}: ${REVIEW_OUT}"
grep -qi "verdict: pass" <<<"${REVIEW_OUT}" \
  || fail "C: route-pinned review should record pass despite sub-tier self-name: ${REVIEW_OUT}"

events_file=".sfs-local/events.jsonl"
[[ -f "${events_file}" ]] || fail "C: events.jsonl should exist after review"
grep -q '"type":"model_resolved"' "${events_file}" \
  || fail "C: review should emit a model_resolved event"
# --stage self → the role must be the author's self-CPO, not cpo-evaluator
# (honest audit log; a hardcoded cross role would spoof the stage).
grep -q "\"agent_role\":\"self-cpo-checker\"" "${events_file}" \
  || fail "C: --stage self reviewer event should record self-cpo-checker role"
grep -q "\"agent_role\":\"cpo-evaluator\"" "${events_file}" \
  && fail "C: --stage self must NOT record the cross cpo-evaluator role"
grep -q "\"route_model\":\"${ROUTE}\"" "${events_file}" \
  || fail "C: reviewer event should carry route_model=${ROUTE}"
grep -q "\"resolved_model\":\"${ROUTE}\"" "${events_file}" \
  || fail "C: reviewer resolved_model should be the route model, not the body self-name"
grep -q '"resolved_model":"gemini-2.5-pro"' "${events_file}" \
  && fail "C: the body self-name (2.5-pro) must NOT become the resolved_model"

# ── flowcheck reviewer-tier invariant ──────────────────────────────────────
EVENTS=".sfs-local/events.jsonl"
emit() {
  local t="$1"; shift
  local body=""
  for kv in "$@"; do body+=",\"${kv%%=*}\":\"${kv#*=}\""; done
  printf '{"ts":"2026-05-30T10:00:00+09:00","type":"%s","sprint_id":"%s"%s}\n' \
    "${t}" "${sprint_id}" "${body}" >> "${EVENTS}"
}
reset_events() { : > "${EVENTS}"; }
run_flowcheck() {
  set +e
  FLOW_OUT="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" flowcheck 2>&1)"
  FLOW_RC=$?
  set -e
}

# positive: route match + a passing review gate → exit 0, names the PASS note
reset_events
emit model_resolved agent_role=cpo-evaluator resolved_tier=review_high resolved_model="${ROUTE}" route_model="${ROUTE}" source=policy
emit gate_passed gate=G6 order_index=1 self_cpo=pass
emit verification_pair implementer=implementation-worker verifier=cpo-evaluator implementer_context=worker-1 verifier_context=review-1 gate=G6
run_flowcheck
[[ "${FLOW_RC}" -eq 0 ]] || fail "flowcheck positive reviewer-tier should exit 0, got ${FLOW_RC}: ${FLOW_OUT}"
flow_art="${sprint_dir}/workbench/flowcheck.md"
[[ -f "${flow_art}" ]] || fail "flowcheck should write a verdict artifact"
grep -q "fcp-reviewer-tier: reviewer model resolution on enforced review route" "${flow_art}" \
  || fail "flowcheck artifact should record the reviewer-tier PASS note: $(cat "${flow_art}")"

# D) sub-tier reviewer (route mismatch) → CRIT, exit 8
reset_events
emit model_resolved agent_role=cpo-evaluator resolved_tier=review_high resolved_model=gemini-2.5-pro route_model="${ROUTE}" source=policy
emit gate_passed gate=G6 order_index=1 self_cpo=pass
emit verification_pair implementer=implementation-worker verifier=cpo-evaluator implementer_context=worker-1 verifier_context=review-1 gate=G6
run_flowcheck
[[ "${FLOW_RC}" -eq 8 ]] || fail "D: sub-tier reviewer should exit 8, got ${FLOW_RC}: ${FLOW_OUT}"
grep -q "fcp-reviewer-tier" <<<"${FLOW_OUT}" || fail "D: should name fcp-reviewer-tier: ${FLOW_OUT}"

# E) reviewer resolved from host default (source=current) → CRIT, exit 8
reset_events
emit model_resolved agent_role=cpo-evaluator resolved_tier=review_high resolved_model="${ROUTE}" route_model="${ROUTE}" source=current
emit gate_passed gate=G6 order_index=1 self_cpo=pass
emit verification_pair implementer=implementation-worker verifier=cpo-evaluator implementer_context=worker-1 verifier_context=review-1 gate=G6
run_flowcheck
[[ "${FLOW_RC}" -eq 8 ]] || fail "E: source=current reviewer should exit 8, got ${FLOW_RC}: ${FLOW_OUT}"
grep -q "fcp-reviewer-tier" <<<"${FLOW_OUT}" || fail "E: should name fcp-reviewer-tier: ${FLOW_OUT}"

# F) reviewer event missing route_model → CRIT, exit 8
reset_events
emit model_resolved agent_role=cpo-evaluator resolved_tier=review_high resolved_model="${ROUTE}" source=policy
emit gate_passed gate=G6 order_index=1 self_cpo=pass
emit verification_pair implementer=implementation-worker verifier=cpo-evaluator implementer_context=worker-1 verifier_context=review-1 gate=G6
run_flowcheck
[[ "${FLOW_RC}" -eq 8 ]] || fail "F: missing route_model should exit 8, got ${FLOW_RC}: ${FLOW_OUT}"
grep -q "fcp-reviewer-tier" <<<"${FLOW_OUT}" || fail "F: should name fcp-reviewer-tier: ${FLOW_OUT}"

# G) laundered route: resolved_model == route_model but NOT a review_high route.
# Equality alone passes; the model-profiles allowlist anchor must still CRIT.
reset_events
emit model_resolved agent_role=cpo-evaluator resolved_tier=review_high resolved_model=gemini-2.5-pro route_model=gemini-2.5-pro source=policy
emit gate_passed gate=G6 order_index=1 self_cpo=pass
emit verification_pair implementer=implementation-worker verifier=cpo-evaluator implementer_context=worker-1 verifier_context=review-1 gate=G6
run_flowcheck
[[ "${FLOW_RC}" -eq 8 ]] || fail "G: laundered sub-tier route (resolved==route==2.5) should exit 8, got ${FLOW_RC}: ${FLOW_OUT}"
grep -q "fcp-reviewer-tier" <<<"${FLOW_OUT}" || fail "G: should name fcp-reviewer-tier: ${FLOW_OUT}"

echo "test-review-reviewer-tier-enforce: OK"
