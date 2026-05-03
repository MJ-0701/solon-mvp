---
phase: review
gate_id: G1
gate_name: "Plan Review Gate (G1, plan.md status=ready-for-review → ready-for-implement 전환 후보)"
sprint_id: "0-6-0-product-implement"
goal: "0.6.0 implement sprint G1 plan review — plan.md (R-A~G + AC1~AC9 + Sprint Contract) plan-quality + brainstorm 9/9 lock 직접 expansion 정합 cross-instance verify"
visibility: raw-internal
created_at: 2026-05-03T23:10:00+09:00
last_touched_at: 2026-05-03T23:10:00+09:00
evaluator_role: CPO
evaluator_persona: ".sfs-local/personas/cpo-evaluator.md"
evaluator_executor_round_1: "claude (cowork same instance, wizardly-quirky-gauss) — AI-PROPOSED Stage 1, self-val flag"
evaluator_executor_round_2: "codex (user-side cross-runtime cross-instance) — Stage 2 (pending)"
evaluator_executor_round_3: "gemini (user-side cross-runtime cross-instance) — Stage 3 (pending)"
generator_executor: "claude (cowork affectionate-trusting-thompson session, plan.md authoring)"
self_validation_flag: true   # Stage 1 same-instance flag; Stage 2 (codex) + Stage 3 (gemini) cross-instance verify 로 resolution.
verdict_round_1_self: "AI-PROPOSED PASS-with-flags (8 review-grade flags for Stage 2/3 cross-instance)"
verdict_round_2_codex: "PENDING (user host invoke required)"
verdict_round_3_gemini: "PENDING (user host invoke required)"
verdict_final: "PENDING (Stage 2 + Stage 3 + user CEO ruling 후)"
verdict_current: "Stage 1 AI-PROPOSED PASS-with-flags — Stage 2/3 진입 대기"
related_review:
  spec_g1_review: "sprints/0-6-0-product-spec/review.md (Round 1~4, Codex final PASS LOCKED) — 본 G1 review 의 P-17 cross-instance 패턴 precedent"
  spec_g6_review: "sprints/0-6-0-product-spec/review-g6.md (Stage 1+2+3 + CEO ruling PASS LOCKED) — 본 G1 review 의 Stage 1 포맷 reference"
session: "claude-cowork:wizardly-quirky-gauss (Stage 1 authoring)"
---

# Review G1 — 0.6.0-product implement plan (pre-implement)

> Sprint **G1 Plan Review Gate** 산출물. plan.md (G1, status=ready-for-review) 의 plan-quality + brainstorm 9/9 lock 직접 expansion 정합 검증.
> ⚠️ **Self-Validation Flag**: 본 파일은 user 명시 chain plan 의 첫 step = **claude same-instance Stage 1 자체리뷰**. spec sprint G1 review (Round 1~4 cycle) + spec sprint G6 review (Stage 1+2+3 + CEO ruling) 의 P-17 패턴 정합으로 Stage 2 (codex cross-runtime) + Stage 3 (gemini cross-runtime) prompt 가 §6 에서 제공.

---

## §1. 대상 Gate

- **gate_id**: G1 (new 7-Gate naming = Gate 3 (Plan), 단 review.md 명명은 G1 = Plan-review historical convention 정합).
- **scope**:
  - `sprints/0-6-0-product-implement/brainstorm.md` (G0, status=ready-for-plan, 9/9 axes locked) — input frame.
  - `sprints/0-6-0-product-implement/plan.md` (G1, status=ready-for-review, 277 lines) — review target.
- **trigger**: user `/sfs review --gate G1, P-17 cross-instance → G2 implement → G6 review → G7 retro → release cut (양채널, §1.24)` chain plan. CLAUDE.md §1.20 sequential disclosure 정합으로 본 세션 = G1 review Stage 1 만.
- **CPO persona**: `.sfs-local/personas/cpo-evaluator.md`.
- **review executor (Stage 1)**: claude (cowork wizardly-quirky-gauss) — ⚠️ **same as generator session lineage** (plan.md authored by sibling cowork session affectionate-trusting-thompson, same model family same instance class).
- **review executor (Stage 2)**: codex (user-side cross-runtime cross-instance, prompt §6.1).
- **review executor (Stage 3)**: gemini (user-side cross-runtime cross-instance, prompt §6.2).
- **generator executor**: claude (cowork affectionate-trusting-thompson session).

## §2. Self-Validation Disclosure

