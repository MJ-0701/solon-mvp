---
id: sfs-command-capture
summary: Record minimal approval, waiver, decision, blocker, or evidence facts without making capture a lifecycle step.
load_when: ["capture", "note", "decision", "review order", "waiver", "blocker", "approval", "evidence"]
---

# Capture / Note Evidence Primitive

- `sfs capture` is an evidence primitive, not an SFS lifecycle gate, phase, or
  default next step. Do not add it to normal flow just because a command ran.
- Use it only when a later gate would otherwise lose a durable fact: explicit
  user approval, waiver, decision, scope change, review-order override, blocker
  classification, or accepted external evidence.
- Prefer the normal artifact first. Brainstorm, plan, implement, review, retro,
  wiki checklist, and report artifacts are the home for their own content;
  capture records only small cross-turn facts that do not already belong there.
- If a natural-language turn says an external GitHub/@codex/PR/check review
  passed, capture the accepted evidence plus the next SFS command. Do not store
  the full review transcript; the durable fact is the PASS evidence and the
  continuation rule, for example self-CPO next, then cross-review.
- GitHub @codex evidence is only for post-implementation/Gate 6 code review.
  Do not capture it as brainstorm, Gate 2, or Gate 3 plan-review completion.
- `sfs note "..."` is an alias for `sfs capture --kind note "..."`.
- Prefer specific kinds when the meaning is clear:
  `decision`, `scope-change`, `user-approval`, `review-order`, `exception`,
  `evidence`, `blocker`, `waiver`, or `note`.
- Use `user-approval` specifically when the user approves implementation after
  a Gate 3 plan that marked `user_approval_required: true`. Gate 3 review PASS
  is not that approval; capture the user's natural-language approval before
  running `sfs implement`.
- `--scope <wu|sprint|until-revoked>` records how long a user override/decision
  is authoritative. Every product-affecting override of an SFS default (model
  tier, flow deviation) carries one (`policies/user-override-precedence.md`);
  flowcheck reads it to decide whether a default deviation is covered.
- Capture before the next dependent command only when the fact affects that
  command. The point is to keep an approval/evidence fact available to the
  workbench, not to create an extra ritual between every SFS step.
- The command appends a timestamped entry to the sprint `log.md` and records a
  non-collapsing `evidence_capture` event in `events.jsonl`. Readers still
  accept legacy `flow_capture` events for existing projects.
- If there is no active sprint, pass `--sprint <id>` only when you are
  intentionally writing to that sprint; otherwise start or restore the sprint
  first.
- Do not use capture as a full transcript recorder. Store the smallest
  decision/evidence sentence that a future reviewer needs.
- `sfs capture` enforces a small text budget by default so prompt bodies and
  transcript dumps do not become durable flow state. If the source is bulky,
  store it as an artifact/archive path and capture the accepted conclusion.

Examples:

```sh
sfs capture --kind review-order --gate 6 "Run Codex self-CPO first, then Gemini/Claude cross CPO, then GitHub @codex as final external PR review."
sfs capture --kind review-order --gate 6 "GitHub @codex PASS is final external evidence after self and cross CPO; next run sfs retro if no new finding appeared."
sfs capture --kind user-approval --gate 3 "User approved this Gate 3 plan for implementation."
sfs capture --kind scope-change "Do not add automatic transcript recording in this sprint."
sfs note "GitHub @codex review passed, but it is external evidence only."
```
