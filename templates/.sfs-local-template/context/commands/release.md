---
id: sfs-command-release
summary: Product release is complete only after stable tag, Homebrew, Scoop, and installed runtime verification.
load_when: ["release", "deploy", "배포", "배포해줘", "배포 프로세스", "배포프로세스", "Homebrew", "Scoop"]
---

# Release

- Product deploy = stable tag + Homebrew tap + Scoop bucket at the same version.
- Korean deploy trigger contract: when the user says "배포해줘", interpret it as
  "배포 프로세스 쭉 진행해줘". This is not a publish-only command: run release
  readiness checks, relevant tests, SFS review/검수, release cut, stable tag,
  Homebrew, Scoop, installed runtime verification, and final evidence reporting
  end to end.
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
