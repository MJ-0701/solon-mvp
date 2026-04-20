---
doc_id: sfs-v0.4-appendix-template-brainstorm
title: "Initiative Brainstorm Template (G0 산출물)"
version: 0.4
status: draft
last_updated: 2026-04-19
audience: [c-level, division-heads]

depends_on:
  - sfs-v0.4-s04-pdca-redef

defines:
  - template/brainstorm

references:
  - principle/brainstorm-gate-mandatory (defined in: s02)
  - gate/g0-brainstorm (defined in: s04)
  - concept/initiative (defined in: s04)
  - principle/self-validation-forbidden (defined in: s02)

affects: []
---

# Initiative Brainstorm Template (G0 산출물)

> 이 파일은 **Initiative 진입 시점**의 G0 Brainstorm Gate 통과 산출물 템플릿이다.
> Sprint decomposition 직전에 작성하며, **6 필드 모두 채워야 G0 Pass**.
> 위치: `docs/00-initiatives/{id}-{name}/brainstorm.md`
>
> ⚠️ **Sprint 단위마다 brainstorm 강제 X.** Initiative 1회당 brainstorm 1회. (원칙 9, §2.9)

---

## YAML 본체 (복사 후 채워서 사용)

```yaml
---
doc_id: brainstorm-{initiative_id}
initiative_id: INI-001
declared_by: c-level/ceo
declared_at: 2026-04-19
status: draft  # draft | g0-passed | g0-failed | g0-reopened

intent: |
  (한 줄 — 이 Initiative로 풀려는 진짜 문제. measurable 권장)
  예: "결제 미지원으로 첫 결제 단계 conversion 30% 누수 → 결제 도입으로 회복"

alternatives_considered:
  - option: "PG 직접 연동 (KG이니시스)"
    pros: "수수료 낮음, 통제력 높음"
    cons: "구현 6주, PCI 컴플라이언스 부담"
    rejected_reason: "Phase 1 dogfooding 단계 적합도 낮음"
  - option: "토스 페이먼츠 SDK"
    pros: "구현 1주, 컴플라이언스 위임"
    cons: "수수료 +0.3%"
    rejected_reason: null  # 채택
  # 최소 2개 검토 필수 — 단일안 진입은 G0 Fail

scope_boundary:
  in_scope:
    - "신용/체크카드 결제만 지원"
    - "한국 원화(KRW) 단일 통화"
    - "단건 결제만 (구독/할부 X)"
  out_of_scope:
    - "해외 카드 (Phase 2 후보)"
    - "가상계좌, 무통장입금"
    - "환불 자동화 (수동 운영 우선)"

success_signal:
  measurable: true
  metric: "첫 결제 성공률 ≥ 95% (1주 측정)"
  evidence_source: "L1 log: payment.attempt + payment.success 비율"
  fallback_if_unmet: "Initiative 종료 보류, hardening sprint 추가"

sprint_decomposition:
  - sprint_id: sprint-5
    name: "결제 MVP"
    duration_weeks: 2
    primary_divisions: [pm, design, dev, qa, infra, taxonomy]
    primary_outputs: ["PRD", "결제 화면", "결제 API", "테스트", "모니터링", "용어 정의"]
  - sprint_id: sprint-6
    name: "결제 hardening"
    duration_weeks: 2
    primary_divisions: [dev, qa, infra]
    primary_outputs: ["에러 케이스 보강", "부하 테스트", "alarm 룰"]
  # Sprint 1~3개 권장. 4개 이상 시 Initiative 분할 검토

risk_pre_register:
  - risk: "토스 SDK 갑작스러운 정책 변경"
    likelihood: low
    impact: high
    mitigation: "PG 직연동 fallback 설계서 문서화"
  - risk: "결제 실패 시 사용자 이탈"
    likelihood: medium
    impact: medium
    mitigation: "QA 본부 시나리오에 실패 UX 포함"
  # mitigation 없는 risk 등재 금지

g0_review:
  reviewers: ["c-level/cpo", "evaluator/intent-discovery-validator"]
  reviewed_at: null
  verdict: null  # pass | partial | fail
  feedback: null
---
```

