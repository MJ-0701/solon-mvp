---
phase: brainstorm
gate_id: G0
sprint_id: "0-6-0-product-implement"
goal: "0.6.0 spec sprint 의 R2 storage architecture + R3 migrate-artifacts 실 코드 구현 + Homebrew/Scoop dual-channel release"
visibility: raw-internal
created_at: 2026-05-03T22:10:00+09:00
last_touched_at: 2026-05-03T22:25:00+09:00
status: ready-for-plan   # Round 1 + Round 2 lock 9/9 (A1 / B2+(b) / C4-γ / D4 / E5(6mo) / F4-with-lifecycle(c) / G2-α). G1 plan 진입 = user 명시 명령 후 (no-auto-advance, CLAUDE.md §1.3).
depth: hard
brainstorm_decisions:
  A1_repo_layout: "flat — scripts/sfs-*.sh 평면 (storage-init / pre-commit-hook / archive-branch-sync / sprint-yml-validator / migrate-artifacts / migrate-artifacts-rollback 등)"
  B2_backward_compat: "전체 backfill — 옛 sprint 모두 main 에서 0.6 schema 로 migrate (one-shot one-version main, B2 strict)"
  B2_archive_policy: "(b) 전부 main 0.6 schema migrate 후, closed 인 것은 다음 release 섹션부터 archive branch 로 별도 이동 (archive 자체는 main migrate 후 이루어짐)"
  C4_gamma_migrate_artifacts_ux: "interactive (wizard 디폴트) + --apply (양 단계 confirm) + --auto (apply + auto, fully unattended) — 3 surface"
  D4_test_strategy: "D3 (unit + smoke + CI matrix macOS+Ubuntu+Windows) + cross-instance verify (P-17 pattern, codex/gemini self-host smoke as canonical SFS practice)"
  E5_consumer_compat: "0.5.x consumer 가 sfs upgrade 시 deprecation warning baseline + 6 mo grace + user 명시 승인 (sfs upgrade --opt-in 0.6-storage 또는 prompt confirm) 시 migrate. grace 만료 시 hard cut."
  F4_with_lifecycle: "full structured yaml (sprint_id / features / dependencies / completion / milestones) + lifecycle hook — sprint 진행 중 update 가능 / sprint close 시 user 매번 prompt (archive 보존 vs delete 완전 삭제 case-by-case)"
  G2_alpha_version: "hard cut — 0.6.0 부터 suffix drop (no -product). 0.5.x 태그는 historical 보존, 신규 release 는 0.6.x 패턴만. CHANGELOG entry header 도 0.6.0 부터 새 패턴."
spec_source:
  - "2026-04-19-sfs-v0.4/sprints/0-6-0-product-spec/plan.md (G1 PASS LOCKED)"
  - "2026-04-19-sfs-v0.4/sprints/0-6-0-product-spec/review-g6.md (G6 PASS LOCKED)"
  - "2026-04-19-sfs-v0.4/SFS-PHILOSOPHY.md (R1, oss-public)"
  - "2026-04-19-sfs-v0.4/storage-architecture-spec.md (R2 spec, oss-public)"
  - "2026-04-19-sfs-v0.4/migrate-artifacts-spec.md (R3 spec, oss-public)"
  - "2026-04-19-sfs-v0.4/improve-codebase-architecture-spec.md (R4 spec, oss-public — 0.6.1 deferred)"
in_scope:
  - "R2 storage architecture 실 코드 (file path schema + co-location + N:M + sprint.yml + pre-merge hook + archive branch 자동화)"
  - "R3 sfs migrate-artifacts --apply CLI 구현 (2-pass propose-accept + algorithm + reject granularity + rollback)"
  - "VERSION bump 0.5.96-product → 0.6.0"
  - "Homebrew tap + Scoop bucket dual-channel release (CLAUDE.md §1.24)"
  - "기존 sprint workbench backward compat (정도 = G0 axis B 결정)"
out_of_scope:
  - "R4 improve-codebase-architecture-spec 구현 (0.6.1 deferred per soft split lock)"
  - "0.5.x dashboard (§4.A 서스테이닝)"
  - "MD split queue (§4.B)"
  - "release-tooling polish (§4.C)"
session: "claude-cowork:affectionate-trusting-thompson"
---

# Brainstorm — 0.6.0 implement sprint (G0, hard mode)

