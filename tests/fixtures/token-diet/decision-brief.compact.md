summary: decision brief remains self-contained
decision: ship runtime compact output only after fixtures pass
why: runtime behavior changes user-visible SFS reports
recommendation: require negative fixture PASS first
alternatives: keep Slice A policy-only; add Slice C benchmark-only; defer runtime behavior
consequence: early runtime compaction can hide evidence, warnings, or decision context
source: `sprints/0-6-84-token-diet/plan.md`
verification: `tests/test-token-diet-compact-output.sh`
