---
id: sfs-policy-mainline-focus-guard
summary: Keep auxiliary tool/auth/setup work subordinate to the user's main objective.
load_when:
  - mainline
  - focus
  - tool setup
  - auth setup
  - drift
  - 삼천포
  - 본론
  - 보조도구
status: filled-v1
content_policy: "load when setup/tooling work might interrupt the requested product work"
---

# Mainline Focus Guard

This pack prevents a visible helper problem from hijacking the real sprint.
Tooling, auth, model setup, connector setup, and bridge probing exist to serve
the user's main objective. They are not the main objective unless the user made
them the objective.

## Classify Side Work

Before spending meaningful time on setup/tooling, classify it:

- `mainline`: the user explicitly asked to improve that product/tool behavior.
- `unblocker`: the current mainline cannot proceed without the smallest setup.
- `deferred_followup`: useful, but the mainline can proceed without it.
- `blocked`: missing auth/tool/runtime/sandbox approval prevents the mainline.
- `out_of_scope`: interesting, but not tied to current AC.

Only `mainline` and true `unblocker` work may interrupt the current sprint.
For `unblocker`, do the minimum viable setup, record evidence, and return to
the mainline immediately.

## Drift Rules

- Restate the main objective before changing files on non-trivial work.
- If the user re-states the mainline after drift, stop the side work and repair
  the SFS artifact/check that allowed the drift.
- Do not turn helper model setup into a sprint unless the product contract says
  the helper setup itself is the deliverable.
- Tool setup bugs found during mainline work become product defects or
  follow-ups after the mainline is closed, unless they block acceptance.

## Mainline Ledger

For plan/review/long-running work, record:

| field | meaning |
|---|---|
| main objective | the product behavior or SFS policy being delivered |
| current step | what is being done now and why it serves the objective |
| side-work classification | mainline / unblocker / deferred_followup / blocked / out_of_scope |
| return condition | what proves the side work is done enough to return |
| evidence | command, artifact, or waiver |

Gate 6 is partial if helper setup consumed the sprint while the main objective
remained unverified.
