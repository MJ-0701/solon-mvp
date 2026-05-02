---
doc_id: handoff-next-session
title: "Next session handoff — 0.5.83 current truth"
written_at: 2026-05-02T13:24:00Z
written_at_kst: 2026-05-02T22:24:00+09:00
last_known_main_commit: a1fab8c
visibility: raw-internal
source_task: release-0.5.83-stale-version-notice
---

# Next Session Handoff

## 1. Current Truth

- Latest Solon Product release is `0.5.83-product`.
- Stable product repo: `34bc0b2` / tag `v0.5.83-product`.
- Homebrew tap: `054abff`.
- Scoop bucket: `49cf67a`.
- Dev repo main at release handoff: `a1fab8c`.
- Installed runtime reports:
  - `sfs 0.5.83-product`
  - `latest 0.5.83-product`
  - `status up-to-date`
- `bash scripts/verify-product-release.sh --version 0.5.83-product` passed:
  product tag, Homebrew formula/hash, Scoop manifest/hash, packaged context
  router tar/zip integrity, installed runtime, and dev/stable/Homebrew/Scoop
  clean handoff state all OK.
- `0.5.83-product` ships stale version notice:
  - Initialized projects get a terminal notice when the project/runtime version
    is at least five product releases behind the latest published tag.
  - The notice is throttled with `.sfs-local/cache/version-notice.env`.
  - `install` / `upgrade` / `version` / `help` / agent management commands are
    skipped.
  - Interactive `sfs status` asks whether to run `sfs upgrade` now.
  - `SFS_VERSION_NOTICE=0` disables the notice; `SFS_VERSION_NOTICE_TTL_SEC`
    controls the cache interval.

## 2. Why This Handoff Exists

This is the compact current-truth handoff after the `0.5.83-product` release.
If future release work lands without updating `PROGRESS.md` + this file,
`resume-session-check.sh` should detect release handoff drift and stop the new
session before broad code inspection.

## 3. Validation Evidence

- `git push origin main` published dev main through `a1fab8c`.
- `scripts/cut-release.sh --version 0.5.83-product --apply --allow-dirty` cut
  stable `34bc0b2` and tag `v0.5.83-product`.
- Homebrew formula published `v0.5.83-product.tar.gz` with SHA256
  `29e07e545d58ad24e186489d3b59c7fb5f61836b0c7730fdac6fce71b93b8c23`.
- Scoop manifest published `v0.5.83-product.zip` with SHA256
  `6a0be68989a0147f6e75879151853b927992d31f0e2515fbd514145592d65b47`.
- `brew upgrade MJ-0701/solon-product/sfs` upgraded local runtime to 0.5.83.
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

- Do not re-open the stale version notice work solely because it was just
  released; treat shell startup hooks or richer release-note previews as new WUs.
- Do not rely on this file as a second SSoT for release history; `PROGRESS.md`
  remains the live entry snapshot.
- Keep future release completion atomic: product release/cut + channel publish +
  verifier + `PROGRESS.md`/handoff update must land together.
- After a task branch is merged into `main`, do not use it for the next session;
  the next direct task gets a fresh branch from `main`.
