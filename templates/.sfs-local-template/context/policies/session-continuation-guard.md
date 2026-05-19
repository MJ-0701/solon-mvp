---
id: sfs-policy-session-continuation-guard
summary: Stop long-running LLM sessions before conversation history becomes the hidden token budget.
load_when: ["token", "session", "continuation", "loop", "wakeup", "resume", "upgrade", "Claude", "Codex", "Gemini"]
---

# Session Continuation Guard

- SFS upgrades runtime files and project-local context; it cannot shrink the
  already-open Claude/Codex/Gemini conversation. Existing session history stays
  in the host runtime until the user opens a fresh session or clears it.
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
- The handoff is compact: write or reference the current sprint `report.md`,
  `review.md`, latest capture ids, exact commit/branch, failing command, and
  next SFS command. Do not copy the chat transcript.
- After handoff, tell the user to open a new session and start from
  `sfs status`, `sfs context cat kernel`, `_INDEX.md`, and the routed command
  module. The new session should read artifacts, not the old conversation.
- If `sfs --version` is current but routed context looks stale, run
  `sfs upgrade` in that project and then start a fresh agent session. A runtime
  upgrade without fresh session/context reload does not change the host's
  already-loaded prompt or conversation state.
- `.sfs-local/` size is a tidy signal, not a token-meter substitute. If it is
  large, run targeted `sfs tidy --all --apply` when safe, but do not broadly
  read `.sfs-local/` to diagnose token usage.
