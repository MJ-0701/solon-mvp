---
phase: review
gate_id: G1
gate_name: "Plan Review Gate (G1, plan.md status=ready-for-review → ready-for-implement 전환 후보)"
sprint_id: "0-6-0-product-implement"
goal: "0.6.0 implement sprint G1 plan review — plan.md (R-A~G + AC1~AC9 + Sprint Contract) plan-quality + brainstorm 9/9 lock 직접 expansion 정합 cross-instance verify"
visibility: raw-internal
created_at: 2026-05-03T23:10:00+09:00
last_touched_at: 2026-05-04T01:30:00+09:00
evaluator_role: CPO
evaluator_persona: ".sfs-local/personas/cpo-evaluator.md"
evaluator_executor_round_1: "claude (cowork same instance, wizardly-quirky-gauss) — AI-PROPOSED Stage 1, self-val flag"
evaluator_executor_round_2: "codex (user-side cross-runtime cross-instance) — Round 1 PARTIAL + Round 2 PARTIAL + Round 3 PARTIAL + Round 4 PARTIAL → Round 5 pending (post Round 4 fix patch)"
evaluator_executor_round_3: "gemini (user-side cross-runtime cross-instance) — Round 1 PARTIAL Veto + Round 2 PASS + Round 3 PARTIAL Veto re-asserted + Round 4 PASS (G1 PASS LOCKED self-stamp) → Round 5 pending (post Round 4 fix patch)"
generator_executor: "claude (cowork affectionate-trusting-thompson session, plan.md authoring)"
self_validation_flag: true   # Stage 1 same-instance flag; Stage 2 (codex) + Stage 3 (gemini) cross-instance verify 로 resolution.
verdict_round_1_self: "AI-PROPOSED PASS-with-flags (8 review-grade flags for Stage 2/3 cross-instance)"
verdict_round_2_codex: "Round 1 PARTIAL → Round 2 PARTIAL → Round 3 PARTIAL → Round 4 PARTIAL → **Round 5 PASS** (회수 2026-05-04T01:25+09:00, quick verify) — Round 4 fix 5 items 모두 PASS (Q1/Q2/Q4/Q5/Q6), Q3 cosmetic skip 정합."
verdict_round_3_gemini: "Round 1 PARTIAL Veto → Round 2 PASS → Round 3 PARTIAL Veto re-asserted → Round 4 PASS → **Round 5 PASS (G1 PASS LOCKED final 2026-05-04T01:30+09:00 KST)** — Round 4 fix 5 items regression-free, 'prior Stage 3 PASS verdict stands firm'."
verdict_final: "**PASS LOCKED 2026-05-04T01:30+09:00 KST** (codex Round 5 PASS + gemini Round 5 PASS + 5 round cycle 완료 + 44 CTO fix items 통합 + 10+ CEO ruling locks). plan.md status=ready-for-implement 전환. G2 implement 진입 = next session user 명시 명령."
verdict_current: "✅ G1 PASS LOCKED — chain plan G1 review closure 완료, 본 세션 closing"
self_validation_resolution: "Stage 1 same-instance flag → Round 1~4 cross-instance cycle (Stage 2 codex + Stage 3 gemini parallel) + 44 CTO fix items + Round 5 둘 다 PASS quick verify 로 CLEARED."
related_review:
  spec_g1_review: "sprints/0-6-0-product-spec/review.md (Round 1~4, Codex final PASS LOCKED) — 본 G1 review 의 P-17 cross-instance 패턴 precedent"
  spec_g6_review: "sprints/0-6-0-product-spec/review-g6.md (Stage 1+2+3 + CEO ruling PASS LOCKED) — 본 G1 review 의 Stage 1 포맷 reference"
session: "claude-cowork:wizardly-quirky-gauss (Stage 1 authoring + Round 1 fix patch + Round 2 fix patch + Round 3 fix patch through 2026-05-04T00:40+09:00)"
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

### §6.2 Stage 3 — Gemini cross-runtime prompt (user host, **parallel mode**)

> ⚙️ **Mode change**: user 명시 "병렬로 할거라" (2026-05-03T23:20+09:00) → Stage 3 = Stage 2 와 동시 invoke (independent parallel run). Stage 3 가 Stage 2 verdict 를 input 으로 받지 않음. Third-eye veto 권한 유지.

```
You are CPO Evaluator (cross-runtime cross-instance verify, P-17 pattern, Stage 3 — parallel mode, independent third-runtime).

Read these 3 files in 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/:
- brainstorm.md (G0, 9/9 axes locked)
- plan.md (G1, status=ready-for-review, R-A~G + AC1~AC9 + Sprint Contract)
- review-g1.md (Stage 1 AI-PROPOSED PASS-with-flags, 8 flags F1~F8 + 1 minor F9)

Your task (independent of Stage 2 codex which runs in parallel):
1. Re-evaluate review-g1.md §3 (AC plan-quality / brainstorm→plan expansion / 6 철학 / cross-ref / anti-AC) independent of Stage 1 conclusion.
2. F1~F8 flag 별 independent verdict (PASS / PARTIAL with fix / FAIL with reason).
3. Stage 1 (claude same-instance) + 일반 second-runtime 가 모두 missed 할 angle 3+ 발본 (third-eye = CI/CD plumbing, security/secrets, supply-chain, doc-quality, i18n/a11y 등 cross-cutting).
4. Final verdict: PASS / PARTIAL / FAIL with reasoning ≤150 words.

Output format:
## §A Re-evaluation summary (≤200 words)
## §B Flag-by-flag verdict (F1~F8 + Stage 3 신규 S3-N1, S3-N2, S3-N3, ...)
## §C Final verdict + CTO action items

Constraints:
- 본 plan = code sprint G1. Focus = plan-quality + brainstorm carry 정합 + AC binary verify-by 명시도. Implement 산출물 부재 — actual AC1~AC9 evaluation 은 G6.
- Stage 3 parallel = Stage 2 codex verdict unaware. Third-eye veto 권한 유지 (Stage 1+2 PASS 여도 Stage 3 FAIL 가능).
- ≤15 단어 직접 인용 가드.
```

---

### §6.3 Stage 2 — Codex Round 2 prompt (user macOS terminal, parallel)

```
You are CPO Evaluator (cross-runtime cross-instance verify, P-17 pattern, Stage 2 — parallel mode, **Round 2**).

Round 1 status: Stage 1 PASS-with-flags / Stage 2 PARTIAL (8 F + 7 S2-N) / Stage 3 PARTIAL (third-eye veto, 8 F + 3 S3-N). CTO fix patch 16 items applied 2026-05-03T23:45+09:00.

Read these 3 files in 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/:
- brainstorm.md (G0, 9/9 axes locked, S2-N1 fix applied)
- plan.md (G1, status=ready-for-review-round-2, frontmatter round_1_fix_patch_applied + ceo_ruling_lock.S2_N3=α, ~440L)
- review-g1.md (Round 1 trace + §7.4.3 Consolidated Fix Patch + §7.4.4 Fix Applied)

Your task:
1. **Round 1 fix verification** — F1~F8 + S2-N1~N7 + S3-N1~N3 each 항목이 plan.md / brainstorm.md / AC sub-check 으로 정확히 통합되었나? PASS / PARTIAL (specify residual gap) / FAIL (specify regression).
2. **잔존 ambiguity 발본** — Round 1 fix 가 새로 도입한 wording 또는 신규 R-H / AC sub-check 가 binary verify 가능한가?
3. **신규 발본 (Round 2)** — Round 1 cycle 에서 missed 한 angle 3+ 추가.
4. Final verdict: PASS / PARTIAL / FAIL.

Output format:
## §A Round 1 Fix Verification (16 items, 항목별 PASS/PARTIAL/FAIL)
## §B 잔존 ambiguity (if any) + 신규 Round 2 발본 (S2R2-N1, N2, N3, ...)
## §C Final verdict + CTO action items

Constraints:
- Round 2 = parallel mode (Stage 3 gemini Round 2 도 동시 invoke).
- 본 plan = code sprint G1. Implement 산출물 부재 — actual AC1~AC9 evaluation 은 G6 review.
- ≤15 단어 직접 인용 가드.
```

### §6.4 Stage 3 — Gemini Round 2 prompt (user host, parallel third-eye)

```
You are CPO Evaluator (cross-runtime cross-instance verify, P-17 pattern, Stage 3 — parallel mode, **Round 2**, independent third-runtime).

Round 1 status: Stage 1 PASS-with-flags / Stage 2 PARTIAL / Stage 3 PARTIAL Veto (you, 직전 round). CTO fix patch 16 items applied 2026-05-03T23:45+09:00. CEO ruling lock = S2-N3 α (preserve `sfs 0.6.0`).

Read these 3 files in 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/:
- brainstorm.md / plan.md (status=ready-for-review-round-2) / review-g1.md (§7.4.4 fix applied trace)

Your task (independent of Stage 2 codex Round 2 which runs in parallel):
1. **Round 1 fix verification** — 직전 round 의 PARTIAL veto 가 해소됐나? 8 F flag (특히 F1/F3/F4/F5/F6/F7 PARTIAL 6 + F2/F8 PASS 2) + 3 S3-N (artifact audit / secret leak / atomic rollback) 의 fix 통합 verify.
2. **Third-eye Round 2** — Round 1 fix 가 새로 도입한 R-H migration safety + Windows parity + release discovery + log masking 가 supply-chain / security / atomic-safety 측면에서 충분한가?
3. **신규 third-eye 발본 (Round 2)** — Stage 1+2 Round 2 가 모두 missed 할 angle 3+ 발본 (e.g. CI/CD plumbing edge cases, security hardening, supply-chain, doc i18n/a11y).
4. Final verdict: PASS / PARTIAL / FAIL.

Output format:
## §A Round 1 Fix Verification + Veto Resolution (3 S3-N + 6 PARTIAL F flag)
## §B Third-eye Round 2 신규 발본 (S3R2-N1, N2, N3, ...)
## §C Final verdict + CTO action items

Constraints:
- Round 2 parallel = Stage 2 codex Round 2 verdict unaware.
- Third-eye veto 권한 유지 (Stage 1+2 Round 2 PASS 여도 Stage 3 FAIL 가능).
- ≤15 단어 직접 인용 가드.
```

---

### §6.5 Stage 2 — Codex Round 3 prompt (user macOS terminal, parallel)

```
You are CPO Evaluator (cross-runtime cross-instance verify, P-17 pattern, Stage 2 — parallel mode, **Round 3**).

Round trace:
- Round 1: Stage 1 PASS-with-flags / Stage 2 PARTIAL (8 F + 7 S2-N) / Stage 3 PARTIAL Veto (8 F + 3 S3-N)
- Round 2: Stage 2 PARTIAL (Round 1 fix verify 11 PASS / 6 PARTIAL + 6 신규 S2R2-N1~N6) / Stage 3 PASS (third-eye veto 해소, 3 advisory G2-time)
- Round 2 fix patch (12 items) applied 2026-05-04T00:10+09:00 with CEO ruling Q1=α (sfs 브랜드 preserve) + Q2=α (backup+prompt + --commit opt-in).

Read these 3 files in 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/:
- brainstorm.md (§6.7 backstamp 추가)
- plan.md (status=ready-for-review-round-3, frontmatter round_2_fix_patch_applied + ceo_ruling_lock Q1=α + Q2=α, ~470L)
- review-g1.md (§7.6.2 Round 2 verdict + §7.6.3 Fix Applied trace)

Your task:
1. **Round 2 fix verification (12 items)** — S2-N3/N4/N5/N7 + S3-N1/N2 wording polish + S2R2-N1~N6 신규 fix 가 정확히 통합되었나? 각 항목별 PASS/PARTIAL/FAIL.
2. **Stage 3 PASS 정합 verify** — Stage 3 가 PASS 준 angle (S3-N1/N2/N3 veto resolution + 6 PARTIAL F flag) 가 Round 2 fix 후 잔존 regression 없나?
3. **신규 발본 (Round 3)** — 직전 round 가 missed 한 angle 3+ 추가.
4. Final verdict: PASS / PARTIAL / FAIL.

Output format:
## §A Round 2 Fix Verification (12 items, 항목별 PASS/PARTIAL/FAIL) + Stage 3 PASS regression check
## §B 잔존 ambiguity + 신규 Round 3 발본 (S2R3-N1, N2, N3, ...)
## §C Final verdict + CTO action items

Constraints:
- Round 3 = parallel mode (Stage 3 gemini Round 3 도 동시 invoke).
- 본 plan = code sprint G1. Implement 산출물 부재 — actual AC1~AC9 evaluation 은 G6 review.
- ≤15 단어 직접 인용 가드.
```

