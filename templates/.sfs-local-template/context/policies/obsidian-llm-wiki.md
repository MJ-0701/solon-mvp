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
- Multi-sprint or agent-heavy work: use the wiki as a retrieval map for core
  design, domain language, tests, CI, release paths, and decision history.
- Do not delay urgent implementation only because the wiki is missing. Capture
  the gap and create the wiki in a follow-up documentation slice.

## Recommended Shape

- Vault root: repository root.
- Wiki root: `llm-wiki/`.
- Keep source truth in existing docs, code, tests, and scripts.
- Wiki pages are TopicHubs, retrieval paths, DDD context maps, upgrade maps,
  and generated indexes.
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

## Review Questions

- Is Obsidian/wiki setup recommended, declined, blocked, or already present?
- Did the wiki point to source truth instead of copying large documents?
- For an existing project, were old docs and core components indexed before the
  next sprint relies on them?
- If a sprint changes domain language, release flow, tests, or core runtime
  components, was the relevant wiki map updated or a follow-up gap recorded?

## Evidence

- `llm-wiki/README.md` or equivalent wiki home.
- Retrieval guide or TopicHub links to source docs/components.
- `.gitignore` entries that keep Obsidian workspace/cache/plugin payloads out
  of commits.
- For existing projects, an adoption handoff plus wiki migration note.
