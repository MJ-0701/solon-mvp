#!/usr/bin/env bash
# WU-1/WU-2: self-improvement loop integration SSoT — headline.
#
# Design reference: note 28 (solon self-improvement loop integration) +
# INSIGHT-2026-06-12/17/19 + idea_wiki R-LOOP. The five mature-but-scattered
# self-improving policies (lessons-accumulation, skill-promotion-loop,
# harness-autonomy, model-workaround-sunset, critical-rule-hook-promotion) gain
# ONE end-to-end loop map (signal -> record -> curate -> propose -> measure ->
# gate -> apply -> capture-delta) that declares the cross-cutting invariants
# ONCE and points to each owning policy by-reference. No policy body is copied
# into the SSoT (dual-SSoT block). WU-2 adds a prep-only self-improvement seam
# to external-orchestrator-entry (by-reference, no runtime wiring).
#
# Additive-only: pre-existing anchors in every touched file stay.
# All probe strings are ASCII, so no LC_ALL pin is needed here; has_ko is kept
# for any future Korean anchor (pinned to that call only).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"

SSOT="${CTX}/policies/self-improvement-loop.md"
INDEX="${CTX}/_INDEX.md"
LESSONS="${CTX}/policies/lessons-accumulation.md"
PROMOTE="${CTX}/policies/skill-promotion-loop.md"
HARNESS="${CTX}/policies/harness-autonomy.md"
SUNSET="${CTX}/policies/model-workaround-sunset.md"
HOOK="${CTX}/policies/critical-rule-hook-promotion.md"
TIDY="${CTX}/commands/tidy.md"
FLOW="${CTX}/commands/flowcheck.md"
ORCH="${CTX}/policies/external-orchestrator-entry.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
# Korean grep pinned to this call only (no global LC_ALL — breaks ruby UTF-8).
has_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
# Dual-SSoT block: a stage-mechanics phrase from a component policy must NOT be
# copied into the loop SSoT (the SSoT points by-reference, never re-describes).
absent() { grep -Fq -- "$2" "$1" && fail "$3: SSoT copies component body '$2'" || true; }

# ── SSoT exists + frontmatter ──────────────────────────────────────
[[ -f "${SSOT}" ]] || fail "missing self-improvement-loop.md"
has "${SSOT}" "id: sfs-policy-self-improvement-loop" "frontmatter id"

# ── 8 stage anchors + ordered pipeline chain (ASCII) ───────────────
for stage in SIGNAL RECORD CURATE PROPOSE MEASURE GATE APPLY CAPTURE; do
  has "${SSOT}" "**${stage}" "stage anchor ${stage}"
done
has "${SSOT}" "SIGNAL -> RECORD -> CURATE -> PROPOSE -> MEASURE -> GATE -> APPLY -> CAPTURE" "ordered 8-stage chain"

# ── 5 component policies called by-reference in the SSoT ───────────
has "${SSOT}" "lessons-accumulation.md" "by-ref lessons-accumulation"
has "${SSOT}" "skill-promotion-loop.md" "by-ref skill-promotion-loop"
has "${SSOT}" "harness-autonomy.md" "by-ref harness-autonomy"
has "${SSOT}" "model-workaround-sunset.md" "by-ref model-workaround-sunset"
has "${SSOT}" "critical-rule-hook-promotion.md" "by-ref critical-rule-hook-promotion"

# ── 6 invariants declared ONCE in the SSoT (canonical enumeration) ─
has "${SSOT}" "suggest-only" "invariant 1 suggest-only-until-gate"
has "${SSOT}" "events.jsonl" "invariant 2 ledger/event-log authoritative"
has "${SSOT}" "L-NNN" "invariant 3 L-NNN id preserved (no merge-away)"
has "${SSOT}" "measured-but-not-sufficient" "invariant 4 measured-but-not-sufficient"
has "${SSOT}" "auto-patch" "invariant 5 no code auto-patch (MD edits only)"
has "${SSOT}" "SCHEDULED_RUN_CONTRACT" "invariant 6 scheduled/unattended contract"

