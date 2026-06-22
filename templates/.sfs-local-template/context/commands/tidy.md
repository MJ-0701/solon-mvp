---
id: sfs-command-tidy
summary: Close work by keeping only durable artifacts and cold-archiving recoverable evidence.
load_when: ["tidy", "report", "retro", "archive", "close", "정리"]
---

# Tidy / Report / Retro

- Retention rule: keep only artifacts with a one-line reason to remain visible.
  If the reason is not clear in one sentence, remove it or pack it into cold
  history after report evidence exists.
- Context Pollution Guard applies while closing: prompt bodies, raw transcripts,
  bridge/run scratch, `.sfs-local/tmp/...` review prompt paths, and long logs
  must not remain in core product docs or routed context. Keep a short
  conclusion plus archive/evidence pointer instead.
- Workbench files are temporary: brainstorm, plan, implement, log, review.
- Shared handoff docs prefer
  `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/report.md` and
  `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/retro.md`.
  Legacy `docs/solon/<english-workspace>/<yyyyMMdd>/` folders are fallback
  only. `tidy --all --apply` may rehome high-confidence flat legacy folders
  into the domain-first path without overwriting existing files; ambiguous or
  conflicting folders stay visible for review.
- Report/retro prose should use the user's native/workspace language, matching
  the native-language commit message rule. Do not force English when the work
  conversation is Korean or another non-English language.
- `tidy --apply` archives workbench only after report evidence exists.
- `tidy --wiki-promote` is the docs/solon GC pre-pass: before compacting or
  archiving, create source-linked `llm-wiki/promotion-candidates/` notes from
  report/retro pairs. It promotes candidates, not conclusions; source records
  stay in `docs/solon/` and human review still decides actual wiki updates.
- Self-improvement loop (`policies/self-improvement-loop.md`): tidy is the APPLY
  stage of the end-to-end loop — the curation, skill-promotion, and sunset
  suggestions below all land here under the one human gate that map's invariants
  require.
- Skill promotion loop (`policies/skill-promotion-loop.md`): at tidy/retro,
  run `sfs harness doctor` and read the **Skill Promotion Candidates** section —
  repeated completed-work patterns (3+) it surfaces are skill/command candidates.
  A single hard task (multiple rounds / nontrivial debugging) is also a
  candidate at count 1 (COMPLEXITY_TRIGGER), and every candidate passes the
  policy's REJECTION_CRITERIA (must be a repeatable computer procedure).
  Suggest-only: a human decides whether to compile one; the loop never writes a
  skill. Success-path twin of `lessons-accumulation.md` (failure side). Before
  adopting a new OR evolved skill, clear EVOLUTION_ADOPTION_GATE, then run
  HELD_OUT_SCORING (two-stage cheap-keyword → cost-gated LLM-judge, before/after
  delta on a held-out set) — measured, but never overrides a gate or sign-off.
- Lessons curation pass (`policies/lessons-accumulation.md` CURATION_PASS): a
  periodic read-only review of the lessons ledger + event archives produces
  merge/graduation/skill-candidate suggestions; applying them happens here at
  tidy under the same human gate as skill adoption. Suggest-only — the pass
  never writes the ledger.
- Model-workaround sunset (`policies/model-workaround-sunset.md`): at tidy
  after a model swap/upgrade, surface rules tagged `model-workaround:` whose
  model no longer matches the active model as sunset-review candidates
  (keep / retire / generalize). Suggest-only, same rail as skill candidates.
- Apply `policies/deprecation-and-migration.md`: every visible leftover needs a
  replacement/handoff reason, cold archive path, or explicit user decision.
  Advisory cleanup may wait; compulsory cleanup needs risk such as stale state,
  data loss, security, or automation breakage.
- `events.jsonl` is allowed only while it has a one-line active-sprint reason:
  current sprint status/gate/review routing. It must be compact, not append-only
  history; repeated command opens replace older lines for the same sprint/gate.
  Before close/tidy/adopt prune closed-sprint lines, SFS preserves exact raw
  JSONL excerpts under `.sfs-local/archives/events/sprints/<sprint-id>.jsonl`.
  That loose archive path is the grep/tail recovery surface; sprint cold
  archives may include a copy for archaeology. Only after that preservation
  succeeds may closed-sprint lines be pruned and an empty active ledger deleted.
- Post-adopt surface cleanup is valid even when no sprint folders remain:
  `sfs tidy --all --apply` removes project-local cache notice files, placeholder
  `auth.env`, orphan `events.jsonl`, empty workbench dirs, and collapses
  top-level non-adopt archive buckets into `archives/adopt/surface-cleanup/...`;
  the durable `archives/events/` bucket is not collapsed.
- `retro` is the normal final close command and ensures `report.md` before
  closing. Do not recommend `report` before `retro` in the normal close path.
  Use `report` only for preview or past-report rebuild. Use `retro --draft`
  only when the user explicitly wants an open-only retro scratchpad.
- Final report/retro should preserve the cross-phase fundamentals that mattered:
  shared design concept, glossary/domain language, feedback evidence, boundary
  decisions, and any gray-box delegation still risky or deferred.
- If a wiki/workbench mission checklist exists, reconcile every item to evidence,
  waiver, or follow-up before `retro` close; unresolved checklist rows keep the
  close partial.
