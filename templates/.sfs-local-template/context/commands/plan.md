---
id: sfs-command-plan
summary: Convert Gate 2 into a measurable contract; do not repair missing brainstorm by guessing.
load_when: ["plan", "계획", "Gate 3", "contract", "AC"]
---

# Plan

- Adapter-first: run `sfs plan`, then read the same sprint's `brainstorm.md`.
  Treat Gate 2 `§1-§8` as source material, not decoration.
- Consult `.sfs-local/lessons.md` on plan entry; fold any matching lesson's rule into AC/design/non-goals before code (`policies/lessons-accumulation.md`). Run the unknowns preflight from `policies/unknowns-and-deviations.md` in the same pass: decompose the slice across the UNKNOWNS_QUADRANT, spend one BLIND_SPOT_PASS prompt (record the `blind_spots` list with answered/delegated/open states), and close the SPEC_INTERVIEW_GATE before the contract freezes — ask impact-ordered questions (design-overturning first, details last), merge each answer into the spec, record explicit skips; an open question or `open` blind spot keeps the plan draft. If existing code already does the desired behavior, fill the plan's `references` field (REFERENCES_FIELD: path/repo/commit + one-line intent; read-before-implement pointers, not payloads); `sfs dig` fact cards' `file:line` evidence pointers are ready-made references entries. When the plan rests on a conclusion the agent researched itself, run ANTAGONISTIC_RESEARCH_PASS (`policies/source-pointer-citation.md`) before the contract freezes and record the refutation trace in the plan — attempts and what survived; a research-backed plan with no trace is a review finding.
- If `brainstorm.md` is still draft or has unresolved blocking questions, do not smooth over them with assumptions. Ask 1-3 questions and keep the plan draft until shared intent is clear.
- Carry Gate 2 AI work intake forward: goal, materials, ask-back rule, and output format become requirements, AC, evidence, and artifact shape.
- If Gate 3 remains draft because the user must choose scope, do not end with
  an unexplained `Q1`. Write a short decision-needed paragraph that restates the
  user-facing choice, why the choice matters, the recommended default, and the
  consequence of each option. The id is only a cross-reference for later logs.
- Never show only the recommended column for scope/persona/provider/source
  choices. Define labels such as `A/B/C/D` inline, show every viable option with
  the practical tradeoff, and then name the recommended default. If the option
  set is too wide for one compact view, ask the decisions sequentially instead
  of hiding alternatives.
- Do not ask for compact bundle confirmations such as `A/A/A/C/C 확정`, and do
  not answer "권장안 다시 보여줘" with only labels or the recommended row.
  Re-state the recommended path in plain language and make the confirmation
  phrase natural, for example `권장안 그대로 확정`.
- State material assumptions, tradeoffs, explicit non-goals, and a simpler path
  when one exists. Do not hide unresolved decisions inside confident wording.
- Gate 3 is a contract proposal, not user approval. If the plan introduces or
  changes product meaning, acceptance criteria meaning, IA, visible UI/workflow,
  public contract, security/privacy/data-loss posture, cost/model policy, or
  destructive behavior, set `user_approval_required: true` and
  `user_approval_status: "pending"` in plan frontmatter and fill the
  "사용자 검토 / 승인 경계" section with the exact reason. Do not write
  "사용자 결정 지점: 없음" for a plan that redefines what the product should do.
  The next step after review is user approval capture, not implementation.
- User approval must be natural-language evidence from the user, recorded with
  `sfs capture --kind user-approval --gate 3 "..."`. `sfs review --gate 3`
  PASS, self-CPO PASS, cross review PASS, or CI PASS never counts as that
  approval.
- Gate 3 must carry the same AI-era fundamentals forward:
  - natural-language SFS activation is real SFS: before accepting an existing
    approved plan as the current contract, compare current user wording, latest
    handoff/docs, active sprint artifacts, and wiki/DDD maps. If handoff/user
    intent conflicts with the active sprint, the plan is mis-scoped until the
    conflict is resolved by evidence-backed re-plan or explicit waiver.
  - shared design concept becomes measurable requirements and explicit
    non-goals.
  - ubiquitous language becomes the terms used in AC, code, docs, UI labels,
    tests, and review notes.
    If canonical terms, forbidden aliases, actors, states, or domain boundaries
    will matter beyond this sprint, point the plan at `docs/solon/domain-map.md`
    or add a small update to that file as an implementation artifact.
  - DDD/TDD becomes an explicit product-level engineering floor:
    name the product behavior, domain boundary, aggregate/invariant or waiver,
    and first failing, characterization, smoke, or review evidence before
    implementation.
    For any broad entrypoint slice, name the policy owner and adapter boundary:
    UI bootstraps/router/root components/hooks/stores/effects, controllers,
    jobs, repositories, DTO mappers, CLI flags, scripts, migrations, docs
    wording, observability glue, and external adapters are not sufficient
    architecture plans for product behavior unless an explicit waiver says why.
  - feedback loops become binary AC with `verify by ...` evidence.
  - deep-module boundaries become public interfaces, artifact boundaries, or
    ownership slices.
  - gray-box delegation and Harness Engineering mark human-owned understanding/
    design, AI-owned execution, narrow tool surface, project-as-prompt structure, and verification checks.
