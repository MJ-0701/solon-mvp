---
id: sfs-command-review
summary: Run or summarize review evidence without letting the generator self-approve.
load_when: ["review", "검토", "CPO", "verdict", "gate"]
---

# Review

- Adapter-run by default: run `sfs review ...` before summarizing.
- Do not create a new verdict from memory; use `review.md` and recorded result paths.
- If the relevant sprint was already compacted/closed and `current-sprint` is
  missing, use `sfs review --sprint <id> --gate <n>` instead of manually
  editing `.sfs-local/current-sprint` or extracting tarballs. The command
  restores the latest cold archive into the active workbench and refuses to
  overwrite existing visible workbench files.
- After any external GitHub/@codex/PR/check PASS, do not stop at PASS. Record
  the evidence, then continue the review gate: self-CPO first, cross-review
  after self-CPO PASS. If the sprint is closed but the id is known, the next
  command is `sfs review --sprint <id> --gate <n>`; if the id is unknown, ask
  for that id instead of creating a new sprint or manually restoring
  `.sfs-local/current-sprint`.
- GitHub @codex review is post-implementation only. Do not request, trigger, or
  count GitHub @codex review during brainstorm or Gate 3 plan review.
- Gate 3 plan review is the required bridge between plan and implement. When a
  plan says ready-for-implement, review the plan contract first with
  `sfs review --gate 3`; only a PASS/accepted result should route to
  `sfs implement`.
- Gate 3 review PASS does not approve product judgment. If a plan introduces
  or changes product meaning, acceptance criteria meaning, IA, visible
  UI/workflow, public contract, security/privacy/data-loss posture, cost/model
  policy, or destructive behavior, the plan must mark
  `user_approval_required: true` and `user_approval_status: "pending"` until
  the user approves. If the plan claims no user decision is needed while
  redefining that meaning, return partial and require a user approval boundary
  instead of routing to implementation.
- When a Gate 3 result is PASS but user approval is still pending, the next
  action is not `sfs implement`; ask the user to approve/waive and record it
  with `sfs capture --kind user-approval --gate 3 "..."` or `sfs capture
  --kind waiver --gate 3 "..."`.
- Gate 3 review has a sequence: local self-review until PASS, then cross
  review. Cross review is independent confirmation after self-review, not a
  replacement for self-review.
- Gate 3 may use self-CPO fallback instead of cross review only when the
  evidence records a concrete operational constraint: no other agent
  subscription, external agent token exhaustion, or cross-review bridge
  unavailability. A bare self-CPO PASS is not enough unless the user explicitly
  waives the gate.
- Local self-review means a self-CPO mini-check, not just an advisor call. It
  must record pass/partial/fail and check requirements-to-AC-to-slice-to-ADR
  traceability, AC-to-file/artifact/evidence mapping, and SEED/placeholder/mock/
  fallback material as fail/partial/non-acceptance until replaced by real
  deliverables. If that evidence is absent, return partial and ask for the
  self-CPO pass before external cross review.
- If self-review returns partial/fail, rework the plan and run self-review
  again. If cross review returns partial/fail, rework the plan and return to
  self-review before another cross review.
- If the finding is deterministic, narrow, and does not require product owner
  judgment, complete the rework loop in the same cycle: patch the artifact, run
  the smallest verification, and invoke the same-gate review again before
  returning. Typical auto-rework findings include grep/file coverage holes,
  stale measured evidence, missing AC/file/artifact mapping, wrong evidence
  path, bounded wording cleanup, or documentation consistency that preserves
  meaning. Do not ask the user to trigger the next review for these cases.
- Escalate to the user instead of auto-reworking when the finding changes scope,
  architecture, public API/schema/CLI contract, security/privacy/data-loss
  posture, cost/latency/model policy, destructive behavior, or acceptance
  criteria meaning; also escalate after repeated partial/fail on the same
  micro-fix.
- Do not treat review volume as completion. Number of lenses, rounds, advisor
  comments, or elapsed time never unlocks `sfs implement`; only PASS or an
  explicit user waiver does.
