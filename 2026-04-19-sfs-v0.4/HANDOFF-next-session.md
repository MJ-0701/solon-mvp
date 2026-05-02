---
doc_id: handoff-next-session
title: "Next session handoff — 0.5.78 current truth"
written_at: 2026-05-02T09:41:34Z
written_at_kst: 2026-05-02T18:41:34+09:00
last_known_main_commit: cc9785d
visibility: raw-internal
source_task: release-0.5.78-context-router-core-repair
---

# Next Session Handoff

## 1. Current Truth

- Latest Solon Product release is `0.5.78-product`.
- Stable product repo: `aef689e` / tag `v0.5.78-product`.
- Homebrew tap: `ce55700`.
- Scoop bucket: `252c75c`.
- Dev repo main at release handoff: `cc9785d`.
- Installed runtime reports:
  - `sfs 0.5.78-product`
  - `latest 0.5.78-product`
  - `status up-to-date`
- `bash scripts/verify-product-release.sh --version 0.5.78-product` passed:
  product tag, Homebrew formula/hash, Scoop manifest/hash, packaged context
  router tar/zip integrity, installed runtime, and dev/stable/Homebrew/Scoop
  clean handoff state all OK.
- `0.5.78-product` ships WU-47 context-router repair:
  - Fresh user `sfs init` keeps the small `kernel + _INDEX + routed module`
    loading shape.
  - Same-version `sfs upgrade` now restores `_INDEX.md` and `kernel.md` when
    `.sfs-local/context/` is missing.
  - This dev repo now self-dogfoods the 36-line Codex SFS router plus
    `.sfs-local/context/`.

## 2. Why This Handoff Exists

This is the compact current-truth handoff after the `0.5.78-product` release.
If future release work lands without updating `PROGRESS.md` + this file,
`resume-session-check.sh` should detect release handoff drift and stop the new
session before broad code inspection.

## 3. Validation Evidence

- `git push origin main` published dev main through `cc9785d`.
- `scripts/cut-release.sh --version 0.5.78-product --apply` cut stable
  `aef689e` and tag `v0.5.78-product`.
- Homebrew formula published `v0.5.78-product.tar.gz` with SHA256
  `193c0285a0e0015abfce9f46512d15d3ab130b128742098eaa2b338ecbb7aa4b`.
- Scoop manifest published `v0.5.78-product.zip` with SHA256
  `08be0d48d972e733c98a3476ff91a98c52d24b2e4c9d6f891b80a9f5d4042a3f`.
- `brew upgrade MJ-0701/solon-product/sfs` upgraded local runtime to 0.5.78.
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

- Do not re-open the division-policy ladder work solely because it was just
  released; treat follow-up policy changes as new WUs.
- Do not rely on this file as a second SSoT for release history; `PROGRESS.md`
  remains the live entry snapshot.
- Keep future release completion atomic: product release/cut + channel publish +
  verifier + `PROGRESS.md`/handoff update must land together.
- After a task branch is merged into `main`, do not use it for the next session;
  the next direct task gets a fresh branch from `main`.
