---
doc_id: sprints-index
title: "sprints/ — WU (Work Unit) 파일 목록 (v2)"
visibility: raw-internal
updated: 2026-04-21
---

# sprints/ — WU 파일 인덱스

> **역할**: WU 파일 (`WU-<id>.md`) SSoT. WU 정의는 `CLAUDE.md §2.1` 참조.
> **진입**: `PROGRESS.md` → `current_wu_path` 로 해당 WU 파일 직행.
> **규율**: 1 파일 ≤ 200 line 기본 (~300 유연), 초과 시 `WU-<id>/` 디렉토리로 sub-step 분리.

---

## 활성 WU (status: in_progress / pending)

| WU | title | status | opened | session | path |
|:--:|:---|:-:|:---|:---|:---|
| WU-15.1 | WU-15 forward sha backfill + README §11.1 glossary | in_progress | 2026-04-21 | (본 세션) | [WU-15.md](WU-15.md) (refresh 전용, 독립 파일 없음) |

## 완료 WU (status: done) — v2 네이티브

| WU | title | final_sha | opened | closed | session | path |
|:--:|:---|:---|:---|:---|:---|:---|
| WU-15 | Workflow v2 인프라 설정 | `aa0a354` | 2026-04-21 | 2026-04-21 | relaxed-vibrant-albattani | [WU-15.md](WU-15.md) |

## 완료 WU (status: done) — Backfill 대상 (WU-16)

> WU-7 ~ WU-14.1 은 `WORK-LOG.md` 에 아직 index 형태로만 존재. WU-16 에서 각 WU 독립 파일로 이관 예정. Backfill 완료 전까지 이 섹션은 placeholder.

| WU | title | final_sha | note |
|:--:|:---|:---|:---|
| WU-7 | plugin.json 스키마 정합성 | `ec263c5` | WORK-LOG 에 존재, 이관 대기 |
| WU-7.1 | WU-7 sha backfill | `af306e0` | WORK-LOG 에 존재, 이관 대기 |
| WU-14 | context-reset 대비 infrastructure | `42e3719` | WORK-LOG 에 존재, 이관 대기 |
| WU-14.1 | WU-14 sha backfill | `853373f` | WORK-LOG 에 존재, 이관 대기 |
| WU-10 | branches/*.yaml 6 본부 schema 정합성 | `3c8cac0` | WORK-LOG 에 존재, 이관 대기 |
| WU-10.1 | WU-10 sha backfill | `ed0ac37` | WORK-LOG 에 존재, 이관 대기 |

---

## 명명 규칙

- 파일: `WU-<id>.md` (id 는 순차 번호, 예: `WU-15.md`)
- 200 line 초과 시: `WU-<id>/` 디렉토리 생성 + `step-1.md`, `step-2.md`, ... 로 분리 + `_meta.md` (frontmatter 집중)
- Refresh WU: `WU-<id>.1.md` (forward sha backfill 전용, squash 제외)

## Frontmatter 필수 필드

`CLAUDE.md §5` 참조. 필수: `wu_id · title · status · opened_at/closed_at · session_opened/session_closed · final_sha · visibility · entry_point · depends_on_reads · files_touched · decision_points · learning_patterns_emitted · sub_steps_split`.
