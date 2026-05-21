---
id: sfs-command-plan
summary: Convert Gate 2 into a measurable contract; do not repair missing brainstorm by guessing.
load_when: ["plan", "계획", "Gate 3", "contract", "AC"]
---

# Plan

- Adapter-first: run `sfs plan`, then read the same sprint's `brainstorm.md`.
  Treat Gate 2 `§1-§8` as source material, not decoration.
- If `brainstorm.md` is still draft or has unresolved blocking questions, do
  not smooth over them with assumptions. Ask 1-3 questions and keep the plan
  draft until shared intent is clear.
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
  - shared design concept becomes measurable requirements and explicit
    non-goals.
  - ubiquitous language becomes the terms used in AC, code, docs, UI labels,
    tests, and review notes.
    If canonical terms, forbidden aliases, actors, states, or domain boundaries
    will matter beyond this sprint, point the plan at `docs/solon/domain-map.md`
    or add a small update to that file as an implementation artifact.
  - feedback loops become binary AC with `verify by ...` evidence.
  - deep-module boundaries become public interfaces, artifact boundaries, or
    ownership slices.
  - gray-box delegation marks what the user/CEO must decide and what the AI
    worker may fill internally.
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
  Gemini, and Gemini uses `gemini-3-pro-auto` for every SFS role.
- Each implementation slice should carry a concrete checklist item and
  `verify by ...` evidence. In SFS, that checklist belongs in sprint
  workbench artifacts such as `plan.md` or `implement.md`, not as mandatory
  root-level `checklist.md` / `context-notes.md` files.
- Gate 3 plan review is mandatory before implementation. Use
  `sfs review --gate 3` with the appropriate lens and an independent executor
  when available; the plan author should not be the only evaluator.
- Do not offer `sfs implement`, worker delegation, or model-selection choices
  from a ready Gate 3 report until Gate 3 review has a PASS/accepted result.
  If the plan is ready, the final `Next` is the plan review command.
- Gate 3 review sequencing follows verified-before-advance: self-review the
  plan until PASS first, then run cross review. If any self or cross review
  returns partial/fail, rework the plan and repeat self-review before offering
  cross review or implementation.
- If a Gate 3 partial/fail finding is a deterministic micro-fix, do not hand it
  back to the user as "fixed; please run review again." Examples: AC grep scope,
  missing docs/file inclusion, stale measured command output, traceability row
  omission, evidence path typo, or a narrow wording fix that does not change
  product judgment. Apply the patch in the same cycle, run the smallest
  verification, and call the same Gate 3 self-review again. Escalate to the user only when
  the fix changes scope, architecture, public contract, security/
  privacy/data-loss risk, cost/latency policy, or acceptance criteria meaning.
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
  change the Claude Sonnet 4.6 coding lane or Gemini 3 Pro auto mapping.
- If a researcher pass produced findings, summarize only the durable result in
  the plan: sources checked, domain terms, contradictions, and remaining
  unknowns. Do not copy the full research transcript into the plan.
- Load `policies/knowledge-pack-router.md` first, or `policies/knowledge-pack-router.ko.md`
  for Korean preference. Proceed to matching division packs from its mapping.
- If backend/JVM/Spring/JPA/transaction/batch/integration/DevOps/AWS risk is in
  scope, record matching ids from `policies/backend-knowledge-pack.md` or
  `policies/backend-knowledge-pack.ko.md` only after router selection.
- If strategy-pm, QA, design/frontend, infra, management-admin, or taxonomy
  signals are in scope, record matching ids from the matching
  `policies/*-knowledge-pack.md` or `policies/*-knowledge-pack.ko.md` only after
  router selection. Apply only the compact guidance for matching ids; do not
  promote every pack into a blocker.
- Use the backend pack as a scale router: first MVP gets minimal guardrails;
  money, PII, partner state, batch, MQ, or production exposure increases depth.
- Do not run implementation automatically from Gate 3. If the contract is ready,
  final `Next` points to Gate 3 review, not to the first implementation slice.