> Sprint **G0 — Brainstorm Gate (hard depth)**. 0.6.0 **spec sprint** 의 7 lock 결정 + 4 신규 spec markdown 을 입력으로 받아, 실 code/script 구현 axis 들을 grill round 로 lock.
> 6 철학 self-application: Grill Me (본 G0) / Ubiquitous Language (spec 의 Layer 1/2 / archive branch / sprint.yml / 2-pass propose-accept) / Deep Module (R2 + R3 = 각각 deep module 단위) / Gray Box (interface = user grill, 구현 = AI 통으로).

---

## §1. 입력 요약 (spec sprint 결과)

- **R1 SFS-PHILOSOPHY.md** — 6 철학 SSoT (oss-public, 98L). **본 sprint 에서 코드 변경 0** (doc only ship 완료).
- **R2 storage-architecture-spec.md** — 7 elements:
  1. Layer 1 영구 = `docs/<domain>/<sub>/<feat>/`
  2. Layer 2 작업 = `.solon/sprints/<S-id>/<feat>/`
  3. archive branch + 미래 S3
  4. co-location pattern
  5. N:M sprint × feature mapping
  6. sprint.yml shared file scope (lock layer **REJECTED**)
  7. pre-merge hook
- **R3 migrate-artifacts-spec.md** — 4 항목:
  1. Pass 1 default action algorithm (`report.md` 존재→archive auto, 부재→AI 가 user 암묵지 질문)
  2. Pass 2 file-level review
  3. Reject granularity (file / sprint-escalate)
  4. Rollback (git revert, pre-push local revert)
- **R5 / R7** = R1 inline 완료 (코드 변경 0).
- **R4** = 0.6.1 deferred (R6 soft split lock).

→ 본 sprint 실 코딩 scope = **R2 + R3 = 2 features**.

---

## §2. Plan Seed (locked from spec sprint)

- repo target: `/Users/mj/agent_architect/2026-04-19-sfs-v0.4/solon-mvp-dist/` (R-D1 dev-first per CLAUDE.md §1.13).
- VERSION: 현재 `0.5.96-product` → 0.6.0 release 시 bump (axis G 결정).
- runtime: spec runtime-agnostic 정합 — 코드는 bash + POSIX 호환 (macOS zsh / Linux bash / WSL 공통, install.sh 패턴).
- 영향 범위: `bin/sfs` dispatch 추가 + `scripts/sfs-storage-*.sh` + `scripts/sfs-migrate-artifacts.sh` + `templates/.solon/` schema + `packaging/{brew,scoop}/` formula/manifest 갱신.

---

## §3. Grill Round 1 — 7 Axes (A~G)

### Axis A — Repo Layout (신규 script 파일 어디에 두나)

- **A1**: `scripts/sfs-migrate-artifacts.sh` + `scripts/sfs-storage-init.sh` + `scripts/sfs-storage-precommit.sh` (현 패턴 따름, flat).
- **A2**: `scripts/0.6.0/*` version-namespaced subdir (release version 별 grouping).
- **A3**: `scripts/storage/*` + `scripts/migrate/*` feature-namespaced subdir (feature 단위 grouping).
- **A4**: 기존 dispatch 확장 + 단일 module file `scripts/sfs-0-6-0-product.sh` (하나로 묶음 — Deep Module 응집도 우선).

### Axis B — R2 backward compat scope (기존 sprint workbench 마이그)

- **B1**: 신규 sprint 부터만 0.6 schema 적용. 기존 `sprints/0-5-x-*/` 등은 그대로 leave.
- **B2**: 기존 sprint 모두 backfill (one-shot script 가 0.5 schema → 0.6 schema 변환).
- **B3**: 신규 sprint 기본 + opt-in backfill (`sfs migrate-artifacts --backfill-legacy` flag).
- **B4**: 기존 sprint 는 deprecation 하되 frozen — 신규는 0.6 schema, 옛 것은 read-only.

### Axis C — `sfs migrate-artifacts` UX

- **C1**: dry-run default + `--apply` opt-in. 본문 변경 시 user 가 매번 명시.
- **C2**: `--apply` flag 필수 + 양 단계 (Pass 1 propose / Pass 2 accept) user confirm.
- **C3**: `--interactive` default (TUI 비슷한 step-by-step) + `--auto` opt-in.
- **C4**: 두 surface 동시 — `sfs migrate-artifacts` (interactive default) + `sfs migrate-artifacts --apply` (non-interactive batch).

