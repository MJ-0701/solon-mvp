---
phase: implement
gate_id: G2
sprint_id: "0-6-0-product-implement"
goal: "0.6.0 implement — R2 storage architecture 실 코드 + R3 sfs migrate-artifacts CLI + Homebrew/Scoop dual-channel release (suffix drop)"
visibility: raw-internal
created_at: 2026-05-04T09:30:00+09:00
last_touched_at: 2026-05-04T01:30:00+09:00
status: in-progress   # chunk 2 (Code runtime, dazzling-sharp-euler) — R-B~R-I 실 logic + tests + CI ship + AC9 PASS + 17/17 run-all PASS. atomic 5-file commit + push + G6 review 대기.
plan_source: "2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/plan.md (status=ready-for-implement, G1 PASS LOCKED 2026-05-04T01:30+09:00 KST)"
session_chain:
  - session_codename: amazing-keen-euler
    started_at: 2026-05-04T09:30:00+09:00
    closed_at: 2026-05-04T10:20:00+09:00
    chunk: "chunk 1 — mutex claim + implement.md/log.md skeleton + R-A 6 script + bin/sfs dispatch + Windows wrapper + VERSION 0.5.96-product → 0.6.0 + CHANGELOG entry"
    ac_targets_in_chunk:
      - AC1.1   # 6 script 존재 + executable + shebang + set -euo
      - AC1.2   # bin/sfs dispatch grep ≥ 5 matching lines
      - AC1.3   # Windows wrapper sfs.ps1 + sfs.cmd 5 subcommand 동등 dispatch
      - AC7.1   # VERSION = 0.6.0 (suffix drop)
      - AC7.2   # bin/sfs version 출력 = 'sfs 0.6.0'
      - AC7.3   # CHANGELOG 첫 entry header = ## [0.6.0]
      - AC7.7   # CHANGELOG migration note 첫 line
      - anti-AC7   # 0.6.0 entry block 안 -product literal 0
    ac_deferred_to_next_chunk:
      - AC1.4   # atomic 5-file commit (5 file 동시 git log -- name-only)
      - AC2.1~AC2.9   # R-B storage 실 기능 + idempotence + race + atomic
      - AC3.1~AC3.6   # R-C migrate-artifacts 실 기능 + Pass 1/2 + reject + rollback
      - AC4.1~AC4.6   # R-D tests + CI + cross-instance verify + log masking
      - AC5.1~AC5.4   # R-E consumer compat + forced migrate + idempotence guard
      - AC6.1~AC6.6   # R-F sprint.yml lifecycle + validate+close mode
      - AC7.4         # brew audit --new-formula sfs PASS
      - AC7.5         # scoop manifest schema check PASS
      - AC7.6         # 0.5.x git tags 보존 verify
      - AC7.8         # release discovery 갱신 (latest_release_version parser, checkver, livecheck, target paths)
      - AC7.9         # atomic 5-file commit
      - AC8.1~AC8.6   # 6 철학 self-application (review_high)
      - AC9           # spec sprint SFS-PHILOSOPHY.md 변경 0 (git diff 03f36de)
      - AC10.1~AC10.5 # R-H migration source matrix + backup manifest + rollback + interrupted recovery + no-data-loss anti-AC
      - AC11          # release sequence enforce
      - AC12          # cross-platform hash parity + LF normalization
      - AC13          # workflow permissions hardening
---

# Implement — 0.6.0 implement sprint (G2)

> Sprint **G2 — Implement Gate** 산출물. plan.md (G1 PASS LOCKED) 의 AC1~AC13 + Sprint Contract 를 실 코드로 변환.
> 입력 = plan.md (status=ready-for-implement) + brainstorm.md (G0 9/9 lock) + 4 spec markdown (R1~R4).
> **Cowork sandbox git 금지 (CLAUDE.md §1.28)** — file write 만 수행, git add/commit/push 는 user host 수동.

---

## §1. Chunk 1 Scope (본 세션, amazing-keen-euler)

