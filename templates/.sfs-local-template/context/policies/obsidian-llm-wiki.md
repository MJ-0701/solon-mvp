---
id: sfs-policy-obsidian-llm-wiki
summary: Recommended Obsidian LLM wiki setup for SFS projects.
language: en
load_when:
  - Obsidian
  - llm wiki
  - wiki
  - knowledge base
  - docs migration
  - existing project
  - new project
  - sprint continuity
status: filled-v1
content_policy: "recommended default; never hard-block a sprint when the user declines or the project cannot use Obsidian"
---

# Obsidian LLM Wiki Policy

Obsidian is a recommended companion for SFS projects because it is free, local-first, Markdown-native, and useful for LLM retrieval. Treat it as a recommended default, not a coercive dependency. If the user declines, the environment lacks Obsidian, or the repository policy forbids a vault, continue SFS with ordinary `docs/solon/` artifacts and record the waiver or blocker.

## Activation Rules

- New project: recommend a repo-root Obsidian vault and a small `llm-wiki/` navigation layer during setup or the first documentation sprint.
- Existing project: during `sfs adopt`, recommend migrating existing docs into an Obsidian-readable wiki by reference before the next real sprint.
- Applied project: if `.obsidian/` or `llm-wiki/` exists, treat Obsidian as active context. Check `llm-wiki/README.md` and `llm-wiki/ddd/README.md` before broad scans, and record a gap/waiver when the expected map is missing.
- Multi-sprint or agent-heavy work: use the wiki as a retrieval map for core design, domain language, tests, CI, release paths, and decision history.
- Documentation-poor project: do not treat missing docs as missing knowledge. Reconstruct a minimal memory baseline from code, git commit history, tests, config, release/deploy scripts, issue/PR traces, and user-provided notes. Mark inferred claims with source links, confidence, and gaps.
- Do not delay urgent implementation only because the wiki is missing. Capture the gap and create the wiki in a follow-up documentation slice.

## Recommended Shape

- Vault root: repository root.
- Wiki root: `llm-wiki/`.
- DDD operating model root: `llm-wiki/ddd/`.
- Keep source truth in existing docs, code, tests, and scripts; the wiki is the
  agent self-serve knowledge refrigerator, not the raw-food warehouse.
- Product identity boundary: wiki growth must serve SFS flow. If a wiki feature does not improve intent capture, plan contracts, review evidence, handoff, or repeated-context retrieval, keep it as deferred wiki tooling instead of Solon product scope.
- Large PDFs, media, and reference libraries may live in an external source manager. The wiki stores stable source IDs, metadata locators, access/rights notes, extraction status, and compile targets; it does not become the file warehouse.
- Wiki pages are TopicHubs, retrieval paths, DDD context maps, upgrade maps, and generated indexes.
- Treat the system as three layers: **Raw / Wiki / Schema (+lint)**. Raw is read-only source truth; Wiki is AI-owned, write-time compiled navigation plus glossary/ubiquitous-language home; Schema + lint are frontmatter, budgets, routing, review questions, verification, link checks, generated indexes, and human-approval rules that keep the wiki from becoming an uncurated pile.
- Knowledge packs are the **Schema-layer review lens** of this model, not wiki pages. They stay as read-only routed context (see `knowledge-pack-router`) and do not move into the wiki.
- Taxonomy is not a standalone wiki or org division. Treat it as a domain language/classification lens linked from `llm-wiki/ddd/` and the relevant TopicHubs.
- Host-local tool/skill bundles and user-home folders are external environment, not project SSoT, wiki roots, install targets, or migration sources. Do not install, clone, scaffold, or promote them while building the wiki unless the user explicitly asks; when referenced, record them as external environment evidence only. If a concept has already been absorbed by SFS, use the SFS command/policy surface instead of the host-local tool.
- Add or preserve `.obsidian/` shared settings only when the project wants them. Never commit personal workspace state, cache, or community plugin payloads.

## New Project Flow

1. Create the normal SFS scaffold first.
2. Recommend a minimal `llm-wiki/README.md` and retrieval guide.
3. Link SFS docs, product design, DDD/TDD method, tests, CI, and release paths.
4. From the next sprint, read the wiki map before broad repo scans.

## Existing Project Flow

