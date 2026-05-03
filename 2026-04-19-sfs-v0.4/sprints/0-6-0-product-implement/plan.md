---
phase: plan
gate_id: G1
sprint_id: "0-6-0-product-implement"
goal: "0.6.0 implement — R2 storage architecture 실 코드 + R3 sfs migrate-artifacts CLI + Homebrew/Scoop dual-channel release (suffix drop)"
visibility: raw-internal
created_at: 2026-05-03T22:40:00+09:00
last_touched_at: 2026-05-03T22:40:00+09:00
status: ready-for-review   # G1 plan 작성 완료. /sfs review --gate G1 진입 = 다음 세션 user 명시 명령 후 (no-auto-advance, CLAUDE.md §1.3).
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
session: "claude-cowork:affectionate-trusting-thompson"
---

# Plan — 0.6.0 implement sprint (G1)

> Sprint **G1 — Plan Gate** 산출물. brainstorm.md (G0) 의 9/9 lock 결정을 측정 가능한 sprint contract 로 변환.
> 입력 = brainstorm.md §6 Plan Seed 7 sub-section + spec sprint 의 4 신규 markdown spec.

---

## §1. 요구사항 (Requirements)

본 sprint = **code sprint** (spec sprint 가 아님). 산출물 = 6+ 신규 bash script + bin/sfs dispatch 확장 + tests + CI workflow + VERSION bump + Homebrew/Scoop manifest 갱신.

- [ ] **R-A — Repo Layout**: `solon-mvp-dist/scripts/` 평면에 신규 6 script + `bin/sfs` dispatch 확장. 각 script POSIX 호환 bash, executable, 기존 scripts/ 컨벤션 정합.
  - `sfs-storage-init.sh` / `sfs-storage-precommit.sh` / `sfs-archive-branch-sync.sh` / `sfs-sprint-yml-validator.sh` / `sfs-migrate-artifacts.sh` / `sfs-migrate-artifacts-rollback.sh`.

- [ ] **R-B — R2 Storage Architecture (B2 + (b))**: 7 elements 모두 spec 정합 구현 + 옛 sprint 전체 backfill.
  - **B-1** Layer 1 영구 path schema (`docs/<domain>/<sub>/<feat>/`) 생성/검증.
  - **B-2** Layer 2 작업 path schema (`.solon/sprints/<S-id>/<feat>/`) 생성/검증.
  - **B-3** co-location pattern (Layer 1+Layer 2 같은 feature 가 한 sprint 안에 묶임).
  - **B-4** N:M sprint × feature 매핑 (한 feature = 여러 sprint, 한 sprint = 여러 feature).
  - **B-5** `sprint.yml` shared file scope (lock semantics 0, advisory 0 — pure metadata + lifecycle, R-F 정합).
  - **B-6** pre-merge hook (git pre-merge 또는 GitHub Actions PR check) 가 co-location + sprint.yml schema + N:M conflict 검증.
  - **B-7** archive branch 자동화 (closed sprint 들 archive branch 로 이동, main 은 진행 중 + 신규).
  - **B-8** 옛 sprint backfill (`sfs migrate-artifacts --backfill-legacy` flag 가 옛 sprints/ dir 전부 0.6 schema 변환, 변환 후 closed → archive branch).

- [ ] **R-C — R3 Migrate-Artifacts CLI (C4-γ)**: 3 surface 동시 + Pass 1/2 algorithm + reject + rollback.
  - **C-1** `sfs migrate-artifacts` (no flag) → interactive wizard (file 별 keep/skip/edit prompt).
  - **C-2** `sfs migrate-artifacts --apply` → batch with 양 단계 confirm (Pass 1 propose list user confirm → Pass 2 file 별 confirm).
  - **C-3** `sfs migrate-artifacts --auto` → fully unattended (Pass 1+2 자동 default 선택, CI 용).
  - **C-4** Pass 1 algorithm: `report.md` 존재 → archive auto, 부재 → AI 가 user 암묵지 (decisions / events.jsonl / raw 메모) 꺼내 질문 (interactive/--apply 모드만, --auto 는 default skip).
  - **C-5** Reject granularity: file 단위 reject (한 file reject 시 나머지 진행), sprint 전체 영향 발견 시 sprint 단위 escalate.
  - **C-6** Rollback: `sfs migrate-artifacts --rollback <commit-sha>` flag 가 git revert 기반 (pre-push local revert).

