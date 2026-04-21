---
doc_id: learning-logs-index
title: "learning-logs/ — 장기 학습 패턴 자산 인덱스"
visibility: raw-internal
updated: 2026-04-21
---

# learning-logs/ — 학습 패턴 인덱스

> **역할**: WU 진행 중 발견된 재사용 가능한 문제-해결 패턴을 장기 자산으로 축적. Dual-track (OSS + Business) 양쪽에 재활용 가능한 지식 베이스.
> **그룹화**: 월 단위 디렉토리 (`YYYY-MM/`) + 개별 패턴 파일 (`P-<kebab-name>.md`).
> **필수 필드**: 각 패턴 파일 frontmatter 에 `visibility` 명시 (`raw-internal` | `business-only` | `oss-public`).

---

## 패턴 목록

### 2026-04 (WU-15 ~ WU-18 시점)

> WU-18 ("v2 운영 1주 검증 + retrospective") 에서 패턴 후보 3건 실체화 예정. 현재는 후보 명세만 보존.

| pattern_id | title | visibility | captured_from | reuse_count | status |
|:---|:---|:-:|:---|:-:|:-:|
| P-fuse-git-bypass | FUSE mount .git/index.lock 경합 우회 | oss-public | WU-7 ~ WU-14 (반복 관찰) | 0 | 후보 (WU-18) |
| P-compact-recovery | Compact mid-WU 복구 절차 (tmp/ + wip commit 보존) | raw-internal | WU-10 실전 | 0 | 후보 (WU-18) |
| P-two-step-wu-refresh | WU + WU.1 forward sha backfill 패턴 | oss-public | WU-7.1 / WU-10.1 / WU-14.1 | 0 | 후보 (WU-18) |

---

## Template

`_TEMPLATE.md` 참조. 필수 섹션: 문제 / 해결 패턴 / 재사용 체크리스트 / 관련 WU·세션.

## Visibility 규칙

- **`oss-public`**: 기술 일반론 패턴 (FUSE, git, 세션 복구 등) — OSS repo 공개 가능.
- **`business-only`**: Business 제품 특화 로직 / Solon 독자 알고리즘 — Business repo 한정.
- **`raw-internal`**: 개인 운영 경험 / 고객 raw 데이터 연관 / 미정 단계 — 양쪽 제외.

## OSS 배포 (Phase 2 이후)

`.visibility-rules.yaml` 의 `learning-logs/**` 규칙 참조 — 기본 제외, `oss-public` 라벨 패턴만 선별 포함.
