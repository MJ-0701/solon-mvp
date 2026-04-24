---
doc_id: sprints-index
title: "sprints/ — WU (Work Unit) 파일 목록 (v2)"
visibility: raw-internal
updated: 2026-04-24   # WU-19 Phase 1 MVP W0 executable scripts 반영
---

# sprints/ — WU 파일 인덱스

> **역할**: WU 파일 (`WU-<id>.md`) SSoT. WU 정의는 `CLAUDE.md §2.1` 참조.
> **진입**: `PROGRESS.md` → `current_wu_path` 로 해당 WU 파일 직행.
> **규율**: 1 파일 ≤ 200 line 기본 (~300 유연), 초과 시 `WU-<id>/` 디렉토리로 sub-step 분리.

---

## 활성 WU (status: in_progress / pending)

| WU | title | status | opened | session | path |
|:--:|:---|:---|:---|:---|:---|
| WU-19 | Phase 1 MVP W0 Executable Scripts (setup-w0.sh + verify-w0.sh) | in_progress | 2026-04-24 | ecstatic-intelligent-brahmagupta | [WU-19.md](WU-19.md) |

## 완료 WU (status: done) — v2 네이티브

| WU | title | final_sha | opened | closed | session | path |
|:--:|:---|:---|:---|:---|:---|:---|
| WU-15 | Workflow v2 인프라 설정 | `aa0a354` | 2026-04-21 | 2026-04-21 | relaxed-vibrant-albattani | [WU-15.md](WU-15.md) |
| WU-15.1 | WU-15 sha backfill + README §11.1 glossary | `acfae03` | 2026-04-21 | 2026-04-21 | relaxed-vibrant-albattani | [WU-15.md](WU-15.md) (refresh 전용) |
| WU-16 | 기존 WU (WU-7 ~ WU-14.1) 이관 + sessions/ 3 retrospective | `2b8b69e` | 2026-04-24 | 2026-04-24 | brave-hopeful-euler | [WU-16.md](WU-16.md) |
| WU-16.1 | WU-16 sha backfill + sessions/2026-04-24 retrospective 신설 | `227f900` | 2026-04-24 | 2026-04-24 | brave-hopeful-euler | [WU-16.md](WU-16.md) (refresh 전용) |
| WU-17 | HANDOFF / BRIEFING 축소 (v2 참조 구조 전환, -77.6%) | `083cfe1` | 2026-04-24 | 2026-04-24 | ecstatic-intelligent-brahmagupta | [WU-17.md](WU-17.md) |
| WU-17.1 | WU-17 sha backfill + sprints/_INDEX.md 이동 | `d5681fa` | 2026-04-24 | 2026-04-24 | ecstatic-intelligent-brahmagupta | [WU-17.md](WU-17.md) (refresh 전용) |
| WU-18 | Phase 1 MVP W0 Pre-Arming (templates + plugin-wip + QUICK-START) | `d200299` | 2026-04-24 | 2026-04-24 | ecstatic-intelligent-brahmagupta | [WU-18.md](WU-18.md) |
| WU-18.1 | WU-18 sha backfill + sprints/_INDEX.md 이동 | `12b9a72` | 2026-04-24 | 2026-04-24 | ecstatic-intelligent-brahmagupta | [WU-18.md](WU-18.md) (refresh 전용) |

## 완료 WU (status: done) — v1 → v2 이관 (WU-16 backfill)

> WU-16 에서 `WORK-LOG.md` append-style entry 를 독립 파일로 이관. 본문은 원본 entry 를 거의 그대로 복사 + frontmatter 추가 (Option β minimal).