`model-profiles.yaml` v1.1 `execution_standard.cannot: approve own work` + CLAUDE.md §1.3 (self-validation-forbidden) + plan §5 contract (Sprint Contract: CPO Evaluator runtime = cross-runtime 권장, P-17 pattern) + spec sprint G1 review Round 1~4 precedent (claude same-instance R1 PASS 부정확 → codex PARTIAL × 2 → codex PASS) — **same-instance evaluator 는 Stage 1 으로 한정, AI-PROPOSED 명시**, Stage 2 + Stage 3 cross-instance verify 로 self-validation flag CLEAR 가능.

본 review 는 user explicit chain plan ("P-17 cross-instance") 의 Stage 1 산출. Stage 2/3 verdict 회수 + final lock 은 다음 conversation cycle.

---

## §3. 평가 항목

### §3.1 AC 구조 plan-quality re-confirm (R-A~G ↔ AC1~AC9 mapping)

> G1 plan-time review = **AC 정의 자체의 plan-quality** (binary verify-by 명시 / anti-AC 명시 / R 정의와 1:1 mapping) 검증.
> implement 산출물 부재이므로 AC1~AC9 actual evaluation 은 G6 review 에서. 본 §3.1 = "AC 가 implement 시점에 binary 검증 가능하게 정의됐나?" 판정.

| AC | R 대응 | sub-check 개수 | binary verify-by | anti-AC | plan-quality |
|---|---|---|---|---|---|
| AC1 | R-A repo layout | 1 + anti-AC1 | `for f; do test -x; head -1 grep bash; done` + `grep dispatch ≥ 5` | anti-AC1 회귀 없음 명시 | PASS-with-flag (F1: grep ERE escape ambiguity §4.2.1) |
| AC2 | R-B R2 storage | 8 sub-checks | path 생성 / validator exit / archive branch / backfill diff | anti-AC2 도메인 hardcoding | PASS-with-flag (F5: AC2.6 pre-merge hook 위치 `또는` ambiguity §4.2.5) |
| AC3 | R-C R3 migrate-artifacts | 6 sub-checks | smoke harness `yes "k" \|` / interactive prompt verify / rollback | (없음) | PASS-with-flag (F8: interactive prompt user input 시뮬레이트 방식 unspecified §4.2.8) |
| AC4 | R-D test | 4 sub-checks | unit / smoke / CI matrix / cross-instance verify | (없음) | PASS-with-flag (F4: AC4.4 cross-instance CI fallback policy 부재 §4.2.4) |
| AC5 | R-E consumer compat | 4 sub-checks | deprecation warning grep / opt-in flag / silent / hard cut default | (없음) | PASS-with-flag (F3: R-E.E-4 vs §3 out-of-scope wording divergence §4.2.3) |
| AC6 | R-F sprint.yml lifecycle | 5 sub-checks | schema field / status FSM / prompt / archive / delete | (없음) | PASS-with-flag (F6: sprint close subcommand R-A 6 script 목록 미명시 §4.2.6) |
| AC7 | R-G version naming | 7 sub-checks | VERSION literal / bin/sfs version / CHANGELOG header / brew url tag / scoop version / 0.5.x tags ≥ 80 / migration note | anti-AC7 suffix 잔존 금지 | PASS |
| AC8 | 6 철학 self-application | 6 sub-checks (review_high) | review.md binary judgment | (없음) | PASS-with-flag (F7: AC8 review_high G1 plan-time evaluation 한계 §4.2.7) |
| AC9 | spec sprint AC carry | 1 (deterministic) | `git diff SFS-PHILOSOPHY.md = 0` | (없음) | PASS-with-flag (F2: AC ID 충돌 — 본 AC9 가 spec sprint AC8 carry, 본 plan 안에 AC8 별도 존재 = grep cross-ref ambiguity §4.2.2) |

→ **AC plan-quality 9/9 = PASS-with-flags** (AC1/AC2/AC3/AC4/AC5/AC6/AC8/AC9 = 8 flags, AC7 = clean).

### §3.2 brainstorm 9/9 lock ↔ plan R-A~G ↔ AC sub-check 정확 expansion

| brainstorm lock | plan R | plan AC | expansion 정합 |
|---|---|---|---|
| A1 (flat layout) | R-A 6 script 평면 | AC1 (test -x + head shebang + dispatch grep ≥ 5) + anti-AC1 | ✓ (단 F6: sprint close subcommand 누락) |
| B2 + (b) (전체 backfill + main migrate 후 archive) | R-B B-1~B-8 | AC2.1~AC2.8 | ✓ (8 sub-check 모두 cover, F5 ambiguity 만) |
| C4-γ (interactive + --apply + --auto 3 surface) | R-C C-1~C-6 | AC3.1~AC3.6 | ✓ (6 sub-check 모두 cover, F8 prompt simulate 만) |
| D4 (unit + smoke + CI + cross-instance) | R-D D-1~D-4 | AC4.1~AC4.4 | ✓ (4 sub-check 모두 cover, F4 fallback 만) |
| E5 (warning + 6 mo grace + opt-in) | R-E E-1~E-4 | AC5.1~AC5.4 | ✓ (4 sub-check 모두 cover, F3 hard cut wording 만) |
| F4 + (c) (full yaml + close prompt) | R-F F-1~F-5 | AC6.1~AC6.5 | ✓ (5 sub-check 모두 cover, F6 close subcommand 만) |
| G2-α (suffix drop hard cut) | R-G G-1~G-7 | AC7.1~AC7.7 + anti-AC7 | ✓ (7 sub-check + anti-AC, clean) |

