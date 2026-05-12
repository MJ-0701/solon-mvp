summary: Token Diet plan summary

The plan for SFS Token Diet has several distinct pieces. Slice A has already
landed the policy and adapter contract that compact output is allowed only when
quality is preserved. Slice B will later touch command output paths, but that
cannot safely happen yet. Slice C must come first because it gives the project a
deterministic benchmark harness. That harness compares normal and compact
fixtures, records character-count reduction, and rejects any compact fixture
that drops evidence, warnings, decisions, source links, source paths, raw-source
traceability, or verification results. This ordering keeps the project from
shipping a feature that is merely short instead of accurate.

source: `sprints/0-6-84-token-diet/plan.md`
verification: `tests/test-token-diet-compact-output.sh` must pass
decision: Slice C before Slice B
why: quality must be measured before runtime behavior changes
next: add compact-output fixtures and negative fixtures