---

## 6 필드 작성 가이드

### 1. `intent` (1줄, measurable 권장)

"왜 이 Initiative가 필요한가" 를 1줄로. 측정 가능한 문제 진술 권장.

| 평가 | 예시 |
|:---:|------|
| ❌ | "결제가 필요해서" |
| ❌ | "더 좋은 UX를 위해" (측정 불가) |
| ✅ | "결제 미지원이 첫 결제 단계 30% 이탈 야기" |
| ✅ | "에러 응답시간 P95 800ms → 200ms로 단축 필요 (PMF 가설 검증 차단됨)" |

### 2. `alternatives_considered` (≥2개 필수)

**최소 2개 대안 검토**. 단일안은 G0 Fail.
- 1개 채택 + 나머지 `rejected_reason` 명시
- "대안이 없다"는 항상 G0 Fail 신호 (intent discovery 부족)
- "do nothing" 도 유효한 대안 — 명시적으로 비교

### 3. `scope_boundary` (양방향 필수)

- `in_scope`, `out_of_scope` 모두 작성. `out_of_scope`만 비어있으면 over-engineering 위험.
- "Phase 2 후보" 표기는 explicit deferral (의도된 미루기, OK)

### 4. `success_signal` (measurable=true 필수)

- 측정 가능 metric 필수. "잘 되면 좋겠다" 류는 G0 Fail.
- `evidence_source`: L1/L2 어디서 측정 가능한지 명시 (관측성 §8 채널 ID)
- `fallback_if_unmet`: 미달 시 다음 행동

### 5. `sprint_decomposition` (1~3개 권장)

- 1 Initiative = 1~3 Sprint baseline
- 4+ Sprint = Initiative 분할 검토 신호 (CEO 판단)
- 각 sprint마다 `primary_divisions` + `primary_outputs` 필수 (CEO Sprint Plan 작성 기반)

### 6. `risk_pre_register`

- 알려진 리스크 사전 등록. **mitigation 없는 risk 등재 금지.**
- Phase 1 dogfooding 시 누락된 risk가 발생하면 learning log에 추가 → 다음 Initiative G0 시 참조 (H6 자기학습)

---

## G0 Pass 기준

| 항목 | 기준 | 미달 시 |
|------|------|--------|
| 6 필드 완결 | 모두 채워짐 (null/빈 값 X) | G0 Fail |
| `intent` measurable | 측정 가능 진술 | G0 Partial → CEO 보강 후 재제출 |
| `alternatives_considered` ≥ 2 | 최소 2개 대안 검토 | G0 Fail (intent discovery 부족) |
| `success_signal.measurable` | true + metric 명시 | G0 Fail |
| `sprint_decomposition` 1~3개 | 각 sprint primary_divisions/outputs 명시 | G0 Partial |
| Tier 3 평가 | CPO + intent-discovery-validator pass | Tier 위반 시 G0 Fail |

→ 5/5 만족 + Tier 3 pass 시 G0 Pass → CEO가 Sprint Plan 작성 진입.

---

## 자기검증 금지(원칙 2)와의 관계

G0 평가도 Tier 3 (외부 evaluator) 원칙 적용:
- brainstorm 작성자 = CEO (operator)
- G0 평가자 = CPO + `intent-discovery-validator` (Phase 1 추가 예정 신규 evaluator)
- 작성자와 평가자 분리 — `principle/self-validation-forbidden` (§2.2) 준수

---

## Initiative ID 명명 규칙

- 형식: `INI-{NNN}` (3자리 zero-padded, 1부터)
- 디렉토리: `docs/00-initiatives/{INI-NNN}-{kebab-case-name}/`
- 예: `docs/00-initiatives/INI-001-payment-domain/brainstorm.md`

---

*(끝)*
