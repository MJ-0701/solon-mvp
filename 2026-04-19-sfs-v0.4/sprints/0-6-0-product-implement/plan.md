---
phase: plan
gate_id: G1
sprint_id: "0-6-0-product-implement"
goal: "0.6.0 implement — R2 storage architecture 실 코드 + R3 sfs migrate-artifacts CLI + Homebrew/Scoop dual-channel release (suffix drop)"
visibility: raw-internal
created_at: 2026-05-03T22:40:00+09:00
last_touched_at: 2026-05-04T01:30:00+09:00
status: ready-for-implement   # ✅ G1 PASS LOCKED 2026-05-04T01:30+09:00 KST (Round 5 codex PASS + gemini PASS, 5 round cycle + 44 CTO fix items + 10+ CEO ruling locks). G2 implement 진입 = next session user 명시 명령 (자동 승급 금지, CLAUDE.md §1.3 + §1.20).
input_brainstorm: "sprints/0-6-0-product-implement/brainstorm.md (G0, status=ready-for-plan, 9/9 axes locked)"
spec_source:
  - "2026-04-19-sfs-v0.4/SFS-PHILOSOPHY.md (R1 spec, oss-public, 0.6.0-spec G6 PASS LOCKED)"
  - "2026-04-19-sfs-v0.4/storage-architecture-spec.md (R2 spec, oss-public)"
  - "2026-04-19-sfs-v0.4/migrate-artifacts-spec.md (R3 spec, oss-public)"
  - "2026-04-19-sfs-v0.4/improve-codebase-architecture-spec.md (R4 spec, 0.6.1 deferred)"
brainstorm_decisions_inherited:
  A1_repo_layout: "flat — solon-mvp-dist/scripts/sfs-*.sh 평면"
  B2_backward_compat: "전체 backfill — 옛 sprint 모두 main 0.6 schema migrate, 그 후 closed 는 archive branch"
  C4_gamma_migrate_artifacts_ux: "interactive (wizard 디폴트) + --apply (양 단계 confirm) + --auto (fully unattended) — 3 surface"
  D4_test_strategy: "unit + smoke + CI matrix (mac/Ubuntu/Win) + cross-instance verify (P-17, codex/gemini self-host smoke in CI)"
  E5_consumer_compat: "deprecation warning + 6 mo grace (hard cut 2026-11-03) + user 명시 승인 opt-in migrate"
  F4_with_lifecycle: "full structured yaml + lifecycle, close 시 user prompt (archive vs delete)"
  G2_alpha_version: "hard cut, 0.6.0 부터 suffix drop, 0.5.x historical 보존"
repo_target: "2026-04-19-sfs-v0.4/solon-mvp-dist/ (R-D1 dev-first per CLAUDE.md §1.13)"
current_version: "0.5.96-product"
target_version: "0.6.0"
hard_cut_date: "2026-11-03 (E5 6 mo grace 만료)"
session: "claude-cowork:affectionate-trusting-thompson (Round 0 plan authoring) → claude-cowork:wizardly-quirky-gauss (Round 1 fix patch)"
round_1_fix_patch_applied: "2026-05-03T23:45:00+09:00 (16 items: F1~F8 + S2-N1~N7 + S3-N1~N3, see review-g1.md §7.4.3 + §7.4.4)"
round_2_fix_patch_applied: "2026-05-04T00:10:00+09:00 (12 items: S2-N3/N4/N5/N7 + S3-N1/N2 wording polish + S2R2-N1~N6 신규, see review-g1.md §7.6.2 + §7.6.3)"
round_3_fix_patch_applied: "2026-05-04T00:40:00+09:00 (11 items: Tier 1 critical S3R3-N1 sentinel isolation + S3R3-N2 commit idempotence + S3R3-N3 snapshot ext filter + AC10 R-H + AC11/12/13 promotion. Tier 2 cleanup anti-AC8→anti-AC10 §5 / footer round-2→round-4 / sentinel regex [0-9a-f]{16} / --commit-existing-dirty 제거 / prompt 4→3 file count / JSON null semantics + trace count, see review-g1.md §7.7.3 + §7.7.4)"
round_4_fix_patch_applied: "2026-05-04T01:15:00+09:00 (5 items, Q3 cosmetic skip + meta-rule: Q1 Sprint Contract §5 + §4 + AC8.3 update AC1~AC9 → AC1~AC13 / Q2 R-D D-4(iv) wording reword (sentinel value-only mask, env var name OK — public convention 정합) / Q4 review-g1 frontmatter executor_round_2/3 Round 4 verdict 갱신 / Q5 R-H.H-2 manifest schema 9 fields enum (snapshot_id+created_at+source_repo_root+source_sha+files+total_count+total_bytes+skipped+extension_filter_applied) AC10.2 정합 / Q6 anti-AC10 skipped[] allowed non-loss exclusion 명시. user 직접 판단 (not codex blanket 추천), see review-g1.md §7.8.3 + §7.8.5)"
ceo_ruling_lock:
  S2_N3_sfs_version_output: "α — preserve current pattern `sfs 0.6.0` (현 0.5.96-product 까지 사용 중인 wording 유지). 0.5.x consumer 호환 ↑, suffix drop 본질(=tag/CHANGELOG header)과 무관, docs/test migration 0. (Round 1 lock)"
  Q1_S2R2_N1_package_identity: "α — preserve `sfs` 브랜드 (Formula/sfs.rb + bucket/sfs.json + command `sfs` + version 0.6.0). 0.5.x consumer brew/scoop install 호환 유지. (Round 2 lock 2026-05-04T00:10+09:00)"
  Q2_S2R2_N3_forced_migrate_commit: "α — backup+prompt default + `--commit` opt-in flag. consumer repo dirty working tree 자동 commit 방지, R-H.H-2 backup manifest 우선 생성, commit 은 user-explicit. (Round 2 lock 2026-05-04T00:10+09:00)"
  Q9_S2R2_N3_commit_existing_dirty: "제거 — `--commit-existing-dirty` flag 미정의 + test 부재 → 단순 wording (Round 3 default lock 2026-05-04T00:40+09:00)"
  Q2_S2R4_N2_log_masking_scope: "α — value-only mask. env var name (CODEX_API_KEY / GEMINI_API_KEY) 노출 OK (public convention, .github/workflows/*.yml 이미 visible). sentinel value (16-hex random suffix) 만 mask. (Round 4 lock 2026-05-04T01:15+09:00)"
---

# Plan — 0.6.0 implement sprint (G1)

> Sprint **G1 — Plan Gate** 산출물. brainstorm.md (G0) 의 9/9 lock 결정을 측정 가능한 sprint contract 로 변환.
> 입력 = brainstorm.md §6 Plan Seed 7 sub-section + spec sprint 의 4 신규 markdown spec.
> **Round 1 fix patch applied 2026-05-03T23:45+09:00**: review-g1.md §7.4.3 의 16 items (F1~F8 + S2-N1~N7 + S3-N1~N3) 통합. Round 2 parallel re-review 대기.

---

## §1. 요구사항 (Requirements)

본 sprint = **code sprint** (spec sprint 가 아님). 산출물 = 6+ 신규 bash script + bin/sfs dispatch 확장 + Windows wrapper + tests + CI workflow + VERSION bump + Homebrew/Scoop manifest 갱신.

- [ ] **R-A — Repo Layout**: `solon-mvp-dist/scripts/` 평면에 신규 6 script + `bin/sfs` dispatch 확장 + **Windows parity** (S2-N6).
  - 6 script: `sfs-storage-init.sh` / `sfs-storage-precommit.sh` / `sfs-archive-branch-sync.sh` / `sfs-sprint-yml-validator.sh` (validate **+ close** 두 mode dispatch — F6 codex preferred fix, 7번째 script 신설 회피 → AC1 6-count preserve) / `sfs-migrate-artifacts.sh` / `sfs-migrate-artifacts-rollback.sh`.
  - 각 script POSIX 호환 bash, executable, 기존 scripts/ 컨벤션 정합.
  - Windows wrapper: `solon-mvp-dist/bin/sfs.ps1` (PowerShell) + `solon-mvp-dist/bin/sfs.cmd` (cmd shim) — 신규 storage/migrate/archive/sprint 5 subcommand 동등 dispatch (현 0.5.96 multi-CLI parity 정합).

