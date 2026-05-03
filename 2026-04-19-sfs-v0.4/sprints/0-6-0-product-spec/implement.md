---
phase: implement
gate_id: G2
status: ready-for-review   # AC1~AC6+AC8 deterministic PASS, AC7.1~AC7.6 G6 review_high 위임
sprint_id: "0-6-0-product-spec"
goal: "0.6.0-product spec — 4 신규 markdown spec 작성 + 2 file 수정 (CLAUDE.md §1.x link / .visibility-rules.yaml)"
visibility: raw-internal
created_at: 2026-05-03T21:15:00+09:00
last_touched_at: 2026-05-03T21:30:00+09:00
plan_source: "sprints/0-6-0-product-spec/plan.md (status=ready-for-implement, Codex Round 4 PASS LOCKED)"
review_source: "sprints/0-6-0-product-spec/review.md (verdict_round_4=PASS LOCKED)"
implementation_persona: ".sfs-local/personas/implementation-worker.md (단 본 sprint = architecture-grade → strategic_high 직접)"
reasoning_tier: "strategic_high (architecture / public contract — model-profiles.yaml 정합)"
runtime: "claude (current cowork session, runtime-agnostic spec)"
session: "claude-cowork:elegant-hopeful-maxwell"
---

# Implement — 0.6.0-product spec

> G2 implement workbench. plan.md (Gate 3 PASS LOCKED) 의 R1~R7 산출물 계약을 실 markdown 파일로 변환.
> 본 sprint = docset-design — 코드 아닌 spec 문서 묶음 산출. AI Coding Guardrails (§0) 의 "Valid artifacts: code, taxonomy, design handoff, QA evidence, ..., docs" 정합.

---

## §0. AI Coding Guardrails — Harness / Design / DDD / TDD (본 sprint 적용)

본 sprint 는 코드 X spec 산출물이지만 §0 가드레일은 모두 적용.

- **Think before coding**: brainstorm 7/7 + plan AC1~AC8 lock 이 사전 가정 명시 = ✓.
- **Simplicity first**: 4 markdown 만 신설 (R5 inline → R1, R7 inline → R1). 5 파일 안 만듦. ✓.
- **Surgical changes**: CLAUDE.md 1 line link 만 추가, .visibility-rules.yaml 4 entries 만 추가. unrelated cleanup 없음. ✓.
- **Goal-driven execution**: AC1~AC6+AC8 deterministic 자체 검증 + AC7.1~AC7.6 review_high judgment G6 위임.
- **Shared design concept first**: SFS-PHILOSOPHY.md = 6 철학 SSoT (Deep Module 1 단위). storage-architecture-spec.md / migrate-artifacts-spec.md / improve-codebase-architecture-spec.md 각각 deep module 단위. ✓.
- **DDD language**: brainstorm round 1+2 의 ubiquitous language (Layer 1/2 / archive branch / sprint.yml / runtime-agnostic / harness-assumption / SFS-local analogy / AC7 review_high / AC8 hard failure) 일관 사용. ✓.
- **TDD feedback loop**: AC1~AC8 binary check + Cowork bash grep verify 가 implementation 의 즉시 feedback. ✓.
- **Regularity over cleverness**: 기존 docset 의 frontmatter style (`doc_id` / `title` / `version` / `visibility`) 일관 유지. ✓.

## §1. Implementation Target

- **Work slice**: 4 신규 markdown spec + 2 file 수정 (R1~R7 일괄).
- **Plan source**: `plan.md` (R1~R7 + AC1~AC8 + Sprint Contract).
- **Implementation persona**: `.sfs-local/personas/implementation-worker.md` — 단 본 sprint 는 architecture-grade 라 strategic_high 가 직접 작성.
- **Reasoning tier**: `strategic_high` (model-profiles.yaml `cto-generator` default).
- **Model profile source**: `.sfs-local/model-profiles.yaml` v1.1 (study-note 0.5.88-product 첨부).
- **Runtime / resolved model / reasoning effort**: claude (current cowork) — 단 spec 본문은 runtime-agnostic.
- **Fallback if profile unset**: current runtime model.
- **Agent model override used?**: no.
- **Acceptance criteria in scope**:
  - AC1 (R1 SFS-PHILOSOPHY.md 6 § / ≤200 line / visibility=oss-public)
  - AC2 (R2 storage 7-item + lock layer reject)
  - AC3 (R3 migrate-artifacts 4-item + pseudo-code)
  - AC4 (R4 improve-codebase 3-surface + I/O contract)
  - AC5 (R5 cross-ref Deep Module 1-line + tier 표 absent + divisions.yaml ref)
  - AC6 (4 신규 spec frontmatter visibility=oss-public)
  - AC8 (R7 harness URL grep + SFS-local analogy grep + ≤15 단어 인용)
  - AC7.1~AC7.6 = G6 review (review_high judgment) 위임.