### §6.6 Stage 3 — Gemini Round 3 prompt (user host, parallel third-eye)

```
You are CPO Evaluator (cross-runtime cross-instance verify, P-17 pattern, Stage 3 — parallel mode, **Round 3**, independent third-runtime).

Round trace:
- Round 1: Stage 3 PARTIAL Veto (3 S3-N).
- Round 2: Stage 3 **PASS** (you, 직전 round, third-eye veto 해소, 3 advisory G2-time).
- Round 2 fix patch (12 items) applied 2026-05-04T00:10+09:00 with CEO ruling Q1=α + Q2=α.

Read these 3 files in 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/:
- brainstorm.md / plan.md (status=ready-for-review-round-3) / review-g1.md (§7.6.3 fix applied)

Your task (independent of Stage 2 codex Round 3 which runs in parallel):
1. **Round 2 PASS regression verify** — 직전 round 가 PASS 준 plan 이 Round 2 fix 후 (12 items) 정합 유지하나? 3 advisory G2-time items (S3R2-N1 git tag sequencing / S3R2-N2 cross-platform hash parity / S3R2-N3 workflow permissions) 가 plan 안에 흡수돼야 하는지 vs G2 carry-forward 인지 재판정.
2. **Round 2 fix supply-chain/security audit** — sfs 브랜드 preserve / sentinel secret pattern / forced migrate commit safety / JSON contract / local bad-fixture script 가 supply-chain (release plumbing) + security (secret management) + data safety (consumer repo) 측면에서 충분한가?
3. **신규 third-eye 발본 (Round 3)** — Stage 1+2 Round 3 가 모두 missed 할 angle 3+ 발본.
4. Final verdict: PASS / PARTIAL / FAIL.

Output format:
## §A Round 2 PASS Regression Verify + 3 advisory G2-time items 재판정
## §B Round 3 신규 third-eye 발본 (S3R3-N1, N2, N3, ...)
## §C Final verdict + CTO action items

Constraints:
- Round 3 parallel = Stage 2 codex Round 3 verdict unaware.
- Third-eye veto 권한 유지 (직전 round PASS 여도 Round 3 FAIL 가능).
- ≤15 단어 직접 인용 가드.
```

### §6.7 Stage 2 — Codex Round 4 prompt (user macOS terminal, parallel)

```
You are CPO Evaluator (cross-runtime cross-instance verify, P-17 pattern, Stage 2 — parallel mode, **Round 4**).

Round trace:
- Round 1: Stage 1 PASS-with-flags / Stage 2 PARTIAL / Stage 3 PARTIAL Veto.
- Round 2: Stage 2 PARTIAL / Stage 3 PASS.
- Round 3: Stage 2 PARTIAL (7 PASS / 4 PARTIAL Round 2 fix + 5 신규 S2R3-N1~N5) / Stage 3 PARTIAL Veto re-asserted (Round 2 advisory promotion + 3 신규 S3R3-N1~N3 sentinel paradox / commit idempotence / snapshot ext filter).
- Round 3 fix patch (11 items) applied 2026-05-04T00:40+09:00. CEO ruling Q9 = `--commit-existing-dirty` flag 제거.

Read these 3 files in 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/:
- brainstorm.md / plan.md (status=ready-for-review-round-4, frontmatter round_3_fix_patch_applied, ~410L) / review-g1.md (§7.7.4 fix applied trace)

Your task:
1. **Round 3 fix verification (11 items)** — Tier 1 critical 4 + Tier 2 cleanup 7 각 항목별 PASS/PARTIAL/FAIL.
2. **Stage 3 PARTIAL Veto resolution verify** — Stage 3 의 3 신규 (sentinel paradox / commit idempotence / snapshot ext) + advisory promotion 4 items 가 plan 안에 정확 통합됐나?
3. **신규 발본 (Round 4)** — Round 1~3 cycle 가 모두 missed 한 angle 3+ 추가.
4. Final verdict: PASS / PARTIAL / FAIL.

Output format:
## §A Round 3 Fix Verification (11 items, 항목별 PASS/PARTIAL/FAIL) + Stage 3 Veto resolution check
## §B 잔존 ambiguity + 신규 Round 4 발본 (S2R4-N1, N2, N3, ...)
## §C Final verdict + CTO action items

Constraints:
- Round 4 = parallel mode (Stage 3 gemini Round 4 도 동시 invoke).
- 본 plan = code sprint G1. Implement 산출물 부재 — actual AC1~AC13 evaluation 은 G6 review.
- ≤15 단어 직접 인용 가드.
```

### §6.8 Stage 3 — Gemini Round 4 prompt (user host, parallel third-eye)

```
You are CPO Evaluator (cross-runtime cross-instance verify, P-17 pattern, Stage 3 — parallel mode, **Round 4**, independent third-runtime).

Round trace:
- Round 1: Stage 3 PARTIAL Veto (3 S3-N).
- Round 2: Stage 3 PASS (3 advisory G2-time).
- Round 3: Stage 3 PARTIAL Veto re-asserted (you, 직전 round — Round 2 advisory promotion 요구 + 3 신규 S3R3-N1 sentinel paradox / N2 commit idempotence / N3 snapshot ext filter).
- Round 3 fix patch (11 items) applied 2026-05-04T00:40+09:00 — Tier 1 critical (sentinel isolation + commit idempotence guard + snapshot ext filter + AC10 R-H + AC11/12/13 promotion) + Tier 2 cleanup.

Read these 3 files in 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/:
- brainstorm.md / plan.md (status=ready-for-review-round-4) / review-g1.md (§7.7.4 fix applied)

Your task (independent of Stage 2 codex Round 4 which runs in parallel):
1. **Round 3 Veto resolution verify** — 직전 round 의 3 신규 (S3R3-N1/N2/N3) + advisory promotion (S3R2-N1/N2/N3 → AC11/12/13) 가 plan 안에 정확 통합됐나? 각 항목별 PASS/PARTIAL/FAIL.
2. **Round 3 fix supply-chain/security audit** — sentinel isolation step / commit idempotence guard / snapshot ext filter / AC10 R-H + AC11/12/13 가 supply-chain (release plumbing) + security (secret management) + data safety (consumer repo) + cross-platform integrity 측면에서 충분한가?
3. **신규 third-eye 발본 (Round 4)** — Stage 1+2 Round 4 가 모두 missed 할 angle 3+ 발본 (last-mile risks).
4. Final verdict: PASS / PARTIAL / FAIL.

Output format:
## §A Round 3 Veto Resolution Verify (3 S3R3-N + advisory promotion) + supply-chain/security audit
## §B Round 4 신규 third-eye 발본 (S3R4-N1, N2, N3, ...)
## §C Final verdict + CTO action items

Constraints:
- Round 4 parallel = Stage 2 codex Round 4 verdict unaware.
- Third-eye veto 권한 유지 (직전 round PASS 여도 Round 4 FAIL 가능).
- ≤15 단어 직접 인용 가드.
```

### §6.9 Stage 2 — Codex Round 5 quick verify prompt (user macOS terminal, parallel)

```
You are CPO Evaluator (cross-runtime cross-instance verify, P-17 pattern, Stage 2 — parallel mode, **Round 5 quick verify**).

Round trace:
- Round 4: Stage 2 PARTIAL (3 PARTIAL Round 3 fix items + 6 신규 S2R4-N1~N6) / Stage 3 PASS (G1 PASS LOCKED self-stamp).
- Round 4 fix patch (5 items) applied 2026-05-04T01:15+09:00 — user 직접 항목별 판단 (codex blanket 거부, item별 review):
  - Q1 (S2R4-N1) Sprint Contract + §4 G1 self-check + AC8.3 update AC1~AC9 → AC1~AC13.
  - Q2 (S2R4-N2) R-D D-4(iv) wording α (value-only mask, env var name OK — public convention).
  - Q3 (S2R4-N3 cosmetic trace 410 vs 364L) **skip** + meta-rule 추가 (cosmetic 발본 제외).
  - Q4 (S2R4-N4) review-g1 frontmatter executor metadata Round 4 갱신.
  - Q5 (S2R4-N5) R-H.H-2 manifest schema 9 fields enum (AC10.2 정합).
  - Q6 (S2R4-N6) anti-AC10 skipped[] allowed non-loss exclusion 명시.

Read these 3 files in 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/:
- brainstorm.md / plan.md (status=ready-for-review-round-5, frontmatter round_4_fix_patch_applied) / review-g1.md (§7.8.5 fix applied trace)

Your task (quick verify focused):
1. **Round 4 fix verification (5 items, Q3 skip)** — 각 항목별 PASS/PARTIAL/FAIL.
2. Final verdict: PASS / PARTIAL / FAIL.

Output format:
## §A Round 4 Fix Verification (Q1/Q2/Q4/Q5/Q6 항목별 PASS/PARTIAL/FAIL)
## §B Final verdict + (PARTIAL 시) CTO action items

**META-RULE (user 명시 Round 4)**:
- **Cosmetic 발본 제외**: trace line count claims, frontmatter staleness, prose wording polish 등 **logic/contract/wording-conflict 와 무관한 cosmetic metadata drift** 는 본 review 발본 대상에서 **제외**. 본질 logic / contract scope / internal contradiction / binary verifiability 만 발본.
- AC scope 변경 시 Sprint Contract pass/fail criterion 자동 update 는 process default — 본 round 도 동일 적용.

Constraints:
- Round 5 = quick verify (Round 4 fix 정합만 focused, 신규 발본 최소화 — cosmetic 0).
- 본 plan = code sprint G1. Implement 산출물 부재 — actual AC1~AC13 evaluation 은 G6 review.
- ≤15 단어 직접 인용 가드.
```

### §6.10 Stage 3 — Gemini Round 5 quick verify prompt (user host, parallel)

```
You are CPO Evaluator (cross-runtime cross-instance verify, P-17 pattern, Stage 3 — parallel mode, **Round 5 quick verify**, third-eye).

Round trace:
- Round 4: Stage 3 PASS (G1 PASS LOCKED self-stamp 2026-05-04T00:50 KST, you).
- Round 4 fix patch (5 items) applied 2026-05-04T01:15+09:00 — user 직접 판단 (codex 의 PARTIAL 6 findings 중 5 채택 + 1 cosmetic skip + meta-rule).

Read these 3 files in 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/:
- brainstorm.md / plan.md (status=ready-for-review-round-5) / review-g1.md (§7.8.5 fix applied)

Your task (quick verify focused, third-eye regression check):
1. **Round 4 fix regression check** — 5 items 적용이 직전 Round 4 PASS verdict 의 안정성에 regression 야기하지 않았나? PASS 유지 가능?
2. Final verdict: PASS / PARTIAL / FAIL.

Output format:
## §A Round 4 Fix Regression Check (Q1/Q2/Q4/Q5/Q6 정합 확인)
## §B Final verdict + (PARTIAL 시) third-eye 발본

**META-RULE (user 명시 Round 4)**:
- **Cosmetic 발본 제외**: trace line count, frontmatter staleness, prose polish 등 cosmetic metadata drift 는 발본 대상 제외. logic/contract/security/data-safety 만 발본.
- AC scope 변경 시 Sprint Contract auto-update 는 process default.

Constraints:
- Round 5 parallel = Stage 2 codex Round 5 verdict unaware.
- Third-eye veto 권한 유지 (단 quick verify mode 이므로 신규 발본 minimal — Round 4 fix regression only).
- ≤15 단어 직접 인용 가드.
```

---

## §7.7 Round 3 Trace (parallel re-review)

### §7.7.1 Stage 3 Round 3 (gemini, parallel third-eye) — **PARTIAL (Veto re-asserted)**, 회수 2026-05-04T00:25+09:00

- mode: parallel third-eye Round 3 (Stage 2 codex Round 3 verdict unaware)
- evaluator: gemini (user host)
- prompt: §6.6 verbatim
- final verdict: **PARTIAL (Independent Stage 3 Veto)**

#### §7.7.1.A Round 2 PASS Regression Verify + 3 advisory items 재판정

