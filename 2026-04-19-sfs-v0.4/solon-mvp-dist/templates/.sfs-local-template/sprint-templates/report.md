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

> Sprint completion report. This is the concise, final artifact for a closed
> sprint. The other sprint files are workbench artifacts: they may be verbose
> while work is active, but completed work should be read from this report first.
> After close/tidy, workbench originals may live under `.sfs-local/archives/`.
> Raw history belongs in `retro.md`, archived workbench files, session logs,
> and events.jsonl.

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

- `.sfs-local/archives/.../brainstorm.md` — archived workbench: raw context and problem shaping
- `.sfs-local/archives/.../plan.md` — archived workbench: sprint contract and AC
- `.sfs-local/archives/.../implement.md` — archived workbench: implementation slice evidence
- `.sfs-local/archives/.../log.md` — archived workbench: chronological notes
- `.sfs-local/archives/.../review.md` — archived evidence: CPO verdict and required actions
- `retro.md` — history: KPT/PDCA learning and retrospective context

## §8. Next Cycle — Division Activation Recommendations

<!-- solon:division-recommendations:start -->
- (auto) Filled on `/sfs report --compact` or `/sfs retro --close`. Add manual notes outside this marker block.
<!-- solon:division-recommendations:end -->