→ **9/9 lock → R-A~G → AC sub-check expansion = 직접 carry forward, 신규 결정 추가 0**. plan §5 contract 정합 ("plan 단계 신규 user 결정 0").

### §3.3 6 철학 self-application (plan-time evidence)

본 sprint 의 plan 자체가 6 철학을 위반하지 않는가:

- **Grill Me**: brainstorm round 1 (7 axes) → round 2 (5 clarification + 1 implied sub-axis) → round 3 (lock close) = 9/9 lock evidence + plan §6 self-flag 5 implement-stage gotcha (Pre-merge hook 위치 / Backfill idempotence / Archive branch race / CI cost / VERSION cascade) = CTO self-grill evidence. ✓
- **Ubiquitous Language**: 핵심 용어 (Layer 1/2 / sprint.yml / migrate-artifacts / opt-in 0.6-storage / cross-instance verify / suffix drop / archive branch / N:M / co-location) 가 spec source (R1~R4) + brainstorm (§6.1~§6.7) + plan (R-A~G + AC1~AC9) + frontmatter brainstorm_decisions_inherited 일관. ✓
- **TDD-no-overtake**: AC1~AC9 binary verify-by 가 G2 implement 직전 명시 — implement signal source 가 plan 안에 헤드라이트로 fix. ✓
- **Deep Module**: 6 신규 script = 각각 deep module 단위 (storage-init / storage-precommit / archive-branch-sync / sprint-yml-validator / migrate-artifacts / migrate-artifacts-rollback). brainstorm A1 flat lock + plan R-A 6 script 명시 = shallow split 회피. ✓ (단 F6: sprint close subcommand 가 7번째 script 가 될 가능성 — implement-time 결정 필요)
- **Gray Box**: brainstorm 9/9 lock = user-locked interface, plan AC8.5 명시 = "구현 detail (file content / error message / 헬퍼) AI fill". ✓
- **Daily System Design**: 본 sprint = 0.6.0 daily 1 step. spec sprint (R2+R3) → implement sprint (실 코드) → release cut 의 daily progression. ✓

→ **6/6 ✓** (plan-time self-application 자체에 violation 없음, F6 만 yellow-flag).

### §3.4 Cross-Reference Consistency

- **brainstorm.md ↔ plan.md frontmatter**: brainstorm `brainstorm_decisions` 9 항목 (A1 / B2+(b) / C4-γ / D4 / E5 / F4-with-lifecycle / G2-α) → plan `brainstorm_decisions_inherited` 7 항목 (A1 / B2 / C4-γ / D4 / E5 / F4-with-lifecycle / G2-α) — **wait, 9/9 vs 7 항목 카운트 mismatch**. 실제 brainstorm 의 9 lock = 7 axes (A~G) + 2 implied sub-axes (B2_archive_policy + F4_with_lifecycle close (c)). plan frontmatter 는 7 항목으로 표현 (sub-axes 가 main axes 안에 흡수 — B2 wording = "전체 backfill ... 그 후 closed 는 archive branch" / F4 wording = "full structured yaml + lifecycle, close 시 user prompt"). 의미 정합 ✓ but **F9: count terminology 일관성 — plan §1 R-B 도 "B2 + (b)" 표기, plan §4 self-check 도 "9/9 lock"** 으로 9 표현이 일관 사용 — frontmatter 만 7 collapse 표현. 명백한 ambiguity 는 아니지만 cross-runtime 가 발본 가능.
- **spec source ↔ plan**: plan `spec_source` 4 항목 (SFS-PHILOSOPHY.md R1 / storage-architecture-spec.md R2 / migrate-artifacts-spec.md R3 / improve-codebase-architecture-spec.md R4) — frontmatter list ↔ plan §1 R 정의 (R-A~R-G 는 implementation R, R1~R4 spec R 와 별개 namespace) 정합. R 의미 분리 명시. ✓
- **plan §3 dependencies ↔ frontmatter**: spec sprint G6 PASS LOCKED (✅ 2026-05-03 21:55 KST, push 03f36de) + 4 spec markdown shipped (✅) + brainstorm 9/9 ✅ + CI/Secrets/tap 기존 0.5.96-product flow 정합. 모두 일관. ✓
- **plan §5 Sprint Contract ↔ §1 R 정의**: CTO Generator 산출물 예상 (~10 신규 + ~6 수정 = ~16 file) ↔ §1 R-A 6 신규 script + §1 R-G 5 file (VERSION + CHANGELOG + bin/sfs + brew + scoop) + §1 R-D 4 file (3 unit + 1 CI workflow) + §1 R-E sfs upgrade 수정 + §1 R-F sprint.yml lifecycle 수정 + (선택) docs/0.6.0-migration-guide.md = ~16 file 정합. ✓

