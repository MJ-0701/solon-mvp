---
doc_id: decisions-template-index
title: "decisions-template/ — `/sfs decision` ADR-full 템플릿"
visibility: oss-public
---

# decisions-template/

> `/sfs decision <title>` 호출 시 본 디렉토리의 `ADR-TEMPLATE.md` 가 `.sfs-local/decisions/<id>-<kebab>.md` 로 cp + placeholder 치환되어 신설된다. WU-26 §1 spec verbatim.

## 파일

| 파일 | 역할 | placeholder |
|:--|:--|:--|
| `ADR-TEMPLATE.md` | ADR-full 5 섹션 (Context / Decision / Alternatives / Consequences / References) | `{{DECISION_ID}}` (4-자리 zero-pad), `{{TITLE}}` (사용자 인자), `{{NOW}}` (ISO8601+TZ) |

## 산출물 (`.sfs-local/decisions/`)

`/sfs decision` 이 신설하는 산출물 디렉토리 spec:

- 파일명 = `<id>-<kebab-slug>.md` (예: `0001-rls-policy-on-shared-tables.md`)
- id 자동 부여: 가장 큰 기존 id + 1, 시작 0001 (sfs-common.sh `next_decision_id` 함수)
- 명시 override: `/sfs decision <title> --id 0042` (충돌 시 exit 1)
- frontmatter `status` 진행: `proposed` → `accepted` / `rejected` / `deprecated` / `superseded` (사용자가 직접 갱신, 본 cycle 자동화 0)

## 관계

- **light 대안**: `sprint-templates/decision-light.md` (4 섹션 ADR-light, sfs.md adapter Claude-driven fallback 모드용. 짧은 결정 / 큰 영향 없는 것 / fallback 시나리오).
- **full**: 본 `decisions-template/ADR-TEMPLATE.md` (5 섹션 ADR-full, sfs-decision.sh 어댑터 우선 사용. 큰 결정 / Alternatives 명시 필요).

## 명명 규칙

- `<id>` = 4-자리 zero-pad sequential (`0001`, `0002`, ..., `0099`, `0100`).
- `<kebab>` = title 의 kebab-case 변환 (소문자 + `[a-z0-9]` 외는 `-` 로, 연속 `-` 압축, 양 끝 `-` 제거).
- 한글/특수문자 입력 시 `[a-z0-9]` 외 모두 `-` 로 변환되어 슬러그가 비면 exit 7 (사용자에게 영문 title 권장 stderr).