- [ ] **R-D — Test (D4)**: unit + smoke + CI matrix + cross-instance verify.
  - **D-1** unit tests in `tests/test-sfs-storage-*.sh` + `tests/test-sfs-migrate-artifacts-*.sh` (bats 또는 자체 harness).
  - **D-2** smoke harness `tests/test-sfs-migrate-artifacts-smoke.sh` (가짜 consumer project 만들고 실 실행).
  - **D-3** CI workflow `.github/workflows/sfs-0-6-storage.yml` (macOS + Ubuntu + Windows scoop 3 runner matrix).
  - **D-4** cross-instance verify `tests/test-sfs-cross-instance-verify.sh` (P-17 pattern, codex/gemini self-host smoke runner, CI 안에서 invoke). credential 관리 = GitHub Secrets (`CODEX_API_KEY` / `GEMINI_API_KEY`).

- [ ] **R-E — Consumer Compat (E5)**: 0.5.x consumer deprecation warning + 6 mo grace + opt-in migrate.
  - **E-1** `sfs upgrade` 가 0.5.x consumer 감지 시 deprecation warning 출력 (정해진 wording, 6 mo grace + hard cut 2026-11-03 명시).
  - **E-2** `sfs upgrade --opt-in 0.6-storage` flag 또는 prompt confirm (`Migrate to 0.6.0 storage now? [y/N]`) 시 backfill 실행.
  - **E-3** `sfs upgrade` 가 0.6.x consumer 감지 시 silent (no warning).
  - **E-4** Hard cut date (2026-11-03) post-grace 시 옵션: (i) hard fail (`sfs upgrade` exit 1) 또는 (ii) forced migrate. **G1 plan 단계에서 (ii) 권장** (user 가 명시 변경 안 하면).

- [ ] **R-F — sprint.yml Lifecycle (F4 + (c))**: full structured yaml + lifecycle hook.
  - **F-1** Schema (yaml): `sprint_id` / `status` (draft/in-progress/ready-for-*/closed) / `features` (list) / `dependencies` (list) / `completion_criteria` (list) / `milestones` (list) / `created_at` / `closed_at`.
  - **F-2** Lifecycle hook: 진행 중 update 가능 (validator 가 schema 만 enforce, content mutate OK).
  - **F-3** Close 시 user prompt: `sfs sprint close <sprint-id>` (또는 `/sfs retro --close`) 가 prompt 출력 (`Archive this sprint.yml or delete? [a/d]`).
  - **F-4** (a) archive → `.sfs-local/archives/sprint-yml/<sprint-id>.yml.gz`.
  - **F-5** (d) delete → 완전 삭제 (project tree 깔끔).

- [ ] **R-G — Version Naming (G2-α)**: 0.6.0 부터 suffix drop, hard cut.
  - **G-1** `solon-mvp-dist/VERSION` = `0.6.0` (single line, no suffix).
  - **G-2** `bin/sfs version` 출력 = `Solon SFS v0.6.0`.
  - **G-3** CHANGELOG entry header = `## [0.6.0]` (no `-product` suffix).
  - **G-4** Homebrew formula url tag = `v0.6.0`, sha256 갱신.
  - **G-5** Scoop manifest version = `0.6.0`, hash 갱신.
  - **G-6** 0.5.x 태그는 historical 보존 (delete 0). tap repo 의 옛 0.5.x-product 도 그대로 유지.
  - **G-7** **CHANGELOG migration note**: `## [0.6.0]` entry 의 첫 line 에 "Version naming hard cut: from 0.6.0 onwards no `-product` suffix. Historical 0.5.x-product tags preserved." 명시.

## §2. Acceptance Criteria (AC, 측정 가능, binary)

각 R 에 대응하는 binary AC + verify-by 명시. anti-AC 도 포함.