→ **Cross-ref consistency = ✓ with 1 minor F9 (count terminology)**.

### §3.5 anti-AC violations (plan-time grep 재검사)

- **anti-AC1** (기존 0.5.96-product subcommand 회귀 없음): plan §2 AC1 sub-bullet 명시. plan-time evaluation impossible (산출물 부재) — G6 review 시점 grep verify. ✓ (정의 OK)
- **anti-AC2** (storage script 도메인 hardcoding 금지: `admin-page|saas|customer-portal` grep = 0): plan §2 anti-AC summary 명시. spec sprint anti-AC2 carry-forward. ✓ (정의 OK)
- **anti-AC7** (VERSION suffix 잔존 금지: 0.6.0 entry block 안에서 `-product` literal 0): plan §2 AC7 sub-bullet + anti-AC summary 명시. ✓ (정의 OK)

→ **anti-AC 정의 모두 명시, plan-time violation 0**.

---

## §4. Findings

### §4.1 Positive (강점)

- **brainstorm 9/9 lock direct expansion**: plan §4 self-check 4 항목 모두 PASS marking + plan AC1~AC7 가 brainstorm A1~G2-α 의 직접 expansion (신규 결정 추가 0). plan-time CEO 결정 부담 0.
- **AC binary 정의 강도**: AC1~AC7+AC9 = deterministic verify-by 명시 (script existence / shebang / grep / exit code / smoke harness output / git diff). AC8 만 review_high judgment 로 분리 — spec sprint AC7 review_high 패턴 정합.
- **Sprint Contract 완결성**: §5 의 CEO/CTO/CPO + persona + reasoning_tier (strategic_high / review_high) + runtime (current / cross-runtime 권장) + AC verify method (deterministic vs review_high split) + 통과/부분/실패 기준 (pass/partial/fail 명시) + 재작업 contract (1 cycle partial / 2회 partial 시 escalate). model-profiles.yaml v1.1 정합.
- **anti-AC 명시도**: AC1 + AC2 + AC7 의 anti-AC 가 binary grep target 으로 정의 (회귀 없음 / 도메인 hardcoding 금지 / suffix 잔존 금지). spec sprint anti-AC2 carry-forward 정합.
- **§6 self-flag (CTO self-grill evidence)**: 5 implement-stage gotcha (Pre-merge hook 위치 / Backfill idempotence / Archive branch race / CI cost / VERSION cascade) 자체 발본. Grill Me 6 철학 self-application evidence.
- **Cross-Reference 정합**: spec_source 4 항목 ↔ plan R-A~G ↔ AC1~AC9 ↔ Sprint Contract 산출물 예상 (~16 file) 모두 cross-validate.

### §4.2 Stage 2/3 Cross-Instance Review-Grade Flags

> 본 §4.2 = same-instance Stage 1 의 한계로 발본 불가 가능성 + cross-runtime 발본 후보 8 flags. Stage 2 codex / Stage 3 gemini 가 각 flag 에 대해 PASS / PARTIAL / FAIL 판정 + 추가 발본 (각 stage 가 5+ flag 추가 가능).

#### F1 — AC1 grep ERE escape syntax suspicion

plan §2 AC1 verify-by:
```
grep -E "migrate-artifacts\|storage\|archive\|sprint" bin/sfs ≥ 5
```
ERE (`-E`) 모드에서 `\|` 는 literal `|` (escape 가 alternation 의 reverse). 의도 = 5 subcommand 중 ≥ 5 match. 정확한 ERE = `grep -E "migrate-artifacts|storage|archive|sprint" bin/sfs` (escape 제거) 또는 `grep -E "(migrate-artifacts|storage|archive|sprint)" bin/sfs`.

**Flag**: grep regex syntax bug 가능성. AC1 implementation 시 verify-by 그대로 실행하면 `migrate-artifacts|storage|archive|sprint` literal string 검색 → 0 match → AC1 false fail.

