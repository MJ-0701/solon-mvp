#!/usr/bin/env bash
# sfs dig C — deterministic L2 capsule emission headline.
#
# Locks:
#   - `sfs dig capsule` is the L2-gate ENFORCEMENT point: NOT-READY queue
#     refuses emission (exit 3, act-directly class) and names the waiver
#     path; READY (waiver recorded) emits
#   - emitted capsule carries all 8 contract fields (goal /
#     acceptance_criteria / files_scope / tools_allowed / output_paths /
#     token_budget / timeout / pii_rules) + warn-before-block note
#   - files_scope = target + direct import deps from the L1 graph
#   - exemplar auto-pointer: absent-with-note on the first card, then
#     points to the first validator-PASS card once one exists
#   - acceptance criteria wire the validator + DEVIATIONS_LOG convention
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DIG="${DIST_DIR}/scripts/sfs-dig.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2' in $1"; }

TMP="$(mktemp -d "${TMPDIR:-/tmp}/sfs-dig-capsule.XXXXXX")"
trap 'rm -rf "${TMP}"' EXIT

cp -R "${SCRIPT_DIR}/fixtures/dig/spring-jpa" "${TMP}/repo"
cd "${TMP}/repo"
bash "${DIG}" scan --write >/dev/null 2>&1
bash "${DIG}" graph --write >/dev/null 2>&1
EXC="docs/solon/repo/excavation"

# ── gate enforcement: NOT-READY refuses (exit 3) ─────────────────────
set +e
out="$(bash "${DIG}" capsule --next --write 2>&1)"
rc=$?
set -e
[[ "${rc}" -eq 3 ]] || fail "NOT-READY capsule emission must exit 3 (got ${rc})"
grep -q "capsule refused" <<<"${out}" || fail "refusal must say so: ${out}"
grep -q "waive-sanity" <<<"${out}" || fail "refusal must name the waiver path: ${out}"
[[ ! -d "${EXC}/capsules" ]] || fail "refused emission must not write a capsule"

# ── waiver → READY → emission with 8 fields ─────────────────────────
bash "${DIG}" scan --write --waive-sanity "test waiver" >/dev/null 2>&1
bash "${DIG}" graph --write >/dev/null 2>&1
bash "${DIG}" capsule --target src/main/java/com/acme/controller/OrderController.java --write >/dev/null 2>&1 \
  || fail "READY capsule emission failed"
CAP="${EXC}/capsules/src-main-java-com-acme-controller-ordercontroller-java.capsule.md"
[[ -f "${CAP}" ]] || fail "capsule file not written"
for field in "goal:" "acceptance_criteria:" "files_scope:" "tools_allowed:" \
             "output_paths:" "token_budget:" "timeout:" "pii_rules:"; do
  fhas "${CAP}" "${field}" "capsule field ${field}"
done
fhas "${CAP}" "warn-before-block" "token budget warn-before-block note"
fhas "${CAP}" "sfs dig card validate" "AC wires the validator"
fhas "${CAP}" "## Deviations" "AC wires the deviations convention"
fhas "${CAP}" "- src/main/java/com/acme/service/OrderService.java" "files_scope includes direct import dep"
fhas "${CAP}" "cards/src-main-java-com-acme-controller-ordercontroller-java.md" "output path is the card slug"
fhas "${CAP}" "exemplar: none yet" "first capsule has no exemplar, with note"

# ── exemplar auto-pointer once a validator-PASS card exists ──────────
mkdir -p "${EXC}/cards"
cp "${SCRIPT_DIR}/fixtures/dig/cards/good-corroborated.md" "${EXC}/cards/"
bash "${DIG}" capsule --target src/main/java/com/acme/domain/Order.java --write >/dev/null 2>&1
CAP2="${EXC}/capsules/src-main-java-com-acme-domain-order-java.capsule.md"
fhas "${CAP2}" "exemplar: ${EXC}/cards/good-corroborated.md" "exemplar points to first PASS card"

# ── --next picks the first open queue item ──────────────────────────
bash "${DIG}" capsule --next --write >/dev/null 2>&1 || fail "--next emission failed"
ls "${EXC}/capsules"/*.capsule.md >/dev/null 2>&1 || fail "--next produced no capsule"

# ── regression locks from the Codex review ──────────────────────────
# #2a: --target outside the queue / with .. must be refused (no capsule written)
before="$(ls "${EXC}/capsules" | wc -l | tr -d '[:space:]')"
set +e
bash "${DIG}" capsule --target ../../.ssh/id_rsa --write >/dev/null 2>&1
rc=$?
set -e
[[ "${rc}" -ne 0 ]] || fail "#2 --target with .. must be refused"
after="$(ls "${EXC}/capsules" | wc -l | tr -d '[:space:]')"
[[ "${before}" == "${after}" ]] || fail "#2 refused --target must not emit a capsule"
# #2b: a path not present as an open queue item is refused
set +e; bash "${DIG}" capsule --target src/not/in/queue.java --write >/dev/null 2>&1; rc=$?; set -e
[[ "${rc}" -ne 0 ]] || fail "#2 --target not in queue must be refused"
# #2c: --next together with --target is a usage error
set +e; bash "${DIG}" capsule --next --target src/main/java/com/acme/App.java --write >/dev/null 2>&1; rc=$?; set -e
[[ "${rc}" -eq 2 ]] || fail "#2 --next plus --target must be a usage error (exit 2)"

echo "test-dig-capsule: OK"
