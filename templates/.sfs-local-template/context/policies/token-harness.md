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
- Tool-surface budget: give agents the few tools, skills, MCPs, and routed
  context modules needed for the current slice. Defer or remove attractive but
  irrelevant tools so selection cost does not steal attention from the work.
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