- [ ] **AC1 (R-A repo layout)**: `solon-mvp-dist/scripts/` 에 6 신규 script 존재 + 각 executable + shebang `#!/usr/bin/env bash` + `set -euo pipefail`. `bin/sfs` dispatch case 에 5 신규 subcommand (`migrate-artifacts` / `storage` / `archive` / `sprint` 가 main, 그 외 sub-action) 등록. — verify by `for f in 6files; do test -x $f && head -1 $f | grep -q bash; done` + `grep -E "migrate-artifacts\|storage\|archive\|sprint" bin/sfs` ≥ 5.
  - **anti-AC1**: 기존 0.5.96-product script 기능 회귀 없음 — `bash bin/sfs version` exit 0 + 기존 sfs subcommand 모두 동작.

- [ ] **AC2 (R-B R2 storage)**: 8 sub-checks 모두 PASS.
  - **AC2.1** Layer 1 path schema 생성 script 가 `docs/<domain>/<sub>/<feat>/` 디렉토리 생성 (예제 input → 결과 확인).
  - **AC2.2** Layer 2 path schema 생성 script 가 `.solon/sprints/<S-id>/<feat>/` 생성.
  - **AC2.3** co-location validator 가 Layer 1+Layer 2 misalignment 감지 (negative test = 잘못 둔 file → exit non-zero).
  - **AC2.4** N:M 매핑 validator 가 한 feature 가 여러 sprint 에 등장 OK + conflict 감지 (예: 같은 feature, 같은 file, 다른 sprint 이 동시 modify → conflict).
  - **AC2.5** sprint.yml validator 가 schema field 누락 감지 (negative test).
  - **AC2.6** pre-merge hook script 가 위 4 validator 호출 + 실패 시 exit non-zero. `.git/hooks/pre-merge-commit` 또는 `.github/workflows/pr-check.yml` 등록.
  - **AC2.7** archive-branch-sync script 가 `git branch archive` 생성 + closed sprint dir 이동.
  - **AC2.8** `sfs migrate-artifacts --backfill-legacy` 가 옛 sprints (e.g. `sprints/0-5-x-*`) 전부 0.6 schema 로 변환 + 변환 결과 git diff 검증 가능.

- [ ] **AC3 (R-C R3 migrate-artifacts)**: 6 sub-checks 모두 PASS.
  - **AC3.1** `sfs migrate-artifacts` (no flag) interactive wizard 가 file 별 prompt (keep/skip/edit) 띄움 — smoke harness 의 자동 입력 (`yes "k" |`) 으로 verify.
  - **AC3.2** `sfs migrate-artifacts --apply` 가 Pass 1 propose list 출력 + user confirm 대기 + Pass 2 file 별 confirm 대기.
  - **AC3.3** `sfs migrate-artifacts --auto` 가 confirm 없이 fully unattended 진행 (CI 안에서 exit 0 verify).
  - **AC3.4** Pass 1 algorithm: report.md 존재 → archive auto / 부재 → interactive 모드는 user 질문, --auto 는 skip.
  - **AC3.5** File-level reject (`n` 입력) 시 한 file 만 skip, 나머지 진행 verify.
  - **AC3.6** `sfs migrate-artifacts --rollback <sha>` 가 git revert 실 실행 + working tree 복구 verify.

- [ ] **AC4 (R-D test)**: 4 sub-checks 모두 PASS.
  - **AC4.1** Unit tests `tests/test-sfs-storage-*.sh` + `tests/test-sfs-migrate-artifacts-*.sh` 존재 + `bash tests/run-all.sh` exit 0.
  - **AC4.2** Smoke harness `tests/test-sfs-migrate-artifacts-smoke.sh` 존재 + 가짜 consumer project sandbox 생성 + sfs 실 실행 + 결과 verify + cleanup.
  - **AC4.3** CI workflow `.github/workflows/sfs-0-6-storage.yml` 존재 + macOS+Ubuntu+Windows 3 runner matrix + push/PR trigger + green PASS.
  - **AC4.4** Cross-instance verify `tests/test-sfs-cross-instance-verify.sh` 존재 + GitHub Secrets (`CODEX_API_KEY` / `GEMINI_API_KEY`) ref + CI 안에서 invoke + verdict (PASS/FAIL) 기록.

