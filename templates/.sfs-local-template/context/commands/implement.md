---
id: sfs-command-implement
summary: Execute the smallest verified work slice; code is one artifact, not the only one.
load_when: ["implement", "구현", "build", "execute", "작업"]
---

# Implement

- Do not stop at artifact creation: execute the requested slice and record evidence.
- Valid artifacts: code, taxonomy, design handoff, QA evidence, infra/runbook,
  management/admin evidence, decisions, docs, workflow, research, or
  user-facing operating material.
- If the codebase, dependency change, or domain model is unfamiliar, split off a
  read-only research slice before editing. Use `.sfs-local/personas/researcher.md`
  when available, prefer a long-context executor such as Gemini when configured,
  and record only the compact findings in the current workbench.
- If intent is not shared, ask 1-3 precise questions before changing files.
- Use project/domain terms consistently; add or reuse a small glossary when terms drift.
- Move only as fast as feedback: test, smoke, preview, or review the smallest useful slice.
- Keep changes surgical: touch only files and lines tied to the request, do not
  refactor adjacent code, and remove only unused pieces created by this slice.
- For user-facing UX validation, add an explicit S0 repair contract before the
  implementation slice: field-level location, friendly coaching copy, one-step
  recovery action, and server-side fallback. Warning/blocking alone is not a
  complete UX.
- Prefer simple code over speculative flexibility. If the implementation grew
  larger than the problem justifies, simplify before review.
- Inspect the exact files and nearby call sites before editing. Treat dirty
  worktree changes as user work unless you made them, and adapt rather than
  reverting unrelated edits.
- When a command fails, read the full error/log output and verify the cause
  before applying a fix.
- If code or executable artifacts changed, run the smallest relevant test,
  build, typecheck, smoke, or scripted review before marking complete. Record
  the command and result in the implementation evidence.
- Use current sprint artifacts for plan/checklist/context notes. Create
  root-level `checklist.md` or `context-notes.md` only when the user asks for
  those exact files.
- Token discipline: inspect the smallest relevant files, prefer symbol/semantic
  search or precise `rg` before broad reads, and do not carry old workbench
  history into the turn unless current report/plan evidence is insufficient.
- Prefer deep modules and gray-box delegation: design the public interface, then let AI fill internals.
- Record artifact type, domain terms, divisions, feedback checks, design/interface notes, and review handoff in `implement.md`.
- When delegating worker slices, keep files_scope explicit and disjoint. Workers
  may implement fixed internals, but architecture, public API, domain terms, and
  acceptance criteria stay with CEO/CTO/user decisions.
- Use TDD/DDD/transaction guardrails when code or data consistency is touched.
- Load `policies/knowledge-pack-router.md` first, or `policies/knowledge-pack-router.ko.md`
  for Korean preference. Apply only the matching division router ids.
- If backend/JVM/Spring/JPA/transaction/batch/integration/DevOps/AWS work is in
  scope, read `policies/backend-knowledge-pack.md` **or**
  `policies/backend-knowledge-pack.ko.md` **only** after router selection.
- If strategy-pm, QA, design/frontend, infra, management-admin, or taxonomy work
  is in scope, read the matching `policies/*-knowledge-pack.md` or
  `policies/*-knowledge-pack.ko.md` only after router selection.
  Apply the compact guidance for matching ids only; ordinary implementation
  should not broaden itself into a knowledge-pack deepening task.
- Backend architecture ladder: clean layered monolith for MVP/small projects;
  CQRS for non-initial backend work even with one DB; propose Hexagonal
  transition when domain seams grow; propose MSA only when independent deploy,
  scale, ownership, resilience, or blast-radius needs justify it. Refactor only
  after user acceptance/approval and record the evidence.
- Non-Dev policy ladders: strategy-pm, taxonomy, design/frontend, QA, infra, and
  management-admin start lightweight, strengthen when trigger evidence appears,
  and require user acceptance/approval before large roadmap, rename/schema,
  redesign, release-readiness, finance/admin process, tax/accounting advisor
  checkpoint, or infra/ops transitions.
