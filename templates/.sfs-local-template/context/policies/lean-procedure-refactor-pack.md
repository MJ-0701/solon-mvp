---
id: sfs-policy-lean-procedure-refactor-pack
summary: Remove or automate procedural bottlenecks while preserving quality gates.
load_when:
  - process bottleneck
  - procedural refactor
  - ceremony
  - lean gate
  - slow review loop
  - unnecessary process
status: filled-v1
---

# Lean Procedure Refactor Pack

Use this pack when SFS itself, or an SFS-managed project, becomes slow because
the procedure is doing visible work without improving quality.

## Keep / Shrink / Remove

- Keep a step when it prevents security, data-loss, public-contract, regression,
  release, or user-judgment failures that tests cannot cheaply cover.
- Shrink a step when it is valuable but can be an auto-lens, checklist row,
  template field, or post-run assertion instead of a user-visible ritual.
- Remove or downgrade a step when it is only ceremony, duplicates stronger
  evidence, asks the user for runnable work, or repeatedly blocks mainline work.
- Never remove the invariant. Refactor the evidence path: automate, narrow,
  merge with an adjacent gate, or require a waiver.

## Bottleneck Ledger

Record only meaningful signals:

- user-call count, runnable-step delegation count, review loop count;
- time spent blocked by auth/tool setup versus main objective;
- repeated finding category and whether a guard/test can catch it earlier;
- token/context growth, stale artifacts, and manual copy-paste handoffs;
- command/test/runtime wait that can become parallel, cached, or targeted.

## Refactor Rule

The output should be less ceremony and equal or stronger quality:

- fewer manual prompts or repeated reviews;
- clearer trigger conditions and smaller context load;
- same or stronger automated test, smoke, ledger, or release verifier evidence;
- no reduction in security, data validation, DDD/TDD, or user approval safety.

## Process self-audit

At each gate, review loop, recurring checklist, or ceremony, ask: Does this gate or ceremony still serve the current objective and prevent a real failure?

- If yes, keep the invariant and make the evidence cheaper where possible.
- If partly, shrink it into an auto-lens, template row, or post-run assertion.
- If no, remove, downgrade, defer, or require an explicit waiver instead of
  preserving ceremony.

## Anti-yak cadence

Use anti-yak cadence as a recommendation, not a hard blocker: after 3 meta-system WUs, schedule at least 1 user-outcome WU or record a waiver with the
owner reason. A user-outcome WU advances a real product/user result outside the
SFS method itself; a meta-system WU changes SFS process, policy, templates,
review rails, or instrumentation.