- [ ] **AC5 (R-E consumer compat)**: 4 sub-checks 모두 PASS.
  - **AC5.1** `sfs upgrade` 가 0.5.x 감지 시 deprecation warning 출력 — wording grep verify.
  - **AC5.2** `sfs upgrade --opt-in 0.6-storage` 가 backfill 실 실행 (smoke verify).
  - **AC5.3** `sfs upgrade` 가 0.6.x 감지 시 silent (warning grep result 0).
  - **AC5.4** Hard cut date (2026-11-03) 처리 — post-grace forced migrate (default) 또는 hard fail (config override). default behavior verify.

- [ ] **AC6 (R-F sprint.yml lifecycle)**: 5 sub-checks 모두 PASS.
  - **AC6.1** sprint.yml schema validator 가 8 required field (sprint_id / status / features / dependencies / completion_criteria / milestones / created_at / closed_at) 검증.
  - **AC6.2** Lifecycle status transition 정합 (draft → in-progress → ready-for-* → closed, invalid transition 감지).
  - **AC6.3** `sfs sprint close <sprint-id>` 가 user prompt (`Archive or delete? [a/d]`) 출력.
  - **AC6.4** `a` 입력 시 `.sfs-local/archives/sprint-yml/<sprint-id>.yml.gz` 파일 존재 + 원본 sprint.yml 부재.
  - **AC6.5** `d` 입력 시 sprint.yml 부재 + archive 부재 (완전 삭제).

- [ ] **AC7 (R-G version naming)**: 7 sub-checks 모두 PASS.
  - **AC7.1** `solon-mvp-dist/VERSION` = `0.6.0` (정확히, no suffix).
  - **AC7.2** `bash solon-mvp-dist/bin/sfs version` 출력 = `Solon SFS v0.6.0`.
  - **AC7.3** CHANGELOG 첫 entry header = `## [0.6.0]` (정확).
  - **AC7.4** Homebrew formula `solon-mvp-dist/packaging/brew/solon-product.rb` (또는 새 `solon.rb`) 의 url field 가 `v0.6.0` tag 참조 + sha256 갱신.
  - **AC7.5** Scoop manifest `solon-mvp-dist/packaging/scoop/solon-product.json` (또는 새 `solon.json`) 의 version field = `0.6.0` + hash 갱신.
  - **AC7.6** 0.5.x git tags 존재 보존 — `git tag | grep -c "0.5.\*-product"` ≥ 80 (현재 89 tag 추정).
  - **AC7.7** CHANGELOG `## [0.6.0]` entry 첫 line 에 migration note ("Version naming hard cut: ..." wording) 존재.
  - **anti-AC7**: VERSION suffix `-product` 잔존 금지 — `grep -c "0.6.0-product" solon-mvp-dist/VERSION solon-mvp-dist/bin/sfs solon-mvp-dist/CHANGELOG.md (단 첫 entry header 후 historical 0.5.x-product entry 는 제외)` = 0 (0.6.0 entry block 안에서).

- [ ] **AC8 — 6 철학 self-application (review_high judgment)**: 본 sprint 산출물 자체가 6 철학을 위반하지 않음. **deterministic grep 안 됨 — review_high reasoning_tier 가 review.md 에서 binary 판정** (spec sprint AC7 패턴 정합).
  - **AC8.1 Grill Me**: brainstorm 9/9 lock + plan G1 추가 grill (R7+R8 발견) evidence.
  - **AC8.2 Ubiquitous Language**: 핵심 용어 (Layer 1/2 / archive branch / sprint.yml / migrate-artifacts / opt-in 0.6-storage / cross-instance verify) 가 spec + brainstorm + plan + 코드 일관 사용.
  - **AC8.3 TDD-no-overtake**: AC1~AC7 binary verify 가 implement 전 명시.
  - **AC8.4 Deep Module**: 6 신규 script 가 각각 deep module 단위 (shallow split 회피, R-B 의 sub-script 6 개 = 의도된 deep module 분리).
  - **AC8.5 Gray Box**: interface 결정 = brainstorm 9/9 + plan AC sub-check. 구현 detail (file content / error message wording / 내부 헬퍼) = AI fill.
  - **AC8.6 Daily System Design**: 본 sprint = 0.6.0 daily 1 step.