# ── stage handoff artifact chain (typed handoff) ───────────────────
has "${SSOT}" "lessons.md" "handoff artifact lessons.md"
has "${SSOT}" "curation report" "handoff artifact curation report"
has "${SSOT}" "evals/" "handoff artifact held-out set"
has "${SSOT}" "evolution-ledger.md" "handoff artifact evolution-ledger"
has "${SSOT}" "typed handoff" "typed handoff discipline"

# ── _INDEX route ───────────────────────────────────────────────────
has "${INDEX}" "policies/self-improvement-loop.md" "index route"

# ── 5 additive backpointers (each component -> loop SSoT) ──────────
has "${LESSONS}" "self-improvement-loop.md" "backpointer lessons-accumulation"
has "${PROMOTE}" "self-improvement-loop.md" "backpointer skill-promotion-loop"
has "${HARNESS}" "self-improvement-loop.md" "backpointer harness-autonomy"
has "${SUNSET}" "self-improvement-loop.md" "backpointer model-workaround-sunset"
has "${HOOK}" "self-improvement-loop.md" "backpointer critical-rule-hook-promotion"

# ── command-rail pointers (tidy applies, flowcheck signals) ────────
has "${TIDY}" "self-improvement-loop.md" "tidy pointer to loop SSoT"
has "${FLOW}" "self-improvement-loop.md" "flowcheck pointer to loop SSoT"

# ── DUAL-SSoT BLOCK: SSoT must NOT copy component stage-mechanics ──
# Each probe is the meatiest copy-target sentence of an owning policy. A
# negative grep is a proxy (only proves these phrases weren't copied), so we
# pick one distinctive mechanics phrase per component.
absent "${SSOT}" "ASCII-lowercased, digits and punctuation stripped" "no skill-promotion DETECTION mechanics"
absent "${SSOT}" "Description integrity" "no EVOLUTION_ADOPTION_GATE four-gate re-listing"
absent "${SSOT}" "model-workaround: {model:" "no model-workaround tag-format copy"
absent "${SSOT}" "consecutive discarded iterations" "no harness discard-ladder mechanics"
absent "${SSOT}" "Tier C — hook (code-enforced" "no critical-rule-hook tier-mechanics copy"
absent "${SSOT}" "category: gate | review" "no lessons schema-block copy"

# ── WU-2: prep-only self-improvement seam in external-orchestrator-entry ──
has "${ORCH}" "Self-improvement seam" "WU-2 seam section anchor"
has "${ORCH}" "self-improvement-loop.md" "WU-2 seam points to loop SSoT"
has "${ORCH}" "External SIGNAL source" "WU-2 seam 1 external signal source"
has "${ORCH}" "proposal-review surface" "WU-2 seam 2 external review surface"
has "${ORCH}" "doctor + curation + tidy" "WU-2 seam standalone-guarantee discriminator"
has "${ORCH}" "no runtime wiring" "WU-2 seam prep-only (no runtime wiring)"
# suggest-only + first-permission read-only apply to the seam too (pre-existing
# anchor must stay).
has "${ORCH}" "First-permission read-only" "WU-2 pre-existing read-only anchor preserved"

# ── vendor / private-path hygiene on the new+touched bodies ────────
for f in "${SSOT}" "${ORCH}"; do
  if grep -Eq '/Users/|/home/[a-z]' "${f}"; then
    fail "$(basename "${f}"): leaks an absolute private path"
  fi
  for v in "Opus 4.8" "Opus 4.7"; do
    if grep -Fq -- "${v}" "${f}"; then
      fail "$(basename "${f}"): vendor model version '${v}' leaked into policy body"
    fi
  done
done

# ── line budgets: SSoT + every touched file under the 200-line ceiling ──
for f in "${SSOT}" "${ORCH}" "${LESSONS}" "${PROMOTE}" "${HARNESS}" "${SUNSET}" "${HOOK}" "${TIDY}" "${FLOW}"; do
  lines="$(wc -l < "${f}")"
  [[ "${lines}" -lt 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS"