- [ ] **R-B — R2 Storage Architecture (B2 + (b))**: 7 elements 모두 spec 정합 구현 + 옛 sprint 전체 backfill.
  - **B-1** Layer 1 영구 path schema (`docs/<domain>/<sub>/<feat>/`) 생성/검증.
  - **B-2** Layer 2 작업 path schema (`.solon/sprints/<S-id>/<feat>/`) 생성/검증.
  - **B-3** co-location pattern (Layer 1+Layer 2 같은 feature 가 한 sprint 안에 묶임).
  - **B-4** N:M sprint × feature 매핑 (한 feature = 여러 sprint, 한 sprint = 여러 feature).
  - **B-5** `sprint.yml` shared file scope (lock semantics 0, advisory 0 — pure metadata + lifecycle, R-F 정합).
  - **B-6** pre-merge hook **CI workflow mandatory** (F5 codex+gemini): `.github/workflows/sfs-pr-check.yml` 가 4 validator 호출 + 실패 시 PR block. local `.git/hooks/pre-merge-commit` = optional/advisory.
  - **B-7** archive branch 자동화 (closed sprint 들 archive branch 로 이동, main 은 진행 중 + 신규) — **race 보호 flock(1) lock 또는 단일 owner 검증** (F7 race protection).
  - **B-8** 옛 sprint backfill (`sfs migrate-artifacts --backfill-legacy` flag) — **idempotent (재실행 = no-op default)** + `--force` flag overwrite (F7 idempotence).

- [ ] **R-C — R3 Migrate-Artifacts CLI (C4-γ)**: 3 surface 동시 + Pass 1/2 algorithm + reject + rollback.
  - **C-1** `sfs migrate-artifacts` (no flag) → interactive wizard (file 별 keep/skip/edit prompt).
  - **C-2** `sfs migrate-artifacts --apply` → batch with 양 단계 confirm (Pass 1 propose list user confirm → Pass 2 file 별 confirm).
  - **C-3** `sfs migrate-artifacts --auto` → fully unattended (Pass 1+2 자동 default 선택, CI 용).
  - **C-4** Pass 1 algorithm: `report.md` 존재 → archive auto, 부재 → **deterministic CLI prompt with structured questions** (S2-N7, bash CLI no-AI-runtime contract — `sfs migrate-artifacts` 가 fixed prompt list 띄움). External agent handoff (claude/codex/gemini invoke) = **R4 0.6.1 deferred** (out-of-scope).
  - **C-5** Reject granularity: file 단위 reject (한 file reject 시 나머지 진행), sprint 전체 영향 발견 시 sprint 단위 escalate.
  - **C-6** Rollback: `sfs migrate-artifacts --rollback <commit-sha>` flag — **`git revert` + Layer 1 `docs/` file movements atomic safety** (S3-N3): partial commit / interrupted mid-way 시 working tree 자동 복구 (transactional 보장 — pre-migrate snapshot manifest + post-fail restore).

- [ ] **R-D — Test (D4)**: unit + smoke + CI matrix + cross-instance verify.
  - **D-1** unit tests in `tests/test-sfs-storage-*.sh` + `tests/test-sfs-migrate-artifacts-*.sh` (bats 또는 자체 harness).
  - **D-2** smoke harness `tests/test-sfs-migrate-artifacts-smoke.sh` (가짜 consumer project 만들고 실 실행) + **Windows Scoop smoke `tests/test-sfs-windows-scoop-smoke.ps1`** (S2-N6 Windows parity).
  - **D-3** CI workflow `.github/workflows/sfs-0-6-storage.yml` (macOS + Ubuntu + Windows scoop 3 runner matrix).
  - **D-4** cross-instance verify `tests/test-sfs-cross-instance-verify.sh` (P-17 pattern, codex/gemini self-host smoke runner, CI 안에서 invoke). credential 관리 = GitHub Secrets (`CODEX_API_KEY` / `GEMINI_API_KEY`).
    - **D-4 fallback policy** (F4 codex 4-bullet): (i) PR (fork 포함) without secrets = **SKIP with warning**, (ii) `main` / nightly / release with secrets = both Codex+Gemini PASS required (block PR/release on either FAIL), (iii) external API outage (codex/gemini API down) = retry with exponential backoff (max 3) then **release-block** (PR fall back to skip+warning), (iv) **log masking — sentinel value-only (Round 4 Q2 = α)** (S3-N2 + S2R4-N2 alignment): `log.md` + CI logs 에서 sentinel **value** literal (`[0-9a-f]{16}` random suffix 포함 full sentinel string) grep result = 0. env var **name** 자체 (`CODEX_API_KEY` / `GEMINI_API_KEY`) 노출은 **OK** (standard public convention — `.github/workflows/*.yml` 에 이미 visible). mask 도구 = sed mask 또는 GitHub Actions `add-mask::<value>`.

- [ ] **R-E — Consumer Compat (E5)**: 0.5.x consumer deprecation warning + 6 mo grace + opt-in migrate.
  - **E-1** `sfs upgrade` 가 0.5.x consumer 감지 시 deprecation warning 출력 (정해진 wording, 6 mo grace + hard cut 2026-11-03 명시).
  - **E-2** `sfs upgrade --opt-in 0.6-storage` flag 또는 prompt confirm (`Migrate to 0.6.0 storage now? [y/N]`) 시 backfill 실행.
  - **E-3** `sfs upgrade` 가 0.6.x consumer 감지 시 silent (no warning).
  - **E-4** Hard cut date (2026-11-03) post-grace = **default forced migrate (in-scope)** — `sfs upgrade` 가 0.5.x 발견 시 자동 backfill 실행. **Config override (`SFS_HARD_CUT_BEHAVIOR=hard_fail`) 도입 여부 = out-of-scope** (F3 wording lock — §3 정합).

- [ ] **R-F — sprint.yml Lifecycle (F4 + (c))**: full structured yaml + lifecycle hook.
  - **F-1** Schema (yaml): `sprint_id` / `status` (draft/in-progress/ready-for-*/closed) / `features` (list) / `dependencies` (list) / `completion_criteria` (list) / `milestones` (list) / `created_at` / `closed_at`.
  - **F-2** Lifecycle hook: 진행 중 update 가능 (validator 가 schema 만 enforce, content mutate OK).
  - **F-3** Close 시 user prompt: `sfs sprint close <sprint-id>` (= `sfs-sprint-yml-validator.sh --mode close`, F6 codex preferred — validator script 안에 close mode dispatch) 가 prompt 출력 (`Archive this sprint.yml or delete? [a/d]`).
  - **F-4** (a) archive → `.sfs-local/archives/sprint-yml/<sprint-id>.yml.gz`.
  - **F-5** (d) delete → 완전 삭제 (project tree 깔끔).