- [ ] **AC9 (Spec sprint AC8 carry-forward — harness reference)**: 본 sprint 가 spec sprint 의 R7 harness reference 정합 유지. SFS-PHILOSOPHY.md (이미 ship) 의 §6 + §9 References 변경 0 (코드 sprint 라 doc 변경 없음). — verify by `git diff 2026-04-19-sfs-v0.4/SFS-PHILOSOPHY.md` 결과 0.

### anti-AC summary

- **anti-AC1** (R-A 회귀 없음): 기존 0.5.96-product subcommand 모두 동작.
- **anti-AC2** (R-B 도메인 hardcoding 금지): script body 에 `admin-page|saas|customer-portal` grep = 0 (spec sprint anti-AC2 carry-forward).
- **anti-AC7** (R-G suffix 잔존 금지): 0.6.0 entry block 안에서 `-product` literal 0.

## §3. 범위 (Scope)

- **In scope (본 sprint = G1 plan + G2~G7 implement/review/retro)**:
  - 6+ 신규 bash script (R-A/B/C/D/E).
  - `bin/sfs` dispatch 확장 (5 신규 subcommand).
  - sprint.yml schema + validator + lifecycle (R-F).
  - VERSION bump 0.5.96-product → 0.6.0 (R-G).
  - Homebrew formula + Scoop manifest 갱신 (R-G).
  - CI workflow + tests (R-D).
  - Consumer compat: deprecation warning + opt-in flag (R-E).

- **Out of scope (다음 sprint / 별도 release)**:
  - R4 `improve-codebase-architecture` 구현 (0.6.1 deferred per soft split lock).
  - 0.5.x dashboard (§4.A 서스테이닝).
  - MD split queue (§4.B).
  - release-tooling polish (§4.C — verify-product-release.sh interactive prompts / cut-release default retarget / scripts/update-product-taps.sh).
  - Hard cut date (2026-11-03) 도래 시 forced migrate vs hard fail 결정 (G1 plan 권장 = forced migrate, user 가 0.6.x patch 시점에 변경 가능).

- **Dependencies**:
  - 0.6.0-spec sprint G6 PASS LOCKED (✅ 2026-05-03 21:55 KST, push 03f36de).
  - 4 신규 spec markdown shipped (✅).
  - VERSION 현재 `0.5.96-product` → 0.6.0 bump (R-G 산출물).
  - GitHub Actions CI (현 0.5.96-product `sfs-cli-discovery.yml` 패턴 정합 — 신규 workflow file 추가).
  - GitHub Secrets `CODEX_API_KEY` + `GEMINI_API_KEY` 신규 필요 (D-4 cross-instance verify).
  - tap repos: `homebrew-solon-product` + `scoop-solon-product` (현 0.5.96-product flow 정합).

## §4. G1 Gate 자기 점검

- [x] R/AC 가 측정 가능: AC1~AC7 = deterministic (script 존재 / grep / exit code / smoke verify), AC8 = review_high sub-check judgment (AC8.1~AC8.6 6 sub-check), AC9 = deterministic (git diff = 0).
- [x] 범위가 sprint 1 개 안에서 닫힘: 6 신규 script + bin/sfs dispatch + tests + CI workflow + VERSION bump + Homebrew/Scoop manifest. R4 (0.6.1) + 후순위 (§4.A/B/C) out-of-scope.
- [x] 의존성 / 결정 대기 항목이 명시됨: spec sprint G6 PASS ✅, 4 spec markdown ✅, VERSION bump (R-G 산출), CI/Secrets/tap (모두 기존 0.5.96 flow 정합), 모두 충족.
- [x] **brainstorm 9/9 lock 직접 expansion**: A1 → R-A / B2+(b) → R-B(B-1~B-8) / C4-γ → R-C(C-1~C-6) / D4 → R-D(D-1~D-4) / E5 → R-E(E-1~E-4) / F4+(c) → R-F(F-1~F-5) / G2-α → R-G(G-1~G-7).

> 본 체크리스트 통과 = `/sfs review --gate G1` 진입 조건. 다음 세션 user 명령 후 review (cross-instance, P-17 패턴 권장 — codex round + gemini round) → verdict (pass / partial / fail) 기록 후 G2 implement 진입.

