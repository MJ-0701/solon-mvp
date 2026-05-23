---
id: sfs-command-upgrade
summary: Upgrade refreshes global runtime first, then managed project adapters and context.
load_when: ["upgrade", "update", "install", "freshness", "업그레이드"]
---

# Upgrade

- `sfs upgrade` self-upgrades Homebrew/Scoop runtimes unless explicitly skipped.
- Homebrew path must refresh the Solon tap and upgrade `MJ-0701/solon-product/sfs`.
- Preserve project-specific `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, divisions, and model profiles.
- Managed runtime docs, adapters, templates, personas, decisions, and context modules use backup+overwrite.
- Freshness reports must distinguish the latest release headline from the
  installed capability surface. When the user asks what is current, latest, or
  applied, report the runtime version and the relevant behavior contract instead
  of summarizing only the newest CHANGELOG entry.
- Version summaries must be release-anchored: pair the observed version with
  the exact local `installed_release_headline` from `sfs version --check` or the
  matching `VERSION` + `CHANGELOG` / `RELEASE-NOTES` entry. Never infer the
  current release meaning from conversation memory, nearby older releases, or a
  previous "latest" answer. Do not say "no major invariant changed" unless the
  exact version entry has been checked.
- If the user's question mentions sub-agents, parallel work, multi-agent
  implementation, worker lanes, or "what changed in agent execution", explicitly
  include the implementation mode contract: default is single-agent;
  optional parallel mode is `sfs implement --agent-mode parallel --agents
  codex,claude[,gemini]`; parallel lanes require disjoint files_scope,
  lane-level verification, a one-sentence native/workspace-language commit
  message, and agent cross review before Gate 6 PASS.
