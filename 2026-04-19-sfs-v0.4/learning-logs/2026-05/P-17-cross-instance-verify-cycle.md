---
pattern_id: P-17-cross-instance-verify-cycle
title: "Multi-runtime multi-stage cross-instance verify cycle — SFS 의 self-validation 회피 mechanism 운영 패턴"
captured_from: "0.6.0-product spec sprint G1 Round 1~4 + G6 Stage 1~3 (sessions: elegant-hopeful-maxwell + affectionate-trusting-thompson, 2026-05-03)"
visibility: oss-public
applicability:
  - "Generator 와 Evaluator 가 동일 runtime/instance/conversation 인 경우 (e.g. claude cowork 안에서 G2 implement + G6 review 둘 다 진행)"
  - "AC contract 의 strict literal 해석 vs 의도 해석 사이 ambiguity 가 있을 때"
  - "Spec/blog/external doc 의 attribution 정확성이 중요한 sprint (mis-attribution 위험)"
  - "Sprint 산출물의 제품 우선순위 (기능 vs 비지니스 vs 안정성) 가 review 시점에 명확하지 않은 경우"
reuse_count: 0
related_patterns:
  - P-04-session-hang-takeover
  - P-11-sequential-disclosure
  - P-15-claude-worktree-gitlink-committed
---

# P-17 — Multi-runtime multi-stage cross-instance verify cycle

> **visibility**: oss-public. SFS 의 self-validation 회피 mechanism 의 운영 패턴 SSoT.
> CLAUDE.md §1.3 (self-validation-forbidden) + plan §5 (CTO Generator ↔ CPO Evaluator 분리 contract) + model-profiles.yaml `execution_standard.cannot: approve own work` 의 실 운영 instance.

---

## 문제

증상: SFS sprint 진행 중 generator (CTO) 와 evaluator (CPO) 가 같은 runtime/instance/conversation 일 때 두 종류 leak 발생:

1. **Strict literal vs 의도 해석 leak**: AC contract 가 grep 으로 자동 verify 가능하다고 plan 단계에 lock 했는데, implement 단계 산출물의 본문 의도가 그 grep 결과를 의도적으로 위반 (e.g. 옵션 설명 맥락의 `business-only` literal 등장). same-instance evaluator 는 generator 의 의도를 너무 우호적으로 해석해서 PASS 줄 위험.
2. **External doc attribution leak**: spec 본문이 외부 blog/doc/source 의 specific term 을 인용/paraphrase 할 때, same-instance evaluator 는 attribution 정확성 (그 term 이 실제 source 에 존재하는지) 을 검증할 동기가 약함. Cross-runtime evaluator (특히 web fetch tool 보유) 가 source 직접 조회로 발본 가능.

발생 조건:
- Cowork session 안에서 G2 implement + G4/G6 review 가 같은 conversation 에 묶임.
- AC contract 가 binary grep 으로 표현 가능한 것처럼 plan 단계에 lock 됐는데, 실제는 review_high judgment 가 필요한 의도 해석 영역.
- Spec 산출물이 외부 reference (blog / paper / doc) 를 cross-ref.

원인:
- Same-instance evaluator 는 generator 와 model knowledge state 공유 → 의도 정합성을 자체 reasoning loop 안에서 정합화.
- model-profiles.yaml `cannot: approve own work` 가 contract 로는 lock 됐지만 실 enforcement 는 user 가 cross-instance invoke 해야 함 (자동 enforcement 부재).

---

## 해결 — Cross-instance verify cycle 운영 패턴

### Stage 정의

| Stage | Executor | 위치 | 목적 |
|---|---|---|---|
| Stage 1 | Same-instance generator 자체 (AI-PROPOSED) | Cowork conversation 내 | 빠른 self-check + flag 정리 + Stage 2/3 prompt 작성 |
| Stage 2 | Cross-runtime cross-instance (codex 권장, GPT 계열) | User-side terminal | Strict literal grep 해석 + AC contract gap 발본 + attribution 정확성 |
| Stage 3 | Cross-runtime cross-instance (gemini 권장, Gemini 계열) | User-side terminal | Stage 2 verdict 의 over-blocking 여부 cross-check + 다른 reasoning style 의 binary 재확인 |

### Stop criteria

- **Pass-out**: Stage N PASS 며 추가 fix 없을 때 (Stage 2 이상 cross-instance 가 최소 1 회 PASS 필요).
- **User CEO ruling 우선**: AI evaluator 가 strict over-blocking 으로 PARTIAL/FAIL 줄 때 user CEO 가 우선순위 ruling 으로 contract 정렬 → contract 수정 후 evaluator 자체 정정 PASS 가능.
- **Fail-out**: Stage 모두 FAIL 또는 contract scope 자체 깨짐 → brainstorm/plan 으로 escalate.

### Anti-pattern (회피)

