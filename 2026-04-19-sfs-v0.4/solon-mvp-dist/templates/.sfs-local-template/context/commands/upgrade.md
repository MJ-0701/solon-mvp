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
