---
id: sfs-context-index
summary: Route Solon agents to the smallest context file needed for the current command.
load_when: ["always", "sfs", "route", "context"]
---

# SFS Context Router

Always keep entry docs small. Read `kernel.md` first, then only the matching
module:

## Commands (lifecycle rails)

- `commands/start.md` — start / new sprint / bash-first Next.
- `commands/adopt.md` — adopt existing project / compact baseline / DDD/TDD retrofit / documentation cleanup.
- `commands/profile.md` — profile / SFS.md project overview only.
- `commands/brainstorm.md` — Gate 2 shared understanding before plan.
- `commands/plan.md` — Gate 3 sprint contract and cross-phase fundamentals.
- `commands/implement.md` — implement / build / execute work.
- `commands/review.md` — review / CPO / verdict.
- `commands/capture.md` — minimal evidence primitive for approval / waiver / decision / blocker / external evidence; not a lifecycle step.
- `commands/ingest.md` — purpose-gated raw intake stub before llm-wiki compile.
- `commands/report-bug.md` — file an SFS-product bug to the official gh channel; confirm gate before fix.
- `commands/flowcheck.md` — postflight self-check that SFS ran per documented flow; classify divergence and route product bugs to report-bug.
- `commands/healthcheck.md` — read-only SFS runtime/project drift checker with report-bug draft output.
- `commands/recall.md` — token-zero session recall over session/handoff/PROGRESS logs via grep/date index (read-only).
- `commands/daily.md` — bookend daily operating loop (morning brief + evening recap) composing existing `status`/`recall`/`capture`/`tidy`/`loop`; a routine, not a binary.
- `commands/release.md` — release / deploy / Homebrew / Scoop.
- `commands/upgrade.md` — upgrade / update / install freshness.
- `commands/harness.md` — harness doctor/map for project autonomy readiness.
- `commands/tidy.md` — tidy / report / retro / archive.
- `commands/loop.md` — loop / autonomous work / queue.

## Policies — flow, gates, delegation, self-improvement

