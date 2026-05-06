---
id: sfs-command-review
summary: Run or summarize review evidence without letting the generator self-approve.
load_when: ["review", "검토", "CPO", "verdict", "gate"]
---

# Review

- Adapter-run by default: run `sfs review ...` before summarizing.
- Do not create a new verdict from memory; use `review.md` and recorded result paths.
- Gate 3 plan review is the required bridge between plan and implement. When a
  plan says ready-for-implement, review the plan contract first with
  `sfs review --gate 3`; only a PASS/accepted result should route to
  `sfs implement`.
- Gate 3 review has a sequence: local self-review until PASS, then cross
  review. Cross review is independent confirmation after self-review, not a
  replacement for self-review.
- If self-review returns partial/fail, rework the plan and run self-review
  again. If cross review returns partial/fail, rework the plan and return to
  self-review before another cross review.
- Do not treat review volume as completion. Number of lenses, rounds, advisor
  comments, or elapsed time never unlocks `sfs implement`; only PASS or an
  explicit user waiver does.
- For Gate 3 plan review, use the CPO/evaluator role and prefer an independent
  executor or fresh agent context when available. The plan author, CTO, or
  generator should not self-approve the plan it will execute.
- Summaries should list verdict, findings, required actions, evidence, and next gate.
  Show gates as `Gate N (Name)`, for example Gate 6 (Review), not a naked
  internal id.
- Lead with bugs, regressions, missing acceptance evidence, or risky behavior
  changes. Cosmetic drift is secondary unless it changes a documented contract.
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
  `code` lens; docs, strategy, design, taxonomy, QA, ops, management-admin,
  release, and generic artifacts use their own acceptance lens.
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
- CLI review lens names are not always the same as division pack ids. Use
  public lens names in commands: `strategy-pm` maps to `strategy`,
  `design/frontend` maps to `design`, `infra` maps to `ops`, and
  `finance`/`accounting` maps to `management-admin`.
- Review the whole contract, not only changed code: shared intent, domain
  language consistency, feedback evidence, interface/artifact boundaries, and
  gray-box delegation should still match the Gate 2/3 record.
- Load `policies/knowledge-pack-router.md` first, or
  `policies/knowledge-pack-router.ko.md` for Korean preference. Read matching full
  division packs only when explicitly needed for review scope and from router
  mapping.
- For backend/JVM/Spring/JPA/transaction/batch/integration/DevOps/AWS work,
  check matching ids from `policies/backend-knowledge-pack.md` or
  `policies/backend-knowledge-pack.ko.md`.
  Flag both missing high-risk topics and over-activated topics for the project
  size.
- For strategy-pm, QA, design/frontend, infra, management-admin, or taxonomy
  work, read the matching `policies/*-knowledge-pack.md` or
  `policies/*-knowledge-pack.ko.md` file and check only the matching ids and
  compact guidance.
  Flag both missing high-risk division topics and over-activated topics.
- For design/frontend work, check `design.md` or `docs/solon/design.md` when it
  exists. Treat token drift as review evidence: arbitrary colors, type sizes,
  spacing, radius, shadows, icon weights, or screen-by-screen style changes can
  be findings even when the UI is functional. If no design contract exists for
  reusable UI, surface that as an AI-slop risk rather than silently accepting
  average-looking output.
- Surface the evaluator's next action. Pass should name `sfs retro` as the
  normal close path because `retro` ensures `report.md` before closing. Mention
  `sfs report` only for report preview or past-report rebuild. Partial should
  name the smallest rework slice; fail should return to plan, implementation,
  or user escalation.
- For Gate 3 Plan review, partial/fail should name the smallest plan rework and
  the next self-review command. It must not ask whether to implement unless the
  user explicitly asks to waive the gate.
- If the review finds a repeated agent mistake, record the smallest harness
  improvement: guardrail/check/hook/context-rule. Claude users may map this to
  Hookify; other agents should use their equivalent hook or scripted check.
