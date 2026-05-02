---
doc_id: handoff-next-session
title: "Next session handoff — 0.5.81 current truth"
written_at: 2026-05-02T12:46:16Z
written_at_kst: 2026-05-02T21:46:16+09:00
last_known_main_commit: 8e9e548
visibility: raw-internal
source_task: release-0.5.81-retro-close-default
---

# Next Session Handoff

## 1. Current Truth

- Latest Solon Product release is `0.5.81-product`.
- Stable product repo: `2ceedde` / tag `v0.5.81-product`.
- Homebrew tap: `aa6fe33`.
- Scoop bucket: `c6d63c5`.
- Dev repo main at release handoff: `8e9e548`.
- Installed runtime reports:
  - `sfs 0.5.81-product`
  - `latest 0.5.81-product`
  - `status up-to-date`
- `bash scripts/verify-product-release.sh --version 0.5.81-product` passed:
  product tag, Homebrew formula/hash, Scoop manifest/hash, packaged context
  router tar/zip integrity, installed runtime, and dev/stable/Homebrew/Scoop
  clean handoff state all OK.
- `0.5.81-product` ships retro close default:
  - `sfs retro` is now the normal sprint completion command.
  - `sfs retro` opens/refines `retro.md`, ensures `report.md`, archives
    workbench evidence, closes the sprint, and creates the local close commit.
  - `sfs retro --close` remains a backward-compatible alias.
  - `sfs retro --draft` / `--no-close` preserve the old open-only behavior.
  - README and Guide now show the current flow ending with `sfs retro`.

## 2. Why This Handoff Exists

This is the compact current-truth handoff after the `0.5.81-product` release.
If future release work lands without updating `PROGRESS.md` + this file,
`resume-session-check.sh` should detect release handoff drift and stop the new
session before broad code inspection.

## 3. Validation Evidence

- `git push origin main` published dev main through `8e9e548`.
- `scripts/cut-release.sh --version 0.5.81-product --apply --allow-dirty` cut
  stable `2ceedde` and tag `v0.5.81-product`.
- Homebrew formula published `v0.5.81-product.tar.gz` with SHA256
  `f0361b520efe64931966e7f7fbf92ca2d5ab3a01fb6563052ced4958161be2f4`.
- Scoop manifest published `v0.5.81-product.zip` with SHA256
  `d8c450ce0873979908209f631e4205a7999c46a73033a21370ad61d47d7213f1`.
- `brew upgrade MJ-0701/solon-product/sfs` upgraded local runtime to 0.5.81.
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

- Do not re-open the retro close default work solely because it was just
  released; treat follow-up retro lifecycle changes as new WUs.
- Do not rely on this file as a second SSoT for release history; `PROGRESS.md`
  remains the live entry snapshot.
- Keep future release completion atomic: product release/cut + channel publish +
  verifier + `PROGRESS.md`/handoff update must land together.
- After a task branch is merged into `main`, do not use it for the next session;
  the next direct task gets a fresh branch from `main`.