### Axis D — Test 전략

- **D1**: bash unit test (bats 또는 자체 harness) only — `tests/test-sfs-migrate-*.sh`.
- **D2**: smoke harness (consumer project 시뮬레이션, sandbox dir 만들고 sfs 실 실행) only.
- **D3**: 둘 다 + GitHub Actions CI matrix (macOS + Ubuntu + Windows scoop).
- **D4**: 둘 다 + CI + cross-instance verify (codex/gemini self-host smoke as canonical SFS practice).

### Axis E — Backward Compat (기존 0.5.x consumer)

- **E1**: 0.5.x consumer 가 `sfs upgrade` 시 자동 migrate (transparent).
- **E2**: 0.5.x consumer 그대로 두고 신규 `sfs init` 만 0.6 schema (전환은 user 명시 명령).
- **E3**: 0.5.x consumer 에 deprecation warning + 6 mo grace period 후 hard cut.
- **E4**: 0.5.x consumer 가 `sfs upgrade --opt-in 0.6-storage` 명시 시만 migrate (opt-in default).

### Axis F — `sprint.yml` scope (R2 lock layer REJECTED 정합)

- **F1**: file 만 두고 lock semantics 0 — pure metadata (sprint_id / status / created_at / closed_at).
- **F2**: optional `sprint_meta.lock_advisory: true` 같은 advisory only flag — pre-merge hook 가 warning 만, block 안 함.
- **F3**: lock 완전 X — workbench memo 만 (현 brainstorm.md 같은 free-form md 만, structured yaml 없음).
- **F4**: full structured yaml (sprint_id / features list / dependencies / completion_criteria / milestones) — workflow tooling 의 SSoT.

### Axis G — Release Version Naming

- **G1**: `0.6.0-product` (semver + product suffix, 현 0.5.96-product 패턴 그대로) — **REJECTED, G2-α lock 정합 (suffix drop hard cut)**.
- **G2**: `0.6.0` (suffix 제거, semver only).
- **G3**: `0.6.0` for R2+R3 → `0.6.1-product` for R4 follow-up (soft split 정합).
- **G4**: `0.6.0-r2-r3` 명시 → `0.6.1-product-r4` (release name 에 R 명시).

---

## §4. 6 철학 Self-Application Notes

- **Grill Me**: 본 G0 round 1 = hard depth. round 2/3 가 필요하면 user 결정 부족분 명시.
- **Ubiquitous Language**: spec 의 7 + 4 용어 + 본 brainstorm 의 axis labels (A1~G4) 일관 사용.
- **TDD-no-overtake**: 본 G0 결정 lock 후 G1 plan AC 가 TDD 헤드라이트로 implement 의 binary feedback 시그널 정의.
- **Deep Module**: R2 + R3 = 2 deep module 단위 — interface (sprint.yml schema / migrate-artifacts CLI) = user lock, 구현 (file IO / git plumbing) = AI 통으로.
- **Gray Box**: interface 결정 = 본 G0 7 axes user lock. 구현 detail (algorithm 의 edge case / error message wording / 내부 헬퍼 함수) = AI fill.
- **Daily System Design**: 본 sprint = 0.6.0 daily 1 step.

---

## §5. 결정 대기 (User Owner)

위 7 axes (A~G) round 1 user 결정 회수 + 추가 axis 발견 시 round 2 grill.

회수 방법: 다음 user 메시지에 axis 별 1 옵션 (또는 freeform 답) — 예: "A1 / B3 / C4 / D3 / E2 / F1 / G3" + 추가 의견.

User 결정 회수 후 본 brainstorm.md §6~§8 Append Log + Plan Seed + Locked Decisions 작성 → status=ready-for-plan close → user 명시 명령으로 G1 plan 진입.

---

## §6. Plan Seed (Locked input for G1 plan)

본 §6 = G1 plan 의 직접 input. R/AC 레벨 R 정의는 plan 에서 expansion.

### §6.1 Repo Layout (A1 lock)

