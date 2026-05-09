---
id: sfs-policy-shipping-and-launch
summary: Release only when the change is reversible, observable, and verified across channels.
load_when: ["release", "deploy", "ship", "launch", "Homebrew", "Scoop"]
---

# Shipping And Launch

Use this policy for product release, package channel updates, production
deployment planning, and high-risk user-facing rollout.

Release rules:
- A product release is not done until the version is consistent across source,
  stable tag, package channels, installed runtime, and release notes.
- Shipping should be reversible, observable, and incremental where the product
  surface allows it.
- Every risky launch needs a rollback plan before deployment. For SFS package
  releases, the rollback plan is the previous stable tag plus channel manifest
  revert.
- Monitoring/evidence must be named. For SFS, that includes GitHub Actions,
  package archive hash parity, installed `sfs version --check`, and the release
  verifier.
- Feature flags or kill switches are preferred for application features. For
  CLI/package releases, equivalent safety is conservative defaults, backward
  compatible flags, and verified downgrade/recovery notes.

Pre-launch checklist:
- Tests/build/smoke checks pass.
- Security-sensitive or data-loss surfaces have explicit review evidence.
- Changelog and user-facing docs name the behavior change.
- Package manifests point at the intended version and hash.
- Rollback/recovery path is known.

Post-launch checklist:
- Remote channels resolve the new version.
- Installed runtime sees the new version as latest and up-to-date.
- CI/workflow runs for the release commit are green.
- Any skipped clean-handoff check is explicitly named with the reason.