**Stage 2/3 task**: BRE/ERE escape semantics confirm + plan §2 AC1 verify-by 정정 권장 여부 판정.

#### F2 — AC ID 충돌 (본 plan AC8/AC9 vs spec sprint AC8)

본 plan AC8 = 6 철학 self-application (review_high, 6 sub-check), AC9 = spec sprint AC8 carry-forward (deterministic, `git diff SFS-PHILOSOPHY.md = 0`).
spec sprint G6 review-g6.md 의 AC8 = "harness URL ref = 2 / SFS-local analogy ref = 4 / 직접 인용 한국어 9 어절 ≤ 15 단어" — 직접 인용 ≤15 단어 가드.

본 plan AC9 = "spec sprint AC8 carry" 라고 명시했지만, 실 wording = `git diff SFS-PHILOSOPHY.md = 0` (코드 sprint 라 doc 변경 0 verify). spec sprint AC8 의 직접 인용 가드 의미와 다름.

**Flag**: AC ID label 동일 (AC8) but semantic divergence — cross-ref grep 시 ambiguity. plan §2 AC9 wording 을 "spec sprint SFS-PHILOSOPHY.md immutability carry" 또는 "AC9 (spec sprint SFS-PHILOSOPHY.md no-modification carry-forward)" 로 reword 권장 여부 판정.

**Stage 2/3 task**: AC ID 충돌 영향도 + reword 필요성 binary 판정.

#### F3 — R-E.E-4 / AC5.4 vs §3 out-of-scope wording divergence (hard cut 처리)

plan §1 R-E.E-4: "Hard cut date (2026-11-03) post-grace 시 옵션: (i) hard fail (`sfs upgrade` exit 1) 또는 (ii) forced migrate. **G1 plan 단계에서 (ii) 권장**".
plan §2 AC5.4: "Hard cut date (2026-11-03) 처리 — post-grace forced migrate (default) 또는 hard fail (config override). default behavior verify."
plan §3 out-of-scope: "Hard cut date (2026-11-03) 도래 시 forced migrate vs hard fail 결정 (G1 plan 권장 = forced migrate, user 가 0.6.x patch 시점에 변경 가능)."

**Flag**: 본 sprint 가 hard cut 처리 default behavior (forced migrate) 를 in-scope 으로 구현 + verify 하는지, vs 결정 자체 (config override 도입) 만 out-of-scope 인지 wording divergence. AC5.4 = in-scope (default 검증) 으로 읽히지만 §3 out-of-scope wording 도 "결정" 만 out-of-scope 인지 "구현 자체" out-of-scope 인지 ambiguous.

**Stage 2/3 task**: AC5.4 = in-scope (default forced migrate 구현 + verify), §3 out-of-scope = config override toggle 도입 — 두 wording 분리 필요성 판정.

#### F4 — AC4.4 cross-instance verify CI fallback policy 부재

plan §1 R-D.D-4 + AC4.4: "credential 관리 = GitHub Secrets (`CODEX_API_KEY` / `GEMINI_API_KEY`)" — Secrets 부재 시 CI 동작 미명시. plan §6 self-flag 4 = "매 PR 마다 codex+gemini invoke 시 API cost ↑. nightly schedule (`schedule: cron`) 옵션 권장" — cost 만 다룸.

**Flag**: (a) GitHub Secrets 부재 시 CI 동작 (skip with warning? hard fail?), (b) API rate-limit 도달 시 fallback (retry? skip?), (c) codex/gemini 둘 중 하나만 PASS 줄 때 PR block 정책 (둘 다 PASS 필수? majority? 어느 한쪽만?), (d) external API outage (codex/gemini API down) 시 fallback (skip with grace? block?). AC4.4 verify-by = "CI 안에서 invoke + verdict (PASS/FAIL) 기록" — fallback policy unspecified.

**Stage 2/3 task**: AC4.4 fallback policy AC sub-bullet 추가 권장 여부 판정 (E.g. AC4.4.1 Secrets 부재 = skip with warning, AC4.4.2 둘 다 PASS 필수, etc.).

#### F5 — AC2.6 pre-merge hook 위치 `또는` ambiguity

plan §1 R-B.B-6: "pre-merge hook (git pre-merge 또는 GitHub Actions PR check) 가 co-location + sprint.yml schema + N:M conflict 검증."
plan §2 AC2.6: "pre-merge hook script 가 위 4 validator 호출 + 실패 시 exit non-zero. `.git/hooks/pre-merge-commit` 또는 `.github/workflows/pr-check.yml` 등록."
plan §6 self-flag 1: "Pre-merge hook 위치: `.git/hooks/pre-merge-commit` (local) vs `.github/workflows/pr-check.yml` (CI). G2 implement 시 CI 측 우선 (consumer side 강제력 ↑), local hook 은 optional."

