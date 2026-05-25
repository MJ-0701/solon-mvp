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
- Release readiness inherits Gate 6 data/security evidence: representative
  fixture/mock validation where data changes, OWASP-style risk notes for touched
  surfaces, no stray production `console.log`/`debugger`/probe logs, and
  Datadog or equivalent redacted error telemetry evidence or waiver.
- Use `cut-release.sh`, push stable main/tag, update both channel repos.
- Before dispatching `publish-product-channels.yml`, run
  `scripts/sfs-channel-publish-preflight.sh --version <VERSION> --mode <pr|push>`.
  `workflow_ready` means the workflow can publish the Homebrew/Scoop repos.
  `manual_required` means do not dispatch the workflow for this release; publish
  the channel repos locally, push them, then run the release verifier. Missing
  `SOLON_RELEASE_BOT_TOKEN` is an optional workflow-automation gap, not a user
  blocker or release blocker when local channel credentials are already
  available.
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
- Post-development Claude Cowork/Gemini/GitHub review evidence is welcome after
  SFS self/cross review, but unavailable optional reviewers do not block release
  unless a real unresolved risk remains.
- Release retros should flag slow or duplicate SFS procedure as refactor work;
  do not preserve ceremony that does not protect quality.