- [ ] **R-G — Version Naming + Release Plumbing (G2-α + S2-N4 + S3-N1)**: 0.6.0 부터 suffix drop, hard cut + release discovery + artifact integrity audit.
  - **G-1** `solon-mvp-dist/VERSION` = `0.6.0` (single line, no suffix).
  - **G-2** `bin/sfs version` 출력 = **`sfs 0.6.0`** (S2-N3 α — preserve current CLI pattern, 0.5.x consumer 호환 유지). plan 의 신규 wording `Solon SFS v0.6.0` 은 **rejected** (CEO ruling 2026-05-03T23:45+09:00).
  - **G-3** CHANGELOG entry header = `## [0.6.0]` (no `-product` suffix).
  - **G-4** Homebrew formula url tag = `v0.6.0`, sha256 갱신 + **`brew audit --new-formula` PASS** (S3-N1 artifact integrity audit, broken manifest = release 전체 break 방지).
  - **G-5** Scoop manifest version = `0.6.0`, hash 갱신 + **scoop manifest schema check** (S3-N1, `scoop checkver` 또는 `scoop bucket validate` 동등) **PASS**.
  - **G-6** 0.5.x 태그는 historical 보존 (delete 0). tap repo 의 옛 0.5.x-product 도 그대로 유지.
  - **G-7** **CHANGELOG migration note**: `## [0.6.0]` entry 의 첫 line 에 "Version naming hard cut: from 0.6.0 onwards no `-product` suffix. Historical 0.5.x-product tags preserved." 명시.
  - **G-8** Release discovery 갱신 (S2-N4) — `latest_release_version` parser (semver-aware) + Scoop `checkver` URL pattern + Homebrew `livecheck` block + package target paths (`tap/Formula/sfs.rb` 신규, `bucket/sfs.json` 신규) 모두 0.6.0 정합.
  - **G-9** Atomic version metadata commit (F7) — VERSION + CHANGELOG + bin/sfs (`version` cmd) + brew formula + scoop manifest = 5 file 단일 commit (atomic), pre-push hook 가 5 file 동시성 검증.

- [ ] **R-H — Migration Source Matrix + Data Safety (S2-N5, 신규)**: `.sfs-local/sprints` (현 0.5.x project local) → `.solon/sprints` (신규 0.6 schema) 마이그레이션 안전성.
  - **H-1** Source matrix 명시: `.sfs-local/sprints/*` (legacy) + `sprints/*` (legacy 2) → `.solon/sprints/<S-id>/<feat>/` (신규). 매핑 표 = `sfs migrate-artifacts --print-matrix` 출력 — **machine-readable JSON contract** (S2R2-N4 Round 2 fix): 각 row 6 fields = `{source, dest, action, sha256_before, sha256_after, reason}`. action ∈ {`migrate`, `archive`, `delete`, `skip`}, reason = 단일 문장 description.
  - **H-2** Backup manifest: 마이그레이션 직전 `.sfs-local/archives/pre-migrate-<ISO>/` 디렉토리 생성 + 변경 대상 file snapshot. **manifest schema 9 required fields** (S2-N5 + Round 4 Q5 fix — AC10.2 정합, normalize): `manifest.json` = `{snapshot_id, created_at, source_repo_root, source_sha, files[], total_count, total_bytes, skipped[], extension_filter_applied}`. `files[]` = `[{path, sha256, size_bytes, captured_at}]`. `skipped[]` = `[{path, reason, ext}]` (extension filter 거부된 file 기록). `extension_filter_applied` = bool (default true / `--snapshot-include-all` 시 false). **Snapshot extension filter** (S3R3-N3 Round 3 fix — disk exhaust 방지): default 캡처 대상 = SFS artifact extensions only — `*.md` / `*.yml` / `*.yaml` / `*.jsonl` / `*.json` / `*.txt` / `*.sh` / `*.ps1` / `*.cmd` / `*.py` / `*.toml`. unknown ext (`*.bin` / `*.exe` / `*.zip` / `*.tar.gz` / `node_modules/**` / `__pycache__/**` / `.venv/**` 등) skip with warning + manifest `skipped[]` array 기록. `--snapshot-include-all` flag 만 unrestricted (advanced opt-in).
  - **H-3** Rollback: `sfs migrate-artifacts --rollback-from-snapshot <ISO>` flag — pre-migrate snapshot 으로 working tree 복원 + git revert 동등.
  - **H-4** **No-data-loss anti-AC** (S2-N5 critical, **anti-AC10** Round 2 rename + Round 4 Q6 fix — `skipped[]` allowed non-loss exclusion 명시): 마이그레이션 전후 file 수 + sha256 sum 모두 보존 (또는 `archive` action 명시 mark **OR** manifest `skipped[]` array 안 명시 file). archive 도 skipped 도 아닌 file 의 mismatch = 분실 = fail. negative test = manifest `files[]` post-migrate sha256 ≠ original + 해당 file 이 `skipped[]` 안 없음 → fail.
  - **H-5** Interrupted-midway recovery (S3-N3 cross-link): SIGINT/SIGTERM 시 atomic rollback 자동 실행 (R-C.C-6 + H-3 정합).

- [ ] **R-I — Release Plumbing Safety (Round 3 promotion of S3R2-N1/N2/N3, AC11/12/13)**: release pipeline 의 sequence + cross-platform integrity + workflow permissions hardening 가 binary AC.
  - **I-1** Release sequence (AC11): `git tag` push → brew audit + scoop schema check → tap/bucket update + push 순서 enforce.
  - **I-2** Cross-platform hash parity (AC12): Windows `sfs.ps1` SHA256 ≡ POSIX `sha256sum` + LF normalization for `.yml`/`.yaml`/`.md`/`.jsonl`/`.json`/`.toml`/`.txt` (`.gitattributes` `text eol=lf`).
  - **I-3** Workflow permissions hardening (AC13): `.github/workflows/*.yml` 모두 explicit `permissions: contents: read` minimum block.

## §2. Acceptance Criteria (AC, 측정 가능, binary)

각 R 에 대응하는 binary AC + verify-by 명시. anti-AC 도 포함.

- [ ] **AC1 (R-A repo layout)**: `solon-mvp-dist/scripts/` 에 6 신규 script + Windows wrapper 존재 + 각 executable + shebang `#!/usr/bin/env bash` + `set -euo pipefail`. `bin/sfs` dispatch case 에 5 신규 subcommand 등록.
  - **AC1.1** 6 script (storage-init / storage-precommit / archive-branch-sync / sprint-yml-validator / migrate-artifacts / migrate-artifacts-rollback) `test -x` + `head -1 \| grep -q bash` 모두 PASS.
  - **AC1.2** `bin/sfs` dispatch — `grep -E "(migrate-artifacts|storage|archive|sprint)" solon-mvp-dist/bin/sfs` 매칭 line ≥ 5 (F1 ERE group-wrap fix, escape 제거).
  - **AC1.3** Windows wrapper (S2-N6) — `solon-mvp-dist/bin/sfs.ps1` + `solon-mvp-dist/bin/sfs.cmd` 존재 + 5 subcommand 동등 dispatch. PowerShell sandbox 실행 시 본 5 subcommand 모두 invoke 가능 (smoke `tests/test-sfs-windows-scoop-smoke.ps1`).
  - **AC1.4** Atomic version metadata (F7 + G-9) — VERSION + CHANGELOG + bin/sfs `version` cmd + brew formula + scoop manifest = 5 file 단일 commit (atomic). `git log --name-only -1` 결과 5 file 모두 포함.
  - **anti-AC1**: 기존 0.5.96-product script 기능 회귀 없음 — `bash bin/sfs version` exit 0 + 기존 sfs subcommand 모두 동작.

