---
id: sfs-command-daily
summary: Bookend daily operating loop for a one-person operator — a morning brief and an evening recap that compose existing runnable commands; not a separate binary.
load_when: ["daily", "daily brief", "daily recap", "start my day", "end my day", "bookend", "운영 루프", "하루 시작", "하루 마무리", "오늘 뭐부터"]
---

# Daily

A bookend operating loop for a one-person operator: open the day with a **brief**
and close it with a **recap**. It is a *composition* of commands SFS already
ships, not a new executable — there is no `sfs daily` binary. Run the named
primitives directly; this doc is the routine that strings them together so the
agent can manage the operator's day instead of the operator re-deriving the
routine each morning.

## Grain

The single source of truth for the recommended morning/evening loop that turns
SFS's existing primitives into a daily operator rhythm.

## Scope

Covers: which existing commands to run, in what order, to start and end a working
day, and what each step produces. Does NOT cover: any new command, scheduler,
calendar/email integration, or external connector — those stay out of the SFS
core (vendor-specific automation is a consumer extension, not promoted here).

## Usage

Open this when the operator says "start my day" / "what first today" /
"wrap up the day" / "하루 시작" / "하루 마무리", or before/after a working
session to restore and then persist context cheaply.

## MORNING_BRIEF

Orient the day from durable state, spending as few model tokens as possible:

1. `sfs status` — current sprint / work-unit state, the authoritative starting
   point (kernel: "Start from `sfs status`").
2. `sfs recall <yesterday|keyword>` — token-zero recall over the prior session's
   handoff / report / retro so yesterday's resume note and open threads return
   without re-reading or re-asking.
3. From those two, name **today's focus**: the next unmet AC or the resume note
   the handoff already records. If intent is unclear, ask the smallest blocking
   question rather than guessing.

The brief reads only; it does not start implementation by itself.

## EVENING_RECAP

Close the day so tomorrow's brief is cheap and lossless:

1. `sfs capture --kind <decision|blocker|waiver|...>` — persist any approval,
   decision, blocker, or external evidence a later gate must remember (capture is
   an evidence primitive, not a routine lifecycle step — record only what matters).
2. `sfs tidy` — report / retro / archive the day's closed work into the dated
   `docs/solon/<workspace>/<yyyyMMdd>/` surfaces that `recall` reads back.
3. Optionally `sfs loop` to queue the next slice so the morning brief starts with
   a primed next action.

The recap's output (handoff / report) is exactly what the next `MORNING_BRIEF`
restores — the two ends close the loop.

## Gotchas

- Not a binary. `sfs daily` does not exist; running it will fail. Invoke the
  primitives (`status` / `recall` / `capture` / `tidy` / `loop`) directly.
- Standalone guarantee intact. Every primitive behaves identically with or
  without this doc; the loop is advisory convenience, never a dependency.
- Do not let the recap balloon. `capture` only durable evidence, `tidy` only
  closed work; routine chatter does not belong in the dated record.

## Cross-Ref

- Token-zero recall mechanics: `commands/recall.md`.
- Evidence primitive contract: `commands/capture.md`.
- Report / retro / archive: `commands/tidy.md`.
- Queue / autonomous slice: `commands/loop.md`.
- Standard delegation repertoire (which work to hand off): `policies/work-delegation-and-startup.md`.
- Parent route: `_INDEX.md` (`commands/daily.md`).

Provenance: Source-grade derived | Confidence high | Reviewed self-CPO |
Freshness 2026-06-07 | Owner SFS maintainer.