- For Gate 3 plan review, use the CPO/evaluator role and prefer an independent
  executor or fresh agent context when available. The plan author, CTO, or
  generator should not self-approve the plan it will execute.
- Review handoff must follow Runtime Token Firewall: send a capsule containing
  the gate, lens, AC, files/artifacts, exact evidence paths, and bounded
  excerpts. Do not invoke Claude in-process plugin wrappers, rescue subagents,
  or forked contexts that forward the lead conversation history as the default
  review path.
- Review handoff must also follow Session Continuation Guard. If the current
  host session is already token-heavy, do not start cross-review in the same
  conversation. Record the review capsule and resume the review from a fresh
  session or real CLI bridge.
- Review durable product/context artifacts for Context Pollution Guard:
  prompt bodies, full transcripts, bridge probe output, `.sfs-local/tmp/...`
  scratch paths, and old review blobs in core docs are findings because they
  dilute the SSoT and burn future token budget.
- If the capsule is insufficient, return partial/fail and name the missing
  evidence. Do not request full chat history or repeatedly poll the lead thread
  to compensate for an underspecified review bundle.
- Summaries should list verdict, findings, required actions, evidence, and next gate.
  Show gates as `Gate N (Name)`, for example Gate 6 (Review), not a naked
  internal id.
- Lead with bugs, regressions, missing acceptance evidence, or risky behavior
  changes. Cosmetic drift is secondary unless it changes a documented contract.
- Label findings by action pressure: `Critical` for security/data-loss/release
  blockers, `Required` for must-fix acceptance gaps, `Important` for risks that
  should be handled now, `Optional` for non-blocking improvement, and `FYI` for
  context only. Do not make every comment feel equally mandatory.
- Review actual diff, files, test output, and logs. Do not infer pass from
  intent or from a familiar failure keyword.
- Flag overengineering, speculative abstraction, unrelated refactors, and
  adjacent cleanup when they are not traceable to the request.
- Check that final evidence names the exact verification command/result, or
  clearly explains why verification could not run.
- The generator does not self-approve its own implementation.
- If the evaluator executor equals the generator executor, call out the
  self-validation risk and prefer a separate model or fresh agent context when
  the change is user-facing, risky, or hard to verify.
- If implement.md records `agent_mode: parallel`, Gate 6 review must verify the
  multi-agent contract: disjoint files_scope per lane, one-sentence proposed
  commit message per lane, lane-level verification evidence, and cross review
  by a different agent before the final artifact acceptance verdict.
- If a parallel lane cannot be described as a clear commit unit, treat that as
  a split-design finding and require rework before PASS.
- Review proposed or actual commit messages against the user's
  native/workspace language. English commit messages are correct only when the
  user/repo language is English or the repo explicitly requires English.
- `sfs review` is an artifact acceptance review. Code review is only the
  `code` lens; docs, source-docs, simplify, security, performance,
  api-contract, strategy, design, taxonomy, QA, ops, management-admin, release,
  and generic artifacts use their own acceptance lens.
- GitHub `@codex` PR/code review is external code-review evidence only. Do not
  convert a PR approval, GitHub check PASS, or `@codex` comment into an SFS
  verdict. Such evidence does not satisfy self-CPO, SFS cross review,
  `sfs review`, Gate 3, or Gate 6 PASS by itself; `review.md` must still
  contain the SFS gate verdict from `sfs review`, or the user must explicitly
  waive that gate.
- External review/check PASS is a continuation trigger, not a stopping point.
  Codex, Claude, Gemini, and future LLM agents must name the next unmet SFS
  command instead of ending the turn at "PASS": run/record self-CPO first with
  `sfs review --gate <n>` or `sfs review --sprint <id> --gate <n>`, then run
  the configured cross-review sequence after self-CPO PASS.
- Gate 6 implementation review order is self-CPO first, then cross CPO, then
  GitHub @codex PR/code review as final external evidence when
  available. Use `sfs review --gate 6 --stage self`, then
  `sfs review --gate 6 --stage cross`, and only then push/PR for @codex. If the
  user only has self-CPO available, record that constraint and use the self-only
  path.