## §5. Sprint Contract (Generator ↔ Evaluator)

역할 흐름: **CEO (= user) → CTO Generator → CPO Evaluator → CTO 구현 → CPO 리뷰 → CTO rework/final confirm → retro**.

- **CEO (user) 요구사항/plan 결정**:
  - 문제 정의: 0.6.0-spec 의 R2+R3 가 spec 만 ship, 실 코드 부재. consumer 가 sfs 0.5.96-product 까지만 동작, 0.6.0 새 schema 미접근.
  - 최종 목표: R2+R3 실 코드 ship + 0.5.x consumer 호환 (E5 6 mo grace) + 0.6.0 release cut (Homebrew/Scoop dual-channel).
  - 이번 sprint 에서 버릴 것: R4 (0.6.1), 후순위 §4.A/B/C, hard cut 도래 후 처리 결정.

- **CTO Generator 가 만들 것**:
  - **persona**: `.sfs-local/personas/cto-generator.md`
  - **reasoning_tier**: `strategic_high` (architecture / public contract — model-profiles.yaml 정합)
  - **runtime**: default = current runtime (claude cowork). 코드는 bash + POSIX 호환 (macOS zsh / Linux bash / WSL 공통, install.sh 패턴).
  - **본 cowork 세션 fact-only**: claude (단 코드 본문에 leak 금지)
  - **policy fallback**: current_model → solon_recommended (model-profiles.yaml 정합)
  - **implementation worker persona**: `.sfs-local/personas/implementation-worker.md` (본 sprint = code-grade — strategic_high 가 high-level architecture, worker 가 detail script 가능)
  - **harness 메타 철학 정합**: spec sprint R7 정합 carry-forward. 본 generator 자체가 "모델이 혼자 할 수 없는 것을 가정" 의 instance — 6 신규 script 의 edge case 검증은 cross-instance evaluator (codex/gemini) 가 자체 cycle 로 발본 가능.
  - **산출물 (예상 file count ~20)**:
    1. 신규 6 script (R-A): `solon-mvp-dist/scripts/sfs-storage-init.sh` 등.
    2. 수정: `solon-mvp-dist/bin/sfs` (dispatch 확장).
    3. 수정: `solon-mvp-dist/VERSION` (G-1).
    4. 수정: `solon-mvp-dist/CHANGELOG.md` (G-3 + G-7 entry 추가).
    5. 수정: `solon-mvp-dist/packaging/brew/*.rb` (G-4).
    6. 수정: `solon-mvp-dist/packaging/scoop/*.json` (G-5).
    7. 신규 tests: `solon-mvp-dist/tests/test-sfs-*-{storage,migrate}-*.sh` + cross-instance + smoke (D-1~D-4).
    8. 신규 CI: `solon-mvp-dist/.github/workflows/sfs-0-6-storage.yml` (D-3).
    9. 수정: `solon-mvp-dist/scripts/sfs-doctor.sh` (R-G version detection 갱신).
    10. (선택) 신규 doc: `solon-mvp-dist/docs/0.6.0-migration-guide.md` (consumer 용).
  - **변경 파일/모듈 예상 stats**: 신규 ~10 + 수정 ~6, 총 ~16 file, +800/-50 line range.
  - **구현하지 않을 것**: R4 improve-codebase, 후순위 §4.A/B/C, hard cut 처리 분기 (default forced migrate 만).

