---
id: sfs-work-delegation-and-startup
summary: Decide whether work is worth delegating as a WU (five-factor test), restate-and-clarify before starting, and pick the right runtime tier.
load_when: ["delegate", "is this a WU", "worth automating", "should I make a sprint", "before we begin", "restate the ask", "clarify first", "which runtime", "chat vs cowork vs code", "getting started"]
---

# Work Delegation And Startup

How an operator decides whether a task is worth handing to the agent as a unit of
work, and how the agent opens that work. Source: "Best practices for getting
started with Claude Cowork" (2026-06-03) — the five-factor delegation test, the
restate-and-clarify opening habit, and the runtime-selection split. Generalized
vendor-neutrally; concrete product names are by-reference, not pinned.

## DELEGATE_FIVE_FACTORS

A task is worth delegating as a WU (rather than just asking inline) when most of
these hold. The more that hold, the better the fit:

1. **Multiple inputs** — it combines several sources/files/constraints.
2. **Produces an artifact** — the output is a file or durable deliverable, not a
   one-line answer.
3. **Repeatable** — it will recur, so structuring it pays back.
4. **You can define "good"** — you know the acceptance criteria for the result.
5. **The middle is tedious** — the work between intent and result is the boring
   part worth offloading.

Few factors hold → handle it inline (a quick chat), do not spin up ceremony.
Most hold → make it a WU with explicit acceptance criteria.

## RESTATE_AND_CLARIFY

Before starting a delegated WU, the agent **restates the ask in its own words,
then asks the blocking clarifying questions** — before any planning or editing.
This is the single highest-leverage startup habit: it surfaces a
misunderstanding while it is still free to fix. It composes with the kernel's
"ask only 1-3 blocking questions" and `user-override-precedence.md` (when intent
is ambiguous, ask rather than guess). Skip the questions only when the user has
already given a self-contained, unambiguous spec.

## RUNTIME_SELECTION

Pick the runtime tier by the shape of the task, not by habit:

| Tier | Shape | Use for |
|:--|:--|:--|
| Quick chat | single-turn, no file output, conversational | quick answers, ideation, "what should I do here" |
| Assisted work session | multi-input, file outputs, supervised mid-run | reports, recurring deliverables, work where you can judge "good" |
| Autonomous code runtime | repo-aware, runs shell/git, gated | implementation, release, verified code changes |

The same Solon 7-step / Gate / SSoT applies across all three (see
`docs/maintenance/methodology-7-step.md` "Host-agnostic 진입"); the tier choice
is about supervision and surface, not a different methodology. Vendor mapping
(e.g. chat assistant / supervised work app / coding agent) is by-reference.

This three-tier split lines up with the official product matrix's three-way
shape — **conversational draft** / **coding** / **cross-app knowledge work**
(source: "The Claude Cowork product guide", 2026-06-05, by-reference): quick chat
maps to conversational draft, autonomous code runtime to coding, and the assisted
work session to cross-app knowledge work (multi-input file work the operator
supervises). The mapping is for orientation, not a fourth methodology.

### LONG_RUNNING_AND_SCHEDULED axis

The tier table above sorts by supervision surface; a second axis is **duration /
trigger** — who owns work that runs long or fires on a schedule rather than in a
live turn. Route it by this axis, not by habit:

- **Long-running, repo-aware** (multi-step build, migration, audit) → autonomous
  code runtime under a gated `loop` (`commands/loop.md`), with a durable handoff
  so a fresh session can resume.
- **Scheduled / recurring, supervised** (a daily brief, a weekly report) → an
  assisted session driven by the bookend operating loop (`commands/daily.md`);
  the host's scheduler is the trigger, the SSoT and gates are unchanged.
- **One-off, conversational** → quick chat; do not schedule or spin up ceremony.

Scheduling is a trigger, never a methodology bypass: a scheduled or long-running
run still obeys the same gates, and unattended runs keep the human-boundary
constraints (`policies/harness-autonomy.md`).

### SCHEDULED_RUN_CONTRACT

A scheduled or recurring job is operable only when it satisfies this contract
(pattern externally validated by managed scheduled agents — "New in Claude
Managed Agents", 2026-06-09, by-reference; Solon's own unattended runners
already run this way):

1. **Every fire is a fresh session.** No implicit memory between runs — all
   inter-run state travels through files the job owns (a seen/state file, a
   pending queue, a handoff doc). If two runs need to coordinate, they do it
   through those files, never through assumed session carryover.
2. **Four operational controls exist**: pause, resume, archive (retire), and
   on-demand trigger. A scheduled job the operator cannot pause or fire
   manually for a one-off run is not an operated job — it is an unowned loop.
3. **Credentials by indirection only.** The job's prompt/skill file is a
   durable agent-visible surface; real keys arrive via environment at spawn
   (`policies/credential-hygiene.md`).

## CROSS_REFERENCES

- Ask-vs-guess and scoped overrides: `user-override-precedence.md`.
- AI work intake (one-off / repeated / batch routing): `ai-work-intake-routing.md`.
- Host-agnostic entry + channel cheat sheet: `docs/maintenance/methodology-7-step.md`.
- Operator preferences that bias autonomy/ask: `user-context-separation.md`.
- Bookend daily operating loop: `commands/daily.md`.
- Credential handling for unattended/scheduled runs: `credential-hygiene.md`.
- Standard delegation repertoire (workflow catalog):
  `docs/{ko,en}/current-product-shape/26-delegation-repertoire.md`.
</content>