**Flag**: plan §6 self-flag = CI 우선 권장 but plan AC2.6 = `또는` (둘 중 하나만 PASS 시 OK?). binary verify 시 ambiguity. CI workflow 안 만들고 local hook 만 만들어도 AC2.6 PASS?

**Stage 2/3 task**: AC2.6 = "둘 다 등록 필수" or "CI 필수 + local optional" or "둘 중 하나" 셋 중 어떤 binary criterion 인지 명확화 권장 여부.

#### F6 — AC6.3 `sfs sprint close <sprint-id>` subcommand 가 R-A 6 script 목록에 미명시

plan §1 R-F.F-3: "Close 시 user prompt: `sfs sprint close <sprint-id>` (또는 `/sfs retro --close`) 가 prompt 출력".
plan §1 R-A 6 신규 script: storage-init / storage-precommit / archive-branch-sync / sprint-yml-validator / migrate-artifacts / migrate-artifacts-rollback. **`sfs sprint close` subcommand 가 어느 script 안에서 dispatch 되는지 미명시**.

**Flag**: (a) sprint-yml-validator.sh 안에 close 함수 추가? (b) 7번째 신규 script `scripts/sfs-sprint-close.sh` 추가? (c) bin/sfs dispatch 안에서 inline implement? plan R-A 의 6 script count 가 binary AC1 verify ("for f in 6files; do test -x $f; done") — 7번째 추가 시 AC1 numeric 변경 필요.

**Stage 2/3 task**: sprint close subcommand dispatch path + script count (6 vs 7) AC1 영향 판정.

#### F7 — plan §6 self-flag 5 gotcha 의 AC 미반영

plan §6 self-flag 5 gotcha:
1. Pre-merge hook 위치 (F5 에서 다룸)
2. Backfill idempotence (재실행 skip default + `--force` flag) — AC2.8 = "옛 sprints 전부 0.6 schema 변환 + git diff 검증 가능", idempotence sub-check 미명시
3. Archive branch race (file lock flock 또는 단일 owner 검증) — AC2.7 = "archive branch 생성 + closed sprint dir 이동", race 처리 sub-check 미명시
4. Cross-instance verify CI cost (F4 에서 다룸)
5. VERSION bump cascade (5 file atomic commit) — AC1+AC7 verify 가 atomic 검증 미명시

**Flag**: idempotence + race + atomic = implement-time discipline 으로만 capture, AC level binary verify 부재. spec sprint AC8 (review_high) 패턴으로 본 plan AC8 의 `Daily System Design` sub-check 안에 흡수 가능 but plan-time 명시 권장 여부 판정 필요.

**Stage 2/3 task**: 3 gotcha (idempotence / race / atomic) 가 AC sub-check 추가 필요 vs implement-discipline 위임 OK 판정.

#### F8 — AC3 interactive prompt user input 시뮬레이트 방식 unspecified

plan §2 AC3.1: "interactive wizard 가 file 별 prompt (keep/skip/edit) 띄움 — smoke harness 의 자동 입력 (`yes "k" |`) 으로 verify".
plan §2 AC3.2: "Pass 1 propose list 출력 + user confirm 대기 + Pass 2 file 별 confirm 대기" — user input 시뮬레이트 방식 미명시.
plan §2 AC3.5: "File-level reject (`n` 입력) 시 한 file 만 skip" — `n` 입력 방식 (`yes "n"|`? `expect`? printf chained?) 미명시.

**Flag**: AC3.1 = `yes "k" |` 명시, AC3.2/AC3.5 = 입력 방식 미명시. smoke harness 안에서 prompt sequencing 일관 처리 방식 미정 — implement-time verify 시 prompt 순서 (Pass 1 confirm → Pass 2 file confirm) 에 따라 input stream 다르게 구성 필요.

**Stage 2/3 task**: AC3.2/AC3.5 verify-by 에 input 방식 (e.g. `printf "y\nk\nk\nn\n" | sfs migrate-artifacts --apply`) 명시 권장 여부 판정.

#### F9 (minor) — count terminology 일관성 (9/9 vs 7 frontmatter)

plan frontmatter `brainstorm_decisions_inherited` = 7 항목 (collapsed sub-axes), plan §1 R-B = "B2 + (b)" 표기 (9/9 expanded), plan §4 self-check = "brainstorm 9/9 lock" 표기. 의미 정합 ✓ but count terminology mixed.

**Flag**: minor. frontmatter 가 9 항목으로 expand 또는 §1/§4 가 7-axis terminology 통일.

**Stage 2/3 task**: cosmetic 수정 권장 여부 판정 (low priority).

