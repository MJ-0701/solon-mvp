---
id: sfs-command-harness
summary: Diagnose and map the project harness around AI agents.
load_when: ["harness", "doctor", "map", "autonomy", "multi-agent"]
---

# `sfs harness`

`sfs harness` is bash-first and does not start a sprint or run workers.

- `sfs harness doctor` inspects whether the current project has enough
  environment around the model: thin entry docs, routed context, six-division
  council, artifact/memory surface, wiki/bug recurrence memory, tests, and
  release/check rails.
- `sfs harness map` prints a compact project harness map.
- `sfs harness map --write` writes `.sfs-local/harness/harness-map.md`.

Use it before long autonomous work, optional parallel-agent work, or a project
structure refactor. The output is evidence for planning and review, not a
substitute for Gate 3 (Plan) or Gate 6 (Review).

If `doctor` reports gaps, prefer small structural fixes: thin entry docs,
active division config, a first smoke/characterization check, or a wiki/bug
report map. Do not answer by adding a longer prompt to an agent doc.
