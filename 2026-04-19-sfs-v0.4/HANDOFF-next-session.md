---
doc_id: handoff-next-session
title: "Next session handoff — 0.5.72 current truth"
written_at: 2026-05-02T05:50:11Z
written_at_kst: 2026-05-02T14:50:11+09:00
last_known_main_commit: 4650738
visibility: raw-internal
source_task: codex-handoff-drift-guard
---

# Next Session Handoff

## 1. Current Truth

- Latest Solon Product release is `0.5.72-product`.
- Stable product repo: `3cb52b0` / tag `v0.5.72-product`.
- Homebrew tap: `106c9a2`.
- Scoop bucket: `a2c7368`.
- Dev repo main at handoff repair start: `4650738`.
- Installed runtime reports:
  - `sfs 0.5.72-product`
  - `latest 0.5.72-product`
  - `status up-to-date`
- `bash scripts/verify-product-release.sh --version 0.5.72-product` passed:
  product tag, Homebrew formula/hash, Scoop manifest/hash, installed runtime,
  and dev/stable/Homebrew/Scoop clean handoff state all OK.

## 2. Why This Handoff Exists

The prior entry state was stale: `PROGRESS.md` still said `0.5.68-product`, and
this handoff still described the old `0.5.42/0.5.43` release path. That broke
the "new session starts from completed previous work" contract.

This file is now the compact current-truth handoff. If future release work lands
without updating `PROGRESS.md` + this file, `resume-session-check.sh` should
detect `release_handoff_drift` and stop the new session before broad code
inspection.

## 3. External Validation Evidence

Study-note project validation exercised the upgraded SFS G4 review path:

- First latest review run returned `partial` with a real code-level finding:
  read mode annotation overlay could block native PDF iframe pointer behavior.
- Rework applied in study-note:
  - read mode annotation surface uses `pointer-events: none`;
  - sticky/pen modes keep input capture;
  - smoke adds read-mode pointer pass-through assertion.
- Verification passed:
  - `npm run smoke:pdf-workspace`
  - `npm run build`
  - `sfs review --gate G4 --executor codex` returned `pass`.
- Latest reported result path:
  `.sfs-local/tmp/review-runs/2026-W18-sprint-5-G4-20260502T054452Z.result.md`.

Conclusion: the G4 review evidence upgrade reached usable code-level review
quality; remaining failures should now be treated as either real code findings
or separately identified evidence packaging gaps.

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

- Do not re-open the product refactor solely because the previous handoff was
  stale. The release channels and study-note G4 validation already passed.
- Do not rely on this file as a second SSoT for release history; `PROGRESS.md`
  remains the live entry snapshot.
- Keep future release completion atomic: product release/cut + channel publish +
  verifier + `PROGRESS.md`/handoff update must land together.
- After a task branch is merged into `main`, do not use it for the next session;
  the next direct task gets a fresh branch from `main`.