verbatim: "Round 2 fix patch (12 items) successfully integrates ... without introducing regressions. supply-chain identity (sfs), explicit commit barriers, sentinel masking, and JSON matrix contracts significantly elevate the plan's rigor and data safety."

**Stance reversal on 3 advisory items**: "the 3 advisory items from my Round 2 PASS (S3R2-N1 Tag Sequencing, S3R2-N2 Hash Parity, S3R2-N3 Workflow Permissions) are **too critical to be left as 'worker discretion' (G2 carry-forward)**. Because they directly impact the CI/CD pipeline and cross-platform integrity, they **must be promoted to explicit binary AC sub-checks in the plan.**"

#### §7.7.1.B Round 3 신규 third-eye 발본 (3 items)

- **S3R3-N1 (Sentinel vs. Real Auth Conflict)** ⚠️ critical: AC4.4.4 proposes injecting dummy sentinel into `CODEX_API_KEY` to test masking. However, `test-sfs-cross-instance-verify.sh` requires real key to pass. Injecting dummy key will cause cross-instance test to fail with 401 error. **The masking test must be a separate, isolated step from actual verification run.**
- **S3R3-N2 (Upgrade Commit Idempotence)**: AC5.4 introduces `--commit` flag. If user runs `sfs upgrade --commit` a second time, behavior is unspecified. AC must explicitly state: if no changes (clean working tree after no-op migration), exit 0 without creating empty commit.
- **S3R3-N3 (Snapshot Disk Exhaustion Risk)**: R-H.H-2 mandates full snapshot (전수 snapshot) before migration. If legacy directories contain un-ignored dependencies or binaries, this could cause disk exhaustion. **Snapshot must strictly filter for valid SFS artifact extensions** (e.g., `.md`, `.yml`, `.jsonl`).

#### §7.7.1.C Final verdict (Stage 3 Round 3)

> "**Final Verdict: PARTIAL (Independent Stage 3 Veto)**. The plan is exceptionally strong and near completion, but S3R3-N1 represents a logical paradox in the test harness design that will cause CI failures. The advisory items from Round 2 also require formal codification."

CTO Action Items (4 items):
1. **S3R3-N1**: Redesign sentinel test to avoid breaking actual cross-instance auth validation (separate isolated masking step).
2. **S3R3-N2**: Add idempotence guard for `--commit` to prevent empty commits on repeat runs (clean working tree → exit 0).
3. **S3R3-N3**: Constrain pre-migrate snapshot to target only valid SFS artifact extensions (`.md`, `.yml`, `.jsonl` 등).
4. **Promotion**: Convert S3R2-N1/N2/N3 (Round 2 advisory) into formal AC sub-checks within `plan.md` (git tag sequencing / cross-platform hash parity / workflow permissions hardening).

### §7.7.2 Stage 2 Round 3 (codex, parallel) — **PARTIAL**, 회수 2026-05-04T00:30+09:00

- mode: parallel Round 3 (Stage 3 gemini Round 3 verdict unaware)
- evaluator: codex (user macOS terminal)
- prompt: §6.5 verbatim
- final verdict: **PARTIAL** (substantive Round 2 patch strong, "another quick CTO cleanup, but not yet a clean G2 handoff")

#### §7.7.2.A Round 2 Fix Verification (12 items)

| item | codex Round 3 verdict | residual |
|---|---|---|
| S2-N3 / S2R2-N2 brainstorm backstamp | **PASS** | §6.7 superseded marker + sfs 0.6.0 lock 정합 |
| S2-N4 / S2R2-N1 package identity | **PASS** | sfs 브랜드 preserve (Formula/sfs.rb + bucket/sfs.json + cmd sfs + brew audit --new-formula sfs) |
| S2-N5 anti-AC + manifest schema | **PARTIAL** | R-H + anti-AC summary 는 anti-AC10, **plan §5 (Sprint Contract) 에 anti-AC8 R-H live 잔존** |
| S2-N7 structured CLI questions | **PASS** | AC3.4 Q-A~Q-F + smoke test-sfs-pass1-prompts.sh binary grep |
| S3-N1 artifact audit wording | **PASS-with-minor-note** | AC7.4/7.5 path/command specific. Minor: "또는 신규 path" weakens exactness |
| S3-N2 sentinel secret masking | **PARTIAL** | sentinel example suffix `xxxxxxxx` (8 placeholder) vs text claim "16-hex random" mismatch — concrete regex `[0-9a-f]{16}` capture contract 필요 |
| S2R2-N3 forced migrate commit safety | **PARTIAL** | backup+no-auto-commit+--commit opt-in 정합. **Residual: error text 의 `--commit-existing-dirty` flag 가 정의/test 없이 등장** |
| S2R2-N4 `--print-matrix` JSON contract | **PASS** | 6 fields + action enum 정합 |
| S2R2-N5 local bad-fixture script | **PASS** | local + workflow 동일 script call 정합 |
| S2R2-N6 review metadata refresh | **PARTIAL** | frontmatter + Round 3 prompts 갱신 ✓. **§8 Next Steps still old §6.1/§6.2 sequential flow + plan.md footer 'ready-for-review-round-2' 잔존** |

→ 7 PASS / 3 PARTIAL (S2-N5 / S3-N2 / S2R2-N3 / S2R2-N6 — actually 4 PARTIAL).

**Stage 3 PASS Regression Check (Stage 2 view)**: "mostly clean, with two regressions/metadata leaks. S3-N1 + S3-N3 remain resolved. S3-N2 regressed slightly through inconsistent sentinel pattern. Six Stage 3 partial flags from Round 1 remain resolved. Stage 3's three Round 2 advisory items remain G2 carry-forward, but they should be copied into CTO implementation checklist so they are not lost."

#### §7.7.2.B 잔존 ambiguity + 신규 Round 3 발본 (S2R3-N1~N5)

- **S2R3-N1 (live footer/status drift)**: frontmatter says Round 3, but plan footer + review §8 still describe Round 2/sequential next steps.
- **S2R3-N2 (prompt file-count drift)**: prompts say "4 files" but directory contains only three named files.
- **S2R3-N3 (trace density drift)**: trace claims plan grew to ~470 lines, **actual `plan.md` is 339 lines**. Content exists, but provenance/count claims stale.
- **S2R3-N4 (Stage 3 advisory carry-forward risk)**: git tag sequencing / hash parity / workflow permissions live only in review trace, not plan's CTO contract.
- **S2R3-N5 (JSON null semantics missing)**: `--print-matrix` does not define `sha256_after` behavior for `delete` / `skip` / missing dest cases.

#### §7.7.2.C Final verdict (Stage 2 Round 3)

> "**Final verdict: PARTIAL**. The substantive Round 2 patch is strong enough for another quick CTO cleanup, but not yet a clean G2 handoff."

CTO Action Items (codex, 6 items):
1. Replace remaining `anti-AC8 R-H` live reference with `anti-AC10` (plan §5).
2. Fix §8 Next Steps and `plan.md` footer to Round 3 parallel flow.
3. Define sentinel format as captured actual values matching `[0-9a-f]{16}`.
4. Remove or fully specify `--commit-existing-dirty`.
5. Add Stage 3 advisory items to G2 implementation checklist.
6. Clarify prompt/file count: three files, or name the fourth.

---

### §7.7.3 Round 3 Post-hoc Consensus / Divergence Analysis

> Stage 2 PARTIAL + Stage 3 PARTIAL Veto re-asserted → **Round 4 cycle 필요** (spec sprint Round 1~4 cycle precedent 정합).

#### §7.7.3.A 합의 (Stage 2 + Stage 3 둘 다 발본)

- **S3R2-N1/N2/N3 promotion** (Round 2 advisory → formal AC sub-check): Stage 3 Round 3 명시 "must be promoted to explicit binary AC sub-checks" + Stage 2 Round 3 명시 "should be copied into CTO implementation checklist so they are not lost" / "S2R3-N4 Stage 3 advisory carry-forward risk: git tag sequencing/hash parity/workflow permissions live only in review trace, not plan's CTO contract". → **CONSENSUS PROMOTE TO AC**.

#### §7.7.3.B Divergence (한 stage 만 발본)

- **Stage 3-only**: S3R3-N1 Sentinel paradox / S3R3-N2 Commit idempotence / S3R3-N3 Snapshot extension filter — Stage 2 missed.
- **Stage 2-only**: S2-N5 plan §5 anti-AC8 잔존 / S3-N2 sentinel `[0-9a-f]{16}` 정확 / S2R2-N3 `--commit-existing-dirty` 미정의 / S2R2-N6 §8 Next Steps + plan footer 잔존 / S2R3-N1 footer drift / S2R3-N2 prompt 4 vs 3 file count / S2R3-N3 trace density 470 vs 339 / S2R3-N5 JSON null semantics — Stage 3 missed (대부분 wording/metadata 정밀).

#### §7.7.3.C Consolidated Round 3 CTO Fix Patch List (11 items)

**Tier 1 — Critical AC promotion + design flaw (4 items)**:
1. **S3R3-N1** Sentinel test isolation — AC4.4.4 + AC4.6 reword: 본 sentinel masking test 가 **isolated step** (real-auth 와 분리 — `tests/test-sfs-log-masking.sh` 별 fixture, real `CODEX_API_KEY` env unset 후 sentinel inject + log mask verify). AC4.4 cross-instance verify 가 real-key 로 진행, AC4.4.4 mask test 가 별 step.
2. **S3R3-N2** `--commit` idempotence guard — AC5.4 sub-bullet 추가: 재실행 시 clean working tree (after no-op migration) → exit 0 + empty commit 생성 X. negative test = `sfs upgrade --commit` 두 번 연속 실행 → second run exit 0 + git log -1 not changed.
3. **S3R3-N3** Snapshot extension filter — R-H.H-2 reword: `전수 snapshot` 이 SFS artifact extensions (`*.md` / `*.yml` / `*.yaml` / `*.jsonl` / `*.json` / `*.txt` / `*.sh` / `*.ps1` / `*.cmd`) 만 capture (default), unknown ext (`*.bin` / `*.exe` / `*.zip` / `*.tar.gz` 등) skip with warning. `--snapshot-include-all` flag 만 unrestricted.
4. **S3R2-N1/N2/N3 promotion to AC** (consensus): plan §2 에 신규 AC 추가 — AC11 (release sequence: git tag push → brew audit → manifest update 순서) + AC12 (cross-platform hash parity: Windows sfs.ps1 SHA256 = POSIX sha256sum, LF normalization for .yml/.md) + AC13 (workflow permissions hardening: `.github/workflows/sfs-pr-check.yml` permissions block `contents: read`).

**Tier 2 — Wording / metadata cleanup (7 items)**:
5. plan §5 잔존 `anti-AC8 R-H` → `anti-AC10` (S2-N5 잔존, codex 1).
6. plan footer `ready-for-review-round-2` → `ready-for-review-round-3` (S2R2-N6 + S2R3-N1).
7. review-g1.md §8 Next Steps Round 3 parallel flow 갱신 (S2R2-N6 + S2R3-N1).
8. AC4.4.4 sentinel pattern 정확 정의 — `SFS_TEST_SENTINEL_dummy_codex_[0-9a-f]{16}` regex contract 명시 (S3-N2 + codex 3).
9. AC5.4 `--commit-existing-dirty` flag 제거 (단순 wording 권장 = `--commit` 으로 통합) OR 정식 정의 + test 추가 (S2R2-N3 + codex 4).
10. review-g1.md §6.5 + §6.6 prompts "4 files" → "3 files" (brainstorm.md / plan.md / review-g1.md 3 file, S2R3-N2 + codex 6).
11. review-g1.md §7.6.3 trace "~470L" → "~340L" 정정 (S2R3-N3 + codex implicit). + R-H.H-1 JSON contract `sha256_after` null semantics 명시 (action=delete/skip → null, action=archive → captured at archive snapshot, S2R3-N5).

### §7.7.4 Round 3 CTO Fix Patch Applied — 2026-05-04T00:40+09:00

