---
doc_id: solon-product-adr-index
title: "ADR Index — Registry"
visibility: oss-public
doc_type: maintenance-doc
language: ko
updated: 2026-09-02
summary: "Searchable registry for architecture decision records."
load_when: "Read when creating, locating, accepting, superseding, or deprecating an ADR."
---

# ADR Index — Registry

모든 ADR의 탐색용 레지스트리다. SSoT는 각 ADR 파일이며, ADR 파일의
생성·상태 변경과 본 레지스트리 갱신은 **같은 변경(commit/PR)** 에서
이뤄져야 한다. 운영 규칙: [`adr-policy.md`](adr-policy.md) ·
템플릿: [`templates/adr-template.md`](templates/adr-template.md)

## Column Spec

| Column | 내용 |
|---|---|
| ID | `ADR-NNNN`. 단조 증가, 재사용 금지. 다음 번호 = 아래 표의 최대 번호 + 1 (첫 ADR은 `ADR-0001`) |
| Title | ADR 제목 (파일의 H1과 동일하게 유지) |
| Status | `proposed` / `accepted` / `superseded` / `deprecated` 중 하나 |
| Owner | 개인 1명 (승계 발생 시 여기서 갱신) |
| Decided | accepted 된 날 (YYYY-MM-DD), 그 전에는 `-` |
| Review by | 다음 리뷰 기한 (YYYY-MM-DD), 종결 상태(superseded/deprecated)면 `-` |
| Supersedes | 이 ADR이 대체한 ADR ID, 없으면 `-` |
| Superseded by | 이 ADR을 대체한 ADR ID, 없으면 `-` |
| File | `adr/ADR-NNNN-{slug}.md` 상대 링크 |

행은 ID 오름차순으로 정렬한다.

## Registry

| ID | Title | Status | Owner | Decided | Review by | Supersedes | Superseded by | File |
|----|-------|--------|-------|---------|-----------|------------|---------------|------|

_(등록된 ADR 없음 — 첫 ADR은 `ADR-0001`이며, 첫 행 추가 시 이 문구를 삭제한다.)_
