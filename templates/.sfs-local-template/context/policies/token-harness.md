---
id: sfs-policy-token-harness
summary: Ambient token and harness hygiene for any LLM runtime.
load_when: ["token", "harness", "context", "Claude", "Codex", "Gemini", "MCP", "Serena", "Hookify"]
---

# Token And Harness Hygiene

- Apply this silently during normal SFS work. Do not ask the user to run extra
  hygiene commands unless a concrete risk appears.
- Keep adapter memory thin: `SFS.md`, `CLAUDE.md`, `AGENTS.md`, and `GEMINI.md`
  should hold entry rules and project identity, not changelog, long history, or
  full API docs. Move durable detail to routed context modules, docs, reports,
  or ADRs.
- Treat persona/user memory files as bounded cache, not project truth. Durable
  knowledge belongs in source-linked docs/wiki/assets; persona memory gets a
  periodic memory audit for stale facts, noisy preferences, and reload-boundary
  notes when a runtime only injects memory at session start.
- Root LLM agent docs are stricter than ordinary entry docs: `CLAUDE.md`,
  `AGENTS.md`, and `GEMINI.md` should be frontmatter-only SFS pointers. Use
  `sfs agent doctor --fix` to archive and rewrite recognized SFS adapter bloat.
- Prefer context routing before broad reads: start from `sfs status`, current
  `report.md`/`retro.md`, `_INDEX.md`, and the command module, then inspect only
  files needed for the slice.
- Apply Context Diet before output compression: prefer concept-grained context
  modules, stable searchable terms, and one-line summaries that let agents
  decide whether a full read is needed. If compact text and raw text might
  diverge, read the raw source first; if meaning-loss risk remains, ask the
  user instead of guessing.
- Apply Runtime Token Firewall before delegating work: worker/review handoff is
  a small capsule with goal, AC, files_scope, commands, output paths, and compact
  evidence. Never forward full conversation history, hidden chain, unrelated
  prior turns, or old workbench transcripts to a cheaper worker or reviewer.
- Apply Context Pollution Guard before editing durable docs: core product and
  adapter context keeps accepted conclusions, not prompt bodies, raw chat,
  bridge probe output, `.sfs-local/tmp/...` scratch paths, or long review blobs.
  Prompt/context bloat is a product finding, not harmless documentation.
- Harness Engineering raises the AI ceiling by structure, not pleading. Prefer a
  small active tool surface, project-as-prompt consistency, automated checks, and
  human-owned understanding/design boundaries over longer prompts.
- Agent productivity is the harness target: optimize retrieved context, tool
  fit, slice size, parallelizable capsules, and verification loops before asking
  a human or model to "work faster".
- Project harness commands make that structure inspectable: `sfs harness doctor`
  checks readiness before long autonomy, and `sfs harness map --write` records
  the agent/team/artifact/test/release environment without starting workers.
  Doctor also surfaces session cost metrics (tokens, cache-read ratio,
  explore/edit mix, sidechain share) as signal-only advisories — never a block.
- Tool-surface budget: give agents the few tools, skills, MCPs, and routed
  context modules needed for the current slice. Defer or remove attractive but
  irrelevant tools so selection cost does not steal attention from the work. The same economy applies over time to standing checks: a surface that keeps coming back empty is demoted in check *frequency* and restored on change or on call, with inviolable gates exempt (`policies/loop-taxonomy.md` ATTENTION_DECAY_ON_BARREN_SURFACES).
- Project-as-prompt audit: folder shape, filenames, domain terms, test names,
  adapters, docs, and style are all prompts. If repeated AI mistakes trace to a
  messy structure, fix the structure or routing instead of restating warnings.
- Verification automation: when a result must be trusted repeatedly, turn the
  check into a test, smoke, hook, review prompt, or release gate. A reminder in
  chat is only a temporary mitigation.