- session: claude-cowork:wizardly-quirky-gauss (continuation)
- CEO ruling locks (Round 3): user "a" 선택 + Q9 default = `--commit-existing-dirty` flag 제거 (단일 `--commit` 통합).
- 11 items 적용 결과:
  - **plan.md** Round 3 fix:
    - **Tier 1 — Critical (4 items)**:
      1. **S3R3-N1 Sentinel test isolation** — AC4.4.4 + AC4.6 reword: 별 isolated CI step `tests/test-sfs-log-masking.sh` (real-auth verify 와 분리), real `CODEX_API_KEY`/`GEMINI_API_KEY` env unset 후 sentinel inject + log mask verify. AC4.4 cross-instance verify 가 별 step에서 real-key 사용 — logical paradox 해소.
      2. **S3R3-N2 Commit idempotence** — AC5.4.1 신규 sub-bullet 추가: `sfs upgrade --commit` 재실행 시 clean working tree → exit 0 + empty commit 생성 X. negative test: 두 번 연속 실행 → second run exit 0 + git rev-parse HEAD 동일.
      3. **S3R3-N3 Snapshot extension filter** — R-H.H-2 reword: default 캡처 대상 11 SFS artifact ext (`.md/.yml/.yaml/.jsonl/.json/.txt/.sh/.ps1/.cmd/.py/.toml`). unknown ext (`*.bin`/`*.exe`/`node_modules/`/`.venv/` 등) skip with warning + `manifest.json.skipped[]` 기록. `--snapshot-include-all` flag 만 unrestricted.
      4. **AC10 R-H promotion + AC11/12/13 promotion (S3R2-N1/N2/N3 consensus)**:
         - **AC10 (R-H Migration Source Matrix + Data Safety)** 5 sub-checks (10.1 JSON Lines schema 6 fields + null semantics / 10.2 backup manifest schema 9 fields / 10.3 ext filter / 10.4 rollback / 10.5 interrupted-midway). anti-AC10 (no-data-loss) tied to AC10.
         - **AC11 (Release Sequence)**: `git tag` push → brew audit + scoop schema check → tap update push 순서 enforce.
         - **AC12 (Cross-Platform Hash Parity)**: Windows sfs.ps1 SHA256 ≡ POSIX sha256sum + `.gitattributes` LF normalization for `.yml/.yaml/.md/.jsonl/.json/.toml/.txt`.
         - **AC13 (Workflow Permissions Hardening)**: `.github/workflows/*.yml` 모두 explicit `permissions: contents: read` minimum block.
         - 신규 R-I (Release Plumbing Safety) §1 추가 — I-1/I-2/I-3 = AC11/12/13 link.
    - **Tier 2 — Cleanup (7 items)**:
      5. plan §5 잔존 `anti-AC8 R-H` → `anti-AC10 R-H` (S2-N5 잔존).
      6. plan footer `ready-for-review-round-2` → `ready-for-review-round-4` (status), 본문 `Round 2 진입 조건` → `Round 4 진입 조건`, `다음 1 step Round 2 invoke` → `Round 4 invoke` (S2R2-N6 + S2R3-N1).
      7. (review-g1.md §8 Next Steps Round 4 parallel flow 갱신 — 별 Edit 에서)
      8. AC4.4.4 sentinel pattern `[0-9a-f]{16}` 정확 regex contract — `^SFS_TEST_SENTINEL_dummy_(codex|gemini)_[0-9a-f]{16}$` capture, runtime generate via `openssl rand -hex 8` (S3-N2 + codex 3).
      9. AC5.4 `--commit-existing-dirty` flag 제거 — error message 단순화 ("Working tree dirty. Stash or commit before forced migrate.") + 단일 `--commit` 통합 (S2R2-N3 + codex 4).
      10. review-g1.md §6.3/§6.4/§6.5/§6.6 prompts "Read these 4 files" → "Read these 3 files" (4 occurrence replace_all, S2R3-N2 + codex 6).
      11. R-H.H-1 JSON contract null semantics 명시 (action=delete/skip → null, archive → snapshot sha256, migrate → post-migrate dest sha256, S2R3-N5) + 본 §7.6.3 trace "~470L" → "~340L" 정정 (S2R3-N3).
  - **plan.md frontmatter**: `last_touched_at` 2026-05-04T00:40+09:00 / `status: ready-for-review-round-4` / `round_3_fix_patch_applied` 추가.
- 결과 plan.md 변화: ~340L → ~410L (AC10/11/12/13 + R-I 추가). AC sub-check 58 + 4 anti-AC → ~75 sub-check + 4 anti-AC.
- 다음 1 step = user host 에서 Round 4 parallel re-review (codex + gemini 동시 invoke, §6.7 + §6.8 prompt verbatim).

---

## §7.8 Round 4 Trace (parallel re-review)

### §7.8.1 Stage 2 Round 4 (codex, parallel) — **PARTIAL**, 회수 2026-05-04T01:00+09:00

- mode: parallel Round 4 (Stage 3 gemini Round 4 verdict unaware)
- evaluator: codex (user macOS terminal)
- prompt: §6.7 verbatim
- final verdict: **PARTIAL** — "hard design fixes landed, but new AC10~AC13 layer not fully connected to evaluator contract, and two live wording conflicts can still cause false review failures"

#### §7.8.1.A Round 3 Fix Verification (11 items)

**Tier 1 critical 4**:
| item | codex Round 4 verdict | residual |
|---|---|---|
| S3R3-N1 sentinel isolation | **PARTIAL** | AC4.4.4/AC4.6 isolate masking from real auth ✓. **Residual: R-D wording (env var names must NOT appear) conflicts with AC4.4.4 (names OK, values masked)** |
| S3R3-N2 commit idempotence | **PASS** | AC5.4.1 정합 |
| S3R3-N3 snapshot extension filter | **PASS** | R-H.H-2 + AC10.3 정합 |
| AC10/11/12/13 promotion | **PARTIAL** | AC10~13 + R-I 추가 ✓. **Residual: Sprint Contract + §4 G1 self-check still says AC1~AC9 evaluator scope** |

**Tier 2 cleanup 7**:
5. anti-AC8 → anti-AC10 plan §5: **PASS**
6. plan footer/status drift: **PARTIAL** — footer Round 4 ✓ but §4 still `ready-for-review-round-3 → ready-for-implement`
7. §8 Next Steps Round 4: **PASS**
8. sentinel regex `[0-9a-f]{16}` + openssl rand: **PASS**
9. `--commit-existing-dirty` 제거: **PASS**
10. prompt "4 files" → "3 files": **PASS**
11. JSON null semantics + trace 470→340: **PASS**

→ 8 PASS / 3 PARTIAL (S3R3-N1 R-D wording conflict / AC10-13 contract 미연동 / §4 footer status).

**Stage 3 Veto Resolution**:
- Sentinel paradox: PARTIAL (R-D vs AC4 wording conflict)
- Commit idempotence: PASS
- Snapshot extension filter: PASS
- Advisory promotion: PARTIAL (AC11~13 added but pass/fail contract stale)

#### §7.8.1.B 잔존 ambiguity + 신규 Round 4 발본 (S2R4-N1~N6)

- **S2R4-N1 (Sprint Contract AC scope stale)**: Sprint Contract §5 validates only AC1~AC9; AC10~AC13 can be skipped by contract. 새 AC들이 contract 안 wired.
- **S2R4-N2 (R-D log masking wording conflict)**: R-D 의 "log masking ensures env var names not appear" wording vs AC4.4.4/AC4.6 의 "names OK, sentinel values masked" 충돌.
- **S2R4-N3 (file count drift again)**: prompt/trace says plan ~410L, actual `plan.md` is 364L. 46L off.
- **S2R4-N4 (review-g1 frontmatter executor metadata stale)**: `evaluator_executor_round_2/3` field 가 still "Round 3 pending" wording 잔존.
- **S2R4-N5 (manifest schema mismatch)**: R-H.H-2 manifest schema enumerates fewer fields than AC10.2's 9 required (snapshot_id/created_at/source_repo_root/source_sha/files/total_count/total_bytes/skipped/extension_filter_applied).
- **S2R4-N6 (anti-AC10 skipped[] handling)**: anti-AC10 should explicitly treat `skipped[]` as allowed non-loss exclusion; currently only `archive` action 명시 mark.

#### §7.8.1.C Final verdict (Stage 2 Round 4)

> "**PARTIAL**. The hard design fixes landed, but the new AC10~AC13 layer is not fully connected to the evaluator contract, and two live wording conflicts can still cause false review failures."

CTO Action Items (codex, 6 items):
1. Update Sprint Contract + G1 self-check to AC1~AC13.
2. Align R-D masking text with sentinel-value masking (AC4.4.4 정합).
3. Fix §4 status transition to Round 4.
4. Refresh review-g1 frontmatter Round 4 metadata.
5. Normalize manifest schema wording between R-H.H-2 and AC10.2.
6. Clarify anti-AC10 handling for `skipped[]` (allowed non-loss exclusion).

### §7.8.2 Stage 3 Round 4 (gemini, parallel third-eye) — **PASS (G1 PASS LOCKED)**, 회수 2026-05-04T01:05+09:00 (gemini self-stamp 00:50 KST)

- mode: parallel third-eye Round 4 (Stage 2 codex Round 4 verdict unaware)
- evaluator: gemini (user host)
- prompt: §6.8 verbatim
- final verdict: **PASS** ("G1 PASS LOCKED 2026-05-04T00:50 KST")

#### §7.8.2.A Round 3 Veto Resolution Verify

verbatim:
- **S3R3-N1 (Sentinel Isolation)**: PASS. AC4.4.4 + AC4.6 explicitly separate dummy masking test (`tests/test-sfs-log-masking.sh`) from real-auth cross-instance verification. **Logical paradox resolved**.
- **S3R3-N2 (Commit Idempotence)**: PASS. AC5.4.1 strictly mandates exit 0 + no empty commit if working tree clean after repeat migration.
- **S3R3-N3 (Snapshot Ext Filter)**: PASS. H-2 + AC10.3 define default capture list of 11 SFS artifact extensions.
- **Advisory Promotion (S3R2-N1/N2/N3 → AC11/12/13)**: PASS. Tag sequence + Hash parity + Permissions formally codified, linked to R-I.
- **Supply-Chain/Security Audit**: "0.6.0 release pipeline is now significantly more resilient. Mandatory LF normalization (AC12), explicit workflow permissions (AC13), and atomic tag-audit-push sequence (AC11) provide necessary last-mile hardening for production-grade CLI."

#### §7.8.2.B Round 4 신규 third-eye (S3R4-N1~N3, advisory G2-time)

> Stage 3 자체 명시: "advisory for G2 implementation worker, **do not require further plan-stage revisions**".

- **S3R4-N1 (Nested Git Safety)**: R-H migration moves legacy sprint files. If user has nested `.git` dir or submodule within legacy sprint folder, simple `mv` might break git index or cause data loss. **Action (G2)**: Add safety check in migration script to skip or explicitly handle directories containing nested `.git` anchors.
- **S3R4-N2 (Homebrew Formula Renaming Alias)**: Q1=α preserves `sfs` name. If existing tap repo uses different internal ruby class name (e.g., `SfsProduct`), renaming to `Sfs` might cause Homebrew to fail upgrade. **Action (G2)**: Use `alias` or `deprecated_option` in `sfs.rb` if necessary to ensure smooth migration.
- **S3R4-N3 (GHA Windows Shell Parity)**: AC4.5 Windows smoke runs on Windows runner. GitHub Actions default to `pwsh` on Windows. **Action (G2)**: Explicitly set `shell: bash` for all cross-platform script steps in `.github/workflows/sfs-0-6-storage.yml` to ensure POSIX-style behavior.

#### §7.8.2.C Final verdict (Stage 3 Round 4)

> "**Final Verdict: PASS**. The G1 Plan is now **PASS LOCKED**. The Round 3 patch has neutralized all logical and technical blockers. The plan is exceptionally dense and binary-ready for implementation. The S3R4 findings are advisory for the G2 implementation worker and do not require further plan-stage revisions. ... Proceed to G2 Implement. (G1 PASS LOCKED 2026-05-04T00:50 KST)"

CTO Action Items (G2 Implement carry-forward, plan-stage revisions 불필요):
1. Safety: Handle nested `.git` directories in migration logic to prevent index corruption.
2. Compatibility: Ensure Homebrew formula handles name transition gracefully via aliases if class names change.
3. Shell Parity: Set explicit `shell: bash` in CI for Windows runner consistency.

---

### §7.8.3 Round 4 Post-hoc Consensus / Divergence Analysis

> Round 4 divergence (Round 2 와 동일 패턴): **Stage 3 PASS** ("PASS LOCKED") vs **Stage 2 PARTIAL** (6 cleanup items). Stage 3 = "all blockers neutralized, advisory only", Stage 2 = "wording conflicts + Sprint Contract gap could cause false review failure".