- **Out of scope for this slice**:
  - 실 storage 마이그레이션 script.
  - 실 `sfs migrate-artifacts` / `sfs improve-deep-modules` script 구현.
  - 0.6.0 release cut.
  - .solon/ runtime 구조 실제 마이그레이션.
- **Shared design concept**: SFS 6 철학 + Deep Module dogma 가 SSoT 1 파일 (`SFS-PHILOSOPHY.md`) 에 codify, 나머지 3 spec 은 그 dogma 의 mechanism 명세.
- **DDD terms touched**: 위 brainstorm + plan 정합 ubiquitous language 7 종.

## §2. Execution Notes

- **Approach**: R1 (SSoT) → R2 → R3 → R4 → CLAUDE.md §1.x link → .visibility-rules.yaml 순. R1 이 SSoT 라 먼저 작성.
- **Files/modules expected to change**:
  - 신규 4: `2026-04-19-sfs-v0.4/SFS-PHILOSOPHY.md` / `2026-04-19-sfs-v0.4/storage-architecture-spec.md` / `2026-04-19-sfs-v0.4/migrate-artifacts-spec.md` / `2026-04-19-sfs-v0.4/improve-codebase-architecture-spec.md`.
  - 수정 2: `2026-04-19-sfs-v0.4/CLAUDE.md` (§1.x 1 line) / `2026-04-19-sfs-v0.4/.visibility-rules.yaml` (4 entries).
- **Test-first plan**: AC1~AC6+AC8 deterministic check 가 본 implementation 의 즉시 feedback. AC7 review_high judgment 는 G6 review 단계.
- **Risks / rollback notes**:
  - CLAUDE.md ≤200 line cap (§1.14) 위반 risk → 1-line link 만 추가, 본문 inline 금지.
  - .visibility-rules.yaml schema 충돌 risk → 기존 entry 형식 그대로 따름.

## §3. Code Changes Made (2026-05-03T21:30+09:00 KST)

| # | 파일 | 변경 | line count |
|---|---|---|---|
| 1 | `2026-04-19-sfs-v0.4/SFS-PHILOSOPHY.md` | 신규 (R1 + R5 inline + R7 inline). 6 철학 §1~§6 + Model Profile Cross-Ref §7 (1-line, no tier table) + SFS-Local 3-Role Analogy §8 (책임 column only, no tier column) + External References §9 | 98 (≤200 ✓) |
| 2 | `2026-04-19-sfs-v0.4/storage-architecture-spec.md` | 신규 (R2). Layer 1/2 + archive branch + co-location + N:M + sprint.yml + pre-merge hook + lock layer REJECTED 명시 | 138 (≤400 soft ✓) |
| 3 | `2026-04-19-sfs-v0.4/migrate-artifacts-spec.md` | 신규 (R3). 2-pass propose-accept + pass 1 algorithm + reject granularity + rollback. pseudo-code fenced block 3 | 129 (≤300 soft ✓) |
| 4 | `2026-04-19-sfs-v0.4/improve-codebase-architecture-spec.md` | 신규 (R4). 3-pass (정적 + AI + interactive) + 3 surface (자동 감지 / `--change-deep` / `improve-deep-modules`) + I/O contract | 171 (≤400 soft ✓) |
| 5 | `2026-04-19-sfs-v0.4/CLAUDE.md` | §1.27 추가 — SFS-PHILOSOPHY.md link 1 줄 | 178 → 179 (≤200 §1.14 ✓) |
| 6 | `2026-04-19-sfs-v0.4/.visibility-rules.yaml` | 4 oss-public 매핑 추가 (SFS-PHILOSOPHY / storage-architecture-spec / migrate-artifacts-spec / improve-codebase-architecture-spec) | 119 → 133 |

implementation iteration log:
- iter 1: SFS-PHILOSOPHY.md 초안 작성 → tier 표 잔존 (§7 4-bullet list + §8 mapping table) 자체 발본 → AC5 strict 위반 가능 → §7 1-line cross-ref 만, §8 tier column 제거. 두 번째 iteration 후 AC5 PASS.
- iter 2: storage-architecture-spec.md 초안 → §7 anti-AC2 meta-comment 가 "admin-page / saas / customer-portal" trigger 단어 포함 → AC2 anti-spec strict grep result 1 → reword (구체 단어 제거, 추상화) → grep result 0 PASS.
- 나머지 파일은 1 iteration 으로 AC PASS.

