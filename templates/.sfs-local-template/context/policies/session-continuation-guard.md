---
id: sfs-policy-session-continuation-guard
summary: Stop long-running LLM sessions before conversation history becomes the hidden token budget.
load_when: ["session continuation", "fresh session", "handoff", "token meter", "long session", "loop wakeup", "resume", "session transfer"]
---

# Session Continuation Guard

- SFS upgrades runtime files and project-local context; it cannot shrink the
  already-open Claude/Codex/Gemini conversation. Existing session history stays
  in the host runtime until the host or session supervisor opens a fresh session
  or clears it.
- Treat the host runtime's token meter, session report, or usage dashboard as
  authoritative. Do not infer safety from `sfs --version` alone.
- Stop and hand off to a fresh session when any trigger appears:
  - token meter is already 30% or higher before the first implementation,
    review, or cross-review action of a new WU/sprint;
  - token meter reaches 50% before starting a new gate, autonomous loop wakeup,
    worker delegation, or external review;
  - one host session spans multiple sprints/WUs, or an autonomous loop resumes
    the same conversation more than twice;
  - a bridge/plugin/rescue agent would forward full conversation history;
  - the agent notices it is rereading broad files, old logs, or the main chat
    because the session is too large to reason from current artifacts.
- A handoff is a derivation of the event ledger, not an authority over it: on
  pickup, verify the handoff against `events.jsonl` (and the preserved raw
  archives) per `flow-conformance-postflight.md` EVENT_LOG_RECONSTRUCTION_SSOT
  — when they disagree, the ledger wins and the mismatch surfaces as #3.
- The handoff is compact: write or reference the current sprint `report.md`,
  `review.md`, latest capture ids, exact commit/branch, failing command, and
  next SFS command. Do not copy the chat transcript.
- Handoff-only scope is a stop contract: a request only for handoff, next-session brief, session report, or `인계문서` means write/update that artifact and stop after recording current state, blockers, first next command, and cleanup evidence. Do not start or continue PR polling, review retriggers, merges, implementation, deploy, or monitor loops; interrupt active or queued batches and do not finish current PRs first unless the same user request explicitly asks to continue. If post-request PR/review/merge work already happened, report it as a scope breach, not as a justification.
- Fresh-session transfer is lossless autopilot after a trigger: durably
  write/update the handoff/report or transfer capsule first, including current
  branch/commit/status, latest evidence paths, first next command, and exact
  next-session prompt.
- The transfer capsule must declare `entry_working_dir` and `entry_repo` — the
  directory and repo the next session must open in for the resume target
  (`PROGRESS.md` / `sprints/` / `CLAUDE.md`) to resolve. On session entry, if the
  current working directory is not the handoff's `entry_working_dir`, stop and
  tell the user which directory to open; never silently attempt pickup. A handoff
  authored in the docset but opened in the distribution repo (or vice-versa)
  finds none of those files and mis-reads the absence as "nothing to do". WU,
  handoff, and `sprints/` live in the docset; the distribution repo receives only
  cut results.
- Only after that durable capsule exists, invoke a host-owned transfer,
  new-session, archive, or clear+resume control that preserves or injects the
  prompt and resumes immediately in the fresh session. Do not call a bare clear
  that cannot resume from the capsule. If no host-owned transition+resume
  control exists, stop after the prompt. Do not ask the user to choose
  same-session vs fresh-session continuation, and do not ask the user to type
  `/clear`; manual clear input is a host capability gap, not an acceptable SFS
  next action.
- If `sfs --version` is current but routed context looks stale, run
  `sfs upgrade` in that project and then start a fresh agent session. A runtime
  upgrade without fresh session/context reload does not change the host's
  already-loaded prompt or conversation state.
- `.sfs-local/` size is a tidy signal, not a token-meter substitute. If it is
  large, run targeted `sfs tidy --all --apply` when safe, but do not broadly
  read `.sfs-local/` to diagnose token usage.