- [ ] **AC2 (R-B R2 storage)**: 9 sub-checks 모두 PASS (idempotence + race + atomic 추가).
  - **AC2.1** Layer 1 path schema 생성 script 가 `docs/<domain>/<sub>/<feat>/` 디렉토리 생성 (예제 input → 결과 확인).
  - **AC2.2** Layer 2 path schema 생성 script 가 `.solon/sprints/<S-id>/<feat>/` 생성.
  - **AC2.3** co-location validator 가 Layer 1+Layer 2 misalignment 감지 (negative test = 잘못 둔 file → exit non-zero).
  - **AC2.4** N:M 매핑 validator 가 한 feature 가 여러 sprint 에 등장 OK + conflict 감지 (예: 같은 feature, 같은 file, 다른 sprint 이 동시 modify → conflict).
  - **AC2.5** sprint.yml validator 가 schema field 누락 감지 (negative test).
  - **AC2.6** **CI workflow mandatory pre-merge check** (F5 codex+gemini): `.github/workflows/sfs-pr-check.yml` 가 위 4 validator (AC2.1~AC2.5) 호출 + 실패 시 PR status fail. **Bad fixture test** (S2R2-N5 Round 2 fix — locally binary): `tests/test-bad-fixture.sh` (신규 script) 가 `tests/fixtures/bad-sprint-yml/` 의 misformed yaml 들 (각 fixture 별 expected fail reason 명시) 을 validator 에 통과 시키고 **모두 exit non-zero** 검증. workflow `.github/workflows/sfs-pr-check.yml` 는 동일 script (`bash tests/test-bad-fixture.sh`) 를 호출 — local CLI 와 CI 가 같은 binary signal 보장. local `.git/hooks/pre-merge-commit` = optional (등록 없어도 AC2.6 PASS).
  - **AC2.7** archive-branch-sync script 가 `git branch archive` 생성 + closed sprint dir 이동 + **race 보호** (F7) — 동시 실행 2-process simulate 시 second process 가 lock 감지 후 exit 0 (no-op) 또는 graceful wait. `flock(1)` 또는 advisory file lock 검증.
  - **AC2.8** `sfs migrate-artifacts --backfill-legacy` 가 옛 sprints (`sprints/0-5-x-*` 등) 전부 0.6 schema 로 변환 + 변환 결과 git diff 검증 가능 + **idempotent** (F7) — 재실행 시 no-op (exit 0, git diff = 0). `--force` flag 만 overwrite.
  - **AC2.9** **Atomic Layer 1 file movements** (S3-N3): `sfs migrate-artifacts` interrupt (SIGINT/SIGTERM) 시 working tree 자동 복구 — pre-migrate snapshot manifest 부터 restore. negative test = mid-way kill 후 git status clean.
  - **anti-AC2**: storage-script 도메인 hardcoding 금지 — `grep -E "(admin-page|saas|customer-portal)" solon-mvp-dist/scripts/sfs-storage-*.sh` = 0.

- [ ] **AC3 (R-C R3 migrate-artifacts)**: 6 sub-checks 모두 PASS.
  - **AC3.1** `sfs migrate-artifacts` (no flag) interactive wizard 가 file 별 prompt (keep/skip/edit) 띄움 — smoke harness 의 자동 입력 (`yes "k" \|`) 으로 verify.
  - **AC3.2** `sfs migrate-artifacts --apply` 가 Pass 1 propose list 출력 + user confirm 대기 + Pass 2 file 별 confirm 대기 — **deterministic input** (F8): `printf "y\nk\nk\nn\n" | sfs migrate-artifacts --apply` 실행 시 prompt 순서 (Pass 1 confirm `y` → Pass 2 file 1 keep `k` → file 2 keep `k` → file 3 reject `n`) + 결과 working tree state 가 expected fixture 와 sha256 match.
  - **AC3.3** `sfs migrate-artifacts --auto` 가 confirm 없이 fully unattended 진행 (CI 안에서 exit 0 verify).
  - **AC3.4** Pass 1 algorithm: `report.md` 존재 → archive auto / 부재 → **deterministic CLI prompt with structured questions** (S2-N7 Round 2 fix — bash CLI no-AI-runtime contract — `sfs migrate-artifacts` 가 fixed prompt list 띄움, **6 enumerated questions binary verify-able**):
    - **Q-A** "What feature does this sprint primarily implement? (free text, 1 line, ≤100 chars)"
    - **Q-B** "Is there a `decisions/` or `events.jsonl` file evidencing locked decisions? [y/N]"
    - **Q-C** "Should this sprint be archived (closed, no further work) or kept (active)? [a/k]"
    - **Q-D** "Default action on undecided files: keep / skip / delete? [k/s/d]"
    - **Q-E** "Migrate `.sfs-local/archives/` legacy artifacts? [y/N]"
    - **Q-F** "Confirm migration plan above? [y/N]"
    - verify by smoke harness `tests/test-sfs-pass1-prompts.sh`: `sfs migrate-artifacts` (no-`report.md` fixture) stdout 에 6 question prefix (Q-A ~ Q-F) literal grep ≥ 6.
    - external agent handoff (e.g. `claude` invoke) = R4 0.6.1 deferred (out-of-scope, AC3.4 verify 0).
  - **AC3.5** File-level reject (`n` 입력) 시 한 file 만 skip, 나머지 진행 verify — **deterministic input** (F8): `printf "y\nk\nn\nk\n" | sfs migrate-artifacts --apply` 실행 시 file 2 만 skip + file 1/3 처리 (working tree assert).
  - **AC3.6** `sfs migrate-artifacts --rollback <sha>` 가 git revert 실 실행 + working tree 복구 verify + **Layer 1 movement atomic** (S3-N3, R-C.C-6): partial commit 시나리오에서도 working tree git status clean.

- [ ] **AC4 (R-D test)**: 6 sub-checks 모두 PASS (Windows + log masking 추가).
  - **AC4.1** Unit tests `tests/test-sfs-storage-*.sh` + `tests/test-sfs-migrate-artifacts-*.sh` 존재 + `bash tests/run-all.sh` exit 0.
  - **AC4.2** Smoke harness `tests/test-sfs-migrate-artifacts-smoke.sh` 존재 + 가짜 consumer project sandbox 생성 + sfs 실 실행 + 결과 verify + cleanup.
  - **AC4.3** CI workflow `.github/workflows/sfs-0-6-storage.yml` 존재 + macOS+Ubuntu+Windows 3 runner matrix + push/PR trigger + green PASS.
  - **AC4.4** Cross-instance verify `tests/test-sfs-cross-instance-verify.sh` 존재 + GitHub Secrets (`CODEX_API_KEY` / `GEMINI_API_KEY`) ref + CI 안에서 invoke + verdict (PASS/FAIL) 기록 + **fallback policy 4-bullet** (F4 codex):
    - **AC4.4.1** PR (fork 포함) without secrets → CI step **SKIP with warning** (CI status = success, warning annotation).
    - **AC4.4.2** `main` / nightly / release with secrets → both Codex + Gemini PASS required (block on either FAIL).
    - **AC4.4.3** External API outage (codex/gemini API down) → retry exponential backoff (max 3) then release-block (PR = skip+warning).
    - **AC4.4.4** **Sentinel secret value verify — isolated step** (S3-N2 + S3R3-N1 Round 3 fix): masking test 는 **별 isolated CI step** `tests/test-sfs-log-masking.sh` (real-auth cross-instance verify 와 분리). 본 step 절차: (i) real `CODEX_API_KEY` + `GEMINI_API_KEY` env unset, (ii) sentinel 값 inject — pattern `SFS_TEST_SENTINEL_dummy_codex_<HEX16>` + `SFS_TEST_SENTINEL_dummy_gemini_<HEX16>` (regex contract: `^SFS_TEST_SENTINEL_dummy_(codex|gemini)_[0-9a-f]{16}$` capture, runtime generate via `openssl rand -hex 8`), (iii) `sfs migrate-artifacts --auto` 또는 fake invoker 가 sentinel-bearing log 생성, (iv) `log.md` + CI artifact logs 에서 capture 한 sentinel literal value grep result = 0 (env var name `CODEX_API_KEY` / `GEMINI_API_KEY` 자체 노출은 OK). real-auth verify (AC4.4.2) 는 별 step 에서 진짜 secret 사용 — masking step 과 logical 충돌 없음.
  - **AC4.5** Windows Scoop smoke (S2-N6) — `tests/test-sfs-windows-scoop-smoke.ps1` 존재 + Windows runner 에서 PASS + 5 신규 subcommand 동등 동작 verify.
  - **AC4.6** **Log masking verify — isolated step assert** (S3-N2 + S3R3-N1 Round 3): AC4.4.4 isolated masking step 의 CI artifact (run log + test output) 안에 capture 한 sentinel value literal (`[0-9a-f]{16}` 16-hex random suffix 포함 full sentinel string) grep result = 0. env var name 자체 (`CODEX_API_KEY` / `GEMINI_API_KEY`) 노출은 OK. mask replacement = `***`, `[masked]`, 또는 `[redacted]` 권장. AC4.6 = AC4.4.4 와 동일 step 의 후속 assert (별 step 분리 = AC4.4 real-auth verify 와 paradox 회피).

