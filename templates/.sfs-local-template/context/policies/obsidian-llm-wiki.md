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

Obsidian is a recommended companion for SFS projects because it is free, local
first, Markdown-native, and useful for LLM retrieval. Treat it as a recommended
default, not a coercive dependency. If the user declines, the environment lacks
Obsidian, or the repository policy forbids a vault, continue SFS with ordinary
`docs/solon/` artifacts and record the waiver or blocker.

## Activation Rules

- New project: recommend a repo-root Obsidian vault and a small `llm-wiki/`
  navigation layer during setup or the first documentation sprint.
- Existing project: during `sfs adopt`, recommend migrating existing docs into
  an Obsidian-readable wiki by reference before the next real sprint.
- Applied project: if `.obsidian/` or `llm-wiki/` exists, treat Obsidian as
  active context. Check `llm-wiki/README.md` and `llm-wiki/ddd/README.md`
  before broad scans, and record a gap/waiver when the expected map is missing.
- Multi-sprint or agent-heavy work: use the wiki as a retrieval map for core
  design, domain language, tests, CI, release paths, and decision history.
- Do not delay urgent implementation only because the wiki is missing. Capture
  the gap and create the wiki in a follow-up documentation slice.

## Recommended Shape

- Vault root: repository root.
- Wiki root: `llm-wiki/`.
- DDD operating model root: `llm-wiki/ddd/`.
- Keep source truth in existing docs, code, tests, and scripts.
- Wiki pages are TopicHubs, retrieval paths, DDD context maps, upgrade maps,
  and generated indexes.
- Treat the system as three layers:
  raw data source, wiki, and harness. Raw data sources are the source truth;
  the wiki is a write-time compiled navigation and concept layer; the harness
  is the frontmatter, line budget, routing, review, and verification rules that
  stop the wiki from becoming an uncurated pile.
- Taxonomy is not a standalone wiki or org division. Treat it as a domain
  language/classification lens linked from `llm-wiki/ddd/` and the relevant
  TopicHubs.
- Host-local tool/skill bundles and user-home folders are external environment,
  not project SSoT, wiki roots, install targets, or migration sources. Do not
  install, clone, scaffold, or promote them while building the wiki unless the
  user explicitly asks; when referenced, record them as external environment
  evidence only. If a concept has already been absorbed by SFS, use the SFS
  command/policy surface instead of the host-local tool.
- Add or preserve `.obsidian/` shared settings only when the project wants
  them. Never commit personal workspace state, cache, or community plugin
  payloads.

## New Project Flow

1. Create the normal SFS scaffold first.
2. Recommend a minimal `llm-wiki/README.md` and retrieval guide.
3. Link SFS docs, product design, DDD/TDD method, tests, CI, and release paths.
4. From the next sprint, read the wiki map before broad repo scans.

## Existing Project Flow

1. Run `sfs adopt --apply "<brief>"` for the baseline handoff.
2. If code structure is in scope, add `--ddd-tdd-retrofit`.
3. Build an Obsidian wiki by reference: do not paste large source docs.
4. Index existing docs, scripts, tests, CI, package manifests, and domain terms.
5. Start the next sprint with the wiki as retrieval context and the source
   files as SSoT.

## Write-Time Compile

- When a source document, meeting note, capture, decision, or useful agent
  answer arrives, compile the durable conclusion immediately into the relevant
  TopicHub, DDD map, index, or gap note instead of waiting for query-time
  rediscovery.
- Keep large raw notes, transcripts, generated output, and external references
  in their source location. The wiki records what the source means, where it is,
  what it connects to, and what is still missing.
- RAG/vector search is an optional query-time accelerator over curated source
  and wiki metadata, not the source of truth. Sync workers should index the
  compiled wiki and source links with metadata rather than dumping arbitrary
  chunks and asking the next agent to reconstruct meaning.
- Accepted AI answers may become wiki updates only after source links and
  confidence/gap notes are attached. Private or personal notes stay private
  unless a human explicitly approves promotion to shared project knowledge.

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
- If RAG/vector indexing is present, does it index curated wiki/source metadata
  rather than replacing the wiki or source truth?
- Did the agent avoid treating host-local tools, skills, or user-home folders as
  wiki/project SSoT, install targets, or migration sources?
- Does the active wiki have `llm-wiki/README.md` and `llm-wiki/ddd/README.md`,
  or a recorded gap/waiver?
- For an existing project, were old docs and core components indexed before the
  next sprint relies on them?
- If a sprint changes domain language, release flow, tests, or core runtime
  components, was the relevant wiki map updated or a follow-up gap recorded?
- Did any shared-knowledge promotion, deletion, sensitive permission, or private
  material movement receive human review?

## Evidence

- `llm-wiki/README.md` or equivalent wiki home.
- `llm-wiki/ddd/README.md` or a recorded DDD wiki gap/waiver.
- Retrieval guide or TopicHub links to source docs/components.
- TopicHub/map/gap updates that summarize durable conclusions by reference.
- RAG/sync metadata policy or waiver when a vector/search layer is connected.
- PR/diff or approval note for promotion from private/member knowledge to shared
  project knowledge.
- If a host-local tool was explicitly requested, a note that marks it as
  external environment evidence, not project source truth.
- `.gitignore` entries that keep Obsidian workspace/cache/plugin payloads out
  of commits.
- For existing projects, an adoption handoff plus wiki migration note.