`solon-mvp-dist/scripts/` 평면. 신규 6 파일 (또는 통합):
- `scripts/sfs-storage-init.sh` — Layer 1 + Layer 2 디렉토리 schema 생성 / 검증.
- `scripts/sfs-storage-precommit.sh` — pre-merge hook entry (co-location 검증 + sprint.yml schema 검증 + N:M conflict 감지).
- `scripts/sfs-archive-branch-sync.sh` — archive branch 생성/동기화 (closed sprint 들).
- `scripts/sfs-sprint-yml-validator.sh` — sprint.yml schema 검증 (frontmatter required field).
- `scripts/sfs-migrate-artifacts.sh` — `sfs migrate-artifacts` CLI dispatch (interactive / --apply / --auto).
- `scripts/sfs-migrate-artifacts-rollback.sh` — git revert 기반 rollback.

`bin/sfs` dispatch 확장: `migrate-artifacts` / `storage init` / `storage validate` / `archive sync` / `sprint validate` 신규 subcommand.

### §6.2 R2 Storage (B2 + archive 정합)

- 7 elements 모두 spec 정합 구현. lock layer **REJECTED** = sprint.yml 에 lock semantics 0 (advisory 도 X — F4 = pure metadata + lifecycle).
- B2 backfill: `sfs migrate-artifacts --backfill-legacy` flag 가 옛 sprints/ dir 들 전부 main 0.6 schema 로 변환. 변환 후 closed sprint 는 다음 step (별 명령 또는 자동 trigger) 으로 archive branch 로 이동.
- N:M sprint × feature mapping = 폴더 구조로 자연 표현 (한 feature 가 여러 sprint 에 등장 가능, 한 sprint 가 여러 feature 포함).
- Pre-merge hook = git pre-merge hook (또는 GitHub Actions PR check) 가 co-location + sprint.yml schema + N:M conflict 검증.

### §6.3 R3 Migrate-Artifacts (C4-γ 정합)

- `sfs migrate-artifacts` (no flag) → interactive wizard (file 별 keep/skip/edit prompt).
- `sfs migrate-artifacts --apply` → batch with 양 단계 confirm (Pass 1 propose list 보여주고 user confirm → Pass 2 file 별 confirm).
- `sfs migrate-artifacts --auto` → fully unattended (Pass 1+2 confirm 자동 default 선택, CI 용).
- Pass 1 algorithm: `report.md` 존재 → archive auto, 부재 → AI 가 user 암묵지 (decisions / events.jsonl / raw 메모) 꺼내 질문.
- Reject granularity: file 단위 (한 file reject 해도 나머지 진행), sprint 전체 영향 발견 시 sprint 단위 escalate.
- Rollback: git revert (pre-push local revert), `sfs migrate-artifacts --rollback <commit-sha>` flag.

### §6.4 Test (D4 정합)

- `tests/test-sfs-storage-*.sh` (unit) — 각 script 함수 단위.
- `tests/test-sfs-migrate-artifacts-smoke.sh` (smoke) — 가짜 consumer project 만들고 실 실행.
- `.github/workflows/sfs-0-6-storage.yml` (CI) — macOS + Ubuntu + Windows scoop matrix.
- `tests/test-sfs-cross-instance-verify.sh` — codex/gemini self-host smoke runner (P-17 pattern, CI 안에서 invoke). credential 관리 = GitHub Secrets.

### §6.5 Consumer Compat (E5 정합)

- `sfs upgrade` 가 0.5.x consumer 감지 시 deprecation warning 출력 (`[WARN] Detected legacy 0.5.x storage schema. 0.6.0 introduces new layer 1/2 schema. Grace period: 6 months from 2026-05-03. Migrate now: sfs upgrade --opt-in 0.6-storage`).
- `sfs upgrade --opt-in 0.6-storage` 또는 prompt confirm (`Migrate to 0.6.0 storage now? [y/N]`) 시 backfill 실행.
- 6 mo grace = 2026-05-03 + 6 mo = **2026-11-03** hard cut 일 (0.6.x patch / 0.7.0 시점 hard cut policy 발효).

### §6.6 sprint.yml Lifecycle (F4 + (c) 정합)

- Schema (yaml):
  ```yaml
  sprint_id: 0-6-0-product-implement
  status: draft | in-progress | ready-for-plan | ready-for-implement | ready-for-review | closed
  features: [R2-storage, R3-migrate-artifacts]
  dependencies: [0-6-0-product-spec]
  completion_criteria: ["G0~G7 all close", "AC pass", "release cut"]
  milestones: [...]
  created_at: ...
  closed_at: ...
  ```