- Skill and harness changes need discriminating evals when their value is not
  obvious: compare with-skill against a baseline, assert objective outcomes
  where possible, and include near-miss trigger queries so description drift
  does not steal adjacent work.
- Human understanding boundary: AI may analyze, code, review, and execute, but
  humans still own why the product exists, what tradeoff is acceptable, and what
  exception changes the design contract.
- Poll run artifacts instead of chat state. Workers should write status/result/
  evidence files; leads should inspect those files rather than repeatedly
  rereading source, diffs, build logs, or the main thread while waiting.
- Delegate heavy verification/investigation that produces build logs, smoke
  logs, test logs, broad grep/file dumps, or large diffs to a scoped worker and
  take back only verdict, failing lines, core evidence paths, and risk. The lead
  keeps root-cause, attribution, and fix-shape judgment instead of swallowing
  raw output into the main context.
- Token savings is secondary to quality. If compression would lower answer
  quality, hide evidence, weaken a risk warning, or break raw-source
  traceability, do not compress; return to full clarity.
- Absorb filefunc-style benchmark lessons only when they reduce irrelevant
  reads. Do not force SFS-wide one-file-one-function/type rules, mandatory
  annotations, or policy-file rewrites when that would add churn or hide safety
  rules.
- Prefer symbol/semantic navigation for large codebases. Claude users may use
  Serena; other agents should use LSP, IDE index, repo graph, or precise `rg`
  before reading entire directories.
- Treat repeated AI mistakes as harness debt. During review/retro, convert
  repeated corrections into guardrails, hooks, checks, or a short adapter/context
  rule instead of re-explaining the same warning every session. Record the
  caught failure as a durable avoidance rule in `.sfs-local/lessons.md`
  (`policies/lessons-accumulation.md`); that ledger is the persistence mechanism
  for this rule.
- Use usage reports when token drain feels abnormal. Claude users may use
  Session Report; other agents should use their own usage dashboard/logs. Do
  not guess blindly from vibes.
- Apply Session Continuation Guard when usage is abnormal. `sfs upgrade` updates
  runtime/project context, but it cannot shrink the already-open LLM
  conversation. If the token meter is 30% or higher before a new WU/sprint
  action, 50% or higher before a new gate/loop/review handoff, or one session
  spans multiple WUs/sprints or repeated loop wakeups, write a compact handoff
  and restart in a fresh session.
- CLAUDE.md Management is useful as audit/report input, but do not auto-apply
  its suggestions to SFS adapter docs. Propose only small, stable, high-signal
  edits.

## KNOB_DIAGNOSTIC_LADDER (context first, then effort, then model)

Enter the ladder on **cost per outcome**, never cost per token — the unit that decides anything
is what one finished result costs. Two questions before the knobs: **"what would this have cost
without an agent, counting the work that would simply not have been done?"**, and **"is this
hard work, or merely a lot of work?"** The second is the routing question — hard work on a small
tier is dearer once retries and human correction are counted, bulk work on the strongest tier
buys capability that goes unused, and a mixed pipeline inside one project is normal.

Model tier and effort/thoroughness are different knobs for different failure
modes: the model tier sets the **capability range** (what the agent can know
and reason about), effort sets **how thoroughly it works** (files read,
verification depth, how far it goes before checking in). The discriminating
question on a failed slice: **"did it fail because it didn't know (capability
→ model tier), or because it didn't look (thoroughness → effort)?"**

- **Escalation order on failure:** (1) check context/skills first — most
  failures are missing context, not missing capability (the map-vs-territory
  gap, `unknowns-and-deviations.md`); (2) raise effort/thoroughness; (3) only
  then raise the model tier. Inverting the order buys cost without fixing the
  cause. One uncertainty shortcut: when you cannot even *name where the fix
  lives* (route-unknown, not just detail-unknown), that is a capability gap —
  take the strong tier for the recon pass, then downshift for execution.