- [ ] **AC5 (R-E consumer compat)**: 4 sub-checks 모두 PASS.
  - **AC5.1** `sfs upgrade` 가 0.5.x 감지 시 deprecation warning 출력 — wording grep verify.
  - **AC5.2** `sfs upgrade --opt-in 0.6-storage` 가 backfill 실 실행 (smoke verify).
  - **AC5.3** `sfs upgrade` 가 0.6.x 감지 시 silent (warning grep result 0).
  - **AC5.4** Hard cut date (2026-11-03) post-grace **default forced migrate** (F3 wording lock, in-scope, **S2R2-N3 Round 2 + S3R3-N2 Round 3 idempotence fix + Q2 = α**) — `sfs upgrade` 가 0.5.x consumer 발견 시 자동 backfill 실행 + **R-H.H-2 backup manifest 생성 default**. **git commit 은 NOT auto** — 다음 둘 중 하나 user-explicit 시점에만 commit:
    - (i) `sfs upgrade --commit` opt-in flag → migrate + auto-commit (`migrate(forced): hard cut 2026-11-03`).
    - (ii) `sfs upgrade` (no flag) → migrate + working tree dirty + prompt: `Commit migration now? [y/N]` (default = N, user 가 manual `git add` + commit 권장).
    - **dirty working tree detect** (consumer 작업 중 보호): `sfs upgrade` 시작 시 `git status --porcelain` 결과 non-empty + `--commit` flag 없음 → exit non-zero with error message ("Working tree dirty. Stash or commit before forced migrate.") — 단순화 (Round 3 fix Q9: `--commit-existing-dirty` flag 제거, 단일 `--commit` 통합).
    - **AC5.4.1 commit idempotence guard** (S3R3-N2 Round 3 fix): 재실행 안전성 — `sfs upgrade --commit` 두 번째 실행 시 working tree clean (no-op migration) → exit 0 + `git log -1` 변동 0 (empty commit 생성 X). negative test: `sfs upgrade --commit && sfs upgrade --commit` 두 번 연속 → second run exit 0 + `git rev-parse HEAD` 두 run 동일.
    - config override (`SFS_HARD_CUT_BEHAVIOR=hard_fail`) **도입 여부 = out-of-scope** (§3 정합), default forced migrate behavior 만 verify.

- [ ] **AC6 (R-F sprint.yml lifecycle)**: 6 sub-checks 모두 PASS (validate+close mode 추가).
  - **AC6.1** sprint.yml schema validator 가 8 required field (sprint_id / status / features / dependencies / completion_criteria / milestones / created_at / closed_at) 검증.
  - **AC6.2** Lifecycle status transition 정합 (draft → in-progress → ready-for-* → closed, invalid transition 감지).
  - **AC6.3** `sfs-sprint-yml-validator.sh --mode close <sprint-id>` (F6 codex preferred — validator script 안에 close mode dispatch, 신규 7번째 script 회피, AC1.1 6-count preserve) 가 user prompt (`Archive or delete? [a/d]`) 출력.
  - **AC6.4** `a` 입력 시 `.sfs-local/archives/sprint-yml/<sprint-id>.yml.gz` 파일 존재 + 원본 sprint.yml 부재.
  - **AC6.5** `d` 입력 시 sprint.yml 부재 + archive 부재 (완전 삭제).
  - **AC6.6** validate mode + close mode dispatch routing (F6) — `sfs-sprint-yml-validator.sh --mode validate <path>` exit 0/1 (schema check) vs `--mode close <sprint-id>` interactive prompt + archive/delete. 둘 다 같은 script 의 case branch.

- [ ] **AC7 (R-G version naming + release plumbing)**: 10 sub-checks 모두 PASS.
  - **AC7.1** `solon-mvp-dist/VERSION` = `0.6.0` (정확히, no suffix).
  - **AC7.2** `bash solon-mvp-dist/bin/sfs version` 출력 = **`sfs 0.6.0`** (S2-N3 α — preserve current 0.5.96-product 까지 사용 패턴, 0.5.x consumer 호환). plan-original wording `Solon SFS v0.6.0` rejected (CEO ruling).
  - **AC7.3** CHANGELOG 첫 entry header = `## [0.6.0]` (정확).
  - **AC7.4** Homebrew formula `solon-mvp-dist/packaging/brew/sfs.rb` (또는 신규 path) 의 url field 가 `v0.6.0` tag 참조 + sha256 갱신 + **`brew audit --new-formula sfs` exit 0** (S3-N1 artifact integrity audit).
  - **AC7.5** Scoop manifest `solon-mvp-dist/packaging/scoop/sfs.json` (또는 신규 path) 의 version field = `0.6.0` + hash 갱신 + **schema check `tests/scoop-manifest-validate.sh` exit 0** (S3-N1 — `scoop checkver` 또는 jsonschema 동등).
  - **AC7.6** 0.5.x git tags 존재 보존 — `git tag | grep -c "0.5.\*-product"` ≥ 80 (현재 89 tag 추정).
  - **AC7.7** CHANGELOG `## [0.6.0]` entry 첫 line 에 migration note ("Version naming hard cut: ..." wording) 존재.
  - **AC7.8** **Release discovery 갱신** (S2-N4): (i) `latest_release_version` parser (semver-aware, `v?(\d+)\.(\d+)\.(\d+)$` regex) verify, (ii) Scoop `checkver` URL pattern 0.6.0 정합, (iii) Homebrew `livecheck` block 0.6.0 정합, (iv) package target paths (`tap/Formula/sfs.rb` + `bucket/sfs.json`) 신규 path 정합.
  - **AC7.9** **Atomic 5-file commit** (F7 + G-9): VERSION + CHANGELOG + bin/sfs + brew + scoop = 1 commit, `git log --pretty=format:"" --name-only -1 | sort -u` 5 file 모두 포함.
  - **anti-AC7**: VERSION suffix `-product` 잔존 금지 — `grep -c "0.6.0-product" solon-mvp-dist/VERSION solon-mvp-dist/bin/sfs solon-mvp-dist/CHANGELOG.md` (단 첫 entry header 후 historical 0.5.x-product entry 는 제외) = 0 (0.6.0 entry block 안에서).

- [ ] **AC8 — 6 철학 self-application (review_high judgment)**: 본 sprint 산출물 자체가 6 철학을 위반하지 않음. **deterministic grep 안 됨 — review_high reasoning_tier 가 review.md 에서 binary 판정** (spec sprint AC7 패턴 정합).
  - **AC8.1 Grill Me**: brainstorm 9/9 lock + plan §6 5 implement-stage gotcha self-flag (S2-N2 reword — R7/R8 stale wording 제거) + Round 1 cross-instance review (Stage 1 PASS-with-flag → Stage 2 PARTIAL → Stage 3 PARTIAL → 16-item fix patch → Round 2 evidence).
  - **AC8.2 Ubiquitous Language**: 핵심 용어 (Layer 1/2 / archive branch / sprint.yml / migrate-artifacts / opt-in 0.6-storage / cross-instance verify / release discovery / no-data-loss) 가 spec + brainstorm + plan + 코드 일관 사용.
  - **AC8.3 TDD-no-overtake**: AC1~AC13 binary verify 가 implement 전 명시 (Round 4 Q1 fix — AC10 R-H + AC11/12/13 R-I promotion 정합).
  - **AC8.4 Deep Module**: 6 신규 script 가 각각 deep module 단위 (shallow split 회피, F6 sprint-yml-validator validate+close 두 mode 통합 = 7번째 script 신설 회피 = 의도된 deep module 응집도).
  - **AC8.5 Gray Box**: interface 결정 = brainstorm 9/9 + plan AC sub-check + Round 1 fix CEO ruling (S2-N3 α). 구현 detail (file content / error message wording / 내부 헬퍼) = AI fill.
  - **AC8.6 Daily System Design**: 본 sprint = 0.6.0 daily 1 step.

