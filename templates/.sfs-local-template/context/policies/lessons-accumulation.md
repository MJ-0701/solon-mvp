---
id: sfs-policy-lessons-accumulation
summary: Accumulate caught failures as durable avoidance rules in .sfs-local/lessons.md; consult on plan/flowcheck, append on every failure.
load_when:
  - lessons
  - gotcha
  - plan
  - flowcheck
  - retro
  - repeated mistake
---

# Lessons Accumulation Loop

Repeated AI mistakes are harness debt. The kernel already says to convert
repeated corrections into guardrails; `token-harness.md` and the retro checklist
repeat it. This policy gives that principle one durable home so a caught failure
is recorded once and never re-explained: the local ledger
`.sfs-local/lessons.md`.

This is the **record** half of the self-improving loop. The **reflect** half —
promoting a recorded lesson into an automated check/test/lint — is the feedback
flywheel; a lesson's `promoted` field is where the two meet.

## Ledger location

- `.sfs-local/lessons.md` — local, durable, agent-readable Markdown. Seeded from
  the template on init.
- It is an **operational log**: when it nears the loadable-md ceiling, rotate
  older entries to a cold archive under `policies/md-line-budget.md`. Do not
  invent a separate rotation system.

## Lesson schema

Append one entry per lesson, newest first under `## Lessons`:

```
## L-NNN <short imperative title>
- date: YYYY-MM-DD
- category: gate | review | wu-type | tooling | process
- trigger: <the observed mistake — what failed or was corrected>
- rule: <the avoidance rule, stated as an imperative>
- source: <sprint-id | gate | review path | evidence pointer>
- promoted: none | <check/test/lint/hook that now enforces this>
```

- `category` classifies the failure so similar lessons cluster.
- `rule` must be actionable on its own — a future agent obeys it without the
  original context.
- `promoted` starts `none`. The feedback flywheel later names the verification
  tool that now enforces the rule, graduating the lesson out of prose into a
  check. Never delete a promoted lesson; the rule stays as the check's rationale.

## Consult obligation (plan / flowcheck entry)

- On `plan` entry, read `.sfs-local/lessons.md` and treat any lesson whose
  `category`/`trigger` matches the current slice as a planning input — fold its
  `rule` into AC, design, or non-goals before writing code.
- On `flowcheck`, the command surfaces the ledger count and the record
  obligation as an advisory line (never changes the verdict or exit code).

## Append obligation (failure → lesson)

- Any failure caught by a WU, review, or gate that could recur in another
  session gets one `L-NNN` entry. A one-off typo does not; a class of mistake
  does.
- Recording happens at review or retro, the same place the kernel already routes
  "repeated mistake → guardrail". A lesson that warrants enforcement now becomes
  a guardrail/check immediately and is recorded with that `promoted` value.

## Feedback flywheel (reflect half)

Recording a lesson is the start, not the end. The flywheel closes when a
repeated finding becomes an automated check:

- A problem found **more than once** in review or bug triage must be reflected
  into a verification tool — a test, lint rule, gate check, or fixture — not just
  re-recorded as prose. Mark the originating lesson's `promoted` field with that
  tool. The tool now catches the class of mistake without a human re-explaining
  it.
- Tool output is agent training material: write check/test/error messages for
  the agent that will read them next. State what failed, why it matters, and the
  concrete fix or rule — an actionable message turns a failure into a guardrail,
  a vague one just repeats the loop.
- record (lesson) → reflect (tool) is one loop, not two systems. The lesson
  preserves the rationale; the tool enforces it. Neither is deleted once
  promoted.

## Gotchas slot

Reference and skill docs may carry a `## Gotchas` section using the same fields
(minus `promoted`). A Gotcha is a doc-local lesson scoped to one component; when
it is cross-cutting, also append it here as an `L-NNN` entry so it is consulted
beyond that doc. Reference-doc skeletons reuse this slot verbatim.

## Boundaries

- Local learning only — `.sfs-local/lessons.md` is private workbench state, not a
  shared/public asset. Promote durable, reviewed meaning to docs/wiki separately.
- Advisory, never blocking. The loop raises the ceiling; it does not gate work.
