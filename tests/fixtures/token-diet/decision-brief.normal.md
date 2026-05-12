summary: decision brief before compaction

SFS sometimes needs to ask the user for a product decision. Token Diet must not
turn those decisions into a label-only prompt or a one-row recommendation. The
compact version still needs to show the plain-language decision, why it matters,
the recommended default, the alternatives, and the consequence. If any of those
fields are missing, the compact answer is lower quality and must fail.

decision: choose whether runtime compact output should ship after fixtures pass
why: runtime behavior changes user-visible SFS reports
recommendation: implement runtime compact output only after negative fixtures pass
alternatives: keep policy-only Slice A; add benchmark-only Slice C; defer runtime behavior
consequence: shipping too early can hide evidence, risk warnings, or decision context
source: `sprints/0-6-84-token-diet/plan.md`
verification: `tests/test-token-diet-compact-output.sh`
