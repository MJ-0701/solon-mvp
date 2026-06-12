#!/usr/bin/env bash
# BLOG-2026-06-12-1 Managed Agents architecture absorption — headline test.
#
# Locks the three promoted principles:
#   (a) model-workaround sunset policy exists (MODEL_TAG_REQUIRED /
#       SUNSET_REVIEW_ON_MODEL_CHANGE / DEBT_FRAMING), is routed from _INDEX,
#       and tidy surfaces stale-model tags;
#   (b) flow-conformance gains EVENT_LOG_RECONSTRUCTION_SSOT (event log is the
#       authoritative run-reconstruction source over handoff/PROGRESS prose);
#   (c) lessons-accumulation gains CURATION_PASS (periodic read-only curation,
#       suggest-only, human-gated at tidy) wired into skill-promotion-loop.
# Additive-only: pre-existing anchors in touched policies stay. ASCII anchors;
# the one Korean-text grep is pinned LC_ALL=C for that grep only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
SUNSET="${CTX}/policies/model-workaround-sunset.md"
FCP="${CTX}/policies/flow-conformance-postflight.md"
LESSONS="${CTX}/policies/lessons-accumulation.md"
SPL="${CTX}/policies/skill-promotion-loop.md"
TIDY="${CTX}/commands/tidy.md"
INDEX="${CTX}/_INDEX.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# (a) model-workaround sunset policy.
[[ -f "${SUNSET}" ]] || fail "missing policy: ${SUNSET}"
has "${SUNSET}" "id: sfs-policy-model-workaround-sunset" "policy frontmatter id"
has "${SUNSET}" "MODEL_TAG_REQUIRED" "tag-required section anchor"
has "${SUNSET}" "SUNSET_REVIEW_ON_MODEL_CHANGE" "sunset-review section anchor"
has "${SUNSET}" "DEBT_FRAMING" "debt-framing section anchor"
has "${SUNSET}" "model-workaround: {model:" "tag schema present"
has "${SUNSET}" "by-reference" "vendor source cited by-reference"
has "${SUNSET}" "critical-rule-hook-promotion.md" "lifecycle-vein cross-link"
lines="$(wc -l < "${SUNSET}")"
[[ "${lines}" -lt 200 ]] || fail "sunset policy exceeds 200-line budget (${lines})"
has "${INDEX}" "policies/model-workaround-sunset.md" "_INDEX route for sunset policy"
has "${TIDY}" "model-workaround-sunset.md" "tidy surfaces sunset candidates"
has "${TIDY}" "keep / retire / generalize" "tidy names the three sunset outcomes"

# (b) event-log reconstruction SSoT in flow-conformance.
has "${FCP}" "EVENT_LOG_RECONSTRUCTION_SSOT" "reconstruction-ssot section anchor"
LC_ALL=C grep -q "로그가 권위다" "${FCP}" \
  || fail "FCP: missing log-is-authoritative clause (Korean)"
LC_ALL=C grep -q "silent 동기화 금지" "${FCP}" \
  || fail "FCP: missing surface-mismatch-as-#3 / no-silent-sync clause (Korean)"
has "${FCP}" "archives/events/sprints" "authority chain includes raw archives"
# pre-existing FCP anchors preserved (additive guarantee).
has "${FCP}" "Tool-telemetry health" "pre-existing telemetry section preserved"
has "${FCP}" "fcp-gate-order" "pre-existing invariant registry preserved"

# (c) lessons curation pass, wired to skill-promotion-loop + tidy.
has "${LESSONS}" "CURATION_PASS" "curation-pass section anchor"
has "${LESSONS}" "suggest-only" "curation pass is suggest-only"
has "${LESSONS}" "never merged away" "promoted lessons survive merge application"
has "${LESSONS}" "SCHEDULED_RUN_CONTRACT" "scheduled runs obey the run contract"
has "${LESSONS}" "skill-promotion-loop.md" "curation feeds skill promotion"
# pre-existing lessons anchors preserved.
has "${LESSONS}" "Feedback flywheel" "pre-existing flywheel section preserved"
has "${LESSONS}" "Gotchas slot" "pre-existing gotchas section preserved"
has "${SPL}" "CURATION_PASS" "skill-promotion names curation as second source"
has "${TIDY}" "CURATION_PASS" "tidy consumes curation suggestions"

echo "PASS"
