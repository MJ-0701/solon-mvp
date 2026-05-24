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
- Long loops must not keep waking the same host conversation forever. Before
  each loop wakeup or next queue item, check the host token meter/session
  report. At 50% or higher, or after more than two wakeups in the same chat,
  write a compact handoff and resume the queue from a fresh session.
