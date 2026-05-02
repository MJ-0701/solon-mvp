---
doc_id: progress-bullets-rotation-2026-05-03-pre-0-5-93
title: "PROGRESS bullets rotation — pre 0.5.93 archive (① Just-Finished + ④ Artifacts verbatim)"
parent_doc: 2026-04-19-sfs-v0.4/PROGRESS.md
split_from_section: "① Just-Finished, ④ Artifacts"
split_reason: "PROGRESS.md size cap (entry-path token cost) — keeping latest 3 product releases (0.5.93/0.5.94/0.5.95) in live PROGRESS, rotating older release bullets verbatim to this archive."
split_at: 2026-05-03T02:52:38+09:00
split_by_session: claude-cowork:modest-charming-keller
visibility: raw-internal
auto_load_required: false
replaces_in_parent: "single-line pointer in PROGRESS.md ① and ④ headers referencing this archive"
last_updated: 2026-05-03T02:52:38+09:00
covered_versions: ["0.5.60-product", "0.5.61-product", "0.5.62-product", "0.5.63-product", "0.5.64-product", "0.5.65-product", "0.5.66-product", "0.5.67-product", "0.5.68-product", "0.5.69-product", "0.5.70-product", "0.5.71-product", "0.5.72-product", "0.5.73-product", "0.5.74-product", "0.5.75-product", "0.5.76-product", "0.5.77-product", "0.5.78-product", "0.5.79-product", "0.5.80-product", "0.5.81-product", "0.5.82-product", "0.5.83-product", "0.5.84-product", "0.5.85-product", "0.5.86-product"]
notes: |
  Releases 0.5.87~0.5.92 (codex hotfix train, 2026-05-03) were not recorded in
  PROGRESS bullets at the time of release — they are documented in
  `solon-mvp-dist/CHANGELOG.md` and git log between commits `6111010..e3c98ad`.
  This archive therefore covers only the bullets that were physically present
  in PROGRESS.md ① and ④ as of the rotation timestamp above.
  This rotation is mechanical: no narrative content was changed, only relocated.
---

# PROGRESS bullets rotation — pre 0.5.93 archive

> **What this is**: a verbatim copy of the ① Just-Finished and ④ Artifacts
> bullets that lived in `2026-04-19-sfs-v0.4/PROGRESS.md` for product releases
> 0.5.60-product through 0.5.86-product, rotated out on 2026-05-03 to keep the
> live PROGRESS.md within the entry-path size cap. No semantic changes.

## ① Just-Finished — pre 0.5.93 (verbatim)

- WU-42 closed and released as `0.5.65-product`. Windows public docs now use
  `sfs.cmd` for PowerShell/cmd examples, keep `sfs` for Mac/Git Bash, and label
  source PowerShell installers as fallback rather than the recommended path.
- WU-43 closed locally at `6c4ca93`. `sfs start` now prints a readable
  `next: sfs brainstorm ...` line, and routed agent docs clarify that
  bash-first means no artifact refinement rather than no Next.
- WU-43 released as `0.5.66-product`: stable `d6af969` / tag
  `v0.5.66-product`; Homebrew `55dc2a2`; Scoop `36ad9c5`; release verifier
  passed and installed `sfs version --check` is up to date.
- WU-44 closed locally at `4430df2`. `sfs profile` is restored as a public
  command: packaged adapter, global CLI routing, dispatch routing, routed
  context, generated SFS.md overview placeholders, README/GUIDE, and agent
  adapter docs.
- WU-44 released as `0.5.67-product`: stable `dd6c018` / tag
  `v0.5.67-product`; Homebrew `a397a46`; Scoop `4d898da`; release verifier
  passed and installed `sfs version` reports `0.5.67-product`.
- User-directed SFS fundamentals + dual naming + runtime command-shape release
  shipped as `0.5.68-product`: stable `6546310` / tag `v0.5.68-product`;
  Homebrew `dbfdeb6`; Scoop `a2398d6`; release verifier passed and installed
  `sfs version --check` reports up to date.
- G4 review evidence upgrades shipped through `0.5.69-product` →
  `0.5.71-product`: evidence bundles now include implementation files, bounded
  source excerpts/diffs, indexed line targets, build/smoke evidence, scoped
  SFS/runtime classification, and generator executor attribution.
