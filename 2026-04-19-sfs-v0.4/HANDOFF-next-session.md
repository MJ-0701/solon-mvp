---
doc_id: handoff-next-session
title: "Next session handoff — 0.5.84 current truth"
written_at: 2026-05-02T13:48:00Z
written_at_kst: 2026-05-02T22:48:00+09:00
last_known_main_commit: 13fff19
visibility: raw-internal
source_task: release-0.5.84-ambient-token-harness-hygiene
---

# Next Session Handoff

## 1. Current Truth

- Latest Solon Product release is `0.5.84-product`.
- Stable product repo: `08e2cc1` / tag `v0.5.84-product`.
- Homebrew tap: `c257847`.
- Scoop bucket: `376ee36`.
- Dev repo main at release handoff: `13fff19`.
- Installed runtime reports:
  - `sfs 0.5.84-product`
  - `latest 0.5.84-product`
  - `status up-to-date`
- `bash scripts/verify-product-release.sh --version 0.5.84-product` passed:
  product tag, Homebrew formula/hash, Scoop manifest/hash, packaged context
  router tar/zip integrity, installed runtime, and dev/stable/Homebrew/Scoop
  clean handoff state all OK.
- `0.5.84-product` ships ambient token/harness hygiene:
  - Routed context now includes a cross-agent token/harness policy for thin
    adapter memory, symbol/semantic search, usage-report checks, and turning
    repeated AI mistakes into guardrails/checks.
  - `sfs-dispatch.sh` emits a throttled hygiene notice when adapter docs,
    current sprint workbench files, or source-file count suggest token waste.
  - The notice is cached with `.sfs-local/cache/hygiene-notice.env`.
  - `SFS_HYGIENE_NOTICE=0` disables it; `SFS_HYGIENE_NOTICE_TTL_SEC` controls
    the interval.
  - `.sfs-local/cache/` is now included in the managed `.gitignore` block.

## 2. Why This Handoff Exists

This is the compact current-truth handoff after the `0.5.84-product` release.
If future release work lands without updating `PROGRESS.md` + this file,
`resume-session-check.sh` should detect release handoff drift and stop the new
session before broad code inspection.

## 3. Validation Evidence

- `git push origin main` published dev main through `13fff19`.
- `scripts/cut-release.sh --version 0.5.84-product --apply --allow-dirty` cut
  stable `08e2cc1` and tag `v0.5.84-product`.
- Homebrew formula published `v0.5.84-product.tar.gz` with SHA256
  `b5dc0cffcd9adf58a9faefeb80f2440dffa916543511230387375202017deda3`.
- Scoop manifest published `v0.5.84-product.zip` with SHA256
  `b866e0943b857beb06dd978a7f5fa920fd2118f67c0fa9b4b84c8ee44a7b5379`.
- `brew upgrade MJ-0701/solon-product/sfs` upgraded local runtime to 0.5.84.
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

- Do not re-open the ambient token/harness hygiene work solely because it was
  just released; treat deeper plugin auto-detection or shell startup hooks as
  new WUs.
- Do not rely on this file as a second SSoT for release history; `PROGRESS.md`
  remains the live entry snapshot.
- Keep future release completion atomic: product release/cut + channel publish +
  verifier + `PROGRESS.md`/handoff update must land together.
- After a task branch is merged into `main`, do not use it for the next session;
  the next direct task gets a fresh branch from `main`.