1. Run `sfs adopt --apply "<brief>"` for the baseline handoff.
2. Classify documentation maturity: `sfs-native`, `documented-legacy`, or `documentation-poor`.
3. If code structure is in scope, add `--ddd-tdd-retrofit`.
4. Build an Obsidian wiki by reference: do not paste large source docs.
5. Index existing docs, scripts, tests, CI, package manifests, git history, and domain terms.
6. For documentation-poor projects, create the smallest useful memory baseline: project map, domain/DDD map, decision ledger, unknowns/gaps, questions ledger, dev guardrails, and bug/release/test memory.
7. Start the next sprint with the wiki as retrieval context and the source files as SSoT.

## Memory Formation And Migration

- **Memory migration** preserves existing SFS sprint records, `docs/solon/` artifacts, legacy docs, ADRs, README/GUIDE material, issue/PR notes, and git history; the wiki links to originals and records durable meaning, not duplicate text.
- **Memory formation** fills the gap when a project never had a real documentation system. Read code, tests, config, migrations, scripts, manifests, commit messages, release notes, and operation traces to infer the current project model with source link, confidence, owner if known, and a gap when evidence cannot prove meaning.
- Developer-written docs transfer tacit knowledge to the next maintainer quickly. The wiki makes that transfer tool-assisted: raise the next agent or developer's domain-knowledge level before feature work starts.
- Absence of a document is not permission to ask the user to re-explain the whole project. Search evidence first, record knowns/unknowns, and ask only the smallest product-significant question.
- A questions ledger should distinguish `answered`, `open`, `stale`, and `ask-again-only-if` facts so agents do not ask the user to repeat prior explanations.

## Write-Time Compile

- When a source document, meeting note, capture, decision, or useful agent
  answer arrives, compile the durable conclusion immediately into the relevant
  TopicHub, DDD map, index, or gap note instead of waiting for query-time
  rediscovery.
- Keep large raw notes, transcripts, generated output, and external references
  in their source location. The wiki records what the source means, where it is,
  what it connects to, and what is still missing.
- Source-bundle analysis tools are derived workspaces. Before copying their
  summaries, Q&A, infographics, PDFs, or slide outputs into the wiki, record the
  input source set, tool/model, output path, citation coverage, confidence/gaps,
  and promotion decision.
- RAG/vector search is an optional query-time accelerator over curated source
  and wiki metadata, not the source of truth or a fact guarantee. Sync workers
  index compiled wiki/source links with metadata and answer surfaces need source
  citation, no-answer behavior, and parser/chunk/retriever smoke evidence.
- Accepted AI answers may become wiki updates only after source links and
  confidence/gap notes are attached. Private or personal notes stay private
  unless a human explicitly approves promotion to shared project knowledge.

## Sprint Close Compile Contract

- `report.md` and `retro.md` remain the sprint close records: final scope, decision evidence, verification, risks, KPT, and PDCA learning. They are the transaction log for the finished sprint, not the long-horizon semantic index.
- `llm-wiki/` is the long-horizon memory layer. On `sfs retro` close, compile only durable meaning into the wiki: reused decisions, domain terms, architecture/release/test contract changes, recurring defects, and follow-up gaps.
- Do not copy the full report or retro into the wiki. Link to source artifacts and write the smallest useful TopicHub/map/glossary/bug-report update instead.
- If `.obsidian/` or `llm-wiki/` is present, the close artifact should include a wiki compile checklist or a gap/waiver. If no wiki surface exists, ordinary `docs/solon/` report/retro artifacts remain sufficient.
- Periodic docs GC should run **promote first, compact/archive second**.
  `sfs tidy --wiki-promote` may create `llm-wiki/promotion-candidates/` notes that
  link to report/retro sources and list promotion roots; it must not delete the
  source records or copy their full prose into the wiki.
- Shared knowledge promotion, deletion, sensitive/private material movement, and conflicting wiki/source-truth changes still require human review.

## Governance

- Agents may suggest wiki promotion, consolidation, or conflict resolution as a
  patch/PR, but shared knowledge changes need human review before merge.
- Team-level deletion, sensitive permissions, private material, and security
  exceptions remain human-owned decisions. Agents can prepare evidence and safe
  diffs, not silently decide them.
- Prefer small, reviewable knowledge promotions from member/private notes into
  shared `docs/solon/` or `llm-wiki/` maps. This keeps repeated explanations out
  of chat while preserving Git history and rollback.

