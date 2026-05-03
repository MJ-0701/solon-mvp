---
doc_id: sfs-philosophy
title: "SFS (Solon) — 6 철학 SSoT"
version: 1.0
created: 2026-05-03
updated: 2026-05-03
visibility: oss-public
sprint_origin: "0-6-0-product-spec (G1 Codex Round 4 PASS LOCKED)"
external_references:
  harness_assumption_blog:
    url: "https://claude.com/ko-kr/blog/harnessing-claudes-intelligence"
    role: "harness-assumption 메타 철학 출처 (직접 인용 ≤15 단어 가드, 본 SSoT 는 paraphrase)"
---

# SFS (Solon) — 6 철학

> SFS 자체의 design dogma SSoT. 본 문서는 6 철학을 ubiquitous language 로 codify 하고, 각 철학이 어떤 trigger 에 어떤 response 를 요구하는지 one-screen 으로 명시한다.
> 입력 trigger → 적용 response. 의도가 안 맞으면 1번, AI 가 장황하면 2번, 안 돌아가면 3번, 테스트가 어려우면 4번, 뇌가 못 따라가면 5번. 매일 6번.

---

## §1. Grill Me — 의도가 안 맞으면 심문

trigger: 사용자 발화의 의도와 AI 출력이 어긋남.

response: brainstorm `--hard` (또는 `--normal`) 모드로 **계속 심문**. user 가 놓치고 있는 부분까지 생각하게 만든다. "ㄱㄱ" 같은 vague agreement 를 plan-readiness 로 자동 변환 금지 — owner 결정이 미해소면 status=draft 유지.

evidence example: brainstorm.md 의 grill round 1+2, plan G1 의 추가 user 결정 grill (R6 split / visibility / runtime split).

## §2. Ubiquitous Language — AI 가 장황하면 어휘 통일

trigger: AI 응답이 장황 / 혼선 / 같은 개념을 다른 용어로 호명.

response: **Taxonomy 본부 활성화** — 도메인 어휘를 동일 wording 으로 spec / 코드 / docs / UI label / 테스트 / 리뷰 노트 모두 일관 사용. Taxonomy 본부 미활성화 시 DDD/TDD 가 본 철학을 강제하는 이유.

evidence example: brainstorm round 1+2 의 핵심 용어 7 종 (Layer 1/2 / archive branch / sprint.yml / runtime-agnostic / harness-assumption / SFS-local analogy / AC7 review_high / AC8 hard failure) 을 plan + review + implement 일관 사용.

## §3. TDD — 안 돌아가면 헤드라이트 추월 X

trigger: 산출물이 안 돌아간다 (binary AC fail / 회귀 / 빌드 깨짐).

response: 안 돌아가면 **돌아가게 하는 게 먼저**. 그러기 위한 작은 failing/covering test 가 head light. test-first 가 비현실적이면 이유 기록 + 가장 작은 useful verification 먼저 실행 후 scope 확장.

evidence example: AC1~AC6+AC8 binary 자동 검증 가능 (grep / line-count / frontmatter / fenced-block grep) — implementation 의 즉시 feedback. AC7 = review_high judgment 위임.

## §4. Deep Module — 테스트가 어려우면 구조 개선

trigger: 테스트가 어렵다 / 작은 모듈만 잔뜩 / context overflow / "무엇을 하려 했는지" 망각.

response: shallow → **deep module** 로 구조 개선. **Deep module 설계 framework**:

- **인터페이스 = 사람 직접 설계** (`sfs brainstorm` 의 `--hard` 라운드가 user 한테 계속 생각하게 하는 이유).
- **구현 = AI 통으로** (model-profiles.yaml `execution_standard` tier 의 implementation-worker 가 책임. 정확 mapping 은 `model-profiles.yaml` SSoT).
- **검증 = interface 단위** — 단 도메인에 따라 안쪽까지: 보험 / 금융 / 보안 critical 모듈은 internal 까지 (per-domain escalation depth = `divisions.yaml` 위임).
- **Shallow module = 복잡성 증가** + AI agent 가 스스로 갇힘 (작은 모듈 만 잔뜩 → 탐색 시간 ↑ → context overflow → context rot → "무엇을 하려 했는지" 망각).
- **Deep module = code 탐색 → 관련 코드 묶기 → testable + 경계 단순**.