### §4.3 정합 항목 (별 flag 없음)

- frontmatter 모든 필수 필드 채워짐 (phase / gate_id / sprint_id / goal / visibility / created_at / status / spec_source / brainstorm_decisions_inherited / repo_target / current_version / target_version / hard_cut_date / session).
- AC7 (R-G version naming) = 7 sub-check + anti-AC 모두 binary, 정합 강도 높음.
- spec_source 4 항목 모두 G6 PASS LOCKED 정합 (R1~R4).
- plan §3 dependency 모두 충족 (spec G6 ✅ + 4 spec markdown ✅ + 기존 0.5.96 flow 정합).
- plan §5 Sprint Contract = CEO/CTO/CPO 3 role + persona reference + reasoning_tier (strategic_high / review_high) + runtime (default current + cross-runtime 권장) + 통과/부분/실패 기준 모두 명시.

---

## §5. AI-PROPOSED Verdict (Stage 1)

> ⚠️ **Self-Validation Flag set** (claude same-instance 자체리뷰). Stage 2 (codex) + Stage 3 (gemini) cross-instance verify 로 resolution.

**Stage 1 AI-PROPOSED verdict = PASS-with-flags**.

**근거**:
- AC1~AC9 plan-quality 9/9 (8 sub-flag, 모두 plan reword 또는 implement-discipline 으로 처리 가능, 어떤 것도 plan §3 scope 위반 또는 R 누락 아님).
- brainstorm 9/9 lock → plan R-A~G → AC sub-check expansion 직접 carry forward (신규 결정 추가 0) ✓.
- 6 철학 self-application 6/6 ✓ (F6 yellow-flag 만, F6 = sprint close subcommand R-A 명시 — implement-time clarification 가능).
- Cross-Reference 정합 ✓ (F9 minor count terminology only).
- anti-AC 정의 모두 명시 (anti-AC1 / anti-AC2 / anti-AC7).

**Pass criteria 정합 (plan §5 Sprint Contract)**:
- AC1~AC9 모두 plan-quality PASS (구조 + binary 정의 + R 매핑) → plan §5 pass criterion ("AC1~AC9 모두 PASS") 만족 (단 actual implement evaluation 은 G6 review).
- AC8 sub-check 단일 fail 0 (plan-time evidence 6/6).
- plan §3 scope 위반 0.

**Stage 2/3 의무**:
- 8 flags (F1~F8) 각각에 대해 PARTIAL / PASS / FAIL 판정.
- 추가 발본 (각 stage 5+ flag 추가 후보).
- Stage 2 PARTIAL 시 CTO (claude) fix → Stage 3 재평가.
- Stage 3 PASS + user CEO ruling lock → plan.md status: ready-for-review → ready-for-implement 전환 (frontmatter 갱신).

**자동 G2 implement 승급 금지** (CLAUDE.md §1.3 + §1.20 + spec sprint Round 1~4 precedent + brainstorm precedent). Stage 2/3 PASS LOCK 후에도 user 명시 G2 implement 명령 후 진입.

---

## §6. Stage 2/3 Cross-Instance Verify Prompts

> user host terminal 에서 codex / gemini 각 invoke 시 본 §6.1 / §6.2 prompt verbatim 제공. PARTIAL/PASS/FAIL verdict + flag 별 판정 + 추가 발본 (5+ flag) 회수.

### §6.1 Stage 2 — Codex cross-runtime prompt (user macOS terminal)

```
You are CPO Evaluator (cross-runtime cross-instance verify, P-17 pattern).

Target review:
- 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/plan.md (status=ready-for-review)
- 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/brainstorm.md (G0 9/9 locked)
- 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/review-g1.md (Stage 1 AI-PROPOSED PASS-with-flags)

Your task:
1. Re-evaluate review-g1.md §3 (AC plan-quality, brainstorm→plan expansion, 6 철학 self-application,
   cross-ref consistency, anti-AC) independent of Stage 1 conclusion.
2. For each of 8 flags (F1~F8 in §4.2), give independent verdict:
   PASS / PARTIAL (specify fix) / FAIL (specify reason).
3. Add 3+ new flags (Stage 2 발본) that Stage 1 same-instance missed.
4. Final verdict: PASS / PARTIAL / FAIL with reasoning.

Output format:
- §A Re-evaluation summary (≤200 words).
- §B Flag-by-flag verdict (F1~F8 + new Stage 2 flags).
- §C Final verdict + CTO action items (if PARTIAL).

Constraints:
- Stage 1 self-validation flag CLEAR 권한 = Stage 2 + Stage 3 합의.
- 본 plan = code sprint G1 (spec sprint 가 아님). plan-quality + brainstorm carry 정합 + AC binary
  verify-by 명시도 가 review focus. implement 산출물 부재 — actual AC1~AC9 evaluation 은 G6 review.
- ≤15 단어 직접 인용 가드 (CLAUDE.md mandatory_copyright_requirements 정합).

Reference:
- spec sprint G1 review (Round 1~4): 2026-04-19-sfs-v0.4/sprints/0-6-0-product-spec/review.md
- spec sprint G6 review (Stage 1+2+3 + CEO ruling): 2026-04-19-sfs-v0.4/sprints/0-6-0-product-spec/review-g6.md
```

