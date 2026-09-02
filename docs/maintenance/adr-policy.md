---
doc_id: solon-product-adr-policy
title: "ADR Policy — Architecture Decision Record 운영 정책"
visibility: oss-public
doc_type: maintenance-doc
language: ko
updated: 2026-09-02
summary: "Eligibility, lifecycle, ownership, and registry rules for ADRs."
load_when: "Read before creating or changing an architecture decision record."
---

# ADR Policy — Architecture Decision Record 운영 정책

스프린트 작업 중 내려지는 구조적 결정을 기록·추적하기 위한 최소 규칙이다.
템플릿: [`templates/adr-template.md`](templates/adr-template.md) ·
레지스트리: [`adr-index.md`](adr-index.md)

## 1. Eligibility Gate — 작성 대상 판정

아래 gate 중 **하나라도** 해당하면 ADR을 작성한다 (MUST):

| Gate | 기준 |
|---|---|
| Irreversible | 되돌리기가 사실상 불가능하거나 되돌리는 데 1 sprint 이상 필요 (예: 데이터 마이그레이션, 외부 공개 API 계약, 저장 포맷) |
| Costly | 도입·전환 비용이 큼 (유료 인프라/벤더 계약, 대규모 리라이트) |
| Cross-team | 두 개 이상의 팀·도메인 경계에 영향 (공유 스키마, 인증 방식, 조직 표준 변경) |
| High-risk | 실패 시 보안 사고·데이터 손실·가용성 저하로 이어질 수 있음 |

**작성하지 않는다**: 사소하고 되돌리기 쉬운 선택 (네이밍, 로컬 리팩토링,
라이브러리 patch 버전 선택, 내부 구현 디테일). 이런 결정은 task log
(커밋 메시지, 태스크 코멘트)에 남기고 ADR로 격상하지 않는다.

판정이 애매하면 **작성한다** — 기록 비용이 재논의 비용보다 싸다.
어느 gate에 해당하는지는 ADR 본문 `## Eligibility` 섹션에 한 줄 근거와
함께 명시한다.

## 2. Stable ID와 파일 위치

- ID 형식: `ADR-NNNN` (4자리 zero-padding, 예: `ADR-0001`).
- 다음 번호 = `adr-index.md` 최대 번호 + 1. 단조 증가하며 **재사용·재부여
  금지**. deprecated 되어도 번호는 영구 결번이다.
- 파일 경로: `docs/maintenance/adr/ADR-NNNN-{slug}.md`
  (slug는 영문 kebab-case, 5단어 이내). merge 후 파일명 변경 금지.
- 동시 작업으로 번호가 충돌하면 나중에 merge 되는 쪽이 다음 번호로 옮긴다.

## 3. Lifecycle

상태는 다음 4개만 사용한다:

```
proposed ──▶ accepted ──▶ superseded
    │            │
    └─────┬──────┘
          ▼
     deprecated
```

| Status | 의미 | 진입 조건 |
|---|---|---|
| `proposed` | 제안됨, 논의 중 | 최초 작성 시 기본값 |
| `accepted` | 팀이 채택, 구현의 유효한 근거 | owner 외 리뷰어 1인 이상 approve |
| `superseded` | 새 ADR로 대체됨 | 대체 ADR이 accepted 되는 같은 변경에서 전환 |
| `deprecated` | 대체 없이 폐기 (미채택 기각 포함) | 리뷰에서 기각되었거나 유효성 상실 |

- `superseded` / `deprecated` 는 종결 상태다. 되살리려면 새 ADR을 쓴다.
- **되돌릴 수 없는 단계(마이그레이션 실행, 외부 계약 배포 등)는 해당
  ADR이 `accepted` 상태가 된 뒤에만 실행한다.**

## 4. Immutability — 불변 규칙

`accepted` 이후:

- **동결 (수정 금지)**: `Eligibility`, `Context`, `Evidence`,
  `Decision Drivers`, `Considered Alternatives`, `Decision`.
  내용을 바꾸려면 새 ADR로 supersede 한다 (§6).
