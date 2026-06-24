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
flywheel; a lesson's `promoted` field is where the two meet. This policy owns the
RECORD + CURATE stages of the end-to-end map in `self-improvement-loop.md`, which
declares the loop's cross-cutting invariants once.

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

## CURATION_PASS (periodic, read-only)

Accumulation alone degrades: a ledger that only grows becomes noise. A
**periodic curation pass** — a scheduled run or a tidy-rail step — reviews
`.sfs-local/lessons.md` plus the preserved event archives
(`.sfs-local/archives/events/sprints/`) read-only — and, when an external
orchestrator seam is wired, the staged SIGNAL queue
`.sfs-local/orchestrator/signal-queue.md` as an additional read-only input
(typed entries from `sfs orchestrator ingest`; suggest-only, by-reference to
`external-orchestrator-entry.md`) — and produces a curation report that:

- clusters lessons repeating the same `trigger`/`category` pattern and
  proposes merges (the merged entry keeps every source `L-NNN` id in its
  `source` field — ids are never reused or silently dropped, and a merged
  entry carries forward any non-`none` `promoted` value: a promoted lesson's
  rule is never merged away — the flywheel never-delete rule binds merge
  application too);
- flags lessons whose `promoted` field should graduate (the same finding
  caught 2+ times → feedback flywheel: name the check/test/lint);
- surfaces success-side repeated patterns as **skill-promotion candidates**
  (input to `skill-promotion-loop.md` DETECTION — the curation pass is a
  second candidate source besides `sfs harness doctor`).

The pass is **suggest-only**: it writes the report, never the ledger. Applying
a proposed merge or promotion happens at the `tidy` rail under the same human
gate as every adoption (`skill-promotion-loop.md` EVOLUTION_ADOPTION_GATE).
When run scheduled/unattended, the pass obeys
`work-delegation-and-startup.md` SCHEDULED_RUN_CONTRACT (fresh session,
file-borne state, four controls). External validation (by-reference): the
Dreaming pattern — a scheduled process periodically reviews session logs and
the memory store, extracts patterns, and curates memory ("The evolution of
agentic surfaces: building with Claude Managed Agents", 2026-06-10; vendor
infrastructure held out, the curation principle adopted).

## PRE_BUILD_AUDIT (audit what exists before building the next thing)

The loop above records failures *after* they are caught. Its forward-looking
twin: before starting the next build, run a **read-only audit of the artifacts
already shipped** — ask the agent what is wrong with what exists, rather than
moving straight to the new thing. The defects this surfaces become `L-NNN`
lesson entries (and success-side patterns become `skill-promotion-loop.md`
candidates), so the next build starts from a corrected base instead of
compounding on a silent flaw.

- **Read-only, suggest-only, non-destructive.** The pass writes a finding list,
  never patches code or the ledger; applying anything is a human/agent decision
  at the `tidy` rail under the same gate as every adoption
  (`skill-promotion-loop.md` EVOLUTION_ADOPTION_GATE).
- **Cheap and under-used.** It is a separate pass from postflight flowcheck
  (which checks the run that just happened); this audits the standing body of
  work before the next slice opens. The flowcheck Plan-gate `eval-first` check
  points here so the audit lands at plan time
  (`commands/flowcheck.md`).
- **Scheduled/unattended runs** obey `work-delegation-and-startup.md`
  SCHEDULED_RUN_CONTRACT (fresh session, file-borne state, four controls), same
  as CURATION_PASS.

External validation (by-reference): Claude blog hackathon-winners interviews
(2026-06-15) — a winning builder's takeaway that the most under-rated loop is
letting Claude audit what you already built before building the next thing;
generalized principle adopted, hackathon/name/model-version specifics held out.

## Gotchas slot

Reference and skill docs may carry a `## Gotchas` section using the same fields
(minus `promoted`). A Gotcha is a doc-local lesson scoped to one component; when
it is cross-cutting, also append it here as an `L-NNN` entry so it is consulted
beyond that doc. Reference-doc skeletons reuse this slot verbatim.

## Boundaries

- Local learning only — `.sfs-local/lessons.md` is private workbench state, not a
  shared/public asset. Promote durable, reviewed meaning to docs/wiki separately.
- Advisory, never blocking. The loop raises the ceiling; it does not gate work.
