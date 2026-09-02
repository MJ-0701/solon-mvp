---
doc_id: solon-product-adr-template
title: "ADR Template"
visibility: oss-public
doc_type: maintenance-template
language: ko
updated: 2026-09-02
summary: "Copyable template for a single architecture decision record."
load_when: "Read when creating a new ADR under docs/maintenance/adr/."
---

<!--
ADR Template — 복사해서 사용:
1. 이 파일을 docs/maintenance/adr/ADR-{NNNN}-{slug}.md 로 복사한다
   (NNNN = adr-index.md 최대 번호 + 1, 첫 ADR은 0001).
2. 모든 {placeholder}를 채운다. 해당 없음이면 "None"으로 명시한다
   (섹션 삭제 금지).
3. 같은 변경(commit/PR)에서 docs/maintenance/adr-index.md 에 행을 추가한다.
운영 규칙: docs/maintenance/adr-policy.md
-->

# ADR-{NNNN}: {결정 제목 — 명사구 한 줄}

## Metadata

| Field | Value |
|---|---|
| ID | ADR-{NNNN} |
| Status | proposed <!-- proposed / accepted / superseded / deprecated --> |
| Owner | {개인 1명 — 이름 또는 handle} |
| Decided | {accepted 된 날 YYYY-MM-DD, proposed 동안은 None} |
| Review by | {YYYY-MM-DD — 기본 Decided + 6개월, high-risk는 + 3개월} |
| Supersedes | {ADR-XXXX 또는 None} |
| Superseded by | None |
| Tasks / Sprint | {구현 태스크 키(JIRA-KEY), sprint 식별자, 없으면 None} |

## Eligibility

{해당 gate(Irreversible / Costly / Cross-team / High-risk)와 한 줄 근거.
어느 gate에도 해당하지 않으면 이 문서는 ADR이 아니라 task log 감이다.}

## Context (immutable)

{결정 시점의 사실과 제약만 서술한다. 의견·결론을 섞지 않는다.
accepted 이후 이 섹션은 수정 금지 — 바꾸려면 새 ADR로 supersede.}

### Evidence

- {불변 참조만: commit SHA, 태그된 문서 버전, 측정 결과 스냅샷,
  날짜 박힌 회의록 링크}

## Decision Drivers

- {결정을 실제로 가른 기준, 우선순위 순 — 예: 운영 비용, 마이그레이션
  리스크, 팀 숙련도}

## Considered Alternatives

채택안을 포함해 최소 2개. 각 대안에 trade-off를 남긴다.

### A. {대안 이름} — 채택

- 장점: {…}
- 단점 / 비용: {…}

### B. {대안 이름} — 기각

- 장점: {…}
- 단점 / 비용: {…}
- 기각 사유: {Decision Drivers 기준으로 한 줄}

## Decision

{채택한 것과 적용 범위를 현재형 한 문단으로.
"우리는 {X}를 {범위}에 적용한다. {핵심 이유}."}

## Consequences

### Positive

- {…}

### Negative / Risks

- {감수하기로 한 비용과 리스크 — "없음"이라고 쓰지 말 것}

### Follow-ups

- [ ] {후속 작업 — 태스크 키 포함, 완료 시 체크}
