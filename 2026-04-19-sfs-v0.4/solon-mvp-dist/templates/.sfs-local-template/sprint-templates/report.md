---
phase: report
status: draft
sprint_id: ""        # filled by /sfs start
goal: ""             # filled by /sfs start <goal>
created_at: ""       # filled by /sfs report
last_touched_at: ""  # filled by /sfs report / retro --close
closed_at: ""        # filled by /sfs report --compact / retro --close
---

# Report — <sprint title>

> Sprint completion report. This is the compact, final artifact for a closed
> sprint. The other sprint files are workbench artifacts: they may be verbose
> while work is active, but completed work should be read from this report first.
> Raw history belongs in `retro.md`, `log.md`, session logs, and events.jsonl.

---

## §1. Executive Summary

- **Goal**:
- **Outcome**: done / partial / stopped
- **Final verdict**: pass / partial / fail / not-reviewed
- **One-line result**:

## §2. Final Scope

- **Delivered**:
- **Explicitly not delivered**:
- **Carried forward**:

## §3. Key Decisions

- <decision title> — <chosen direction and why it matters>

## §4. Implementation Summary

- **Changed files/modules**:
- **Behavior added/changed**:
- **Compatibility notes**:

## §5. Verification Evidence

- **Commands/checks**:
- **Result**:
- **Manual smoke/inspection**:

## §6. Risks / Follow-ups

- **Remaining risks**:
- **Next sprint candidates**:
- **Open questions**:

## §7. Artifact Map

- `brainstorm.md` — workbench: raw context and problem shaping
- `plan.md` — workbench: sprint contract and AC
- `implement.md` — workbench: implementation slice evidence
- `log.md` — workbench: chronological notes
- `review.md` — evidence: CPO verdict and required actions
- `retro.md` — history: KPT/PDCA learning and retrospective context