- Before a completed work slice can be reported as done, require self-agent
  top-model CPO evidence. Claude self-CPO uses Opus 4.7, Codex self-CPO uses
  `gpt-5.5` with xhigh reasoning, Gemini self-CPO uses `gemini-3-pro-auto`, and
  custom runtimes use their configured top-model equivalent. Partial/fail is not
  a stopping point: the CPO redirects the work, the author reworks it, verifies
  again, and repeats self-CPO until PASS or an explicit user waiver.
- Review scope is functional correctness + consistency only. Functional means
  the artifact delivers the declared behaviour (plan / Sprint Contract / AC).
  Consistency means cross-document SSoT (plan ↔ implement ↔ tests ↔ frontmatter)
  and AC ↔ test ↔ impl ↔ frontmatter alignment. Identifier naming, formatting,
  line-count drift, wording variants, and comment style are out-of-scope and
  must auto-skip when meaning is unchanged. Surface a finding only when it
  changes behaviour, traceability, or a documented contract. Public APIs, CLI flags/options,
  user- or automation-consumed paths, persisted data shapes, and domain ubiquitous terms
  are documented contract surfaces; renames there are in-scope even if they look like
  "just naming".
- Let the adapter's `review_lens` stand unless it is clearly wrong. Use
  `--lens <name>` only as an override.
- Repeated review for the same sprint/gate must converge. If `--lens auto`
  already selected a lens for that sprint/gate, later auto reviews reuse that
  lens instead of rotating to a new one. To intentionally change lens, pass an
  explicit `--lens <name>` and record why the review lane changed.
- Lens aliases and knowledge-pack paths are split to
  `policies/review-lens-routing.md`. Public lens names include `source-docs`,
  `simplify`, `security`, `performance`, `api-contract`, `strategy`, `design`,
  `taxonomy`, `qa`, `ops`, `management-admin`, and `release`.
- Review the whole contract, not only changed code: shared intent, domain
  language consistency, feedback evidence, interface/artifact boundaries, and
  gray-box delegation should still match the Gate 2/3 record.
- Load `policies/knowledge-pack-router.md` first, or
  `policies/knowledge-pack-router.ko.md` for Korean preference. Read matching
  split packs only when the router maps the current review scope to them.
- For design/frontend work, check `design.md` or `docs/solon/design.md` when it
  exists. Treat token drift as review evidence: arbitrary colors, type sizes,
  spacing, radius, shadows, icon weights, or screen-by-screen style changes can
  be findings even when the UI is functional. If no design contract exists for
  reusable UI, surface that as an AI-slop risk rather than silently accepting
  average-looking output.
- For visible frontend/UI implementation, missing pre-user browser evidence is
  a review finding. Look for Playwright/Cypress/Storybook/browser automation
  evidence, desktop and mobile/small viewport screenshots or traces, primary
  workflow interaction, text fit/overflow and responsive layout checks, and a
  console/runtime error note. If browser verification could not run, require
  an exact blocker plus alternate evidence or an explicit user waiver.
- Surface the evaluator's next action. Pass should name `sfs retro` as the
  normal close path for Gate 6/7 because `retro` ensures `report.md` before
  closing. Gate 3 (Plan) PASS is different: name `sfs implement` or the
  implementation handoff as the next action and carry required review items into
  the first implementation slice. Mention `sfs report` only for report preview
  or past-report rebuild. Partial should name the smallest rework slice; fail
  should return to plan, implementation, or user escalation.
- Adapter stdout is evidence, not the whole user-facing answer. Claude, Codex,
  and Gemini must all render the same compact SFS action rail after review:
  verdict, evidence/output path, required items, and exactly one `Next Action`.
  Do not end on "PASS" without the next SFS command.
- For Gate 3 Plan review, partial/fail should name the smallest plan rework and
  the next self-review command. It must not ask whether to implement unless the
  user explicitly asks to waive the gate.
- If the review finds a repeated agent mistake, record the smallest harness
  improvement: guardrail/check/hook/context-rule. Claude users may map this to
  Hookify; other agents should use their equivalent hook or scripted check.