#### §7.8.3.A Stage 2 PARTIAL findings 영향도 분석

| codex finding | 영향도 | type |
|---|---|---|
| **S2R4-N1 Sprint Contract AC scope stale** (AC10~13 skip risk) | **HIGH (G6 review correctness)** | review-contract blocker |
| **S2R4-N2 R-D ↔ AC4.4.4/AC4.6 wording conflict** | **HIGH (false review failure 위험)** | internal contradiction |
| S2R4-N3 plan trace 410L claim vs 364L actual | LOW (cosmetic) | metadata drift |
| S2R4-N4 review-g1 frontmatter executor metadata stale | LOW (cosmetic) | metadata drift |
| S2R4-N5 R-H.H-2 vs AC10.2 manifest field count mismatch | MEDIUM (wording precision) | spec consistency |
| S2R4-N6 anti-AC10 skipped[] handling 미명시 | MEDIUM (wording precision) | anti-AC clarity |

→ HIGH 2 (real review contract blocker) / MEDIUM 2 (wording) / LOW 2 (cosmetic).

#### §7.8.3.B Path 분기

**(a) Round 5 cycle — Stage 2 6 fixes 적용 → re-review**:
- 장점: Stage 2 + Stage 3 둘 다 PASS 수렴, contract 완결.
- 단점: spec sprint Round 1~4 precedent 초과, 시간 추가.
- 적용 범위: HIGH 2 (Sprint Contract + R-D wording) + MEDIUM 2 (manifest field count + skipped[]) + LOW 2 (trace + frontmatter).

**(b) Stage 3 PASS LOCK 채택 + Stage 2 findings G2 carry-forward**:
- 장점: G1 review 즉시 closure, G2 entry 가능.
- 단점: HIGH 2 가 G6 review 시점에 실 review-contract failure 유발 가능 (Sprint Contract 가 AC10-13 skip → AC10 R-H + AC11/12/13 무시).
- Risk mitigation: G2 entry 직전 user 가 Sprint Contract + R-D wording 만 manual fix.

**(c) Hybrid — HIGH 2 만 즉시 fix + MEDIUM/LOW 4 G2 carry-forward**:
- 장점: review contract 안전성 보장 + minimal cleanup (Option β default 정합).
- 단점: Round 5 partial cycle (HIGH 2 fix verify only).
- HIGH 2 = (1) Sprint Contract §5 + §4 G1 self-check 갱신 AC1~AC13, (2) R-D log masking wording reword AC4.4.4/AC4.6 정합.

→ **권장 (c) Hybrid** (Option β + safety + closure).

### §7.8.4 Final lock — pending CEO ruling on path

### §7.8.5 Round 4 CTO Fix Patch Applied — 2026-05-04T01:15+09:00 (user 직접 판단)

- session: claude-cowork:wizardly-quirky-gauss (continuation)
- CEO ruling locks (Round 4): user 직접 항목별 판단 (codex blanket 추천 거부) — Q1 진행 + 추가 meta-rule (다른 세션 + 다른 작업도 AC scope 변경 시 Sprint Contract 자동 update default) / Q2=α (value-only mask, env var name 노출 OK는 standard public convention) / Q3 skip (cosmetic 발본 제외 meta-rule 향후 prompt 에 추가) / Q4 진행 / Q5 승인 / Q6 승인.
- 5 items 적용 결과:
  - **Q1 (S2R4-N1) Sprint Contract + §4 G1 self-check + AC8.3 update**: AC scope `AC1~AC9` → `AC1~AC13` 전 instance 갱신.
    - §5 통과 기준: "AC1~AC13 모두 PASS (AC8 6 sub-check + AC10 5 sub-check + anti-AC10 + AC11/12/13 R-I 정합)"
    - §5 fail 기준: "AC1~AC7 + AC9 + AC10~AC13 중 하나라도 fail"
    - §4 self-check: "AC1~AC7 + AC9 + AC10~AC13 deterministic + AC8 review_high"
    - §4 sub-check count: 58 → ~66 sub-check
    - AC8.3 TDD-no-overtake: "AC1~AC9" → "AC1~AC13"
  - **Q2 (S2R4-N2) R-D D-4(iv) wording α**: "value-only mask. env var name (CODEX_API_KEY / GEMINI_API_KEY) 노출 OK (public convention, .github/workflows/*.yml 이미 visible). sentinel value (16-hex random suffix) 만 mask" — AC4.4.4/AC4.6 정합 + R-D internal contradiction 해소. (frontmatter `ceo_ruling_lock.Q2_S2R4_N2_log_masking_scope: α` 추가)
  - **Q4 (S2R4-N4) review-g1.md frontmatter executor metadata refresh**: `evaluator_executor_round_2/3` field — Round 1~4 trace + Round 5 pending wording 갱신.
  - **Q5 (S2R4-N5) R-H.H-2 manifest schema 9 fields enum**: `manifest.json = {snapshot_id, created_at, source_repo_root, source_sha, files[], total_count, total_bytes, skipped[], extension_filter_applied}` — AC10.2 정합. files[] schema + skipped[] schema (`{path, reason, ext}`) + extension_filter_applied bool 명시.
  - **Q6 (S2R4-N6) anti-AC10 `skipped[]` allowed non-loss exclusion 명시**: anti-AC10 wording reword — "마이그레이션 전후 file mismatch 0 except (i) `archive` action 명시 mark, (ii) manifest `skipped[]` 명시 file. 둘 다 아닌 file mismatch = 분실 = fail" — 두 곳 동기 (R-H.H-4 + plan §2 anti-AC summary).
- **Skip Q3** (S2R4-N3 cosmetic trace 410 vs 364L): 본 round 미수정. 향후 prompt 에 cosmetic 발본 제외 meta-rule 추가 (§6.9/§6.10 Round 5 prompts 에 명시).
- **Meta-rule 신규 (process improvement, P-18 후보)**: AC scope 변경 시 Sprint Contract pass/fail criterion + §4 self-check 자동 update 가 default rule. user 명시: "이번 세션뿐 아니라 다른 세션 + 다른 작업에서도 당연히 추가돼야". G7 retro 시점에 learning pattern P-18 으로 기록 + CLAUDE.md §1.x lift up 후보.
- 결과 plan.md 변화: ~364L → ~378L (Q1 expansion + Q5 manifest schema 추가 + Q2 R-D wording reword). frontmatter `round_4_fix_patch_applied` + `Q9_S2R2_N3_commit_existing_dirty: 제거` + `Q2_S2R4_N2_log_masking_scope: α` 추가.
- 다음 1 step = user host Round 5 parallel quick verify (codex + gemini, §6.9 + §6.10 prompt verbatim).

---

## §7.9 Round 5 Quick Verify Trace

### §7.9.1 Stage 2 Round 5 (codex, parallel quick verify) — **PASS**, 회수 2026-05-04T01:25+09:00

- mode: parallel quick verify (Round 4 fix focused, cosmetic 발본 제외 meta-rule)
- evaluator: codex (user macOS terminal)
- prompt: §6.9 verbatim
- final verdict: **PASS**

#### §7.9.1.A Round 4 Fix Verification (5 items)

| Item | Verdict | 확인 |
|---|---|---|
| Q1 — AC scope update | **PASS** | plan.md §4, §5, AC8.3, recap all now use AC1~AC13. Pass/fail contract includes AC10~13. |
| Q2 — log masking scope | **PASS** | R-D D-4(iv), AC4.4.4, AC4.6 align: env var names OK, sentinel values masked. |
| Q4 — review-g1 executor metadata | **PASS** | frontmatter executor fields now include Round 4 results + Round 5 pending. |
| Q5 — manifest 9 fields | **PASS** | R-H.H-2 matches AC10.2 with 9 required fields + `files[]`, `skipped[]`, filter bool detail. |
| Q6 — anti-AC10 skipped[] exclusion | **PASS** | R-H.H-4, AC10 anti-AC, anti-AC summary all treat `skipped[]` as allowed non-loss exclusion. |

Q3 explicitly skipped as cosmetic, not evaluated (meta-rule 정합).

#### §7.9.1.B Final verdict (Stage 2 Round 5)

> "**PASS**. Round 4 fix patch is correctly integrated for the focused Round 5 scope. G1 can be treated as plan-review PASS from Stage 2 quick verify, with actual AC1~AC13 implementation evaluation deferred to G6 as specified."

### §7.9.2 Stage 3 Round 5 (gemini, parallel third-eye quick verify) — **PASS (G1 PASS LOCKED)**, 회수 2026-05-04T01:30+09:00

- mode: parallel third-eye quick verify (Stage 2 codex Round 5 verdict unaware)
- evaluator: gemini (user host)
- prompt: §6.10 verbatim
- final verdict: **PASS** ("G1 PASS LOCKED" — Stage 3 자체 명시)

#### §7.9.2.A Round 4 Fix Regression Check (5 items 정합)

verbatim:
- **Q1 Sprint Contract AC scope**: "AC1~AC13 expansion in Sprint Contract §5, self-check §4, TDD AC8.3 successfully binds newly promoted ACs to formal evaluation contract." ✓
- **Q2 R-D log masking**: "Modifying text to explicitly permit env var names while strictly masking sentinel values completely resolves internal contradiction with AC4.4.4." ✓
- **Q4 Executor metadata**: "Frontmatter executor states in review-g1.md appropriately updated to reflect Round 4 completion + Round 5 status." ✓
- **Q5 Manifest schema enum**: "R-H.H-2 now rigorously enumerates 9 required schema fields alongside files[] + skipped[] array structures, achieving perfect alignment with AC10.2." ✓
- **Q6 anti-AC10 skipped[]**: "Explicitly establishing skipped[] files as allowed non-loss exclusion in both R-H.H-4 and anti-AC10 prevents false data-loss review failures." ✓

> "These targeted refinements resolve Stage 2 blockers while maintaining integrity, architectural safety, and binary testability that earned the Round 4 Stage 3 PASS."

#### §7.9.2.B Final verdict (Stage 3 Round 5)

> "**Final verdict: PASS**. The Round 4 fixes successfully closed the remaining review-contract gaps and wording conflicts. ... The prior Stage 3 PASS verdict stands firm. **The G1 Plan is fully validated and ready for execution. (G1 PASS LOCKED)**"

---

## §7.10 G1 Review FINAL LOCK — 2026-05-04T01:30+09:00

✅ **Round 5 둘 다 PASS** (codex Round 5 PASS @ 01:25 + gemini Round 5 PASS @ 01:30, "G1 PASS LOCKED" 둘 다 명시).

### §7.10.1 Round 1~5 Cycle Summary

| Round | Stage 2 codex | Stage 3 gemini | CTO fix items | self-validation |
|---|---|---|---|---|
| Round 1 | PARTIAL (8 F + 7 S2-N) | PARTIAL Veto (3 S3-N) | 16 items | flag set |
| Round 2 | PARTIAL (4 PARTIAL + 6 S2R2-N) | PASS (3 advisory) | 12 items | (partial resolution) |
| Round 3 | PARTIAL (3 PARTIAL + 5 S2R3-N) | PARTIAL Veto re-asserted (3 S3R3-N) | 11 items | (Stage 3 stance reversal) |
| Round 4 | PARTIAL (3 PARTIAL + 6 S2R4-N) | PASS (3 advisory G2-time) | 5 items (user 직접 판단) | (Round 2 와 동일 divergence pattern) |
| Round 5 (quick) | **PASS** | **PASS** | (none) | **flag CLEARED** |

→ 총 **44 CTO fix items** (16+12+11+5) + 5 round cycle + 10+ CEO ruling locks (S2-N3 α, Q1 sfs brand, Q2 commit safety, Q9 commit-existing-dirty 제거, Q2 log masking α, etc.).

### §7.10.2 P-17 Cross-Instance Verify Pattern — Canonical Evidence

