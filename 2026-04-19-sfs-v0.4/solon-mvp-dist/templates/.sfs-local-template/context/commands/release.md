---
id: sfs-command-release
summary: Product release is complete only after stable tag, Homebrew, Scoop, and installed runtime verification.
load_when: ["release", "deploy", "배포", "Homebrew", "Scoop"]
---

# Release

- Product deploy = stable tag + Homebrew tap + Scoop bucket at the same version.
- Use `cut-release.sh`, push stable main/tag, update both channel repos.
- Run `scripts/verify-product-release.sh --version <VERSION>` before saying done.
- If Homebrew local tap or installed `sfs version --check` is stale, release is not complete.
