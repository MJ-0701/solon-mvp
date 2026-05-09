---
id: sfs-command-implement
summary: Execute the smallest verified work slice; code is one artifact, not the only one.
load_when: ["implement", "구현", "build", "execute", "작업"]
---

# Implement

- Do not stop at artifact creation: execute the requested slice and record evidence.
- Preflight is strict: `sfs implement` requires a Gate 3 Plan review PASS
  (`sfs review --gate 3`) before implementation starts. If review evidence is
  missing, return to plan review; bypass only with an explicit user waiver.
- Gate 3 review must have passed by outcome, not by effort. Do not enter
  implementation because there were many review rounds, many lenses, or no new
  categories. Self-review must pass first; cross review follows; any
  partial/fail returns to plan rework and self-review.
- The default implementation owner is the worker/generator model resolved from
  `.sfs-local/model-profiles.yaml`, not the C-Level planner/evaluator model.
  C-Level may define the contract, split files_scope, and handle escalation, but
  should not present itself as the normal direct coding option.
- For Codex runtime, the recommended worker default is `gpt-5.3-codex`.
  `gpt-5.3-codex-spark` is not the normal implementation owner; reserve Spark
  for bounded mechanical subtasks after C-Level has locked scope, files_scope,
  and AC. Escalate to strategic_high or an explicit high-end override before
  coding if the slice touches architecture, public contracts, security,
  privacy, data-loss risk, release gates, or repeated review failure.
- Valid artifacts: code, taxonomy, design handoff, QA evidence, infra/runbook,
  management/admin evidence, decisions, docs, workflow, research, or
  user-facing operating material.
- If the codebase, dependency change, or domain model is unfamiliar, split off a
  read-only research slice before editing. Use `.sfs-local/personas/researcher.md`
  when available, prefer a long-context executor such as Gemini when configured,
  and record only the compact findings in the current workbench.
- Do not create new lifecycle commands for borrowed engineering practices.
  Strengthen this existing implement rail with routed policies:
  `policies/source-driven-development.md` for framework/library/API patterns,
  `policies/debugging-and-error-recovery.md` when anything fails,
  `policies/deprecation-and-migration.md` for legacy cleanup/migration, and
  `policies/shipping-and-launch.md` for release/deploy slices.
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
- Stop-the-line on failures: preserve exact evidence, reproduce or document why
  reproduction is not yet possible, localize the smallest failing layer, fix the
  root cause, add a guard, and resume only after verification passes.
- Framework-specific code must be source-driven: detect stack/version from the
  repo, check the smallest relevant official documentation or standard, cite the
  source in evidence for non-trivial decisions, and mark unverified patterns
  instead of hiding them.
- Bug fixes should use the prove-it pattern: create a failing regression test or
  minimal repro first when practical, then make it pass. If no automated guard
  is practical, record the exact manual repro and smoke check.
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
- Agent mode is an implementation-time choice. Default to single-agent
  execution. Offer optional parallel execution only as `sfs implement
  --agent-mode parallel --agents codex,claude[,gemini] ...`, and only when the
  plan already has independent lanes.
- Multi-agent implementation requires commit-unit clarity before coding: every
  lane must have a disjoint files_scope and a one-sentence proposed commit
  message. If an agent cannot clearly name what its commit would say, do not
  split that lane.
- Commit messages default to the user's native/workspace language. If the user
  is Korean, write Korean commit messages; use English only when English is the
  user's native/workspace language or the repo explicitly requires English.
- Parallel agents must not edit the same files or silently absorb another
  agent's scope. If scopes overlap, return to single-agent mode or re-plan the
  split before editing.
- Implementation is not complete at artifact creation. After any implementation
  mode, record verification evidence and run `sfs review --gate 6`. For
  multi-agent mode, cross review between agents is required before Gate 6 review
  can pass; each lane should review a different lane's diff/evidence.
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
- For visible design/frontend implementation, read `design.md` or
  `docs/solon/design.md` when present before editing. If neither exists and the
  work creates reusable UI, record the design-system gap or create a compact
  design.md seed before broad screen generation. After editing, check token
  drift: colors, type sizes, spacing, radius, shadows, and icon styles should
  come from the design contract or be explicitly justified.
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
