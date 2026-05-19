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
- Long loops must not keep waking the same host conversation forever. Before
  each loop wakeup or next queue item, check the host token meter/session
  report. At 50% or higher, or after more than two wakeups in the same chat,
  write a compact handoff and resume the queue from a fresh session.