| WU | title | final_sha | opened | closed | session | path |
|:--:|:---|:---|:---|:---|:---|:---|
| WU-7 | plugin.json 샘플 분리 (Option β skeleton+sample) | `ec263c5` | 2026-04-21 | 2026-04-21 | serene-fervent-wozniak | [WU-7.md](WU-7.md) |
| WU-7.1 | WU-7 sha backfill | `af306e0` | 2026-04-21 | 2026-04-21 | serene-fervent-wozniak | [WU-7.1.md](WU-7.1.md) |
| WU-10 | branches/*.yaml 6 본부 schema 정합성 (Option β) | `3c8cac0` | 2026-04-21 | 2026-04-21 | serene-fervent-wozniak | [WU-10.md](WU-10.md) |
| WU-10.1 | WU-10 sha backfill | `ed0ac37` | 2026-04-21 | 2026-04-21 | serene-fervent-wozniak | [WU-10.1.md](WU-10.1.md) |
| WU-13 | NEXT-SESSION-BRIEFING.md 신설 (9-섹션) | `101030f` | 2026-04-20 | 2026-04-20 | funny-compassionate-wright | [WU-13.md](WU-13.md) |
| WU-13.1 | WU-13 sha backfill | `899643a` | 2026-04-20 | 2026-04-21 | funny-compassionate-wright | [WU-13.1.md](WU-13.1.md) |
| WU-14 | context-reset 대비 infrastructure (tmp/ + PROGRESS.md v1) | `42e3719` | 2026-04-21 | 2026-04-21 | serene-fervent-wozniak | [WU-14.md](WU-14.md) |
| WU-14.1 | WU-14 sha backfill | `853373f` | 2026-04-21 | 2026-04-21 | serene-fervent-wozniak | [WU-14.1.md](WU-14.1.md) |

## 완료 WU (status: done) — v1 형식 (WORK-LOG.md 원본 유지, 추후 확장 이관 대기)

> 아래 WU 들은 `WORK-LOG.md` 의 append-style entry 로만 존재. 본 인덱스에서는 sha 만 참조. 독립 파일 이관은 WU-16b (필요 시) 에서.

| WU | final_sha | WORK-LOG entry |
|:--:|:---|:---|
| WU-0 (backfill) | `d034d0d` | L55-L77 |
| WU-1 | `92c2f54` | L42-L54 |
| WU-1.1 | (backfill) | — |
| WU-2 | (entry) | L78-L94 |
| WU-3 | (entry) | L95-L116 |
| WU-8 | (entry) | L117-L140 |
| WU-8.1 | (entry) | (WORK-LOG append) |
| WU-11 | `4cd07e6` | L141-L171 |
| WU-11.1 | `eed4dd1` | L172-L185 |
| WU-11.2 | `6527252` | L186-L198 |
| WU-12 | `7f8a635` | L199-L237 |
| WU-12.1 | `ff89ea1` | L238-L251 |
| WU-12.2 | `8ab660c` | L252-L269 |
| WU-12.3 | `b77fcb2` | L270-L297 |
| WU-4 | `7d982dc` | L298-L325 |
| WU-4.1 | `1c375aa` | L326-L339 |
| WU-5 | `20c3474` | L340-L363 |
| WU-5.1 | `9c4d6c0` | L364-L378 |
| WU-9 | `816d751` | L379-L408 |
| WU-9.1 | `6884bbd` | L409-L423 |

## BLOCKED

| WU | 사유 | 해결 조건 |
|:--:|:---|:---|
| WU-6 | claude-shared-config/.git IP 경계 재정리 | 사용자 결정 필요 (HANDOFF §0 참조) |

## Phase 2

| WU | 조건 |
|:--:|:---|
| WU-11 B | Phase 1 Claude 구현 안정화 후 재검토 (Claude-specific layer: 필드) |
| WU-11 C | Phase 2 Go/No-Go 결정 후 (Codex / Gemini-CLI 어댑터) |

---

## 명명 규칙

- 파일: `WU-<id>.md` (id 는 순차 번호, 예: `WU-15.md`)
- 200 line 초과 시: `WU-<id>/` 디렉토리 생성 + `step-1.md`, `step-2.md`, ... 로 분리 + `_meta.md` (frontmatter 집중)
- Refresh WU: `WU-<id>.1.md` (forward sha backfill 전용, squash 제외)

## Frontmatter 필수 필드

`CLAUDE.md §5` 참조. 필수: `wu_id · title · status · opened_at/closed_at · session_opened/session_closed · final_sha · visibility · entry_point · depends_on_reads · files_touched · decision_points · learning_patterns_emitted · sub_steps_split`.

**WU-16 migration 추가 필드**: `migrated_from` (WORK-LOG.md 원본 line range) · `migrated_by` (이관 WU id). 추후 확장 이관 시 동일 패턴 사용.