- Runtime safety release shipped as `0.5.72-product`: stable `3cb52b0` / tag
  `v0.5.72-product`; Homebrew `106c9a2`; Scoop `a2c7368`; installed
  `sfs version --check` reports up to date.
- Release verifier hardening landed at dev `4650738`: network checks, installed
  runtime checks, and clean handoff checks are bounded; verifier passed for
  `0.5.72-product` with dev/stable/Homebrew/Scoop all clean + synced.
- External study-note validation confirmed the upgraded G4 path: first Codex
  CPO run produced a real code-level `partial`, rework fixed read-mode PDF
  pointer pass-through, smoke/build passed, and rerun returned G4 `pass`.
- Context router upgrade repair shipped as `0.5.73-product`: stable `df8552a` /
  tag `v0.5.73-product`; Homebrew `9a30c0b`; Scoop `be4134e`; installed
  `sfs version --check` reports up to date. `sfs upgrade` now repairs missing
  context router targets even when the project already reports latest.
- Gate numbering/report-label cleanup validated locally: Solon report/CLI
  surfaces now prefer Gate 1~7 labels and `/sfs review --gate 6` for review,
  while older storage ids stay compatibility-only.
- Gate numbering/report-label cleanup + review evidence bundle hotfix shipped
  together as `0.5.74-product`: dev `ebf8a4a`; stable `2062971` / tag
  `v0.5.74-product`; Homebrew `7e00696`; Scoop `24f4aa8`; full release
  verifier passed and installed `sfs version --check` reports up to date.
- Gate 6 review evidence excerpt-priority hotfix shipped as
  `0.5.75-product`: stable `b9e3276` / tag `v0.5.75-product`; Homebrew
  `508162d`; Scoop `9d3eb60`; full release verifier passed and installed
  `sfs version --check` reports up to date. Collector now separates full
  manifests from bounded excerpt priority, promotes declared implement/plan
  target paths, includes safe `.env.example`, compacts `.gitignore`
  product-owned hunks, and separates same-tool review risk as warning metadata.
- Gate 6 review scope filter refinement shipped as `0.5.76-product`: stable
  `28366b1` / tag `v0.5.76-product`; Homebrew `4f7683b`; Scoop `291a03b`;
  full release verifier passed and installed `sfs version --check` reports up
  to date. `.claude/skills/sfs/**` is classified as SFS system scope, nested
  generated outputs like `backend/dist/**` and `backend/build/**` are excluded
  from reviewable manifests, and declared first-class source/config excerpts
  are emitted before the generic first-N cap.
- WU-45 closed locally at `8f16102`: Dev backend architecture guardrails now
  record the clean layered monolith → CQRS → Hexagonal guidance → MSA guidance
  ladder in `/sfs implement`, with Hexagonal refactor gated on user acceptance
  and MSA refactor gated on explicit approval.
- WU-46 closed locally at `a67d9b3`: Strategy-PM, Taxonomy, Design/Frontend,
  QA, and Infra now have lightweight-start policy ladders with trigger-evidence
  strengthening and user acceptance/approval before major roadmap,
  rename/schema, redesign, release-readiness, or infra/ops transitions.
- Dev/Division policy ladders shipped as `0.5.77-product`: stable `953f36f` /
  tag `v0.5.77-product`; Homebrew `d3510fb`; Scoop `54d8918`; full release
  verifier passed and installed `sfs version --check` reports up to date.
- WU-47 closed locally at `3f11052`: context-router audit confirmed fresh user
  `sfs init` installs routed context correctly, found the same-version upgrade
  repair gap for `_INDEX.md`/`kernel.md`, and slimmed this dev repo's Codex SFS
  Skill to the same 36-line router used by product projects.
- Context router same-version repair shipped as `0.5.78-product`: stable
  `aef689e` / tag `v0.5.78-product`; Homebrew `ce55700`; Scoop `252c75c`;
  package/runtime verifier passed and installed `sfs version --check` reports
  up to date.
- Review lens routing shipped as `0.5.79-product`: dev `be01069`; stable
  `d6b753f` / tag `v0.5.79-product`; Homebrew `f179e68`; Scoop `1215135`;
  full release verifier passed and installed `sfs version --check` reports up
  to date. `sfs review` now auto-selects code/docs/strategy/design/taxonomy/QA/
  ops/release/artifact acceptance lens and asks CPO for a concrete next action.
