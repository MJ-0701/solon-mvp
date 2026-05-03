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
- Token discipline: inspect the smallest relevant files, prefer symbol/semantic
  search or precise `rg` before broad reads, and do not carry old workbench
  history into the turn unless current report/plan evidence is insufficient.
- Prefer deep modules and gray-box delegation: design the public interface, then let AI fill internals.
- Record artifact type, domain terms, divisions, feedback checks, design/interface notes, and review handoff in `implement.md`.
- Use TDD/DDD/transaction guardrails when code or data consistency is touched.
- Load `policies/knowledge-pack-router.md` first, or `policies/knowledge-pack-router.ko.md`
  for Korean preference. Apply only the matching division router ids.
- If backend/JVM/Spring/JPA/transaction/batch/integration/DevOps/AWS work is in
  scope, read `policies/backend-knowledge-pack.md` **or**
  `policies/backend-knowledge-pack.ko.md` **only** after router selection.
- If strategy-pm, QA, design/frontend, infra, or taxonomy work is in scope,
  read the matching `policies/*-knowledge-pack.md` or
  `policies/*-knowledge-pack.ko.md` only after router selection.
  Do not fill the knowledge content during ordinary implementation.
- Backend architecture ladder: clean layered monolith for MVP/small projects;
  CQRS for non-initial backend work even with one DB; propose Hexagonal
  transition when domain seams grow; propose MSA only when independent deploy,
  scale, ownership, resilience, or blast-radius needs justify it. Refactor only
  after user acceptance/approval and record the evidence.
- Non-Dev policy ladders: strategy-pm, taxonomy, design/frontend, QA, and infra
  start lightweight, strengthen when trigger evidence appears, and require user
  acceptance/approval before large roadmap, rename/schema, redesign,
  release-readiness, or infra/ops transitions.