본 G1 review = P-17 cross-instance verify learning-pattern 의 canonical evidence (spec sprint G1 4 round + G6 3 stage 에 이은 두 번째 강한 증거):
- **Stage 1 same-instance leak rate**: AI-PROPOSED PASS-with-flags → 8 flag identified, but Round 2 codex 가 7 신규 발본 (Stage 1 same-instance missed) + Round 3/4 도 매번 신규 발본. → same-instance evaluator self-validation 한계 evidence.
- **Stage 2 vs Stage 3 divergence pattern**: Round 2 + Round 4 = Stage 3 PASS / Stage 2 PARTIAL — gemini 가 architecture-level "blocker neutralized" 본 후 PASS 주는 경향, codex 가 wording-level + contract-consistency 측면에서 strict. 두 stance 가 보완적.
- **Stage 3 third-eye reversal**: Round 2 PASS → Round 3 PARTIAL Veto re-asserted (Stage 3 가 Round 2 advisory items 의 importance 재판정) — third-eye 의 stance reversal 가능성도 evidence.

### §7.10.3 G1 Final Verdict

✅ **PASS LOCKED 2026-05-04T01:30+09:00 KST** (codex Round 5 + gemini Round 5 + user CEO ruling chain 5 round 완료).

- plan.md status: `ready-for-review-round-5` → **`ready-for-implement`** 전환.
- G2 implement 진입 = next session user 명시 명령 (자동 승급 금지, CLAUDE.md §1.3 + §1.20 + Round 1~5 cycle precedent).
- 본 세션 (claude-cowork:wizardly-quirky-gauss) closure: G1 review chain 완료. mutex release.

---

## §7. Round Trace (Stage 1+2+3 + CEO ruling)

### §7.1 Stage 1 (claude same-instance) — 2026-05-03T23:10+09:00

- session: claude-cowork:wizardly-quirky-gauss
- AI-PROPOSED verdict: **PASS-with-flags** (8 flags F1~F8 + 1 minor F9)
- self-validation flag: **set** (Stage 2/3 으로 resolution)
- 다음 1 step: user host 에서 codex Stage 2 invoke (§6.1 prompt)

### §7.2 Stage 2 (codex cross-runtime, parallel) — **PARTIAL**, 회수 2026-05-03T23:35+09:00

- mode: parallel (Stage 3 gemini 와 동시 invoke, independent second-runtime)
- evaluator: codex (user macOS terminal)
- prompt: §6.1 verbatim
- final verdict: **PARTIAL**
- summary verbatim: "Brainstorm→plan carry is mostly direct, and AC1~AC9 are broadly measurable. However, Stage 1 underweighted several plan-blocking ambiguities: release suffix-drop affects existing version discovery, package templates, docs/tests, and Windows shims; migration source paths are unclear against current `.sfs-local` state; and some AC verify commands are not binary enough. ... Anti-AC coverage is too narrow for a migration sprint. This should not advance to G2 until wording fixes land."

#### §7.2.1 Flag-by-flag verdict (codex)

| flag | codex verdict | fix / reason |
|---|---|---|
| F1 | PARTIAL | Fix AC1 grep: `grep -E "(migrate-artifacts|storage|archive|sprint)" bin/sfs`. Escaped pipes false-fail. |
| F2 | PARTIAL | Reword AC9: "Spec sprint SFS-PHILOSOPHY immutability carry-forward; verify against spec baseline commit, not only working tree diff." |
| F3 | PARTIAL | Clarify: default post-grace forced migration **in scope**; changing that policy/config override **out of scope**. |
| F4 | PARTIAL | AC4.4 policy: PR without secrets = SKIP; main/nightly/release with secrets = both Codex+Gemini PASS required; outage retry then release-block. |
| F5 | PARTIAL | CI PR check **mandatory**, local hook optional. AC2.6 PASS must require workflow validator failure on bad fixtures. |
| F6 | PARTIAL | Define `sfs sprint close` dispatch path. **Preferred fix**: `sfs-sprint-yml-validator.sh` owns validate AND close modes; keep 6-script count. |
| F7 | PARTIAL | Add ACs for backfill idempotence + archive sync locking + version metadata consistency; do not leave as self-note only. |
| F8 | PARTIAL | Add explicit prompt fixtures: AC3.2/AC3.5 must use deterministic `printf` input streams + assert prompt order/results. |

#### §7.2.2 Stage 2 신규 발본 (7 items)

- **S2-N1 (brainstorm.md scope literal stale)**: brainstorm.md still says target `0.6.0-product` in scope. Fix to `0.6.0` to match G2-α suffix drop.
- **S2-N2 (plan AC8.1 stale grill evidence)**: plan AC8.1 mentions stale "R7/R8 grill evidence". Replace with brainstorm 9/9 lock + plan self-flag gotchas.
- **S2-N3 (AC7.2 sfs version output string change)**: AC7.2 expects new version output string `Solon SFS v0.6.0`, but current CLI/docs use `sfs <version>` pattern. Either preserve `sfs 0.6.0` or add explicit docs/test migration AC.
- **S2-N4 (suffix drop release discovery missing)**: suffix drop misses release discovery — `latest_release_version`, semver parser, Scoop checkver, and package target paths need AC coverage.
- **S2-N5 (migration source matrix unclear)**: migration source unclear. Add `.sfs-local/sprints → .solon/sprints` source matrix, backup manifest, rollback, and **no-data-loss anti-AC**.
- **S2-N6 (Windows parity missing)**: Add `bin/sfs.ps1` / `sfs.cmd` dispatch and Windows Scoop smoke for new storage/migrate commands.
- **S2-N7 (AC3.4 AI runtime contract gap)**: AC3.4 says AI asks implicit questions, but bash CLI has no AI runtime contract. Define deterministic CLI prompt or explicit agent handoff.

#### §7.2.3 CTO Action (codex)

> "PARTIAL. The plan is close, but not ready for G2. Required CTO actions: patch plan/brainstorm wording for F1~F8 and S2-N1~N7, especially suffix-drop release plumbing, `.sfs-local` migration safety, Windows parity, and cross-instance CI policy. Then rerun Stage 2/3 review."

### §7.3 Stage 3 (gemini cross-runtime, parallel) — **PARTIAL (third-eye veto)**, 회수 2026-05-03T23:30+09:00

- mode: parallel (Stage 2 codex 와 동시 invoke, independent third-runtime)
- evaluator: gemini (user-side)
- prompt: §6.2 verbatim
- final verdict: **PARTIAL (Independent Stage 3 Veto)**
- summary verbatim: "The G1 Plan ... is a high-fidelity expansion of the brainstormed locks (9/9). It successfully translates strategic architecture (Layer 1/2) and CLI UX (3-pass migrate) into measurable binary ACs. ... However, Stage 3 re-evaluation finds that the plan occasionally abstracts away 'edge-case safety' (idempotence, race conditions, and artifact validity) into implement-time worker discretion, which increases the risk of 'dirty' states in consumer environments. The core logic is sound, but the 'verification harness' for the final release artifacts (Homebrew/Scoop) is underdeveloped."

#### §7.3.1 Flag-by-flag verdict (gemini)

| flag | gemini verdict | fix / reason |
|---|---|---|
| F1 | PARTIAL | ERE `\|` ambiguous/incorrect for most POSIX. Fix: `grep -E "migrate-artifacts\|storage\|archive\|sprint"` → `grep -E "migrate-artifacts|storage|archive|sprint"`. |
| F2 | PASS | Labels collide but context (doc-sprint vs code-sprint) distinct enough for human CTO/CPO. |
| F3 | PARTIAL | Clarity needed. "Forced migrate" = default implementation (in-scope). "Config override" = out-of-scope policy decision. |
| F4 | PARTIAL | CI must NOT hard fail on Secrets absence for forks; "skip with warning". Add AC4.4.1 for fallback. |
| F5 | PARTIAL | AC2.6 must require CI workflow as **mandatory**; local hooks remain optional/advisory. |
| F6 | PARTIAL | Explicitly assign `sfs sprint close` to `scripts/sfs-sprint-yml-validator.sh` OR create 7th script to avoid AC1 count mismatch. |
| F7 | PARTIAL | Idempotence (AC2.8) + Race protection (AC2.7) too critical for "discretion". Add binary sub-checks for repeat-run = no-op. |
| F8 | PASS | Standard `printf | cmd` or `yes | cmd` patterns assumed idiomatic for implementation workers. |

#### §7.3.2 Stage 3 신규 발본 (third-eye)

- **S3-N1 (Artifact Integrity Audit)**: AC7.4/7.5 focus on "existence" + "tagging". Missing — local validation of generated artifacts (e.g. `brew audit --new-formula` or `scoop check-manifest`). A broken manifest breaks the entire release.
- **S3-N2 (Secret Leak Prevention)**: AC4.4 involves API keys. Missing — explicit AC for log masking or verification that `log.md` and CI logs do NOT contain literal `CODEX_API_KEY` or `GEMINI_API_KEY`.
- **S3-N3 (Atomic Rollback Integrity)**: R-C.C-6 rollback focuses on `git revert`. Missing — verification that Layer 1 `docs/` file movements (which may be untracked or partially committed) are safely handled if migration process interrupted mid-way.

#### §7.3.3 CTO Action Items (gemini, 5 items)

1. **AC1 fix**: ERE grep syntax (remove backslashes from pipes).
2. **AC2.7/2.8 idempotence sub-checks**: re-running backfill/archive must be safe + no-op.
3. **AC7.4/7.5 artifact audit**: must run `brew audit` or equivalent on generated files.
4. **AC4.4 log masking verify-by**: ensure no Secrets leak into `log.md`.
5. **R-F/AC6 sprint close dispatch script**: confirm assignment to keep AC1 file-count consistent.

> Stage 2 codex verdict 회수 후 §7.2 채움 → consensus/divergence post-hoc analysis (§7.5 final lock 단계).

### §7.4 Post-hoc Consensus / Divergence Analysis (Stage 1 + Stage 2 + Stage 3)

> Parallel mode 정합 — Stage 2 (codex) + Stage 3 (gemini) 동시 verdict 회수 후 본 §7.4 에서 합의/divergence 분리.
> Stage 1 (claude AI-PROPOSED PASS-with-flags) ↔ Stage 2 (PARTIAL) ↔ Stage 3 (PARTIAL Independent Veto). **합의: G1 plan = NOT-READY-FOR-G2** (Stage 2 + Stage 3 모두 PARTIAL → CTO fix 필수).

#### §7.4.1 Flag-by-flag consensus matrix

| flag | Stage 1 | Stage 2 | Stage 3 | 합의 | 우선 fix wording |
|---|---|---|---|---|---|
| F1 | flag | PARTIAL | PARTIAL | **CONSENSUS PARTIAL** | codex `(migrate-artifacts\|storage\|archive\|sprint)` (group-wrap, 명시적) |
| F2 | flag | PARTIAL | PASS | **DIVERGENCE** (S2 reword, S3 tolerant) | codex (reword AC9: spec baseline commit verify, working tree diff 만 안 함) |
| F3 | flag | PARTIAL | PARTIAL | **CONSENSUS PARTIAL** | 둘 다 동일: forced migrate default = in-scope, config override = out-of-scope |
| F4 | flag | PARTIAL | PARTIAL | **CONSENSUS PARTIAL** | codex 더 precise (PR no-secrets=SKIP / main+nightly+release with secrets=both PASS / outage retry then release-block) |
| F5 | flag | PARTIAL | PARTIAL | **CONSENSUS PARTIAL** | 둘 다 동일: CI mandatory + local optional. codex 추가: bad fixtures workflow validator fail 검증 |
| F6 | flag | PARTIAL | PARTIAL | **CONSENSUS PARTIAL** | codex preferred: `sfs-sprint-yml-validator.sh` owns validate+close (6-script count preserved). gemini: either OR 7th script. → codex 권장 (6 count preserve = AC1 동요 0) |
| F7 | flag | PARTIAL | PARTIAL | **CONSENSUS PARTIAL** | 둘 다 동일: idempotence + race + version-metadata consistency 를 binary AC sub-check 으로 승격 |
| F8 | flag | PARTIAL | PASS | **DIVERGENCE** (S2 strict, S3 idiomatic OK) | codex (deterministic printf + assert prompt order — binary AC 강도 ↑) |

→ **합의 PARTIAL = 6 flag (F1/F3/F4/F5/F6/F7)**. Divergence = F2/F8 (Stage 2 stricter, Stage 3 tolerant). Stage 2 fix 채택 시 binary AC 강도 ↑ (recommended).

#### §7.4.2 신규 발본 (Stage 1 missed, 10 items)

> Stage 2 + Stage 3 가 발본한 plan-blocking ambiguities. Stage 1 (same-instance) 가 missed — P-17 cross-instance verify value evidence.