## Review Questions

- Is Obsidian/wiki setup recommended, declined, blocked, or already present?
- If `.obsidian/` or `llm-wiki/` exists, did the agent treat it as active
  project context instead of skipping it?
- Did the wiki point to source truth instead of copying large documents?
- Did new source material get write-time compiled into a TopicHub/map/gap note
  instead of being left as query-time RAG residue?
- If an external source manager or source-bundle notebook is used, are source IDs,
  metadata locators, input set, output path, citations/confidence/gaps, and
  promotion decision recorded?
- On sprint close, did report/retro stay as close evidence while only durable
  meaning was compiled into the wiki?
- During docs GC, did promotion candidates get created before archive/compact,
  with source links and without copying report/retro wholesale?
- If RAG/vector indexing is present, does it index curated wiki/source metadata
  rather than replacing the wiki or source truth, and does the answer path have
  citations, no-answer behavior, and retrieval smoke evidence?
- Does any wiki/RAG/graph/ingest feature pass the Solon Advancement Scorecard,
  or is it explicitly deferred as wiki tooling outside Solon product scope?
- Did the agent avoid treating host-local tools, skills, or user-home folders as
  wiki/project SSoT, install targets, or migration sources?
- Does the active wiki have `llm-wiki/README.md` and `llm-wiki/ddd/README.md`,
  or a recorded gap/waiver?
- For documentation-poor projects, did the agent form a minimal memory baseline from code/git/tests/config before asking broad project questions?
- Did the wiki include an already-answered/questions ledger so repeated user explanations are not requested again?
- For an existing project, were old docs and core components indexed before the next sprint relies on them?
- If a sprint changes domain language, release flow, tests, or core runtime
  components, was the relevant wiki map updated or a follow-up gap recorded?
- Did any shared-knowledge promotion, deletion, sensitive permission, or private
  material movement receive human review?

## Evidence

- `llm-wiki/README.md` or equivalent wiki home.
- `llm-wiki/ddd/README.md` or a recorded DDD wiki gap/waiver.
- Retrieval guide or TopicHub links to source docs/components.
- TopicHub/map/gap updates that summarize durable conclusions by reference.
- External source-library/notebook manifest: source IDs, metadata locator, input
  set, output path, citations/confidence/gaps, and promotion decision.
- Minimal memory baseline for documentation-poor projects: project map, domain/DDD map, decision ledger, unknowns/gaps, questions ledger, dev guardrails, and bug/release/test memory when applicable.
- RAG/sync metadata policy or waiver when a vector/search layer is connected.
- PR/diff or approval note for promotion from private/member knowledge to shared
  project knowledge.
- If a host-local tool was explicitly requested, a note that marks it as
  external environment evidence, not project source truth.
- `.gitignore` entries that keep Obsidian workspace/cache/plugin payloads out
  of commits.
- For existing projects, an adoption handoff plus wiki migration note.

## WIKI-AIERA - AI-Era Wiki-Entry Lens

Review-lens prompts distilled from 2026-05/06 practitioner talks. Discussion
checks for AI-era wiki onboarding, not hard rules; cited claims are
speaker-time assertions. These are review questions only; the wiki collection and setup
mechanics they touch stay core-product surface, outside this Schema-layer lens.

- WIKI-AIERA-001: When entering an unfamiliar codebase or domain, ask whether the
  agent observed the running system first — runtime/log/metric plus git/test/config
  signals, the way an operator reads APM before touching production — and turned
  that into a glossary plus a map before broad change. The wiki glossary and
  `NN-*-map` pages are the durable output of that observation step, not a
  formality done afterward. This is the entry discipline, distinct from the
  documentation-poor reconstruction question above.
- WIKI-AIERA-002: Ask whether the purpose was confirmed before collecting or
  working — why this material, for which question (Gold In, Gold Out). Purpose
  decides what is worth compiling into the wiki; capturing first and asking why
  later fills it with residue. Pairs with ask-first and the smallest-question rule.
- WIKI-AIERA-003: Ask whether the second brain is indexed context, not a
  warehouse. Useful memory is split by topic/service/question metadata so an
  agent loads the needed slice, not every note. Pairs with Context Diet and
  write-time compile.
