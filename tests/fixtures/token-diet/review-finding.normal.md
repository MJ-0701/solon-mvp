summary: review finding before compaction

Finding P1: the compact-output implementation must not remove the path, line
number, verdict, evidence, source trace, or risk statement from a review result.
The fuller version includes a lot of explanatory language so that humans can
understand the concern. However, the compact version still has to retain the
machine-checkable acceptance fields because those fields are how SFS prevents a
short answer from becoming an unverifiable answer.

file: `solon-mvp-dist/templates/.sfs-local-template/context/kernel.md`
line: 68
verdict: PARTIAL if compactness is treated as success by itself
evidence: compactness must preserve warnings, decisions, source links/paths,
  raw-source traceability, and verification results
source: `sprints/0-6-84-token-diet/plan.md`
verification: `tests/test-token-diet-compact-output.sh`
risk: evidence loss would make review PASS meaningless