- [ ] **AC9 (Spec sprint SFS-PHILOSOPHY immutability carry-forward)**: 본 sprint 가 spec sprint G6 PASS LOCKED 의 SFS-PHILOSOPHY.md (이미 ship) 를 변경하지 않음. **F2 reword**: working tree diff 만이 아니라 **spec baseline commit (`03f36de` spec sprint push 후) 대비 diff = 0** verify. — `git diff 03f36de -- 2026-04-19-sfs-v0.4/SFS-PHILOSOPHY.md` 결과 0.

- [ ] **AC10 (R-H Migration Source Matrix + Data Safety)** (Round 3 promotion — R-H top-level AC). 5 sub-checks 모두 PASS:
  - **AC10.1** `sfs migrate-artifacts --print-matrix` 출력 = JSON Lines (each row 6 fields). schema verify by `bash tests/test-print-matrix-schema.sh` — `jq` 로 각 row `{source, dest, action, sha256_before, sha256_after, reason}` 필드 존재 + action ∈ `[migrate, archive, delete, skip]` enum. **null semantics** (S2R3-N5 Round 3 fix): action=`delete`/`skip` → `sha256_after = null` (JSON null, not empty string), action=`archive` → `sha256_after` = archive snapshot 의 sha256, action=`migrate` → `sha256_after` = post-migrate dest sha256.
  - **AC10.2** Backup manifest schema (R-H.H-2): `manifest.json` 9 required field (snapshot_id / created_at / source_repo_root / source_sha / files / total_count / total_bytes / skipped / extension_filter_applied). validator `tests/test-backup-manifest-schema.sh`.
  - **AC10.3** Snapshot extension filter (R-H.H-2 + S3R3-N3): default 캡처 = 11 SFS artifact ext (`.md/.yml/.yaml/.jsonl/.json/.txt/.sh/.ps1/.cmd/.py/.toml`). negative test = `*.bin` / `*.exe` / `node_modules/` 가 fixture 에 있을 때 skip + manifest `skipped[]` 기록 + warning stderr.
  - **AC10.4** Rollback `sfs migrate-artifacts --rollback-from-snapshot <ISO>` (R-H.H-3): pre-migrate snapshot 으로 working tree restore + smoke verify (`tests/test-rollback-from-snapshot.sh`).
  - **AC10.5** Interrupted-midway recovery (R-H.H-5 + S3-N3): SIGINT/SIGTERM mid-migrate 시 atomic rollback 자동 실행 + git status clean. negative test = `kill -INT` mid-process → `git status --porcelain` empty.
  - **anti-AC10** (R-H no-data-loss, **renumbered Round 3 + Round 4 Q6 fix `skipped[]` clarity**) — 마이그레이션 전후 file count + sha256 sum mismatch 0 except (i) `archive` action 명시 mark file, (ii) manifest `skipped[]` array 명시 file (extension filter 거부). archive 도 skipped 도 아닌 file 의 mismatch = 분실 = fail. negative test = manifest `files[]` post-migrate sha256 ≠ original + 해당 file 이 `archive` action 도 `skipped[]` 안 도 없음 → fail.

- [ ] **AC11 (Release Sequence)** — S3R2-N1 Round 3 promotion (Stage 3 advisory → formal AC, consensus): release tool 가 (1) `git tag v0.6.0` + push to remote → (2) brew audit (AC7.4) + scoop schema check (AC7.5) → (3) tap repo formula/manifest update + push 순서 enforce. 순서 위반 (e.g. brew audit 가 git tag push 전 invoke) 시 release script exit non-zero. verify by `tests/test-release-sequence.sh`.

- [ ] **AC12 (Cross-Platform Hash Parity)** — S3R2-N2 Round 3 promotion (Stage 3 advisory → formal AC, consensus): Windows `sfs.ps1` 가 생성한 SHA256 hash = POSIX `sha256sum` 결과 동일. **LF normalization mandatory** for all `.yml` / `.yaml` / `.md` / `.jsonl` / `.json` / `.toml` / `.txt` files (cross-platform sprint.yml + spec md hash 정합). `.gitattributes` `text eol=lf` for above ext. negative test = CRLF 가 fixture 에 있을 때 hash 불일치 → migrate 실 fail (smoke `tests/test-hash-parity.sh`).

- [ ] **AC13 (Workflow Permissions Hardening)** — S3R2-N3 Round 3 promotion (Stage 3 advisory → formal AC, consensus): `.github/workflows/sfs-pr-check.yml` + `.github/workflows/sfs-0-6-storage.yml` 모두 explicit `permissions:` block 명시 (default `contents: read` minimum, action 별 추가 권한 explicit). `pull_request` event from forks 도 정상 동작 verify (no `secrets` access required for masking-only step). verify by static yaml lint `tests/test-workflow-permissions.sh` (yq query: `.permissions.contents == "read"` exists in each workflow).

### anti-AC summary

- **anti-AC1** (R-A 회귀 없음): 기존 0.5.96-product subcommand 모두 동작.
- **anti-AC2** (R-B 도메인 hardcoding 금지): script body 에 `admin-page|saas|customer-portal` grep = 0 (spec sprint anti-AC2 carry-forward).
- **anti-AC7** (R-G suffix 잔존 금지): 0.6.0 entry block 안에서 `-product` literal 0.
- **anti-AC10** (R-H / AC10 no-data-loss, S2-N5 critical, Round 4 Q6 `skipped[]` clarity): 마이그레이션 전후 file count + sha256 sum mismatch 0 except (i) `archive` action 명시 mark, (ii) manifest `skipped[]` 명시 file. 둘 다 아닌 file mismatch = 분실 = fail.

## §3. 범위 (Scope)

- **In scope (본 sprint = G1 plan + G2~G7 implement/review/retro)**:
  - 6 신규 bash script (R-A) + Windows wrapper (`bin/sfs.ps1` + `sfs.cmd`, S2-N6).
  - `bin/sfs` dispatch 확장 (5 신규 subcommand).
  - sprint.yml schema + validator + lifecycle (R-F, validate+close 두 mode, F6).
  - VERSION bump 0.5.96-product → 0.6.0 (R-G G2-α).
  - Homebrew formula + Scoop manifest 갱신 + brew audit + scoop schema check (R-G G-4/G-5, S3-N1).
  - Release discovery 갱신 (latest_release_version parser, Scoop checkver, Homebrew livecheck, package target paths) (G-8, S2-N4).
  - Atomic version metadata 5-file commit (G-9, F7).
  - CI workflow + tests (R-D) + Windows Scoop smoke (D-2, S2-N6) + log masking (D-4 fallback, S3-N2).
  - Consumer compat: deprecation warning + opt-in flag + **default forced migrate post-grace** (R-E E5, F3).
  - **Migration source matrix + backup manifest + rollback + no-data-loss anti-AC** (R-H, S2-N5).
  - Atomic Layer 1 movements + interrupted-midway recovery (R-C.C-6 + R-H.H-5, S3-N3).
  - **Release plumbing safety** (R-I, AC11/12/13 — Round 3 promotion): release sequence + cross-platform hash parity + workflow permissions hardening.
  - **Sentinel masking isolated test step** (S3R3-N1 Round 3 fix): real-auth verify (AC4.4.2) 와 분리 (`tests/test-sfs-log-masking.sh`).
  - **Snapshot extension filter** (R-H.H-2 + S3R3-N3): SFS artifact ext only default + `--snapshot-include-all` opt-in.
  - **Commit idempotence** (AC5.4.1 + S3R3-N2): `sfs upgrade --commit` 재실행 시 clean working tree → exit 0 no-empty-commit.

