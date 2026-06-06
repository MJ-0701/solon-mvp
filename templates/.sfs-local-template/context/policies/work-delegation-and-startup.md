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

## CROSS_REFERENCES

- Ask-vs-guess and scoped overrides: `user-override-precedence.md`.
- AI work intake (one-off / repeated / batch routing): `ai-work-intake-routing.md`.
- Host-agnostic entry + channel cheat sheet: `docs/maintenance/methodology-7-step.md`.
- Operator preferences that bias autonomy/ask: `user-context-separation.md`.
</content>