- `policies/mutex.md` — lock conflict or concurrent session.
- `policies/bug-report-lifecycle.md` — official bug channel, report template, confirm gate, dev-first|hotfix fix routing.
- `policies/flow-conformance-postflight.md` — flowcheck invariant registry + non-collapsing event contract; critical vs advisory + divergence classification.
- `policies/user-override-precedence.md` — explicit user command > SFS default; scoped overrides (wu|sprint|until-revoked) with always-surfaced transitions (#3 guard).
- `policies/zero-knowledge-activation.md` — any state SFS can detect+safely-apply must be reachable via detect→guide→consent(1x)→apply; requiring the user to know a command/flag/manual config edit = design bug. solo default / consent / standalone invariant. Gate 6 review check + activatable-states meta-test enforce it; reference = R5 auto-offer + R2 fallback promotion.
- `policies/context-conflict-gate.md` — detect contradictory directives across loaded context via opt-in `conflict-key`/`stance` markers; `sfs harness doctor` flags any slug declared both allow and deny (consumer `.sfs-local/context/` only). Conflict, not volume, is the real context failure.
- `policies/critical-rule-hook-promotion.md` — classify which documented rules promote from prose (Tier A) to gate/lint (Tier B) to code-enforced hook (Tier C); criteria = severity + mechanical detectability + pre-action interception, with recurrence as escalator. Hooks are the only 100%-enforcement layer.
- `policies/steering-surface-taxonomy.md` — decide WHERE a behavior instruction belongs (entry stub / routed policy / Gate·hook / capsule) by scoring load-timing + compaction + context-cost + authority; "Every time / Never" rules can't be guaranteed by prose and must promote to deterministic enforcement; managed-settings authority tier is by-reference only (solon operator overrides all).
- `policies/skill-promotion-loop.md` — suggest (never auto-create) skill/command candidates from repeated completed-work patterns; `sfs harness doctor` surfaces signatures recurring 3+ times (consumer logs only, read-only). Success-path twin of `lessons-accumulation.md`; acted on at `tidy`.
- `policies/model-workaround-sunset.md` — model-specific workaround rules carry a model/date source tag (MODEL_TAG_REQUIRED) and surface for sunset review on model change (keep / retire / generalize); untagged behavior workarounds are review findings; tidy surfaces stale-model tags.
- `policies/user-context-separation.md` — split context three ways: soul (agent identity, `personas/`) / user (operator, `operator-context.md`) / procedure (routed). Keeps identity thin and gives operator preferences their own home; template ships placeholders only; access/memory scoped per compartment (COMPARTMENT_SCOPING: baseline inherited + per-boundary override, cross-boundary memory non-leak).
- `policies/work-delegation-and-startup.md` — five-factor test for whether work is worth delegating as a WU, restate-and-clarify before starting, and runtime-tier selection (quick chat / assisted session / autonomous code); north star + trust-gated proactive-proposal authority (NORTH_STAR) and human-attention discipline (HUMAN_ATTENTION_IS_SCARCE: batch/repeat/limit-exposure/workload guardrail). 7-step step-1 alignment.
- `policies/loop-taxonomy.md` — single decision lens for choosing a loop type: trigger axis (prompt/goal/interval/event) x stop axis (judgment/criteria+turn-cap/cancel/goal-met) → minimum-complexity primitive; four types mapped by-reference (turn→default session, goal→`commands/loop.md` AC+turn-cap, time→SCHEDULED_RUN_CONTRACT, proactive→unattended runners + NORTH_STAR).
- `policies/self-improvement-loop.md` — the end-to-end map of the five self-improving policies as one cycle (signal -> record -> curate -> propose -> measure -> gate -> apply -> capture-delta); calls each owning policy by-reference and declares the six cross-cutting invariants once (suggest-only / ledger-authoritative / L-NNN preserved / measured-but-not-sufficient / no code auto-patch / scheduled-run contract).
- `policies/lessons-accumulation.md` — accumulate caught failures as durable avoidance rules in `.sfs-local/lessons.md`; consult on plan/flowcheck, append on failure, Gotchas slot.
- `policies/external-orchestrator-entry.md` — headless external orchestrator (Hermes-class) entry contract; inviolable gates, file-bus reporting, first-permission read-only.
- `policies/harness-autonomy.md` — project harness diagnosis, map, artifacts, human boundary, and autonomy loop; team roster as an explicit artifact (owns/scope/tools) and verifier!=implementer extended to "verification capability is the precondition for expanding autonomy".
- `policies/division-subagent-council.md` — six core divisions as always-on conceptual sub-agents.
- `policies/mainline-focus-guard.md` — keep helper tool/setup work subordinate to the main objective.
- `policies/ai-work-intake-routing.md` — four-part AI work intake and one-off/repeated/batch routing.
- `policies/credential-hygiene.md` — placeholders only on agent-visible surfaces; real keys live in one store, attach at the boundary per-consumer-scoped, rotate in one place; unattended runners get keys via env at spawn; agent acts as itself (AGENT_IDENTITY: service account, revoke-by-identity kill switch) and grants widen by audit not guess (GRANT_LIFECYCLE: baseline -> events.jsonl/tool_call audit -> one justified grant).

## Policies — token / context / session hygiene

- `policies/harness-readiness.md` — AI-readiness (Sanity) audit: 4-axis 0-2 rubric in `sfs harness doctor`, `.sfs-local/readiness-waiver`, readiness-before-cartography order discipline, knowledge graphs as opt-in pointers only (all signal-only).
- `policies/token-harness.md` — token/context hygiene, semantic search, repeated mistake guardrails.
- `policies/runtime-token-firewall.md` — capsule-only worker/review handoff and no full-history forwarding.
- `policies/sub-agent-capsule-contract.md` — structured field contract (goal/ac/files_scope/tools_allowed/output_paths/token_budget/timeout/pii_rules) for that capsule handoff.
- `policies/session-continuation-guard.md` — stop long-session token bleed with fresh-session handoff.
- `policies/context-pollution-guard.md` — keep core docs/context free of prompt bodies, transcripts, and scratch residue.
- `policies/md-line-budget.md` — 200-line ceiling for loadable md (routed context / top-level docs / operational logs / user long-form); warn(180)/partial(200)/fail(250) + archive rotation + harness `md-line-budget-violation`/`operational-log-lag` detectors; ko mirror at `policies/md-line-budget.ko.md`.
- `policies/search-tooling.md` — agents default to `rg` (ripgrep) for code/text search, `grep` only as fallback; ast-grep / Aider evaluated PASS for the SFS core (bash+Markdown majority) and stay opt-in consumer-project extensions; ko mirror at `policies/search-tooling.ko.md`.

## Policies — knowledge, citation, docs discipline

- `policies/source-pointer-citation.md` — cite external knowledge by namespaced pointer (`idea_wiki:LNNN-In`), never by content copy; advisory, runtime-independent, consumer placeholder.
- `policies/skill-catalog-discipline.md` — audit routed commands/policies against a nine-category skill lens to find coverage gaps; keep `load_when` trigger-centric (lint-locked); on-demand guardrail candidates (`/careful`, `/freeze`); setup-via-placeholder cross-link.
- `policies/doc-colocation-provenance.md` — change routed-context docs in the same change (colocation); machine-lock literal `_INDEX` routes against broken links (forward direction stays a review-lens flag); reference-doc skeleton (Grain/Scope/Usage/Gotchas/Cross-Ref); five-field provenance footer SSoT.
- `policies/agent-adapter-doc-refactor.md` — keep root LLM agent docs frontmatter-only and auto-refactor recognized SFS adapter bloat.
- `policies/sfs-router-doc-refactor.md` — keep `SFS.md` as a thin router and auto-refactor recognized policy dumps.
- `policies/domain-knowledge-assets.md` — turn expert domain know-how into AI-usable assets.
- `policies/domain-ontology-discipline.md` — keep domain entities/relationships compiled and reconciled on change; backs the ontology review lens.
- `policies/source-driven-development.md` — official-source verification for framework/library patterns.
- `policies/writing-discipline.md` — user-facing artifact writing discipline (no preamble / hedging / self-congratulation / re-statement / filler conclusions); ko mirror at `policies/writing-discipline.ko.md`.
- `policies/obsidian-llm-wiki.md` — recommended Obsidian LLM wiki setup for SFS project continuity.
- `policies/wiki-mission-checklist-skill.md` — live wiki checklist for long-context follow-through.

## Policies — engineering disciplines

- `policies/debugging-and-error-recovery.md` — stop-the-line failure triage and root-cause guardrails.
- `policies/deprecation-and-migration.md` — legacy state/API cleanup with replacement, archive, and migration evidence.
- `policies/shipping-and-launch.md` — reversible, observable release/deploy checklist.

## Policies — knowledge packs, review lenses, ko mirrors

- `policies/ddd-tdd-knowledge-pack.md` — DDD/TDD baseline for project scaffolds and implementation.
- `policies/review-lens-routing.md` — review lens aliases and split knowledge-pack loading.
- `policies/agent-build-review-lens.md` — review lens for work shipping AI agents / MCP servers / sub-agent harnesses (`lens:agent-build`); failure modes generic code review misses.
- `policies/knowledge-pack-router.md` — knowledge pack / review lens router (English).
- `policies/knowledge-pack-router.ko.md` — knowledge pack / review lens router (Korean).
- `policies/enterprise-agent-team-pack.md` — enterprise 6-division agent team parent pack.
- `policies/enterprise-plan-council-pack.md` — plan-stage 6-division council contract.
- `policies/enterprise-evidence-pack.md` — QA/QC evidence and project-applied validation.
- `policies/enterprise-performance-review-pack.md` — performance and algorithm review lens.
- `policies/gate6-data-validation-pack.md` — mock/fixture/seed/data validation at Gate 6.
- `policies/agentic-security-logging-pack.md` — OWASP-style security, console-log, and Datadog evidence guard.
- `policies/postdev-external-review-pack.md` — post-development Claude/Gemini/Codex review evidence.
- `policies/lean-procedure-refactor-pack.md` — keep/shrink/remove procedural bottleneck review.
- `policies/*-knowledge-pack.md` — English compact guidance packs for each lens/pack.
- `policies/*-knowledge-pack.ko.md` — Korean compact guidance packs for each lens/pack.
- `policies/*.ko.md` (general rule) — every `*.ko.md` is the Korean mirror of its same-named en policy; load the mirror when the session/workspace language is Korean. Mirrors keep their en counterpart's ASCII anchor tokens (uppercase section ids and check ids) verbatim; heading prose may be localized, so cross-reference by anchor token, not heading text.
- `policies/*-knowledge-pack-*.md` — split child packs loaded only after a parent pack activates matching ids.
- Backend split children: `backend-knowledge-pack-runtime*`, `backend-knowledge-pack-transactions*`, `backend-knowledge-pack-integration*`, `backend-knowledge-pack-operating*`.
- Design split children: `design-knowledge-pack-operating*`.