evidence example: 본 0.6.0 sprint 자체가 4 deep module 산출 (SFS-PHILOSOPHY / storage-architecture / migrate-artifacts / improve-codebase-architecture). 실 코드 / script 는 별 implement sprint 위임 (gray-box).

## §5. Gray Box — 뇌가 못 따라가면 위임

trigger: 사용자 brain 가 implementation detail 다 따라가기 무리 / interface 결정 vs 내부 구현이 섞임.

response: **interface = user 가 직접 결정** (gray-box public surface). **internal 구현 detail = AI worker 가 fill** (gray-box opaque interior). Plan §5 Sprint Contract 의 "사용자 최종 결정이 필요한 지점" 가 gray-box 경계.

evidence example: brainstorm 7/7 lock + plan 3 user decisions = user 가 interface 결정. spec 본문 wording / fenced-block detail / file path schema 정확치 = AI worker fill.

## §6. Daily System Design — 매일 system 설계에 투자

trigger: 모델 / runtime / 도메인 / scale 변화. 매일.

response: harness / 6 철학 / Deep Module / Gray Box / SSoT structure 를 **매일 1 step 재점검**. 모델 발전 시 이전 가정이 낡아지므로 (예: `gpt-5.5` 출시 시 sprint 분해 강도 약화 가능 — Anthropic harness-assumption blog reference 참조). 본 sprint 자체가 본 철학의 daily evidence.

> **harness-assumption 메타 철학** (Anthropic blog reference, ≤15 단어 paraphrase): "하네스의 모든 구성 요소는 모델이 혼자 할 수 없는 것을 가정". 모델 업데이트마다 그 가정 재점검.

---

## §7. Model Profile Cross-Reference (R5 inline)

본 SSoT 는 의미 layer (interface = C-Level / 구현 = worker / 검증 = evaluator) 만 명시. **실 model / runtime / tier mapping 은 본 파일에 복제 금지** — `model-profiles.yaml` 이 tier mapping SSoT (R-D1 정합).

1-line 의 cross-ref: 구현은 `execution_standard` tier, 정확 mapping 은 `model-profiles.yaml`. validator 도메인별 escalation depth (보험 / 금융 / 보안 critical = 안쪽까지 검증) 는 `divisions.yaml` 의 도메인 단위 SSoT 위임.

## §8. SFS-Local 3-Role Analogy (R7 inline)

본 SFS 의 CEO (brainstorm/plan G0~G1) + CTO Generator (implement G2~G4) + CPO Evaluator (review G5~G6) 3-role 구조는 **SFS 자체의 design** 이다. 본 mapping 자체를 외부 출처로 attribute 하지 않는다 — 위 §6 의 harness-assumption 메타 철학과 정합 / 영감 받음 (SFS-local analogy).

| SFS-Local 3-Role (SFS 자체 design) | 책임 (의미 layer) |
|---|---|
| CEO | brainstorm G0 + plan G1 (interface 결정 = user) |
| CTO Generator | implement G2~G4 (구현 = AI worker) |
| CPO Evaluator | review G5~G6 (검증) |

실 model / tier mapping 은 §7 정합 — `model-profiles.yaml` SSoT 에서 확인. Sprint Contract (Plan §5) 가 Generator ↔ Evaluator 선 협상의 SSoT.

## §9. External References

- Anthropic harness-assumption blog: <https://claude.com/ko-kr/blog/harnessing-claudes-intelligence> — §6 의 메타 철학 출처. 직접 인용 ≤15 단어 가드. 어떤 specific 3-role / agent terminology 도 본 출처로 attribute 하지 않는다 (Codex round 2~4 cross-instance verify 정합).