- **CPO Evaluator 가 검증할 것**:
  - **persona**: `.sfs-local/personas/cpo-evaluator.md`
  - **reasoning_tier**: `review_high`
  - **runtime**: **cross-runtime 권장** — P-17 pattern 정합. Stage 1 (claude same-instance, AI-PROPOSED, self-val flag) → Stage 2 (codex cross-runtime cross-instance) → Stage 3 (gemini cross-runtime cross-instance).
  - **AC 검증 방법**:
    - **AC1~AC7 + AC9**: deterministic — script 존재 / grep / shebang / exit code / smoke output verify. CI 안에서 자동 검증.
    - **AC8 (6 철학 self-application, 6 sub-check)**: review_high reasoning_tier 가 review.md 에서 1-pass binary 판정.
  - **회귀/위험 체크**:
    - 기존 0.5.96-product subcommand 회귀 없음 (anti-AC1).
    - VERSION suffix 잔존 (anti-AC7).
    - sprint.yml schema breaking change 0.5.x consumer 영향 — E5 grace 정합.
    - cross-instance verify CI cost (codex+gemini API calls) — 최소 1 회/PR + nightly.
  - **통과/부분통과/실패 기준**:
    - **pass**: AC1~AC9 모두 PASS (AC8 = AC8.1~AC8.6 6 sub-check 전부 PASS).
    - **partial**: AC8 sub-check 단일 fail (1 cycle CTO 부분 rework) 또는 minor wording fix.
    - **fail**: AC1~AC7+AC9 중 하나라도 fail OR AC8 multiple sub-checks fail OR plan §3 scope 위반.

- **CTO ↔ CPO 재작업 계약**:
  - CPO `pass`: 최종 통과 + retro 진입 (G7) → release cut (Homebrew + Scoop dual-channel, §1.24).
  - CPO `partial`: 지정된 R 만 CTO 재작성 후 재리뷰 (1 cycle, 2회 partial 시 plan escalate per §1.7 + model-profiles.yaml).
  - CPO `fail`: brainstorm escalate (R 정의 자체 재검토) 또는 plan §3 scope 재조정.

- **사용자 최종 결정 (모두 LOCKED via brainstorm 9/9)**:
  - ✅ 9 axes 모두 (A1 / B2+(b) / C4-γ / D4 / E5 / F4+(c) / G2-α). plan 단계 신규 user 결정 0 — brainstorm lock 의 순수 expansion.

---

## §6. Plan Self-Note (CTO 메모)

본 plan 은 brainstorm.md §6 Plan Seed 7 sub-section + 9/9 lock 의 직접 expansion. 새로운 결정 추가 0.

**가능한 implement-stage gotcha** (CTO self-flag):
1. **Pre-merge hook 위치**: `.git/hooks/pre-merge-commit` (local) vs `.github/workflows/pr-check.yml` (CI). G2 implement 시 CI 측 우선 (consumer side 강제력 ↑), local hook 은 optional.
2. **Backfill idempotence**: `sfs migrate-artifacts --backfill-legacy` 가 재실행 시 overwrite vs skip — skip default + `--force` flag.
3. **Archive branch race**: 2+ session 이 동시 archive sync 실행 시 conflict — file lock (flock) 또는 단일 owner 검증.
4. **Cross-instance verify CI cost**: 매 PR 마다 codex+gemini invoke 시 API cost ↑. nightly schedule (`schedule: cron`) 옵션 권장.
5. **VERSION bump cascade**: VERSION + CHANGELOG + bin/sfs + brew + scoop = 5 file. 한 commit atomic 추천.

**Cross-Reference**:
- spec source: `2026-04-19-sfs-v0.4/SFS-PHILOSOPHY.md` (R1) / `storage-architecture-spec.md` (R2) / `migrate-artifacts-spec.md` (R3) / `improve-codebase-architecture-spec.md` (R4 deferred).
- brainstorm: `sprints/0-6-0-product-implement/brainstorm.md` (G0, 9/9 locked).
- 정합 패턴: P-16 multi-CLI plugin umbrella (0.5.96 hotfix) / P-17 cross-instance verify cycle (0.6.0-spec G1+G6).

### G1 Self-Check Recap (§4 final state)

- [x] R/AC measurable: AC1~AC7+AC9 deterministic, AC8 review_high (6 sub-check).
- [x] Sprint 1 안에서 닫힘: ~16 file, R4 + 후순위 out-of-scope.
- [x] Dependency / 결정 대기: 모두 충족 (spec G6 ✅, 4 spec markdown ✅, brainstorm 9/9 ✅, CI/tap 기존 flow 정합).

**status: ready-for-review** ✅. **다음 1 step (다음 세션)** = user 명시 `/sfs review --gate G1` 명령 (예: "review 가자" / "G1 review"). 자동 G1 review 승급 금지 (CLAUDE.md §1.3 + §1.20 + brainstorm precedent).