- **Out of scope (다음 sprint / 별도 release)**:
  - R4 `improve-codebase-architecture` 구현 (0.6.1 deferred per soft split lock).
  - **Config override `SFS_HARD_CUT_BEHAVIOR=hard_fail`** 도입 (F3 wording lock — 본 sprint = forced migrate default 만, override toggle 도입 여부 = user 결정 0.6.x patch 시점).
  - **External agent handoff in Pass 1 algorithm** (S2-N7) — `sfs migrate-artifacts` 가 claude/codex/gemini 직접 invoke = R4 0.6.1 deferred. 본 sprint = bash CLI deterministic prompt only.
  - 0.5.x dashboard (§4.A 서스테이닝).
  - MD split queue (§4.B).
  - release-tooling polish (§4.C — verify-product-release.sh interactive prompts / cut-release default retarget / scripts/update-product-taps.sh).

- **Dependencies**:
  - 0.6.0-spec sprint G6 PASS LOCKED (✅ 2026-05-03 21:55 KST, push 03f36de) — spec baseline commit reference (AC9 F2 verify base).
  - 4 신규 spec markdown shipped (✅).
  - VERSION 현재 `0.5.96-product` → 0.6.0 bump (R-G 산출물).
  - GitHub Actions CI (현 0.5.96-product `sfs-cli-discovery.yml` 패턴 정합 — 신규 workflow file 추가).
  - GitHub Secrets `CODEX_API_KEY` + `GEMINI_API_KEY` 신규 필요 (D-4 cross-instance verify).
  - tap repos: `homebrew-solon-product` + `scoop-solon-product` (현 0.5.96-product flow 정합).

## §4. G1 Gate 자기 점검

- [x] R/AC 가 측정 가능: **AC1~AC7 + AC9 + AC10~AC13** = deterministic (script 존재 / grep / exit code / smoke verify / brew audit / scoop schema check / git diff baseline commit / JSON Lines schema / `flock(1)` / sentinel regex / git tag sequence / SHA256 parity / yq permissions check), AC8 = review_high sub-check judgment (AC8.1~AC8.6 6 sub-check). (Round 4 Q1 fix: AC scope AC1~AC9 → AC1~AC13)
- [x] 범위가 sprint 1 개 안에서 닫힘: 6 신규 script + Windows wrapper + bin/sfs dispatch + tests + CI workflow + VERSION bump + Homebrew/Scoop manifest + R-H migration safety. R4 (0.6.1) + 후순위 (§4.A/B/C) + config override + external agent handoff out-of-scope.
- [x] 의존성 / 결정 대기 항목이 명시됨: spec sprint G6 PASS ✅, 4 spec markdown ✅, VERSION bump (R-G 산출), CI/Secrets/tap (모두 기존 0.5.96 flow 정합), S2-N3 CEO ruling lock (α preserve `sfs 0.6.0`), 모두 충족.
- [x] **brainstorm 9/9 lock 직접 expansion** (S2-N2 reword — R7/R8 stale 제거): A1 → R-A / B2+(b) → R-B(B-1~B-8) / C4-γ → R-C(C-1~C-6) / D4 → R-D(D-1~D-4 + 4-bullet fallback) / E5 → R-E(E-1~E-4 forced migrate default) / F4+(c) → R-F(F-1~F-5 + validator+close) / G2-α → R-G(G-1~G-9, S2-N3 α preserve) + R-H 신규 (S2-N5 migration safety).
- [x] **Round 1 fix patch 적용 완료** (review-g1.md §7.4.3 16 items): F1~F8 + S2-N1~N7 + S3-N1~N3 모두 plan/brainstorm/review-g1 wording 또는 AC sub-check 으로 통합. CEO ruling = S2-N3 α (sfs 0.6.0 preserve).

> 본 체크리스트 통과 = `/sfs review --gate G1` Round 5 quick verify 진입 조건. parallel cross-instance (codex + gemini) Round 5 → 둘 다 PASS 시 verdict_final lock + plan.md status: ready-for-review-round-5 → ready-for-implement.

## §5. Sprint Contract (Generator ↔ Evaluator)

역할 흐름: **CEO (= user) → CTO Generator → CPO Evaluator → CTO 구현 → CPO 리뷰 → CTO rework/final confirm → retro**.

- **CEO (user) 요구사항/plan 결정**:
  - 문제 정의: 0.6.0-spec 의 R2+R3 가 spec 만 ship, 실 코드 부재. consumer 가 sfs 0.5.96-product 까지만 동작, 0.6.0 새 schema 미접근.
  - 최종 목표: R2+R3 실 코드 ship + 0.5.x consumer 호환 (E5 6 mo grace + default forced migrate post-grace) + 0.6.0 release cut (Homebrew/Scoop dual-channel, suffix drop) + Windows parity + R-H migration safety.
  - 이번 sprint 에서 버릴 것: R4 (0.6.1), 후순위 §4.A/B/C, config override toggle 도입, external agent handoff in Pass 1 algorithm (R4 deferred).

- **CTO Generator 가 만들 것**:
  - **persona**: `.sfs-local/personas/cto-generator.md`
  - **reasoning_tier**: `strategic_high` (architecture / public contract — model-profiles.yaml 정합)
  - **runtime**: default = current runtime (claude cowork). 코드는 bash + POSIX 호환 (macOS zsh / Linux bash / WSL 공통, install.sh 패턴) + Windows wrapper PowerShell + cmd shim.
  - **본 cowork 세션 fact-only**: claude (단 코드 본문에 leak 금지)
  - **policy fallback**: current_model → solon_recommended (model-profiles.yaml 정합)
  - **implementation worker persona**: `.sfs-local/personas/implementation-worker.md` (본 sprint = code-grade — strategic_high 가 high-level architecture, worker 가 detail script 가능)
  - **harness 메타 철학 정합**: spec sprint R7 정합 carry-forward. 본 generator 자체가 "모델이 혼자 할 수 없는 것을 가정" 의 instance — 6 신규 script + R-H migration safety 의 edge case 검증은 cross-instance evaluator (codex/gemini) 가 자체 cycle 로 발본 가능 (Round 1 cycle precedent).
  - **산출물 (예상 file count ~22, Round 1 fix 후)**:
    1. 신규 6 script (R-A): `solon-mvp-dist/scripts/sfs-storage-init.sh` 등.
    2. 수정: `solon-mvp-dist/bin/sfs` (dispatch 확장).
    3. 신규 Windows wrapper (S2-N6): `solon-mvp-dist/bin/sfs.ps1` + `solon-mvp-dist/bin/sfs.cmd`.
    4. 수정: `solon-mvp-dist/VERSION` (G-1).
    5. 수정: `solon-mvp-dist/CHANGELOG.md` (G-3 + G-7 entry 추가).
    6. 수정: `solon-mvp-dist/packaging/brew/sfs.rb` (G-4, 신규 path 가능).
    7. 수정: `solon-mvp-dist/packaging/scoop/sfs.json` (G-5, 신규 path 가능).
    8. 수정: `solon-mvp-dist/scripts/cut-release.sh` 또는 release helper (G-8 release discovery 갱신).
    9. 신규 tests: `solon-mvp-dist/tests/test-sfs-{storage,migrate,migrate-rollback}-*.sh` + smoke + Windows ps1 (D-1~D-2 + AC4.5).
    10. 신규 cross-instance verify: `solon-mvp-dist/tests/test-sfs-cross-instance-verify.sh` (D-4 + 4-bullet fallback + log masking).
    11. 신규 CI: `solon-mvp-dist/.github/workflows/sfs-0-6-storage.yml` + `solon-mvp-dist/.github/workflows/sfs-pr-check.yml` (D-3 + AC2.6 mandatory).
    12. 수정: `solon-mvp-dist/scripts/sfs-doctor.sh` (R-G version detection 갱신).
    13. (선택) 신규 doc: `solon-mvp-dist/docs/0.6.0-migration-guide.md` (consumer 용).
    14. R-H 산출물: `sfs migrate-artifacts --print-matrix` + `--rollback-from-snapshot` (migrate-artifacts.sh 안 추가).
  - **변경 파일/모듈 예상 stats**: 신규 ~12 + 수정 ~10, 총 ~22 file, +1100/-80 line range (Round 1 fix 후 ↑).
  - **구현하지 않을 것**: R4 improve-codebase, 후순위 §4.A/B/C, config override toggle, external agent handoff in Pass 1.

