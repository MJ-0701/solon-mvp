---
id: sfs-command-implement
summary: Execute the smallest verified work slice; code is one artifact, not the only one.
load_when: ["implement", "구현", "build", "execute", "작업"]
---

# Implement

- Do not stop at artifact creation: execute the requested slice and record evidence.
- Valid artifacts: code, taxonomy, design handoff, QA evidence, infra/runbook,
  decisions, docs, workflow, research, or user-facing operating material.
- If intent is not shared, ask 1-3 precise questions before changing files.
- Use project/domain terms consistently; add or reuse a small glossary when terms drift.
- Move only as fast as feedback: test, smoke, preview, or review the smallest useful slice.
- Prefer deep modules and gray-box delegation: design the public interface, then let AI fill internals.
- Record artifact type, domain terms, divisions, feedback checks, design/interface notes, and review handoff in `implement.md`.
- Use TDD/DDD/transaction guardrails when code or data consistency is touched.
- Backend architecture ladder: clean layered monolith for MVP/small projects;
  CQRS for non-initial backend work even with one DB; propose Hexagonal
  transition when domain seams grow; propose MSA only when independent deploy,
  scale, ownership, resilience, or blast-radius needs justify it. Refactor only
  after user acceptance/approval and record the evidence.
