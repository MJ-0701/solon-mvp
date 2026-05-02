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