- Brainstorm depth modes shipped as `0.5.80-product`: dev `561aab9`; stable
  `68aa669` / tag `v0.5.80-product`; Homebrew `0ff49c5`; Scoop `7011133`;
  full release verifier passed and installed `sfs version --check` reports up
  to date. `sfs brainstorm` now supports `--simple`/`--easy`/`--quick`, default
  normal, and `--hard`; `sfs start` exposes the depth selector in its `next:`
  line so users discover the flow without reading the guide first.
- Retro close default shipped as `0.5.81-product`: dev `8e9e548`; stable
  `2ceedde` / tag `v0.5.81-product`; Homebrew `aa6fe33`; Scoop `c6d63c5`;
  full release verifier passed and installed `sfs version --check` reports up
  to date. `sfs retro` is now the normal close command; `--close` remains a
  compatibility alias and `--draft`/`--no-close` preserve open-only behavior.
- Product docs current flow shipped as `0.5.82-product`: dev `adc967f`; stable
  `a691e4c` / tag `v0.5.82-product`; Homebrew `90b157b`; Scoop `1c9c5da`;
  full release verifier passed and installed `sfs version --check` reports up
  to date. README is now a high-level map/TOC, detail docs live under
  `docs/ko` and `docs/en`, Korean 10x value docs were added, the English guide
  was added, and the docs explicitly state that GitHub Markdown has no native
  language-switch tabs.
- Stale version notice shipped as `0.5.83-product`: dev `a1fab8c`; stable
  `34bc0b2` / tag `v0.5.83-product`; Homebrew `054abff`; Scoop `49cf67a`;
  full release verifier passed and installed `sfs version --check` reports up
  to date. Initialized projects now get a throttled terminal notice when their
  project/runtime is at least five product releases behind latest; interactive
  `sfs status` asks whether to run `sfs upgrade` now; `SFS_VERSION_NOTICE=0`
  disables the notice.
- Ambient token/harness hygiene shipped as `0.5.84-product`: dev `13fff19`;
  stable `08e2cc1` / tag `v0.5.84-product`; Homebrew `c257847`; Scoop
  `376ee36`; full release verifier passed and installed `sfs version --check`
  reports up to date. SFS now applies cross-agent token/harness hygiene through
  routed context and emits throttled hygiene notices for oversized adapter docs,
  oversized workbench files, or large codebases; `.sfs-local/cache/` is ignored.
- GUIDE/README close-flow cleanup shipped as `0.5.85-product`: dev `77ebe55`;
  stable `4c1e1d0` / tag `v0.5.85-product`; Homebrew `b8bb937`; Scoop
  `dcf1790`; full release verifier passed and installed `sfs version --check`
  reports up to date. GUIDE is now a beginner-first first-sprint walkthrough,
  README stays a map/TOC, installer onboarding points through `review -> retro`,
  and `report`/`tidy` are documented as optional/special actions.
- Docs trim + KO/EN sync shipped as `0.5.86-product`: dev `503c327` (release
  handoff) + `62f7560` (work commit); stable `1ff3df5` / tag
  `v0.5.86-product`; Homebrew tap commit `8209ced`; Scoop bucket commit
  `5c681aa`; full release verifier 7/7 passed and installed
  `sfs version --check` reports up to date.
  README/GUIDE/`docs/ko`+`docs/en` no longer surface dev-internal rationale,
  migration tone, or near-duplicate sections; `sfs guide` added to README
  Command Surface; `sfs retro --draft` moved into the §11 reference table;
  `solon-mvp-dist/10X-VALUE.md` consolidated under
  `solon-mvp-dist/docs/en/10x-value.md` (KO/EN docs symmetry); historical
  `APPLY-INSTRUCTIONS.md` archived out of OSS surface.

## ④ Artifacts — pre 0.5.93 (verbatim)

- Product release: stable `72b2543` / tag `v0.5.60-product`; Homebrew `97ceb6c`; Scoop `d4c8866`.
- Product hotfix release: stable `39dd076` / tag `v0.5.61-product`; Homebrew `b60c810`; Scoop `0681b4e`.
- Product context-routing release: stable `fb60524` / tag `v0.5.62-product`;
  Homebrew `1a7d1f1`; Scoop `a5362d2`.
- Product beginner-guide release: stable `1bb4209` / tag `v0.5.63-product`;
  Homebrew `a2c72cd`; Scoop `093fac3`.
