---
doc_id: handoff-next-session
title: "Next session handoff - 0.5.85 current truth"
written_at: 2026-05-02T13:55:09Z
written_at_kst: 2026-05-02T22:55:09+09:00
last_known_main_commit: 77ebe55
visibility: raw-internal
source_task: release-0.5.85-guide-readme-close-flow
---

# Next Session Handoff

## 1. Current Truth

- Latest Solon Product release is `0.5.85-product`.
- Stable product repo: `4c1e1d0` / tag `v0.5.85-product`.
- Homebrew tap: `b8bb937`.
- Scoop bucket: `dcf1790`.
- Dev repo main at release handoff: `77ebe55`.
- Installed runtime reports:
  - `sfs 0.5.85-product`
  - `latest 0.5.85-product`
  - `status up-to-date`
- `bash 2026-04-19-sfs-v0.4/scripts/verify-product-release.sh --version 0.5.85-product`
  passed after the release handoff commit:
  product tag, Homebrew formula/hash, Scoop manifest/hash, packaged context
  router tar/zip integrity, installed runtime, and dev/stable/Homebrew/Scoop
  clean handoff state all OK.
- `0.5.85-product` ships the README/GUIDE close-flow cleanup:
  - GUIDE is now a beginner-first first-sprint walkthrough instead of a dense
    internal manual.
  - The normal user path is `status -> start -> brainstorm -> plan ->
    implement -> review -> retro`.
  - `sfs retro` is documented as the default sprint close.
  - `sfs report` and `sfs tidy` are documented as optional/special actions for
    report preview/rebuild and old workbench cleanup.
  - Installer onboarding now points new users through `review -> retro`, not
    `report` as a required intermediate step.

## 2. Why This Handoff Exists

This is the compact current-truth handoff after the `0.5.85-product` release.
If future release work lands without updating `PROGRESS.md` and this file,
`resume-session-check.sh` should detect release handoff drift and stop the new
session before broad code inspection.

## 3. Validation Evidence

- `docs: simplify guide close flow` landed on dev main as `77ebe55`.
- `scripts/cut-release.sh --version 0.5.85-product --apply --allow-dirty` cut
  stable `4c1e1d0` and tag `v0.5.85-product`.
- Stable main and tag were pushed to `MJ-0701/solon-product`.
- Homebrew formula published `v0.5.85-product.tar.gz` with SHA256
  `2cb92c79f3293ad5999c23346448f32c50b2cd3fa2c03935d3ed7bc774d171ff`.
- Scoop manifest published `v0.5.85-product.zip` with SHA256
  `315694043bb3799dae868887633bf9e56924f69edda0653e3e75568ce7059dbf`.
- `brew upgrade MJ-0701/solon-product/sfs` upgraded local runtime to 0.5.85.
- `sfs version --check` returned up-to-date.
- Full release verifier returned OK.

## 4. Default Action

1. Read `CLAUDE.md`, then `PROGRESS.md`.
2. Run `bash 2026-04-19-sfs-v0.4/scripts/resume-session-check.sh`; expected
   result is exit `0`.
3. If `release_handoff_drift` appears, stop and repair entry/handoff SSoT
   before inspecting product code.
4. With clean entry state, ask the user for the next WU/domain unless they give
   a direct task.
5. For a direct task, do not continue a previous session branch. Start from
   clean `main`, then create `feature/<slug>` or `hotfix/<slug>` from the
   requirement before editing.

## 5. Guardrails

- Do not re-open the README/GUIDE close-flow cleanup solely because it was just
  released; treat deeper docs architecture or command UX requests as new WUs.
- Do not rely on this file as a second SSoT for release history; `PROGRESS.md`
  remains the live entry snapshot.
- Keep future release completion atomic: product release/cut + channel publish +
  verifier + `PROGRESS.md`/handoff update must land together.
- After a task branch is merged into `main`, do not use it for the next session;
  the next direct task gets a fresh branch from `main`.
