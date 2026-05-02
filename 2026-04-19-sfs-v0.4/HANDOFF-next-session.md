---
doc_id: handoff-next-session
title: "Next session handoff — 0.5.82 current truth"
written_at: 2026-05-02T13:05:00Z
written_at_kst: 2026-05-02T22:05:00+09:00
last_known_main_commit: adc967f
visibility: raw-internal
source_task: release-0.5.82-product-docs-current-flow
---

# Next Session Handoff

## 1. Current Truth

- Latest Solon Product release is `0.5.82-product`.
- Stable product repo: `a691e4c` / tag `v0.5.82-product`.
- Homebrew tap: `90b157b`.
- Scoop bucket: `1c9c5da`.
- Dev repo main at release handoff: `adc967f`.
- Installed runtime reports:
  - `sfs 0.5.82-product`
  - `latest 0.5.82-product`
  - `status up-to-date`
- `bash scripts/verify-product-release.sh --version 0.5.82-product` passed:
  product tag, Homebrew formula/hash, Scoop manifest/hash, packaged context
  router tar/zip integrity, installed runtime, and dev/stable/Homebrew/Scoop
  clean handoff state all OK.
- `0.5.82-product` ships current product documentation:
  - README is now a high-level flow and table of contents rather than a detail
    warehouse.
  - Detailed docs live under `docs/ko` and `docs/en`, with explicit language
    links because GitHub Markdown has no native language-switch tabs.
  - Korean 10x value docs and an English onboarding guide were added.
  - GUIDE/README now reflect the recent release train: brainstorm depth,
    plan-as-contract, non-code implementation artifacts, review lens routing,
    and retro-as-close.
  - The release script allowlist now includes `docs/` so bilingual docs ship in
    stable packages.

## 2. Why This Handoff Exists

This is the compact current-truth handoff after the `0.5.82-product` release.
If future release work lands without updating `PROGRESS.md` + this file,
`resume-session-check.sh` should detect release handoff drift and stop the new
session before broad code inspection.

## 3. Validation Evidence

- `git push origin main` published dev main through `adc967f`.
- `scripts/cut-release.sh --version 0.5.82-product --apply --allow-dirty` cut
  stable `a691e4c` and tag `v0.5.82-product`.
- Homebrew formula published `v0.5.82-product.tar.gz` with SHA256
  `12f1df91d7be6699ef212d85780f189ffa500b4d652b55c442f5654779bcf3d1`.
- Scoop manifest published `v0.5.82-product.zip` with SHA256
  `d1a69638962939f7eeb2ece040068bfd07876453afb31cf8144ddc3f94a3ccc1`.
- `brew upgrade MJ-0701/solon-product/sfs` upgraded local runtime to 0.5.82.
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

- Do not re-open the documentation current-flow work solely because it was just
  released; treat follow-up docs IA/language/tab UX changes as new WUs.
- Do not rely on this file as a second SSoT for release history; `PROGRESS.md`
  remains the live entry snapshot.
- Keep future release completion atomic: product release/cut + channel publish +
  verifier + `PROGRESS.md`/handoff update must land together.
- After a task branch is merged into `main`, do not use it for the next session;
  the next direct task gets a fresh branch from `main`.