- **Downshift discipline (the mirror):** routine, judgment-free stretches
  route to a smaller tier and default effort — sustained success on a task
  class is the downshift signal, consumed by the existing capsule/worker
  routing (`runtime-token-firewall.md`, fcp-model-tier) rather than a new
  mechanism. Default effort first; tune per task-type preference, not per
  task.
- **Route from a record, not a feel.** The ladder's tier decision is decided
  against two recorded numbers per task class — **task completion ratio** and
  **cost per task** — and the second is why "start at the strongest tier, then
  downshift" is not extravagant: a stronger tier that needs fewer turns and
  less thinking often wins on cost *per task* while losing on cost per token.
  This pair is the measured binding behind every routing surface that consumes
  it (`external-orchestrator-entry.md` ADVISOR_STRATEGY_BINDING for selective
  advisor calls, `model-workaround-sunset.md` MODEL_HEAD_TO_HEAD_ON_UPGRADE for
  swap decisions) — recorded once here, not re-derived per surface.

External validation (by-reference): a Claude blog post on choosing model and
effort level (2026-07-07), a model-selection guide, and an overnight-agent
operator interview (2026-07-20/24); vendor model names, benchmark names,
effort-UI specifics, and every performance figure held out.

## SERIALIZE_EXPENSIVE_OPS

In any fan-out (parallel capsules, worker fleets, batch fixes), the **most
expensive operations — full build, full test suite, whole-repo verification —
run at a single serialization point**, never per-worker. Workers write patches
and small local checks only; a single runner (one daemon, one lead pass, one
scheduled batch) collects the accumulated patches, runs the expensive
operation once, and distributes results back. N workers each triggering a full
build multiplies the costliest step by N for no added signal. External
validation (by-reference): a Claude blog large-scale migration writeup
(2026-07-16) — fixers wrote patches while a single build daemon batched and
rebuilt; vendor and scale figures held out.

## CACHE_AWARE_PROMPT_LAYOUT

Prompt surfaces are cache surfaces: cached input costs a fraction of fresh
input (~10% — "Harnessing Claude's intelligence", 2026-04-02, by-reference),
and an edit to a static surface invalidates every cached read after it.

- **Static first, dynamic last.** Entry docs, kernel, and routed policies are
  the stable layers; volatile state (sprint status, dates, counters, tallies)
  lives in state files (`events.jsonl`, PROGRESS, status output) loaded after
  them — never edited into the static surface itself.
- **Update by append, not in-place edit.** A status change rides a new
  message/event/file line; editing an entry doc or policy mid-run to carry
  run state is both a cache break and a context-pollution finding.
- **Tool surface stable, not just narrow.** The kernel already requires a
  narrow active tool surface; keep it *stable* too — tool-list churn breaks
  caching and selection alike. Change the tool set at slice boundaries, not
  mid-run.
- **One model per run segment.** Route cost tiers through scoped
  workers/capsules (`runtime-token-firewall.md`, fcp-model-tier), not by
  swapping the model mid-conversation.

### Cache-prefix discipline

The layout above fixes *order*; this fixes *lifecycle* — the invalidation
rule in the section intro makes the stable layers session-scoped commitments,
not just ordering preferences.

- **Prefix surfaces are frozen for the session.** Root adapter docs, kernel,
  routed policy text, and the model tier are picked at session start from the
  work type (mid-run model swaps are already banned above; the same freeze
  covers the docs). If one must change mid-session:
  land the change, then start a fresh session on the new prefix instead of
  continuing on an invalidated cache.
- **Long sessions end; they are not repeatedly compacted.** Each in-place
  compaction rewrites the prefix and forfeits the cache again. At Session
  Continuation Guard thresholds, prefer a durable handoff plus fresh session
  (`session-continuation-guard.md`) over another compaction pass.
- **Delegation keeps the lead prefix warm.** Heavy exploration/verification
  goes to a scoped worker (Runtime Token Firewall above): the worker spends
  its own context and cache, and only the compact verdict re-enters the lead
  session instead of churning the lead window.