- If expert/domain know-how becomes reusable project memory, load `policies/domain-knowledge-assets.md` and fill the Domain Asset Promotion Ledger: raw source, owner/expert, `asset_candidate`, promotion boundary, and behavior check before worker handoff.
- Gate 3 must include all six required council roles in the legacy `division_subagent_ledger`:
  five organization divisions (strategy-pm, dev, QA, design, infra) plus the taxonomy
  cross-cutting product function/lens map to AC/files/evidence or record a
  waiver/not-applicable. Actual parallel implementation is optional; this council review is mandatory.
- For non-trivial product-bearing work, load
  `policies/enterprise-plan-council-pack.md` or `.ko.md` before Gate 3 review.
  Plan must record risk flags, selected child packs, and an enterprise council
  row for each relevant council role. Empty six-role council ceremony is not PASS; each
  row needs a finding, evidence, `asset_candidate`, waiver, or concrete N/A reason.
- Load `policies/mainline-focus-guard.md` when tool/auth/model setup appears
  beside the user's real objective. Plan must classify side work as mainline,
  unblocker, deferred_followup, blocked, or out_of_scope and define the return
  condition to the main objective.
- Load `policies/gate6-data-validation-pack.md` when the plan changes data
  shape, fixture/mock/seed, API payload, UI state, auth/session, migration/
  backfill, cache, persistence, or observable log/analytics shape. Add data
  validation AC with named fixture/invariant/command/result expectation.
- Load `policies/agentic-security-logging-pack.md` when auth, permissions,
  secrets, PII, untrusted input/output, agent tools, dependencies, release,
  logs, console output, Datadog, or observability is in scope. Add OWASP family,
  no-stray-console-log, redaction, and Datadog/equivalent evidence expectations.
- Load `policies/wiki-mission-checklist-skill.md` for long-context/multi-defect/
  multi-agent/release/monitor work or when the user says issues may blur. Name
  the checklist path and make checklist reconciliation part of Gate 6.
- A plan is not ready just because it is long. It is ready when an evaluator can
  independently check pass/partial/fail without reading the generator's mind.
- In the review-readiness checklist, avoid translationese such as `열린 결정이
  이름 붙어 있다`. Prefer concrete Korean checks: Gate 2 decisions are mapped
  to requirements and AC, files/artifacts are mapped per slice, and worker model
  routing is explicit: Codex general worker uses `gpt-5.4`, helper-grade I/O and
  non-coding helpers use `gpt-5.4-mini`, bounded repo-aware coding helpers use
  `gpt-5.3-codex`, and Spark is limited to locked judgment-free mechanical
  implementation helper work. Claude coding-capable worker/helper lanes use
  Sonnet 4.6, Haiku is non-coding helper-only, substantive research prefers
  Gemini `gemini-3.1-pro-preview`; Gemini coding/helper routes use
  `gemini-3-flash-preview` and `gemini-3.1-flash-lite` by role.
- Each implementation slice should carry a concrete checklist item and
  `verify by ...` evidence. In SFS, that checklist belongs in sprint
  workbench artifacts such as `plan.md` or `implement.md`, not as mandatory
  root-level `checklist.md` / `context-notes.md` files.
- Gate 3 plan review is mandatory before implementation. Use
  `sfs review --gate 3` with the appropriate lens and an independent executor
  when available; the plan author should not be the only evaluator. On a Gate 3 PASS emit `sfs event gate_passed gate=G3 order_index=<n> self_cpo=pass` so flowcheck sees the gate sequence (`fcp-gate-order`).
- Do not offer `sfs implement`, worker delegation, or model-selection choices
  from a ready Gate 3 report until Gate 3 review has a PASS/accepted result.
  If the plan is ready, the final `Next` is the plan review command.
- Gate 3 review sequencing follows verified-before-advance: self-review the
  plan until PASS first, then run cross review. If any self or cross review
  returns partial/fail, rework the plan and repeat self-review before offering
  cross review or implementation.
- If a Gate 3 partial/fail finding is deterministic and inside the approved
  contract, autopilot the micro-fix. Do not ask "진행?" / "proceed?" and do not
  hand it back as "fixed; please run review again." Examples: missing self-CPO
  evidence, AC grep scope, docs/file inclusion, stale command output,
  traceability, evidence path typo, small guard/test or regex gap, or wording
  that preserves product judgment. Patch, verify, rerun self-CPO and cross
  review. Escalate only when the fix changes scope, architecture, public
  contract, security/privacy/data-loss risk, cost/latency policy, or AC meaning.
