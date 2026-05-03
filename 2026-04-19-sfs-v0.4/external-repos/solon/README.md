# Solon — multi-CLI marketplace for SFS

> Solo founder's AI-native sprint flow system. This repository hosts the slash-command discovery surface for three CLIs under one umbrella.

## What this repo is

Three install mechanisms, one source of truth:

| CLI | Mechanism | Install command |
|---|---|---|
| Claude Code | Plugin marketplace (`.claude-plugin/marketplace.json` + `plugins/solon/`) | `/plugin marketplace add MJ-0701/solon` then `/plugin install solon` |
| Gemini CLI | Extension (`gemini-extension.json` + `commands/sfs.toml`) | `gemini extensions install --consent --auto-update https://github.com/MJ-0701/solon.git` |
| Codex CLI | User-global skill at `~/.codex/skills/sfs/SKILL.md` (auto-discovered) | Bundled with `sfs` Homebrew/Scoop install — no separate command needed |

## Why three at once

Solon Product's `sfs` CLI is the same binary across all three agents (Claude Code, Codex CLI, Gemini CLI). Project work artifacts live in `.sfs-local/` (git-tracked, portable). The plugin/extension/skill files in this repo are **CLI-side discovery surfaces** — they let the model recognize and route `/sfs` (Claude), `sfs <subcommand>` (Gemini), `$sfs` (Codex) to the same global binary.

## One-liner install (real entry point)

You don't `git clone` this repo directly. Install Solon Product via Homebrew (macOS) or Scoop (Windows) — its post-install hook runs the three commands above for you, so all three CLIs gain `/sfs` discovery in one user action:

```bash
# macOS
brew install MJ-0701/solon-product/sfs

# Windows
scoop bucket add solon-product https://github.com/MJ-0701/solon-product
scoop install sfs
```

After install, `/sfs status` works in any project regardless of which CLI you're in.

## Project surface stays clean

This repo is the *discovery* surface. Your project tree stays free of `.claude/commands/`, `.gemini/commands/`, `.agents/skills/sfs/`. Sprint workbench / decisions / events / SFS.md / CLAUDE.md / AGENTS.md / GEMINI.md remain project-local (work artifacts), but per-CLI mechanism files do not.

Multi-CLI continuity test: open a project in Claude Code, commit work artifacts to git, switch to Codex CLI on the same project — the sprint state is intact because all three CLIs share `.sfs-local/` and the same `sfs` binary.

## Source

Primary repo (binary, install hooks, docs): https://github.com/MJ-0701/solon-product

This repo is a thin discovery surface and tracks Solon Product release versions.

## License

See `LICENSE` (TBD).