- Product beginner wording cleanup release: stable `60ba10b` / tag
  `v0.5.64-product`; Homebrew `7dfbf95`; Scoop `4c01e25`.
- Product Windows command docs release: stable `b8fc3c2` / tag
  `v0.5.65-product`; Homebrew `6538fda`; Scoop `9dd73fe`.
- Product start next-action release: stable `d6af969` / tag
  `v0.5.66-product`; Homebrew `55dc2a2`; Scoop `36ad9c5`.
- Product profile command restore release: stable `dd6c018` / tag
  `v0.5.67-product`; Homebrew `a397a46`; Scoop `4d898da`.
- Product SFS fundamentals + runtime command-shape release: stable `6546310` /
  tag `v0.5.68-product`; Homebrew `dbfdeb6`; Scoop `a2398d6`.
- Product G4 evidence bundle release: stable `f44a53c` / tag
  `v0.5.69-product`; Homebrew `867b3e4`; Scoop `c88e2c2`.
- Product code-level G4 packaging release: stable `13c1dcb` / tag
  `v0.5.70-product`; Homebrew `05b9c7d`; Scoop `60f4e66`.
- Product targeted G4 source evidence release: stable `b91d433` / tag
  `v0.5.71-product`; Homebrew `821e908`; Scoop `b799fba`.
- Product runtime safety guard release: stable `3cb52b0` / tag
  `v0.5.72-product`; Homebrew `106c9a2`; Scoop `a2c7368`.
- Product context router upgrade repair release: stable `df8552a` / tag
  `v0.5.73-product`; Homebrew `9a30c0b`; Scoop `be4134e`.
- Product Gate 1~7 UX + review evidence bundle release: stable `2062971` /
  tag `v0.5.74-product`; Homebrew `7e00696`; Scoop `24f4aa8`.
- Product Gate 6 review evidence prioritization release: stable `b9e3276` /
  tag `v0.5.75-product`; Homebrew `508162d`; Scoop `9d3eb60`.
- Product Gate 6 review scope filter release: stable `28366b1` / tag
  `v0.5.76-product`; Homebrew `4f7683b`; Scoop `291a03b`.
- WU-45 local dev commit: `8f16102`.
- WU-46 local dev commit: `a67d9b3`.
- Product division policy ladders release: stable `953f36f` / tag
  `v0.5.77-product`; Homebrew `d3510fb`; Scoop `54d8918`; dev `5f32322`.
- WU-47 local dev commit: `3f11052` (backfill `cc9785d`).
- Product context router same-version repair release: stable `aef689e` / tag
  `v0.5.78-product`; Homebrew `ce55700`; Scoop `252c75c`; dev `cc9785d`.
- Product review lens routing release: stable `d6b753f` / tag
  `v0.5.79-product`; Homebrew `f179e68`; Scoop `1215135`; dev `be01069`.
- Product brainstorm depth modes release: stable `68aa669` / tag
  `v0.5.80-product`; Homebrew `0ff49c5`; Scoop `7011133`; dev `561aab9`.
- Product retro close default release: stable `2ceedde` / tag
  `v0.5.81-product`; Homebrew `aa6fe33`; Scoop `c6d63c5`; dev `8e9e548`.
- Product docs current flow release: stable `a691e4c` / tag
  `v0.5.82-product`; Homebrew `90b157b`; Scoop `1c9c5da`; dev `adc967f`.
- Product stale version notice release: stable `34bc0b2` / tag
  `v0.5.83-product`; Homebrew `054abff`; Scoop `49cf67a`; dev `a1fab8c`.
- Product ambient token/harness hygiene release: stable `08e2cc1` / tag
  `v0.5.84-product`; Homebrew `c257847`; Scoop `376ee36`; dev `13fff19`.
- Product GUIDE/README close-flow cleanup release: stable `4c1e1d0` / tag
  `v0.5.85-product`; Homebrew `b8bb937`; Scoop `dcf1790`; dev `77ebe55`.
- Product docs trim + KO/EN sync release: stable `1ff3df5` / tag
  `v0.5.86-product`; Homebrew `8209ced`; Scoop `5c681aa`; dev `503c327`
  (release handoff) atop `62f7560` (work commit).
- Study-note G4 validation: `.sfs-local/tmp/review-runs/2026-W18-sprint-5-G4-20260502T054452Z.result.md`
  returned `pass` after code-level rework.