- User-call minimalism: the user already co-designed intent and decision
  boundaries in brainstorm + plan review. Treat those artifacts as SoT and call
  the user only for a genuinely new product decision, not for executing a small
  review patch sequence.
- Before escalating a self/cross-review finding as a user question, run a
  premise check. State the finding's premise, then compare it with Gate 2
  intent, the current plan, domain SoT, schema/code ownership, and recorded
  decisions. If the premise is stale, contradicted, already answered, or
  over-modeled, update the plan and rerun Gate 3 review instead of asking the
  user to adjudicate the reviewer frame.
- Do not add ownership, cascade delete, soft-delete, restore API, or migration
  policy because a reviewer asked a hypothetical question. If the domain SoT
  says the entity is metadata-only or the data owner sits at another aggregate,
  remove the wrong premise. For delete flows with child data, the minimal
  default is reject delete while dependents exist unless the product contract
  explicitly chooses cascade/restore behavior.
- The self-review must be a self-CPO mini-check, not only advisor consultation.
  Before calling Codex/Claude/Gemini or another external CPO, verify and record:
  requirements ↔ AC ↔ implementation slices ↔ ADR/decision ids traceability;
  every AC has an explicit file/artifact plus expected-content/evidence mapping;
  and all SEED, placeholder, mock, or fallback material starts as fail,
  partial, or explicit non-acceptance evidence until real deliverables replace
  it. If this pass is missing, the plan is not ready for cross review.
- Do not use review volume as a stopping rule. Phrases like "enough rounds",
  "review-side 종료", or "same lens partial twice" are not pass criteria unless
  the user explicitly records a waiver.
- C-Level owns the contract, acceptance criteria, architecture boundaries, and
  review handoff. The worker/generator model owns fixed implementation slices.
  Do not frame C-Level direct implementation as a normal option; use it only
  when the user explicitly overrides the worker path or the slice is an
  emergency tiny patch, and record the cost/risk.
- If the handoff names Codex implementation, classify the lane by judgment:
  use `gpt-5.4` for the normal implementation worker, `gpt-5.3-codex` for
  bounded repo-aware coding helper work, and `gpt-5.3-codex-spark` only when
  scope, files_scope, AC, and exact edit intent are already locked and no
  product or code-design judgment remains. This Codex-specific split does not
  change the Claude Sonnet 4.6 coding lane or Gemini 3.x role routing.
- If a researcher pass produced findings, summarize only the durable result in
  the plan: sources checked, domain terms, contradictions, and remaining
  unknowns. Do not copy the full research transcript into the plan.
- For wiki/RAG/graph/ingest/doc-memory work, load `policies/obsidian-llm-wiki.md`
  and carry the Solon Advancement Scorecard into requirements/non-goals. A plan
  can treat it as Solon product scope only when it names the SFS-loop improvement;
  otherwise defer it as wiki tooling and avoid implementation slices.
- Load `policies/knowledge-pack-router.md` first, or `policies/knowledge-pack-router.ko.md`
  for Korean preference. Proceed to matching council-role packs from its mapping.
- If enterprise, agent-team, QA/QC, performance, algorithm, or large-project
  signals are present, route through `policies/enterprise-agent-team-pack.md`
  and its matching child pack instead of treating the council ledger as a
  cosmetic table.
- If mainline focus, data validation, OWASP/security/logging, Datadog, console
  log cleanup, or checklist signals are present, route through the matching
  packs before Gate 3 review. These are product behavior requirements, not
  optional polish.
- If backend/JVM/Spring/JPA/transaction/batch/integration/DevOps/AWS risk is in
  scope, record matching ids from `policies/backend-knowledge-pack.md` or
  `policies/backend-knowledge-pack.ko.md` only after router selection.
- If project scaffolding or product behavior is in scope, record the
  DDD/TDD floor from `policies/ddd-tdd-knowledge-pack.md` or `.ko.md`.
- If any broad entrypoint carries product behavior, record the same DDD/TDD
  floor for that layer: the domain/use-case/state boundary, adapter/composition
  boundary, and test/smoke/review evidence. Do not let UI bootstraps, routers,
  root components, hooks/stores/effects, controllers, jobs, repositories, DTO
  mappers, CLI flags, scripts, migrations, docs wording, observability glue, or
  external adapters become the product-policy home by default.
- If strategy-pm, QA, design/frontend, infra, management-admin, or taxonomy
  signals are in scope, record matching ids from the matching
  `policies/*-knowledge-pack.md` or `policies/*-knowledge-pack.ko.md` only after
  router selection. Apply only the compact guidance for matching ids; do not
  promote every pack into a blocker.
- Use the backend pack as a scale router: first MVP gets minimal guardrails;
  money, PII, partner state, batch, MQ, or production exposure increases depth.
- Do not run implementation automatically from Gate 3. If the contract is ready,
  final `Next` points to Gate 3 review, not to the first implementation slice.