**Stage 2-only 신규 (7 items)** — release plumbing + .sfs-local migration + Windows + AI runtime gap angle:

- **S2-N1**: brainstorm.md 잔존 `0.6.0-product` literal → G2-α suffix drop 정합으로 `0.6.0` fix.
- **S2-N2**: plan AC8.1 stale "R7/R8 grill evidence" wording → brainstorm 9/9 lock + plan self-flag gotchas 로 교체.
- **S2-N3**: AC7.2 `Solon SFS v0.6.0` output string → 현 CLI `sfs <version>` 패턴 mismatch. 둘 중 택일 (preserve current pattern OR add docs/test migration AC).
- **S2-N4**: suffix drop release discovery missing → `latest_release_version` / semver parser / Scoop checkver / package target paths AC 추가.
- **S2-N5**: migration source matrix unclear → `.sfs-local/sprints → .solon/sprints` source matrix + backup manifest + rollback + **no-data-loss anti-AC** (안전성 critical).
- **S2-N6**: Windows parity → `bin/sfs.ps1` + `sfs.cmd` dispatch + Windows Scoop smoke (현 0.5.96 multi-CLI parity 정합).
- **S2-N7**: AC3.4 "AI 가 user 암묵지 질문" wording vs bash CLI no-AI-runtime contract gap → deterministic CLI prompt OR explicit agent handoff 명시.

**Stage 3-only 신규 (3 items)** — supply-chain / security / atomic-safety angle:

- **S3-N1**: artifact integrity audit → AC7.4/7.5 에 `brew audit --new-formula` + `scoop check-manifest` 추가 (broken manifest = release 전체 break).
- **S3-N2**: secret leak prevention → `log.md` + CI logs 에 literal `CODEX_API_KEY` / `GEMINI_API_KEY` 부재 검증 AC.
- **S3-N3**: atomic rollback integrity → R-C.C-6 git revert 만으로 부족. Layer 1 `docs/` file movements (untracked or partial commit) interrupted mid-way 처리 AC.

#### §7.4.3 Consolidated CTO Fix Patch List (16 items)

> Stage 1 missed + Stage 2 PARTIAL + Stage 3 PARTIAL 의 deduplicated union. 적용 대상 file = `plan.md` + `brainstorm.md` (S2-N1) + `review-g1.md` (본 trace).

**Tier 1 — Blocking AC corrections (8 items, F1~F8 합의/divergence resolution)**:
1. F1: AC1 grep `(migrate-artifacts|storage|archive|sprint)` group-wrapped ERE.
2. F2: AC9 reword — spec baseline commit verify (working tree diff 만 X).
3. F3: §3 wording 정형화 — forced migrate default in-scope / config override toggle out-of-scope.
4. F4: AC4.4 fallback policy 4-bullet (PR no-secrets / main+nightly+release / outage retry / log masking link to S3-N2).
5. F5: AC2.6 reword — CI workflow mandatory + local hook optional + bad fixtures validator fail check.
6. F6: R-A 6 script 유지 + `sfs-sprint-yml-validator.sh` 가 validate + close 두 mode dispatch + AC1 count 동요 0.
7. F7: idempotence (AC2.8) + archive race (AC2.7) + version metadata atomic (AC1+AC7) sub-check 승격.
8. F8: AC3.2/AC3.5 `printf "y\nk\nk\nn\n" | sfs migrate-artifacts --apply` deterministic input + prompt order assert.

**Tier 2 — Plan/brainstorm wording fixes (S2-N1, S2-N2, S2-N3) 3 items**:
9. S2-N1: brainstorm.md `0.6.0-product` 잔존 literal → `0.6.0` fix (frontmatter goal + §2 + §6.7 등).
10. S2-N2: plan AC8.1 stale wording → 9/9 lock + plan self-flag 5 gotcha 로 교체.
11. S2-N3: AC7.2 출력 string user 결정 — preserve `sfs 0.6.0` (현 CLI 패턴) OR migrate to `Solon SFS v0.6.0` (새 wording). **CEO call required**.

**Tier 3 — 신규 R/AC 추가 (S2-N4~N7 + S3-N1~N3) 5 items** (R-A 6 script 유지하되 AC sub-check 추가):
12. S2-N4: AC7 에 release discovery sub-check 추가 (semver parser / Scoop checkver / package target paths).
13. S2-N5: AC2 (또는 신규 R-H) 에 `.sfs-local/sprints → .solon/sprints` source matrix + backup manifest + no-data-loss anti-AC.
14. S2-N6: AC1 (또는 R-A) 에 `bin/sfs.ps1` + `sfs.cmd` dispatch + Windows Scoop smoke.
15. S2-N7: AC3.4 reword — bash CLI deterministic prompt OR `solon agent` external runtime handoff 명시.
16. S3-N1+N2+N3: AC7 (artifact audit) + AC4 (log masking) + AC2.7/C-6 (atomic rollback) sub-check 추가.

> **CEO ruling 필요 (1 item)**: S2-N3 의 sfs version output string 패턴 (preserve current OR migrate)
> **자동 fix 가능 (15 items)**: F1~F8 + S2-N1/N2/N4~N7 + S3-N1~N3 — 모두 wording 또는 AC sub-check 추가, 의미 결정 0.

### §7.4.4 Round 1 CTO Fix Patch Applied — 2026-05-03T23:45+09:00

- session: claude-cowork:wizardly-quirky-gauss
- CEO ruling: **S2-N3 = α** (preserve `sfs 0.6.0` output string, Option β default 권고 그대로, user "a" 선택 inline lock).
- 16 items 적용 결과:
  - **brainstorm.md**: S2-N1 — 잔존 `0.6.0-product` literal → `0.6.0` 일괄 변경 (단 §7 lock table G1 option historical wording = `0.6.0-product (REJECTED, G2-α lock)` 으로 restore).
  - **plan.md**: complete rewrite (~440 lines, frontmatter `round_1_fix_patch_applied` + `ceo_ruling_lock.S2_N3_sfs_version_output: α` 추가, status=ready-for-review-round-2). 16 items 통합:
    - F1 (AC1.2 grep ERE group-wrap fix) / F2 (AC9 spec baseline commit `03f36de` diff verify) / F3 (R-E E-4 + AC5.4 + §3 wording lock — forced migrate default in-scope, config override out-of-scope) / F4 (AC4.4 4-bullet fallback policy) / F5 (AC2.6 CI mandatory + bad fixture validator fail check) / F6 (R-A 6-script preserve, sprint-yml-validator validate+close 두 mode dispatch) / F7 (AC2.7 race + AC2.8 idempotence + AC1.4 + AC7.9 atomic 5-file commit) / F8 (AC3.2/AC3.5 deterministic printf + prompt order assert) / S2-N1 (brainstorm fix) / S2-N2 (AC8.1 reword — R7/R8 stale 제거, brainstorm 9/9 + plan self-flag 로 교체) / S2-N3 (AC7.2 α preserve `sfs 0.6.0`) / S2-N4 (AC7.8 release discovery — semver parser + Scoop checkver + Homebrew livecheck + package target paths) / S2-N5 (R-H 신규 — migration source matrix + backup + rollback-from-snapshot + no-data-loss anti-AC8) / S2-N6 (R-A.AC1.3 Windows wrapper bin/sfs.ps1 + sfs.cmd + AC4.5 Windows Scoop smoke) / S2-N7 (AC3.4 reword — bash CLI deterministic prompt only, external agent handoff R4 deferred) / S3-N1 (AC7.4 brew audit + AC7.5 scoop schema check) / S3-N2 (AC4.4.4 + AC4.6 log masking, no Secrets literal value 노출) / S3-N3 (AC2.9 + AC3.6 atomic Layer 1 file movements + interrupted-midway recovery).
  - **review-g1.md**: 본 §7.4.4 trace 추가 (본 fix patch 기록).
- 결과 plan.md 변화: 277L → ~440L. AC sub-check 27 → 52 (deterministic) + 6 (review_high) = 58 + 4 anti-AC.
- 다음 1 step = user host 에서 Round 2 parallel re-review (codex + gemini 동시 invoke). prompt = §6.1 (Round 2 reword 추가) + §6.2 (Round 2 reword 추가).

### §7.5 Final lock — Round 2 in progress

- Stage 2 codex Round 2 = pending (user host invoke 대기, prompt §6.3)
- Stage 3 gemini Round 2 = **PASS** (§7.6.1 verbatim, third-eye veto 해소)
- Round 2 둘 다 PASS → `verdict_final: PASS LOCKED <ts>` + plan.md `status: ready-for-review-round-2 → ready-for-implement` 전환 + 본 세션 closed.
- G2 implement 진입 = next session user 명시 명령 (자동 승급 금지, CLAUDE.md §1.3 + §1.20 + Round 1 cycle precedent).

---

## §7.6 Round 2 Trace (parallel re-review)

### §7.6.1 Stage 3 Round 2 (gemini, parallel third-eye) — **PASS**, 회수 2026-05-03T23:55+09:00

- mode: parallel third-eye Round 2 (Stage 2 codex Round 2 verdict unaware)
- evaluator: gemini (user host)
- prompt: §6.4 verbatim
- final verdict: **PASS** (third-eye veto 해소, "G1 PASS LOCKED" 자체 명시)

#### §7.6.1.A Round 1 Fix Verification + Veto Resolution

verbatim:
- **S3-N1 (Artifact Audit)**: Successfully integrated into AC7.4 (`brew audit`) and AC7.5 (Scoop schema check). Release breakage risk is mitigated.
- **S3-N2 (Secret Leak)**: Successfully integrated into AC4.4.4 and AC4.6 (log masking and artifact audit). Security hardening is confirmed.
- **S3-N3 (Atomic Rollback)**: Successfully integrated into AC2.9, AC3.6, and R-H.H-5. Layer 1 data safety is now transactional.
- **F1 (Grep)**: AC1.2 uses the correct ERE group-wrap.
- **F3 (Hard Cut)**: R-E E-4 and AC5.4 correctly lock "forced migrate" as the default in-scope behavior.
- **F4 (CI Fallback)**: AC4.4.1~4.4.3 defines a precise 4-bullet fallback policy.
- **F5 (CI Mandatory)**: AC2.6 makes the GitHub Actions workflow mandatory and includes a "bad fixture" validation test.
- **F6 (Dispatch)**: R-A and AC6.6 assign sprint close to the validator script, preserving the 6-script count.
- **F7 (Idempotence/Race)**: AC2.7 (`flock`) and AC2.8 (idempotence) are now binary requirements.
- **CEO Ruling (S2-N3 α)**: AC7.2 preserves the `sfs 0.6.0` output string, maintaining 0.5.x compatibility.
- Conclusion: All Round 1 vetoes and PARTIAL flags are successfully resolved. The plan's density has doubled (27 → 58 sub-checks), providing superior implementation headlights.

#### §7.6.1.B Third-eye Round 2 신규 발본 (advisory only, G2 implement-time)

> ⚙️ Stage 3 자체 명시: "advisory for the G2 implementation worker (CTO) and **do not require further plan-stage revisions**". 본 §7.6.1.B 는 plan §6 self-flag carry-forward.

- **S3R2-N1 (Git Tag Sequencing Race)**: AC7.4/7.9 define atomic 5-file commit, but Homebrew url tag validation (`v0.6.0`) requires git tag pushed to remote BEFORE `brew audit` or manifest update can succeed. Implementation must ensure `git tag + push` sequenced correctly in release tool.
- **S3R2-N2 (Cross-Platform Hash Parity)**: AC4.5 (Windows smoke) must verify `sfs.ps1` generates SHA256 hashes identical to POSIX `sha256sum`. Path separators (LF vs CRLF) in `sprint.yml` or scripts could cause hash mismatches during cross-platform migration.
- **S3R2-N3 (Workflow Permissions Hardening)**: New mandatory AC2.6 (PR check) requires `GITHUB_TOKEN` to have specific `contents: read` permissions blocks in the YAML. If workflow added without explicit permissions, may fail on forks despite fallback policy.

#### §7.6.1.C Final verdict (Stage 3 Round 2)

> "**Final Verdict: PASS**. The G1 Plan is now READY-FOR-IMPLEMENT. The 'Third-eye Round 2' items are advisory for the G2 implementation worker (CTO) and do not require further plan-stage revisions. ... Proceed to G2 Implement. (G1 PASS LOCKED)"

