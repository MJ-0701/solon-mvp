---
id: sfs-command-release
summary: Product release is complete only after stable tag, Homebrew, Scoop, and installed runtime verification.
load_when: ["release", "deploy", "배포", "Homebrew", "Scoop"]
---

# Release

- Product deploy = stable tag + Homebrew tap + Scoop bucket at the same version.
- Apply `policies/shipping-and-launch.md`: release must be reversible,
  observable, and verified. Know the rollback path before publishing.
- Use `cut-release.sh`, push stable main/tag, update both channel repos.
- Push is not categorically forbidden. Default safe mode may stop at exact
  push instructions, but if the user explicitly asks for autonomous deploy or
  grants push permission, run the necessary `git push` steps for source,
  stable, Homebrew, and Scoop repos and record the pushed refs as evidence.
  This policy applies to every LLM agent and runtime, including Codex, Claude,
  Gemini, and future agent adapters.
- Run `scripts/verify-product-release.sh --version <VERSION>` before saying done.
- If Homebrew local tap or installed `sfs version --check` is stale, release is not complete.
- Name GitHub Actions run ids, package archive hash parity, installed runtime
  freshness, and any intentionally skipped clean-handoff check in the release
  evidence.