- Lifecycle: 진행 중 update 가능. close 시 `sfs sprint close <sprint-id>` (또는 `/sfs retro --close`) 가 user prompt: "Archive this sprint.yml or delete? [a/d]".
- (a) archive → `.sfs-local/archives/sprint-yml/<sprint-id>.yml.gz`.
- (d) delete → 완전 삭제 (project tree 깔끔).

### §6.7 Version Naming (G2-α 정합)

> ⚠️ **Backstamp 2026-05-04T00:05+09:00 (Round 2 fix S2-N3 + S2R2-N2)**: 본 §6.7 의 "bin/sfs version 출력 = `Solon SFS v0.6.0`" wording 은 **superseded by CEO ruling S2-N3 = α** (preserve `sfs 0.6.0` 현 CLI pattern, 0.5.x consumer 호환 유지). 추가로 Q1 CEO ruling = α (sfs 브랜드 preserve) 정합으로 Homebrew formula = `Formula/sfs.rb`, Scoop manifest = `bucket/sfs.json`, package command = `sfs`. 본 §6.7 historical wording 은 Round 0 G0 brainstorm 기록 보존 목적으로 leave, 실 lock 은 `plan.md frontmatter ceo_ruling_lock` + `review-g1.md §7.6` 참조.

- `solon-mvp-dist/VERSION` = `0.6.0` (single line, no suffix).
- `bin/sfs version` 출력 = ~~`Solon SFS v0.6.0`~~ → **`sfs 0.6.0`** (CEO ruling S2-N3 α, Round 2).
- CHANGELOG entry header = `## [0.6.0]` (no `-product` suffix).
- Homebrew formula url tag = `v0.6.0`, formula path = `Formula/sfs.rb` (Q1 α — sfs 브랜드 preserve).
- Scoop manifest version = `0.6.0`, manifest path = `bucket/sfs.json` (Q1 α).
- 0.5.x 태그는 historical 보존, hard cut. tap repo 의 옛 0.5.x-product 도 그대로 유지.

---

## §7. Locked Decisions (round 1 + round 2)

| Axis | Lock | 의미 |
|---|---|---|
| A | A1 | flat repo layout (`solon-mvp-dist/scripts/sfs-*.sh`) |
| B | B2 + (b) | 전체 backfill, main 0.6 migrate 후 closed → archive branch |
| C | C4-γ | interactive + --apply (양 단계 confirm) + --auto (fully unattended) 3 surface |
| D | D4 | unit + smoke + CI matrix + cross-instance verify (P-17) |
| E | E5 | deprecation warning + 6 mo grace + user 명시 승인 migrate (hard cut 2026-11-03) |
| F | F4 + (c) | full structured yaml + lifecycle, close 시 user prompt (archive vs delete) |
| G | G2-α | 0.6.0 부터 suffix drop, hard cut, 0.5.x historical 보존 |

→ **9/9 locked**. round 3 추가 grill 불필요 (interface 결정 닫힘, 나머지는 plan-stage R/AC 또는 implement-stage Gray Box 위임).

---

## §8. Append Log (round 별 grill 기록)

- **Round 1 (2026-05-03T22:10+09:00)**: 7 axes (A~G) 옵션 제시. user 회수 — A1 / B2 / C4 (clarification 요청) / D (clarification 요청) / E E3+E1 hybrid / F F4+삭제 가능 / G2.
- **Round 2 (2026-05-03T22:20+09:00)**: clarification + hybrid 정형화 + cascade grill.
  - C clarification: C4-α/β/γ 정의 → user lock C4-γ.
  - D clarification: D scope (i)+(ii)+(iii)+cross-instance → user lock D4.
  - E hybrid 정형화: E5 = deprecation warning + 6 mo grace + opt-in migrate → user lock E5 (6 mo).
  - F lifecycle 정형화: F4 + close 시 (a)/(b)/(c) → user lock (c) user 매번 prompt.
  - G2 cascade: G2-α/β/γ → user lock G2-α (hard cut).
  - B2 implied sub-axis (closed sprint archive 정책): (a)/(b)/(c) → user lock (b) main migrate 후 archive.
- **Round 3 (2026-05-03T22:25+09:00)**: round close. status=ready-for-plan. G1 plan 진입 = user 명시 명령 후 (no-auto-advance).