## §4. Verification (deterministic AC self-check, 2026-05-03T21:30+09:00 KST)

**Commands run** (Cowork bash sandbox):

```bash
# AC1
grep -c "^## §" SFS-PHILOSOPHY.md             # 9 ≥ 6 ✓
wc -l SFS-PHILOSOPHY.md                       # 98 ≤ 200 ✓
grep "^visibility:" SFS-PHILOSOPHY.md         # oss-public ✓

# AC2
for kw in "Layer 1" "Layer 2" "archive 브랜치" "co-location" "N:M" \
          "sprint.yml" "pre-merge hook" "lock layer 명시적 REJECTED"; do
  grep -c "$kw" storage-architecture-spec.md  # 모두 ≥1 ✓
done
grep -cE 'admin-page|saas|customer-portal' storage-architecture-spec.md  # 0 ✓

# AC3
for kw in "Pass 1" "Pass 2" "Reject Granularity" "Rollback"; do
  grep -c "$kw" migrate-artifacts-spec.md     # 모두 ≥1 ✓
done
grep -c '```pseudo' migrate-artifacts-spec.md # 3 ≥ 1 ✓

# AC4
for kw in "Surface (a)" "Surface (b)" "Surface (c)" "Input / Output Contract"; do
  grep -c "$kw" improve-codebase-architecture-spec.md  # 모두 ≥1 ✓
done

# AC5
grep -c "model-profiles.yaml" SFS-PHILOSOPHY.md  # 4 ≥ 1 ✓
grep -c "divisions.yaml" SFS-PHILOSOPHY.md       # 2 ≥ 1 ✓
grep -cE "^\|.*strategic_high.*\|" SFS-PHILOSOPHY.md  # 0 (no tier table) ✓

# AC6
for f in SFS-PHILOSOPHY.md storage-architecture-spec.md \
         migrate-artifacts-spec.md improve-codebase-architecture-spec.md; do
  grep "^visibility:" $f                       # 모두 oss-public ✓
done

# AC8
grep -c "harnessing-claudes-intelligence" SFS-PHILOSOPHY.md  # 2 ≥ 1 ✓
grep -cE "(SFS-local analogy|SFS 자체)" SFS-PHILOSOPHY.md    # 4 ≥ 1 ✓
# 직접 인용 ≤15 단어 가드: §6 의 "하네스의 모든 구성 요소는 모델이 혼자 할 수
# 없는 것을 가정" = 한국어 9 어절 ≤ 15 단어 ✓

# CLAUDE.md ≤200 line cap (§1.14)
wc -l CLAUDE.md                                # 179 ≤ 200 ✓
```

**Result**: AC1~AC6+AC8 deterministic = **all PASS** (cap + count + grep). 단 minor flag:
- AC6 grep "business-only" = 2 occurrences in spec body (storage-architecture L44 + migrate-artifacts L118) = user-explicit override 옵션 설명 (frontmatter 자체는 oss-public). spec 의 의도와 정합 — 단 AC6 strict grep contract "0" 시 review-grade 판정 필요.

**AC7.1~AC7.6 review_high judgment**: G6 review 단계 위임 (cross-instance evaluator 가 6 sub-check binary 평가). claude same-instance 가 self-evaluate 시 self-validation 위반 (Round 1~4 cycle 가 입증).

**Manual smoke / inspection**: 6 신규/수정 파일 각각 frontmatter / 본문 / cross-ref link 모두 1-pass 검토 완료.

## §5. Review Handoff

- **Ready for review?**: **YES** — implementation 완료, AC1~AC6+AC8 deterministic PASS.
- **Recommended next gate**: **Gate 6 (Review)** — AC7.1~AC7.6 review_high judgment 평가 + AC1~AC6+AC8 deterministic re-confirm + minor flag (AC6 spec body grep) review-grade 판정.
- **Next command**: `/sfs review --gate G6`.
- **Cross-instance verify recommendation**: claude generator (본 cowork, 본 implement) → codex evaluator (user-side). Round 1~4 cycle 의 same-instance leak rate 가 cross-instance verify 의 가치를 입증 — G6 review 도 cross-instance 권장.
- **G6 review 시 평가 input**:
  - 4 신규 markdown spec (SFS-PHILOSOPHY / storage-architecture / migrate-artifacts / improve-codebase-architecture).
  - 2 modified file (CLAUDE.md §1.27 / .visibility-rules.yaml 4 entries).
  - implement.md (본 파일) §3 §4 evidence.
  - plan.md (G1 PASS LOCKED, AC1~AC8 + AC7.1~AC7.6 contract).
  - brainstorm.md (G0, 7/7 lock).
  - review.md (Round 1~4 history trace).