- **갱신 허용 (metadata)**: `Status`, `Superseded by`, `Review by`,
  `Tasks / Sprint` 링크 추가, `Follow-ups` 체크박스 상태.
- Evidence 링크는 **불변 참조**여야 한다: commit SHA, 태그된 문서 버전,
  날짜 박힌 스냅샷·회의록. "main 브랜치의 현재 파일" 같은 움직이는
  링크는 금지.

## 5. 필수 필드

템플릿([`templates/adr-template.md`](templates/adr-template.md))의 모든
섹션이 필수다. 해당 없음이면 비우지 말고 `None`으로 명시한다. 요약:

- Metadata: ID / Status / Owner / Decided / Review by / Supersedes /
  Superseded by / Tasks · Sprint
- Eligibility (해당 gate + 근거)
- Context (immutable) + Evidence
- Decision Drivers
- Considered Alternatives (채택안 포함 최소 2개, trade-off와 기각 사유)
- Decision
- Consequences (Positive / Negative · Risks / Follow-ups)

## 6. Supersession — 대체 절차

1. 새 ADR을 작성하고 Metadata에 `Supersedes: ADR-XXXX` 를 기입한다.
2. 새 ADR이 `accepted` 되는 **같은 변경에서** 구 ADR의 `Status`를
   `superseded`로 바꾸고 `Superseded by: ADR-YYYY` 를 기입한다.
3. `adr-index.md`의 두 행을 같은 변경에서 갱신한다.
4. 부분 대체도 전체 supersede로 처리한다 — 여전히 유효한 나머지 결정은
   새 ADR에 다시 서술한다 (반쪽만 유효한 문서를 남기지 않는다).

## 7. Owner / Date / Review Schedule

- Owner는 **개인 1명** (팀 이름 금지). owner가 떠나면 index에서 승계자를
  지정한다.
- `accepted` 전환 시 `Decided` 날짜와 `Review by` 날짜를 기입한다.
  기본: Decided + 6개월, High-risk gate 해당 건은 Decided + 3개월.
- `Review by` 도래 시 owner가 판정한다: 유지(`Review by` 연장) /
  supersede / deprecate. 결과는 ADR 파일과 index에 함께 반영한다.

## 8. Sprint 연동

- ADR은 영향받는 작업의 구현 착수 전, 늦어도 같은 sprint 안에 `proposed`
  로 올린다. 리뷰 채널은 일반 PR 리뷰와 동일하다.
- Metadata `Tasks / Sprint` 에 구현 태스크 키(JIRA-KEY)와 sprint
  식별자를 링크한다. 역방향으로, 결정을 구현하는 커밋·PR 본문에
  `ADR-NNNN` 을 표기한다.
- Follow-ups 는 체크박스 + 태스크 키로 남기고, 완료 시 체크한다.
- Gate 3 (Plan)에서 eligible ADR을 결정·기록하고, Gate 6 (Review)의
  report/retro evidence 안에 **이미 존재하는** `ADR-NNNN | 경로 | 한 줄
  rationale` 항목만 남긴다. Gate 7의 기본 `sfs retro` close가 그 항목을
  `daily-handoff.md`/`.html` Decisions projection으로 자동 발행한다. ADR은
  handoff를 위해 새로 만들거나 추측하지 않는다. SSoT는 ADR 파일이고 HTML은
  재생성되는 파생 산출물이다. 흐름:
  [`context/commands/daily.md`](../../templates/.sfs-local-template/context/commands/daily.md)
  의 MANAGER_HANDOFF.

## 9. Registry 운영

- 모든 ADR은 [`adr-index.md`](adr-index.md)에 정확히 한 행을 가진다 (MUST).
- SSoT는 각 ADR 파일이고 index는 탐색용 사본이다. 단, **ADR 생성·상태
  변경과 index 갱신은 반드시 같은 변경(commit/PR)에서** 이뤄져야 한다.
  index에 없는 ADR, ADR 파일 없는 index 행은 둘 다 결함이다.