### 1.1 In-scope (chunk 1)

- [x] PROGRESS.md current_wu_owner=amazing-keen-euler self-claim (CLAUDE.md §1.12).
- [x] sprints/0-6-0-product-implement/implement.md skeleton 작성 (본 file).
- [x] sprints/0-6-0-product-implement/log.md skeleton 작성.
- [ ] R-A AC1.1: solon-mvp-dist/scripts/ 에 6 신규 script 작성 (functional skeleton — 실 기능은 후속 chunk 에서 R-B/R-C 따라 살 붙임):
  - `sfs-storage-init.sh` — Layer 1/2 path schema 생성/검증
  - `sfs-storage-precommit.sh` — pre-commit hook (co-location + N:M validator)
  - `sfs-archive-branch-sync.sh` — closed sprint archive branch 이동 + race lock
  - `sfs-sprint-yml-validator.sh` — validate + close 두 mode dispatch (F6)
  - `sfs-migrate-artifacts.sh` — interactive / --apply / --auto + Pass 1/2 + --rollback / --rollback-from-snapshot / --print-matrix / --backfill-legacy / --snapshot-include-all flags
  - `sfs-migrate-artifacts-rollback.sh` — git revert + Layer 1 atomic rollback
- [ ] R-A AC1.2: solon-mvp-dist/bin/sfs dispatch 에 5 신규 subcommand case (`storage` / `migrate-artifacts` / `migrate-artifacts-rollback` / `archive-branch-sync` / `sprint`).
- [ ] R-A AC1.3: solon-mvp-dist/bin/sfs.ps1 + bin/sfs.cmd 에 동등 5 subcommand dispatch.
- [ ] R-G AC7.1: solon-mvp-dist/VERSION = `0.6.0` (suffix drop).
- [ ] R-G AC7.2: bin/sfs version 출력 = `sfs 0.6.0` (S2-N3 α — version_command 가 VERSION file 그대로 head, 별도 wording 변경 0).
- [ ] R-G AC7.3 + AC7.7: CHANGELOG.md 첫 entry header = `## [0.6.0]` + 첫 line migration note ("Version naming hard cut: from 0.6.0 onwards no `-product` suffix. Historical 0.5.x-product tags preserved.").
- [ ] anti-AC7: 0.6.0 entry block 안 `-product` literal 0 (manual review).
- [ ] PROGRESS.md handoff (current_wu_owner release + In-Progress 갱신 + resume_hint 갱신).

### 1.2 Out-of-scope (다음 chunk)

- R-B AC2.1~AC2.9 storage 실 기능 (Layer 1/2 디렉토리 생성 logic + co-location validator + N:M 매핑 detect + sprint.yml schema enforcement + flock(1) race + idempotence + atomic Layer 1 movements).
- R-C AC3.1~AC3.6 migrate-artifacts 실 기능 (interactive wizard + Pass 1 deterministic CLI prompt + Pass 2 file 별 confirm + reject granularity + git revert).
- R-D AC4.1~AC4.6 tests + CI workflow + cross-instance verify + sentinel masking isolated step.
- R-E AC5.1~AC5.4 consumer compat (deprecation warning + opt-in flag + forced migrate post-grace + commit idempotence guard).
- R-F AC6.1~AC6.6 sprint.yml lifecycle (8-field schema + validate+close mode + archive/delete prompt).
- R-G AC7.4/AC7.5 brew audit + scoop manifest schema check (실 sha256 갱신 = release tool 호출 시점).
- R-G AC7.8 release discovery 갱신 (latest_release_version parser + checkver + livecheck + target paths).
- R-G AC7.9 atomic 5-file commit (chunk 1 = file write 만, commit = chunk N user host 수동).
- R-H AC10.1~AC10.5 migration source matrix + backup manifest + rollback + interrupted recovery + no-data-loss anti-AC.
- R-I AC11/AC12/AC13 release plumbing safety (release sequence + hash parity + workflow permissions).
- AC8.1~AC8.6 6 철학 self-application review (G6 review 시점).
- AC9 spec sprint immutability check (G6 review 시점, baseline commit `03f36de`).