- **CPO Evaluator 가 검증할 것**:
  - **persona**: `.sfs-local/personas/cpo-evaluator.md`
  - **reasoning_tier**: `review_high`
  - **runtime**: **cross-runtime parallel 권장** — P-17 pattern 정합 (Round 1 evidence). Stage 1 (claude same-instance, AI-PROPOSED, self-val flag) + Stage 2 (codex parallel) + Stage 3 (gemini parallel third-eye veto) 동시 invoke + post-hoc consensus/divergence analysis.
  - **AC 검증 방법**:
    - **AC1~AC7 + AC9 + AC10~AC13**: deterministic — script 존재 / grep / shebang / exit code / smoke output verify / brew audit / scoop schema / git diff baseline commit / JSON Lines schema (AC10.1) / flock(1) lock (AC2.7) / sentinel regex `[0-9a-f]{16}` (AC4.4.4) / git tag sequence enforce (AC11) / SHA256 parity + LF normalization (AC12) / yq workflow permissions (AC13). CI 안에서 자동 검증.
    - **AC8 (6 철학 self-application, 6 sub-check)**: review_high reasoning_tier 가 review.md 에서 1-pass binary 판정.
  - **회귀/위험 체크**:
    - 기존 0.5.96-product subcommand 회귀 없음 (anti-AC1).
    - VERSION suffix 잔존 (anti-AC7).
    - sprint.yml schema breaking change 0.5.x consumer 영향 — E5 grace 정합.
    - cross-instance verify CI cost (codex+gemini API calls) — 4-bullet fallback 정합.
    - Migration data loss (anti-AC10 R-H) — 가장 critical.
  - **통과/부분통과/실패 기준**:
    - **pass**: **AC1~AC13 모두 PASS** (AC8 = AC8.1~AC8.6 6 sub-check 전부 PASS, AC10 = AC10.1~AC10.5 5 sub-check + anti-AC10 PASS, AC11/12/13 = R-I 정합 PASS) — Round 4 Q1 fix (Sprint Contract scope AC1~AC9 → AC1~AC13 expansion).
    - **partial**: AC8 sub-check 단일 fail (1 cycle CTO 부분 rework) 또는 minor wording fix.
    - **fail**: **AC1~AC7 + AC9 + AC10~AC13** 중 하나라도 fail OR AC8 multiple sub-checks fail OR plan §3 scope 위반 OR anti-AC10 (data loss) 1건이라도 fail.

- **CTO ↔ CPO 재작업 계약**:
  - CPO `pass`: 최종 통과 + retro 진입 (G7) → release cut (Homebrew + Scoop dual-channel, §1.24).
  - CPO `partial`: 지정된 R 만 CTO 재작성 후 재리뷰 (1 cycle, 2회 partial 시 plan escalate per §1.7 + model-profiles.yaml).
  - CPO `fail`: brainstorm escalate (R 정의 자체 재검토) 또는 plan §3 scope 재조정.

- **사용자 최종 결정 (모두 LOCKED via brainstorm 9/9 + Round 1 fix CEO ruling)**:
  - ✅ 9 axes 모두 (A1 / B2+(b) / C4-γ / D4 / E5 / F4+(c) / G2-α).
  - ✅ S2-N3 sfs version output string = α preserve `sfs 0.6.0` (Round 1 fix CEO ruling 2026-05-03T23:45+09:00).
  - plan 단계 신규 user 결정 0 (lock 외) — Round 1 fix patch = brainstorm lock + Round 1 cross-instance evaluator 정합 정형화.

---

## §6. Plan Self-Note (CTO 메모)

본 plan = brainstorm.md §6 Plan Seed 7 sub-section + 9/9 lock + Round 1 fix patch 16 items 의 직접 expansion. 새로운 user 결정 = S2-N3 α only (round 1 fix CEO ruling).

**Implement-stage gotcha** (CTO self-flag, F7 일부는 binary AC 으로 승격 — Round 1 fix):
1. **Pre-merge hook 위치 (F5 Round 1 lock)**: CI workflow `.github/workflows/sfs-pr-check.yml` mandatory (AC2.6), local hook `.git/hooks/pre-merge-commit` optional only.
2. **Backfill idempotence (F7 → AC2.8 binary lock)**: 재실행 = no-op default, `--force` flag 만 overwrite.
3. **Archive branch race (F7 → AC2.7 binary lock)**: flock(1) 또는 advisory file lock + 동시 실행 simulate negative test.
4. **Cross-instance verify CI cost (F4 → AC4.4 fallback 4-bullet binary lock)**: PR no-secrets skip, main+nightly+release with-secrets both PASS, outage retry+release-block.
5. **VERSION bump cascade (F7 + G-9 → AC1.4 + AC7.9 binary lock)**: 5 file (VERSION + CHANGELOG + bin/sfs + brew + scoop) atomic single commit.
6. **Migration data safety (R-H 신규)**: source matrix + backup manifest + rollback-from-snapshot + no-data-loss anti-AC10 + interrupted-midway atomic recovery (S3-N3).

**Cross-Reference**:
- spec source: `2026-04-19-sfs-v0.4/SFS-PHILOSOPHY.md` (R1) / `storage-architecture-spec.md` (R2) / `migrate-artifacts-spec.md` (R3) / `improve-codebase-architecture-spec.md` (R4 deferred).
- brainstorm: `sprints/0-6-0-product-implement/brainstorm.md` (G0, 9/9 locked, S2-N1 fix applied 0.6.0-product → 0.6.0).
- Round 1 review: `sprints/0-6-0-product-implement/review-g1.md` (Stage 1 + Stage 2 codex PARTIAL + Stage 3 gemini PARTIAL Veto + §7.4.3 Consolidated Fix Patch).
- 정합 패턴: P-16 multi-CLI plugin umbrella (0.5.96 hotfix) / P-17 cross-instance verify cycle (0.6.0-spec G1+G6 + 0.6.0-implement G1 Round 1).

### G1 Self-Check Recap (§4 final state, post Round 1 fix)

- [x] R/AC measurable: AC1~AC7+AC9+AC10~AC13 deterministic (10+9+6+6+4+6+10+1+5+1+1+1 = ~60 sub-check), AC8 review_high (6 sub-check). 총 ~66 sub-check + 4 anti-AC. (Round 4 Q1 fix: AC scope expansion)
- [x] Sprint 1 안에서 닫힘: ~22 file (Round 1 fix 후 +6 from 16), R4 + config override + external agent handoff + 후순위 out-of-scope.
- [x] Dependency / 결정 대기: 모두 충족 (spec G6 ✅, 4 spec markdown ✅, brainstorm 9/9 ✅, CI/tap 기존 flow 정합, S2-N3 CEO ruling α lock ✅).
- [x] Round 1 fix patch 통합 (review-g1.md §7.4.3 16 items): F1~F8 + S2-N1~N7 + S3-N1~N3 모두 plan/brainstorm/AC sub-check 으로 흡수.

**status: ready-for-implement** ✅✅✅. **G1 PASS LOCKED 2026-05-04T01:30+09:00 KST** (Round 5 codex + gemini 둘 다 PASS, 5 round cycle 완료, 44 CTO fix items 통합, 10+ CEO ruling locks). **다음 1 step** = next session user 명시 G2 implement 명령 진입 (자동 승급 금지, CLAUDE.md §1.3 + §1.20).
