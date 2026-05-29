---
id: sfs-context-index
summary: Route Solon agents to the smallest context file needed for the current command.
load_when: ["always", "sfs", "route", "context"]
---

# SFS Context Router

Always keep entry docs small. Read `kernel.md` first, then only the matching
module:

- `commands/start.md` — start / new sprint / bash-first Next.
- `commands/adopt.md` — adopt existing project / compact baseline / DDD/TDD retrofit / documentation cleanup.
- `commands/profile.md` — profile / SFS.md project overview only.
- `commands/brainstorm.md` — Gate 2 shared understanding before plan.
- `commands/plan.md` — Gate 3 sprint contract and cross-phase fundamentals.
- `commands/implement.md` — implement / build / execute work.
- `commands/review.md` — review / CPO / verdict.
- `commands/capture.md` — minimal evidence primitive for approval / waiver / decision / blocker / external evidence; not a lifecycle step.
- `commands/release.md` — release / deploy / Homebrew / Scoop.
- `commands/upgrade.md` — upgrade / update / install freshness.
- `commands/harness.md` — harness doctor/map for project autonomy readiness.
- `commands/tidy.md` — tidy / report / retro / archive.
- `commands/loop.md` — loop / autonomous work / queue.
- `policies/mutex.md` — lock conflict or concurrent session.
- `policies/token-harness.md` — token/context hygiene, semantic search, repeated mistake guardrails.
- `policies/harness-autonomy.md` — project harness diagnosis, map, artifacts, human boundary, and autonomy loop.
- `policies/agent-adapter-doc-refactor.md` — keep root LLM agent docs frontmatter-only and auto-refactor recognized SFS adapter bloat.
- `policies/sfs-router-doc-refactor.md` — keep `SFS.md` as a thin router and auto-refactor recognized policy dumps.
- `policies/runtime-token-firewall.md` — capsule-only worker/review handoff and no full-history forwarding.
- `policies/sub-agent-capsule-contract.md` — structured field contract (goal/ac/files_scope/tools_allowed/output_paths/token_budget/timeout/pii_rules) for that capsule handoff.
- `policies/session-continuation-guard.md` — stop long-session token bleed with fresh-session handoff.
- `policies/division-subagent-council.md` — six core divisions as always-on conceptual sub-agents.
- `policies/mainline-focus-guard.md` — keep helper tool/setup work subordinate to the main objective.
- `policies/context-pollution-guard.md` — keep core docs/context free of prompt bodies, transcripts, and scratch residue.
- `policies/ai-work-intake-routing.md` — four-part AI work intake and one-off/repeated/batch routing.
- `policies/domain-knowledge-assets.md` — turn expert domain know-how into AI-usable assets.
- `policies/domain-ontology-discipline.md` — keep domain entities/relationships compiled and reconciled on change; backs the ontology review lens.
- `policies/source-driven-development.md` — official-source verification for framework/library patterns.
- `policies/writing-discipline.md` — user-facing artifact writing discipline (no preamble / hedging / self-congratulation / re-statement / filler conclusions); ko mirror at `policies/writing-discipline.ko.md`.
- `policies/md-line-budget.md` — 200-line ceiling for loadable md (routed context / top-level docs / operational logs / user long-form); warn(180)/partial(200)/fail(250) + archive rotation + harness `md-line-budget-violation`/`operational-log-lag` detectors; ko mirror at `policies/md-line-budget.ko.md`.
- `policies/search-tooling.md` — agents default to `rg` (ripgrep) for code/text search, `grep` only as fallback; ast-grep / Aider evaluated PASS for the SFS core (bash+Markdown majority) and stay opt-in consumer-project extensions; ko mirror at `policies/search-tooling.ko.md`.
- `policies/debugging-and-error-recovery.md` — stop-the-line failure triage and root-cause guardrails.
- `policies/deprecation-and-migration.md` — legacy state/API cleanup with replacement, archive, and migration evidence.
- `policies/shipping-and-launch.md` — reversible, observable release/deploy checklist.
- `policies/obsidian-llm-wiki.md` — recommended Obsidian LLM wiki setup for SFS project continuity.
- `policies/ddd-tdd-knowledge-pack.md` — DDD/TDD baseline for project scaffolds and implementation.
- `policies/review-lens-routing.md` — review lens aliases and split knowledge-pack loading.
- `policies/knowledge-pack-router.md` — knowledge pack / review lens router (English).
- `policies/knowledge-pack-router.ko.md` — knowledge pack / review lens router (Korean).
- `policies/enterprise-agent-team-pack.md` — enterprise 6-division agent team parent pack.
- `policies/enterprise-plan-council-pack.md` — plan-stage 6-division council contract.
- `policies/enterprise-evidence-pack.md` — QA/QC evidence and project-applied validation.
- `policies/enterprise-performance-review-pack.md` — performance and algorithm review lens.
- `policies/gate6-data-validation-pack.md` — mock/fixture/seed/data validation at Gate 6.
- `policies/agentic-security-logging-pack.md` — OWASP-style security, console-log, and Datadog evidence guard.
- `policies/wiki-mission-checklist-skill.md` — live wiki checklist for long-context follow-through.
- `policies/postdev-external-review-pack.md` — post-development Claude/Gemini/Codex review evidence.
- `policies/lean-procedure-refactor-pack.md` — keep/shrink/remove procedural bottleneck review.
- `policies/*-knowledge-pack.md` — English compact guidance packs for each lens/pack.
- `policies/*-knowledge-pack.ko.md` — Korean compact guidance packs for each lens/pack.
- `policies/*-knowledge-pack-*.md` — split child packs loaded only after a parent pack activates matching ids.
- Backend split children: `backend-knowledge-pack-runtime*`, `backend-knowledge-pack-transactions*`, `backend-knowledge-pack-integration*`, `backend-knowledge-pack-operating*`.
- Design split children: `design-knowledge-pack-operating*`.