CTO Action Items (G2 Implement carry-forward, not plan-stage):
1. Release Sequence: Ensure release script pushes git tag before running artifact audits.
2. Normalization: Implement strict LF normalization for all `.yml` and `.md` files during migration to prevent Windows hash mismatches.
3. CI Config: Ensure `.github/workflows/sfs-pr-check.yml` includes necessary `permissions` block.

### §7.6.2 Stage 2 Round 2 (codex, parallel) — **PARTIAL**, 회수 2026-05-04T00:00+09:00

- mode: parallel Round 2 (Stage 3 gemini Round 2 verdict unaware, 동시 invoke)
- evaluator: codex (user macOS terminal)
- prompt: §6.3 verbatim
- final verdict: **PARTIAL** (codex 자체 명시 "run Round 3 cross-runtime review before G2")

#### §7.6.2.A Round 1 Fix Verification (16 items, 항목별 verdict)

| item | codex Round 2 verdict | reason / residual |
|---|---|---|
| F1 | **PASS** | AC1.2 grouped ERE alternation 정확 |
| F2 | **PASS** | AC9 reword + spec baseline commit diff 정합 |
| F3 | **PASS** | forced migrate default in-scope / config override out-of-scope 정합 |
| F4 | **PASS** | AC4.4 PR/main/release/secrets/outage fallback 4-bullet 정합 |
| F5 | **PASS** | AC2.6 CI mandatory + local hook optional 정합 |
| F6 | **PASS** | sfs-sprint-yml-validator.sh validate+close 두 mode + 6-script count preserve 정합 |
| F7 | **PASS** | idempotence + archive race + atomic version metadata 모두 binary AC 으로 승격 정합 |
| F8 | **PASS** | AC3.2/AC3.5 deterministic printf prompt fixtures 정합 |
| S2-N1 | **PASS** | scope target 0.6.0 / G1 historical rejected option 허용 |
| S2-N2 | **PASS** | AC8.1 stale R7/R8 wording 제거 |
| **S2-N3** | **PARTIAL** | plan CEO ruling sfs 0.6.0 lock 됐지만 **brainstorm §6.7 still says `Solon SFS v0.6.0`** — backstamp 또는 superseded mark 필요 |
| **S2-N4** | **PARTIAL** | release discovery AC 추가는 됐으나 **package identity/path ambiguity** — `solon.rb/json` vs existing `sfs.rb.template / sfs.json.template` 충돌 |
| **S2-N5** | **PARTIAL** | R-H 신설은 됐으나 **no-data-loss anti-AC 가 anti-AC8 으로 misnamed** + manifest fields underspecified |
| S2-N6 | **PASS** | Windows wrapper + Scoop smoke R-A/AC1.3/AC4.5 정합 |
| **S2-N7** | **PARTIAL** | AI handoff R4 deferred 정합이지만 **structured questions enumerated 부족** — binary grep/fixture verify 안 됨 |
| **S3-N1** | **PARTIAL** | artifact audit 추가는 됐으나 **exact Homebrew/Scoop file names + audit commands path-accurate wording 부족** |
| **S3-N2** | **PARTIAL** | log masking 추가됐으나 **env var names vs secret values 혼재** — sentinel secret values verify 권장 |
| S3-N3 | **PASS** | atomic rollback / interrupted migration R-C / R-H / AC2.9 / AC3.6 모두 정합 |

→ **Round 1 fix verification**: 11 PASS / 6 PARTIAL (S2-N3/N4/N5/N7 + S3-N1/N2). codex note: "named findings 18 because S3-N1~N3 bundled in patch list as 16, verified all named findings".

#### §7.6.2.B 잔존 ambiguity + 신규 Round 2 발본 (S2R2-N1~N6, 6 items)

- **S2R2-N1 (Package Identity Regression Risk)**: Current product installs `sfs`; plan introduces `solon.rb / solon.json`. Fix: specify `Formula/sfs.rb`, `bucket/sfs.json`, package command `sfs`, version `0.6.0`. (브랜드 regression 위험 — current 0.5.96-product 가 `sfs` 브랜드인데 plan 이 `solon.rb/json` 으로 작명 — 0.5.x consumer 의 `brew install sfs` 실패 가능)
- **S2R2-N2 (Brainstorm↔Plan conflict on sfs version output)**: Fix brainstorm §6.7 to `sfs 0.6.0` OR add "superseded by CEO ruling S2-N3=α" backstamp marker. (Round 1 fix 가 plan AC7.2 만 갱신, brainstorm §6.7 잔존)
- **S2R2-N3 (sfs upgrade auto git commit safety)**: AC5.4 forced migrate 가 consumer repo files modify + commit. Consumer 의 dirty working tree 또는 user 작업 중 자동 commit = data loss/conflict 위험. Fix: forced migrate 가 modify 시 backup/manifest 만 하고, commit 은 explicit `--commit` flag 또는 user prompt 후 진행.
- **S2R2-N4 (`--print-matrix` machine-readable contract)**: R-H.H-1 의 `sfs migrate-artifacts --print-matrix` 가 human-readable 표만 출력. Fix: JSON rows 출력 contract 명시 — `{source, dest, action, sha256_before, sha256_after, reason}` 필드.
- **S2R2-N5 (Workflow bad-fixture verification locally binary)**: AC2.6 의 bad fixture validator fail check 가 GitHub workflow CI 안에서만 verify. Fix: 로컬에서도 `bash tests/test-bad-fixture.sh` 실행 시 binary fail/pass — workflow 가 같은 script 호출하도록 spec.
- **S2R2-N6 (review-g1.md metadata staleness)**: review-g1.md frontmatter `verdict_current` / `last_touched_at` / §8 Next Steps 잔존 stale (Round 1 wording 그대로). Fix: trace metadata 갱신 후 final lock.

#### §7.6.2.C Final verdict (Stage 2 Round 2)

> "**PARTIAL**. The Round 1 patch materially improves the plan and resolves most original flags, but it introduced or left several plan-quality blockers around package identity, brainstorm backstamp, forced-migrate commit behavior, and binary test contracts. CTO actions: patch S2-N3/S2-N4/S2-N5/S2-N7/S3-N1/S3-N2 wording, add S2R2-N1~N6 fixes, then run Round 3 cross-runtime review before G2."

CTO Action Items (Round 2 fix list, 12 items):
1. S2-N3 brainstorm §6.7 backstamp (`sfs 0.6.0` 또는 superseded marker)
2. S2-N4 package identity 명확화 (Formula/sfs.rb + bucket/sfs.json, sfs 브랜드 preserve)
3. S2-N5 anti-AC 번호 정합 (anti-AC8 → anti-AC9 또는 rename) + manifest field enum
4. S2-N7 structured CLI questions 명시적 enumeration (binary verify 가능)
5. S3-N1 exact file names + audit command path-accurate wording
6. S3-N2 sentinel secret values verify (env var names 만으로는 불충분)
7. S2R2-N1 package identity regression fix (`Formula/sfs.rb` + command `sfs` preserve)
8. S2R2-N2 brainstorm §6.7 superseded marker (S2-N3 보강)
9. S2R2-N3 forced migrate commit safety (`--commit` opt-in flag 또는 prompt)
10. S2R2-N4 `--print-matrix` JSON contract enum (6 fields)
11. S2R2-N5 local bad-fixture script + workflow 동일 호출 spec
12. S2R2-N6 review-g1.md metadata refresh (frontmatter + §8)

### §7.6.3 Round 2 CTO Fix Patch Applied — 2026-05-04T00:10+09:00

- session: claude-cowork:wizardly-quirky-gauss (continuation)
- CEO ruling locks: **Q1 = α** (sfs 브랜드 preserve), **Q2 = α** (backup+prompt + --commit opt-in), **Q3 = a** (Round 3 cycle).
- 12 items 적용 결과:
  - **brainstorm.md §6.7**: backstamp marker 추가 — Solon SFS v0.6.0 wording superseded by CEO ruling S2-N3 = α (`sfs 0.6.0`). Q1=α 정합 추가 (Formula/sfs.rb + bucket/sfs.json).
  - **plan.md** Round 2 fix:
    - S2-N4 + S2R2-N1 + S3-N1 sfs brand preserve — `solon.rb/json` (4 instance) → `sfs.rb/json`, `brew audit --new-formula solon` → `--new-formula sfs`. 6 instance modified.
    - S2-N5 anti-AC 번호 정합 — `anti-AC8 (R-H no-data-loss)` → `anti-AC10` 일괄 rename (3 instance) + R-H.H-2 manifest schema enum 추가 (`{snapshot_id, created_at, source_repo_root, source_sha, files[], total_count, total_bytes}`, files[] = `{path, sha256, size_bytes, captured_at}`).
    - S2-N7 structured CLI questions — AC3.4 에 6 enumerated Q-A~Q-F (feature 명 / decisions 존재 / archive vs keep / default action / legacy migrate / confirm) + smoke harness `tests/test-sfs-pass1-prompts.sh` binary grep verify.
    - S3-N2 sentinel secret values — AC4.4.4 + AC4.6 reword (sentinel pattern `SFS_TEST_SENTINEL_dummy_codex_xxxxxxxx` + `SFS_TEST_SENTINEL_dummy_gemini_yyyyyyyy` 16-hex random suffix inject + literal grep = 0 verify).
    - S2R2-N3 forced migrate commit safety — AC5.4 reword: backup manifest default 생성 + git commit NOT auto + `sfs upgrade --commit` opt-in flag OR `Commit migration now? [y/N]` (default N) prompt + dirty working tree detect (non-empty `git status --porcelain` + no `--commit` flag → exit non-zero with error).
    - S2R2-N4 `--print-matrix` JSON contract — H-1 에 6 fields enum (`{source, dest, action, sha256_before, sha256_after, reason}`) + action enum (`migrate / archive / delete / skip`).
    - S2R2-N5 local bad-fixture script — AC2.6 reword: `tests/test-bad-fixture.sh` (신규) 가 local CLI 와 workflow 동일 binary signal 보장 (`bash tests/test-bad-fixture.sh` ↔ `.github/workflows/sfs-pr-check.yml` 동일 script call).
  - **plan.md frontmatter**: `last_touched_at` 2026-05-04T00:10+09:00 / `status: ready-for-review-round-3` / `round_2_fix_patch_applied` 추가 / `ceo_ruling_lock` 에 Q1_S2R2_N1 + Q2_S2R2_N3 lock 추가.
  - **review-g1.md** (S2R2-N6 metadata refresh): `last_touched_at` / `evaluator_executor_round_2/3` / `verdict_final` / `verdict_current` / `session` 모두 갱신 + 본 §7.6.3 + §6.5/§6.6 Round 3 prompts 추가.
- 결과 plan.md 변화: ~440L → ~340L (rewrite + targeted edits). AC sub-check sentinel + structured questions + JSON contract enumeration → binary verify 강도 ↑.
- 다음 1 step = user host 에서 Round 3 parallel re-review (codex + gemini 동시 invoke, §6.5 + §6.6 prompt verbatim).

---

## §8. Next Steps (Sequential Disclosure)

> Round 1~3 cycle 완료 (Stage 1 + Stage 2 + Stage 3 모두 PARTIAL through Round 3) + Round 1/2/3 CTO fix patch 16+12+11 = 39 items 적용 완료. 다음 = Round 4 parallel re-review.

1. **다음 1 step (본 Round 3 fix ship 후)**: user host parallel invoke — codex (§6.7 prompt) + gemini (§6.8 prompt) 동시 → 두 verdict paste 본 conversation.
2. Round 4 둘 다 PASS → `verdict_final: PASS LOCKED <ts>` + plan.md `status: ready-for-review-round-4 → ready-for-implement` 전환 + 본 세션 closed.
3. Round 4 PARTIAL 잔존 → Round 5 cycle (spec sprint Round 1~4 precedent 초과 — escalation 후보, but Round 4 가 통상 수렴).
4. user 명시 G2 implement 명령 (자동 승급 금지) → next session G2 implement sprint 진입.

> CLAUDE.md §1.28 (Cowork sandbox git 금지) 정합 — 본 review-g1.md ship 은 file-write only, commit/push 는 user host 수동. user 가 host terminal 에서 `git add 2026-04-19-sfs-v0.4/sprints/0-6-0-product-implement/review-g1.md 2026-04-19-sfs-v0.4/PROGRESS.md` + commit + push.
