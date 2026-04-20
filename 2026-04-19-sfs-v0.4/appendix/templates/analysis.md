---
doc_id: sfs-v0.4-appendix-template-analysis
title: "PDCA Analysis (Check) Template"
version: 0.4
status: draft
last_updated: 2026-04-19
audience: [division-heads, evaluators, qa]
template_type: pdca-analysis

depends_on:
  - sfs-v0.4-s04-pdca-redef
  - sfs-v0.4-s05-gate-framework

defines:
  - template/analysis.md

references:
  - template/plan.md (defined in: appendix/templates/plan.md)
  - template/design.md (defined in: appendix/templates/design.md)
  - schema/gate-report-v1 (defined in: s05)
  - formula/g4-per-division (defined in: s05)

affects: []
---

# [PDCA-{ID}] Analysis (Check) — {Feature Name}

> **Template usage**: Do 완료 후 G4 Check Gate 결과 정리. 5-Axis 점수 포함.

---

## Frontmatter

```yaml
---
pdca_id: PDCA-042
phase: check
status: g4-pending | g4-passed | g4-failed
linked_design: PDCA-042.design.md
gate_report_ref: docs/02-gates/PDCA-042/G4.md
---
```

---

## 1. G4 점수 (formula 적용 결과)

| 본부 | Formula | 점수 |
|------|---------|------|
| (해당 본부) | gap-detector × 0.4 + 5-Axis × 0.6 (예) | 87 |

---

## 2. AC 충족 여부

| AC ID | 충족? | 증거 (테스트/측정) |
|-------|------|----------------|
| AC-001 | ✓ | qa-monitor log #1234 |
| AC-002 | △ | 부분 충족, 엣지 케이스 fail |
| AC-003 | ✗ | **Escalate 필요** |

---

## 3. CPO 5-Axis 평가

| Axis | 점수 | 메모 |
|------|------|------|
| Business Impact | 85 | ... |
| User Value | 90 | ... |
| Technical Soundness | 80 | ... |
| Maintainability | 88 | ... |
| Future-proof | 75 | ... |

> Axis 정의 → §5.6

---

## 4. Failure Mode (해당 시)

- Mode: SUCCESS | FAIL-FIXABLE | FAIL-HARD | STALL | CONFLICT | TIMEOUT | ABORT
- 영향 받는 AC: [AC-003]
- 영향 받는 Design: [DES-005]
- 영향 받는 Impl: [IMPL-008]

---

## 5. Escalation 필요 여부

- [ ] FAIL-FIXABLE → 같은 본부 내 재작업
- [ ] FAIL-HARD → **Escalate-Plan (Case-α)** → escalation-record.yaml 작성
- [ ] CONFLICT → 5-option protocol → 본부장 + CEO 협의
- [ ] ABORT → **새 PDCA (Case-β)**

→ Escalate 필요 시: [appendix/schemas/escalation.schema.yaml](../schemas/escalation.schema.yaml) 따라 작성.

---

## 6. Recommendations

[evaluator가 자동 채움 + 본부장이 검토]

---

*(template 끝)*
