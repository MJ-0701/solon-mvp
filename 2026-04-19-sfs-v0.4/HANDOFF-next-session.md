---
doc_id: handoff-next-session
title: "Next session handoff — 0.5.79 current truth"
written_at: 2026-05-02T12:16:12Z
written_at_kst: 2026-05-02T21:16:12+09:00
last_known_main_commit: be01069
visibility: raw-internal
source_task: release-0.5.79-review-lens-routing
---

# Next Session Handoff

## 1. Current Truth

- Latest Solon Product release is `0.5.79-product`.
- Stable product repo: `d6b753f` / tag `v0.5.79-product`.
- Homebrew tap: `f179e68`.
- Scoop bucket: `1215135`.
- Dev repo main at release handoff: `be01069`.
- Installed runtime reports:
  - `sfs 0.5.79-product`
  - `latest 0.5.79-product`
  - `status up-to-date`
- `bash scripts/verify-product-release.sh --version 0.5.79-product` passed:
  product tag, Homebrew formula/hash, Scoop manifest/hash, packaged context
  router tar/zip integrity, installed runtime, and dev/stable/Homebrew/Scoop
  clean handoff state all OK.
- `0.5.79-product` ships review lens routing:
  - `sfs review` stays the user command and auto-selects an artifact acceptance
    lens: code, docs, strategy, design, taxonomy, QA, ops, release, or generic
    artifact.
  - Code review is now explicitly only the `code` lens.
  - CPO review prompts require a concrete next action in addition to verdict,
    findings, evidence gaps, and required CTO actions.

## 2. Why This Handoff Exists

This is the compact current-truth handoff after the `0.5.79-product` release.
If future release work lands without updating `PROGRESS.md` + this file,
`resume-session-check.sh` should detect release handoff drift and stop the new
session before broad code inspection.

## 3. Validation Evidence

- `git push origin main` published dev main through `be01069`.
- `scripts/cut-release.sh --version 0.5.79-product --apply` cut stable
  `d6b753f` and tag `v0.5.79-product`.
- Homebrew formula published `v0.5.79-product.tar.gz` with SHA256
  `111337313bbd8ae019c83bb5b511bda996354e9b84df0e93a3347abff0aeea38`.
- Scoop manifest published `v0.5.79-product.zip` with SHA256
  `3020424ee9abd3b154b1db6583d886e20c278a75096949b1e279e2f22307a4b4`.
- `brew upgrade MJ-0701/solon-product/sfs` upgraded local runtime to 0.5.79.
- `sfs version --check` returned up-to-date.
- Full release verifier returned OK.

## 4. Default Action

1. Read `CLAUDE.md`, then `PROGRESS.md`.
2. Run `bash scripts/resume-session-check.sh`; expected result is exit `0`.
3. If `release_handoff_drift` appears, stop and repair entry/handoff SSoT
   before inspecting product code.
4. With clean entry state, ask the user for the next WU/domain unless they give
   a direct task.
5. For a direct task, do not continue a previous session branch. Start from
   clean `main`, then create `feature/<slug>` or `hotfix/<slug>` from the
   requirement before editing.

## 5. Guardrails

- Do not re-open the review lens routing work solely because it was just
  released; treat follow-up review-mode changes as new WUs.
- Do not rely on this file as a second SSoT for release history; `PROGRESS.md`
  remains the live entry snapshot.
- Keep future release completion atomic: product release/cut + channel publish +
  verifier + `PROGRESS.md`/handoff update must land together.
- After a task branch is merged into `main`, do not use it for the next session;
  the next direct task gets a fresh branch from `main`.