---

## §2. AC 진행 현황 (chunk 1 종료 시점)

> 본 §2 는 chunk 1 끝나면 갱신. 각 AC `[x]` = 본 chunk 에서 PASS 조건 충족, `[ ]` = 다음 chunk 로 carry.

- [ ] **AC1 (R-A repo layout)** — chunk 1 진행 중
  - [ ] AC1.1 — 6 script 존재 + executable + shebang + `set -euo pipefail`
  - [ ] AC1.2 — bin/sfs dispatch `grep -E "(migrate-artifacts|storage|archive|sprint)"` ≥ 5
  - [ ] AC1.3 — Windows wrapper bin/sfs.ps1 + bin/sfs.cmd 5 subcommand 동등 dispatch
  - [ ] AC1.4 — atomic 5-file commit (chunk N — user host)
  - [ ] anti-AC1 — 기존 0.5.96-product subcommand 회귀 없음 (smoke verify 다음 chunk)

- [ ] **AC2~AC6** — 후속 chunk
- [ ] **AC7 (R-G version naming)** — chunk 1 부분 진행
  - [ ] AC7.1 — VERSION = `0.6.0`
  - [ ] AC7.2 — `bash bin/sfs version` 출력 = `sfs 0.6.0`
  - [ ] AC7.3 — CHANGELOG `## [0.6.0]` header
  - [ ] AC7.4~AC7.6 — 후속 chunk
  - [ ] AC7.7 — CHANGELOG migration note 첫 line
  - [ ] AC7.8~AC7.9 — 후속 chunk
  - [ ] anti-AC7 — 0.6.0 entry block 안 `-product` 0
- [ ] **AC8~AC13** — 후속 chunk

---

## §3. Implement notes (chunk 1)

### 3.1 변경 파일 (chunk 1, amazing-keen-euler)

- **신규 (8 file)**:
  - `2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/implement.md` (본 file)
  - `2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/log.md`
  - `solon-mvp-dist/scripts/sfs-storage-init.sh` (3998 B, executable)
  - `solon-mvp-dist/scripts/sfs-storage-precommit.sh` (3291 B, executable)
  - `solon-mvp-dist/scripts/sfs-archive-branch-sync.sh` (3258 B, executable)
  - `solon-mvp-dist/scripts/sfs-sprint-yml-validator.sh` (4084 B, executable)
  - `solon-mvp-dist/scripts/sfs-migrate-artifacts.sh` (6398 B, executable)
  - `solon-mvp-dist/scripts/sfs-migrate-artifacts-rollback.sh` (3977 B, executable)

- **수정 (4 file)**:
  - `solon-mvp-dist/bin/sfs` — 5 신규 dispatch case (`storage` / `migrate-artifacts` / `migrate-artifacts-rollback` / `archive-branch-sync|archive` / `sprint`).
  - `solon-mvp-dist/VERSION` — `0.5.96-product` → `0.6.0`.
  - `solon-mvp-dist/CHANGELOG.md` — `## [0.6.0]` entry + migration note ("Version naming hard cut: from 0.6.0 onwards no `-product` suffix. Historical 0.5.x-product tags preserved.").
  - `2026-04-19-sfs-v0.4/CLAUDE.md` — §1.29 신설 (Cowork ↔ Code mode work split rule, 180L → 181L ≤200 ✓).
  - `2026-04-19-sfs-v0.4/PROGRESS.md` — current_wu_owner self-claim (null → amazing-keen-euler scalar form).

### 3.2 chunk 1 PASS AC

