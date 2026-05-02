---
doc_id: handoff-next-session
title: "Next session handoff — 0.5.77 current truth"
written_at: 2026-05-02T09:23:07Z
written_at_kst: 2026-05-02T18:23:07+09:00
last_known_main_commit: 5f32322
visibility: raw-internal
source_task: release-0.5.77-division-policy-ladders
---

# Next Session Handoff

## 1. Current Truth

- Latest Solon Product release is `0.5.77-product`.
- Stable product repo: `953f36f` / tag `v0.5.77-product`.
- Homebrew tap: `d3510fb`.
- Scoop bucket: `54d8918`.
- Dev repo main at release handoff: `5f32322`.
- Installed runtime reports:
  - `sfs 0.5.77-product`
  - `latest 0.5.77-product`
  - `status up-to-date`
- `bash scripts/verify-product-release.sh --version 0.5.77-product` passed:
  product tag, Homebrew formula/hash, Scoop manifest/hash, packaged context
  router tar/zip integrity, installed runtime, and dev/stable/Homebrew/Scoop
  clean handoff state all OK.
- `0.5.77-product` ships WU-45/WU-46 division policy ladders:
  - Dev/backend: clean layered monolith → CQRS → Hexagonal guidance →
    MSA guidance, with refactors gated on user acceptance/approval.
  - Strategy-PM, Taxonomy, Design/Frontend, QA, and Infra: lightweight MVP
    defaults, trigger-evidence strengthening, and approval before major
    roadmap, rename/schema, redesign, release-readiness, or infra/ops
    transitions.

## 2. Why This Handoff Exists

This is the compact current-truth handoff after the `0.5.77-product` release.
If future release work lands without updating `PROGRESS.md` + this file,
`resume-session-check.sh` should detect release handoff drift and stop the new
session before broad code inspection.

## 3. Validation Evidence

- `git push origin main` published dev main through `5f32322`.
- `scripts/cut-release.sh --version 0.5.77-product --apply` cut stable
  `953f36f` and tag `v0.5.77-product`.
- Homebrew formula published `v0.5.77-product.tar.gz` with SHA256
  `3d8bc660233d416fae012c9b9b45dd9f19821af97ab1afd760dcad80fb79bca2`.
- Scoop manifest published `v0.5.77-product.zip` with SHA256
  `64b78ca0263c44bc65b645c11143a84fe234d020bae441cc43cdded6850b4dc4`.
- `brew upgrade MJ-0701/solon-product/sfs` upgraded local runtime to 0.5.77.
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
