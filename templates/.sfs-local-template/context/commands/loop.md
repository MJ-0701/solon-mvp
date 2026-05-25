---
id: sfs-command-loop
summary: Autonomous loop work is single-runner, queue-aware, and lock-sensitive.
load_when: ["loop", "queue", "autonomous", "자율", "반복"]
---

# Loop

- Default mode is single-runner.
- Respect queue state: pending, claimed, done, failed, abandoned.
- Stop on mutex conflict; never steal active work automatically.
- Keep each loop slice small, evidence-backed, and reviewable.
- Long-running monitor checkpoints must state `progressing`, `slow`,
  `stalled`, `dead`, or `auth_blocked`; record commit delta, PR/head delta,
  local dirty state, test/check delta, review status delta, worker liveness
  probe result, lane-utilization evidence or waiver, and next action `wait`,
  `probe`, `revive`, or `close`.
- Worker liveness for monitor purposes requires a request-response probe, never
  process/auth-status alone. Use a static benign payload only, never
  workspace/user content, and persist only status/category/timestamp/redacted
  error class; do not persist raw stdout/stderr, bearer/auth tokens, env vars,
  prompt bodies, model responses, workspace/user content, or PII.
- A monitor is not closed until heartbeat/automation cleanup and durable
  wiki/report evidence are recorded.
- Handoff-only scope is a stop contract. When asked only for a handoff, next-session brief, session report, or `인계문서`, write current state, blockers, first next command, and cleanup evidence, then stop; do not start or continue PR polling, review retriggers, merges, implementation, deploy, or monitor loops; interrupt active or queued batches and do not finish current PRs first unless the same user request explicitly asks to continue. If post-request PR/review/merge work already happened, report it as a scope breach, not as a justification.
- Long loops must not keep waking the same host conversation forever. Before
  each loop wakeup or next queue item, check the host token meter/session
  report. At 50% or higher, or after more than two wakeups in the same chat,
  perform fresh-session transfer automatically: write durable compact handoff or
  transfer capsule, invoke host-owned transfer/new-session/archive/clear+resume
  when available, and resume immediately in the fresh session. Do not call bare
  clear. If no host-owned transition+resume control exists, stop with the exact
  resume prompt. Do not ask same-session vs fresh-session and do not ask the
  user to type `/clear`.