- AI 가 user 의 ruling 없이 PARTIAL/FAIL 을 자체 PASS 로 정정하는 것 금지 (CLAUDE.md §1.3 self-validation-forbidden).
- Stage 1 만으로 sprint close 하는 것 금지 (high-stakes spec sprint 한정 — minor patch sprint 는 Stage 1 only 허용 가능, user judgment).
- Same-instance evaluator 만 여러 round 도는 것 (Round N → Round N+1 모두 same-instance) 금지 — 효용 0.

---

## 실 사례 evidence (2026-05-03 0.6.0-product spec sprint)

### G1 review (4 round cycle)

- **Round 1**: claude same-instance AI-PROPOSED PASS (부정확, 3 항목 leak — AC8 누락 / AC7 deterministic 가장 / blog attribution 부정확).
- **Round 2**: codex cross-runtime cross-instance PARTIAL → 3 fix (AC8 inclusion / AC7 relabel + 6 sub-check / attribution split).
- **Round 3**: codex 재검증 PARTIAL → 3 follow-up fix (§4 stale self-check / §5 fail criteria AC8 hard fail / §6 historical literal phrase grep cleanup).
- **Round 4**: codex final PASS LOCKED.
- **Cost**: user manual codex invoke 4 회 + cowork session round-trip 4 회 ≈ 30분.
- **Value**: blog page 직접 조회로 "Anthropic Planner/Generator/Evaluator" 본문 부재 confirm — same-instance 가 절대 발본 못 했을 attribution 정확성 fix.

### G6 review (3 stage cycle)

- **Stage 1**: claude same-instance AI-PROPOSED PASS-with-flags (5 review-grade flag 정리).
- **Stage 2**: codex cross-runtime cross-instance initial PARTIAL (AC6 strict grep ambiguity) → user CEO ruling "비지니스 모델 = later track" 회수 후 Codex 자체 정정 PASS.
- **Stage 3**: gemini cross-runtime cross-instance ALL PASS (AC1~AC8 + AC7.1~AC7.6 + 5 flag 전부 resolve + 6 철학 6/6).
- **Cost**: user manual codex + gemini invoke 2 회 + cowork session round-trip 2 회 ≈ 15분.
- **Value**: AC contract clarification (frontmatter only) + over-blocking 회피 (gemini cross-check) + CEO ruling SSoT lock.

---

## Trade-off + 적용 한계

- **Cycle 단축 trigger**: Stage 1 이 binary grep 만으로 끝나는 minor patch sprint 는 Stage 2/3 생략 가능 (user judgment).
- **Cycle 연장 trigger**: Round/Stage N 이 PARTIAL 일 때 fix 가 deterministic 인지 (= same-instance 가 fix 가능) 또는 wording subtlety 가 있는지 (= 다음 round 도 cross-instance 권장) 판단.
- **User cost vs AI cost**: User manual invoke 가 cycle 당 ~5분 (terminal 띄우고 prompt paste 하고 verdict 회수). AI 입장 시간은 추가 0 — bottleneck 은 user.
- **Multi-runtime 정합**: codex (GPT) + gemini (Gemini) + claude 3 runtime 모두 user 가 보유했을 때 ideal. 둘만 보유 시 (e.g. codex + claude) 도 대부분 sufficient.

---

## 관련 정합

- CLAUDE.md §1.3 (self-validation-forbidden, A/B/C 의미 결정 사용자에게만)
- CLAUDE.md §1.20 (단계적 안내, 다음 1 step 만)
- CLAUDE.md §1.12 (session mutex, takeover protocol — Stage 사이 session 끊김 시 takeover)
- model-profiles.yaml `execution_standard.cannot: approve own work`
- model-profiles.yaml `review_high.escalate_when "same test/review finding fails twice"`
- 0-6-0-product-spec/plan.md §5 (CTO Generator ↔ CPO Evaluator runtime split contract)
- 0-6-0-product-spec/review.md (Round 1~4 trace SSoT)
- 0-6-0-product-spec/review-g6.md (Stage 1~3 trace SSoT)
- SFS-PHILOSOPHY.md §6 6번 철학 "매일 system 설계" (cycle 자체 = harness-assumption 정합)

## 재사용 시 체크리스트

- [ ] Sprint 가 spec/architecture/contract grade 인가? (minor patch 면 Stage 1 only 가능)
- [ ] Generator runtime 외 cross-runtime evaluator (codex / gemini / 다른 claude) 1+ 보유?
- [ ] Stage 2 prompt 가 Stage 1 산출물 + 첨부 file list + 5+ 명확한 focus question 포함?
- [ ] User CEO ruling 가 필요한 priority 결정 (e.g. 비지니스 vs 기능) 사전 정렬?
- [ ] Stop criteria + escalation criteria 사전 합의?
- [ ] Cycle 별 cost (user 시간) 합리적 한계 (e.g. 4 round 초과 시 brainstorm escalate)?
