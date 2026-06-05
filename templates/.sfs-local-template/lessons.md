---
id: sfs-local-lessons-ledger
summary: Local accumulated avoidance-rule ledger; append L-NNN on failure, consult on plan/flowcheck.
load_when:
  - lessons
  - gotcha
  - plan
  - retro
---

# Lessons — accumulated avoidance rules

<!-- Local self-improving ledger. Each failure caught by a WU, review, or gate
     becomes one durable avoidance rule here so the same mistake is not
     re-explained every session. See routed context
     `policies/lessons-accumulation.md` for the schema and the consult/append
     obligation. This is an operational log: when it nears the md-line-budget
     ceiling, rotate older entries to a cold archive (see
     `policies/md-line-budget.md`). -->

## Schema

Append one entry per lesson, newest at the top of the Lessons section:

```
## L-NNN <short imperative title>
- date: YYYY-MM-DD
- category: gate | review | wu-type | tooling | process
- trigger: <what failed or was corrected — the observed mistake>
- rule: <the avoidance rule, stated as an imperative>
- source: <sprint-id | gate | review path | evidence pointer>
- promoted: none | <check/test/lint/hook that now enforces this>   # WU-3 flywheel
```

`promoted` starts `none`; the feedback flywheel later marks it with the
verification tool that now enforces the rule, so a recorded lesson can graduate
into an automated check.

## Gotchas slot

Reference/skill docs may carry a `## Gotchas` section using the same fields
(minus `promoted`). A Gotcha is a doc-local lesson scoped to that component; a
durable cross-cutting Gotcha should also be appended here as an `L-NNN` entry.

## Lessons

<!-- L-NNN entries below. None yet. -->