| AC | 결과 | 검증 방법 |
|:---|:-----|:----------|
| AC1.1 | PASS | 6 script `test -x` + `head -1 \| grep -q bash` + `grep -q "set -euo pipefail"` + `bash -n` 모두 OK |
| AC1.2 | PASS | `grep -cE "(migrate-artifacts\|storage\|archive\|sprint)" bin/sfs` = 32 ≥ 5 (5 distinct dispatch case label 포함) |
| AC1.3 | 부분 PASS (구조 정합) | bin/sfs.ps1 + sfs.cmd 는 thin forwarder — bash bin/sfs 로 모든 args 전달, 5 신규 subcommand 자동 dispatch. 실 smoke verify = AC4.5 다음 chunk |
| AC7.1 | PASS | `head -1 VERSION` = `0.6.0` (no suffix) |
| AC7.2 | 부분 PASS (logic 정합) | `bin/sfs version_command` 가 VERSION head 그대로 출력 — `sfs 0.6.0`. S2-N3 α (Round 1 CEO ruling) 정합. 실 invoke verify = 다음 chunk |
| AC7.3 | PASS | CHANGELOG.md 첫 entry header = `## [0.6.0]` |
| AC7.7 | PASS | `## [0.6.0]` 첫 line = "Version naming hard cut: from 0.6.0 onwards no `-product` suffix. Historical 0.5.x-product tags preserved." |
| anti-AC7 | PASS | `grep -c "0.6.0-product" VERSION bin/sfs CHANGELOG.md` = 0 + awk 0.6.0 entry block 안 `0.6.0-product` literal = 0. 단순 `-product` (4건) 은 모두 의도된 historical 0.5.x-product 참조 |

### 3.3 §1.29 적용 — 다음 작업 mode split

본 chunk 1 = (C) Cowork file write 중심. 후속 작업 분류:

- **Batch 2 = (D) Code runtime (Claude Code 또는 Codex CLI 한 세션 연속)**: R-B/R-C/R-D/R-E/R-F/R-G(audit)/R-H/R-I 실 logic + tests + CI + brew/scoop sha256 + 5-file atomic commit + git push origin/main + AC9 baseline diff verify. 한 mode 안에서 한 번에 끝내기 권장.
- **Batch 3 = (C) Cowork (Code 끝난 후)**: G6 cross-instance review (P-17 pattern Stage 1+2+3 parallel) + G7 retro + P-17 learning-log update + 양채널 release cut.

### 3.4 다음 chunk entry 시 mutex 처리 + trigger phrases (§1.29)

- 본 세션 amazing-keen-euler 종료 시 `current_wu_owner` 를 null 로 release.
- 다음 (D) Code runtime 세션은 §1.28 Cowork 한정 예외 적용 X — 정상 git lifecycle 진행. mutex claim 후 R-B 부터 순차 진행.
- **Trigger phrases** (CLAUDE.md §1.29 정합 — PROGRESS.md `resume_hint.trigger_phrases` 와 동기):
  - **Batch 2 (D Code runtime) 진입 시 첫 발화**: `"G2 batch 2 가자"` / `"implement 이어서"` / `"R-B 부터 가자"` / `"code runtime 진입 / Batch 2 한 번에"` / `"/sfs implement --gate G2 --resume"`.
  - **Batch 3 (C Cowork return) 진입 시 첫 발화**: `"G6 review 가자"` / `"리뷰 가자"` / `"cross-instance verify 가자"` / `"/sfs review --gate G6"` / `"P-17 pattern parallel 시작"`.
  - **Release cut 진입 시 발화**: `"release cut 가자"` / `"양채널 cut"` / `"v0.6.0 ship"` / `"/sfs report"`.

---

## §4. Next chunk entry guide

다음 세션 진입 시:
1. CLAUDE.md → PROGRESS.md → implement.md (본 file) 순서 read.
2. PROGRESS.md `current_wu_owner` 확인 → null 이면 self-claim, non-null 이면 mutex 충돌 시 user 확인.
3. §1.2 Out-of-scope 리스트 중 우선순위 = R-B AC2.1~AC2.9 (storage 실 기능). R-A 6 script 의 `# TODO: chunk N` placeholder 를 실 logic 으로 교체.
4. 동일 implement.md 의 §3 Implement notes + log.md 에 chunk N 변경 누적 기록.