### §6.2 Stage 3 — Gemini cross-runtime prompt (user host)

```
You are CPO Evaluator (cross-runtime cross-instance verify, P-17 pattern, Stage 3).

Stage 2 (codex) verdict: <user 회수 후 paste>.

Target review (same as Stage 2):
- plan.md / brainstorm.md / review-g1.md (post-Stage-2 fixes 반영 후).

Your task:
1. Stage 1 (claude same-instance) + Stage 2 (codex cross-runtime) 의 합의 부분 ↔ divergence 부분 분리.
2. F1~F8 flag + Stage 2 신규 flag 별 verdict (PASS / PARTIAL / FAIL).
3. Stage 1+2 가 모두 missed 한 flag 추가 발본 (Stage 3 = third-eye).
4. Final verdict: PASS / PARTIAL / FAIL.

Output format:
- §A Stage 1+2 합의/divergence 분석 (≤150 words).
- §B Flag-by-flag verdict + Stage 3 신규 flag.
- §C Final verdict + CTO action items.

Constraints:
- Stage 1+2 verdict 가 모두 PASS 여도 Stage 3 가 FAIL 결정 가능 (third-eye veto).
- ≤15 단어 직접 인용 가드.
```

---

## §7. Round Trace (Stage 1+2+3 + CEO ruling)

### §7.1 Stage 1 (claude same-instance) — 2026-05-03T23:10+09:00

- session: claude-cowork:wizardly-quirky-gauss
- AI-PROPOSED verdict: **PASS-with-flags** (8 flags F1~F8 + 1 minor F9)
- self-validation flag: **set** (Stage 2/3 으로 resolution)
- 다음 1 step: user host 에서 codex Stage 2 invoke (§6.1 prompt)

### §7.2 Stage 2 (codex cross-runtime) — pending

- evaluator: codex (user-side)
- prompt: §6.1
- 회수 방법: user macOS terminal codex CLI invoke → verdict paste 본 conversation
- 결과 기록 위치: 본 §7.2 (PARTIAL fix 적용 후 §7.2.fix)

### §7.3 Stage 3 (gemini cross-runtime) — pending

- evaluator: gemini (user-side)
- prompt: §6.2
- 회수 방법: user host gemini CLI invoke → verdict paste
- 결과 기록 위치: 본 §7.3

### §7.4 User CEO ruling — pending

- Stage 1+2+3 verdict 종합 + plan §3 scope ambiguity (F3) 등 user 결정 필요 사항 lock.
- 결과 기록 위치: 본 §7.4 + frontmatter `verdict_final`.

### §7.5 Final lock

- Stage 1+2+3 + CEO ruling 모두 PASS → `verdict_final: PASS LOCKED <ts>` + plan.md `status: ready-for-review → ready-for-implement` 전환.
- G2 implement 진입 = user 명시 명령 후 (자동 승급 금지, CLAUDE.md §1.3 + §1.20).

---

## §8. Next Steps (Sequential Disclosure)

1. **다음 1 step (본 review-g1.md ship 후)**: user host macOS terminal 에서 §6.1 prompt 로 codex 호출 → PARTIAL/PASS/FAIL verdict + flag 별 판정 + 추가 발본 회수 → 본 conversation paste.
2. Stage 2 PARTIAL 시: CTO (claude) fix 적용 → review-g1.md §7.2.fix 기록 → Stage 3 재평가.
3. Stage 2 PASS 시: §6.2 prompt 로 gemini Stage 3 호출 → verdict 회수.
4. Stage 3 PASS + user CEO ruling lock → plan.md frontmatter `status: ready-for-implement` 전환 + 본 review-g1.md `verdict_final: PASS LOCKED`.
5. user 명시 G2 implement 명령 (자동 승급 금지) → G2 implement sprint 진입.

> CLAUDE.md §1.28 (Cowork sandbox git 금지) 정합 — 본 review-g1.md ship 은 file-write only, commit/push 는 user host 수동. user 가 host terminal 에서 `git add 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/review-g1.md 2026-04-19-sfs-v0.4/PROGRESS.md` + commit + push.
