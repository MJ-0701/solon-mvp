---
doc_id: sfs-v0.4-appendix-template-report
title: "PDCA Report (Act) Template"
version: 0.4
status: draft
last_updated: 2026-04-19
audience: [division-heads, c-level]
template_type: pdca-report

depends_on:
  - sfs-v0.4-s04-pdca-redef
  - sfs-v0.4-s06-escalate-plan

defines:
  - template/report.md

references:
  - template/analysis.md (defined in: appendix/templates/analysis.md)
  - concept/h6-self-learning (defined in: s06)
  - schema/escalation-v1 (defined in: s06)

affects: []
---

# [PDCA-{ID}] Report (Act) — {Feature Name}

> **Template usage**: PDCA 종료 시 작성. H6 학습 입력으로 사용됨.

---

## Frontmatter

```yaml
---
pdca_id: PDCA-042
phase: act
status: completed | escalated | aborted
linked_analysis: PDCA-042.analysis.md
sprint_id: SPR-2026-04-W3
duration_days: 3
final_g4_score: 87
---
```

---

## 1. 요약 (1 paragraph)

[본부장 작성: 무엇을 했고, 결과는, 어떤 학습이 있었는가]

---

## 2. 산출물 링크

- Plan: [PDCA-042.plan.md](./PDCA-042.plan.md)
- Design: [PDCA-042.design.md](./PDCA-042.design.md)
- Analysis: [PDCA-042.analysis.md](./PDCA-042.analysis.md)
- Code: [git ref or PR link]

---

## 3. AC 최종 상태

| AC ID | 최종 상태 | 비고 |
|-------|---------|------|
| AC-001 | ✓ 충족 | — |
| AC-002 | △ 부분 충족 | edge case는 다음 Sprint backlog로 |
| AC-003 | ↺ Escalate된 후 충족 (v2 브랜치) | ESC-2026-04-19-001 참조 |

---

## 4. Escalation 발생 (해당 시)

| Escalation ID | Case | Resolution | Outcome |
|--------------|------|-----------|---------|
| ESC-2026-04-19-001 | alpha | alpha-1 (AC-003 reopen) | resolved |

→ 상세: [docs/03-analysis/escalations/ESC-2026-04-19-001.yaml](../../docs/03-analysis/escalations/)

---

## 5. 학습 (H6 입력)

```yaml
learning_records:
  - pattern_id: PTRN-0042
    pattern_summary: "이메일 발송 timing 측정 부재 → AC measurable 약함"
    occurrence_count: 3   # 최근 3 PDCA에서 같은 패턴
    add_to_validator: plan-validator
    new_check: "이메일/알림 관련 AC는 timing window를 measurable에 명시"
    proposed_at: 2026-04-19T18:00:00Z
    accepted: false       # G5 Sprint Retro에서 결정
```

> G5 Sprint Retro에서 자동 집계되어 다음 Sprint의 plan-validator 체크리스트에 반영 (§6.6).

---

## 6. Sprint 컨트리뷰션

- 이 PDCA가 Sprint {SPR-XXX}에 어떻게 기여했는가
- Sprint 목표 대비 임팩트

---

## 7. 다음 PDCA / Backlog

- [ ] AC-002 edge case 처리 → [PDCA-XXX]
- [ ] H6 패턴 PTRN-0042 검증

---

*(template 끝)*