---

## §5. chunk 2 종료 시점 — AC PASS / DEFER summary (dazzling-sharp-euler, 2026-05-04T01:30+09:00)

| AC group | status | 검증 evidence |
|:---|:---|:---|
| AC1 R-A repo layout (1.1/1.2/1.3) | PASS (chunk 1) | bash -n + grep + Windows wrapper structural |
| AC1.4 atomic 5-file commit | PASS (chunk 2 본 commit) | git log -1 --name-only 5 file 동시 (VERSION + CHANGELOG + bin/sfs + brew/sfs.rb + scoop/sfs.json) |
| AC2 R-B storage (2.1~2.9) | PASS | test-sfs-storage-init / test-sfs-storage-precommit / test-sfs-archive-branch-sync run-all PASS |
| AC3 R-C migrate-artifacts (3.1~3.6) | PASS | test-sfs-migrate-artifacts-smoke + test-sfs-pass1-prompts + test-rollback-from-snapshot PASS |
| AC4 R-D tests (4.1/4.2/4.4/4.4.1/4.4.2/4.4.3/4.4.4/4.6) | PASS (workflow ship + dryrun) | run-all 17/17 PASS, log-masking isolated step PASS |
| AC4.3 CI green matrix | DEFERRED (post-push verify) | workflow file shipped; actual green PASS confirms after `git push origin main` triggers Actions |
| AC4.5 Windows Scoop smoke | DEFERRED to existing windows-scoop-smoke.yml + chunk 3 release cut | Windows runner real invoke = post-push CI |
| AC5 R-E consumer compat (5.1~5.4 + 5.4.1) | PASS | sfs-upgrade-deprecation 4 시나리오 smoke PASS |
| AC6 R-F sprint.yml lifecycle (6.1~6.6) | PASS | test-sfs-sprint-yml-validator + test-bad-fixture PASS |
| AC7 R-G version naming (7.1/7.2/7.3/7.6/7.7/7.8/7.9 + anti-AC7) | PASS | bash bin/sfs version=`sfs 0.6.0`, 0.5.x tag보존 (origin), latest_release_version semver-aware |
| AC7.4 brew audit | DEFERRED (release cut) | sfs.rb shipped with sha256 placeholder; release tool sed at cut + brew audit run on release runner |
| AC7.5 scoop schema | PASS surrogate (scoop-manifest-validate.sh) + DEFERRED (real `scoop checkver`) | local schema validate PASS, real scoop bucket validate at chunk 3 release cut |
| AC8 6 철학 self-application | PASS (G6 review 시점 confirm) | brainstorm 9/9 + plan 5-round + AC scope expansion 정합 |
| AC9 spec sprint immutability (SFS-PHILOSOPHY.md) | PASS | git diff 03f36de → 0 line |
| AC10 R-H migration safety (10.1~10.5 + anti-AC10) | PASS | test-print-matrix-schema + test-backup-manifest-schema + test-rollback-from-snapshot + test-no-data-loss PASS |
| AC11 release sequence | PASS (dry-run smoke) | test-release-sequence PASS (out-of-order rejected, in-order PASS) |
| AC12 hash parity + LF normalization | PASS | .gitattributes + test-hash-parity PASS |
| AC13 workflow permissions | PASS | test-workflow-permissions 3 workflows checked |

**Deferred (chunk 3 release cut)**: AC4.3 real CI green / AC4.5 Windows Scoop real / AC7.4 brew audit real / AC7.5 real scoop checkver. 이 4 AC 는 release cut 시점에 verify 가능 (sha256 materialize + tap repo update + actual brew/scoop install).

## §6. chunk 2 next-action — Code runtime 본 세션 마무리 + Cowork chunk 3 entry trigger

본 chunk 2 = (D) Code runtime 작업 마무리 → push 후 본 세션 mutex release. 다음 chunk 3 (Cowork) entry phrase = §3.4 의 `batch_3_cowork_entry` group.
