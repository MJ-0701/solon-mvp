---
id: sfs-command-adopt
summary: Adopt existing projects into a compact SFS baseline without document sprawl.
load_when: ["sfs adopt", "adopt", "legacy baseline", "existing project", "documentation cleanup"]
---

# Adopt Command Context

Applies to `sfs adopt`.

Rules:
- Run the adapter first and keep stdout/stderr verbatim.
- `adopt` is bash-first for the repository scan and archive policy; AI-side work is a compact interpretation of the adapter result, not a replacement for it.
- A quoted free-text brief is valid: `sfs adopt "docs cleanup and current-state handoff"`.
- For existing codebase retrofit, use
  `sfs adopt --ddd-tdd-retrofit --apply "<brief>"`. It scans source paths for
  DDD-lite boundaries, writes `ddd-tdd-retrofit.md`, and seeds
  `docs/solon/domain-map.md`.
- For existing projects with meaningful docs, **strongly recommend** an Obsidian
  LLM wiki migration by reference after `adopt --apply`: preserve source docs as
  SSoT, create `llm-wiki/` maps/indexes, and start the next real sprint with that
  wiki as retrieval context. This is active guidance, not a hard-block — if the
  user declines, record a waiver (`.sfs-local/llm-wiki.waiver`) and continue
  adoption. `sfs harness doctor` will surface a one-line advisory until the wiki
  exists or a waiver is recorded (see `policies/obsidian-llm-wiki.md`).
- For projects without a real documentation system, **strongly recommend**
  Obsidian LLM wiki memory formation after `adopt --apply`: reconstruct tacit
  knowledge from
  code, git commit history, tests, config, release/deploy scripts, issue/PR
  traces, and user notes. Create only a minimal baseline: project map,
  domain/DDD map, decision ledger, unknowns/gaps, questions ledger, dev
  guardrails, and bug/release/test memory.
- Before asking broad project questions during adoption, check existing docs,
  commit history, wiki/domain maps, and the questions ledger. Ask only what the
  evidence cannot prove and mark answered facts so future agents do not ask the
  user to repeat the same explanation.
- Retrofit adoption does not move arbitrary project code. If DDD is missing,
  the next real sprint should choose one product behavior slice, write
  characterization/failing/smoke evidence first, then move that slice behind
  `domain`, `application`, `interfaces`, and `infrastructure` boundaries.
- TDD for legacy code starts from the next sprint; do not claim old code was
  test-first. The first refactor sprint must name the behavior and evidence
  path before code moves.
- Default mode is dry-run. If the user clearly wants files created, use `sfs adopt --apply "<brief>"`; otherwise show the dry-run result and ask before applying.
- Shared visible output is intentionally one handoff file under
  `docs/solon/<english-workspace>/<yyyyMMdd>/handoff.md`. For adopt, `<workspace>` is the
  adopt id (`legacy-baseline` by default, or `--id <name>`). Raw scan evidence
  belongs under `.sfs-local/archives/adopt/...`.
- Apply `policies/deprecation-and-migration.md`: legacy visible state is a
  liability unless it still earns its place. Archive or remove residue only
  after the durable handoff path exists, and report how to recover cold
  evidence.
- `adopt --apply` must not leave an active sprint pointer. It summarizes and
  cleans the legacy state; the first real sprint starts afterward.
- Visible `.sfs-local` after adopt is intentionally tiny: keep only runtime
  files with a one-line reason (`VERSION`, `config.yaml`, `divisions.yaml`,
  `model-profiles.yaml`) plus private compressed recovery evidence under
  `archives/adopt/` when evidence exists and raw event excerpts under
  `archives/events/sprints/<sprint-id>.jsonl` when the preexisting ledger had
  sprint-scoped lines. Do not leave `events.jsonl`, `current-sprint`, `tmp`,
  `cache`, empty `sprints`, `auth.env.example`, or template/auth placeholder
  residue visible after adopt.
- If a later upgrade or status command leaves `cache/*notice.env` or top-level
  `archives/runtime-*`/`archives/sprints` buckets, treat that as surface
  residue and run `sfs tidy --all --apply` to collapse it back under
  `archives/adopt/surface-cleanup/...` or remove it. `archives/events/` is the
  durable grep/tail surface for preserved event excerpts and must not be
  collapsed. `events.jsonl` is different: it may exist only for an active
  sprint's compact status/gate/review state; no active sprint means it is
  residue after preservation.
- Do not expand old sprint/archive material into the active working context unless the user asks for archaeology or recovery.
- After apply, the next useful move is usually `sfs start "<first real cleanup slice>"`, then Gate 2 (Brainstorm) if scope is still fuzzy.
- If wiki migration is accepted, the cleanup slice may be
  `sfs start "Obsidian LLM wiki baseline"` before feature implementation.
- If documentation is missing or weak, name the slice
  `sfs start "Obsidian LLM wiki memory formation"` and treat code/git/tests as
  evidence, not as final semantic truth without confidence/gap notes.
